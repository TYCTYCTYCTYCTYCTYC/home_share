import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:home_share/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChoresStatisticsPage extends StatefulWidget {
  @override
  _ChoresStatisticsPageState createState() => _ChoresStatisticsPageState();
}

class _ChoresStatisticsPageState extends State<ChoresStatisticsPage> {
  int _selectedFilterIndex = 0;
  List<String> _filterChoices = ['This Week', 'Last Week', 'This Month'];

  int _selectedValueIndex = 0;
  List<String> _valueChoices = ['Total Chores', 'Total Points'];

  List<ChartData> _chartData = [];
  List<PointsData> _pointsData = [];

  bool _isDropdownOpen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataStatistics();
    setState(() {
      _isLoading = true;
    });
  }

  Future<void> getDataStatistics() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = currentUser?.id;
    final now = DateTime.now().toUtc();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).toLocal();
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    final startOfMonth = DateTime(now.year, now.month, 1).toLocal();
    final endOfMonth = DateTime(now.year, now.month + 1, 0).toLocal();
    String startDate;
    String endDate;

    String startDateToString(DateTime date) {
      return date.toIso8601String();
    }

    String endDateToString(DateTime date) {
      return date.add(Duration(days: 1)).toIso8601String();
    }

    switch (_selectedFilterIndex) {
      case 0: // This Week
        startDate =
            startDateToString(now.subtract(Duration(days: now.weekday - 1)));
        endDate = endDateToString(
            now.add(Duration(days: DateTime.daysPerWeek - now.weekday)));
        break;
      case 1: // Last Week
        startDate = startDateToString(
            now.subtract(Duration(days: now.weekday + DateTime.daysPerWeek)));
        endDate = endDateToString(now.subtract(Duration(days: now.weekday)));
        break;
      case 2: // This Month
        startDate = startDateToString(DateTime(now.year, now.month, 1));
        endDate = endDateToString(DateTime(now.year, now.month + 1, 0));
        break;
      default:
        startDate = startDateToString(startOfMonth);
        endDate = endDateToString(endOfMonth);
    }

    if (_selectedValueIndex == 0) {
      final response = await supabase.rpc('get_chore_statistics', params: {
        'current_user_id': userId,
        'filter_start_date': startDate,
        'filter_end_date': endDate
      }).execute();
      if (response.status == 200) {
        final List<dynamic> data = response.data;

        final newData = data
            .map((item) => ChartData(item['username'], item['total_chores']))
            .toList();
        setState(() {
          _chartData = newData;
        });
      }
    } else if (_selectedValueIndex == 1) {
      final response = await supabase.rpc('get_points_statistics', params: {
        'current_user_id': userId,
        'filter_start_date': startDate,
        'filter_end_date': endDate
      }).execute();
      if (response.status == 200) {
        final List<dynamic> data = response.data;

        final newData = data
            .map((item) => PointsData(item['username'], item['points']))
            .toList();
        setState(() {
          _pointsData = newData;
          _pointsData.sort((a, b) => a.points.compareTo(b.points));
        });
      }
    } else {
      throw Exception('Failed to get chore statistics');
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedFilter = _filterChoices[_selectedFilterIndex];

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(2.0),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () {
                            final RenderBox button =
                                context.findRenderObject() as RenderBox;
                            final RenderBox overlay = Overlay.of(context)!
                                .context
                                .findRenderObject() as RenderBox;
                            final buttonTopLeft = button
                                .localToGlobal(Offset.zero, ancestor: overlay);
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                buttonTopLeft.dx,
                                buttonTopLeft.dy,
                                buttonTopLeft.dx + button.size.width,
                                buttonTopLeft.dy + button.size.height,
                              ),
                              items: _valueChoices
                                  .asMap()
                                  .entries
                                  .map((entry) => PopupMenuItem(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      ))
                                  .toList(),
                            ).then((index) {
                              if (index != null &&
                                  index != _selectedValueIndex) {
                                setState(() {
                                  _selectedValueIndex = index;
                                  getDataStatistics();
                                });
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Text('Filter',
                                  style: TextStyle(color: Color(0xFF103465))),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.0),
                  ToggleButtons(
                    isSelected: List.generate(_filterChoices.length,
                        (index) => _selectedFilterIndex == index),
                    onPressed: (int index) {
                      setState(() {
                        _selectedFilterIndex = index;
                        getDataStatistics();
                      });
                    },
                    selectedColor: Colors.black,
                    fillColor: Colors.amber,
                    borderWidth: 1,
                    borderRadius: BorderRadius.circular(16),
                    constraints: BoxConstraints(
                      maxHeight: 36,
                    ),
                    children: List.generate(
                        _filterChoices.length,
                        (index) => Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(_filterChoices[index]),
                            )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Text(_selectedValueIndex == 0
              ? 'Amount of Chores Done'
              : 'Points Accumulated'),
          SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _chartData.isNotEmpty
                    ? Stack(
                        children: <Widget>[
                          Container(
                            child: _selectedValueIndex == 0
                                ? _isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _chartData.isNotEmpty
                                        ? Expanded(
                                            child: SfCartesianChart(
                                                primaryXAxis: CategoryAxis(
                                                  majorGridLines:
                                                      const MajorGridLines(
                                                          color: Colors
                                                              .transparent),
                                                  labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                primaryYAxis: NumericAxis(
                                                  majorGridLines:
                                                      const MajorGridLines(
                                                          color: Colors
                                                              .transparent),
                                                  labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                series: <
                                                    BarSeries<ChartData,
                                                        String>>[
                                                  BarSeries<ChartData, String>(
                                                    dataSource: _chartData,
                                                    xValueMapper:
                                                        (ChartData data, _) =>
                                                            data.username,
                                                    yValueMapper:
                                                        (ChartData data, _) =>
                                                            data.total_chores,
                                                    color: Colors.amber,
                                                  ),
                                                ]),
                                          )
                                        : Visibility(
                                            visible: true,
                                            child: Center(
                                              child: Text(
                                                'No data for $selectedFilter',
                                                style: GoogleFonts.arvo(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                : _selectedValueIndex == 1
                                    ? _isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : _pointsData.isNotEmpty
                                            ? Expanded(
                                                child: SfCircularChart(
                                                legend: Legend(
                                                    isVisible: true,
                                                    position:
                                                        LegendPosition.bottom,
                                                    overflowMode:
                                                        LegendItemOverflowMode
                                                            .wrap),
                                                series: <CircularSeries>[
                                                  RadialBarSeries<PointsData,
                                                      String>(
                                                    dataSource: _pointsData,
                                                    xValueMapper:
                                                        (PointsData data, _) =>
                                                            data.username,
                                                    yValueMapper:
                                                        (PointsData data, _) =>
                                                            data.points,
                                                    useSeriesColor: true,
                                                    enableTooltip: true,
                                                    cornerStyle:
                                                        CornerStyle.bothCurve,
                                                    radius: '100%',
                                                    innerRadius: '10%',
                                                    trackBorderWidth: 1,
                                                    trackColor:
                                                        Color(0xFF103465),
                                                    trackOpacity: 0.3,
                                                    gap: '0.8%',
                                                    maximumValue: 20,
                                                  ),
                                                ],
                                              ))
                                            : Visibility(
                                                visible: !_isLoading,
                                                child: Center(
                                                  child: Text(
                                                    'No data for $selectedFilter',
                                                    style: GoogleFonts.arvo(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                    : Container(),
                          ),
                        ],
                      )
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class ChartData {
  final String username;
  final int total_chores;

  ChartData(this.username, this.total_chores);
}

class PointsData {
  final String username;
  final int points;

  PointsData(this.username, this.points);
}
