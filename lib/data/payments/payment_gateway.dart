/// The result of asking a gateway to collect and confirm a payment.
class PaymentResult {
  const PaymentResult.ok(this.ref)
      : success = true,
        error = null;
  const PaymentResult.failed(this.error)
      : success = false,
        ref = null;

  final bool success;

  /// The provider's reference for the charge (order id, payment intent, etc.).
  final String? ref;
  final String? error;
}

/// A payment provider seam. Everything above this line — the basket, the
/// ledger, payouts — is provider-agnostic; only an implementation of this
/// interface knows about Stripe, Telr or the mock.
///
/// [pay] is the client-side step: collect the card / open the provider's sheet
/// or redirect, and return once the charge is confirmed. The [payment] map is
/// the `payments` row created by `SupabaseService.createPayment` (id, amount,
/// currency, provider, …).
///
/// Security: a real provider's secret key must never live in the app. A real
/// implementation calls a Supabase Edge Function (which holds the secret and
/// talks to the provider), and the provider's webhook — not the client — flips
/// the payment to 'paid'. See `supabase/functions/README.md`.
abstract class PaymentGateway {
  String get id;

  /// Whether this gateway can actually take money right now.
  bool get isConfigured;

  Future<PaymentResult> pay(Map<String, dynamic> payment);

  /// Pick the gateway the operator has made live (from platform settings).
  static PaymentGateway forProvider(String? provider) {
    switch (provider) {
      case 'stripe':
        return const StripeGateway();
      case 'telr':
        return const TelrGateway();
      case 'mock':
      default:
        return const MockGateway();
    }
  }
}

/// The default until a real provider is wired: pretends the card cleared so the
/// whole checkout → held → payable → payout flow works end to end. The actual
/// 'paid' write is done by the caller via `SupabaseService.markPaymentPaid`,
/// which the database only allows for mock payments.
class MockGateway implements PaymentGateway {
  const MockGateway();
  @override
  String get id => 'mock';
  @override
  bool get isConfigured => true;
  @override
  Future<PaymentResult> pay(Map<String, dynamic> payment) async {
    final ref = 'mock-${(payment['id'] as String? ?? '').split('-').first}';
    return PaymentResult.ok(ref);
  }
}

/// Stripe seam — not yet configured. To turn it on:
///   1. Deploy the `create-checkout` + `stripe-webhook` Edge Functions
///      (templates in supabase/functions), with STRIPE_SECRET_KEY set.
///   2. Set the provider to 'stripe' in the Admin Console → Fees → Payments.
///   3. Implement [pay] to call the Edge Function and open Stripe Checkout,
///      returning once the intent is confirmed.
class StripeGateway implements PaymentGateway {
  const StripeGateway();
  @override
  String get id => 'stripe';
  @override
  bool get isConfigured => false;
  @override
  Future<PaymentResult> pay(Map<String, dynamic> payment) async =>
      const PaymentResult.failed(
          'Stripe is selected but not configured yet. Deploy the payment '
          'Edge Function and set STRIPE_SECRET_KEY.');
}

/// Telr seam (UAE) — not yet configured. Same shape as Stripe: a `create-order`
/// Edge Function holds the store id + auth key and returns a hosted-payment URL;
/// Telr's webhook settles the payment. Implement [pay] to open that URL.
class TelrGateway implements PaymentGateway {
  const TelrGateway();
  @override
  String get id => 'telr';
  @override
  bool get isConfigured => false;
  @override
  Future<PaymentResult> pay(Map<String, dynamic> payment) async =>
      const PaymentResult.failed(
          'Telr is selected but not configured yet. Deploy the payment Edge '
          'Function and set the Telr store id + auth key.');
}
