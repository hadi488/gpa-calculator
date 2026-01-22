// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      id: fields[0] as String,
      courseCode: fields[1] as String,
      courseName: fields[2] as String,
      gradePoint: fields[3] as double,
      creditHours: fields[4] as int,
      isTemporarilyRemoved: fields[5] as bool,
      removedFromSemesterId: fields[6] as String?,
      hasGrade: fields[7] as bool,
      marks: fields[8] as int?,
      isExcludedFromCalculations: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseCode)
      ..writeByte(2)
      ..write(obj.courseName)
      ..writeByte(3)
      ..write(obj.gradePoint)
      ..writeByte(4)
      ..write(obj.creditHours)
      ..writeByte(5)
      ..write(obj.isTemporarilyRemoved)
      ..writeByte(6)
      ..write(obj.removedFromSemesterId)
      ..writeByte(7)
      ..write(obj.hasGrade)
      ..writeByte(8)
      ..write(obj.marks)
      ..writeByte(9)
      ..write(obj.isExcludedFromCalculations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
