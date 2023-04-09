import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCredentials{
  static const String APIKEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jZWR2d2lzYXRybmVycm9qZmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODA1NDExMjksImV4cCI6MTk5NjExNzEyOX0.zbYqEmU2OtBkl1B_qbQcaKOlPDMfD3UGP02I12ZE_a4";
  static const String APIURL = "https://mcedvwisatrnerrojfbe.supabase.co";

  static SupabaseClient supabaseClient = SupabaseClient(APIURL, APIKEY);
}