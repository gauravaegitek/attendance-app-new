// lib/models/performance_model.dart

class EmployeeScoreModel {
  final int userId;
  final String userName;
  final String? role;
  final String? department;
  final int month;
  final int year;
  final int? totalWorkingDays;
  final int? presentDays;
  final int? wfhDays;
  final int? absentDays;
  final double? attendancePercentage;
  final double? averageWorkingHours;
  final double? performanceScore;
  final String? grade;
  final double? autoScore;
  final double? manualScore;
  final String? comments;

  EmployeeScoreModel({
    required this.userId,
    required this.userName,
    this.role,
    this.department,
    required this.month,
    required this.year,
    this.totalWorkingDays,
    this.presentDays,
    this.wfhDays,
    this.absentDays,
    this.attendancePercentage,
    this.averageWorkingHours,
    this.performanceScore,
    this.grade,
    this.autoScore,
    this.manualScore,
    this.comments,
  });

  double get finalScore => manualScore ?? performanceScore ?? 0.0;

  factory EmployeeScoreModel.fromJson(Map<String, dynamic> json) {
    return EmployeeScoreModel(
      userId:               json['userId']               ?? 0,
      userName:             json['userName']?.toString() ?? '',
      role:                 json['role'],
      department:           json['department'],
      month:                json['month']                ?? 0,
      year:                 json['year']                 ?? 0,
      totalWorkingDays:     json['totalWorkingDays'],
      presentDays:          json['presentDays'],
      wfhDays:              json['wfhDays'],
      absentDays:           json['absentDays'],
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
      averageWorkingHours:  (json['averageWorkingHours']  as num?)?.toDouble(),
      performanceScore:     (json['performanceScore']     as num?)?.toDouble(),
      grade:                json['grade'],
      autoScore:            (json['autoScore']            as num?)?.toDouble(),
      manualScore:          (json['manualScore']          as num?)?.toDouble(),
      comments:             json['comments'],
    );
  }
}

class RankingModel {
  final int rank;
  final int userId;
  final String userName;
  final String? department;
  final double? performanceScore;
  final String? grade;
  final int? presentDays;
  final double? attendancePercentage;

  RankingModel({
    required this.rank,
    required this.userId,
    required this.userName,
    this.department,
    this.performanceScore,
    this.grade,
    this.presentDays,
    this.attendancePercentage,
  });

  double get finalScore => performanceScore ?? 0.0;

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      rank:                 json['rank']                                 ?? 0,
      userId:               json['userId']                               ?? 0,
      userName:             json['userName']?.toString()                 ?? '',
      department:           json['department'],
      performanceScore:     (json['performanceScore']     as num?)?.toDouble(),
      grade:                json['grade'],
      presentDays:          json['presentDays'],
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
    );
  }
}

class ReviewModel {
  final int id;
  final int userId;
  final String userName;
  final int month;
  final int year;
  final double? manualScore;
  final String? comments;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.month,
    required this.year,
    this.manualScore,
    this.comments,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id:         json['id']       ?? 0,
      userId:     json['userId']   ?? 0,
      userName:   json['userName']?.toString() ?? '',
      month:      json['month']    ?? 0,
      year:       json['year']     ?? 0,
      manualScore:(json['manualScore'] as num?)?.toDouble(),
      comments:   json['comments'],
      reviewedBy: json['reviewedBy'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'])
          : null,
    );
  }
}

class ReviewRequestModel {
  final int userId;
  final int month;
  final int year;
  final double manualScore;
  final String comments;

  ReviewRequestModel({
    required this.userId,
    required this.month,
    required this.year,
    required this.manualScore,
    required this.comments,
  });

  Map<String, dynamic> toJson() => {
        'userId':      userId,
        'month':       month,
        'year':        year,
        'manualScore': manualScore,
        'comments':    comments,
      };
}