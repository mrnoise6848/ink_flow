# InkFlow

**A notebook for the things you would rather write by hand.**

Sketch an idea, mark up a diagram or work through a PDF in the same local notebook. InkFlow combines finger/stylus ink, imported page backgrounds and notebook organization on Android and iOS, without an account or cloud workflow.

Pages stay editable inside the app. When you need to send something, export a document as PDF or the current page as PNG and choose its destination through the operating system.

## Write on a page, or bring your own

- **Handwriting:** pen colors and widths, highlighter, pressure when reported by the device, whole-stroke erase and undo/redo.
- **Annotation:** import PDF, PNG, JPEG or WebP, draw over the original background, and switch to move mode for pan/zoom.
- **Notebooks:** add, duplicate, reorder and move pages/documents; use titles, tags, favorites and metadata search to find them again.

The eraser removes InkFlow strokes, leaving imported background content intact. Search covers organization metadata; handwriting recognition and OCR are future work.

## Ink is stored as strokes

A stroke retains its points, pressure and drawing style rather than becoming a screenshot of the page. This supports editable ink, whole-stroke erasing and an undo history built from shared stroke references.

The active stroke repaints separately from cached completed ink. Only the active page background is decoded, with a bounded resolution. Undo keeps at most 80 edits. These choices keep page content and pointer updates from forcing the same work through the rendering path. [Canvas](lib/presentation/ink_canvas.dart) · [Performance design](docs/performance.md)

## Saving without rewriting the notebook

Changed pages are saved after a 500 ms debounce. JSON work runs in worker isolates; a serialized write queue flushes a temporary file, retains a backup and renames the new page into place. Read failures can recover a valid backup, and save failures allow retry.

A recovered backup remains available until a successful write. The trade-off is explicit: undo is session-only, and a process kill during the debounce can lose the newest unsaved gesture. [Local storage](lib/data/local_store.dart)

## What leaves the notebook

PDF/PNG export combines the visible background and ink. PDF uses flattened page images with an 1800 px longest edge and JPEG quality 92; PNG preserves the rendered pixels losslessly. Source PDF text, forms, links and vector structure are not preserved in the exported copy.

The exporter processes pages serially, compresses JPEG in a worker and caps retained compressed PDF payloads at 32 MiB. That bounds one part of export memory, not the whole process. Larger documents need smaller exports or individual pages. [Exporter](lib/services/exporter.dart)

## Open a notebook

```sh
flutter pub get
flutter run
```

Use the project's declared Flutter/Dart toolchain. Create a page, draw, undo and erase; import a PDF and annotate it; reopen the app to inspect saved ink; then export both formats.

Android and iOS runners are configured, with an iOS 15 target. Desktop-sized layouts are adaptive, but desktop runners and web persistence are not configured.

## Build status and data

The [verification record](docs/verification.md) reports successful Android debug packaging, analysis and formatting. Device/stylus checks, automated tests and iOS/release verification remain open. Run static/build checks with `flutter analyze` and `flutter build apk --debug`.

Documents are private local files. Sharing sends the chosen derivative to the recipient app; OS backups/encryption are platform-controlled. InkFlow adds no document encryption, and deleted documents can leave private recovery files until app data is cleared. Password-protected PDFs and office files are unsupported. [Privacy](docs/privacy.md) · [Architecture](docs/architecture.md)

No project license is selected. Package licenses are available through the app's information button.
