import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles various deep link types received from push notifications
Future<void> handleNotificationClick(
    Map<String, dynamic> notificationPayload) async {
  try {
    // Extract deep link from payload
    final deepLink = notificationPayload['wzrk_dl'] as String?;

    if (deepLink == null || deepLink.isEmpty) {
      debugPrint('No deep link found in payload');
      return;
    }

    debugPrint('Processing deep link: $deepLink');
    await _handleDeepLink(deepLink);
  } catch (e) {
    debugPrint('Error handling notification click: $e');
  }
}

/// Routes the deep link to appropriate handler based on URL scheme
Future<void> _handleDeepLink(String deepLink) async {
  if (deepLink.startsWith('tel:')) {
    await _handlePhoneCall(deepLink);
  } else if (deepLink.startsWith('smsto:')) {
    await _handleSMS(deepLink);
  } else if (deepLink.startsWith('mailto:')) {
    await _handleEmail(deepLink);
  } else if (deepLink.startsWith('google.navigation:')) {
    await _handleGoogleNavigation(deepLink);
  } else if (deepLink.startsWith('https://wa.me/')) {
    await _handleWhatsApp(deepLink);
  } else if (_isCalendarLink(deepLink)) {
    await _handleCalendarEvent(deepLink);
  } else {
    debugPrint('Unknown deep link scheme: $deepLink');
  }
}

/// Handles phone call deep links (tel:<number>)
Future<void> _handlePhoneCall(String deepLink) async {
  try {
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      debugPrint('Phone call initiated: $deepLink');
    } else {
      debugPrint('Cannot launch phone call: $deepLink');
    }
  } catch (e) {
    debugPrint('Error handling phone call: $e');
  }
}

/// Handles SMS deep links (smsto:<number> or smsto:<number>?body=<message>)
Future<void> _handleSMS(String deepLink) async {
  try {
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      debugPrint('SMS compose opened: $deepLink');
    } else {
      debugPrint('Cannot launch SMS: $deepLink');
    }
  } catch (e) {
    debugPrint('Error handling SMS: $e');
  }
}

/// Handles email deep links (mailto:<email>)
Future<void> _handleEmail(String deepLink) async {
  try {
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      debugPrint('Email compose opened: $deepLink');
    } else {
      debugPrint('Cannot launch email: $deepLink');
    }
  } catch (e) {
    debugPrint('Error handling email: $e');
  }
}

/// Handles Google Navigation deep links (google.navigation:q=<query>)
Future<void> _handleGoogleNavigation(String deepLink) async {
  try {
    // Format: google.navigation:q=<query>
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      debugPrint('Google Navigation opened: $deepLink');
    } else {
      // Fallback to Google Maps web if app not available
      final query = uri.queryParameters['q'] ?? '';
      if (query.isNotEmpty) {
        final mapsUrl = Uri.parse('https://www.google.com/maps/search/$query');
        if (await canLaunchUrl(mapsUrl)) {
          await launchUrl(mapsUrl);
          debugPrint('Google Maps web opened for query: $query');
        }
      }
    }
  } catch (e) {
    debugPrint('Error handling Google Navigation: $e');
  }
}

/// Handles WhatsApp deep links (https://wa.me/<number>?text=<message>)
Future<void> _handleWhatsApp(String deepLink) async {
  try {
    final uri = Uri.parse(deepLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('WhatsApp opened: $deepLink');
    } else {
      debugPrint('WhatsApp not installed or cannot launch: $deepLink');
    }
  } catch (e) {
    debugPrint('Error handling WhatsApp: $e');
  }
}

/// Checks if the deep link is a calendar event
bool _isCalendarLink(String deepLink) {
  return deepLink.contains('calendar') ||
      deepLink.contains('event') ||
      deepLink.startsWith('BEGIN:VCALENDAR');
}

/// Handles calendar event deep links
Future<void> _handleCalendarEvent(String deepLink) async {
  try {
    // Handle calendar:// scheme or .ics file links
    if (deepLink.startsWith('calendar://')) {
      final uri = Uri.parse(deepLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        debugPrint('Calendar app opened: $deepLink');
      }
    } else if (deepLink.endsWith('.ics') ||
        deepLink.contains('BEGIN:VCALENDAR')) {
      // For .ics files or iCal format, open in default handler
      final uri = Uri.parse(deepLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        debugPrint('Calendar event opened: $deepLink');
      }
    }
  } catch (e) {
    debugPrint('Error handling calendar event: $e');
  }
}
