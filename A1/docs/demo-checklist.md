# Demonstration checklist

All gameplay demonstrations are pending implementation.

- [ ] Launch the extracted standalone desktop package.
- [ ] Show named player-to-NPC dialogue and meaningful choices with both survivors.
- [ ] Command each survivor to follow, wait, and perform a role-specific task.
- [ ] Show alternating NPC-to-NPC dialogue and its observable action/hint effect.
- [ ] Show premature puzzle feedback, then player/Mara/Eli cooperation.
- [ ] Show the final decision and an ending.
- [ ] Retry the checkpoint, show the other ending and countdown failure.
- [ ] Show pause/settings, clues, and New Game reset.

Add exact routes, dialogue options, and build ID when these behaviors exist.

## M1 walkthrough (development build)

- Start with initial lockdown; demonstrate WASD/mouse, Shift sprint, F flashlight, E inspection and the Gate A explanation.
- Escape to pause; Resume, then Return to Menu.
- Choose Facility tour and visit security, control, maintenance, coolant, chamber observation and evacuation lift. Inspect each room's landmark/panel and return to security.
- Start a fresh lockdown run to confirm gates reset, then Quit.
- NPCs, dialogue, cooperative objectives, scripted horror, and endings remain later milestones. Record manual results in `verification.md`.

## M2 interaction walkthrough (development build)

- Use E to talk with each survivor. Show the short hint, larger text and horizontal options; optional questions are under Help me with something. Escape closes any dialogue page.
- Give both Follow commands; each conversation closes immediately. Walk to control/maintenance, turn around while stationary, and verify followers remain approachable. Demonstrate Wait and Follow again.
- Under Help, assign Inspect your station and observe travel/arrival. Interrupt and reassign one task.
- In Facility tour, use Help to send both survivors to their isolation stations.
- Show typed bottom-screen acknowledgements: each completed line remains for five seconds, then disappears; overlapping lines queue.
- Escape closes dialogue first; another press pauses gameplay. Pause during travel to verify freezing. Losing application focus during dialogue still pauses safely and preserves the conversation.
- Obstruct an NPC, clear the path, and reassign after its recovery message. Power/gate objectives, NPC exchanges and cooperative effects remain M3.

## M3 playable walkthrough

- Speak to both survivors, close dialogue, and read the automatic briefing.
- Collect the component at the maintenance workbench; try repeated collection.
- Assign Mara's repair, interrupt with Wait, and reassign. Confirm Gate A opens.
- Assign Eli's authorization and watch his exchange open Gate B.
- Enter coolant for the false voice and both survivors' responses; request guidance afterward.
- Try chamber control early. Assign both isolation stations, cancel one, retry, and inspect the missing-participant explanation.
- Reassign, isolate, and return to the lift with both survivors. Activate the panel for success.
- Start a new game and confirm initial gates, component, objectives, and NPCs reset.
- M4 decision/countdown/checkpoint and alternate ending are not in this skeleton.

## M4 demonstration

- Read one optional note in security, maintenance, and observation; press J to reread.
- Restore power/access, enter coolant for lights and imitation responses, then approach the observation window facing north for the silhouette.
- Assign both stations and activate the console. Show the saved checkpoint and conflicting advice.
- Choose reconnect, confirm, and read the breach consequence.
- Retry, choose isolate, inspect the countdown/alarm, pause and verify timer freeze; test volume/mute.
- Evacuate with both NPCs and activate the lift for the successful containment ending.
- Retry again, deliberately time out, and retry from failure. Verify fresh timer, ready NPCs, open gates, and retained notes.
- New Game must clear notes, events, checkpoint, objectives, and NPC commands.

## M5 checks

- Open Settings from main menu and pause. Adjust sensitivity, volume/mute, brightness, Low quality, and resolution. Restart the executable and confirm persistence.
- Pause during NPC dialogue, open Settings, return, then Resume. Confirm dialogue/input mode is preserved.
- During evacuation open Settings and confirm countdown stays frozen.
- Listen for quiet machinery hum, gate cue, objective cue, and alarm; confirm mute silences all.
- Extract the Windows playtest ZIP to a separate folder and launch with the included PCK and license notices.

## Shadow / art playtest

- Explore while watching corridors for brief random silhouettes; they cannot kill before isolation.
- Inspect new NPC faces/clothing/animation, instruments, coolant machinery, workshop, and reactor view.
- Isolate, sprint to the lift, and wait safely for survivors.
- Retry and deliberately let the shadow catch you; retry from YOU DIED. Pause mid-chase and verify it stops.
- Reconnect for the alternate ending; verify no pursuit starts.

## Latest presentation / access checks

- Compare flashlight on/off; adjust brightness if needed for the target display.
- Check the title logo and Mara/Eli models, including Mara's long hair.
- Try entering maintenance before introductions, after one introduction, and after speaking to both survivors. Repeat in the opposite order on a new game.
- Read two floor books: each pickup must display only that book. Press J separately to browse collected notes.
- Refresh the final submission archive from the latest Windows EXE/PCK; the older standalone M5 ZIP does not contain these follow-ups.