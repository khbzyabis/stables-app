# Payments — the provider seam

My Stables is **provider-agnostic**: the app, the ledger (held → payable →
payout) and the receipts never mention a specific gateway. Only two Edge
Functions know about Stripe or Telr, and they are the only place a **secret key
may live**. Never put a payment secret in the Flutter app.

## The flow

1. **Checkout (app).** The buyer taps Pay. The app calls `create_payment` (SQL
   RPC) to open a `payments` row (`status = created`, `provider` stamped from
   `platform_settings`). Amount and provider are decided server-side.

2. **Collect (Edge Function `create-checkout`).** For a real provider the app
   calls this function with the payment id. The function reads the payment,
   creates the provider's checkout (Stripe PaymentIntent / Checkout Session, or
   a Telr hosted-payment order) and returns the client secret / redirect URL.
   The app opens it.

3. **Settle (Edge Function `payments-webhook`).** The provider calls this
   webhook when the charge succeeds. Running as `service_role`, it flips the
   `payments` row to `paid`. That is the *only* way a non-mock payment becomes
   paid — the app cannot do it (`mark_payment_paid` refuses non-mock).

4. **Ledger (unchanged).** Once paid, the orders attached to that payment ride
   the existing money model: held during the return window, then payable, then
   swept into a payout.

## Turning a provider on

```bash
# Stripe
supabase secrets set STRIPE_SECRET_KEY=sk_live_...
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
supabase functions deploy create-checkout
supabase functions deploy payments-webhook
# then: Admin Console → Fees → Payments → choose Stripe

# Telr
supabase secrets set TELR_STORE_ID=...
supabase secrets set TELR_AUTH_KEY=...
supabase functions deploy create-checkout
supabase functions deploy payments-webhook
# then: Admin Console → Fees → Payments → choose Telr
```

While the provider is selected but not yet deployed, buyers cannot check out —
switch back to **Test** in the console to keep trading with the mock gateway.

## Refunds

`decide_dispute('refund_buyer')` already records the refund in the ledger. To
also move real money back, extend `payments-webhook` (or add a `refund`
function) to call the provider's refund API for the payment's `provider_ref`.
The two templates here are where that goes.

The `.ts` files are **templates** — read them as the shape of the integration,
fill in the provider branch you are using, and deploy.
