// // lib/models/document_model.dart

// class DocumentModel {
//   final int id;
//   final int employeeId;
//   final String employeeName;
//   final String documentType;
//   final String description;
//   final String fileName;
//   final String fileUrl;
//   final String status; // Pending, Verified, Rejected
//   final String remarks;
//   final DateTime uploadedAt;
//   final DateTime? verifiedAt;

//   DocumentModel({
//     required this.id,
//     required this.employeeId,
//     required this.employeeName,
//     required this.documentType,
//     required this.description,
//     required this.fileName,
//     required this.fileUrl,
//     required this.status,
//     required this.remarks,
//     required this.uploadedAt,
//     this.verifiedAt,
//   });

//   factory DocumentModel.fromJson(Map<String, dynamic> json) {
//     return DocumentModel(
//       id:           json['id']           ?? json['documentId'] ?? 0,
//       employeeId:   json['employeeId']   ?? json['employeeID'] ?? 0,
//       employeeName: json['employeeName'] ?? json['name']       ?? '',
//       documentType: json['documentType'] ?? '',
//       description:  json['description']  ?? '',
//       fileName:     json['fileName']     ?? json['file']       ?? '',
//       fileUrl:      json['fileUrl']      ?? json['url']        ?? '',
//       status:       json['status']       ?? 'Pending',
//       remarks:      json['remarks']      ?? '',
//       uploadedAt:   json['uploadedAt']  != null
//           ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
//           : DateTime.now(),
//       verifiedAt: json['verifiedAt'] != null
//           ? DateTime.tryParse(json['verifiedAt'].toString())
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id':           id,
//         'employeeId':   employeeId,
//         'employeeName': employeeName,
//         'documentType': documentType,
//         'description':  description,
//         'fileName':     fileName,
//         'fileUrl':      fileUrl,
//         'status':       status,
//         'remarks':      remarks,
//         'uploadedAt':   uploadedAt.toIso8601String(),
//         'verifiedAt':   verifiedAt?.toIso8601String(),
//       };
// }

// class DocumentSummaryModel {
//   final int totalDocuments;
//   final int pendingCount;
//   final int verifiedCount;
//   final int rejectedCount;
//   final List<DocumentModel> documents;

//   DocumentSummaryModel({
//     required this.totalDocuments,
//     required this.pendingCount,
//     required this.verifiedCount,
//     required this.rejectedCount,
//     required this.documents,
//   });

//   factory DocumentSummaryModel.fromJson(Map<String, dynamic> json) {
//     // ✅ API returns: { total, pending, approved, rejected, byType:[...] }
//     // Documents list is NOT in summary — it's fetched separately
//     return DocumentSummaryModel(
//       totalDocuments: json['totalDocuments'] ?? json['total']    ?? 0,
//       pendingCount:   json['pendingCount']   ?? json['pending']  ?? 0,
//       verifiedCount:  json['verifiedCount']  ?? json['approved'] ?? json['verified'] ?? 0,
//       rejectedCount:  json['rejectedCount']  ?? json['rejected'] ?? 0,
//       documents:      [],   // summary endpoint doesn't return docs list
//     );
//   }
// }












// lib/models/document_model.dart

class DocumentModel {
  final int id;
  final int employeeId;
  final String employeeName;
  final String documentType;
  final String description;
  final String fileName;
  final String fileUrl;
  final String status; // pending, verified/approved, rejected
  final String remarks;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;

  DocumentModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.documentType,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.status,
    required this.remarks,
    required this.uploadedAt,
    this.verifiedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    // ✅ API returns 'verifyStatus' not 'status' — handle both
    final rawStatus = json['verifyStatus']
        ?? json['status']
        ?? 'pending';

    return DocumentModel(
      id:           json['documentId'] ?? json['id']           ?? 0,
      employeeId:   json['employeeId'] ?? json['employeeID']   ?? 0,
      employeeName: json['employeeName'] ?? json['name']       ?? '',
      documentType: json['documentType'] ?? '',
      description:  json['description']  ?? '',
      fileName:     json['fileName']     ?? json['file']       ?? '',
      fileUrl:      json['filePath']     ?? json['fileUrl']    ?? json['url'] ?? '',
      status:       rawStatus.toString(),
      remarks:      json['remarks']      ?? '',
      uploadedAt:   json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':           id,
        'employeeId':   employeeId,
        'employeeName': employeeName,
        'documentType': documentType,
        'description':  description,
        'fileName':     fileName,
        'fileUrl':      fileUrl,
        'status':       status,
        'remarks':      remarks,
        'uploadedAt':   uploadedAt.toIso8601String(),
        'verifiedAt':   verifiedAt?.toIso8601String(),
      };
}

class DocumentSummaryModel {
  final int totalDocuments;
  final int pendingCount;
  final int verifiedCount;
  final int rejectedCount;
  final List<DocumentModel> documents;
  final List<DocumentByType> byType;

  DocumentSummaryModel({
    required this.totalDocuments,
    required this.pendingCount,
    required this.verifiedCount,
    required this.rejectedCount,
    required this.documents,
    this.byType = const [],
  });

  factory DocumentSummaryModel.fromJson(Map<String, dynamic> json) {
    final byTypeJson = json['byType'] as List<dynamic>? ?? [];
    return DocumentSummaryModel(
      totalDocuments: json['totalDocuments'] ?? json['total']              ?? 0,
      pendingCount:   json['pendingCount']   ?? json['pending']            ?? 0,
      verifiedCount:  json['verifiedCount']  ?? json['approved'] ?? json['verified'] ?? 0,
      rejectedCount:  json['rejectedCount']  ?? json['rejected']           ?? 0,
      documents: [],
      byType: byTypeJson.map((e) => DocumentByType.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class DocumentByType {
  final String documentType;
  final int count;

  DocumentByType({required this.documentType, required this.count});

  factory DocumentByType.fromJson(Map<String, dynamic> json) => DocumentByType(
        documentType: json['documentType'] ?? '',
        count: json['count'] ?? 0,
      );
}