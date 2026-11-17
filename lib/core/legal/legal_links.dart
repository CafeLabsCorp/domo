/// Public legal pages, served by domo-landing (its middleware redirects
/// `/privacidade` and `/termos` to the visitor's locale on its own).
///
/// The texts were reviewed and approved by a lawyer (2026-11-16).
abstract final class LegalLinks {
  static const privacyPolicy = 'https://domo.cafelabs.net/privacidade';
  static const termsOfUse = 'https://domo.cafelabs.net/termos';
  static const deleteAccount = 'https://domo.cafelabs.net/excluir-conta';

  /// Version of the legal texts the user accepted. Bump when the texts change
  /// in a way that needs a new acceptance.
  static const termsVersion = '2026-11';
}
