extends CanvasLayer

@onready var hp_bar: ProgressBar = $"HBoxContainer/HPBar"
@onready var mp_bar: ProgressBar = $"HBoxContainer/MPBar"

func update_hp(current: int, max: int) -> void:
    hp_bar.max_value = max
    hp_bar.value = clamp(current, 0, max)

func update_mp(current: int, max: int) -> void:
    mp_bar.max_value = max
    mp_bar.value = clamp(current, 0, max)