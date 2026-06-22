import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_enums.dart';
import '../services/clevertap_service.dart';
import '../utils/ct_snack.dart';
import '../widgets/action_section.dart';
import '../widgets/ct_input_dialog.dart';
import '../widgets/ct_dynamic_props_dialog.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.isLoggedIn,
    required this.cleverTapId,
    required this.pulseAnim,
    required this.onLogin,
  });

  final bool isLoggedIn;
  final String? cleverTapId;
  final Animation<double> pulseAnim;
  final Function(Map<String, dynamic>) onLogin;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _identityController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _identityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final identity = _identityController.text.trim();
    if (identity.isEmpty) return;

    final profile = <String, dynamic>{'Identity': identity};
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isNotEmpty) profile['Name'] = name;
    if (email.isNotEmpty) profile['Email'] = email;
    if (phone.isNotEmpty) profile['Phone'] = phone;

    widget.onLogin(profile);
  }

  Future<void> _setProfileProperty() async {
    final result = await CtDynamicPropsDialog.show(
      context,
      title: 'Set Profile Properties',
      subtitle: 'Set one or more properties on the current user profile',
      submitLabel: 'Update',
    );
    if (result == null) return;
    if (result.props.isEmpty) return;
    try {
      CleverTapService().profileSet(result.props);
      final count = result.props.length;
      if (mounted) {
        ctSnack(context,
            message:
                '$count profile propert${count == 1 ? 'y' : 'ies'} updated',
            type: SnackType.success);
      }
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _getProfileProperty() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Get Profile Property',
      subtitle: 'Retrieve a property value from the user profile',
      submitLabel: 'Get',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Plan'),
      ],
    );
    if (result == null) return;
    try {
      final value = await CleverTapService().profileGetProperty(result['key']!);
      debugPrint('Profile Property [${result['key']}]: $value');
      if (mounted)
        ctSnack(context,
            message: '${result['key']}: $value', type: SnackType.info);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _removeProfileProperty() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Remove Property',
      subtitle: 'Remove a property from the user profile',
      submitLabel: 'Remove',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Plan'),
      ],
    );
    if (result == null) return;
    try {
      CleverTapService().profileRemoveValueForKey(result['key']!);
      if (mounted)
        ctSnack(context,
            message: 'Removed: ${result['key']}', type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _setMultiValues() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Set Multi-Values',
      subtitle: 'Set a list of values for a profile property',
      submitLabel: 'Set',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Tags'),
        CtInputField(
            key: 'values',
            label: 'Values (comma-separated)',
            hint: 'e.g. sports,music,tech'),
      ],
    );
    if (result == null) return;
    try {
      final values = result['values']!
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();
      CleverTapService().profileSetMultiValues(result['key']!, values);
      if (mounted)
        ctSnack(context,
            message: 'Set ${values.length} values for ${result['key']}',
            type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _addMultiValue() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Add Multi-Value',
      subtitle: 'Add a single value to a multi-value property',
      submitLabel: 'Add',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Tags'),
        CtInputField(key: 'value', label: 'Value', hint: 'e.g. sports'),
      ],
    );
    if (result == null) return;
    try {
      CleverTapService().profileAddMultiValue(result['key']!, result['value']!);
      if (mounted)
        ctSnack(context,
            message: 'Added "${result['value']}" to ${result['key']}',
            type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _removeMultiValue() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Remove Multi-Value',
      subtitle: 'Remove a single value from a multi-value property',
      submitLabel: 'Remove',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Tags'),
        CtInputField(key: 'value', label: 'Value', hint: 'e.g. sports'),
      ],
    );
    if (result == null) return;
    try {
      CleverTapService()
          .profileRemoveMultiValue(result['key']!, result['value']!);
      if (mounted)
        ctSnack(context,
            message: 'Removed "${result['value']}" from ${result['key']}',
            type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _incrementValue() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Increment Value',
      subtitle: 'Increment a numeric profile property by 15',
      submitLabel: 'Increment',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Score'),
      ],
    );
    if (result == null) return;
    try {
      CleverTapService().profileIncrementValue(result['key']!, 15);
      if (mounted)
        ctSnack(context,
            message: '${result['key']} incremented by 15',
            type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _decrementValue() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Decrement Value',
      subtitle: 'Decrement a numeric profile property by 10',
      submitLabel: 'Decrement',
      fields: const [
        CtInputField(key: 'key', label: 'Property Key', hint: 'e.g. Score'),
      ],
    );
    if (result == null) return;
    try {
      CleverTapService().profileDecrementValue(result['key']!, 10);
      if (mounted)
        ctSnack(context,
            message: '${result['key']} decremented by 10',
            type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _setLocation() async {
    final result = await CtInputDialog.show(
      context,
      title: 'Set Location',
      subtitle: 'Update the user location on CleverTap',
      submitLabel: 'Set',
      fields: const [
        CtInputField(key: 'lat', label: 'Latitude', hint: 'e.g. 19.0760'),
        CtInputField(key: 'lng', label: 'Longitude', hint: 'e.g. 72.8777'),
      ],
    );
    if (result == null) return;
    try {
      final lat = double.parse(result['lat']!);
      final lng = double.parse(result['lng']!);
      CleverTapService().setLocation(lat, lng);
      if (mounted)
        ctSnack(context,
            message: 'Location set: $lat, $lng', type: SnackType.success);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdentityCard(),
          const SizedBox(height: 20),
          _buildLoginForm(),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Authentication',
            icon: Icons.shield_outlined,
            iconColor: AppColors.accent,
            tiles: [
              ActionTileData(
                label: 'Get CT ID',
                subtitle: 'Get CleverTap ID for this device',
                icon: Icons.perm_identity_outlined,
                color: AppColors.violet,
                onTap: () async {
                  try {
                    final id = await CleverTapService().getCleverTapId();
                    debugPrint('CleverTap ID: $id');
                    if (mounted)
                      ctSnack(context,
                          message: 'CT ID: ${id ?? 'N/A'}',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Profile Properties',
            icon: Icons.edit_attributes_outlined,
            iconColor: AppColors.emerald,
            tiles: [
              ActionTileData(
                label: 'Set Profile Property',
                subtitle: 'Update a custom user attribute',
                icon: Icons.edit_attributes_outlined,
                color: AppColors.emerald,
                onTap: _setProfileProperty,
              ),
              ActionTileData(
                label: 'Get Profile Property',
                subtitle: 'Retrieve a property value',
                icon: Icons.manage_search_outlined,
                color: AppColors.emerald,
                onTap: _getProfileProperty,
              ),
              ActionTileData(
                label: 'Remove Property',
                subtitle: 'Delete a property from profile',
                icon: Icons.remove_circle_outline,
                color: AppColors.emerald,
                onTap: _removeProfileProperty,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Multi-Value Properties',
            icon: Icons.list_alt_outlined,
            iconColor: AppColors.violet,
            tiles: [
              ActionTileData(
                label: 'Set Multi-Values',
                subtitle: 'Replace all values for a property',
                icon: Icons.playlist_add_rounded,
                color: AppColors.violet,
                onTap: _setMultiValues,
              ),
              ActionTileData(
                label: 'Add Multi-Value',
                subtitle: 'Append a value to a list property',
                icon: Icons.add_circle_outline_rounded,
                color: AppColors.violet,
                onTap: _addMultiValue,
              ),
              ActionTileData(
                label: 'Remove Multi-Value',
                subtitle: 'Remove a value from a list property',
                icon: Icons.remove_circle_outline_rounded,
                color: AppColors.violet,
                onTap: _removeMultiValue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Numeric Properties',
            icon: Icons.exposure_rounded,
            iconColor: AppColors.amber,
            tiles: [
              ActionTileData(
                label: 'Increment Value (+15)',
                subtitle: 'Add 15 to a numeric property',
                icon: Icons.add_rounded,
                color: AppColors.amber,
                onTap: _incrementValue,
              ),
              ActionTileData(
                label: 'Decrement Value (-10)',
                subtitle: 'Subtract 10 from a numeric property',
                icon: Icons.remove_rounded,
                color: AppColors.amber,
                onTap: _decrementValue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Location',
            icon: Icons.location_on_outlined,
            iconColor: AppColors.teal,
            tiles: [
              ActionTileData(
                label: 'Set Location',
                subtitle: 'Update user latitude and longitude',
                icon: Icons.location_on_outlined,
                color: AppColors.teal,
                onTap: _setLocation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fingerprint_rounded,
                  size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'USER LOGIN'.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FormField(
            controller: _identityController,
            label: 'Identity *',
            hint: 'e.g. user_123',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _FormField(
            controller: _nameController,
            label: 'Name',
            hint: 'e.g. Jane Doe',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _FormField(
            controller: _emailController,
            label: 'Email',
            hint: 'e.g. jane@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _FormField(
            controller: _phoneController,
            label: 'Phone',
            hint: 'e.g. +911234567890',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: () => _submitLogin(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submitLogin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: widget.isLoggedIn
                      ? AppColors.accentDim
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isLoggedIn
                      ? Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.isLoggedIn ? 'Re-Login' : 'Login',
                  style: TextStyle(
                    color: widget.isLoggedIn
                        ? AppColors.accentSoft
                        : AppColors.textOnAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('logo.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CleverTap SDK',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Demo Application',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.isLoggedIn
                      ? AppColors.successDim
                      : AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isLoggedIn
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.borderDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: widget.pulseAnim,
                      builder: (_, __) => Opacity(
                        opacity:
                            widget.isLoggedIn ? widget.pulseAnim.value : 0.5,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isLoggedIn
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isLoggedIn ? 'Active' : 'Guest',
                      style: TextStyle(
                        color: widget.isLoggedIn
                            ? AppColors.success
                            : AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isLoggedIn && widget.cleverTapId != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.key_rounded,
                      size: 13, color: AppColors.accentSoft),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'CT ID: ${widget.cleverTapId}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.accentSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textTertiary, fontSize: 14),
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
          ),
          onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
        ),
      ],
    );
  }
}
