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
