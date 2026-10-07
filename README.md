# InkFlow

Write, annotate, organize — without the cloud.

Typed note apps often interrupt handwriting and PDF annotation. InkFlow gives you
private notebooks, real ink and a straightforward Write → Annotate → Organize →
Export workflow, without signing in.

## Features
- Notebooks, recent notes, favorites, tags and local metadata search.
- Finger/stylus handwriting, pressure where exposed by the platform, pen colors,
  stroke width, highlighter, whole-stroke eraser, undo/redo and clear.
- Add, duplicate, delete and reorder pages; rename notes/notebooks and move notes.
- Import PDF, PNG, JPEG and WebP through the system file picker.
- Annotate original page backgrounds, with an explicit move mode for pan/zoom.
- Autosave locally; atomic page files, backups, recovery and save retry.
- Export a document as PDF or the current page as PNG; system sharing.
- Keyboard shortcuts: Ctrl/Cmd+Z, Shift+Ctrl/Cmd+Z, Ctrl+Y, Ctrl/Cmd+S.

## Architecture
Existing Flutter State/ChangeNotifier + Navigator, with domain, private-file data,
service and presentation boundaries. No account, backend or AI API. See
[architecture](docs/architecture.md) and [decisions](docs/decisions).
Flutter 3.47.4 / Dart 3.13.3 and original platform identifiers are preserved.

## Run and build
```sh
flutter pub get
flutter run
flutter analyze
flutter build apk --debug
```
iOS uses standard CocoaPods plugin integration and the existing iOS 15 target.
Android and iOS are configured; desktop-sized layouts are adaptive, but desktop
platform runners and web persistence are not configured in this project.

## Performance
Active-page rendering, cached vector ink, bounded decoding, debounced page saves,
worker-isolate JSON/JPEG operations and capped undo history. Export processes pages
serially; a 32MiB compressed PDF payload budget prevents unlimited memory growth.
See [performance](docs/performance.md). Device performance is not benchmarked.

## Privacy
Documents are stored on device. Sharing sends the selected derivative through the
OS to an app you choose. No analytics or document uploads. OS backups/encryption
are platform-controlled; InkFlow does not add encryption. Deleted documents may
leave private recovery files until app data is cleared. See [privacy](docs/privacy.md).

## Limitations
- Flattened PDF exports preserve visible content, but lose searchable text, forms,
  links and source vector fidelity. Longest raster edge is 1800px, JPEG quality 92.
- Password-protected PDFs and office document formats are not supported.
- Eraser deletes whole InkFlow strokes, not original background content.
- Handwriting recognition, OCR, semantic search and cloud sync are future work.
- Extremely large exports must be split into smaller notes or exported page by page.
- Undo history is session-only; the latest gesture may be lost if the OS kills the
  process within the autosave debounce period. Export before uninstalling.
- Manual device/stylus checks have not been performed; no screenshots are fabricated.

## Verification
Tests are intentionally not executed or added, as requested. The obsolete template
counter test is removed. Static analysis and build results are recorded in
[verification](docs/verification.md). See [phases](docs/phases.md) for scope.

## Dependencies and licenses
pdfrx (MIT), pdf (Apache-2.0), image (MIT), file_selector, path_provider and
share_plus (BSD-3-Clause). No application source is copied. View package licenses
from the app's information button. This repository has no project license yet;
third-party package licenses do not automatically license InkFlow itself.
