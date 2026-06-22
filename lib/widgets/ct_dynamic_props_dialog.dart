export '../config/app_enums.dart' show SnackType;

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class CtDynamicPropsResult {
  const CtDynamicPropsResult({this.eventName, required this.props});
  final String? eventName;
  final Map<String, dynamic> props;
}

class _PropRow {
  _PropRow()
      : keyCtrl = TextEditingController(),
        valCtrl = TextEditingController();
  final TextEditingController keyCtrl;
  final TextEditingController valCtrl;
  void dispose() {
    keyCtrl.dispose();
    valCtrl.dispose();
  }
}

/// Bottom-sheet dialog that supports an optional event-name field and a
/// dynamic list of key-value property pairs.
class CtDynamicPropsDialog extends StatefulWidget {
  const CtDynamicPropsDialog({
    super.key,
    this.hasEventName = false,
    required this.title,
    this.subtitle,
    this.submitLabel = 'Submit',
  });

  final bool hasEventName;
  final String title;
  final String? subtitle;
  final String submitLabel;

  static Future<CtDynamicPropsResult?> show(
    BuildContext context, {
    bool hasEventName = false,
    required String title,
    String? subtitle,
    String submitLabel = 'Submit',
  }) {
    return showModalBottomSheet<CtDynamicPropsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CtDynamicPropsDialog(
        hasEventName: hasEventName,
        title: title,
        subtitle: subtitle,
        submitLabel: submitLabel,
      ),
    );
  }

  @override
  State<CtDynamicPropsDialog> createState() => _CtDynamicPropsDialogState();
}

class _CtDynamicPropsDialogState extends State<CtDynamicPropsDialog> {
  final _nameCtrl = TextEditingController();
  final List<_PropRow> _rows = [_PropRow()];
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_PropRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  void _submit() {
    if (widget.hasEventName && _nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Event name is required');
      return;
    }
    setState(() => _nameError = null);

    final props = <String, dynamic>{};
    for (final row in _rows) {
      final k = row.keyCtrl.text.trim();
      final v = row.valCtrl.text.trim();
      if (k.isNotEmpty) {
        props[k] = v;
      }
    }

    Navigator.of(context).pop(CtDynamicPropsResult(
      eventName: widget.hasEventName ? _nameCtrl.text.trim() : null,
      props: props,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle + header (fixed)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderDefault,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (widget.hasEventName) ...[
                      const SizedBox(height: 16),
                      _label('Event Name *'),
                      const SizedBox(height: 6),
                      _textField(
                        controller: _nameCtrl,
                        hint: 'e.g. Button Clicked',
                        error: _nameError,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'PROPERTIES',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'optional',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // Scrollable rows
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _rows.length,
                  itemBuilder: (_, i) => _buildRow(i),
                ),
              ),
              // Add row + buttons (fixed)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _addRow,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.midnight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text(
                              'Add Property',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _outlineBtn(
                            'Cancel',
                            () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _filledBtn(widget.submitLabel, _submit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _textField(
              controller: _rows[i].keyCtrl,
              hint: 'Key',
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _textField(
              controller: _rows[i].valCtrl,
              hint: 'Value',
              textInputAction:
                  i == _rows.length - 1 ? TextInputAction.done : TextInputAction.next,
              onSubmitted: i == _rows.length - 1 ? _submit : null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _rows.length > 1 ? () => _removeRow(i) : null,
            child: Container(
              width: 36,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _rows.length > 1
                    ? AppColors.errorDim
                    : AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: _rows.length > 1
                    ? AppColors.error
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? error,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textTertiary, fontSize: 13),
        errorText: error,
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
        filled: true,
        fillColor: AppColors.midnight,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
    );
  }

  Widget _filledBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textOnAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _outlineBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
