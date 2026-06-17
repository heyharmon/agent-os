// Package store is a dumb, map-backed repository for accounts and entries.
// It performs NO validation and knows nothing of accounting rules (see ADR 0001
// and the layering convention): the ledger package is the only validator.
package store

import "sync"

// Entry is one leg of a transaction, in integer minor units (cents).
type Entry struct {
	Account string
	Amount  int64
}

// Txn is a posted, balanced transaction.
type Txn struct {
	ID      string
	Entries []Entry
}

// Store holds accounts and posted transactions in memory (ADR 0003).
type Store struct {
	mu      sync.Mutex
	txns    map[string]Txn
	nextSeq int
}

// New returns an empty in-memory store.
func New() *Store {
	return &Store{txns: map[string]Txn{}}
}

// Save persists a transaction. It trusts the caller (the ledger) to have
// validated it; the store never checks balancing or amounts.
func (s *Store) Save(t Txn) Txn {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.nextSeq++
	t.ID = formatID(s.nextSeq)
	s.txns[t.ID] = t
	return t
}

func formatID(seq int) string {
	return "txn-" + itoa(seq)
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	var b []byte
	for n > 0 {
		b = append([]byte{byte('0' + n%10)}, b...)
		n /= 10
	}
	return string(b)
}
