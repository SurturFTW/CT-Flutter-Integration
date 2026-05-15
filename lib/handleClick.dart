import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles various deep link types received from push notifications
Future<void> handleNotificationClick(
    Map<String, dynamic> notificationPayload) async {
  try {
    // Extract deep link from payload - check multiple field names
    final deepLink = notificationPayload['wzrk_dl'] as String? ??
        notificationPayload['telephone'] as String? ??
        notificationPayload['email'] as String? ??
        notificationPayload['sms'] as String? ??
        notificationPayload['whatsapp'] as String? ??
        notificationPayload['maps'] as String? ??
        notificationPayload['calendar'] as String?;

    if (deepLink == null || deepLink.isEmpty) {
      debugPrint('No deep link found in payload');
      debugPrint('Available keys: ${notificationPayload.keys.toList()}');
      return;
    }

    debugPrint('Processing deep link: $deepLink');
    // Fire and forget - don't await
    _handleDeepLink(deepLink);
  } catch (e) {
    debugPrint('Error handling notification click: $e');
  }
}

/// Routes the deep link to appropriate handler based on URL scheme
void _handleDeepLink(String deepLink) {
  if (deepLink.startsWith('tel:')) {
    _handlePhoneCall(deepLink);
  } else if (deepLink.startsWith('smsto:')) {
    _handleSMS(deepLink);
  } else if (deepLink.startsWith('mailto:')) {
    _handleEmail(deepLink);
  } else if (deepLink.startsWith('google.navigation:')) {
    _handleGoogleNavigation(deepLink);
  } else if (deepLink.startsWith('https://wa.me/')) {
    _handleWhatsApp(deepLink);
  } else if (_isCalendarLink(deepLink)) {
    _handleCalendarEvent(deepLink);
  } else if (deepLink.startsWith('http://') ||
      deepLink.startsWith('https://')) {
    _handleExternalWebLink(deepLink);
  } else {
    debugPrint('Unknown deep link scheme: $deepLink');
  }
}

/// Handles phone call deep links (tel:<number>)
void _handlePhoneCall(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    launchUrl(uri).then((_) {
      debugPrint('Phone call initiated: $deepLink');
    }).catchError((e) {
      debugPrint('Cannot launch phone call: $e');
    });
  } catch (e) {
    debugPrint('Error handling phone call: $e');
  }
}

/// Handles SMS deep links (smsto:<number> or smsto:<number>?body=<message>)
void _handleSMS(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    launchUrl(uri).then((_) {
      debugPrint('SMS compose opened: $deepLink');
    }).catchError((e) {
      debugPrint('Cannot launch SMS: $e');
    });
  } catch (e) {
    debugPrint('Error handling SMS: $e');
  }
}

/// Handles email deep links (mailto:<email>)
void _handleEmail(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    launchUrl(uri).then((_) {
      debugPrint('Email compose opened: $deepLink');
    }).catchError((e) {
      debugPrint('Cannot launch email: $e');
    });
  } catch (e) {
    debugPrint('Error handling email: $e');
  }
}

/// Handles Google Navigation deep links (google.navigation:q=<query>)
void _handleGoogleNavigation(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    launchUrl(uri).then((_) {
      debugPrint('Google Navigation opened: $deepLink');
    }).catchError((e) {
      debugPrint('Fallback to Google Maps web');
      final query = uri.queryParameters['q'] ?? '';
      if (query.isNotEmpty) {
        final mapsUrl = Uri.parse('https://www.google.com/maps/search/$query');
        launchUrl(mapsUrl);
      }
    });
  } catch (e) {
    debugPrint('Error handling Google Navigation: $e');
  }
}

/// Handles WhatsApp deep links (https://wa.me/<number>?text=<message>)
void _handleWhatsApp(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    launchUrl(uri, mode: LaunchMode.externalApplication).then((_) {
      debugPrint('WhatsApp opened: $deepLink');
    }).catchError((e) {
      debugPrint('WhatsApp not installed or cannot launch: $e');
    });
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
void _handleCalendarEvent(String deepLink) {
  try {
    if (deepLink.startsWith('calendar://')) {
      final uri = Uri.parse(deepLink);
      launchUrl(uri).then((_) {
        debugPrint('Calendar app opened: $deepLink');
      }).catchError((e) {
        debugPrint('Cannot launch calendar: $e');
      });
    } else if (deepLink.endsWith('.ics') ||
        deepLink.contains('BEGIN:VCALENDAR')) {
      final uri = Uri.parse(deepLink);
      launchUrl(uri).then((_) {
        debugPrint('Calendar event opened: $deepLink');
      }).catchError((e) {
        debugPrint('Cannot launch calendar event: $e');
      });
    }
  } catch (e) {
    debugPrint('Error handling calendar event: $e');
  }
}

/// Handles standard web links by opening in external browser
void _handleExternalWebLink(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    launchUrl(uri, mode: LaunchMode.externalApplication).then((_) {
      debugPrint('Web link opened in external browser: $deepLink');
    }).catchError((e) {
      debugPrint('Cannot launch web link: $e');
    });
  } catch (e) {
    debugPrint('Error handling web link: $e');
  }
}
