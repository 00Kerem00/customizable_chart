library customizable_chart;

import 'package:flutter/cupertino.dart';
import 'package:customizable_chart/change_notifiers.dart';
import 'package:provider/provider.dart';


// Main widget
class CustomizableChart extends StatelessWidget
{
  BarGroupDrawer barGroupDrawer;
  static ChartBarsChangeNotifier? cbcn = null;
  static ChartIndicatorsChangeNotifier? cicn = null;

  CustomizableChart({super.key, required Size size, required this.barGroupDrawer})
  {
    this.size = size;
    unitScale = size.height / 64;

    if(cbcn == null)
      cbcn = ChartBarsChangeNotifier(barGroupDrawer.barData, unitScale, size);
    if(cicn == null)
      cicn = ChartIndicatorsChangeNotifier(cbcn!.GetIndexesOfDataToDisplay(), 0, cbcn!);

    cbcn!.SetCICN(cicn!);
  }

  late Size size;
  late double unitScale;

  @override
  Widget build(BuildContext context)
  {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => cbcn),
        ChangeNotifierProvider(create: (context) => cicn)
      ],
      child: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              size: Size.infinite,
              painter: ChartScaffold(unitScale),
            ),
          ),
          Consumer<ChartIndicatorsChangeNotifier>(
              builder: (context, cicn, child)
              {
                return SizedBox(
                    width: size.width, height: size.height,
                    child: CustomPaint(
                        size: Size.infinite,
                        painter: ChartIndicators(
                            ConfigurationDataOfChartIndicators(
                                size: size,
                                valueOfFirstIndicator: cicn.valueOfFirstIndicator,
                                valueRangeOfIndicators: cicn.valueRange,
                                indicatorCount: cicn.indicatorCount,
                                transitionScale: cicn.transitionScale,
                                unitScale: unitScale
                            )
                        )
                    )
                );
              }),
          Consumer<ChartBarsChangeNotifier>(
              builder:(context, cbcn, child)
              {
                return GestureDetector(
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                        size: Size.infinite,
                        painter: ChartBars(
                            ConfigurationDataOfChartBars(
                                unitScale: unitScale,
                                size: size,
                                scaleFactor: cbcn.scaleFactor,
                                indexesOfDataToDisplay: cbcn.GetIndexesOfDataToDisplay(),
                                barGroupDrawer: barGroupDrawer,
                                xPos: cbcn.xPos,
                                widthOfCanvas: size.width,
                                minValue: cicn!.valueOfFirstIndicator - cicn!.valueRange,
                                maxValue: cicn!.valueOfFirstIndicator + (cicn!.indicatorCount - 1) * cicn!.valueRange
                            )
                        )
                    ),
                  ),
                  onScaleStart: (details)
                  {
                    cbcn.resizeScaleStart();
                  },
                  onScaleUpdate: (details)
                  {
                    cbcn.resizeScaleUpdate(details.scale, details.localFocalPoint.dx);
                  },
                  onScaleEnd: (details)
                  {
                    cbcn.resizeScaleEnd();
                  },

                  onHorizontalDragUpdate: (details)
                  {
                    cbcn.shiftXPose(details.delta.dx);
                  },
                );
              }
          ),
        ],
      ),
    );
  }
}

// Custom painters
class ChartScaffold extends CustomPainter
{
  ChartScaffold(this.unitScale);
  double unitScale;

  @override
  void paint(Canvas canvas, Size size)
  {
    final paint = Paint()..color = Color.fromARGB(255, 187, 226, 249);;   // Color of the scaffold bars

    final verticalBar = Rect.fromLTRB(unitScale * 6, 0, unitScale * 6.5,  unitScale * 59);
    final horizontalBar = Rect.fromLTRB(unitScale * 6, unitScale * 58.5, size.width, unitScale * 59);

    canvas.drawRect(verticalBar, paint);
    canvas.drawRect(horizontalBar, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) { return false; }
}

class ConfigurationDataOfChartIndicators
{
  // Constants
  static const double maxIndicatorHeight = 5.0;
  static const int rangeMinFromMax = 53;

  // Data from context
  Size size;
  double unitScale;
  double valueOfFirstIndicator;           // the minimum value
  double valueRangeOfIndicators;
  int indicatorCount;
  double transitionScale;

  // Data to be calculated when start configuration
  late double thicknessOfIndicator;
  late double widthOfIndicator;
  late double centerOfIndicator;
  late double indicatorRange;     // (as distance)

  ConfigurationDataOfChartIndicators({
    required this.size,
    required this.unitScale,
    required this.valueOfFirstIndicator,
    required this.valueRangeOfIndicators,
    required this.indicatorCount,
    required this.transitionScale
  })
  {
    thicknessOfIndicator = unitScale / 4;
    widthOfIndicator = size.width - 6.5 * unitScale;
    centerOfIndicator = (size.width + 6.5 * unitScale) / 2;

    double defaultRange = rangeMinFromMax / indicatorCount;
    if(transitionScale == 0)
      indicatorRange =  defaultRange;
    else if(transitionScale > 0)
      indicatorRange = defaultRange - defaultRange * ((indicatorCount - 1) * transitionScale);
    else
      indicatorRange = defaultRange - defaultRange * ((indicatorCount - 2) * transitionScale);
  }
}
class ChartIndicators extends CustomPainter
{
  ChartIndicators(this.configData);
  ConfigurationDataOfChartIndicators configData;

  @override
  void paint(Canvas canvas, Size size)
  {
    // Build textPainter
    final paint = Paint()..color = Color.fromARGB(255, 170, 186, 204);
    final textStyle = TextStyle(color: Color.fromARGB(255, 218, 239, 245), fontSize: 16);
    final textPainter = TextPainter(
        text: TextSpan(
          text: "",
          style: textStyle,
        ),
        textDirection: TextDirection.ltr
    );

    // Define startHeight
    double startHeight = ConfigurationDataOfChartIndicators.maxIndicatorHeight + ConfigurationDataOfChartIndicators.rangeMinFromMax - configData.indicatorRange;

    // Define indicator count according to transitionScale
    int countOfIndicatorDrawingInLoop = configData.indicatorCount;
    if(configData.transitionScale < 0)
      countOfIndicatorDrawingInLoop--;

    // If transitionScale greater than 0.5 or less than -0.5, draw an indicator to the top
    if(configData.transitionScale.abs() > 0.5)
      DrawIndicator("${(configData.valueOfFirstIndicator + (countOfIndicatorDrawingInLoop + 1) * configData.valueRangeOfIndicators).floor()})",
          ConfigurationDataOfChartIndicators.maxIndicatorHeight, canvas, textPainter, textStyle, paint);

    // Draw the all indicators (starts from bottom)
    for(int i = 0; i < countOfIndicatorDrawingInLoop; i++)
    {
      double heightOfIndicator =  startHeight - i * configData.indicatorRange;
      DrawIndicator("${(configData.valueOfFirstIndicator + i * configData.valueRangeOfIndicators).floor()}", heightOfIndicator * configData.unitScale, canvas, textPainter, textStyle, paint);
    }
  }

  void DrawIndicator(String text, double height, Canvas canvas, TextPainter textPainter, TextStyle textStyle, Paint paint)
  {
    // Prepare the indicator
    final indicator = Rect.fromCenter(
        center: Offset(configData.centerOfIndicator, height),
        width: configData.widthOfIndicator,
        height: configData.thicknessOfIndicator);
    // Draw the indicator
    canvas.drawRect(indicator, paint);

    // Prepare the text
    textPainter.text = TextSpan(text: text, style: textStyle);
    textPainter.layout();
    // Write the text
    textPainter.paint(canvas, Offset(-2.5 * configData.unitScale, height -3 * configData.unitScale));
  }

  @override
  bool shouldRepaint(covariant ChartIndicators oldDelegate)
  { return oldDelegate.configData.indicatorCount != configData.indicatorCount || oldDelegate.configData.valueOfFirstIndicator != configData.valueOfFirstIndicator; }
}

class ConfigurationDataOfChartBars
{
  // Constants (normalized)
  static const double rightLimitOffset = 5.0;                                   // Offset of right limit from right
  static const double xZero = 8.0;                                              // Offset of start position. But not same as the left limit. Left limit will define with offset according to scaleFactor.
  static const double valueRangeOfTopOfBar = 53.0;                              // Offset of minimum value. If the bar has the min value, the top of rect is equals to sum of yMax and this.
  static const double yMax = 5.0;                                               // Offset of top of bar that has the maximum value

  // Data from context
  Size size;
  double unitScale;
  List<int> indexesOfDataToDisplay;
  BarGroupDrawer barGroupDrawer;
  double xPos;
  double scaleFactor;
  double widthOfCanvas;
  double maxValue;                                                              // The max value that displayable in chart
  double minValue;                                                              // And the min

  // Data to be calculated when start configuration
  late double xPosNFSU;                                                         // xPos normalized from unit scale
  late double leftLimit;                                                        // (normalized)
  late double rightLimit;                                                       // (normalized)
  late double distanceBetweenLimits;                                            // (normalized)
  late int timeWritePeriod;

  ConfigurationDataOfChartBars({
    required this.unitScale,
    required this.scaleFactor,
    required this.xPos,
    required this.indexesOfDataToDisplay,
    required this.barGroupDrawer,
    required this.widthOfCanvas,
    required this.maxValue,
    required this.minValue,
    required this.size
  })
  {
    xPosNFSU = xPos / unitScale;                                                // Normalize xPos from unit scale
    distanceBetweenLimits = widthOfCanvas / unitScale - (xZero + 2 * scaleFactor) - rightLimitOffset;     // Calculate distance between limits without unit scale
    leftLimit = xZero + (2 * scaleFactor).clamp(1, 8);                                        // Left limit has not a constant value. Then we calculate it according to scaleFactor.
    rightLimit = leftLimit + distanceBetweenLimits;
    timeWritePeriod = (11.5 / scaleFactor * (size.width / size.height)).floor().clamp(1, 8);
  }
}
class ChartBars extends CustomPainter
{
  ChartBars(this.configData);
  ConfigurationDataOfChartBars configData;

  // Gradient colors of bars
  final colors = [Color.fromARGB(255, 22, 47, 71), Color.fromARGB(255, 128, 164, 215), Color.fromARGB(255, 211, 230, 243)];
  final stops = [0.25, 0.5, 1.0];

  @override
  void paint(Canvas canvas, Size size)
  {
    List<Rect> barRects = [];

    // Define the side offsets of leftmost and rightmost bars.
    List<double> sidesOfBars = CalculateLeftAndRightSidesOfLeftAndRightBars();
    double rightSideOfTheRightColumn = sidesOfBars[0] * configData.unitScale; //0
    double leftSideOfTheRightColumn = sidesOfBars[1] * configData.unitScale;  //1
    double rightSideOfTheLeftColumn = sidesOfBars[2] * configData.unitScale;  //2
    double leftSideOfTheLeftColumn = sidesOfBars[3] * configData.unitScale;   //3

    // Create bounds of bars
    double bottomSide = (ConfigurationDataOfChartBars.valueRangeOfTopOfBar + 5) * configData.unitScale;
    double topSide = 5 * configData.unitScale;

    barRects.add(Rect.fromLTRB(leftSideOfTheRightColumn, topSide, rightSideOfTheRightColumn, bottomSide));
    int countOfBars = configData.indexesOfDataToDisplay.length - 1;
    for(int i = 1; i < countOfBars; i++)
      barRects.add(Rect.fromLTRB(
          leftSideOfTheRightColumn - (i * 2) * configData.scaleFactor *  configData.unitScale, topSide,
          leftSideOfTheRightColumn - (i * 2 - 1) * configData.scaleFactor *  configData.unitScale, bottomSide));
    barRects.add(Rect.fromLTRB(leftSideOfTheLeftColumn, topSide, rightSideOfTheLeftColumn, bottomSide));

    // Use the barGroupDrawer to draw customized bars
    configData.barGroupDrawer.drawBars(canvas, barRects, configData.indexesOfDataToDisplay, configData.unitScale, configData.minValue, configData.maxValue);

    DrawLabels(canvas, barRects);
  }

  void DrawLabels(Canvas canvas, List<Rect> rects)
  {
    // Build textPainter
    TextStyle textStyle = TextStyle(color: Color.fromARGB(255, 218, 239, 245), fontSize: 16);
    TextPainter textPainter = TextPainter();
    textPainter.text = TextSpan(text: "", style: textStyle);
    textPainter.textAlign = TextAlign.center;
    textPainter.textDirection = TextDirection.ltr;
    textPainter.layout();

    int index = configData.indexesOfDataToDisplay.last;
    Map<int, String> lastLabels = {};
    for(int i = 0; i < rects.length; i++)
    {
      BarData data = configData.barGroupDrawer.barData[index - i];
      String label = "";
      bool timeWrite = (index - i) % configData.timeWritePeriod == 0;
      if(timeWrite)
      {
        List<int> keys = lastLabels.keys.toList()..sort();
        for(int j in keys)
          if(j > data.labelPriority)
            label += lastLabels[j]! + "\n";
        label += data.label;

        textPainter.text = TextSpan(text: label, style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, Offset((rects[rects.length - 1 - i].left + rects[rects.length - 1 - i].right - textPainter.width) / 2, configData.size.height - 3 * configData.unitScale));
        lastLabels = {};
      }
      else
        lastLabels[data.labelPriority] = data.label;
    }
  }

  List<double> CalculateLeftAndRightSidesOfLeftAndRightBars()
  {
    List<double> result = [0, 0, 0, 0];               // 0: right of right bar, 1: left of right bar, 2: right of left bar, 3: left of left bar

    double remainder = configData.xPosNFSU % (configData.scaleFactor * 2);
    if(remainder < configData.scaleFactor)                                      // Right limit is intersecting the right bar
        {
      result[0] = configData.rightLimit;
      result[1] = configData.rightLimit - (configData.scaleFactor - remainder);
      double d = (configData.indexesOfDataToDisplay.length * configData.scaleFactor * 2 - remainder - configData.scaleFactor) - configData.distanceBetweenLimits;
      if(d > 0)                                                                 // Left limit is intersecting the right bar
          {
        result[3] = configData.leftLimit;
        result[2] = configData.leftLimit + (configData.scaleFactor - d);
      }
      else                                                                      // Left limit is not intersecting the right bar
          {
        result[3] = configData.leftLimit - d;
        result[2] = result[3] + configData.scaleFactor;
      }
    }
    else                                                                        // Right limit is not intersecting the right bar
        {
      result[0] = configData.rightLimit - (configData.scaleFactor * 2 - remainder);
      result[1] = result[0] - configData.scaleFactor;

      double d = (configData.scaleFactor - remainder + configData.indexesOfDataToDisplay.length * configData.scaleFactor * 2) - configData.distanceBetweenLimits;
      if(d > 0)                                                                 // Left limit is intersecting the right bar
          {
        result[3] = configData.leftLimit;
        result[2] = configData.leftLimit + (configData.scaleFactor - d);
      }
      else                                                                      // Left limit is not intersecting the right bar
          {
        result[3] = configData.leftLimit - d;
        result[2] = result[3] + configData.scaleFactor;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant ChartBars oldDelegate)
  { return oldDelegate.configData.xPos != configData.xPos || oldDelegate.configData.scaleFactor != configData.scaleFactor; }
}

// Abstract managers used for create custom bars with custom data types
class BarData
{
  Map<String, double> heightReferenceValues;
  String label;
  int labelPriority;
  late double minValue, maxValue;
  BarData(this.heightReferenceValues, this.label, this.labelPriority)
  {
    minValue = double.infinity;
    maxValue = double.negativeInfinity;
    heightReferenceValues.forEach((key, value)
    {
      if(value < minValue) minValue = value;
      if(value > maxValue) maxValue = value;
    });
  }
}
class BarGroupDrawer
{
  late double minValue, maxValue;
  List<BarData> barData;                                                        // The whole data
  BarPainter barPainter;
  BarGroupDrawer(this.barData, this.barPainter);

  void drawBars(Canvas canvas, List<Rect> rects, List<int> indexesOfDisplayed, double unitScale, double minValue, double maxValue){}

  Map<String, double> getHeightsFromReferenceValues(Map<String, double> referenceValues, double unitScale)
  {
    Map<String, double> result = {};

    double valueRange = maxValue - minValue;
    referenceValues.forEach((key, value)
    {
      double headerOfValue = value - minValue;  // This will be used for get height according to value range
      result[key] = (5 + ConfigurationDataOfChartBars.valueRangeOfTopOfBar * (1 - headerOfValue / valueRange)) * unitScale;
    });

    return result;
  }
}
class BarPainter
{
  void paintBar(Canvas canvas, Size size, Offset offset, BarData bardata, Map<String, double> heights) {}
}