
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomMonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomMonthYearPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  _CustomMonthYearPickerDialogState createState() => _CustomMonthYearPickerDialogState();
}

class _CustomMonthYearPickerDialogState extends State<CustomMonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(widget.lastDate.year - widget.firstDate.year + 1, (i) => widget.firstDate.year + i);
    final months = List<String>.generate(12, (i) => DateFormat('MMMM').format(DateTime(0, i + 1)));

    return AlertDialog(
      title: const Text('Select Month and Year'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownButton<int>(
            value: _selectedMonth,
            items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(months[i]))),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMonth = newValue;
                });
              }
            },
          ),
          DropdownButton<int>(
            value: _selectedYear,
            items: years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedYear = newValue;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(DateTime(_selectedYear, _selectedMonth));
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
