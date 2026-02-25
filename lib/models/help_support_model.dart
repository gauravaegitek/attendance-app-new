// lib/models/help_support_model.dart

class FaqModel {
  final int faqId;
  final String question;
  final String answer;
  final String category;
  final int sortOrder;

  FaqModel({
    required this.faqId,
    required this.question,
    required this.answer,
    required this.category,
    required this.sortOrder,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        faqId:     json['faqId']      ?? json['id']         ?? 0,
        question:  json['question']   ?? '',
        answer:    json['answer']     ?? '',
        category:  json['category']   ?? '',
        sortOrder: json['sortOrder']  ?? json['sort_order'] ?? 0,
      );
}

class ContactMessageModel {
  final int id;
  final String subject;
  final String message;
  final String senderName;
  final String senderEmail;
  final bool isResolved;
  final DateTime createdAt;

  ContactMessageModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.senderName,
    required this.senderEmail,
    required this.isResolved,
    required this.createdAt,
  });

  factory ContactMessageModel.fromJson(Map<String, dynamic> json) {
    // contactId field
    final id = json['contactId'] ?? json['id'] ?? json['contact_id'] ?? 0;

    // ✅ FIX: API returns "status":"resolved" (string), not isResolved (bool)
    final isResolved = json['isResolved']   ??
                       json['is_resolved']  ??
                       json['resolved']     ??
                       (json['status']?.toString().toLowerCase() == 'resolved');

    // createdAt
    DateTime createdAt;
    try {
      final raw = json['createdAt']  ??
                  json['created_at'] ??
                  json['createdOn']  ?? '';
      createdAt = raw.toString().isNotEmpty
          ? DateTime.parse(raw.toString())
          : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    return ContactMessageModel(
      id:          id,
      subject:     json['subject']     ?? '',
      message:     json['message']     ?? '',
      senderName:  json['senderName']  ?? json['userName'] ?? json['name']  ?? '',
      senderEmail: json['senderEmail'] ?? json['email']    ?? '',
      isResolved:  isResolved,
      createdAt:   createdAt,
    );
  }
}