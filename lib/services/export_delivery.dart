import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

class ExportDelivery {
  Future<bool> save(File file, String title, Rect anchor) async {
    // Mobile file_selector has no save dialog. Use the system sheet, which can
    // save to Files/Drive/a user-selected destination without app uploads.
    if (Platform.isAndroid || Platform.isIOS) {
      await share(file, title, anchor);
      return true;
    }
    final extension = file.path.endsWith('.pdf') ? 'pdf' : 'png';
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
    final location = await getSaveLocation(
      suggestedName: '${safeTitle.isEmpty ? 'InkFlow' : safeTitle}.$extension',
    );
    if (location == null) return false;
    await XFile(file.path).saveTo(location.path);
    return true;
  }

  Future<ShareResult> share(File file, String title, Rect anchor) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          title: title,
          sharePositionOrigin: anchor,
        ),
      );
}
