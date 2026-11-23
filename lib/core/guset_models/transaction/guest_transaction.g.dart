// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuestSubTransactionAdapter extends TypeAdapter<GuestSubTransaction> {
  @override
  final int typeId = 2;

  @override
  GuestSubTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuestSubTransaction(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      description: fields[3] as String,
      timestamp: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GuestSubTransaction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestSubTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuestTransactionAdapter extends TypeAdapter<GuestTransaction> {
  @override
  final int typeId = 4;

  @override
  GuestTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuestTransaction(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      categoryName: fields[2] as String,
      title: fields[3] as String,
      amount: fields[4] as double,
      currency: fields[5] as String,
      frequency: fields[6] as String,
      type: fields[7] as GuestTransactionType,
      subTransactions: (fields[8] as List).cast<GuestSubTransaction>(),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GuestTransaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.subTransactions)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuestTransactionTypeAdapter extends TypeAdapter<GuestTransactionType> {
  @override
  final int typeId = 3;

  @override
  GuestTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GuestTransactionType.income;
      case 1:
        return GuestTransactionType.expense;
      case 2:
        return GuestTransactionType.loan;
      default:
        return GuestTransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, GuestTransactionType obj) {
    switch (obj) {
      case GuestTransactionType.income:
        writer.writeByte(0);
        break;
      case GuestTransactionType.expense:
        writer.writeByte(1);
        break;
      case GuestTransactionType.loan:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
