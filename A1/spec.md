# Blackwell: Last Shift — Implementation Specification

## Overview

**Status:** specification draft, September 18, 2026. All game behavior below is **planned**, not implemented or verified. This document authorizes no implementation by itself. The original acceptance criteria are preserved at the end of this document; proposed design details must satisfy them and may be revised without reducing required scope.

Blackwell: Last Shift is a single-player, first-person 3D atmospheric horror game set in a fictional nuclear research facility during an emergency lockdown. The player is a night-shift technician trapped with engineer Mara Voss and security officer Eli Ward. An experimental energy system has produced an entity that imitates human voices over the intercom. The player restores emergency power, coordinates chamber isolation, and attempts evacuation.

The target is a complete first playthrough of approximately **15–25 minutes**, measured with new-player playtests. Facility procedures and equipment are fictional, simplified puzzles. A complete, polished short game takes priority over optional features.

The gameplay loop is: read the current objective, explore a readable section of the facility, inspect clues or converse with survivors, issue a role-specific command, observe a cooperative action, and unlock the next objective. Horror events complicate the story without hiding required instructions or destroying progression resources.

## Assignment summary

- Develop in a stable Godot release using GDScript, with source editable in VS Code. Choose and record the exact engine version at M0; no specific version is selected by this draft.
- Deliver a connected six-area level, two commandable NPCs, written branching dialogue, three NPC exchanges, a cooperative puzzle, four scripted horror events, three optional clues, two decision-based endings, and a timed evacuation with checkpoint retry.
- Deliver complete source, a standalone desktop export for the professor's confirmed OS, setup and launch documentation, actual development prompts, asset credits/licenses, a development summary, and a demonstration checklist in a ZIP for manual submission.
- **Deadline: September 28, 2026, at 7:00 a.m. US Central.** Schedule final packaging before this deadline.
- **Required assignment README: `A1/README.md`.** It must cover the exact engine version, source setup, how to run the source project, how to launch the packaged game, controls, graphics settings, and supported operating systems.

Excluded: multiplayer, combat, open world, procedural levels, free-form typed or spoken dialogue, runtime AI services, and complex inventory management. Optional only after required scope passes verification: a patrolling entity encounter, extra ambient conversations/clues, persistent saves, and a tested browser build. Full voice acting is optional. In-memory checkpoint retry is required even if persistent saves are omitted.

## Acceptance criteria

### Traceability and evidence policy

The verbatim criteria below are authoritative. The following checklist maps **every AC ID** to delivery milestones and concrete verification. Each check covers all subrequirements of its AC; record individual subrequirement results in `docs/verification.md` during development rather than treating a partial pass as an AC pass.

Track three separate fields for each AC: **planned design**, **implemented evidence** (files/revision), and **verified evidence** (build, environment, procedure, result). Initially all implemented fields are “not implemented” and all verification fields are “not run.” A design, source file, or successful editor import alone is not proof of gameplay correctness. Record failures and unavailable external tests explicitly.

| Check | Milestones | Concrete verification required before marking verified |
| --- | --- | --- |
| AC-01 | M0, M6 | Open a clean source copy in the documented stable engine; import all assets and run without missing files or script errors. Edit a GDScript file in VS Code. Follow documented asset setup from scratch. |
| AC-02 | M1, M2, M5 | Exercise WASD, mouse look, held Shift, E, and F. Walk/sprint against walls, floors, closed doors, and major props. Open/close dialogue and pause; confirm pointer capture and movement restoration, including pause during dialogue. |
| AC-03 | M1, M3, M6 | Walk and identify all six signed/landmarked areas. Check both initial gates, their objective unlocks, and complete traversal afterward. Test door closure, backtracking, and exploration in different orders for trapping. |
| AC-04 | M2–M4 | Identify both NPCs visually and by named, stylistically different dialogue. Complete mandatory repair/security contributions. Observe and record at least one objective/event-driven behavior change for each. |
| AC-05 | M2, M3, M6 | Target each NPC for an E prompt; exercise situation/objective/expertise topics. Show two conversations per NPC with at least two meaningful choices each; compare responses before/after objectives. Exit every optional conversation. Repeat reward-bearing nodes and confirm unchanged item/reward counts and valid state. Run offline without services or microphone. |
| AC-06 | M2, M3, M6 | Command both NPCs to follow around obstacles, stop near the player, wait, and resume. Assign each role task. Check acknowledgements and prerequisite explanations. Attempt locked/solid routes; interrupt tasks and obstruct paths, then recover through normal play without restarting. |
| AC-07 | M3, M4 | Trigger all three exchanges, including an automatic trigger; verify alternating named lines, a visible action, and a changed later option/hint. Trigger during another conversation and from far away; confirm serialization, no silent completion, and retained essential information. |
| AC-08 | M3, M6 | Finish the six objectives in order with matching HUD text. Attempt each completion early. Leave/revisit the component and interrupt its use. Request phase-specific hints. Observe a new player complete the game without external instructions. |
| AC-09 | M3, M6 | Attempt isolation with each participant absent/unready, inspect the specific explanation, assign all roles, and succeed. Cancel/reassign NPC tasks and retry incorrect activations without losing progression. |
| AC-10 | M4, M5 | Witness the window figure, imitation message, occupied-corridor lighting event, and final alarm. Verify both NPC reactions to one event. Read essential clues at default brightness; test lowered/muted volume on sudden sounds and repeat trigger entry for one-shot behavior. |
| AC-11 | M4, M6 | Find and reread three optional clues. Demonstrate contradictory intercom/survivor advice supported by earlier evidence. Replay the checkpoint for both decision-based endings; inspect consequence text and use menu/restart from each. |
| AC-12 | M4–M6 | Isolate the chamber and verify visible countdown, navigable route, and both NPC escape attempts. Succeed at the lift, deliberately time out, and retry repeatedly. Compare timer, NPC transforms, doors, and objective state with the checkpoint baseline. |
| AC-13 | M1, M2, M5 | Exercise every main/pause menu action and checkpoint availability. Pause during movement, NPC tasks, conversations, and countdown; verify simulation freeze. Test sensitivity, volume, brightness, and any motion-effect toggles. Inspect named story text, action/key prompts, non-color cues, and UI at both 1280×720 and 1920×1080. |
| AC-14 | M4, M5 | Inspect consistent art and distinguishable rooms/NPCs/objects. Test flashlight lighting and interaction feedback; listen for ambience, door, objective, and alarm cues. Audit each third-party asset against its attribution and compatible license. |
| AC-15 | M5, M6 | Select low preset and resolutions; profile representative rooms, puzzle, and escape on documented hardware, targeting about 30 FPS or better. Complete a crash/blocker/error-free run. Start a new game after progress and each ending and inspect reset items, objectives, conversation flags, NPC state, and events. |
| AC-16 | M0, M5, M6 | On the confirmed professor OS, extract the desktop package into a separate folder and launch without Godot/VS Code, offline and without developer paths/accounts/keys/services. Follow launch/control/graphics/OS instructions and audit bundled dependencies. Test a second computer if available; otherwise record “not tested” and limitations. Browser export is optional. |
| AC-17 | M0–M6 | Audit ZIP contents for source, playable export, actual prompt log, assignment-root README, credits/licenses, development summary, and demo checklist. Extract and follow the README, then demonstrate dialogue, commands, NPC exchanges, puzzle, and an ending. Prepare ZIP before the stated deadline for manual submission. |

## Files

Only this specification is created at this stage. The following is a **proposed** structure; it does not assert that these files exist.

```text
A1/
  SPEC.md
  README.md                     # Required assignment entry point and run instructions
  prompts.txt                   # Actual prompts, chronological; never reconstructed as quotations
  CREDITS.md                    # Asset origin, author, license, modifications, attribution
  licenses/                     # Required third-party license texts
  docs/
    development-summary.md      # Iterations, problems, fixes, lessons
    verification.md             # AC/subcheck status and evidence, performance/playtests
    demo-checklist.md            # Reproducible demonstration sequence
  game/
    project.godot
    export_presets.cfg          # Portable export configuration; no credentials
    scenes/
      main.tscn                 # Bootstrap and menu/run transitions
      facility.tscn             # One connected level and navigation
      player.tscn
      npc.tscn                  # Shared NPC scene configured for Mara/Eli
      interactables/            # Doors, component, clues, panels, lift
      ui/                       # HUD, dialogue, journal, menus, endings/failure
      events/                   # Scripted atmosphere/event scenes
    scripts/
      core/                     # Session, objectives, checkpoint, settings
      player/                   # Movement, camera, interaction ray
      npc/                      # Commands, state machine, navigation/recovery
      dialogue/                 # Conversation predicates/effects and scheduling
      world/                    # Doors, tasks, puzzle, horror, escape
      ui/
    data/                       # Authored dialogue, objectives, clues, event definitions
    assets/                     # Models, textures, fonts, audio; bundled dependencies
  builds/<confirmed-platform>/  # Runnable export and needed companion files
  submission/                   # Final ZIP staging/output; avoid nested old ZIPs
```

Use project-relative `res://` paths and Godot-managed `user://` settings storage. Exclude generated import caches, machine-specific editor files, credentials, and unrelated course assignments from the source package. Include original source assets and runtime dependencies. README commands and executable names must match actual verified output, with no invented launch instructions before a build exists.

## Implementation notes

### Proposed technical baseline and responsibilities

Use a stable Godot version selected at M0, GDScript, simple stylized industrial assets, and a modest desktop rendering configuration. Evaluate the Compatibility renderer first against flashlight, lighting, and target-device needs; selection remains provisional until tested. Avoid renderer-specific effects that block the chosen desktop target. No runtime network requests or AI dependency are needed: NPC behavior is authored state-machine logic with local dialogue data.

| Scene/system | Responsibility |
| --- | --- |
| Main/session controller | Own menu/run transitions, fresh-run creation, ending/failure transitions, and checkpoint restoration. Keep session state separate from persistent user settings. |
| Facility | Place six areas, signed paths, collision, interaction anchors, navigation regions, gates, and trigger volumes. |
| Player | Character movement, sprint, camera/mouse capture, flashlight, and short-range line-of-sight interaction. No jumping requirement. |
| NPC | Shared character scene with role appearance/data, navigation agent, command state, interaction prompt, animations/visible posture, and task execution. |
| Objective controller | Authoritative prerequisite evaluation, monotonic objective transitions, unique item consumption, and current-objective/hint notifications. |
| Dialogue director | Evaluate available options, serialize conversations/exchanges, show named text, apply effects once, and preserve essential hints. |
| Task/puzzle controller | Validate role, prerequisites, reachable workstation, readiness, cancellation, and atomic chamber-isolation completion. |
| World interactables | Expose a common availability/prompt/interaction contract; consult state rather than independently granting progress. |
| Horror/event controller | Fire authored events once per run, queue story dialogue, issue reactions, and start escape after isolation. |
| Escape/checkpoint controller | Own decision state, countdown, lift eligibility, NPC evacuation override, and deterministic restoration. |
| UI/settings/audio | Menus, prompts, subtitles, journal, readiness and objective displays; settings and volume buses. All sounds route through master volume. |

Prefer typed local Resources for authored data and stable string IDs for saved/session references. Signals announce committed state changes; visual nodes derive their display from state. Avoid multiple managers independently completing the same objective.

| Data | Planned fields/invariants |
| --- | --- |
| Objective definition | ID, prerequisites, completion conditions, display text, role hints, effects. Ordered O1–O6; reject unmet prerequisites. |
| Run state | Current/completed objectives, component status, flags, collected clue IDs, completed conversation/effect IDs, fired event IDs, door states, final decision, escape state. One authoritative instance. |
| Component state | `available`, `held`, or `consumed`; exactly one valid state. No dropping/destruction and no duplicate pickup. |
| NPC runtime state | Stable NPC ID, role, transform, behavior state, accepted command, wait anchor, task ID, readiness, recovery attempts. |
| Dialogue node/choice | ID, speaker, text, choice label, predicates, next node, unique effect IDs, exit permission. Meaningful choices disclose different information or perform distinct commands. |
| Exchange/event | ID, prerequisite/location trigger, ordered lines/actions, delivery policy, one-shot flag, resulting hint/flag. |
| Clue | ID, title, text, location; collection adds a rereadable journal entry without becoming a progression prerequisite. |
| Checkpoint | Schema/version, objective/item/flag snapshots, player/NPC transforms and states, door states, clue/effect/event sets, decision state, timer baseline, relevant puzzle state. |
| Settings | Sensitivity, master volume, brightness, quality preset, resolution, optional motion toggles. Persist independently of new games. |

### Facility and narrative progression

Proposed topology: security station connects to the control room and maintenance workshop. Maintenance connects back to control; control leads through the coolant gallery to the observation room. A lift branch returns toward security. These are six identifiable areas within one level, not six separately loaded levels. Use room-name signs plus distinctive machinery and shapes, so lighting/color is never the only navigation cue.

Gate A blocks the coolant-gallery route until emergency power is restored. Gate B blocks observation-room access until Eli completes security authorization after power restoration. Lift activation is disabled until successful isolation. Unlocked mandatory paths remain open; door sensors prevent crushing, NPC blockage, or stranding. The final route must work from either puzzle workstation. Give the observation room a chamber-control console and clear signage distinguishing it from the separate control room.

| Stage | Prerequisites and completion | Actions and information | Initial pacing budget |
| --- | --- | --- | --- |
| O1: Meet survivors | Fresh run; speak with both survivors and receive lockdown briefing | Security station; introduce roles, controls, and maintenance objective | 2–3 min |
| O2: Retrieve component | O1; pick up unique component | Maintenance exploration and an optional clue; component remains available until collected | 2–4 min |
| O3: Restore power | O2 and component held; command Mara, reach repair panel, finish repair | Consume component only when repair commits; open Gate A and update lighting | 3–4 min |
| O4: Access observation | O3; command Eli, finish reachable security task | Power-confirmation exchange and visible Gate B opening; cross coolant gallery | 2–3 min |
| O5: Isolate chamber | O4; both NPCs at assigned stations and player confirms isolation | Cooperative readiness puzzle, warning exchange, checkpoint and final choice | 4–6 min |
| O6: Evacuate | Successful O5; required lift conditions met before expiry | Alarm, visible countdown, NPC escape behavior, lift activation and ending | 2–3 min |

These budgets total 15–23 minutes with some room for exploration; they are planning estimates, not playtest results. Tune navigation and dialogue with first-time-player observations to meet the 15–25-minute target.

Every objective has an explicit useful hint available through survivor dialogue and the HUD. Reaching future locations early does not satisfy later objectives. Failed or interrupted tasks do not consume the component, close permanent escape paths, or erase hints.

### Controls and interaction ownership

Input actions: WASD walk, mouse look, held Shift sprint, E interact, F flashlight, Escape pause. Select written dialogue options with the released mouse. Offer the clue journal through a labeled HUD/menu action; its final shortcut is an implementation choice to document in the README.

Use a single input-mode owner for gameplay, dialogue/journal, pause/settings, and ending screens. Dialogue prevents player movement and camera look and releases the pointer. Closing it restores gameplay only when no higher-priority menu remains open. Pause preserves the previous mode, releases the mouse, and freezes gameplay, NPC tasks, story event timers, dialogue playback, and the evacuation countdown. Resume returns to the previous mode; resuming into dialogue must not capture the mouse. Menus remain interactive while paused.

### NPC navigation, commands, and recovery

Mara uses an engineer silhouette/tool gear and precise mechanical explanations. Eli uses a security uniform and concise route/security language. Names appear in dialogue regardless of appearance. Mara visibly moves to repair/puzzle machinery after assignment; Eli moves to the security panel and visibly changes to evacuation behavior during the alarm. Both also react to the imitation event.

Shared states: `idle`, `follow`, `wait`, `travel_to_task`, `perform_task`, `react`, and `evacuate`. Dialogue is coordinated with these states rather than creating competing movement controllers. Follow/wait and role tasks are available as selectable dialogue commands for each NPC. Accepted commands receive named acknowledgements; unavailable tasks state the actual missing objective, item, access, or route condition.

Use baked navigation and collision-aware movement with a stopping distance near the player. Closed gates must block traversal in both navigation connectivity and physical collision; an apparently valid path through a closed door is not enough. Recompute affected connectivity when gates open. Test two NPCs in narrow doors and at the shared destination; use distinct destination offsets to avoid crowding.

Wait stores a reachable world anchor until a new command is accepted. Mandatory evacuation can override wait only with an explicit named announcement. Never silently move a waiting NPC for an optional conversation. Role tasks target authored reachable anchors: Mara repairs power and operates the maintenance panel; Eli authorizes access and holds the override.

Detect lack of progress over a tunable interval. Retry pathfinding, choose a nearby reachable anchor on the same unlocked side, and communicate blockage. If still blocked, cancel travel/readiness and allow follow/wait/reassignment or a visible “regroup” recovery at a reachable nearby anchor. Recovery must not cross locked gates, grant objectives, or require a restart. A relocation fallback, if needed, must be visibly communicated, collision-safe, and restricted to the same accessible region. Readiness requires actual arrival and an active task; interrupted NPCs immediately lose readiness. Door and level design should eliminate ordinary permanent traps first.

### Dialogue and NPC exchanges

Each NPC has situation, current-objective, and expertise topics, with at least two distinct conversations containing two meaningful response choices. Proposed pairs: Mara's initial repair briefing (ask about the failure versus repair procedure) and post-power analysis (ask about imitation evidence versus isolation steps); Eli's lockdown briefing (ask about survivors versus blocked routes) and observation briefing (ask about access versus emergency evacuation). Both offer exits on nonessential conversations. Objective hints change after completion; commands do not count as the only meaningful narrative choices.

Dialogue effects are guarded by predicates and unique applied-effect IDs. Repeating nodes may replay information but cannot issue another item, consume a second component, reopen a completed reward, or regress objectives. No microphone, model, API key, account, or connection is required.

Required authored exchanges:

1. **Lockdown briefing:** automatic when the player meets both survivors in security; alternating Mara/Eli lines establish roles and point to maintenance.
2. **Power/access confirmation:** after Mara's repair and Eli's accepted access task, Mara confirms power and Eli acknowledges, operates security, and opens Gate B. The action occurs at the corresponding line, not invisibly beforehand.
3. **Imitation warning:** a gallery/observation trigger after power restores plays a false intercom instruction. Both survivors respond; an `imitation_warning_known` flag changes later trust-related dialogue and the objective hint.

One director owns the dialogue channel. Queue mandatory exchanges until any current conversation ends and their participants/player can receive them. A nearby exchange that loses range pauses until reception is possible; it must not mark itself completed silently. Specifically authored intercom/radio delivery may continue at distance with explicit speaker-labeled text. Keep essential conclusions in HUD hints and follow-up topics. Queued triggers use pending/completed IDs so entering repeatedly cannot duplicate an exchange.

### Cooperative puzzle, final decision, and endings

Proposed required puzzle: Mara holds a maintenance panel, Eli holds a security override, and the player uses the chamber-control console in observation. The panel/override anchors are reachable through unlocked areas. Display labeled readiness states with text/icons; readiness is not color-only. Early console use lists the missing prerequisites/participants. Invalid attempts change no irreversible state, and NPC tasks can be reassigned.

**Proposed resolution of the final-choice requirements:** once all puzzle prerequisites are ready, create a checkpoint immediately before presenting the final decision. The intercom recommends a fictional “reconnect” action; the survivors advise isolation. Previous clues and conversations explain the imitation and provide a fair basis for trust. The two explicit choices are:

- **Trust the survivors / isolate:** revalidate readiness, commit O5 once, play containment alarm, unlock the evacuation route, and start a visible countdown. Both NPCs announce evacuation and attempt to reach separate lift anchors. Player activation of the lift while the timer is positive and both NPCs are present completes O6 and shows the **successful escape ending**, explaining that isolation contained the entity.
- **Trust the intercom / reconnect:** confirm the player's explicit choice, apply the authored consequence, and show the **containment-breach ending**, explaining how the imitation persuaded the player to release the entity. This branch deliberately ends before successful isolation and therefore does not start the evacuation timer.

Countdown expiration on the isolation branch shows a clear **failure screen**, not a third narrative ending. Both endings provide Return to Menu and Restart/New Game; also offer Retry Checkpoint. Failure provides retry and menu. The decision wording, outcome fiction, and requirement that both NPCs board are proposed design decisions to confirm, not extra supplied AC.

Start with a provisional 120-second countdown and tune from measured route times, allowing for NPC travel and reading. Keep the route navigable and no mandatory modal exposition during escape. Disable optional conversation initiation during evacuation with an informative prompt; retain essential hints and story text. Pause/settings freeze the timer. Evaluate lift success and timeout in one authoritative update so zero-time activation cannot produce both outcomes.

### Checkpoint, retry, and reset

Checkpoint exists only after O4 and puzzle readiness, before either final decision. Its baseline contains O1–O4 complete, O5 pending, the consumed repair component, unlocked access gates, player at the console, both NPCs at ready anchors, no decision, and an inactive full-duration countdown. Copy all listed Run/NPC/checkpoint fields deeply; do not retain mutable node references.

Restore by stopping active dialogue/audio events and pending task callbacks, reloading the facility/session from the snapshot, applying door and objective state, placing characters at validated anchors, rebuilding navigation as needed, restoring readiness, and displaying the decision again. Clear post-checkpoint event effects, ending overlays, and alarm/countdown state. Use a new run generation ID or equivalent to reject stale callbacks. Retry must not duplicate dialogue effects or keep spent time from the failed attempt.

New Game creates the initial baseline independently of the checkpoint and clears all run-specific items, objectives, clues, conversations, NPC commands, event flags, decision and countdown data. User settings persist. Required checkpoint storage lasts within the current run; disk save/load is a stretch goal.

### Horror, clues, presentation, and accessibility

Author four distinct one-shot events: a figure behind the observation window on first valid approach; an imitation message in the coolant/observation transition; a lighting failure/change while the player occupies a corridor; and the containment alarm immediately after successful isolation. Both survivors visibly/textually react to the imitation. Store fired flags in run state and restore them from checkpoints. Use occupancy/prerequisite triggers so events occur where intended rather than firing behind an absent player.

Place three optional written clues in security, maintenance, and observation: a voice-authentication warning, an experiment incident note, and an isolation protocol note. All are fictional narrative props, readable at default brightness and rereadable from the journal. Required dialogue supplies enough evidence to decide fairly if clues are skipped.

Use a consistent simple 3D style, distinguishable silhouettes/props, readable signs, nearby flashlight illumination, ambient machinery, and distinct door/objective/alarm cues. Sudden sounds use the same user-controlled audio hierarchy as everything else. Avoid full voice acting as a dependency. Include speaker-labeled text for every story-critical line, including the imitation.

Main menu: Start, Settings, Quit. Pause menu: Resume, Settings, Restart Checkpoint when available, Return to Menu. Settings: mouse sensitivity, master volume, brightness, low-quality preset, adjustable resolution; add disable toggles if camera shake/head bob is implemented. Prefer omitting motion effects initially. Use scalable UI layout, readable contrast/font sizing, and text/icon cues in addition to color; verify 720p and 1080p rather than assuming scaling works.

### Milestones and incremental plan

Dates are proposed work windows, not assertions of completed work. Export early and keep a playable build at each subsequent milestone. Maintain actual prompt and development records from the first implementation session.

| Milestone | Suggested window | Playable deliverable and exit condition |
| --- | --- | --- |
| M0: Baseline and delivery path | Sep 18–19 | Confirm OS/hardware, pin stable engine, create source structure and documentation skeleton, choose renderer, and test a minimal desktop export outside the project. Record real prompts and asset provenance from now on. |
| M1: Walkable facility | Sep 19–20 | Six labeled graybox areas, collision, player/flashlight/interactions, initial gates, and start/pause/resume. Export a walkable build; demonstrate traversal and no ordinary traps. |
| M2: NPC interaction slice | Sep 20–21 | Both distinguishable NPCs, written dialogue/input modes, follow/wait, reachable task anchors, and blocked-path recovery. Export and exercise both NPCs around gates and obstacles. |
| M3: Complete objective skeleton | Sep 21–23 | O1–O6 wired, component/repair/access, three exchanges scaffolded, cooperative readiness, hints, basic isolation-to-lift success. Export a beginning-to-end playable skeleton before art polish. |
| M4: Narrative and end states | Sep 23–24 | All required dialogue content, four horror events, three journal clues, trust decision, both endings, countdown failure, checkpoint restoration. Export and replay all outcomes. |
| M5: Presentation and portability | Sep 24–25 | Consistent assets/audio, accessibility/settings, low preset/resolution, target-device profiling and desktop package. Verify all menus and supported sizes; audit licenses. |
| M6: Acceptance and submission | Sep 25–27 | New-player timed tests, regression/retry/new-game checks, extracted export test, second-machine test if available, finalized README/evidence/summary/demo, and inspected submission ZIP. Reserve Sep 27 for fixes and packaging; manual submission before Sep 28 at 7:00 a.m. Central. |

If work slips, simplify art, animation, and dialogue length while preserving the stated interactions and content counts. Do not trade required NPC coordination, ending/checkpoint behavior, or portability for stretch features.

### Risks and unresolved decisions

| Decision/risk | Proposed handling and resolution point |
| --- | --- |
| Professor OS and CPU architecture unknown | Confirm before committing export targets at M0. Development on Windows does not establish the professor's OS. Do not claim support until an export is tested. |
| Target and available test hardware unknown | Record OS, CPU, GPU, RAM, resolution, preset, and tested build at M0/M5. Target approximately 30 FPS or better on tested low settings; do not promise all laptops. |
| Exact Godot version/renderer unselected | Select a stable release and matching export templates at M0; validate lighting/navigation/export, then document the exact version and avoid unnecessary upgrades. |
| NPC gates and narrow corridors | Prototype at M2 with both NPCs, interrupted tasks, locked gates, and recovery. Expand corridors/anchors before adding complex avoidance behavior. |
| Dialogue/task/event races | Single dialogue scheduler, guarded effects, atomic objective transitions, and snapshot generation isolation; test simultaneous triggers and pause/retry during callbacks. |
| Ending/escape interpretation | Proposed trust choice precedes successful isolation; reconnect is second ending, timeout is retryable failure. Confirm narrative and both-NPC boarding condition before M4 content lock. |
| Countdown and 15–25-minute duration | Treat 120 seconds and stage budgets as provisional; tune using first-time players and actual NPC route times. Record sample sizes and observed completion times. |
| Asset budget, availability, and licenses | Prefer simple original or compatible licensed assets; track provenance immediately. Select assets at M0–M4 without making paid services a runtime requirement. |
| Brightness/flashlight versus low-end performance | Favor limited dynamic lights and simple geometry. Measure busy scenes and escape, record FPS lows/dips as well as typical performance, and verify readable clues after changes. |
| Second computer unavailable | Test the extracted package separately regardless; record unavailable second-machine testing and any known limitations honestly. |
| Prompt log completeness | Log actual prompts verbatim with date/tool/context; retain supplied prompts available in this session when starting the log. Mark omissions rather than inventing historical prompts. |
| Short schedule | Complete the gameplay skeleton before polish; freeze stretch work until all required checks pass. |

The current spec requires no answer to these questions to exist as a draft. OS/hardware/version decisions must be resolved before dependent implementation or verification claims.

### Final verification and submission procedure

1. Record build/revision, exact engine, OS/hardware/settings, and the individual AC results. Separate source-editor testing from exported-build testing.
2. Run a fresh playthrough and observe a new player using only in-game guidance; record elapsed time, hints used, issues, and fixes. Rerun affected checks after changes.
3. Exercise both choices, countdown expiry, repeated retries, interrupted NPC tasks, repeated dialogue/event triggers, pause in each input mode, and fresh starts after endings.
4. Profile the low preset in representative areas and evacuation; document results and limitations without universal performance claims.
5. Follow `A1/README.md` from a clean source copy and from an extracted standalone package in a separate folder, offline. Validate supported OS and second-machine behavior where available.
6. Finish credits/licenses, actual prompt log, development summary, and demo checklist. The demo must show player dialogue, follow/wait and role commands, NPC-to-NPC communication, all three puzzle participants, and an ending.
7. Build the submission ZIP with a clear `A1/README.md` entry point, source, export, and required documents. Extract and inspect it, excluding caches and prior archives. Deliver for manual submission; do not claim that packaging constitutes submission.

## Original acceptance criteria (verbatim)

The following source requirements are retained to prevent summarized implementation notes from dropping individual acceptance conditions.

- Project concept
  - Working title: Blackwell: Last Shift.
  - Genre: single-player, first-person 3D atmospheric horror.
  - Setting: a fictional nuclear research facility during an emergency lockdown.
  - Premise: an experimental energy system has produced an entity that imitates human voices over the facility intercom.
  - The player is a night-shift technician trapped with two surviving employees.
  - The player must restore emergency power, isolate the experimental chamber, and reach the evacuation lift.
  - Facility procedures and equipment are fictional, simplified gameplay puzzles.
  - Target a complete first playthrough of approximately 15–25 minutes, verified through playtesting.
  - Prioritize a complete, polished short game before adding optional features.

- AC-01 — Engine and project setup
  - The game is implemented in a stable Godot release, with the exact version documented.
  - Gameplay code uses GDScript.
  - The submitted project opens in the documented Godot version without missing files or script errors.
  - Source code is editable in VS Code.
  - All required assets are included or obtained through clearly documented setup steps.

- AC-02 — First-person controls
  - The player can walk using WASD and look around using the mouse.
  - The player can sprint while holding Shift.
  - The player can interact using E and toggle a flashlight using F.
  - Walls, floors, closed doors, and major objects have working collision.
  - Opening dialogue releases the mouse for selecting options and prevents player movement.
  - Closing dialogue restores normal controls.
  - Escape opens a pause menu and releases the mouse.

- AC-03 — Facility layout
  - One connected level contains six identifiable areas: security station, control room, maintenance workshop, coolant gallery, experimental chamber observation room, and evacuation lift.
  - Signs or environmental landmarks allow the player to distinguish these areas.
  - At least two routes are initially blocked and become accessible through objective completion.
  - Every required area is reachable during the intended progression.
  - The player cannot become permanently trapped by ordinary exploration or door interactions.

- AC-04 — Two distinct NPCs
  - Mara Voss, an engineer, understands the facility’s machinery and assists with repairs.
  - Eli Ward, a security officer, knows access routes and assists with security systems.
  - Both NPCs have distinguishable appearances, visible names during dialogue, and different dialogue styles.
  - Both contribute to required objectives.
  - Each NPC visibly changes behavior at least once in response to a completed objective or horror event.

- AC-05 — Player-to-NPC dialogue
  - Approaching and targeting an available NPC displays a conversation prompt.
  - Pressing E opens a dialogue interface identifying the speaker.
  - Conversations use selectable written dialogue options.
  - Each NPC supports questions about the situation, the current objective, and their area of expertise.
  - At least two conversations per NPC offer two or more meaningful response choices.
  - Each NPC has at least one response that changes after an objective is completed.
  - The player can exit any nonessential conversation.
  - Repeating a conversation cannot duplicate items, repeat completed rewards, or corrupt progression.
  - Dialogue requires no microphone, runtime language model, account, API key, or internet connection.

- AC-06 — NPC commands
  - The player can command each NPC to follow or wait.
  - Following NPCs navigate around level obstacles and stop near the player.
  - Waiting NPCs remain in place until recalled or moved by a clearly communicated story event.
  - The player can assign each NPC at least one role-specific objective task.
  - NPCs acknowledge accepted commands.
  - If a task is unavailable, the NPC explains the missing prerequisite.
  - NPCs cannot be ordered through locked doors or solid geometry.
  - A blocked or interrupted NPC can recover without requiring a game restart.

- AC-07 — NPC-to-NPC communication
  - At least three distinct exchanges occur between Mara and Eli.
  - At least one exchange begins automatically when a defined objective or location trigger occurs.
  - An exchange includes alternating lines from both NPCs, with speaker names shown.
  - At least one exchange causes an observable action, such as Eli opening access after Mara confirms a repair.
  - At least one exchange changes a later dialogue option or objective hint.
  - Mandatory conversations do not overlap with other dialogue.
  - NPC conversations cannot silently complete out of range and leave the player without required information.
  - Essential information remains available through the objective display or follow-up dialogue.

- AC-08 — Objective progression
  - The main objective sequence is:
    1. Meet the survivors and learn about the lockdown.
    2. Retrieve a replacement component from maintenance.
    3. Direct Mara to restore emergency power.
    4. Coordinate with Eli to access the observation room.
    5. Isolate the experimental chamber.
    6. Reach and activate the evacuation lift.
  - The interface shows the current objective and updates when its completion conditions are met.
  - Objectives cannot complete before their prerequisites are satisfied.
  - Required items remain obtainable until used.
  - The player can request a useful current-objective hint from an NPC.
  - A new player can finish using only information provided inside the game.

- AC-09 — Cooperative puzzle
  - At least one required puzzle involves the player and both NPCs.
  - Proposed puzzle: Mara operates a maintenance panel, Eli holds a security override, and the player activates chamber isolation from the control console.
  - Each participant’s readiness is communicated through dialogue or visible indicators.
  - Activating the console prematurely explains which condition is missing.
  - Incorrect attempts are retryable and do not permanently block progression.

- AC-10 — Horror and atmosphere
  - The level uses an industrial visual style with emergency lighting and readable navigation.
  - At least four distinct scripted horror events occur:
    - A figure briefly appears behind an observation window.
    - An intercom message imitates a known NPC.
    - Lighting fails or changes in an occupied corridor.
    - A containment alarm initiates the final escape sequence.
  - At least one event receives a visible or textual reaction from both NPCs.
  - Essential clues remain readable at the default brightness.
  - Sudden sounds respect the user’s volume settings.
  - Re-entering a trigger does not unintentionally replay a one-time event.

- AC-11 — Clues and a meaningful choice
  - At least three optional written clues explain the experiment and the voice imitation.
  - Collected clues can be reread during the current playthrough.
  - Near the final objective, the intercom gives an instruction that conflicts with the survivors’ advice.
  - Earlier clues and conversations give the player a reasonable basis for deciding whom to trust.
  - The player’s decision produces one of two distinct endings.
  - Each ending clearly communicates the consequence of the decision.
  - Completing either ending allows the player to return to the menu or restart.

- AC-12 — Final escape sequence
  - Successful chamber isolation begins a clearly communicated evacuation countdown.
  - The remaining time is visible.
  - The evacuation route remains navigable.
  - Both NPCs attempt to reach the lift.
  - Reaching the lift with the required conditions produces the successful escape ending.
  - Countdown expiration produces a clear failure screen.
  - A checkpoint immediately before the final decision allows retrying without replaying the whole game.
  - Retrying resets the timer, NPC positions, doors, and relevant objective state consistently.

- AC-13 — Interface and accessibility
  - A main menu provides Start, Settings, and Quit.
  - The pause menu provides Resume, Settings, Restart Checkpoint when available, and Return to Menu.
  - Pausing freezes gameplay, NPC actions, and countdown timers.
  - Interaction prompts identify the action and its key.
  - All story-critical speech is available as text with speaker labels.
  - Settings include mouse sensitivity, master volume, and brightness.
  - Camera shake and head bob can be disabled if implemented.
  - Essential information does not rely on color alone.
  - Text remains readable at 1280×720 and 1920×1080.

- AC-14 — Presentation and assets
  - Use a consistent, simple 3D art style suitable for a small project.
  - Required rooms, characters, and interactable objects are visually distinguishable.
  - The flashlight illuminates nearby surfaces and useful navigation details.
  - Interaction targets are identifiable through prompts or visual feedback.
  - Audio includes ambient facility noise and distinct cues for doors, objective completion, and alarms.
  - Full voice acting is optional.
  - Third-party assets have compatible licenses and are listed with attribution where required.

- AC-15 — Performance and reliability
  - The game is designed for ordinary desktop or laptop hardware, with modest graphics requirements.
  - Graphics settings include a low-quality preset and adjustable resolution.
  - Target approximately 30 FPS or better on the low preset on tested hardware; this is not a guarantee for every device.
  - Document the hardware and settings actually used for testing.
  - A complete playthrough runs without crashes, progression blockers, or unhandled script errors.
  - Starting a new game resets items, objectives, conversations, NPC behavior, and one-time events.

- AC-16 — Easy execution and portability
  - The game does not depend on the developer’s specific computer, file paths, or installed development tools.
  - Provide a packaged desktop build for the professor’s operating system once confirmed.
  - The player can extract the package and launch the game without installing Godot or VS Code.
  - The packaged game works offline without accounts, API keys, or paid services.
  - Include all assets and dependencies required to play.
  - Provide brief instructions covering launch, controls, graphics settings, and supported operating systems.
  - Verify that the exported build launches from a folder separate from the development project.
  - Test on a second computer when available and document any compatibility limitations.
  - A browser build remains optional if it improves access without delaying the desktop version.

- AC-17 — Assignment deliverables
  - Include the complete Godot source project.
  - Include the playable exported build.
  - Include a plain-text log of the actual prompts used during development.
  - Include a README with the engine version, setup instructions, launch instructions, and controls.
  - Include asset credits and required license information.
  - Include a short development summary describing iterations, problems encountered, fixes, and lessons learned.
  - Include a demonstration checklist showing player dialogue, NPC commands, NPC-to-NPC communication, the cooperative puzzle, and an ending.
  - Package submission materials in a ZIP for manual submission.
  - Assignment deadline: September 28, 2026, at 7:00 a.m. US Central.

- Optional stretch goals
  - A short encounter with a patrolling entity.
  - Additional ambient NPC conversations.
  - Extra environmental clues.
  - Persistent save and load.
  - A tested browser build.

- Scope boundaries
  - No multiplayer.
  - No combat system.
  - No open world or procedurally generated level.
  - No free-form typed or spoken dialogue.
  - No runtime AI service dependency.
  - No complex inventory management.
  - Required scope takes priority over every stretch goal.

