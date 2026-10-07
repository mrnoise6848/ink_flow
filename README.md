# InkFlow

**Keep handwritten notes and document annotations editable on your device, then export a visible copy when needed.**

Typing is not always the right way to capture a sketch, mark a diagram or review a PDF. InkFlow brings notebooks, ink strokes and imported page backgrounds into one local workflow, so writing and annotation do not require an account or cloud library.

The workflow is **Write → Annotate → Organize → Export**. Ink remains structured stroke data inside the app; exported PDF/PNG files are flattened derivatives intended for viewing and sharing.

## Writing and annotation

Use a finger or stylus with pen colors, stroke widths and highlighter. Pressure affects ink width when the platform reports it. The whole-stroke eraser removes InkFlow ink, not content in an imported background. Undo/redo, page duplication/reordering and an explicit move mode support editing without mixing drawing gestures with pan/zoom.

PDF, PNG, JPEG and WebP imports become page backgrounds. Notebooks, favorites, tags and local metadata search organize the library. **Search does not recognize handwriting or PDF text**; OCR and semantic search are not implemented.

## Keeping input responsive while saving

```text
Pointer samples → active ink repaint → committed vector strokes
    → bounded undo history + cached completed ink
    → debounced changed-page snapshot
    → serialized local write queue → temporary file + backup + rename
```

Active ink has its own repaint notifier. Completed strokes are cached in a disposable picture; metadata search does not load page ink. Undo retains shared stroke references for at most 80 edits instead of bitmap copies. JSON encoding/decoding runs in worker isolates.

Local writes are queued, flushed to a temporary file and renamed into place. A readable backup can recover damaged page data; a recovered backup is retained until a successful write. Save errors offer retry. Autosave is debounced by 500 ms, so an abrupt process kill can still lose the newest unsaved gesture. This is recovery-oriented persistence, not a guarantee against every storage failure.

Source: [ink canvas](lib/presentation/ink_canvas.dart), [editor](lib/presentation/editor_screen.dart), [local store](lib/data/local_store.dart). See [architecture](docs/architecture.md), [performance strategy](docs/performance.md) and [decisions](docs/decisions/).

## Export is a deliberate fidelity trade-off

The exporter renders backgrounds and strokes into a visible composite. PDF pages use JPEG derivatives with an 1800 px longest edge and quality 92; current-page PNG export is lossless at its rendered resolution. Original PDF text, forms, links and vector fidelity are not preserved in the output.

Pages are processed serially and JPEG compression runs in a worker. A 32 MiB compressed-payload budget rejects oversized PDF exports; this is not a 32 MiB total-process memory ceiling. Large notes need smaller exports or individual pages. See [exporter](lib/services/exporter.dart).

## Try it

Use the Flutter/Dart versions declared by the project:

```sh
flutter pub get
flutter run
```

Create a notebook and page, draw with finger/stylus, test undo/redo and whole-stroke erase, then import a PDF and annotate it. Switch pages, reopen the app to inspect saved ink, and export PDF/PNG through the OS delivery flow. A real handwriting page and annotated PDF are the most useful screenshots; none are included yet.

Android and iOS runners are configured, with an iOS 15 target. Adaptive desktop-sized layouts do not imply desktop runners or web persistence support.

## Verification and device gaps

```sh
flutter analyze
flutter build apk --debug
```

The [verification record](docs/verification.md) reports successful Android debug packaging, static analysis and formatting. It reports no automated tests or manual device/stylus checks. iOS/release builds, pressure handling, file pickers, sharing, accessibility and lifecycle behavior remain unverified on devices. No performance benchmark is claimed; these checks were not rerun for this documentation change.

## Local data and limits

There is no runtime backend, analytics, AI API or document-upload integration. OS sharing delivers the selected derivative to the chosen app; backups and encryption remain platform-controlled. InkFlow adds no document encryption. Deleted documents may leave private recovery files until app data is cleared. Export before uninstalling. See [privacy](docs/privacy.md).

Password-protected PDFs, office documents, handwriting recognition and cloud sync are outside scope. Undo history is session-only.

No project license is selected. Dependencies include pdfrx (MIT), pdf (Apache-2.0), image (MIT) and Flutter plugins under their respective licenses; the app's information button exposes package licenses.
