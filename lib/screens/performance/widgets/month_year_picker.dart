// lib/screens/performance/widgets/month_year_picker.dart

import 'package:flutter/material.dart';

class MonthYearPicker extends StatefulWidget {
  final int month;
  final int year;
  final void Function(int month, int year) onChanged;

  const MonthYearPicker({
    super.key,
    required this.month,
    required this.year,
    required this.onChanged,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int _month;
  late int _year;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    _year  = widget.year;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) { _month = 12; _year--; }
      else { _month--; }
    });
    widget.onChanged(_month, _year);
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_year > now.year || (_year == now.year && _month >= now.month)) return;
    setState(() {
      if (_month == 12) { _month = 1; _year++; }
      else { _month++; }
    });
    widget.onChanged(_month, _year);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month == now.month && _year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Prev
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),

          // Month Year label
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_months[_month - 1]} $_year',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),

          const Spacer(),

          // Next
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _isCurrentMonth ? Colors.grey.shade300 : null,
            ),
            onPressed: _isCurrentMonth ? null : _nextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    int tempMonth = _month;
    int tempYear  = _year;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModal) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setModal(() => tempYear--),
                    ),
                    Text('$tempYear',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (tempYear < DateTime.now().year) {
                          setModal(() => tempYear++);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Month grid
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: List.generate(12, (i) {
                    final m = i + 1;
                    final isSel = m == tempMonth;
                    return GestureDetector(
                      onTap: () => setModal(() => tempMonth = m),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSel
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _months[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSel ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _month = tempMonth;
                        _year  = tempYear;
                      });
                      widget.onChanged(_month, _year);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}