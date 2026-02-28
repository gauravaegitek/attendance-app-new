import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wfh_controller.dart';
import '../../core/utils/response_handler.dart';
import '../../models/wfh_model.dart';

class WfhAdminScreen extends StatelessWidget {
  const WfhAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WfhController>();
    ctrl.loadAllRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WFH Requests'),
        actions: [
          Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: ctrl.statusFilter.value,
                  dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
                  style: const TextStyle(color: Colors.white),
                  items: ['all', 'Pending', 'Approved', 'Rejected']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (v) {
                    ctrl.statusFilter.value = v!;
                    ctrl.loadAllRequests(status: v);
                  },
                ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.allRequests.isEmpty) {
          return const Center(child: Text('No WFH requests found'));
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.loadAllRequests(status: ctrl.statusFilter.value),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ctrl.allRequests.length,
            itemBuilder: (_, i) => _AdminWfhCard(
              item: ctrl.allRequests[i],
              onApprove: (id) async {
                await ctrl.approveWFH(
                  wfhId: id,
                  action: 'Approved',
                );
              },
              onReject: (id) => _showRejectDialog(context, ctrl, id),
            ),
          ),
        );
      }),
    );
  }

  void _showRejectDialog(
      BuildContext context, WfhController ctrl, int wfhId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ctrl.approveWFH(
                wfhId: wfhId,
                action: 'Rejected',
                rejectionReason: reasonCtrl.text.trim(),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AdminWfhCard extends StatelessWidget {
  final WfhModel item;
  final Function(int) onApprove;
  final Function(int) onReject;

  const _AdminWfhCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = item.status.toLowerCase() == 'pending';
    final color = switch (item.status.toLowerCase()) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.userName ?? 'User #${item.userId}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Chip(
                  label: Text(item.status,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: color,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '📅 ${item.wfhDate.length >= 10 ? item.wfhDate.substring(0, 10) : item.wfhDate}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text('📝 ${item.reason}'),
            if (item.rejectionReason != null &&
                item.rejectionReason!.isNotEmpty)
              Text('❌ ${item.rejectionReason}',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),

            // Approve / Reject buttons — only for pending
            if (isPending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onReject(item.id),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Reject',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onApprove(item.id),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
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