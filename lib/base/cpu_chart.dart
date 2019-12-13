import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class CpuChart extends StatefulWidget {
  final props;

  CpuChart(this.props);

  @override
  _CpuChartState createState() => _CpuChartState();
}

class _CpuChartState extends State<CpuChart> {
  /// Creates a [TimeSeriesChart] with sample data and no transition.
//  factory CpuChart.withSampleData() {
//    return new CpuChart(
//      _createSampleData(),
//    );
//  }

  Map msg = {};
  List cpu = [];

  @override
  void initState() {
    super.initState();
    _createSampleData();
  }

  @override
  void didUpdateWidget(CpuChart oldWidget) {
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
        'cpu': measures['Sales']
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 300,
          child: charts.TimeSeriesChart(
            cpu,
            animate: true,
            // Provide a tickProviderSpec which does NOT require that zero is
            // included.
            primaryMeasureAxis:
                new charts.NumericAxisSpec(tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false)),
            selectionModels: [
              new charts.SelectionModelConfig(
                  type: charts.SelectionModelType.info, changedListener: _onSelectionChangedUser)
            ],
          ),
        ),
        msg.isNotEmpty
            ? Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('${msg['time']}  cpu占用率: ${msg['cpu']}%')],
                ),
              )
            : Container(
                height: 20,
              ),
      ],
    );
  }

  /// Create one series with sample hard coded data.
  _createSampleData() {
    final data = [
      TimeSeriesSales(DateTime(2017, 9, 19), 5),
    ];

    if (widget.props['ajaxCpu'].isNotEmpty) {
      data.clear();
      for (var o in widget.props['ajaxCpu']) {
        data.add(TimeSeriesSales(DateTime.tryParse(o['time']), double.tryParse(o['cpu'])));
      }
    }
    cpu.clear();
    cpu = <charts.Series<TimeSeriesSales, DateTime>>[
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];

    return cpu;
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
