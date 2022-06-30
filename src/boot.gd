extends CanvasLayer

const card = preload("res://src/card.gd")
const set = preload("res://src/set.gd")

func _ready() -> void:
  $Control/Label.text = "Yu-Gi-Oh! Collect"
  yield(get_tree().create_timer(2, true), "timeout")
  var result = $Externals.download_data()
  if result is GDScriptFunctionState:
    result = yield(result, "completed")
  if result != OK:
    $Control/Label.text = "Error. Could not download necessary data."
  else:
    Info.generate_resources(Externals.CARD_SETS_PATH, Externals.CARD_INFO_PATH)

  get_tree().change_scene("res://scenes/Main.tscn")
