import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';

class BillPaymentPage extends StatefulWidget {
  final Color buttonColor;
  final Color textColor;
  final String availableCredit;

  const BillPaymentPage({
    Key? key,
    required this.buttonColor,
    required this.textColor,
    required this.availableCredit,
  }) : super(key: key);

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _selectedBillType = 'Credit Card';
  bool _enableAutoPayment = false;

  final List<String> _billTypes = [
    'Credit Card',
    'Electricity',
    'Water',
    'Internet',
    'Mobile',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bills'),
        backgroundColor: widget.buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDueReminderCard(),
            const SizedBox(height: 24),
            _buildBillTypeSelector(),
            const SizedBox(height: 20),
            _buildAmountField(),
            const SizedBox(height: 20),
            _buildDueDatePicker(),
            const SizedBox(height: 20),
            _buildAutoPaymentToggle(),
            const SizedBox(height: 30),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDueReminderCard() {
    final daysUntilDue = _dueDate.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.buttonColor.withOpacity(0.8), widget.buttonColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.buttonColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$daysUntilDue days until due',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _billTypes.map((type) {
            final isSelected = _selectedBillType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedBillType = type;
                });
                HapticFeedback.selectionClick();
              },
              selectedColor: widget.buttonColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : widget.textColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Amount to Pay',
        prefixText: '₹ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.buttonColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            _dueDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Due Date: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
              style: TextStyle(fontSize: 16, color: widget.textColor),
            ),
            Icon(Icons.calendar_today, color: widget.buttonColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoPaymentToggle() {
    return SwitchListTile(
      title: Text('Enable Auto Payment',
          style: TextStyle(color: widget.textColor)),
      subtitle: const Text('Automatically pay on due date'),
      value: _enableAutoPayment,
      activeColor: widget.buttonColor,
      onChanged: (value) {
        setState(() {
          _enableAutoPayment = value;
        });
        HapticFeedback.selectionClick();
      },
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (_amountController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter amount')),
            );
            return;
          }

          HapticFeedback.heavyImpact();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Payment Successful'),
              content: Text(
                  'Paid ₹${_amountController.text} for $_selectedBillType'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.buttonColor,
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Pay Now',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
