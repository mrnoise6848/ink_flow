import 'package:flutter/material.dart';

import 'data/library.dart';
import 'presentation/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final library = Library();
  late final Future<void> ready = library.initialize();
  @override
  void dispose() {
    library.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'InkFlow',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff256d60)),
      scaffoldBackgroundColor: const Color(0xfff4f6f3),
      inputDecorationTheme: const InputDecorationTheme(filled: true),
    ),
    home: FutureBuilder(
      future: ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        if (snapshot.hasError)
          return Scaffold(
            body: Center(
              child: Text('Could not open library: ${snapshot.error}'),
            ),
          );
        return LibraryScreen(library: library);
      },
    ),
  );
}
