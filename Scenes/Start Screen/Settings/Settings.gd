extends VBoxContainer

onready var _soundtrack: AudioStreamPlayer = $"/root/Soundtrack"

onready var _music_label = $"Music Volume/Value"
onready var _music_slider = $"Music Volume/Slider"
onready var _soundfx_label = $"Sound FX/Value"

func _ready() -> void:
	_music_slider.value = Settings.volume_percent
	if (Settings.volume_percent == 0):
		_music_label.text = "OFF"
	else:
		_music_label.text = str(Settings.volume_percent) + "%"


func _on_MusicSlider_changed(value : float) -> void:
	Settings.volume_percent = value	
	if value == 0:
		_soundtrack.playing = false
		_music_label.text = "OFF"
	else:
		if not _soundtrack.playing:
			_soundtrack.playing = true
		_music_label.text = str(value) + "%"	
		_soundtrack.volume_db = _set_volume_from_percent(value)

func _on_SFX_Slider_changed(value: float) -> void:
	if value == 0:
		_soundfx_label.text = "OFF"	
		for sound in Sounds.get_all_sounds():
			sound.volume_db = -80
	else:
		_soundfx_label.text = str(value) + "%"
		for sound in Sounds.get_all_sounds():
			sound.volume_db = _set_volume_from_percent(value)		

func _set_volume_from_percent(percent: int) -> float:
	return (0 - (100 - percent)) * 0.2



