# Blackwell: Last Shift

A1 for CSC-4753 Artificial Intelligence. See [the specification](spec.md) for scope and acceptance criteria.

## Current status

M4 now adds the final trust decision, two consequence-based endings, a 120-second evacuation countdown, timeout failure, and a repeatable checkpoint at the chamber console. Three optional notes can be reread with J. Scripted events include a brief window figure, the imitated voice with survivor responses, gallery lighting failure, and the containment alarm. The user successfully played the M3 flow; M4 has automated and rendered-screen checks but awaits a user playthrough. Full presentation, persistent settings, profiling, and final packaging remain M5/M6 work.

## For the professor: run the submitted game

No Godot editor, VS Code, installation of development tools, accounts, API keys, or internet connection is required to play the packaged game.

### Launch

The current export targets **Windows x86_64**. The professor's operating system still needs confirmation before the final submission package is prepared.

1. Extract the entire submission ZIP into a writable folder. Do not run the executable from inside the ZIP viewer.
2. Open `A1/builds/windows/` inside the extracted submission.
3. Double-click **`Blackwell.exe`**. Keep **`Blackwell.pck`** in the same folder; it contains the game's packaged resources.
4. Select **Start - initial lockdown** to explore with the initial gates locked, or **Facility tour - gates open** to walk all six areas. Press Escape for Resume, Return to Menu, or Quit.

The final ZIP will include the executable, packaged resources, and any other required runtime files together. A final submission ZIP is not available yet. For the current local M4 build, open `builds/windows/` beside this README and launch the executable there. A source-only Git checkout does not include generated builds.

### Controls and graphics

Implemented: **WASD** walk, **mouse** look, hold **Shift** to sprint, **E** inspect or talk to the targeted object/NPC within 3 meters, **F** toggle flashlight, and **Escape** pause/resume, and **J** reread collected notes before evacuation. Menus support mouse and keyboard. Losing application focus pauses gameplay. The window opens at 1280×720.

There is no jumping, head bob, or camera shake. The pause menu has a master-volume slider, including mute. Full persistent settings (sensitivity, brightness, quality, and resolution) arrive in M5. Gate A requires emergency power; Gate B requires power and security authorization. Both gates now unlock through those objectives. Facility tour is a development walkthrough, not completed story progression.

### Talk to Mara and Eli

Both survivors start in security. Aim at one and press **E**. Each NPC immediately explains the situation, their role, and the current next step. Three horizontal choices provide **Follow me / Wait here**, the current **role task**, and optional **More context**. There are no nested question menus; More context gives one short explanation with Back.

Escape closes the conversation. Commands close it immediately so the NPC can act. New interactions replace current bottom feedback and clear stale queued acknowledgements. The new line types out, stays for three seconds, then disappears. Interrupted story-exchange lines resume afterward so essential information is retained. Spontaneous NPC lines still serialize when no new interaction replaces them.

Followers track your movement, not your facing direction. Once they stop near you, turning around leaves them in place so you can talk. If someone reports a blocked route, clear the obstruction and speak to them again to follow or reassign. Escape closes an open conversation and restores gameplay. Press Escape again to pause. Losing application focus still pauses safely; Resume then returns to the conversation.

### Build verification

All 29 M1, 46 M2, 29 M3, and 37 M4 checks pass, covering navigation, dialogue input modes, follow/wait, station arrival, interruption, recovery, and gate connectivity. See the verification record for export results and the hands-on checklist. Automated checks do not establish visual quality, real mouse/keyboard usability, or gameplay performance. See the [verification record](docs/verification.md) for details and the [demonstration checklist](docs/demo-checklist.md) for the planned assignment demonstration.

### M4 playthrough

1. Talk to Mara and Eli in security. Close dialogue with Escape and read their briefing across the bottom.
2. Walk north to control, then east into maintenance. Use E on the workbench to collect the component.
3. Talk to Mara: Restore power. Follow her to maintenance; her arrival consumes the component and opens Gate A.
4. Ask Eli to authorize observation access. He goes to control; his radio confirmation opens Gate B.
5. Enter coolant and read the imitation warning. Ask both survivors to go to their isolation stations in observation. You can use Follow me to bring survivors along before assigning stations.
6. Check both READY indicators, then use E on the chamber console. This saves an in-memory checkpoint and presents the trust decision. Early attempts explain who is missing; Wait cancels readiness and reassignment restores it.
7. Choose **Trust survivors / ISOLATE** to start the alarm and 120-second countdown. Return south through coolant/control/security and west to the lift. Both survivors must board before you activate the lift.
8. Use **Retry Checkpoint** from an ending/failure screen or **Restart Checkpoint** from pause. Try **Trust intercom / RECONNECT**, then confirm, for the breach ending. Let the timer expire to test the separate failure screen. Retry restores ready NPCs, open gates, clues, and a fresh inactive timer. New Game clears the checkpoint.
9. Optional clues are labeled **Voice warning** in security, **Incident note** in maintenance, and **Isolation protocol** in observation. E reads them; J reopens collected notes. Journal access is disabled during evacuation.

Exchanges wait until conversations and earlier subtitles finish. Each subtitle types out and remains for three seconds; radio labels allow story delivery while moving away. The 120-second countdown is provisional; the final 15-25 minute first-playthrough target is not yet verified.

## For the developer: edit, run, and export

### Engine and source setup

Use **Godot 4.7.2 Standard**, with **GDScript** and the **Compatibility** renderer. The .NET edition and SDK are unnecessary for this project. The professor's operating system is unknown; Windows x86_64 is the initial development target, not a confirmed submission platform.

1. Download the Windows x86_64 Standard editor from the [official Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/). Extract the ZIP into a tools folder and run the editor executable; no installer is required.
2. In Godot's Project Manager, choose **Import**, select `A1/game/project.godot`, and open the project.
3. Press **F6** to run the open scene or **F5** to run the project. The project displays the M4 menu. Choose Start or Facility tour; Escape opens the pause menu.
4. Edit `.gd` source files in VS Code and save them; return to Godot to run the project. A VS Code extension is optional, not a runtime dependency.

Local tooling, when downloaded by Codex, lives in the ignored `A1/.tools/` directory. It is not part of the submitted game or a required location on another computer. No additional art/audio downloads are needed for this baseline.

### Export a standalone build

Install the **matching 4.7.2 export templates** through Godot's **Editor > Manage Export Templates**. Under **Project > Export**, select the included **Windows Desktop** preset and export to `A1/builds/windows/Blackwell.exe`. Keep the companion `Blackwell.pck` file with the executable. On the current development machine, the matching Windows x86_64 templates are already installed.

Running the project with **F5** uses the current source. Launching `Blackwell.exe` uses the last exported version; export again after source changes to update it. The local M4 export is in `builds/windows/`, which is ignored by Git.

### Prepare the submission ZIP

1. Confirm the professor's operating system and export the appropriate desktop build. Update the professor's launch instructions if the platform or file layout changes.
2. Include the `A1/` folder with this README, complete `game/` source, `builds/` executable and companion files, prompt log, credits and required licenses, and the documents linked below.
3. Exclude local `.tools/`, generated `game/.godot/` caches, and previous submission archives.
4. Extract the ZIP into a separate folder and follow the professor's instructions. Verify that all runtime files are present and the game works offline without development tools. Record the actual checks and any limitations in `docs/verification.md`.

The engine uses Compatibility rendering. Performance and full gameplay acceptance testing remain future work; packaging alone does not establish those checks have passed.

## Deliverables

- [Actual prompt log](prompts.txt)
- [Asset credits](CREDITS.md)
- [Development summary](docs/development-summary.md)
- [Verification record](docs/verification.md)
- [Demonstration checklist](docs/demo-checklist.md)

Deadline: September 28, 2026, 7:00 a.m. US Central. Final source, exported build, and documentation will be packaged in a ZIP for manual submission.
