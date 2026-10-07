# Architecture

## Existing project (phase 1)
Flutter 3.47.4, Dart 3.13.3; SDK constraint ^3.13.3. Original project was
Flutter's counter template with Material widgets, StatefulWidget state, Navigator,
cupertino_icons 1.0.8 and flutter_lints 6.0.0. No persistence, routing framework,
localization, service layer or reusable domain components existed. Android package
com.noise.ink_flow and iOS com.noise.inkFlow, iOS target 15.0 are preserved.
Android uses the existing Gradle/Kotlin configuration, including pre-existing edits.
The obsolete counter widget test is removed. Tests are not executed per user instruction.

## Integration
Keep Flutter State/ChangeNotifier and Navigator. Domain contains notebook, document,
page and vector ink data. Data owns private local files and serialized writes.
Services handle file selection, PDF rendering/export and platform sharing.
Presentation contains library and editor screens with an isolated canvas repaint
notifier. No cloud or AI provider is part of startup or document operations.

## Verification policy
User explicitly requested no tests. Formatting, static analysis and a final Android
build are permitted; device behavior and performance remain unverified unless
explicitly reported otherwise.

Native plugins require the standard Flutter-generated iOS Podfile and Pods xcconfig
includes; these are added without changing the existing iOS 15 deployment target.
Image 4.10.1 (MIT) is a direct dependency reused from pdf's existing transitive
codec for worker-isolate JPEG encoding. All original dependency versions remain.
