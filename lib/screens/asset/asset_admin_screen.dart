// lib/screens/asset/asset_admin_screen.dart
// ✅ Sirf Admin ke liye — full asset management

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/asset_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset_model_screen.dart';

class AssetAdminScreen extends StatefulWidget {
  const AssetAdminScreen({super.key});

  @override
  State<AssetAdminScreen> createState() => _AssetAdminScreenState();
}

class _AssetAdminScreenState extends State<AssetAdminScreen>
    with SingleTickerProviderStateMixin {
  late final AssetController _ctrl;
  late final TabController    _tab;

  String? _filterStatus;
  String? _filterType;

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

  // ── Helpers ───────────────────────────────────────────────────────────
  static Color statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'assigned':    return AppTheme.primary;
      case 'available':   return AppTheme.success;
      case 'maintenance': return AppTheme.warning;
      default:            return AppTheme.textSecondary;
    }
  }

  static Color actionColor(String a) {
    switch (a.toLowerCase()) {
      case 'assigned':  return AppTheme.primary;
      case 'returned':  return AppTheme.success;
      case 'added':     return AppTheme.info;
      case 'updated':   return AppTheme.accent;
      default:          return AppTheme.textSecondary;
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_box_rounded,
                    color: AppTheme.primary, size: 32),
              ),
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
              _DialogField(
                  ctrl: descCtrl,
                  label: 'Description',
                  hint: 'Optional notes about this asset',
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
                            if (ok) Get.back();
                          },
                    style: _primaryBtnStyle(),
                    child: _ctrl.isSubmitting.value
                        ? _LoadingIndicator()
                        : const Text('Add Asset',
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

  void _showAssignDialog(AssetModel asset) {
    final userIdCtrl = TextEditingController();
    final noteCtrl   = TextEditingController();
    final formKey    = GlobalKey<FormState>();
    DateTime? returnDate;
    final returnDateLabel = 'Select expected return date (optional)'.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_ind_rounded,
                    color: AppTheme.primary, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Assign Asset', style: AppTheme.headline2),
              const SizedBox(height: 6),
              Text(asset.assetName,
                  style: AppTheme.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextFormField(
                controller: userIdCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDeco(
                    label: 'Assign To (User ID)',
                    hint: 'Enter employee user ID',
                    prefixIcon: Icons.person_search_rounded),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'User ID is required' : null,
              ),
              const SizedBox(height: 12),
              Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    border: Border.all(color: AppTheme.divider),
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                              : AppTheme.textHint,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textHint, size: 18),
                  ]),
                ),
              )),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: noteCtrl,
                  label: 'Assignment Note',
                  hint: 'Optional note for employee',
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
                            if (!formKey.currentState!.validate()) return;
                            final ok = await _ctrl.assignAsset(
                              assetId: asset.id,
                              assignedToUserId:
                                  int.parse(userIdCtrl.text.trim()),
                              expectedReturnDate: returnDate,
                              assignmentNote:
                                  noteCtrl.text.trim().isEmpty
                                      ? null
                                      : noteCtrl.text.trim(),
                            );
                            if (ok) Get.back();
                          },
                    style: _primaryBtnStyle(),
                    child: _ctrl.isSubmitting.value
                        ? _LoadingIndicator()
                        : const Text('Assign',
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

  void _showReturnDialog(AssetModel asset) {
    final noteCtrl      = TextEditingController();
    final conditionCtrl = TextEditingController();
    final formKey       = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_return_rounded,
                    color: AppTheme.success, size: 32),
              ),
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
                  ctrl: noteCtrl,
                  label: 'Return Note',
                  hint: 'e.g. Returned in good condition'),
              const SizedBox(height: 12),
              _DialogField(
                  ctrl: conditionCtrl,
                  label: 'Condition',
                  hint: 'e.g. Good / Fair / Damaged'),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _CancelBtn()),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final ok = await _ctrl.returnAsset(
                              assetId:         asset.id,
                              returnNote:      noteCtrl.text.trim(),
                              returnCondition: conditionCtrl.text.trim(),
                            );
                            if (ok) Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _ctrl.isSubmitting.value
                        ? _LoadingIndicator()
                        : const Text('Confirm Return',
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
            title: const Text(
              'Asset Management',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppTheme.primary, size: 22),
                onPressed: () {
                  _ctrl.fetchAssets(
                      status: _filterStatus, assetType: _filterType);
                  _ctrl.fetchSummary();
                  _ctrl.fetchHistory();
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
            // ── Tab 1: All Assets ──────────────────────────────────────
            Column(children: [
              // Filter bar
              Container(
                color: AppTheme.cardBackground,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(children: [
                  Expanded(
                    child: _FilterDrop(
                      value: _filterStatus,
                      hint: 'All Status',
                      items: const [
                        'Available',
                        'Assigned',
                        'Maintenance'
                      ],
                      onChanged: (v) {
                        setState(() => _filterStatus = v);
                        _ctrl.fetchAssets(
                            status: v, assetType: _filterType);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterDrop(
                      value: _filterType,
                      hint: 'All Types',
                      items: const [
                        'Laptop',
                        'Mobile',
                        'Tablet',
                        'Monitor',
                        'Keyboard',
                        'Mouse'
                      ],
                      onChanged: (v) {
                        setState(() => _filterType = v);
                        _ctrl.fetchAssets(
                            status: _filterStatus, assetType: v);
                      },
                    ),
                  ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.filter_alt_off_rounded,
                          color: AppTheme.error, size: 18),
                    ),
                  ),
                ]),
              ),
              // List
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary));
                  }
                  if (_ctrl.assets.isEmpty) {
                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.07),
                                shape: BoxShape.circle,
                              ),
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
                            const Text('Try changing filters or add a new asset',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ]),
                    );
                  }
                  return RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: () => _ctrl.fetchAssets(
                        status: _filterStatus,
                        assetType: _filterType),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: _ctrl.assets.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final a = _ctrl.assets[i];
                        return GestureDetector(
                          onTap: () => Get.to(
                              () => AssetModelScreen(asset: a)),
                          child: _AdminAssetCard(
                            asset: a,
                            sColor: statusColor(a.status),
                            onAssign: a.status.toLowerCase() ==
                                    'available'
                                ? () => _showAssignDialog(a)
                                : null,
                            onReturn: a.status.toLowerCase() ==
                                    'assigned'
                                ? () => _showReturnDialog(a)
                                : null,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ]),

            // ── Tab 2: History ─────────────────────────────────────────
            Obx(() {
              if (_ctrl.isHistoryLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary));
              }
              if (_ctrl.history.isEmpty) {
                return const Center(
                  child: Text('No history available',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppTheme.textSecondary)),
                );
              }
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () => _ctrl.fetchHistory(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ctrl.history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _HistoryCard(history: _ctrl.history[i]),
                ),
              );
            }),

            // ── Tab 3: Summary ─────────────────────────────────────────
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
                          color: AppTheme.textSecondary)),
                );
              }
              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () => _ctrl.fetchSummary(),
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: _SummaryCard(
                              label: 'Total',
                              value: s.total.toString(),
                              icon: Icons.inventory_2_rounded,
                              color: AppTheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryCard(
                              label: 'Available',
                              value: s.available.toString(),
                              icon: Icons.check_circle_rounded,
                              color: AppTheme.success)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _SummaryCard(
                              label: 'Assigned',
                              value: s.assigned.toString(),
                              icon: Icons.person_rounded,
                              color: const Color(0xFF6366F1))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryCard(
                              label: 'Maintenance',
                              value: s.underMaintenance.toString(),
                              icon: Icons.build_rounded,
                              color: AppTheme.warning)),
                    ]),
                    const SizedBox(height: 22),
                    // Distribution bars
                    if (s.total > 0)
                      Container(
                        decoration: AppTheme.cardDecoration(),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Asset Distribution',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                    color: AppTheme.textPrimary,
                                  )),
                              const SizedBox(height: 18),
                              _ProgressBar(
                                  label: 'Available',
                                  value: s.available / s.total,
                                  color: AppTheme.success,
                                  count: s.available,
                                  total: s.total),
                              const SizedBox(height: 14),
                              _ProgressBar(
                                  label: 'Assigned',
                                  value: s.assigned / s.total,
                                  color: const Color(0xFF6366F1),
                                  count: s.assigned,
                                  total: s.total),
                              const SizedBox(height: 14),
                              _ProgressBar(
                                  label: 'Maintenance',
                                  value: s.underMaintenance / s.total,
                                  color: AppTheme.warning,
                                  count: s.underMaintenance,
                                  total: s.total),
                            ]),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Style Helpers ─────────────────────────────────────────────────────
  ButtonStyle _primaryBtnStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      );

  InputDecoration _inputDeco(
          {required String label,
          required String hint,
          required IconData prefixIcon}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        hintStyle: const TextStyle(fontFamily: 'Poppins'),
      );
}

// ─────────────────────────────────────────────
//  ADMIN ASSET CARD
// ─────────────────────────────────────────────
class _AdminAssetCard extends StatelessWidget {
  final AssetModel asset;
  final Color sColor;
  final VoidCallback? onAssign;
  final VoidCallback? onReturn;

  const _AdminAssetCard({
    required this.asset,
    required this.sColor,
    this.onAssign,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: sColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.devices_rounded, color: sColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(asset.assetName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary,
                  )),
              Text('${asset.assetType}  ·  ${asset.assetCode}',
                  style: AppTheme.caption),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(asset.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: sColor,
                )),
          ),
        ]),

        if (asset.assignedToName != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person_outline_rounded,
                size: 13, color: AppTheme.textHint),
            const SizedBox(width: 4),
            Text('Assigned to: ${asset.assignedToName}',
                style: AppTheme.caption),
          ]),
        ],

        // Tap hint
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.touch_app_rounded,
              size: 12, color: AppTheme.textHint),
          const SizedBox(width: 4),
          const Text('Tap to view details',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Poppins',
                color: AppTheme.textHint,
              )),
          const Spacer(),
          if (asset.brand.isNotEmpty)
            Text('${asset.brand} · ${asset.model}',
                style: AppTheme.caption),
        ]),

        if (onAssign != null || onReturn != null) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          Row(children: [
            if (onAssign != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAssign,
                  icon: const Icon(Icons.assignment_ind_rounded, size: 14),
                  label: const Text('Assign'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppTheme.primary),
                    textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            if (onReturn != null) ...[
              if (onAssign != null) const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReturn,
                  icon: const Icon(
                      Icons.assignment_return_rounded,
                      size: 14),
                  label: const Text('Return'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppTheme.success),
                    textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ]),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  HISTORY CARD
// ─────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final AssetHistoryModel history;
  const _HistoryCard({required this.history});

  Color get _color {
    switch (history.action.toLowerCase()) {
      case 'assigned':  return AppTheme.primary;
      case 'returned':  return AppTheme.success;
      case 'added':     return AppTheme.info;
      case 'updated':   return AppTheme.accent;
      default:          return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.history_rounded, color: _color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(
                  history.assetName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(history.action,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: _color,
                    )),
              ),
            ]),
            const SizedBox(height: 4),
            if (history.targetUserName != null)
              Text('To: ${history.targetUserName}',
                  style: AppTheme.caption),
            if (history.performedByName != null)
              Text('By: ${history.performedByName}',
                  style: AppTheme.caption),
            if (history.note != null && history.note!.isNotEmpty)
              Text(history.note!, style: AppTheme.caption),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy  ·  hh:mm a')
                  .format(history.createdAt),
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Poppins',
                color: AppTheme.textHint,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool required;
  final int maxLines;

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
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppTheme.primary, width: 2),
          ),
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
  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;

  const _FilterDrop({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(10),
          color: AppTheme.background,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppTheme.textHint)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppTheme.textSecondary),
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppTheme.textPrimary),
            items: items
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
                color: color,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              )),
        ]),
      );
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final int count;
  final int total;

  const _ProgressBar({
    required this.label,
    required this.value,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              )),
        ),
        Text(
          '$count / $total  (${(value * 100).toInt()}%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: color,
          ),
        ),
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
}

class _CancelBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppTheme.divider),
        ),
        child: const Text('Cancel',
            style: TextStyle(
                fontFamily: 'Poppins', color: AppTheme.textSecondary)),
      );
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
}
