
attribute vec4 position;
attribute vec2 textureCoordinate;

uniform mat4 modelviewMatrix;
uniform mat4 projectionMatrix;

varying lowp vec2 varyingTexture;

void main(){
    varyingTexture = textureCoordinate;
    
    vec4 pos = position * projectionMatrix * modelviewMatrix;
    gl_Position = pos;
}
