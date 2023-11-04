import 'package:customizable_chart/customizable_chart.dart';
import 'package:flutter/cupertino.dart';

class SuperGraphic extends StatelessWidget {
  SuperGraphic(this.size);
  Size size;

  @override
  Widget build(BuildContext context)
  {
    return CustomizableChart(size: size, barGroupDrawer: SuperBarGroupDrawer(ExampleData(), SuperBarPainter()));
  }

  List<SuperBarData> ExampleData()
  {
    List<SuperBarData> result = [];

    result.add(SuperBarData({"a": 8218.47, "y": 8358.03, "d": 8218.47, "k": 8337.67}, "07", "Eylul", "2023", "07", 1));
    result.add(SuperBarData({"a": 8291.55, "y": 8298.54, "d": 8127.88, "k": 8181.67}, "06", "Eylul", "2023", "06", 1));
    result.add(SuperBarData({"a": 8161.14, "y": 8236.14, "d": 8090.21, "k": 8236.14}, "05", "Eylul", "2023", "05", 1));
    result.add(SuperBarData({"a": 8141.33, "y": 8238.89, "d": 8126.01, "k": 8141.33}, "04", "Eylul", "2023", "04", 1));
    result.add(SuperBarData({"a": 7966.65, "y": 8060.92, "d": 7930.09, "k": 8056.12}, "01", "Eylul", "2023", "Eylul", 2));
    result.add(SuperBarData({"a": 7964.48, "y": 8005.82, "d": 7880.56, "k": 7917.93}, "31", "Agustos", "2023", "31", 1));
    result.add(SuperBarData({"a": 7963.44, "y": 8013.52, "d": 7865.58, "k": 7907.13}, "29", "Agustos", "2023", "29", 1));
    result.add(SuperBarData({"a": 7837.07, "y": 8008.78, "d": 7837.07, "k": 7941.73}, "28", "Agustos", "2023", "28", 1));
    result.add(SuperBarData({"a": 7545.17, "y": 7747.64, "d": 7407.94, "k": 7716.67}, "25", "Agustos", "2023", "25", 1));
    result.add(SuperBarData({"a": 7648.30, "y": 7872.81, "d": 7476.94, "k": 7491.94}, "24", "Agustos", "2023", "24", 1));
    result.add(SuperBarData({"a": 7829.40, "y": 7831.24, "d": 7602.24, "k": 7602.24}, "23", "Agustos", "2023", "23", 1));
    result.add(SuperBarData({"a": 7856.15, "y": 7902.95, "d": 7691.26, "k": 7771.30}, "22", "Agustos", "2023", "22", 1));
    result.add(SuperBarData({"a": 7446.35, "y": 7820.08, "d": 7411.52, "k": 7796.65}, "21", "Agustos", "2023", "21", 1));
    result.add(SuperBarData({"a": 7803.71, "y": 7815.83, "d": 7424.04, "k": 7513.29}, "18", "Agustos", "2023", "18", 1));
    result.add(SuperBarData({"a": 7675.06, "y": 7798.61, "d": 7633.13, "k": 7764.47}, "17", "Agustos", "2023", "17", 1));
    result.add(SuperBarData({"a": 7685.25, "y": 7734.41, "d": 7588.91, "k": 7662.26}, "16", "Agustos", "2023", "16", 1));
    result.add(SuperBarData({"a": 7763.70, "y": 7794.94, "d": 7550.30, "k": 7690.75}, "15", "Agustos", "2023", "15", 1));
    result.add(SuperBarData({"a": 7795.01, "y": 7868.74, "d": 7681.27, "k": 7737.38}, "14", "Agustos", "2023", "14", 1));
    result.add(SuperBarData({"a": 7453.42, "y": 7720.97, "d": 7397.63, "k": 7714.38}, "11", "Agustos", "2023", "11", 1));
    result.add(SuperBarData({"a": 7652.36, "y": 7766.12, "d": 7398.48, "k": 7441.50}, "10", "Agustos", "2023", "10", 1));
    result.add(SuperBarData({"a": 7423.11, "y": 7644.59, "d": 7367.03, "k": 7600.65}, "09", "Agustos", "2023", "09", 1));
    result.add(SuperBarData({"a": 7495.65, "y": 7504.38, "d": 7359.49, "k": 7412.20}, "08", "Agustos", "2023", "08", 1));
    result.add(SuperBarData({"a": 7434.53, "y": 7493.87, "d": 7399.02, "k": 7470.10}, "07", "Agustos", "2023", "07", 1));
    result.add(SuperBarData({"a": 7256.57, "y": 7427.10, "d": 7205.35, "k": 7400.57}, "04", "Agustos", "2023", "04", 1));
    result.add(SuperBarData({"a": 7296.00, "y": 7365.61, "d": 7200.81, "k": 7221.51}, "03", "Agustos", "2023", "03", 1));
    result.add(SuperBarData({"a": 7180.08, "y": 7336.11, "d": 7174.64, "k": 7258.54}, "02", "Agustos", "2023", "02", 1));
    result.add(SuperBarData({"a": 7209.59, "y": 7296.57, "d": 7113.31, "k": 7168.51}, "01", "Agustos", "2023", "Agustos", 2));
    result.add(SuperBarData({"a": 7143.14, "y": 7256.61, "d": 7117.09, "k": 7216.96}, "31", "Temmuz", "2023", "31", 1));
    result.add(SuperBarData({"a": 6925.41, "y": 7096.99, "d": 6912.00, "k": 7067.28}, "28", "Temmuz", "2023", "28", 1));

    return result;
  }
}

class SuperBarPainter extends BarPainter
{
  final redGradient = const [Color.fromARGB(255, 229, 210, 209), Color.fromARGB(255, 193, 136, 135), Color.fromARGB(255, 66, 28, 28)];
  final greenGradient = const [Color.fromARGB(255, 27, 68, 32), Color.fromARGB(255, 137, 196, 136), Color.fromARGB(255, 211, 232, 210)];
  final gradientStops = [0.25, 0.5, 1.0];

  @override
  void paintBar(Canvas canvas, Size size, Offset offset, BarData barData, Map<String, double> heights)
  {

    double openCloseTop, openCloseBottom, open = heights["a"]!, close = heights["k"]!;
    bool up = open > close; // because height is from topside
    openCloseTop = up ? heights["k"]! : heights["a"]!;
    openCloseBottom = up ? heights["a"]! : heights["k"]!;

    final gradient = LinearGradient(colors: up ? greenGradient : redGradient, stops: gradientStops,
        begin: Alignment(0, 1), end: Alignment(0, -1));

    Rect openClose = Rect.fromLTRB(offset.dx, openCloseTop, offset.dx + size.width, openCloseBottom);
    Rect highestLowest = Rect.fromLTRB(offset.dx + size.width * 3/7, heights["y"]!, offset.dx + size.width * 4/7, heights["d"]!);

    final paint = Paint()..shader = gradient.createShader(openClose)..style = PaintingStyle.fill;

    canvas.drawRect(highestLowest, Paint()..color = up ? greenGradient[1] : redGradient[1]);
    canvas.drawRect(openClose, paint);
  }
}
class SuperBarGroupDrawer extends BarGroupDrawer
{
  SuperBarGroupDrawer(super.barData, super.barPainter);

  @override
  drawBars(Canvas canvas, List<Rect> rects, List<int> indexesOfDisplayed, double unitScale, double minValue, double maxValue)
  {
    super.minValue = minValue; super.maxValue = maxValue;

    for(int i = 0; i < indexesOfDisplayed.length; i++)
    {
      BarData data = barData[indexesOfDisplayed[i]];
      barPainter.paintBar(canvas, rects[i].size, rects[i].topLeft, data, getHeightsFromReferenceValues(data.heightReferenceValues, unitScale));
    }
  }
}
class SuperBarData extends BarData
{
  String day, month, year;
  SuperBarData(super.heightReferenceValues, this.day, this.month, this.year, super.label, super.labelPriority);
}