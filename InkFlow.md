# InkFlow — Final Flutter Product Specification & Agent Instructions

## 1. CRITICAL EXECUTION RULES

You are continuing development of an **EXISTING Flutter project**.

The current source code, project structure, architecture, Flutter/Dart version, package configuration, dependency versions, platform configuration, and build environment are considered valid.

Your task is to **extend the existing project**, not recreate or migrate it.

### NON-NEGOTIABLE RULES

1. **Do NOT recreate the project from scratch.**
2. **Work directly on the existing source code.**
3. **Do NOT migrate this project to Kotlin or another framework.**
4. **This project is Flutter + Dart.**
5. **Do NOT change the existing Flutter version.**
6. **Do NOT change the existing Dart version.**
7. **Do NOT change existing dependency versions unnecessarily.**
8. **Do NOT replace the current architecture without a strong technical reason.**
9. **Do NOT change Android/iOS platform configuration unnecessarily.**
10. **Do NOT change package/application IDs unnecessarily.**
11. **Do NOT introduce unnecessary packages.**
12. **Do NOT introduce unnecessary Flutter plugins.**
13. **Do NOT perform broad refactors unrelated to InkFlow.**
14. **Do NOT remove working functionality.**
15. **Do NOT silently migrate the project to another state-management or architecture solution.**
16. Reuse existing packages and utilities whenever they are sufficient.
17. You are explicitly allowed to use mature open-source Flutter packages, GitHub repositories, official Flutter examples, and platform integrations when they reduce unnecessary implementation effort or improve correctness.
18. Before using external code, inspect its license, compatibility, maintenance quality, and security implications.
19. Never blindly copy large portions of another project's source code.
20. Prefer mature libraries over reinventing complex PDF, file, rendering, or platform functionality.
21. **Do NOT run tests until ALL implementation phases are complete.**
22. You may inspect, create, or modify tests during implementation, but do not execute them before the final phase.
23. Never use fake production data, fake drawing behavior, fake persistence, or fake export functionality.
24. Do not claim a feature works unless it is actually implemented.

---

# 2. PRODUCT

## App Name

**InkFlow**

## Platform

Flutter

## Language

Dart

## Primary Goal

InkFlow is a **local-first handwriting and document annotation application**.

It allows users to:

* create handwritten notes
* draw with finger or stylus
* organize notes into notebooks
* annotate imported documents/PDFs
* undo/redo edits
* persist work locally
* export notes
* share documents
* work without an account or cloud backend

### Core value proposition

> **Write, annotate, organize — anywhere, without needing the cloud.**

---

# 3. WHY THIS PRODUCT EXISTS

Many note applications are optimized for typed text.

InkFlow focuses on a different workflow:

```text id="3z7g5f"
Think
 ↓
Write by hand
 ↓
Annotate
 ↓
Organize
 ↓
Export
```

A user should be able to open InkFlow and immediately create a handwritten page without configuring an account, subscription, or cloud storage.

---

# 4. IMPORTANT DIFFERENTIATION

InkFlow is NOT intended to be:

* a clone of Saber
* a clone of Goodnotes
* a clone of OneNote
* a generic notes CRUD application
* a cloud document platform

The portfolio goal is to demonstrate:

**Flutter rendering + gesture handling + custom interaction + local persistence + document/PDF workflows + performance**

The product should remain intentionally focused.

---

# 5. AI-ERA DESIGN PRINCIPLE

Do NOT force AI into the core product merely because AI is popular.

The core product must be useful without AI.

However, the architecture should make future AI-assisted functionality possible without rewriting the application.

Potential future capabilities could include:

* handwriting-to-text
* summarize selected notes
* convert notes into structured tasks
* extract key points from annotated documents
* semantic search
* AI-assisted organization

These are **future extension points**, not mandatory MVP functionality.

Do not add cloud AI APIs to the MVP unless explicitly required later.

---

# 6. PHASE 1 — EXISTING PROJECT INSPECTION

Before modifying the codebase, inspect the existing project completely.

Review:

* `pubspec.yaml`
* Flutter version
* Dart version
* dependencies
* existing architecture
* state management
* routing
* persistence
* file handling
* platform folders
* Android configuration
* iOS configuration
* existing UI system
* themes
* localization
* tests
* reusable widgets
* existing utilities
* build scripts

Treat the current project as the source of truth.

Do NOT modernize the project merely because newer versions exist.

Create or update:

```text id="1t2fhl"
docs/architecture.md
```

Document:

* current architecture
* current dependencies
* reusable components
* where InkFlow functionality will be integrated

---

# 7. OPEN-SOURCE / PACKAGE REUSE

You are explicitly encouraged to reuse mature Flutter packages and existing implementations.

Before implementing complex functionality from scratch, evaluate:

* Flutter SDK
* CustomPainter
* gesture/pointer APIs
* file picker packages
* PDF rendering packages
* PDF export packages
* image packages
* local database/storage packages
* document/file sharing packages
* platform plugins
* mature drawing/canvas packages

You may inspect relevant GitHub projects such as:

* Saber
* other mature Flutter drawing applications
* PDF annotation packages
* drawing/canvas libraries

### IMPORTANT

Use them as:

* architectural references
* behavior references
* package sources

Do NOT clone another application.

Do NOT copy large source files without necessity.

Do NOT violate licenses.

Document meaningful external dependencies in:

```text id="z7r5a1"
docs/decisions/
```

---

# 8. PHASE 2 — NOTEBOOK / DOCUMENT MODEL

Create a local document model.

Conceptually:

```text id="i6p0h6"
Notebook
  ↓
Document
  ↓
Page
  ↓
Stroke / Element
```

A document may contain:

* title
* creation date
* modification date
* pages
* tags
* favorite state

A page may contain:

* handwritten strokes
* text elements if supported
* imported images
* PDF/page background where applicable
* annotations

Keep the domain model simple.

---

# 9. PHASE 3 — HOME / LIBRARY

Create a useful home screen.

Example:

```text id="2a6mly"
InkFlow

Recent

Meeting Notes
Today

Project Ideas
Yesterday

Study Notes
Oct 5

[ + New Notebook ]
```

Support:

* recent documents
* notebooks
* search entry
* favorites
* basic organization

Avoid an unnecessarily complicated navigation system.

---

# 10. PHASE 4 — HANDWRITING CANVAS

This is the central feature.

The user must be able to draw using:

* finger
* stylus where the platform provides pointer information

Support:

* freehand strokes
* configurable stroke width
* configurable color
* eraser
* clear page
* undo
* redo

The canvas must use real pointer events.

Do NOT simulate handwriting with buttons or fake animations.

---

# 11. PHASE 5 — POINTER / STYLUS HANDLING

Where Flutter/platform APIs expose relevant information, support:

* pointer down
* pointer move
* pointer up
* device kind
* pressure where available
* stylus input where available

Do not assume pressure is supported on every device.

Gracefully degrade:

```text id="1j29b6"
Stylus pressure
Available
```

or:

```text id="eqv2d8"
Stylus pressure
Not supported on this device
```

Never fake pressure data.

---

# 12. PHASE 6 — STROKE MODEL

Do not store a handwritten page as one giant bitmap by default.

Prefer a structured stroke representation.

Conceptually:

```text id="iy9p6n"
Stroke
 ├── points
 ├── color
 ├── width
 ├── opacity
 └── metadata
```

This enables:

* undo
* redo
* editing
* persistence
* efficient reconstruction
* future handwriting analysis

Use an efficient serialization format.

Avoid excessive memory usage for long notes.

---

# 13. PHASE 7 — UNDO / REDO

Implement real undo/redo.

Examples:

```text id="yy7d6a"
Draw stroke
Draw stroke
Draw stroke
     ↓
Undo
     ↓
Remove last stroke
```

Support:

* undo
* redo
* clear
* continued editing after undo

The state model must remain consistent.

---

# 14. PHASE 8 — PERSISTENCE

Notes must survive:

* app restart
* navigation
* backgrounding
* device process recreation where practical

Use the project's existing persistence technology when sufficient.

If no appropriate solution exists, evaluate mature local persistence packages.

Do not store unnecessarily large serialized structures repeatedly.

Consider incremental persistence where appropriate.

---

# 15. PHASE 9 — NOTE EDITING

Support:

* create page
* rename document
* rename notebook
* delete page
* reorder pages
* duplicate page where useful

Keep editing predictable.

---

# 16. PHASE 10 — PDF IMPORT

Support importing a PDF or other compatible document format where practical.

The user should be able to open the document and annotate it.

Conceptually:

```text id="v8x02x"
PDF
 ↓
Page
 ↓
Annotation Layer
 ↓
Stroke
```

Do not modify the original PDF destructively.

Store annotations separately where practical.

---

# 17. PHASE 11 — PDF VIEW / ANNOTATION

Provide:

* page navigation
* zoom
* pan
* draw
* highlight where practical
* erase
* undo/redo

Use a mature PDF package if one is suitable.

Do not implement an entire PDF rendering engine from scratch.

---

# 18. PHASE 12 — IMAGE / DOCUMENT IMPORT

Allow users to import images/documents where appropriate.

Handle:

* large images
* unsupported files
* missing files
* inaccessible files
* platform-specific file behavior

Use modern platform APIs.

Do not assume arbitrary filesystem paths.

---

# 19. PHASE 13 — EXPORT

Support:

### Export note

Export a handwritten document as:

* PDF
* image where practical

### Export annotated document

Generate an output document that contains:

```text id="2uubd4"
Original document
+
User annotations
```

Do not overwrite the original source automatically.

---

# 20. PHASE 14 — SHARE

Use the system share mechanism.

Support sharing:

* exported PDF
* exported image
* annotated document

Do not require a cloud account.

---

# 21. PHASE 15 — ORGANIZATION

Support:

* notebooks
* tags
* favorites
* recent documents

Example:

```text id="7o3czb"
Notebooks

Work
Study
Personal
Projects
```

Tags may include:

```text id="efpbla"
Important
Meeting
Idea
Exam
```

Keep organization simple.

Do not build a complicated folder hierarchy unless the existing product clearly needs it.

---

# 22. PHASE 16 — SEARCH

Provide local search across:

* document titles
* notebook titles
* tags
* metadata

OCR/handwriting semantic search is NOT mandatory for the MVP.

However, the architecture should leave room for later:

```text id="w4t4oj"
Handwriting
 ↓
Recognition
 ↓
Text index
 ↓
Search
```

Do not add a complex AI pipeline just to satisfy this future possibility.

---

# 23. PHASE 17 — PERFORMANCE

Performance is important.

The app must remain responsive with:

* long pages
* hundreds of strokes
* many pages
* multiple notebooks
* large documents

Avoid:

* rebuilding the entire canvas unnecessarily
* decoding large images repeatedly
* storing huge bitmap snapshots for every undo action
* excessive widget rebuilds
* blocking the UI isolate
* excessive serialization
* unnecessary disk writes

Consider:

* efficient stroke structures
* repaint boundaries
* caching
* incremental persistence
* background work
* bounded memory usage

---

# 24. PHASE 18 — LARGE DOCUMENT / MEMORY HANDLING

Never assume documents are small.

Handle:

* large PDFs
* large images
* long handwritten notes
* many pages

Avoid loading every page into memory simultaneously.

Use:

* lazy page rendering
* cached thumbnails
* bounded image decoding
* incremental export

where appropriate.

---

# 25. PHASE 19 — RESPONSIVE UI

The Flutter UI should behave correctly on:

* small phones
* large phones
* tablets
* desktop-sized windows where practical

Do not create a completely separate architecture for each platform.

Use adaptive layouts where appropriate.

---

# 26. PHASE 20 — ACCESSIBILITY

Support:

* readable text sizes
* meaningful semantics
* sensible tap targets
* keyboard navigation where relevant
* sufficient contrast
* accessible labels for important controls

The canvas itself should provide appropriate semantic information where practical.

---

# 27. PHASE 21 — ERROR HANDLING

Handle:

* save failure
* corrupted document
* missing file
* unsupported format
* PDF rendering failure
* PDF export failure
* insufficient storage
* import cancellation
* export cancellation
* invalid document state

A single bad page must not crash the application.

Example:

```text id="6m8rb6"
Could not load this page.

The rest of the document is still available.
```

---

# 28. PHASE 22 — LOCAL-FIRST / PRIVACY

The MVP must not require:

* backend
* user account
* cloud synchronization
* analytics
* remote document processing

Do not upload:

* handwritten notes
* PDFs
* images
* annotations
* document metadata

The privacy statement must reflect the implementation exactly.

---

# 29. PHASE 23 — AI-READY ARCHITECTURE

Do NOT add an AI API to the MVP just because this is an AI-heavy era.

Instead design clean boundaries so future features can be added without rewriting the core.

Possible future interface:

```text id="1wq5kb"
AiDocumentAssistant
    ↓
summarize()
extractTasks()
recognizeHandwriting()
semanticSearch()
```

The core application must not depend on this interface being active.

If future AI is added, provider implementations should remain replaceable.

For now:

```text id="owf4n6"
Core Product
    ↓
No AI dependency
```

---

# 30. ARCHITECTURE

Preserve the existing Flutter architecture.

Do NOT migrate the project to a different state-management solution unless genuinely necessary.

A reasonable logical separation is:

```text id="6amj0s"
Presentation
    ↓
Domain
    ↓
Data
    ↓
Platform / Packages
```

Possible domain models:

```text id="tn7d1h"
Notebook
Document
Page
Stroke
Annotation
DocumentTag
ExportRequest
```

Possible services:

```text id="qeqf4q"
DrawingEngine
DocumentRepository
PageRepository
PdfRepository
FileImporter
FileExporter
AnnotationRepository
SearchRepository
```

Use names consistent with the existing project.

Do not over-engineer.

---

# 31. STATE MANAGEMENT

Use the existing project's state management approach.

If the project already uses:

* Riverpod
* Bloc
* Provider
* another established approach

continue using it.

Do NOT migrate state management merely for preference.

Canvas interaction should remain responsive and should not cause unnecessary global state rebuilds.

---

# 32. PACKAGE / DEPENDENCY RULES

Before adding a dependency:

1. Search existing dependencies.
2. Determine whether Flutter SDK/platform APIs already solve the problem.
3. Evaluate mature packages.
4. Verify maintenance status.
5. Verify compatibility with the existing Flutter/Dart version.
6. Check license.
7. Check transitive dependency impact.
8. Add the dependency only if justified.

Do not add packages merely because they are popular.

---

# 33. VERSION PROTECTION

The current project configuration is valid.

DO NOT change:

```text id="z3u0wm"
Flutter version
Dart version
Android Gradle configuration
iOS deployment configuration
existing dependency versions
existing build tools
existing package IDs
```

unless the implementation is genuinely impossible without a change.

Before changing any foundational configuration:

1. inspect existing packages
2. inspect alternative packages
3. inspect Flutter APIs
4. inspect platform APIs
5. look for a compatible implementation

Do not silently upgrade the project's toolchain.

---

# 34. LICENSE / OPEN-SOURCE POLICY

InkFlow may be inspired by projects such as Saber, but it must remain an independent implementation.

Do not copy Saber source code wholesale.

Do not copy proprietary code.

Respect all open-source licenses.

Every important external dependency must be documented.

Create:

```text id="5inw3v"
docs/decisions/
```

with entries such as:

```text id="2a09m5"
001-preserve-existing-project.md
002-canvas-engine-choice.md
003-pdf-library-choice.md
004-local-storage-choice.md
005-annotation-model.md
006-performance-strategy.md
007-ai-ready-boundaries.md
```

---

# 35. IMPLEMENTATION PHASES

Implement in this order:

```text id="w2il27"
Phase 1
Existing Project Inspection

Phase 2
Notebook / Document Model

Phase 3
Home / Library

Phase 4
Handwriting Canvas

Phase 5
Pointer / Stylus Handling

Phase 6
Stroke Model

Phase 7
Undo / Redo

Phase 8
Persistence

Phase 9
Note Editing

Phase 10
PDF Import

Phase 11
PDF View / Annotation

Phase 12
Image / Document Import

Phase 13
Export

Phase 14
Share

Phase 15
Organization

Phase 16
Search

Phase 17
Performance

Phase 18
Large Document / Memory Handling

Phase 19
Responsive UI

Phase 20
Accessibility

Phase 21
Error Handling

Phase 22
Privacy Review

Phase 23
AI-Ready Architecture Review

Phase 24
Final UI / UX Polish
```

You may combine tightly coupled implementation work where appropriate, but do not skip the core capabilities.

---

# 36. PHASE EXECUTION RULE

For every phase:

1. Inspect existing relevant code.
2. Reuse existing code and packages.
3. Implement the minimum required changes.
4. Review code statically.
5. Review memory/performance implications.
6. Review architecture consistency.
7. Continue to the next phase.
8. **Do NOT run tests.**

---

# 37. ABSOLUTE TESTING RULE

## DO NOT RUN ANY TESTS UNTIL ALL IMPLEMENTATION PHASES ARE COMPLETE

During every implementation phase:

Do not execute:

* `flutter test`
* unit tests
* widget tests
* integration tests
* golden tests
* benchmark tests
* platform tests

You may:

* inspect tests
* create tests
* modify tests
* review tests

But:

> **DO NOT EXECUTE ANY TESTS UNTIL ALL IMPLEMENTATION PHASES ARE COMPLETE.**

Only after the entire implementation is finished may testing begin.

---

# 38. FINAL VERIFICATION

After all implementation phases are complete:

### Run build

Use the existing project's normal build command.

For example:

```text id="1rmyap"
flutter build apk --debug
```

Use the appropriate existing platform/build configuration rather than changing it.

### Then run

* unit tests
* widget tests
* integration tests
* static analysis
* formatting verification
* platform build verification

Do not claim success if a check was not actually executed.

---

# 39. MANUAL VALIDATION

Validate on a real device or emulator where possible.

Verify:

1. Create notebook
2. Create document
3. Create handwritten page
4. Draw with finger
5. Draw with stylus where available
6. Change stroke width
7. Change color
8. Erase
9. Undo
10. Redo
11. Save
12. Restart app
13. Reopen document
14. Add multiple pages
15. Reorder pages
16. Import image
17. Import PDF
18. Annotate PDF
19. Zoom/pan
20. Export PDF
21. Share exported document
22. Search
23. Tags
24. Favorites
25. Large note
26. Large document
27. Many documents
28. Backgrounding
29. Process recreation where practical
30. Error handling scenarios

Do not claim manual validation for scenarios that were not actually tested.

---

# 40. README

The README must start with the user problem, not the technology stack.

Recommended:

```text id="7uj2ib"
# InkFlow

Write, annotate, organize — without the cloud.

## The Problem

Typed note applications are not ideal for
handwritten notes and document annotation.

## The Solution

InkFlow provides a local-first handwriting
and annotation workflow.

Write → Annotate → Organize → Export

## Features

## Screenshots

## Architecture

## Performance

## Privacy

## Platform Support

## Limitations

## Testing

## Roadmap

## License
```

Do not describe AI capabilities unless they actually exist.

---

# 41. DOCUMENTATION

Create or maintain:

```text id="m3s7gi"
docs/architecture.md
docs/canvas-engine.md
docs/stroke-model.md
docs/pdf-annotation.md
docs/storage.md
docs/performance.md
docs/privacy.md
```

---

# 42. FINAL DEFINITION OF DONE

The project is complete when:

* existing project preserved
* Flutter/Dart versions unchanged
* existing architecture preserved
* existing dependencies preserved unless additions are justified
* handwriting canvas works
* finger input works
* stylus input works where supported
* stroke model works
* undo/redo works
* persistence works
* notebook organization works
* document/page management works
* image import works
* PDF import works
* PDF annotation works
* export works
* sharing works
* search works
* tags work
* favorites work
* large documents remain usable
* application remains responsive
* memory usage is reasonable
* no document data is uploaded
* no fake production functionality exists
* no fake drawing exists
* no fake export exists
* AI is not a mandatory core dependency
* architecture is ready for future AI extension
* README exists
* documentation exists
* final build succeeds
* final tests pass
* final static analysis passes
* manual verification is completed

---

# 43. FINAL REPORT FORMAT

After all implementation and final verification:

## Implemented

* ...

## External Libraries / Open Source Reused

* ...

## Build

* ...

## Tests

* ...

## Static Analysis

* ...

## Manual Validation

* ...

## Performance

* ...

## Privacy

* ...

## Known Limitations

* ...

## Architecture Notes

* ...

## Files Changed

* ...

## Final Status

* Complete / Incomplete

---

# 44. FINAL INSTRUCTION

This is an **EXISTING Flutter project**.

Build **InkFlow on top of the existing source code**.

Do not recreate the project.

Do not migrate it to Kotlin.

Do not change Flutter.

Do not change Dart.

Do not change existing build/toolchain versions.

Do not perform unnecessary architecture migrations.

Reuse mature open-source packages and implementations when appropriate.

Do not reinvent complex PDF or document functionality unnecessarily.

Do not copy another application.

The portfolio objective is to demonstrate:

> **Flutter + custom interaction + rendering + handwriting + document/PDF workflow + local persistence + performance**

The application must be useful without AI.

AI should remain an optional future extension point rather than a forced dependency.

Most importantly:

> **DO NOT RUN ANY TESTS UNTIL ALL IMPLEMENTATION PHASES ARE COMPLETE.**

After every implementation phase is finished, perform one comprehensive final verification pass.

Never claim functionality, testing, or verification that has not actually happened.
