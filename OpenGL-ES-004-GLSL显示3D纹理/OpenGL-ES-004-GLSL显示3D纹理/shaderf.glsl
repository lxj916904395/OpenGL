
varying lowp vec2 varyingCoordinate;
uniform sampler2D colorMap0;
uniform sampler2D colorMap1;

void main(){
    gl_FragColor = texture2D(colorMap0,varyingCoordinate)+texture2D(colorMap1,varyingCoordinate);
    
}
