//
//  ZFView.m
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "ZFView.h"
#import <OpenGLES/ES3/gl.h>

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
}
@end
@implementation ZFView
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
}


- (void)setup{
    //1.设置图层
    [self setupLayer];
    //2.设置上下文
    [self setupContext];
    //3.设置renderbuffer
    [self setupRenderBuffer];
    //4.设置frameBuffer
    [self setupFrameBuffer];
    //5.render
    [self render];
}

- (void) render{
    
}


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
