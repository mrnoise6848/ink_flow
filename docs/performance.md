# Performance strategy
Completed ink is cached in a disposable ui.Picture and only reconstructed after a
committed edit. Active ink has a separate repaint notifier. Page backgrounds sit
outside the ink painter. Input is sampled at a half-point movement threshold.
Undo stores shared immutable stroke references, capped at 80 edits; no bitmaps.
Library list uses builder virtualization. Metadata search never loads ink pages.
Autosave is debounced and writes only the changed page. JSON encoding/decoding is
performed in worker isolates. No benchmark or device performance claim is made.
