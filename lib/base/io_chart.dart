import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:convert';

class IOChart extends StatefulWidget {
  final props;

  IOChart(this.props);

  @override
  _IOChartState createState() => _IOChartState();
}

class _IOChartState extends State<IOChart> {
  /// Creates a [TimeSeriesChart] with sample data and no transition.
//  factory IOChart.withSampleData() {
//    return new IOChart(
//      _createSampleData(),
//    );
//  }
  Map msg = {};
  List io = [];

  @override
  void initState() {
    super.initState();
    _createSampleData();
  }

  @override
  void didUpdateWidget(IOChart oldWidget) {
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
        'read': measures['读取(k/s)'],
        'write': measures['写入(k/s)'],
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
          child: new charts.TimeSeriesChart(
            io,
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
                children: <Widget>[Text('${msg['time']}  读取: ${msg['read']}k/s, 写入: ${msg['write']}k/s')],
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

    if (widget.props['ajaxIO'].isNotEmpty) {
      data.clear();
      data2.clear();
      for (var o in widget.props['ajaxIO']) {
        Map temp = jsonDecode(o['io']);
        data.add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse('${temp['read']}')));
        data2.add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse('${temp['write']}')));
      }
    }
    io.clear();
    io = <charts.Series<TimeSeriesSales, DateTime>>[
      new charts.Series<TimeSeriesSales, DateTime>(
        id: '读取(k/s)',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: '写入(k/s)',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data2,
      ),
    ];
    return io;
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
