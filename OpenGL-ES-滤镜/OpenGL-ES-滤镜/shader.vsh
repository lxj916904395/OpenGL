
attribute vec4 position;

//纹理坐标
uniform vec2 textureCoordinate;

varying lowp vec3 varyingCoord;

void main(){
    varyingCoord = textureCoordinate;
    gl_Position = position;
}
