extends Node
## Authoritative monotonic objectives; all effects are prerequisite guarded.
var app: Control
var stage := 1
var component := "available"
var met: Array[String] = []
var pending: Array[String] = []
var completed: Array[String] = []
var active := ""
var line_index := 0
var warning_known := false
const HINTS := [
	"Meet Mara and Eli in security. Talk to both about the lockdown.",
	"Retrieve the replacement component: maintenance workbench, east of control.",
	"Ask Mara to restore power. She needs to reach the maintenance station.",
	"Ask Eli to authorize observation access at the control-room station.",
	"Assign both survivors to isolation stations in observation; use the chamber console.",
	"Return through control and security to the western lift. Both survivors must board.",
	"Evacuation complete."
]
const EXCHANGES := {
	"briefing": ["Mara Voss [radio]: The supply failed. I can repair it with the spare from maintenance.", "Eli Ward [radio]: I'll handle access. Maintenance is east of control; bring that component back."],
	"access": ["Mara Voss [radio]: Emergency power is stable. Your security panel should respond.", "Eli Ward [radio]: Confirmed. Authorizing observation access now."],
	"warning": ["Intercom (Mara's voice): Reconnect the chamber. I'm waiting inside.", "Mara Voss [radio]: That wasn't me. I'm outside the chamber. Trust the physical controls.", "Eli Ward [radio]: Something is copying us. Keep the chamber sealed; use isolation."]
}

func hint() -> String:
	return HINTS[stage - 1] + (" Voices can be imitated; trust the survivors." if warning_known and stage == 5 else "")

func meet(npc: CharacterBody3D) -> void:
	if npc.person not in met:
		met.append(npc.person)
	if met.size() == 2 and stage == 1:
		stage = 2
		queue_exchange("briefing")

func queue_exchange(id: String) -> void:
	if id not in pending and id not in completed and active != id:
		pending.append(id)

func ready_for(npc: CharacterBody3D, task: String) -> bool:
	return npc.task_ready and npc.state == "perform_task" and npc.task_id == task and npc.position.distance_to(npc.destination) < 0.6

func command_reason(npc: CharacterBody3D, order: String) -> String:
	if stage == 6 and order != "evacuate":
		return "We must board the lift. I'm heading there now."
	if order in ["repair", "station"]:
		if npc.engineer and stage != 3:
			return "I need the replacement component first." if stage < 3 else "Power is already restored. Assign my isolation station next."
		if not npc.engineer and stage != 4:
			return "Power must be restored before authorization." if stage < 4 else "Access is already open. Assign my isolation station next."
	if order == "isolation" and stage != 5:
		return "No reachable route to isolation until power and security access are complete."
	return ""

func interact(target: Object) -> void:
	var id: String = target.get_meta("object_id", "")
	match id:
		"Maintenance workbench":
			if stage == 2 and component == "available":
				component = "held"
				stage = 3
				target.set_meta("prompt", "Inspect empty component tray")
				app.show_notice("Replacement component collected. " + hint())
			else:
				app.show_notice(("Not collected. Speak to both Mara and Eli first." if stage == 1 else "Component: " + component + ". " + hint()))
		"Chamber control console":
			var missing := isolation_missing()
			if missing != "":
				app.show_notice("Isolation unavailable: " + missing)
			elif stage == 5:
				app.narrative.save_checkpoint()
				app.show_decision()
		"Lift call panel":
			if stage != 6:
				app.show_notice("Lift unavailable. " + hint())
			elif app.narrative.remaining <= 0:
				app.show_outcome("EVACUATION FAILED", "The evacuation window closed. Retry the checkpoint.")
			elif not ready_for(app.world.npcs[0], "evacuate") or not ready_for(app.world.npcs[1], "evacuate"):
				app.show_notice("Waiting for Mara and Eli to board. Clear their route to the lift.")
			else:
				stage = 7
				app.show_success()
		"Control console":
			app.show_notice(hint())
		_:
			app.show_notice(str(target.get_meta("message", hint())))

func isolation_missing() -> String:
	if stage != 5:
		return hint()
	var missing: Array[String] = []
	if not ready_for(app.world.npcs[0], "isolation"):
		missing.append("Mara must hold the maintenance panel")
	if not ready_for(app.world.npcs[1], "isolation"):
		missing.append("Eli must hold the security override")
	return "; ".join(missing)

func readiness() -> String:
	if stage != 5:
		return ""
	return "Mara: %s | Eli: %s | You: chamber console" % ["READY" if ready_for(app.world.npcs[0], "isolation") else "NOT READY", "READY" if ready_for(app.world.npcs[1], "isolation") else "NOT READY"]

func tick() -> void:
	var mara = app.world.npcs[0]
	var eli = app.world.npcs[1]
	if stage == 3 and component == "held" and (ready_for(mara, "station") or ready_for(mara, "repair")):
		component = "consumed"
		stage = 4
		app.world.unlock_gate(0)
		mara.say("Power restored. Gate A is open; ask Eli to authorize access.")
	if stage == 4 and (ready_for(eli, "station") or ready_for(eli, "repair")):
		queue_exchange("access")
	if stage == 5 and app.player.position.z < -20:
		queue_exchange("warning")
	if stage == 6 and app.world.navigation_ready:
		for npc in app.world.npcs:
			if npc.state == "wait" or npc.task_id != "evacuate":
				npc.command("evacuate")
	if app.mode != "play" or not app.notice.text.is_empty() or not app.notice_queue.is_empty():
		return
	if active == "" and not pending.is_empty():
		active = pending.pop_front()
		line_index = 0
	if active != "":
		if active == "access" and not (ready_for(eli, "station") or ready_for(eli, "repair")):
			active = ""
			return
		if line_index < EXCHANGES[active].size():
			app.show_notice(EXCHANGES[active][line_index])
			app.notice_is_exchange = true
			if active == "access" and line_index == 1:
				app.world.unlock_gate(1)
			line_index += 1
		else:
			completed.append(active)
			if active == "briefing":
				stage = maxi(stage, 2)
			elif active == "access":
				stage = 5
			elif active == "warning":
				warning_known = true
			active = ""
