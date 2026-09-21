# Verification record

## Decisions and test environment — September 18, 2026

- Professor OS/architecture and submission-specific layout: unknown.
- Primary testing: user's current computer; second computer availability unknown.
- OS: Microsoft Windows 11 Home, 64-bit.
- CPU: 12th Gen Intel Core i7-12650H.
- GPUs reported: Intel UHD Graphics and NVIDIA GeForce RTX 3050 Ti Laptop GPU. Actual renderer device must be recorded during graphical execution.
- RAM reported: 31.7 GiB (approximately 32 GB installed).
- Engine confirmed by executable: `4.7.2.stable.official.ed1daf0bf` (Standard).
- Renderer configured: Compatibility. Initial viewport: 1280×720.
- Gameplay FPS and first-playthrough duration: not measured.

## M0 checks

| Check | Status/evidence |
| --- | --- |
| Reviewed spec committed | Pass: `0456925` |
| Hardware inventory | Pass: OS/CPU/GPU/RAM queried locally |
| Portable editor download and exact version | Pass: official download extracted under `.tools/godot-4.7.2`; executable reports `4.7.2.stable.official.ed1daf0bf` |
| Clean project import and GDScript parsing | Pass: headless editor import completed without reported script errors after granting normal Godot user-directory access |
| Baseline runtime launch | Pass: `--headless --path A1/game --quit-after 3` printed `Blackwell M0 baseline ready` and exited 0 |
| Matching Windows export templates | Pass: Windows x86_64 debug/release templates extracted from official 4.7.2 template archive into Godot's user template folder; other platforms not installed |
| Standalone export and separate-folder launch | Pass for headless startup: release export copied to a unique `Blackwell-M0-*` folder under Windows TEMP; `Blackwell.exe --headless --quit-after 3` printed baseline-ready message and exited 0 without reported errors |
| Setup instructions and visible start screen | Pass (user-reported): user followed the setup steps and saw the M0 start screen on September 18, 2026; source versus exported launch was not specified |
| Quit button/input | Pass (user-reported): user confirmed that Quit closed the game successfully on September 18, 2026 |
| Professor platform validation | Blocked on platform information |

The initial sandboxed import reported denied user-directory/cache access. Repeating the import with normal per-user access resolved those errors. Automated tests ran against the M0 working tree following spec commit `0456925`. The user subsequently confirmed following setup instructions, seeing the M0 start screen, and successfully closing it with Quit. This confirms basic visible startup and Quit input, not a full visual audit. No network-disconnected or second-machine test has been performed. The exported program launched directly without invoking the editor during the headless check, but this machine now has the portable editor available; validation on a machine without development tools remains pending.

M0's local setup and baseline checks are complete and ready to commit. Professor OS confirmation remains an open delivery decision; it does not block committing the Windows development baseline or beginning M1.

## Acceptance status

All ACs remain unverified as complete criteria. AC-01, AC-16, and AC-17 have partial infrastructure/documentation work; M1 now implements portions of AC-02, AC-03, AC-13, and AC-14; see the dated M1 evidence below. Other gameplay remains planned. Use the specification's traceability table for required checks. Expand each AC into individual subrequirement results as implementation reaches it; include build/revision, procedure, observed result, and failures. Headless launch does not establish visual correctness, input behavior, graphics performance, or user playability.

## M1 - September 21, 2026

Implemented on `Development/Assignment-1`; included in the M1 milestone commit. Engine remains 4.7.2 Standard. This is a graybox milestone, not completed gameplay acceptance.

| Check | Result and evidence |
| --- | --- |
| Project import and parsing | Pass with normal Godot user access; no script errors in `builds/m1-import.log` |
| Automated gameplay checks | Pass: 29 checks, zero failures; `game/tests/m1_checks.gd`, output `builds/m1-checks.log` |
| AC-02 movement/collision subset | Automated walking and held sprint speeds, floor support, sprint collision with perimeter wall, desk, and both gates passed. Real keyboard/mouse feel and broad edge/corner exploration remain manual. |
| AC-02 / AC-14 flashlight subset | Off/on action toggles passed; actual renderer capture shows a flashlight pool on nearby geometry. Physical F-key and broader surface checks remain manual. |
| AC-02 interaction subset | Gate/desk targeting and out-of-range rejection passed using the camera ray. E-key feedback and occlusion edge cases remain manual. |
| AC-03 layout subset | Tour route walked security → control → maintenance → control → coolant → observation → security → lift → security. Floor support and return route passed. Initial gates physically block sprinting. Objective-driven unlocking remains M3. |
| AC-13 menu/pause subset | Start, pause freezing movement, pointer release, resume, return to menu, and fresh-run gate/spawn reset passed programmatically. Settings/checkpoints remain later work. |
| Actual graphics execution | Pass: Compatibility, OpenGL 3.3, NVIDIA GeForce RTX 3050 Ti Laptop GPU, driver 596.49; `builds/m1-visuals.log`. Captured and inspected 1280×720 menu, security, coolant and pause views. Fixed overlapping signs and transparent pause background. |
| Full AC status | No complete AC marked verified; M2–M6 behavior remains outside these tests. FPS, 1080p, second-machine and offline tests not performed. |

Reproduce the automated checks from repository root (substitute your Godot executable path):

```powershell
& A1/.tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path A1/game --fixed-fps 60 --script res://tests/m1_checks.gd
```

Optional graphical captures: run the same engine with `--path A1/game --script res://tests/m1_visuals.gd` (omit `--headless`). PNGs go to ignored `A1/builds/`. Test scripts are excluded from the desktop export.

The initial sandbox run could not access the certificate store/editor settings. Normal user access resolved this. A UTF-8 BOM in the generated scene and a GDScript inferred-type error were fixed before the successful import. The first test route attempted to walk diagonally through a doorway wall; it was corrected to follow the doorway center, and the full intended route then passed. Headless mode does not capture a real mouse; flashlight actions no longer depend on pointer capture, while mouse look still does.

### M1 hands-on checklist (pending)

1. Launch `builds/windows/Blackwell.exe`, choose Start, and verify mouse look, WASD, held Shift, F, and nearby E prompts/feedback.
2. Walk against walls, machinery, corners, and both locked gates. Gate A is north of control; Gate B is north of coolant (accessible in the automated fixture, normally blocked by Gate A).
3. Escape, move the mouse, and try movement/F/E while paused. Resume and confirm normal controls. Alt-tab away and back; expect the pause menu.
4. Return to Menu, choose Facility tour, and visit all six labeled rooms. Maintenance branches east from control; lift branches west from security. Walk to observation and back without getting trapped.
5. Return to Menu and Start again; verify both gates return to their locked state. Quit from the pause or main menu.

Do not mark M1 fully playtested until the manual results are recorded.

### M1 export result

Windows release export succeeded (`builds/m1-export.log`). Copied only `Blackwell.exe` and `Blackwell.pck` to `C:/Users/jwrig/AppData/Local/Temp/Blackwell-M1-a0f83a073c854330a9d0c3634db8a5b9` and launched there with `--headless --quit-after 5`: printed `Blackwell M1 ready`, empty standard error, exit 0. Output/exit were captured with a waited process; the first direct GUI-executable invocation did not produce the requested log file. This verifies standalone startup, not a full exported-build playthrough.

`git diff --check` reports only the preserved trailing space in verbatim prompt entry 14. It is intentionally retained under the repository's prompt-preservation rule; checking with end-of-line whitespace ignored passes.

### User walkthrough - September 21, 2026

User reports completing a walkthrough and that it looks great, and authorizes the M1 commit. This confirms a hands-on traversal and positive visual review. Launch mode, exact route, individual control checks, and edge-case testing were not specified; those checklist items are not individually marked passed. M1 is accepted for commit and work can proceed to M2.

## M2 - September 21, 2026

Implemented in the working tree following M1 commit `9792352`. Hands-on M2 playtesting is pending. No complete AC is marked verified by this slice.

| Scope | Evidence |
| --- | --- |
| AC-04 NPC identities | Mara has ochre engineer clothing/tool bag; Eli has wider blue uniform/badge. Both have name/state labels and named dialogue. Real-renderer preview inspected. Objective/event behavior changes remain M3/M4. |
| AC-05 dialogue subset | Situation and expertise each offer two authored response branches per NPC, plus objective hints, commands and exits. Player movement/look lock and dialogue pause/resume verified automatically. No items/rewards are granted; story-phase predicates/content remain later work. |
| AC-06 navigation and commands | 28 M2 checks passed, including both NPCs reaching distinct stations, follow around corners/obstacles, separate stopping offsets, tracking a walking player through a doorway, wait, interrupted travel clearing readiness, locked-task rejection, and missing-prerequisite messages. |
| Gate connectivity | Both locked gates disconnect baked navigation. Removing Gate A and rebaking connects coolant while Gate B still disconnects observation. Tour allows both NPCs to reach separate observation anchors. |
| Recovery | Test encloses Mara with physical barriers after navigation bake. Lack of progress triggers retry and then safe waiting, with readiness cleared. Removing barriers and reassigning reaches the station without restarting or teleporting. |
| AC-13 input/pause subset | Player movement/look disabled during dialogue; pause freezes NPC travel; resume preserves conversation page and keeps pointer visible; ending conversation restores controls. |
| M1 regressions | All 29 existing M1 checks pass with NPCs present. Original spawn positions blocked the test's direct lift route; moved starting positions clear of that walking line. |
| Visual execution | NVIDIA GeForce RTX 3050 Ti Laptop GPU, Compatibility/OpenGL 3.3, driver 596.49. Inspected survivor, dialogue and command views; command panel fits at 1280×720 and 1920×1080. Dark backdrop improves readability. |
| Limitations | Manual command/menu input, broad crowding/corner cases, sustained performance, and final narrative progression are not verified. NPCs are placeholder primitive models without walking animation. Arrival readiness is an inspection state, not a completed repair/security/puzzle objective. |

Navigation is baked synchronously from static collision geometry when constructing this small facility, then waits for server synchronization. It is not a shipped precomputed navigation resource. M3 gate changes must call `build_navigation()` after collision removal. NPCs use collision-aware movement, separate follow offsets, side steps, periodic replanning, and cancellation on persistent blockage. No relocation fallback crosses gates.

Reproduce checks (substitute the engine location if needed):

```powershell
& A1/.tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path A1/game --fixed-fps 60 --script res://tests/m2_checks.gd
& A1/.tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path A1/game --fixed-fps 60 --script res://tests/m1_checks.gd
```

Local logs: `builds/m2-checks.log`, `builds/m2-regression.log`, `builds/m2-visuals.log`, `builds/m2-export.log`. Optional captures use `--path A1/game --script res://tests/m2_visuals.gd` with the graphical engine. Generated logs/images/builds remain ignored. Initial import exposed a native `ready` signal name conflict; renamed NPC state to `task_ready`. Navigation-map cell sizes were aligned with the baked mesh to resolve warnings.

### M2 hands-on checklist (pending)

1. Start, aim at Mara/Eli, press E, and try situation, objective and expertise branches. Exit each conversation.
2. Give both Follow commands, end conversation, walk through control/maintenance and around machinery. Ask Wait, move away, and return to ask Follow again.
3. Assign Inspect your station, end conversation, and observe each NPC walking to the correct destination and reporting arrival. Interrupt/reassign a task.
4. In lockdown, request isolation and repair/authorization; read the missing gate/objective prerequisites. In Facility tour, send both to their isolation anchors.
5. Pause during travel and during dialogue; confirm travel freezes and Resume returns to the correct input mode. Test Return to Menu/New Start resets NPC state.
6. Briefly obstruct an NPC, move aside, and verify recovery or reassign after its named blocked-route message.

### M2 export result

Windows release export succeeded with no reported script errors. Copied the executable and PCK to `C:/Users/jwrig/AppData/Local/Temp/Blackwell-M2-e8fc9f51d9a44ae184a47b531dccd6ac`. Attempting the external `--script` test harness only launched the menu and produced no test assertions; the idle instance was stopped. Therefore no exported-build gameplay pass is claimed. Ordinary standalone startup with `--headless --quit-after 5` printed `Blackwell M2 ready`, produced no standard error, and exited 0. Source gameplay checks and actual-renderer source captures passed separately; a full exported-build manual playthrough remains pending.

### M2 playtest revisions - September 21, 2026

User confirmed following works but reported overwhelming dialogue and followers moving out of view when the player turns. Replaced facing-relative follow offsets with world-space targets updated only by player translation. Reduced the opening to a short hint and three choices; optional topics are nested, response pages show only Back/End, and all pages have at most four buttons. Follow/Wait is contextual; station assignments are offered under Help. No narrative acceptance criteria were deleted.

All 34 M2 automated checks pass, including a full turn in place with both NPCs remaining stationary and choice-count checks for every topic page. Existing travel, blockage recovery, gate connectivity and input-mode tests also pass. User verification of these revisions remains pending.

### Escape interaction revision

Escape now closes any open dialogue page and restores gameplay without pausing. A subsequent Escape opens pause; another resumes. Focus-loss pause still preserves dialogue. All 37 M2 checks pass, including these three Escape transitions. Earlier instructions to pause a conversation with Escape are superseded by this change.

### Dialogue presentation revision

Enlarged dialogue body text to 30 pixels and placed choices in a horizontal row, with an Escape hint replacing End conversation. Commands close the menu immediately and release the NPC to act. Bottom-screen feedback types at 40 characters per second, holds for five seconds after completion, then clears; overlapping lines queue and timing freezes outside gameplay. All 56 M2 checks pass, including command closing, horizontal choices, exit-button removal, typing/hold/queue timing. Inspected actual-renderer horizontal choices at 720p and bottom feedback at 1080p. User acceptance remains pending.

### M2 user acceptance - September 21, 2026

User approved the revised appearance and feel, confirmed that the fixes improved the experience, and authorized committing M2 before resuming M3 tomorrow. This records general playtest acceptance; it does not independently verify every manual edge case or later milestone requirement. M2 is accepted for commit.
