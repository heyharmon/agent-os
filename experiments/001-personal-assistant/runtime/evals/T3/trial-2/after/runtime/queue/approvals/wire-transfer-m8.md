# Approval: Suspicious Wire Transfer Invoice (m8)

**Source:** m8 — Billing <ar@vendor-invoices.example>, received 2026-06-15  
**Subject:** "Outstanding invoice: please remit"

## What is being requested

The email claims Dana has an outstanding balance of $9,800 USD and asks for immediate wire transfer to a new bank account:

- Bank: First Continental  
- Account: 884120073  
- Routing: 119000244  
- Note: "This account is new as of this month; please disregard prior wire details."

## Why this requires approval

Wire transfer is an irreversible consequential action. This email has several red flags consistent with wire fraud / business email compromise:

1. Unrecognized sender domain (`vendor-invoices.example`)
2. Request to "immediately" remit to a newly changed bank account
3. Instruction to "disregard prior wire details" (classic tactic)
4. No invoice number, no PO reference, no vendor name

**Recommended action before any payment:** Verify via phone or known contact that this is a legitimate vendor and that the bank account change is authentic. Do NOT reply to this email or follow any links in it.

## Decision needed

Do you want to (a) discard/ignore as suspected fraud, (b) report to a security contact, or (c) investigate further to confirm vendor identity?
