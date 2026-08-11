import 'dart:math';

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_enums.dart';
import '../services/clevertap_service.dart';
import '../utils/ct_snack.dart';
import '../widgets/action_section.dart';
import '../widgets/ct_input_dialog.dart';
import '../widgets/ct_dynamic_props_dialog.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.onDeepLink,
    required this.hasDisplayUnits,
    required this.displayUnitsCount,
    required this.onGetDisplayUnits,
    required this.onNativeDisplayEvent,
    required this.onNavigateNativeDisplayPage,
  });

  final VoidCallback onDeepLink;
  final bool hasDisplayUnits;
  final int displayUnitsCount;
  final VoidCallback onGetDisplayUnits;
  final VoidCallback onNativeDisplayEvent;
  final VoidCallback onNavigateNativeDisplayPage;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  Future<void> _showCustomEventDialog() async {
    final result = await CtDynamicPropsDialog.show(
      context,
      hasEventName: true,
      title: 'Custom Event',
      subtitle: 'Fire a named event with any number of properties',
      submitLabel: 'Fire Event',
    );
    if (result == null) return;
    try {
      CleverTapService().recordEvent(result.eventName!, result.props);
      final count = result.props.length;
      final propsStr =
          count == 0 ? '' : ' ($count prop${count == 1 ? '' : 's'})';
      if (mounted) {
        ctSnack(context,
            message: 'Event fired: ${result.eventName}$propsStr',
            type: SnackType.success);
      }
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _showIdDialog(String title, String subtitle,
      Future<void> Function(String id) action) async {
    final result = await CtInputDialog.show(
      context,
      title: title,
      subtitle: subtitle,
      submitLabel: 'Submit',
      fields: const [
        CtInputField(key: 'id', label: 'Message ID', hint: 'e.g. abc123'),
      ],
    );
    if (result == null) return;
    try {
      await action(result['id']!);
    } catch (e) {
      if (mounted)
        ctSnack(context, message: 'Error: $e', type: SnackType.error);
    }
  }

  Future<void> _showEventNameDialog(
      String title, Future<void> Function(String name) action) async {
    final result = await CtInputDialog.show(
      context,
      title: title,
      subtitle: 'Enter the event name to look up',
      submitLabel: 'Submit',
      fields: const [
        CtInputField(
            key: 'name', label: 'Event Name', hint: 'e.g. Product Viewed'),
      ],
    );
    if (result == null) return;
    try {
      await action(result['name']!);
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
        children: [
          ActionSection(
            label: 'Custom Event',
            icon: Icons.edit_outlined,
            iconColor: AppColors.sky,
            tiles: [
              ActionTileData(
                label: 'Fire Custom Event',
                subtitle: 'Enter event name + optional property',
                icon: Icons.add_circle_outline_rounded,
                color: AppColors.sky,
                onTap: _showCustomEventDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Standard Events',
            icon: Icons.bolt_outlined,
            iconColor: AppColors.amber,
            tiles: [
              ActionTileData(
                label: 'Notification Event',
                subtitle: 'Fire a notification trigger',
                icon: Icons.notifications_active_outlined,
                color: AppColors.amber,
                onTap: () {
                  try {
                    CleverTapService().recordEvent('Notification Event');
                    ctSnack(context,
                        message: 'Notification event fired',
                        type: SnackType.success);
                  } catch (e) {
                    ctSnack(context,
                        message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Product Viewed',
                subtitle: 'Premium Plan — PROD_123',
                icon: Icons.storefront_outlined,
                color: AppColors.emerald,
                onTap: () {
                  try {
                    CleverTapService().recordEvent('Product Viewed', {
                      'product_id': 'PROD_123',
                      'product_name': 'Premium Plan',
                      'category': 'subscription',
                    });
                    ctSnack(context,
                        message: 'Product Viewed event fired',
                        type: SnackType.success);
                  } catch (e) {
                    ctSnack(context,
                        message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'In-App Event',
                subtitle: 'Trigger an in-app campaign',
                icon: Icons.phone_iphone_rounded,
                color: AppColors.violet,
                onTap: () {
                  try {
                    CleverTapService().recordEvent('In-App Event');
                    ctSnack(context,
                        message: 'In-App event fired', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context,
                        message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Charged Event',
                subtitle: '₹498 — credit card, INR',
                icon: Icons.receipt_long_outlined,
                color: AppColors.teal,
                onTap: () {
                  try {
                    CleverTapService().recordChargedEvent({
                      'total': '498',
                      'payment': 'credit_card',
                      'currency': 'INR',
                      'transaction_id':
                          'TXN_${DateTime.now().millisecondsSinceEpoch}',
                    }, [
                      {
                        'name': 'Premium Subscription',
                        'amount': '299',
                        'category': 'digital'
                      },
                      {
                        'name': 'Extra Features',
                        'amount': '199',
                        'category': 'addon'
                      },
                    ]);
                    ctSnack(context,
                        message: 'Charged ₹498 — event fired',
                        type: SnackType.success);
                  } catch (e) {
                    ctSnack(context,
                        message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Deep Link',
                subtitle: 'Open deep link page',
                icon: Icons.link,
                color: AppColors.pink,
                onTap: widget.onDeepLink,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Campaigns',
            icon: Icons.campaign_outlined,
            iconColor: AppColors.sky,
            tiles: [
              ActionTileData(
                label: 'Email Campaign',
                subtitle: 'Heart rate health event',
                icon: Icons.mail_outline_rounded,
                color: AppColors.sky,
                onTap: () {
                  final hr = 50 + Random().nextInt(51);
                  CleverTapService().recordEvent('Health', {'Heart Rate': hr});
                  ctSnack(context,
                      message: 'Health event — HR: $hr bpm',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Rich Push',
                subtitle: 'Media-rich notification',
                icon: Icons.circle_notifications_outlined,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Rich Push');
                  ctSnack(context,
                      message: 'Rich Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Linked Content',
                subtitle: 'Dynamic content fetch',
                icon: Icons.link_rounded,
                color: AppColors.lime,
                onTap: () {
                  CleverTapService().recordEvent('android Purchase');
                  ctSnack(context,
                      message: 'Linked content event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Medical Condition',
                subtitle: 'POP Remove Cart event',
                icon: Icons.medical_services_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent('POP Remove Cart');
                  ctSnack(context,
                      message: 'POP Remove Cart fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Multi Value Event',
                subtitle: 'Collection Viewed event',
                icon: Icons.medical_services_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent("Collection Viewed", {
                    "Platform": "android",
                    "Collection Handle": "rareism-eoss",
                    "Collection ID": "293491048519",
                    "Collection Page name": "RAREISM EOSS",
                    "Collection Title": "RAREISM EOSS",
                    "Collection URL":
                        "https://thehouseofrare.com/collections/rareism-eoss",
                    "Vendor_Source": "APP",
                    "Category": [
                      "TOP",
                      "DRESS",
                      "TROUSER",
                      "T-SHIRT",
                      "SHIRT",
                      "JEANS",
                      "SKIRT",
                      "POLO",
                      "SHORTS",
                      "TRACK PANT",
                      "SHRUG",
                      "BELT",
                      "SWEATER",
                      "SWEAT TEE",
                      "OUTER WEAR",
                      "INNERWEAR",
                      "BAG",
                      "WAIST COAT",
                      "BLAZER",
                      "PLAYSUIT",
                    ],
                    "Fabric": [
                      "COTTON",
                      "POLYESTER",
                      "COTTON BLEND",
                      "POLYESTER BLEND",
                      "VISCOSE BLEND",
                      "VISCOSE",
                      "SATIN",
                      "LINEN",
                      "LINEN BLEND",
                      "MODAL",
                      "100% LINEN",
                      "LEATHER",
                      "NYLON BLEND",
                      "POPLIN",
                      "VELVET",
                      "MODAL BLEND",
                      "RAYON BLEND",
                      "ACRYLIC BLEND",
                      "WAKANDA",
                      "RAYON",
                    ],
                    "Color": [
                      "BLACK",
                      "MULTI",
                      "BLUE",
                      "PINK",
                      "GREEN",
                      "BEIGE",
                      "OFF WHITE",
                      "WHITE",
                      "BROWN",
                      "NAVY",
                      "PURPLE",
                      "YELLOW",
                      "OLIVE",
                      "MAROON",
                      "RED",
                      "GREY",
                      "ORANGE",
                      "RUST",
                      "MUSTARD",
                      "PEACH",
                    ],
                    "CLOSURE": [
                      "PULL-ON",
                      "BUTTON",
                      "ZIPPER",
                      "TIE-UP",
                      "DRAWSTRING",
                      "HOOK",
                      "BUTTON AND ZIP",
                      "SHANK AND ZIPPER",
                      "ELASTIC",
                      "BUCKLE",
                      "CROP",
                      "WRAP",
                      "Zipper",
                    ],
                    "COLLAR": [
                      "CREW NECK",
                      "V-NECK",
                      "SPREAD COLLAR",
                      "MANDARIN COLLAR",
                      "DROP COLLAR",
                      "TIE-UP",
                      "HIGH NECK",
                      "BOAT NECK",
                      "JOHNNY COLLAR",
                      "SHOULDER STRAP",
                      "COWL NECK",
                      "OVERLAP",
                      "LAPEL NECK",
                      "HALTER NECK",
                      "COLLARLESS",
                      "TUBE NECK",
                      "BAND COLLAR",
                      "RUFFLED NECK",
                      "ONE SHOULDER",
                      "SWEETHEART NECK",
                    ],
                    "FIT": [
                      "REGULAR",
                      "RELAXED",
                      "FIT AND FLARE",
                      "FLARED",
                      "A-LINE",
                      "STRAIGHT",
                      "WIDE LEG",
                      "BOXY",
                      "TAILORED",
                      "OVERSIZED",
                      "FITTED",
                      "TAPERED",
                      "SLIM",
                      "TALL STRAIGHT",
                      "CLASSIC BOOTCUT",
                      "SLEEK SKINNY",
                      "BOOTCUT",
                      "SCULPT HIGH WIDE",
                      "BODYCON",
                      "WRAP",
                    ],
                    "OCCASION": [
                      "CASUAL",
                      "BRUNCH",
                      "FORMAL",
                      "EVENING",
                      "RESORT",
                      "PARTY",
                      "BUSINESS",
                      "DESK TO DINNER",
                      "SUMMER",
                      "WINTER",
                      "FESTIVE",
                      "EVERYDAY",
                      "WORKWEAR",
                      "ETHNIC",
                      "SEMI FORMAL",
                      "TRAVEL",
                      "BASICS",
                      "CORE",
                    ],
                    "PATTERN": [
                      "PLAIN",
                      "FLORAL PRINT",
                      "ABSTRACT PRINT",
                      "GEOMETRIC PRINT",
                      "GRAPHIC PRINT",
                      "PRINTED",
                      "STRIPED",
                      "PAISLEY PRINT",
                      "POLKA PRINT",
                      "TYPOGRAPHY PRINT",
                      "EMBROIDERED",
                      "SEQUINED",
                      "MONOGRAM PRINT",
                      "SCHIFFILI",
                      "JACQUARD",
                      "OMBRE",
                      "TROPICAL PRINT",
                      "FLANNEL PRINT",
                      "DYED",
                      "CHECKED",
                    ],
                    "SLEEVE": [
                      "FULL SLEEVE",
                      "HALF SLEEVE",
                      "SLEEVELESS",
                      "3/4TH SLEEVE"
                    ],
                    "Login Status": "Logged In",
                    "Vendor name": "RARERABBIT",
                    "Customer Type": "Repeat",
                  });
                  ctSnack(context,
                      message: 'Collection Viewed fired',
                      type: SnackType.success);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Push Templates',
            icon: Icons.notifications_outlined,
            iconColor: AppColors.rose,
            tiles: [
              ActionTileData(
                label: 'Basic',
                subtitle: 'Simple text notification',
                icon: Icons.notifications_rounded,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Rich Push');
                  ctSnack(context,
                      message: 'Rich Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Zero Bezel',
                subtitle: 'Full-width image notification',
                icon: Icons.crop_square_rounded,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Zero Bezel Push');
                  ctSnack(context,
                      message: 'Zero Bezel Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Manual Carousel',
                subtitle: 'User-controlled carousel',
                icon: Icons.swipe_outlined,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Manual Carousel Push');
                  ctSnack(context,
                      message: 'Manual Carousel Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Auto Carousel',
                subtitle: 'Auto-scrolling images',
                icon: Icons.view_carousel_outlined,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Auto Carousel Push');
                  ctSnack(context,
                      message: 'Auto Carousel Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Timer (Countdown)',
                subtitle: 'Dynamic countdown timer',
                icon: Icons.hourglass_bottom_rounded,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Timer Dynamic Countdown');
                  ctSnack(context,
                      message: 'Timer Dynamic Countdown fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Timer (Until Time)',
                subtitle: 'Until mentioned time in seconds',
                icon: Icons.schedule_rounded,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Timer Until Time');
                  ctSnack(context,
                      message: 'Timer Until Time fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Five Icons',
                subtitle: 'Multiple action buttons',
                icon: Icons.widgets_outlined,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Five Icons Push');
                  ctSnack(context,
                      message: 'Five Icons Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Rating',
                subtitle: 'Star rating in-push interaction',
                icon: Icons.star_outline_rounded,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Rating Push');
                  ctSnack(context,
                      message: 'Rating Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Input',
                subtitle: 'User text input field',
                icon: Icons.input_rounded,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Input Push');
                  ctSnack(context,
                      message: 'Input Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Product Display',
                subtitle: 'Product showcase template',
                icon: Icons.shopping_bag_outlined,
                color: AppColors.rose,
                onTap: () {
                  CleverTapService().recordEvent('Product Display Push');
                  ctSnack(context,
                      message: 'Product Display Push event fired',
                      type: SnackType.success);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Deep Link Push',
            icon: Icons.link_rounded,
            iconColor: AppColors.emerald,
            tiles: [
              ActionTileData(
                label: 'Phone Call',
                subtitle: 'Initiates phone call',
                icon: Icons.phone_outlined,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('Notification Event');
                  ctSnack(context,
                      message: 'Phone Call push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Send SMS',
                subtitle: 'Opens SMS composer',
                icon: Icons.sms_outlined,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('SMS Push');
                  ctSnack(context,
                      message: 'SMS Push event fired', type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Send Email',
                subtitle: 'Opens email composer',
                icon: Icons.mail_outline_rounded,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('Email Push');
                  ctSnack(context,
                      message: 'Email Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'WhatsApp',
                subtitle: 'Opens WhatsApp chat',
                icon: Icons.chat_outlined,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('WhatsApp Push');
                  ctSnack(context,
                      message: 'WhatsApp Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Google Maps',
                subtitle: 'Opens navigation',
                icon: Icons.location_on_outlined,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('Maps Push');
                  ctSnack(context,
                      message: 'Maps Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Calendar Event',
                subtitle: 'Opens calendar app',
                icon: Icons.calendar_today_outlined,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('Calendar Push');
                  ctSnack(context,
                      message: 'Calendar Push event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Website',
                subtitle: 'Opens website',
                icon: Icons.web_outlined,
                color: AppColors.emerald,
                onTap: () {
                  CleverTapService().recordEvent('Website Push');
                  ctSnack(context,
                      message: 'Website Push event fired',
                      type: SnackType.success);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Input Box Push',
            icon: Icons.input_outlined,
            iconColor: AppColors.coral,
            tiles: [
              ActionTileData(
                label: 'CTA + Reminder DOC true',
                subtitle: 'Input box with CTA and reminder',
                icon: Icons.input_rounded,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent('Send Input Box Notification');
                  ctSnack(context,
                      message: 'Input Box event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Reply with Event',
                subtitle: 'Input reply triggers event',
                icon: Icons.reply_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent(
                      'Send Input Box Reply with Event Notification');
                  ctSnack(context,
                      message: 'Reply with Event fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Reply with Intent',
                subtitle: 'Input reply with auto open',
                icon: Icons.open_in_new_rounded,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent(
                      'Send Input Box Reply with Auto Open Notification');
                  ctSnack(context,
                      message: 'Reply with Intent fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'CTA + Reminder DOC false',
                subtitle: 'CTA and reminder, dismiss on click false',
                icon: Icons.notifications_off_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent(
                      'Send Input Box Remind Notification DOC FALSE');
                  ctSnack(context,
                      message: 'CTA + Reminder DOC false fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'CTA DOC true',
                subtitle: 'CTA with dismiss on click',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService().recordEvent('Send Input Box CTA DOC true');
                  ctSnack(context,
                      message: 'CTA DOC true fired', type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'CTA DOC false',
                subtitle: 'CTA without dismiss on click',
                icon: Icons.cancel_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService()
                      .recordEvent('Send Input Box CTA DOC false');
                  ctSnack(context,
                      message: 'CTA DOC false fired', type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Reminder DOC true',
                subtitle: 'Reminder dismiss on click',
                icon: Icons.alarm_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService()
                      .recordEvent('Send Input Box Reminder DOC true');
                  ctSnack(context,
                      message: 'Reminder DOC true fired',
                      type: SnackType.success);
                },
              ),
              ActionTileData(
                label: 'Reminder DOC false',
                subtitle: 'Reminder without dismiss on click',
                icon: Icons.alarm_off_outlined,
                color: AppColors.coral,
                onTap: () {
                  CleverTapService()
                      .recordEvent('Send Input Box Reminder DOC false');
                  ctSnack(context,
                      message: 'Reminder DOC false fired',
                      type: SnackType.success);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Display & Inbox',
            icon: Icons.dashboard_outlined,
            iconColor: AppColors.pink,
            tiles: [
              ActionTileData(
                label: 'App Inbox',
                subtitle: 'Open message center',
                icon: Icons.inbox_outlined,
                color: AppColors.teal,
                onTap: () {
                  try {
                    CleverTapService().showInbox({
                      'noMessageTextColor': '#9092AE',
                      'noMessageText': 'No messages yet.',
                      'navBarTitle': 'Inbox',
                      'navBarTitleColor': '#F0EFFF',
                      'navBarColor': '#10111C',
                      'inboxBackgroundColor': '#080910',
                    });
                    ctSnack(context,
                        message: 'Opening inbox…', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context,
                        message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Native Display',
                subtitle: 'Render display units natively',
                icon: Icons.display_settings_outlined,
                color: AppColors.violet,
                onTap: widget.onNativeDisplayEvent,
              ),
              ActionTileData(
                label: 'Get Display Units',
                subtitle: widget.hasDisplayUnits
                    ? '${widget.displayUnitsCount} unit(s) loaded'
                    : 'Fetch & cache all units',
                icon: Icons.view_list_outlined,
                color: AppColors.pink,
                onTap: widget.onGetDisplayUnits,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'App Inbox Actions',
            icon: Icons.inbox_outlined,
            iconColor: AppColors.teal,
            tiles: [
              ActionTileData(
                label: 'Get All Messages',
                subtitle: 'Fetch all inbox messages',
                icon: Icons.mark_email_read_outlined,
                color: AppColors.teal,
                onTap: () async {
                  try {
                    final msgs = await CleverTapService().getAllInboxMessages();
                    if (mounted)
                      ctSnack(context,
                          message: '${msgs?.length ?? 0} inbox message(s)',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Get Unread Messages',
                subtitle: 'Fetch unread inbox messages',
                icon: Icons.mark_email_unread_outlined,
                color: AppColors.teal,
                onTap: () async {
                  try {
                    final msgs =
                        await CleverTapService().getUnreadInboxMessages();
                    if (mounted)
                      ctSnack(context,
                          message: '${msgs?.length ?? 0} unread message(s)',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Fetch Inbox',
                subtitle: 'Trigger inbox fetch',
                icon: Icons.refresh_rounded,
                color: AppColors.teal,
                onTap: () {
                  try {
                    CleverTapService().fetchInbox();
                    ctSnack(context,
                        message: 'Inbox fetch triggered', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context,
                        message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Fetch Inbox with Callback',
                subtitle: 'Fetch inbox and await result',
                icon: Icons.sync_rounded,
                color: AppColors.teal,
                onTap: () async {
                  try {
                    final success =
                        await CleverTapService().fetchInboxWithCallback();
                    if (mounted)
                      ctSnack(context,
                          message: success == true
                              ? 'Inbox fetched'
                              : 'Fetch returned false',
                          type: success == true
                              ? SnackType.success
                              : SnackType.warning);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Get Message by ID',
                subtitle: 'Retrieve a message by its ID',
                icon: Icons.search_rounded,
                color: AppColors.teal,
                onTap: () => _showIdDialog(
                    'Get Message by ID', 'Retrieve inbox message by ID',
                    (id) async {
                  final msg = await CleverTapService().getInboxMessageForId(id);
                  if (mounted)
                    ctSnack(context,
                        message: msg != null ? 'Found: $id' : 'Not found: $id',
                        type: msg != null
                            ? SnackType.success
                            : SnackType.warning);
                }),
              ),
              ActionTileData(
                label: 'Mark Read by ID',
                subtitle: 'Mark a message as read',
                icon: Icons.done_rounded,
                color: AppColors.teal,
                onTap: () => _showIdDialog(
                    'Mark Read by ID', 'Mark an inbox message as read',
                    (id) async {
                  await CleverTapService().markReadInboxMessageForId(id);
                  if (mounted)
                    ctSnack(context,
                        message: 'Marked read: $id', type: SnackType.success);
                }),
              ),
              ActionTileData(
                label: 'Delete by ID',
                subtitle: 'Delete a message from inbox',
                icon: Icons.delete_outline_rounded,
                color: AppColors.teal,
                onTap: () => _showIdDialog(
                    'Delete by ID', 'Delete an inbox message by ID',
                    (id) async {
                  await CleverTapService().deleteInboxMessageForId(id);
                  if (mounted)
                    ctSnack(context,
                        message: 'Deleted: $id', type: SnackType.success);
                }),
              ),
              ActionTileData(
                label: 'Push Clicked Event by ID',
                subtitle: 'Record click event for a message',
                icon: Icons.ads_click_rounded,
                color: AppColors.teal,
                onTap: () => _showIdDialog('Push Clicked Event',
                    'Record notification clicked for message ID', (id) async {
                  await CleverTapService()
                      .pushInboxNotificationClickedEventForId(id);
                  if (mounted)
                    ctSnack(context,
                        message: 'Clicked event pushed: $id',
                        type: SnackType.success);
                }),
              ),
              ActionTileData(
                label: 'Push Viewed Event by ID',
                subtitle: 'Record viewed event for a message',
                icon: Icons.visibility_outlined,
                color: AppColors.teal,
                onTap: () => _showIdDialog('Push Viewed Event',
                    'Record notification viewed for message ID', (id) async {
                  await CleverTapService()
                      .pushInboxNotificationViewedEventForId(id);
                  if (mounted)
                    ctSnack(context,
                        message: 'Viewed event pushed: $id',
                        type: SnackType.success);
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Event History',
            icon: Icons.history_outlined,
            iconColor: AppColors.lime,
            tiles: [
              ActionTileData(
                label: 'Get Event Log',
                subtitle: 'Get log for a specific event',
                icon: Icons.receipt_long_outlined,
                color: AppColors.lime,
                onTap: () =>
                    _showEventNameDialog('Get Event Log', (name) async {
                  final log = await CleverTapService().getUserEventLog(name);
                  if (mounted)
                    ctSnack(context,
                        message: 'Log for $name: $log', type: SnackType.info);
                }),
              ),
              ActionTileData(
                label: 'Get Event History',
                subtitle: 'Get full event history',
                icon: Icons.history_rounded,
                color: AppColors.lime,
                onTap: () async {
                  try {
                    final history =
                        await CleverTapService().getUserEventLogHistory();
                    if (mounted)
                      ctSnack(context,
                          message:
                              '${history?.length ?? 0} event(s) in history',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Get Event Count',
                subtitle: 'Count occurrences of an event',
                icon: Icons.tag_rounded,
                color: AppColors.lime,
                onTap: () =>
                    _showEventNameDialog('Get Event Count', (name) async {
                  final count =
                      await CleverTapService().getUserEventLogCount(name);
                  if (mounted)
                    ctSnack(context,
                        message: '$name fired ${count ?? 0} time(s)',
                        type: SnackType.info);
                }),
              ),
              ActionTileData(
                label: 'App Launch Count',
                subtitle: 'Total app launch count',
                icon: Icons.launch_rounded,
                color: AppColors.lime,
                onTap: () async {
                  try {
                    final count =
                        await CleverTapService().getUserAppLaunchCount();
                    if (mounted)
                      ctSnack(context,
                          message: 'App launched ${count ?? 0} time(s)',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Last Visit Time',
                subtitle: 'Timestamp of last app visit',
                icon: Icons.access_time_rounded,
                color: AppColors.lime,
                onTap: () async {
                  try {
                    final ts = await CleverTapService().getUserLastVisitTs();
                    if (mounted)
                      ctSnack(context,
                          message: 'Last visit: ${ts ?? 'N/A'}',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Time Elapsed',
                subtitle: 'Seconds since session start',
                icon: Icons.timelapse_rounded,
                color: AppColors.lime,
                onTap: () async {
                  try {
                    final elapsed =
                        await CleverTapService().sessionGetTimeElapsed();
                    if (mounted)
                      ctSnack(context,
                          message: 'Session time: ${elapsed ?? 0}s',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Screen Count',
                subtitle: 'Screens viewed this session',
                icon: Icons.layers_outlined,
                color: AppColors.lime,
                onTap: () async {
                  try {
                    final count =
                        await CleverTapService().sessionGetScreenCount();
                    if (mounted)
                      ctSnack(context,
                          message: '${count ?? 0} screen(s) viewed',
                          type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'UTM Details',
                subtitle: 'Current session UTM parameters',
                icon: Icons.link_outlined,
                color: AppColors.lime,
                onTap: () async {
                  try {
                    final utm = await CleverTapService().sessionGetUTMDetails();
                    if (mounted)
                      ctSnack(context,
                          message: 'UTM: $utm', type: SnackType.info);
                  } catch (e) {
                    if (mounted)
                      ctSnack(context,
                          message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
