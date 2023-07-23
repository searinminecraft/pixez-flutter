import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/illust_persist.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import '../../saf_plugin.dart';

part 'history_store.g.dart';

class HistoryStore = _HistoryStoreBase with _$HistoryStore;

abstract class _HistoryStoreBase with Store {
  IllustPersistProvider illustPersistProvider = IllustPersistProvider();
  ObservableList<IllustPersist> data = ObservableList();
  @observable
  var word = "";

  @action
  fetch() async {
    await illustPersistProvider.open();
    final result = await illustPersistProvider.getAllAccount();
    data.clear();
    data.addAll(result);
  }

  @action
  search(String word) async {
    await illustPersistProvider.open();
    final result = await illustPersistProvider.getLikeIllusts(word);
    data.clear();
    data.addAll(result);
  }

  @action
  insert(Illusts illust) async {
    await illustPersistProvider.open();
    var illustPersist = IllustPersist(
        illustId: illust.id,
        userId: illust.user.id,
        pictureUrl: illust.imageUrls.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: illust.title,
        userName: illust.user.name);
    await illustPersistProvider.insert(illustPersist);
    await fetch();
  }

  @action
  delete(int id) async {
    await illustPersistProvider.open();
    await illustPersistProvider.delete(id);
    await fetch();
  }

  deleteAll() async {
    await illustPersistProvider.open();
    await illustPersistProvider.deleteAll();
    await fetch();
  }

  Future<void> exportData() async {
    final uriStr = await SAFPlugin.createFile("illustpresist.db", "application/vnd.sqlite3");
    if (uriStr == null) return;
    String databasesPath = (await getDatabasesPath());
    String path = Path.join(databasesPath, 'illustpersist.db');
    File databaseFile = File(path);
    final exportData = databaseFile.readAsBytesSync();
    await SAFPlugin.writeUri(uriStr, exportData);
  }
}
