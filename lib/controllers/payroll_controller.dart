// // lib/controllers/payroll_controller.dart

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import '../models/payroll_model.dart';
// import '../services/storage_service.dart';

// class PayrollController extends GetxController {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _authHeaders => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // ─────────────────────────────────────────────
//   //  OBSERVABLE STATE
//   // ─────────────────────────────────────────────

//   final RxList<UserModel> employees = <UserModel>[].obs;
//   final Rx<UserModel?> selectedEmp = Rx<UserModel?>(null);

//   final RxInt selectedMonth = DateTime.now().month.obs;
//   final RxInt selectedYear = DateTime.now().year.obs;
//   final RxDouble basicSalary = 0.0.obs;
//   final RxString lateCutoff = '10:15'.obs;

//   final Rx<PayrollCalculateResult?> calculateResult =
//       Rx<PayrollCalculateResult?>(null);
//   final Rx<PayrollSlipModel?> currentSlip = Rx<PayrollSlipModel?>(null);
//   final RxList<PayrollSlipModel> allPayrolls = <PayrollSlipModel>[].obs;
//   final Rx<PayrollSlipModel?> myPayroll = Rx<PayrollSlipModel?>(null);

//   final RxBool isLoadingEmployees = false.obs;
//   final RxBool isCalculating = false.obs;
//   final RxBool isLoadingAll = false.obs;
//   final RxBool isLoadingMyPayroll = false.obs;
//   final RxBool isActionLoading = false.obs;

//   // ─────────────────────────────────────────────
//   //  LIFECYCLE
//   // ─────────────────────────────────────────────

//   @override
//   void onInit() {
//     super.onInit();
//     loadEmployees();
//   }

//   // ─────────────────────────────────────────────
//   //  HELPERS
//   // ─────────────────────────────────────────────

//   static const _monthNames = [
//     '',
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December',
//   ];

//   String get periodLabel =>
//       '${_monthNames[selectedMonth.value]} ${selectedYear.value}';

//   static String monthName(int m) => _monthNames[m.clamp(1, 12)];

//   // ─────────────────────────────────────────────
//   //  LOAD EMPLOYEES
//   // ─────────────────────────────────────────────

//   Future<void> loadEmployees() async {
//     try {
//       isLoadingEmployees.value = true;
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getAllUsersEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('loadEmployees status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           employees.value = (data['data'] as List)
//               .map((u) => UserModel.fromJson(u))
//               .toList();
//         }
//       }
//     } catch (e) {
//       debugPrint('loadEmployees error: $e');
//     } finally {
//       isLoadingEmployees.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  CALCULATE  GET /api/Payroll/calculate
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> calculatePayroll() async {
//     if (selectedEmp.value == null) {
//       return ApiResponse(success: false, message: 'Please select an employee');
//     }
//     if (basicSalary.value <= 0) {
//       return ApiResponse(
//           success: false, message: 'Please enter Basic Salary');
//     }
//     try {
//       isCalculating.value = true;
//       calculateResult.value = null;

//       final uri =
//           Uri.parse('$_base${AppConstants.payrollCalculateEndpoint}')
//               .replace(queryParameters: {
//         'EmployeeId': selectedEmp.value!.userId.toString(),
//         'Month': selectedMonth.value.toString(),
//         'Year': selectedYear.value.toString(),
//         'BasicSalary': basicSalary.value.toString(),
//         'LateCutoff': lateCutoff.value,
//       });

//       debugPrint('calculatePayroll URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('calculatePayroll status: ${response.statusCode}');
//       debugPrint('calculatePayroll body  : ${response.body}');

//       final body = jsonDecode(response.body);
//       if (response.statusCode == 200 && body['success'] == true) {
//         final raw = body['data'] is Map ? body['data'] : body;
//         calculateResult.value = PayrollCalculateResult.fromJson(raw);
//         return ApiResponse(
//             success: true, message: 'Payroll calculated successfully');
//       }
//       return ApiResponse(
//         success: false,
//         message:
//             (body['message'] ?? body['msg'] ?? 'Calculation failed').toString(),
//       );
//     } catch (e) {
//       debugPrint('calculatePayroll error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isCalculating.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  ADD DEDUCTION  POST /api/Payroll/deduction
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> addDeduction({
//     required int employeeId,
//     required double amount,
//     required String reason,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       isActionLoading.value = true;
//       final bodyMap = {
//         'employeeId': employeeId,
//         'month': month ?? selectedMonth.value,
//         'year': year ?? selectedYear.value,
//         'amount': amount,
//         'reason': reason,
//       };
//       debugPrint('addDeduction body: $bodyMap');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.payrollDeductionEndpoint}'),
//             headers: _authHeaders,
//             body: jsonEncode(bodyMap),
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('addDeduction status: ${response.statusCode}');
//       debugPrint('addDeduction body  : ${response.body}');

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('addDeduction error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isActionLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  APPROVE  POST /api/Payroll/approve
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> approvePayroll({
//     required int employeeId,
//     required String remarks,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       isActionLoading.value = true;
//       final bodyMap = {
//         'employeeId': employeeId,
//         'month': month ?? selectedMonth.value,
//         'year': year ?? selectedYear.value,
//         'remarks': remarks,
//       };
//       debugPrint('approvePayroll body: $bodyMap');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.payrollApproveEndpoint}'),
//             headers: _authHeaders,
//             body: jsonEncode(bodyMap),
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('approvePayroll status: ${response.statusCode}');
//       debugPrint('approvePayroll body  : ${response.body}');

//       final data = jsonDecode(response.body);
//       final success = response.statusCode == 200;

//       // ✅ Refresh via /Payroll/list
//       if (success) await getAllPayrolls();

//       return ApiResponse(
//         success: success,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//       );
//     } catch (e) {
//       debugPrint('approvePayroll error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isActionLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  MARK PAID  POST /api/Payroll/markpaid
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> markPaid({
//     required int employeeId,
//     required String remarks,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       isActionLoading.value = true;
//       final bodyMap = {
//         'employeeId': employeeId,
//         'month': month ?? selectedMonth.value,
//         'year': year ?? selectedYear.value,
//         'remarks': remarks,
//       };
//       debugPrint('markPaid body: $bodyMap');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.payrollMarkPaidEndpoint}'),
//             headers: _authHeaders,
//             body: jsonEncode(bodyMap),
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markPaid status: ${response.statusCode}');
//       debugPrint('markPaid body  : ${response.body}');

//       final data = jsonDecode(response.body);
//       final success = response.statusCode == 200;

//       // ✅ Refresh via /Payroll/list
//       if (success) await getAllPayrolls();

//       return ApiResponse(
//         success: success,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//       );
//     } catch (e) {
//       debugPrint('markPaid error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isActionLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  GET SLIP  GET /api/Payroll/slip
//   //  (single employee — used for "My Payroll" view)
//   // ─────────────────────────────────────────────

//   Future<PayrollSlipModel?> getSlip({
//     required int employeeId,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       final uri =
//           Uri.parse('$_base${AppConstants.payrollSlipEndpoint}')
//               .replace(queryParameters: {
//         'EmployeeId': employeeId.toString(),
//         'Month': (month ?? selectedMonth.value).toString(),
//         'Year': (year ?? selectedYear.value).toString(),
//       });

//       debugPrint('getSlip URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getSlip [emp:$employeeId] status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);
//         final raw = body['data'] ?? body;
//         if (raw is Map<String, dynamic>) {
//           return PayrollSlipModel.fromJson(raw);
//         }
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getSlip [emp:$employeeId] error: $e');
//       return null;
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   //  ✅ GET ALL PAYROLLS — Single API call to GET /Payroll/list
//   //
//   //  Flow:
//   //   1. Call GET /api/Payroll/list?Month=X&Year=Y  (1 request)
//   //   2. Backend returns ALL employees:
//   //      • Processed   → full payroll data
//   //      • Unprocessed → status: "not_processed" placeholder
//   //   3. Parse response into List<PayrollSlipModel>
//   //
//   //  ✅ Replaces old N-requests loop completely.
//   // ═══════════════════════════════════════════════════════════

//   Future<void> getAllPayrolls() async {
//     try {
//       isLoadingAll.value = true;
//       allPayrolls.value = [];

//       final uri =
//           Uri.parse('$_base${AppConstants.payrollListEndpoint}')
//               .replace(queryParameters: {
//         'Month': selectedMonth.value.toString(),
//         'Year': selectedYear.value.toString(),
//       });

//       debugPrint('getAllPayrolls URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllPayrolls status: ${response.statusCode}');
//       debugPrint('getAllPayrolls body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);
//         if (body['success'] == true && body['data'] != null) {
//           allPayrolls.value = (body['data'] as List)
//               .map((e) => PayrollSlipModel.fromJson(e as Map<String, dynamic>))
//               .toList();
//           debugPrint(
//               'getAllPayrolls complete: ${allPayrolls.length} records');
//         }
//       } else {
//         debugPrint(
//             'getAllPayrolls failed: ${response.statusCode} ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('getAllPayrolls error: $e');
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  LOAD MY PAYROLL (employee self-view)
//   // ─────────────────────────────────────────────

//   Future<void> loadMyPayroll(int userId) async {
//     try {
//       isLoadingMyPayroll.value = true;
//       myPayroll.value = null;
//       myPayroll.value = await getSlip(
//         employeeId: userId,
//         month: selectedMonth.value,
//         year: selectedYear.value,
//       );
//     } finally {
//       isLoadingMyPayroll.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  MONTH / YEAR NAVIGATION
//   // ─────────────────────────────────────────────

//   void prevMonth() {
//     if (selectedMonth.value == 1) {
//       selectedMonth.value = 12;
//       selectedYear.value--;
//     } else {
//       selectedMonth.value--;
//     }
//   }

//   void nextMonth() {
//     final now = DateTime.now();
//     if (selectedYear.value == now.year &&
//         selectedMonth.value == now.month) return;
//     if (selectedMonth.value == 12) {
//       selectedMonth.value = 1;
//       selectedYear.value++;
//     } else {
//       selectedMonth.value++;
//     }
//   }

//   bool get canGoNext {
//     final now = DateTime.now();
//     return !(selectedYear.value == now.year &&
//         selectedMonth.value == now.month);
//   }

//   // ─────────────────────────────────────────────
//   //  STATUS COLOR
//   // ─────────────────────────────────────────────

//   int statusColorValue(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'paid':
//         return 0xFF22C55E; // green
//       case 'approved':
//         return 0xFF3B82F6; // blue
//       case 'pending':
//       case 'draft':
//         return 0xFFF97316; // orange
//       case 'not_processed':
//       case 'not processed':
//         return 0xFF94A3B8; // slate grey
//       default:
//         return 0xFF94A3B8;
//     }
//   }
// }
















// // lib/controllers/payroll_controller.dart

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import '../models/payroll_model.dart';
// import '../services/storage_service.dart';

// class PayrollController extends GetxController {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _authHeaders => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // ─────────────────────────────────────────────
//   //  OBSERVABLE STATE
//   // ─────────────────────────────────────────────

//   final RxList<UserModel> employees = <UserModel>[].obs;
//   final Rx<UserModel?> selectedEmp = Rx<UserModel?>(null);

//   final RxInt selectedMonth = DateTime.now().month.obs;
//   final RxInt selectedYear = DateTime.now().year.obs;
//   final RxDouble basicSalary = 0.0.obs;
//   final RxString lateCutoff = '10:15'.obs;

//   final Rx<PayrollCalculateResult?> calculateResult =
//       Rx<PayrollCalculateResult?>(null);
//   final Rx<PayrollSlipModel?> currentSlip = Rx<PayrollSlipModel?>(null);
//   final RxList<PayrollSlipModel> allPayrolls = <PayrollSlipModel>[].obs;
//   final Rx<PayrollSlipModel?> myPayroll = Rx<PayrollSlipModel?>(null);

//   final RxBool isLoadingEmployees = false.obs;
//   final RxBool isCalculating = false.obs;
//   final RxBool isLoadingAll = false.obs;
//   final RxBool isLoadingMyPayroll = false.obs;
//   final RxBool isActionLoading = false.obs;

//   // ─────────────────────────────────────────────
//   //  LIFECYCLE
//   // ─────────────────────────────────────────────

//   @override
//   void onInit() {
//     super.onInit();
//     loadEmployees();
//   }

//   // ─────────────────────────────────────────────
//   //  HELPERS
//   // ─────────────────────────────────────────────

//   static const _monthNames = [
//     '',
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December',
//   ];

//   String get periodLabel =>
//       '${_monthNames[selectedMonth.value]} ${selectedYear.value}';

//   static String monthName(int m) => _monthNames[m.clamp(1, 12)];

//   // ─────────────────────────────────────────────
//   //  LOAD EMPLOYEES
//   // ─────────────────────────────────────────────

//   Future<void> loadEmployees() async {
//     try {
//       isLoadingEmployees.value = true;
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getAllUsersEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('loadEmployees status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           employees.value = (data['data'] as List)
//               .map((u) => UserModel.fromJson(u))
//               .toList();
//         }
//       }
//     } catch (e) {
//       debugPrint('loadEmployees error: $e');
//     } finally {
//       isLoadingEmployees.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  CALCULATE  GET /api/Payroll/calculate
//   // ─────────────────────────────────────────────
//   //
//   //  ✅ FIX 1: Backend ab one-time calculate karta hai.
//   //  Agar 400 aaya aur response mein 'data' field hai (existing record),
//   //  toh calculateResult set kar do taaki admin existing payroll dekh sake.
//   //  success = false rakho taaki UI message dikhaye, but data lost na ho.
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> calculatePayroll() async {
//     if (selectedEmp.value == null) {
//       return ApiResponse(success: false, message: 'Please select an employee');
//     }
//     if (basicSalary.value <= 0) {
//       return ApiResponse(
//           success: false, message: 'Please enter Basic Salary');
//     }
//     try {
//       isCalculating.value = true;

//       // ✅ FIX 3: Fresh calculate se pehle purana result clear karo
//       calculateResult.value = null;

//       final uri =
//           Uri.parse('$_base${AppConstants.payrollCalculateEndpoint}')
//               .replace(queryParameters: {
//         'EmployeeId': selectedEmp.value!.userId.toString(),
//         'Month': selectedMonth.value.toString(),
//         'Year': selectedYear.value.toString(),
//         'BasicSalary': basicSalary.value.toString(),
//         'LateCutoff': lateCutoff.value,
//       });

//       debugPrint('calculatePayroll URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('calculatePayroll status: ${response.statusCode}');
//       debugPrint('calculatePayroll body  : ${response.body}');

//       final body = jsonDecode(response.body);

//       // ── Success: 200 ──────────────────────────────────────────────
//       if (response.statusCode == 200 && body['success'] == true) {
//         final raw = body['data'] is Map ? body['data'] : body;
//         calculateResult.value = PayrollCalculateResult.fromJson(raw);
//         return ApiResponse(
//             success: true, message: 'Payroll calculated successfully');
//       }

//       // ── ✅ FIX 1: Already calculated (400) — existing data load karo ─
//       // Backend returns { success: false, message: "...", data: {...} }
//       // 'data' mein existing record hota hai — show karo as read-only
//       if (response.statusCode == 400 &&
//           body['data'] != null &&
//           body['data'] is Map<String, dynamic>) {
//         calculateResult.value =
//             PayrollCalculateResult.fromJson(body['data'] as Map<String, dynamic>);
//         debugPrint('calculatePayroll: already exists, existing data loaded');
//       }

//       return ApiResponse(
//         success: false,
//         message: (body['message'] ?? body['msg'] ?? 'Calculation failed')
//             .toString(),
//       );
//     } catch (e) {
//       debugPrint('calculatePayroll error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isCalculating.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  ADD DEDUCTION  POST /api/Payroll/deduction
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> addDeduction({
//     required int employeeId,
//     required double amount,
//     required String reason,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       isActionLoading.value = true;
//       final bodyMap = {
//         'employeeId': employeeId,
//         'month': month ?? selectedMonth.value,
//         'year': year ?? selectedYear.value,
//         'amount': amount,
//         'reason': reason,
//       };
//       debugPrint('addDeduction body: $bodyMap');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.payrollDeductionEndpoint}'),
//             headers: _authHeaders,
//             body: jsonEncode(bodyMap),
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('addDeduction status: ${response.statusCode}');
//       debugPrint('addDeduction body  : ${response.body}');

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('addDeduction error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isActionLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  APPROVE  POST /api/Payroll/approve
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> approvePayroll({
//     required int employeeId,
//     required String remarks,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       isActionLoading.value = true;
//       final bodyMap = {
//         'employeeId': employeeId,
//         'month': month ?? selectedMonth.value,
//         'year': year ?? selectedYear.value,
//         'remarks': remarks,
//       };
//       debugPrint('approvePayroll body: $bodyMap');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.payrollApproveEndpoint}'),
//             headers: _authHeaders,
//             body: jsonEncode(bodyMap),
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('approvePayroll status: ${response.statusCode}');
//       debugPrint('approvePayroll body  : ${response.body}');

//       final data = jsonDecode(response.body);
//       final success = response.statusCode == 200;

//       if (success) await getAllPayrolls();

//       return ApiResponse(
//         success: success,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//       );
//     } catch (e) {
//       debugPrint('approvePayroll error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isActionLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  MARK PAID  POST /api/Payroll/markpaid
//   // ─────────────────────────────────────────────

//   Future<ApiResponse> markPaid({
//     required int employeeId,
//     required String remarks,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       isActionLoading.value = true;
//       final bodyMap = {
//         'employeeId': employeeId,
//         'month': month ?? selectedMonth.value,
//         'year': year ?? selectedYear.value,
//         'remarks': remarks,
//       };
//       debugPrint('markPaid body: $bodyMap');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.payrollMarkPaidEndpoint}'),
//             headers: _authHeaders,
//             body: jsonEncode(bodyMap),
//           )
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markPaid status: ${response.statusCode}');
//       debugPrint('markPaid body  : ${response.body}');

//       final data = jsonDecode(response.body);
//       final success = response.statusCode == 200;

//       if (success) await getAllPayrolls();

//       return ApiResponse(
//         success: success,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//       );
//     } catch (e) {
//       debugPrint('markPaid error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     } finally {
//       isActionLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  GET SLIP  GET /api/Payroll/slip
//   // ─────────────────────────────────────────────

//   Future<PayrollSlipModel?> getSlip({
//     required int employeeId,
//     int? month,
//     int? year,
//   }) async {
//     try {
//       final uri =
//           Uri.parse('$_base${AppConstants.payrollSlipEndpoint}')
//               .replace(queryParameters: {
//         'EmployeeId': employeeId.toString(),
//         'Month': (month ?? selectedMonth.value).toString(),
//         'Year': (year ?? selectedYear.value).toString(),
//       });

//       debugPrint('getSlip URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getSlip [emp:$employeeId] status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);
//         final raw = body['data'] ?? body;
//         if (raw is Map<String, dynamic>) {
//           return PayrollSlipModel.fromJson(raw);
//         }
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getSlip [emp:$employeeId] error: $e');
//       return null;
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   //  GET ALL PAYROLLS  GET /api/Payroll/list
//   // ═══════════════════════════════════════════════════════════

//   Future<void> getAllPayrolls() async {
//     try {
//       isLoadingAll.value = true;
//       allPayrolls.value = [];

//       final uri =
//           Uri.parse('$_base${AppConstants.payrollListEndpoint}')
//               .replace(queryParameters: {
//         'Month': selectedMonth.value.toString(),
//         'Year': selectedYear.value.toString(),
//       });

//       debugPrint('getAllPayrolls URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(
//               const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllPayrolls status: ${response.statusCode}');
//       debugPrint('getAllPayrolls body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);
//         if (body['success'] == true && body['data'] != null) {
//           allPayrolls.value = (body['data'] as List)
//               .map((e) =>
//                   PayrollSlipModel.fromJson(e as Map<String, dynamic>))
//               .toList();
//           debugPrint(
//               'getAllPayrolls complete: ${allPayrolls.length} records');
//         }
//       } else {
//         debugPrint(
//             'getAllPayrolls failed: ${response.statusCode} ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('getAllPayrolls error: $e');
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  LOAD MY PAYROLL (employee self-view)
//   // ─────────────────────────────────────────────

//   Future<void> loadMyPayroll(int userId) async {
//     try {
//       isLoadingMyPayroll.value = true;
//       myPayroll.value = null;
//       myPayroll.value = await getSlip(
//         employeeId: userId,
//         month: selectedMonth.value,
//         year: selectedYear.value,
//       );
//     } finally {
//       isLoadingMyPayroll.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  MONTH / YEAR NAVIGATION
//   // ─────────────────────────────────────────────

//   void prevMonth() {
//     if (selectedMonth.value == 1) {
//       selectedMonth.value = 12;
//       selectedYear.value--;
//     } else {
//       selectedMonth.value--;
//     }
//   }

//   void nextMonth() {
//     final now = DateTime.now();
//     if (selectedYear.value == now.year &&
//         selectedMonth.value == now.month) return;
//     if (selectedMonth.value == 12) {
//       selectedMonth.value = 1;
//       selectedYear.value++;
//     } else {
//       selectedMonth.value++;
//     }
//   }

//   bool get canGoNext {
//     final now = DateTime.now();
//     return !(selectedYear.value == now.year &&
//         selectedMonth.value == now.month);
//   }

//   // ─────────────────────────────────────────────
//   //  STATUS COLOR
//   //
//   //  ✅ FIX 2: "not generated" case add kiya —
//   //  backend ab paymentStatus = "Not Generated"
//   //  bhejta hai (pehle "Pending" tha)
//   // ─────────────────────────────────────────────

//   int statusColorValue(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'paid':
//       case 'pay completed':
//         return 0xFF22C55E; // green
//       case 'approved':
//         return 0xFF3B82F6; // blue
//       case 'pending':
//       case 'draft':
//         return 0xFFF97316; // orange
//       case 'not_processed':
//       case 'not processed':
//       case 'not generated':   // ✅ Added — new paymentStatus value
//         return 0xFF94A3B8;    // slate grey
//       default:
//         return 0xFF94A3B8;
//     }
//   }
// }















// lib/controllers/payroll_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/models.dart';
import '../models/payroll_model.dart';
import '../services/storage_service.dart';

class PayrollController extends GetxController {
  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${StorageService.getToken()}',
      };

  // ─────────────────────────────────────────────
  //  OBSERVABLE STATE
  // ─────────────────────────────────────────────

  final RxList<UserModel> employees = <UserModel>[].obs;
  final Rx<UserModel?> selectedEmp = Rx<UserModel?>(null);

  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxDouble basicSalary = 0.0.obs;
  final RxString lateCutoff = '10:15'.obs;

  final Rx<PayrollCalculateResult?> calculateResult =
      Rx<PayrollCalculateResult?>(null);
  final Rx<PayrollSlipModel?> currentSlip = Rx<PayrollSlipModel?>(null);
  final RxList<PayrollSlipModel> allPayrolls = <PayrollSlipModel>[].obs;
  final Rx<PayrollSlipModel?> myPayroll = Rx<PayrollSlipModel?>(null);

  // ✅ NEW: Detail sheet ke liye reactive slip
  // Jab bhi addDeduction/approve/markpaid success hota hai,
  // ye auto-update hota hai → sheet mein bina swipe-to-refresh
  // ke instantly "Other Deductions" aur baaki data update ho jaata hai
  final Rx<PayrollSlipModel?> detailSlip = Rx<PayrollSlipModel?>(null);

  final RxBool isLoadingEmployees = false.obs;
  final RxBool isCalculating = false.obs;
  final RxBool isLoadingAll = false.obs;
  final RxBool isLoadingMyPayroll = false.obs;
  final RxBool isActionLoading = false.obs;

  // ─────────────────────────────────────────────
  //  LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  static const _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get periodLabel =>
      '${_monthNames[selectedMonth.value]} ${selectedYear.value}';

  static String monthName(int m) => _monthNames[m.clamp(1, 12)];

  // ─────────────────────────────────────────────
  //  ✅ detailSlip helpers
  // ─────────────────────────────────────────────

  /// Sheet open hone pe call karo
  void setDetailSlip(PayrollSlipModel slip) {
    detailSlip.value = slip;
  }

  /// getAllPayrolls ke baad detailSlip ko updated list se sync karo
  void _refreshDetailSlipFromList() {
    final current = detailSlip.value;
    if (current == null) return;
    final updated = allPayrolls.firstWhereOrNull(
      (s) =>
          s.employeeId == current.employeeId &&
          s.month == current.month &&
          s.year == current.year,
    );
    if (updated != null) {
      detailSlip.value = updated;
      debugPrint(
          'detailSlip refreshed → emp:${updated.employeeId} '
          '${updated.month}/${updated.year} | '
          'manualDeduction: ${updated.manualDeduction}');
    }
  }

  // ─────────────────────────────────────────────
  //  LOAD EMPLOYEES
  // ─────────────────────────────────────────────

  Future<void> loadEmployees() async {
    try {
      isLoadingEmployees.value = true;
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.getAllUsersEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('loadEmployees status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          employees.value = (data['data'] as List)
              .map((u) => UserModel.fromJson(u))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('loadEmployees error: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  CALCULATE  GET /api/Payroll/calculate
  // ─────────────────────────────────────────────

  Future<ApiResponse> calculatePayroll() async {
    if (selectedEmp.value == null) {
      return ApiResponse(success: false, message: 'Please select an employee');
    }
    if (basicSalary.value <= 0) {
      return ApiResponse(
          success: false, message: 'Please enter Basic Salary');
    }
    try {
      isCalculating.value = true;
      calculateResult.value = null;

      final uri =
          Uri.parse('$_base${AppConstants.payrollCalculateEndpoint}')
              .replace(queryParameters: {
        'EmployeeId': selectedEmp.value!.userId.toString(),
        'Month': selectedMonth.value.toString(),
        'Year': selectedYear.value.toString(),
        'BasicSalary': basicSalary.value.toString(),
        'LateCutoff': lateCutoff.value,
      });

      debugPrint('calculatePayroll URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('calculatePayroll status: ${response.statusCode}');
      debugPrint('calculatePayroll body  : ${response.body}');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final raw = body['data'] is Map ? body['data'] : body;
        calculateResult.value = PayrollCalculateResult.fromJson(raw);
        return ApiResponse(
            success: true, message: 'Payroll calculated successfully');
      }

      // Already calculated (400) — existing data load karo
      if (response.statusCode == 400 &&
          body['data'] != null &&
          body['data'] is Map<String, dynamic>) {
        calculateResult.value = PayrollCalculateResult.fromJson(
            body['data'] as Map<String, dynamic>);
        debugPrint('calculatePayroll: already exists, existing data loaded');
      }

      return ApiResponse(
        success: false,
        message:
            (body['message'] ?? body['msg'] ?? 'Calculation failed').toString(),
      );
    } catch (e) {
      debugPrint('calculatePayroll error: $e');
      return ApiResponse(success: false, message: e.toString());
    } finally {
      isCalculating.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  ADD DEDUCTION  POST /api/Payroll/deduction
  //
  //  ✅ FIX: Success pe getAllPayrolls() → _refreshDetailSlipFromList()
  //  Sheet mein "Other Deductions" bina manual refresh ke dikhega
  // ─────────────────────────────────────────────

  Future<ApiResponse> addDeduction({
    required int employeeId,
    required double amount,
    required String reason,
    int? month,
    int? year,
  }) async {
    try {
      isActionLoading.value = true;
      final bodyMap = {
        'employeeId': employeeId,
        'month': month ?? selectedMonth.value,
        'year': year ?? selectedYear.value,
        'amount': amount,
        'reason': reason,
      };
      debugPrint('addDeduction body: $bodyMap');

      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.payrollDeductionEndpoint}'),
            headers: _authHeaders,
            body: jsonEncode(bodyMap),
          )
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('addDeduction status: ${response.statusCode}');
      debugPrint('addDeduction body  : ${response.body}');

      final data = jsonDecode(response.body);
      final success =
          response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        // ✅ List refresh → detailSlip auto-update → sheet instantly reacts
        await getAllPayrolls();
        _refreshDetailSlipFromList();
      }

      return ApiResponse(
        success: success,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data: data['data'],
      );
    } catch (e) {
      debugPrint('addDeduction error: $e');
      return ApiResponse(success: false, message: e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  APPROVE  POST /api/Payroll/approve
  // ─────────────────────────────────────────────

  Future<ApiResponse> approvePayroll({
    required int employeeId,
    required String remarks,
    int? month,
    int? year,
  }) async {
    try {
      isActionLoading.value = true;
      final bodyMap = {
        'employeeId': employeeId,
        'month': month ?? selectedMonth.value,
        'year': year ?? selectedYear.value,
        'remarks': remarks,
      };
      debugPrint('approvePayroll body: $bodyMap');

      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.payrollApproveEndpoint}'),
            headers: _authHeaders,
            body: jsonEncode(bodyMap),
          )
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('approvePayroll status: ${response.statusCode}');
      debugPrint('approvePayroll body  : ${response.body}');

      final data = jsonDecode(response.body);
      final success = response.statusCode == 200;

      if (success) {
        await getAllPayrolls();
        _refreshDetailSlipFromList();
      }

      return ApiResponse(
        success: success,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
      );
    } catch (e) {
      debugPrint('approvePayroll error: $e');
      return ApiResponse(success: false, message: e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  MARK PAID  POST /api/Payroll/markpaid
  // ─────────────────────────────────────────────

  Future<ApiResponse> markPaid({
    required int employeeId,
    required String remarks,
    int? month,
    int? year,
  }) async {
    try {
      isActionLoading.value = true;
      final bodyMap = {
        'employeeId': employeeId,
        'month': month ?? selectedMonth.value,
        'year': year ?? selectedYear.value,
        'remarks': remarks,
      };
      debugPrint('markPaid body: $bodyMap');

      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.payrollMarkPaidEndpoint}'),
            headers: _authHeaders,
            body: jsonEncode(bodyMap),
          )
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('markPaid status: ${response.statusCode}');
      debugPrint('markPaid body  : ${response.body}');

      final data = jsonDecode(response.body);
      final success = response.statusCode == 200;

      if (success) {
        await getAllPayrolls();
        _refreshDetailSlipFromList();
      }

      return ApiResponse(
        success: success,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
      );
    } catch (e) {
      debugPrint('markPaid error: $e');
      return ApiResponse(success: false, message: e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  GET SLIP  GET /api/Payroll/slip
  // ─────────────────────────────────────────────

  Future<PayrollSlipModel?> getSlip({
    required int employeeId,
    int? month,
    int? year,
  }) async {
    try {
      final uri =
          Uri.parse('$_base${AppConstants.payrollSlipEndpoint}')
              .replace(queryParameters: {
        'EmployeeId': employeeId.toString(),
        'Month': (month ?? selectedMonth.value).toString(),
        'Year': (year ?? selectedYear.value).toString(),
      });

      debugPrint('getSlip URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getSlip [emp:$employeeId] status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final raw = body['data'] ?? body;
        if (raw is Map<String, dynamic>) {
          return PayrollSlipModel.fromJson(raw);
        }
      }
      return null;
    } catch (e) {
      debugPrint('getSlip [emp:$employeeId] error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  GET ALL PAYROLLS  GET /api/Payroll/list
  // ═══════════════════════════════════════════════════════════

  Future<void> getAllPayrolls() async {
    try {
      isLoadingAll.value = true;
      allPayrolls.value = [];

      final uri =
          Uri.parse('$_base${AppConstants.payrollListEndpoint}')
              .replace(queryParameters: {
        'Month': selectedMonth.value.toString(),
        'Year': selectedYear.value.toString(),
      });

      debugPrint('getAllPayrolls URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(
              const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getAllPayrolls status: ${response.statusCode}');
      debugPrint('getAllPayrolls body  : ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          allPayrolls.value = (body['data'] as List)
              .map((e) =>
                  PayrollSlipModel.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint(
              'getAllPayrolls complete: ${allPayrolls.length} records');
        }
      } else {
        debugPrint(
            'getAllPayrolls failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('getAllPayrolls error: $e');
    } finally {
      isLoadingAll.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  LOAD MY PAYROLL (employee self-view)
  // ─────────────────────────────────────────────

  Future<void> loadMyPayroll(int userId) async {
    try {
      isLoadingMyPayroll.value = true;
      myPayroll.value = null;
      myPayroll.value = await getSlip(
        employeeId: userId,
        month: selectedMonth.value,
        year: selectedYear.value,
      );
    } finally {
      isLoadingMyPayroll.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  MONTH / YEAR NAVIGATION
  // ─────────────────────────────────────────────

  void prevMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
  }

  void nextMonth() {
    final now = DateTime.now();
    if (selectedYear.value == now.year &&
        selectedMonth.value == now.month) return;
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
  }

  bool get canGoNext {
    final now = DateTime.now();
    return !(selectedYear.value == now.year &&
        selectedMonth.value == now.month);
  }

  // ─────────────────────────────────────────────
  //  STATUS COLOR
  // ─────────────────────────────────────────────

  int statusColorValue(String status) {
    switch (status.toLowerCase().trim()) {
      case 'paid':
      case 'pay completed':
        return 0xFF22C55E;
      case 'approved':
        return 0xFF3B82F6;
      case 'pending':
      case 'draft':
        return 0xFFF97316;
      case 'not_processed':
      case 'not processed':
      case 'not generated':
        return 0xFF94A3B8;
      default:
        return 0xFF94A3B8;
    }
  }
}