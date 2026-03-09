// // lib/controllers/document_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// import '../models/document_model.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// // ✅ No AppTheme import here — controllers should not depend on UI theme

// class DocumentController extends GetxController {
//   // =================== STATE ===================

//   final RxList<DocumentModel>     myDocuments   = <DocumentModel>[].obs;
//   final RxList<DocumentModel>     allDocuments  = <DocumentModel>[].obs;
//   final Rxn<DocumentSummaryModel> summary       = Rxn<DocumentSummaryModel>();

//   final RxBool isLoadingMy      = false.obs;
//   final RxBool isLoadingAll     = false.obs;
//   final RxBool isLoadingSummary = false.obs;
//   final RxBool isUploading      = false.obs;

//   // Upload form
//   final RxString selectedDocType  = ''.obs;
//   final RxString description      = ''.obs;
//   final Rxn<XFile> selectedFile   = Rxn<XFile>();
//   final RxString selectedFileName = ''.obs;
//   // ✅ Shared TextEditingController so _resetForm() can directly clear the TextField
//   final TextEditingController descriptionCtrl = TextEditingController();

//   // Filters
//   final RxString filterStatus    = 'All'.obs;
//   final RxString summaryFromDate = ''.obs;
//   final RxString summaryToDate   = ''.obs;

//   // ✅ Tab navigation — screen listens to this to switch tabs
//   final RxInt switchToTab = 0.obs;

//   // =================== HELPERS ===================

//   bool get isAdmin  => StorageService.isAdmin();
//   int  get myUserId => StorageService.getUserId();

//   static const List<String> documentTypes = [
//     'Aadhar Card',
//     'PAN Card',
//     'Passport',
//     'Driving License',
//     'Degree Certificate',
//     'Experience Letter',
//     'Offer Letter',
//     'Relieving Letter',
//     'Bank Passbook',
//     'Other',
//   ];

//   static const List<String> statusFilters = [
//     'All', 'Pending', 'Verified', 'Rejected',
//   ];

//   // =================== LIFECYCLE ===================

//   @override
//   void onInit() {
//     super.onInit();
//     loadMyDocuments();
//     // Admin loads their own docs initially; All Documents tab has its own search
//   }

//   // =================== LOAD ===================

//   Future<void> loadMyDocuments() async {
//     isLoadingMy.value = true;
//     try {
//       // ✅ API requires explicit employeeId — token alone is not enough
//       myDocuments.value = await ApiService.getDocumentList(
//         employeeId: myUserId,
//       );
//     } catch (e) {
//       debugPrint('loadMyDocuments error: $e');
//     } finally {
//       isLoadingMy.value = false;
//     }
//   }

//   Future<void> loadAllDocuments({int? employeeId}) async {
//     isLoadingAll.value = true;
//     try {
//       allDocuments.value = await ApiService.getDocumentList(
//         employeeId: employeeId,
//       );
//     } catch (e) {
//       debugPrint('loadAllDocuments error: $e');
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   /// ✅ Fetch docs for all users and combine (used when "All Employees" selected)
//   Future<void> loadAllDocumentsForAll(List<dynamic> users) async {
//     if (users.isEmpty) return;
//     isLoadingAll.value = true;
//     try {
//       final futures = users.map((u) =>
//           ApiService.getDocumentList(employeeId: u.userId)
//               .catchError((_) => <DocumentModel>[]));
//       final results = await Future.wait(futures);
//       allDocuments.value = results.expand((list) => list).toList();
//     } catch (e) {
//       debugPrint('loadAllDocumentsForAll error: $e');
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   Future<void> loadSummary() async {
//     isLoadingSummary.value = true;
//     try {
//       summary.value = await ApiService.getDocumentSummary(
//         fromDate: summaryFromDate.value.isNotEmpty
//             ? summaryFromDate.value
//             : null,
//         toDate: summaryToDate.value.isNotEmpty
//             ? summaryToDate.value
//             : null,
//       );
//     } catch (e) {
//       debugPrint('loadSummary error: $e');
//     } finally {
//       isLoadingSummary.value = false;
//     }
//   }

//   // =================== FILE PICKER ===================

//   Future<void> pickFromGallery() async {
//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//       );
//       if (picked != null) {
//         selectedFile.value     = picked;
//         selectedFileName.value = picked.name;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Could not pick image: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   Future<void> pickFromCamera() async {
//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 85,
//       );
//       if (picked != null) {
//         selectedFile.value     = picked;
//         selectedFileName.value = picked.name;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Could not open camera: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   void clearFile() {
//     selectedFile.value     = null;
//     selectedFileName.value = '';
//   }

//   // =================== UPLOAD ===================

//   Future<bool> uploadDocument() async {
//     if (selectedDocType.value.isEmpty) {
//       Get.snackbar('Validation', 'Please select document type',
//           snackPosition: SnackPosition.BOTTOM);
//       return false;
//     }
//     if (selectedFile.value == null) {
//       Get.snackbar('Validation', 'Please select a file',
//           snackPosition: SnackPosition.BOTTOM);
//       return false;
//     }

//     isUploading.value = true;
//     try {
//       final result = await ApiService.uploadDocument(
//         employeeId:   myUserId,
//         documentType: selectedDocType.value,
//         description:  description.value,
//         file:         selectedFile.value!,
//       );

//       if (result.success) {
//         Get.snackbar(
//           'Success', 'Document uploaded successfully',
//           snackPosition:   SnackPosition.BOTTOM,
//           backgroundColor: const Color(0xFF22C55E),
//           colorText:       Colors.white,
//         );
//         _resetForm();
//         // ✅ Refresh my docs and signal screen to switch to My Docs tab
//         await loadMyDocuments();
//         switchToTab.value = 0; // 0 = My Docs tab
//         return true;
//       } else {
//         Get.snackbar('Error', result.message,
//             snackPosition: SnackPosition.BOTTOM);
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//       return false;
//     } finally {
//       isUploading.value = false;
//     }
//   }

//   void _resetForm() {
//     selectedDocType.value  = '';
//     description.value      = '';
//     descriptionCtrl.clear(); // ✅ Directly clear the TextField
//     selectedFile.value     = null;
//     selectedFileName.value = '';
//   }

//   @override
//   void onClose() {
//     descriptionCtrl.dispose();
//     super.onClose();
//   }

//   // =================== DELETE ===================

//   Future<void> deleteDocument(int documentId) async {
//     try {
//       final result = await ApiService.deleteDocument(documentId: documentId);
//       if (result.success) {
//         Get.snackbar('Success', 'Document deleted',
//             snackPosition:   SnackPosition.BOTTOM,
//             backgroundColor: const Color(0xFF22C55E),
//             colorText:       Colors.white);
//         allDocuments.removeWhere((d) => d.id == documentId);
//         myDocuments.removeWhere((d) => d.id == documentId);
//       } else {
//         Get.snackbar('Error', result.message,
//             snackPosition: SnackPosition.BOTTOM);
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   // =================== VERIFY ===================

//   Future<void> verifyDocument({
//     required int    documentId,
//     required String status,   // "Verified" or "Rejected" from UI
//     String?         remarks,
//   }) async {
//     // ✅ API only accepts lowercase: "approved" or "rejected"
//     final apiStatus = status.toLowerCase() == 'verified' ? 'approved' : 'rejected';
//     try {
//       final result = await ApiService.verifyDocument(
//         documentId: documentId,
//         status:     apiStatus,
//         remarks:    remarks ?? '',
//       );
//       if (result.success) {
//         Get.snackbar(
//           'Success',
//           'Document ${status.toLowerCase()} successfully',
//           snackPosition:   SnackPosition.BOTTOM,
//           backgroundColor: status == 'Verified'
//               ? const Color(0xFF22C55E)
//               : const Color(0xFFEF4444),
//           colorText: Colors.white,
//         );
//         // ✅ Refresh both lists in parallel
//         await Future.wait([
//           loadMyDocuments(),
//           if (allDocuments.isNotEmpty)
//             loadAllDocuments(
//                 employeeId: allDocuments.first.employeeId),
//         ]);
//       } else {
//         Get.snackbar('Error', result.message,
//             snackPosition: SnackPosition.BOTTOM);
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   // =================== DOWNLOAD ===================

//   Future<void> downloadDocumentPdf(int employeeId) async {
//     try {
//       Get.snackbar('Downloading', 'Preparing PDF...',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: const Duration(seconds: 2));
//       final success =
//           await ApiService.downloadDocumentPdf(employeeId: employeeId);
//       if (!success) {
//         Get.snackbar('Error', 'Download failed',
//             snackPosition: SnackPosition.BOTTOM);
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   // =================== FILTERED LISTS ===================

//   List<DocumentModel> get filteredAllDocuments {
//     if (filterStatus.value == 'All') return allDocuments;
//     return allDocuments
//         .where((d) =>
//             d.status.toLowerCase() == filterStatus.value.toLowerCase())
//         .toList();
//   }

//   List<DocumentModel> get filteredMyDocuments {
//     if (filterStatus.value == 'All') return myDocuments;
//     return myDocuments
//         .where((d) =>
//             d.status.toLowerCase() == filterStatus.value.toLowerCase())
//         .toList();
//   }
// }


















// // lib/controllers/document_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// import '../models/document_model.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// // ✅ No AppTheme import here — controllers should not depend on UI theme

// class DocumentController extends GetxController {
//   // =================== STATE ===================

//   final RxList<DocumentModel>     myDocuments   = <DocumentModel>[].obs;
//   final RxList<DocumentModel>     allDocuments  = <DocumentModel>[].obs;
//   final Rxn<DocumentSummaryModel> summary       = Rxn<DocumentSummaryModel>();

//   final RxBool isLoadingMy      = false.obs;
//   final RxBool isLoadingAll     = false.obs;
//   final RxBool isLoadingSummary = false.obs;
//   final RxBool isUploading      = false.obs;

//   // Upload form
//   final RxString selectedDocType  = ''.obs;
//   final RxString description      = ''.obs;
//   final Rxn<XFile> selectedFile   = Rxn<XFile>();
//   final RxString selectedFileName = ''.obs;
//   // ✅ Shared TextEditingController so _resetForm() can directly clear the TextField
//   final TextEditingController descriptionCtrl = TextEditingController();

//   // Filters
//   final RxString filterStatus    = 'All'.obs;
//   final RxString summaryFromDate = ''.obs;
//   final RxString summaryToDate   = ''.obs;

//   // ✅ Tab navigation — screen listens to this to switch tabs
//   final RxInt switchToTab = 0.obs;

//   // =================== HELPERS ===================

//   bool get isAdmin  => StorageService.isAdmin();
//   int  get myUserId => StorageService.getUserId();

//   static const List<String> documentTypes = [
//     'Aadhar Card',
//     'PAN Card',
//     'Passport',
//     'Driving License',
//     'Degree Certificate',
//     'Experience Letter',
//     'Offer Letter',
//     'Relieving Letter',
//     'Bank Passbook',
//     'Other',
//   ];

//   static const List<String> statusFilters = [
//     'All', 'Pending', 'Verified', 'Rejected',
//   ];

//   // =================== LIFECYCLE ===================

//   @override
//   void onInit() {
//     super.onInit();
//     loadMyDocuments();
//     // Admin loads their own docs initially; All Documents tab has its own search
//   }

//   // =================== LOAD ===================

//   Future<void> loadMyDocuments() async {
//     isLoadingMy.value = true;
//     try {
//       // ✅ API requires explicit employeeId — token alone is not enough
//       myDocuments.value = await ApiService.getDocumentList(
//         employeeId: myUserId,
//       );
//     } catch (e) {
//       debugPrint('loadMyDocuments error: $e');
//     } finally {
//       isLoadingMy.value = false;
//     }
//   }

//   // ✅ Tracks last search so verify can auto-refresh the same result
//   int? _lastSearchedEmployeeId; // null = all employees
//   List<dynamic> _lastSearchedUsers = []; // used when all employees selected

//   Future<void> loadAllDocuments({int? employeeId}) async {
//     _lastSearchedEmployeeId = employeeId;
//     isLoadingAll.value = true;
//     try {
//       allDocuments.value = await ApiService.getDocumentList(
//         employeeId: employeeId,
//       );
//     } catch (e) {
//       debugPrint('loadAllDocuments error: $e');
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   /// Fetch docs for all users and combine (used when "All Employees" selected)
//   Future<void> loadAllDocumentsForAll(List<dynamic> users) async {
//     if (users.isEmpty) return;
//     _lastSearchedEmployeeId = null;
//     _lastSearchedUsers = users;
//     isLoadingAll.value = true;
//     try {
//       final futures = users.map((u) =>
//           ApiService.getDocumentList(employeeId: u.userId)
//               .catchError((_) => <DocumentModel>[]));
//       final results = await Future.wait(futures);
//       allDocuments.value = results.expand((list) => list).toList();
//     } catch (e) {
//       debugPrint('loadAllDocumentsForAll error: $e');
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   Future<void> loadSummary() async {
//     isLoadingSummary.value = true;
//     try {
//       summary.value = await ApiService.getDocumentSummary(
//         fromDate: summaryFromDate.value.isNotEmpty
//             ? summaryFromDate.value
//             : null,
//         toDate: summaryToDate.value.isNotEmpty
//             ? summaryToDate.value
//             : null,
//       );
//     } catch (e) {
//       debugPrint('loadSummary error: $e');
//     } finally {
//       isLoadingSummary.value = false;
//     }
//   }

//   // =================== FILE PICKER ===================

//   Future<void> pickFromGallery() async {
//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//       );
//       if (picked != null) {
//         selectedFile.value     = picked;
//         selectedFileName.value = picked.name;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Could not pick image: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   Future<void> pickFromCamera() async {
//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 85,
//       );
//       if (picked != null) {
//         selectedFile.value     = picked;
//         selectedFileName.value = picked.name;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Could not open camera: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   void clearFile() {
//     selectedFile.value     = null;
//     selectedFileName.value = '';
//   }

//   // =================== UPLOAD ===================

//   Future<bool> uploadDocument() async {
//     if (selectedDocType.value.isEmpty) {
//       Get.snackbar('Validation', 'Please select document type',
//           snackPosition: SnackPosition.BOTTOM);
//       return false;
//     }
//     if (selectedFile.value == null) {
//       Get.snackbar('Validation', 'Please select a file',
//           snackPosition: SnackPosition.BOTTOM);
//       return false;
//     }

//     isUploading.value = true;
//     try {
//       final result = await ApiService.uploadDocument(
//         employeeId:   myUserId,
//         documentType: selectedDocType.value,
//         description:  description.value,
//         file:         selectedFile.value!,
//       );

//       if (result.success) {
//         Get.snackbar(
//           'Success', 'Document uploaded successfully',
//           snackPosition:   SnackPosition.BOTTOM,
//           backgroundColor: const Color(0xFF22C55E),
//           colorText:       Colors.white,
//         );
//         _resetForm();
//         // ✅ Refresh my docs and signal screen to switch to My Docs tab
//         await loadMyDocuments();
//         switchToTab.value = 0; // 0 = My Docs tab
//         return true;
//       } else {
//         Get.snackbar('Error', result.message,
//             snackPosition: SnackPosition.BOTTOM);
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//       return false;
//     } finally {
//       isUploading.value = false;
//     }
//   }

//   void _resetForm() {
//     selectedDocType.value  = '';
//     description.value      = '';
//     descriptionCtrl.clear(); // ✅ Directly clear the TextField
//     selectedFile.value     = null;
//     selectedFileName.value = '';
//   }

//   @override
//   void onClose() {
//     descriptionCtrl.dispose();
//     super.onClose();
//   }

//   // =================== DELETE ===================

//   Future<void> deleteDocument(int documentId) async {
//     try {
//       final result = await ApiService.deleteDocument(documentId: documentId);
//       if (result.success) {
//         Get.snackbar('Success', 'Document deleted',
//             snackPosition:   SnackPosition.BOTTOM,
//             backgroundColor: const Color(0xFF22C55E),
//             colorText:       Colors.white);
//         allDocuments.removeWhere((d) => d.id == documentId);
//         myDocuments.removeWhere((d) => d.id == documentId);
//       } else {
//         Get.snackbar('Error', result.message,
//             snackPosition: SnackPosition.BOTTOM);
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   // =================== VERIFY ===================

//   Future<void> verifyDocument({
//     required int    documentId,
//     required String status,   // "Verified" or "Rejected" from UI
//     String?         remarks,
//   }) async {
//     // ✅ API only accepts lowercase: "approved" or "rejected"
//     final apiStatus = status.toLowerCase() == 'verified' ? 'approved' : 'rejected';
//     try {
//       final result = await ApiService.verifyDocument(
//         documentId: documentId,
//         status:     apiStatus,
//         remarks:    remarks ?? '',
//       );
//       if (result.success) {
//         Get.snackbar(
//           'Success',
//           'Document ${status.toLowerCase()} successfully',
//           snackPosition:   SnackPosition.BOTTOM,
//           backgroundColor: status == 'Verified'
//               ? const Color(0xFF22C55E)
//               : const Color(0xFFEF4444),
//           colorText: Colors.white,
//         );
//         // ✅ Refresh using same search that was last performed
//         final refreshAll = allDocuments.isNotEmpty
//             ? (_lastSearchedEmployeeId != null
//                 ? loadAllDocuments(employeeId: _lastSearchedEmployeeId)
//                 : loadAllDocumentsForAll(_lastSearchedUsers))
//             : Future.value();
//         await Future.wait([loadMyDocuments(), refreshAll]);
//       } else {
//         Get.snackbar('Error', result.message,
//             snackPosition: SnackPosition.BOTTOM);
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   // =================== DOWNLOAD ===================

//   Future<void> downloadDocumentPdf(int employeeId) async {
//     try {
//       Get.snackbar('Downloading', 'Preparing PDF...',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: const Duration(seconds: 2));
//       final success =
//           await ApiService.downloadDocumentPdf(employeeId: employeeId);
//       if (!success) {
//         Get.snackbar('Error', 'Download failed',
//             snackPosition: SnackPosition.BOTTOM);
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   // =================== FILTERED LISTS ===================

//   List<DocumentModel> get filteredAllDocuments {
//     if (filterStatus.value == 'All') return allDocuments;
//     return allDocuments
//         .where((d) =>
//             d.status.toLowerCase() == filterStatus.value.toLowerCase())
//         .toList();
//   }

//   List<DocumentModel> get filteredMyDocuments {
//     if (filterStatus.value == 'All') return myDocuments;
//     return myDocuments
//         .where((d) =>
//             d.status.toLowerCase() == filterStatus.value.toLowerCase())
//         .toList();
//   }
// }








// lib/controllers/document_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/document_model.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
// ✅ No AppTheme import here — controllers should not depend on UI theme

class DocumentController extends GetxController {
  // =================== STATE ===================

  final RxList<DocumentModel>     myDocuments   = <DocumentModel>[].obs;
  final RxList<DocumentModel>     allDocuments  = <DocumentModel>[].obs;
  final Rxn<DocumentSummaryModel> summary       = Rxn<DocumentSummaryModel>();

  final RxBool isLoadingMy      = false.obs;
  final RxBool isLoadingAll     = false.obs;
  final RxBool isLoadingSummary = false.obs;
  final RxBool isUploading      = false.obs;

  // Upload form
  final RxString selectedDocType  = ''.obs;
  final RxString description      = ''.obs;
  final Rxn<XFile> selectedFile   = Rxn<XFile>();
  final RxString selectedFileName = ''.obs;
  // ✅ Shared TextEditingController so _resetForm() can directly clear the TextField
  final TextEditingController descriptionCtrl = TextEditingController();

  // Filters
  final RxString filterStatus    = 'All'.obs;
  final RxString summaryFromDate = ''.obs;
  final RxString summaryToDate   = ''.obs;

  // ✅ Tab navigation — screen listens to this to switch tabs
  final RxInt switchToTab = 0.obs;

  // =================== HELPERS ===================

  bool get isAdmin  => StorageService.isAdmin();
  int  get myUserId => StorageService.getUserId();

  static const List<String> documentTypes = [
    'Aadhar Card',
    'PAN Card',
    'Passport',
    'Driving License',
    'Degree Certificate',
    'Experience Letter',
    'Offer Letter',
    'Relieving Letter',
    'Bank Passbook',
    'Other',
  ];

  static const List<String> statusFilters = [
    'All', 'Pending', 'Verified', 'Rejected',
  ];

  // =================== LIFECYCLE ===================

  @override
  void onInit() {
    super.onInit();
    loadMyDocuments();
    // Admin loads their own docs initially; All Documents tab has its own search
  }

  // =================== LOAD ===================

  Future<void> loadMyDocuments() async {
    isLoadingMy.value = true;
    try {
      // ✅ API requires explicit employeeId — token alone is not enough
      myDocuments.value = await ApiService.getDocumentList(
        employeeId: myUserId,
      );
    } catch (e) {
      debugPrint('loadMyDocuments error: $e');
    } finally {
      isLoadingMy.value = false;
    }
  }

  // ✅ Tracks last search so verify can auto-refresh the same result
  int? _lastSearchedEmployeeId; // null = all employees
  List<dynamic> _lastSearchedUsers = []; // used when all employees selected

  Future<void> loadAllDocuments({int? employeeId}) async {
    _lastSearchedEmployeeId = employeeId;
    isLoadingAll.value = true;
    try {
      allDocuments.value = await ApiService.getDocumentList(
        employeeId: employeeId,
      );
    } catch (e) {
      debugPrint('loadAllDocuments error: $e');
    } finally {
      isLoadingAll.value = false;
    }
  }

  /// Fetch docs for all users and combine (used when "All Employees" selected)
  Future<void> loadAllDocumentsForAll(List<dynamic> users) async {
    if (users.isEmpty) return;
    _lastSearchedEmployeeId = null;
    _lastSearchedUsers = users;
    isLoadingAll.value = true;
    try {
      final futures = users.map((u) =>
          ApiService.getDocumentList(employeeId: u.userId)
              .catchError((_) => <DocumentModel>[]));
      final results = await Future.wait(futures);
      allDocuments.value = results.expand((list) => list).toList();
    } catch (e) {
      debugPrint('loadAllDocumentsForAll error: $e');
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<void> loadSummary() async {
    isLoadingSummary.value = true;
    try {
      summary.value = await ApiService.getDocumentSummary(
        fromDate: summaryFromDate.value.isNotEmpty
            ? summaryFromDate.value
            : null,
        toDate: summaryToDate.value.isNotEmpty
            ? summaryToDate.value
            : null,
      );
    } catch (e) {
      debugPrint('loadSummary error: $e');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // =================== FILE PICKER ===================

  Future<void> pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        selectedFile.value     = picked;
        selectedFileName.value = picked.name;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not pick image: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked != null) {
        selectedFile.value     = picked;
        selectedFileName.value = picked.name;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open camera: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  void clearFile() {
    selectedFile.value     = null;
    selectedFileName.value = '';
  }

  // =================== UPLOAD ===================

  Future<bool> uploadDocument() async {
    if (selectedDocType.value.isEmpty) {
      Get.snackbar('Validation', 'Please select document type',
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (selectedFile.value == null) {
      Get.snackbar('Validation', 'Please select a file',
          snackPosition: SnackPosition.TOP);
      return false;
    }

    isUploading.value = true;
    try {
      final result = await ApiService.uploadDocument(
        employeeId:   myUserId,
        documentType: selectedDocType.value,
        description:  description.value,
        file:         selectedFile.value!,
      );

      if (result.success) {
        Get.snackbar(
          'Success', 'Document uploaded successfully',
          snackPosition:   SnackPosition.TOP,
          backgroundColor: const Color(0xFF22C55E),
          colorText:       Colors.white,
        );
        _resetForm();
        // ✅ Refresh my docs and signal screen to switch to My Docs tab
        await loadMyDocuments();
        switchToTab.value = 0; // 0 = My Docs tab
        return true;
      } else {
        Get.snackbar('Error', result.message,
            snackPosition: SnackPosition.TOP);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  void _resetForm() {
    selectedDocType.value  = '';
    description.value      = '';
    descriptionCtrl.clear(); // ✅ Directly clear the TextField
    selectedFile.value     = null;
    selectedFileName.value = '';
  }

  @override
  void onClose() {
    descriptionCtrl.dispose();
    super.onClose();
  }

  // =================== DELETE ===================

  Future<void> deleteDocument(int documentId) async {
    try {
      final result = await ApiService.deleteDocument(documentId: documentId);
      if (result.success) {
        Get.snackbar('Success', 'Document deleted',
            snackPosition:   SnackPosition.TOP,
            backgroundColor: const Color(0xFF22C55E),
            colorText:       Colors.white);
        allDocuments.removeWhere((d) => d.id == documentId);
        myDocuments.removeWhere((d) => d.id == documentId);
      } else {
        Get.snackbar('Error', result.message,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
    }
  }

  // =================== VERIFY ===================

  Future<void> verifyDocument({
    required int    documentId,
    required String status,   // "Verified" or "Rejected" from UI
    String?         remarks,
  }) async {
    // ✅ API only accepts lowercase: "approved" or "rejected"
    final apiStatus = status.toLowerCase() == 'verified' ? 'approved' : 'rejected';
    try {
      final result = await ApiService.verifyDocument(
        documentId: documentId,
        status:     apiStatus,
        remarks:    remarks ?? '',
      );
      if (result.success) {
        Get.snackbar(
          'Success',
          'Document ${status.toLowerCase()} successfully',
          snackPosition:   SnackPosition.TOP,
          backgroundColor: status == 'Verified'
              ? const Color(0xFF22C55E)
              : const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        // ✅ Refresh using same search that was last performed
        final refreshAll = allDocuments.isNotEmpty
            ? (_lastSearchedEmployeeId != null
                ? loadAllDocuments(employeeId: _lastSearchedEmployeeId)
                : loadAllDocumentsForAll(_lastSearchedUsers))
            : Future.value();
        await Future.wait([loadMyDocuments(), refreshAll]);
      } else {
        Get.snackbar('Error', result.message,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
    }
  }

  // =================== DOWNLOAD ===================

  Future<void> downloadDocumentPdf(int employeeId) async {
    try {
      Get.snackbar('Downloading', 'Preparing PDF...',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
      final success =
          await ApiService.downloadDocumentPdf(employeeId: employeeId);
      if (!success) {
        Get.snackbar('Error', 'Download failed',
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP);
    }
  }

  // =================== FILTERED LISTS ===================

  List<DocumentModel> get filteredAllDocuments {
    if (filterStatus.value == 'All') return allDocuments;
    return allDocuments
        .where((d) =>
            d.status.toLowerCase() == filterStatus.value.toLowerCase())
        .toList();
  }

  List<DocumentModel> get filteredMyDocuments {
    if (filterStatus.value == 'All') return myDocuments;
    return myDocuments
        .where((d) =>
            d.status.toLowerCase() == filterStatus.value.toLowerCase())
        .toList();
  }
}