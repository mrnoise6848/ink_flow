# Canvas and pointer input
Page coordinates are logical document points, independent of viewer zoom.
Listener handles down/move/up/cancel and rejects extra simultaneous pointers.
Touch/mouse uses constant width. Stylus pressure is normalized only when the
platform exposes a nonzero pressure range. The toolbar reports the last pointer's
capability, not a promise about the physical device. Cancel discards unfinished ink.
Use Move mode to zoom/pan, Pen/Highlight mode to annotate.
