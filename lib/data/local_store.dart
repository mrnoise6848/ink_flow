import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/models.dart';

Object? decodeJson(String input) => jsonDecode(input);
String encodeJson(Object input) => jsonEncode(input);

class LocalStore {
  late Directory root;
  Future<void> _queue = Future.value();
  Future<void> initialize() async {
    root = Directory('${(await getApplicationSupportDirectory()).path}/inkflow');
    for (final dir in ['pages', 'assets', 'exports']) { await Directory('${root.path}/$dir').create(recursive: true); }
  }
  File file(String relative) {
    if (!RegExp(r'^[a-zA-Z0-9_./-]+$').hasMatch(relative) || relative.contains('..') || relative.startsWith('/')) { throw const FormatException('Invalid local file reference'); }
    return File('${root.path}/$relative');
  }
  Future<Object?> read(String relative) async {
    final target = file(relative);
    try { return await compute(decodeJson, await target.readAsString()); }
    catch (_) {
      final backup = File('${target.path}.bak');
      if (await backup.exists()) return compute(decodeJson, await backup.readAsString());
      rethrow;
    }
  }
  Future<void> write(String relative, Object snapshot) {
    final task = _queue.then((_) async {
      final data = await compute(encodeJson, snapshot);
      final target = file(relative), temporary = file('$relative.tmp');
      await temporary.writeAsString(data, flush: true);
      if (await target.exists()) await target.copy('${target.path}.bak');
      await temporary.rename(target.path);
    });
    _queue = task.catchError((Object _) {});
    return task;
  }
  Future<void> flush() => _queue;
  Future<InkPage> loadPage(String id) async => InkPage.fromJson(await read('pages/$id.json') as Map<String, dynamic>);
  Future<void> savePage(InkPage page) => write('pages/${page.id}.json', page.toJson());
}
