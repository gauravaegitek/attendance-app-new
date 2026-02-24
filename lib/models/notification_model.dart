// lib/models/notification_model.dart

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:        json['id']        ?? json['notificationId'] ?? 0,
      userId:    json['userId']    ?? 0,
      title:     json['title']     ?? '',
      message:   json['message']   ?? '',
      type:      json['type']      ?? 'info',
      isRead:    json['isRead']    ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id:        id,
        userId:    userId,
        title:     title,
        message:   message,
        type:      type,
        isRead:    isRead ?? this.isRead,
        createdAt: createdAt,
      );
}