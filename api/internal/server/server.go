// Package server holds the HTTP handlers. They implement the interface generated from openapi.yaml
// (internal/api), so the contract and the code cannot drift silently.
package server

import (
	"context"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/kindaMid72/bappelitbangda-sulselprov/api/internal/api"
)

// Server implements api.StrictServerInterface.
type Server struct{}

var _ api.StrictServerInterface = (*Server)(nil)

// GetHealth reports liveness. It deliberately does not touch the database.
func (Server) GetHealth(_ context.Context, _ api.GetHealthRequestObject) (api.GetHealthResponseObject, error) {
	return api.GetHealth200JSONResponse{Status: api.Ok}, nil
}

// NewHandler builds the router with the generated routes and base middleware.
func NewHandler() http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.Recoverer)
	strict := api.NewStrictHandler(Server{}, nil)
	return api.HandlerFromMux(strict, r)
}
