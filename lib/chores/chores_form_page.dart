import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_share/main.dart';
import 'package:home_share/home.dart';

class ChoreFormPage extends StatefulWidget {
  const ChoreFormPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const ChoreFormPage());
  }

  @override
  _ChoreFormPageState createState() => _ChoreFormPageState();
}

class _ChoreFormPageState extends State<ChoreFormPage> {
  String? _category;
  String? _assignedUser;
  String? _description;
  DateTime? _startDate;
  int? _effortPoints;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Category'),
      value: _category,
      onChanged: (newValue) => setState(() => _category = newValue),
      items: <String>[
        'Cleaning',
        'Cooking',
        'Errands',
        'Gardening',
        'Other',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildAssignedUserField() {
    return FutureBuilder<List<String>>(
      future: _getHomeUsernames(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Assigned user'),
            value: _assignedUser,
            onChanged: (newValue) => setState(() => _assignedUser = newValue),
            items: snapshot.data!.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<List<String>> _getHomeUsernames() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;

    final response = await supabase
        .from('user_home')
        .select('home_id')
        .eq('user_id', currentUserId)
        .single()
        .execute();

    final homeId = response.data['home_id'] as int;

    final response2 = await supabase
        .from('user_home')
        .select('user_id')
        .eq('home_id', homeId)
        .execute();

    final userIds = response2.data
        .map<String>((item) => item['user_id'] as String)
        .toList();

    final response3 = await supabase
        .from('profiles')
        .select('username')
        .in_('id', userIds)
        .execute();

    final usernames = response3.data
        .map<String>((item) => item['username'] as String)
        .toList();

    return usernames;
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Short Description'),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 16, // set maximum length here

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
      onChanged: (newValue) => setState(() => _description = newValue),
    );
  }

  Widget _buildStartDateField() {
    return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF103465),
            onPrimary: Colors.white,
          ),
        ),
        child: DateTimePicker(
          type: DateTimePickerType.date,
          initialValue: _startDate.toString(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          dateLabelText: 'Start Date',
          onChanged: (value) {
            setState(() {
              _startDate = DateTime.parse(value);
            });
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please select start date';
            }
            return null;
          },
          onSaved: (value) => _startDate = DateTime.parse(value!),
        ));
  }

  Widget _buildEffortPointsField() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Effort points'),
      value: _effortPoints,
      onChanged: (newValue) => setState(() => _effortPoints = newValue),
      items: <int>[1, 2, 3].map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () async {
            if ((_assignedUser?.isEmpty ?? true) ||
                (_category?.isEmpty ?? true) ||
                (_description?.isEmpty ?? true) ||
                (_startDate == null) ||
                (_effortPoints == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill in all fields.',
                      style: GoogleFonts.arvo(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                  backgroundColor: Colors.amber,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            final currentUser = Supabase.instance.client.auth.currentUser;
            final userId = currentUser?.id;

            final assignedUserIdResponse = await supabase
                .from('profiles')
                .select('id')
                .eq('username', _assignedUser)
                .execute();
            final assignedUserId = assignedUserIdResponse.data[0]['id'];

            // insert data into the 'chores' table
            final response = await supabase.from('chores').insert({
              'created_user_id': userId,
              'assigned_user_id': assignedUserId,
              'category': _category,
              'description': _description,
              'start_date': _startDate.toString().substring(0, 10),
              'effort_points': _effortPoints,
              'status': false,
            }).execute();

            if (response.status == 201) {
              Fluttertoast.showToast(
                  msg: 'Chore created successfully.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.amber,
                  textColor: Colors.black,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: 'Failed to create chore.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.black,
                  fontSize: 16.0);
              throw Exception('Failed to create chore: ${response.status}');
            }

            Navigator.of(context).push(Home.route(initialIndex: 2));
          },
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF103465), // Set the background color here
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Done',
                  style: GoogleFonts.arvo(
                      textStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8.0),
              const Icon(Icons.check),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF103465),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Create a new chore',
            style: GoogleFonts.arvo(
                textStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategoryField(),
                const SizedBox(height: 16.0),
                _buildDescriptionField(),
                const SizedBox(height: 16.0),
                _buildAssignedUserField(),
                const SizedBox(height: 16.0),
                _buildStartDateField(),
                const SizedBox(height: 16.0),
                _buildEffortPointsField(),
                const SizedBox(height: 16.0),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
