extends CanvasLayer

const card = preload("res://src/card.gd")
const set = preload("res://src/set.gd")

func _ready() -> void:
  self.call_deferred("start")


func start() -> void:
  # Create directories to store ygo data, ygo images, and resources
  yield(get_tree().create_timer(.1), "timeout")
  $Control/Label.text = "Creating directories"
  var dir = Directory.new()
  dir.open("user://")
  dir.make_dir("data")
  dir.make_dir("images")
  dir.make_dir("resources")
  $Control/ProgressBar.value += 10
  
  # Download db info
  var file := File.new()
  if not file.file_exists(Externals.CHECK_DB_VERSION_PATH):
    $HTTPRequest.set_download_file(Externals.CHECK_DB_VERSION_PATH)
    $HTTPRequest.request(Externals.CHECK_DB_VERSION_URL)
    var response = yield($HTTPRequest, "request_completed")
    var response_code = response[1]
    if response_code != 200:
      print("Error.")
  else:
    print("Card info file found.")
  
  # Download card info 
  if not file.file_exists(Externals.CARD_INFO_PATH):
    $HTTPRequest.set_download_file(Externals.CARD_INFO_PATH)
    $HTTPRequest.request(Externals.CARD_INFO_URL)
    var response = yield($HTTPRequest, "request_completed")
  else:
    print("Card info file found.")
  
  # Download card sets
  if not file.file_exists(Externals.CARD_SETS_PATH):
    $HTTPRequest.set_download_file(Externals.CARD_SETS_PATH)
    $HTTPRequest.request(Externals.CARD_SETS_URL)
    var response = yield($HTTPRequest, "request_completed")
  else:
    print("Card sets file found.")
  
  # Generate card set resources
  yield(get_tree().create_timer(.1), "timeout")
  $Control/Label.text = "Generating card sets"
  var set_parse = Parse.read_json("user://data/cardsets.php")
  $Control/ProgressBar.value += 10
  if set_parse:
    # TODO: turn to resource
    # cardsets = set_parse.result
    #cardsets.sort_custom(self, "sort_by_date_desc")
    #form_cardsets(cardsets)
    pass
  else:
    # TODO: show error
    print("Error.")
  
  # Generate card info resources
  yield(get_tree().create_timer(.1), "timeout")
  $Control/Label.text = "Generating cards"
  var all_cards_parse = Parse.read_json("user://data/cardinfo.php")
  $Control/ProgressBar.value += 10
  if all_cards_parse:
    pass
    # cards = all_cards_parse.result["data"]
  else:
    print("Error.")
  
  
