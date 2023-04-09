import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchAccounts() async {
  final String projectUrl = 'https://mcedvwisatrnerrojfbe.supabase.co';
  final String apiKey = '<your-api-key>';
  final String endpointUrl = '$projectUrl/rest/v1/accounts';

  final response = await http.get(
    Uri.parse(endpointUrl),
    headers: {
      'Content-Type': 'application/json',
      'apikey': apiKey,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Do something with the data, for example:
    for (final account in data) {
      print(account['name']);
      print(account['email']);
      // ...
    }
  } else {
    throw Exception('Failed to fetch accounts');
  }
}
