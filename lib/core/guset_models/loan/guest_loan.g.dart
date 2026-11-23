// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuestLoanPaymentAdapter extends TypeAdapter<GuestLoanPayment> {
  @override
  final int typeId = 5;

  @override
  GuestLoanPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuestLoanPayment(
      id: fields[0] as String,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      note: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GuestLoanPayment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestLoanPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuestLoanAdapter extends TypeAdapter<GuestLoan> {
  @override
  final int typeId = 6;

  @override
  GuestLoan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuestLoan(
      id: fields[0] as String,
      name: fields[1] as String,
      principal: fields[2] as double,
      remainingAmount: fields[3] as double,
      deadline: fields[4] as DateTime,
      note: fields[5] as String,
      categoryId: fields[6] as String,
      payments: (fields[7] as List).cast<GuestLoanPayment>(),
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GuestLoan obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.principal)
      ..writeByte(3)
      ..write(obj.remainingAmount)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.payments)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestLoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
