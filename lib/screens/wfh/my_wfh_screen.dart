import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wfh_controller.dart';
import '../../models/wfh_model.dart';

class MyWfhScreen extends StatelessWidget {
  const MyWfhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WfhController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My WFH Requests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRequestDialog(context, ctrl),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.myRequests.isEmpty) {
          return const Center(
            child: Text('No WFH requests yet.\nTap + to submit one.',
                textAlign: TextAlign.center),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.loadMyRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ctrl.myRequests.length,
            itemBuilder: (_, i) => _WfhCard(item: ctrl.myRequests[i]),
          ),
        );
      }),
    );
  }

  void _showRequestDialog(BuildContext context, WfhController ctrl) async {
    DateTime? selectedDate;
    final reasonCtrl = TextEditingController();

    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (selectedDate == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('WFH Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${selectedDate!.toLocal().toString().substring(0, 10)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please enter a reason');
                return;
              }
              Navigator.pop(ctx);
              final ok = await ctrl.requestWFH(
                wfhDate: selectedDate!.toIso8601String(),
                reason: reasonCtrl.text.trim(),
              );
              Get.snackbar(
                ok ? 'Success' : 'Failed',
                ok ? 'WFH request submitted!' : 'Something went wrong',
                backgroundColor: ok ? Colors.green : Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _WfhCard extends StatelessWidget {
  final WfhModel item;
  const _WfhCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status.toLowerCase()) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.home_work_outlined, color: color),
        ),
        title: Text(
          item.wfhDate.length >= 10 ? item.wfhDate.substring(0, 10) : item.wfhDate,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.reason),
            if (item.rejectionReason != null && item.rejectionReason!.isNotEmpty)
              Text('Reason: ${item.rejectionReason}',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        trailing: Chip(
          label: Text(item.status,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
        isThreeLine: item.rejectionReason != null,
      ),
    );
  }
}