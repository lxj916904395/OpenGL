//纹理坐标
varying lowp vec3 textureCoordi;
//立体纹理贴图
uniform samplerCube cubeMap;
void main(){
    //textureCube(sampler, p)
    //sampler:指定采样的纹理 p:指定纹理将被采样的纹理坐标。
    gl_FragColor = textureCube(cubeMap,textureCoordi);
}
