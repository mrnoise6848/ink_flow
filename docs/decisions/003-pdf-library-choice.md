# PDF and platform dependencies
Inspected pub.dev metadata, downloaded pubspecs, API source and licenses. Existing
SDK/dependencies are kept. No external application source was copied.

- pdfrx 2.6.5 / pdfrx_engine: MIT, active PDFium wrapper. Supports current Dart /
  Flutter and iOS 15. Native rendering is used rather than a custom PDF engine.
- pdf 3.13.1: Apache-2.0, established pure Dart PDF writer; used for derivatives.
- file_selector 1.1.0: BSD-3-Clause, Flutter-maintained platform document picker.
- share_plus 13.3.1: BSD-3-Clause, Flutter Community system share integration;
  SDK minimum Dart 3.10 / Flutter 3.38.1 fits the existing project.
- path_provider 2.1.6: BSD-3-Clause, private application storage directories.

Transitive additions include PDFium native binaries, image codecs, file-selector
platform adapters and share adapters. Package download/build may access the network;
InkFlow runtime never calls HTTP APIs or opens remote PDFs. Native parsers process
untrusted files: errors are surfaced, only a page-sized raster is held for viewing.
Sources: https://pub.dev/packages/pdfrx, https://pub.dev/packages/pdf,
https://pub.dev/packages/file_selector, https://pub.dev/packages/share_plus,
https://pub.dev/packages/path_provider. Licenses can be viewed in the app.
