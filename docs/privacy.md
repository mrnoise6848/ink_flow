# Privacy
InkFlow operates locally with no account, backend, analytics, cloud synchronization,
AI API or runtime document upload. Documents, source PDFs/images and ink are held in
application-support storage. App exports use a private staging directory; old
staging exports are cleaned after seven days. Sharing invokes the OS sheet only on
user action. Destination apps have their own privacy policies.

InkFlow does not implement its own encryption. Device protection, OS backups,
filesystem permissions and destination apps are controlled by the platform/user.
Deleting a document removes it from the active library; recovery backups and orphaned
private assets may remain until application data is cleared or the app is uninstalled.
There is no secure-erasure promise. Keep an export before clearing app data.

Dependencies may download native build assets at build time. That does not upload
notes. No source PDF is opened from a URL. Android's debug/profile Internet
permission is the existing Flutter tooling permission; no production app feature
uses it. The app's release manifest retains the existing configuration.
