//电击
precision highp float;
varying vec2 vTextureCoord;
uniform sampler2D inputTexture;

uniform float time;

void main() {
    
    vec4 sourceColor = texture2D(inputTexture,vTextureCoord);

    if ((time > 40.0 && time < 50.0) || (time >20.0 && time <25.0)) {
            gl_FragColor  = vec4((1.0 - sourceColor.rgb), sourceColor.w);
    }else{
            gl_FragColor = sourceColor;
    }

}
