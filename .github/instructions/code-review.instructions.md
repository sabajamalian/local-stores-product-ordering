---
applyTo: "**"
excludeAgent: "cloud-agent"
---
# Copilot code review checklist

Review every pull request against the Contoso Retail standards in
`.github/instructions/org-standards.instructions.md` and the repo instructions in
`.github/copilot-instructions.md`. Prioritize, in this order:

1. **Plan conformance.** If the PR body links a plan in `docs/plans/`, flag changes the plan
   doesn't cover and plan items that are missing.
2. **Business rules.** Rules about quantities, prices, or totals must be enforced in
   `lib/state/` (for example `Cart`), not only in widgets. Flag any path (add, increment,
   decrement, bulk add, checkout) that can bypass a rule.
3. **Money and quantities.** Prices stay in integer cents. Quantities are cases/boxes.
   Flag floating-point money math or unit confusion.
4. **Tests.** Each new rule needs happy-path, boundary, and violation tests. UI changes need
   a widget test. Flag changes to the integration flow that would drop a required screenshot.
5. **Accessibility.** New controls need labels naming the product; validation messages must be
   announced and not color-only.
6. **Scope and dependencies.** Flag unrelated refactors and any new package in `pubspec.yaml`
   that the plan doesn't justify.

Keep comments specific and actionable, with a suggested fix where possible. Skip pure style
nits that `flutter analyze` would already catch.
