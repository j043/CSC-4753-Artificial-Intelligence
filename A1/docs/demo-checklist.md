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
