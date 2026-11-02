Status: canonical
Last reviewed: 2026-11-02

# PRD (requirements baseline)

| Item | Value |
|---|---|
| Master document | Google Doc "PRD Pembangunan Ulang Situs Web Bappelitbangda Sulsel v1.1" (Indonesian) |
| Doc id | `1AVENcFTXL9Oq-QnqwATAegQENVnz2FqGc2EaBnfl8UU` |
| URL | https://docs.google.com/document/d/1AVENcFTXL9Oq-QnqwATAegQENVnz2FqGc2EaBnfl8UU/edit |
| Version | 1.1 |
| Google Doc modified (when captured) | 2026-11-02T03:31:42Z |
| Copy in this repo | [`PRD.md`](PRD.md): English 1:1 translation, header kept, body unchanged |
| sha256 of the body | `2e8ba03a62efc6414852af75605dfce67acb97a94b4666421a8c8c40712c1d9a` (recomputed on 2026-11-02 and equal to the header) |
| Approval | **not signed** (section 13 of the PRD is empty) |

The Indonesian Google Doc is the master. If this copy and the Doc differ, the Doc wins.
The signed original stays with the agency.

## How the hash is computed

The hash covers the text after the `---` line and the blank line that follows it:

```sh
awk 'f{print} /^---$/ && !f{f=1; getline}' docs/prd/PRD.md | sha256sum
```

## Update procedure

Agents never edit `PRD.md`. Humans edit the Google Doc, re-export, re-translate, bump the version, Doc modified time and hash in the header, and open a PR titled `docs(prd): vX.Y`.
Requirement ids (`FR-nn`, `NFR-nn`, `OQ-nn`) are never renumbered.
Traceability of each id to issues and tests: [`traceability.md`](traceability.md).
