// // lib/models/daily_task_model.dart

// class DailyTaskModel {
//   final int    id;
//   final int    userId;
//   final String userName;
//   final String taskDate;
//   final String taskTitle;
//   final String taskDescription;
//   final String projectName;
//   final String status;       // e.g. Pending / In Progress / Completed
//   final double hoursSpent;
//   final String remarks;
//   final DateTime createdAt;

//   DailyTaskModel({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     required this.taskDate,
//     required this.taskTitle,
//     required this.taskDescription,
//     required this.projectName,
//     required this.status,
//     required this.hoursSpent,
//     required this.remarks,
//     required this.createdAt,
//   });

//   factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
//     return DailyTaskModel(
//       id:              json['id']              ?? 0,
//       userId:          json['userId']          ?? 0,
//       userName:        json['userName']        ?? json['name'] ?? '',
//       taskDate:        json['taskDate']        ?? '',
//       taskTitle:       json['taskTitle']       ?? '',
//       taskDescription: json['taskDescription'] ?? '',
//       projectName:     json['projectName']     ?? '',
//       status:          json['status']          ?? 'Pending',
//       hoursSpent:      (json['hoursSpent']     ?? 0).toDouble(),
//       remarks:         json['remarks']         ?? '',
//       createdAt:       DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toUpdateJson() => {
//     'taskTitle':       taskTitle,
//     'taskDescription': taskDescription,
//     'projectName':     projectName,
//     'status':          status,
//     'hoursSpent':      hoursSpent,
//     'remarks':         remarks,
//   };
// }






// lib/models/daily_task_model.dart

class DailyTaskModel {
  final int    id;
  final int    userId;
  final String userName;
  final String taskDate;
  final String taskTitle;
  final String taskDescription;
  final String projectName;
  final String status;
  final double hoursSpent;
  final String remarks;
  final DateTime createdAt;

  DailyTaskModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.taskDate,
    required this.taskTitle,
    required this.taskDescription,
    required this.projectName,
    required this.status,
    required this.hoursSpent,
    required this.remarks,
    required this.createdAt,
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id:              json['taskId']          ?? 0,   // ← FIXED: was json['id']
      userId:          json['userId']          ?? 0,
      userName:        json['userName']        ?? json['name'] ?? '',
      taskDate:        json['taskDate']        ?? '',
      taskTitle:       json['taskTitle']       ?? '',
      taskDescription: json['taskDescription'] ?? '',
      projectName:     json['projectName']     ?? '',
      status:          json['status']          ?? 'Pending',
      hoursSpent:      (json['hoursSpent']     ?? 0).toDouble(),
      remarks:         json['remarks']         ?? '',
      createdAt:       DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toUpdateJson() => {
    'taskTitle':       taskTitle,
    'taskDescription': taskDescription,
    'projectName':     projectName,
    'status':          status,
    'hoursSpent':      hoursSpent,
    'remarks':         remarks,
  };
}