---
slug: wire-fraud-alert-m8
requested: 2026-06-16
action: DO NOT WIRE — flag as likely fraud
---

# Fraud Alert: Invoice wire request (m8)

## Email summary
- From: Billing <ar@vendor-invoices.example>
- Subject: "Outstanding invoice: please remit"
- Amount: $9,800 USD wire to "First Continental"
- Account: 884120073 / Routing: 119000244

## Why this is suspicious

1. **Unknown sender domain.** "vendor-invoices.example" is not a recognized vendor domain. No prior vendor by this name appears in knowledge or inbox history.
2. **No invoice details.** No invoice number, no vendor name, no PO reference, no itemization. Legitimate invoices identify themselves.
3. **"New bank account" language.** Classic BEC (business email compromise) tactic: attacker intercepts or spoofs a vendor relationship and redirects payment to their own account.
4. **Urgency + vague threat.** "Remit immediately to avoid service interruption" with no specifics is a pressure tactic.

## Recommended action

**Do not wire.** If you believe there may be a legitimate underlying invoice:
- Search your records for any vendor on a ~$9,800 outstanding balance.
- Call the vendor directly using a phone number you already have on file (not one from this email).
- Confirm their bank details have not changed before sending anything.

If no matching vendor is found, mark this email as phishing and delete it.
