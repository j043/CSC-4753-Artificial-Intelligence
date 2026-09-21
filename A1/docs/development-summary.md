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
