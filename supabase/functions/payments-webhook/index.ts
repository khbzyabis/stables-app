// payments-webhook — the ONLY thing that settles a real payment.
//
// The provider calls this when a charge succeeds. It runs as service_role
// (bypassing RLS) and flips the matching `payments` row to 'paid'. The app can
// never do this for a real provider (mark_payment_paid refuses non-mock), so
// this webhook is the trust boundary.
//
// Deploy: supabase functions deploy payments-webhook
//   (set verify_jwt = false for this function — providers don't send a user JWT)
// Secrets: STRIPE_WEBHOOK_SECRET (Stripe) etc.
//
// This is a TEMPLATE. Fill in the branch for the provider you use.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// service_role client — bypasses RLS. Keep this key server-side only.
const admin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
)

Deno.serve(async (req) => {
  try {
    // ---- Stripe ----
    // const sig = req.headers.get('stripe-signature')!
    // const event = stripe.webhooks.constructEvent(
    //   await req.text(), sig, Deno.env.get('STRIPE_WEBHOOK_SECRET')!)
    // if (event.type === 'payment_intent.succeeded') {
    //   const pi = event.data.object
    //   await settle(pi.metadata.payment_id, pi.id)
    // }
    // return new Response('ok')

    // ---- Telr ----
    // Verify the callback, read cartid (our payment_id) and the tran ref, then:
    // await settle(cartid, tranRef)
    // return new Response('ok')

    return new Response('Webhook template — implement your provider branch', {
      status: 501,
    })
  } catch (e) {
    return new Response(String(e), { status: 400 })
  }
})

async function settle(paymentId: string, ref: string) {
  await admin.from('payments')
    .update({ status: 'paid', paid_at: new Date().toISOString(), provider_ref: ref })
    .eq('id', paymentId)
    .eq('status', 'created') // idempotent: only settle once
}
