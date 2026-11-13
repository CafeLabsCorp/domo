import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/legal/legal_links.dart';
import '../../l10n/app_localizations.dart';

/// `prefix` followed by "Terms of use and Privacy policy", both names tappable.
class LegalLinksText extends StatelessWidget {
  const LegalLinksText({super.key, required this.prefix, this.style});

  final String prefix;
  final TextStyle? style;

  Future<void> _abrir(BuildContext context, String url) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotOpenLink),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final base = style ?? Theme.of(context).textTheme.bodySmall;
    final link = base?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    Widget tappable(String label, String url) => InkWell(
          onTap: () => _abrir(context, url),
          child: Text(label, style: link),
        );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prefix, style: base),
        tappable(l10n.termsOfUseLink, LegalLinks.termsOfUse),
        Text(l10n.legalAnd, style: base),
        tappable(l10n.privacyPolicyLink, LegalLinks.privacyPolicy),
        Text('.', style: base),
      ],
    );
  }
}
