import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class CtInputField {
  const CtInputField({
    required this.key,
    required this.label,
    this.hint = '',
    this.required = true,
    this.keyboardType = TextInputType.text,
    this.initialValue = '',
  });

  final String key;
  final String label;
  final String hint;
  final bool required;
  final TextInputType keyboardType;
  final String initialValue;
}

/// Themed bottom-sheet input form. Returns a map of field keys → values,
/// or null if the user cancelled.
class CtInputDialog extends StatefulWidget {
  const CtInputDialog({
    super.key,
    required this.title,
    required this.fields,
    this.subtitle,
    this.submitLabel = 'Submit',
  });

  final String title;
  final String? subtitle;
  final List<CtInputField> fields;
  final String submitLabel;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String title,
    required List<CtInputField> fields,
    String? subtitle,
    String submitLabel = 'Submit',
  }) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CtInputDialog(
        title: title,
        subtitle: subtitle,
        fields: fields,
        submitLabel: submitLabel,
      ),
    );
  }

  @override
  State<CtInputDialog> createState() => _CtInputDialogState();
}

class _CtInputDialogState extends State<CtInputDialog> {
  late final Map<String, TextEditingController> _controllers;
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.fields)
        f.key: TextEditingController(text: f.initialValue),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    setState(() {
      for (final f in widget.fields) {
        if (f.required && _controllers[f.key]!.text.trim().isEmpty) {
          _errors[f.key] = '${f.label} is required';
        } else {
          _errors.remove(f.key);
        }
      }
    });
    if (_errors.isNotEmpty) return;
    final result = {
      for (final f in widget.fields) f.key: _controllers[f.key]!.text.trim(),
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            for (int i = 0; i < widget.fields.length; i++) ...[
              _CtTextField(
                field: widget.fields[i],
                controller: _controllers[widget.fields[i].key]!,
                error: _errors[widget.fields[i].key],
                isLast: i == widget.fields.length - 1,
                onSubmit: _submit,
              ),
              if (i < widget.fields.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _CtOutlineButton(
                    label: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _CtFilledButton(
                    label: widget.submitLabel,
                    onTap: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CtTextField extends StatelessWidget {
  const _CtTextField({
    required this.field,
    required this.controller,
    required this.isLast,
    required this.onSubmit,
    this.error,
  });

  final CtInputField field;
  final TextEditingController controller;
  final bool isLast;
  final VoidCallback onSubmit;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label + (field.required ? ' *' : ''),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: field.keyboardType,
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: field.hint,
            hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
            errorText: error,
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
            filled: true,
            fillColor: AppColors.midnight,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          onSubmitted: (_) {
            if (isLast) onSubmit();
          },
        ),
      ],
    );
  }
}

class _CtFilledButton extends StatelessWidget {
  const _CtFilledButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
}

class _CtOutlineButton extends StatelessWidget {
  const _CtOutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
