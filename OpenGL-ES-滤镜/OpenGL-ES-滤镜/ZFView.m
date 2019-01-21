//
//  ZFView.m
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "ZFView.h"
#import <OpenGLES/ES3/gl.h>


typedef enum {
    AttribTemp_Position,//色温顶点位置
    AttribTemp_TextureCoorDinate,//色温纹理坐标
    
    AttribSat_Position,//饱和度顶点位置
    AttribSat_TextureCoorDinate,//饱和度纹理坐标
    
    AttribNum,//属性个数
}Attribuites;

//存储所有属性
GLint shaderAttribs[AttribNum];


typedef enum {
    UniformTemp_textureMap,//色温纹理
    UniformTemp_temperature,//色温值

    UniformSat_textureMap,//饱和度纹理
    UniformSat_saturation,//饱和度值
    
    UniformNum,//nuniform个数
}Uniforms;

//存储所有uniform值
GLint shaderUniforms[UniformNum];

@interface ZFView()
{
    CAEAGLLayer *eaglLayer;
    EAGLContext * context;
    
    //色温程序
    GLuint temperatureRendeBuffer;
    GLuint temperatureFrameBuffer;
    GLuint temperatureProgram;
    
    //饱和度程序
    GLuint saturationFrameBuffer;
    GLuint saturationRenderBuffer;
    GLuint saturationProgram;
    
    
    //饱和度
    CGFloat _saturation;
    //色温值
    CGFloat _temperature;
    
    GLuint texttureID;
}
@end
@implementation ZFView
#pragma mark ***************** public

//饱和度
- (void)setSaturationValue:(CGFloat)saturation{
    _saturation = saturation;
    [self render];
}

//色温值
- (void)setTemperatureValue:(CGFloat)temperature{
    _temperature = temperature;
    [self render];
}

- (void)setTextureImage:(UIImage*)immage{
    [self setup];
    [self setTextureImage:immage];
    [self render];
}

#pragma mark ***************** setup

- (void)setup{
    //初始化值
    _saturation = _temperature = 0.5;
    
    //1.设置图层
    [self setupLayer];
    //2.设置上下文
    [self setupContext];
    //3.设置renderbuffer
    [self setupRenderBuffer];
    //4.设置frameBuffer
    [self setupFrameBuffer];
    
    [self compileSaturationProgram];
    
    [self compileTemperatureProgram];
    
    
    [self setupVBO];
    
}


- (void) render{
    
}


- (void)setupVBO{
    GLfloat vertexs[] = {
        
        -0.5,-0.5,  0,0,
        0.5,-0.5,   1,0,
        -0.5,0.5,   0,1,
        0.5,0.5,    1,1
    };
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
}

//创建saturation program
- (void)compileSaturationProgram{
    
    GLuint vsher,fshder;
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shadersat" ofType:@"fsh"];
    
    [self compileShader:&vsher type:GL_VERTEX_SHADER file:vfile];
    [self compileShader:&fshder type:GL_FRAGMENT_SHADER file:ffile];
    
    saturationProgram = glCreateProgram();
    
    glAttachShader(saturationProgram, vsher);
    glAttachShader(saturationProgram, fshder);
  
    
    [self linkProgram:saturationProgram];
    
    glDeleteShader(vsher);
    glDeleteShader(fshder);
    
    glUseProgram(saturationProgram);
    
    //开启属性读取
    shaderAttribs[AttribSat_Position] = glGetAttribLocation(saturationProgram, "position");
    shaderAttribs[AttribSat_TextureCoorDinate] = glGetAttribLocation(saturationProgram, "textureCoordinate");
    
    glEnableVertexAttribArray(shaderAttribs[AttribSat_Position]);
    glEnableVertexAttribArray(shaderAttribs[AttribSat_TextureCoorDinate]);

}

//创建temperature program
- (void)compileTemperatureProgram{
    
    GLuint vsher,fshder;
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shadertem" ofType:@"fsh"];
    
    [self compileShader:&vsher type:GL_VERTEX_SHADER file:vfile];
    [self compileShader:&fshder type:GL_FRAGMENT_SHADER file:ffile];
    
    temperatureProgram = glCreateProgram();
    
    glAttachShader(temperatureProgram, vsher);
    glAttachShader(temperatureProgram, fshder);
    
    [self linkProgram:temperatureProgram];
    
    glDeleteShader(vsher);
    glDeleteShader(fshder);
    
    //开启属性读取
    shaderAttribs[AttribTemp_Position] = glGetAttribLocation(temperatureProgram, "position");
    shaderAttribs[AttribTemp_TextureCoorDinate] = glGetAttribLocation(temperatureProgram, "textureCoordinate");
    
    glEnableVertexAttribArray(shaderAttribs[AttribTemp_Position]);
    glEnableVertexAttribArray(shaderAttribs[AttribTemp_TextureCoorDinate]);
}


//链接program
- (void)linkProgram:(GLuint)pro{
    
    if (pro) {
        
        glLinkProgram(pro);
        
        GLint loglength;
        glGetProgramiv(pro, GL_INFO_LOG_LENGTH, &loglength);
        
        if (loglength >0) {
            
            GLchar * log = (GLchar*)malloc(loglength);
            
            glGetProgramInfoLog(pro, loglength, &loglength, log);
            
            NSLog(@"link program is err :%s",log);
            return;
        }
        
    }else{
        NSLog(@"program is NULL");
    }
}


//创建shader
- (void)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString *)file{
    
    NSString *str = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar*)[str UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
    GLint loglength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &loglength);
    if (loglength > 0) {
        
        GLchar *log = malloc(loglength);
        glGetShaderInfoLog(*shader, loglength, &loglength, log);
        NSLog(@"shader log:%s",log);
        return;
    }
}

#pragma mark ***************** 纹理载入

- (void)setupTextureImage:(UIImage *)image{
    
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    
    //申请图片空间
    GLubyte *data = (GLubyte*)malloc(width*height*4);
    
    //通过上下文绘制图片
    CGContextRef contextRef = CGBitmapContextCreate(&data, width, height, 8, width*4, CGImageGetColorSpace(image.CGImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image.CGImage);
    
    CGContextRelease(contextRef);
    
    //纹理设置
    glGenBuffers(1, &texttureID);
    glBindBuffer(GL_TEXTURE_2D, texttureID);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    
    //载入纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    free(data);
}

#pragma mark ***************** frame buffer

- (void) setupFrameBuffer{
    
    if(temperatureFrameBuffer){
        glDeleteFramebuffers(1, &temperatureFrameBuffer);
        temperatureFrameBuffer = 0;
    }
    glGenFramebuffers(1, &temperatureFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, temperatureFrameBuffer);
    
    if (saturationFrameBuffer) {
        glDeleteFramebuffers(1, &saturationFrameBuffer);
        saturationFrameBuffer = 0;
    }
    glGenFramebuffers(1, &saturationFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, saturationFrameBuffer);
}

#pragma mark ***************** render buffer

- (void) setupRenderBuffer{
    
    if (temperatureRendeBuffer) {
        glDeleteRenderbuffers(1, &temperatureRendeBuffer);
        temperatureRendeBuffer = 0;
    }
    
    glGenRenderbuffers(1, &temperatureRendeBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, temperatureRendeBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    
    if (saturationRenderBuffer) {
        glDeleteRenderbuffers(1, &saturationRenderBuffer);
        saturationRenderBuffer = 0;
    }
    
    glGenRenderbuffers(GL_RENDERBUFFER, &saturationRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, saturationRenderBuffer);
}

- (void) setupContext{
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    [EAGLContext setCurrentContext:context];
}

- (void) setupLayer{
    eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

@end
