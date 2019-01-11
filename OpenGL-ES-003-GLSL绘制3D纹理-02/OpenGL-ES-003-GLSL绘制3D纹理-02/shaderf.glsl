
varying lowp vec2 varyingTexture;
uniform sampler2D colorMap;

void main(){
    gl_FragColor = texture2D(colorMap,varyingTexture);
}
