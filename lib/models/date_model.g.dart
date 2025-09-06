// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImportantDateAdapter extends TypeAdapter<ImportantDate> {
  @override
  final int typeId = 0;

  @override
  ImportantDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImportantDate(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      description: fields[3] as String?,
      notificationIds: (fields[4] as List?)?.cast<int>(),
      isNotificationEnabled: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ImportantDate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.notificationIds)
      ..writeByte(5)
      ..write(obj.isNotificationEnabled)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportantDateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
