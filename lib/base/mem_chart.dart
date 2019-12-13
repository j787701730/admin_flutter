import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:convert';

class MemChart extends StatefulWidget {
  final props;

  MemChart(this.props);

  @override
  _MemChartState createState() => _MemChartState();
}

class _MemChartState extends State<MemChart> {
  /// Creates a [TimeSeriesChart] with sample data and no transition.
//  factory MemChart.withSampleData() {
//    return new MemChart(
//      _createSampleData(),
//    );
//  }

  Map msg = {};
  List mem = [];

  @override
  void initState() {
    super.initState();
    _createSampleData();
  }

  @override
  void didUpdateWidget(MemChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _createSampleData();
  }

  _onSelectionChangedUser(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    DateTime time;
    final measures = <String, num>{};
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.time;
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.sales;
      });
    }

    setState(() {
      msg = {
        'time': '${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}',
        'used': measures['已使用(M)'],
        'share': measures['共享(M)']
      };
    });
    // Request a build.
//    if (!mounted) return;
//    setState(() {
//      _userMonth = time;
//      _userNum = measures;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 300,
          child: charts.TimeSeriesChart(
            mem,
            animate: true,
            // Provide a tickProviderSpec which does NOT require that zero is
            // included.
            primaryMeasureAxis:
                new charts.NumericAxisSpec(tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false)),
            behaviors: [
              new charts.SeriesLegend(
                // Positions for "start" and "end" will be left and right respectively
                // for widgets with a build context that has directionality ltr.
                // For rtl, "start" and "end" will be right and left respectively.
                // Since this example has directionality of ltr, the legend is
                // positioned on the right side of the chart.
                position: charts.BehaviorPosition.top,
                // For a legend that is positioned on the left or right of the chart,
                // setting the justification for [endDrawArea] is aligned to the
                // bottom of the chart draw area.
                outsideJustification: charts.OutsideJustification.middleDrawArea,
                // By default, if the position of the chart is on the left or right of
                // the chart, [horizontalFirst] is set to false. This means that the
                // legend entries will grow as new rows first instead of a new column.
                horizontalFirst: true,
                // By setting this value to 2, the legend entries will grow up to two
                // rows before adding a new column.
                desiredMaxRows: 2,
                // This defines the padding around each legend entry.
                cellPadding: new EdgeInsets.only(right: 20.0, bottom: 4.0),
                // Render the legend entry text with custom styles.
                entryTextStyle: charts.TextStyleSpec(color: charts.Color(r: 127, g: 63, b: 191), fontSize: 11),
              ),
            ],
            selectionModels: [
              new charts.SelectionModelConfig(
                  type: charts.SelectionModelType.info, changedListener: _onSelectionChangedUser)
            ],
          ),
        ),
        msg.isEmpty
            ? Container(
                height: 20,
              )
            : Wrap(
                children: <Widget>[Text('${msg['time']}  已使用: ${msg['used']}M, 共享: ${msg['share']}M')],
              )
      ],
    );
  }

  /// Create one series with sample hard coded data.
  List _createSampleData() {
    final data = [
      new TimeSeriesSales(new DateTime.now(), 5),
    ];
    final data2 = [
      new TimeSeriesSales(new DateTime.now(), 5),
    ];

    if (widget.props['ajaxMem'].isNotEmpty) {
      data.clear();
      data2.clear();
      for (var o in widget.props['ajaxMem']) {
        Map temp = jsonDecode(o['mem']);
        data.add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse('${temp['used']}')));
        data2.add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse('${temp['share']}')));
      }
    }

    mem.clear();
    mem = <charts.Series<TimeSeriesSales, DateTime>>[
      new charts.Series<TimeSeriesSales, DateTime>(
        id: '已使用(M)',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: '共享(M)',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data2,
      ),
    ];

    return mem;
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
