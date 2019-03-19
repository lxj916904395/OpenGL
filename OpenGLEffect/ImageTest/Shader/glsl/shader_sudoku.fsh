//九宫格
precision highp float;
varying vec2 vTextureCoord;
uniform sampler2D inputTexture;

void main() {
    
    vec4 sourceColor = texture2D(inputTexture,vTextureCoord);
    gl_FragColor = sourceColor;
}
