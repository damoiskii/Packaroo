import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'packaroo_project.g.dart';

@HiveType(typeId: 0)
class PackarooProject extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String projectPath;

  @HiveField(4)
  late String outputPath;

  @HiveField(5)
  late String jarPath;

  @HiveField(6)
  late String mainClass;

  @HiveField(7)
  late String modulePath;

  @HiveField(8)
  late String jdkPath;

  @HiveField(9)
  late String appName;

  @HiveField(10)
  late String appVersion;

  @HiveField(11)
  late String appDescription;

  @HiveField(12)
  late String appVendor;

  @HiveField(13)
  late String appCopyright;

  @HiveField(14)
  late String iconPath;

  @HiveField(15)
  late String packageType;

  @HiveField(16)
  late List<String> jvmOptions;

  @HiveField(17)
  late List<String> appArguments;

  @HiveField(18)
  late List<String> additionalModules;

  @HiveField(19)
  late DateTime createdDate;

  @HiveField(20)
  late DateTime lastModified;

  @HiveField(21)
  late bool useJlink;

  @HiveField(22)
  late bool includeAllModules;

  @HiveField(23)
  late bool stripDebug;

  @HiveField(24)
  late bool compress;

  @HiveField(25)
  late bool noHeaderFiles;

  @HiveField(26)
  late bool noManPages;

  @HiveField(27)
  late int sortOrder;

  PackarooProject({
    String? id,
    required this.name,
    this.description = '',
    required this.projectPath,
    required this.outputPath,
    required this.jarPath,
    required this.mainClass,
    this.modulePath = '',
    this.jdkPath = '',
    this.appName = '',
    this.appVersion = '1.0.0',
    this.appDescription = '',
    this.appVendor = '',
    this.appCopyright = '',
    this.iconPath = '',
    this.packageType = 'app-image',
    this.jvmOptions = const [],
    this.appArguments = const [],
    this.additionalModules = const [],
    DateTime? createdDate,
    DateTime? lastModified,
    this.useJlink = false,
    this.includeAllModules = false,
    this.stripDebug = true,
    this.compress = true,
    this.noHeaderFiles = true,
    this.noManPages = true,
    int? sortOrder,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdDate = createdDate ?? DateTime.now();
    this.lastModified = lastModified ?? DateTime.now();
    this.sortOrder = sortOrder ?? DateTime.now().millisecondsSinceEpoch;

    // Set default app name if not provided
    if (appName.isEmpty) {
      appName = name;
    }
  }

  // Copy constructor
  PackarooProject copyWith({
    String? id,
    String? name,
    String? description,
    String? projectPath,
    String? outputPath,
    String? jarPath,
    String? mainClass,
    String? modulePath,
    String? jdkPath,
    String? appName,
    String? appVersion,
    String? appDescription,
    String? appVendor,
    String? appCopyright,
    String? iconPath,
    String? packageType,
    List<String>? jvmOptions,
    List<String>? appArguments,
    List<String>? additionalModules,
    DateTime? createdDate,
    DateTime? lastModified,
    bool? useJlink,
    bool? includeAllModules,
    bool? stripDebug,
    bool? compress,
    bool? noHeaderFiles,
    bool? noManPages,
    int? sortOrder,
  }) {
    return PackarooProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      projectPath: projectPath ?? this.projectPath,
      outputPath: outputPath ?? this.outputPath,
      jarPath: jarPath ?? this.jarPath,
      mainClass: mainClass ?? this.mainClass,
      modulePath: modulePath ?? this.modulePath,
      jdkPath: jdkPath ?? this.jdkPath,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      appDescription: appDescription ?? this.appDescription,
      appVendor: appVendor ?? this.appVendor,
      appCopyright: appCopyright ?? this.appCopyright,
      iconPath: iconPath ?? this.iconPath,
      packageType: packageType ?? this.packageType,
      jvmOptions: jvmOptions ?? List.from(this.jvmOptions),
      appArguments: appArguments ?? List.from(this.appArguments),
      additionalModules: additionalModules ?? List.from(this.additionalModules),
      createdDate: createdDate ?? this.createdDate,
      lastModified: lastModified ?? DateTime.now(),
      useJlink: useJlink ?? this.useJlink,
      includeAllModules: includeAllModules ?? this.includeAllModules,
      stripDebug: stripDebug ?? this.stripDebug,
      compress: compress ?? this.compress,
      noHeaderFiles: noHeaderFiles ?? this.noHeaderFiles,
      noManPages: noManPages ?? this.noManPages,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'projectPath': projectPath,
      'outputPath': outputPath,
      'jarPath': jarPath,
      'mainClass': mainClass,
      'modulePath': modulePath,
      'jdkPath': jdkPath,
      'appName': appName,
      'appVersion': appVersion,
      'appDescription': appDescription,
      'appVendor': appVendor,
      'appCopyright': appCopyright,
      'iconPath': iconPath,
      'packageType': packageType,
      'jvmOptions': jvmOptions,
      'appArguments': appArguments,
      'additionalModules': additionalModules,
      'createdDate': createdDate.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'useJlink': useJlink,
      'includeAllModules': includeAllModules,
      'stripDebug': stripDebug,
      'compress': compress,
      'noHeaderFiles': noHeaderFiles,
      'noManPages': noManPages,
      'sortOrder': sortOrder,
    };
  }

  factory PackarooProject.fromJson(Map<String, dynamic> json) {
    return PackarooProject(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      projectPath: json['projectPath'],
      outputPath: json['outputPath'],
      jarPath: json['jarPath'],
      mainClass: json['mainClass'],
      modulePath: json['modulePath'] ?? '',
      jdkPath: json['jdkPath'] ?? '',
      appName: json['appName'] ?? '',
      appVersion: json['appVersion'] ?? '1.0.0',
      appDescription: json['appDescription'] ?? '',
      appVendor: json['appVendor'] ?? '',
      appCopyright: json['appCopyright'] ?? '',
      iconPath: json['iconPath'] ?? '',
      packageType: json['packageType'] ?? 'app-image',
      jvmOptions: List<String>.from(json['jvmOptions'] ?? []),
      appArguments: List<String>.from(json['appArguments'] ?? []),
      additionalModules: List<String>.from(json['additionalModules'] ?? []),
      createdDate: DateTime.parse(json['createdDate']),
      lastModified: DateTime.parse(json['lastModified']),
      useJlink: json['useJlink'] ?? false,
      includeAllModules: json['includeAllModules'] ?? false,
      stripDebug: json['stripDebug'] ?? true,
      compress: json['compress'] ?? true,
      noHeaderFiles: json['noHeaderFiles'] ?? true,
      noManPages: json['noManPages'] ?? true,
      sortOrder: json['sortOrder'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool get isValid {
    return name.isNotEmpty &&
        projectPath.isNotEmpty &&
        outputPath.isNotEmpty &&
        jarPath.isNotEmpty &&
        mainClass.isNotEmpty;
  }

  String get displayName => appName.isNotEmpty ? appName : name;

  @override
  String toString() {
    return 'PackarooProject{id: $id, name: $name, appName: $appName}';
  }
}
