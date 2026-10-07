# Stroke format
Versioned per-page JSON stores [x,y,pressure] numeric arrays and per-stroke ARGB,
width, opacity, input kind and pressure capability. Completed strokes remain vector
data. There is no OCR or bitmap-only note store. Separate page files make loads
lazy and writes page-scoped. IDs are generated locally using time + secure entropy.
