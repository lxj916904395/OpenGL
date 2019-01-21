//顶点坐标
attribute vec4 position;

//纹理坐标
attribute vec2 textureCoordinate;


varying lowp vec3 varyingCoord;

void main(){
    varyingCoord = textureCoordinate;
    gl_Position = position;
}
