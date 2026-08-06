// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordGroupAdapter extends TypeAdapter<PasswordGroup> {
  @override
  final int typeId = 1;

  @override
  PasswordGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordGroup(
      name: fields[0] as String,
      entries: (fields[1] as List).cast<PasswordEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, PasswordGroup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.entries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
