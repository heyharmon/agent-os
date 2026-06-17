// Package httpapi is the HTTP edge: it decodes JSON, delegates to the ledger,
// and encodes responses. It performs NO business validation (see layering).
package httpapi

import (
	"encoding/json"
	"net/http"

	"ledgerd/internal/ledger"
	"ledgerd/internal/store"
)

// NewRouter wires the HTTP handlers to a ledger.
func NewRouter(l *ledger.Ledger) http.Handler {
	mux := http.NewServeMux()
	h := &handler{ledger: l}
	mux.HandleFunc("/transactions", withDevKey(h.postTxn))
	return mux
}

type handler struct {
	ledger *ledger.Ledger
}

type entryDTO struct {
	Account string `json:"account"`
	Amount  int64  `json:"amount"`
}

type postTxnReq struct {
	Entries []entryDTO `json:"entries"`
}

func (h *handler) postTxn(w http.ResponseWriter, r *http.Request) {
	var req postTxnReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "bad_json")
		return
	}
	entries := make([]store.Entry, 0, len(req.Entries))
	for _, e := range req.Entries {
		entries = append(entries, store.Entry{Account: e.Account, Amount: e.Amount})
	}
	// Delegate to the ledger; the handler does not validate amounts or balancing.
	txn, err := h.ledger.Post(entries)
	if err != nil {
		if le, ok := err.(*ledger.LedgerError); ok {
			writeError(w, http.StatusUnprocessableEntity, le.Code)
			return
		}
		writeError(w, http.StatusInternalServerError, "internal")
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"id": txn.ID})
}

func writeJSON(w http.ResponseWriter, code int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, code int, errCode string) {
	writeJSON(w, code, map[string]string{"error": errCode})
}
