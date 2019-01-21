//纹理坐标
varying lowp vec3 varyingCoord;

//e纹理
uniform sampler2D textureMap;

//色温
uniform lowp float temperature;

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
    lowp vec4 source = texture2D(textureMap,textureCoordinate);
    
    //源颜色RGB转换为YIQ颜色
    mediump vec3 yiq = RGB2YIQ * source.rgb;
    
    /*
     clamp(x,minVal,maxVal):裁剪
     1.x与minVal比较，取较大值；
     2.上一步得到的结果与maxVal比较，取较小值；
     
     yiq.b：b ->指yiq中的第三个值，而不是其b值
     */
    yiq.b = clamp(yiq.b, -0.5226, 0.5226);
    
    //YIQ颜色转RGB颜色
    lowp vec3 rgb = YIQ2RGB * yiq;
    
    /*
     色温计算:
     warmR:色温h过滤器--warmFilter
     if r<0.5 -->2.0*r*warmR;
     if r>= 0.5-->1.0-2.0*(1.0-r)*(1.0-warmR); */
    
    lowp float A = (rgb.r < 0.5 ? (2.0 * rgb.r * warmFilter.r) : (1.0 - 2.0 * (1.0 - rgb.r) * (1.0 - warmFilter.r)));
    
    lowp float B = (rgb.g < 0.5 ? (2.0 * rgb.g * warmFilter.g) : (1.0 - 2.0 * (1.0 - rgb.g) * (1.0 - warmFilter.g)));
    
    lowp float C =  (rgb.b < 0.5 ? (2.0 * rgb.b * warmFilter.b) : (1.0 - 2.0 * (1.0 - rgb.b) * (1.0 - warmFilter.b)));
    
    //组件新的颜色值
    lowp vec3 color = vec3(A,B,C);
    
    /*
     mix(x,y,a):将颜色与颜色/纹理与纹理/纹理与颜色通过线性方程式混合
     x.(1-a)+y.a --> vec3向量颜色
     vec4(vec3,w);-->vec4向量
     */
    gl_FragColor = vec4(mix(rgb,color，temperature),source.a);
}
