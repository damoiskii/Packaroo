// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packaroo_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PackarooProjectAdapter extends TypeAdapter<PackarooProject> {
  @override
  final int typeId = 0;

  @override
  PackarooProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PackarooProject(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      projectPath: fields[3] as String,
      outputPath: fields[4] as String,
      jarPath: fields[5] as String,
      mainClass: fields[6] as String,
      modulePath: fields[7] as String,
      jdkPath: fields[8] as String,
      appName: fields[9] as String,
      appVersion: fields[10] as String,
      appDescription: fields[11] as String,
      appVendor: fields[12] as String,
      appCopyright: fields[13] as String,
      iconPath: fields[14] as String,
      packageType: fields[15] as String,
      jvmOptions: (fields[16] as List).cast<String>(),
      appArguments: (fields[17] as List).cast<String>(),
      additionalModules: (fields[18] as List).cast<String>(),
      createdDate: fields[19] as DateTime?,
      lastModified: fields[20] as DateTime?,
      useJlink: fields[21] as bool,
      includeAllModules: fields[22] as bool,
      stripDebug: fields[23] as bool,
      compress: fields[24] as bool,
      noHeaderFiles: fields[25] as bool,
      noManPages: fields[26] as bool,
      sortOrder: fields[27] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PackarooProject obj) {
    writer
      ..writeByte(28)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.projectPath)
      ..writeByte(4)
      ..write(obj.outputPath)
      ..writeByte(5)
      ..write(obj.jarPath)
      ..writeByte(6)
      ..write(obj.mainClass)
      ..writeByte(7)
      ..write(obj.modulePath)
      ..writeByte(8)
      ..write(obj.jdkPath)
      ..writeByte(9)
      ..write(obj.appName)
      ..writeByte(10)
      ..write(obj.appVersion)
      ..writeByte(11)
      ..write(obj.appDescription)
      ..writeByte(12)
      ..write(obj.appVendor)
      ..writeByte(13)
      ..write(obj.appCopyright)
      ..writeByte(14)
      ..write(obj.iconPath)
      ..writeByte(15)
      ..write(obj.packageType)
      ..writeByte(16)
      ..write(obj.jvmOptions)
      ..writeByte(17)
      ..write(obj.appArguments)
      ..writeByte(18)
      ..write(obj.additionalModules)
      ..writeByte(19)
      ..write(obj.createdDate)
      ..writeByte(20)
      ..write(obj.lastModified)
      ..writeByte(21)
      ..write(obj.useJlink)
      ..writeByte(22)
      ..write(obj.includeAllModules)
      ..writeByte(23)
      ..write(obj.stripDebug)
      ..writeByte(24)
      ..write(obj.compress)
      ..writeByte(25)
      ..write(obj.noHeaderFiles)
      ..writeByte(26)
      ..write(obj.noManPages)
      ..writeByte(27)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackarooProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
