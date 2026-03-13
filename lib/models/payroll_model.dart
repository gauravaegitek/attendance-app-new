// =================== PAYROLL CALCULATE RESULT ===================

class PayrollCalculateResult {
  final int    employeeId;
  final String employeeName;
  final int    month;
  final int    year;
  final double basicSalary;
  final int    presentDays;
  final int    absentDays;
  final int    lateDays;
  final double perDaySalary;
  final double absentDeduction;
  final double lateDeduction;
  final double manualDeduction;
  final String? manualDeductionReason;
  final double totalDeduction;
  final double netSalary;
  final String status;
  final String lateCutoff;

  PayrollCalculateResult({
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.perDaySalary,
    required this.absentDeduction,
    required this.lateDeduction,
    required this.manualDeduction,
    this.manualDeductionReason,
    required this.totalDeduction,
    required this.netSalary,
    required this.status,
    required this.lateCutoff,
  });

  bool get showLateWarning  => lateDays > 0 && lateDays < 3;
  bool get hasLateDeduction => lateDays >= 3;

  /// ✅ Total calendar days in this month (e.g. March=31, Feb=28/29)
  int get totalCalendarDays => DateTime(year, month + 1, 0).day;

  /// Gross = basic - absent deduction only (before late + manual)
  double get grossSalary => basicSalary - absentDeduction;

  factory PayrollCalculateResult.fromJson(Map<String, dynamic> json) {
    return PayrollCalculateResult(
      employeeId:            _i(json['employeeId']            ?? json['EmployeeId']            ?? 0),
      employeeName:          _s(json['employeeName']           ?? json['EmployeeName']           ?? ''),
      month:                 _i(json['month']                 ?? json['Month']                 ?? 0),
      year:                  _i(json['year']                  ?? json['Year']                  ?? 0),
      basicSalary:           _d(json['basicSalary']           ?? json['BasicSalary']           ?? 0),
      presentDays:           _i(json['presentDays']           ?? json['PresentDays']           ?? 0),
      absentDays:            _i(json['absentDays']            ?? json['AbsentDays']            ?? 0),
      lateDays:              _i(json['lateDays']              ?? json['LateDays']              ?? 0),
      perDaySalary:          _d(json['perDaySalary']          ?? json['PerDaySalary']          ?? 0),
      absentDeduction:       _d(json['absentDeduction']       ?? json['AbsentDeduction']       ?? 0),
      lateDeduction:         _d(json['lateDeduction']         ?? json['LateDeduction']
                                ?? json['lateDeductionAmount']?? json['LateDeductionAmount']   ?? 0),
      manualDeduction:       _d(json['manualDeduction']       ?? json['ManualDeduction']
                                ?? json['otherDeductions']    ?? json['OtherDeductions']       ?? 0),
      manualDeductionReason: _ns(json['manualDeductionReason']?? json['ManualDeductionReason']),
      totalDeduction:        _d(json['totalDeduction']        ?? json['TotalDeduction']
                                ?? json['totalDeductions']    ?? json['TotalDeductions']       ?? 0),
      netSalary:             _d(json['netSalary']             ?? json['NetSalary']             ?? 0),
      status:                _s(json['status']                ?? json['Status']                ?? 'Pending'),
      lateCutoff:            _s(json['lateCutoff']            ?? json['LateCutoff']            ?? '10:15'),
    );
  }

  static int    _i(dynamic v) => (v is num) ? v.toInt()    : int.tryParse('$v')    ?? 0;
  static double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
  static String _s(dynamic v) => v?.toString() ?? '';
  static String? _ns(dynamic v) => v?.toString();
}

// =================== PAYROLL SLIP MODEL ===================

class PayrollSlipModel {
  final int?   payrollId;
  final int    employeeId;
  final String employeeName;
  final String? employeeEmail;
  final String? department;
  final String? designation;
  final int    month;
  final int    year;
  final String? monthName;
  final double basicSalary;
  final int    totalWorkingDays;
  final int    presentDays;
  final int    absentDays;
  final int    lateDays;
  final double perDaySalary;
  final double absentDeduction;
  final double lateDeduction;
  final double manualDeduction;
  final String? manualDeductionReason;
  final double totalDeduction;
  final double netSalary;
  final String status;
  final String? paymentStatus;
  final String? approvedByName;
  final String? approvedAt;
  final String? paidAt;
  final String? paidByName;
  final String? generatedAt;
  final String? remarks;
  final List<PayrollDeductionModel> deductions;

  PayrollSlipModel({
    this.payrollId,
    required this.employeeId,
    required this.employeeName,
    this.employeeEmail,
    this.department,
    this.designation,
    required this.month,
    required this.year,
    this.monthName,
    required this.basicSalary,
    this.totalWorkingDays = 26,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.perDaySalary,
    required this.absentDeduction,
    required this.lateDeduction,
    required this.manualDeduction,
    this.manualDeductionReason,
    required this.totalDeduction,
    required this.netSalary,
    required this.status,
    this.paymentStatus,
    this.approvedByName,
    this.approvedAt,
    this.paidAt,
    this.paidByName,
    this.generatedAt,
    this.remarks,
    this.deductions = const [],
  });

  // ── Computed getters ──────────────────────────────────────────────────

  /// ✅ Total calendar days in this month (e.g. March=31, Feb=28/29)
  int get totalCalendarDays => DateTime(year, month + 1, 0).day;

  /// Gross = basicSalary - absentDeduction
  double get grossSalary => basicSalary - absentDeduction;

  /// Normalised status string for UI comparisons
  String get statusNorm => status.toLowerCase().trim().replaceAll('_', ' ');

  bool get isPaid         => statusNorm == 'paid';
  bool get isApproved     => statusNorm == 'approved' || isPaid;
  bool get isDraft        => statusNorm == 'draft';
  bool get isPending      => statusNorm == 'pending' || isDraft;
  // ✅ handles both 'not_processed' (API) and 'not processed'
  bool get isNotProcessed => statusNorm == 'not processed';

  /// UI-friendly label
  String get statusLabel {
    switch (statusNorm) {
      case 'paid':          return 'Paid';
      case 'approved':      return 'Approved';
      case 'draft':         return 'Pending';
      case 'pending':       return 'Pending';
      case 'not processed': return 'N/A';
      default:              return status;
    }
  }

  factory PayrollSlipModel.fromJson(Map<String, dynamic> json) {
    List<PayrollDeductionModel> deds = [];
    final rawDeds = json['deductions'] ?? json['Deductions'];
    if (rawDeds is List) {
      deds = rawDeds.map((e) => PayrollDeductionModel.fromJson(e)).toList();
    }

    return PayrollSlipModel(
      payrollId:             _ni(json['payrollId']            ?? json['PayrollId']),
      employeeId:            _i(json['employeeId']            ?? json['EmployeeId']            ?? 0),
      employeeName:          _s(json['employeeName']           ?? json['EmployeeName']           ?? ''),
      employeeEmail:         _ns(json['employeeEmail']         ?? json['EmployeeEmail']),
      department:            _ns(json['department']            ?? json['Department']),
      designation:           _ns(json['designation']           ?? json['Designation']),
      month:                 _i(json['month']                 ?? json['Month']                 ?? 0),
      year:                  _i(json['year']                  ?? json['Year']                  ?? 0),
      monthName:             _ns(json['monthName']             ?? json['MonthName']),
      basicSalary:           _d(json['basicSalary']           ?? json['BasicSalary']           ?? 0),
      totalWorkingDays:      _i(json['totalWorkingDays']      ?? json['TotalWorkingDays']      ?? 26),
      presentDays:           _i(json['presentDays']           ?? json['PresentDays']           ?? 0),
      absentDays:            _i(json['absentDays']            ?? json['AbsentDays']            ?? 0),
      lateDays:              _i(json['lateDays']              ?? json['LateDays']              ?? 0),
      perDaySalary:          _d(json['perDaySalary']          ?? json['PerDaySalary']          ?? 0),
      absentDeduction:       _d(json['absentDeduction']       ?? json['AbsentDeduction']       ?? 0),
      lateDeduction:         _d(json['lateDeduction']         ?? json['LateDeduction']
                                ?? json['lateDeductionAmount']?? json['LateDeductionAmount']   ?? 0),
      manualDeduction:       _d(json['manualDeduction']       ?? json['ManualDeduction']
                                ?? json['otherDeductions']    ?? json['OtherDeductions']       ?? 0),
      manualDeductionReason: _ns(json['manualDeductionReason']?? json['ManualDeductionReason']),
      totalDeduction:        _d(json['totalDeduction']        ?? json['TotalDeduction']
                                ?? json['totalDeductions']    ?? json['TotalDeductions']       ?? 0),
      netSalary:             _d(json['netSalary']             ?? json['NetSalary']             ?? 0),
      status:                _s(json['status']                ?? json['Status']                ?? 'Pending'),
      paymentStatus:         _ns(json['paymentStatus']        ?? json['PaymentStatus']),
      approvedByName:        _ns(json['approvedByName']       ?? json['ApprovedByName']
                                ?? json['approvedBy']         ?? json['ApprovedBy']),
      approvedAt:            _ns(json['approvedAt']           ?? json['ApprovedAt']
                                ?? json['approvedOn']         ?? json['ApprovedOn']),
      paidAt:                _ns(json['paidAt']               ?? json['PaidAt']
                                ?? json['paidOn']             ?? json['PaidOn']),
      paidByName:            _ns(json['paidByName']           ?? json['PaidByName']),
      generatedAt:           _ns(json['generatedAt']          ?? json['GeneratedAt']),
      remarks:               _ns(json['remarks']              ?? json['Remarks']),
      deductions:            deds,
    );
  }

  static int     _i(dynamic v)  => (v is num) ? v.toInt()    : int.tryParse('$v')    ?? 0;
  static double  _d(dynamic v)  => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
  static String  _s(dynamic v)  => v?.toString() ?? '';
  static int?    _ni(dynamic v) => v == null ? null : _i(v);
  static String? _ns(dynamic v) => v?.toString();
}

// =================== PAYROLL DEDUCTION MODEL ===================

class PayrollDeductionModel {
  final int?   deductionId;
  final int    employeeId;
  final String? employeeName;
  final int    month;
  final int    year;
  final double amount;
  final String reason;
  final String? createdOn;

  PayrollDeductionModel({
    this.deductionId,
    required this.employeeId,
    this.employeeName,
    required this.month,
    required this.year,
    required this.amount,
    required this.reason,
    this.createdOn,
  });

  factory PayrollDeductionModel.fromJson(Map<String, dynamic> json) =>
      PayrollDeductionModel(
        deductionId:  json['deductionId']  is int ? json['deductionId']  : int.tryParse('${json['deductionId']  ?? ''}'),
        employeeId:   json['employeeId']   is int ? json['employeeId']   : int.tryParse('${json['employeeId']   ?? ''}') ?? 0,
        employeeName: json['employeeName']?.toString(),
        month:        json['month']        is int ? json['month']        : int.tryParse('${json['month']        ?? ''}') ?? 0,
        year:         json['year']         is int ? json['year']         : int.tryParse('${json['year']         ?? ''}') ?? 0,
        amount:       (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse('${json['amount'] ?? ''}') ?? 0.0,
        reason:       json['reason']?.toString() ?? '',
        createdOn:    json['createdOn']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'month':      month,
        'year':       year,
        'amount':     amount,
        'reason':     reason,
      };
}