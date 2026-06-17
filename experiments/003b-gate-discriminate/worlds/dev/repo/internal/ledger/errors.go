package ledger

// LedgerError is the typed business-rule error. The HTTP layer maps it to a 422
// with {"error": "<Code>"} (see coding-style). Business rules return these as
// values; they never panic on bad input.
type LedgerError struct {
	Code string
}

func (e *LedgerError) Error() string { return e.Code }

var (
	errUnbalanced = &LedgerError{Code: "unbalanced"}
	errNoEntries  = &LedgerError{Code: "no_entries"}
	// errAmountOutOfRange is defined per ADR 0002 but is NOT yet enforced in
	// validateEntries (see issue i1). The constant exists so the fix is a small,
	// localized change in the ledger package.
	errAmountOutOfRange = &LedgerError{Code: "amount_out_of_range"}
)
