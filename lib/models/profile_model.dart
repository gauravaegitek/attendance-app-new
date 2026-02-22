// lib/models/profile_model.dart

class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final String role;
  final String? department;
  final String? designation;
  final String? joiningDate;
  final String? emergencyContact;
  final String? dateOfBirth;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photoUrl,
    required this.role,
    this.department,
    this.designation,
    this.joiningDate,
    this.emergencyContact,
    this.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // ✅ FIX: Backend userName field mein "17" (numeric ID) aata hai
    // Agar userName numeric hai toh email prefix use karo as display name
    final rawName = (json['userName'] ?? json['name'] ?? '').toString();
    final email = (json['email'] ?? '').toString();

    String displayName = rawName;
    if (rawName.isEmpty || int.tryParse(rawName) != null) {
      // userName numeric ID hai — email prefix use karo
      displayName = email.contains('@')
          ? email.split('@')[0]
          : (rawName.isNotEmpty ? rawName : 'User');
    }

    return ProfileModel(
      id: json['userId'] ?? json['id'] ?? 0,
      name: displayName,
      email: email,
      phone: json['phone'],
      address: json['address'],
      photoUrl: json['profilePhoto'] ?? json['photoUrl'],
      role: json['role'] ?? '',
      department: json['department'],
      designation: json['designation'],
      joiningDate: json['joiningDate'],
      emergencyContact: json['emergencyContact'],
      dateOfBirth: json['dateOfBirth'],
    );
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? photoUrl,
    String? department,
    String? designation,
    String? emergencyContact,
    String? dateOfBirth,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      joiningDate: joiningDate,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}