//
//  ViewController.m
//  OpenGL-ES-006-天空盒子
//
//  Created by lxj on 2019/1/12.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "ViewController.h"

#import "ImageTailor.h"
#import "SkyboxEffect.h"
#import "starship.h"


@interface ViewController (){
    
    GLKVector3 eyePosition;
    GLKVector3 lookAtPosition;
    GLKVector3 upPosition;
    
    //旋转角度
    GLfloat angle;
    
    GLuint positionBuffer;
    
}

@property (strong ,nonatomic) GLKBaseEffect *baseEffect;
@property (strong ,nonatomic) SkyboxEffect *skyEffect;

@property (strong ,nonatomic) EAGLContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup{
    
    //旋转角度
    angle = 5;
    
    //相机(观察者)在世界坐标系的位置 第一组:就是眼睛的位置
    eyePosition = GLKVector3Make(0, 10, 0);
    //观察者观察的物体在世界坐标系的位置 第二组:就是眼睛所看物体的位置
    lookAtPosition = GLKVector3Make(0, 0, 0);
    //观察者向上的方向的世界坐标系的方向.第三组:就是头顶朝向的方向(因为你可以头歪着的状态看物体)
    upPosition = GLKVector3Make(0,1, 0);
    
    
    _context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    GLKView *view = (GLKView*)self.view;
    view.context = _context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:_context];
    
    [self setupBaseEffect];

    [self setupSkyEffect];

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
}

- (void)setBuffer{
    
    //==============顶点数据
    
    glGenVertexArraysOES(1, &positionBuffer);
    glBindVertexArrayOES(positionBuffer);
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    //将缓存对象对应到相应的缓存上
    /*
     glBindBuffer (GLenum target, GLuint buffer);
     target:告诉VBO缓存对象时保存顶点数组数据还是索引数组数据 :GL_ARRAY_BUFFER\GL_ELEMENT_ARRAY_BUFFER
     任何顶点属性，如顶点坐标、纹理坐标、法线与颜色分量数组都使用GL_ARRAY_BUFFER。用于glDraw[Range]Elements()的索引数据需要使用GL_ELEMENT_ARRAY绑定。注意，target标志帮助VBO确定缓存对象最有效的位置，如有些系统将索引保存AGP或系统内存中，将顶点保存在显卡内存中。
     buffer: 缓存区对象
     */
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
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
    //starshipPositions 飞机模型的顶点数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipPositions), starshipPositions, GL_DYNAMIC_DRAW);
    
    //出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的，意味着数据在着色器端是不可见的，哪怕数据已经上传到GPU，由glEnableVertexAttribArray启用指定属性，才可在顶点着色器中访问逐顶点的属性数据.
    //VBO只是建立CPU和GPU之间的逻辑连接，从而实现了CPU数据上传至GPU。但是，数据在GPU端是否可见，即，着色器能否读取到数据，由是否启用了对应的属性决定，这就是glEnableVertexAttribArray的功能，允许顶点着色器读取GPU（服务器端）数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    //顶点数据传入GPU之后，还需要通知OpenGL如何解释这些顶点数据，这个工作由函数glVertexAttribPointer完成
    /*
     glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
     indx:参数指定顶点属性位置
     size:指定顶点属性大小
     type:指定数据类型
     normalized:数据被标准化
     stride:步长
     ptr:偏移量
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat*)NULL+0);
    
    //===============绑定法线数据
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipNormals), starshipNormals, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat*)NULL+0);
}


//baseeffect 用于显示飞机
- (void)setupBaseEffect{
    _baseEffect = [[GLKBaseEffect alloc] init];
    //开启光照
    _baseEffect.light0.enabled = YES;
    //漫反射颜色
    _baseEffect.light0.diffuseColor = GLKVector4Make(0.75f, 0.75f, 0.75f, 1.0f);
    //镜面反射颜色
    _baseEffect.light0.specularColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
    //光源位置
    _baseEffect.light0.position = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
    //反射光的颜色
    //光照策略
    //GLKLightingTypePerVertex:表示在三角形的每个顶点执行照明计算，然后在三角形中插值。
    //GLKLightingTypePerPixel指示对照明计算的输入在三角形内进行插值，并在每个片段上执行照明计算。
    _baseEffect.lightingType = GLKLightingTypePerVertex;
    
    [self setBuffer];
    [self setMatrix];
  
}

//skyeffect 用于显示天空
- (void)setupSkyEffect{
    _skyEffect = [[SkyboxEffect alloc] init];
    
    //获取纹理贴图信息
    NSString *path = [ImageTailor imageTailorWithFile:@"skybox3.jpg" rowCount:4];
    GLKTextureInfo *textureInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:nil];
    
    _skyEffect.textureCube.name = textureInfo.name;
    _skyEffect.textureCube.target = textureInfo.target;
    
    _skyEffect.zsize =
    _skyEffect.ysize =
    _skyEffect.xsize = 3;
}


- (void)setMatrix{
    
    float aspect = self.view.frame.size.width/self.view.frame.size.height;
    
    //投影矩阵
    _baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85), aspect, 0.1, 20);
    
    //获取世界坐标系去模型矩阵中.
    /*
     LKMatrix4 GLKMatrix4MakeLookAt(float eyeX, float eyeY, float eyeZ,
     float centerX, float centerY, float centerZ,
     float upX, float upY, float upZ)
     等价于 OpenGL 中
     void gluLookAt(GLdouble eyex,GLdouble eyey,GLdouble eyez,GLdouble centerx,GLdouble centery,GLdouble centerz,GLdouble upx,GLdouble upy,GLdouble upz);
     
     目的:根据你的设置返回一个4x4矩阵变换的世界坐标系坐标。
     参数1:眼睛位置的x坐标
     参数2:眼睛位置的y坐标
     参数3:眼睛位置的z坐标
     第一组:就是脑袋的位置
     
     参数4:正在观察的点的X坐标
     参数5:正在观察的点的Y坐标
     参数6:正在观察的点的Z坐标
     第二组:就是眼睛所看物体的位置
     
     参数7:摄像机上向量的x坐标
     参数8:摄像机上向量的y坐标
     参数9:摄像机上向量的z坐标
     第三组:就是头顶朝向的方向(因为你可以头歪着的状态看物体)
     */
    
    _baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, lookAtPosition.x, lookAtPosition.y, lookAtPosition.z, upPosition.x, upPosition.y, upPosition.z);
    
    angle +=0.01;
    
     // 调整眼睛的位置
    eyePosition = GLKVector3Make(-5*sin(angle), -5, -5*cos(angle));
    // 调整观察的位置
    lookAtPosition = GLKVector3Make(0.0,1.5 + -5.0f * sinf(0.3 * angle),0.0);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClearColor(0.5f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self setMatrix];
    
    _skyEffect.center = eyePosition;
    _skyEffect.transform.projectionMatrix = _baseEffect.transform.projectionMatrix;
    _skyEffect.transform.modelviewMatrix = _baseEffect.transform.modelviewMatrix;
    
    [_skyEffect preparDraw];
    
    /*
     1. 深度缓冲区
     
     深度缓冲区原理就是把一个距离观察平面(近裁剪面)的深度值(或距离)与窗口中的每个像素相关联。
     
     
     1> 首先使用glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)来打开DEPTH_BUFFER
     void glutInitDisplayMode(unsigned int mode);
     
     2>  每帧开始绘制时，须清空深度缓存 glClear(GL_DEPTH_BUFFER_BIT); 该函数把所有像素的深度值设置为最大值(一般是远裁剪面)
     
     3> 必要时调用glDepthMask(GL_FALSE)来禁止对深度缓冲区的写入。绘制完后在调用glDepthMask(GL_TRUE)打开DEPTH_BUFFER的读写（否则物体有可能显示不出来）
     
     注意：只要存在深度缓冲区，无论是否启用深度测试（GL_DEPTH_TEST），OpenGL在像素被绘制时都会尝试将深度数据写入到缓冲区内，除非调用了glDepthMask(GL_FALSE)来禁止写入。
     在绘制天空盒子的时候,禁止深度缓冲区
     */
    glDepthMask(false);
    [_skyEffect draw];
    glDepthMask(true);
    
        //将缓存区\纹理都清空
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    
    
    // 需要重新设置顶点数据，不需要缓存
    /*
     很多应用会在同一个渲染帧调用多次glBindBuffer()、glEnableVertexAttribArray()和glVertexAttribPointer()函数（用不同的顶点属性来渲染多个对象）
     新的顶点数据对象(VAO) 扩展会几率当前上下文中的与顶点属性相关的状态，并存储这些信息到一个小的缓存中。之后可以通过单次调用glBindVertexArrayOES() 函数来恢复，不需要在调用glBindBuffer()、glEnableVertexAttribArray()和glVertexAttribPointer()。
     */
    glBindVertexArrayOES(positionBuffer);
    
    // 绘制飞船
    //starshipMaterials 飞船材料
    for(int i=0; i<starshipMaterials; i++)
    {
        //设置材质的漫反射颜色
        self.baseEffect.material.diffuseColor = GLKVector4Make(starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2], 1.0f);
        
        //设置反射光颜色
        self.baseEffect.material.specularColor = GLKVector4Make(starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2], 1.0f);
        
        //飞船准备绘制
        [self.baseEffect prepareToDraw];
        
        //绘制
        /*
         glDrawArrays (GLenum mode, GLint first, GLsizei count);提供绘制功能。当采用顶点数组方式绘制图形时，使用该函数。该函数根据顶点数组中的坐标数据和指定的模式，进行绘制。
         参数列表:
         mode，绘制方式，OpenGL2.0以后提供以下参数：GL_POINTS、GL_LINES、GL_LINE_LOOP、GL_LINE_STRIP、GL_TRIANGLES、GL_TRIANGLE_STRIP、GL_TRIANGLE_FAN。
         first，从数组缓存中的哪一位开始绘制，一般为0。
         count，数组中顶点的数量。
         */
        glDrawArrays(GL_TRIANGLES, starshipFirsts[i], starshipCounts[i]);
    }
}
@end
