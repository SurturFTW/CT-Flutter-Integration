import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';

import '../../config/app_colors.dart';

class OnsurityClaimPage extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;
  final String planName;

  const OnsurityClaimPage({
    Key? key,
    required this.primaryColor,
    required this.accentColor,
    required this.planName,
  }) : super(key: key);

  @override
  State<OnsurityClaimPage> createState() => _OnsurityClaimPageState();
}

class _OnsurityClaimPageState extends State<OnsurityClaimPage> {
  final _amountController = TextEditingController();
  String _selectedClaimType = 'Hospitalisation';
  DateTime? _admissionDate;
  bool _isCashless = true;
  bool _submitting = false;

  final List<String> _claimTypes = [
    'Hospitalisation',
    'OPD',
    'Dental',
    'Vision',
    'Mental Wellness',
    'Ambulance',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text('File a Claim',
            style: TextStyle(
                color: widget.primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: widget.primaryColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Claims are processed within 7 working days. Keep all bills & discharge summaries ready.',
                      style:
                          TextStyle(color: widget.primaryColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Claim Type'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _claimTypes.map((type) {
                final selected = _selectedClaimType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedClaimType = type);
                    HapticFeedback.selectionClick();
                  },
                  selectedColor: widget.primaryColor,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? widget.primaryColor
                        : AppColors.borderDefault,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Claim Amount (₹)'),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle:
                    TextStyle(color: widget.primaryColor, fontSize: 16),
                hintText: 'Enter claim amount',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderDefault)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderDefault)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: widget.primaryColor, width: 2)),
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Admission Date'),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 90)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _admissionDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: widget.primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _admissionDate == null
                          ? 'Select date'
                          : '${_admissionDate!.day}/${_admissionDate!.month}/${_admissionDate!.year}',
                      style: TextStyle(
                        color: _admissionDate == null
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Claim Mode'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  _ClaimModeOption(
                    title: 'Cashless',
                    subtitle: 'Direct settlement with network hospital',
                    selected: _isCashless,
                    icon: Icons.contactless_outlined,
                    color: widget.primaryColor,
                    onTap: () => setState(() => _isCashless = true),
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  _ClaimModeOption(
                    title: 'Reimbursement',
                    subtitle: 'Pay first, get refunded later',
                    selected: !_isCashless,
                    icon: Icons.account_balance_outlined,
                    color: widget.accentColor,
                    onTap: () => setState(() => _isCashless = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Claim',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8));

  void _submitClaim() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter claim amount')));
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _submitting = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _submitting = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.successDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Claim Submitted!',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Your $_selectedClaimType claim for ₹${_amountController.text} has been received. You will hear from us in 7 working days.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child:
                    const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ClaimModeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(selected ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? color : AppColors.textTertiary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? color : AppColors.borderDefault,
                    width: 2),
                color: selected ? color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
