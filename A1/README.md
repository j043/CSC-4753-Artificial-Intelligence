# Blackwell: Last Shift

A1 for CSC-4753 Artificial Intelligence. See [the specification](spec.md) for scope and acceptance criteria.

## Current status

M1 is implemented: six connected graybox areas, collision, walking/sprinting, mouse look, flashlight, inspectable props, two initially locked gates, and start/pause/resume menus. A separate Facility tour opens the gates for layout testing. NPCs, objective progression, settings, and endings remain planned. The user completed a walkthrough and approved the visuals; detailed control/edge-case checks remain open; the professor's operating system remains unconfirmed. See [verification](docs/verification.md) for actual test results.

## For the professor: run the submitted game

No Godot editor, VS Code, installation of development tools, accounts, API keys, or internet connection is required to play the packaged game.

### Launch

The current export targets **Windows x86_64**. The professor's operating system still needs confirmation before the final submission package is prepared.

1. Extract the entire submission ZIP into a writable folder. Do not run the executable from inside the ZIP viewer.
2. Open `A1/builds/windows/` inside the extracted submission.
3. Double-click **`Blackwell.exe`**. Keep **`Blackwell.pck`** in the same folder; it contains the game's packaged resources.
4. Select **Start - initial lockdown** to explore with the initial gates locked, or **Facility tour - gates open** to walk all six areas. Press Escape for Resume, Return to Menu, or Quit.

The final ZIP will include the executable, packaged resources, and any other required runtime files together. A final submission ZIP is not available yet. For the current local M1 build, open `builds/windows/` beside this README and launch the executable there. A source-only Git checkout does not include generated builds.

### Controls and graphics

Implemented: **WASD** walk, **mouse** look, hold **Shift** to sprint, **E** inspect the targeted object within 3 meters, **F** toggle flashlight, and **Escape** pause/resume. Menus support mouse and keyboard. Losing application focus pauses gameplay. The window opens at 1280×720.

There is no jumping, head bob, or camera shake. Settings (sensitivity, volume, brightness, low-quality preset, and resolution) arrive in M5. Gate A requires emergency power; Gate B requires power and security authorization. Those objectives arrive in M3. Facility tour is a development walkthrough, not completed story progression.

### Build verification

M1 automated checks exercise traversal, collision, gate locks, interaction range, flashlight toggling, pause, and new-run reset. See the verification record for export results and the hands-on checklist. Automated checks do not establish visual quality, real mouse/keyboard usability, or gameplay performance. See the [verification record](docs/verification.md) for details and the [demonstration checklist](docs/demo-checklist.md) for the planned assignment demonstration.

## For the developer: edit, run, and export

### Engine and source setup

Use **Godot 4.7.2 Standard**, with **GDScript** and the **Compatibility** renderer. The .NET edition and SDK are unnecessary for this project. The professor's operating system is unknown; Windows x86_64 is the initial development target, not a confirmed submission platform.

1. Download the Windows x86_64 Standard editor from the [official Godot 4.7.2 archive](https://godotengine.org/download/archive/4.7.2-stable/). Extract the ZIP into a tools folder and run the editor executable; no installer is required.
2. In Godot's Project Manager, choose **Import**, select `A1/game/project.godot`, and open the project.
3. Press **F6** to run the open scene or **F5** to run the project. The project displays the M1 menu. Choose Start or Facility tour; Escape opens the pause menu.
4. Edit `.gd` source files in VS Code and save them; return to Godot to run the project. A VS Code extension is optional, not a runtime dependency.

Local tooling, when downloaded by Codex, lives in the ignored `A1/.tools/` directory. It is not part of the submitted game or a required location on another computer. No additional art/audio downloads are needed for this baseline.

### Export a standalone build

Install the **matching 4.7.2 export templates** through Godot's **Editor > Manage Export Templates**. Under **Project > Export**, select the included **Windows Desktop** preset and export to `A1/builds/windows/Blackwell.exe`. Keep the companion `Blackwell.pck` file with the executable. On the current development machine, the matching Windows x86_64 templates are already installed.

Running the project with **F5** uses the current source. Launching `Blackwell.exe` uses the last exported version; export again after source changes to update it. The local M1 export is in `builds/windows/`, which is ignored by Git.

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
