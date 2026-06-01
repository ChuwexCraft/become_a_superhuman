extends Area2D



func _on_body_entered(body: CharacterBody2D) -> void:
	$Label.visible = true
	%Player.acquired_double_jump = true
	%Player.acquired_dash = true
	%Player/Camera2D.zoom = Vector2(2.0, 2.0)
	
