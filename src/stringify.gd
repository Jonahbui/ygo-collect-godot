class_name Stringify
extends Reference

static func ellipse(string:String, max_length:int=40):
  if string.length() > max_length:
    return string.substr(0, max_length-3) + '...'
  else:
    return string
  
