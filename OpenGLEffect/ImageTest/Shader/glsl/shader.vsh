
attribute vec2 textureCoor;
attribute vec4 position;

varying vec2 vTextureCoord;
void main(){
    gl_Position =   position;
    vTextureCoord = textureCoor;
}
