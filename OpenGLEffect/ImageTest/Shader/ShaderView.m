//
//  ShaderView.m
//  ImageTest
//
//  Created by apple on 2019/3/15.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ShaderView.h"

#import "ShaderProgram.h"
#import <GLKit/GLKit.h>

#define MirroringNum 4
#define SudokuNum 10
#define DimNum 3

GLfloat defaultVertexs[] = {
    -1,-1,0,     0,0,
    1,-1,0,     1,0,
    1,1,0,      1,1,
    -1,1,0,     0,1
};

@interface ShaderView()
{
    GLuint VAO_Mirroring[MirroringNum];
    GLuint vertextBuffer_Mirroring[MirroringNum];
    
    GLuint VAO_Sudoku[SudokuNum];
    GLuint vertextBuffer_Sudoku[SudokuNum];
    
    GLuint VAO_Dim[DimNum];
    GLuint vertextBuffer_Dim[DimNum];

    NSTimer *link;
    float linkTime;
    
    GLuint dimProgram;
    GLuint dimRenderBuffer;
    GLuint dimFrameBuffer;
}
@property (strong,nonatomic) CAEAGLLayer *eaglLayer;
@property (strong ,nonatomic) EAGLContext *context;

@property (assign,nonatomic) GLuint frameBuffer;
@property (assign,nonatomic) GLuint renderBuffer;
@property (assign,nonatomic) GLuint program;

@property (assign,nonatomic) float mScale;
@property (assign,nonatomic) float mOffset;

@end
@implementation ShaderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    [self setupLayer];
    [self setupContext];
    [self setupBuffer];
    glEnable(GL_DEPTH_TEST);
}

#pragma mark 纹理图片
- (void)setImage:(UIImage *)image{
    _image = image;
    [self setupTexture:image];
}

#pragma mark 纹理样式
- (void)setShaderStyle:(ShaderStyle)shaderStyle{
    _shaderStyle = shaderStyle;
    switch (shaderStyle) {
        case ShaderStyleSoulout:
            _program = [ShaderProgram programWithVertext:@"shader.vsh" fragment:@"shader_soulout.fsh"];

            [self setupVAO_Soulout];
            break;
            
       case ShaderStyleMirroring:
            _program = [ShaderProgram programWithVertext:@"shader.vsh" fragment:@"shader.fsh"];
            [self setupVAO_Mirroring];
            break;
      
        case ShaderStyleElectric:
            _program = [ShaderProgram programWithVertext:@"shader.vsh" fragment:@"shader_electric.fsh"];
            [self setupVAO_Electric];
            break;
            
       case ShaderStyleSudoku:
            _program = [ShaderProgram programWithVertext:@"shader_sudoku.vsh" fragment:@"shader_sudoku.fsh"];
            [self setVBO_Sudoku];
            break;
     
        case ShaderStyleDim:
            dimProgram = [ShaderProgram programWithVertext:@"shader.vsh" fragment:@"shader_dim.fsh"];
            _program = [ShaderProgram programWithVertext:@"shader.vsh" fragment:@"shader.fsh"];

            [self setupVBO_dim];
            break;
            
        default:
            break;
    }
   [self setupTimer];
}

#pragma mark 定时器
//开始定时器刷新
- (void)setupTimer{
    link = [NSTimer scheduledTimerWithTimeInterval:1/20.0 target:self selector:@selector(updateTextureScale) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:link forMode:NSRunLoopCommonModes];
}

float getInterpolation(float input) {
    return (float)(cos((input + 1) * M_PI) / 2.0f) + 0.5f;
}

- (void)updateTextureScale{
    self.mScale = 1.0f + 0.5f * getInterpolation(self.mOffset);
    self.mOffset += 0.04f;
    if (self.mOffset > 1.0f) {
        self.mOffset = 0.0f;
    }
    
    linkTime ++;
    
    [self setupRender];
}

#pragma mark 渲染
- (void)setupRender{
    glViewport(0, 0, self.frame.size.width , self.frame.size.height );
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_TEST);
    
    switch (_shaderStyle) {
        case ShaderStyleSoulout:
            [self render_Soulout];
            break;
            
        case ShaderStyleMirroring:
            [self render_Mirroring];
            break;
            
       case ShaderStyleElectric:
            [self render_Electric];
            break;
            
        case ShaderStyleSudoku:
            [self render_Sudoku];
            break;
            
        case ShaderStyleDim:
            [self render_dim];
            break;
            
        default:
            break;
    }
    [self render];
}

- (void)render{
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark 电击
- (void)render_Electric{
    if (linkTime >60) {
        linkTime = 0;
    }
    GLuint time = glGetUniformLocation(_program, "time");
    glUniform1f(time, linkTime);
}

- (void)setupVAO_Electric{
    [self setupVAO_Soulout];
}

#pragma mark 灵魂出窍
- (void)render_Soulout{
    GLuint scale = glGetUniformLocation(_program, "scale");
    glUniform1f(scale, self.mScale);
}

- (void)setupVAO_Soulout{

    GLuint vertexbuffer;
    glGenBuffers(1, &vertexbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(defaultVertexs), defaultVertexs, GL_DYNAMIC_DRAW);
    [self setupVertexAttrib];
}

#pragma mark 镜像
//渲染镜像
- (void)render_Mirroring{
    for (int i =0 ;i < MirroringNum;i++){
        //绑定VAO
        glBindVertexArray(VAO_Mirroring[i]);
        [self render];
    }
}

//镜像VAO
- (void)setupVAO_Mirroring{

    GLfloat vertexs0[] = {
        -1,0,0,     0,0,
        0,0,0,     1,0,
        0,1,0,      1,1,
        -1,1,0,     0,1
    };
    
    GLfloat vertexs1[] = {
       0,0,0,       1,0,
        1,0,0,      0,0,
        1,1,0,      0,1,
        0,1,0,      1,1
    };
    
    GLfloat vertexs2[] = {
        -1,-1,0,    0,1,
        0,-1,0,     1,1,
        0,0,0,      1,0,
        -1,0,0,     0,0
    };
    
    GLfloat vertexs3[] = {
        0,-1,0,     1,1,
        1,-1,0,     0,1,
        1,0,0,      0,0,
        0,0,0,      1,0
    };
    
    //用到多组顶点数据，采用VAO绑定这些数据
    //申请VAO数组标识
    glGenVertexArrays(MirroringNum, VAO_Mirroring);
    
    //VBO标识
    glGenBuffers(MirroringNum, vertextBuffer_Mirroring);
    
    for(int i = 0; i < MirroringNum;i++){
        //绑定VAO
        glBindVertexArray(VAO_Mirroring[i]);
        //绑定VBO
        glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer_Mirroring[i]);

        if (i == 0) {
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs0), vertexs0, GL_DYNAMIC_DRAW);
        } else if(i==1){
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs1), vertexs1, GL_DYNAMIC_DRAW);
        } else if(i==2){
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs2), vertexs2, GL_DYNAMIC_DRAW);
        } else if(i==3){
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs3), vertexs3, GL_DYNAMIC_DRAW);
        }
        
        [self setupVertexAttrib];
    }
}

#pragma mark 九宫格
-(void)render_Sudoku{

    for (int i =0 ;i < SudokuNum;i++){
        //绑定VAO
        glBindVertexArray(VAO_Sudoku[i]);

        [self render];
    }
}

- (void)setVBO_Sudoku{
    
    //用到多组顶点数据，采用VAO绑定这些数据
    //申请VAO数组标识
    glGenVertexArrays(SudokuNum, VAO_Sudoku);
    
    //VBO标识
    glGenBuffers(SudokuNum, vertextBuffer_Sudoku);
    
    
    glBindVertexArray(VAO_Sudoku[0]);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer_Sudoku[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(defaultVertexs), defaultVertexs, GL_DYNAMIC_DRAW);
    [self setupVertexAttrib];

    GLfloat wh = 2/3.0;
    for(int i = 1; i < SudokuNum;i++){
        
        int row = (i-1)/3;
        int colunm = (i-1)%3;
        
        GLfloat x1,x2,y1,y2;
        y1 = (row==0)?1-wh:((row==1)?-1+wh:-1);
        y2 = y1 + wh;

        x1 = (colunm==0)?-1:((colunm==1)?wh-1:1-wh);
        x2 = x1 + wh;
        GLfloat vertexs0[] = {
            x1,y1,0,     0,0,
            x2,y1,0,     1,0,
            x2,y2,0,      1,1,
           x1,y2,0,     0,1
        };
        
        //绑定VAO
        glBindVertexArray(VAO_Sudoku[i]);

        glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer_Sudoku[i]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs0), vertexs0, GL_DYNAMIC_DRAW);

        [self setupVertexAttrib];
    }
}

#pragma mark 镜像模糊
-(void)render_dim{
    //先绘制模糊底图
    glUseProgram(dimProgram);
    glBindVertexArray(VAO_Dim[0]);
    [self render];
    
    glUseProgram(_program);

    for (int i = 1; i < DimNum; i++) {
        glBindVertexArray(VAO_Dim[i]);
        [self render];
    }
}

- (void)setupVBO_dim{

    glGenVertexArrays(DimNum, VAO_Dim);
    glGenBuffers(DimNum, vertextBuffer_Dim);
    
    glBindVertexArray(VAO_Dim[0]);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer_Dim[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(defaultVertexs), defaultVertexs, GL_STATIC_DRAW);
    
    //获取顶点着色器属性position
    GLuint  position = glGetAttribLocation(dimProgram, "position");
    //开启position读取，
    glEnableVertexAttribArray(position);
    //position数据读取格式
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+0);
    
    GLuint textureCoor = glGetAttribLocation(dimProgram, "textureCoor");
    glEnableVertexAttribArray(textureCoor);
    glVertexAttribPointer(textureCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+3);

    GLfloat vertexs0[] = {
        -1,-0.5,0,     0,0,
        0,-0.5,0,     1,0,
        0,0.5,0,      1,1,
        -1,0.5,0,     0,1
    };
    
    GLfloat vertexs1[] = {
        0,-0.5,0,       1,0,
        1,-0.5,0,      0,0,
        1,0.5,0,      0,1,
        0,0.5,0,      1,1
    };
    
    for(int i = 1; i < DimNum;i++){
        //绑定VAO
        glBindVertexArray(VAO_Dim[i]);
        //绑定VBO
        glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer_Dim[i]);
        
       if(i==1){
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs0), vertexs0, GL_STATIC_DRAW);
        } else if(i==2){
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs1), vertexs1, GL_STATIC_DRAW);
        }
        
        [self setupVertexAttrib];
    }
}

#pragma mark 设置顶点属性
- (void)setupVertexAttrib{
    //获取顶点着色器属性position
    GLuint  position = glGetAttribLocation(_program, "position");
    //开启position读取，
    glEnableVertexAttribArray(position);
    //position数据读取格式
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+0);
    
    GLuint textureCoor = glGetAttribLocation(_program, "textureCoor");
    glEnableVertexAttribArray(textureCoor);
    glVertexAttribPointer(textureCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+3);
}

#pragma mark 渲染设置准备

- (void)setupBuffer{

    //渲染缓冲区
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage: GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    
    //帧缓冲区
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)setupLayer{
    //渲染图层
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    _eaglLayer.opaque = YES;
}

-(void)setupContext{
    //设置上下文
    _context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"context 设置失败");
        return;
    }
    NSLog(@"context 设置成功");
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}


- (void)setupTexture:(UIImage*)image{
    
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
    
    CGContextRef   cgcontext = CGBitmapContextCreate(imageData,
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
    CGContextClearRect( cgcontext, CGRectMake( 0, 0, width, height ) );
    //CTM--从用户空间和设备空间存在一个转换矩阵CTM
    /*
     CGContextTranslateCTM(CGContextRef cg_nullable c,
     CGFloat tx, CGFloat ty)
     参数1:上下文
     参数2:X轴上移动距离
     参数3:Y轴上移动距离
     */
    CGContextTranslateCTM(cgcontext, 0, height);
    //缩小
    CGContextScaleCTM (cgcontext, 1.0,-1.0);
    
    //绘制图片
    CGContextDrawImage( cgcontext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    //释放context
    CGContextRelease(cgcontext);

    GLuint textureID;
    //生成纹理标记
    glGenTextures(1, &textureID);
    
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    
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


- (void)distory{
    if (link) {
        [link invalidate];
    }
    link = nil;
    
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    _renderBuffer = 0;
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
    }
    _frameBuffer = 0;
    
    if (VAO_Mirroring) {
        glDeleteVertexArrays(MirroringNum, VAO_Mirroring);
    }
    if (vertextBuffer_Mirroring) {
        glDeleteVertexArrays(MirroringNum, vertextBuffer_Mirroring);
    }
    
    if (VAO_Sudoku) {
        glDeleteVertexArrays(SudokuNum, VAO_Sudoku);
    }
    if (vertextBuffer_Sudoku) {
        glDeleteVertexArrays(SudokuNum, vertextBuffer_Sudoku);
    }
    
    glBindVertexArray(0);
    
    if (_program) {
        glDeleteProgram(_program);
    }
    _program = 0;
    
    NSLog(@"%s",__func__);
}
@end
