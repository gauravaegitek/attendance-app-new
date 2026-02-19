class HolidayModel {
  final int id;
  final String name;
  final DateTime date;
  final String? description;

  HolidayModel({
    required this.id,
    required this.name,
    required this.date,
    this.description,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['holidayName'] ?? '',
      date: DateTime.tryParse(
              json['date'] ?? json['holidayDate'] ?? '') ??
          DateTime.now(),
      description: json['description'] ?? json['remarks'],
    );
  }
}