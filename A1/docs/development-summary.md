# Development summary

## September 18, 2026 — specification and M0

- Drafted the specification and mapped all 17 acceptance criteria to milestones and verification procedures.
- Committed the reviewed specification as `0456925` before starting the baseline.
- User confirmed testing on this computer, no existing Godot installation/version requirement, and an unknown professor OS. Second-computer availability is still unknown.
- Selected Godot 4.7.2 Standard from the official Windows download page and Compatibility rendering as the initial baseline.
- Added an initial GDScript launch screen and assignment documentation. This is infrastructure, not a gameplay implementation.
- Environment restrictions required explicit access for hardware queries, Git metadata writes, and editor download. Keep tools and generated outputs out of source control.
- Confirmed engine version, imported the project, and ran the GDScript baseline without reported errors after permitting Godot's normal user-directory access.
- Installed matching Windows x86_64 export templates, exported a release build, and verified headless startup from a separate temporary directory (exit 0). Visual/input and offline/second-machine checks remain pending.

Testing results and unresolved limitations are recorded in verification.md. Later entries should describe actual iterations, defects, fixes, and lessons learned.

- User subsequently followed the setup instructions, saw the M0 start screen, and confirmed that Quit closed the game. Local M0 baseline checks are complete; professor OS confirmation remains open.

## September 21, 2026 - M1 walkable facility

- Added deterministic project-authored 3D graybox geometry, six labeled rooms, distinctive desk/workbench/tank/console/lift landmarks, perimeter/floor/ceiling/prop collision, and wide door openings.
- Implemented first-person walking, held sprint, mouse look with pitch limits, flashlight, and a three-meter line-of-sight inspection ray with visible feedback.
- Added initial locked power/security gates. A separately labeled Facility tour opens both for M1 traversal testing; it does not simulate completed objectives or endings.
- Added Start, tour, Quit, Pause, Resume, Return to Menu, focus-loss pause, mouse capture ownership, and fresh-run reset. Settings and checkpoints remain later milestones.
- Simplified the proposed loop topology to a branching graybox: security connects north to control and west to lift; control connects east to maintenance and north through coolant to observation. This satisfies the six connected areas while leaving corridor/navigation refinement for M2.
- Separated menu/input-mode ownership (`main.gd`), player behavior (`player.gd`), and deterministic facility construction (`facility.gd`). Geometry is built at runtime from room data; no external assets are needed.
- Corrected a scene encoding issue and inferred-type parse error during import. Separated flashlight actions from mouse-capture checks after headless testing exposed an unnecessary dependency. Corrected an automated route that aimed through a doorway wall.
- Used real Compatibility-renderer screenshots to identify and fix overlapping signs and pause-panel transparency. Automated physics/interaction/menu checks now pass; hands-on feel, broad trap testing, and performance remain pending.

- User completed a walkthrough, approved the visual result, and requested the M1 commit before M2. Detailed manual control/edge-case checks remain recorded separately from this general walkthrough confirmation.

## September 21, 2026 - M2 NPC interaction slice

- Added Mara and Eli with distinct project-authored primitive silhouettes, clothing/tool details, names and state labels.
- Added local written situation/expertise branches, objective hints and commands. One menu/input-mode owner preserves the conversation through pause/resume and prevents player movement/look during dialogue.
- Baked navigation from static collision geometry, including locked gates. Added safe route validation, separate follow offsets, role-specific station anchors, physical collision/yielding, wait/cancel, arrival readiness and named recovery messages.
- Persistent physical blockage retries and then cancels to waiting; clearing the route and reassigning resumes normal play without teleportation. Station inspection has no story effects; actual repair, authorization, cooperative puzzle, NPC exchanges and event reactions remain M3/M4.
- Fixed a native signal/property name collision and navigation grid mismatch during validation. M1 regression testing exposed an NPC starting position on the direct lift route; shifted both survivors clear of it.
- All 28 M2 checks and 29 M1 regression checks pass. Inspected actual-renderer NPC/dialogue views and 720p/1080p command layouts. Added a dark menu backdrop and wrapped feedback text. M2 hands-on acceptance remains pending.

- M2 user playtest found excess dialogue choices and followers orbiting out of view during mouse look. Simplified conversations to a short contextual hint, three opening choices and at most four buttons per page. Optional information remains available behind questions. Follow targets now update from player translation only; automated full-turn regression confirms both followers remain still. Updated M2 suite: 34 passing checks.

- User requested dialogue-first Escape behavior: close dialogue, then allow a subsequent press to pause. Implemented and verified all three Escape transitions; updated build and instructions.

### Dialogue presentation revision

Enlarged dialogue body text to 30 pixels and placed choices in a horizontal row, with an Escape hint replacing End conversation. Commands close the menu immediately and release the NPC to act. Bottom-screen feedback types at 40 characters per second, holds for five seconds after completion, then clears; overlapping lines queue and timing freezes outside gameplay. All 56 M2 checks pass, including command closing, horizontal choices, exit-button removal, typing/hold/queue timing. Inspected actual-renderer horizontal choices at 720p and bottom feedback at 1080p. User acceptance remains pending.

- User approved M2's revised appearance and feel and requested the milestone commit. Next session: M3 objective progression, repairs/security authorization, NPC exchanges and cooperative puzzle; see the specification for full scope.

## M3 - September 25, 2026

Connected the interaction/navigation slice to an authoritative objective controller. Component state advances available / held / consumed; repair and access require actual assigned-station arrival. Opening gates removes collision and rebakes navigation. Three queued radio/intercom exchanges serialize with player dialogue and typed feedback; access opens at Eli's authorization line, and the imitation warning changes a retained hint. Isolation validates both active station assignments; cancellation revokes readiness. Both NPCs leave for separate lift anchors and the lift waits for them. Success supports a fresh game or menu.

Preserved compact horizontal dialogue and Escape/command behavior. Added objective/readiness HUD, phase-aware choices, station signs, and early-attempt explanations. The M2 regression fixture disables story effects to isolate navigation and commands. M3 tests exercise actual NPC travel but reposition the player and accelerate subtitle reading. Manual playthrough remains needed. Countdown, checkpoint, trust decision, polished horror/audio, and final pacing remain later work.

### M3 interaction refinement - September 25, 2026

New object/NPC interactions and commands replace bottom feedback, reset typing/hold time, and clear stale acknowledgement backlog. Interrupted mandatory exchange lines replay afterward instead of silently completing. NPCs give phase-specific situation, role, and next-step information immediately; follow/wait, role task, and one optional context page replace the nested question tree. Updated M2 and M3 regression checks pass, including interruption/resumption and immediate command feedback.

### Component pickup timing fix - September 25, 2026

Meeting both survivors now unlocks component retrieval immediately instead of waiting for all briefing subtitles. The delayed briefing cannot regress later objectives. Early attempts explicitly report "Not collected"; tour inspection explicitly explains that objectives require initial-lockdown mode. All 28 M3 checks pass, including pickup during an interrupted briefing, immediate Mara acknowledgement/repair availability, and preserved state after delayed briefing completion.

### Playthrough feedback - September 25, 2026

The user reports completing the entire current game successfully. This is manual M3 flow evidence, not a timed new-player acceptance run. Reduced subtitle hold time to three seconds after typing. Shortened command acknowledgements, removed redundant repair/access arrival lines and lift boarding chatter, and retained isolation readiness, actionable blockage feedback, objective updates, and the three story exchanges. One isolation message explicitly announces both survivors moving to the lift.

## M4 - narrative and end states

Committed the user-approved M3 slice as cdfeb28, then added three optional journal notes, a window silhouette, occupied-gallery lighting failure, the existing imitation exchange, and a generated containment alarm. The console now saves an in-memory checkpoint and offers survivors/isolate versus intercom/reconnect, with explicit confirmation of reconnection. Isolation starts a provisional 120-second countdown and NPC evacuation; reconnect ends in breach. Success requires everyone aboard before zero; timeout gives retryable failure.

Retries recreate the entire world from value data, avoiding live-node snapshots and old alarm/task callbacks. Tests exposed a navigation synchronization edge case after immediate retry; evacuation assignment now waits/retries until the rebuilt map is ready. Audio follows the Master bus with a pause-menu volume control. Preserved the user's three-second subtitles, direct NPC choices, and latest-interaction feedback. M4 changes are uncommitted pending playtest; M5 presentation/persistent settings and M6 full acceptance remain.

## M5 - settings and portable presentation

Committed approved M4 as 2f19354. Added persistent player/display/audio preferences and pause-safe settings navigation; retained the approved geometry and concise dialogue. Added original synthesized ambience and gate/objective sounds, polished NPC activity labels, measured Low/720p rendered samples on the development laptop, and collected engine license notices for packaging. Settings tests use an isolated file so automated checks do not overwrite player preferences. Windows is the user-assumed submission platform. M5 changes await manual playtest; final acceptance/packaging remain M6.

## User-requested chase and graphics expansion

Added random exploration sightings and a lethal, physically navigated shadow chase after isolation. Tuned a six-second head start and pursuit between walk/sprint speeds, with safe lift boarding and checkpoint death recovery. Tested an actual player-input sprint route rather than only teleporting the player. Expanded graphics with original industrial facility geometry and articulated stylized human meshes, preserving the lighting mood and tested routes. Screenshot review caught shadow artifacts and hidden coolant cylinders; fixed both and moved observation signage off the reactor view. Detailed art remains performant in short Low samples on the development machine; human playtest remains necessary.

## September 26 presentation and interaction follow-up

The user approved the darker facility, floor-book journals, title logo, long hair, custom angular character meshes, and the maintenance/journal interaction refinements. Maintenance now unlocks only after meeting both survivors; pickup views show one note, while J retains the collected-note index. Updated M3/M4 checks pass (37 and 41), and the Windows EXE/PCK was refreshed. Work was committed in separate visual, settings/audio, shadow, and access/journal groups, followed by documentation and the verbatim prompt record. Remaining work is M6 acceptance and final packaging, including confirming the target platform, longer playthrough/performance checks, and refreshing the final distributable archive from the latest source. The older standalone M5 ZIP predates these follow-up changes.
## M6 acceptance and packaging - September 26, 2026

Removed the original floating item/room labels and associated gate/station captions, preserving HUD guidance, target prompts, NPC labels, and industrial art signage. Refreshed the Windows release. M1/M2 regressions pass; progression, checkpoint/journal, settings, and shadow suites total 104 passing checks. A clean source copy imports and starts with Godot 4.7.2. Updated README and replaced historical demo instructions with the current playable route and remaining human checks. Prepared the source-and-Windows submission candidate under submission/Blackwell-A1-M6.zip; see verification.md for archive/startup results and environment diagnostics. First-time-player timing, full-route performance, a disconnected-network exported playthrough, and second-machine evidence remain open. No submission or commit is implied by packaging.


Added animated industrial sliding doors for maintenance and both gates, plus a shared large eight-legged shadow with fangs, glowing eyes, and a scuttling gait. Verified door animation/pause/collision, progression, checkpoints, and chase (101 checks); refreshed the Windows build and submission candidate.


Restored the original humanoid shadow at user request. Sightings now approach briefly and vanish after 0.9 seconds; evacuation grace reduced to three seconds. Updated cues/documentation, passed 65 relevant checks, and refreshed Windows/submission artifacts.


Added procedural walking/sprinting footsteps and an eerie layered background drone; increased the final alarm by 10 dB. Audio and settings checks pass (19 checks). Refreshed build/submission; final listening balance awaits user playtest.

## M5 additions approved - September 26, 2026

The user approved the final visuals and sound and requested that these additions be committed as M5 work before continuing M6. This approval covers removed hovering labels, sliding doors, restored approaching humanoid sightings, three-second chase grace, louder alarm, footsteps, and creepy ambience. Earlier M6 candidate packaging describes preparatory acceptance work, not completion of M6. M6 resumes from this approved M5 baseline; first-time-player timing, full-route performance, extracted offline playthrough, and second-machine evidence remain open.
