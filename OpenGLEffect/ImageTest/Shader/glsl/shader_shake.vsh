
attribute vec2 textureCoor;
attribute vec4 position;

uniform mat4 mvpMatrix;

varying vec2 vTextureCoord;
void main(){
    gl_Position =  mvpMatrix *  position;
    vTextureCoord = textureCoor;
}
