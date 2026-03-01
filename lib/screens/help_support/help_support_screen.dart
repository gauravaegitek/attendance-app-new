// // lib/screens/help_support/help_support_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/help_support_model.dart';
// import '../../services/api_service.dart';

// class HelpSupportScreen extends StatefulWidget {
//   const HelpSupportScreen({super.key});

//   @override
//   State<HelpSupportScreen> createState() => _HelpSupportScreenState();
// }

// class _HelpSupportScreenState extends State<HelpSupportScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late bool _isAdmin;

//   // FAQs
//   final RxList<FaqModel> _faqs = <FaqModel>[].obs;
//   final RxBool _faqLoading     = true.obs;
//   String _faqSearch            = '';
//   String? _selectedCategory;

//   // Contact (non-admin only)
//   final _subjectCtrl    = TextEditingController();
//   final _messageCtrl    = TextEditingController();
//   final _contactFormKey = GlobalKey<FormState>();
//   final RxBool _sending = false.obs;

//   // Admin: Contact messages
//   final RxList<ContactMessageModel> _messages = <ContactMessageModel>[].obs;
//   final RxBool _messagesLoading               = false.obs;
//   String _messageFilter = 'all'; // 'all' | 'open' | 'resolved'

//   @override
//   void initState() {
//     super.initState();
//     final auth = Get.find<AuthController>();
//     _isAdmin = auth.isAdmin;
//     _tabController = TabController(length: 2, vsync: this);
//     _loadFaqs();
//     if (_isAdmin) _loadMessages();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _subjectCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   // ─── DATA LOADERS ──────────────────────────────────────

//   Future<void> _loadFaqs() async {
//     _faqLoading.value = true;
//     final list = await ApiService.getFaqs();
//     _faqs.assignAll(list);
//     _faqLoading.value = false;
//   }

//   Future<void> _loadMessages() async {
//     _messagesLoading.value = true;
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messagesLoading.value = false;
//   }

//   Future<void> _sendContact() async {
//     if (!_contactFormKey.currentState!.validate()) return;
//     _sending.value = true;
//     final res = await ApiService.sendContactMessage(
//       subject: _subjectCtrl.text.trim(),
//       message: _messageCtrl.text.trim(),
//     );
//     _sending.value = false;
//     if (res.success) {
//       _subjectCtrl.clear();
//       _messageCtrl.clear();
//       _showSnack('Message sent successfully!');
//     } else {
//       _showSnack(
//         res.message.isNotEmpty ? res.message : 'Failed to send',
//         isError: true,
//       );
//     }
//   }

//   Future<void> _resolveMessage(int contactId) async {
//     final res = await ApiService.resolveContact(contactId);
//     if (res.success) {
//       _showSnack('Marked as resolved');
//       _loadMessages();
//     } else {
//       _showSnack('Failed to resolve', isError: true);
//     }
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       msg,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//         isError ? Icons.error_outline : Icons.check_circle_outline,
//         color: Colors.white,
//       ),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   // ─── ADD FAQ DIALOG ────────────────────────────────────

//   void _showAddFaqDialog() {
//     final qCtrl    = TextEditingController();
//     final aCtrl    = TextEditingController();
//     final catCtrl  = TextEditingController();
//     final sortCtrl = TextEditingController(text: '0');
//     final formKey  = GlobalKey<FormState>();
//     final loading  = false.obs;

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
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.quiz_rounded,
//                       color: AppTheme.primary, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text('Add FAQ', style: AppTheme.headline2),
//               ]),
//               const SizedBox(height: 20),
//               _dialogField(qCtrl,   'Question', Icons.help_outline_rounded,
//                   required: true),
//               const SizedBox(height: 12),
//               _dialogField(aCtrl,   'Answer',   Icons.lightbulb_outline_rounded,
//                   required: true, maxLines: 4),
//               const SizedBox(height: 12),
//               _dialogField(catCtrl, 'Category', Icons.category_outlined),
//               const SizedBox(height: 12),
//               _dialogField(sortCtrl,'Sort Order',Icons.sort_rounded,
//                   isNumber: true),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                         onPressed: loading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 loading.value = true;
//                                 final res = await ApiService.createFaq(
//                                   question:  qCtrl.text.trim(),
//                                   answer:    aCtrl.text.trim(),
//                                   category:  catCtrl.text.trim(),
//                                   sortOrder: int.tryParse(
//                                           sortCtrl.text.trim()) ??
//                                       0,
//                                 );
//                                 loading.value = false;
//                                 if (res.success) {
//                                   Get.back();
//                                   _loadFaqs();
//                                   _showSnack('FAQ added successfully!');
//                                 } else {
//                                   _showSnack(
//                                       res.message.isNotEmpty
//                                           ? res.message
//                                           : 'Failed',
//                                       isError: true);
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primary,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: loading.value
//                             ? const SizedBox(
//                                 width: 18, height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Add FAQ',
//                                 style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dialogField(
//     TextEditingController ctrl,
//     String label,
//     IconData icon, {
//     bool required = false,
//     bool isNumber = false,
//     int maxLines  = 1,
//   }) {
//     return TextFormField(
//       controller:   ctrl,
//       maxLines:     maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
//       decoration: InputDecoration(
//         labelText:   label,
//         prefixIcon:  Icon(icon, size: 20),
//         border:      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//       validator: required
//           ? (v) => (v == null || v.trim().isEmpty)
//               ? '$label is required'
//               : null
//           : null,
//     );
//   }

//   // ─── FAQ TAB ───────────────────────────────────────────

//   Widget _buildFaqTab() {
//     return Obx(() {
//       if (_faqLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final allCategories = _faqs
//           .map((f) => f.category)
//           .where((c) => c.isNotEmpty)
//           .toSet()
//           .toList();

//       final filtered = _faqs.where((f) {
//         final matchSearch = _faqSearch.isEmpty ||
//             f.question.toLowerCase().contains(_faqSearch.toLowerCase()) ||
//             f.answer.toLowerCase().contains(_faqSearch.toLowerCase());
//         final matchCat =
//             _selectedCategory == null || f.category == _selectedCategory;
//         return matchSearch && matchCat;
//       }).toList()
//         ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

//       return RefreshIndicator(
//         onRefresh: _loadFaqs,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             // Admin banner
//             if (_isAdmin) ...[
//               _AdminFaqBanner(totalFaqs: _faqs.length),
//               const SizedBox(height: 16),
//             ],

//             // Search
//             TextField(
//               onChanged: (v) => setState(() => _faqSearch = v),
//               decoration: InputDecoration(
//                 hintText:   'Search FAQs…',
//                 prefixIcon: const Icon(Icons.search_rounded,
//                     color: AppTheme.textSecondary),
//                 filled:     true,
//                 fillColor:  AppTheme.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 14),
//               ),
//               style:
//                   const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//             ),
//             const SizedBox(height: 12),

//             // Category chips
//             if (allCategories.isNotEmpty) ...[
//               SizedBox(
//                 height: 38,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _CategoryChip(
//                       label:    'All',
//                       selected: _selectedCategory == null,
//                       onTap:    () =>
//                           setState(() => _selectedCategory = null),
//                     ),
//                     ...allCategories.map((c) => _CategoryChip(
//                           label:    c,
//                           selected: _selectedCategory == c,
//                           onTap: () => setState(() =>
//                               _selectedCategory =
//                                   _selectedCategory == c ? null : c),
//                         )),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],

//             if (filtered.isEmpty)
//               const _EmptyState(
//                 icon:    Icons.quiz_outlined,
//                 message: 'No FAQs found',
//               )
//             else
//               ...filtered.map((faq) => _FaqCard(faq: faq)),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── CONTACT US TAB (non-admin) ────────────────────────

//   Widget _buildContactTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Banner
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               AppTheme.primary.withOpacity(0.12),
//               AppTheme.primary.withOpacity(0.04),
//             ]),
//             borderRadius: BorderRadius.circular(16),
//             border:
//                 Border.all(color: AppTheme.primary.withOpacity(0.2)),
//           ),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color:        AppTheme.primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.support_agent_rounded,
//                   color: Colors.white, size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Need Help?',
//                         style: TextStyle(
//                             fontFamily:  'Poppins',
//                             fontWeight:  FontWeight.w700,
//                             fontSize:    15,
//                             color:       AppTheme.primary)),
//                     const SizedBox(height: 2),
//                     Text(
//                         'Send us a message and we\'ll get back to you shortly.',
//                         style: AppTheme.caption),
//                   ]),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 24),

//         // Info tiles
//         Row(children: [
//           _InfoTile(
//             icon:  Icons.access_time_rounded,
//             label: 'Response Time',
//             value: '< 24 hrs',
//             color: AppTheme.primary,
//           ),
//           const SizedBox(width: 12),
//           _InfoTile(
//             icon:  Icons.support_rounded,
//             label: 'Support',
//             value: 'Mon–Sat',
//             color: AppTheme.success,
//           ),
//         ]),
//         const SizedBox(height: 24),

//         // Form
//         Container(
//           padding:    const EdgeInsets.all(20),
//           decoration: AppTheme.cardDecoration(),
//           child: Form(
//             key: _contactFormKey,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.edit_note_rounded,
//                       color: AppTheme.primary, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text('Send a Message', style: AppTheme.headline3),
//               ]),
//               const SizedBox(height: 16),

//               // Subject
//               TextFormField(
//                 controller: _subjectCtrl,
//                 decoration: InputDecoration(
//                   labelText:  'Subject',
//                   prefixIcon: const Icon(Icons.subject_rounded, size: 20),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(
//                         color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty)
//                         ? 'Subject is required'
//                         : null,
//               ),
//               const SizedBox(height: 14),

//               // Message
//               TextFormField(
//                 controller: _messageCtrl,
//                 maxLines:   5,
//                 decoration: InputDecoration(
//                   labelText: 'Message',
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(bottom: 64),
//                     child:   Icon(Icons.message_outlined, size: 20),
//                   ),
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(
//                         color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty)
//                         ? 'Message is required'
//                         : null,
//               ),
//               const SizedBox(height: 20),

//               Obx(() => SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed:
//                           _sending.value ? null : _sendContact,
//                       icon: _sending.value
//                           ? const SizedBox(
//                               width: 18, height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2))
//                           : const Icon(Icons.send_rounded, size: 18),
//                       label: Text(
//                         _sending.value
//                             ? 'Sending…'
//                             : 'Send Message',
//                         style: const TextStyle(
//                             fontFamily:  'Poppins',
//                             fontWeight:  FontWeight.w600,
//                             fontSize:    15),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16),
//                         shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//         ),
//       ]),
//     );
//   }

//   // ─── MESSAGES TAB (admin) ──────────────────────────────

//   Widget _buildMessagesTab() {
//     return Obx(() {
//       if (_messagesLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final open     = _messages.where((m) => !m.isResolved).length;
//       final resolved = _messages.where((m) =>  m.isResolved).length;

//       final filtered = _messages.where((m) {
//         if (_messageFilter == 'open')     return !m.isResolved;
//         if (_messageFilter == 'resolved') return  m.isResolved;
//         return true;
//       }).toList();

//       return RefreshIndicator(
//         onRefresh: _loadMessages,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             // Stats
//             Row(children: [
//               _StatCard(
//                 label: 'Open',
//                 count: open,
//                 color: AppTheme.warning,
//                 icon:  Icons.mark_email_unread_rounded,
//               ),
//               const SizedBox(width: 12),
//               _StatCard(
//                 label: 'Resolved',
//                 count: resolved,
//                 color: AppTheme.success,
//                 icon:  Icons.check_circle_rounded,
//               ),
//             ]),
//             const SizedBox(height: 16),

//             // Filter chips
//             SizedBox(
//               height: 38,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   _FilterChip2(
//                     label:    'All (${_messages.length})',
//                     selected: _messageFilter == 'all',
//                     onTap: () =>
//                         setState(() => _messageFilter = 'all'),
//                   ),
//                   _FilterChip2(
//                     label:    'Open ($open)',
//                     selected: _messageFilter == 'open',
//                     color:    AppTheme.warning,
//                     onTap: () =>
//                         setState(() => _messageFilter = 'open'),
//                   ),
//                   _FilterChip2(
//                     label:    'Resolved ($resolved)',
//                     selected: _messageFilter == 'resolved',
//                     color:    AppTheme.success,
//                     onTap: () =>
//                         setState(() => _messageFilter = 'resolved'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),

//             if (filtered.isEmpty)
//               _EmptyState(
//                 icon: Icons.inbox_outlined,
//                 message: _messageFilter == 'all'
//                     ? 'No contact messages yet'
//                     : 'No $_messageFilter messages',
//               )
//             else
//               ...filtered.map((msg) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _ContactMessageCard(
//                       msg:       msg,
//                       onResolve: msg.isResolved
//                           ? null
//                           : () => _resolveMessage(msg.id),
//                     ),
//                   )),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── BUILD ─────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final tabs = _isAdmin
//         ? [
//             const Tab(
//                 icon: Icon(Icons.quiz_rounded, size: 18),
//                 text: 'FAQs'),
//             const Tab(
//                 icon: Icon(Icons.inbox_rounded, size: 18),
//                 text: 'Messages'),
//           ]
//         : [
//             const Tab(
//                 icon: Icon(Icons.quiz_rounded, size: 18),
//                 text: 'FAQs'),
//             const Tab(
//                 icon: Icon(Icons.contact_support_rounded, size: 18),
//                 text: 'Contact Us'),
//           ];

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation:       0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Help & Support',
//           style: TextStyle(
//               fontFamily:  'Poppins',
//               fontWeight:  FontWeight.w700,
//               fontSize:    18,
//               color:       AppTheme.textPrimary),
//         ),
//         actions: [
//           if (_isAdmin)
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (_, __) => _tabController.index == 0
//                   ? IconButton(
//                       icon: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primaryLight,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.add_rounded,
//                             color: AppTheme.primary, size: 20),
//                       ),
//                       onPressed: _showAddFaqDialog,
//                       tooltip: 'Add FAQ',
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           const SizedBox(width: 4),
//         ],
//         bottom: TabBar(
//           controller:          _tabController,
//           tabs:                tabs,
//           labelColor:          AppTheme.primary,
//           unselectedLabelColor: AppTheme.textSecondary,
//           indicatorColor:      AppTheme.primary,
//           indicatorWeight:     3,
//           labelStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w600,
//               fontSize:   12),
//           unselectedLabelStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w500,
//               fontSize:   12),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _isAdmin
//             ? [_buildFaqTab(), _buildMessagesTab()]
//             : [_buildFaqTab(), _buildContactTab()],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────
// //  SUB-WIDGETS
// // ─────────────────────────────────────────────────────────

// class _AdminFaqBanner extends StatelessWidget {
//   final int totalFaqs;
//   const _AdminFaqBanner({required this.totalFaqs});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           AppTheme.primary.withOpacity(0.15),
//           AppTheme.primary.withOpacity(0.05),
//         ]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//       ),
//       child: Row(children: [
//         const Icon(Icons.admin_panel_settings_rounded,
//             color: AppTheme.primary, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Admin View — $totalFaqs FAQ${totalFaqs == 1 ? '' : 's'} total. Tap + to add new.',
//             style: const TextStyle(
//                 fontFamily:  'Poppins',
//                 fontSize:    13,
//                 fontWeight:  FontWeight.w500,
//                 color:       AppTheme.primary),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String   label;
//   final String   value;
//   final Color    color;

//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 10),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   11,
//                     color:      AppTheme.textSecondary)),
//             Text(value,
//                 style: TextStyle(
//                     fontFamily:  'Poppins',
//                     fontSize:    13,
//                     fontWeight:  FontWeight.w700,
//                     color:       color)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String   label;
//   final int      count;
//   final Color    color;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   22,
//                   fontWeight: FontWeight.w800,
//                   color:      color),
//             ),
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   12,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _CategoryChip extends StatelessWidget {
//   final String       label;
//   final bool         selected;
//   final VoidCallback onTap;

//   const _CategoryChip({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin:  const EdgeInsets.only(right: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           decoration: BoxDecoration(
//             color: selected ? AppTheme.primary : AppTheme.cardBackground,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: selected ? AppTheme.primary : AppTheme.divider,
//             ),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize:   12,
//               fontWeight: FontWeight.w600,
//               color: selected ? Colors.white : AppTheme.textSecondary,
//             ),
//           ),
//         ),
//       );
// }

// class _FilterChip2 extends StatelessWidget {
//   final String       label;
//   final bool         selected;
//   final VoidCallback onTap;
//   final Color        color;

//   const _FilterChip2({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//     this.color = AppTheme.primary,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin:  const EdgeInsets.only(right: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           decoration: BoxDecoration(
//             color: selected ? color : AppTheme.cardBackground,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: selected ? color : AppTheme.divider,
//             ),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize:   12,
//               fontWeight: FontWeight.w600,
//               color: selected ? Colors.white : AppTheme.textSecondary,
//             ),
//           ),
//         ),
//       );
// }

// class _FaqCard extends StatefulWidget {
//   final FaqModel faq;
//   const _FaqCard({required this.faq});

//   @override
//   State<_FaqCard> createState() => _FaqCardState();
// }

// class _FaqCardState extends State<_FaqCard> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin:     const EdgeInsets.only(bottom: 10),
//       decoration: AppTheme.cardDecoration(),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: ExpansionTile(
//           tilePadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           leading: Container(
//             width:  36,
//             height: 36,
//             decoration: BoxDecoration(
//               color:        AppTheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.help_outline_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           title: Text(
//             widget.faq.question,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize:   14,
//                 color:      AppTheme.textPrimary),
//           ),
//           trailing: AnimatedRotation(
//             turns:    _expanded ? 0.5 : 0,
//             duration: const Duration(milliseconds: 200),
//             child: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: AppTheme.textSecondary),
//           ),
//           onExpansionChanged: (v) => setState(() => _expanded = v),
//           children: [
//             const Divider(height: 1, color: AppTheme.divider),
//             const SizedBox(height: 12),
//             Text(
//               widget.faq.answer,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   13,
//                   color:      AppTheme.textSecondary,
//                   height:     1.5),
//             ),
//             if (widget.faq.category.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.faq.category,
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize:   11,
//                         color:      AppTheme.primary,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactMessageCard extends StatelessWidget {
//   final ContactMessageModel msg;
//   final VoidCallback?       onResolve;

//   const _ContactMessageCard({required this.msg, this.onResolve});

//   @override
//   Widget build(BuildContext context) {
//     final dateStr =
//         DateFormat('dd MMM yyyy, hh:mm a').format(msg.createdAt);

//     return Container(
//       padding:    const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         // Header row
//         Row(children: [
//           Container(
//             width:  8, height: 8,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success
//                   : AppTheme.warning,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               msg.subject.isNotEmpty ? msg.subject : '(No Subject)',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize:   14,
//                   color:      AppTheme.textPrimary),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success.withOpacity(0.12)
//                   : AppTheme.warning.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               msg.isResolved ? 'Resolved' : 'Open',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   11,
//                   fontWeight: FontWeight.w700,
//                   color: msg.isResolved
//                       ? AppTheme.success
//                       : AppTheme.warning),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 8),

//         // Sender
//         if (msg.senderName.isNotEmpty || msg.senderEmail.isNotEmpty)
//           Row(children: [
//             const Icon(Icons.person_outline_rounded,
//                 size: 14, color: AppTheme.textSecondary),
//             const SizedBox(width: 4),
//             Text(
//               [msg.senderName, msg.senderEmail]
//                   .where((s) => s.isNotEmpty)
//                   .join(' · '),
//               style: AppTheme.caption,
//             ),
//           ]),

//         const SizedBox(height: 8),

//         // Message body
//         Container(
//           padding:    const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color:        AppTheme.background,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             msg.message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 color:      AppTheme.textSecondary,
//                 height:     1.5),
//           ),
//         ),
//         const SizedBox(height: 10),

//         // Footer
//         Row(children: [
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           Text(dateStr, style: AppTheme.caption),
//           const Spacer(),
//           if (onResolve != null)
//             GestureDetector(
//               onTap: onResolve,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppTheme.success.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: AppTheme.success.withOpacity(0.3)),
//                 ),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.check_circle_outline_rounded,
//                       size: 14, color: AppTheme.success),
//                   const SizedBox(width: 4),
//                   const Text('Resolve',
//                       style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize:   12,
//                           fontWeight: FontWeight.w600,
//                           color:      AppTheme.success)),
//                 ]),
//               ),
//             ),
//         ]),
//       ]),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   message;

//   const _EmptyState({required this.icon, required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(children: [
//             Icon(icon, size: 64, color: AppTheme.shimmerBase),
//             const SizedBox(height: 16),
//             Text(message,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   15,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ),
//       );
// }









// // lib/screens/help_support/help_support_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/help_support_model.dart';
// import '../../services/api_service.dart';

// class HelpSupportScreen extends StatefulWidget {
//   const HelpSupportScreen({super.key});

//   @override
//   State<HelpSupportScreen> createState() => _HelpSupportScreenState();
// }

// class _HelpSupportScreenState extends State<HelpSupportScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late bool _isAdmin;

//   // FAQs
//   final RxList<FaqModel> _faqs = <FaqModel>[].obs;
//   final RxBool _faqLoading     = true.obs;
//   String _faqSearch            = '';
//   String? _selectedCategory;

//   // Contact (non-admin only)
//   final _subjectCtrl    = TextEditingController();
//   final _messageCtrl    = TextEditingController();
//   final _contactFormKey = GlobalKey<FormState>();
//   final RxBool _sending = false.obs;

//   // Admin: Contact messages
//   final RxList<ContactMessageModel> _messages = <ContactMessageModel>[].obs;
//   final RxBool _messagesLoading               = false.obs;
//   String _messageFilter = 'all'; // 'all' | 'open' | 'resolved'

//   @override
//   void initState() {
//     super.initState();
//     final auth = Get.find<AuthController>();
//     _isAdmin = auth.isAdmin;
//     _tabController = TabController(length: 2, vsync: this);
//     _loadFaqs();
//     if (_isAdmin) _loadMessages();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _subjectCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   // ─── DATA LOADERS ──────────────────────────────────────

//   Future<void> _loadFaqs() async {
//     _faqLoading.value = true;
//     final list = await ApiService.getFaqs();
//     _faqs.assignAll(list);
//     _faqLoading.value = false;
//   }

//   Future<void> _loadMessages() async {
//     _messagesLoading.value = true;
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messagesLoading.value = false;
//   }

//   // Background refresh — bina loading spinner ke
//   Future<void> _refreshMessagesQuiet() async {
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messages.refresh();
//   }

//   Future<void> _sendContact() async {
//     if (!_contactFormKey.currentState!.validate()) return;
//     _sending.value = true;
//     final res = await ApiService.sendContactMessage(
//       subject: _subjectCtrl.text.trim(),
//       message: _messageCtrl.text.trim(),
//     );
//     _sending.value = false;
//     if (res.success) {
//       _subjectCtrl.clear();
//       _messageCtrl.clear();
//       _showSnack('Message sent successfully!');
//     } else {
//       _showSnack(
//         res.message.isNotEmpty ? res.message : 'Failed to send',
//         isError: true,
//       );
//     }
//   }

//   // ✅ FIXED: Optimistic update — UI turant change, phir API call
//   Future<void> _resolveMessage(int contactId) async {
//     // Step 1: Turant UI update karo
//     final idx = _messages.indexWhere((m) => m.id == contactId);
//     if (idx != -1) {
//       final old = _messages[idx];
//       _messages[idx] = ContactMessageModel(
//         id:          old.id,
//         subject:     old.subject,
//         message:     old.message,
//         senderName:  old.senderName,
//         senderEmail: old.senderEmail,
//         isResolved:  true,
//         createdAt:   old.createdAt,
//       );
//       _messages.refresh();
//     }

//     // Step 2: API call
//     final res = await ApiService.resolveContact(contactId);

//     if (res.success) {
//       _showSnack('Marked as resolved');
//       _refreshMessagesQuiet(); // background refresh
//     } else {
//       // Revert if API failed
//       if (idx != -1) {
//         final cur = _messages[idx];
//         _messages[idx] = ContactMessageModel(
//           id:          cur.id,
//           subject:     cur.subject,
//           message:     cur.message,
//           senderName:  cur.senderName,
//           senderEmail: cur.senderEmail,
//           isResolved:  false,
//           createdAt:   cur.createdAt,
//         );
//         _messages.refresh();
//       }
//       _showSnack('Failed to resolve', isError: true);
//     }
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       msg,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//         isError ? Icons.error_outline : Icons.check_circle_outline,
//         color: Colors.white,
//       ),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   // ─── ADD FAQ DIALOG ────────────────────────────────────

//   void _showAddFaqDialog() {
//     final qCtrl    = TextEditingController();
//     final aCtrl    = TextEditingController();
//     final catCtrl  = TextEditingController();
//     final sortCtrl = TextEditingController(text: '0');
//     final formKey  = GlobalKey<FormState>();
//     final loading  = false.obs;

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
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.quiz_rounded,
//                       color: AppTheme.primary, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text('Add FAQ', style: AppTheme.headline2),
//               ]),
//               const SizedBox(height: 20),
//               _dialogField(qCtrl,    'Question',   Icons.help_outline_rounded,
//                   required: true),
//               const SizedBox(height: 12),
//               _dialogField(aCtrl,    'Answer',     Icons.lightbulb_outline_rounded,
//                   required: true, maxLines: 4),
//               const SizedBox(height: 12),
//               _dialogField(catCtrl,  'Category',   Icons.category_outlined),
//               const SizedBox(height: 12),
//               _dialogField(sortCtrl, 'Sort Order', Icons.sort_rounded,
//                   isNumber: true),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                         onPressed: loading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 loading.value = true;
//                                 final res = await ApiService.createFaq(
//                                   question:  qCtrl.text.trim(),
//                                   answer:    aCtrl.text.trim(),
//                                   category:  catCtrl.text.trim(),
//                                   sortOrder: int.tryParse(
//                                           sortCtrl.text.trim()) ?? 0,
//                                 );
//                                 loading.value = false;
//                                 if (res.success) {
//                                   Get.back();
//                                   _loadFaqs();
//                                   _showSnack('FAQ added successfully!');
//                                 } else {
//                                   _showSnack(
//                                       res.message.isNotEmpty
//                                           ? res.message
//                                           : 'Failed',
//                                       isError: true);
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primary,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: loading.value
//                             ? const SizedBox(
//                                 width: 18, height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Add FAQ',
//                                 style: TextStyle(
//                                     fontFamily:  'Poppins',
//                                     color:       Colors.white,
//                                     fontWeight:  FontWeight.w600)),
//                       )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dialogField(
//     TextEditingController ctrl,
//     String label,
//     IconData icon, {
//     bool required = false,
//     bool isNumber = false,
//     int maxLines  = 1,
//   }) {
//     return TextFormField(
//       controller:   ctrl,
//       maxLines:     maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
//       decoration: InputDecoration(
//         labelText:   label,
//         prefixIcon:  Icon(icon, size: 20),
//         border:      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//       validator: required
//           ? (v) => (v == null || v.trim().isEmpty)
//               ? '$label is required'
//               : null
//           : null,
//     );
//   }

//   // ─── FAQ TAB ───────────────────────────────────────────

//   Widget _buildFaqTab() {
//     return Obx(() {
//       if (_faqLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final allCategories = _faqs
//           .map((f) => f.category)
//           .where((c) => c.isNotEmpty)
//           .toSet()
//           .toList();

//       final filtered = _faqs.where((f) {
//         final matchSearch = _faqSearch.isEmpty ||
//             f.question.toLowerCase().contains(_faqSearch.toLowerCase()) ||
//             f.answer.toLowerCase().contains(_faqSearch.toLowerCase());
//         final matchCat =
//             _selectedCategory == null || f.category == _selectedCategory;
//         return matchSearch && matchCat;
//       }).toList()
//         ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

//       return RefreshIndicator(
//         onRefresh: _loadFaqs,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             if (_isAdmin) ...[
//               _AdminFaqBanner(totalFaqs: _faqs.length),
//               const SizedBox(height: 16),
//             ],
//             TextField(
//               onChanged: (v) => setState(() => _faqSearch = v),
//               decoration: InputDecoration(
//                 hintText:   'Search FAQs…',
//                 prefixIcon: const Icon(Icons.search_rounded,
//                     color: AppTheme.textSecondary),
//                 filled:     true,
//                 fillColor:  AppTheme.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 14),
//               ),
//               style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//             ),
//             const SizedBox(height: 12),
//             if (allCategories.isNotEmpty) ...[
//               SizedBox(
//                 height: 38,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _CategoryChip(
//                       label:    'All',
//                       selected: _selectedCategory == null,
//                       onTap:    () =>
//                           setState(() => _selectedCategory = null),
//                     ),
//                     ...allCategories.map((c) => _CategoryChip(
//                           label:    c,
//                           selected: _selectedCategory == c,
//                           onTap: () => setState(() =>
//                               _selectedCategory =
//                                   _selectedCategory == c ? null : c),
//                         )),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//             if (filtered.isEmpty)
//               const _EmptyState(
//                 icon:    Icons.quiz_outlined,
//                 message: 'No FAQs found',
//               )
//             else
//               ...filtered.map((faq) => _FaqCard(faq: faq)),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── CONTACT US TAB (non-admin) ────────────────────────

//   Widget _buildContactTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               AppTheme.primary.withOpacity(0.12),
//               AppTheme.primary.withOpacity(0.04),
//             ]),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//           ),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color:        AppTheme.primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.support_agent_rounded,
//                   color: Colors.white, size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Need Help?',
//                         style: TextStyle(
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w700,
//                             fontSize:   15,
//                             color:      AppTheme.primary)),
//                     const SizedBox(height: 2),
//                     Text(
//                         'Send us a message and we\'ll get back to you shortly.',
//                         style: AppTheme.caption),
//                   ]),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 24),
//         Row(children: [
//           _InfoTile(
//             icon:  Icons.access_time_rounded,
//             label: 'Response Time',
//             value: '< 24 hrs',
//             color: AppTheme.primary,
//           ),
//           const SizedBox(width: 12),
//           _InfoTile(
//             icon:  Icons.support_rounded,
//             label: 'Support',
//             value: 'Mon–Sat',
//             color: AppTheme.success,
//           ),
//         ]),
//         const SizedBox(height: 24),
//         Container(
//           padding:    const EdgeInsets.all(20),
//           decoration: AppTheme.cardDecoration(),
//           child: Form(
//             key: _contactFormKey,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.edit_note_rounded,
//                       color: AppTheme.primary, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text('Send a Message', style: AppTheme.headline3),
//               ]),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _subjectCtrl,
//                 decoration: InputDecoration(
//                   labelText:  'Subject',
//                   prefixIcon: const Icon(Icons.subject_rounded, size: 20),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty)
//                         ? 'Subject is required'
//                         : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _messageCtrl,
//                 maxLines:   5,
//                 decoration: InputDecoration(
//                   labelText: 'Message',
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(bottom: 64),
//                     child:   Icon(Icons.message_outlined, size: 20),
//                   ),
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty)
//                         ? 'Message is required'
//                         : null,
//               ),
//               const SizedBox(height: 20),
//               Obx(() => SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _sending.value ? null : _sendContact,
//                       icon: _sending.value
//                           ? const SizedBox(
//                               width: 18, height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Icon(Icons.send_rounded, size: 18),
//                       label: Text(
//                         _sending.value ? 'Sending…' : 'Send Message',
//                         style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                             fontSize:   15),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//         ),
//       ]),
//     );
//   }

//   // ─── MESSAGES TAB (admin) ──────────────────────────────

//   Widget _buildMessagesTab() {
//     return Obx(() {
//       if (_messagesLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final open     = _messages.where((m) => !m.isResolved).length;
//       final resolved = _messages.where((m) =>  m.isResolved).length;

//       final filtered = _messages.where((m) {
//         if (_messageFilter == 'open')     return !m.isResolved;
//         if (_messageFilter == 'resolved') return  m.isResolved;
//         return true;
//       }).toList();

//       return RefreshIndicator(
//         onRefresh: _loadMessages,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             Row(children: [
//               _StatCard(
//                 label: 'Open',
//                 count: open,
//                 color: AppTheme.warning,
//                 icon:  Icons.mark_email_unread_rounded,
//               ),
//               const SizedBox(width: 12),
//               _StatCard(
//                 label: 'Resolved',
//                 count: resolved,
//                 color: AppTheme.success,
//                 icon:  Icons.check_circle_rounded,
//               ),
//             ]),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 38,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   _FilterChip2(
//                     label:    'All (${_messages.length})',
//                     selected: _messageFilter == 'all',
//                     onTap: () => setState(() => _messageFilter = 'all'),
//                   ),
//                   _FilterChip2(
//                     label:    'Open ($open)',
//                     selected: _messageFilter == 'open',
//                     color:    AppTheme.warning,
//                     onTap: () => setState(() => _messageFilter = 'open'),
//                   ),
//                   _FilterChip2(
//                     label:    'Resolved ($resolved)',
//                     selected: _messageFilter == 'resolved',
//                     color:    AppTheme.success,
//                     onTap: () =>
//                         setState(() => _messageFilter = 'resolved'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             if (filtered.isEmpty)
//               _EmptyState(
//                 icon: Icons.inbox_outlined,
//                 message: _messageFilter == 'all'
//                     ? 'No contact messages yet'
//                     : 'No $_messageFilter messages',
//               )
//             else
//               ...filtered.map((msg) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _ContactMessageCard(
//                       msg:       msg,
//                       onResolve: msg.isResolved
//                           ? null
//                           : () => _resolveMessage(msg.id),
//                     ),
//                   )),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── BUILD ─────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final tabs = _isAdmin
//         ? [
//             const Tab(
//                 icon: Icon(Icons.quiz_rounded,  size: 18), text: 'FAQs'),
//             const Tab(
//                 icon: Icon(Icons.inbox_rounded, size: 18), text: 'Messages'),
//           ]
//         : [
//             const Tab(
//                 icon: Icon(Icons.quiz_rounded,            size: 18), text: 'FAQs'),
//             const Tab(
//                 icon: Icon(Icons.contact_support_rounded, size: 18), text: 'Contact Us'),
//           ];

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation:       0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Help & Support',
//           style: TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w700,
//               fontSize:   18,
//               color:      AppTheme.textPrimary),
//         ),
//         actions: [
//           if (_isAdmin)
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (_, __) => _tabController.index == 0
//                   ? IconButton(
//                       icon: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color:        AppTheme.primaryLight,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.add_rounded,
//                             color: AppTheme.primary, size: 20),
//                       ),
//                       onPressed: _showAddFaqDialog,
//                       tooltip: 'Add FAQ',
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           const SizedBox(width: 4),
//         ],
//         bottom: TabBar(
//           controller:           _tabController,
//           tabs:                 tabs,
//           labelColor:           AppTheme.primary,
//           unselectedLabelColor: AppTheme.textSecondary,
//           indicatorColor:       AppTheme.primary,
//           indicatorWeight:      3,
//           labelStyle: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
//           unselectedLabelStyle: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _isAdmin
//             ? [_buildFaqTab(), _buildMessagesTab()]
//             : [_buildFaqTab(), _buildContactTab()],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────
// //  SUB-WIDGETS
// // ─────────────────────────────────────────────────────────

// class _AdminFaqBanner extends StatelessWidget {
//   final int totalFaqs;
//   const _AdminFaqBanner({required this.totalFaqs});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           AppTheme.primary.withOpacity(0.15),
//           AppTheme.primary.withOpacity(0.05),
//         ]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//       ),
//       child: Row(children: [
//         const Icon(Icons.admin_panel_settings_rounded,
//             color: AppTheme.primary, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Admin View — $totalFaqs FAQ${totalFaqs == 1 ? '' : 's'} total. Tap + to add new.',
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 fontWeight: FontWeight.w500,
//                 color:      AppTheme.primary),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String   label;
//   final String   value;
//   final Color    color;

//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 10),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   11,
//                     color:      AppTheme.textSecondary)),
//             Text(value,
//                 style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   13,
//                     fontWeight: FontWeight.w700,
//                     color:      color)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String   label;
//   final int      count;
//   final Color    color;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   22,
//                   fontWeight: FontWeight.w800,
//                   color:      color),
//             ),
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   12,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _CategoryChip extends StatelessWidget {
//   final String       label;
//   final bool         selected;
//   final VoidCallback onTap;

//   const _CategoryChip({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin:  const EdgeInsets.only(right: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           decoration: BoxDecoration(
//             color: selected ? AppTheme.primary : AppTheme.cardBackground,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//                 color: selected ? AppTheme.primary : AppTheme.divider),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize:   12,
//               fontWeight: FontWeight.w600,
//               color: selected ? Colors.white : AppTheme.textSecondary,
//             ),
//           ),
//         ),
//       );
// }

// class _FilterChip2 extends StatelessWidget {
//   final String       label;
//   final bool         selected;
//   final VoidCallback onTap;
//   final Color        color;

//   const _FilterChip2({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//     this.color = AppTheme.primary,
//   });

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin:  const EdgeInsets.only(right: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           decoration: BoxDecoration(
//             color: selected ? color : AppTheme.cardBackground,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//                 color: selected ? color : AppTheme.divider),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize:   12,
//               fontWeight: FontWeight.w600,
//               color: selected ? Colors.white : AppTheme.textSecondary,
//             ),
//           ),
//         ),
//       );
// }

// class _FaqCard extends StatefulWidget {
//   final FaqModel faq;
//   const _FaqCard({required this.faq});

//   @override
//   State<_FaqCard> createState() => _FaqCardState();
// }

// class _FaqCardState extends State<_FaqCard> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin:     const EdgeInsets.only(bottom: 10),
//       decoration: AppTheme.cardDecoration(),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: ExpansionTile(
//           tilePadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           leading: Container(
//             width: 36, height: 36,
//             decoration: BoxDecoration(
//               color:        AppTheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.help_outline_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           title: Text(
//             widget.faq.question,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize:   14,
//                 color:      AppTheme.textPrimary),
//           ),
//           trailing: AnimatedRotation(
//             turns:    _expanded ? 0.5 : 0,
//             duration: const Duration(milliseconds: 200),
//             child: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: AppTheme.textSecondary),
//           ),
//           onExpansionChanged: (v) => setState(() => _expanded = v),
//           children: [
//             const Divider(height: 1, color: AppTheme.divider),
//             const SizedBox(height: 12),
//             Text(
//               widget.faq.answer,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   13,
//                   color:      AppTheme.textSecondary,
//                   height:     1.5),
//             ),
//             if (widget.faq.category.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.faq.category,
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize:   11,
//                         color:      AppTheme.primary,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactMessageCard extends StatelessWidget {
//   final ContactMessageModel msg;
//   final VoidCallback?       onResolve;

//   const _ContactMessageCard({required this.msg, this.onResolve});

//   @override
//   Widget build(BuildContext context) {
//     final dateStr =
//         DateFormat('dd MMM yyyy, hh:mm a').format(msg.createdAt);

//     return Container(
//       padding:    const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         Row(children: [
//           Container(
//             width: 8, height: 8,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: msg.isResolved ? AppTheme.success : AppTheme.warning,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               msg.subject.isNotEmpty ? msg.subject : '(No Subject)',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize:   14,
//                   color:      AppTheme.textPrimary),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success.withOpacity(0.12)
//                   : AppTheme.warning.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               msg.isResolved ? 'Resolved' : 'Open',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   11,
//                   fontWeight: FontWeight.w700,
//                   color: msg.isResolved ? AppTheme.success : AppTheme.warning),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 8),

//         if (msg.senderName.isNotEmpty || msg.senderEmail.isNotEmpty)
//           Row(children: [
//             const Icon(Icons.person_outline_rounded,
//                 size: 14, color: AppTheme.textSecondary),
//             const SizedBox(width: 4),
//             Text(
//               [msg.senderName, msg.senderEmail]
//                   .where((s) => s.isNotEmpty)
//                   .join(' · '),
//               style: AppTheme.caption,
//             ),
//           ]),

//         const SizedBox(height: 8),

//         Container(
//           padding:    const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color:        AppTheme.background,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             msg.message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 color:      AppTheme.textSecondary,
//                 height:     1.5),
//           ),
//         ),
//         const SizedBox(height: 10),

//         Row(children: [
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           Text(dateStr, style: AppTheme.caption),
//           const Spacer(),
//           if (onResolve != null)
//             GestureDetector(
//               onTap: onResolve,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppTheme.success.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: AppTheme.success.withOpacity(0.3)),
//                 ),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.check_circle_outline_rounded,
//                       size: 14, color: AppTheme.success),
//                   const SizedBox(width: 4),
//                   const Text('Resolve',
//                       style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize:   12,
//                           fontWeight: FontWeight.w600,
//                           color:      AppTheme.success)),
//                 ]),
//               ),
//             ),
//         ]),
//       ]),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   message;

//   const _EmptyState({required this.icon, required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(children: [
//             Icon(icon, size: 64, color: AppTheme.shimmerBase),
//             const SizedBox(height: 16),
//             Text(message,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   15,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ),
//       );
// }















// // lib/screens/help_support/help_support_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/help_support_model.dart';
// import '../../services/api_service.dart';

// class HelpSupportScreen extends StatefulWidget {
//   const HelpSupportScreen({super.key});

//   @override
//   State<HelpSupportScreen> createState() => _HelpSupportScreenState();
// }

// class _HelpSupportScreenState extends State<HelpSupportScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late bool _isAdmin;

//   // FAQs
//   final RxList<FaqModel> _faqs = <FaqModel>[].obs;
//   final RxBool _faqLoading     = true.obs;
//   String _faqSearch            = '';
//   String? _selectedCategory;

//   // Contact (non-admin only)
//   final _subjectCtrl    = TextEditingController();
//   final _messageCtrl    = TextEditingController();
//   final _contactFormKey = GlobalKey<FormState>();
//   final RxBool _sending = false.obs;

//   // Admin: Contact messages
//   final RxList<ContactMessageModel> _messages = <ContactMessageModel>[].obs;
//   final RxBool _messagesLoading               = false.obs;
//   String _messageFilter = 'all';

//   // User: My messages
//   final RxList<ContactMessageModel> _myMessages = <ContactMessageModel>[].obs;
//   final RxBool _myMessagesLoading               = false.obs;

//   @override
//   void initState() {
//     super.initState();
//     final auth = Get.find<AuthController>();
//     _isAdmin = auth.isAdmin;
//     _tabController = TabController(length: 2, vsync: this);
//     _loadFaqs();
//     if (_isAdmin) {
//       _loadMessages();
//     } else {
//       _loadMyMessages();
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _subjectCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   // ─── DATA LOADERS ──────────────────────────────────────

//   Future<void> _loadFaqs() async {
//     _faqLoading.value = true;
//     final list = await ApiService.getFaqs();
//     _faqs.assignAll(list);
//     _faqLoading.value = false;
//   }

//   Future<void> _loadMessages() async {
//     _messagesLoading.value = true;
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messagesLoading.value = false;
//   }

//   Future<void> _loadMyMessages() async {
//     _myMessagesLoading.value = true;
//     final list = await ApiService.getMyContactMessages();
//     _myMessages.assignAll(list);
//     _myMessagesLoading.value = false;
//   }

//   Future<void> _refreshMessagesQuiet() async {
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messages.refresh();
//   }

//   Future<void> _sendContact() async {
//     if (!_contactFormKey.currentState!.validate()) return;
//     _sending.value = true;
//     final res = await ApiService.sendContactMessage(
//       subject: _subjectCtrl.text.trim(),
//       message: _messageCtrl.text.trim(),
//     );
//     _sending.value = false;
//     if (res.success) {
//       _subjectCtrl.clear();
//       _messageCtrl.clear();
//       _showSnack('Message sent successfully!');
//       _loadMyMessages(); // refresh my messages list
//     } else {
//       _showSnack(
//         res.message.isNotEmpty ? res.message : 'Failed to send',
//         isError: true,
//       );
//     }
//   }

//   Future<void> _resolveMessage(int contactId) async {
//     final idx = _messages.indexWhere((m) => m.id == contactId);
//     if (idx != -1) {
//       final old = _messages[idx];
//       _messages[idx] = ContactMessageModel(
//         id: old.id, subject: old.subject, message: old.message,
//         senderName: old.senderName, senderEmail: old.senderEmail,
//         isResolved: true, createdAt: old.createdAt,
//       );
//       _messages.refresh();
//     }

//     final res = await ApiService.resolveContact(contactId);
//     if (res.success) {
//       _showSnack('Marked as resolved');
//       _refreshMessagesQuiet();
//     } else {
//       if (idx != -1) {
//         final cur = _messages[idx];
//         _messages[idx] = ContactMessageModel(
//           id: cur.id, subject: cur.subject, message: cur.message,
//           senderName: cur.senderName, senderEmail: cur.senderEmail,
//           isResolved: false, createdAt: cur.createdAt,
//         );
//         _messages.refresh();
//       }
//       _showSnack('Failed to resolve', isError: true);
//     }
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       msg,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//         isError ? Icons.error_outline : Icons.check_circle_outline,
//         color: Colors.white,
//       ),
//       snackPosition: SnackPosition.TOP,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   // ─── ADD FAQ DIALOG ────────────────────────────────────

//   void _showAddFaqDialog() {
//     final qCtrl    = TextEditingController();
//     final aCtrl    = TextEditingController();
//     final catCtrl  = TextEditingController();
//     final sortCtrl = TextEditingController(text: '0');
//     final formKey  = GlobalKey<FormState>();
//     final loading  = false.obs;

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
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.quiz_rounded,
//                       color: AppTheme.primary, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text('Add FAQ', style: AppTheme.headline2),
//               ]),
//               const SizedBox(height: 20),
//               _dialogField(qCtrl,    'Question',   Icons.help_outline_rounded, required: true),
//               const SizedBox(height: 12),
//               _dialogField(aCtrl,    'Answer',     Icons.lightbulb_outline_rounded, required: true, maxLines: 4),
//               const SizedBox(height: 12),
//               _dialogField(catCtrl,  'Category',   Icons.category_outlined),
//               const SizedBox(height: 12),
//               _dialogField(sortCtrl, 'Sort Order', Icons.sort_rounded, isNumber: true),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                         onPressed: loading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 loading.value = true;
//                                 final res = await ApiService.createFaq(
//                                   question:  qCtrl.text.trim(),
//                                   answer:    aCtrl.text.trim(),
//                                   category:  catCtrl.text.trim(),
//                                   sortOrder: int.tryParse(sortCtrl.text.trim()) ?? 0,
//                                 );
//                                 loading.value = false;
//                                 if (res.success) {
//                                   Get.back();
//                                   _loadFaqs();
//                                   _showSnack('FAQ added successfully!');
//                                 } else {
//                                   _showSnack(
//                                       res.message.isNotEmpty ? res.message : 'Failed',
//                                       isError: true);
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primary,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: loading.value
//                             ? const SizedBox(
//                                 width: 18, height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Add FAQ',
//                                 style: TextStyle(
//                                     fontFamily:  'Poppins',
//                                     color:       Colors.white,
//                                     fontWeight:  FontWeight.w600)),
//                       )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dialogField(
//     TextEditingController ctrl,
//     String label,
//     IconData icon, {
//     bool required = false,
//     bool isNumber = false,
//     int maxLines  = 1,
//   }) {
//     return TextFormField(
//       controller:   ctrl,
//       maxLines:     maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
//       decoration: InputDecoration(
//         labelText:   label,
//         prefixIcon:  Icon(icon, size: 20),
//         border:      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//       validator: required
//           ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
//           : null,
//     );
//   }

//   // ─── FAQ TAB ───────────────────────────────────────────

//   Widget _buildFaqTab() {
//     return Obx(() {
//       if (_faqLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final allCategories = _faqs
//           .map((f) => f.category)
//           .where((c) => c.isNotEmpty)
//           .toSet()
//           .toList();

//       final filtered = _faqs.where((f) {
//         final matchSearch = _faqSearch.isEmpty ||
//             f.question.toLowerCase().contains(_faqSearch.toLowerCase()) ||
//             f.answer.toLowerCase().contains(_faqSearch.toLowerCase());
//         final matchCat =
//             _selectedCategory == null || f.category == _selectedCategory;
//         return matchSearch && matchCat;
//       }).toList()
//         ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

//       return RefreshIndicator(
//         onRefresh: _loadFaqs,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             if (_isAdmin) ...[
//               _AdminFaqBanner(totalFaqs: _faqs.length),
//               const SizedBox(height: 16),
//             ],
//             TextField(
//               onChanged: (v) => setState(() => _faqSearch = v),
//               decoration: InputDecoration(
//                 hintText:   'Search FAQs…',
//                 prefixIcon: const Icon(Icons.search_rounded,
//                     color: AppTheme.textSecondary),
//                 filled:     true,
//                 fillColor:  AppTheme.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//             ),
//             const SizedBox(height: 12),

//             // ── Category chips — Leave screen style ─────────────────
//             if (allCategories.isNotEmpty) ...[
//               SizedBox(
//                 height: 36,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount:       allCategories.length + 1, // +1 for 'All'
//                   separatorBuilder: (_, __) => const SizedBox(width: 8),
//                   itemBuilder: (_, i) {
//                     final isAll      = i == 0;
//                     final label      = isAll ? 'All' : allCategories[i - 1];
//                     final isSelected = isAll
//                         ? _selectedCategory == null
//                         : _selectedCategory == label;
//                     return GestureDetector(
//                       onTap: () => setState(() =>
//                           _selectedCategory = isAll ? null : label),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppTheme.primary
//                               : AppTheme.cardBackground,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                               color: isSelected
//                                   ? AppTheme.primary
//                                   : AppTheme.divider),
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(label,
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize:   12,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : AppTheme.textSecondary)),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],

//             if (filtered.isEmpty)
//               const _EmptyState(
//                 icon:    Icons.quiz_outlined,
//                 message: 'No FAQs found',
//               )
//             else
//               ...filtered.map((faq) => _FaqCard(faq: faq)),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── CONTACT US TAB (non-admin) ────────────────────────

//   Widget _buildContactTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Header banner
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               AppTheme.primary.withOpacity(0.12),
//               AppTheme.primary.withOpacity(0.04),
//             ]),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//           ),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color:        AppTheme.primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.support_agent_rounded,
//                   color: Colors.white, size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 const Text('Need Help?',
//                     style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w700,
//                         fontSize:   15,
//                         color:      AppTheme.primary)),
//                 const SizedBox(height: 2),
//                 Text('Send us a message and we\'ll get back to you shortly.',
//                     style: AppTheme.caption),
//               ]),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 24),

//         // Info tiles
//         Row(children: [
//           _InfoTile(
//             icon:  Icons.access_time_rounded,
//             label: 'Response Time',
//             value: '< 24 hrs',
//             color: AppTheme.primary,
//           ),
//           const SizedBox(width: 12),
//           _InfoTile(
//             icon:  Icons.support_rounded,
//             label: 'Support',
//             value: 'Mon–Sat',
//             color: AppTheme.success,
//           ),
//         ]),
//         const SizedBox(height: 24),

//         // Send message form
//         Container(
//           padding:    const EdgeInsets.all(20),
//           decoration: AppTheme.cardDecoration(),
//           child: Form(
//             key: _contactFormKey,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.edit_note_rounded,
//                       color: AppTheme.primary, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text('Send a Message', style: AppTheme.headline3),
//               ]),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _subjectCtrl,
//                 decoration: InputDecoration(
//                   labelText:  'Subject',
//                   prefixIcon: const Icon(Icons.subject_rounded, size: 20),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _messageCtrl,
//                 maxLines:   5,
//                 decoration: InputDecoration(
//                   labelText: 'Message',
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(bottom: 64),
//                     child:   Icon(Icons.message_outlined, size: 20),
//                   ),
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Message is required' : null,
//               ),
//               const SizedBox(height: 20),
//               Obx(() => SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _sending.value ? null : _sendContact,
//                       icon: _sending.value
//                           ? const SizedBox(
//                               width: 18, height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Icon(Icons.send_rounded, size: 18),
//                       label: Text(
//                         _sending.value ? 'Sending…' : 'Send Message',
//                         style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                             fontSize:   15),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//         ),

//         // ── FIX 3: My Messages section (user's own sent messages) ──
//         const SizedBox(height: 28),
//         Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        AppTheme.primaryLight,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.inbox_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           const SizedBox(width: 10),
//           const Text('My Messages', style: AppTheme.headline3),
//           const Spacer(),
//           GestureDetector(
//             onTap: _loadMyMessages,
//             child: const Icon(Icons.refresh_rounded,
//                 color: AppTheme.primary, size: 20),
//           ),
//         ]),
//         const SizedBox(height: 12),

//         Obx(() {
//           if (_myMessagesLoading.value) {
//             return const Center(
//                 child: Padding(
//               padding: EdgeInsets.all(24),
//               child: CircularProgressIndicator(color: AppTheme.primary),
//             ));
//           }
//           if (_myMessages.isEmpty) {
//             return const _EmptyState(
//               icon:    Icons.inbox_outlined,
//               message: 'No messages sent yet',
//             );
//           }
//           return Column(
//             children: _myMessages
//                 .map((msg) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: _ContactMessageCard(
//                         msg:       msg,
//                         onResolve: null, // user cannot resolve
//                       ),
//                     ))
//                 .toList(),
//           );
//         }),
//       ]),
//     );
//   }

//   // ─── MESSAGES TAB (admin) ──────────────────────────────

//   Widget _buildMessagesTab() {
//     return Obx(() {
//       if (_messagesLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final open     = _messages.where((m) => !m.isResolved).length;
//       final resolved = _messages.where((m) =>  m.isResolved).length;

//       final filtered = _messages.where((m) {
//         if (_messageFilter == 'open')     return !m.isResolved;
//         if (_messageFilter == 'resolved') return  m.isResolved;
//         return true;
//       }).toList();

//       return RefreshIndicator(
//         onRefresh: _loadMessages,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             Row(children: [
//               _StatCard(
//                 label: 'Open',
//                 count: open,
//                 color: AppTheme.warning,
//                 icon:  Icons.mark_email_unread_rounded,
//               ),
//               const SizedBox(width: 12),
//               _StatCard(
//                 label: 'Resolved',
//                 count: resolved,
//                 color: AppTheme.success,
//                 icon:  Icons.check_circle_rounded,
//               ),
//             ]),
//             const SizedBox(height: 16),

//             // ── Filter chips — Leave screen style ───────────────────
//             SizedBox(
//               height: 36,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount:        3,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (_, i) {
//                   final labels   = ['All (${_messages.length})', 'Open ($open)', 'Resolved ($resolved)'];
//                   final keys     = ['all', 'open', 'resolved'];
//                   final colors   = [AppTheme.primary, AppTheme.warning, AppTheme.success];
//                   final isSelected = _messageFilter == keys[i];
//                   return GestureDetector(
//                     onTap: () => setState(() => _messageFilter = keys[i]),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? colors[i]
//                             : AppTheme.cardBackground,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color: isSelected ? colors[i] : AppTheme.divider),
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(labels[i],
//                           style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize:   12,
//                               fontWeight: FontWeight.w600,
//                               color: isSelected
//                                   ? Colors.white
//                                   : AppTheme.textSecondary)),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 12),
//             if (filtered.isEmpty)
//               _EmptyState(
//                 icon: Icons.inbox_outlined,
//                 message: _messageFilter == 'all'
//                     ? 'No contact messages yet'
//                     : 'No $_messageFilter messages',
//               )
//             else
//               ...filtered.map((msg) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _ContactMessageCard(
//                       msg:       msg,
//                       onResolve: msg.isResolved
//                           ? null
//                           : () => _resolveMessage(msg.id),
//                     ),
//                   )),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── BUILD ─────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final tabs = _isAdmin
//         ? [
//             const Tab(icon: Icon(Icons.quiz_rounded,  size: 18), text: 'FAQs'),
//             const Tab(icon: Icon(Icons.inbox_rounded, size: 18), text: 'Messages'),
//           ]
//         : [
//             const Tab(icon: Icon(Icons.quiz_rounded,            size: 18), text: 'FAQs'),
//             const Tab(icon: Icon(Icons.contact_support_rounded, size: 18), text: 'Contact Us'),
//           ];

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation:       0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Help & Support',
//           style: TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w700,
//               fontSize:   18,
//               color:      AppTheme.textPrimary),
//         ),
//         actions: [
//           if (_isAdmin)
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (_, __) => _tabController.index == 0
//                   ? IconButton(
//                       icon: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color:        AppTheme.primaryLight,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.add_rounded,
//                             color: AppTheme.primary, size: 20),
//                       ),
//                       onPressed: _showAddFaqDialog,
//                       tooltip: 'Add FAQ',
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           const SizedBox(width: 4),
//         ],
//         bottom: TabBar(
//           controller:           _tabController,
//           tabs:                 tabs,
//           labelColor:           AppTheme.primary,
//           unselectedLabelColor: AppTheme.textSecondary,
//           indicatorColor:       AppTheme.primary,
//           indicatorWeight:      3,
//           labelStyle: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
//           unselectedLabelStyle: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _isAdmin
//             ? [_buildFaqTab(), _buildMessagesTab()]
//             : [_buildFaqTab(), _buildContactTab()],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────
// //  SUB-WIDGETS
// // ─────────────────────────────────────────────────────────

// class _AdminFaqBanner extends StatelessWidget {
//   final int totalFaqs;
//   const _AdminFaqBanner({required this.totalFaqs});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           AppTheme.primary.withOpacity(0.15),
//           AppTheme.primary.withOpacity(0.05),
//         ]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//       ),
//       child: Row(children: [
//         const Icon(Icons.admin_panel_settings_rounded,
//             color: AppTheme.primary, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Admin View — $totalFaqs FAQ${totalFaqs == 1 ? '' : 's'} total. Tap + to add new.',
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 fontWeight: FontWeight.w500,
//                 color:      AppTheme.primary),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String   label;
//   final String   value;
//   final Color    color;

//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 10),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   11,
//                     color:      AppTheme.textSecondary)),
//             Text(value,
//                 style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   13,
//                     fontWeight: FontWeight.w700,
//                     color:      color)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String   label;
//   final int      count;
//   final Color    color;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   22,
//                   fontWeight: FontWeight.w800,
//                   color:      color),
//             ),
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   12,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _FaqCard extends StatefulWidget {
//   final FaqModel faq;
//   const _FaqCard({required this.faq});

//   @override
//   State<_FaqCard> createState() => _FaqCardState();
// }

// class _FaqCardState extends State<_FaqCard> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin:     const EdgeInsets.only(bottom: 10),
//       decoration: AppTheme.cardDecoration(),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: ExpansionTile(
//           tilePadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           leading: Container(
//             width: 36, height: 36,
//             decoration: BoxDecoration(
//               color:        AppTheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.help_outline_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           title: Text(
//             widget.faq.question,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize:   14,
//                 color:      AppTheme.textPrimary),
//           ),
//           trailing: AnimatedRotation(
//             turns:    _expanded ? 0.5 : 0,
//             duration: const Duration(milliseconds: 200),
//             child: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: AppTheme.textSecondary),
//           ),
//           onExpansionChanged: (v) => setState(() => _expanded = v),
//           children: [
//             const Divider(height: 1, color: AppTheme.divider),
//             const SizedBox(height: 12),
//             Text(
//               widget.faq.answer,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   13,
//                   color:      AppTheme.textSecondary,
//                   height:     1.5),
//             ),
//             if (widget.faq.category.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.faq.category,
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize:   11,
//                         color:      AppTheme.primary,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactMessageCard extends StatelessWidget {
//   final ContactMessageModel msg;
//   final VoidCallback?       onResolve;

//   const _ContactMessageCard({required this.msg, this.onResolve});

//   @override
//   Widget build(BuildContext context) {
//     final dateStr =
//         DateFormat('dd MMM yyyy, hh:mm a').format(msg.createdAt);

//     return Container(
//       padding:    const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         Row(children: [
//           Container(
//             width: 8, height: 8,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: msg.isResolved ? AppTheme.success : AppTheme.warning,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               msg.subject.isNotEmpty ? msg.subject : '(No Subject)',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize:   14,
//                   color:      AppTheme.textPrimary),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success.withOpacity(0.12)
//                   : AppTheme.warning.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               msg.isResolved ? 'Resolved' : 'Open',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   11,
//                   fontWeight: FontWeight.w700,
//                   color: msg.isResolved ? AppTheme.success : AppTheme.warning),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 8),

//         if (msg.senderName.isNotEmpty || msg.senderEmail.isNotEmpty)
//           Row(children: [
//             const Icon(Icons.person_outline_rounded,
//                 size: 14, color: AppTheme.textSecondary),
//             const SizedBox(width: 4),
//             Text(
//               [msg.senderName, msg.senderEmail]
//                   .where((s) => s.isNotEmpty)
//                   .join(' · '),
//               style: AppTheme.caption,
//             ),
//           ]),

//         const SizedBox(height: 8),

//         Container(
//           padding:    const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color:        AppTheme.background,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             msg.message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 color:      AppTheme.textSecondary,
//                 height:     1.5),
//           ),
//         ),
//         const SizedBox(height: 10),

//         Row(children: [
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           Text(dateStr, style: AppTheme.caption),
//           const Spacer(),
//           if (onResolve != null)
//             GestureDetector(
//               onTap: onResolve,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppTheme.success.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: AppTheme.success.withOpacity(0.3)),
//                 ),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.check_circle_outline_rounded,
//                       size: 14, color: AppTheme.success),
//                   const SizedBox(width: 4),
//                   const Text('Resolve',
//                       style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize:   12,
//                           fontWeight: FontWeight.w600,
//                           color:      AppTheme.success)),
//                 ]),
//               ),
//             ),
//         ]),
//       ]),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   message;

//   const _EmptyState({required this.icon, required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(children: [
//             Icon(icon, size: 64, color: AppTheme.shimmerBase),
//             const SizedBox(height: 16),
//             Text(message,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   15,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ),
//       );
// }








// // lib/screens/help_support/help_support_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/help_support_model.dart';
// import '../../services/api_service.dart';

// class HelpSupportScreen extends StatefulWidget {
//   const HelpSupportScreen({super.key});

//   @override
//   State<HelpSupportScreen> createState() => _HelpSupportScreenState();
// }

// class _HelpSupportScreenState extends State<HelpSupportScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late bool _isAdmin;

//   // FAQs
//   final RxList<FaqModel> _faqs = <FaqModel>[].obs;
//   final RxBool _faqLoading     = true.obs;
//   String _faqSearch            = '';
//   String? _selectedCategory;

//   // Contact (non-admin only)
//   final _subjectCtrl    = TextEditingController();
//   final _messageCtrl    = TextEditingController();
//   final _contactFormKey = GlobalKey<FormState>();
//   final RxBool _sending = false.obs;

//   // Admin: Contact messages
//   final RxList<ContactMessageModel> _messages = <ContactMessageModel>[].obs;
//   final RxBool _messagesLoading               = false.obs;
//   String _messageFilter = 'all';

//   // User: My messages
//   final RxList<ContactMessageModel> _myMessages = <ContactMessageModel>[].obs;
//   final RxBool _myMessagesLoading               = false.obs;

//   @override
//   void initState() {
//     super.initState();
//     final auth = Get.find<AuthController>();
//     _isAdmin = auth.isAdmin;
//     _tabController = TabController(length: 2, vsync: this);
//     _loadFaqs();
//     if (_isAdmin) {
//       _loadMessages();
//     } else {
//       _loadMyMessages();
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _subjectCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   // ─── DATA LOADERS ──────────────────────────────────────

//   Future<void> _loadFaqs() async {
//     _faqLoading.value = true;
//     final list = await ApiService.getFaqs();
//     _faqs.assignAll(list);
//     _faqLoading.value = false;
//   }

//   Future<void> _loadMessages() async {
//     _messagesLoading.value = true;
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messagesLoading.value = false;
//   }

//   Future<void> _loadMyMessages() async {
//     _myMessagesLoading.value = true;
//     final list = await ApiService.getMyContactMessages();
//     _myMessages.assignAll(list);
//     _myMessagesLoading.value = false;
//   }

//   Future<void> _refreshMessagesQuiet() async {
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messages.refresh();
//   }

//   Future<void> _sendContact() async {
//     if (!_contactFormKey.currentState!.validate()) return;
//     _sending.value = true;
//     final res = await ApiService.sendContactMessage(
//       subject: _subjectCtrl.text.trim(),
//       message: _messageCtrl.text.trim(),
//     );
//     _sending.value = false;
//     if (res.success) {
//       _subjectCtrl.clear();
//       _messageCtrl.clear();
//       _showSnack('Message sent successfully!');
//       _loadMyMessages(); // refresh my messages list
//     } else {
//       _showSnack(
//         res.message.isNotEmpty ? res.message : 'Failed to send',
//         isError: true,
//       );
//     }
//   }

//   Future<void> _resolveMessage(int contactId) async {
//     final idx = _messages.indexWhere((m) => m.id == contactId);
//     if (idx != -1) {
//       final old = _messages[idx];
//       _messages[idx] = ContactMessageModel(
//         id: old.id, subject: old.subject, message: old.message,
//         senderName: old.senderName, senderEmail: old.senderEmail,
//         isResolved: true, createdAt: old.createdAt,
//       );
//       _messages.refresh();
//     }

//     final res = await ApiService.resolveContact(contactId);
//     if (res.success) {
//       _showSnack('Marked as resolved');
//       _refreshMessagesQuiet();
//     } else {
//       if (idx != -1) {
//         final cur = _messages[idx];
//         _messages[idx] = ContactMessageModel(
//           id: cur.id, subject: cur.subject, message: cur.message,
//           senderName: cur.senderName, senderEmail: cur.senderEmail,
//           isResolved: false, createdAt: cur.createdAt,
//         );
//         _messages.refresh();
//       }
//       _showSnack('Failed to resolve', isError: true);
//     }
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       msg,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//         isError ? Icons.error_outline : Icons.check_circle_outline,
//         color: Colors.white,
//       ),
//       snackPosition: SnackPosition.TOP,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   // ─── ADD FAQ DIALOG ────────────────────────────────────

//   void _showAddFaqDialog() {
//     final qCtrl    = TextEditingController();
//     final aCtrl    = TextEditingController();
//     final catCtrl  = TextEditingController();
//     final sortCtrl = TextEditingController(text: '0');
//     final formKey  = GlobalKey<FormState>();
//     final loading  = false.obs;

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
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.quiz_rounded,
//                       color: AppTheme.primary, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text('Add FAQ', style: AppTheme.headline2),
//               ]),
//               const SizedBox(height: 20),
//               _dialogField(qCtrl,    'Question',   Icons.help_outline_rounded, required: true),
//               const SizedBox(height: 12),
//               _dialogField(aCtrl,    'Answer',     Icons.lightbulb_outline_rounded, required: true, maxLines: 4),
//               const SizedBox(height: 12),
//               _dialogField(catCtrl,  'Category',   Icons.category_outlined),
//               const SizedBox(height: 12),
//               _dialogField(sortCtrl, 'Sort Order', Icons.sort_rounded, isNumber: true),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                         onPressed: loading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 loading.value = true;
//                                 final res = await ApiService.createFaq(
//                                   question:  qCtrl.text.trim(),
//                                   answer:    aCtrl.text.trim(),
//                                   category:  catCtrl.text.trim(),
//                                   sortOrder: int.tryParse(sortCtrl.text.trim()) ?? 0,
//                                 );
//                                 loading.value = false;
//                                 if (res.success) {
//                                   Get.back();
//                                   _loadFaqs();
//                                   _showSnack('FAQ added successfully!');
//                                 } else {
//                                   _showSnack(
//                                       res.message.isNotEmpty ? res.message : 'Failed',
//                                       isError: true);
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primary,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: loading.value
//                             ? const SizedBox(
//                                 width: 18, height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Add FAQ',
//                                 style: TextStyle(
//                                     fontFamily:  'Poppins',
//                                     color:       Colors.white,
//                                     fontWeight:  FontWeight.w600)),
//                       )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dialogField(
//     TextEditingController ctrl,
//     String label,
//     IconData icon, {
//     bool required = false,
//     bool isNumber = false,
//     int maxLines  = 1,
//   }) {
//     return TextFormField(
//       controller:   ctrl,
//       maxLines:     maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
//       decoration: InputDecoration(
//         labelText:   label,
//         prefixIcon:  Icon(icon, size: 20),
//         border:      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//       validator: required
//           ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
//           : null,
//     );
//   }

//   // ─── FAQ TAB ───────────────────────────────────────────

//   Widget _buildFaqTab() {
//     return Obx(() {
//       if (_faqLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final allCategories = _faqs
//           .map((f) => f.category)
//           .where((c) => c.isNotEmpty)
//           .toSet()
//           .toList();

//       final filtered = _faqs.where((f) {
//         final matchSearch = _faqSearch.isEmpty ||
//             f.question.toLowerCase().contains(_faqSearch.toLowerCase()) ||
//             f.answer.toLowerCase().contains(_faqSearch.toLowerCase());
//         final matchCat =
//             _selectedCategory == null || f.category == _selectedCategory;
//         return matchSearch && matchCat;
//       }).toList()
//         ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

//       return RefreshIndicator(
//         onRefresh: _loadFaqs,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             if (_isAdmin) ...[
//               _AdminFaqBanner(totalFaqs: _faqs.length),
//               const SizedBox(height: 16),
//             ],
//             TextField(
//               onChanged: (v) => setState(() => _faqSearch = v),
//               decoration: InputDecoration(
//                 hintText:   'Search FAQs…',
//                 prefixIcon: const Icon(Icons.search_rounded,
//                     color: AppTheme.textSecondary),
//                 filled:     true,
//                 fillColor:  AppTheme.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//             ),
//             const SizedBox(height: 12),

//             // ── Category chips ──────────────────────────────────────
//             if (allCategories.isNotEmpty) ...[
//               SizedBox(
//                 height: 36,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount:       allCategories.length + 1, // +1 for 'All'
//                   separatorBuilder: (_, __) => const SizedBox(width: 8),
//                   itemBuilder: (_, i) {
//                     final isAll      = i == 0;
//                     final rawLabel   = isAll ? 'All' : allCategories[i - 1];
//                     // ✅ FIX: First letter capital
//                     final label      = rawLabel.isEmpty
//                         ? rawLabel
//                         : '${rawLabel[0].toUpperCase()}${rawLabel.substring(1)}';
//                     final isSelected = isAll
//                         ? _selectedCategory == null
//                         : _selectedCategory == allCategories[i - 1];
//                     return GestureDetector(
//                       onTap: () => setState(() =>
//                           _selectedCategory = isAll ? null : allCategories[i - 1]),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppTheme.primary
//                               : AppTheme.cardBackground,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                               color: isSelected
//                                   ? AppTheme.primary
//                                   : AppTheme.divider),
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(label,
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize:   12,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : AppTheme.textSecondary)),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],

//             if (filtered.isEmpty)
//               const _EmptyState(
//                 icon:    Icons.quiz_outlined,
//                 message: 'No FAQs found',
//               )
//             else
//               ...filtered.map((faq) => _FaqCard(faq: faq)),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── CONTACT US TAB (non-admin) ────────────────────────

//   Widget _buildContactTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Header banner
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               AppTheme.primary.withOpacity(0.12),
//               AppTheme.primary.withOpacity(0.04),
//             ]),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//           ),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color:        AppTheme.primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.support_agent_rounded,
//                   color: Colors.white, size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 const Text('Need Help?',
//                     style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w700,
//                         fontSize:   15,
//                         color:      AppTheme.primary)),
//                 const SizedBox(height: 2),
//                 Text('Send us a message and we\'ll get back to you shortly.',
//                     style: AppTheme.caption),
//               ]),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 24),

//         // Info tiles
//         Row(children: [
//           _InfoTile(
//             icon:  Icons.access_time_rounded,
//             label: 'Response Time',
//             value: '< 24 hrs',
//             color: AppTheme.primary,
//           ),
//           const SizedBox(width: 12),
//           _InfoTile(
//             icon:  Icons.support_rounded,
//             label: 'Support',
//             value: 'Mon–Sat',
//             color: AppTheme.success,
//           ),
//         ]),
//         const SizedBox(height: 24),

//         // Send message form
//         Container(
//           padding:    const EdgeInsets.all(20),
//           decoration: AppTheme.cardDecoration(),
//           child: Form(
//             key: _contactFormKey,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.edit_note_rounded,
//                       color: AppTheme.primary, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text('Send a Message', style: AppTheme.headline3),
//               ]),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _subjectCtrl,
//                 decoration: InputDecoration(
//                   labelText:  'Subject',
//                   prefixIcon: const Icon(Icons.subject_rounded, size: 20),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _messageCtrl,
//                 maxLines:   5,
//                 decoration: InputDecoration(
//                   labelText: 'Message',
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(bottom: 64),
//                     child:   Icon(Icons.message_outlined, size: 20),
//                   ),
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Message is required' : null,
//               ),
//               const SizedBox(height: 20),
//               Obx(() => SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _sending.value ? null : _sendContact,
//                       icon: _sending.value
//                           ? const SizedBox(
//                               width: 18, height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Icon(Icons.send_rounded, size: 18),
//                       label: Text(
//                         _sending.value ? 'Sending…' : 'Send Message',
//                         style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                             fontSize:   15),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//         ),

//         // My Messages section
//         const SizedBox(height: 28),
//         Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        AppTheme.primaryLight,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.inbox_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           const SizedBox(width: 10),
//           const Text('My Messages', style: AppTheme.headline3),
//           const Spacer(),
//           GestureDetector(
//             onTap: _loadMyMessages,
//             child: const Icon(Icons.refresh_rounded,
//                 color: AppTheme.primary, size: 20),
//           ),
//         ]),
//         const SizedBox(height: 12),

//         Obx(() {
//           if (_myMessagesLoading.value) {
//             return const Center(
//                 child: Padding(
//               padding: EdgeInsets.all(24),
//               child: CircularProgressIndicator(color: AppTheme.primary),
//             ));
//           }
//           if (_myMessages.isEmpty) {
//             return const _EmptyState(
//               icon:    Icons.inbox_outlined,
//               message: 'No messages sent yet',
//             );
//           }
//           return Column(
//             children: _myMessages
//                 .map((msg) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: _ContactMessageCard(
//                         msg:       msg,
//                         onResolve: null,
//                       ),
//                     ))
//                 .toList(),
//           );
//         }),
//       ]),
//     );
//   }

//   // ─── MESSAGES TAB (admin) ──────────────────────────────

//   Widget _buildMessagesTab() {
//     return Obx(() {
//       if (_messagesLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }

//       final open     = _messages.where((m) => !m.isResolved).length;
//       final resolved = _messages.where((m) =>  m.isResolved).length;

//       final filtered = _messages.where((m) {
//         if (_messageFilter == 'open')     return !m.isResolved;
//         if (_messageFilter == 'resolved') return  m.isResolved;
//         return true;
//       }).toList();

//       return RefreshIndicator(
//         onRefresh: _loadMessages,
//         color: AppTheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             Row(children: [
//               _StatCard(
//                 label: 'Open',
//                 count: open,
//                 color: AppTheme.warning,
//                 icon:  Icons.mark_email_unread_rounded,
//               ),
//               const SizedBox(width: 12),
//               _StatCard(
//                 label: 'Resolved',
//                 count: resolved,
//                 color: AppTheme.success,
//                 icon:  Icons.check_circle_rounded,
//               ),
//             ]),
//             const SizedBox(height: 16),

//             // ── Filter chips ────────────────────────────────────────
//             SizedBox(
//               height: 36,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount:        3,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (_, i) {
//                   final labels   = ['All (${_messages.length})', 'Open ($open)', 'Resolved ($resolved)'];
//                   final keys     = ['all', 'open', 'resolved'];
//                   final colors   = [AppTheme.primary, AppTheme.warning, AppTheme.success];
//                   final isSelected = _messageFilter == keys[i];
//                   return GestureDetector(
//                     onTap: () => setState(() => _messageFilter = keys[i]),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? colors[i]
//                             : AppTheme.cardBackground,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color: isSelected ? colors[i] : AppTheme.divider),
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(labels[i],
//                           style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize:   12,
//                               fontWeight: FontWeight.w600,
//                               color: isSelected
//                                   ? Colors.white
//                                   : AppTheme.textSecondary)),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 12),
//             if (filtered.isEmpty)
//               _EmptyState(
//                 icon: Icons.inbox_outlined,
//                 message: _messageFilter == 'all'
//                     ? 'No contact messages yet'
//                     : 'No $_messageFilter messages',
//               )
//             else
//               ...filtered.map((msg) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _ContactMessageCard(
//                       msg:       msg,
//                       onResolve: msg.isResolved
//                           ? null
//                           : () => _resolveMessage(msg.id),
//                     ),
//                   )),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── BUILD ─────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final tabs = _isAdmin
//         ? [
//             const Tab(icon: Icon(Icons.quiz_rounded,  size: 18), text: 'FAQs'),
//             const Tab(icon: Icon(Icons.inbox_rounded, size: 18), text: 'Messages'),
//           ]
//         : [
//             const Tab(icon: Icon(Icons.quiz_rounded,            size: 18), text: 'FAQs'),
//             const Tab(icon: Icon(Icons.contact_support_rounded, size: 18), text: 'Contact Us'),
//           ];

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation:       0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Help & Support',
//           style: TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w700,
//               fontSize:   18,
//               color:      AppTheme.textPrimary),
//         ),
//         actions: [
//           if (_isAdmin)
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (_, __) => _tabController.index == 0
//                   ? IconButton(
//                       icon: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color:        AppTheme.primaryLight,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.add_rounded,
//                             color: AppTheme.primary, size: 20),
//                       ),
//                       onPressed: _showAddFaqDialog,
//                       tooltip: 'Add FAQ',
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           const SizedBox(width: 4),
//         ],
//         bottom: TabBar(
//           controller:           _tabController,
//           tabs:                 tabs,
//           labelColor:           AppTheme.primary,
//           unselectedLabelColor: AppTheme.textSecondary,
//           indicatorColor:       AppTheme.primary,
//           indicatorWeight:      3,
//           labelStyle: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
//           unselectedLabelStyle: const TextStyle(
//               fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _isAdmin
//             ? [_buildFaqTab(), _buildMessagesTab()]
//             : [_buildFaqTab(), _buildContactTab()],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────
// //  SUB-WIDGETS
// // ─────────────────────────────────────────────────────────

// class _AdminFaqBanner extends StatelessWidget {
//   final int totalFaqs;
//   const _AdminFaqBanner({required this.totalFaqs});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           AppTheme.primary.withOpacity(0.15),
//           AppTheme.primary.withOpacity(0.05),
//         ]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
//       ),
//       child: Row(children: [
//         const Icon(Icons.admin_panel_settings_rounded,
//             color: AppTheme.primary, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Admin View — $totalFaqs FAQ${totalFaqs == 1 ? '' : 's'} total. Tap + to add new.',
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 fontWeight: FontWeight.w500,
//                 color:      AppTheme.primary),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String   label;
//   final String   value;
//   final Color    color;

//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 10),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   11,
//                     color:      AppTheme.textSecondary)),
//             Text(value,
//                 style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   13,
//                     fontWeight: FontWeight.w700,
//                     color:      color)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String   label;
//   final int      count;
//   final Color    color;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   22,
//                   fontWeight: FontWeight.w800,
//                   color:      color),
//             ),
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   12,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _FaqCard extends StatefulWidget {
//   final FaqModel faq;
//   const _FaqCard({required this.faq});

//   @override
//   State<_FaqCard> createState() => _FaqCardState();
// }

// class _FaqCardState extends State<_FaqCard> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin:     const EdgeInsets.only(bottom: 10),
//       decoration: AppTheme.cardDecoration(),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: ExpansionTile(
//           tilePadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           leading: Container(
//             width: 36, height: 36,
//             decoration: BoxDecoration(
//               color:        AppTheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.help_outline_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           title: Text(
//             widget.faq.question,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize:   14,
//                 color:      AppTheme.textPrimary),
//           ),
//           trailing: AnimatedRotation(
//             turns:    _expanded ? 0.5 : 0,
//             duration: const Duration(milliseconds: 200),
//             child: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: AppTheme.textSecondary),
//           ),
//           onExpansionChanged: (v) => setState(() => _expanded = v),
//           children: [
//             const Divider(height: 1, color: AppTheme.divider),
//             const SizedBox(height: 12),
//             Text(
//               widget.faq.answer,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   13,
//                   color:      AppTheme.textSecondary,
//                   height:     1.5),
//             ),
//             if (widget.faq.category.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.faq.category,
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize:   11,
//                         color:      AppTheme.primary,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactMessageCard extends StatelessWidget {
//   final ContactMessageModel msg;
//   final VoidCallback?       onResolve;

//   const _ContactMessageCard({required this.msg, this.onResolve});

//   @override
//   Widget build(BuildContext context) {
//     final dateStr =
//         DateFormat('dd MMM yyyy, hh:mm a').format(msg.createdAt);

//     return Container(
//       padding:    const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         Row(children: [
//           Container(
//             width: 8, height: 8,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: msg.isResolved ? AppTheme.success : AppTheme.warning,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               msg.subject.isNotEmpty ? msg.subject : '(No Subject)',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize:   14,
//                   color:      AppTheme.textPrimary),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success.withOpacity(0.12)
//                   : AppTheme.warning.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               msg.isResolved ? 'Resolved' : 'Open',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   11,
//                   fontWeight: FontWeight.w700,
//                   color: msg.isResolved ? AppTheme.success : AppTheme.warning),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 8),

//         if (msg.senderName.isNotEmpty || msg.senderEmail.isNotEmpty)
//           Row(children: [
//             const Icon(Icons.person_outline_rounded,
//                 size: 14, color: AppTheme.textSecondary),
//             const SizedBox(width: 4),
//             Text(
//               [msg.senderName, msg.senderEmail]
//                   .where((s) => s.isNotEmpty)
//                   .join(' · '),
//               style: AppTheme.caption,
//             ),
//           ]),

//         const SizedBox(height: 8),

//         Container(
//           padding:    const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color:        AppTheme.background,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             msg.message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 color:      AppTheme.textSecondary,
//                 height:     1.5),
//           ),
//         ),
//         const SizedBox(height: 10),

//         Row(children: [
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           Text(dateStr, style: AppTheme.caption),
//           const Spacer(),
//           if (onResolve != null)
//             GestureDetector(
//               onTap: onResolve,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppTheme.success.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: AppTheme.success.withOpacity(0.3)),
//                 ),
//                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                   const Icon(Icons.check_circle_outline_rounded,
//                       size: 14, color: AppTheme.success),
//                   const SizedBox(width: 4),
//                   const Text('Resolve',
//                       style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize:   12,
//                           fontWeight: FontWeight.w600,
//                           color:      AppTheme.success)),
//                 ]),
//               ),
//             ),
//         ]),
//       ]),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   message;

//   const _EmptyState({required this.icon, required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(children: [
//             Icon(icon, size: 64, color: AppTheme.shimmerBase),
//             const SizedBox(height: 16),
//             Text(message,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   15,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ),
//       );
// }














// // lib/screens/help_support/help_support_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/response_handler.dart';
// import '../../models/help_support_model.dart';
// import '../../services/api_service.dart';

// class HelpSupportScreen extends StatefulWidget {
//   const HelpSupportScreen({super.key});

//   @override
//   State<HelpSupportScreen> createState() => _HelpSupportScreenState();
// }

// class _HelpSupportScreenState extends State<HelpSupportScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late bool _isAdmin;

//   // FAQs
//   final RxList<FaqModel> _faqs = <FaqModel>[].obs;
//   final RxBool _faqLoading     = true.obs;
//   String  _faqSearch           = '';
//   String? _selectedCategory;

//   // Contact (non-admin only)
//   final _subjectCtrl    = TextEditingController();
//   final _messageCtrl    = TextEditingController();
//   final _contactFormKey = GlobalKey<FormState>();
//   final RxBool _sending = false.obs;

//   // Admin: Contact messages
//   final RxList<ContactMessageModel> _messages = <ContactMessageModel>[].obs;
//   final RxBool _messagesLoading               = false.obs;
//   String _messageFilter = 'all';

//   // User: My messages
//   final RxList<ContactMessageModel> _myMessages = <ContactMessageModel>[].obs;
//   final RxBool _myMessagesLoading               = false.obs;

//   // ✅ FIX: Loaded flags — screen re-push hone pe duplicate call nahi hogi
//   bool _faqsLoaded       = false;
//   bool _messagesLoaded   = false;
//   bool _myMessagesLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     final auth = Get.find<AuthController>();
//     _isAdmin       = auth.isAdmin;
//     _tabController = TabController(length: 2, vsync: this);

//     // ✅ FIX: Flags check karenge — pehli baar hi load hoga
//     _loadFaqs();
//     if (_isAdmin) {
//       _loadMessages();
//     } else {
//       _loadMyMessages();
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _subjectCtrl.dispose();
//     _messageCtrl.dispose();
//     super.dispose();
//   }

//   // ─── DATA LOADERS ──────────────────────────────────────

//   /// [forceRefresh] = true karo jab pull-to-refresh ho
//   Future<void> _loadFaqs({bool forceRefresh = false}) async {
//     // ✅ FIX: Already loaded → skip (unless force refresh)
//     if (_faqsLoaded && !forceRefresh) return;

//     _faqLoading.value = true;
//     final list = await ApiService.getFaqs();
//     _faqs.assignAll(list);
//     _faqLoading.value = false;
//     _faqsLoaded = true; // ✅ mark loaded
//   }

//   Future<void> _loadMessages({bool forceRefresh = false}) async {
//     // ✅ FIX: Already loaded → skip (unless force refresh)
//     if (_messagesLoaded && !forceRefresh) return;

//     _messagesLoading.value = true;
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messagesLoading.value = false;
//     _messagesLoaded = true; // ✅ mark loaded
//   }

//   Future<void> _loadMyMessages({bool forceRefresh = false}) async {
//     // ✅ FIX: Already loaded → skip (unless force refresh)
//     if (_myMessagesLoaded && !forceRefresh) return;

//     _myMessagesLoading.value = true;
//     final list = await ApiService.getMyContactMessages();
//     _myMessages.assignAll(list);
//     _myMessagesLoading.value = false;
//     _myMessagesLoaded = true; // ✅ mark loaded
//   }

//   Future<void> _refreshMessagesQuiet() async {
//     final list = await ApiService.getContactMessages();
//     _messages.assignAll(list);
//     _messages.refresh();
//   }

//   Future<void> _sendContact() async {
//     if (!_contactFormKey.currentState!.validate()) return;
//     _sending.value = true;
//     final res = await ApiService.sendContactMessage(
//       subject: _subjectCtrl.text.trim(),
//       message: _messageCtrl.text.trim(),
//     );
//     _sending.value = false;
//     if (res.success) {
//       _subjectCtrl.clear();
//       _messageCtrl.clear();
//       _showSnack('Message sent successfully!');
//       // ✅ Send ke baad force refresh karo
//       _loadMyMessages(forceRefresh: true);
//     } else {
//       _showSnack(
//         res.message.isNotEmpty ? res.message : 'Failed to send',
//         isError: true,
//       );
//     }
//   }

//   Future<void> _resolveMessage(int contactId) async {
//     final idx = _messages.indexWhere((m) => m.id == contactId);
//     if (idx != -1) {
//       final old = _messages[idx];
//       _messages[idx] = ContactMessageModel(
//         id:          old.id,
//         subject:     old.subject,
//         message:     old.message,
//         senderName:  old.senderName,
//         senderEmail: old.senderEmail,
//         isResolved:  true,
//         createdAt:   old.createdAt,
//       );
//       _messages.refresh();
//     }

//     final res = await ApiService.resolveContact(contactId);
//     if (res.success) {
//       _showSnack('Marked as resolved');
//       _refreshMessagesQuiet();
//     } else {
//       if (idx != -1) {
//         final cur = _messages[idx];
//         _messages[idx] = ContactMessageModel(
//           id:          cur.id,
//           subject:     cur.subject,
//           message:     cur.message,
//           senderName:  cur.senderName,
//           senderEmail: cur.senderEmail,
//           isResolved:  false,
//           createdAt:   cur.createdAt,
//         );
//         _messages.refresh();
//       }
//       _showSnack('Failed to resolve', isError: true);
//     }
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     if (isError) {
//       ResponseHandler.showError(apiMessage: '', fallback: msg);
//     } else {
//       ResponseHandler.showSuccess(apiMessage: '', fallback: msg);
//     }
//   }

//   // ─── ADD FAQ DIALOG ────────────────────────────────────

//   void _showAddFaqDialog() {
//     final qCtrl    = TextEditingController();
//     final aCtrl    = TextEditingController();
//     final catCtrl  = TextEditingController();
//     final sortCtrl = TextEditingController(text: '0');
//     final formKey  = GlobalKey<FormState>();
//     final loading  = false.obs;

//     showDialog(
//       context:             context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24)),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.quiz_rounded,
//                       color: AppTheme.primary, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text('Add FAQ', style: AppTheme.headline2),
//               ]),
//               const SizedBox(height: 20),
//               _dialogField(qCtrl,    'Question',   Icons.help_outline_rounded,     required: true),
//               const SizedBox(height: 12),
//               _dialogField(aCtrl,    'Answer',     Icons.lightbulb_outline_rounded, required: true, maxLines: 4),
//               const SizedBox(height: 12),
//               _dialogField(catCtrl,  'Category',   Icons.category_outlined),
//               const SizedBox(height: 12),
//               _dialogField(sortCtrl, 'Sort Order', Icons.sort_rounded, isNumber: true),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                         onPressed: loading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 loading.value = true;
//                                 final res = await ApiService.createFaq(
//                                   question:  qCtrl.text.trim(),
//                                   answer:    aCtrl.text.trim(),
//                                   category:  catCtrl.text.trim(),
//                                   sortOrder: int.tryParse(sortCtrl.text.trim()) ?? 0,
//                                 );
//                                 loading.value = false;
//                                 if (res.success) {
//                                   Get.back();
//                                   // ✅ FAQ add ke baad force refresh
//                                   _loadFaqs(forceRefresh: true);
//                                   _showSnack('FAQ added successfully!');
//                                 } else {
//                                   _showSnack(
//                                       res.message.isNotEmpty
//                                           ? res.message
//                                           : 'Failed',
//                                       isError: true);
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primary,
//                           padding:
//                               const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: loading.value
//                             ? const SizedBox(
//                                 width:  18,
//                                 height: 18,
//                                 child:  CircularProgressIndicator(
//                                     color:       Colors.white,
//                                     strokeWidth: 2))
//                             : const Text('Add FAQ',
//                                 style: TextStyle(
//                                     fontFamily:  'Poppins',
//                                     color:       Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _dialogField(
//     TextEditingController ctrl,
//     String label,
//     IconData icon, {
//     bool required  = false,
//     bool isNumber  = false,
//     int  maxLines  = 1,
//   }) {
//     return TextFormField(
//       controller:   ctrl,
//       maxLines:     maxLines,
//       keyboardType: isNumber
//           ? TextInputType.number
//           : TextInputType.multiline,
//       decoration: InputDecoration(
//         labelText:  label,
//         prefixIcon: Icon(icon, size: 20),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(
//               color: AppTheme.primary, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//       style:     const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//       validator: required
//           ? (v) => (v == null || v.trim().isEmpty)
//               ? '$label is required'
//               : null
//           : null,
//     );
//   }

//   // ─── FAQ TAB ───────────────────────────────────────────

//   Widget _buildFaqTab() {
//     return Obx(() {
//       if (_faqLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(
//                 color: AppTheme.primary));
//       }

//       final allCategories = _faqs
//           .map((f) => f.category)
//           .where((c) => c.isNotEmpty)
//           .toSet()
//           .toList();

//       final filtered = _faqs.where((f) {
//         final matchSearch = _faqSearch.isEmpty ||
//             f.question
//                 .toLowerCase()
//                 .contains(_faqSearch.toLowerCase()) ||
//             f.answer
//                 .toLowerCase()
//                 .contains(_faqSearch.toLowerCase());
//         final matchCat = _selectedCategory == null ||
//             f.category == _selectedCategory;
//         return matchSearch && matchCat;
//       }).toList()
//         ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

//       return RefreshIndicator(
//         // ✅ Pull to refresh = force refresh
//         onRefresh: () => _loadFaqs(forceRefresh: true),
//         color:     AppTheme.primary,
//         child: ListView(
//           padding:
//               const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             if (_isAdmin) ...[
//               _AdminFaqBanner(totalFaqs: _faqs.length),
//               const SizedBox(height: 16),
//             ],
//             TextField(
//               onChanged: (v) => setState(() => _faqSearch = v),
//               decoration: InputDecoration(
//                 hintText: 'Search FAQs…',
//                 prefixIcon: const Icon(Icons.search_rounded,
//                     color: AppTheme.textSecondary),
//                 filled:    true,
//                 fillColor: AppTheme.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 14),
//               ),
//               style: const TextStyle(
//                   fontFamily: 'Poppins', fontSize: 14),
//             ),
//             const SizedBox(height: 12),

//             // Category chips
//             if (allCategories.isNotEmpty) ...[
//               SizedBox(
//                 height: 36,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: allCategories.length + 1,
//                   separatorBuilder: (_, __) =>
//                       const SizedBox(width: 8),
//                   itemBuilder: (_, i) {
//                     final isAll    = i == 0;
//                     final rawLabel = isAll
//                         ? 'All'
//                         : allCategories[i - 1];
//                     final label = rawLabel.isEmpty
//                         ? rawLabel
//                         : '${rawLabel[0].toUpperCase()}${rawLabel.substring(1)}';
//                     final isSelected = isAll
//                         ? _selectedCategory == null
//                         : _selectedCategory ==
//                             allCategories[i - 1];
//                     return GestureDetector(
//                       onTap: () => setState(() =>
//                           _selectedCategory = isAll
//                               ? null
//                               : allCategories[i - 1]),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppTheme.primary
//                               : AppTheme.cardBackground,
//                           borderRadius:
//                               BorderRadius.circular(20),
//                           border: Border.all(
//                               color: isSelected
//                                   ? AppTheme.primary
//                                   : AppTheme.divider),
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(label,
//                             style: TextStyle(
//                                 fontFamily:  'Poppins',
//                                 fontSize:    12,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : AppTheme.textSecondary)),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],

//             if (filtered.isEmpty)
//               const _EmptyState(
//                 icon:    Icons.quiz_outlined,
//                 message: 'No FAQs found',
//               )
//             else
//               ...filtered.map((faq) => _FaqCard(faq: faq)),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── CONTACT US TAB (non-admin) ────────────────────────

//   Widget _buildContactTab() {
//     return SingleChildScrollView(
//       padding:
//           const EdgeInsets.fromLTRB(16, 20, 16, 100),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         Container(
//           padding:    const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               AppTheme.primary.withOpacity(0.12),
//               AppTheme.primary.withOpacity(0.04),
//             ]),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//                 color: AppTheme.primary.withOpacity(0.2)),
//           ),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color:        AppTheme.primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.support_agent_rounded,
//                   color: Colors.white, size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 const Text('Need Help?',
//                     style: TextStyle(
//                         fontFamily:  'Poppins',
//                         fontWeight: FontWeight.w700,
//                         fontSize:   15,
//                         color:      AppTheme.primary)),
//                 const SizedBox(height: 2),
//                 Text(
//                     'Send us a message and we\'ll get back to you shortly.',
//                     style: AppTheme.caption),
//               ]),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 24),

//         Row(children: [
//           _InfoTile(
//             icon:  Icons.access_time_rounded,
//             label: 'Response Time',
//             value: '< 24 hrs',
//             color: AppTheme.primary,
//           ),
//           const SizedBox(width: 12),
//           _InfoTile(
//             icon:  Icons.support_rounded,
//             label: 'Support',
//             value: 'Mon–Sat',
//             color: AppTheme.success,
//           ),
//         ]),
//         const SizedBox(height: 24),

//         Container(
//           padding:    const EdgeInsets.all(20),
//           decoration: AppTheme.cardDecoration(),
//           child: Form(
//             key: _contactFormKey,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color:        AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.edit_note_rounded,
//                       color: AppTheme.primary, size: 20),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text('Send a Message',
//                     style: AppTheme.headline3),
//               ]),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _subjectCtrl,
//                 decoration: InputDecoration(
//                   labelText:  'Subject',
//                   prefixIcon: const Icon(
//                       Icons.subject_rounded,
//                       size: 20),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(
//                         color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty)
//                         ? 'Subject is required'
//                         : null,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _messageCtrl,
//                 maxLines:   5,
//                 decoration: InputDecoration(
//                   labelText: 'Message',
//                   prefixIcon: const Padding(
//                     padding:
//                         EdgeInsets.only(bottom: 64),
//                     child: Icon(
//                         Icons.message_outlined,
//                         size: 20),
//                   ),
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(
//                         color: AppTheme.primary, width: 2),
//                   ),
//                 ),
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 14),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty)
//                         ? 'Message is required'
//                         : null,
//               ),
//               const SizedBox(height: 20),
//               Obx(() => SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _sending.value
//                           ? null
//                           : _sendContact,
//                       icon: _sending.value
//                           ? const SizedBox(
//                               width:  18,
//                               height: 18,
//                               child:  CircularProgressIndicator(
//                                   color:       Colors.white,
//                                   strokeWidth: 2))
//                           : const Icon(
//                               Icons.send_rounded,
//                               size: 18),
//                       label: Text(
//                         _sending.value
//                             ? 'Sending…'
//                             : 'Send Message',
//                         style: const TextStyle(
//                             fontFamily:  'Poppins',
//                             fontWeight: FontWeight.w600,
//                             fontSize:   15),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16),
//                         shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//         ),

//         const SizedBox(height: 28),
//         Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        AppTheme.primaryLight,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.inbox_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           const SizedBox(width: 10),
//           const Text('My Messages', style: AppTheme.headline3),
//           const Spacer(),
//           GestureDetector(
//             // ✅ Manual refresh = force refresh
//             onTap: () => _loadMyMessages(forceRefresh: true),
//             child: const Icon(Icons.refresh_rounded,
//                 color: AppTheme.primary, size: 20),
//           ),
//         ]),
//         const SizedBox(height: 12),

//         Obx(() {
//           if (_myMessagesLoading.value) {
//             return const Center(
//                 child: Padding(
//               padding: EdgeInsets.all(24),
//               child: CircularProgressIndicator(
//                   color: AppTheme.primary),
//             ));
//           }
//           if (_myMessages.isEmpty) {
//             return const _EmptyState(
//               icon:    Icons.inbox_outlined,
//               message: 'No messages sent yet',
//             );
//           }
//           return Column(
//             children: _myMessages
//                 .map((msg) => Padding(
//                       padding:
//                           const EdgeInsets.only(bottom: 12),
//                       child: _ContactMessageCard(
//                         msg:       msg,
//                         onResolve: null,
//                       ),
//                     ))
//                 .toList(),
//           );
//         }),
//       ]),
//     );
//   }

//   // ─── MESSAGES TAB (admin) ──────────────────────────────

//   Widget _buildMessagesTab() {
//     return Obx(() {
//       if (_messagesLoading.value) {
//         return const Center(
//             child: CircularProgressIndicator(
//                 color: AppTheme.primary));
//       }

//       final open     = _messages.where((m) => !m.isResolved).length;
//       final resolved = _messages.where((m) =>  m.isResolved).length;

//       final filtered = _messages.where((m) {
//         if (_messageFilter == 'open')     return !m.isResolved;
//         if (_messageFilter == 'resolved') return  m.isResolved;
//         return true;
//       }).toList();

//       return RefreshIndicator(
//         onRefresh: () => _loadMessages(forceRefresh: true),
//         color:     AppTheme.primary,
//         child: ListView(
//           padding:
//               const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           children: [
//             Row(children: [
//               _StatCard(
//                 label: 'Open',
//                 count: open,
//                 color: AppTheme.warning,
//                 icon:  Icons.mark_email_unread_rounded,
//               ),
//               const SizedBox(width: 12),
//               _StatCard(
//                 label: 'Resolved',
//                 count: resolved,
//                 color: AppTheme.success,
//                 icon:  Icons.check_circle_rounded,
//               ),
//             ]),
//             const SizedBox(height: 16),

//             SizedBox(
//               height: 36,
//               child: ListView.separated(
//                 scrollDirection:  Axis.horizontal,
//                 itemCount:        3,
//                 separatorBuilder: (_, __) =>
//                     const SizedBox(width: 8),
//                 itemBuilder: (_, i) {
//                   final labels = [
//                     'All (${_messages.length})',
//                     'Open ($open)',
//                     'Resolved ($resolved)'
//                   ];
//                   final keys   = ['all', 'open', 'resolved'];
//                   final colors = [
//                     AppTheme.primary,
//                     AppTheme.warning,
//                     AppTheme.success
//                   ];
//                   final isSelected = _messageFilter == keys[i];
//                   return GestureDetector(
//                     onTap: () =>
//                         setState(() => _messageFilter = keys[i]),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? colors[i]
//                             : AppTheme.cardBackground,
//                         borderRadius:
//                             BorderRadius.circular(20),
//                         border: Border.all(
//                             color: isSelected
//                                 ? colors[i]
//                                 : AppTheme.divider),
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(labels[i],
//                           style: TextStyle(
//                               fontFamily:  'Poppins',
//                               fontSize:    12,
//                               fontWeight: FontWeight.w600,
//                               color: isSelected
//                                   ? Colors.white
//                                   : AppTheme.textSecondary)),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 12),
//             if (filtered.isEmpty)
//               _EmptyState(
//                 icon:    Icons.inbox_outlined,
//                 message: _messageFilter == 'all'
//                     ? 'No contact messages yet'
//                     : 'No $_messageFilter messages',
//               )
//             else
//               ...filtered.map((msg) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _ContactMessageCard(
//                       msg:       msg,
//                       onResolve: msg.isResolved
//                           ? null
//                           : () => _resolveMessage(msg.id),
//                     ),
//                   )),
//           ],
//         ),
//       );
//     });
//   }

//   // ─── BUILD ─────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final tabs = _isAdmin
//         ? [
//             const Tab(
//                 icon: Icon(Icons.quiz_rounded, size: 18),
//                 text: 'FAQs'),
//             const Tab(
//                 icon: Icon(Icons.inbox_rounded, size: 18),
//                 text: 'Messages'),
//           ]
//         : [
//             const Tab(
//                 icon: Icon(Icons.quiz_rounded, size: 18),
//                 text: 'FAQs'),
//             const Tab(
//                 icon: Icon(Icons.contact_support_rounded,
//                     size: 18),
//                 text: 'Contact Us'),
//           ];

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation:       0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Help & Support',
//           style: TextStyle(
//               fontFamily:  'Poppins',
//               fontWeight: FontWeight.w700,
//               fontSize:   18,
//               color:      AppTheme.textPrimary),
//         ),
//         actions: [
//           if (_isAdmin)
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (_, __) => _tabController.index == 0
//                   ? IconButton(
//                       icon: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color:        AppTheme.primaryLight,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.add_rounded,
//                             color: AppTheme.primary, size: 20),
//                       ),
//                       onPressed: _showAddFaqDialog,
//                       tooltip: 'Add FAQ',
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           const SizedBox(width: 4),
//         ],
//         bottom: TabBar(
//           controller:           _tabController,
//           tabs:                 tabs,
//           labelColor:           AppTheme.primary,
//           unselectedLabelColor: AppTheme.textSecondary,
//           indicatorColor:       AppTheme.primary,
//           indicatorWeight:      3,
//           labelStyle: const TextStyle(
//               fontFamily:  'Poppins',
//               fontWeight: FontWeight.w600,
//               fontSize:   12),
//           unselectedLabelStyle: const TextStyle(
//               fontFamily:  'Poppins',
//               fontWeight: FontWeight.w500,
//               fontSize:   12),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _isAdmin
//             ? [_buildFaqTab(), _buildMessagesTab()]
//             : [_buildFaqTab(), _buildContactTab()],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────
// //  SUB-WIDGETS (unchanged)
// // ─────────────────────────────────────────────────────────

// class _AdminFaqBanner extends StatelessWidget {
//   final int totalFaqs;
//   const _AdminFaqBanner({required this.totalFaqs});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//           horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [
//           AppTheme.primary.withOpacity(0.15),
//           AppTheme.primary.withOpacity(0.05),
//         ]),
//         borderRadius: BorderRadius.circular(16),
//         border:
//             Border.all(color: AppTheme.primary.withOpacity(0.2)),
//       ),
//       child: Row(children: [
//         const Icon(Icons.admin_panel_settings_rounded,
//             color: AppTheme.primary, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Admin View — $totalFaqs FAQ${totalFaqs == 1 ? '' : 's'} total. Tap + to add new.',
//             style: const TextStyle(
//                 fontFamily:  'Poppins',
//                 fontSize:    13,
//                 fontWeight: FontWeight.w500,
//                 color:      AppTheme.primary),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String   label;
//   final String   value;
//   final Color    color;

//   const _InfoTile({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 10),
//           Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   11,
//                     color:      AppTheme.textSecondary)),
//             Text(value,
//                 style: TextStyle(
//                     fontFamily:  'Poppins',
//                     fontSize:    13,
//                     fontWeight: FontWeight.w700,
//                     color:      color)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String   label;
//   final int      count;
//   final Color    color;
//   final IconData icon;

//   const _StatCard({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:        color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color:        color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                   fontFamily:  'Poppins',
//                   fontSize:    22,
//                   fontWeight: FontWeight.w800,
//                   color:      color),
//             ),
//             Text(label,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   12,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _FaqCard extends StatefulWidget {
//   final FaqModel faq;
//   const _FaqCard({required this.faq});

//   @override
//   State<_FaqCard> createState() => _FaqCardState();
// }

// class _FaqCardState extends State<_FaqCard> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin:     const EdgeInsets.only(bottom: 10),
//       decoration: AppTheme.cardDecoration(),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(
//               horizontal: 16, vertical: 4),
//           childrenPadding:
//               const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           leading: Container(
//             width:  36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: AppTheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.help_outline_rounded,
//                 color: AppTheme.primary, size: 18),
//           ),
//           title: Text(
//             widget.faq.question,
//             style: const TextStyle(
//                 fontFamily:  'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize:   14,
//                 color:      AppTheme.textPrimary),
//           ),
//           trailing: AnimatedRotation(
//             turns:    _expanded ? 0.5 : 0,
//             duration: const Duration(milliseconds: 200),
//             child: const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: AppTheme.textSecondary),
//           ),
//           onExpansionChanged: (v) =>
//               setState(() => _expanded = v),
//           children: [
//             const Divider(height: 1, color: AppTheme.divider),
//             const SizedBox(height: 12),
//             Text(
//               widget.faq.answer,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize:   13,
//                   color:      AppTheme.textSecondary,
//                   height:     1.5),
//             ),
//             if (widget.faq.category.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.faq.category,
//                     style: const TextStyle(
//                         fontFamily:  'Poppins',
//                         fontSize:    11,
//                         color:       AppTheme.primary,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactMessageCard extends StatelessWidget {
//   final ContactMessageModel msg;
//   final VoidCallback?       onResolve;

//   const _ContactMessageCard(
//       {required this.msg, this.onResolve});

//   @override
//   Widget build(BuildContext context) {
//     final dateStr =
//         DateFormat('dd MMM yyyy, hh:mm a').format(msg.createdAt);

//     return Container(
//       padding:    const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         Row(children: [
//           Container(
//             width:  8,
//             height: 8,
//             margin: const EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success
//                   : AppTheme.warning,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               msg.subject.isNotEmpty
//                   ? msg.subject
//                   : '(No Subject)',
//               style: const TextStyle(
//                   fontFamily:  'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize:   14,
//                   color:      AppTheme.textPrimary),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: msg.isResolved
//                   ? AppTheme.success.withOpacity(0.12)
//                   : AppTheme.warning.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               msg.isResolved ? 'Resolved' : 'Open',
//               style: TextStyle(
//                   fontFamily:  'Poppins',
//                   fontSize:    11,
//                   fontWeight: FontWeight.w700,
//                   color: msg.isResolved
//                       ? AppTheme.success
//                       : AppTheme.warning),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 8),

//         if (msg.senderName.isNotEmpty ||
//             msg.senderEmail.isNotEmpty)
//           Row(children: [
//             const Icon(Icons.person_outline_rounded,
//                 size: 14, color: AppTheme.textSecondary),
//             const SizedBox(width: 4),
//             Text(
//               [msg.senderName, msg.senderEmail]
//                   .where((s) => s.isNotEmpty)
//                   .join(' · '),
//               style: AppTheme.caption,
//             ),
//           ]),

//         const SizedBox(height: 8),

//         Container(
//           padding:    const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color:        AppTheme.background,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             msg.message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize:   13,
//                 color:      AppTheme.textSecondary,
//                 height:     1.5),
//           ),
//         ),
//         const SizedBox(height: 10),

//         Row(children: [
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textHint),
//           const SizedBox(width: 4),
//           Text(dateStr, style: AppTheme.caption),
//           const Spacer(),
//           if (onResolve != null)
//             GestureDetector(
//               onTap: onResolve,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color:        AppTheme.success.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: AppTheme.success.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                   const Icon(
//                       Icons.check_circle_outline_rounded,
//                       size:  14,
//                       color: AppTheme.success),
//                   const SizedBox(width: 4),
//                   const Text('Resolve',
//                       style: TextStyle(
//                           fontFamily:  'Poppins',
//                           fontSize:    12,
//                           fontWeight: FontWeight.w600,
//                           color:      AppTheme.success)),
//                 ]),
//               ),
//             ),
//         ]),
//       ]),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   message;

//   const _EmptyState(
//       {required this.icon, required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(children: [
//             Icon(icon, size: 64, color: AppTheme.shimmerBase),
//             const SizedBox(height: 16),
//             Text(message,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize:   15,
//                     color:      AppTheme.textSecondary)),
//           ]),
//         ),
//       );
// }










// lib/screens/help_support/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/response_handler.dart';
import '../../models/help_support_model.dart';
import '../../services/api_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isAdmin;

  // FAQs
  final RxList<FaqModel> _faqs = <FaqModel>[].obs;
  final RxBool _faqLoading = true.obs;
  String _faqSearch = '';
  String? _selectedCategory;

  // Contact (both admin & user)
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _contactFormKey = GlobalKey<FormState>();
  final RxBool _sending = false.obs;

  // Admin: All contact messages
  final RxList<ContactMessageModel> _messages = <ContactMessageModel>[].obs;
  final RxBool _messagesLoading = false.obs;
  String _messageFilter = 'all';

  // My sent messages (both admin & user)
  final RxList<ContactMessageModel> _myMessages = <ContactMessageModel>[].obs;
  final RxBool _myMessagesLoading = false.obs;

  // Loaded flags — prevent duplicate calls
  bool _faqsLoaded = false;
  bool _messagesLoaded = false;
  bool _myMessagesLoaded = false;

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    _isAdmin = auth.isAdmin;

    // ✅ FIX: Admin ke liye 3 tabs — FAQs | Contact Us | Messages
    //         User ke liye 2 tabs  — FAQs | Contact Us
    _tabController = TabController(
      length: _isAdmin ? 3 : 2,
      vsync: this,
    );

    _loadFaqs();
    _loadMyMessages(); // ✅ Both admin & user apne sent messages dekh sakein
    if (_isAdmin) {
      _loadMessages(); // Admin: all user messages
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ─── DATA LOADERS ──────────────────────────────────────

  Future<void> _loadFaqs({bool forceRefresh = false}) async {
    if (_faqsLoaded && !forceRefresh) return;
    _faqLoading.value = true;
    final list = await ApiService.getFaqs();
    _faqs.assignAll(list);
    _faqLoading.value = false;
    _faqsLoaded = true;
  }

  Future<void> _loadMessages({bool forceRefresh = false}) async {
    if (_messagesLoaded && !forceRefresh) return;
    _messagesLoading.value = true;
    final list = await ApiService.getContactMessages();
    _messages.assignAll(list);
    _messagesLoading.value = false;
    _messagesLoaded = true;
  }

  Future<void> _loadMyMessages({bool forceRefresh = false}) async {
    if (_myMessagesLoaded && !forceRefresh) return;
    _myMessagesLoading.value = true;
    final list = await ApiService.getMyContactMessages();
    _myMessages.assignAll(list);
    _myMessagesLoading.value = false;
    _myMessagesLoaded = true;
  }

  Future<void> _refreshMessagesQuiet() async {
    final list = await ApiService.getContactMessages();
    _messages.assignAll(list);
    _messages.refresh();
  }

  Future<void> _sendContact() async {
    if (!_contactFormKey.currentState!.validate()) return;
    _sending.value = true;
    final res = await ApiService.sendContactMessage(
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );
    _sending.value = false;
    if (res.success) {
      _subjectCtrl.clear();
      _messageCtrl.clear();
      _showSnack('Message sent successfully!');
      _loadMyMessages(forceRefresh: true);
    } else {
      _showSnack(
        res.message.isNotEmpty ? res.message : 'Failed to send',
        isError: true,
      );
    }
  }

  Future<void> _resolveMessage(int contactId) async {
    final idx = _messages.indexWhere((m) => m.id == contactId);
    if (idx != -1) {
      final old = _messages[idx];
      _messages[idx] = ContactMessageModel(
        id: old.id,
        subject: old.subject,
        message: old.message,
        senderName: old.senderName,
        senderEmail: old.senderEmail,
        isResolved: true,
        createdAt: old.createdAt,
      );
      _messages.refresh();
    }

    final res = await ApiService.resolveContact(contactId);
    if (res.success) {
      _showSnack('Marked as resolved');
      _refreshMessagesQuiet();
    } else {
      if (idx != -1) {
        final cur = _messages[idx];
        _messages[idx] = ContactMessageModel(
          id: cur.id,
          subject: cur.subject,
          message: cur.message,
          senderName: cur.senderName,
          senderEmail: cur.senderEmail,
          isResolved: false,
          createdAt: cur.createdAt,
        );
        _messages.refresh();
      }
      _showSnack('Failed to resolve', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (isError) {
      ResponseHandler.showError(apiMessage: '', fallback: msg);
    } else {
      ResponseHandler.showSuccess(apiMessage: '', fallback: msg);
    }
  }

  // ─── ADD FAQ DIALOG ────────────────────────────────────

  void _showAddFaqDialog() {
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final sortCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
    final loading = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text('Add FAQ', style: AppTheme.headline2),
              ]),
              const SizedBox(height: 20),
              _dialogField(qCtrl, 'Question', Icons.help_outline_rounded,
                  required: true),
              const SizedBox(height: 12),
              _dialogField(
                  aCtrl, 'Answer', Icons.lightbulb_outline_rounded,
                  required: true, maxLines: 4),
              const SizedBox(height: 12),
              _dialogField(
                  catCtrl, 'Category', Icons.category_outlined),
              const SizedBox(height: 12),
              _dialogField(sortCtrl, 'Sort Order', Icons.sort_rounded,
                  isNumber: true),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: AppTheme.divider),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: loading.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                loading.value = true;
                                final res = await ApiService.createFaq(
                                  question: qCtrl.text.trim(),
                                  answer: aCtrl.text.trim(),
                                  category: catCtrl.text.trim(),
                                  sortOrder:
                                      int.tryParse(sortCtrl.text.trim()) ?? 0,
                                );
                                loading.value = false;
                                if (res.success) {
                                  Get.back();
                                  _loadFaqs(forceRefresh: true);
                                  _showSnack('FAQ added successfully!');
                                } else {
                                  _showSnack(
                                      res.message.isNotEmpty
                                          ? res.message
                                          : 'Failed',
                                      isError: true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: loading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Add FAQ',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                      )),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.multiline,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
              ? '$label is required'
              : null
          : null,
    );
  }

  // ─── FAQ TAB ───────────────────────────────────────────

  Widget _buildFaqTab() {
    return Obx(() {
      if (_faqLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary));
      }

      final allCategories = _faqs
          .map((f) => f.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      final filtered = _faqs.where((f) {
        final matchSearch = _faqSearch.isEmpty ||
            f.question
                .toLowerCase()
                .contains(_faqSearch.toLowerCase()) ||
            f.answer.toLowerCase().contains(_faqSearch.toLowerCase());
        final matchCat = _selectedCategory == null ||
            f.category == _selectedCategory;
        return matchSearch && matchCat;
      }).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return RefreshIndicator(
        onRefresh: () => _loadFaqs(forceRefresh: true),
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            if (_isAdmin) ...[
              _AdminFaqBanner(totalFaqs: _faqs.length),
              const SizedBox(height: 16),
            ],
            TextField(
              onChanged: (v) => setState(() => _faqSearch = v),
              decoration: InputDecoration(
                hintText: 'Search FAQs…',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Category chips
            if (allCategories.isNotEmpty) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: allCategories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final isAll = i == 0;
                    final rawLabel =
                        isAll ? 'All' : allCategories[i - 1];
                    final label = rawLabel.isEmpty
                        ? rawLabel
                        : '${rawLabel[0].toUpperCase()}${rawLabel.substring(1)}';
                    final isSelected = isAll
                        ? _selectedCategory == null
                        : _selectedCategory == allCategories[i - 1];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory =
                          isAll ? null : allCategories[i - 1]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.divider),
                        ),
                        alignment: Alignment.center,
                        child: Text(label,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (filtered.isEmpty)
              const _EmptyState(
                icon: Icons.quiz_outlined,
                message: 'No FAQs found',
              )
            else
              ...filtered.map((faq) => _FaqCard(faq: faq)),
          ],
        ),
      );
    });
  }

  // ─── CONTACT US TAB (both admin & user) ───────────────
  // ✅ FIX: Admin bhi yahan se message send kar sakta hai

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // ── Header Banner ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.primary.withOpacity(0.12),
              AppTheme.primary.withOpacity(0.04),
            ]),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Need Help?',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.primary)),
                const SizedBox(height: 2),
                Text(
                    'Send us a message and we\'ll get back to you shortly.',
                    style: AppTheme.caption),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        Row(children: [
          _InfoTile(
            icon: Icons.access_time_rounded,
            label: 'Response Time',
            value: '< 24 hrs',
            color: AppTheme.primary,
          ),
          const SizedBox(width: 12),
          _InfoTile(
            icon: Icons.support_rounded,
            label: 'Support',
            value: 'Mon–Sat',
            color: AppTheme.success,
          ),
        ]),
        const SizedBox(height: 24),

        // ── Send Message Form ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(),
          child: Form(
            key: _contactFormKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Send a Message', style: AppTheme.headline3),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  prefixIcon:
                      const Icon(Icons.subject_rounded, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 2),
                  ),
                ),
                style:
                    const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Subject is required'
                        : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.message_outlined, size: 20),
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 2),
                  ),
                ),
                style:
                    const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Message is required'
                        : null,
              ),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _sending.value ? null : _sendContact,
                      icon: _sending.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _sending.value ? 'Sending…' : 'Send Message',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  )),
            ]),
          ),
        ),

        const SizedBox(height: 28),

        // ── My Sent Messages ─────────────────────────────────────────────
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inbox_rounded,
                color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('My Messages', style: AppTheme.headline3),
          const Spacer(),
          GestureDetector(
            onTap: () => _loadMyMessages(forceRefresh: true),
            child: const Icon(Icons.refresh_rounded,
                color: AppTheme.primary, size: 20),
          ),
        ]),
        const SizedBox(height: 12),

        Obx(() {
          if (_myMessagesLoading.value) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child:
                  CircularProgressIndicator(color: AppTheme.primary),
            ));
          }
          if (_myMessages.isEmpty) {
            return const _EmptyState(
              icon: Icons.inbox_outlined,
              message: 'No messages sent yet',
            );
          }
          return Column(
            children: _myMessages
                .map((msg) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ContactMessageCard(
                        msg: msg,
                        onResolve: null,
                      ),
                    ))
                .toList(),
          );
        }),
      ]),
    );
  }

  // ─── MESSAGES TAB (admin only — all user messages) ─────

  Widget _buildMessagesTab() {
    return Obx(() {
      if (_messagesLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary));
      }

      final open = _messages.where((m) => !m.isResolved).length;
      final resolved = _messages.where((m) => m.isResolved).length;

      final filtered = _messages.where((m) {
        if (_messageFilter == 'open') return !m.isResolved;
        if (_messageFilter == 'resolved') return m.isResolved;
        return true;
      }).toList();

      return RefreshIndicator(
        onRefresh: () => _loadMessages(forceRefresh: true),
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Row(children: [
              _StatCard(
                label: 'Open',
                count: open,
                color: AppTheme.warning,
                icon: Icons.mark_email_unread_rounded,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Resolved',
                count: resolved,
                color: AppTheme.success,
                icon: Icons.check_circle_rounded,
              ),
            ]),
            const SizedBox(height: 16),

            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final labels = [
                    'All (${_messages.length})',
                    'Open ($open)',
                    'Resolved ($resolved)'
                  ];
                  final keys = ['all', 'open', 'resolved'];
                  final colors = [
                    AppTheme.primary,
                    AppTheme.warning,
                    AppTheme.success
                  ];
                  final isSelected = _messageFilter == keys[i];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _messageFilter = keys[i]),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors[i]
                            : AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? colors[i]
                                : AppTheme.divider),
                      ),
                      alignment: Alignment.center,
                      child: Text(labels[i],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            if (filtered.isEmpty)
              _EmptyState(
                icon: Icons.inbox_outlined,
                message: _messageFilter == 'all'
                    ? 'No contact messages yet'
                    : 'No $_messageFilter messages',
              )
            else
              ...filtered.map((msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ContactMessageCard(
                      msg: msg,
                      onResolve: msg.isResolved
                          ? null
                          : () => _resolveMessage(msg.id),
                    ),
                  )),
          ],
        ),
      );
    });
  }

  // ─── BUILD ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Admin: 3 tabs | User: 2 tabs
    final tabs = _isAdmin
        ? [
            const Tab(
                icon: Icon(Icons.quiz_rounded, size: 18), text: 'FAQs'),
            const Tab(
                icon: Icon(Icons.contact_support_rounded, size: 18),
                text: 'Contact Us'), // ✅ Admin ka naya tab
            const Tab(
                icon: Icon(Icons.inbox_rounded, size: 18),
                text: 'Messages'),
          ]
        : [
            const Tab(
                icon: Icon(Icons.quiz_rounded, size: 18), text: 'FAQs'),
            const Tab(
                icon: Icon(Icons.contact_support_rounded, size: 18),
                text: 'Contact Us'),
          ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppTheme.textPrimary),
        ),
        actions: [
          // ✅ FIX: + button sirf FAQ tab (index 0) pe dikhao
          if (_isAdmin)
            AnimatedBuilder(
              animation: _tabController,
              builder: (_, __) => _tabController.index == 0
                  ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: AppTheme.primary, size: 20),
                      ),
                      onPressed: _showAddFaqDialog,
                      tooltip: 'Add FAQ',
                    )
                  : const SizedBox.shrink(),
            ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 12),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ),
      ),
      // ✅ FIX: Admin: 3 TabBarView children | User: 2 children
      body: TabBarView(
        controller: _tabController,
        children: _isAdmin
            ? [
                _buildFaqTab(),
                _buildContactTab(), // ✅ Admin bhi message send kar sakta hai
                _buildMessagesTab(),
              ]
            : [
                _buildFaqTab(),
                _buildContactTab(),
              ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────────────────

class _AdminFaqBanner extends StatelessWidget {
  final int totalFaqs;
  const _AdminFaqBanner({required this.totalFaqs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primary.withOpacity(0.15),
          AppTheme.primary.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.admin_panel_settings_rounded,
            color: AppTheme.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Admin View — $totalFaqs FAQ${totalFaqs == 1 ? '' : 's'} total. Tap + to add new.',
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary),
          ),
        ),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppTheme.textSecondary)),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ]),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              count.toString(),
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppTheme.textSecondary)),
          ]),
        ]),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final FaqModel faq;
  const _FaqCard({required this.faq});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.help_outline_rounded,
                color: AppTheme.primary, size: 18),
          ),
          title: Text(
            widget.faq.question,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textPrimary),
          ),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary),
          ),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          children: [
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 12),
            Text(
              widget.faq.answer,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5),
            ),
            if (widget.faq.category.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.faq.category,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactMessageCard extends StatelessWidget {
  final ContactMessageModel msg;
  final VoidCallback? onResolve;

  const _ContactMessageCard({required this.msg, this.onResolve});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(msg.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color:
                  msg.isResolved ? AppTheme.success : AppTheme.warning,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              msg.subject.isNotEmpty ? msg.subject : '(No Subject)',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: msg.isResolved
                  ? AppTheme.success.withOpacity(0.12)
                  : AppTheme.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              msg.isResolved ? 'Resolved' : 'Open',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: msg.isResolved
                      ? AppTheme.success
                      : AppTheme.warning),
            ),
          ),
        ]),
        const SizedBox(height: 8),

        if (msg.senderName.isNotEmpty || msg.senderEmail.isNotEmpty)
          Row(children: [
            const Icon(Icons.person_outline_rounded,
                size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              [msg.senderName, msg.senderEmail]
                  .where((s) => s.isNotEmpty)
                  .join(' · '),
              style: AppTheme.caption,
            ),
          ]),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            msg.message,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5),
          ),
        ),
        const SizedBox(height: 10),

        Row(children: [
          const Icon(Icons.access_time_rounded,
              size: 13, color: AppTheme.textHint),
          const SizedBox(width: 4),
          Text(dateStr, style: AppTheme.caption),
          const Spacer(),
          if (onResolve != null)
            GestureDetector(
              onTap: onResolve,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 14, color: AppTheme.success),
                  const SizedBox(width: 4),
                  const Text('Resolve',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success)),
                ]),
              ),
            ),
        ]),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            Icon(icon, size: 64, color: AppTheme.shimmerBase),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: AppTheme.textSecondary)),
          ]),
        ),
      );
}