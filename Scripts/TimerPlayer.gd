class_name TurnTimer extends Timer
@export var timer_ui : Label

func _ready() -> void:
	GameManager.StartTurn.connect(func(): start())
	

func _process(delta: float) -> void:
	timer_ui.text = "%.1f" % time_left


func _on_timeout() -> void:
	GameManager.end_turn.rpc()
