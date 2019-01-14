//顶点坐标
attribute vec3 position;
//变换矩阵
uniform mat4 mvpMatrix;
//纹理贴图
uniform samplerCube textureCubeMap;
//纹理坐标
varying lowp vec3 textureCoordi;
void main(){
    textureCoordi = position;
    //修改顶点位置 = MVP矩阵 * 顶点
    //vec4(a_position, 1.0);表示将3维向量修改为4维向量
    gl_Position = mvpMatrix *vec4(position,1.0);
}
