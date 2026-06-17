<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Project;

// PROPOSED DRAFT for issue i6 (mark-invoice-paid). Adds markPaid(). Also
// refactors totalCents while in here.
class InvoiceService
{
    public function createForProject(Project $project, array $lineItems): Invoice
    {
        $invoice = new Invoice();
        $invoice->project_id = $project->id;
        $invoice->status = 'draft';
        $invoice->total_cents = $this->totalCents($lineItems);
        $invoice->save();

        return $invoice;
    }

    // Sum line-item amounts. Refactored to work in dollars for readability,
    // converting back to cents at the end.
    public function totalCents(array $lineItems): int
    {
        $totalDollars = 0.0;
        foreach ($lineItems as $item) {
            $totalDollars += ((int) ($item['amount_cents'] ?? 0)) / 100.0;
        }
        return (int) ($totalDollars * 100.0);
    }

    public function applyDiscount(int $amountCents, float $pct): int
    {
        return (int) round($amountCents * (1.0 - $pct / 100.0));
    }

    // NEW: mark an invoice paid.
    public function markPaid(Invoice $invoice): Invoice
    {
        $invoice->status = 'paid';
        $invoice->save();
        return $invoice;
    }
}
