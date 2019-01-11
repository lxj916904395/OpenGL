
uniform mat4 projectionMatrix;//投影矩阵
uniform mat4 modelviewMatrix;//模型视图矩阵

attribute vec4 position;
attribute vec2 textureCoordinate;//纹理坐标

varying lowp vec2 varyingCoordinate;

void main(){
    
    varyingCoordinate = textureCoordinate;
    
    
    vec4 vPos;
    vPos = projectionMatrix * modelviewMatrix * position;
    gl_Position = vPos;
}
