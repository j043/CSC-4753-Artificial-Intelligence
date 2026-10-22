extends RefCounted
var path := "user://settings.cfg"
var sensitivity := 1.0
var volume := 0.8
var brightness := 1.0
var low := false
var resolution := 0
const SIZES := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	sensitivity = clampf(float(config.get_value("settings", "sensitivity", 1.0)), 0.25, 2.5)
	volume = clampf(float(config.get_value("settings", "volume", 0.8)), 0, 1)
	brightness = clampf(float(config.get_value("settings", "brightness", 1.0)), 0.6, 1.6)
	low = bool(config.get_value("settings", "low", false))
	resolution = clampi(int(config.get_value("settings", "resolution", 0)), 0, 2)
func save_settings() -> Error:
	var config := ConfigFile.new()
	for key in ["sensitivity", "volume", "brightness", "low", "resolution"]:
		config.set_value("settings", key, get(key))
	return config.save(path)
func apply(app: Control, resize := false) -> void:
	AudioServer.set_bus_volume_linear(0, volume)
	if resize and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(SIZES[resolution])
	if is_instance_valid(app.player):
		app.player.sensitivity = 0.0023 * sensitivity
		app.player.light.shadow_enabled = not low
	if is_instance_valid(app.world):
		for child in app.world.get_children():
			if child is WorldEnvironment:
				child.environment.ambient_light_energy = app.world.AMBIENT_ENERGY * brightness
			elif child is OmniLight3D:
				child.shadow_enabled = false
