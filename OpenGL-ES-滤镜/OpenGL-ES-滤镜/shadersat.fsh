//纹理坐标
varying lowp vec3 varyingCoord;

//e纹理
uniform sampler2D textureMap;

//饱和度
uniform lowp float saturation;

//色温过滤器
const lowp vec3  warmFilter = vec3(0.93,0.54,0);

//RGBtoYIQ
const mediump mat3 RGB2YIQ = mat3(0.299, 0.587, 0.114, 0.596, -0.274, -0.322, 0.212, -0.523, 0.311);

//YIQtoRGB
const mediump mat3 YIQ2RGB = mat3(1.0, 0.956, 0.621, 1.0, -0.272, -0.647, 1.0, -1.105, 1.702);

//亮度加权
const mediump vec3 lumanaceWeight = vec3(0.2125, 0.7154, 0.0721);

void main(){
    
    //读取每个像素点的颜色值
    lowp vec4 soource = texture2D(textureMap,varyingCoord);
    
    //dot(v1,v2) 向量点乘
    //亮度 = RGB值 * 亮度加权
    lowp float luminace = dot(soource.rgb,lumanaceWeight);
    
    //将亮度标量转换为vec3 向量
    lowp vec3 color = vec3(luminace,0 ,0);
    
    /*
     mix(x,y,a):将颜色与颜色/纹理与纹理/纹理与颜色通过线性方程式混合
     x.(1-a)+y.a --> vec3向量颜色
     vec4(vec3,w);-->vec4向量
     */
    gl_FragColor  = vec4(mix(color,soource.rgb,saturation),soource.w);
}
