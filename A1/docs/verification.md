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

All ACs remain unverified as complete criteria. AC-01, AC-16, and AC-17 have partial infrastructure/documentation work; AC-02–AC-15 gameplay is planned only. Use the specification's traceability table for required checks. Expand each AC into individual subrequirement results as implementation reaches it; include build/revision, procedure, observed result, and failures. Headless launch does not establish visual correctness, input behavior, graphics performance, or user playability.
