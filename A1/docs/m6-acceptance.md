# M6 final acceptance record

Finalized September 26, 2026, following user approval. Approved M5 gameplay baseline: `281996e`. M6 documentation, verification, and packaging are ready for manual submission.

## Human playtest evidence

- The user reports several full playthroughs completed successfully, with everything working well and no blockers reported.
- Familiar-player completion time: approximately five minutes.
- One new player on the same machine completed the game in approximately 16 minutes. This meets the 15-25 minute target for that observed run; it is a sample of one, not a general pacing guarantee.
- The user confirms everything worked offline. The report does not separately enumerate every ending/failure path or specify the launch method.
- The user approved the final visuals and sound.
- A second computer was unavailable: not tested. Windows remains the assumed professor platform, not independently confirmed.

## Technical evidence and limits

| Scope | Evidence |
| --- | --- |
| Setup and distribution | Godot 4.7.2 clean source import/startup and separately extracted Windows executable startup succeeded. Original assets need no downloads. |
| Controls and NPCs | M1/M2 automated checks cover controls, collision, dialogue, follow/wait, navigation, and recovery. |
| Progression | Integrated rendered M3 run: 37 passing checks, covering objectives, exchanges, gates, readiness, evacuation, and new-game resets. |
| Endings and horror | M4: 41 passing checks. Latest shadow suite: 16 passing checks, including approaching sightings, three-second grace, sprint escape, capture, lift safety, and retry. |
| Doors and audio | Door/humanoid suite: eight passing checks. Audio suite: eight passing checks. Settings suite: eleven passing checks. User approved presentation and sound. |
| Performance | Low/720p automated rendered progression: 118.7 FPS mean, 71.94 gameplay sample seconds, p99 8.71 ms, worst frame 144.39 ms on i7-12650H / RTX 3050 Ti. Scripted relocations and real NPC traversal; not uninterrupted human-route or second-machine profiling. |
| Deliverables | Source/tests, Windows EXE/PCK, README, actual prompts, credits/licenses, development summary, demo checklist, and packaging script included. ZIP CRC and exact file contents verified; SHA-256 sidecar generated. |

The automated checks and human reports are complementary evidence; individual human walkthrough steps were not all separately reported. Engine sandbox certificate/cache/editor-preference diagnostics and occasional test-harness shutdown leak warnings are recorded in verification.md. No claim of a wholly diagnostic-free environment is made.

## Final handoff

1. Submit `A1/submission/Blackwell-A1-M6.zip` manually before September 28, 2026, 7:00 a.m. Central.
2. The recipient extracts the ZIP and launches `A1/builds/windows/Blackwell.exe`, keeping its PCK alongside it. No Godot editor or account is needed.
3. Use `docs/demo-checklist.md` as the demonstration route, not as a claim that every unchecked step was individually observed.

If changes are made later, re-export Windows Desktop after gameplay changes, then run `python A1/package_submission.py` from the repository root. This verifies contents and writes a SHA-256 sidecar; it does not run Godot's exporter or submit the assignment.
