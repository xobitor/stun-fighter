# Fighting Game Project

Tiago's long-marinated idea for a solo 2D fighting game, now in active design.

## Core concept

No juggle states, ever. "The grounded fighting game." Combos are won in the head, not in the air.

Move-based stun system (decided): light stun ("wobble", fast moves, mash-out-able or reversal-able) and heavy stun ("rocked", slow telegraphed moves) replace juggles as the combo engine. Combos end naturally when the opponent recovers/covers up — no damage scaling.

Throws: classic strike > throw > block RPS preserved; throws during light stun deny mash-out → hard knockdown + corner carry; throws during heavy stun cover-up = anti-turtle answer, modest damage + hard knockdown.

Air options exist but are deliberately unsafe/risk-priced; connected jump-ins lead to heavy stun. Clean anti-airs are the main combo starters.

Knockdowns/okizeme allowed, exact rules TBD.

Archetypes: grappler = slow mobility + stun-state specialist (command grabs unblockable during heavy stun); zoner = herds to the corner instead of stunning from range; counter-poker archetype still undefined.

## Full design doc

The complete, living design doc (pillars, system specs, open questions list, Unity implementation plan with milestones) lives in the Canvas named "Project Grounded — Stun-Based 2D Fighting Game Design Doc" (canvas: grounded-fighting-game). Consult and update it rather than re-deriving decisions.

### Implementation direction

Engine: Godot. Goal: training-grounds prototype (two placeholder actors + training stage) in a few months.

Key technical commitments: fixed-timestep deterministic simulation from day one, frame data spreadsheet, state-machine design.

First thing to prototype: the light-stun mini-game (mash / reversal / throw) — make-or-break exchange.

### Open design questions (as of 2026-11-13)

Hidden governor meter under move-based stuns? Air blocking rules? Attacker self-light-stun on blocked jump-ins? Comeback mechanics? Counter-poker archetype? Round/damage economy with honest damage?

### Motivation & expectations (2026-11-15)

Primary goal is learning, not money; Tiago expects the game may never be a hit and accepts that.

Quality bar: a solid game, not a kusoge — if it finds a cult following, it should be respected.

Tech direction settled: Godot + GDScript (over Unity/Unreal) after comparing 2026 licensing and 2D fit.

Commercial plan (informal): premium ~€9.99/$9.99 at launch with 10–15% launch discount, regional pricing, optional cosmetic "supporter pack" DLC — explicitly NOT F2P (small-playerbase F2P fighting games die in empty matchmaking).

"Not kusoge" priorities identified: rollback netcode (biggest single factor), real training mode (frame data/hitbox display), few deeply tuned characters over many shallow ones, consistent post-launch cadence.

Suggested framing: two-phase project — phase 1 (prototype spine, the real win) with explicit permission to stop there; phase 2 optional.

### Prototype progress (as of 2026-11-17)

Godot 4 project created; scaffold scripts (game_config / attack_data / fighter_tuning / fighter) implemented and running. Full setup walkthrough was provided in chat (Input Map actions p1_/p2_, Fighter.tscn with Hitbox/Hurtbox Area2D children, Main.tscn with Floor StaticBody2D, main.gd wiring opponent refs).

Working: movement, slow committed jumps, block held, light/heavy attacks cycle through startup/active/recovery correctly.

Bug fixed together: _can_transition_to() blanket-blocked attack phases' own progression, locking the fighter in ATTACK_STARTUP. Lesson: guards must allow internal state-machine progression vs. player input; attack phases allow only successor transitions (cancels come in M2 via cancellable_into).

Scaffold surfaced to user via the canvas "Project Grounded — Godot Prototype Scaffold" (workspace filesystem is not user-visible).

Next session: implement _tick_hitbox() overlap resolution + wire receive_hit() + hitstop (global freeze frames, Main-level). Then M1 is functionally done.

### Where to resume

Next natural steps: resolve the governor-meter question (open question #1), then start the Unity M1 milestone (movement & attacks framework).