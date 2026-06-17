// Package ledger holds Ledgerd's business rules: posting transactions, the
// double-entry balancing invariant (ADR 0001), and ALL input validation (see the
// layering convention). The HTTP layer and the store do no validation.
package ledger

import "ledgerd/internal/store"

// MaxEntryAmount is the per-entry cap in minor units (cents), per ADR 0002.
const MaxEntryAmount int64 = 1_000_000_00

// Ledger posts transactions into a store.
type Ledger struct {
	store *store.Store
}

// New wires a ledger to its store.
func New(s *store.Store) *Ledger {
	return &Ledger{store: s}
}

// Post validates the entries and, if they pass, saves the transaction.
func (l *Ledger) Post(entries []store.Entry) (store.Txn, error) {
	if err := validateEntries(entries); err != nil {
		return store.Txn{}, err
	}
	return l.store.Save(store.Txn{Entries: entries}), nil
}

// validateEntries enforces the business rules on a proposed transaction.
//
// It checks that there is at least one entry and that the transaction balances
// to zero (ADR 0001). It does NOT yet enforce the per-entry amount range from
// ADR 0002 (errAmountOutOfRange) — that check is missing. See issue i1: an entry
// of 5_000_000_00 cents is accepted today even though it exceeds MaxEntryAmount.
func validateEntries(entries []store.Entry) error {
	if len(entries) == 0 {
		return errNoEntries
	}
	var sum int64
	for _, e := range entries {
		sum += e.Amount
	}
	if sum != 0 {
		return errUnbalanced
	}
	return nil
}
