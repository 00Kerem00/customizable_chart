import 'dart:async';
import 'dart:math';

import 'package:customizable_chart/customizable_chart.dart';
import 'package:flutter/cupertino.dart';

class ChartBarsChangeNotifier extends ChangeNotifier
{
  void SetCICN(ChartIndicatorsChangeNotifier cicn){this.cicn = cicn;}
  late ChartIndicatorsChangeNotifier cicn;

  static const int rightLimitUnit = 5;
  static const int xZeroUnit = 8;

  ChartBarsChangeNotifier(this.wholeData, this.scaleUnit, this.sizeOfCanvas)
  {
    // Define xPos and scaleFactor limitations according to aspect ratio and scaleFactor
    double distanceWithoutScaleFactor =  sizeOfCanvas.width / scaleUnit - xZeroUnit - rightLimitUnit;
    distanceBetweenLimits = distanceWithoutScaleFactor - 2 * scaleFactor;
    maxXPose = wholeData.length * 2 * scaleFactor * scaleUnit - sizeOfCanvas.width + xZeroUnit * scaleUnit + (3 * scaleFactor) * scaleUnit;
    maxScaleFactor *= sizeOfCanvas.width / sizeOfCanvas.height;
    minScaleFactor *= sizeOfCanvas.width / sizeOfCanvas.height;

    // Set old displaying data status
    calculateIndexOfFirstBar();
    oldIndexOfFirstBar = indexOfFirstBar;
    countOfBarsToDisplay = ((distanceBetweenLimits - scaleFactor) / (scaleFactor * 2)).round() + 1;
    oldCountOfBarsToDisplay = countOfBarsToDisplay;
  }

  double scaleUnit;
  List<BarData> wholeData;

  late double distanceBetweenLimits;
  Size sizeOfCanvas;

  double scaleFactor = 6;                                                       // current scale factor
  double xPos = 0;                                                              // current xPos

  double minXPose = 0, maxXPose = 100;                                          // limit of xPos
  double minScaleFactor = 1, maxScaleFactor = 8;                                // limits of scale factor

  double sfForResize = 0;                                                       // these registers when resize started
  double xpForResize = 0;

  int indexOfFirstBar = 0;                                                      // The information for define indexes of bar data to display
  int countOfBarsToDisplay = 0;
  // Information of the previous state.
  // It will compared to current state and check there is any change in appering data.
  // If there is any change the state of indicator will be updated
  int oldIndexOfFirstBar = 0;
  int oldCountOfBarsToDisplay = 0;

  // Resize methods
  void resizeScaleStart() { xpForResize = xPos; sfForResize = scaleFactor; }
  void resizeScaleUpdate(double resizeScale, double localFocalPointDx)
  {
    // Reduce resize scale and if greater or less than limits cancel the function
    num powResizeScaleWith05 = pow(resizeScale, 0.5);
    double rawScale = (powResizeScaleWith05 * sfForResize);
    if(rawScale < minScaleFactor || rawScale > maxScaleFactor){ return; }

    scaleFactor = rawScale;

    // Redefine the xPos limits
    distanceBetweenLimits = sizeOfCanvas.width / scaleUnit - (xZeroUnit + 2 * scaleFactor) - rightLimitUnit;
    maxXPose = (wholeData.length * 2 * scaleFactor + xZeroUnit + (2 * scaleFactor) + rightLimitUnit - scaleFactor) * scaleUnit - sizeOfCanvas.width;

    // Set xPos according to localFocalPointDx
    xPos = ((sizeOfCanvas.width - localFocalPointDx + xpForResize) * powResizeScaleWith05 - (sizeOfCanvas.width - localFocalPointDx)).clamp(minXPose, maxXPose);

    // If there is any change in appearing data redraw the ChartIndicator then redraw ChartBars according to ChartIndicator state.
    // Else redraw ChartBars only.
    if(IndicatorStateHasChanged())
    {
      cicn.SetIndicatorState(GetIndexesOfDataToDisplay());
      WidgetsBinding.instance.addPostFrameCallback((_)
      {
        cicn.notifyListeners();
        notifyListeners();
      });
    }
    else
      notifyListeners();

    // wtf???
    notifyListeners();
    cicn.notifyListeners();
  }
  void resizeScaleEnd()
  {
    xpForResize = xPos;
    sfForResize = scaleFactor;
  }
  double getScaleFactor()
  {
    return scaleFactor;
  }

  // Shift xPos methods
  void shiftXPose(double shift)
  {
    xPos = (xPos + shift).clamp(minXPose, maxXPose);

    if(IndicatorStateHasChanged())
    {
      cicn.SetIndicatorState(GetIndexesOfDataToDisplay());
      WidgetsBinding.instance.addPostFrameCallback((_)
      {
        cicn.notifyListeners();
        notifyListeners();
      });
    }
    else { notifyListeners(); }
  }
  double getXPos()
  {
    return xPos;
  }

  List<int> GetIndexesOfDataToDisplay()
  {
    List<int> result = [];

    for(int i = 0; i < countOfBarsToDisplay; i++)
      result.add(indexOfFirstBar + i);

    return result;
  }

  // Checks is there any change in data to display
  bool IndicatorStateHasChanged()                                               // It is necessary to call in shiftXPose and resizeScale
  {
    oldCountOfBarsToDisplay = countOfBarsToDisplay;
    double r = (xPos / scaleUnit) % (2 * scaleFactor);

    if(r < scaleFactor)
      countOfBarsToDisplay = ((distanceBetweenLimits - (scaleFactor - r)) / (2 * scaleFactor)).round() + 1;
    else
      countOfBarsToDisplay = ((distanceBetweenLimits - 3 * scaleFactor + r) / (scaleFactor * 2)).round() + 1;

    oldIndexOfFirstBar = indexOfFirstBar;
    calculateIndexOfFirstBar();

    return oldCountOfBarsToDisplay != countOfBarsToDisplay || oldIndexOfFirstBar != indexOfFirstBar;
  }
  void calculateIndexOfFirstBar()
  {
    while(xPos / scaleUnit < 2 * scaleFactor * indexOfFirstBar + scaleFactor) indexOfFirstBar--;
    while(xPos / scaleUnit > 2 * scaleFactor * indexOfFirstBar + scaleFactor) indexOfFirstBar++;
  }
}

class ChartIndicatorsChangeNotifier extends ChangeNotifier
{
  static int maxIndicatorCount = 8;

  ChartBarsChangeNotifier cbcn;

  ChartIndicatorsChangeNotifier(List<int> indexesOfValuesToDisplay, this.transitionScale, this.cbcn)
  {
    SetIndicatorState(indexesOfValuesToDisplay);
  }
  double valueOfFirstIndicator = 0;
  double valueRange = 0;
  int indicatorCount = 0;
  double transitionScale;

  void SetIndicatorState(List<int> indexesOfValuesToDisplay)
  {
    // Find the maximum range among of height reference values
    double differenceMinWithMax = 0;
    double minValue = double.infinity, maxValue = double.negativeInfinity;
    for(int i = 0; i < indexesOfValuesToDisplay.length; i++)
    {
      double min = cbcn.wholeData[indexesOfValuesToDisplay[i]].minValue, max = cbcn.wholeData[indexesOfValuesToDisplay[i]].maxValue;
      if(min < minValue) minValue = min;
      if(max > maxValue) maxValue = max;
    }
    differenceMinWithMax = maxValue - minValue;

    // Define the value range of indicators.
    double distance = 5.0;
    while(differenceMinWithMax / distance > maxIndicatorCount)
      distance *= 2;

    // Define the first indicator value and count of indicators. (first is the minimum) (value of first indicator can not be negative or zero)
    int minOverD = ((minValue / distance).floor()), maxOverD = ((maxValue / distance).floor());
    valueOfFirstIndicator = (minOverD - 0) * distance;
    int increase = 0;
    while(valueOfFirstIndicator <= 0){ increase++; valueOfFirstIndicator = distance * (minOverD + increase - 0);}

    // Assign the needed values except valueOfFirstIndicator. (Because it assigned just before)
    valueRange = distance;
    indicatorCount = maxOverD - minOverD + 2 - increase;
    //notifyListeners();
  }

  void StartStateChangeAnimation(bool increasing)
  {
    transitionScale = 0;
    double shiftUnit;
    increasing ? shiftUnit = 0.05 : shiftUnit = -0.05;
    Timer.periodic(Duration(milliseconds: 5), (timer)
    {
      transitionScale += shiftUnit;
      notifyListeners();
      if(transitionScale.abs() >= 1) timer.cancel();
    });
  }
  void SetTransitionScale(transitionScale) { this.transitionScale = transitionScale; notifyListeners();}

}