class_name CardSet
extends Control

const IMAGE_DB_URL := "https://storage.googleapis.com/ygoprodeck.com/pics"

onready var grid = $List/Scroll/Grid
onready var card_template = $List/Scroll/Grid/Card

var cards := []


func _ready() -> void:
  get_tree().connect("screen_resized", self, "window_size_changed")
  $HTTPRequest.connect("request_completed", self, "request_completed")


func form_set(set:Dictionary, cards:Array) -> void: 
  $List/SetName.text = set.set_name
  $List/Info/CardsInSet.text = str(set.num_of_cards)
  
  if cards.size() > self.cards.size():
    for i in range (0, cards.size() - self.cards.size()):
      var new_card = card_template.duplicate()
      grid.call_deferred("add_child", new_card)
      self.cards.append(new_card)
  elif cards.size() < self.cards.size():
    for i in range(0, self.cards.size()):
      self.cards[i].hide()
  
  var file := File.new()
  
  for i in range(0, cards.size()):
    var new_card = self.cards[i]
    
    var card_image_id = cards[i].card_images[0].id
    var image_path = "user://images/%s.jpg" % [card_image_id]
    if not file.file_exists(image_path):
      $HTTPRequest.set_download_file(image_path)
      $HTTPRequest.request("%s/%s.jpg" % [IMAGE_DB_URL, card_image_id])
      yield($HTTPRequest, "request_completed")
    
    var card_image : TextureButton = new_card.get_node("Image")
    var image = Image.new()
    var error = image.load(image_path)
    if error != OK:
      print("Error loading image.")
    else:
      var texture = ImageTexture.new()
      texture.create_from_image(image, 0)
      card_image.texture_normal = texture
    var card_name : RichTextLabel = new_card.get_node("Name")
    
    card_name.text = cards[i].name
    new_card.show()

func window_size_changed():
  var card_x = int(card_template.rect_size.x)
  var grid_pad_x = grid.get_constant("hseparation")
  var margin_x = get_constant("margin_left") + get_constant("margin_right")
  var window_x = OS.window_size.x - margin_x
  
  # NOTE: formula for the number of columns needed to fill in the grid
  # n = floor((z + y)/(x + y))
  # where
  # n : the number of columns needed to fill a grid
  # z : the x-size of the grid
  # y : the x-size of the padding between each elemennt in the grid
  # x : the x-size of the element in the grid
  grid.columns = int(floor((window_x + grid_pad_x) / (card_x + grid_pad_x)))


func request_completed(result, response_code, headers, body):
  print(result)
  print(response_code)
#  var json = JSON.parse(body.get_string_from_utf8())
#  print(json.result)
