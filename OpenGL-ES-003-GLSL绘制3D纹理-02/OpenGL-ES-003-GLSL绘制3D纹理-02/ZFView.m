//
//  ZFView.m
//  OpenGL-ES-003-GLSL绘制3D纹理-02
//
//  Created by zhongding on 2019/1/3.
//

#import "ZFView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLESUtils.h"
#include "GLESMath.h"
@interface ZFView(){
    CGFloat xrot;
    CGFloat yrot;
    CGFloat zrot;
    
    BOOL xb;
    BOOL yb;
    BOOL zb;
    
    NSTimer *_timer;
}
@property(strong ,nonatomic) CAEAGLLayer *newlayer;
@property(strong ,nonatomic) EAGLContext *context;

@property(assign ,nonatomic) GLuint renderBuffer;
@property(assign ,nonatomic) GLuint frameBuffer;

@property(assign ,nonatomic) GLuint program;
@end
@implementation ZFView


- (void)layoutSubviews{
    [self setupLayer];
    [self setupContext];
    [self cleanBuffer];
    [self setupRenderbuffer];
    [self setupFramebuffer];
    [self render];
}

- (void)render{
    glClearColor(0.4,0.1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    float scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);

    if (self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
    [self loadProgram];
    [self setupData];
}


- (void)setupData{
    GLfloat vertexs[] = {
        -0.5,0.5,0,        1,0,
        0.5,0.5,0,         0,0,
        -0.5,-0.5,0,       1,1,
        0.5,-0.5,0,        0,1,
        0,0,20,           0.5,0.5
    };
    
    GLint indexs[] = {
        0,1,3,
        0,3,2,
        0,2,4,
        0,4,1,
        2,3,4,
        1,4,3
    };
    
    GLuint vertexBuffer;
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, 0);
    
    GLuint textureCoordinate = glGetAttribLocation(self.program, "textureCoordinate");
    glEnableVertexAttribArray(textureCoordinate);
    glVertexAttribPointer(textureCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+3);
    
    [self setupTexure];
    
    [self setupMatrix];
    
    glDrawElements(GL_TRIANGLES, sizeof(indexs)/sizeof(GLuint), GL_UNSIGNED_INT, indexs);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupMatrix{
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    float aspect = width/height;

    ksPerspective(&_projectionMatrix, 30, aspect, 5.0f, 20.0f);

    GLuint projectionMatrix = glGetUniformLocation(self.program, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrix, 1, GL_FALSE, &_projectionMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);

    KSMatrix4 _modelviewMatrix;
    ksMatrixLoadIdentity(&_modelviewMatrix);
    ksTranslate(&_modelviewMatrix, 0, 0, -10);
    
    
    KSMatrix4 _rotateMatrix;
    ksMatrixLoadIdentity(&_rotateMatrix);
    ksRotate(&_rotateMatrix, xrot, 1, 0, 0);
    ksRotate(&_rotateMatrix, yrot, 0, 1, 0);
    ksRotate(&_rotateMatrix, zrot, 0, 0, 1);
    ksMatrixMultiply(&_modelviewMatrix, &_rotateMatrix, &_modelviewMatrix);
    
    GLuint modelviewMatrix = glGetUniformLocation(self.program, "modelviewMatrix");
    glUniformMatrix4fv(modelviewMatrix, 1, GL_FALSE, &_modelviewMatrix.m[0][0]);
    
}

- (void)setupTexure{
    CGImageRef image = [UIImage imageNamed:@"pp.jpg"].CGImage;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    GLubyte *data = (GLubyte*)calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(context);
    
    glBindBuffer(GL_TEXTURE_2D, 0);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    free(data);
    
}


- (void)loadProgram{
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    
    GLuint vertexShader,fragShader;
    [self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vfile];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:ffile];
    
    
    GLuint program = glCreateProgram();
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShader);
    
    self.program = program;
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragShader);
    
    glLinkProgram(self.program);
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus== GL_FALSE) {
        char message[1024];
        glGetProgramInfoLog(self.program, sizeof(message), 0, &message[0]);
        NSString *err = [NSString stringWithUTF8String:message];
        NSLog(@"链接出错:%@",err);
        return;
    }
    NSLog(@"link Program success");
    glUseProgram(self.program);
}

- (void)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString*)file{
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar*)[content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}


#pragma mark *****************

- (void)setupFramebuffer{
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)setupRenderbuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.newlayer];
}

- (void)cleanBuffer{
    glDeleteBuffers(1, &_renderBuffer);
    glDeleteBuffers(1, &_frameBuffer);
    
    _renderBuffer = 0;
    _frameBuffer = 0;
}

-  (void)setupContext{
    self.context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupLayer{
    
    self.newlayer = (CAEAGLLayer*)self.layer;
    
    self.newlayer.opaque = YES;
    
    self.newlayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    

}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}


- (IBAction)clickX:(id)sender {
    xb = !xb;
    [self startTimer];
}
- (IBAction)clickY:(id)sender {
    yb = !yb;
    [self startTimer];
}
- (IBAction)clickZ:(id)sender {
    zb = !zb;
    [self startTimer];
}

- (void)startTimer{
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
    }
}


- (void)rotate{
    xrot += 5 * xb;
    yrot += 5 *yb;
    zrot += 5* zb;
    [self render];
}

@end
