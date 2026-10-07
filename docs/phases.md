# Implementation phases
Each phase has a separate Git commit. Tests are not run per explicit user request.

| Phase | Delivered scope |
|---|---|
| 1 | Existing source, SDK, dependencies and platform inspection |
| 2 | Notebook/document/page/vector ink models |
| 3 | Local library and note creation |
| 4 | Real pointer-driven pen and eraser canvas |
| 5 | Stylus device and exposed pressure handling |
| 6 | Compact versioned stroke/page format |
| 7 | Bounded undo/redo, cancellable gestures, clear |
| 8 | Private page persistence, atomic updates and backups |
| 9 | Rename, add, duplicate, delete, reorder and navigate pages |
| 10 | Private non-destructive PDF import |
| 11 | Active-page PDF render, annotation, highlight, pan/zoom |
| 12 | Streamed PNG/JPEG/WebP import |
| 13 | Flattened PDF and current-page PNG export |
| 14 | System sharing and platform save delivery |
| 15 | Tags, favorites, notebook moves and library deletion |
| 16 | Local title/notebook/tag/date/metadata search |
| 17 | Cached completed ink, isolated repaint and bounded history |
| 18 | Bounded decode, sequential export and memory budget |
| 19 | Phone/tablet/window page fitting |
| 20 | Tool semantics, keyboard shortcuts and state labels |
| 21 | Save retry, corrupt-page isolation and recovery |
| 22 | Accurate privacy/retention review |
| 23 | Optional inactive analysis boundary and shared rendering service |
| 24 | UI feedback, empty tag editing, licensing UI and final documentation |

Implementation completion is distinct from build/device verification. See
verification.md; unsupported formats and export tradeoffs are disclosed in README.
