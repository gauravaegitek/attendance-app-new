// lib/models/location_model.dart

class LocationTrackingModel {
  final int     trackingId;
  final int     userId;
  final String  userName;
  final String  role;

  // Check-in
  final double  checkInLatitude;
  final double  checkInLongitude;
  final String  checkInAddress;
  final String  workType;
  final String  checkInTime;

  // Check-out
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutAddress;
  final String? checkOutTime;

  // Client visit
  final bool    isClientVisit;
  final String? clientName;
  final String? clientAddress;
  final double? clientLatitude;
  final double? clientLongitude;
  final String? visitPurpose;
  final String? meetingNotes;
  final String? outcome;

  // Meta
  final String  date;
  final String? totalHours;

  const LocationTrackingModel({
    required this.trackingId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.checkInLatitude,
    required this.checkInLongitude,
    required this.checkInAddress,
    required this.workType,
    required this.checkInTime,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAddress,
    this.checkOutTime,
    required this.isClientVisit,
    this.clientName,
    this.clientAddress,
    this.clientLatitude,
    this.clientLongitude,
    this.visitPurpose,
    this.meetingNotes,
    this.outcome,
    required this.date,
    this.totalHours,
  });

  bool get isCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  factory LocationTrackingModel.fromJson(Map<String, dynamic> j) {
    return LocationTrackingModel(
      trackingId:        j['trackingId']        ?? 0,
      userId:            j['userId']            ?? 0,
      userName:          j['userName']          ?? '',
      role:              j['role']              ?? '',
      checkInLatitude:   (j['checkInLatitude']  ?? 0).toDouble(),
      checkInLongitude:  (j['checkInLongitude'] ?? 0).toDouble(),
      checkInAddress:    j['checkInAddress']    ?? j['address'] ?? '',
      workType:          j['workType']          ?? '',
      checkInTime:       j['checkInTime']       ?? j['createdAt'] ?? '',
      checkOutLatitude:  j['checkOutLatitude'] != null
          ? (j['checkOutLatitude'] as num).toDouble()
          : null,
      checkOutLongitude: j['checkOutLongitude'] != null
          ? (j['checkOutLongitude'] as num).toDouble()
          : null,
      checkOutAddress:   j['checkOutAddress'],
      checkOutTime:      j['checkOutTime'],
      isClientVisit:     j['isClientVisit']     ?? false,
      clientName:        j['clientName'],
      clientAddress:     j['clientAddress'],
      clientLatitude:    j['clientLatitude'] != null
          ? (j['clientLatitude'] as num).toDouble()
          : null,
      clientLongitude:   j['clientLongitude'] != null
          ? (j['clientLongitude'] as num).toDouble()
          : null,
      visitPurpose:      j['visitPurpose'],
      meetingNotes:      j['meetingNotes'],
      outcome:           j['outcome'],
      date:              j['date'] ?? j['trackingDate'] ?? '',
      totalHours:        j['totalHours']?.toString(),
    );
  }
}