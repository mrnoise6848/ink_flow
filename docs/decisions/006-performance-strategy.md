# Performance
Use page-scoped lazy IO, cached vector pictures, RepaintBoundary, bounded decoding
and bounded undo. Keep one page background in memory. Export walks pages serially
and releases raw images after PNG encoding. PDF output still accumulates compressed
page data; impose an explicit memory budget instead of risking an OS process kill.
