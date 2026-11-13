import 'package:flutter/material.dart';

import '../PE/Fintech/walletPage.dart';
import '../PE/OTT/OTTPage.dart';
import '../custom_html_page.dart';
import '../rich_push_page.dart';
import '../secondPage.dart';

/// Routes internal `ctdemo://<page>` links to screens.
///
/// Use in a push notification's deep link field, e.g.
///   ctdemo://second?type=promo&title=Hello&message=Welcome
///   ctdemo://wallet | ctdemo://ott | ctdemo://health | ctdemo://html | ctdemo://richpush
class DeepLinkRouter {
  static const scheme = 'ctdemo';

  static final navigatorKey = GlobalKey<NavigatorState>();

  // A link can arrive (killed-state push) before the navigator is mounted.
  static Uri? _pending;

  static bool isInternal(String link) =>
      link.toLowerCase().startsWith('$scheme://');

  static void open(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      debugPrint('DeepLinkRouter: invalid link $link');
      return;
    }
    if (navigatorKey.currentState == null) {
      _pending = uri;
      return;
    }
    _push(uri);
  }

  /// Call once the first frame is up to consume a link that arrived early.
  static void flushPending() {
    final uri = _pending;
    if (uri == null || navigatorKey.currentState == null) return;
    _pending = null;
    _push(uri);
  }

  static void _push(Uri uri) {
    final nav = navigatorKey.currentState!;
    final q = uri.queryParameters;

    // ctdemo://wallet -> host = "wallet"; ctdemo:///wallet -> path = "/wallet"
    final target = (uri.host.isNotEmpty ? uri.host : uri.path)
        .replaceAll('/', '')
        .toLowerCase();

    final Widget? page = switch (target) {
      'second' || 'deeplink' => DeepLinkPage(
          type: q['type'] ?? '',
          title: q['title'] ?? '',
          message: q['message'] ?? '',
        ),
      'wallet' || 'fintech' => const TrueMoneyPage(),
      'ott' => const OTTPage(),
      'html' => const CustomHtmlPage(),
      'richpush' => const RichPushPage(),
      'home' => null,
      _ => null,
    };

    if (target == 'home') {
      nav.popUntil((r) => r.isFirst);
      return;
    }
    if (page == null) {
      debugPrint('DeepLinkRouter: unknown target "$target" in $uri');
      return;
    }
    nav.push(MaterialPageRoute(builder: (_) => page));
  }
}
