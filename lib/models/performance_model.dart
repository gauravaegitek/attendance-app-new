// // lib/models/performance_model.dart

// class EmployeeScoreModel {
//   final int userId;
//   final String userName;
//   final String? role;
//   final String? department;
//   final int month;
//   final int year;
//   final int? totalWorkingDays;
//   final int? presentDays;
//   final int? wfhDays;
//   final int? absentDays;
//   final double? attendancePercentage;
//   final double? averageWorkingHours;
//   final double? performanceScore;
//   final String? grade;
//   final double? autoScore;
//   final double? manualScore;
//   final String? comments;

//   EmployeeScoreModel({
//     required this.userId,
//     required this.userName,
//     this.role,
//     this.department,
//     required this.month,
//     required this.year,
//     this.totalWorkingDays,
//     this.presentDays,
//     this.wfhDays,
//     this.absentDays,
//     this.attendancePercentage,
//     this.averageWorkingHours,
//     this.performanceScore,
//     this.grade,
//     this.autoScore,
//     this.manualScore,
//     this.comments,
//   });

//   double get finalScore => manualScore ?? performanceScore ?? 0.0;

//   factory EmployeeScoreModel.fromJson(Map<String, dynamic> json) {
//     return EmployeeScoreModel(
//       userId:               json['userId']               ?? 0,
//       userName:             json['userName']?.toString() ?? '',
//       role:                 json['role'],
//       department:           json['department'],
//       month:                json['month']                ?? 0,
//       year:                 json['year']                 ?? 0,
//       totalWorkingDays:     json['totalWorkingDays'],
//       presentDays:          json['presentDays'],
//       wfhDays:              json['wfhDays'],
//       absentDays:           json['absentDays'],
//       attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
//       averageWorkingHours:  (json['averageWorkingHours']  as num?)?.toDouble(),
//       performanceScore:     (json['performanceScore']     as num?)?.toDouble(),
//       grade:                json['grade'],
//       autoScore:            (json['autoScore']            as num?)?.toDouble(),
//       manualScore:          (json['manualScore']          as num?)?.toDouble(),
//       comments:             json['comments'],
//     );
//   }
// }

// class RankingModel {
//   final int rank;
//   final int userId;
//   final String userName;
//   final String? department;
//   final double? performanceScore;
//   final String? grade;
//   final int? presentDays;
//   final double? attendancePercentage;

//   RankingModel({
//     required this.rank,
//     required this.userId,
//     required this.userName,
//     this.department,
//     this.performanceScore,
//     this.grade,
//     this.presentDays,
//     this.attendancePercentage,
//   });

//   double get finalScore => performanceScore ?? 0.0;

//   factory RankingModel.fromJson(Map<String, dynamic> json) {
//     return RankingModel(
//       rank:                 json['rank']                                 ?? 0,
//       userId:               json['userId']                               ?? 0,
//       userName:             json['userName']?.toString()                 ?? '',
//       department:           json['department'],
//       performanceScore:     (json['performanceScore']     as num?)?.toDouble(),
//       grade:                json['grade'],
//       presentDays:          json['presentDays'],
//       attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
//     );
//   }
// }

// class ReviewModel {
//   final int id;
//   final int userId;
//   final String userName;
//   final int month;
//   final int year;
//   final double? manualScore;
//   final String? comments;
//   final String? reviewedBy;
//   final DateTime? reviewedAt;

//   ReviewModel({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     required this.month,
//     required this.year,
//     this.manualScore,
//     this.comments,
//     this.reviewedBy,
//     this.reviewedAt,
//   });

//   factory ReviewModel.fromJson(Map<String, dynamic> json) {
//     return ReviewModel(
//       id:         json['id']       ?? 0,
//       userId:     json['userId']   ?? 0,
//       userName:   json['userName']?.toString() ?? '',
//       month:      json['month']    ?? 0,
//       year:       json['year']     ?? 0,
//       manualScore:(json['manualScore'] as num?)?.toDouble(),
//       comments:   json['comments'],
//       reviewedBy: json['reviewedBy'],
//       reviewedAt: json['reviewedAt'] != null
//           ? DateTime.tryParse(json['reviewedAt'])
//           : null,
//     );
//   }
// }

// class ReviewRequestModel {
//   final int userId;
//   final int month;
//   final int year;
//   final double manualScore;
//   final String comments;

//   ReviewRequestModel({
//     required this.userId,
//     required this.month,
//     required this.year,
//     required this.manualScore,
//     required this.comments,
//   });

//   Map<String, dynamic> toJson() => {
//         'userId':      userId,
//         'month':       month,
//         'year':        year,
//         'manualScore': manualScore,
//         'comments':    comments,
//       };
// }








// // lib/models/performance_model.dart

// class EmployeeScoreModel {
//   final int userId;
//   final String userName;
//   final String? role;
//   final String? department;
//   final int month;
//   final int year;
//   final int? totalWorkingDays;
//   final int? presentDays;
//   final int? wfhDays;
//   final int? absentDays;
//   final double? attendancePercentage;
//   final double? averageWorkingHours;
//   final double? performanceScore;
//   final String? grade;
//   final double? autoScore;
//   final double? manualScore;
//   final String? comments;

//   EmployeeScoreModel({
//     required this.userId,
//     required this.userName,
//     this.role,
//     this.department,
//     required this.month,
//     required this.year,
//     this.totalWorkingDays,
//     this.presentDays,
//     this.wfhDays,
//     this.absentDays,
//     this.attendancePercentage,
//     this.averageWorkingHours,
//     this.performanceScore,
//     this.grade,
//     this.autoScore,
//     this.manualScore,
//     this.comments,
//   });

//   double get finalScore => manualScore ?? performanceScore ?? 0.0;

//   factory EmployeeScoreModel.fromJson(Map<String, dynamic> json) {
//     return EmployeeScoreModel(
//       userId: json['userId'] ?? 0,
//       userName: json['userName']?.toString() ?? '',
//       role: json['role'],
//       department: json['department'],
//       month: json['month'] ?? 0,
//       year: json['year'] ?? 0,
//       totalWorkingDays: json['totalWorkingDays'],
//       presentDays: json['presentDays'],
//       wfhDays: json['wfhDays'],
//       absentDays: json['absentDays'],
//       attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
//       averageWorkingHours: (json['averageWorkingHours'] as num?)?.toDouble(),
//       performanceScore: (json['performanceScore'] as num?)?.toDouble(),
//       grade: json['grade'],
//       autoScore: (json['autoScore'] as num?)?.toDouble(),
//       manualScore: (json['manualScore'] as num?)?.toDouble(),
//       comments: json['comments'],
//     );
//   }
// }

// class RankingModel {
//   final int rank;
//   final int userId;
//   final String userName;
//   final String? department;
//   final double? performanceScore;
//   final String? grade;
//   final int? presentDays;
//   final double? attendancePercentage;

//   RankingModel({
//     required this.rank,
//     required this.userId,
//     required this.userName,
//     this.department,
//     this.performanceScore,
//     this.grade,
//     this.presentDays,
//     this.attendancePercentage,
//   });

//   double get finalScore => performanceScore ?? 0.0;

//   factory RankingModel.fromJson(Map<String, dynamic> json) {
//     return RankingModel(
//       rank: json['rank'] ?? 0,
//       userId: json['userId'] ?? 0,
//       userName: json['userName']?.toString() ?? '',
//       department: json['department'],
//       performanceScore: (json['performanceScore'] as num?)?.toDouble(),
//       grade: json['grade'],
//       presentDays: json['presentDays'],
//       attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
//     );
//   }
// }

// class ReviewModel {
//   // ✅ Backend always sends reviewId
//   final int reviewId;

//   final int userId;
//   final String userName;
//   final int month;
//   final int year;
//   final double? manualScore;
//   final String? comments;
//   final String? reviewedBy;
//   final DateTime? reviewedAt;

//   // optional fields from API (you had createdOn in logs)
//   final String? role;
//   final double? attendanceScore;
//   final double? finalScore;
//   final String? grade;
//   final String? createdOnRaw;

//   ReviewModel({
//     required this.reviewId,
//     required this.userId,
//     required this.userName,
//     required this.month,
//     required this.year,
//     this.manualScore,
//     this.comments,
//     this.reviewedBy,
//     this.reviewedAt,
//     this.role,
//     this.attendanceScore,
//     this.finalScore,
//     this.grade,
//     this.createdOnRaw,
//   });

//   factory ReviewModel.fromJson(Map<String, dynamic> json) {
//     return ReviewModel(
//       reviewId: json['reviewId'] ?? 0,
//       userId: json['userId'] ?? 0,
//       userName: json['userName']?.toString() ?? '',
//       role: json['role']?.toString(),
//       month: json['month'] ?? 0,
//       year: json['year'] ?? 0,
//       attendanceScore: (json['attendanceScore'] as num?)?.toDouble(),
//       manualScore: (json['manualScore'] as num?)?.toDouble(),
//       finalScore: (json['finalScore'] as num?)?.toDouble(),
//       grade: json['grade']?.toString(),
//       comments: json['comments'],
//       createdOnRaw: json['createdOn']?.toString(),
//       reviewedBy: json['reviewedBy'],
//       reviewedAt: json['reviewedAt'] != null
//           ? DateTime.tryParse(json['reviewedAt'])
//           : null,
//     );
//   }
// }

// class ReviewRequestModel {
//   // ✅ optional (only for update/edit)
//   final int? reviewId;

//   final int userId;
//   final int month;
//   final int year;
//   final double manualScore;
//   final String comments;

//   ReviewRequestModel({
//     this.reviewId,
//     required this.userId,
//     required this.month,
//     required this.year,
//     required this.manualScore,
//     required this.comments,
//   });

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{
//       'userId': userId,
//       'month': month,
//       'year': year,
//       'manualScore': manualScore,
//       'comments': comments,
//     };

//     // ✅ send only if editing
//     if (reviewId != null && reviewId! > 0) {
//       map['reviewId'] = reviewId;
//     }
//     return map;
//   }
// }

// /// ✅ API submit response wrapper
// class SubmitReviewResponse {
//   final bool success;
//   final String message;
//   final ReviewModel? data;

//   SubmitReviewResponse({
//     required this.success,
//     required this.message,
//     this.data,
//   });

//   factory SubmitReviewResponse.fromJson(Map<String, dynamic> json) {
//     return SubmitReviewResponse(
//       success: json['success'] == true,
//       message: (json['message'] ?? '').toString(),
//       data: (json['data'] != null && json['data'] is Map<String, dynamic>)
//           ? ReviewModel.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }











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
      userId:              json['userId'] ?? 0,
      userName:            json['userName']?.toString() ?? '',
      role:                json['role'],
      department:          json['department'],
      month:               json['month'] ?? 0,
      year:                json['year'] ?? 0,
      totalWorkingDays:    json['totalWorkingDays'],
      presentDays:         json['presentDays'],
      // ✅ FIX: wfhDays — int ya num dono handle karo
      wfhDays:             (json['wfhDays'] as num?)?.toInt(),
      absentDays:          (json['absentDays'] as num?)?.toInt(),
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
      averageWorkingHours: (json['averageWorkingHours'] as num?)?.toDouble(),
      performanceScore:    (json['performanceScore'] as num?)?.toDouble(),
      grade:               json['grade'],
      autoScore:           (json['autoScore'] as num?)?.toDouble(),
      manualScore:         (json['manualScore'] as num?)?.toDouble(),
      comments:            json['comments'],
    );
  }
}

class RankingModel {
  final int rank;
  final int userId;
  final String userName;
  final String? department;  // ✅ department parent group se aata hai
  final double? performanceScore;
  final String? grade;
  final int? presentDays;
  final int? wfhDays;
  final double? attendancePercentage;

  RankingModel({
    required this.rank,
    required this.userId,
    required this.userName,
    this.department,
    this.performanceScore,
    this.grade,
    this.presentDays,
    this.wfhDays,
    this.attendancePercentage,
  });

  double get finalScore => performanceScore ?? 0.0;

  // ✅ FIX: department alag se pass karna hoga (parent group se)
  factory RankingModel.fromJson(Map<String, dynamic> json,
      {String? department}) {
    return RankingModel(
      rank:                json['rank'] ?? 0,
      userId:              json['userId'] ?? 0,
      userName:            json['userName']?.toString() ?? '',
      // department: json mein nahi hota nested structure mein,
      // parent se pass karo
      department:          department ?? json['department'],
      performanceScore:    (json['performanceScore'] as num?)?.toDouble(),
      grade:               json['grade'],
      presentDays:         (json['presentDays'] as num?)?.toInt(),
      wfhDays:             (json['wfhDays'] as num?)?.toInt(),
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),
    );
  }

  // ✅ Re-ranked copy banane ke liye (global sort ke baad)
  RankingModel copyWith({int? rank}) {
    return RankingModel(
      rank:                rank ?? this.rank,
      userId:              userId,
      userName:            userName,
      department:          department,
      performanceScore:    performanceScore,
      grade:               grade,
      presentDays:         presentDays,
      wfhDays:             wfhDays,
      attendancePercentage: attendancePercentage,
    );
  }
}

class ReviewModel {
  final int reviewId;
  final int userId;
  final String userName;
  final int month;
  final int year;
  final double? manualScore;
  final String? comments;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? role;
  final double? attendanceScore;
  final double? finalScore;
  final String? grade;
  final String? createdOnRaw;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.month,
    required this.year,
    this.manualScore,
    this.comments,
    this.reviewedBy,
    this.reviewedAt,
    this.role,
    this.attendanceScore,
    this.finalScore,
    this.grade,
    this.createdOnRaw,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId:        json['reviewId'] ?? 0,
      userId:          json['userId'] ?? 0,
      userName:        json['userName']?.toString() ?? '',
      role:            json['role']?.toString(),
      month:           json['month'] ?? 0,
      year:            json['year'] ?? 0,
      attendanceScore: (json['attendanceScore'] as num?)?.toDouble(),
      manualScore:     (json['manualScore'] as num?)?.toDouble(),
      finalScore:      (json['finalScore'] as num?)?.toDouble(),
      grade:           json['grade']?.toString(),
      comments:        json['comments'],
      createdOnRaw:    json['createdOn']?.toString(),
      reviewedBy:      json['reviewedBy'],
      reviewedAt:      json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'])
          : null,
    );
  }
}

class ReviewRequestModel {
  final int? reviewId;
  final int userId;
  final int month;
  final int year;
  final double manualScore;
  final String comments;

  ReviewRequestModel({
    this.reviewId,
    required this.userId,
    required this.month,
    required this.year,
    required this.manualScore,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId':      userId,
      'month':       month,
      'year':        year,
      'manualScore': manualScore,
      'comments':    comments,
    };
    if (reviewId != null && reviewId! > 0) {
      map['reviewId'] = reviewId;
    }
    return map;
  }
}

class SubmitReviewResponse {
  final bool success;
  final String message;
  final ReviewModel? data;

  SubmitReviewResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SubmitReviewResponse.fromJson(Map<String, dynamic> json) {
    return SubmitReviewResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: (json['data'] != null && json['data'] is Map<String, dynamic>)
          ? ReviewModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}