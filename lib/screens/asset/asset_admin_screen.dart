// // lib/screens/asset/asset_admin_screen.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import '../../controllers/asset_controller.dart';
// import '../../core/constants/app_constants.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/asset_model_screen.dart';
// import '../../services/storage_service.dart';

// // ─────────────────────────────────────────────
// //  USER ITEM  (for assign dropdown)
// // ─────────────────────────────────────────────
// class _UserItem {
//   final int    id;
//   final String name;
//   final String email;
//   const _UserItem({required this.id, required this.name, required this.email});

//   factory _UserItem.fromJson(Map<String, dynamic> j) => _UserItem(
//         id:    j['userId']   ?? j['id']   ?? 0,
//         name:  j['userName'] ?? j['name'] ?? '',
//         email: j['email']    ?? '',
//       );
// }

// // ─────────────────────────────────────────────
// //  SHARED STYLE HELPERS
// // ─────────────────────────────────────────────
// const _whiteBold = TextStyle(
//   fontFamily: 'Poppins',
//   color: Colors.white,
//   fontWeight: FontWeight.w600,
// );

// ButtonStyle _btnStyle(Color c) => ElevatedButton.styleFrom(
//       backgroundColor: c,
//       foregroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 0,
//     );

// // ─────────────────────────────────────────────
// //  SCREEN
// // ─────────────────────────────────────────────
// class AssetAdminScreen extends StatefulWidget {
//   const AssetAdminScreen({super.key});

//   @override
//   State<AssetAdminScreen> createState() => _AssetAdminScreenState();
// }

// class _AssetAdminScreenState extends State<AssetAdminScreen>
//     with SingleTickerProviderStateMixin {
//   late final AssetController _ctrl;
//   late final TabController    _tab;

//   String? _filterStatus;
//   String? _filterType;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 3, vsync: this);
//     if (!Get.isRegistered<AssetController>()) Get.put(AssetController());
//     _ctrl = Get.find<AssetController>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _ctrl.fetchAssets();
//       _ctrl.fetchSummary();
//       _ctrl.fetchHistory();
//     });
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }

//   void _goToAllAssets() {
//     _tab.animateTo(0);
//     _ctrl.fetchAssets(
//       status:    _filterStatus?.toLowerCase(),
//       assetType: _filterType?.toLowerCase(),
//     );
//     _ctrl.fetchSummary();
//     _ctrl.fetchHistory();
//   }

//   Future<List<_UserItem>> _fetchUsers() async {
//     try {
//       final uri = Uri.parse(
//           '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.getAllUsersEndpoint}');
//       final res = await http.get(uri, headers: {
//         'Content-Type':  'application/json',
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       }).timeout(Duration(milliseconds: AppConstants.connectTimeout));
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         final list = (data['data'] ?? data) as List;
//         return list.map((e) => _UserItem.fromJson(e)).toList();
//       }
//     } catch (e) {
//       debugPrint('fetchUsers error: $e');
//     }
//     return [];
//   }

//   // ── Dialog: Add Asset ─────────────────────────────────────────────────
//   void _showAddDialog() {
//     final nameCtrl   = TextEditingController();
//     final typeCtrl   = TextEditingController();
//     final codeCtrl   = TextEditingController();
//     final serialCtrl = TextEditingController();
//     final brandCtrl  = TextEditingController();
//     final modelCtrl  = TextEditingController();
//     final descCtrl   = TextEditingController();
//     final formKey    = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.add_box_rounded, AppTheme.primary),
//               const SizedBox(height: 16),
//               const Text('Add New Asset', style: AppTheme.headline2),
//               const SizedBox(height: 20),
//               _DialogField(ctrl: nameCtrl,   label: 'Asset Name',    hint: 'e.g. MacBook Pro'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: typeCtrl,   label: 'Asset Type',    hint: 'e.g. Laptop'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: codeCtrl,   label: 'Asset Code',    hint: 'e.g. LAP-001'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: serialCtrl, label: 'Serial Number', hint: 'e.g. SN123456'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: brandCtrl,  label: 'Brand',         hint: 'e.g. Apple'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: modelCtrl,  label: 'Model',         hint: 'e.g. M3 Pro'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: descCtrl,   label: 'Description',   hint: 'Optional notes', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.addAsset(
//                         assetName:    nameCtrl.text.trim(),
//                         assetType:    typeCtrl.text.trim(),
//                         assetCode:    codeCtrl.text.trim(),
//                         serialNumber: serialCtrl.text.trim(),
//                         brand:        brandCtrl.text.trim(),
//                         model:        modelCtrl.text.trim(),
//                         description:  descCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(context).pop(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.primary),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Add Asset', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Assign ────────────────────────────────────────────────────
//   void _showAssignDialog(AssetModel asset) {
//     final noteCtrl       = TextEditingController();
//     final formKey        = GlobalKey<FormState>();
//     DateTime? returnDate;
//     final returnDateLabel = 'Select expected return date (optional)'.obs;
//     final selectedUser    = Rxn<_UserItem>();
//     final users           = <_UserItem>[].obs;
//     final isLoadingUsers  = true.obs;

//     _fetchUsers().then((list) {
//       users.assignAll(list);
//       isLoadingUsers.value = false;
//     });

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.assignment_ind_rounded, AppTheme.primary),
//               const SizedBox(height: 16),
//               const Text('Assign Asset', style: AppTheme.headline2),
//               const SizedBox(height: 6),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 20),
//               Obx(() {
//                 if (isLoadingUsers.value) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.divider),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       SizedBox(width: 16, height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
//                       SizedBox(width: 10),
//                       Text('Loading employees...',
//                           style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textHint)),
//                     ]),
//                   );
//                 }
//                 if (users.isEmpty) {
//                   return Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.error.withOpacity(0.4)),
//                       borderRadius: BorderRadius.circular(14),
//                       color: AppTheme.errorLight,
//                     ),
//                     child: const Row(children: [
//                       Icon(Icons.warning_rounded, size: 16, color: AppTheme.error),
//                       SizedBox(width: 8),
//                       Text('Could not load employees',
//                           style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.error)),
//                     ]),
//                   );
//                 }
//                 return DropdownButtonFormField<_UserItem>(
//                   value: selectedUser.value,
//                   decoration: InputDecoration(
//                     labelText: 'Assign To',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//                     ),
//                     labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                   ),
//                   hint: const Text('Select employee',
//                       style: TextStyle(fontFamily: 'Poppins')),
//                   isExpanded: true,
//                   itemHeight: null,
//                   validator: (v) => v == null ? 'Please select an employee' : null,
//                   items: users.map((u) => DropdownMenuItem(
//                     value: u,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(u.name,  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                         Text(u.email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.textHint)),
//                       ],
//                     ),
//                   )).toList(),
//                   onChanged: (v) => selectedUser.value = v,
//                   style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//                 );
//               }),
//               const SizedBox(height: 12),
//               Obx(() => GestureDetector(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now().add(const Duration(days: 7)),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                     builder: (ctx, child) => Theme(
//                       data: Theme.of(ctx).copyWith(
//                           colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
//                       child: child!,
//                     ),
//                   );
//                   if (picked != null) {
//                     returnDate = picked;
//                     returnDateLabel.value = DateFormat('dd MMMM yyyy').format(picked);
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.divider),
//                       borderRadius: BorderRadius.circular(14)),
//                   child: Row(children: [
//                     const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 18),
//                     const SizedBox(width: 10),
//                     Expanded(child: Text(
//                       returnDateLabel.value,
//                       style: TextStyle(
//                           fontFamily: 'Poppins', fontSize: 14,
//                           color: returnDate != null ? AppTheme.textPrimary : AppTheme.textHint),
//                     )),
//                     const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 18),
//                   ]),
//                 ),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: noteCtrl, label: 'Assignment Note', hint: 'Optional note', required: false, maxLines: 2),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.assignAsset(
//                         assetId:            asset.id,
//                         assignedToUserId:   selectedUser.value!.id,
//                         expectedReturnDate: returnDate,
//                         assignmentNote:     noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(context).pop(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.primary),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Assign', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Return ────────────────────────────────────────────────────
//   void _showReturnDialog(AssetModel asset) {
//     final noteCtrl      = TextEditingController();
//     final conditionCtrl = TextEditingController();
//     final formKey       = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.assignment_return_rounded, AppTheme.success),
//               const SizedBox(height: 16),
//               const Text('Return Asset', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               if (asset.assignedToName != null)
//                 Text('Currently with: ${asset.assignedToName}', style: AppTheme.caption),
//               const SizedBox(height: 20),
//               _DialogField(ctrl: noteCtrl,      label: 'Return Note',  hint: 'e.g. Returned in good condition'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: conditionCtrl, label: 'Condition',    hint: 'e.g. Good / Fair / Damaged'),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.returnAsset(
//                         assetId:         asset.id,
//                         returnNote:      noteCtrl.text.trim(),
//                         returnCondition: conditionCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(context).pop(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.success),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Confirm Return', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Open Maintenance Request (Step 1) ─────────────────────────
//   void _showOpenMaintenanceDialog(AssetModel asset) {
//     final issueCtrl      = TextEditingController();
//     final formKey        = GlobalKey<FormState>();
//     final selectedType   = RxnString();
//     const typeOptions    = ['repair', 'preventive', 'corrective', 'service'];

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.pending_actions_rounded, AppTheme.warning),
//               const SizedBox(height: 16),
//               const Text('Open Maintenance Request', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.warning.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
//                 ),
//                 child: const Row(children: [
//                   Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warning),
//                   SizedBox(width: 8),
//                   Expanded(child: Text(
//                     'Request will be opened. Admin can start it later when ready.',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.warning),
//                   )),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedType.value,
//                 decoration: InputDecoration(
//                   labelText: 'Maintenance Type',
//                   prefixIcon: const Icon(Icons.build_circle_rounded),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: AppTheme.warning, width: 2),
//                   ),
//                   labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                 ),
//                 hint: const Text('Select type', style: TextStyle(fontFamily: 'Poppins')),
//                 isExpanded: true,
//                 validator: (v) => v == null ? 'Please select maintenance type' : null,
//                 items: typeOptions.map((t) => DropdownMenuItem(
//                   value: t,
//                   child: Text(t[0].toUpperCase() + t.substring(1),
//                       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//                 )).toList(),
//                 onChanged: (v) => selectedType.value = v,
//                 style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: issueCtrl, label: 'Issue Description', hint: 'Describe the problem...', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.openMaintenanceRequest(
//                         assetId:          asset.id,
//                         maintenanceType:  selectedType.value!,
//                         issueDescription: issueCtrl.text.trim().isEmpty ? null : issueCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(context).pop(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.warning),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Open Request', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Start Maintenance (Step 2) ───────────────────────────────
//   void _showStartMaintenanceDialog(AssetModel asset) {
//     final vendorCtrl   = TextEditingController();
//     final issueCtrl    = TextEditingController();
//     final formKey      = GlobalKey<FormState>();
//     final selectedType = RxnString();
//     const typeOptions  = ['repair', 'preventive', 'corrective', 'service'];

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.build_rounded, AppTheme.error),
//               const SizedBox(height: 16),
//               const Text('Start Maintenance', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.error.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: AppTheme.error.withOpacity(0.3)),
//                 ),
//                 child: const Row(children: [
//                   Icon(Icons.play_circle_outline_rounded, size: 14, color: AppTheme.error),
//                   SizedBox(width: 8),
//                   Expanded(child: Text(
//                     'Asset will be marked as "In Maintenance". It will not be available until completed.',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.error),
//                   )),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedType.value,
//                 decoration: InputDecoration(
//                   labelText: 'Maintenance Type',
//                   prefixIcon: const Icon(Icons.build_circle_rounded),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: AppTheme.error, width: 2),
//                   ),
//                   labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                 ),
//                 hint: const Text('Select type', style: TextStyle(fontFamily: 'Poppins')),
//                 isExpanded: true,
//                 validator: (v) => v == null ? 'Please select maintenance type' : null,
//                 items: typeOptions.map((t) => DropdownMenuItem(
//                   value: t,
//                   child: Text(t[0].toUpperCase() + t.substring(1),
//                       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//                 )).toList(),
//                 onChanged: (v) => selectedType.value = v,
//                 style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: vendorCtrl, label: 'Vendor / Service Center', hint: 'e.g. Dell Service Center', required: false),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: issueCtrl,  label: 'Additional Notes',        hint: 'Any additional info...', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.startMaintenance(
//                         assetId:          asset.id,
//                         maintenanceType:  selectedType.value!,
//                         vendorName:       vendorCtrl.text.trim().isEmpty ? null : vendorCtrl.text.trim(),
//                         issueDescription: issueCtrl.text.trim().isEmpty  ? null : issueCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(context).pop(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.error),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Start Maintenance', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Complete Maintenance (Step 3) ─────────────────────────────
//   void _showCompleteMaintenanceDialog(AssetModel asset) {
//     final noteCtrl = TextEditingController();
//     final costCtrl = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             _DialogIcon(Icons.check_circle_rounded, AppTheme.success),
//             const SizedBox(height: 16),
//             const Text('Complete Maintenance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                   color: AppTheme.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8)),
//               child: const Text('In Maintenance',
//                   style: TextStyle(fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppTheme.error)),
//             ),
//             const SizedBox(height: 20),
//             _DialogField(ctrl: costCtrl, label: 'Cost (₹)', hint: 'e.g. 2500', required: false),
//             const SizedBox(height: 12),
//             _DialogField(ctrl: noteCtrl, label: 'Resolution Note', hint: 'What was fixed / replaced?', required: false, maxLines: 3),
//             const SizedBox(height: 24),
//             Row(children: [
//               Expanded(child: _CancelBtn()),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Obx(() => ElevatedButton(
//                   onPressed: _ctrl.isSubmitting.value ? null : () async {
//                     final ok = await _ctrl.completeMaintenance(
//                       assetId:        asset.id,
//                       cost:           costCtrl.text.trim().isEmpty ? null : double.tryParse(costCtrl.text.trim()),
//                       resolutionNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
//                     );
//                     if (ok) { Navigator.of(context).pop(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                   },
//                   style: _btnStyle(AppTheme.success),
//                   child: _ctrl.isSubmitting.value
//                       ? const _LoadingIndicator()
//                       : const Text('Mark Complete', style: _whiteBold),
//                 )),
//               ),
//             ]),
//           ]),
//         ),
//       ),
//     );
//   }

//   // ── Build ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddDialog,
//         backgroundColor: AppTheme.primary,
//         icon: const Icon(Icons.add_rounded, color: Colors.white),
//         label: const Text('Add Asset',
//             style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
//       ),
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: AppTheme.cardBackground,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
//               onPressed: () => Get.back(),
//             ),
//             title: const Text('Asset Management',
//                 style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.textPrimary)),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 22),
//                 onPressed: _goToAllAssets,
//               ),
//             ],
//             bottom: TabBar(
//               controller: _tab,
//               labelColor: AppTheme.primary,
//               unselectedLabelColor: AppTheme.textSecondary,
//               indicatorColor: AppTheme.primary,
//               indicatorWeight: 3,
//               labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
//               unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
//               tabs: const [Tab(text: 'All Assets'), Tab(text: 'History'), Tab(text: 'Summary')],
//             ),
//           ),
//         ],
//         body: TabBarView(
//           controller: _tab,
//           children: [
//             // ── Tab 1: All Assets ──────────────────────────────────────
//             Column(children: [
//               Container(
//                 color: AppTheme.cardBackground,
//                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
//                 child: Row(children: [
//                   Expanded(child: _FilterDrop(
//                     value: _filterStatus, hint: 'All Status',
//                     items: AssetStatus.filterLabels,
//                     onChanged: (v) {
//                       setState(() => _filterStatus = v);
//                       _ctrl.fetchAssets(status: v?.toLowerCase(), assetType: _filterType?.toLowerCase());
//                     },
//                   )),
//                   const SizedBox(width: 10),
//                   Expanded(child: _FilterDrop(
//                     value: _filterType, hint: 'All Types',
//                     items: AssetTypeNames.filterLabels,
//                     onChanged: (v) {
//                       setState(() => _filterType = v);
//                       _ctrl.fetchAssets(status: _filterStatus?.toLowerCase(), assetType: v?.toLowerCase());
//                     },
//                   )),
//                   const SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() { _filterStatus = null; _filterType = null; });
//                       _ctrl.fetchAssets();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(10)),
//                       child: const Icon(Icons.filter_alt_off_rounded, color: AppTheme.error, size: 18),
//                     ),
//                   ),
//                 ]),
//               ),
//               Expanded(child: Obx(() {
//                 if (_ctrl.isLoading.value) {
//                   return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//                 }
//                 if (_ctrl.assets.isEmpty) {
//                   return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.07), shape: BoxShape.circle),
//                       child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 40),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text('No assets found',
//                         style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                     const SizedBox(height: 6),
//                     const Text('Try changing filters or add a new asset',
//                         style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary, fontSize: 12)),
//                   ]));
//                 }
//                 return RefreshIndicator(
//                   color: AppTheme.primary,
//                   onRefresh: () => _ctrl.fetchAssets(status: _filterStatus?.toLowerCase(), assetType: _filterType?.toLowerCase()),
//                   child: ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//                     itemCount: _ctrl.assets.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 10),
//                     itemBuilder: (_, i) {
//                       final a  = _ctrl.assets[i];
//                       final st = a.status.toLowerCase();
//                       return GestureDetector(
//                         onTap: () => Get.to(() => AssetModelScreen(asset: a)),
//                         child: _AdminAssetCard(
//                           asset: a,
//                           onOpenMaintenance:     st == AssetStatus.available   ? () => _showOpenMaintenanceDialog(a)    : null,
//                           onStartMaintenance:    st == AssetStatus.open        ? () => _showStartMaintenanceDialog(a)   : null,
//                           onCompleteMaintenance: st == AssetStatus.maintenance ? () => _showCompleteMaintenanceDialog(a) : null,
//                           onAssign:              st == AssetStatus.available   ? () => _showAssignDialog(a)             : null,
//                           onReturn:              st == AssetStatus.assigned    ? () => _showReturnDialog(a)             : null,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               })),
//             ]),

//             // ── Tab 2: History ─────────────────────────────────────────
//             Obx(() {
//               if (_ctrl.isHistoryLoading.value) {
//                 return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//               }
//               if (_ctrl.history.isEmpty) {
//                 return const Center(child: Text('No history available',
//                     style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)));
//               }
//               return RefreshIndicator(
//                 color: AppTheme.primary,
//                 onRefresh: () => _ctrl.fetchHistory(),
//                 child: ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _ctrl.history.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 10),
//                   itemBuilder: (_, i) => _HistoryCard(history: _ctrl.history[i]),
//                 ),
//               );
//             }),

//             // ── Tab 3: Summary ─────────────────────────────────────────
//             Obx(() {
//               if (_ctrl.isSummaryLoading.value) {
//                 return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//               }
//               final s = _ctrl.summary.value;
//               if (s == null) {
//                 return const Center(child: Text('No summary available',
//                     style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)));
//               }
//               return RefreshIndicator(
//                 color: AppTheme.primary,
//                 onRefresh: () => _ctrl.fetchSummary(),
//                 child: ListView(padding: const EdgeInsets.all(18), children: [
//                   const SizedBox(height: 8),
//                   Row(children: [
//                     Expanded(child: _SummaryCard(label: 'Total',     value: s.total.toString(),            icon: Icons.inventory_2_rounded,     color: AppTheme.primary)),
//                     const SizedBox(width: 12),
//                     Expanded(child: _SummaryCard(label: 'Available', value: s.available.toString(),        icon: Icons.check_circle_rounded,    color: AppTheme.success)),
//                   ]),
//                   const SizedBox(height: 12),
//                   Row(children: [
//                     Expanded(child: _SummaryCard(label: 'Assigned',    value: s.assigned.toString(),         icon: Icons.person_rounded, color: AssetColors.indigo)),
//                     const SizedBox(width: 12),
//                     Expanded(child: _SummaryCard(label: 'In Maint.',   value: (s.total - s.available - s.assigned).clamp(0, s.total).toString(), icon: Icons.build_rounded, color: AppTheme.error)),
//                   ]),
//                   const SizedBox(height: 22),
//                   if (s.total > 0) Container(
//                     decoration: AppTheme.cardDecoration(),
//                     padding: const EdgeInsets.all(18),
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       const Text('Asset Distribution',
//                           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//                       const SizedBox(height: 18),
//                       _ProgressBar(label: 'Available',    value: s.total > 0 ? s.available / s.total : 0,   color: AppTheme.success,   count: s.available, total: s.total),
//                       const SizedBox(height: 14),
//                       _ProgressBar(label: 'Assigned',     value: s.total > 0 ? s.assigned / s.total : 0,    color: AssetColors.indigo, count: s.assigned,  total: s.total),
//                       const SizedBox(height: 14),
//                       _ProgressBar(label: 'In Maint.',    value: s.total > 0 ? (s.total - s.available - s.assigned).clamp(0, s.total) / s.total : 0, color: AppTheme.error, count: (s.total - s.available - s.assigned).clamp(0, s.total), total: s.total),
//                     ]),
//                   ),
//                 ]),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN ASSET CARD
// // ─────────────────────────────────────────────
// class _AdminAssetCard extends StatelessWidget {
//   final AssetModel    asset;
//   final VoidCallback? onAssign;
//   final VoidCallback? onReturn;
//   final VoidCallback? onOpenMaintenance;
//   final VoidCallback? onStartMaintenance;
//   final VoidCallback? onCompleteMaintenance;

//   const _AdminAssetCard({
//     required this.asset,
//     this.onAssign,
//     this.onReturn,
//     this.onOpenMaintenance,
//     this.onStartMaintenance,
//     this.onCompleteMaintenance,
//   });

//   bool get _hasActions =>
//       onAssign != null || onReturn != null ||
//       onOpenMaintenance != null || onStartMaintenance != null ||
//       onCompleteMaintenance != null;

//   @override
//   Widget build(BuildContext context) {
//     final sc = AssetModel.statusColor(asset.status);
//     final si = AssetModel.statusIcon(asset.status);
//     final tc = AssetModel.typeColor(asset.assetType);
//     final ti = AssetModel.typeIcon(asset.assetType);

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(14),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 48, height: 48,
//             decoration: BoxDecoration(color: tc.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//             child: Icon(ti, color: tc, size: 24),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(asset.assetName,
//                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//             const SizedBox(height: 2),
//             Text('${asset.assetCodeSafe}  ·  ${asset.assetType}', style: AppTheme.caption),
//           ])),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(si, size: 10, color: sc),
//               const SizedBox(width: 4),
//               Text(AssetModel.statusLabel(asset.status),
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: sc)),
//             ]),
//           ),
//         ]),
//         if (asset.assignedToName != null) ...[
//           const SizedBox(height: 8),
//           Row(children: [
//             const Icon(Icons.person_outline_rounded, size: 13, color: AppTheme.textHint),
//             const SizedBox(width: 4),
//             Text('Assigned to: ${asset.assignedToName}', style: AppTheme.caption),
//           ]),
//         ],
//         const SizedBox(height: 8),
//         Row(children: [
//           const Icon(Icons.touch_app_rounded, size: 12, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           const Text('Tap to view details',
//               style: TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint)),
//           const Spacer(),
//           if (asset.brand?.isNotEmpty ?? false)
//             Text('${asset.brand} · ${asset.model}', style: AppTheme.caption),
//         ]),
//         if (_hasActions) ...[
//           const SizedBox(height: 10),
//           const Divider(height: 1, color: AppTheme.divider),
//           const SizedBox(height: 10),
//           Wrap(spacing: 8, runSpacing: 8, children: [
//             if (onAssign != null)
//               _ActionBtn(label: 'Assign',        icon: Icons.assignment_ind_rounded,    color: AppTheme.primary, onTap: onAssign!),
//             if (onOpenMaintenance != null)
//               _ActionBtn(label: 'Open Request',  icon: Icons.pending_actions_rounded,   color: AppTheme.warning, onTap: onOpenMaintenance!),
//             if (onStartMaintenance != null)
//               _ActionBtn(label: 'Start Maint.',  icon: Icons.build_circle_rounded,      color: AppTheme.error,   onTap: onStartMaintenance!),
//             if (onReturn != null)
//               _ActionBtn(label: 'Return',        icon: Icons.assignment_return_rounded, color: AppTheme.success, onTap: onReturn!),
//             if (onCompleteMaintenance != null)
//               _ActionBtn(label: 'Mark Done',     icon: Icons.check_circle_rounded,      color: AppTheme.success, onTap: onCompleteMaintenance!),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ACTION BUTTON
// // ─────────────────────────────────────────────
// class _ActionBtn extends StatelessWidget {
//   final String label; final IconData icon; final Color color; final VoidCallback onTap;
//   const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});
//   @override
//   Widget build(BuildContext context) => OutlinedButton.icon(
//     onPressed: onTap, icon: Icon(icon, size: 13), label: Text(label),
//     style: OutlinedButton.styleFrom(
//       foregroundColor: color,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       side: BorderSide(color: color),
//       textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
//     ),
//   );
// }

// // ─────────────────────────────────────────────
// //  HISTORY CARD
// // ─────────────────────────────────────────────
// class _HistoryCard extends StatelessWidget {
//   final AssetHistoryModel history;
//   const _HistoryCard({required this.history});

//   // Parse JSON note from backend (maintenance records send JSON in note field)
//   Map<String, dynamic>? _parseNoteJson(String? note) {
//     if (note == null || note.isEmpty) return null;
//     try {
//       final decoded = jsonDecode(note);
//       if (decoded is Map<String, dynamic>) return decoded;
//     } catch (_) {}
//     return null;
//   }

//   String _formatDateTime(String? iso) {
//     if (iso == null) return '';
//     try {
//       // Ensure UTC parsing: append Z if no timezone offset present
//       final normalized = (iso.endsWith('Z') || iso.contains('+')) ? iso : iso + 'Z';
//       final dt = DateTime.tryParse(normalized)?.toLocal();
//       if (dt == null) return iso;
//       return '${DateFormat('dd MMM yyyy').format(dt)}  ·  ${DateFormat('hh:mm a').format(dt)}';
//     } catch (_) { return iso; }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color    = AssetHistoryModel.actionColor(history.action);
//     final icon     = AssetHistoryModel.actionIcon(history.action);
//     final label    = AssetHistoryModel.actionLabel(history.action);
//     final dateStr  = DateFormat('dd MMM yyyy').format(history.actionDate);
//     final timeStr  = DateFormat('hh:mm a').format(history.actionDate);

//     // Try parsing note as JSON (backend sends maintenance details as JSON string)
//     final noteJson = _parseNoteJson(history.note);

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(14),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           width: 44, height: 44,
//           decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Expanded(child: Text(
//               history.assetNameSafe,
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               maxLines: 1, overflow: TextOverflow.ellipsis,
//             )),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
//               child: Text(label,
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//             ),
//           ]),
//           const SizedBox(height: 6),

//           // By (who performed)
//           if (history.performedByName != null)
//             _HistoryDetail(icon: Icons.manage_accounts_rounded, color: color,
//                 label: 'By', value: history.performedByName!),

//           // To / From (target user)
//           if (history.targetUserName != null)
//             _HistoryDetail(icon: Icons.person_rounded, color: AppTheme.textSecondary,
//                 label: history.action.toLowerCase() == HistoryAction.returned ? 'From' : 'To',
//                 value: history.targetUserName!),

//           // ── Note: plain text or parsed JSON ──
//           if (noteJson != null) ...[
//             // Maintenance type
//             if (noteJson['type'] != null && noteJson['type'].toString().isNotEmpty)
//               _HistoryDetail(icon: Icons.build_circle_rounded, color: color,
//                   label: 'Type', value: noteJson['type'].toString()),
//             // Vendor
//             if (noteJson['vendor'] != null && noteJson['vendor'].toString().isNotEmpty)
//               _HistoryDetail(icon: Icons.store_rounded, color: AppTheme.textSecondary,
//                   label: 'Vendor', value: noteJson['vendor'].toString()),
//             // Issue description
//             if (noteJson['issue'] != null && noteJson['issue'].toString().isNotEmpty)
//               _HistoryDetail(icon: Icons.warning_amber_rounded, color: AppTheme.warning,
//                   label: 'Issue', value: noteJson['issue'].toString()),
//             // Resolution
//             if (noteJson['resolution'] != null && noteJson['resolution'].toString().isNotEmpty)
//               _HistoryDetail(icon: Icons.check_circle_outline_rounded, color: AppTheme.success,
//                   label: 'Resolution', value: noteJson['resolution'].toString()),
//             // Cost
//             if (noteJson['cost'] != null)
//               _HistoryDetail(icon: Icons.currency_rupee_rounded, color: AppTheme.textSecondary,
//                   label: 'Cost', value: '₹${noteJson['cost']}'),
//             // Start date
//             if (noteJson['startedAt'] != null)
//               _HistoryDetail(icon: Icons.play_circle_outline_rounded, color: AppTheme.error,
//                   label: 'Started', value: _formatDateTime(noteJson['startedAt'].toString())),
//             // Completed date
//             if (noteJson['completedAt'] != null)
//               _HistoryDetail(icon: Icons.task_alt_rounded, color: AppTheme.success,
//                   label: 'Completed', value: _formatDateTime(noteJson['completedAt'].toString())),
//           ] else if (history.note != null && history.note!.isNotEmpty)
//             // Plain text note
//             _HistoryDetail(icon: Icons.notes_rounded, color: AppTheme.textSecondary,
//                 label: 'Note', value: history.note!),

//           // Maintenance type (from separate field, if not in JSON)
//           if (noteJson == null && history.maintenanceType != null && history.maintenanceType!.isNotEmpty)
//             _HistoryDetail(icon: Icons.build_circle_rounded, color: color,
//                 label: 'Type', value: history.maintenanceType!),

//           const SizedBox(height: 6),
//           Row(children: [
//             const Icon(Icons.access_time_rounded, size: 11, color: AppTheme.textHint),
//             const SizedBox(width: 4),
//             Text('$dateStr  ·  $timeStr',
//                 style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', color: AppTheme.textHint)),
//           ]),
//         ])),
//       ]),
//     );
//   }
// }

// class _HistoryDetail extends StatelessWidget {
//   final IconData icon; final Color color; final String label, value;
//   const _HistoryDetail({required this.icon, required this.color, required this.label, required this.value});
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Icon(icon, size: 12, color: color),
//       const SizedBox(width: 5),
//       Text('$label: ', style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint, fontWeight: FontWeight.w600)),
//       Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textSecondary))),
//     ]),
//   );
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────
// class _DialogIcon extends StatelessWidget {
//   final IconData icon; final Color color;
//   const _DialogIcon(this.icon, this.color);
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
//     child: Icon(icon, color: color, size: 32),
//   );
// }

// class _DialogField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String label, hint;
//   final bool   required;
//   final int    maxLines;
//   const _DialogField({required this.ctrl, required this.label, required this.hint, this.required = true, this.maxLines = 1});
//   @override
//   Widget build(BuildContext context) => TextFormField(
//     controller: ctrl, maxLines: maxLines,
//     decoration: InputDecoration(
//       labelText: label, hintText: hint,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
//       labelStyle: const TextStyle(fontFamily: 'Poppins'),
//       hintStyle:  const TextStyle(fontFamily: 'Poppins', color: AppTheme.textHint),
//     ),
//     style: const TextStyle(fontFamily: 'Poppins'),
//     validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
//   );
// }

// class _FilterDrop extends StatelessWidget {
//   final String? value; final String hint; final List<String> items;
//   final void Function(String?) onChanged;
//   const _FilterDrop({required this.value, required this.hint, required this.items, required this.onChanged});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//     decoration: BoxDecoration(
//         border: Border.all(color: AppTheme.divider),
//         borderRadius: BorderRadius.circular(10),
//         color: AppTheme.background),
//     child: DropdownButtonHideUnderline(child: DropdownButton<String>(
//       value: value, isExpanded: true,
//       hint: Text(hint, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textHint)),
//       icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textSecondary),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textPrimary),
//       items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//       onChanged: onChanged,
//     )),
//   );
// }

// class _SummaryCard extends StatelessWidget {
//   final String label, value; final IconData icon; final Color color;
//   const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(),
//     child: Column(children: [
//       Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//         child: Icon(icon, color: color, size: 24),
//       ),
//       const SizedBox(height: 12),
//       Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: color)),
//       const SizedBox(height: 4),
//       Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
//     ]),
//   );
// }

// class _ProgressBar extends StatelessWidget {
//   final String label; final double value; final Color color; final int count, total;
//   const _ProgressBar({required this.label, required this.value, required this.color, required this.count, required this.total});
//   @override
//   Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
//       Text('$count / $total  (${(value * 100).toInt()}%)',
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//     ]),
//     const SizedBox(height: 7),
//     ClipRRect(borderRadius: BorderRadius.circular(6),
//       child: LinearProgressIndicator(
//         value: value, minHeight: 9,
//         backgroundColor: color.withOpacity(0.1),
//         valueColor: AlwaysStoppedAnimation<Color>(color),
//       )),
//   ]);
// }

// class _CancelBtn extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => OutlinedButton(
//     onPressed: () => Get.back(),
//     style: OutlinedButton.styleFrom(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       side: const BorderSide(color: AppTheme.divider),
//     ),
//     child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//   );
// }

// class _LoadingIndicator extends StatelessWidget {
//   const _LoadingIndicator();
//   @override
//   Widget build(BuildContext context) =>
//       const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
// }













// // lib/screens/asset/asset_admin_screen.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import '../../controllers/asset_controller.dart';
// import '../../core/constants/app_constants.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/asset_model_screen.dart';
// import '../../services/storage_service.dart';

// // ─────────────────────────────────────────────
// //  USER ITEM  (for assign dropdown)
// // ─────────────────────────────────────────────
// class _UserItem {
//   final int    id;
//   final String name;
//   final String email;
//   const _UserItem({required this.id, required this.name, required this.email});

//   factory _UserItem.fromJson(Map<String, dynamic> j) => _UserItem(
//         id:    j['userId']   ?? j['id']   ?? 0,
//         name:  j['userName'] ?? j['name'] ?? '',
//         email: j['email']    ?? '',
//       );
// }

// // ─────────────────────────────────────────────
// //  WORKFLOW GROUP  (Issue 1 – group related history entries)
// // ─────────────────────────────────────────────
// /// Groups consecutive history entries for the same asset into a single
// /// workflow: assign→return  or  open_maintenance→start→complete.
// class _WorkflowGroup {
//   final List<AssetHistoryModel> steps;
//   _WorkflowGroup(this.steps);

//   AssetHistoryModel get latest => steps.last;
//   AssetHistoryModel get first  => steps.first;

//   bool get isMaintenanceFlow {
//     final a = first.action.toLowerCase();
//     return a == HistoryAction.maintenanceOpen   ||
//            a == HistoryAction.maintenance          ||
//            a == HistoryAction.maintenanceStarted   ||
//            a == HistoryAction.inProgress           ||
//            a == HistoryAction.maintenanceCompleted ||
//            a == HistoryAction.completed;
//   }

//   bool get isAssignFlow {
//     final a = first.action.toLowerCase();
//     return a == HistoryAction.assigned || a == HistoryAction.returned;
//   }
// }

// List<_WorkflowGroup> _groupHistories(List<AssetHistoryModel> history) {
//   // Sort oldest→newest so we can merge forward
//   final sorted = [...history]..sort((a, b) => a.actionDate.compareTo(b.actionDate));

//   final List<_WorkflowGroup> groups = [];

//   for (final entry in sorted) {
//     final action = entry.action.toLowerCase();

//     // Maintenance continuation: start or complete attaches to existing open/start group
//     if (action == HistoryAction.maintenanceStarted ||
//         action == HistoryAction.maintenanceCompleted) {
//       // Find last open maintenance group for same asset
//       final idx = groups.lastIndexWhere((g) =>
//           g.isMaintenanceFlow &&
//           g.latest.assetId == entry.assetId &&
//           g.latest.action.toLowerCase() != HistoryAction.maintenanceCompleted &&
//           g.latest.action.toLowerCase() != HistoryAction.completed);
//       if (idx != -1) {
//         groups[idx].steps.add(entry);
//         continue;
//       }
//     }

//     // Return attaches to existing assign group for same asset
//     if (action == HistoryAction.returned) {
//       final idx = groups.lastIndexWhere((g) =>
//           g.isAssignFlow &&
//           g.latest.assetId == entry.assetId &&
//           g.latest.action.toLowerCase() != HistoryAction.returned);
//       if (idx != -1) {
//         groups[idx].steps.add(entry);
//         continue;
//       }
//     }

//     groups.add(_WorkflowGroup([entry]));
//   }

//   // Reverse so newest group shows first
//   return groups.reversed.toList();
// }

// // ─────────────────────────────────────────────
// //  SHARED STYLE HELPERS
// // ─────────────────────────────────────────────
// const _whiteBold = TextStyle(
//   fontFamily: 'Poppins',
//   color: Colors.white,
//   fontWeight: FontWeight.w600,
// );

// ButtonStyle _btnStyle(Color c) => ElevatedButton.styleFrom(
//       backgroundColor: c,
//       foregroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 0,
//     );

// // ─────────────────────────────────────────────
// //  SCREEN
// // ─────────────────────────────────────────────
// class AssetAdminScreen extends StatefulWidget {
//   const AssetAdminScreen({super.key});

//   @override
//   State<AssetAdminScreen> createState() => _AssetAdminScreenState();
// }

// class _AssetAdminScreenState extends State<AssetAdminScreen>
//     with SingleTickerProviderStateMixin {
//   late final AssetController _ctrl;
//   late final TabController    _tab;

//   String? _filterStatus;
//   String? _filterType;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 3, vsync: this);
//     if (!Get.isRegistered<AssetController>()) Get.put(AssetController());
//     _ctrl = Get.find<AssetController>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _ctrl.fetchAssets();
//       _ctrl.fetchSummary();
//       _ctrl.fetchHistory();
//     });
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }

//   void _goToAllAssets() {
//     _tab.animateTo(0);
//     _ctrl.fetchAssets(
//       status:    _filterStatus?.toLowerCase(),
//       assetType: _filterType?.toLowerCase(),
//     );
//     _ctrl.fetchSummary();
//     _ctrl.fetchHistory();
//   }

//   Future<List<_UserItem>> _fetchUsers() async {
//     try {
//       final token = StorageService.getToken();
//       final headers = {
//         'Content-Type':  'application/json',
//         'Authorization': 'Bearer $token',
//       };

//       // Try primary endpoint first, then fallback to Profile/all
//       final endpoints = [
//         '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.getAllUsersEndpoint}',
//         '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.profileAllEndpoint}',
//       ];

//       for (final url in endpoints) {
//         debugPrint('fetchUsers trying: $url');
//         try {
//           final res = await http.get(Uri.parse(url), headers: headers)
//               .timeout(Duration(milliseconds: AppConstants.connectTimeout));

//           debugPrint('fetchUsers status: ${res.statusCode}');
//           debugPrint('fetchUsers body: ${res.body.substring(0, res.body.length.clamp(0, 400))}');

//           if (res.statusCode == 200) {
//             final data = jsonDecode(res.body);

//             List<dynamic>? list;
//             if (data is List) {
//               list = data;
//             } else if (data['data'] is List)    { list = data['data']; }
//             else if (data['users'] is List)     { list = data['users']; }
//             else if (data['result'] is List)    { list = data['result']; }
//             else if (data['employees'] is List) { list = data['employees']; }
//             else if (data['profiles'] is List)  { list = data['profiles']; }

//             if (list != null && list.isNotEmpty) {
//               debugPrint('fetchUsers: ${list.length} users loaded from $url');
//               return list.map((e) {
//                 final m = e as Map<String, dynamic>;
//                 return _UserItem(
//                   id:    m['userId']    ?? m['id']        ?? m['profileId'] ?? 0,
//                   name:  m['userName']  ?? m['name']      ?? m['fullName']  ?? m['displayName'] ?? '',
//                   email: m['email']     ?? m['userEmail'] ?? '',
//                 );
//               }).where((u) => u.name.isNotEmpty).toList();
//             }
//             debugPrint('fetchUsers: unknown structure keys: ${data is Map ? data.keys.toList() : "list"}');
//           } else {
//             debugPrint('fetchUsers failed ${res.statusCode} from $url — ${res.body}');
//           }
//         } catch (inner) {
//           debugPrint('fetchUsers error on $url: $inner');
//         }
//       }
//     } catch (e, stack) {
//       debugPrint('fetchUsers exception: $e\n$stack');
//     }
//     return [];
//   }

//   // ── Helper: assignee info from history ───────────────────────────────
//   // For AVAILABLE asset  → show last person who had it (latest assigned record)
//   // For ASSIGNED asset   → show who had it before current assignee (second latest)
//   String? _getPreviousAssignee(int assetId, String currentStatus) {
//     // All assign actions for this asset, newest first
//     final assignRecords = _ctrl.history
//         .where((h) =>
//             h.assetId == assetId &&
//             h.action.toLowerCase() == HistoryAction.assigned)
//         .toList()
//       ..sort((a, b) => b.actionDate.compareTo(a.actionDate));

//     if (assignRecords.isEmpty) return null;

//     if (currentStatus.toLowerCase() == AssetStatus.assigned) {
//       // Currently assigned — show second latest (previous holder)
//       return assignRecords.length >= 2 ? assignRecords[1].targetUserName : null;
//     } else {
//       // Available / maintenance / open — show latest (last holder)
//       return assignRecords.first.targetUserName;
//     }
//   }

//   // ── Dialog: Add Asset ─────────────────────────────────────────────────
//   void _showAddDialog() {
//     final nameCtrl   = TextEditingController();
//     final typeCtrl   = TextEditingController();
//     final codeCtrl   = TextEditingController();
//     final serialCtrl = TextEditingController();
//     final brandCtrl  = TextEditingController();
//     final modelCtrl  = TextEditingController();
//     final descCtrl   = TextEditingController();
//     final formKey    = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.add_box_rounded, AppTheme.primary),
//               const SizedBox(height: 16),
//               const Text('Add New Asset', style: AppTheme.headline2),
//               const SizedBox(height: 20),
//               _DialogField(ctrl: nameCtrl,   label: 'Asset Name',    hint: 'e.g. MacBook Pro'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: typeCtrl,   label: 'Asset Type',    hint: 'e.g. Laptop'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: codeCtrl,   label: 'Asset Code',    hint: 'e.g. LAP-001'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: serialCtrl, label: 'Serial Number', hint: 'e.g. SN123456'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: brandCtrl,  label: 'Brand',         hint: 'e.g. Apple'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: modelCtrl,  label: 'Model',         hint: 'e.g. M3 Pro'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: descCtrl,   label: 'Description',   hint: 'Optional notes', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.addAsset(
//                         assetName:    nameCtrl.text.trim(),
//                         assetType:    typeCtrl.text.trim(),
//                         assetCode:    codeCtrl.text.trim(),
//                         serialNumber: serialCtrl.text.trim(),
//                         brand:        brandCtrl.text.trim(),
//                         model:        modelCtrl.text.trim(),
//                         description:  descCtrl.text.trim(),
//                       );
//                       if (ok) { Get.back(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.primary),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Add Asset', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Assign ────────────────────────────────────────────────────
//   void _showAssignDialog(AssetModel asset) {
//     final noteCtrl       = TextEditingController();
//     final formKey        = GlobalKey<FormState>();
//     DateTime? returnDate;
//     final returnDateLabel = 'Select expected return date (optional)'.obs;
//     final selectedUser    = Rxn<_UserItem>();
//     final users           = <_UserItem>[].obs;
//     final isLoadingUsers  = true.obs;

//     _fetchUsers().then((list) {
//       users.assignAll(list);
//       isLoadingUsers.value = false;
//     });

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.assignment_ind_rounded, AppTheme.primary),
//               const SizedBox(height: 16),
//               const Text('Assign Asset', style: AppTheme.headline2),
//               const SizedBox(height: 6),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 20),
//               Obx(() {
//                 if (isLoadingUsers.value) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.divider),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       SizedBox(width: 16, height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
//                       SizedBox(width: 10),
//                       Text('Loading employees...',
//                           style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textHint)),
//                     ]),
//                   );
//                 }
//                 if (users.isEmpty) {
//                   return Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.error.withOpacity(0.4)),
//                       borderRadius: BorderRadius.circular(14),
//                       color: AppTheme.errorLight,
//                     ),
//                     child: const Row(children: [
//                       Icon(Icons.warning_rounded, size: 16, color: AppTheme.error),
//                       SizedBox(width: 8),
//                       Text('Could not load employees',
//                           style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.error)),
//                     ]),
//                   );
//                 }

//                 // ─────────────────────────────────────────────────────────
//                 // FIX Issue 2: selectedItemBuilder prevents overflow when a
//                 // user is selected – the dropdown button only shows the name,
//                 // while the open list shows name + email.
//                 // ─────────────────────────────────────────────────────────
//                 return DropdownButtonFormField<_UserItem>(
//                   value: selectedUser.value,
//                   decoration: InputDecoration(
//                     labelText: 'Assign To',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//                     ),
//                     labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                   ),
//                   hint: const Text('Select employee',
//                       style: TextStyle(fontFamily: 'Poppins')),
//                   isExpanded: true,
//                   // Show only name when selected (no overflow)
//                   selectedItemBuilder: (ctx) => users.map((u) => Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       u.name,
//                       style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: AppTheme.textPrimary,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   )).toList(),
//                   validator: (v) => v == null ? 'Please select an employee' : null,
//                   items: users.map((u) => DropdownMenuItem(
//                     value: u,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(u.name,  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                         Text(u.email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.textHint)),
//                       ],
//                     ),
//                   )).toList(),
//                   onChanged: (v) => selectedUser.value = v,
//                   style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//                 );
//               }),
//               const SizedBox(height: 12),
//               Obx(() => GestureDetector(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now().add(const Duration(days: 7)),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                     builder: (ctx, child) => Theme(
//                       data: Theme.of(ctx).copyWith(
//                           colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
//                       child: child!,
//                     ),
//                   );
//                   if (picked != null) {
//                     returnDate = picked;
//                     returnDateLabel.value = DateFormat('dd MMMM yyyy').format(picked);
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.divider),
//                       borderRadius: BorderRadius.circular(14)),
//                   child: Row(children: [
//                     const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 18),
//                     const SizedBox(width: 10),
//                     Expanded(child: Text(
//                       returnDateLabel.value,
//                       style: TextStyle(
//                           fontFamily: 'Poppins', fontSize: 14,
//                           color: returnDate != null ? AppTheme.textPrimary : AppTheme.textHint),
//                     )),
//                     const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 18),
//                   ]),
//                 ),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: noteCtrl, label: 'Assignment Note', hint: 'Optional note', required: false, maxLines: 2),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.assignAsset(
//                         assetId:            asset.id,
//                         assignedToUserId:   selectedUser.value!.id,
//                         expectedReturnDate: returnDate,
//                         assignmentNote:     noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
//                       );
//                       if (ok) { Get.back(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.primary),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Assign', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Return ────────────────────────────────────────────────────
//   void _showReturnDialog(AssetModel asset) {
//     final noteCtrl      = TextEditingController();
//     final conditionCtrl = TextEditingController();
//     final formKey       = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.assignment_return_rounded, AppTheme.success),
//               const SizedBox(height: 16),
//               const Text('Return Asset', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               if (asset.assignedToName != null)
//                 Text('Currently with: ${asset.assignedToName}', style: AppTheme.caption),
//               const SizedBox(height: 20),
//               _DialogField(ctrl: conditionCtrl, label: 'Return Condition', hint: 'e.g. Good / Fair / Damaged'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: noteCtrl, label: 'Return Note', hint: 'e.g. Returned in good condition', required: false, maxLines: 2),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.returnAsset(
//                         assetId:         asset.id,
//                         returnNote:      noteCtrl.text.trim(),
//                         returnCondition: conditionCtrl.text.trim(),
//                       );
//                       if (ok) { Get.back(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.success),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Confirm Return', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Open Maintenance Request (Step 1) ─────────────────────────
//   void _showOpenMaintenanceDialog(AssetModel asset) {
//     final issueCtrl      = TextEditingController();
//     final formKey        = GlobalKey<FormState>();
//     final selectedType   = RxnString();
//     const typeOptions    = ['repair', 'preventive', 'corrective', 'service'];

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.pending_actions_rounded, AppTheme.warning),
//               const SizedBox(height: 16),
//               const Text('Open Maintenance Request', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.warning.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
//                 ),
//                 child: const Row(children: [
//                   Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warning),
//                   SizedBox(width: 8),
//                   Expanded(child: Text(
//                     'Request will be opened. Admin can start it later when ready.',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.warning),
//                   )),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedType.value,
//                 decoration: InputDecoration(
//                   labelText: 'Maintenance Type',
//                   prefixIcon: const Icon(Icons.build_circle_rounded),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: AppTheme.warning, width: 2),
//                   ),
//                   labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                 ),
//                 hint: const Text('Select type', style: TextStyle(fontFamily: 'Poppins')),
//                 isExpanded: true,
//                 validator: (v) => v == null ? 'Please select maintenance type' : null,
//                 items: typeOptions.map((t) => DropdownMenuItem(
//                   value: t,
//                   child: Text(t[0].toUpperCase() + t.substring(1),
//                       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//                 )).toList(),
//                 onChanged: (v) => selectedType.value = v,
//                 style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: issueCtrl, label: 'Issue Description', hint: 'Describe the problem...', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.openMaintenanceRequest(
//                         assetId:          asset.id,
//                         maintenanceType:  selectedType.value!,
//                         issueDescription: issueCtrl.text.trim().isEmpty ? null : issueCtrl.text.trim(),
//                       );
//                       if (ok) { Get.back(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.warning),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Open Request', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Start Maintenance (Step 2) ───────────────────────────────
//   void _showStartMaintenanceDialog(AssetModel asset) {
//     final vendorCtrl   = TextEditingController();
//     final issueCtrl    = TextEditingController();
//     final formKey      = GlobalKey<FormState>();
//     final selectedType = RxnString();
//     const typeOptions  = ['repair', 'preventive', 'corrective', 'service'];

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.build_rounded, AppTheme.error),
//               const SizedBox(height: 16),
//               const Text('Start Maintenance', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.error.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: AppTheme.error.withOpacity(0.3)),
//                 ),
//                 child: const Row(children: [
//                   Icon(Icons.play_circle_outline_rounded, size: 14, color: AppTheme.error),
//                   SizedBox(width: 8),
//                   Expanded(child: Text(
//                     'Asset will be marked as "In Maintenance". It will not be available until completed.',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.error),
//                   )),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedType.value,
//                 decoration: InputDecoration(
//                   labelText: 'Maintenance Type',
//                   prefixIcon: const Icon(Icons.build_circle_rounded),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: AppTheme.error, width: 2),
//                   ),
//                   labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                 ),
//                 hint: const Text('Select type', style: TextStyle(fontFamily: 'Poppins')),
//                 isExpanded: true,
//                 validator: (v) => v == null ? 'Please select maintenance type' : null,
//                 items: typeOptions.map((t) => DropdownMenuItem(
//                   value: t,
//                   child: Text(t[0].toUpperCase() + t.substring(1),
//                       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//                 )).toList(),
//                 onChanged: (v) => selectedType.value = v,
//                 style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: vendorCtrl, label: 'Vendor / Service Center', hint: 'e.g. Dell Service Center', required: false),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: issueCtrl,  label: 'Additional Notes',        hint: 'Any additional info...', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.startMaintenance(
//                         assetId:          asset.id,
//                         maintenanceType:  selectedType.value!,
//                         vendorName:       vendorCtrl.text.trim().isEmpty ? null : vendorCtrl.text.trim(),
//                         issueDescription: issueCtrl.text.trim().isEmpty  ? null : issueCtrl.text.trim(),
//                       );
//                       if (ok) { Get.back(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                     },
//                     style: _btnStyle(AppTheme.error),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Start Maintenance', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Complete Maintenance (Step 3) ─────────────────────────────
//   void _showCompleteMaintenanceDialog(AssetModel asset) {
//     final noteCtrl = TextEditingController();
//     final costCtrl = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             _DialogIcon(Icons.check_circle_rounded, AppTheme.success),
//             const SizedBox(height: 16),
//             const Text('Complete Maintenance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                   color: AppTheme.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8)),
//               child: const Text('In Maintenance',
//                   style: TextStyle(fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppTheme.error)),
//             ),
//             const SizedBox(height: 20),
//             _DialogField(ctrl: costCtrl, label: 'Cost (₹)', hint: 'e.g. 2500', required: false),
//             const SizedBox(height: 12),
//             _DialogField(ctrl: noteCtrl, label: 'Resolution Note', hint: 'What was fixed / replaced?', required: false, maxLines: 3),
//             const SizedBox(height: 24),
//             Row(children: [
//               Expanded(child: _CancelBtn()),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Obx(() => ElevatedButton(
//                   onPressed: _ctrl.isSubmitting.value ? null : () async {
//                     final ok = await _ctrl.completeMaintenance(
//                       assetId:        asset.id,
//                       cost:           costCtrl.text.trim().isEmpty ? null : double.tryParse(costCtrl.text.trim()),
//                       resolutionNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
//                     );
//                     if (ok) { Get.back(); Future.delayed(const Duration(milliseconds: 200), _goToAllAssets); }
//                   },
//                   style: _btnStyle(AppTheme.success),
//                   child: _ctrl.isSubmitting.value
//                       ? const _LoadingIndicator()
//                       : const Text('Mark Complete', style: _whiteBold),
//                 )),
//               ),
//             ]),
//           ]),
//         ),
//       ),
//     );
//   }

//   // ── Build ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddDialog,
//         backgroundColor: AppTheme.primary,
//         icon: const Icon(Icons.add_rounded, color: Colors.white),
//         label: const Text('Add Asset',
//             style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
//       ),
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: AppTheme.cardBackground,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
//               onPressed: () => Get.back(),
//             ),
//             title: const Text('Asset Management',
//                 style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.textPrimary)),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 22),
//                 onPressed: _goToAllAssets,
//               ),
//             ],
//             bottom: TabBar(
//               controller: _tab,
//               labelColor: AppTheme.primary,
//               unselectedLabelColor: AppTheme.textSecondary,
//               indicatorColor: AppTheme.primary,
//               indicatorWeight: 3,
//               labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
//               unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
//               tabs: const [Tab(text: 'All Assets'), Tab(text: 'History'), Tab(text: 'Summary')],
//             ),
//           ),
//         ],
//         body: TabBarView(
//           controller: _tab,
//           children: [
//             // ── Tab 1: All Assets ──────────────────────────────────────
//             Column(children: [
//               Container(
//                 color: AppTheme.cardBackground,
//                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
//                 child: Row(children: [
//                   Expanded(child: _FilterDrop(
//                     value: _filterStatus, hint: 'All Status',
//                     items: AssetStatus.filterLabels,
//                     onChanged: (v) {
//                       setState(() => _filterStatus = v);
//                       _ctrl.fetchAssets(status: v?.toLowerCase(), assetType: _filterType?.toLowerCase());
//                     },
//                   )),
//                   const SizedBox(width: 10),
//                   Expanded(child: _FilterDrop(
//                     value: _filterType, hint: 'All Types',
//                     items: AssetTypeNames.filterLabels,
//                     onChanged: (v) {
//                       setState(() => _filterType = v);
//                       _ctrl.fetchAssets(status: _filterStatus?.toLowerCase(), assetType: v?.toLowerCase());
//                     },
//                   )),
//                   const SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() { _filterStatus = null; _filterType = null; });
//                       _ctrl.fetchAssets();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(10)),
//                       child: const Icon(Icons.filter_alt_off_rounded, color: AppTheme.error, size: 18),
//                     ),
//                   ),
//                 ]),
//               ),
//               Expanded(child: Obx(() {
//                 if (_ctrl.isLoading.value) {
//                   return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//                 }
//                 if (_ctrl.assets.isEmpty) {
//                   return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.07), shape: BoxShape.circle),
//                       child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 40),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text('No assets found',
//                         style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                     const SizedBox(height: 6),
//                     const Text('Try changing filters or add a new asset',
//                         style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary, fontSize: 12)),
//                   ]));
//                 }
//                 return RefreshIndicator(
//                   color: AppTheme.primary,
//                   onRefresh: () => _ctrl.fetchAssets(status: _filterStatus?.toLowerCase(), assetType: _filterType?.toLowerCase()),
//                   child: ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//                     itemCount: _ctrl.assets.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 10),
//                     itemBuilder: (_, i) {
//                       final a  = _ctrl.assets[i];
//                       final st = a.status.toLowerCase();

//                       // Issue 3: previous assignee history se nikalna
//                       final prevAssignee = _getPreviousAssignee(a.id, a.status);

//                       return GestureDetector(
//                         onTap: () => Get.to(() => AssetModelScreen(asset: a)),
//                         child: _AdminAssetCard(
//                           asset: a,
//                           previousAssignee: prevAssignee,
//                           onOpenMaintenance:     st == AssetStatus.available   ? () => _showOpenMaintenanceDialog(a)    : null,
//                           onStartMaintenance:    st == AssetStatus.open        ? () => _showStartMaintenanceDialog(a)   : null,
//                           onCompleteMaintenance: st == AssetStatus.maintenance ? () => _showCompleteMaintenanceDialog(a) : null,
//                           onAssign:              st == AssetStatus.available   ? () => _showAssignDialog(a)             : null,
//                           onReturn:              st == AssetStatus.assigned    ? () => _showReturnDialog(a)             : null,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               })),
//             ]),

//             // ── Tab 2: History (Grouped) ───────────────────────────────
//             Obx(() {
//               if (_ctrl.isHistoryLoading.value) {
//                 return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//               }
//               if (_ctrl.history.isEmpty) {
//                 return const Center(child: Text('No history available',
//                     style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)));
//               }

//               // Issue 1: Group related history entries
//               final groups = _groupHistories(_ctrl.history);

//               return RefreshIndicator(
//                 color: AppTheme.primary,
//                 onRefresh: () => _ctrl.fetchHistory(),
//                 child: ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: groups.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 10),
//                   itemBuilder: (_, i) => _GroupedHistoryCard(group: groups[i]),
//                 ),
//               );
//             }),

//             // ── Tab 3: Summary ─────────────────────────────────────────
//             Obx(() {
//               if (_ctrl.isSummaryLoading.value) {
//                 return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//               }
//               final s = _ctrl.summary.value;
//               if (s == null) {
//                 return const Center(child: Text('No summary available',
//                     style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)));
//               }
//               return RefreshIndicator(
//                 color: AppTheme.primary,
//                 onRefresh: () => _ctrl.fetchSummary(),
//                 child: ListView(padding: const EdgeInsets.all(18), children: [
//                   const SizedBox(height: 8),
//                   Row(children: [
//                     Expanded(child: _SummaryCard(label: 'Total',     value: s.total.toString(),            icon: Icons.inventory_2_rounded,     color: AppTheme.primary)),
//                     const SizedBox(width: 12),
//                     Expanded(child: _SummaryCard(label: 'Available', value: s.available.toString(),        icon: Icons.check_circle_rounded,    color: AppTheme.success)),
//                   ]),
//                   const SizedBox(height: 12),
//                   Row(children: [
//                     Expanded(child: _SummaryCard(label: 'Assigned',    value: s.assigned.toString(),         icon: Icons.person_rounded, color: AssetColors.indigo)),
//                     const SizedBox(width: 12),
//                     Expanded(child: _SummaryCard(label: 'In Maint.',   value: (s.total - s.available - s.assigned).clamp(0, s.total).toString(), icon: Icons.build_rounded, color: AppTheme.error)),
//                   ]),
//                   const SizedBox(height: 22),
//                   if (s.total > 0) Container(
//                     decoration: AppTheme.cardDecoration(),
//                     padding: const EdgeInsets.all(18),
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       const Text('Asset Distribution',
//                           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//                       const SizedBox(height: 18),
//                       _ProgressBar(label: 'Available',    value: s.total > 0 ? s.available / s.total : 0,   color: AppTheme.success,   count: s.available, total: s.total),
//                       const SizedBox(height: 14),
//                       _ProgressBar(label: 'Assigned',     value: s.total > 0 ? s.assigned / s.total : 0,    color: AssetColors.indigo, count: s.assigned,  total: s.total),
//                       const SizedBox(height: 14),
//                       _ProgressBar(label: 'In Maint.',    value: s.total > 0 ? (s.total - s.available - s.assigned).clamp(0, s.total) / s.total : 0, color: AppTheme.error, count: (s.total - s.available - s.assigned).clamp(0, s.total), total: s.total),
//                     ]),
//                   ),
//                 ]),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN ASSET CARD  (Issue 3: previousAssignee added)
// // ─────────────────────────────────────────────
// class _AdminAssetCard extends StatelessWidget {
//   final AssetModel    asset;
//   final String?       previousAssignee;   // Issue 3
//   final VoidCallback? onAssign;
//   final VoidCallback? onReturn;
//   final VoidCallback? onOpenMaintenance;
//   final VoidCallback? onStartMaintenance;
//   final VoidCallback? onCompleteMaintenance;

//   const _AdminAssetCard({
//     required this.asset,
//     this.previousAssignee,
//     this.onAssign,
//     this.onReturn,
//     this.onOpenMaintenance,
//     this.onStartMaintenance,
//     this.onCompleteMaintenance,
//   });

//   bool get _hasActions =>
//       onAssign != null || onReturn != null ||
//       onOpenMaintenance != null || onStartMaintenance != null ||
//       onCompleteMaintenance != null;

//   @override
//   Widget build(BuildContext context) {
//     final sc = AssetModel.statusColor(asset.status);
//     final si = AssetModel.statusIcon(asset.status);
//     final tc = AssetModel.typeColor(asset.assetType);
//     final ti = AssetModel.typeIcon(asset.assetType);

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(14),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 48, height: 48,
//             decoration: BoxDecoration(color: tc.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//             child: Icon(ti, color: tc, size: 24),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(asset.assetName,
//                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//             const SizedBox(height: 2),
//             Text('${asset.assetCodeSafe}  ·  ${asset.assetType}', style: AppTheme.caption),
//           ])),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(si, size: 10, color: sc),
//               const SizedBox(width: 4),
//               Text(AssetModel.statusLabel(asset.status),
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: sc)),
//             ]),
//           ),
//         ]),

//         // Current assignee
//         if (asset.assignedToName != null) ...[
//           const SizedBox(height: 8),
//           Row(children: [
//             const Icon(Icons.person_rounded, size: 13, color: AppTheme.primary),
//             const SizedBox(width: 4),
//             Text('Assigned to: ${asset.assignedToName}',
//                 style: const TextStyle(fontSize: 11, fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w600, color: AppTheme.primary)),
//           ]),
//         ],

//         // Issue 3: Previous assignee
//         if (previousAssignee != null) ...[
//           const SizedBox(height: 4),
//           Row(children: [
//             Icon(
//               asset.status.toLowerCase() == AssetStatus.assigned
//                   ? Icons.swap_horiz_rounded
//                   : Icons.person_off_rounded,
//               size: 13, color: AppTheme.textHint,
//             ),
//             const SizedBox(width: 4),
//             Text(
//               asset.status.toLowerCase() == AssetStatus.assigned
//                   ? 'Previously: $previousAssignee'
//                   : 'Last with: $previousAssignee',
//               style: const TextStyle(
//                   fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint),
//             ),
//           ]),
//         ],

//         const SizedBox(height: 8),
//         Row(children: [
//           const Icon(Icons.touch_app_rounded, size: 12, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           const Text('Tap to view details',
//               style: TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint)),
//           const Spacer(),
//           if (asset.brand?.isNotEmpty ?? false)
//             Text('${asset.brand} · ${asset.model}', style: AppTheme.caption),
//         ]),
//         if (_hasActions) ...[
//           const SizedBox(height: 10),
//           const Divider(height: 1, color: AppTheme.divider),
//           const SizedBox(height: 10),
//           Wrap(spacing: 8, runSpacing: 8, children: [
//             if (onAssign != null)
//               _ActionBtn(label: 'Assign',        icon: Icons.assignment_ind_rounded,    color: AppTheme.primary, onTap: onAssign!),
//             if (onOpenMaintenance != null)
//               _ActionBtn(label: 'Open Request',  icon: Icons.pending_actions_rounded,   color: AppTheme.warning, onTap: onOpenMaintenance!),
//             if (onStartMaintenance != null)
//               _ActionBtn(label: 'Start Maint.',  icon: Icons.build_circle_rounded,      color: AppTheme.error,   onTap: onStartMaintenance!),
//             if (onReturn != null)
//               _ActionBtn(label: 'Return',        icon: Icons.assignment_return_rounded, color: AppTheme.success, onTap: onReturn!),
//             if (onCompleteMaintenance != null)
//               _ActionBtn(label: 'Mark Done',     icon: Icons.check_circle_rounded,      color: AppTheme.success, onTap: onCompleteMaintenance!),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  GROUPED HISTORY CARD  (Issue 1)
// //  Shows a single card per workflow with a
// //  timeline of all steps inside.
// // ─────────────────────────────────────────────
// class _GroupedHistoryCard extends StatelessWidget {
//   final _WorkflowGroup group;
//   const _GroupedHistoryCard({required this.group});

//   static Map<String, dynamic>? _parseNoteJson(String? note) {
//     if (note == null || note.isEmpty) return null;
//     try {
//       final decoded = jsonDecode(note);
//       if (decoded is Map<String, dynamic>) return decoded;
//     } catch (_) {}
//     return null;
//   }

//   // Issue 4: proper UTC → local conversion
//   static String _fmtLocal(DateTime dt) {
//     final local = dt.toLocal();
//     return '${DateFormat('dd MMM yyyy').format(local)}  ·  ${DateFormat('hh:mm a').format(local)}';
//   }

//   static String _fmtIsoLocal(String? iso) {
//     if (iso == null || iso.isEmpty) return '';
//     try {
//       final normalized = (iso.endsWith('Z') || iso.contains('+')) ? iso : '${iso}Z';
//       final dt = DateTime.tryParse(normalized)?.toLocal();
//       if (dt == null) return iso;
//       return '${DateFormat('dd MMM yyyy').format(dt)}  ·  ${DateFormat('hh:mm a').format(dt)}';
//     } catch (_) { return iso; }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final latest   = group.latest;
//     final color    = AssetHistoryModel.actionColor(latest.action);
//     final icon     = AssetHistoryModel.actionIcon(latest.action);
//     final label    = AssetHistoryModel.actionLabel(latest.action);

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(14),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // ── Header ──────────────────────────────────────────────────────
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 44, height: 44,
//             decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(child: Text(
//                 latest.assetNameSafe,
//                 style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary),
//                 maxLines: 1, overflow: TextOverflow.ellipsis,
//               )),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
//                 child: Text(label,
//                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//               ),
//             ]),
//             const SizedBox(height: 3),
//             Row(children: [
//               const Icon(Icons.access_time_rounded, size: 11, color: AppTheme.textHint),
//               const SizedBox(width: 3),
//               Text(_fmtLocal(latest.actionDate.toLocal()),   // Issue 4 fix
//                   style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', color: AppTheme.textHint)),
//             ]),
//           ])),
//         ]),

//         // ── Timeline of all steps ────────────────────────────────────────
//         if (group.steps.length > 1) ...[
//           const SizedBox(height: 12),
//           const Divider(height: 1, color: AppTheme.divider),
//           const SizedBox(height: 10),
//           ...group.steps.asMap().entries.map((e) {
//             final idx   = e.key;
//             final step  = e.value;
//             final sc    = AssetHistoryModel.actionColor(step.action);
//             final si    = AssetHistoryModel.actionIcon(step.action);
//             final sl    = AssetHistoryModel.actionLabel(step.action);
//             final isLast = idx == group.steps.length - 1;
//             return _TimelineStep(
//               icon: si, color: sc, label: sl,
//               isLast: isLast,
//               content: _buildStepContent(step, sc),
//             );
//           }),
//         ] else ...[
//           // Single step – show details inline
//           const SizedBox(height: 8),
//           ..._buildStepContent(group.first, color),
//         ],
//       ]),
//     );
//   }

//   List<Widget> _buildStepContent(AssetHistoryModel step, Color color) {
//     final noteJson = _parseNoteJson(step.note);
//     final widgets  = <Widget>[];

//     // Issue 5: Who performed the action (Add, Assign, Return, etc.)
//     if (step.performedByName != null && step.performedByName!.isNotEmpty) {
//       widgets.add(_HistoryDetail(
//         icon: Icons.manage_accounts_rounded, color: color,
//         label: step.action.toLowerCase() == HistoryAction.added ? 'Added by' : 'By',
//         value: step.performedByName!,
//       ));
//     }

//     // To / From
//     if (step.targetUserName != null) {
//       final lbl = step.action.toLowerCase() == HistoryAction.returned ? 'Returned from' : 'Assigned to';
//       widgets.add(_HistoryDetail(
//         icon: Icons.person_rounded, color: AppTheme.textSecondary,
//         label: lbl, value: step.targetUserName!,
//       ));
//     }

//     if (noteJson != null) {
//       if ((noteJson['type'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.build_circle_rounded, color: color, label: 'Type', value: noteJson['type'].toString()));
//       if ((noteJson['vendor'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.store_rounded, color: AppTheme.textSecondary, label: 'Vendor', value: noteJson['vendor'].toString()));
//       if ((noteJson['issue'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.warning_amber_rounded, color: AppTheme.warning, label: 'Issue', value: noteJson['issue'].toString()));
//       if ((noteJson['resolution'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.check_circle_outline_rounded, color: AppTheme.success, label: 'Resolution', value: noteJson['resolution'].toString()));
//       if (noteJson['cost'] != null)
//         widgets.add(_HistoryDetail(icon: Icons.currency_rupee_rounded, color: AppTheme.textSecondary, label: 'Cost', value: '₹${noteJson['cost']}'));
//       // Issue 4: Return condition
//       if ((noteJson['condition'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.verified_outlined, color: AppTheme.success, label: 'Condition', value: noteJson['condition'].toString()));
//       if (noteJson['startedAt'] != null)
//         widgets.add(_HistoryDetail(icon: Icons.play_circle_outline_rounded, color: AppTheme.error, label: 'Started', value: _fmtIsoLocal(noteJson['startedAt'].toString())));
//       if (noteJson['completedAt'] != null)
//         widgets.add(_HistoryDetail(icon: Icons.task_alt_rounded, color: AppTheme.success, label: 'Completed', value: _fmtIsoLocal(noteJson['completedAt'].toString())));
//     } else {
//       // Issue 4: plain return condition (if backend stores it separately)
//       if (step.condition != null && step.condition!.isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.verified_outlined, color: AppTheme.success, label: 'Condition', value: step.condition!));
//       if (step.note != null && step.note!.isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.notes_rounded, color: AppTheme.textSecondary, label: 'Note', value: step.note!));
//       if (step.maintenanceType != null && step.maintenanceType!.isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.build_circle_rounded, color: color, label: 'Type', value: step.maintenanceType!));
//     }

//     return widgets;
//   }
// }

// // ─────────────────────────────────────────────
// //  TIMELINE STEP  (used inside grouped card)
// // ─────────────────────────────────────────────
// class _TimelineStep extends StatelessWidget {
//   final IconData     icon;
//   final Color        color;
//   final String       label;
//   final bool         isLast;
//   final List<Widget> content;

//   const _TimelineStep({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.isLast,
//     required this.content,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicHeight(
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Vertical line + dot
//         SizedBox(width: 28, child: Column(children: [
//           Container(
//             width: 24, height: 24,
//             decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
//             child: Icon(icon, size: 13, color: color),
//           ),
//           if (!isLast)
//             Expanded(child: Container(width: 2, color: AppTheme.divider, margin: const EdgeInsets.symmetric(vertical: 2))),
//         ])),
//         const SizedBox(width: 10),
//         Expanded(child: Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//               decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
//               child: Text(label,
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//             ),
//             const SizedBox(height: 4),
//             ...content,
//           ]),
//         )),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ACTION BUTTON
// // ─────────────────────────────────────────────
// class _ActionBtn extends StatelessWidget {
//   final String label; final IconData icon; final Color color; final VoidCallback onTap;
//   const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});
//   @override
//   Widget build(BuildContext context) => OutlinedButton.icon(
//     onPressed: onTap, icon: Icon(icon, size: 13), label: Text(label),
//     style: OutlinedButton.styleFrom(
//       foregroundColor: color,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       side: BorderSide(color: color),
//       textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
//     ),
//   );
// }

// // ─────────────────────────────────────────────
// //  HISTORY DETAIL ROW
// // ─────────────────────────────────────────────
// class _HistoryDetail extends StatelessWidget {
//   final IconData icon; final Color color; final String label, value;
//   const _HistoryDetail({required this.icon, required this.color, required this.label, required this.value});
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Icon(icon, size: 12, color: color),
//       const SizedBox(width: 5),
//       Text('$label: ', style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint, fontWeight: FontWeight.w600)),
//       Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textSecondary))),
//     ]),
//   );
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────
// class _DialogIcon extends StatelessWidget {
//   final IconData icon; final Color color;
//   const _DialogIcon(this.icon, this.color);
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
//     child: Icon(icon, color: color, size: 32),
//   );
// }

// class _DialogField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String label, hint;
//   final bool   required;
//   final int    maxLines;
//   const _DialogField({required this.ctrl, required this.label, required this.hint, this.required = true, this.maxLines = 1});
//   @override
//   Widget build(BuildContext context) => TextFormField(
//     controller: ctrl, maxLines: maxLines,
//     decoration: InputDecoration(
//       labelText: label, hintText: hint,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
//       labelStyle: const TextStyle(fontFamily: 'Poppins'),
//       hintStyle:  const TextStyle(fontFamily: 'Poppins', color: AppTheme.textHint),
//     ),
//     style: const TextStyle(fontFamily: 'Poppins'),
//     validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
//   );
// }

// class _FilterDrop extends StatelessWidget {
//   final String? value; final String hint; final List<String> items;
//   final void Function(String?) onChanged;
//   const _FilterDrop({required this.value, required this.hint, required this.items, required this.onChanged});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//     decoration: BoxDecoration(
//         border: Border.all(color: AppTheme.divider),
//         borderRadius: BorderRadius.circular(10),
//         color: AppTheme.background),
//     child: DropdownButtonHideUnderline(child: DropdownButton<String>(
//       value: value, isExpanded: true,
//       hint: Text(hint, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textHint)),
//       icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textSecondary),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textPrimary),
//       items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//       onChanged: onChanged,
//     )),
//   );
// }

// class _SummaryCard extends StatelessWidget {
//   final String label, value; final IconData icon; final Color color;
//   const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(),
//     child: Column(children: [
//       Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//         child: Icon(icon, color: color, size: 24),
//       ),
//       const SizedBox(height: 12),
//       Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: color)),
//       const SizedBox(height: 4),
//       Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
//     ]),
//   );
// }

// class _ProgressBar extends StatelessWidget {
//   final String label; final double value; final Color color; final int count, total;
//   const _ProgressBar({required this.label, required this.value, required this.color, required this.count, required this.total});
//   @override
//   Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
//       Text('$count / $total  (${(value * 100).toInt()}%)',
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//     ]),
//     const SizedBox(height: 7),
//     ClipRRect(borderRadius: BorderRadius.circular(6),
//       child: LinearProgressIndicator(
//         value: value, minHeight: 9,
//         backgroundColor: color.withOpacity(0.1),
//         valueColor: AlwaysStoppedAnimation<Color>(color),
//       )),
//   ]);
// }

// class _CancelBtn extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => OutlinedButton(
//     onPressed: () => Get.back(),
//     style: OutlinedButton.styleFrom(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       side: const BorderSide(color: AppTheme.divider),
//     ),
//     child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//   );
// }

// class _LoadingIndicator extends StatelessWidget {
//   const _LoadingIndicator();
//   @override
//   Widget build(BuildContext context) =>
//       const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
// }



















// // lib/screens/asset/asset_admin_screen.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import '../../controllers/asset_controller.dart';
// import '../../core/constants/app_constants.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/asset_model_screen.dart';
// import '../../services/storage_service.dart';

// // ─────────────────────────────────────────────
// //  USER ITEM  (for assign dropdown)
// // ─────────────────────────────────────────────
// class _UserItem {
//   final int    id;
//   final String name;
//   final String email;
//   const _UserItem({required this.id, required this.name, required this.email});

//   factory _UserItem.fromJson(Map<String, dynamic> j) => _UserItem(
//         id:    j['userId']   ?? j['id']   ?? 0,
//         name:  j['userName'] ?? j['name'] ?? '',
//         email: j['email']    ?? '',
//       );
// }

// // ─────────────────────────────────────────────
// //  WORKFLOW GROUP  (Issue 1 – group related history entries)
// // ─────────────────────────────────────────────
// /// Groups consecutive history entries for the same asset into a single
// /// workflow: assign→return  or  open_maintenance→start→complete.
// class _WorkflowGroup {
//   final List<AssetHistoryModel> steps;
//   _WorkflowGroup(this.steps);

//   AssetHistoryModel get latest => steps.last;
//   AssetHistoryModel get first  => steps.first;

//   bool get isMaintenanceFlow {
//     final a = first.action.toLowerCase();
//     return a == HistoryAction.maintenanceOpen   ||
//            a == HistoryAction.maintenance          ||
//            a == HistoryAction.maintenanceStarted   ||
//            a == HistoryAction.inProgress           ||
//            a == HistoryAction.maintenanceCompleted ||
//            a == HistoryAction.completed;
//   }

//   bool get isAssignFlow {
//     final a = first.action.toLowerCase();
//     return a == HistoryAction.assigned || a == HistoryAction.returned;
//   }
// }

// List<_WorkflowGroup> _groupHistories(List<AssetHistoryModel> history) {
//   // Sort oldest→newest so we can merge forward
//   final sorted = [...history]..sort((a, b) => a.actionDate.compareTo(b.actionDate));

//   final List<_WorkflowGroup> groups = [];

//   for (final entry in sorted) {
//     final action = entry.action.toLowerCase();

//     // Maintenance continuation: start or complete attaches to existing open/start group
//     if (action == HistoryAction.maintenanceStarted ||
//         action == HistoryAction.maintenanceCompleted) {
//       // Find last open maintenance group for same asset
//       final idx = groups.lastIndexWhere((g) =>
//           g.isMaintenanceFlow &&
//           g.latest.assetId == entry.assetId &&
//           g.latest.action.toLowerCase() != HistoryAction.maintenanceCompleted &&
//           g.latest.action.toLowerCase() != HistoryAction.completed);
//       if (idx != -1) {
//         groups[idx].steps.add(entry);
//         continue;
//       }
//     }

//     // Return attaches to existing assign group for same asset
//     if (action == HistoryAction.returned) {
//       final idx = groups.lastIndexWhere((g) =>
//           g.isAssignFlow &&
//           g.latest.assetId == entry.assetId &&
//           g.latest.action.toLowerCase() != HistoryAction.returned);
//       if (idx != -1) {
//         groups[idx].steps.add(entry);
//         continue;
//       }
//     }

//     groups.add(_WorkflowGroup([entry]));
//   }

//   // Reverse so newest group shows first
//   return groups.reversed.toList();
// }

// // ─────────────────────────────────────────────
// //  SHARED STYLE HELPERS
// // ─────────────────────────────────────────────
// const _whiteBold = TextStyle(
//   fontFamily: 'Poppins',
//   color: Colors.white,
//   fontWeight: FontWeight.w600,
// );

// ButtonStyle _btnStyle(Color c) => ElevatedButton.styleFrom(
//       backgroundColor: c,
//       foregroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 0,
//     );

// // ─────────────────────────────────────────────
// //  SCREEN
// // ─────────────────────────────────────────────
// class AssetAdminScreen extends StatefulWidget {
//   const AssetAdminScreen({super.key});

//   @override
//   State<AssetAdminScreen> createState() => _AssetAdminScreenState();
// }

// class _AssetAdminScreenState extends State<AssetAdminScreen>
//     with SingleTickerProviderStateMixin {
//   late final AssetController _ctrl;
//   late final TabController    _tab;

//   String? _filterStatus;
//   String? _filterType;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 3, vsync: this);
//     if (!Get.isRegistered<AssetController>()) Get.put(AssetController());
//     _ctrl = Get.find<AssetController>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _ctrl.fetchAssets();
//       _ctrl.fetchSummary();
//       _ctrl.fetchHistory();
//     });
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }

//   void _goToAllAssets() {
//     _tab.animateTo(0);
//     _ctrl.fetchAssets(
//       status:    _filterStatus?.toLowerCase(),
//       assetType: _filterType?.toLowerCase(),
//     );
//     _ctrl.fetchSummary();
//     _ctrl.fetchHistory();
//   }

//   Future<List<_UserItem>> _fetchUsers() async {
//     try {
//       final token = StorageService.getToken();
//       final headers = {
//         'Content-Type':  'application/json',
//         'Authorization': 'Bearer $token',
//       };

//       // Try primary endpoint first, then fallback to Profile/all
//       final endpoints = [
//         '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.getAllUsersEndpoint}',
//         '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.profileAllEndpoint}',
//       ];

//       for (final url in endpoints) {
//         debugPrint('fetchUsers trying: $url');
//         try {
//           final res = await http.get(Uri.parse(url), headers: headers)
//               .timeout(Duration(milliseconds: AppConstants.connectTimeout));

//           debugPrint('fetchUsers status: ${res.statusCode}');
//           debugPrint('fetchUsers body: ${res.body.substring(0, res.body.length.clamp(0, 400))}');

//           if (res.statusCode == 200) {
//             final data = jsonDecode(res.body);

//             List<dynamic>? list;
//             if (data is List) {
//               list = data;
//             } else if (data['data'] is List)    { list = data['data']; }
//             else if (data['users'] is List)     { list = data['users']; }
//             else if (data['result'] is List)    { list = data['result']; }
//             else if (data['employees'] is List) { list = data['employees']; }
//             else if (data['profiles'] is List)  { list = data['profiles']; }

//             if (list != null && list.isNotEmpty) {
//               debugPrint('fetchUsers: ${list.length} users loaded from $url');
//               return list.map((e) {
//                 final m = e as Map<String, dynamic>;
//                 return _UserItem(
//                   id:    m['userId']    ?? m['id']        ?? m['profileId'] ?? 0,
//                   name:  m['userName']  ?? m['name']      ?? m['fullName']  ?? m['displayName'] ?? '',
//                   email: m['email']     ?? m['userEmail'] ?? '',
//                 );
//               }).where((u) => u.name.isNotEmpty).toList();
//             }
//             debugPrint('fetchUsers: unknown structure keys: ${data is Map ? data.keys.toList() : "list"}');
//           } else {
//             debugPrint('fetchUsers failed ${res.statusCode} from $url — ${res.body}');
//           }
//         } catch (inner) {
//           debugPrint('fetchUsers error on $url: $inner');
//         }
//       }
//     } catch (e, stack) {
//       debugPrint('fetchUsers exception: $e\n$stack');
//     }
//     return [];
//   }

//   // ── Helper: assignee info from history ───────────────────────────────
//   // For AVAILABLE asset  → show last person who had it (latest assigned record)
//   // For ASSIGNED asset   → show who had it before current assignee (second latest)
//   String? _getPreviousAssignee(int assetId, String currentStatus) {
//     // All assign actions for this asset, newest first
//     final assignRecords = _ctrl.history
//         .where((h) =>
//             h.assetId == assetId &&
//             h.action.toLowerCase() == HistoryAction.assigned)
//         .toList()
//       ..sort((a, b) => b.actionDate.compareTo(a.actionDate));

//     if (assignRecords.isEmpty) return null;

//     if (currentStatus.toLowerCase() == AssetStatus.assigned) {
//       // Currently assigned — show second latest (previous holder)
//       return assignRecords.length >= 2 ? assignRecords[1].targetUserName : null;
//     } else {
//       // Available / maintenance / open — show latest (last holder)
//       return assignRecords.first.targetUserName;
//     }
//   }

//   // ── Dialog: Add Asset ─────────────────────────────────────────────────
//   void _showAddDialog() {
//     final nameCtrl   = TextEditingController();
//     final typeCtrl   = TextEditingController();
//     final codeCtrl   = TextEditingController();
//     final serialCtrl = TextEditingController();
//     final brandCtrl  = TextEditingController();
//     final modelCtrl  = TextEditingController();
//     final descCtrl   = TextEditingController();
//     final formKey    = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.add_box_rounded, AppTheme.primary),
//               const SizedBox(height: 16),
//               const Text('Add New Asset', style: AppTheme.headline2),
//               const SizedBox(height: 20),
//               _DialogField(ctrl: nameCtrl,   label: 'Asset Name',    hint: 'e.g. MacBook Pro'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: typeCtrl,   label: 'Asset Type',    hint: 'e.g. Laptop'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: codeCtrl,   label: 'Asset Code',    hint: 'e.g. LAP-001'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: serialCtrl, label: 'Serial Number', hint: 'e.g. SN123456'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: brandCtrl,  label: 'Brand',         hint: 'e.g. Apple'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: modelCtrl,  label: 'Model',         hint: 'e.g. M3 Pro'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: descCtrl,   label: 'Description',   hint: 'Optional notes', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.addAsset(
//                         assetName:    nameCtrl.text.trim(),
//                         assetType:    typeCtrl.text.trim(),
//                         assetCode:    codeCtrl.text.trim(),
//                         serialNumber: serialCtrl.text.trim(),
//                         brand:        brandCtrl.text.trim(),
//                         model:        modelCtrl.text.trim(),
//                         description:  descCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(dialogContext).pop(); WidgetsBinding.instance.addPostFrameCallback((_) => _goToAllAssets()); }
//                     },
//                     style: _btnStyle(AppTheme.primary),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Add Asset', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Assign ────────────────────────────────────────────────────
//   void _showAssignDialog(AssetModel asset) {
//     final noteCtrl       = TextEditingController();
//     final formKey        = GlobalKey<FormState>();
//     DateTime? returnDate;
//     final returnDateLabel = 'Select expected return date (optional)'.obs;
//     final selectedUser    = Rxn<_UserItem>();
//     final users           = <_UserItem>[].obs;
//     final isLoadingUsers  = true.obs;

//     _fetchUsers().then((list) {
//       users.assignAll(list);
//       isLoadingUsers.value = false;
//     });

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.assignment_ind_rounded, AppTheme.primary),
//               const SizedBox(height: 16),
//               const Text('Assign Asset', style: AppTheme.headline2),
//               const SizedBox(height: 6),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 20),
//               Obx(() {
//                 if (isLoadingUsers.value) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.divider),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       SizedBox(width: 16, height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
//                       SizedBox(width: 10),
//                       Text('Loading employees...',
//                           style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.textHint)),
//                     ]),
//                   );
//                 }
//                 if (users.isEmpty) {
//                   return Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.error.withOpacity(0.4)),
//                       borderRadius: BorderRadius.circular(14),
//                       color: AppTheme.errorLight,
//                     ),
//                     child: const Row(children: [
//                       Icon(Icons.warning_rounded, size: 16, color: AppTheme.error),
//                       SizedBox(width: 8),
//                       Text('Could not load employees',
//                           style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.error)),
//                     ]),
//                   );
//                 }

//                 // ─────────────────────────────────────────────────────────
//                 // FIX Issue 2: selectedItemBuilder prevents overflow when a
//                 // user is selected – the dropdown button only shows the name,
//                 // while the open list shows name + email.
//                 // ─────────────────────────────────────────────────────────
//                 return DropdownButtonFormField<_UserItem>(
//                   value: selectedUser.value,
//                   decoration: InputDecoration(
//                     labelText: 'Assign To',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//                     ),
//                     labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                   ),
//                   hint: const Text('Select employee',
//                       style: TextStyle(fontFamily: 'Poppins')),
//                   isExpanded: true,
//                   // Show only name when selected (no overflow)
//                   selectedItemBuilder: (ctx) => users.map((u) => Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       u.name,
//                       style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: AppTheme.textPrimary,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   )).toList(),
//                   validator: (v) => v == null ? 'Please select an employee' : null,
//                   items: users.map((u) => DropdownMenuItem(
//                     value: u,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(u.name,  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                         Text(u.email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.textHint)),
//                       ],
//                     ),
//                   )).toList(),
//                   onChanged: (v) => selectedUser.value = v,
//                   style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//                 );
//               }),
//               const SizedBox(height: 12),
//               Obx(() => GestureDetector(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now().add(const Duration(days: 7)),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                     builder: (ctx, child) => Theme(
//                       data: Theme.of(ctx).copyWith(
//                           colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
//                       child: child!,
//                     ),
//                   );
//                   if (picked != null) {
//                     returnDate = picked;
//                     returnDateLabel.value = DateFormat('dd MMMM yyyy').format(picked);
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: AppTheme.divider),
//                       borderRadius: BorderRadius.circular(14)),
//                   child: Row(children: [
//                     const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 18),
//                     const SizedBox(width: 10),
//                     Expanded(child: Text(
//                       returnDateLabel.value,
//                       style: TextStyle(
//                           fontFamily: 'Poppins', fontSize: 14,
//                           color: returnDate != null ? AppTheme.textPrimary : AppTheme.textHint),
//                     )),
//                     const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 18),
//                   ]),
//                 ),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: noteCtrl, label: 'Assignment Note', hint: 'Optional note', required: false, maxLines: 2),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.assignAsset(
//                         assetId:            asset.id,
//                         assignedToUserId:   selectedUser.value!.id,
//                         expectedReturnDate: returnDate,
//                         assignmentNote:     noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(dialogContext).pop(); WidgetsBinding.instance.addPostFrameCallback((_) => _goToAllAssets()); }
//                     },
//                     style: _btnStyle(AppTheme.primary),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Assign', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Return ────────────────────────────────────────────────────
//   void _showReturnDialog(AssetModel asset) {
//     final noteCtrl      = TextEditingController();
//     final conditionCtrl = TextEditingController();
//     final formKey       = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.assignment_return_rounded, AppTheme.success),
//               const SizedBox(height: 16),
//               const Text('Return Asset', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               if (asset.assignedToName != null)
//                 Text('Currently with: ${asset.assignedToName}', style: AppTheme.caption),
//               const SizedBox(height: 20),
//               _DialogField(ctrl: conditionCtrl, label: 'Return Condition', hint: 'e.g. Good / Fair / Damaged'),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: noteCtrl, label: 'Return Note', hint: 'e.g. Returned in good condition', required: false, maxLines: 2),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.returnAsset(
//                         assetId:         asset.id,
//                         returnNote:      noteCtrl.text.trim(),
//                         returnCondition: conditionCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(dialogContext).pop(); WidgetsBinding.instance.addPostFrameCallback((_) => _goToAllAssets()); }
//                     },
//                     style: _btnStyle(AppTheme.success),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Confirm Return', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Open Maintenance Request (Step 1) ─────────────────────────
//   void _showOpenMaintenanceDialog(AssetModel asset) {
//     final issueCtrl      = TextEditingController();
//     final formKey        = GlobalKey<FormState>();
//     final selectedType   = RxnString();
//     const typeOptions    = ['repair', 'preventive', 'corrective', 'service'];

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.pending_actions_rounded, AppTheme.warning),
//               const SizedBox(height: 16),
//               const Text('Open Maintenance Request', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.warning.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
//                 ),
//                 child: const Row(children: [
//                   Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warning),
//                   SizedBox(width: 8),
//                   Expanded(child: Text(
//                     'Request will be opened. Admin can start it later when ready.',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.warning),
//                   )),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedType.value,
//                 decoration: InputDecoration(
//                   labelText: 'Maintenance Type',
//                   prefixIcon: const Icon(Icons.build_circle_rounded),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: AppTheme.warning, width: 2),
//                   ),
//                   labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                 ),
//                 hint: const Text('Select type', style: TextStyle(fontFamily: 'Poppins')),
//                 isExpanded: true,
//                 validator: (v) => v == null ? 'Please select maintenance type' : null,
//                 items: typeOptions.map((t) => DropdownMenuItem(
//                   value: t,
//                   child: Text(t[0].toUpperCase() + t.substring(1),
//                       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//                 )).toList(),
//                 onChanged: (v) => selectedType.value = v,
//                 style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: issueCtrl, label: 'Issue Description', hint: 'Describe the problem...', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.openMaintenanceRequest(
//                         assetId:          asset.id,
//                         maintenanceType:  selectedType.value!,
//                         issueDescription: issueCtrl.text.trim().isEmpty ? null : issueCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(dialogContext).pop(); WidgetsBinding.instance.addPostFrameCallback((_) => _goToAllAssets()); }
//                     },
//                     style: _btnStyle(AppTheme.warning),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Open Request', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Start Maintenance (Step 2) ───────────────────────────────
//   void _showStartMaintenanceDialog(AssetModel asset) {
//     final vendorCtrl   = TextEditingController();
//     final issueCtrl    = TextEditingController();
//     final formKey      = GlobalKey<FormState>();
//     final selectedType = RxnString();
//     const typeOptions  = ['repair', 'preventive', 'corrective', 'service'];

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               _DialogIcon(Icons.build_rounded, AppTheme.error),
//               const SizedBox(height: 16),
//               const Text('Start Maintenance', style: AppTheme.headline2),
//               const SizedBox(height: 4),
//               Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.error.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: AppTheme.error.withOpacity(0.3)),
//                 ),
//                 child: const Row(children: [
//                   Icon(Icons.play_circle_outline_rounded, size: 14, color: AppTheme.error),
//                   SizedBox(width: 8),
//                   Expanded(child: Text(
//                     'Asset will be marked as "In Maintenance". It will not be available until completed.',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.error),
//                   )),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedType.value,
//                 decoration: InputDecoration(
//                   labelText: 'Maintenance Type',
//                   prefixIcon: const Icon(Icons.build_circle_rounded),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: AppTheme.error, width: 2),
//                   ),
//                   labelStyle: const TextStyle(fontFamily: 'Poppins'),
//                 ),
//                 hint: const Text('Select type', style: TextStyle(fontFamily: 'Poppins')),
//                 isExpanded: true,
//                 validator: (v) => v == null ? 'Please select maintenance type' : null,
//                 items: typeOptions.map((t) => DropdownMenuItem(
//                   value: t,
//                   child: Text(t[0].toUpperCase() + t.substring(1),
//                       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//                 )).toList(),
//                 onChanged: (v) => selectedType.value = v,
//                 style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textPrimary),
//               )),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: vendorCtrl, label: 'Vendor / Service Center', hint: 'e.g. Dell Service Center', required: false),
//               const SizedBox(height: 12),
//               _DialogField(ctrl: issueCtrl,  label: 'Additional Notes',        hint: 'Any additional info...', required: false, maxLines: 3),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(child: _CancelBtn()),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                     onPressed: _ctrl.isSubmitting.value ? null : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final ok = await _ctrl.startMaintenance(
//                         assetId:          asset.id,
//                         maintenanceType:  selectedType.value!,
//                         vendorName:       vendorCtrl.text.trim().isEmpty ? null : vendorCtrl.text.trim(),
//                         issueDescription: issueCtrl.text.trim().isEmpty  ? null : issueCtrl.text.trim(),
//                       );
//                       if (ok) { Navigator.of(dialogContext).pop(); WidgetsBinding.instance.addPostFrameCallback((_) => _goToAllAssets()); }
//                     },
//                     style: _btnStyle(AppTheme.error),
//                     child: _ctrl.isSubmitting.value
//                         ? const _LoadingIndicator()
//                         : const Text('Start Maintenance', style: _whiteBold),
//                   )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog: Complete Maintenance (Step 3) ─────────────────────────────
//   void _showCompleteMaintenanceDialog(AssetModel asset) {
//     final noteCtrl = TextEditingController();
//     final costCtrl = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             _DialogIcon(Icons.check_circle_rounded, AppTheme.success),
//             const SizedBox(height: 16),
//             const Text('Complete Maintenance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             Text(asset.assetName, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                   color: AppTheme.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8)),
//               child: const Text('In Maintenance',
//                   style: TextStyle(fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppTheme.error)),
//             ),
//             const SizedBox(height: 20),
//             _DialogField(ctrl: costCtrl, label: 'Cost (₹)', hint: 'e.g. 2500', required: false),
//             const SizedBox(height: 12),
//             _DialogField(ctrl: noteCtrl, label: 'Resolution Note', hint: 'What was fixed / replaced?', required: false, maxLines: 3),
//             const SizedBox(height: 24),
//             Row(children: [
//               Expanded(child: _CancelBtn()),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Obx(() => ElevatedButton(
//                   onPressed: _ctrl.isSubmitting.value ? null : () async {
//                     final ok = await _ctrl.completeMaintenance(
//                       assetId:        asset.id,
//                       cost:           costCtrl.text.trim().isEmpty ? null : double.tryParse(costCtrl.text.trim()),
//                       resolutionNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
//                     );
//                     if (ok) { Navigator.of(dialogContext).pop(); WidgetsBinding.instance.addPostFrameCallback((_) => _goToAllAssets()); }
//                   },
//                   style: _btnStyle(AppTheme.success),
//                   child: _ctrl.isSubmitting.value
//                       ? const _LoadingIndicator()
//                       : const Text('Mark Complete', style: _whiteBold),
//                 )),
//               ),
//             ]),
//           ]),
//         ),
//       ),
//     );
//   }

//   // ── Build ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddDialog,
//         backgroundColor: AppTheme.primary,
//         icon: const Icon(Icons.add_rounded, color: Colors.white),
//         label: const Text('Add Asset',
//             style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
//       ),
//       body: NestedScrollView(
//         headerSliverBuilder: (_, __) => [
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: AppTheme.cardBackground,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
//               onPressed: () => Get.back(),
//             ),
//             title: const Text('Asset Management',
//                 style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.textPrimary)),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 22),
//                 onPressed: () {
//                   switch (_tab.index) {
//                     case 0:
//                       _ctrl.fetchAssets(
//                         status:    _filterStatus?.toLowerCase(),
//                         assetType: _filterType?.toLowerCase(),
//                       );
//                       break;
//                     case 1:
//                       _ctrl.fetchHistory();
//                       break;
//                     case 2:
//                       _ctrl.fetchSummary();
//                       break;
//                   }
//                 },
//               ),
//             ],
//             bottom: TabBar(
//               controller: _tab,
//               labelColor: AppTheme.primary,
//               unselectedLabelColor: AppTheme.textSecondary,
//               indicatorColor: AppTheme.primary,
//               indicatorWeight: 3,
//               labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
//               unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
//               tabs: const [Tab(text: 'All Assets'), Tab(text: 'History'), Tab(text: 'Summary')],
//             ),
//           ),
//         ],
//         body: TabBarView(
//           controller: _tab,
//           children: [
//             // ── Tab 1: All Assets ──────────────────────────────────────
//             Column(children: [
//               Container(
//                 color: AppTheme.cardBackground,
//                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
//                 child: Row(children: [
//                   Expanded(child: _FilterDrop(
//                     value: _filterStatus, hint: 'All Status',
//                     items: AssetStatus.filterLabels,
//                     onChanged: (v) {
//                       setState(() => _filterStatus = v);
//                       _ctrl.fetchAssets(status: v?.toLowerCase(), assetType: _filterType?.toLowerCase());
//                     },
//                   )),
//                   const SizedBox(width: 10),
//                   Expanded(child: _FilterDrop(
//                     value: _filterType, hint: 'All Types',
//                     items: AssetTypeNames.filterLabels,
//                     onChanged: (v) {
//                       setState(() => _filterType = v);
//                       _ctrl.fetchAssets(status: _filterStatus?.toLowerCase(), assetType: v?.toLowerCase());
//                     },
//                   )),
//                   const SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() { _filterStatus = null; _filterType = null; });
//                       _ctrl.fetchAssets();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(10)),
//                       child: const Icon(Icons.filter_alt_off_rounded, color: AppTheme.error, size: 18),
//                     ),
//                   ),
//                 ]),
//               ),
//               Expanded(child: Obx(() {
//                 if (_ctrl.isLoading.value) {
//                   return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//                 }
//                 if (_ctrl.assets.isEmpty) {
//                   return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.07), shape: BoxShape.circle),
//                       child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 40),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text('No assets found',
//                         style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                     const SizedBox(height: 6),
//                     const Text('Try changing filters or add a new asset',
//                         style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary, fontSize: 12)),
//                   ]));
//                 }
//                 return RefreshIndicator(
//                   color: AppTheme.primary,
//                   onRefresh: () => _ctrl.fetchAssets(status: _filterStatus?.toLowerCase(), assetType: _filterType?.toLowerCase()),
//                   child: ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//                     itemCount: _ctrl.assets.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 10),
//                     itemBuilder: (_, i) {
//                       final a  = _ctrl.assets[i];
//                       final st = a.status.toLowerCase();

//                       // Issue 3: previous assignee history se nikalna
//                       final prevAssignee = _getPreviousAssignee(a.id, a.status);

//                       return GestureDetector(
//                         onTap: () => Get.to(() => AssetModelScreen(asset: a)),
//                         child: _AdminAssetCard(
//                           asset: a,
//                           previousAssignee: prevAssignee,
//                           onOpenMaintenance:     st == AssetStatus.available   ? () => _showOpenMaintenanceDialog(a)    : null,
//                           onStartMaintenance:    st == AssetStatus.open        ? () => _showStartMaintenanceDialog(a)   : null,
//                           onCompleteMaintenance: st == AssetStatus.maintenance ? () => _showCompleteMaintenanceDialog(a) : null,
//                           onAssign:              st == AssetStatus.available   ? () => _showAssignDialog(a)             : null,
//                           onReturn:              st == AssetStatus.assigned    ? () => _showReturnDialog(a)             : null,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               })),
//             ]),

//             // ── Tab 2: History (Grouped) ───────────────────────────────
//             Obx(() {
//               if (_ctrl.isHistoryLoading.value) {
//                 return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//               }
//               if (_ctrl.history.isEmpty) {
//                 return const Center(child: Text('No history available',
//                     style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)));
//               }

//               // Issue 1: Group related history entries
//               final groups = _groupHistories(_ctrl.history);

//               return RefreshIndicator(
//                 color: AppTheme.primary,
//                 onRefresh: () => _ctrl.fetchHistory(),
//                 child: ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: groups.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 10),
//                   itemBuilder: (_, i) => _GroupedHistoryCard(group: groups[i]),
//                 ),
//               );
//             }),

//             // ── Tab 3: Summary ─────────────────────────────────────────
//             Obx(() {
//               if (_ctrl.isSummaryLoading.value) {
//                 return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
//               }
//               final s = _ctrl.summary.value;
//               if (s == null) {
//                 return const Center(child: Text('No summary available',
//                     style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)));
//               }
//               return RefreshIndicator(
//                 color: AppTheme.primary,
//                 onRefresh: () => _ctrl.fetchSummary(),
//                 child: ListView(padding: const EdgeInsets.all(18), children: [
//                   const SizedBox(height: 8),
//                   Row(children: [
//                     Expanded(child: _SummaryCard(label: 'Total',     value: s.total.toString(),            icon: Icons.inventory_2_rounded,     color: AppTheme.primary)),
//                     const SizedBox(width: 12),
//                     Expanded(child: _SummaryCard(label: 'Available', value: s.available.toString(),        icon: Icons.check_circle_rounded,    color: AppTheme.success)),
//                   ]),
//                   const SizedBox(height: 12),
//                   Row(children: [
//                     Expanded(child: _SummaryCard(label: 'Assigned',    value: s.assigned.toString(),         icon: Icons.person_rounded, color: AssetColors.indigo)),
//                     const SizedBox(width: 12),
//                     Expanded(child: _SummaryCard(label: 'In Maint.',   value: (s.total - s.available - s.assigned).clamp(0, s.total).toString(), icon: Icons.build_rounded, color: AppTheme.error)),
//                   ]),
//                   const SizedBox(height: 22),
//                   if (s.total > 0) Container(
//                     decoration: AppTheme.cardDecoration(),
//                     padding: const EdgeInsets.all(18),
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       const Text('Asset Distribution',
//                           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//                       const SizedBox(height: 18),
//                       _ProgressBar(label: 'Available',    value: s.total > 0 ? s.available / s.total : 0,   color: AppTheme.success,   count: s.available, total: s.total),
//                       const SizedBox(height: 14),
//                       _ProgressBar(label: 'Assigned',     value: s.total > 0 ? s.assigned / s.total : 0,    color: AssetColors.indigo, count: s.assigned,  total: s.total),
//                       const SizedBox(height: 14),
//                       _ProgressBar(label: 'In Maint.',    value: s.total > 0 ? (s.total - s.available - s.assigned).clamp(0, s.total) / s.total : 0, color: AppTheme.error, count: (s.total - s.available - s.assigned).clamp(0, s.total), total: s.total),
//                     ]),
//                   ),
//                 ]),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN ASSET CARD  (Issue 3: previousAssignee added)
// // ─────────────────────────────────────────────
// class _AdminAssetCard extends StatelessWidget {
//   final AssetModel    asset;
//   final String?       previousAssignee;   // Issue 3
//   final VoidCallback? onAssign;
//   final VoidCallback? onReturn;
//   final VoidCallback? onOpenMaintenance;
//   final VoidCallback? onStartMaintenance;
//   final VoidCallback? onCompleteMaintenance;

//   const _AdminAssetCard({
//     required this.asset,
//     this.previousAssignee,
//     this.onAssign,
//     this.onReturn,
//     this.onOpenMaintenance,
//     this.onStartMaintenance,
//     this.onCompleteMaintenance,
//   });

//   bool get _hasActions =>
//       onAssign != null || onReturn != null ||
//       onOpenMaintenance != null || onStartMaintenance != null ||
//       onCompleteMaintenance != null;

//   @override
//   Widget build(BuildContext context) {
//     final sc = AssetModel.statusColor(asset.status);
//     final si = AssetModel.statusIcon(asset.status);
//     final tc = AssetModel.typeColor(asset.assetType);
//     final ti = AssetModel.typeIcon(asset.assetType);

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(14),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 48, height: 48,
//             decoration: BoxDecoration(color: tc.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//             child: Icon(ti, color: tc, size: 24),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(asset.assetName,
//                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//             const SizedBox(height: 2),
//             Text('${asset.assetCodeSafe}  ·  ${asset.assetType}', style: AppTheme.caption),
//           ])),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(si, size: 10, color: sc),
//               const SizedBox(width: 4),
//               Text(AssetModel.statusLabel(asset.status),
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: sc)),
//             ]),
//           ),
//         ]),

//         // Current assignee
//         if (asset.assignedToName != null) ...[
//           const SizedBox(height: 8),
//           Row(children: [
//             const Icon(Icons.person_rounded, size: 13, color: AppTheme.primary),
//             const SizedBox(width: 4),
//             Text('Assigned to: ${asset.assignedToName}',
//                 style: const TextStyle(fontSize: 11, fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w600, color: AppTheme.primary)),
//           ]),
//         ],

//         // Issue 3: Previous assignee
//         if (previousAssignee != null) ...[
//           const SizedBox(height: 4),
//           Row(children: [
//             Icon(
//               asset.status.toLowerCase() == AssetStatus.assigned
//                   ? Icons.swap_horiz_rounded
//                   : Icons.person_off_rounded,
//               size: 13, color: AppTheme.textHint,
//             ),
//             const SizedBox(width: 4),
//             Text(
//               asset.status.toLowerCase() == AssetStatus.assigned
//                   ? 'Previously: $previousAssignee'
//                   : 'Last with: $previousAssignee',
//               style: const TextStyle(
//                   fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint),
//             ),
//           ]),
//         ],

//         const SizedBox(height: 8),
//         Row(children: [
//           const Icon(Icons.touch_app_rounded, size: 12, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           const Text('Tap to view details',
//               style: TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint)),
//           const Spacer(),
//           if (asset.brand?.isNotEmpty ?? false)
//             Text('${asset.brand} · ${asset.model}', style: AppTheme.caption),
//         ]),
//         if (_hasActions) ...[
//           const SizedBox(height: 10),
//           const Divider(height: 1, color: AppTheme.divider),
//           const SizedBox(height: 10),
//           Wrap(spacing: 8, runSpacing: 8, children: [
//             if (onAssign != null)
//               _ActionBtn(label: 'Assign',        icon: Icons.assignment_ind_rounded,    color: AppTheme.primary, onTap: onAssign!),
//             if (onOpenMaintenance != null)
//               _ActionBtn(label: 'Open Request',  icon: Icons.pending_actions_rounded,   color: AppTheme.warning, onTap: onOpenMaintenance!),
//             if (onStartMaintenance != null)
//               _ActionBtn(label: 'Start Maint.',  icon: Icons.build_circle_rounded,      color: AppTheme.error,   onTap: onStartMaintenance!),
//             if (onReturn != null)
//               _ActionBtn(label: 'Return',        icon: Icons.assignment_return_rounded, color: AppTheme.success, onTap: onReturn!),
//             if (onCompleteMaintenance != null)
//               _ActionBtn(label: 'Mark Done',     icon: Icons.check_circle_rounded,      color: AppTheme.success, onTap: onCompleteMaintenance!),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  GROUPED HISTORY CARD  (Issue 1)
// //  Shows a single card per workflow with a
// //  timeline of all steps inside.
// // ─────────────────────────────────────────────
// class _GroupedHistoryCard extends StatelessWidget {
//   final _WorkflowGroup group;
//   const _GroupedHistoryCard({required this.group});

//   static Map<String, dynamic>? _parseNoteJson(String? note) {
//     if (note == null || note.isEmpty) return null;
//     try {
//       final decoded = jsonDecode(note);
//       if (decoded is Map<String, dynamic>) return decoded;
//     } catch (_) {}
//     return null;
//   }

//   // Issue 4: proper UTC → local conversion
//   static String _fmtLocal(DateTime dt) {
//     final local = dt.toLocal();
//     return '${DateFormat('dd MMM yyyy').format(local)}  ·  ${DateFormat('hh:mm a').format(local)}';
//   }

//   static String _fmtIsoLocal(String? iso) {
//     if (iso == null || iso.isEmpty) return '';
//     try {
//       final normalized = (iso.endsWith('Z') || iso.contains('+')) ? iso : '${iso}Z';
//       final dt = DateTime.tryParse(normalized)?.toLocal();
//       if (dt == null) return iso;
//       return '${DateFormat('dd MMM yyyy').format(dt)}  ·  ${DateFormat('hh:mm a').format(dt)}';
//     } catch (_) { return iso; }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final latest   = group.latest;
//     final color    = AssetHistoryModel.actionColor(latest.action);
//     final icon     = AssetHistoryModel.actionIcon(latest.action);
//     final label    = AssetHistoryModel.actionLabel(latest.action);

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(14),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // ── Header ──────────────────────────────────────────────────────
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 44, height: 44,
//             decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(child: Text(
//                 latest.assetNameSafe,
//                 style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary),
//                 maxLines: 1, overflow: TextOverflow.ellipsis,
//               )),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
//                 child: Text(label,
//                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//               ),
//             ]),
//             const SizedBox(height: 3),
//             Row(children: [
//               const Icon(Icons.access_time_rounded, size: 11, color: AppTheme.textHint),
//               const SizedBox(width: 3),
//               Text(_fmtLocal(latest.actionDate.toLocal()),   // Issue 4 fix
//                   style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', color: AppTheme.textHint)),
//             ]),
//           ])),
//         ]),

//         // ── Timeline of all steps ────────────────────────────────────────
//         if (group.steps.length > 1) ...[
//           const SizedBox(height: 12),
//           const Divider(height: 1, color: AppTheme.divider),
//           const SizedBox(height: 10),
//           ...group.steps.asMap().entries.map((e) {
//             final idx   = e.key;
//             final step  = e.value;
//             final sc    = AssetHistoryModel.actionColor(step.action);
//             final si    = AssetHistoryModel.actionIcon(step.action);
//             final sl    = AssetHistoryModel.actionLabel(step.action);
//             final isLast = idx == group.steps.length - 1;
//             return _TimelineStep(
//               icon: si, color: sc, label: sl,
//               isLast: isLast,
//               content: _buildStepContent(step, sc),
//             );
//           }),
//         ] else ...[
//           // Single step – show details inline
//           const SizedBox(height: 8),
//           ..._buildStepContent(group.first, color),
//         ],
//       ]),
//     );
//   }

//   List<Widget> _buildStepContent(AssetHistoryModel step, Color color) {
//     final noteJson = _parseNoteJson(step.note);
//     final widgets  = <Widget>[];

//     // Issue 5: Who performed the action (Add, Assign, Return, etc.)
//     if (step.performedByName != null && step.performedByName!.isNotEmpty) {
//       widgets.add(_HistoryDetail(
//         icon: Icons.manage_accounts_rounded, color: color,
//         label: step.action.toLowerCase() == HistoryAction.added ? 'Added by' : 'By',
//         value: step.performedByName!,
//       ));
//     }

//     // To / From
//     if (step.targetUserName != null) {
//       final lbl = step.action.toLowerCase() == HistoryAction.returned ? 'Returned from' : 'Assigned to';
//       widgets.add(_HistoryDetail(
//         icon: Icons.person_rounded, color: AppTheme.textSecondary,
//         label: lbl, value: step.targetUserName!,
//       ));
//     }

//     if (noteJson != null) {
//       if ((noteJson['type'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.build_circle_rounded, color: color, label: 'Type', value: noteJson['type'].toString()));
//       if ((noteJson['vendor'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.store_rounded, color: AppTheme.textSecondary, label: 'Vendor', value: noteJson['vendor'].toString()));
//       if ((noteJson['issue'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.warning_amber_rounded, color: AppTheme.warning, label: 'Issue', value: noteJson['issue'].toString()));
//       if ((noteJson['resolution'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.check_circle_outline_rounded, color: AppTheme.success, label: 'Resolution', value: noteJson['resolution'].toString()));
//       if (noteJson['cost'] != null)
//         widgets.add(_HistoryDetail(icon: Icons.currency_rupee_rounded, color: AppTheme.textSecondary, label: 'Cost', value: '₹${noteJson['cost']}'));
//       // Issue 4: Return condition
//       if ((noteJson['condition'] ?? '').toString().isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.verified_outlined, color: AppTheme.success, label: 'Condition', value: noteJson['condition'].toString()));
//       if (noteJson['startedAt'] != null)
//         widgets.add(_HistoryDetail(icon: Icons.play_circle_outline_rounded, color: AppTheme.error, label: 'Started', value: _fmtIsoLocal(noteJson['startedAt'].toString())));
//       if (noteJson['completedAt'] != null)
//         widgets.add(_HistoryDetail(icon: Icons.task_alt_rounded, color: AppTheme.success, label: 'Completed', value: _fmtIsoLocal(noteJson['completedAt'].toString())));
//     } else {
//       // Issue 4: plain return condition (if backend stores it separately)
//       if (step.condition != null && step.condition!.isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.verified_outlined, color: AppTheme.success, label: 'Condition', value: step.condition!));
//       if (step.note != null && step.note!.isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.notes_rounded, color: AppTheme.textSecondary, label: 'Note', value: step.note!));
//       if (step.maintenanceType != null && step.maintenanceType!.isNotEmpty)
//         widgets.add(_HistoryDetail(icon: Icons.build_circle_rounded, color: color, label: 'Type', value: step.maintenanceType!));
//     }

//     return widgets;
//   }
// }

// // ─────────────────────────────────────────────
// //  TIMELINE STEP  (used inside grouped card)
// // ─────────────────────────────────────────────
// class _TimelineStep extends StatelessWidget {
//   final IconData     icon;
//   final Color        color;
//   final String       label;
//   final bool         isLast;
//   final List<Widget> content;

//   const _TimelineStep({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.isLast,
//     required this.content,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicHeight(
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Vertical line + dot
//         SizedBox(width: 28, child: Column(children: [
//           Container(
//             width: 24, height: 24,
//             decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
//             child: Icon(icon, size: 13, color: color),
//           ),
//           if (!isLast)
//             Expanded(child: Container(width: 2, color: AppTheme.divider, margin: const EdgeInsets.symmetric(vertical: 2))),
//         ])),
//         const SizedBox(width: 10),
//         Expanded(child: Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//               decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
//               child: Text(label,
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//             ),
//             const SizedBox(height: 4),
//             ...content,
//           ]),
//         )),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ACTION BUTTON
// // ─────────────────────────────────────────────
// class _ActionBtn extends StatelessWidget {
//   final String label; final IconData icon; final Color color; final VoidCallback onTap;
//   const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});
//   @override
//   Widget build(BuildContext context) => OutlinedButton.icon(
//     onPressed: onTap, icon: Icon(icon, size: 13), label: Text(label),
//     style: OutlinedButton.styleFrom(
//       foregroundColor: color,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       side: BorderSide(color: color),
//       textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
//     ),
//   );
// }

// // ─────────────────────────────────────────────
// //  HISTORY DETAIL ROW
// // ─────────────────────────────────────────────
// class _HistoryDetail extends StatelessWidget {
//   final IconData icon; final Color color; final String label, value;
//   const _HistoryDetail({required this.icon, required this.color, required this.label, required this.value});
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Icon(icon, size: 12, color: color),
//       const SizedBox(width: 5),
//       Text('$label: ', style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint, fontWeight: FontWeight.w600)),
//       Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textSecondary))),
//     ]),
//   );
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────
// class _DialogIcon extends StatelessWidget {
//   final IconData icon; final Color color;
//   const _DialogIcon(this.icon, this.color);
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
//     child: Icon(icon, color: color, size: 32),
//   );
// }

// class _DialogField extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String label, hint;
//   final bool   required;
//   final int    maxLines;
//   const _DialogField({required this.ctrl, required this.label, required this.hint, this.required = true, this.maxLines = 1});
//   @override
//   Widget build(BuildContext context) => TextFormField(
//     controller: ctrl, maxLines: maxLines,
//     decoration: InputDecoration(
//       labelText: label, hintText: hint,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
//       labelStyle: const TextStyle(fontFamily: 'Poppins'),
//       hintStyle:  const TextStyle(fontFamily: 'Poppins', color: AppTheme.textHint),
//     ),
//     style: const TextStyle(fontFamily: 'Poppins'),
//     validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
//   );
// }

// class _FilterDrop extends StatelessWidget {
//   final String? value; final String hint; final List<String> items;
//   final void Function(String?) onChanged;
//   const _FilterDrop({required this.value, required this.hint, required this.items, required this.onChanged});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//     decoration: BoxDecoration(
//         border: Border.all(color: AppTheme.divider),
//         borderRadius: BorderRadius.circular(10),
//         color: AppTheme.background),
//     child: DropdownButtonHideUnderline(child: DropdownButton<String>(
//       value: value, isExpanded: true,
//       hint: Text(hint, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textHint)),
//       icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.textSecondary),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.textPrimary),
//       items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//       onChanged: onChanged,
//     )),
//   );
// }

// class _SummaryCard extends StatelessWidget {
//   final String label, value; final IconData icon; final Color color;
//   const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(16), decoration: AppTheme.cardDecoration(),
//     child: Column(children: [
//       Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
//         child: Icon(icon, color: color, size: 24),
//       ),
//       const SizedBox(height: 12),
//       Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: color)),
//       const SizedBox(height: 4),
//       Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
//     ]),
//   );
// }

// class _ProgressBar extends StatelessWidget {
//   final String label; final double value; final Color color; final int count, total;
//   const _ProgressBar({required this.label, required this.value, required this.color, required this.count, required this.total});
//   @override
//   Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
//       Text('$count / $total  (${(value * 100).toInt()}%)',
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
//     ]),
//     const SizedBox(height: 7),
//     ClipRRect(borderRadius: BorderRadius.circular(6),
//       child: LinearProgressIndicator(
//         value: value, minHeight: 9,
//         backgroundColor: color.withOpacity(0.1),
//         valueColor: AlwaysStoppedAnimation<Color>(color),
//       )),
//   ]);
// }

// class _CancelBtn extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => OutlinedButton(
//     onPressed: () => Get.back(),
//     style: OutlinedButton.styleFrom(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       side: const BorderSide(color: AppTheme.divider),
//     ),
//     child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//   );
// }

// class _LoadingIndicator extends StatelessWidget {
//   const _LoadingIndicator();
//   @override
//   Widget build(BuildContext context) =>
//       const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
// }

















// lib/screens/asset/asset_admin_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../controllers/asset_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset_model_screen.dart';
import '../../services/storage_service.dart';

// ─────────────────────────────────────────────
//  USER ITEM  (for assign dropdown)
// ─────────────────────────────────────────────
class _UserItem {
  final int    id;
  final String name;
  final String email;
  const _UserItem({required this.id, required this.name, required this.email});

  factory _UserItem.fromJson(Map<String, dynamic> j) => _UserItem(
        id:    j['userId']   ?? j['id']   ?? 0,
        name:  j['userName'] ?? j['name'] ?? '',
        email: j['email']    ?? '',
      );
}

// ─────────────────────────────────────────────
//  WORKFLOW GROUP
// ─────────────────────────────────────────────
class _WorkflowGroup {
  final List<AssetHistoryModel> steps;
  _WorkflowGroup(this.steps);

  AssetHistoryModel get latest => steps.last;
  AssetHistoryModel get first  => steps.first;

  bool get isMaintenanceFlow {
    final a = first.action.toLowerCase();
    return a == HistoryAction.maintenanceOpen   ||
           a == HistoryAction.maintenance          ||
           a == HistoryAction.maintenanceStarted   ||
           a == HistoryAction.inProgress           ||
           a == HistoryAction.maintenanceCompleted ||
           a == HistoryAction.completed;
  }

  bool get isAssignFlow {
    final a = first.action.toLowerCase();
    return a == HistoryAction.assigned || a == HistoryAction.returned;
  }
}

List<_WorkflowGroup> _groupHistories(List<AssetHistoryModel> history) {
  final sorted = [...history]..sort((a, b) => a.actionDate.compareTo(b.actionDate));
  final List<_WorkflowGroup> groups = [];

  for (final entry in sorted) {
    final action = entry.action.toLowerCase();

    if (action == HistoryAction.maintenanceStarted ||
        action == HistoryAction.maintenanceCompleted) {
      final idx = groups.lastIndexWhere((g) =>
          g.isMaintenanceFlow &&
          g.latest.assetId == entry.assetId &&
          g.latest.action.toLowerCase() != HistoryAction.maintenanceCompleted &&
          g.latest.action.toLowerCase() != HistoryAction.completed);
      if (idx != -1) { groups[idx].steps.add(entry); continue; }
    }

    if (action == HistoryAction.returned) {
      final idx = groups.lastIndexWhere((g) =>
          g.isAssignFlow &&
          g.latest.assetId == entry.assetId &&
          g.latest.action.toLowerCase() != HistoryAction.returned);
      if (idx != -1) { groups[idx].steps.add(entry); continue; }
    }

    groups.add(_WorkflowGroup([entry]));
  }

  return groups.reversed.toList();
}

// ─────────────────────────────────────────────
//  SHARED STYLE HELPERS
// ─────────────────────────────────────────────
const _whiteBold = TextStyle(
  fontFamily: 'Poppins',
  color: Colors.white,
  fontWeight: FontWeight.w600,
);

ButtonStyle _btnStyle(Color c) => ElevatedButton.styleFrom(
      backgroundColor: c,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    );

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class AssetAdminScreen extends StatefulWidget {
  const AssetAdminScreen({super.key});

  @override
  State<AssetAdminScreen> createState() => _AssetAdminScreenState();
}

class _AssetAdminScreenState extends State<AssetAdminScreen>
    with SingleTickerProviderStateMixin {
  late final AssetController _ctrl;
  late final TabController    _tab;

  // ── Asset list filters ──────────────────────────────────────────────
  String? _filterStatus;
  String? _filterType;

  // ── History date filters ────────────────────────────────────────────
  final _historyFromDate    = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final _historyToDate      = DateTime.now().obs;
  final _hasHistorySearched = false.obs;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    if (!Get.isRegistered<AssetController>()) Get.put(AssetController());
    _ctrl = Get.find<AssetController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchAssets();
      _ctrl.fetchSummary();
      _ctrl.fetchHistory();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _goToAllAssets() {
    _tab.animateTo(0);
    _ctrl.fetchAssets(
      status:    _filterStatus?.toLowerCase(),
      assetType: _filterType?.toLowerCase(),
    );
    _ctrl.fetchSummary();
    _ctrl.fetchHistory();
  }

  // ── History date pickers ────────────────────────────────────────────
  Future<void> _pickHistoryFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _historyFromDate.value,
      firstDate: DateTime(2020),
      lastDate: _historyToDate.value,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) _historyFromDate.value = picked;
  }

  Future<void> _pickHistoryToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _historyToDate.value,
      firstDate: _historyFromDate.value,
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) _historyToDate.value = picked;
  }

  // ── Fetch users ─────────────────────────────────────────────────────
  Future<List<_UserItem>> _fetchUsers() async {
    try {
      final token   = StorageService.getToken();
      final headers = {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      };

      final endpoints = [
        '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.getAllUsersEndpoint}',
        '${AppConstants.baseUrl}${AppConstants.apiVersion}${AppConstants.profileAllEndpoint}',
      ];

      for (final url in endpoints) {
        debugPrint('fetchUsers trying: $url');
        try {
          final res = await http
              .get(Uri.parse(url), headers: headers)
              .timeout(Duration(milliseconds: AppConstants.connectTimeout));

          debugPrint('fetchUsers status: ${res.statusCode}');
          debugPrint('fetchUsers body: ${res.body.substring(0, res.body.length.clamp(0, 400))}');

          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            List<dynamic>? list;
            if (data is List)                      { list = data; }
            else if (data['data']      is List)    { list = data['data']; }
            else if (data['users']     is List)    { list = data['users']; }
            else if (data['result']    is List)    { list = data['result']; }
            else if (data['employees'] is List)    { list = data['employees']; }
            else if (data['profiles']  is List)    { list = data['profiles']; }

            if (list != null && list.isNotEmpty) {
              debugPrint('fetchUsers: ${list.length} users loaded from $url');
              return list.map((e) {
                final m = e as Map<String, dynamic>;
                return _UserItem(
                  id:    m['userId']   ?? m['id']        ?? m['profileId'] ?? 0,
                  name:  m['userName'] ?? m['name']      ?? m['fullName']  ?? m['displayName'] ?? '',
                  email: m['email']    ?? m['userEmail'] ?? '',
                );
              }).where((u) => u.name.isNotEmpty).toList();
            }
            debugPrint('fetchUsers: unknown structure keys: ${data is Map ? data.keys.toList() : "list"}');
          } else {
            debugPrint('fetchUsers failed ${res.statusCode} from $url — ${res.body}');
          }
        } catch (inner) {
          debugPrint('fetchUsers error on $url: $inner');
        }
      }
    } catch (e, stack) {
      debugPrint('fetchUsers exception: $e\n$stack');
    }
    return [];
  }

  // ── Previous assignee from history ──────────────────────────────────
  String? _getPreviousAssignee(int assetId, String currentStatus) {
    final assignRecords = _ctrl.history
        .where((h) =>
            h.assetId == assetId &&
            h.action.toLowerCase() == HistoryAction.assigned)
        .toList()
      ..sort((a, b) => b.actionDate.compareTo(a.actionDate));

    if (assignRecords.isEmpty) return null;

    if (currentStatus.toLowerCase() == AssetStatus.assigned) {
      return assignRecords.length >= 2 ? assignRecords[1].targetUserName : null;
    } else {
      return assignRecords.first.targetUserName;
    }
  }

  // ── Dialog: Add Asset ────────────────────────────────────────────────
  void _showAddDialog() {
    final nameCtrl   = TextEditingController();
    final typeCtrl   = TextEditingController();
    final codeCtrl   = TextEditingController();
    final serialCtrl = TextEditingController();
    final brandCtrl  = TextEditingController();
    final modelCtrl  = TextEditingController();
    final descCtrl   = TextEditingController();
    final formKey    = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogIcon(Icons.add_box_rounded, AppTheme.primary),
              const SizedBox(height: 16),
              const Text('Add New Asset', style: AppTheme.headline2),
              const SizedBox(height: 20),
              _DialogField(ctrl: nameCtrl,   label: 'Asset Name',    hint: 'e.g. MacBook Pro'),
              const SizedBox(height: 12),
              _DialogField(ctrl: typeCtrl,   label: 'Asset Type',    hint: 'e.g. Laptop'),
              const SizedBox(height: 12),
              _DialogField(ctrl: codeCtrl,   label: 'Asset Code',    hint: 'e.g. LAP-001'),
              const SizedBox(height: 12),
              _DialogField(ctrl: serialCtrl, label: 'Serial Number', hint: 'e.g. SN123456'),
              const SizedBox(height: 12),
              _DialogField(ctrl: brandCtrl,  label: 'Brand',         hint: 'e.g. Apple'),
              const SizedBox(height: 12),
              _DialogField(ctrl: modelCtrl,  label: 'Model',         hint: 'e.g. M3 Pro'),
              const SizedBox(height: 12),
              _DialogField(ctrl: descCtrl,   label: 'Description',   hint: 'Optional notes', required: false, maxLines: 3),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CancelBtn()),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value ? null : () async {
                      if (!formKey.currentState!.validate()) return;
                      final ok = await _ctrl.addAsset(
                        assetName:    nameCtrl.text.trim(),
                        assetType:    typeCtrl.text.trim(),
                        assetCode:    codeCtrl.text.trim(),
                        serialNumber: serialCtrl.text.trim(),
                        brand:        brandCtrl.text.trim(),
                        model:        modelCtrl.text.trim(),
                        description:  descCtrl.text.trim(),
                      );
                      if (ok) {
                        Navigator.of(dialogContext).pop();
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _goToAllAssets());
                      }
                    },
                    style: _btnStyle(AppTheme.primary),
                    child: _ctrl.isSubmitting.value
                        ? const _LoadingIndicator()
                        : const Text('Add Asset', style: _whiteBold),
                  )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Dialog: Assign ───────────────────────────────────────────────────
  void _showAssignDialog(AssetModel asset) {
    final noteCtrl        = TextEditingController();
    final formKey         = GlobalKey<FormState>();
    DateTime? returnDate;
    final returnDateLabel = 'Select expected return date (optional)'.obs;
    final selectedUser    = Rxn<_UserItem>();
    final users           = <_UserItem>[].obs;
    final isLoadingUsers  = true.obs;

    _fetchUsers().then((list) {
      users.assignAll(list);
      isLoadingUsers.value = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogIcon(Icons.assignment_ind_rounded, AppTheme.primary),
              const SizedBox(height: 16),
              const Text('Assign Asset', style: AppTheme.headline2),
              const SizedBox(height: 6),
              Text(asset.assetName,
                  style: AppTheme.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Obx(() {
                if (isLoadingUsers.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary)),
                          SizedBox(width: 10),
                          Text('Loading employees...',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppTheme.textHint)),
                        ]),
                  );
                }
                if (users.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.error.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(14),
                      color: AppTheme.errorLight,
                    ),
                    child: const Row(children: [
                      Icon(Icons.warning_rounded,
                          size: 16, color: AppTheme.error),
                      SizedBox(width: 8),
                      Text('Could not load employees',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppTheme.error)),
                    ]),
                  );
                }
                return DropdownButtonFormField<_UserItem>(
                  value: selectedUser.value,
                  decoration: InputDecoration(
                    labelText: 'Assign To',
                    prefixIcon:
                        const Icon(Icons.person_search_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppTheme.primary, width: 2),
                    ),
                    labelStyle:
                        const TextStyle(fontFamily: 'Poppins'),
                  ),
                  hint: const Text('Select employee',
                      style: TextStyle(fontFamily: 'Poppins')),
                  isExpanded: true,
                  selectedItemBuilder: (ctx) =>
                      users
                          .map((u) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  u.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ))
                          .toList(),
                  validator: (v) =>
                      v == null ? 'Please select an employee' : null,
                  items: users
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(u.name,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary)),
                                Text(u.email,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: AppTheme.textHint)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => selectedUser.value = v,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.textPrimary),
                );
              }),
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now()
                            .add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: AppTheme.primary)),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        returnDate = picked;
                        returnDateLabel.value =
                            DateFormat('dd MMMM yyyy').format(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppTheme.divider),
                          borderRadius:
                              BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppTheme.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(
                          returnDateLabel.value,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: returnDate != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textHint),
                        )),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textHint, size: 18),
                      ]),
                    ),
                  )),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: noteCtrl,
                  label: 'Assignment Note',
                  hint: 'Optional note',
                  required: false,
                  maxLines: 2),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CancelBtn()),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value
                        ? null
                        : () async {
                            if (!formKey.currentState!
                                .validate()) return;
                            final ok = await _ctrl.assignAsset(
                              assetId: asset.id,
                              assignedToUserId:
                                  selectedUser.value!.id,
                              expectedReturnDate: returnDate,
                              assignmentNote: noteCtrl.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : noteCtrl.text.trim(),
                            );
                            if (ok) {
                              Navigator.of(dialogContext).pop();
                              WidgetsBinding.instance
                                  .addPostFrameCallback(
                                      (_) => _goToAllAssets());
                            }
                          },
                    style: _btnStyle(AppTheme.primary),
                    child: _ctrl.isSubmitting.value
                        ? const _LoadingIndicator()
                        : const Text('Assign', style: _whiteBold),
                  )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Dialog: Return ───────────────────────────────────────────────────
  void _showReturnDialog(AssetModel asset) {
    final noteCtrl      = TextEditingController();
    final conditionCtrl = TextEditingController();
    final formKey       = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogIcon(Icons.assignment_return_rounded,
                  AppTheme.success),
              const SizedBox(height: 16),
              const Text('Return Asset', style: AppTheme.headline2),
              const SizedBox(height: 4),
              Text(asset.assetName,
                  style: AppTheme.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              if (asset.assignedToName != null)
                Text('Currently with: ${asset.assignedToName}',
                    style: AppTheme.caption),
              const SizedBox(height: 20),
              _DialogField(
                  ctrl: conditionCtrl,
                  label: 'Return Condition',
                  hint: 'e.g. Good / Fair / Damaged'),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: noteCtrl,
                  label: 'Return Note',
                  hint: 'e.g. Returned in good condition',
                  required: false,
                  maxLines: 2),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CancelBtn()),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value
                        ? null
                        : () async {
                            if (!formKey.currentState!
                                .validate()) return;
                            final ok = await _ctrl.returnAsset(
                              assetId: asset.id,
                              returnNote: noteCtrl.text.trim(),
                              returnCondition:
                                  conditionCtrl.text.trim(),
                            );
                            if (ok) {
                              Navigator.of(dialogContext).pop();
                              WidgetsBinding.instance
                                  .addPostFrameCallback(
                                      (_) => _goToAllAssets());
                            }
                          },
                    style: _btnStyle(AppTheme.success),
                    child: _ctrl.isSubmitting.value
                        ? const _LoadingIndicator()
                        : const Text('Confirm Return',
                            style: _whiteBold),
                  )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Dialog: Open Maintenance Request ────────────────────────────────
  void _showOpenMaintenanceDialog(AssetModel asset) {
    final issueCtrl    = TextEditingController();
    final formKey      = GlobalKey<FormState>();
    final selectedType = RxnString();
    const typeOptions  = ['repair', 'preventive', 'corrective', 'service'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogIcon(Icons.pending_actions_rounded,
                  AppTheme.warning),
              const SizedBox(height: 16),
              const Text('Open Maintenance Request',
                  style: AppTheme.headline2),
              const SizedBox(height: 4),
              Text(asset.assetName,
                  style: AppTheme.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppTheme.warning),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    'Request will be opened. Admin can start it later when ready.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppTheme.warning),
                  )),
                ]),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: selectedType.value,
                    decoration: InputDecoration(
                      labelText: 'Maintenance Type',
                      prefixIcon:
                          const Icon(Icons.build_circle_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppTheme.warning, width: 2),
                      ),
                      labelStyle:
                          const TextStyle(fontFamily: 'Poppins'),
                    ),
                    hint: const Text('Select type',
                        style: TextStyle(fontFamily: 'Poppins')),
                    isExpanded: true,
                    validator: (v) => v == null
                        ? 'Please select maintenance type'
                        : null,
                    items: typeOptions
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                  t[0].toUpperCase() + t.substring(1),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) => selectedType.value = v,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppTheme.textPrimary),
                  )),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: issueCtrl,
                  label: 'Issue Description',
                  hint: 'Describe the problem...',
                  required: false,
                  maxLines: 3),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CancelBtn()),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value
                        ? null
                        : () async {
                            if (!formKey.currentState!
                                .validate()) return;
                            final ok =
                                await _ctrl.openMaintenanceRequest(
                              assetId: asset.id,
                              maintenanceType:
                                  selectedType.value!,
                              issueDescription: issueCtrl.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : issueCtrl.text.trim(),
                            );
                            if (ok) {
                              Navigator.of(dialogContext).pop();
                              WidgetsBinding.instance
                                  .addPostFrameCallback(
                                      (_) => _goToAllAssets());
                            }
                          },
                    style: _btnStyle(AppTheme.warning),
                    child: _ctrl.isSubmitting.value
                        ? const _LoadingIndicator()
                        : const Text('Open Request',
                            style: _whiteBold),
                  )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Dialog: Start Maintenance ────────────────────────────────────────
  void _showStartMaintenanceDialog(AssetModel asset) {
    final vendorCtrl   = TextEditingController();
    final issueCtrl    = TextEditingController();
    final formKey      = GlobalKey<FormState>();
    final selectedType = RxnString();
    const typeOptions  = ['repair', 'preventive', 'corrective', 'service'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogIcon(Icons.build_rounded, AppTheme.error),
              const SizedBox(height: 16),
              const Text('Start Maintenance',
                  style: AppTheme.headline2),
              const SizedBox(height: 4),
              Text(asset.assetName,
                  style: AppTheme.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.error.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.play_circle_outline_rounded,
                      size: 14, color: AppTheme.error),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    'Asset will be marked as "In Maintenance". It will not be available until completed.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppTheme.error),
                  )),
                ]),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: selectedType.value,
                    decoration: InputDecoration(
                      labelText: 'Maintenance Type',
                      prefixIcon:
                          const Icon(Icons.build_circle_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppTheme.error, width: 2),
                      ),
                      labelStyle:
                          const TextStyle(fontFamily: 'Poppins'),
                    ),
                    hint: const Text('Select type',
                        style: TextStyle(fontFamily: 'Poppins')),
                    isExpanded: true,
                    validator: (v) => v == null
                        ? 'Please select maintenance type'
                        : null,
                    items: typeOptions
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                  t[0].toUpperCase() + t.substring(1),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) => selectedType.value = v,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppTheme.textPrimary),
                  )),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: vendorCtrl,
                  label: 'Vendor / Service Center',
                  hint: 'e.g. Dell Service Center',
                  required: false),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: issueCtrl,
                  label: 'Additional Notes',
                  hint: 'Any additional info...',
                  required: false,
                  maxLines: 3),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CancelBtn()),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value
                        ? null
                        : () async {
                            if (!formKey.currentState!
                                .validate()) return;
                            final ok =
                                await _ctrl.startMaintenance(
                              assetId: asset.id,
                              maintenanceType:
                                  selectedType.value!,
                              vendorName: vendorCtrl.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : vendorCtrl.text.trim(),
                              issueDescription: issueCtrl.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : issueCtrl.text.trim(),
                            );
                            if (ok) {
                              Navigator.of(dialogContext).pop();
                              WidgetsBinding.instance
                                  .addPostFrameCallback(
                                      (_) => _goToAllAssets());
                            }
                          },
                    style: _btnStyle(AppTheme.error),
                    child: _ctrl.isSubmitting.value
                        ? const _LoadingIndicator()
                        : const Text('Start Maintenance',
                            style: _whiteBold),
                  )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Dialog: Complete Maintenance ─────────────────────────────────────
  void _showCompleteMaintenanceDialog(AssetModel asset) {
    final noteCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _DialogIcon(Icons.check_circle_rounded, AppTheme.success),
            const SizedBox(height: 16),
            const Text('Complete Maintenance',
                style: AppTheme.headline2),
            const SizedBox(height: 4),
            Text(asset.assetName,
                style: AppTheme.bodySmall
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('In Maintenance',
                  style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error)),
            ),
            const SizedBox(height: 20),
            _DialogField(
                ctrl: costCtrl,
                label: 'Cost (₹)',
                hint: 'e.g. 2500',
                required: false),
            const SizedBox(height: 12),
            _DialogField(
                ctrl: noteCtrl,
                label: 'Resolution Note',
                hint: 'What was fixed / replaced?',
                required: false,
                maxLines: 3),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _CancelBtn()),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed: _ctrl.isSubmitting.value
                      ? null
                      : () async {
                          final ok =
                              await _ctrl.completeMaintenance(
                            assetId: asset.id,
                            cost: costCtrl.text.trim().isEmpty
                                ? null
                                : double.tryParse(
                                    costCtrl.text.trim()),
                            resolutionNote: noteCtrl.text
                                    .trim()
                                    .isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                          );
                          if (ok) {
                            Navigator.of(dialogContext).pop();
                            WidgetsBinding.instance
                                .addPostFrameCallback(
                                    (_) => _goToAllAssets());
                          }
                        },
                  style: _btnStyle(AppTheme.success),
                  child: _ctrl.isSubmitting.value
                      ? const _LoadingIndicator()
                      : const Text('Mark Complete',
                          style: _whiteBold),
                )),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Asset',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.cardBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppTheme.textPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
            title: const Text('Asset Management',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppTheme.textPrimary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppTheme.primary, size: 22),
                onPressed: () {
                  switch (_tab.index) {
                    case 0:
                      _ctrl.fetchAssets(
                        status:    _filterStatus?.toLowerCase(),
                        assetType: _filterType?.toLowerCase(),
                      );
                      break;
                    case 1:
                      _ctrl.fetchHistory();
                      break;
                    case 2:
                      _ctrl.fetchSummary();
                      break;
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tab,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              tabs: const [
                Tab(text: 'All Assets'),
                Tab(text: 'History'),
                Tab(text: 'Summary'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            // ══════════════════════════════════════════════════════════
            //  TAB 1: All Assets
            // ══════════════════════════════════════════════════════════
            Column(children: [
              Container(
                color: AppTheme.cardBackground,
                padding:
                    const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(children: [
                  Expanded(child: _FilterDrop(
                    value: _filterStatus,
                    hint: 'All Status',
                    items: AssetStatus.filterLabels,
                    onChanged: (v) {
                      setState(() => _filterStatus = v);
                      _ctrl.fetchAssets(
                          status: v?.toLowerCase(),
                          assetType: _filterType?.toLowerCase());
                    },
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _FilterDrop(
                    value: _filterType,
                    hint: 'All Types',
                    items: AssetTypeNames.filterLabels,
                    onChanged: (v) {
                      setState(() => _filterType = v);
                      _ctrl.fetchAssets(
                          status: _filterStatus?.toLowerCase(),
                          assetType: v?.toLowerCase());
                    },
                  )),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterStatus = null;
                        _filterType   = null;
                      });
                      _ctrl.fetchAssets();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.errorLight,
                          borderRadius:
                              BorderRadius.circular(10)),
                      child: const Icon(
                          Icons.filter_alt_off_rounded,
                          color: AppTheme.error,
                          size: 18),
                    ),
                  ),
                ]),
              ),
              Expanded(child: Obx(() {
                if (_ctrl.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary));
                }
                if (_ctrl.assets.isEmpty) {
                  return Center(
                      child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: AppTheme.primary
                                  .withOpacity(0.07),
                              shape: BoxShape.circle),
                          child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppTheme.primary,
                              size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('No assets found',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 6),
                        const Text(
                            'Try changing filters or add a new asset',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ]));
                }
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => _ctrl.fetchAssets(
                      status: _filterStatus?.toLowerCase(),
                      assetType: _filterType?.toLowerCase()),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        16, 12, 16, 100),
                    itemCount: _ctrl.assets.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a  = _ctrl.assets[i];
                      final st = a.status.toLowerCase();
                      final prevAssignee =
                          _getPreviousAssignee(a.id, a.status);
                      return GestureDetector(
                        onTap: () => Get.to(
                            () => AssetModelScreen(asset: a)),
                        child: _AdminAssetCard(
                          asset: a,
                          previousAssignee: prevAssignee,
                          onOpenMaintenance:
                              st == AssetStatus.available
                                  ? () =>
                                      _showOpenMaintenanceDialog(a)
                                  : null,
                          onStartMaintenance:
                              st == AssetStatus.open
                                  ? () =>
                                      _showStartMaintenanceDialog(a)
                                  : null,
                          onCompleteMaintenance:
                              st == AssetStatus.maintenance
                                  ? () =>
                                      _showCompleteMaintenanceDialog(
                                          a)
                                  : null,
                          onAssign: st == AssetStatus.available
                              ? () => _showAssignDialog(a)
                              : null,
                          onReturn: st == AssetStatus.assigned
                              ? () => _showReturnDialog(a)
                              : null,
                        ),
                      );
                    },
                  ),
                );
              })),
            ]),

            // ══════════════════════════════════════════════════════════
            //  TAB 2: History  (with Date Filter — AdminScreen pattern)
            // ══════════════════════════════════════════════════════════
            Column(children: [
              // ── Filter Bar ─────────────────────────────────────────
              Container(
                color: AppTheme.cardBackground,
                padding:
                    const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(children: [
                  // From date
                  Expanded(child: Obx(() => _HistoryDateChip(
                        label: 'From',
                        date: _historyFromDate.value,
                        onTap: _pickHistoryFromDate,
                      ))),
                  const SizedBox(width: 10),
                  // To date
                  Expanded(child: Obx(() => _HistoryDateChip(
                        label: 'To',
                        date: _historyToDate.value,
                        onTap: _pickHistoryToDate,
                      ))),
                  const SizedBox(width: 10),
                  // Search button
                  Obx(() => ElevatedButton(
                        onPressed: _ctrl.isHistoryLoading.value
                            ? null
                            : () {
                                _hasHistorySearched.value = true;
                                _ctrl.fetchHistory();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10)),
                        ),
                        child: _ctrl.isHistoryLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Icon(Icons.search_rounded,
                                size: 20),
                      )),
                  const SizedBox(width: 8),
                  // Reset button
                  GestureDetector(
                    onTap: () {
                      _historyFromDate.value = DateTime(DateTime.now().year, DateTime.now().month, 1);
                      _historyToDate.value   = DateTime.now();
                      _hasHistorySearched.value = false;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.errorLight,
                          borderRadius:
                              BorderRadius.circular(10)),
                      child: const Icon(
                          Icons.filter_alt_off_rounded,
                          color: AppTheme.error,
                          size: 18),
                    ),
                  ),
                ]),
              ),

              // ── List ───────────────────────────────────────────────
              Expanded(child: Obx(() {
                if (_ctrl.isHistoryLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary));
                }

                // Pehli baar search nahi hua
                if (!_hasHistorySearched.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_search_rounded,
                            size: 64, color: AppTheme.textHint),
                        SizedBox(height: 16),
                        Text('Search History',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 6),
                        Text(
                            'Date range select karke 🔍 tap karo',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  );
                }

                // Date range filter (local)
                final from = DateTime(
                  _historyFromDate.value.year,
                  _historyFromDate.value.month,
                  _historyFromDate.value.day,
                );
                final to = DateTime(
                  _historyToDate.value.year,
                  _historyToDate.value.month,
                  _historyToDate.value.day,
                  23, 59, 59,
                );

                final filtered = _ctrl.history.where((h) {
                  final d = h.actionDate.toLocal();
                  return d.isAfter(
                          from.subtract(const Duration(seconds: 1))) &&
                      d.isBefore(
                          to.add(const Duration(seconds: 1)));
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: AppTheme.primary
                                  .withOpacity(0.07),
                              shape: BoxShape.circle),
                          child: const Icon(
                              Icons
                                  .history_toggle_off_rounded,
                              color: AppTheme.primary,
                              size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('No history found',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 6),
                        const Text(
                            'Selected date range mein koi record nahi',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  );
                }

                final groups = _groupHistories(filtered);

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => _ctrl.fetchHistory(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _GroupedHistoryCard(group: groups[i]),
                  ),
                );
              })),
            ]),

            // ══════════════════════════════════════════════════════════
            //  TAB 3: Summary
            // ══════════════════════════════════════════════════════════
            Obx(() {
              if (_ctrl.isSummaryLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary));
              }
              final s = _ctrl.summary.value;
              if (s == null) {
                return const Center(
                    child: Text('No summary available',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppTheme.textSecondary)));
              }
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () => _ctrl.fetchSummary(),
                child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _SummaryCard(
                        label: 'Total',
                        value: s.total.toString(),
                        icon: Icons.inventory_2_rounded,
                        color: AppTheme.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(
                        label: 'Available',
                        value: s.available.toString(),
                        icon: Icons.check_circle_rounded,
                        color: AppTheme.success)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _SummaryCard(
                        label: 'Assigned',
                        value: s.assigned.toString(),
                        icon: Icons.person_rounded,
                        color: AssetColors.indigo)),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(
                        label: 'In Maint.',
                        value: (s.total - s.available - s.assigned)
                            .clamp(0, s.total)
                            .toString(),
                        icon: Icons.build_rounded,
                        color: AppTheme.error)),
                  ]),
                  const SizedBox(height: 22),
                  if (s.total > 0)
                    Container(
                      decoration: AppTheme.cardDecoration(),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        const Text('Asset Distribution',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 18),
                        _ProgressBar(
                            label: 'Available',
                            value: s.total > 0
                                ? s.available / s.total
                                : 0,
                            color: AppTheme.success,
                            count: s.available,
                            total: s.total),
                        const SizedBox(height: 14),
                        _ProgressBar(
                            label: 'Assigned',
                            value: s.total > 0
                                ? s.assigned / s.total
                                : 0,
                            color: AssetColors.indigo,
                            count: s.assigned,
                            total: s.total),
                        const SizedBox(height: 14),
                        _ProgressBar(
                            label: 'In Maint.',
                            value: s.total > 0
                                ? (s.total -
                                            s.available -
                                            s.assigned)
                                        .clamp(0, s.total) /
                                    s.total
                                : 0,
                            color: AppTheme.error,
                            count: (s.total -
                                    s.available -
                                    s.assigned)
                                .clamp(0, s.total),
                            total: s.total),
                      ]),
                    ),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ADMIN ASSET CARD
// ─────────────────────────────────────────────
class _AdminAssetCard extends StatelessWidget {
  final AssetModel    asset;
  final String?       previousAssignee;
  final VoidCallback? onAssign;
  final VoidCallback? onReturn;
  final VoidCallback? onOpenMaintenance;
  final VoidCallback? onStartMaintenance;
  final VoidCallback? onCompleteMaintenance;

  const _AdminAssetCard({
    required this.asset,
    this.previousAssignee,
    this.onAssign,
    this.onReturn,
    this.onOpenMaintenance,
    this.onStartMaintenance,
    this.onCompleteMaintenance,
  });

  bool get _hasActions =>
      onAssign != null || onReturn != null ||
      onOpenMaintenance != null || onStartMaintenance != null ||
      onCompleteMaintenance != null;

  @override
  Widget build(BuildContext context) {
    final sc = AssetModel.statusColor(asset.status);
    final si = AssetModel.statusIcon(asset.status);
    final tc = AssetModel.typeColor(asset.assetType);
    final ti = AssetModel.typeIcon(asset.assetType);

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: tc.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(ti, color: tc, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(asset.assetName,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text('${asset.assetCodeSafe}  ·  ${asset.assetType}',
                style: AppTheme.caption),
          ])),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: sc.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(si, size: 10, color: sc),
              const SizedBox(width: 4),
              Text(AssetModel.statusLabel(asset.status),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: sc)),
            ]),
          ),
        ]),

        if (asset.assignedToName != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person_rounded,
                size: 13, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text('Assigned to: ${asset.assignedToName}',
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
          ]),
        ],

        if (previousAssignee != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            Icon(
              asset.status.toLowerCase() == AssetStatus.assigned
                  ? Icons.swap_horiz_rounded
                  : Icons.person_off_rounded,
              size: 13, color: AppTheme.textHint,
            ),
            const SizedBox(width: 4),
            Text(
              asset.status.toLowerCase() == AssetStatus.assigned
                  ? 'Previously: $previousAssignee'
                  : 'Last with: $previousAssignee',
              style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppTheme.textHint),
            ),
          ]),
        ],

        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.touch_app_rounded,
              size: 12, color: AppTheme.textHint),
          const SizedBox(width: 4),
          const Text('Tap to view details',
              style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppTheme.textHint)),
          const Spacer(),
          if (asset.brand?.isNotEmpty ?? false)
            Text('${asset.brand} · ${asset.model}',
                style: AppTheme.caption),
        ]),
        if (_hasActions) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (onAssign != null)
              _ActionBtn(
                  label: 'Assign',
                  icon: Icons.assignment_ind_rounded,
                  color: AppTheme.primary,
                  onTap: onAssign!),
            if (onOpenMaintenance != null)
              _ActionBtn(
                  label: 'Open Request',
                  icon: Icons.pending_actions_rounded,
                  color: AppTheme.warning,
                  onTap: onOpenMaintenance!),
            if (onStartMaintenance != null)
              _ActionBtn(
                  label: 'Start Maint.',
                  icon: Icons.build_circle_rounded,
                  color: AppTheme.error,
                  onTap: onStartMaintenance!),
            if (onReturn != null)
              _ActionBtn(
                  label: 'Return',
                  icon: Icons.assignment_return_rounded,
                  color: AppTheme.success,
                  onTap: onReturn!),
            if (onCompleteMaintenance != null)
              _ActionBtn(
                  label: 'Mark Done',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.success,
                  onTap: onCompleteMaintenance!),
          ]),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  GROUPED HISTORY CARD
// ─────────────────────────────────────────────
class _GroupedHistoryCard extends StatelessWidget {
  final _WorkflowGroup group;
  const _GroupedHistoryCard({required this.group});

  static Map<String, dynamic>? _parseNoteJson(String? note) {
    if (note == null || note.isEmpty) return null;
    try {
      final decoded = jsonDecode(note);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  static String _fmtLocal(DateTime dt) {
    final local = dt.toLocal();
    return '${DateFormat('dd MMM yyyy').format(local)}  ·  ${DateFormat('hh:mm a').format(local)}';
  }

  static String _fmtIsoLocal(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final normalized =
          (iso.endsWith('Z') || iso.contains('+')) ? iso : '${iso}Z';
      final dt = DateTime.tryParse(normalized)?.toLocal();
      if (dt == null) return iso;
      return '${DateFormat('dd MMM yyyy').format(dt)}  ·  ${DateFormat('hh:mm a').format(dt)}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final color  = AssetHistoryModel.actionColor(latest.action);
    final icon   = AssetHistoryModel.actionIcon(latest.action);
    final label  = AssetHistoryModel.actionLabel(latest.action);

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              Expanded(
                  child: Text(
                latest.assetNameSafe,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: color)),
              ),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.access_time_rounded,
                  size: 11, color: AppTheme.textHint),
              const SizedBox(width: 3),
              Text(_fmtLocal(latest.actionDate.toLocal()),
                  style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      color: AppTheme.textHint)),
            ]),
          ])),
        ]),

        // Timeline of all steps
        if (group.steps.length > 1) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          ...group.steps.asMap().entries.map((e) {
            final idx    = e.key;
            final step   = e.value;
            final sc     = AssetHistoryModel.actionColor(step.action);
            final si     = AssetHistoryModel.actionIcon(step.action);
            final sl     = AssetHistoryModel.actionLabel(step.action);
            final isLast = idx == group.steps.length - 1;
            return _TimelineStep(
              icon: si, color: sc, label: sl,
              isLast: isLast,
              content: _buildStepContent(step, sc),
            );
          }),
        ] else ...[
          const SizedBox(height: 8),
          ..._buildStepContent(group.first, color),
        ],
      ]),
    );
  }

  List<Widget> _buildStepContent(
      AssetHistoryModel step, Color color) {
    final noteJson = _parseNoteJson(step.note);
    final widgets  = <Widget>[];

    if (step.performedByName != null &&
        step.performedByName!.isNotEmpty) {
      widgets.add(_HistoryDetail(
        icon: Icons.manage_accounts_rounded,
        color: color,
        label: step.action.toLowerCase() == HistoryAction.added
            ? 'Added by'
            : 'By',
        value: step.performedByName!,
      ));
    }

    if (step.targetUserName != null) {
      final lbl =
          step.action.toLowerCase() == HistoryAction.returned
              ? 'Returned from'
              : 'Assigned to';
      widgets.add(_HistoryDetail(
        icon: Icons.person_rounded,
        color: AppTheme.textSecondary,
        label: lbl,
        value: step.targetUserName!,
      ));
    }

    if (noteJson != null) {
      if ((noteJson['type'] ?? '').toString().isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.build_circle_rounded,
            color: color,
            label: 'Type',
            value: noteJson['type'].toString()));
      if ((noteJson['vendor'] ?? '').toString().isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.store_rounded,
            color: AppTheme.textSecondary,
            label: 'Vendor',
            value: noteJson['vendor'].toString()));
      if ((noteJson['issue'] ?? '').toString().isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.warning_amber_rounded,
            color: AppTheme.warning,
            label: 'Issue',
            value: noteJson['issue'].toString()));
      if ((noteJson['resolution'] ?? '').toString().isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.check_circle_outline_rounded,
            color: AppTheme.success,
            label: 'Resolution',
            value: noteJson['resolution'].toString()));
      if (noteJson['cost'] != null)
        widgets.add(_HistoryDetail(
            icon: Icons.currency_rupee_rounded,
            color: AppTheme.textSecondary,
            label: 'Cost',
            value: '₹${noteJson['cost']}'));
      if ((noteJson['condition'] ?? '').toString().isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.verified_outlined,
            color: AppTheme.success,
            label: 'Condition',
            value: noteJson['condition'].toString()));
      if (noteJson['startedAt'] != null)
        widgets.add(_HistoryDetail(
            icon: Icons.play_circle_outline_rounded,
            color: AppTheme.error,
            label: 'Started',
            value: _fmtIsoLocal(noteJson['startedAt'].toString())));
      if (noteJson['completedAt'] != null)
        widgets.add(_HistoryDetail(
            icon: Icons.task_alt_rounded,
            color: AppTheme.success,
            label: 'Completed',
            value:
                _fmtIsoLocal(noteJson['completedAt'].toString())));
    } else {
      if (step.condition != null && step.condition!.isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.verified_outlined,
            color: AppTheme.success,
            label: 'Condition',
            value: step.condition!));
      if (step.note != null && step.note!.isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.notes_rounded,
            color: AppTheme.textSecondary,
            label: 'Note',
            value: step.note!));
      if (step.maintenanceType != null &&
          step.maintenanceType!.isNotEmpty)
        widgets.add(_HistoryDetail(
            icon: Icons.build_circle_rounded,
            color: color,
            label: 'Type',
            value: step.maintenanceType!));
    }

    return widgets;
  }
}

// ─────────────────────────────────────────────
//  TIMELINE STEP
// ─────────────────────────────────────────────
class _TimelineStep extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       label;
  final bool         isLast;
  final List<Widget> content;

  const _TimelineStep({
    required this.icon,
    required this.color,
    required this.label,
    required this.isLast,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 28,
            child: Column(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle),
            child: Icon(icon, size: 13, color: color),
          ),
          if (!isLast)
            Expanded(
                child: Container(
                    width: 2,
                    color: AppTheme.divider,
                    margin:
                        const EdgeInsets.symmetric(vertical: 2))),
        ])),
        const SizedBox(width: 10),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: color)),
            ),
            const SizedBox(height: 4),
            ...content,
          ]),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  HISTORY DATE CHIP  (AdminScreen ke _DateChip jaisa)
// ─────────────────────────────────────────────
class _HistoryDateChip extends StatelessWidget {
  final String       label;
  final DateTime     date;
  final VoidCallback onTap;

  const _HistoryDateChip({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(10),
        color: AppTheme.background,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    color: AppTheme.textHint)),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: AppTheme.textPrimary),
            ),
          ]),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.calendar_month_rounded,
                  color: AppTheme.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 13),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: color),
          textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      );
}

// ─────────────────────────────────────────────
//  HISTORY DETAIL ROW
// ─────────────────────────────────────────────
class _HistoryDetail extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;

  const _HistoryDetail({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppTheme.textHint,
                  fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: AppTheme.textSecondary))),
        ]),
      );
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _DialogIcon extends StatelessWidget {
  final IconData icon;
  final Color    color;

  const _DialogIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration:
            BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 32),
      );
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool   required;
  final int    maxLines;

  const _DialogField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.required = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 2)),
          labelStyle: const TextStyle(fontFamily: 'Poppins'),
          hintStyle: const TextStyle(
              fontFamily: 'Poppins', color: AppTheme.textHint),
        ),
        style: const TextStyle(fontFamily: 'Poppins'),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? '$label is required'
                : null
            : null,
      );
}

class _FilterDrop extends StatelessWidget {
  final String?             value;
  final String              hint;
  final List<String>        items;
  final void Function(String?) onChanged;

  const _FilterDrop({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
            border: Border.all(color: AppTheme.divider),
            borderRadius: BorderRadius.circular(10),
            color: AppTheme.background),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppTheme.textHint)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: AppTheme.textSecondary),
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppTheme.textPrimary),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        )),
      );
}

class _SummaryCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  final int    count;
  final int    total;

  const _ProgressBar({
    required this.label,
    required this.value,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500))),
          Text('$count / $total  (${(value * 100).toInt()}%)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: color)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 9,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ]);
}

class _CancelBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppTheme.divider),
        ),
        child: const Text('Cancel',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: AppTheme.textSecondary)),
      );
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
            color: Colors.white, strokeWidth: 2),
      );
}