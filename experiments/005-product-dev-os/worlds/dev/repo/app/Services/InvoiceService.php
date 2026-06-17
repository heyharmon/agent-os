<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Project;

// Invoicing logic. Money is stored and computed in integer cents everywhere
// (see conventions/coding-style.md); never floats. The invoice total is the
// sum of its line items, computed in the service layer.
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

    // Sum line-item amounts. Each line item is ['amount_cents' => int].
    public function totalCents(array $lineItems): int
    {
        $total = 0;
        foreach ($lineItems as $item) {
            $total += (int) ($item['amount_cents'] ?? 0);
        }
        return $total;
    }

    // Apply a percentage discount to a cents amount, rounding to the nearest
    // cent. Used by reporting and by the invoice builder.
    public function applyDiscount(int $amountCents, float $pct): int
    {
        return (int) round($amountCents * (1.0 - $pct / 100.0));
    }
}
