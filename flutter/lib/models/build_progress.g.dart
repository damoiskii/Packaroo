// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildProgressAdapter extends TypeAdapter<BuildProgress> {
  @override
  final int typeId = 2;

  @override
  BuildProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildProgress(
      id: fields[0] as String,
      projectId: fields[1] as String,
      status: fields[2] as BuildStatus,
      progress: fields[3] as double,
      currentStep: fields[4] as String,
      logs: (fields[5] as List?)?.cast<String>(),
      startTime: fields[6] as DateTime?,
      endTime: fields[7] as DateTime?,
      errorMessage: fields[8] as String?,
      outputPath: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BuildProgress obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.progress)
      ..writeByte(4)
      ..write(obj.currentStep)
      ..writeByte(5)
      ..write(obj.logs)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.endTime)
      ..writeByte(8)
      ..write(obj.errorMessage)
      ..writeByte(9)
      ..write(obj.outputPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildStatusAdapter extends TypeAdapter<BuildStatus> {
  @override
  final int typeId = 1;

  @override
  BuildStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuildStatus.pending;
      case 1:
        return BuildStatus.running;
      case 2:
        return BuildStatus.completed;
      case 3:
        return BuildStatus.failed;
      case 4:
        return BuildStatus.cancelled;
      default:
        return BuildStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, BuildStatus obj) {
    switch (obj) {
      case BuildStatus.pending:
        writer.writeByte(0);
        break;
      case BuildStatus.running:
        writer.writeByte(1);
        break;
      case BuildStatus.completed:
        writer.writeByte(2);
        break;
      case BuildStatus.failed:
        writer.writeByte(3);
        break;
      case BuildStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
