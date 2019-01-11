//
//  ZFView.m
//  OpenGL-ES-004-GLSL显示3D纹理
//
//  Created by zhongding on 2019/1/7.
//

#import "ZFView.h"

#import <OpenGLES/ES3/gl.h>
#import "sphere.h"
#import "GLESUtils.h"
#import "GLESMath.h"
#import "ShaderUtil.h"

#define texture_count 2

@interface ZFView()
{
    
    CAEAGLLayer *eaglLayer;
    EAGLContext *context;
    
    GLuint renderBuffer;
    GLuint frameBuffer;
    
    GLuint program;
    
    GLuint textureID[texture_count];
    
    CGFloat aspect;
    
    NSTimer *timer;
    
    CGFloat moonrot;
    
}
@end
@implementation ZFView

- (void)layoutSubviews{
    
    aspect = self.frame.size.width/self.frame.size.height;
    
    [self setupLayer];
    [self setupContext];
    [self cleanBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
    [self startTimer];
}

- (void)render{
    [self setup];
    
    [self loadProgram];
    
    [self setupBufferData];
    
    //申请两个纹理标识
    NSArray *textureName = @[@"son.jpg",@"Earth512x256.jpg"];
    glGenTextures(texture_count, textureID);
    [self setTeture:textureName[0] texture:textureID[0]];
    [self setTeture:textureName[1] texture:textureID[1]];

    [self setPerspective];
    
    [self drawSon];
}

- (void)setup{
    glClearColor(0.1, 0.5, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x*scale, self.frame.origin.y*scale, self.frame.size.width*scale, self.frame.size.height*scale);
}

#pragma mark ***************** 绘制太阳
- (void)drawSon{
//    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLuint colorMap;
    colorMap = glGetUniformLocation(program, "colorMap0");
//    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    glUniform1i(colorMap, 0);
    
    GLuint umodelviewMatrix = glGetUniformLocation(program, "modelviewMatrix");
    
    //设置模型视图矩阵
    KSMatrix4 _modelviewMatrix;
    ksMatrixLoadIdentity(&_modelviewMatrix);
    ksTranslate(&_modelviewMatrix, 0, 0, -10);

    //旋转
    KSMatrix4 rotMatrix;
    ksMatrixLoadIdentity(&rotMatrix);
    ksRotate(&rotMatrix, moonrot, 0, 1, 0);

    ksMatrixMultiply(&_modelviewMatrix, &rotMatrix, &_modelviewMatrix);
    
    glUniformMatrix4fv(umodelviewMatrix, 1, GL_FALSE, &_modelviewMatrix.m[0][0]);
    
    //绘制
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
    [self drawEarth:_modelviewMatrix];
}

#pragma mark ***************** 绘制地球
- (void)drawEarth:(KSMatrix4)sonMatrix{
//    glBindTexture(GL_TEXTURE_2D, 0);

    //重新绑定纹理
    GLuint colorMap;
    colorMap = glGetUniformLocation(program, "colorMap1");
//    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureID[1]);
    glUniform1i(colorMap, 1);
    
    GLuint umodelviewMatrix = glGetUniformLocation(program, "modelviewMatrix");
  
//    KSMatrix4 earthMatrix;
//    ksMatrixLoadIdentity(&earthMatrix);

    //缩小
    ksScale(&sonMatrix, 0.4, 0.4, 0.4);
    
    KSMatrix4 rotateMatrix;
    ksMatrixLoadIdentity(&rotateMatrix);
    
    //自转
    ksRotate(&rotateMatrix, moonrot, 0, 1, 0);

    //公转
    ksTranslate(&sonMatrix, 0.5, 0, -5);
//    ksMatrixMultiply(&sonMatrix, &sonMatrix, &earthMatrix);

    ksRotate(&rotateMatrix, moonrot-360, 1, 0, 0);

    ksMatrixMultiply(&sonMatrix, &rotateMatrix, &sonMatrix);

    glUniformMatrix4fv(umodelviewMatrix, 1, GL_FALSE, &sonMatrix.m[0][0]);
    
    //绘制
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark *****************透视投影
- (void)setPerspective{
    //投影矩阵
    GLuint uprojectionMatrix = glGetUniformLocation(program, "projectionMatrix");
    KSMatrix4 projectionMatrix;
    ksMatrixLoadIdentity(&projectionMatrix);
    ksPerspective(&projectionMatrix, 30.0, aspect, 5.0f, 20.0f);
    glUniformMatrix4fv(uprojectionMatrix, 1, GL_FALSE, &projectionMatrix.m[0][0]);
}


- (void)setTeture:(NSString*)name texture:(GLuint)textureid{
    
    CGImageRef image = [UIImage imageNamed:name].CGImage;
    size_t width =  CGImageGetWidth(image),
    height = CGImageGetHeight(image);
    GLubyte *data = calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef contextRef = CGBitmapContextCreate(data, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), image);
    CGContextRelease(contextRef);
    
    glBindTexture(GL_TEXTURE_2D, textureid);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    free(data);
}

//坐标数据
- (void)setupBufferData{
    GLuint vertexBuffer,textureCoorBuffer;
    
    //顶点数据buffer
    [ShaderUtil lallocBuffer:&vertexBuffer size:sizeof(sphereVerts) data:sphereVerts usage:GL_STATIC_DRAW];

    //顶点数据读取
    GLuint position = glGetAttribLocation(program, "position");
    [ShaderUtil prepareToDrawWithAttrib:vertexBuffer index:position count:3 stride:sizeof(GLfloat)*3 stepOffet:0];
    
    //纹理坐标buffer
    [ShaderUtil lallocBuffer:&textureCoorBuffer size:sizeof(sphereTexCoords) data:sphereTexCoords usage:GL_STATIC_DRAW];
    //纹理坐标数据读取
    GLuint textureCoordinate = glGetAttribLocation(program, "textureCoordinate");
    [ShaderUtil prepareToDrawWithAttrib:textureCoorBuffer index:textureCoordinate count:2 stride:sizeof(GLfloat)*2 stepOffet:0];
    
}

- (void)loadProgram{
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    program = [ShaderUtil glCreateProgramWithVpath:vfile fPath:ffile];
}

#pragma mark *****************
- (void)setupFrameBuffer{
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}
#pragma mark *****************
- (void)setupRenderBuffer{
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
}
#pragma mark *****************
- (void)cleanBuffer{
    glDeleteBuffers(1, &renderBuffer);
    glDeleteBuffers(1,&frameBuffer);
    
    renderBuffer = 0;
    frameBuffer = 0;
}
#pragma mark *****************
- (void)setupContext{
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    [EAGLContext setCurrentContext:context];
}
#pragma mark *****************
- (void)setupLayer{
    
    eaglLayer = (CAEAGLLayer*)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    [self setContentScaleFactor:[UIScreen mainScreen].scale];

    glEnable(GL_DEPTH_TEST);
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)startTimer{
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
    }
}

- (void)rotate{
    moonrot += 2;
  
    [self setup];
    [self drawSon];
}

@end
