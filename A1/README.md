# Blackwell: Last Shift

A1 for CSC-4753 Artificial Intelligence. See [the specification](spec.md) for scope and acceptance criteria.

## Current status

M6 documentation and acceptance are finalized for submission on September 26, 2026. Approved M5 baseline: `281996e`. See [the acceptance record](docs/m6-acceptance.md) for evidence and limitations.

The completed game includes six objectives, two survivors, cooperative tasks, two endings, checkpoint retry, clues, a lethal evacuation chase, industrial scenery, and persistent settings. Automated checks pass. The user reports successful offline play and several complete playthroughs; a new player completed the game in approximately 16 minutes on the same computer, meeting the 15-25 minute target. Another computer was unavailable and was not tested.

## For the professor: run the submitted game

No Godot editor, VS Code, installation of development tools, accounts, API keys, or internet connection is required to play the packaged game.

### Launch

The current export targets **Windows x86_64**. The user assumes the professor uses Windows; this is not independently confirmed. macOS/Linux builds are not included.

1. Extract the entire submission ZIP into a writable folder. Do not run the executable from inside the ZIP viewer.
2. Open `A1/builds/windows/` inside the extracted submission.
3. Double-click **`Blackwell.exe`**. Keep **`Blackwell.pck`** in the same folder; it contains the game's packaged resources.
4. Select **Start - initial lockdown** to explore with the initial gates locked, or **Facility tour - gates open** to walk all six areas. Press Escape for Resume, Return to Menu, or Quit.

The submission candidate is `submission/Blackwell-A1-M6.zip` in the working repository. It includes source, the Windows executable and resources, documentation, prompts, credits, and licenses. Older M5 archives are obsolete. A source-only Git checkout does not include generated builds or archives.

### Controls and graphics

Implemented: **WASD** walk, **mouse** look, hold **Shift** to sprint, **E** inspect or talk to the targeted object/NPC within 3 meters, **F** toggle flashlight, and **Escape** pause/resume, and **J** reread collected notes before evacuation. Menus support mouse and keyboard. Losing application focus pauses gameplay. The window opens at 1280×720.

There is no jumping, head bob, or camera shake. Open **Settings** from the main or pause menu for mouse sensitivity, master volume/mute, brightness, Low quality, and 1280x720 / 1600x900 / 1920x1080 resolution. Settings persist in Godot's per-user `settings.cfg`; New Game and checkpoint retries retain them. Settings and pause freeze gameplay. Low quality disables dynamic shadows. Gate A requires emergency power; Gate B requires power and security authorization. Both gates now unlock through those objectives. Facility tour is a development walkthrough, not completed story progression.

### Talk to Mara and Eli

Both survivors start in security. Aim at one and press **E**. Each NPC immediately explains the situation, their role, and the current next step. Three horizontal choices provide **Follow me / Wait here**, the current **role task**, and optional **More context**. There are no nested question menus; More context gives one short explanation with Back.

Escape closes the conversation. Commands close it immediately so the NPC can act. New interactions replace current bottom feedback and clear stale queued acknowledgements. The new line types out, stays for three seconds, then disappears. Interrupted story-exchange lines resume afterward so essential information is retained. Spontaneous NPC lines still serialize when no new interaction replaces them.

Followers track your movement, not your facing direction. Once they stop near you, turning around leaves them in place so you can talk. If someone reports a blocked route, clear the obstruction and speak to them again to follow or reassign. Escape closes an open conversation and restores gameplay. Press Escape again to pause. Losing application focus still pauses safely; Resume then returns to the conversation.

### Build verification

Recorded checks pass: 29 M1, 46 M2, 37 M3, 41 M4, 11 M5, and 15 shadow/chase checks, covering navigation, dialogue input modes, follow/wait, station arrival, interruption, recovery, and gate connectivity. See the verification record for export results and the hands-on checklist. Automated checks do not establish visual quality, real mouse/keyboard usability, or gameplay performance. See the [verification record](docs/verification.md) for details and the [demonstration checklist](docs/demo-checklist.md) for the planned assignment demonstration.

### Playthrough

1. Talk to Mara and Eli in security. The maintenance door unlocks after speaking to both, in either order. Close dialogue with Escape and read their briefing across the bottom.
2. Walk north to control, then east into maintenance. Use E on the workbench to collect the component.
3. Talk to Mara: Restore power. Follow her to maintenance; her arrival consumes the component and opens Gate A.
4. Ask Eli to authorize observation access. He goes to control; his radio confirmation opens Gate B.
5. Enter coolant and read the imitation warning. Ask both survivors to go to their isolation stations in observation. You can use Follow me to bring survivors along before assigning stations.
6. Check both READY indicators, then use E on the chamber console. This saves an in-memory checkpoint and presents the trust decision. Early attempts explain who is missing; Wait cancels readiness and reassignment restores it.
7. Choose **Trust survivors / ISOLATE** to start the alarm, 120-second countdown, and shadow chase. You get a three-second head start. **Hold Shift to sprint** south through coolant/control/security and west into the lift. The shadow is faster than walking and slower than sprinting. Reaching the lift interior makes you safe while both survivors board; then activate the lift. If the shadow catches you outside, use Retry Checkpoint from the death screen.
8. Use **Retry Checkpoint** from an ending/failure screen or **Restart Checkpoint** from pause. Try **Trust intercom / RECONNECT**, then confirm, for the breach ending. Let the timer expire to test the separate failure screen. Retry restores ready NPCs, open gates, clues, and a fresh inactive timer. New Game clears the checkpoint.
9. Optional clues are labeled **Voice warning** in security, **Incident note** in maintenance, and **Isolation protocol** in observation. E reads only the targeted book; J opens the list of collected notes to reread. Journal access is disabled during evacuation.

Exchanges wait until conversations and earlier subtitles finish. Each subtitle types out and remains for three seconds; radio labels allow story delivery while moving away. Evacuation uses a 120-second countdown and three-second shadow head start. One new-player playthrough took approximately 16 minutes; familiar-player runs took approximately five minutes.

## For the developer: edit, run, and export

### Engine and source setup

Use **Godot 4.7.2 Standard**, with **GDScript** and the **Compatibility** renderer. The .NET edition and SDK are unnecessary for this project. The professor's operating system is unknown; Windows x86_64 is the initial development target, not a confirmed submission platform.

1. Download the Windows x86_64 Standard editor from the [official Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/). Extract the ZIP into a tools folder and run the editor executable; no installer is required.
2. In Godot's Project Manager, choose **Import**, select `A1/game/project.godot`, and open the project.
3. Press **F6** to run the open scene or **F5** to run the project. The project displays the main menu. Choose Start or Facility tour; Escape opens the pause menu.
4. Edit `.gd` source files in VS Code and save them; return to Godot to run the project. A VS Code extension is optional, not a runtime dependency.

Local tooling, when downloaded by Codex, lives in the ignored `A1/.tools/` directory. It is not part of the submitted game or a required location on another computer. No additional art/audio downloads are needed for this baseline.

### Export a standalone build

Install the **matching 4.7.2 export templates** through Godot's **Editor > Manage Export Templates**. Under **Project > Export**, select the included **Windows Desktop** preset and export to `A1/builds/windows/Blackwell.exe`. Keep the companion `Blackwell.pck` file with the executable. On the current development machine, the matching Windows x86_64 templates are already installed.

Running the project with **F5** uses the current source. Launching `Blackwell.exe` uses the last exported version; export again after source changes to update it. The local M6 export is in `builds/windows/`, which is ignored by Git.

### Prepare the submission ZIP

After exporting, run `python A1/package_submission.py` from the repository root to rebuild and verify the candidate and its SHA-256 sidecar. This command packages the current export; it does not re-export Godot.

1. Confirm the professor's operating system and export the appropriate desktop build. Update the professor's launch instructions if the platform or file layout changes.
2. Include the `A1/` folder with this README, complete `game/` source, `builds/` executable and companion files, prompt log, credits and required licenses, and the documents linked below.
3. Exclude local `.tools/`, generated `game/.godot/` caches, and previous submission archives.
4. Extract the ZIP into a separate folder and follow the professor's instructions. Verify that all runtime files are present and the game works offline without development tools. Record the actual checks and any limitations in `docs/verification.md`.

The engine uses Compatibility rendering. A rendered automated Low/720p progression run averaged 118.7 FPS over 71.94 seconds on an i7-12650H / RTX 3050 Ti laptop. This uses scripted player relocations and real NPC traversal, not continuous human-route profiling. User playthroughs reported no blockers; another computer was unavailable. See the verification record for methodology and environment diagnostics.

## Deliverables

- [Actual prompt log](prompts.txt)
- [Asset credits](CREDITS.md)
- [Development summary](docs/development-summary.md)
- [Verification record](docs/verification.md)
- [Demonstration checklist](docs/demo-checklist.md)

Deadline: September 28, 2026, 7:00 a.m. US Central. The final ZIP contains source, Windows build, and documentation. Manual submission remains the user's responsibility; packaging and committing do not submit it.
