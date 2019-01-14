//顶点坐标
attribute vec3 position;

//变换矩阵
uniform mat4 mvpMatrix;

//纹理坐标
varying lowp vec3 textureCoor;

uniform samplerCube textureCubeMap;


void main(){
    textureCoor = position;
    gl_Position = mvpMatrix * vec4(position,1);
}
