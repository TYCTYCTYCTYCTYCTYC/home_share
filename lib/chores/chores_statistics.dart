import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChoresStatisticsPage extends StatefulWidget {
  @override
  _ChoresStatisticsPageState createState() => _ChoresStatisticsPageState();
}

class _ChoresStatisticsPageState extends State<ChoresStatisticsPage> {
  List<ChartData> _chartData = [
    ChartData('User A', 60),
    ChartData('User B', 80),
    ChartData('User C', 40),
    ChartData('User D', 50),
  ];

// List<ChartData> _getData() {
//   switch (_selectedFilter) {
//     case 'This Month':
//       return _getThisMonthData();
//     case 'Last Month':
//       return _getLastMonthData();
//     case 'This Year':
//       return _getThisYearData();
//     default:
//       return _getAllData();
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Bar Chart Sample'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton(
                //value: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    //_selectedFilter = value;
                  });
                },
                items: [
                  DropdownMenuItem(
                      value: 'This Month', child: Text('This Month')),
                  DropdownMenuItem(
                      value: 'Last Month', child: Text('Last Month')),
                  DropdownMenuItem(
                      value: 'This Year', child: Text('This Year')),
                ],
              ),
              SizedBox(height: 16.0),
              Text('Chores by User'),
              SizedBox(height: 16.0),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries>[
                    BarSeries<ChartData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ChartData data, _) => data.user,
                      yValueMapper: (ChartData data, _) => data.points,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class ChartData {
  final String user;
  final double points;

  ChartData(this.user, this.points);
}
