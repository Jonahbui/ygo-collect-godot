class_name CardOutline
extends Control

const ANIM_ZOOM_IN = "zoom_in"
const ANIM_ZOOM_OUT = "zoom_out"

onready var card_image : TextureButton = $Image
onready var card_name : RichTextLabel = $Name
onready var card_rarity : RichTextLabel = $Image/Rarity


func _ready() -> void:
  card_image.connect("mouse_entered", self, "_card_mouse_entered")
  card_image.connect("mouse_exited", self, "_card_mouse_exited")


func _card_mouse_entered():
  $AnimationPlayer.play(ANIM_ZOOM_IN)


func _card_mouse_exited():
  $AnimationPlayer.play(ANIM_ZOOM_OUT)


