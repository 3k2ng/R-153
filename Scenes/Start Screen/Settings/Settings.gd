extends Control

onready var _soundtrack: AudioStreamPlayer = $"/root/Soundtrack"

onready var _music_label = $"Music Volume/Value"

func _ready() -> void:
	pass


func _on_MusicSlider_changed(value : float) -> void:
	_music_label.text = str(value) + "%"
	if value == 0:
		_soundtrack.playing = false
	else:
		if not _soundtrack.playing:
			_soundtrack.playing = true
		_soundtrack.volume_db = (0 - (100 - value)) * 0.2
