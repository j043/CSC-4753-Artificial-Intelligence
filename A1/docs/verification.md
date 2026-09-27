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

## M3 verification - September 25, 2026

Implemented: `scripts/progression.gd` owns ordered objectives, unique component state, exchange effects, readiness, and lift success. Main/player/facility/NPC integration provides interactions, phase hints, gates/navigation, and evacuation.

- Godot 4.7.2 Standard, Windows, Compatibility: all 29 M1, 56 M2, and 24 M3 automated checks pass. M2 deliberately disables story effects while retaining initially locked geometry.
- M3 covers early interactions, deferred exchanges, repeated pickup, interrupted repair retention, actual NPC repair/access travel, both gate navigation changes, three one-shot exchanges and changed hint, isolation arrival/cancellation/reassignment, premature lift activation, pause during evacuation, actual NPC lift travel, success, and fresh-run reset.
- Tests directly call interactions and reposition the player. They do not prove complete keyboard/mouse playthrough or first-time-player comprehension. No full AC is newly declared verified. AC-03 through AC-09 have partial implementation/test evidence; AC-12 timed escape/checkpoint remains M4.
- Inspected 1280x720 rendered captures for horizontal dialogue and objective/readiness readability. A wrapped objective exposed potential prompt overlap, corrected by placing the prompt below actual HUD height. Logs/screenshots remain ignored build artifacts.
- Engine emitted a Windows certificate-store diagnostic; initial sandboxed editor/log attempts reported unavailable user-profile writes. No GDScript errors occurred. Subsequent checks use a writable build log.

Pending: user playthrough using only in-game guidance, natural subtitle pacing/interruption, physical console targeting, player and two NPCs through the return route, 1080p visual review, measured timing/performance, and final narrative outcomes.

Windows release export completed successfully. Copied `Blackwell.exe` and `Blackwell.pck` into the separate ignored `builds/m3-portability-check/` directory and ran headless startup there: exit 0, "Blackwell M3 ready", no script errors. The certificate-store diagnostic persisted. This verifies packaged startup on this computer, not exported gameplay or second-machine compatibility.

### M3 interaction refinement - September 25, 2026

New object/NPC interactions and commands replace bottom feedback, reset typing/hold time, and clear stale acknowledgement backlog. Interrupted mandatory exchange lines replay afterward instead of silently completing. NPCs give phase-specific situation, role, and next-step information immediately; follow/wait, role task, and one optional context page replace the nested question tree. Updated M2 and M3 regression checks pass, including interruption/resumption and immediate command feedback.

### Component pickup timing fix - September 25, 2026

Meeting both survivors now unlocks component retrieval immediately instead of waiting for all briefing subtitles. The delayed briefing cannot regress later objectives. Early attempts explicitly report "Not collected"; tour inspection explicitly explains that objectives require initial-lockdown mode. All 28 M3 checks pass, including pickup during an interrupted briefing, immediate Mara acknowledgement/repair availability, and preserved state after delayed briefing completion.

### Playthrough feedback - September 25, 2026

The user reports completing the entire current game successfully. This is manual M3 flow evidence, not a timed new-player acceptance run. Reduced subtitle hold time to three seconds after typing. Shortened command acknowledgements, removed redundant repair/access arrival lines and lift boarding chatter, and retained isolation readiness, actionable blockage feedback, objective updates, and the three story exchanges. One isolation message explicitly announces both survivors moving to the lift.

## M4 - September 25, 2026

Implemented evidence: `scripts/narrative.gd` owns clue collection, run-local event flags, figure/lighting timing, generated alarm, final decisions, countdown, and a deep value checkpoint. `main.gd` owns decision confirmation, journal, endings/failure, pause volume/retry, and fresh-world restoration. `progression.gd` revalidates readiness and rejects zero-time lift success. New clue props are in `facility.gd`.

Verification: 29 M1, 46 M2, 29 updated M3, and 37 M4 checks pass. M3 still exercises real NPC travel through the complete route. M4 tests both decision branches, confirmation, note deduplication, occupied one-shot events, disappearance/restoration, three repeated retries, timer freeze/timeout, restored transforms/readiness/items/gates/notes/events, immediate retry before navigation synchronization, master-bus mute, zero-time lift race, and new-game reset. M4 fixtures arrange the pre-decision state directly; they do not replace a human full playthrough.

Rendered journal/decision/window-figure screens inspected at 1280x720 and escape HUD at 1920x1080; UI is readable. Basic figure is a graybox silhouette; presentation polish remains M5. Master volume is available in pause and affects the generated alarm. Audible quality/loudness, suspense, countdown fairness, both endings via physical controls, clue targeting, and performance still need user review.

Environment diagnostics: certificate-store warning persists; sandboxed rendering reported shader-cache write failures. Fast headless shutdown initially reported audio playback resources pending disposal; tests now give the mixer time to release stopped buffers. No GDScript errors remain in the passing checks. No complete acceptance criterion is inferred solely from these fixtures.

M4 Windows export completed; copied EXE/PCK to the separate ignored `builds/m4-portability-check/` directory and verified headless startup exits 0 with "Blackwell M4 ready". Exported gameplay and second-machine behavior remain untested. The final accelerated headless tests still intermittently report two audio-resource instances at engine shutdown despite stopping/detaching playback; this remains an engine/audio teardown diagnostic to revisit, not a cleared warning.

September 26, 2026: User reports playing both M4 endings successfully and approves the work. This adds manual ending-flow evidence; performance, timing, and exhaustive retry checks remain separate.

## M5 verification - September 26, 2026

Implemented: persistent `user://settings.cfg` preferences (`scripts/settings.gd`), main/pause settings menus, mouse sensitivity, Master volume/mute, ambient brightness, dynamic-shadow Low preset, and three window resolutions. New games/checkpoints retain preferences. Settings return correctly to pause and any preserved NPC conversation. New `soundscape.gd` provides original ambient hum and gate/objective cues. NPC labels now show player-facing activity names.

All 152 automated checks pass (M1 29 / M2 46 / M3 29 / M4 37 / M5 11). M5 tests use a separate ignored settings file to verify saved/reloaded preferences, application to new runs, brightness/shadows, Master mute, pause/dialogue input restoration, frozen NPC/countdown state, and story reset independent of settings. Existing certificate-store and accelerated audio-teardown warnings persist; no passing run reports GDScript errors. The rendered run has sandbox shader-cache write diagnostics. These are recorded rather than called clean engine logs.

Rendered Settings screens inspected at 1280x720 and 1920x1080: controls and Back fit; no camera motion effects are implemented. License notices extracted from the actual engine, with project-authored asset provenance recorded in CREDITS. Windows x86_64 remains the user's assumed professor target, not confirmed hardware/OS compatibility.

Performance method: three seconds per location after 60 warmup frames, measuring intervals between rendered frame-post-draw signals, VSync off, Low/720p, flashlight enabled; escape includes moving NPCs and alarm. These short engine render-loop samples are not a GPU-isolated benchmark, whole-game minimum, or guarantee for other computers. They support the target only for sampled conditions. Headless correctness tests are not FPS evidence.

```text
Godot 4.7.2-stable (official)
CPU: 12th Gen Intel(R) Core(TM) i7-12650H
GPU: NVIDIA GeForce RTX 3050 Ti Laptop GPU
Memory: { "physical": 34011602944, "free": 22314573824, "available": 36159086592, "stack": 8388608 }
OS: Windows
Low preset, 1280x720, Compatibility, VSync disabled. Three-second rendered-frame samples per location; not full-playthrough performance.
security: average 1287.0 FPS; p95 1.03 ms; worst 2.07 ms
maintenance: average 1408.0 FPS; p95 0.99 ms; worst 1.79 ms
observation: average 1561.5 FPS; p95 0.91 ms; worst 2.10 ms
escape: average 976.3 FPS; p95 1.42 ms; worst 2.16 ms
```

Pending: user M5 settings/audio playtest, longer real-route profiling, first-time-player duration (15-25 minutes remains unverified), second computer if available, and M6 final source/export ZIP audit.

M5 Windows release exported successfully. Created `builds/Blackwell-Windows-M5.zip` containing EXE, PCK, launch/control/settings README, and engine/component licenses. ZIP CRC check passed; extracted to separate `builds/m5-extracted-check/` and launched headless: exit 0, "Blackwell M5 ready". This verifies packaged startup, not a second-machine or exported full-playthrough test. The final source-and-deliverables ZIP remains M6.

## Requested shadow chase and graphics pass - September 26, 2026

New behavior: brief nonlethal sightings at randomly selected visible, reachable anchors during normal exploration. Timers stop outside active gameplay. Isolation starts a six-second grace period, then a 4.1 m/s navigation/collision-aware pursuit; normal walk is 3.4 m/s and sprint is 5.6 m/s. Capture within 0.9 m requires an unobstructed line to the player. The lift interior is safe while waiting for NPCs. Death exposes the existing checkpoint retry; reconnect does not start the chase. Retry/new game recreate the shadow controller with no stale pursuit or sightings.

All 167 automated checks pass: prior 152 plus 15 dedicated checks covering harmless sightings, visibility/lifetime, pause, closed gates, grace, actual corridor traversal and capture, death retry, a full evacuation using normal sprint input, lift safety, leaving safety, reconnect, and new-game reset. The M3 general progression fixture now waits at the lift; the separate chase fixture explicitly performs the moving-player escape. Difficulty and natural random-sighting frequency still need user feedback.

Graphics: original industrial dressing, an actual reactor view through sealed glass, detailed instruments/coolant/workbench/clues, and stylized human NPCs with faces, equipment, facing, gait, and work poses. Decorative geometry stays off navigation; original collision/interaction tests pass. The observation window still physically seals the chamber. Component decoration hides after collection/retry. Reduced shadow artifacts by retaining non-shadowed room lights and reserving Standard's dynamic shadow for the flashlight. Rendered screenshots inspected for security/NPCs, control, coolant, workshop, and reactor; art is stylized, not photorealistic.

Post-art performance, same short-sample method and limitations as M5 (escape sample includes shadow movement):

```text
Godot 4.7.2-stable (official)
CPU: 12th Gen Intel(R) Core(TM) i7-12650H
GPU: NVIDIA GeForce RTX 3050 Ti Laptop GPU
Memory: { "physical": 34011602944, "free": 22391222272, "available": 36159086592, "stack": 8388608 }
OS: Windows
Low preset, 1280x720, Compatibility, VSync disabled. Three-second rendered-frame samples per location; not full-playthrough performance.
security: average 528.4 FPS; p95 2.52 ms; worst 3.67 ms
maintenance: average 799.5 FPS; p95 1.64 ms; worst 2.70 ms
observation: average 1248.8 FPS; p95 1.17 ms; worst 2.58 ms
escape: average 721.1 FPS; p95 1.85 ms; worst 2.79 ms
```

Existing sandbox certificate/shader-cache diagnostics and intermittent accelerated audio-teardown warnings persist. No GDScript errors in passing suites.

## Darker facility and floor journals - September 26, 2026

Reduced ambient energy from 0.55 to 0.07 and room-light energy from 1.1 to 0.22, with a shorter six-meter reach and dimmer ceiling fixtures. Brightness preferences scale the new baseline; the coolant flicker restores it correctly. Flashlight output remains strong. Replaced the three upright clue blocks and floating labels with small floor books, each with covers, page edges, a spine, a cover label, and a bookmark. Existing clue IDs and journal behavior remain intact.

Validation: all 37 M4 and 11 M5 checks pass. A temporary rendered fixture verified the actual player interaction ray hits all three books from standing height. Inspected flashlight-on/off screenshots and a close book view. Existing sandbox certificate-store, log-write, and shader-cache diagnostics occurred; no GDScript errors. Manual darkness preference/playthrough feedback remains useful.
## Title logo and Mara hair - September 26, 2026

Added an original code-drawn nuclear insignia and BLACKWELL / LAST SHIFT wordmark to the main menu, with gold industrial accents. The logo replaces only the main-menu heading and retains button focus and layout. Mara now has long chestnut hair beneath her hard hat, with face-framing side locks and back strands.

Validation: 11 M5 menu/settings checks pass. Inspected rendered 1280x720 title-screen and front/back Mara screenshots; all title buttons fit, and hair leaves her face visible. Existing certificate-store/shader-cache sandbox diagnostics remain. No GDScript errors in the check run.
## Shaped character meshes - September 26, 2026

Replaced oval torsos, limbs, hands, boots, necks, noses, and heads with original custom cross-section meshes: tapered clothing, chamfered edges, sloping shoulders, defined jaws, and flat boot soles. Mara's long hair now uses a continuous shaped back section and two tapered side locks. Small facial details and rounded headgear retain curved primitives. Both NPCs retain existing animation pivots and collision geometry.

Validation: M2 NPC/navigation/dialogue suite passes with zero failures. Inspected rendered Mara front/back and Eli views; corrected mesh winding during visual review. Windows EXE/PCK re-exported successfully. Existing certificate-store and editor-settings sandbox diagnostics persist; no GDScript errors in passing checks.
## Maintenance introductions gate and focused journal reading - September 26, 2026

Maintenance now starts behind a physical door that blocks player collision and NPC navigation until both Mara and Eli have been spoken to. Either introduction order works; repeated conversations with one NPC do not unlock it. Opening removes the door and rebuilds navigation. New games relock it; facility tours and restored isolation checkpoints keep access open. Reading a book shows only that note and Return to facility; J retains the collected-note index.

Validation: all 37 updated M3 checks and 41 updated M4 checks pass, including blocked player movement, locked/open navigation, repeated and reversed introductions, new-game reset, actual repair/access/evacuation travel, single-note pickup views, journal index, and checkpoint retries. Inspected locked-door and single-note screenshots. Windows EXE/PCK exported successfully. Existing certificate-store/editor-settings sandbox diagnostics remain; no GDScript errors in passing checks.
## M6 submission candidate - September 26, 2026

Removed original floating room/item/gate/station captions and their stale update code. HUD room names, interaction prompts, NPC name/activity labels, industrial signs, and book cover details remain. Inspected the newly rendered workshop view; no hovering workbench caption remains. Refreshed Windows EXE/PCK and replaced the outdated demonstration checklist with the current route and explicit human acceptance steps.

| Check | Result |
| --- | --- |
| M1 movement/collision/traversal regression | Exit 0, zero failed checks; two ObjectDB instances reported at shutdown by this test harness. |
| M2 dialogue/navigation/commands regression | Exit 0, zero failed checks. |
| M3 real progression and evacuation | 37 checks, zero failures. Includes both introduction orders and maintenance gating. |
| M4 decisions/checkpoints/journal/reset | 41 checks, zero failures. |
| M5 persistent settings/pause | 11 checks, zero failures. |
| Shadow sightings/chase/retry/lift safety | 15 checks, zero failures. |
| Rendered art capture | Compatibility renderer on RTX 3050 Ti; exit 0. Workshop image inspected. |
| Windows release export | Exit 0; refreshed EXE/PCK. |
| Clean source copy | Copied source without .godot cache into a separate staging directory; Godot 4.7.2 import and headless startup both exit 0, reporting Blackwell M6 ready. No missing assets or GDScript errors observed. |

Environment limitations: sandboxed engine runs report inability to read the Windows certificate store; editor/export runs also cannot save editor preferences outside the workspace. The first M3 invocation could not write its default engine log, and initial M4/M5 relative log paths were rejected. These diagnostics are not counted as game script failures. This is not evidence of a wholly diagnostic-free run. Local M1/M2/shadow/import/export logs are in ignored builds/m6-*.log files.

The submission candidate includes assignment-root README, specification, full source/tests, current prompt log, prompt-preservation instructions, credits/licenses, current demo checklist, development summary, and Windows EXE/PCK. Local tools, source import caches, old builds/archives, and developer logs are excluded. Packaging and extracted-startup evidence follows below.

Remaining human acceptance: timed first-time-player run (15-25 minutes unverified), full-playthrough performance and blocker check, disconnected-network exported playthrough, display/audio/settings review, and another Windows computer if available. Windows remains the user's assumed professor platform, not confirmed. Prior successful user playthroughs of both endings are recorded above; they do not substitute for a fresh extracted M6 playthrough. Manual submission is still required.

Archive audit: Blackwell-A1-M6.zip contains 64 files and passes ZIP CRC verification. Extracted to submission/m6-extracted/ and launched the packaged Blackwell.exe directly from its own directory with --headless --quit-after 120: exit 0, Blackwell M6 ready. The same certificate-store diagnostic appears. This verifies standalone startup on the development computer, not rendered exported gameplay or another computer. Final archive incorporates this evidence; executable and PCK are unchanged from the extracted startup test.


## Sliding doors and spider entity - September 26, 2026

All three locked entrances now use split steel sliding panels, hazard strips, recessed trim, and red lock indicators that turn green on unlock. Leaves retract sideways over 1.15 seconds with physical collision, and pause freezes their motion. Tour/checkpoint doors initialize fully open. Navigation blockers retain the existing progression rules and inspection prompts.

The shadow now uses a shared original eight-legged creature mesh for random sightings, the chamber appearance, and pursuit: broad dark carapace, tall pointed legs, fangs, six glowing eyes, idle movement, and a scuttling gait that turns with travel. Chase speed, grace period, capture rules, and lift safety remain intact.

Validation: eight new door/spider checks, M3's 37 checks, M4's 41 checks, and all 15 shadow checks pass (101 total). Rendered closed/open door and frontal creature captures inspected. Windows EXE/PCK refreshed. The initial new test used an incorrect resume method name; corrected to the existing resume method before the passing run. Engine sandbox diagnostics remain as documented above. Updated archive replaces the earlier 64-file candidate; archive validation and extracted startup are checked again for this build.


## Humanoid restoration and faster appearances - September 26, 2026

Restored the original dark humanoid torso/head silhouette for sightings, chamber appearance, and pursuit; removed the unused spider visual. Harmless appearances approach the player at 1.8 m/s, stop before obstacles or close contact, and vanish after 0.9 seconds. Chamber glimpses use the same movement/lifetime. Evacuation pursuit now has a three-second grace period; Mara's warning and README match. Sliding doors remain unchanged.

Validation: shadow suite 16/16 (including approach, shorter lifetime, pause, actual sprint escape with the reduced grace, and retry); M4 41/41; door/humanoid suite 8/8. All exit 0. Door test reported two ObjectDB instances at teardown; certificate/editor-preference sandbox diagnostics persist. Windows export refreshed successfully. Submission ZIP refreshed from current source/build and CRC/content checked; prior spider package is superseded. Final human playtest remains outstanding.


## Audio polish - September 26, 2026

Raised the evacuation alarm from -16 dB to -6 dB. Added original synthesized boot impacts with scuff and metal resonance; cadence follows actual grounded movement, alternates pitch, and accelerates while sprinting. Stationary movement, pushing into a wall, and pause do not generate footsteps. Replaced the quiet single-tone hum with an eight-second seamless low drone, dissonant swelling tones, and whisper-like modulation. Cached procedural streams avoid regeneration during checkpoint retries. All audio uses Master volume/mute and the world's pause lifecycle.

Validation: eight audio behavior checks and eleven settings checks pass, exit 0. These verify triggering, cadence, wall/idle/pause behavior, loop configuration, alarm gain, and Master routing; subjective listening on the user's speakers/headphones remains a manual check. Windows export and submission archive refreshed. Existing sandbox certificate/editor-preference diagnostics remain.


## M6 from approved M5 commit 281996e - September 26, 2026

User confirmed the final visuals and audio look/sound good, then authorized committing them as M5 additions. M6 now has an explicit evidence/remaining-work table in m6-acceptance.md and reproducible packaging via package_submission.py.

Rendered integrated progression profile:

```text
Approved M5 baseline: 281996e
Automated M3 route, rendered Low 1280x720, VSync off. Scripted player relocations; real NPC traversal. Excludes menus/paused frames. Not a human full-route benchmark or first-playthrough timing.
CPU: 12th Gen Intel(R) Core(TM) i7-12650H
GPU: NVIDIA GeForce RTX 3050 Ti Laptop GPU
Frames: 8540; gameplay sample seconds: 71.94
Mean FPS: 118.7; median frame ms: 8.33; p95 frame ms: 8.33; p99 frame ms: 8.71; worst frame ms: 144.39
Progression checks: 37; failures: 0
```

All 37 progression checks passed against the approved code, including real NPC evacuation and new-game resets. Reported timings use engine process-frame deltas over unpaused gameplay, not independent GPU timings. Shader-cache write diagnostics and the known certificate-store diagnostic occurred under the sandbox; this was not a diagnostic-free run. Human route timing, offline release playthrough, and second-machine testing remain pending.


## User M6 playthrough report - September 26, 2026

User reports several successful full playthroughs, everything working great, with approximately five-minute completion time. This is a familiar-player report, not a verified first-time-player timing; it is shorter than the 15?25 minute design target. Exact tested build/launch method, disconnected-network status, and coverage of individual endings/failure paths were not specified. Second-computer testing is unavailable, explicitly confirmed by the user; record as not tested, not an unresolved request for another machine. Remaining handoff work includes extracted offline release confirmation, timing-target disposition, final documentation/package review, M6 commit, and manual submission.


## Final M6 user acceptance - September 26, 2026

User confirms everything worked offline and a new player on the same machine completed the game in approximately 16 minutes. This satisfies the 15-25 minute pacing target for one observed new-player run. Earlier approximately five-minute runs were familiar-player runs. User authorized finalizing documentation and committing. Several full playthroughs and final visuals/audio were approved. Second-computer testing was unavailable, not failed. Offline launch method, assistance details, and individual ending/failure coverage were not separately specified; do not infer them. Documentation and submission packaging are finalized with these limitations; manual submission remains outstanding.
