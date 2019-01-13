
attribute vec3 position;

uniform mat4 mvpMatrix;

//纹理
uniform samplerCube textureCubeMap;


varying lowp vec3 textureCoordi;


void main(){
    textureCoordi = position;
    //修改顶点位置 = MVP矩阵 * 顶点
    //vec4(a_position, 1.0);表示将3维向量修改为4维向量
    gl_Position = mvpMatrix *vec4(position,1.0);
    
}
