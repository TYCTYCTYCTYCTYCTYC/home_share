import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ChoresStatisticsPage extends StatefulWidget {
  @override
  _ChoresStatisticsPageState createState() => _ChoresStatisticsPageState();
}

class _ChoresStatisticsPageState extends State<ChoresStatisticsPage> {
  int _selectedFilterIndex = 0;
  List<String> _filterChoices = ['This Month', 'Last Month', 'This Year'];

  List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    getChoreStatistics();
  }

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
  Future<void> getChoreStatistics() async {
    final response = await supabase.rpc('get_chore_statistics').execute();
    if (response.status == 200) {
      final List<dynamic> data = response.data;
      final newData = data
          .map((item) => ChartData(item['username'], item['total_chores']))
          .toList();
      setState(() {
        _chartData = newData;
      });
    } else {
      throw Exception('Failed to get chore statistics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: List.generate(_filterChoices.length,
                  (index) => _selectedFilterIndex == index),
              onPressed: (int index) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              selectedColor: Colors.black,
              fillColor: Colors
                  .amber, // set the color of the button when it's selected

              children: List.generate(
                  _filterChoices.length,
                  (index) => Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(_filterChoices[index]),
                      )),
            ),
          ),
          SizedBox(height: 16.0),
          Text('Chores by User'),
          SizedBox(height: 16.0),
          _chartData.isNotEmpty
              ? Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      majorGridLines:
                          const MajorGridLines(color: Colors.transparent),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      majorGridLines:
                          const MajorGridLines(color: Colors.transparent),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    series: <ChartSeries>[
                      BarSeries<ChartData, String>(
                        dataSource: _chartData,
                        color: Colors.amber,
                        xValueMapper: (ChartData data, _) => data.username,
                        yValueMapper: (ChartData data, _) => data.total_chores,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.arvo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : CircularProgressIndicator(),
        ],
      ),
    ));
  }
}

class ChartData {
  final String username;
  final int total_chores;
  //final int points;

  ChartData(this.username, this.total_chores);
}
