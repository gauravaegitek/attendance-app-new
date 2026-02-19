// // =================== AUTH MODELS ===================

// class LoginRequest {
//   final String email;
//   final String password;
//   final String deviceId;

//   LoginRequest({
//     required this.email,
//     required this.password,
//     required this.deviceId,
//   });

//   Map<String, dynamic> toJson() => {
//     'email': email,
//     'password': password,
//     'deviceId': deviceId,
//   };
// }

// class RegisterRequest {
//   final String userName;
//   final String email;
//   final String password;
//   final String role;

//   RegisterRequest({
//     required this.userName,
//     required this.email,
//     required this.password,
//     required this.role,
//   });

//   Map<String, dynamic> toJson() => {
//     'userName': userName,
//     'email': email,
//     'password': password,
//     'role': role,
//   };
// }

// class AuthResponse {
//   final bool success;
//   final String message;
//   final AuthData? data;

//   AuthResponse({
//     required this.success,
//     required this.message,
//     this.data,
//   });

//   factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
//     success: json['success'] ?? false,
//     message: json['message'] ?? '',
//     data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
//   );
// }

// class AuthData {
//   final int userId;
//   final String userName;
//   final String email;
//   final String role;
//   final String? token;
//   final String? message;

//   AuthData({
//     required this.userId,
//     required this.userName,
//     required this.email,
//     required this.role,
//     this.token,
//     this.message,
//   });

//   factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
//     userId: json['userId'] ?? 0,
//     userName: json['userName'] ?? '',
//     email: json['email'] ?? '',
//     role: json['role'] ?? '',
//     token: json['token'],
//     message: json['message'],
//   );
// }

// class UserModel {
//   final int userId;
//   final String userName;
//   final String email;
//   final String role;
//   final bool isActive;
//   final String? lastSeen;
//   final String? createdOn;

//   UserModel({
//     required this.userId,
//     required this.userName,
//     required this.email,
//     required this.role,
//     required this.isActive,
//     this.lastSeen,
//     this.createdOn,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//     userId: json['userId'] ?? 0,
//     userName: json['userName'] ?? '',
//     email: json['email'] ?? '',
//     role: json['role'] ?? '',
//     isActive: json['isActive'] ?? false,
//     lastSeen: json['lastSeen'],
//     createdOn: json['createdOn'],
//   );
// }

// // =================== ATTENDANCE MODELS ===================

// class MarkInResponse {
//   final bool success;
//   final String message;
//   final MarkInData? data;

//   MarkInResponse({required this.success, required this.message, this.data});

//   factory MarkInResponse.fromJson(Map<String, dynamic> json) => MarkInResponse(
//     success: json['success'] ?? false,
//     message: json['message'] ?? '',
//     data: json['data'] != null ? MarkInData.fromJson(json['data']) : null,
//   );
// }

// class MarkInData {
//   final String attendanceDate;
//   final TimeData? inTime;
//   final String location;

//   MarkInData({
//     required this.attendanceDate,
//     this.inTime,
//     required this.location,
//   });

//   factory MarkInData.fromJson(Map<String, dynamic> json) => MarkInData(
//     attendanceDate: json['attendanceDate'] ?? '',
//     inTime: json['inTime'] != null ? TimeData.fromJson(json['inTime']) : null,
//     location: json['location'] ?? '',
//   );
// }

// class MarkOutData {
//   final String attendanceDate;
//   final TimeData? inTime;
//   final TimeData? outTime;
//   final String totalHours;
//   final String location;

//   MarkOutData({
//     required this.attendanceDate,
//     this.inTime,
//     this.outTime,
//     required this.totalHours,
//     required this.location,
//   });

//   factory MarkOutData.fromJson(Map<String, dynamic> json) => MarkOutData(
//     attendanceDate: json['attendanceDate'] ?? '',
//     inTime: json['inTime'] != null ? TimeData.fromJson(json['inTime']) : null,
//     outTime: json['outTime'] != null ? TimeData.fromJson(json['outTime']) : null,
//     totalHours: json['totalHours']?.toString() ?? '0',
//     location: json['location'] ?? '',
//   );
// }

// class TimeData {
//   final String ticks;

//   TimeData({required this.ticks});

//   factory TimeData.fromJson(Map<String, dynamic> json) =>
//       TimeData(ticks: json['ticks'] ?? '');
// }

// class AttendanceRecord {
//   final int attendanceId;
//   final String userName;
//   final String role;
//   final String attendanceDate;
//   final String? inTime;
//   final String? outTime;
//   final String? inLocation;
//   final String? outLocation;
//   final double? totalHours;
//   final String status;

//   AttendanceRecord({
//     required this.attendanceId,
//     required this.userName,
//     required this.role,
//     required this.attendanceDate,
//     this.inTime,
//     this.outTime,
//     this.inLocation,
//     this.outLocation,
//     this.totalHours,
//     required this.status,
//   });

//   factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
//       AttendanceRecord(
//         attendanceId: json['attendanceId'] ?? 0,
//         userName: json['userName'] ?? '',
//         role: json['role'] ?? '',
//         attendanceDate: json['attendanceDate'] ?? '',
//         inTime: json['inTime'],
//         outTime: json['outTime'],
//         inLocation: json['inLocation'],
//         outLocation: json['outLocation'],
//         totalHours: json['totalHours']?.toDouble(),
//         status: json['status'] ?? 'Incomplete',
//       );
// }

// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? data;

//   ApiResponse({required this.success, required this.message, this.data});

//   factory ApiResponse.fromJson(
//     Map<String, dynamic> json,
//     T Function(dynamic)? fromData,
//   ) =>
//       ApiResponse(
//         success: json['success'] ?? false,
//         message: json['message'] ?? '',
//         data: json['data'] != null && fromData != null
//             ? fromData(json['data'])
//             : null,
//       );
// }






// // =================== ROLE MODEL ===================

// class RoleModel {
//   final int roleId;
//   final String roleName;

//   RoleModel({required this.roleId, required this.roleName});

//   factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
//         roleId: json['roleId'] ?? json['id'] ?? 0,
//         roleName: (json['roleName'] ?? json['name'] ?? '').toString(),
//       );
// }

// // =================== AUTH MODELS ===================

// class LoginRequest {
//   final String email;
//   final String password;
//   final String deviceId;

//   LoginRequest({
//     required this.email,
//     required this.password,
//     required this.deviceId,
//   });

//   Map<String, dynamic> toJson() => {
//         'email': email,
//         'password': password,
//         'deviceId': deviceId,
//       };
// }

// class RegisterRequest {
//   final String userName;
//   final String email;
//   final String password;
//   final String confirmPassword;
//   final String role;
//   final int roleId; // ✅ ADDED

//   RegisterRequest({
//     required this.userName,
//     required this.email,
//     required this.password,
//     required this.confirmPassword,
//     required this.role,
//     required this.roleId, // ✅ ADDED
//   });

//   Map<String, dynamic> toJson() => {
//         'userName': userName,
//         'email': email,
//         'password': password,
//         'confirmPassword': confirmPassword,
//         'role': role,
//         'roleId': roleId, // ✅ ADDED — DB mein save hoga
//       };
// }

// class AuthResponse {
//   final bool success;
//   final String message;
//   final AuthData? data;

//   AuthResponse({
//     required this.success,
//     required this.message,
//     this.data,
//   });

//   factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
//         success: json['success'] ?? false,
//         message: json['message'] ?? '',
//         data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
//       );
// }

// class AuthData {
//   final int userId;
//   final String userName;
//   final String email;
//   final String role;
//   final String? token;
//   final String? message;

//   AuthData({
//     required this.userId,
//     required this.userName,
//     required this.email,
//     required this.role,
//     this.token,
//     this.message,
//   });

//   factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
//         userId: json['userId'] ?? 0,
//         userName: json['userName'] ?? '',
//         email: json['email'] ?? '',
//         role: json['role'] ?? '',
//         token: json['token'],
//         message: json['message'],
//       );
// }

// class UserModel {
//   final int userId;
//   final String userName;
//   final String email;
//   final String role;
//   final bool isActive;
//   final String? lastSeen;
//   final String? createdOn;

//   UserModel({
//     required this.userId,
//     required this.userName,
//     required this.email,
//     required this.role,
//     required this.isActive,
//     this.lastSeen,
//     this.createdOn,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//         userId: json['userId'] ?? 0,
//         userName: json['userName'] ?? '',
//         email: json['email'] ?? '',
//         role: json['role'] ?? '',
//         isActive: json['isActive'] ?? false,
//         lastSeen: json['lastSeen'],
//         createdOn: json['createdOn'],
//       );
// }

// // =================== ATTENDANCE MODELS ===================

// class MarkInResponse {
//   final bool success;
//   final String message;
//   final MarkInData? data;

//   MarkInResponse({required this.success, required this.message, this.data});

//   factory MarkInResponse.fromJson(Map<String, dynamic> json) => MarkInResponse(
//         success: json['success'] ?? false,
//         message: json['message'] ?? '',
//         data: json['data'] != null ? MarkInData.fromJson(json['data']) : null,
//       );
// }

// class MarkInData {
//   final String attendanceDate;
//   final TimeData? inTime;
//   final String location;

//   MarkInData({
//     required this.attendanceDate,
//     this.inTime,
//     required this.location,
//   });

//   factory MarkInData.fromJson(Map<String, dynamic> json) => MarkInData(
//         attendanceDate: json['attendanceDate'] ?? '',
//         inTime:
//             json['inTime'] != null ? TimeData.fromJson(json['inTime']) : null,
//         location: json['location'] ?? '',
//       );
// }

// class MarkOutData {
//   final String attendanceDate;
//   final TimeData? inTime;
//   final TimeData? outTime;
//   final String totalHours;
//   final String location;

//   MarkOutData({
//     required this.attendanceDate,
//     this.inTime,
//     this.outTime,
//     required this.totalHours,
//     required this.location,
//   });

//   factory MarkOutData.fromJson(Map<String, dynamic> json) => MarkOutData(
//         attendanceDate: json['attendanceDate'] ?? '',
//         inTime:
//             json['inTime'] != null ? TimeData.fromJson(json['inTime']) : null,
//         outTime:
//             json['outTime'] != null ? TimeData.fromJson(json['outTime']) : null,
//         totalHours: json['totalHours']?.toString() ?? '0',
//         location: json['location'] ?? '',
//       );
// }

// class TimeData {
//   final String ticks;

//   TimeData({required this.ticks});

//   factory TimeData.fromJson(Map<String, dynamic> json) =>
//       TimeData(ticks: json['ticks'] ?? '');
// }

// class AttendanceRecord {
//   final int attendanceId;
//   final String userName;
//   final String role;
//   final String attendanceDate;
//   final String? inTime;
//   final String? outTime;
//   final String? inLocation;
//   final String? outLocation;
//   final double? totalHours;
//   final String status;

//   AttendanceRecord({
//     required this.attendanceId,
//     required this.userName,
//     required this.role,
//     required this.attendanceDate,
//     this.inTime,
//     this.outTime,
//     this.inLocation,
//     this.outLocation,
//     this.totalHours,
//     required this.status,
//   });

//   factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
//       AttendanceRecord(
//         attendanceId: json['attendanceId'] ?? 0,
//         userName: json['userName'] ?? '',
//         role: json['role'] ?? '',
//         attendanceDate: json['attendanceDate'] ?? '',
//         inTime: json['inTime'],
//         outTime: json['outTime'],
//         inLocation: json['inLocation'],
//         outLocation: json['outLocation'],
//         totalHours: json['totalHours']?.toDouble(),
//         status: json['status'] ?? 'Incomplete',
//       );
// }

// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? data;

//   ApiResponse({required this.success, required this.message, this.data});

//   factory ApiResponse.fromJson(
//     Map<String, dynamic> json,
//     T Function(dynamic)? fromData,
//   ) =>
//       ApiResponse(
//         success: json['success'] ?? false,
//         message: json['message'] ?? '',
//         data: json['data'] != null && fromData != null
//             ? fromData(json['data'])
//             : null,
//       );
// }








// =================== ROLE MODEL ===================

class RoleModel {
  final int roleId;
  final String roleName;

  RoleModel({required this.roleId, required this.roleName});

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        roleId: json['roleId'] ?? json['id'] ?? 0,
        roleName: (json['roleName'] ?? json['name'] ?? '').toString(),
      );
}

// =================== AUTH MODELS ===================

class LoginRequest {
  final String email;
  final String password;
  final String deviceId;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'deviceId': deviceId,
      };
}

class RegisterRequest {
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final int roleId;

  RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    required this.roleId,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
        'roleId': roleId,
      };
}

class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      );
}

class AuthData {
  final int userId;
  final String userName;
  final String email;
  final String role;
  final String? token;
  final String? message;

  // ✅ DB ke roles table ka requiresSelfie column
  // true  → selfie mandatory  → Screen: 🔴 Required
  // false → selfie optional   → Screen: ⚪ Optional
  final bool requiresSelfie;

  AuthData({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    this.token,
    this.message,
    this.requiresSelfie = false, // ✅ default false
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        userId: json['userId'] ?? 0,
        userName: json['userName'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        token: json['token'],
        message: json['message'],
        // ✅ Backend 'requiresSelfie' field se aayega
        requiresSelfie: json['requiresSelfie'] as bool? ?? false,
      );
}

class UserModel {
  final int userId;
  final String userName;
  final String email;
  final String role;
  final bool isActive;
  final String? lastSeen;
  final String? createdOn;

  UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastSeen,
    this.createdOn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['userId'] ?? 0,
        userName: json['userName'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        isActive: json['isActive'] ?? false,
        lastSeen: json['lastSeen'],
        createdOn: json['createdOn'],
      );
}

// =================== ATTENDANCE MODELS ===================

class MarkInResponse {
  final bool success;
  final String message;
  final MarkInData? data;

  MarkInResponse({required this.success, required this.message, this.data});

  factory MarkInResponse.fromJson(Map<String, dynamic> json) => MarkInResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? MarkInData.fromJson(json['data']) : null,
      );
}

class MarkInData {
  final String attendanceDate;
  final TimeData? inTime;
  final String location;

  MarkInData({
    required this.attendanceDate,
    this.inTime,
    required this.location,
  });

  factory MarkInData.fromJson(Map<String, dynamic> json) => MarkInData(
        attendanceDate: json['attendanceDate'] ?? '',
        inTime:
            json['inTime'] != null ? TimeData.fromJson(json['inTime']) : null,
        location: json['location'] ?? '',
      );
}

class MarkOutData {
  final String attendanceDate;
  final TimeData? inTime;
  final TimeData? outTime;
  final String totalHours;
  final String location;

  MarkOutData({
    required this.attendanceDate,
    this.inTime,
    this.outTime,
    required this.totalHours,
    required this.location,
  });

  factory MarkOutData.fromJson(Map<String, dynamic> json) => MarkOutData(
        attendanceDate: json['attendanceDate'] ?? '',
        inTime:
            json['inTime'] != null ? TimeData.fromJson(json['inTime']) : null,
        outTime:
            json['outTime'] != null ? TimeData.fromJson(json['outTime']) : null,
        totalHours: json['totalHours']?.toString() ?? '0',
        location: json['location'] ?? '',
      );
}

class TimeData {
  final String ticks;

  TimeData({required this.ticks});

  factory TimeData.fromJson(Map<String, dynamic> json) =>
      TimeData(ticks: json['ticks'] ?? '');
}

class AttendanceRecord {
  final int attendanceId;
  final String userName;
  final String role;
  final String attendanceDate;
  final String? inTime;
  final String? outTime;
  final String? inLocation;
  final String? outLocation;
  final double? totalHours;
  final String status;

  AttendanceRecord({
    required this.attendanceId,
    required this.userName,
    required this.role,
    required this.attendanceDate,
    this.inTime,
    this.outTime,
    this.inLocation,
    this.outLocation,
    this.totalHours,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        attendanceId: json['attendanceId'] ?? 0,
        userName: json['userName'] ?? '',
        role: json['role'] ?? '',
        attendanceDate: json['attendanceDate'] ?? '',
        inTime: json['inTime'],
        outTime: json['outTime'],
        inLocation: json['inLocation'],
        outLocation: json['outLocation'],
        totalHours: json['totalHours']?.toDouble(),
        status: json['status'] ?? 'Incomplete',
      );
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) =>
      ApiResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null && fromData != null
            ? fromData(json['data'])
            : null,
      );
}