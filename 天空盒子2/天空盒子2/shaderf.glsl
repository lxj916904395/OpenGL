//纹理坐标
varying lowp vec3 textureCoor;
//纹理贴图
uniform samplerCube cubmap;

void main(){
    gl_FragColor = textureCube(cubmap,textureCoor);
}
