//
//  ViewController.m
//  OpenGL-ES-005-光照
//
//  Created by zhongding on 2019/1/10.
//

#import "ViewController.h"

#import "AGLKVertexAttribArrayBuffer.h"
#import "sceneUtil.h"
#import "ShaderUtil.h"

@interface ViewController (){
    AGLKVertexAttribArrayBuffer *vertexBuffer;
    AGLKVertexAttribArrayBuffer *extraBuffer;
    
    //三角形面的个数
    SceneTriangle triangles[NUM_FACES];
}

@property(strong ,nonatomic) EAGLContext *context;
@property(strong ,nonatomic) GLKBaseEffect *baseEffect;
@property(strong ,nonatomic) GLKBaseEffect *extraEffect;

@property(assign ,nonatomic)  GLfloat vertexHeight;;
//是否使用面法线
@property(nonatomic,assign)BOOL shouldUseFaceNormals;

//是否绘制法线
@property(nonatomic,assign)BOOL shouldDrawNormals;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup{
    _context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    GLKView *view = (GLKView*)self.view;
    view.context = _context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:_context];
    
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(1, 0, 0, 1);
    _baseEffect.light0.position = GLKVector4Make(1, 1, 0,0);
    
    _extraEffect = [[GLKBaseEffect alloc] init];
    _extraEffect.useConstantColor = GL_TRUE;

    //调整模型矩阵，更好的观察
    //可以尝试不执行这段代码，改为false
    if (true) {
        //围绕x轴旋转-60度
        //返回一个4x4矩阵进行绕任意矢量旋转
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        
        //围绕z轴，旋转-30度
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        
        //围绕Z方向，移动0.25f
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
        
        //设置baseEffect,extraEffect 模型矩阵
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
        
    }
    
    
    //通过3个顶点确定面
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    //申请、绑定顶点数据缓冲区
    vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    
   
    //申请、绑定法线数据
    extraBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    
    self.vertexHeight = 0;
    self.shouldUseFaceNormals = YES;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.2,0.6, 0.6, 1);
    glClear(GL_COLOR_BUFFER_BIT);
     

     [_baseEffect prepareToDraw];
    
    //准备绘制顶点    //准备绘制顶点数据
    [vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex,position)shouldEnable:YES];
    
    //准备绘制光照数据
    [vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, normal) shouldEnable:YES];
    
    [vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];

    if(self.shouldDrawNormals)
        [self drawNormals];
}

//绘制法线
- (void)drawNormals{
    
 
    GLKVector3 normalLineVertices[NUM_LINE_VERTS];
    
    //以每个顶点的坐标为起点，顶点坐标加上法向量的偏移值作为终点，更新法线显示数组
    //参数1.三角形数组
    //参数2：光源位置
    //参数3：法线显示的顶点数组
    SceneTrianglesNormalLinesUpdate(triangles, GLKVector3MakeWithArray(self.baseEffect.light0.position.v), normalLineVertices);
    
    //为extraBuffer重新开辟空间
    [extraBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:NUM_LINE_VERTS bytes:normalLineVertices];
    
    //准备绘制数据
    [extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    /*
     指示是否使用常量颜色的布尔值。
     如果该值设置为gl_true，然后存储在设置属性的值为每个顶点的颜色值。如果该值设置为gl_false，那么你的应用将使glkvertexattribcolor属性提供每顶点颜色数据。默认值是gl_false。
     */
    self.extraEffect.useConstantColor = GL_TRUE;
    //设置光源颜色为绿色，画顶点法线
    self.extraEffect.constantColor = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
    
    //准备绘制-绿色的法线
    [self.extraEffect prepareToDraw];
    
    //绘制线段
    [extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:NUM_NORMAL_LINE_VERTS];
    
    //设置光源颜色为黄色，并且画光源线
    //Red+Green =Yellow
    self.extraEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f);
    
    //准备绘制-黄色的光源方向线
    [self.extraEffect prepareToDraw];
    
    //(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS) = 2 .2点确定一条线
    [extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:NUM_NORMAL_LINE_VERTS numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
}


//更新塔尖顶点的z值
- (void)setVertexHeight:(GLfloat)vertexHeight{
    _vertexHeight = vertexHeight;
    
    //更新顶点 E
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = vertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
     [self updateNormals];
}

//更新法向量
-(void)updateNormals
{
    if (self.shouldUseFaceNormals) {
        //更新每个点的平面法向量
        SceneTrianglesUpdateFaceNormals(triangles);
    }else
    {
        //通过平均值求出每个点的法向量
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    [vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles];
    
    
}

-(void)setShouldUseFaceNormals:(BOOL)shouldUseFaceNormals
{
    if (shouldUseFaceNormals != _shouldUseFaceNormals) {
        
        _shouldUseFaceNormals = shouldUseFaceNormals;
        
        [self updateNormals];
    }
}

- (IBAction)useFaceNormal:(UISwitch*)sender {
    self.shouldUseFaceNormals = sender.on;
}

- (IBAction)useNormal:(UISwitch*)sender {
    self.shouldDrawNormals = sender.on;
}

- (IBAction)changeHeight:(UISlider*)sender {
    self.vertexHeight = sender.value;
}

@end
