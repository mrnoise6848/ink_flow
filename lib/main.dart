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
  late Future<void> ready = library.initialize();
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
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      'Could not open library: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        library.notebooks.clear();
                        library.documents.clear();
                        library.invalidNotebooks.clear();
                        library.invalidDocuments.clear();
                        ready = library.initialize();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return LibraryScreen(library: library);
      },
    ),
  );
}
