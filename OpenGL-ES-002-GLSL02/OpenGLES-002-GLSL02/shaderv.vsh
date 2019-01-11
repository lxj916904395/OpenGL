
attribute vec4 position;
attribute vec2 textureCoodinate;

uniform mat4 rotMatrix;

varying lowp vec2 varyingTexture;


void main(void){
    varyingTexture = textureCoodinate;
    
    gl_Position = position* rotMatrix;
}
