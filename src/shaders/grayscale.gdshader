shader_type canvas_item;

void fragment(){
  COLOR = texture(TEXTURE, UV);
  float c_linear = COLOR.r * 0.3 + COLOR.g * 0.6 * COLOR.b * 0.1;
  COLOR = vec4(
    c_linear ,
    c_linear ,
    c_linear,
    COLOR.a
   );
}
