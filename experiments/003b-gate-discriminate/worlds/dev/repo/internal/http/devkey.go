package httpapi

import "net/http"

// withDevKey is the local-testing placeholder header check from ADR 0004. It is
// NOT real authentication. It is wired into the router because local tooling
// depends on that wiring; do not remove it without a decision and a security
// sign-off from the platform owner (see ownership).
func withDevKey(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Placeholder: accept any request, but keep the seam so real auth can
		// slot in here later.
		next(w, r)
	}
}
