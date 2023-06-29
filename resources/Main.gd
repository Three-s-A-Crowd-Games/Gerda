extends Node
class_name Main

enum Scene {
	START,
	OPTION,
	CREDIT,
	CHARACTER_SELECT,
	GAME_OVER,
	GAME,
	VICTORY
}

enum Character {
	MOLE,
	BADGER
}

var character :Character


var scene_dict := {
	Scene.START : preload("res://resources/menus/StartMenu.tscn"),
	Scene.OPTION : preload("res://resources/menus/OptionsMenu.tscn"),
	Scene.CREDIT : preload("res://resources/menus/CreditsScreen.tscn"),
	Scene.CHARACTER_SELECT : preload("res://resources/menus/CharacterSelectScreen.tscn"),
	Scene.GAME_OVER : preload("res://resources/menus/GameOverScreen.tscn"),
	Scene.GAME : preload("res://resources/levels/GameWorld.tscn"),
	Scene.VICTORY : preload("res://resources/menus/VictoryScreen.tscn")
}

var current_scene: Node

@onready var canvas_layer := $CanvasLayer

func _ready():
	on_switch_scene(Scene.START)
	ready.connect(create_level)

func create_level():
	self.add_child(load("res://resources/levels/StartMenuLevel.tscn").instantiate())

func on_switch_scene(scene: Scene) -> void:
	if current_scene != null:
		if scene != Scene.START:
			$Level.visible = false
			$Level/CanvasModulate.visible = false
		elif scene == Scene.START and not is_instance_valid($Level):
			self.add_child(load("res://resources/levels/StartMenuLevel.tscn").instantiate())
			var tweeny = self.create_tween()
			$Level/CanvasModulate.visible = false
			tweeny.tween_property($Level/CanvasModulate, "visible", true, 0.01)
		else:
			var tweeny = self.create_tween()
			# To actually have it active again
			tweeny.tween_property($Level/CanvasModulate, "visible", true, 0.01)
			$Level.visible = true
			if not $Level/Enemies/SpecialSpider/Camera2D.is_current():
				$Level/Enemies/SpecialSpider/Camera2D.make_current()
		current_scene.queue_free()
	current_scene = scene_dict[scene].instantiate()
	if current_scene.has_signal("switch_scene"):
		current_scene.switch_scene.connect(on_switch_scene)
	if current_scene.has_signal("character_selected"):
		current_scene.character_selected.connect(on_character_selected)
	if scene == Scene.GAME:
		MutatorManager.reset_mutators()
		setup_game_world()
		return
	canvas_layer.add_child(current_scene)

func on_character_selected(character: Character) -> void:
	self.character = character
	$Level.queue_free()
	on_switch_scene(Scene.GAME)
	

func setup_game_world() -> void:
	var player: Player = current_scene.get_node("Player")	
	match character:
		Character.MOLE:
			player.set_script(load("res://resources/entity/player/Mole.gd"))
		Character.BADGER:
			assert(false, "badger is not playable yet")
	add_child(current_scene)

