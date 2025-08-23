import 'package:hive/hive.dart';

part 'build_progress.g.dart';

@HiveType(typeId: 1)
enum BuildStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  running,

  @HiveField(2)
  completed,

  @HiveField(3)
  failed,

  @HiveField(4)
  cancelled,
}

@HiveType(typeId: 2)
class BuildProgress extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late BuildStatus status;

  @HiveField(3)
  late double progress; // 0.0 to 1.0

  @HiveField(4)
  late String currentStep;

  @HiveField(5)
  late List<String> logs;

  @HiveField(6)
  late DateTime startTime;

  @HiveField(7)
  DateTime? endTime;

  @HiveField(8)
  String? errorMessage;

  @HiveField(9)
  late String outputPath;

  BuildProgress({
    required this.id,
    required this.projectId,
    this.status = BuildStatus.pending,
    this.progress = 0.0,
    this.currentStep = 'Initializing...',
    List<String>? logs,
    DateTime? startTime,
    this.endTime,
    this.errorMessage,
    this.outputPath = '',
  }) {
    this.logs = logs ?? <String>[];
    this.startTime = startTime ?? DateTime.now();
  }

  void updateProgress(double newProgress, String step) {
    progress = newProgress.clamp(0.0, 1.0);
    currentStep = step;
    addLog('[$step] Progress: ${(progress * 100).toStringAsFixed(1)}%');
  }

  void addLog(String message) {
    logs.add('${DateTime.now().toIso8601String()}: $message');
  }

  void complete(String outputPath) {
    status = BuildStatus.completed;
    progress = 1.0;
    endTime = DateTime.now();
    this.outputPath = outputPath;
    currentStep = 'Build completed successfully';
    addLog('Build completed successfully at $outputPath');
  }

  void fail(String errorMessage) {
    status = BuildStatus.failed;
    endTime = DateTime.now();
    this.errorMessage = errorMessage;
    currentStep = 'Build failed';
    addLog('Build failed: $errorMessage');
  }

  void cancel() {
    status = BuildStatus.cancelled;
    endTime = DateTime.now();
    currentStep = 'Build cancelled';
    addLog('Build cancelled by user');
  }

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    } else if (status == BuildStatus.running) {
      return DateTime.now().difference(startTime);
    }
    return null;
  }

  String get durationString {
    final dur = duration;
    if (dur == null) return 'N/A';

    final minutes = dur.inMinutes;
    final seconds = dur.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  bool get isRunning => status == BuildStatus.running;
  bool get isCompleted => status == BuildStatus.completed;
  bool get isFailed => status == BuildStatus.failed;
  bool get isCancelled => status == BuildStatus.cancelled;
  bool get isFinished => isCompleted || isFailed || isCancelled;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'status': status.name,
      'progress': progress,
      'currentStep': currentStep,
      'logs': logs,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'errorMessage': errorMessage,
      'outputPath': outputPath,
    };
  }

  factory BuildProgress.fromJson(Map<String, dynamic> json) {
    return BuildProgress(
      id: json['id'],
      projectId: json['projectId'],
      status: BuildStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BuildStatus.pending,
      ),
      progress: json['progress']?.toDouble() ?? 0.0,
      currentStep: json['currentStep'] ?? 'Initializing...',
      logs: List<String>.from(json['logs'] ?? []),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      errorMessage: json['errorMessage'],
      outputPath: json['outputPath'] ?? '',
    );
  }
}
