// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'TaskFlow';

  // Supabase - replace with your project values
  static const String supabaseUrl = 'https://xhgqbozfjuxuhzwqdiml.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhoZ3Fib3pmanV4dWh6d3FkaW1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4NDQwODksImV4cCI6MjA5MjQyMDA4OX0.ksqoPhc1pnwdxpW8w-F4g5zY4BnQ1Lp2g8cCqB3UKH4';

  // Task priorities
  static const List<String> priorities = ['Low', 'Medium', 'High', 'Critical'];

  // Task statuses
  static const List<String> statuses = ['Todo', 'In Progress', 'Review', 'Done'];
}
