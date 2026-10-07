import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models.dart';

Object? decodeJson(String input) => jsonDecode(input);
String encodeJson(Object input) => jsonEncode(input);
InkPage decodePage(String input) =>
    InkPage.fromJson(jsonDecode(input) as Map<String, dynamic>);

class LocalStore {
  late Directory root;
  Future<void> _queue = Future.value();
  Future<void> initialize() async {
    root = Directory(
      '${(await getApplicationSupportDirectory()).path}/inkflow',
    );
    for (final dir in ['pages', 'assets', 'exports']) {
      await Directory('${root.path}/$dir').create(recursive: true);
    }
  }

  Future<void> cleanupExports() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    await for (final entry in Directory('${root.path}/exports').list()) {
      if (entry is File && (await entry.stat()).modified.isBefore(cutoff)) {
        await entry.delete();
      }
    }
  }

  File file(String relative) {
    if (!RegExp(r'^[a-zA-Z0-9_./-]+$').hasMatch(relative) ||
        relative.contains('..') ||
        relative.startsWith('/')) {
      throw const FormatException('Invalid local file reference');
    }
    return File('${root.path}/$relative');
  }

  Future<Object?> read(String relative) async {
    final target = file(relative);
    try {
      return await compute(decodeJson, await target.readAsString());
    } catch (_) {
      final backup = File('${target.path}.bak');
      if (await backup.exists()) {
        final recovered = await compute(
          decodeJson,
          await backup.readAsString(),
        );
        _recovered.add(relative);
        return recovered;
      }
      rethrow;
    }
  }

  Future<void> write(String relative, Object snapshot) {
    final task = _queue.then((_) async {
      final data = await compute(encodeJson, snapshot);
      final target = file(relative), temporary = file('$relative.tmp');
      await temporary.writeAsString(data, flush: true);
      if (!_recovered.contains(relative) && await target.exists())
        await target.copy('${target.path}.bak');
      await temporary.rename(target.path);
      _recovered.remove(relative);
    });
    _queue = task.catchError((Object _) {});
    return task;
  }

  Future<void> flush() => _queue;
  Future<InkPage> loadPage(String id) async {
    localId(id);
    Future<InkPage> parse(File file) async {
      if ((await file.length()) > 32 * 1024 * 1024)
        throw const FormatException('Page exceeds safe memory limit');
      final page = await compute(decodePage, await file.readAsString());
      if (page.id != id)
        throw const FormatException('Page ID does not match file');
      return page;
    }

    final target = file('pages/$id.json');
    try {
      return await parse(target);
    } catch (_) {
      final backup = file('pages/$id.json.bak');
      if (!await backup.exists()) rethrow;
      final recovered = await parse(backup);
      // Keep the valid backup until the next successful write. Do not replace
      // it with damaged data on subsequent saves.
      _recovered.add('pages/$id.json');
      return recovered;
    }
  }

  final Set<String> _recovered = {};
  Future<void> savePage(InkPage page) =>
      write('pages/${page.id}.json', page.toJson());
}
