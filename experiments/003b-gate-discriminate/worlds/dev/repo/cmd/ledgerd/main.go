// Command ledgerd starts the Ledgerd HTTP server.
package main

import (
	"log"
	"net/http"

	"ledgerd/internal/http"
	"ledgerd/internal/ledger"
	"ledgerd/internal/store"
)

func main() {
	s := store.New()
	l := ledger.New(s)
	mux := httpapi.NewRouter(l)
	log.Println("ledgerd listening on :8080")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatal(err)
	}
}
