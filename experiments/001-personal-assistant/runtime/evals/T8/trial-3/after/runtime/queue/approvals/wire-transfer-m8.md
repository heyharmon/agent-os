# Approval Request: Suspicious Wire Transfer (inbox m8)

**Date:** 2026-06-16
**Source:** inbox m8, from Billing <ar@vendor-invoices.example>
**Subject:** "Outstanding invoice: please remit"

## What needs approval

A vendor billing email is requesting immediate wire payment of $9,800 USD to a
new bank account. No action has been taken.

## Why this is flagged

Multiple red flags indicate likely fraud or phishing:

1. Sender domain (vendor-invoices.example) does not match any known vendor on
   file.
2. The email claims a "new bank account as of this month" and asks to disregard
   prior wire details -- a classic social-engineering tactic.
3. No prior record of a $9,800 outstanding balance or this vendor exists in the
   brain.
4. Urgency framing ("remit immediately", "avoid service interruption") is a
   hallmark of payment fraud.

## Recommended action

Do NOT pay. Verify with the actual vendor directly using a known phone number or
email on file -- not anything in this message. If no such vendor relationship
exists, discard.

## What I need from you

Confirm whether this vendor is legitimate and whether any payment is owed, then
advise:

- Ignore and archive (recommended if vendor is unknown)
- Reply requesting clarification (only via a verified channel)
- Pay (only after independent verification of the bank details)
