# PDF workflow
The document picker streams a private copy of the original PDF. Each page stores
its original page number, dimensions and separate vector ink. Viewing rasterizes
only the active page at a bounded resolution using pdfrx. Move mode enables zoom
and pan; Pen/Highlight mode writes over the background. Eraser affects InkFlow
strokes, not source content. Export creates a separate flattened PDF, preserving
visible source content plus ink. Searchable source text/forms/links are not retained
in flattened exports. Password-protected PDFs currently report an import failure.
