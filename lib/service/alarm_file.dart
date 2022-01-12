import 'dart:io';

class AlarmFileStorage {
  File? _file;

  AlarmFileStorage();

  AlarmFileStorage.toFile(this._file);

  Future<void> writeLAlarmFile() async {
    _file?.writeAsString("");
  }
}
