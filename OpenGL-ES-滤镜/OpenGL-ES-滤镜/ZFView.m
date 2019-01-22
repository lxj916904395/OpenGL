//
//  ZFView.m
//  OpenGL-ES-滤镜
//
//  Created by zhongding on 2019/1/22.
//

#import "ZFView.h"

#import <OpenGLES/ES3/gl.h>

//顶点结构体
typedef struct
{
    float position[4];//顶点x,y,z,w
    float textureCoordinate[2];//纹理 s,t
} CustomVertex;

//属性枚举
enum
{
    ATTRIBUTE_POSITION = 0,//属性_顶点
    ATTRIBUTE_INPUT_TEXTURE_COORDINATE,//属性_输入纹理坐标
    TEMP_ATTRIBUTE_POSITION,//色温_属性_顶点位置
    TEMP_ATTRIBUTE_INPUT_TEXTURE_COORDINATE,//色温_属性_输入纹理坐标
    NUM_ATTRIBUTES//属性个数
};

//属性数组
GLint glViewAttributes[NUM_ATTRIBUTES];

enum
{
    UNIFORM_INPUT_IMAGE_TEXTURE = 0,//输入纹理
    TEMP_UNIFORM_INPUT_IMAGE_TEXTURE,//色温_输入纹理
    UNIFORM_TEMPERATURE,//色温
    UNIFORM_SATURATION,//饱和度
    NUM_UNIFORMS//Uniforms个数
};

//Uniforms数组
GLint glViewUniforms[NUM_UNIFORMS];


@interface ZFView ()
{
    EAGLContext *context;
    CAEAGLLayer *eaglLayer;
    
    GLuint temperatureFramebuffer;
    GLuint temperatureRenderbuffer;
    GLuint temperatureProgram;
    GLuint       _tempTexture;

    GLuint saturationFramebuffer;
    GLuint saturationRenderbuffer;
    GLuint saturationProgram;
    GLuint       _satexture;

}
@end

@implementation ZFView

- (void)setImage:(UIImage *)image{
    _image = image;
    [self setup];
    [self setImageTexture:image];
    [self render];
}

- (void)setTemperature:(CGFloat)temperature{
    _temperature = temperature;
     [self render];
}

- (void)setSaturation:(CGFloat)saturation{
    _saturation = saturation;
     [self render];
}

#pragma mark ***************** Private

- (void)setup{
    
    _saturation = _temperature = 0.5;
    
    [self setupLayer];
    [self setupContext];
    [self setupSaturationBuffer];
    
    [self checkFramebuffer];
    [self compileSaturationProgram];
    [self compileTemperatureProgram];
    
    [self setupVBO];

    [self setTemper];
}

- (void)render{
    glUseProgram(temperatureProgram);

    glBindFramebuffer(GL_FRAMEBUFFER, temperatureFramebuffer);

    [self setViewPort];

    glUniform1f(glViewUniforms[TEMP_UNIFORM_INPUT_IMAGE_TEXTURE], 1);
    glUniform1f(glViewUniforms[UNIFORM_SATURATION], _temperature);

    glVertexAttribPointer(glViewAttributes[TEMP_ATTRIBUTE_POSITION], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
    //纹理数据
    glVertexAttribPointer(glViewAttributes[TEMP_ATTRIBUTE_INPUT_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    

    glUseProgram(saturationProgram);
    glBindFramebuffer(GL_FRAMEBUFFER, saturationFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, saturationRenderbuffer);
    
    [self setViewPort];
    glUniform1f(glViewUniforms[UNIFORM_INPUT_IMAGE_TEXTURE], 0);
    glUniform1f(glViewUniforms[UNIFORM_SATURATION], _saturation);
    
    //顶点数据
    glVertexAttribPointer(glViewAttributes[ATTRIBUTE_POSITION], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
    //纹理数据
    glVertexAttribPointer(glViewAttributes[ATTRIBUTE_INPUT_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)setViewPort{
    glViewport(0, 0, self.frame.size.width * self.contentScaleFactor, self.frame.size.height * self.contentScaleFactor);

    glClearColor(0, 0, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)setTemper{
    glGenFramebuffers(1, &temperatureFramebuffer);
    
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_tempTexture);
    glBindTexture(GL_TEXTURE_2D, _tempTexture);
    
    //设置纹理参数
    //放大\缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.frame.size.width * self.contentScaleFactor, self.frame.size.height * self.contentScaleFactor, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    glBindFramebuffer(GL_FRAMEBUFFER, temperatureFramebuffer);
    
    //应用FBO渲染到纹理（glGenTextures），直接绘制到纹理中。glCopyTexImage2D是渲染到FrameBuffer->复制FrameBuffer中的像素产生纹理。glFramebufferTexture2D直接渲染生成纹理，做全屏渲染（比如全屏模糊）时比glCopyTexImage2D高效的多。
    /*
     glFramebufferTexture2D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level)
     参数列表:
     1.target,GL_FRAMEBUFFER
     2.attachment,附着点名称
     3.textarget,GL_TEXTURE_2D
     4.texture,纹理对象
     5.level,一般为0
     */
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _tempTexture, 0);
    
}

- (void)setupVBO{
    //顶点坐标和纹理坐标
    static const CustomVertex vertices[] =
    {
        { .position = { -1.0, -1.0, 0, 1 }, .textureCoordinate = { 0.0, 0.0 } },
        { .position = {  1.0, -1.0, 0, 1 }, .textureCoordinate = { 1.0, 0.0 } },
        { .position = { -1.0,  1.0, 0, 1 }, .textureCoordinate = { 0.0, 1.0 } },
        { .position = {  1.0,  1.0, 0, 1 }, .textureCoordinate = { 1.0, 1.0 } }
    };
    
    //初始化缓存区
    //创建VBO的3个步骤
    //1.生成新缓存对象glGenBuffers
    //2.绑定缓存对象glBindBuffer
    //3.将顶点数据拷贝到缓存对象中glBufferData
    
    GLuint vertexBuffer;
    
    // STEP 1 创建缓存对象并返回缓存对象的标识符
    glGenBuffers(1, &vertexBuffer);
    // STEP 2 将缓存对象对应到相应的缓存上
    /*
     glBindBuffer (GLenum target, GLuint buffer);
     target:告诉VBO缓存对象时保存顶点数组数据还是索引数组数据 :GL_ARRAY_BUFFER\GL_ELEMENT_ARRAY_BUFFER
     任何顶点属性，如顶点坐标、纹理坐标、法线与颜色分量数组都使用GL_ARRAY_BUFFER。用于glDraw[Range]Elements()的索引数据需要使用GL_ELEMENT_ARRAY绑定。注意，target标志帮助VBO确定缓存对象最有效的位置，如有些系统将索引保存AGP或系统内存中，将顶点保存在显卡内存中。
     buffer: 缓存区对象
     */
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    /*
     数据拷贝到缓存对象
     void glBufferData(GLenum target，GLsizeiptr size, const GLvoid*  data, GLenum usage);
     target:可以为GL_ARRAY_BUFFER或GL_ELEMENT_ARRAY
     size:待传递数据字节数量
     data:源数据数组指针
     usage:
     GL_STATIC_DRAW
     GL_STATIC_READ
     GL_STATIC_COPY
     GL_DYNAMIC_DRAW
     GL_DYNAMIC_READ
     GL_DYNAMIC_COPY
     GL_STREAM_DRAW
     GL_STREAM_READ
     GL_STREAM_COPY
     
     ”static“表示VBO中的数据将不会被改动（一次指定多次使用），
     ”dynamic“表示数据将会被频繁改动（反复指定与使用），
     ”stream“表示每帧数据都要改变（一次指定一次使用）。
     ”draw“表示数据将被发送到GPU以待绘制（应用程序到GL），
     ”read“表示数据将被客户端程序读取（GL到应用程序），”
     */
    // STEP 3 数据拷贝到缓存对象
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}


- (void)compileSaturationProgram{
    GLuint vshader = [self compileShader:@"shader.vsh" type:GL_VERTEX_SHADER];
    GLuint fshader = [self compileShader:@"shadersat.fsh" type:GL_FRAGMENT_SHADER];
    
    saturationProgram = glCreateProgram();
    
    glAttachShader(saturationProgram, vshader);
    glAttachShader(saturationProgram, fshader);
    
    [self linkProgram:saturationProgram];
    
    glViewAttributes[ATTRIBUTE_POSITION] = glGetAttribLocation(saturationProgram, "position");
    glViewAttributes[ATTRIBUTE_INPUT_TEXTURE_COORDINATE] = glGetAttribLocation(saturationProgram, "inputTextureCoordinate");
    
    glEnableVertexAttribArray(glViewAttributes[ATTRIBUTE_POSITION]);
    glEnableVertexAttribArray(glViewAttributes[ATTRIBUTE_INPUT_TEXTURE_COORDINATE]);


    glViewUniforms[UNIFORM_TEMPERATURE] = glGetUniformLocation(saturationProgram, "saturation");
    glViewUniforms[UNIFORM_INPUT_IMAGE_TEXTURE] = glGetUniformLocation(saturationProgram, "inputImageTexture");
    
}

- (void)compileTemperatureProgram{
    
    GLuint vshader = [self compileShader:@"shader.vsh" type:GL_VERTEX_SHADER];
    GLuint fshader = [self compileShader:@"shadertemp.fsh" type:GL_FRAGMENT_SHADER];
    
    temperatureProgram = glCreateProgram();
    
    glAttachShader(temperatureProgram, vshader);
    glAttachShader(temperatureProgram, fshader);
    
    [self linkProgram:temperatureProgram];
    
    glViewAttributes[TEMP_ATTRIBUTE_POSITION] = glGetAttribLocation(temperatureProgram, "position");
    glViewAttributes[TEMP_ATTRIBUTE_INPUT_TEXTURE_COORDINATE] = glGetAttribLocation(temperatureProgram, "inputTextureCoordinate");
    
    glEnableVertexAttribArray(glViewAttributes[TEMP_ATTRIBUTE_POSITION]);
    glEnableVertexAttribArray(glViewAttributes[TEMP_ATTRIBUTE_INPUT_TEXTURE_COORDINATE]);
    
    
    glViewUniforms[UNIFORM_SATURATION] = glGetUniformLocation(temperatureProgram, "temperature");
    glViewUniforms[TEMP_UNIFORM_INPUT_IMAGE_TEXTURE] = glGetUniformLocation(temperatureProgram, "inputImageTexture");
}

- (void)linkProgram:(GLuint)pro{
    glLinkProgram(pro);
    
    GLint loglength;
    glGetProgramiv(pro, GL_INFO_LOG_LENGTH, &loglength);
    if (loglength > 0) {
        
        char *log = (char*)malloc(loglength);
        glGetProgramInfoLog(pro, loglength, &loglength, log);
        NSLog(@"program link err====%s",log);
        return;
    }
    
    glUseProgram(pro);
}

- (GLuint)compileShader:(NSString*)filename type:(GLenum)type{
    
    NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar*)[content UTF8String];
    
    GLuint shader = glCreateShader(type);
    
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    GLint loglength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &loglength);
    if (loglength > 0) {
        
        char *log = (char*)malloc(loglength);
        glGetShaderInfoLog(shader, loglength, &loglength, log);
        NSLog(@"shader err====%s",log);
        return 0;
    }
    
    return shader;
}

- (void)checkFramebuffer {
    
    // 检查 framebuffer 是否创建成功
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString *errorMessage = nil;
    BOOL result = NO;
    switch (status)
    {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorMessage = @"framebuffer不支持该格式";
            result = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"framebuffer 创建成功");
            result = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorMessage = @"Framebuffer不完整 缺失组件";
            result = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorMessage = @"Framebuffer 不完整, 附加图片必须要指定大小";
            result = NO;
            break;
        default:
            // 一般是超出GL纹理的最大限制
            errorMessage = @"未知错误 error !!!!";
            result = NO;
            break;
    }
    NSLog(@"%@",errorMessage ? errorMessage : @"");
    if (!result) {
        return;
    }
}


- (void)setupSaturationBuffer{
    
    glGenRenderbuffers(1, &saturationRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, saturationRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    
    glGenFramebuffers(1, &saturationFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, saturationFramebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, saturationRenderbuffer);
    
}

- (void)setupContext{
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES2)];
    [EAGLContext setCurrentContext:context];
}

- (void)setupLayer{
    eaglLayer = (CAEAGLLayer*)self.layer;
    eaglLayer.opaque = YES;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)setImageTexture:(UIImage *)image{
    //1.获取图片宽\高
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    
    
    //2.获取颜色组件
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //3.计算图片数据大小->开辟空间
    void *imageData = malloc( height * width * 4 );
    //CG开头的方法都是来自于CoreGraphics这个框架
    //了解CoreGraphics 框架
    
    //创建位图context
    /*
     CGBitmapContextCreate(void * __nullable data,
     size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow,
     CGColorSpaceRef cg_nullable space, uint32_t bitmapInfo)
     参数列表:
     1.data,指向要渲染的绘制内存的地址
     2.width,bitmap的宽度,单位为像素
     3.height,bitmap的高度,单位为像素
     4.bitsPerComponent, 内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
     5.bytesPerRow, bitmap的每一行在内存所占的比特数
     6.colorspace, bitmap上下文使用的颜色空间
     7.bitmapInfo,指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
     
     
     */
    
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 8,
                                                 4 * width,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //创建完context,可以释放颜色空间colorSpace
    CGColorSpaceRelease( colorSpace );
    
    /*
     绘制透明矩形。如果所提供的上下文是窗口或位图上下文，则核心图形将清除矩形。对于其他上下文类型，核心图形以设备依赖的方式填充矩形。但是，不应在窗口或位图上下文以外的上下文中使用此函数
     CGContextClearRect(CGContextRef cg_nullable c, CGRect rect)
     参数:
     1.C,绘制矩形的图形上下文。
     2.rect,矩形，在用户空间坐标中。
     */
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    //CTM--从用户空间和设备空间存在一个转换矩阵CTM
    /*
     CGContextTranslateCTM(CGContextRef cg_nullable c,
     CGFloat tx, CGFloat ty)
     参数1:上下文
     参数2:X轴上移动距离
     参数3:Y轴上移动距离
     */
    CGContextTranslateCTM(context, 0, height);
    //缩小
    CGContextScaleCTM (context, 1.0,-1.0);
    
    //绘制图片
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    //释放context
    CGContextRelease(context);
    //在绑定纹理之前,激活纹理单元 glActiveTexture
    glActiveTexture(GL_TEXTURE1);
    
    //生成纹理标记
    glGenTextures(1, &_satexture);
    
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, _satexture);
    
    //设置纹理参数
    //环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //放大\缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    //将图片载入纹理
    /*
     glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
     参数列表:
     1.target,目标纹理
     2.level,一般设置为0
     3.internalformat,纹理中颜色组件
     4.width,纹理图像的宽度
     5.height,纹理图像的高度
     6.border,边框的宽度
     7.format,像素数据的颜色格式
     8.type,像素数据数据类型
     9.pixels,内存中指向图像数据的指针
     */
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLint)width,
                 (GLint)height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 imageData);
    
    //释放imageData
    free(imageData);
    
}

@end
