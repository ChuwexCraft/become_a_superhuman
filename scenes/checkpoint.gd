extends Area2D

var has_taken = false
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

	


func _on_area_entered(area: Area2D) -> void:
	if has_taken == false:
		sprite_2d.visible = false
		has_taken = true
		#play sopund
