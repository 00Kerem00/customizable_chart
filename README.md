It's a widget that allows you to design your bars with your own data structures and a lot of details.

![ghi2](https://github.com/00Kerem00/customizable_chart/assets/143900054/4c643398-f7e2-4f9c-81ed-1b8a9a70841f)
![ghi3](https://github.com/00Kerem00/customizable_chart/assets/143900054/87cc568a-e400-4334-babb-4e21c0ba5a1b)

It gives you an chart and rects and draws your bar design in those rects.

![ghi0](https://github.com/00Kerem00/customizable_chart/assets/143900054/a58d85c9-b5cf-4d8b-8804-0a669dc85a9d)
![ghi1](https://github.com/00Kerem00/customizable_chart/assets/143900054/80b82725-86bb-46ca-a6b7-ea17720b1f0b)

## Before started

You need to have knowledge of CustomPaint to use this.

## Usage

Let's start with adding dependency to "pubspec.yaml".

```yaml
dependencies:
  customizable_chart:
    git:
      url: "https://github.com/00Kerem00/customizable_chart.git"
      ref: master
```


Then create a dart file named as "sample_chart" that has the widget that will build our designed chart and import 'package:customizable_chart/customizable_chart.dart'.
We have 3 parent classes to design our chart. They are BarData, BarPainter, BarGroupDrawer.


### BarData
In BarData we store height reference values, labels, priority and other values. And add data we want to display in list of BarData

| Properties | Description                                                                                                                                                                                            | Type |
|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----|
| `heightReferenceValues` | Values that you want to show as heights in this chart.                                                                                                                                                 | Map<String, double> |
| `label` | Name of the value. This will appear bottom of bar.                                                                                                                                                     | String |
| `labelPriority` | When the chart zooms out some of your bar labels are not able to appear. They appear according to a period. If this period doesn't allow any high priority label to write it, writes above next label. | int |
| `minValue, maxValue` | Min and max values of heightReferenceValues to define indicator state. They determined in constructor.                                                                                                  |     |


### BarPainter
We design our bars with CustomPainter principles in BarPainter.

| Methods    | Description                                                                                                                                                                                       | Type |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------|
| `paintBar(Canvas canvas, Size size, Offset offset, BarData barData, Map<String, double> heights)`| This is the method you will override and add your own data drawings. Heights are determined by BarGroupDrawer from reference values according to other bars that are currently appearing in chart | void |


### BarGroupDrawer
If we want to draw anything without depending on bars, we can add some extras.
![ghi4](https://github.com/00Kerem00/customizable_chart/assets/143900054/bdb1b2b4-54fc-4ba0-83a3-9ae402ea515d)

| Properties   | Description                                                                  | Type          |
|--------------|------------------------------------------------------------------------------|---------------|
| `barData`    | The whole data that you want to show in this chart.                          | List<BarData> |
| `barPainter` |                                                                              | BarPainter    |
| `minValue, maxValue` | Min and Max values of heightReferenceValues in all currently appearing bars. | double     |
| Methods      |                                                                              |               |
| `void drawBars(Canvas canvas, List<Rect> rects, List<int> indexesOfDisplayed, double unitScale, double minValue, double maxValue)`  |                                                                              | void          |


We need to define 3 classes that extend these classes above.

```dart
class SampleBarData extends BarData
{
  // Actually if we want to make just a simple chart that contains one height reference value, we don't need to adding extra properties.
  // But if we want to show different values like color or shape we can make custom bar data. If you want to see sample of custom bar data check out SuperGraphic in examples.
}

class SampleBarPainter extends BarPainter
{
  // Gradient color of bars.
  final gradient = const LinearGradient(
      colors: [Color.fromARGB(255, 229, 210, 209), Color.fromARGB(255, 193, 136, 135), Color.fromARGB(255, 66, 28, 28)],
      stops:  [0.25, 0.5, 1.0],
      begin: Alignment(0, 1), end: Alignment(0, -1)
  );

  // This method gives the rect information as size and offset that we want to draw our bar inside of it
  @override
  void paintBar(Canvas canvas, Size size, Offset offset, BarData barData, Map<String, double> heights)				
  {
    Rect bar = Rect.fromLTRB(offset.dx, heights["value_0"], offset.dx + size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(gradient)..style = PaintingStyle.fill;

    canvas.drawRect(openClose, paint);
  }
}

class SampleBarGroupDrawer extends BarGroupDrawer
{
  SampleBarGroupDrawer(super.barData, super.barPainter);

  @override
  drawBars(Canvas canvas, List<Rect> rects, List<int> indexesOfDisplayed, double unitScale, double minValue, double maxValue)
  {
    // Attention: this assignment is necessary to use getHeightsFromReferenceValues()
    super.minValue = minValue; super.maxValue = maxValue;			

    for(int i = 0; i < indexesOfDisplayed; i++)
    {
      BarData data = barData[indexesOfDisplayed[i]];
      barPainter.paintBar(canvas, rects[i], rects[i].topLeft, data, getHeightsFromReferenceValues(data.heightReferenceValues, unitScale));
    }
  }

}
```


Now we will define the stateless widget class that builds our chart.

```dart
class SampleGraphic extends StatelessWidget
{
  SampleGraphic(this.Size)
  Size size;

  @override
  Widget build(BuildContext context)
  {
    return CustomizableChart(size: size, barGroupDrawer: SampleBarGroupDrawer(exampleData(), SampleBarPainter()));
  }

  List<SampleBarData> exampleData()
  {
    List<SampleBarData> result = [];
    result.add({"value_0": 8218.47});
    result.add({"value_0": 8291.55});
    result.add({"value_0": 8161.14});
    result.add({"value_0": 8141.33});
    result.add({"value_0": 7966.65});
    result.add({"value_0": 7964.48});
    result.add({"value_0": 7963.44});
    result.add({"value_0": 7837.07});
    result.add({"value_0": 7545.17});
    result.add({"value_0": 7648.30});
    result.add({"value_0": 7829.40});
    result.add({"value_0": 8218.47});
    result.add({"value_0": 8291.55});
    result.add({"value_0": 8161.14});
    result.add({"value_0": 8141.33});
    result.add({"value_0": 7966.65});
    result.add({"value_0": 7964.48});
    result.add({"value_0": 7963.44});
    result.add({"value_0": 7837.07});
    result.add({"value_0": 7545.17});
    result.add({"value_0": 7648.30});
    result.add({"value_0": 7829.40});

    return result;
  }
}
```
