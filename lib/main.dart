import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat2/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uclqvsgfysdtihatjqxy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjbHF2c2dmeXNkdGloYXRqcXh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3NjExMjIsImV4cCI6MjA1MjMzNzEyMn0.R2RrWD0jGF92UFmrkBVUi3hJULI3Fk8_2XLkWSvB3mY',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        barBackgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      home: const SplashPage(),
    );
  }
}
