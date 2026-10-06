extends Node
## Original synthesized facility hum and brief cues. All route through Master.
var hum: AudioStreamPlayer
var cue_player: AudioStreamPlayer
var footsteps: AudioStreamPlayer
var step_count := 0
static var ambient_wave: AudioStreamWAV
static var step_wave: AudioStreamWAV

static func atmosphere() -> AudioStreamWAV:
	if ambient_wave:
		return ambient_wave
	ambient_wave = AudioStreamWAV.new()
	ambient_wave.mix_rate = 22050
	ambient_wave.format = AudioStreamWAV.FORMAT_16_BITS
	var count := 22050 * 8
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / 22050
		var breath := 0.5 - 0.5 * cos(TAU * t / 8)
		var drone := sin(TAU * 48 * t) * 0.20 + sin(TAU * 60 * t) * 0.12
		var uneasy := (sin(TAU * 143.125 * t) + sin(TAU * 149.375 * t)) * 0.065 * breath
		var whisper := sin(TAU * 721 * t + 3 * sin(TAU * 17 * t)) * 0.025 * breath
		data.encode_s16(i * 2, int((drone + uneasy + whisper) * 32767))
	ambient_wave.data = data
	ambient_wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambient_wave.loop_end = count
	return ambient_wave

static func footstep() -> AudioStreamWAV:
	if step_wave:
		return step_wave
	step_wave = AudioStreamWAV.new()
	step_wave.mix_rate = 22050
	step_wave.format = AudioStreamWAV.FORMAT_16_BITS
	var count := 6615
	var data := PackedByteArray()
	data.resize(count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = 4753
	for i in count:
		var t := float(i) / 22050
		var attack := minf(t / 0.003, 1.0)
		var thud := sin(TAU * 82 * t) * exp(-t * 28) * 0.55
		var scuff := random.randf_range(-1, 1) * exp(-t * 55) * 0.25
		var ring := sin(TAU * 310 * t) * exp(-t * 18) * 0.08
		data.encode_s16(i * 2, int((thud + scuff + ring) * attack * 32767))
	step_wave.data = data
	return step_wave

func step(sprinting: bool) -> void:
	step_count += 1
	footsteps.pitch_scale = 0.94 if step_count % 2 == 0 else 1.06
	footsteps.volume_db = -9 if sprinting else -13
	footsteps.play()
static func tone(frequency: float, duration: float, gain: float, looping := false) -> AudioStreamWAV:
	var wave := AudioStreamWAV.new()
	wave.mix_rate = 22050
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	var count := int(22050 * duration)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var envelope := 1.0 if looping else sin(PI * float(i) / count)
		data.encode_s16(i * 2, int(sin(TAU * frequency * i / 22050.0) * 32767 * gain * envelope))
	wave.data = data
	if looping:
		wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wave.loop_end = count
	return wave
func _ready() -> void:
	hum = AudioStreamPlayer.new()
	hum.stream = atmosphere()
	hum.volume_db = -20
	add_child(hum)
	hum.play()
	cue_player = AudioStreamPlayer.new()
	cue_player.volume_db = -16
	add_child(cue_player)
	footsteps = AudioStreamPlayer.new()
	footsteps.stream = footstep()
	add_child(footsteps)
func cue(kind: String) -> void:
	cue_player.stream = tone(160 if kind == "door" else 660, 0.45 if kind == "door" else 0.2, 0.25)
	cue_player.play()
func _exit_tree() -> void:
	for audio in [hum, cue_player, footsteps]:
		if is_instance_valid(audio):
			audio.stop()
			audio.stream = null
