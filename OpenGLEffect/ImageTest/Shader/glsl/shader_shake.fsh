//抖动
precision mediump float;
//每个点的xy坐标
varying vec2 vTextureCoord;
//对应纹理
uniform sampler2D inputTexture;
uniform float offset;

void main()
{
    //直接采样蓝色色值
    vec4 blue = texture2D(inputTexture,vTextureCoord);
    //从效果看，绿色和红色色值特别明显，所以需要对其色值偏移。绿色和红色需要分开方向，不然重叠一起会混色。
    //坐标向左上偏移，然后再采样色值
    vec4 green = texture2D(inputTexture, vec2(vTextureCoord.x + offset, vTextureCoord.y + offset));
    //坐标向右下偏移，然后再采样色值
    vec4 red = texture2D(inputTexture,vec2(vTextureCoord.x - offset,vTextureCoord.y - offset));
    //RG两个经过偏移后分别采样，B沿用原来的色值，透明度为1，组合最终输出
    gl_FragColor = vec4(red.r,green.g,blue.b,blue.a);
}
