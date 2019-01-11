//
//  ZFView.m
//  OpenGLES-002-GLSL02
//
//  Created by zhongding on 2018/12/28.
//

#import "ZFView.h"
#import <OpenGLES/ES3/gl.h>
@interface ZFView ()
@property(strong ,nonatomic) CAEAGLLayer *eaglLayer;
@property(strong ,nonatomic) EAGLContext *context;

@property(assign ,nonatomic) GLuint renderBuffer;
@property(assign ,nonatomic) GLuint frameBuffer;

@property(assign ,nonatomic) GLint program;
@end


@implementation ZFView

- (void)layoutSubviews{
    [self setupLayer];
    [self setupContext];
    [self cleanBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self begainRender];
}


- (void)begainRender{
    
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.program = [self loadProgram];
    
    glLinkProgram(self.program);
    
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus==GL_FALSE) {
        char message[1024];
        glGetProgramInfoLog(self.program, sizeof(message), NULL, &message[0]);
        NSString *err = [NSString stringWithUTF8String:message];
        NSLog(@"program 链接出错:%@",err);
        return;
    }
    
    glUseProgram(self.program);
    
    [self setupVertex];
    [self setupTexture];
    
    GLfloat rot = 10*3.1415/180;
    GLfloat c = cos(rot);
   GLfloat s = sin(rot);
    
    GLfloat rotMatt[] = {
        c ,-s,0,0,
        s,c,0,0,
        0,0,1,0,
        0,0,0 ,1
    };
    
    GLuint rotMatrix = glGetUniformLocation(self.program, "rotMatrix");
    glUniformMatrix4fv(rotMatrix, 1, GL_FALSE, &rotMatt[0]);
    
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.context presentRenderbuffer:self.renderBuffer];
}


- (void)setupVertex{
        CGFloat size = 1.0f;
    GLfloat vertexs[] = {
        size,size,0,   0,0,
        -size,size,0,  1,0,
        -size,-size,0, 1,1,
        
        size,size,0,   0,0,
        -size,-size,0, 1,1,
        size,-size,0 ,  0,1

        
//        size, -size, 0.0f,        1.0f, 1.0f, //右下
//        -size, size, 0.0f,        0.0f, 0.0f, // 左上
//        -size, -size, 0.0f,       0.0f, 1.0f, // 左下
//        size, size, 0.0f,         1.0f, 0.0f, // 右上
//        -size, size, 0.0f,        0.0f, 0.0f, // 左上
//        size, -size, 0.0f,        1.0f, 1.0f, // 右下
    };
    
    GLuint verBuffer;
    glGenBuffers(1, &verBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, verBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, 0);
    
    GLuint textureCoodinate = glGetAttribLocation(self.program, "textureCoodinate");
    glEnableVertexAttribArray(textureCoodinate);
    glVertexAttribPointer(textureCoodinate, 2, GL_FLOAT
                          , GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+3);
    
    
}

- (void)setupTexture{
    
    CGImageRef image = [UIImage imageNamed:@"test.jpg"].CGImage;
    
    size_t width = CGImageGetWidth(image),height = CGImageGetHeight(image);
    
    GLubyte *data = calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    
    CGFloat w = width,h = height;
    CGContextDrawImage(context, CGRectMake(0, 0, w ,h), image);
    
    CGContextRelease(context);
    
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glProgramParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glProgramParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);

    free(data);
    
}


- (GLint)loadProgram{
    
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];

    GLuint verShader,fragShader;
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vfile];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:ffile];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}

- (void)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString*)file{
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar*)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}


- (void)setupFrameBuffer{
    glGenRenderbuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)setupRenderBuffer{
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}


- (void)cleanBuffer{
    glDeleteBuffers(1, &_renderBuffer);
    
    _renderBuffer = 0;
    
    glDeleteBuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)setupContext{
    self.context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    if (!self.context) {
        return;
    }
    
    if (![EAGLContext setCurrentContext:self.context]) {
        return;
    }
}

- (void)setupLayer{
    CAEAGLLayer *layer = (CAEAGLLayer*)self.layer;
    layer.opaque = YES;
    layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    
    self.eaglLayer = layer;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

@end

