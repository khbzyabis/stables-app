import '../models/transport.dart';

/// Sample transport content for the foundation (server data in production).
abstract final class TransportData {
  static const reasons = <TransportReason>[
    TransportReason('A show', 'Timed back from your collecting ring slot. The return leg is usually cheaper booked now.'),
    TransportReason('Vet or clinic', 'Say if the horse is lame or sedated — not every lorry will take one.'),
    TransportReason('Moving stables', 'One way. Both stables see the journey, and the horse moves across when it arrives.'),
    TransportReason('Collecting a horse', 'Coming to you from a seller or another yard. No pickup gate code needed.'),
  ];

  static const needs = <TransportNeed>[
    TransportNeed('Travelling together', 'Same partition, they box better side by side'),
    TransportNeed('A groom travels with them', 'Rasil comes, one seat needed'),
    TransportNeed('Insured to AED 150,000 each', 'Say what your horses are worth'),
    TransportNeed('One is a nervous loader', 'Comme Ci · takes twenty minutes'),
  ];

  static const quotes = <TransportQuote>[
    TransportQuote(
      name: 'Gulf Horse Transport', price: 'AED 640', expires: 'Expires in 2 days',
      meta: '4.8 · 240 journeys · used by Al Marmoom',
      facts: [
        ItemFact('Vehicle', 'Two-horse lorry, air ride, CCTV'),
        ItemFact('Insured to', 'AED 250,000 per horse'),
        ItemFact('Loading', '06:15 · driver arrives 15 minutes early'),
      ],
    ),
    TransportQuote(
      name: 'Desert Equine Movers', price: 'AED 520', expires: 'Expires tomorrow',
      meta: '4.3 · 88 journeys',
      facts: [
        ItemFact('Vehicle', 'Three-horse trailer'),
        ItemFact('Insured to', 'AED 80,000 per horse'),
        ItemFact('Loading', '05:45 · one other pickup on the way'),
      ],
    ),
    TransportQuote(
      name: 'Al Marmoom Logistics', price: 'AED 780', expires: 'Expires in 3 days',
      meta: '4.9 · 610 journeys · groom seat included',
      facts: [
        ItemFact('Vehicle', 'Four-horse lorry, ramp, camera per stall'),
        ItemFact('Insured to', 'AED 400,000 per horse'),
        ItemFact('Loading', '06:00 · direct, no other stops'),
      ],
    ),
  ];

  static const journeyFacts = <ItemFact>[
    ItemFact('Horses', 'Joy and Abby · travelling together'),
    ItemFact('Driver', 'Saeed · +971 50 771 4402'),
    ItemFact('Vehicle', 'Two-horse lorry · air ride, CCTV'),
    ItemFact('Insured to', 'AED 250,000 per horse'),
    ItemFact('Cost', 'AED 640 · charged after the journey'),
    ItemFact('Booked by', 'Ahmad · Monday 14:20'),
  ];

  static const footnote =
      'The cheapest here is insured to a third of the highest. Read the middle line before the price.';
}
