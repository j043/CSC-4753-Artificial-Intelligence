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
