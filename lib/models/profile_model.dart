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
  final String? emergencyContact; // ✅ NEW


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
    this.emergencyContact, // ✅ NEW

  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['userId'] ?? json['id'] ?? 0,                  // ✅ FIXED
      name: json['userName'] ?? json['name'] ?? '',            // ✅ FIXED
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      photoUrl: json['profilePhoto'] ?? json['photoUrl'],      // ✅ FIXED
      role: json['role'] ?? '',
      department: json['department'],
      designation: json['designation'],
      joiningDate: json['joiningDate'],
      emergencyContact: json['emergencyContact'], // ✅ NEW

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
    String? emergencyContact, // ✅ NEW

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
      emergencyContact: emergencyContact ?? this.emergencyContact, // ✅ NEW

    );
  }
}