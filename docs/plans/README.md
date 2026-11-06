# Implementation plans

Each feature gets a plan here before any code is written. The `planner` custom agent
(`.github/agents/planner.agent.md`) writes plans from `TEMPLATE.md`, a human reviews and merges
the plan PR, and the `implementer` agent builds from the merged plan.

File names: `<issue-number>-<short-slug>.md`, for example `12-minimum-order-quantity.md`.
