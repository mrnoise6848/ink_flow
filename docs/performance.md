# Performance strategy
Completed ink is cached in a disposable ui.Picture and only reconstructed after a
committed edit. Active ink has a separate repaint notifier. Page backgrounds sit
outside the ink painter. Input is sampled at a half-point movement threshold.
Undo stores shared immutable stroke references, capped at 80 edits; no bitmaps.
Library list uses builder virtualization. Metadata search never loads ink pages.
Autosave is debounced and writes only the changed page. JSON encoding/decoding is
performed in worker isolates. No benchmark or device performance claim is made.

## Large documents
Only the active page is decoded (maximum background edge 1800px). Original images
are streamed to storage, not read into one large byte array. Imports enumerate PDF
page metadata but never rasterize all pages. Export encodes one page at a time,
compresses JPEG in a worker, then releases native raster buffers. PDF retains the
compressed JPEG payloads, with a 32MiB budget and actionable failure. Derivatives
are 1800px at the longest edge and JPEG quality 92; PNG export is lossless. Temporary
exports older than seven days are removed on startup. No claim of unlimited export
size is made; enormous documents can be split or exported as individual pages.
