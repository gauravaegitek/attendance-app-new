// // lib/screens/document/document_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/document_controller.dart';
// import '../../models/document_model.dart';
// import '../../models/models.dart';
// import '../../services/api_service.dart';
// import '../../core/theme/app_theme.dart'; // ✅ CORRECT PATH

// class DocumentScreen extends StatefulWidget {
//   const DocumentScreen({super.key});

//   @override
//   State<DocumentScreen> createState() => _DocumentScreenState();
// }

// class _DocumentScreenState extends State<DocumentScreen>
//     with SingleTickerProviderStateMixin {
//   late final DocumentController _ctrl;
//   late final TabController _tabCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = Get.find<DocumentController>();
//     _tabCtrl = TabController(
//         length: _ctrl.isAdmin ? 3 : 2, vsync: this);

//     // ✅ Listen for upload-success tab switch signal
//     ever(_ctrl.switchToTab, (int idx) {
//       if (idx < _tabCtrl.length) _tabCtrl.animateTo(idx);
//     });
//   }

//   @override
//   void dispose() {
//     _tabCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         title: const Text('Documents'),
//         elevation: 0,
//         backgroundColor: AppTheme.primary,
//         foregroundColor: Colors.white,
//         actions: [
//           Obx(() => (_ctrl.isLoadingMy.value || _ctrl.isLoadingAll.value)
//               ? const Padding(
//                   padding: EdgeInsets.all(14),
//                   child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2)))
//               : IconButton(
//                   icon: const Icon(Icons.refresh_rounded),
//                   tooltip: 'Refresh',
//                   onPressed: () {
//                     _ctrl.loadMyDocuments();
//                     if (_ctrl.isAdmin) _ctrl.loadAllDocuments();
//                   },
//                 )),
//         ],
//         bottom: TabBar(
//           controller: _tabCtrl,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: [
//             const Tab(text: 'My Docs'),
//             const Tab(text: 'Upload'),
//             if (_ctrl.isAdmin) const Tab(text: 'Admin'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabCtrl,
//         children: [
//           _MyDocumentsTab(ctrl: _ctrl),
//           _UploadTab(ctrl: _ctrl),
//           if (_ctrl.isAdmin) _AdminTab(ctrl: _ctrl),
//         ],
//       ),
//     );
//   }
// }

// // =====================================================================
// // TAB 1 — MY DOCUMENTS
// // =====================================================================

// class _MyDocumentsTab extends StatelessWidget {
//   final DocumentController ctrl;
//   const _MyDocumentsTab({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _StatusFilterBar(
//           selected: ctrl.filterStatus,
//           onChanged: (v) => ctrl.filterStatus.value = v,
//         ),
//         Expanded(
//           child: Obx(() {
//             if (ctrl.isLoadingMy.value) {
//               return const Center(
//                   child: CircularProgressIndicator(color: AppTheme.primary));
//             }
//             final docs = ctrl.filteredMyDocuments;
//             if (docs.isEmpty) {
//               return const _EmptyState(
//                   icon: Icons.folder_open, message: 'No documents found');
//             }
//             return RefreshIndicator(
//               color: AppTheme.primary,
//               onRefresh: ctrl.loadMyDocuments,
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(12),
//                 itemCount: docs.length,
//                 itemBuilder: (_, i) => _DocumentCard(
//                   doc: docs[i],
//                   showActions: false,
//                   ctrl: ctrl,
//                 ),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }

// // =====================================================================
// // TAB 2 — UPLOAD
// // =====================================================================

// class _UploadTab extends StatefulWidget {
//   final DocumentController ctrl;
//   const _UploadTab({required this.ctrl});

//   @override
//   State<_UploadTab> createState() => _UploadTabState();
// }

// class _UploadTabState extends State<_UploadTab> {
//   // ✅ Using ctrl.descriptionCtrl directly — no local controller needed

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = widget.ctrl;
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [AppTheme.primary, AppTheme.secondary]),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.upload_file, color: Colors.white, size: 32),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text('Upload Document',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Poppins')),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           Text('Document Type *',
//               style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Obx(() => DropdownButtonFormField<String>(
//                 value: ctrl.selectedDocType.value.isEmpty
//                     ? null
//                     : ctrl.selectedDocType.value,
//                 hint: const Text('Select document type'),
//                 decoration: _inputDecoration(),
//                 items: DocumentController.documentTypes
//                     .map((t) => DropdownMenuItem(value: t, child: Text(t)))
//                     .toList(),
//                 onChanged: (v) => ctrl.selectedDocType.value = v ?? '',
//               )),
//           const SizedBox(height: 16),

//           Text('Description',
//               style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: ctrl.descriptionCtrl,
//             maxLines: 3,
//             decoration: _inputDecoration(hint: 'Enter description (optional)'),
//             onChanged: (v) => ctrl.description.value = v,
//           ),
//           const SizedBox(height: 16),

//           Text('Select File *',
//               style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Obx(() => ctrl.selectedFile.value != null
//               ? _SelectedFileCard(
//                   name: ctrl.selectedFileName.value,
//                   onRemove: ctrl.clearFile,
//                 )
//               : Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _PickerButton(
//                             icon: Icons.photo_library,
//                             label: 'Gallery',
//                             color: AppTheme.primary,
//                             onTap: ctrl.pickFromGallery,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: _PickerButton(
//                             icon: Icons.camera_alt,
//                             label: 'Camera',
//                             color: AppTheme.success,
//                             onTap: ctrl.pickFromCamera,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Pick a photo of your document',
//                         style: AppTheme.caption),
//                   ],
//                 )),
//           const SizedBox(height: 28),

//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   onPressed:
//                       ctrl.isUploading.value ? null : ctrl.uploadDocument,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     minimumSize: const Size(double.infinity, 52),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   icon: ctrl.isUploading.value
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Icon(Icons.cloud_upload, color: Colors.white),
//                   label: Text(
//                     ctrl.isUploading.value
//                         ? 'Uploading...'
//                         : 'Upload Document',
//                     style: AppTheme.buttonText,
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }

// // =====================================================================
// // TAB 3 — ADMIN
// // =====================================================================

// class _AdminTab extends StatelessWidget {
//   final DocumentController ctrl;
//   const _AdminTab({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         children: [
//           Container(
//             color: AppTheme.primary,
//             child: const TabBar(
//               indicatorColor: Colors.amber,
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.white60,
//               tabs: [
//                 Tab(text: 'All Documents'),
//                 Tab(text: 'Summary'),
//               ],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 _AdminDocumentsList(ctrl: ctrl),
//                 _SummaryTab(ctrl: ctrl),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =====================================================================
// // ADMIN — ALL DOCUMENTS with Employee Name dropdown
// // =====================================================================

// class _AdminDocumentsList extends StatefulWidget {
//   final DocumentController ctrl;
//   const _AdminDocumentsList({required this.ctrl});

//   @override
//   State<_AdminDocumentsList> createState() => _AdminDocumentsListState();
// }

// class _AdminDocumentsListState extends State<_AdminDocumentsList> {
//   List<UserModel> _users       = [];
//   UserModel?      _selectedUser;  // null = "All Employees"
//   bool            _loadingUsers = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }

//   Future<void> _loadUsers() async {
//     try {
//       final list = await ApiService.getAllUsers();
//       setState(() {
//         _users        = list;
//         _loadingUsers = false;
//       });
//       // ✅ Auto-load all documents on open (null = no employeeId filter)
//       // We load each user's docs and combine, or just load first user if API requires ID
//       _loadAll();
//     } catch (_) {
//       setState(() => _loadingUsers = false);
//     }
//   }

//   /// Load documents — if no user selected, load for all users and combine
//   Future<void> _loadAll() async {
//     if (_selectedUser != null) {
//       widget.ctrl.loadAllDocuments(employeeId: _selectedUser!.userId);
//     } else {
//       // Load all employees' docs and combine
//       widget.ctrl.loadAllDocumentsForAll(_users);
//     }
//   }

//   void _onEmployeeChanged(UserModel? val) {
//     setState(() => _selectedUser = val);
//     // ✅ Auto-search on selection change, no button tap needed
//     if (val != null) {
//       widget.ctrl.loadAllDocuments(employeeId: val.userId);
//     } else {
//       widget.ctrl.loadAllDocumentsForAll(_users);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ── Employee Dropdown Header ────────────────────
//         Container(
//           color: AppTheme.primary,
//           padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Search by Employee',
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 11,
//                       fontFamily: 'Poppins')),
//               const SizedBox(height: 6),
//               _loadingUsers
//                   ? Container(
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.white.withOpacity(0.3)),
//                       ),
//                       child: const Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 16, height: 16,
//                               child: CircularProgressIndicator(
//                                   strokeWidth: 2, color: Colors.white),
//                             ),
//                             SizedBox(width: 8),
//                             Text('Loading employees...',
//                                 style: TextStyle(
//                                     color: Colors.white70,
//                                     fontFamily: 'Poppins',
//                                     fontSize: 13)),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                             color: Colors.white.withOpacity(0.3)),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<UserModel?>(
//                           value: _selectedUser,
//                           isExpanded: true,
//                           dropdownColor: AppTheme.primaryDark,
//                           iconEnabledColor: Colors.white,
//                           // ✅ "All Employees" as first item
//                           items: [
//                             const DropdownMenuItem<UserModel?>(
//                               value: null,
//                               child: Row(children: [
//                                 Icon(Icons.people_rounded,
//                                     color: Colors.white70, size: 16),
//                                 SizedBox(width: 8),
//                                 Text('All Employees',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontFamily: 'Poppins',
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600)),
//                               ]),
//                             ),
//                             ..._users.map((u) =>
//                                 DropdownMenuItem<UserModel?>(
//                                   value: u,
//                                   child: Row(children: [
//                                     const Icon(Icons.person_outline_rounded,
//                                         color: Colors.white70, size: 16),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(u.userName,
//                                           style: const TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: 'Poppins',
//                                               fontSize: 14),
//                                           overflow: TextOverflow.ellipsis),
//                                     ),
//                                   ]),
//                                 )),
//                           ],
//                           selectedItemBuilder: (_) => [
//                             // "All Employees" selected display
//                             const Row(children: [
//                               Icon(Icons.people_rounded,
//                                   color: Colors.white70, size: 16),
//                               SizedBox(width: 8),
//                               Text('All Employees',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontFamily: 'Poppins',
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600)),
//                             ]),
//                             ..._users.map((u) => Row(children: [
//                                   const Icon(Icons.person_rounded,
//                                       color: Colors.white70, size: 16),
//                                   const SizedBox(width: 8),
//                                   Text(u.userName,
//                                       style: const TextStyle(
//                                           color: Colors.white,
//                                           fontFamily: 'Poppins',
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w600)),
//                                 ])),
//                           ],
//                           onChanged: _onEmployeeChanged, // ✅ Auto-search on change
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),

//         _StatusFilterBar(
//           selected: widget.ctrl.filterStatus,
//           onChanged: (v) => widget.ctrl.filterStatus.value = v,
//         ),

//         Expanded(
//           child: Obx(() {
//             if (widget.ctrl.isLoadingAll.value) {
//               return const Center(
//                   child: CircularProgressIndicator(color: AppTheme.primary));
//             }
//             final docs = widget.ctrl.filteredAllDocuments;
//             if (docs.isEmpty) {
//               return _EmptyState(
//                 icon: Icons.manage_search_rounded,
//                 message: _selectedUser == null
//                     ? 'No documents found for any employee'
//                     : 'No documents found for ${_selectedUser!.userName}',
//               );
//             }
//             return RefreshIndicator(
//               color: AppTheme.primary,
//               onRefresh: _loadAll,
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(12),
//                 itemCount: docs.length,
//                 itemBuilder: (_, i) => _DocumentCard(
//                   doc: docs[i],
//                   showActions: true,
//                   ctrl: widget.ctrl,
//                 ),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }

// // =====================================================================
// // ADMIN — SUMMARY TAB with proper date filter
// // =====================================================================

// class _SummaryTab extends StatefulWidget {
//   final DocumentController ctrl;
//   const _SummaryTab({required this.ctrl});

//   @override
//   State<_SummaryTab> createState() => _SummaryTabState();
// }

// class _SummaryTabState extends State<_SummaryTab> {
//   // ✅ Default: from = 1st of current month, to = today
//   final Rx<DateTime> _fromDate =
//       DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
//   final Rx<DateTime> _toDate = DateTime.now().obs;

//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     widget.ctrl.summaryFromDate.value =
//         DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
//     widget.ctrl.summaryToDate.value = DateFormat('yyyy-MM-dd').format(now);
//     widget.ctrl.loadSummary();
//   }

//   Future<void> _pickFrom() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       _fromDate.value = picked;
//       widget.ctrl.summaryFromDate.value =
//           DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }

//   Future<void> _pickTo() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _toDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       _toDate.value = picked;
//       widget.ctrl.summaryToDate.value =
//           DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = widget.ctrl;
//     return Column(
//       children: [
//         // ✅ Date filter header matching login_history_screen style
//         Container(
//           color: AppTheme.primary,
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//           child: Row(
//             children: [
//               Expanded(
//                   child: _DatePickerField(
//                       label: 'From',
//                       obs: _fromDate,
//                       onTap: _pickFrom)),
//               const SizedBox(width: 12),
//               Expanded(
//                   child: _DatePickerField(
//                       label: 'To', obs: _toDate, onTap: _pickTo)),
//               const SizedBox(width: 10),
//               SizedBox(
//                 width: 44,
//                 height: 44,
//                 child: Obx(() => ElevatedButton(
//                       onPressed: ctrl.isLoadingSummary.value
//                           ? null
//                           : ctrl.loadSummary,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppTheme.primary,
//                         minimumSize: const Size(44, 44),
//                         padding: EdgeInsets.zero,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       child: ctrl.isLoadingSummary.value
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: AppTheme.primary))
//                           : const Icon(Icons.search_rounded, size: 22),
//                     )),
//               ),
//             ],
//           ),
//         ),

//         Expanded(
//           child: Obx(() {
//             if (ctrl.isLoadingSummary.value) {
//               return const Center(
//                   child: CircularProgressIndicator(
//                       color: AppTheme.primary));
//             }
//             final s = ctrl.summary.value;
//             if (s == null) {
//               return const _EmptyState(
//                   icon: Icons.bar_chart, message: 'No summary data');
//             }
//             return RefreshIndicator(
//               color: AppTheme.primary,
//               onRefresh: ctrl.loadSummary,
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   Row(
//                     children: [
//                       _StatCard(
//                           label: 'Total',
//                           value: s.totalDocuments,
//                           color: AppTheme.primary),
//                       _StatCard(
//                           label: 'Pending',
//                           value: s.pendingCount,
//                           color: AppTheme.warning),
//                       _StatCard(
//                           label: 'Verified',
//                           value: s.verifiedCount,
//                           color: AppTheme.success),
//                       _StatCard(
//                           label: 'Rejected',
//                           value: s.rejectedCount,
//                           color: AppTheme.error),
//                     ],
//                   ),
//                   if (s.documents.isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     Text('Documents', style: AppTheme.headline3),
//                     const SizedBox(height: 8),
//                     ...s.documents.map((d) => _DocumentCard(
//                           doc: d,
//                           showActions: true,
//                           ctrl: ctrl,
//                         )),
//                   ] else if (s.byType.isNotEmpty) ...[
//                     // ── Document Type Breakdown ─────────────
//                     const SizedBox(height: 20),
//                     Row(children: [
//                       const Icon(Icons.bar_chart_rounded,
//                           color: AppTheme.primary, size: 18),
//                       const SizedBox(width: 8),
//                       Text('By Document Type', style: AppTheme.headline3),
//                     ]),
//                     const SizedBox(height: 10),
//                     ...s.byType.map((bt) => Container(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 11),
//                           decoration: AppTheme.cardDecoration(),
//                           child: Row(children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.primaryLight,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(Icons.description_outlined,
//                                   color: AppTheme.primary, size: 18),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(bt.documentType,
//                                   style: AppTheme.bodyMedium
//                                       .copyWith(fontWeight: FontWeight.w600)),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.primary.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                     color: AppTheme.primary.withOpacity(0.3)),
//                               ),
//                               child: Text('${bt.count} docs',
//                                   style: AppTheme.bodySmall.copyWith(
//                                       color: AppTheme.primary,
//                                       fontWeight: FontWeight.w700)),
//                             ),
//                           ]),
//                         )),

//                     // ── Per-Employee Breakdown ──────────────
//                     // Uses allDocuments loaded in All Documents tab
//                     if (ctrl.allDocuments.isNotEmpty) ...[
//                       const SizedBox(height: 20),
//                       Row(children: [
//                         const Icon(Icons.people_alt_rounded,
//                             color: AppTheme.primary, size: 18),
//                         const SizedBox(width: 8),
//                         Text('By Employee', style: AppTheme.headline3),
//                       ]),
//                       const SizedBox(height: 10),
//                       ...() {
//                         // Group allDocuments by employeeName
//                         final Map<String, List<DocumentModel>> grouped = {};
//                         for (final d in ctrl.allDocuments) {
//                           grouped.putIfAbsent(
//                               d.employeeName.isNotEmpty
//                                   ? d.employeeName
//                                   : 'Employee #${d.employeeId}',
//                               () => []).add(d);
//                         }
//                         return grouped.entries.map((entry) {
//                           final empName = entry.key;
//                           final empDocs = entry.value;
//                           // Count by docType for this employee
//                           final typeCount = <String, int>{};
//                           for (final d in empDocs) {
//                             typeCount[d.documentType] =
//                                 (typeCount[d.documentType] ?? 0) + 1;
//                           }
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             decoration: AppTheme.cardDecoration(),
//                             child: Theme(
//                               data: Theme.of(Get.context!).copyWith(
//                                   dividerColor: Colors.transparent),
//                               child: ExpansionTile(
//                                 tilePadding: const EdgeInsets.symmetric(
//                                     horizontal: 14, vertical: 0),
//                                 leading: CircleAvatar(
//                                   radius: 18,
//                                   backgroundColor:
//                                       AppTheme.primary.withOpacity(0.15),
//                                   child: Text(
//                                     empName.isNotEmpty
//                                         ? empName[0].toUpperCase()
//                                         : '?',
//                                     style: const TextStyle(
//                                         color: AppTheme.primary,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                         fontFamily: 'Poppins'),
//                                   ),
//                                 ),
//                                 title: Text(empName,
//                                     style: AppTheme.bodyMedium.copyWith(
//                                         fontWeight: FontWeight.w600)),
//                                 subtitle: Text(
//                                     '${empDocs.length} document${empDocs.length > 1 ? 's' : ''}',
//                                     style: AppTheme.caption),
//                                 children: typeCount.entries
//                                     .map((e) => Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               56, 0, 16, 8),
//                                           child: Row(children: [
//                                             const Icon(
//                                                 Icons.subdirectory_arrow_right,
//                                                 size: 14,
//                                                 color: AppTheme.textHint),
//                                             const SizedBox(width: 6),
//                                             Expanded(
//                                               child: Text(e.key,
//                                                   style: AppTheme.bodySmall),
//                                             ),
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8,
//                                                       vertical: 2),
//                                               decoration: BoxDecoration(
//                                                 color: AppTheme.primaryLight,
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                               ),
//                                               child: Text('${e.value}',
//                                                   style: AppTheme.caption
//                                                       .copyWith(
//                                                           color:
//                                                               AppTheme.primary,
//                                                           fontWeight:
//                                                               FontWeight.w700)),
//                                             ),
//                                           ]),
//                                         ))
//                                     .toList(),
//                               ),
//                             ),
//                           );
//                         }).toList();
//                       }(),
//                     ] else ...[
//                       const SizedBox(height: 12),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primaryLight,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                               color: AppTheme.primary.withOpacity(0.2)),
//                         ),
//                         child: Row(children: [
//                           const Icon(Icons.info_outline,
//                               color: AppTheme.primary, size: 16),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Go to All Documents tab → select "All Employees" to see per-employee breakdown here.',
//                               style: AppTheme.caption
//                                   .copyWith(color: AppTheme.primary),
//                             ),
//                           ),
//                         ]),
//                       ),
//                     ],
//                   ] else ...[
//                     const SizedBox(height: 24),
//                     const _EmptyState(
//                       icon: Icons.info_outline_rounded,
//                       message: 'No documents in selected date range.',
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }

// // =====================================================================
// // DATE PICKER FIELD
// // =====================================================================

// class _DatePickerField extends StatelessWidget {
//   final String label;
//   final Rx<DateTime> obs;
//   final VoidCallback onTap;

//   const _DatePickerField(
//       {required this.label, required this.obs, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(10),
//           border:
//               Border.all(color: Colors.white.withOpacity(0.3)),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(label,
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(0.8),
//                           fontSize: 10,
//                           fontFamily: 'Poppins')),
//                   const SizedBox(height: 2),
//                   Obx(() => Text(
//                         DateFormat('dd MMM yyyy').format(obs.value),
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'Poppins'),
//                       )),
//                 ],
//               ),
//             ),
//             Icon(Icons.calendar_month_outlined,
//                 size: 16,
//                 color: Colors.white.withOpacity(0.85)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =====================================================================
// // DOCUMENT CARD
// // =====================================================================

// class _DocumentCard extends StatelessWidget {
//   final DocumentModel doc;
//   final bool showActions;
//   final DocumentController ctrl;

//   const _DocumentCard({
//     required this.doc,
//     required this.showActions,
//     required this.ctrl,
//   });

//   Color get _statusColor {
//     switch (doc.status.toLowerCase()) {
//       case 'verified':
//       case 'approved': // ✅ API returns "approved" = verified
//         return AppTheme.success;
//       case 'rejected':
//         return AppTheme.error;
//       default:
//         return AppTheme.warning;
//     }
//   }

//   IconData get _statusIcon {
//     switch (doc.status.toLowerCase()) {
//       case 'verified':
//       case 'approved':
//         return Icons.verified;
//       case 'rejected':
//         return Icons.cancel;
//       default:
//         return Icons.hourglass_empty;
//     }
//   }

//   String get _statusLabel {
//     switch (doc.status.toLowerCase()) {
//       case 'approved':
//         return 'Verified';
//       case 'pending':
//         return 'Pending';
//       case 'rejected':
//         return 'Rejected';
//       default:
//         return doc.status.isNotEmpty
//             ? doc.status[0].toUpperCase() + doc.status.substring(1)
//             : 'Pending';
//     }
//   }

//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Document'),
//         content: const Text(
//             'Are you sure you want to delete this document?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ctrl.deleteDocument(doc.id);
//             },
//             child: Text('Delete',
//                 style:
//                     AppTheme.bodyMedium.copyWith(color: AppTheme.error)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showVerifyDialog(BuildContext context, String status) {
//     final remarksCtrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('$status Document'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Type: ${doc.documentType}',
//                 style: AppTheme.bodyMedium),
//             if (doc.employeeName.isNotEmpty)
//               Text('Employee: ${doc.employeeName}',
//                   style: AppTheme.bodyMedium),
//             const SizedBox(height: 12),
//             TextField(
//               controller: remarksCtrl,
//               maxLines: 2,
//               decoration: const InputDecoration(
//                 labelText: 'Remarks (optional)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: status == 'Verified'
//                   ? AppTheme.success
//                   : AppTheme.error,
//               minimumSize: const Size(80, 36),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               ctrl.verifyDocument(
//                 documentId: doc.id,
//                 status: status,
//                 remarks: remarksCtrl.text.trim(),
//               );
//             },
//             child: Text(status,
//                 style: const TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _statusColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: _statusColor.withOpacity(0.4)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(_statusIcon,
//                           size: 14, color: _statusColor),
//                       const SizedBox(width: 4),
//                       Text(_statusLabel,
//                           style: AppTheme.caption.copyWith(
//                               color: _statusColor,
//                               fontWeight: FontWeight.w600)),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   DateFormat('dd MMM yyyy').format(doc.uploadedAt),
//                   style: AppTheme.caption,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text(doc.documentType, style: AppTheme.labelBold),
//             if (doc.employeeName.isNotEmpty) ...[
//               const SizedBox(height: 2),
//               Text('Employee: ${doc.employeeName}',
//                   style: AppTheme.bodySmall),
//             ],
//             if (doc.description.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Text(doc.description, style: AppTheme.bodySmall),
//             ],
//             if (doc.remarks.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Text('Remarks: ${doc.remarks}',
//                   style: AppTheme.caption.copyWith(
//                       color: AppTheme.primary,
//                       fontStyle: FontStyle.italic)),
//             ],
//             if (doc.fileName.isNotEmpty) ...[
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   const Icon(Icons.insert_drive_file,
//                       size: 14, color: AppTheme.primary),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(doc.fileName,
//                         style: AppTheme.caption
//                             .copyWith(color: AppTheme.primary),
//                         overflow: TextOverflow.ellipsis),
//                   ),
//                 ],
//               ),
//             ],
//             if (showActions) ...[
//               const SizedBox(height: 10),
//               const Divider(height: 1),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   if (doc.status.toLowerCase() == 'pending') ...[
//                     Expanded(
//                       child: _ActionButton(
//                         label: 'Verify',
//                         color: AppTheme.success,
//                         icon: Icons.check_circle_outline,
//                         onTap: () =>
//                             _showVerifyDialog(context, 'Verified'),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: _ActionButton(
//                         label: 'Reject',
//                         color: AppTheme.error,
//                         icon: Icons.cancel_outlined,
//                         onTap: () =>
//                             _showVerifyDialog(context, 'Rejected'),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                   InkWell(
//                     onTap: () => _confirmDelete(context),
//                     borderRadius: BorderRadius.circular(8),
//                     child: Padding(
//                       padding: const EdgeInsets.all(6),
//                       child: Icon(Icons.delete_outline,
//                           color: AppTheme.textSecondary, size: 22),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =====================================================================
// // SHARED WIDGETS
// // =====================================================================

// class _StatusFilterBar extends StatelessWidget {
//   final RxString selected;
//   final void Function(String) onChanged;
//   const _StatusFilterBar(
//       {required this.selected, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppTheme.cardBackground,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: Obx(() => Row(
//             children: DocumentController.statusFilters.map((s) {
//               final isSelected = selected.value == s;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => onChanged(s),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 3),
//                     padding: const EdgeInsets.symmetric(vertical: 7),
//                     decoration: BoxDecoration(
//                       color: isSelected ? AppTheme.primary : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected
//                             ? AppTheme.primary
//                             : AppTheme.textHint,
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (isSelected) ...[
//                           Icon(Icons.check_rounded,
//                               size: 12,
//                               color: Colors.white),
//                           const SizedBox(width: 3),
//                         ],
//                         Flexible(
//                           child: Text(s,
//                               textAlign: TextAlign.center,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : AppTheme.textPrimary,
//                               )),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           )),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String label;
//   final int value;
//   final Color color;
//   const _StatCard(
//       {required this.label,
//       required this.value,
//       required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.all(4),
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             Text('$value',
//                 style: AppTheme.headline2.copyWith(color: color)),
//             const SizedBox(height: 4),
//             Text(label,
//                 style: AppTheme.caption.copyWith(color: color)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PickerButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _PickerButton(
//       {required this.icon,
//       required this.label,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(10),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           border: Border.all(color: color),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 28),
//             const SizedBox(height: 6),
//             Text(label,
//                 style: AppTheme.bodyMedium.copyWith(
//                     color: color, fontWeight: FontWeight.w500)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SelectedFileCard extends StatelessWidget {
//   final String name;
//   final VoidCallback onRemove;
//   const _SelectedFileCard(
//       {required this.name, required this.onRemove});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppTheme.primaryLight,
//         borderRadius: BorderRadius.circular(10),
//         border:
//             Border.all(color: AppTheme.primary.withOpacity(0.4)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.insert_drive_file,
//               color: AppTheme.primary, size: 28),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(name,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTheme.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w500,
//                     color: AppTheme.primary)),
//           ),
//           IconButton(
//             onPressed: onRemove,
//             icon: const Icon(Icons.close,
//                 color: AppTheme.error, size: 20),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _ActionButton(
//       {required this.label,
//       required this.color,
//       required this.icon,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       style: OutlinedButton.styleFrom(
//         side: BorderSide(color: color),
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8)),
//       ),
//       icon: Icon(icon, size: 16, color: color),
//       label: Text(label,
//           style: AppTheme.bodySmall.copyWith(color: color)),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String message;
//   const _EmptyState({required this.icon, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 64, color: AppTheme.shimmerBase),
//             const SizedBox(height: 12),
//             Text(message,
//                 textAlign: TextAlign.center,
//                 style: AppTheme.bodyMedium
//                     .copyWith(color: AppTheme.textHint)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// InputDecoration _inputDecoration({String? hint}) {
//   return InputDecoration(
//     hintText: hint,
//     hintStyle: const TextStyle(
//         color: AppTheme.textHint, fontFamily: 'Poppins'),
//     contentPadding:
//         const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppTheme.divider)),
//     enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppTheme.divider)),
//     focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppTheme.primary)),
//     filled: true,
//     fillColor: AppTheme.cardBackground,
//   );
// }














// lib/screens/document/document_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/document_controller.dart';
import '../../models/document_model.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_theme.dart'; // ✅ CORRECT PATH

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with SingleTickerProviderStateMixin {
  late final DocumentController _ctrl;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DocumentController>();
    _tabCtrl = TabController(
        length: _ctrl.isAdmin ? 3 : 2, vsync: this);

    // ✅ Listen for upload-success tab switch signal
    ever(_ctrl.switchToTab, (int idx) {
      if (idx < _tabCtrl.length) _tabCtrl.animateTo(idx);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Documents'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => (_ctrl.isLoadingMy.value || _ctrl.isLoadingAll.value)
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                  onPressed: () {
                    _ctrl.loadMyDocuments();
                    if (_ctrl.isAdmin) _ctrl.loadAllDocuments();
                  },
                )),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'My Docs'),
            const Tab(text: 'Upload'),
            if (_ctrl.isAdmin) const Tab(text: 'Admin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _MyDocumentsTab(ctrl: _ctrl),
          _UploadTab(ctrl: _ctrl),
          if (_ctrl.isAdmin) _AdminTab(ctrl: _ctrl),
        ],
      ),
    );
  }
}

// =====================================================================
// TAB 1 — MY DOCUMENTS
// =====================================================================

class _MyDocumentsTab extends StatelessWidget {
  final DocumentController ctrl;
  const _MyDocumentsTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusFilterBar(
          selected: ctrl.filterStatus,
          onChanged: (v) => ctrl.filterStatus.value = v,
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingMy.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary));
            }
            final docs = ctrl.filteredMyDocuments;
            if (docs.isEmpty) {
              return const _EmptyState(
                  icon: Icons.folder_open, message: 'No documents found');
            }
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: ctrl.loadMyDocuments,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) => _DocumentCard(
                  doc: docs[i],
                  showActions: false,
                  ctrl: ctrl,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// =====================================================================
// TAB 2 — UPLOAD
// =====================================================================

class _UploadTab extends StatefulWidget {
  final DocumentController ctrl;
  const _UploadTab({required this.ctrl});

  @override
  State<_UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<_UploadTab> {
  // ✅ Using ctrl.descriptionCtrl directly — no local controller needed

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.upload_file, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Upload Document',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Document Type *',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<String>(
                value: ctrl.selectedDocType.value.isEmpty
                    ? null
                    : ctrl.selectedDocType.value,
                hint: const Text('Select document type'),
                decoration: _inputDecoration(),
                items: DocumentController.documentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => ctrl.selectedDocType.value = v ?? '',
              )),
          const SizedBox(height: 16),

          Text('Description',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl.descriptionCtrl,
            maxLines: 3,
            decoration: _inputDecoration(hint: 'Enter description (optional)'),
            onChanged: (v) => ctrl.description.value = v,
          ),
          const SizedBox(height: 16),

          Text('Select File *',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => ctrl.selectedFile.value != null
              ? _SelectedFileCard(
                  name: ctrl.selectedFileName.value,
                  onRemove: ctrl.clearFile,
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PickerButton(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            color: AppTheme.primary,
                            onTap: ctrl.pickFromGallery,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerButton(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            color: AppTheme.success,
                            onTap: ctrl.pickFromCamera,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Pick a photo of your document',
                        style: AppTheme.caption),
                  ],
                )),
          const SizedBox(height: 28),

          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      ctrl.isUploading.value ? null : ctrl.uploadDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: ctrl.isUploading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload, color: Colors.white),
                  label: Text(
                    ctrl.isUploading.value
                        ? 'Uploading...'
                        : 'Upload Document',
                    style: AppTheme.buttonText,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// =====================================================================
// TAB 3 — ADMIN
// =====================================================================

class _AdminTab extends StatelessWidget {
  final DocumentController ctrl;
  const _AdminTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppTheme.primary,
            child: const TabBar(
              indicatorColor: Colors.amber,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: 'All Documents'),
                Tab(text: 'Summary'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _AdminDocumentsList(ctrl: ctrl),
                _SummaryTab(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ADMIN — ALL DOCUMENTS with Employee Name dropdown
// =====================================================================

class _AdminDocumentsList extends StatefulWidget {
  final DocumentController ctrl;
  const _AdminDocumentsList({required this.ctrl});

  @override
  State<_AdminDocumentsList> createState() => _AdminDocumentsListState();
}

class _AdminDocumentsListState extends State<_AdminDocumentsList> {
  List<UserModel> _users       = [];
  UserModel?      _selectedUser;  // null = "All Employees"
  bool            _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final list = await ApiService.getAllUsers();
      setState(() {
        _users        = list;
        _loadingUsers = false;
      });
      // ✅ Users loaded — wait for user to select and tap 🔍
    } catch (_) {
      setState(() => _loadingUsers = false);
    }
  }

  /// Called by search button — load based on current dropdown selection
  void _search() {
    if (_selectedUser != null) {
      widget.ctrl.loadAllDocuments(employeeId: _selectedUser!.userId);
    } else {
      widget.ctrl.loadAllDocumentsForAll(_users);
    }
  }

  void _onEmployeeChanged(UserModel? val) {
    // Only update selection — user must tap 🔍 to load
    setState(() => _selectedUser = val);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Employee Dropdown Header ────────────────────
        Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search by Employee',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _loadingUsers
                        ? Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Loading employees...',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'Poppins',
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserModel?>(
                          value: _selectedUser,
                          isExpanded: true,
                          dropdownColor: AppTheme.primaryDark,
                          iconEnabledColor: Colors.white,
                          // ✅ "All Employees" as first item
                          items: [
                            const DropdownMenuItem<UserModel?>(
                              value: null,
                              child: Row(children: [
                                Icon(Icons.people_rounded,
                                    color: Colors.white70, size: 16),
                                SizedBox(width: 8),
                                Text('All Employees',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ),
                            ..._users.map((u) =>
                                DropdownMenuItem<UserModel?>(
                                  value: u,
                                  child: Row(children: [
                                    const Icon(Icons.person_outline_rounded,
                                        color: Colors.white70, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(u.userName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ]),
                                )),
                          ],
                          selectedItemBuilder: (_) => [
                            // "All Employees" selected display
                            const Row(children: [
                              Icon(Icons.people_rounded,
                                  color: Colors.white70, size: 16),
                              SizedBox(width: 8),
                              Text('All Employees',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ]),
                            ..._users.map((u) => Row(children: [
                                  const Icon(Icons.person_rounded,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 8),
                                  Text(u.userName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ])),
                          ],
                          onChanged: _onEmployeeChanged,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ✅ Search button — list only loads on tap
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Obx(() => ElevatedButton(
                          onPressed: _loadingUsers || widget.ctrl.isLoadingAll.value
                              ? null
                              : _search,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            minimumSize: const Size(44, 44),
                            padding: EdgeInsets.zero,
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: widget.ctrl.isLoadingAll.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primary))
                              : const Icon(Icons.search_rounded, size: 22),
                        )),
                  ),
                ],
              ),
          ],
        ),
      ),

        _StatusFilterBar(
          selected: widget.ctrl.filterStatus,
          onChanged: (v) => widget.ctrl.filterStatus.value = v,
        ),

        Expanded(
          child: Obx(() {
            if (widget.ctrl.isLoadingAll.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary));
            }
            final docs = widget.ctrl.filteredAllDocuments;
            if (docs.isEmpty) {
              return _EmptyState(
                icon: Icons.manage_search_rounded,
                message: _selectedUser == null
                    ? 'Select an employee (or All) and tap 🔍'
                    : 'No documents found for ${_selectedUser!.userName}',
              );
            }
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async => _search(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) => _DocumentCard(
                  doc: docs[i],
                  showActions: true,
                  ctrl: widget.ctrl,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// =====================================================================
// ADMIN — SUMMARY TAB with proper date filter
// =====================================================================

class _SummaryTab extends StatefulWidget {
  final DocumentController ctrl;
  const _SummaryTab({required this.ctrl});

  @override
  State<_SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<_SummaryTab> {
  // ✅ Default: from = 1st of current month, to = today
  final Rx<DateTime> _fromDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final Rx<DateTime> _toDate = DateTime.now().obs;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // ✅ Pre-fill dates but do NOT auto-load — user must tap 🔍
    widget.ctrl.summaryFromDate.value =
        DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    widget.ctrl.summaryToDate.value = DateFormat('yyyy-MM-dd').format(now);
    widget.ctrl.summary.value = null; // clear any previous result
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _fromDate.value = picked;
      widget.ctrl.summaryFromDate.value =
          DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _toDate.value = picked;
      widget.ctrl.summaryToDate.value =
          DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return Column(
      children: [
        // ✅ Date filter header matching login_history_screen style
        Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                  child: _DatePickerField(
                      label: 'From',
                      obs: _fromDate,
                      onTap: _pickFrom)),
              const SizedBox(width: 12),
              Expanded(
                  child: _DatePickerField(
                      label: 'To', obs: _toDate, onTap: _pickTo)),
              const SizedBox(width: 10),
              SizedBox(
                width: 44,
                height: 44,
                child: Obx(() => ElevatedButton(
                      onPressed: ctrl.isLoadingSummary.value
                          ? null
                          : ctrl.loadSummary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: ctrl.isLoadingSummary.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary))
                          : const Icon(Icons.search_rounded, size: 22),
                    )),
              ),
            ],
          ),
        ),

        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingSummary.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primary));
            }
            final s = ctrl.summary.value;
            if (s == null) {
              return const _EmptyState(
                  icon: Icons.search_rounded,
                  message: 'Select a date range and tap 🔍 to load summary');
            }
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: ctrl.loadSummary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      _StatCard(
                          label: 'Total',
                          value: s.totalDocuments,
                          color: AppTheme.primary),
                      _StatCard(
                          label: 'Pending',
                          value: s.pendingCount,
                          color: AppTheme.warning),
                      _StatCard(
                          label: 'Verified',
                          value: s.verifiedCount,
                          color: AppTheme.success),
                      _StatCard(
                          label: 'Rejected',
                          value: s.rejectedCount,
                          color: AppTheme.error),
                    ],
                  ),
                  if (s.documents.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Documents', style: AppTheme.headline3),
                    const SizedBox(height: 8),
                    ...s.documents.map((d) => _DocumentCard(
                          doc: d,
                          showActions: true,
                          ctrl: ctrl,
                        )),
                  ] else if (s.byType.isNotEmpty) ...[
                    // ── Document Type Breakdown ─────────────
                    const SizedBox(height: 20),
                    Row(children: [
                      const Icon(Icons.bar_chart_rounded,
                          color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('By Document Type', style: AppTheme.headline3),
                    ]),
                    const SizedBox(height: 10),
                    ...s.byType.map((bt) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: AppTheme.cardDecoration(),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description_outlined,
                                  color: AppTheme.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(bt.documentType,
                                  style: AppTheme.bodyMedium
                                      .copyWith(fontWeight: FontWeight.w600)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.3)),
                              ),
                              child: Text('${bt.count} docs',
                                  style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        )),

                    // ── Per-Employee Breakdown ──────────────
                    // Uses allDocuments loaded in All Documents tab
                    if (ctrl.allDocuments.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(children: [
                        const Icon(Icons.people_alt_rounded,
                            color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('By Employee', style: AppTheme.headline3),
                      ]),
                      const SizedBox(height: 10),
                      ...() {
                        // Group allDocuments by employeeName
                        final Map<String, List<DocumentModel>> grouped = {};
                        for (final d in ctrl.allDocuments) {
                          grouped.putIfAbsent(
                              d.employeeName.isNotEmpty
                                  ? d.employeeName
                                  : 'Employee #${d.employeeId}',
                              () => []).add(d);
                        }
                        return grouped.entries.map((entry) {
                          final empName = entry.key;
                          final empDocs = entry.value;
                          // Count by docType for this employee
                          final typeCount = <String, int>{};
                          for (final d in empDocs) {
                            typeCount[d.documentType] =
                                (typeCount[d.documentType] ?? 0) + 1;
                          }
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: AppTheme.cardDecoration(),
                            child: Theme(
                              data: Theme.of(Get.context!).copyWith(
                                  dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 0),
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      AppTheme.primary.withOpacity(0.15),
                                  child: Text(
                                    empName.isNotEmpty
                                        ? empName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Poppins'),
                                  ),
                                ),
                                title: Text(empName,
                                    style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${empDocs.length} document${empDocs.length > 1 ? 's' : ''}',
                                    style: AppTheme.caption),
                                children: typeCount.entries
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              56, 0, 16, 8),
                                          child: Row(children: [
                                            const Icon(
                                                Icons.subdirectory_arrow_right,
                                                size: 14,
                                                color: AppTheme.textHint),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(e.key,
                                                  style: AppTheme.bodySmall),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text('${e.value}',
                                                  style: AppTheme.caption
                                                      .copyWith(
                                                          color:
                                                              AppTheme.primary,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                            ),
                                          ]),
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                        }).toList();
                      }(),
                    ] else ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline,
                              color: AppTheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Go to All Documents tab → select "All Employees" to see per-employee breakdown here.',
                              style: AppTheme.caption
                                  .copyWith(color: AppTheme.primary),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ] else ...[
                    const SizedBox(height: 24),
                    const _EmptyState(
                      icon: Icons.info_outline_rounded,
                      message: 'No documents in selected date range.',
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// =====================================================================
// DATE PICKER FIELD
// =====================================================================

class _DatePickerField extends StatelessWidget {
  final String label;
  final Rx<DateTime> obs;
  final VoidCallback onTap;

  const _DatePickerField(
      {required this.label, required this.obs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        DateFormat('dd MMM yyyy').format(obs.value),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      )),
                ],
              ),
            ),
            Icon(Icons.calendar_month_outlined,
                size: 16,
                color: Colors.white.withOpacity(0.85)),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// DOCUMENT CARD
// =====================================================================

class _DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final bool showActions;
  final DocumentController ctrl;

  const _DocumentCard({
    required this.doc,
    required this.showActions,
    required this.ctrl,
  });

  Color get _statusColor {
    switch (doc.status.toLowerCase()) {
      case 'verified':
      case 'approved': // ✅ API returns "approved" = verified
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  IconData get _statusIcon {
    switch (doc.status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  String get _statusLabel {
    switch (doc.status.toLowerCase()) {
      case 'approved':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return doc.status.isNotEmpty
            ? doc.status[0].toUpperCase() + doc.status.substring(1)
            : 'Pending';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
            'Are you sure you want to delete this document?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ctrl.deleteDocument(doc.id);
            },
            child: Text('Delete',
                style:
                    AppTheme.bodyMedium.copyWith(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context, String status) {
    final remarksCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$status Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${doc.documentType}',
                style: AppTheme.bodyMedium),
            if (doc.employeeName.isNotEmpty)
              Text('Employee: ${doc.employeeName}',
                  style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: remarksCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Verified'
                  ? AppTheme.success
                  : AppTheme.error,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () {
              Navigator.pop(context);
              ctrl.verifyDocument(
                documentId: doc.id,
                status: status,
                remarks: remarksCtrl.text.trim(),
              );
            },
            child: Text(status,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon,
                          size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(_statusLabel,
                          style: AppTheme.caption.copyWith(
                              color: _statusColor,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(doc.uploadedAt),
                  style: AppTheme.caption,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(doc.documentType, style: AppTheme.labelBold),
            if (doc.employeeName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Employee: ${doc.employeeName}',
                  style: AppTheme.bodySmall),
            ],
            if (doc.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(doc.description, style: AppTheme.bodySmall),
            ],
            if (doc.remarks.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Remarks: ${doc.remarks}',
                  style: AppTheme.caption.copyWith(
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic)),
            ],
            if (doc.fileName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.insert_drive_file,
                      size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(doc.fileName,
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.primary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (doc.status.toLowerCase() == 'pending') ...[
                    Expanded(
                      child: _ActionButton(
                        label: 'Verify',
                        color: AppTheme.success,
                        icon: Icons.check_circle_outline,
                        onTap: () =>
                            _showVerifyDialog(context, 'Verified'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Reject',
                        color: AppTheme.error,
                        icon: Icons.cancel_outlined,
                        onTap: () =>
                            _showVerifyDialog(context, 'Rejected'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  InkWell(
                    onTap: () => _confirmDelete(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.delete_outline,
                          color: AppTheme.textSecondary, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// SHARED WIDGETS
// =====================================================================

class _StatusFilterBar extends StatelessWidget {
  final RxString selected;
  final void Function(String) onChanged;
  const _StatusFilterBar(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Obx(() => Row(
            children: DocumentController.statusFilters.map((s) {
              final isSelected = selected.value == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(s),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textHint,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected) ...[
                          Icon(Icons.check_rounded,
                              size: 12,
                              color: Colors.white),
                          const SizedBox(width: 3),
                        ],
                        Flexible(
                          child: Text(s,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: AppTheme.headline2.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTheme.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PickerButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: AppTheme.bodyMedium.copyWith(
                    color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SelectedFileCard extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  const _SelectedFileCard(
      {required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file,
              color: AppTheme.primary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary)),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close,
                color: AppTheme.error, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: AppTheme.bodySmall.copyWith(color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.shimmerBase),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textHint)),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
        color: AppTheme.textHint, fontFamily: 'Poppins'),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.divider)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.divider)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primary)),
    filled: true,
    fillColor: AppTheme.cardBackground,
  );
}