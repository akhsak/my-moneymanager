// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuestCategoryAdapter extends TypeAdapter<GuestCategory> {
  @override
  final int typeId = 1;

  @override
  GuestCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuestCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      isActive: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GuestCategory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
