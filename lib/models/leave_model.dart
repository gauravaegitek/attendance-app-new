// lib/models/leave_model.dart

class LeaveModel {
  final int id;
  final int userId;
  final String userName;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // Pending, Approved, Rejected
  final String? adminRemark;
  final DateTime createdAt;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.adminRemark,
    required this.createdAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id:          json['id']          ?? 0,
      userId:      json['userId']      ?? 0,
      userName:    json['userName']    ?? json['name'] ?? '',
      leaveType:   json['leaveType']   ?? '',
      fromDate:    DateTime.tryParse(json['fromDate'] ?? '') ?? DateTime.now(),
      toDate:      DateTime.tryParse(json['toDate']   ?? '') ?? DateTime.now(),
      reason:      json['reason']      ?? '',
      status:      json['status']      ?? 'Pending',
      adminRemark: json['adminRemark'],
      createdAt:   DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  int get totalDays => toDate.difference(fromDate).inDays + 1;
}