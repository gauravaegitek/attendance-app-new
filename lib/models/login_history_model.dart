// // lib/models/login_history_model.dart

// class LoginHistoryModel {
//   final int id;
//   final int userId;
//   final String userName;
//   final String? userEmail;
//   final String? role;
//   final String loginTime;
//   final String? logoutTime;
//   final String? deviceId;
//   final String? ipAddress;
//   final String? platform;
//   final bool isActive;

//   const LoginHistoryModel({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     this.userEmail,
//     this.role,
//     required this.loginTime,
//     this.logoutTime,
//     this.deviceId,
//     this.ipAddress,
//     this.platform,
//     required this.isActive,
//   });

//   factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
//     return LoginHistoryModel(
//       id:          (json['id']         ?? json['loginHistoryId'] ?? 0) as int,
//       userId:      (json['userId']     ?? 0) as int,
//       userName:    (json['userName']   ?? json['name'] ?? '').toString(),
//       userEmail:   json['userEmail']   as String?,
//       role:        json['role']        as String?,
//       loginTime:   (json['loginTime']  ?? json['loginAt'] ?? '').toString(),
//       logoutTime:  json['logoutTime']  as String? ?? json['logoutAt'] as String?,
//       deviceId:    json['deviceId']    as String?,
//       ipAddress:   json['ipAddress']   as String?,
//       platform:    json['platform']    as String?,
//       isActive:    (json['isActive']   ?? json['active'] ?? false) as bool,
//     );
//   }

//   /// Duration between login and logout (or "Active" if still logged in)
//   String get sessionDuration {
//     if (logoutTime == null || logoutTime!.isEmpty) return 'Active';
//     try {
//       final login  = DateTime.parse(loginTime);
//       final logout = DateTime.parse(logoutTime!);
//       final diff   = logout.difference(login);
//       if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
//       if (diff.inMinutes > 0) return '${diff.inMinutes}m ${diff.inSeconds.remainder(60)}s';
//       return '${diff.inSeconds}s';
//     } catch (_) {
//       return '--';
//     }
//   }
// }









// lib/models/login_history_model.dart

class LoginHistoryModel {
  final int     id;
  final int     userId;
  final String  userName;
  final String? userEmail;
  final String? role;
  final String  loginTime;
  final String? logoutTime;
  final String? deviceId;
  final String? ipAddress;
  final String? platform;
  final bool    isActive;

  // ✅ NEW
  final int?    totalMinutes;
  final String? totalDuration;
  final String? logoutReason;
  final String? sessionStatus;

  const LoginHistoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.role,
    required this.loginTime,
    this.logoutTime,
    this.deviceId,
    this.ipAddress,
    this.platform,
    required this.isActive,
    // ✅ NEW
    this.totalMinutes,
    this.totalDuration,
    this.logoutReason,
    this.sessionStatus,
  });

  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
    // ✅ loginTime — API "loginDate" + "loginTime" combine karo
    String loginTimeStr = '';
    final loginDate = json['loginDate']?.toString() ?? '';
    final loginTime = json['loginTime']?.toString() ?? '';
    if (loginDate.isNotEmpty && loginTime.isNotEmpty) {
      // "2026-03-01T00:00:00" + "15:47:44" → "2026-03-01T15:47:44"
      final datePart = loginDate.split('T')[0];
      loginTimeStr = '${datePart}T$loginTime';
    } else {
      loginTimeStr = (json['loginTime'] ?? json['loginAt'] ?? '').toString();
    }

    // ✅ logoutTime — API "logoutDate" + "logoutTime" combine karo
    String? logoutTimeStr;
    final logoutDate = json['logoutDate']?.toString() ?? '';
    final logoutTime = json['logoutTime']?.toString() ?? '';
    if (logoutDate.isNotEmpty && logoutTime.isNotEmpty) {
      final datePart = logoutDate.split('T')[0];
      logoutTimeStr = '${datePart}T$logoutTime';
    } else if (logoutTime.isNotEmpty) {
      logoutTimeStr = logoutTime;
    }

    return LoginHistoryModel(
      id:            (json['id']          ?? json['loginHistoryId'] ?? 0) as int,
      userId:        (json['userId']       ?? 0) as int,
      userName:      (json['userName']     ?? json['name'] ?? '').toString(),
      userEmail:     json['userEmail']     as String?,
      role:          json['role']          as String?,
      loginTime:     loginTimeStr,
      logoutTime:    logoutTimeStr,
      deviceId:      json['deviceId']      as String?,
      ipAddress:     json['ipAddress']     as String?,
      platform:      json['deviceType']    as String?,   // ✅ API mein deviceType hai
      isActive:      (json['isActive']     ?? json['active'] ?? false) as bool,
      // ✅ NEW
      totalMinutes:  json['totalMinutes']  as int?,
      totalDuration: json['totalDuration'] as String?,
      logoutReason:  json['logoutReason']  as String?,
      sessionStatus: json['sessionStatus'] as String?,
    );
  }

  /// ✅ API ka totalDuration use karo, fallback local calculation
  String get sessionDuration {
    // API se aaya to use karo
    if (totalDuration != null && totalDuration!.isNotEmpty) {
      return totalDuration!;
    }
    // Fallback — local calculate
    if (logoutTime == null || logoutTime!.isEmpty) return 'Active';
    try {
      final login  = DateTime.parse(loginTime);
      final logout = DateTime.parse(logoutTime!);
      final diff   = logout.difference(login);
      if (diff.inHours > 0)   return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return '${diff.inSeconds}s';
    } catch (_) {
      return '--';
    }
  }
}