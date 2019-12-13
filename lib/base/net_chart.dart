import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:convert';

class NETChart extends StatefulWidget {
  final props;

  NETChart(this.props);

  @override
  _NETChartState createState() => _NETChartState();
}

class _NETChartState extends State<NETChart> {
  /// Creates a [TimeSeriesChart] with sample data and no transition.
//  factory NETChart.withSampleData() {
//    return new NETChart(
//      _createSampleData(),
//    );
//  }

  Map net = {};
  Map netName = {};
  String netKey = '';

  _onSelectionChangedUser(charts.SelectionModel model, key) {
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
      netKey = key;
      netName['$key']['rx'] = '${measures['入流量(k/s)']}';
      netName['$key']['tx'] = '${measures['出流量(k/s)']}';
      netName['$key']['time'] = '${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}';
    });
  }

  @override
  void initState() {
    super.initState();
    _createSampleData();
  }

  @override
  void didUpdateWidget(NETChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _createSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: net.keys.toList().map<Widget>((item) {
        return Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 6),
              child: Text('网卡: $item'),
            ),
            Container(
              height: 300,
              child: charts.TimeSeriesChart(
                net['$item'],
                animate: true,
                // Provide a tickProviderSpec which does NOT require that zero is
                // included.
                primaryMeasureAxis: new charts.NumericAxisSpec(
                    tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false)),
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
                      type: charts.SelectionModelType.info,
                      changedListener: (charts.SelectionModel model) {
                        _onSelectionChangedUser(model, '$item');
                      }),
                ],
              ),
            ),
            netName[item]['rx'] == ''
                ? Container(
                    height: 20,
                  )
                : Container(
                    child: Text(
                      '${netName[item]['time']}  入流量: ${netName[item]['rx']}k/s, 出流量: ${netName[item]['tx']}k/s',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
          ],
        );
      }).toList(),
    );
  }

  /// Create one series with sample hard coded data.
  Map _createSampleData() {
    if (widget.props['ajaxNet'].isNotEmpty) {
      net.clear();
      for (var o in jsonDecode(widget.props['ajaxNet'][0]['net'])) {
        netName['${o['name']}'] = {'rx': '', 'tx': ''};
        net['${o['name']}'] = <charts.Series<TimeSeriesSales, DateTime>>[
          new charts.Series<TimeSeriesSales, DateTime>(
            id: '入流量(k/s)',
            colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
            domainFn: (TimeSeriesSales sales, _) => sales.time,
            measureFn: (TimeSeriesSales sales, _) => sales.sales,
            data: [],
          ),
          new charts.Series<TimeSeriesSales, DateTime>(
            id: '出流量(k/s)',
            colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
            domainFn: (TimeSeriesSales sales, _) => sales.time,
            measureFn: (TimeSeriesSales sales, _) => sales.sales,
            data: [],
          ),
        ];
      }

      for (var o in widget.props['ajaxNet']) {
        List temp = jsonDecode(o['net']);
        for (var t in temp) {
          if (net['${t['name']}'] != null) {
            net[t['name']]
                .toList()[0]
                .data
                .add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse('${t['rx']}')));
            net[t['name']]
                .toList()[1]
                .data
                .add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse('${t['tx']}')));
          }
        }
      }
    }

    return net;
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
