extends Area2D


func _on_body_entered(body: CharacterBody2D) -> void:
	$Label.visible = true
	$%Player.acquired_dash = true
	
