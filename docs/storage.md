# Local storage
Application-support/inkflow contains library.json, separate pages/<id>.json and
immutable assets. Each update is queued, encoded in a worker isolate and written to
a flushed temporary file before atomic rename. Previous content is retained as .bak
for JSON recovery. Editor autosaves completed gestures after 500ms, flushes on page
navigation, back and backgrounding. A failed page save keeps dirty state in memory
and prevents leaving until retry succeeds. Abrupt kills during the debounce window
can lose the most recent gesture; no mobile app can guarantee shutdown callbacks.
Do not uninstall/clear app data without exporting; there is no cloud backup.

Corrupted pages retry their last valid backup, with model validation performed in a
worker. Damaged index entries are retained in subsequent saves rather than silently
discarded. A wholly unreadable index blocks editing and offers Retry. An unavailable
page never exposes the previous page's canvas. Failed metadata commits during page
reordering/creation restore the prior in-memory page order.
