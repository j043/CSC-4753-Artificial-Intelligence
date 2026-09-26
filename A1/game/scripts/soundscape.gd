extends Node
## Original synthesized facility hum and brief cues. All route through Master.
var hum: AudioStreamPlayer
var cue_player: AudioStreamPlayer
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
	hum.stream = tone(60, 1, 0.08, true)
	hum.volume_db = -22
	add_child(hum)
	hum.play()
	cue_player = AudioStreamPlayer.new()
	cue_player.volume_db = -16
	add_child(cue_player)
func cue(kind: String) -> void:
	cue_player.stream = tone(160 if kind == "door" else 660, 0.45 if kind == "door" else 0.2, 0.25)
	cue_player.play()
func _exit_tree() -> void:
	for audio in [hum, cue_player]:
		if is_instance_valid(audio):
			audio.stop()
			audio.stream = null
