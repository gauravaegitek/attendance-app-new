// lib/screens/performance/widgets/date_range_filter.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final void Function(DateTime from, DateTime to) onChanged;

  const DateRangeFilter({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onChanged,
  });

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month + 1, 0); // last day of current month

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: last,
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(ctx).primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      onChanged(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // ── From Date ─────────────────────────────────────────────────────
          Expanded(
            child: _DateBox(
              label: 'From',
              date: _fmt(fromDate),
              onTap: () => _pick(context),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, size: 18, color: Color(0xFF9CA3AF)),
          ),

          // ── To Date ───────────────────────────────────────────────────────
          Expanded(
            child: _DateBox(
              label: 'To',
              date: _fmt(toDate),
              onTap: () => _pick(context),
            ),
          ),

          // ── Calendar Icon ─────────────────────────────────────────────────
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _pick(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.date_range_outlined,
                  size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.expand_more, size: 16, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}