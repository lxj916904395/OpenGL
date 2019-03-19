precision highp float;

varying vec2 vTextureCoord;
uniform sampler2D inputTexture;

void main() {
    // 线性混合
    gl_FragColor = texture2D(inputTexture, vTextureCoord);
}
