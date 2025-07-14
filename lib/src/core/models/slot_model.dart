// lib/src/core/models/evaluation_slot_model.dart
class EvaluationSlotModel {
  final int id;
  final DateTime beginAt;
  final DateTime endAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? scaleTeam;
  final bool isBooked;

  EvaluationSlotModel({
    required this.id,
    required this.beginAt,
    required this.endAt,
    this.user,
    this.scaleTeam,
    this.isBooked = false,
  });

  factory EvaluationSlotModel.fromJson(Map<String, dynamic> json) {
    return EvaluationSlotModel(
      id: json['id'] ?? 0,
      beginAt: DateTime.parse(json['begin_at'] ?? DateTime.now().toIso8601String()),
      endAt: DateTime.parse(json['end_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'],
      scaleTeam: json['scale_team'],
      isBooked: json['scale_team'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'begin_at': beginAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'user': user,
      'scale_team': scaleTeam,
      'is_booked': isBooked,
    };
  }

  Duration get duration => endAt.difference(beginAt);
  
  bool get isAvailable => !isBooked && scaleTeam == null;
  
  String get evaluatorLogin => user?['login'] ?? 'Unknown';
  
  String get statusText {
    if (scaleTeam != null) {
      return 'Booked for evaluation';
    }
    return 'Available for evaluation';
  }

  SlotStatus get status {
    final now = DateTime.now();
    
    if (scaleTeam != null) {
      return SlotStatus.booked;
    }
    
    if (beginAt.isBefore(now) && endAt.isAfter(now)) {
      return SlotStatus.active;
    }
    
    if (endAt.isBefore(now)) {
      return SlotStatus.completed;
    }
    
    return SlotStatus.available;
  }

  bool get canCancel {
    final now = DateTime.now();
    return scaleTeam == null && beginAt.isAfter(now.add(Duration(minutes: 30)));
  }
}

enum SlotStatus {
  available,
  booked,
  active,
  completed,
}

// lib/src/core/models/scale_team_model.dart
class ScaleTeamModel {
  final int id;
  final DateTime? beginAt;
  final DateTime? filledAt;
  final String? comment;
  final String? feedback;
  final int? finalMark;
  final List<Map<String, dynamic>> correcteds;
  final Map<String, dynamic>? corrector;
  final Map<String, dynamic>? scale;
  final Map<String, dynamic>? team;
  final Map<String, dynamic>? flag;

  ScaleTeamModel({
    required this.id,
    this.beginAt,
    this.filledAt,
    this.comment,
    this.feedback,
    this.finalMark,
    this.correcteds = const [],
    this.corrector,
    this.scale,
    this.team,
    this.flag,
  });

  factory ScaleTeamModel.fromJson(Map<String, dynamic> json) {
    return ScaleTeamModel(
      id: json['id'] ?? 0,
      beginAt: json['begin_at'] != null ? DateTime.parse(json['begin_at']) : null,
      filledAt: json['filled_at'] != null ? DateTime.parse(json['filled_at']) : null,
      comment: json['comment'],
      feedback: json['feedback'],
      finalMark: json['final_mark'],
      correcteds: List<Map<String, dynamic>>.from(json['correcteds'] ?? []),
      corrector: json['corrector'],
      scale: json['scale'],
      team: json['team'],
      flag: json['flag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'begin_at': beginAt?.toIso8601String(),
      'filled_at': filledAt?.toIso8601String(),
      'comment': comment,
      'feedback': feedback,
      'final_mark': finalMark,
      'correcteds': correcteds,
      'corrector': corrector,
      'scale': scale,
      'team': team,
      'flag': flag,
    };
  }

  String get projectName => scale?['name'] ?? team?['project']?['name'] ?? 'Unknown Project';
  
  String get correctorLogin => corrector?['login'] ?? 'Unknown';
  
  List<String> get correctedLogins {
    return correcteds.map((user) => user['login'] as String? ?? 'Unknown').toList();
  }

  EvaluationStatus get status {
    if (filledAt != null) {
      return EvaluationStatus.completed;
    }
    
    if (beginAt != null) {
      final now = DateTime.now();
      if (beginAt!.isBefore(now)) {
        return EvaluationStatus.inProgress;
      }
    }
    
    return EvaluationStatus.scheduled;
  }

  bool get isCompleted => filledAt != null;
  bool get hasScore => finalMark != null;
}

enum EvaluationStatus {
  scheduled,
  inProgress,
  completed,
}

// lib/src/core/models/slot_creation_request.dart
class SlotCreationRequest {
  final DateTime beginAt;
  final DateTime endAt;
  final String? description;

  SlotCreationRequest({
    required this.beginAt,
    required this.endAt,
    this.description,
  });

  Duration get duration => endAt.difference(beginAt);
  
  bool get isValidDuration => duration.inSeconds >= 1800; // At least 30 minutes
  
  Map<String, dynamic> toJson() {
    return {
      'slot': {
        'begin_at': beginAt.toUtc().toIso8601String(),
        'end_at': endAt.toUtc().toIso8601String(),
      }
    };
  }

  String? validate() {
    final now = DateTime.now();
    
    if (!isValidDuration) {
      return 'Slot must be at least 30 minutes long';
    }
    
    if (beginAt.isBefore(now.add(Duration(minutes: 30)))) {
      return 'Slot must be at least 30 minutes in the future';
    }
    
    if (beginAt.isAfter(now.add(Duration(days: 14)))) {
      return 'Slot cannot be more than 2 weeks in advance';
    }
    
    if (endAt.isBefore(beginAt)) {
      return 'End time must be after begin time';
    }
    
    return null;
  }
}