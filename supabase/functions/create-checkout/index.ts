// create-checkout — provider-agnostic "collect the money" step.
//
// The app calls this with { payment_id } and the user's JWT. The function loads
// the payment (RLS scopes it to the caller), then asks whichever provider is
// live to create a checkout and returns what the client needs to open it.
//
// Deploy: supabase functions deploy create-checkout
// Secrets: STRIPE_SECRET_KEY, or TELR_STORE_ID + TELR_AUTH_KEY.
//
// This is a TEMPLATE. Fill in the branch for the provider you use.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const { payment_id } = await req.json()
    const authHeader = req.headers.get('Authorization') ?? ''

    // A client scoped to the calling user, so RLS applies.
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    )

    const { data: payment, error } = await supabase
      .from('payments').select('*').eq('id', payment_id).single()
    if (error || !payment) return json({ error: 'Payment not found' }, 404)
    if (payment.status !== 'created') return json({ error: 'Already handled' }, 409)

    const amountFils = Math.round(Number(payment.amount_aed) * 100) // AED -> fils

    switch (payment.provider) {
      case 'stripe': {
        // const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)
        // const intent = await stripe.paymentIntents.create({
        //   amount: amountFils, currency: 'aed',
        //   metadata: { payment_id },                 // <- webhook reads this
        //   automatic_payment_methods: { enabled: true },
        // })
        // return json({ clientSecret: intent.client_secret })
        return json({ error: 'Stripe branch not implemented' }, 501)
      }
      case 'telr': {
        // POST https://secure.telr.com/gateway/order.json with
        //   store: TELR_STORE_ID, authkey: TELR_AUTH_KEY,
        //   order: { amount: payment.amount_aed, currency: 'AED',
        //            cartid: payment_id, ... }, return: { ... }
        // return json({ url: hostedPaymentPageUrl })
        return json({ error: 'Telr branch not implemented' }, 501)
      }
      default:
        return json({ error: `Provider ${payment.provider} has no checkout` }, 400)
    }
  } catch (e) {
    return json({ error: String(e) }, 500)
  }
})

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { 'Content-Type': 'application/json' },
  })
}
