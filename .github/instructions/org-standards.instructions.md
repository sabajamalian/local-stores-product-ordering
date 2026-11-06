---
applyTo: "**"
---
# Contoso Retail engineering standards

These are the organization's standards for every Contoso Retail product team. In a real
GitHub organization they would live in the org's `.github-private` repository or in
organization custom instructions. Here they're kept in the repo so the demo is self-contained.

## Planning (required before implementation)
- Every feature starts from an issue and an approved plan in `docs/plans/`.
- Plans follow `docs/plans/TEMPLATE.md` exactly, with every section filled in or marked N/A.
- A plan names the exact files to change, the acceptance criteria it covers, the tests to
  add, and the risks. A plan never contains production code beyond short illustrative
  signatures.
- Plans must call out any change to pricing, quantities, or order totals as
  **business-rule impact**, because those need product-owner sign-off.
- Implementation doesn't start until a human approves and merges the plan PR and the issue
  has the `plan-approved` label.

## Code
- Business rules live in the state/domain layer and are enforced there. The UI may mirror a
  rule for usability, but must not be the only place it's enforced.
- Validate inputs at the boundary and fail loudly (`ArgumentError`, `StateError`) for
  programming errors. Show plain-language messages to users for business-rule violations.
- No new third-party dependencies without a justification in the plan (license, maintenance,
  size).
- No secrets, tokens, customer data, or real store identifiers in code, tests, fixtures, or
  logs.
- Keep changes focused on the issue. Don't refactor unrelated code in a feature PR.

## Testing
- Every business rule gets unit tests for the happy path, the boundary, and the violation.
- User-visible behavior gets a widget test.
- End-to-end flows that change get the integration test updated.
- Tests must be deterministic: no network, no real time, no random data.

## Accessibility
- All interactive elements need accessible labels that include the product name.
- Error and validation messages must be announced (for example `Semantics(liveRegion: true)`)
  and must not rely on color alone.

## Pull requests
- Title: imperative, under 72 characters, no issue number.
- Body: summary, link to the plan doc, `Closes #<issue>` (implementation PRs only), test
  evidence, and screenshots for UI changes.
- PRs must pass all required checks (analyze, unit tests, Android, iOS, web) before merge.
- Every PR gets a Copilot code review and a human approval before merge.
