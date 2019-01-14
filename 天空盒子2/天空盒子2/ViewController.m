//
//  ViewController.m
//  天空盒子2
//
//  Created by zhongding on 2019/1/14.
//

#import "ViewController.h"

#import "SkyEffect.h"
#import "starship.h"
#import "ImageTailor.h"

@interface ViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *baseEffect;
    SkyEffect *skyEffect;
    
    GLuint VAO;
    
    CGFloat angle;
    
    GLKVector3 eyeP;
    GLKVector3 lookAtP;
    GLKVector3 upP;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    
    angle = 5;
    eyeP = GLKVector3Make(0, 10, 0);
    lookAtP = GLKVector3Make(0, 0, 0);
    upP = GLKVector3Make(0, 1, 0);
    
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    GLKView *view = (GLKView*)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:context];
    
    [self setBaseEffect];
    [self setSkyEffect];
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
}

- (void)setBaseEffect{
    
    baseEffect = [[GLKBaseEffect alloc] init];
    baseEffect.light0.enabled = YES;
    baseEffect.light0.diffuseColor = GLKVector4Make(0.75f, 0.75f, 0.75f, 1.0f);
    //镜面反射颜色
    baseEffect.light0.specularColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
    //光源位置
    baseEffect.light0.position = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
    baseEffect.lightingType = GLKLightingTypePerPixel;
    
    [self setBuffer];
    [self setMatrix];
}

- (void)setBuffer{
    
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    GLuint buffer;
    
    //顶点数据
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipPositions), starshipPositions, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat*)NULL +0);
    
    
    //法线数据
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipNormals), starshipNormals, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat*)NULL+0);
    
}

- (void)setMatrix{
    
    CGFloat aspect = self.view.frame.size.width/self.view.frame.size.height;
    baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85), aspect, 0.1, 20);
    
    baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(eyeP.x, eyeP.y, eyeP.z, lookAtP.x, lookAtP.y, lookAtP.z, upP.x, upP.y, upP.z);
    
    angle += 0.01;
    
    eyeP = GLKVector3Make(-5*sin(angle), -5, -5*cos(angle));
    lookAtP = GLKVector3Make(0.0,1.5 + -5.0f * sinf(0.3 * angle),0.0);
}

- (void)setSkyEffect{
    skyEffect = [[SkyEffect alloc] init];
    
    skyEffect.xsize = skyEffect.ysize = skyEffect.zsize = 6;
    
    NSString *path = [ImageTailor imageTailorWithFile:@"skybox3.jpg" rowCount:4];
    GLKTextureInfo *info = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:nil];

    skyEffect.textureCube.name = info.name;
    skyEffect.textureCube.target = info.target;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(0.2, 0.3, 0.4, 1);
    
    [self setMatrix];
    
    skyEffect.center = eyeP;
    skyEffect.transform.modelviewMatrix = baseEffect.transform.modelviewMatrix;
    skyEffect.transform.projectionMatrix = baseEffect.transform.projectionMatrix;
    
    [skyEffect prepareDraw];
    
    glDepthMask(false);
    [skyEffect draw];
    glDepthMask(true);
    
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
//    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    
    glBindVertexArrayOES(VAO);
    
    
      //starshipMaterials 飞船材料
    for(int i=0; i<starshipMaterials; i++)
    {
        //设置材质的漫反射颜色
        baseEffect.material.diffuseColor = GLKVector4Make(starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2], 1.0f);
        
        //设置反射光颜色
        baseEffect.material.specularColor = GLKVector4Make(starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2], 1.0f);
        
        //飞船准备绘制
        [baseEffect prepareToDraw];
        
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
