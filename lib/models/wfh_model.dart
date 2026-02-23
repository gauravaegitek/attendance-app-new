class WfhModel {
  final int id;
  final String wfhDate;
  final String reason;
  final String status;
  final String? rejectionReason;
  final String? userName;
  final int? userId;

  WfhModel({
    required this.id,
    required this.wfhDate,
    required this.reason,
    required this.status,
    this.rejectionReason,
    this.userName,
    this.userId,
  });

  factory WfhModel.fromJson(Map<String, dynamic> json) {
    return WfhModel(
      id: json['wfhId'] ?? json['id'] ?? 0,
      wfhDate: json['wfhDate'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      userName: json['userName'] ?? json['name'],
      userId: json['userId'],
    );
  }
}