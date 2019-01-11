
varying lowp vec2 varyingTexture;
uniform sampler2D colorMap;

void main(void){
    gl_FragColor = texture2D(colorMap,varyingTexture);
}
