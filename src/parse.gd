class_name Parse
extends Node



static func read_json(path:String) -> JSONParseResult:
  var file = File.new()
  file.open(path, file.READ)
  var text = file.get_as_text()
  file.close()
  var parse := JSON.parse(text)
  if parse.error == OK:
    return parse
  else:
    return null
