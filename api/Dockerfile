# Build from the REPO ROOT:  docker build -f api/Dockerfile --target api .   (or --target migrate)
# Base images are pinned by digest; Dependabot (docker ecosystem) proposes updates.
FROM golang:1.26.10-alpine@sha256:a2012b4a1d1f9f7e9f44e0d39b805a901e856b1dd80b4e6ee4338db547050308 AS build
WORKDIR /src
ENV CGO_ENABLED=0 GOFLAGS=-mod=readonly
COPY api/go.mod api/go.sum ./api/
COPY tools/go.mod tools/go.sum ./tools/
RUN cd api && go mod download && cd ../tools && go mod download
COPY api ./api
COPY tools ./tools
RUN mkdir /out \
 && cd api && go build -trimpath -ldflags="-s -w" -o /out/api ./cmd/api \
 && cd ../tools && go build -trimpath -ldflags="-s -w" -o /out/goose github.com/pressly/goose/v3/cmd/goose

# Runtime API: static binary, non-root, no shell.
FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab AS api
COPY --from=build /out/api /api
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/api"]

# One-shot migration job: goose plus the migrations of this release. Configure with
# GOOSE_DRIVER=postgres and GOOSE_DBSTRING (from the environment file); the default command is `up`.
FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab AS migrate
COPY --from=build /out/goose /goose
COPY api/db/migrations /migrations
USER nonroot:nonroot
ENTRYPOINT ["/goose", "-dir", "/migrations"]
CMD ["up"]
