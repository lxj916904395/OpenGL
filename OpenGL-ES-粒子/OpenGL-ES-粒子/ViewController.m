//
//  ViewController.m
//  OpenGL-ES-粒子
//
//  Created by zhongding on 2019/1/18.
//

#import "ViewController.h"
#import "ParticleEffect.h"

@interface ViewController ()
{
    EAGLContext *context;
    
}
@property (strong, nonatomic) NSArray *emitterBlocks;
@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;

@property (assign, nonatomic) NSInteger currentEmitterIndex;

@property(strong ,nonatomic)  ParticleEffect *effect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    GLKView *view = (GLKView*)self.view;
    view.context = context;
    
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:context];
    
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"ball.png" ofType:nil];
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:file options:nil error:nil];
    
    _effect = [[ParticleEffect alloc] init];
    _effect.texture.name = info.name;
    _effect.texture.target = info.target;
    
  
    
    float aspect = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);

    //设置透视投影方式
    _effect.tranform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(60.0f),
                              aspect,
                              0.1f,
                              20.0f);
    
    //模型视图变换矩阵
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
    
    _effect.tranform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 1.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    
    [self setupBlock];
    
}

- (void)setupBlock{
    //执行代码块.4种不同效果.
    void(^blockA)(void) = ^{
        
        self.autoSpawnDelta = 0.5f;
        
        //重力
        self.effect.gravity = DefaultGravity;
        
        //X轴上随机速度
        float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
        
        /*
         Position:出发位置
         velocity:速度
         force:抛物线
         size:大小
         lifeSpanSeconds:耗时
         fadeDurationSeconds:渐逝时间
         */
        [self.effect
         addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.9f)
         velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0f)
         force:GLKVector3Make(0.0f, 9.0f, 0.0f)
         size:6.0f
         lifeSpanSeconds:5.2f
         fadeDurationSeconds:0.5f];
    };
    
    void(^blockB)(void) = ^{
        self.autoSpawnDelta = 0.05f;
        
        //重力
        self.effect.gravity = GLKVector3Make(0.0f,0.5f, 0.0f);
        
        //一次创建多少个粒子
        int n = 50;
        
        for(int i = 0; i < n; i++)
        {
            //X轴速度
            float randomXVelocity = -0.1f + 0.5f *(float)random() / (float)RAND_MAX;
            
            //Y轴速度
            float randomZVelocity = 0.1f + 0.2f * (float)random() / (float)RAND_MAX;
            
            [self.effect
             addParticleAtPosition:GLKVector3Make(0.00f, -0.5f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     0.0,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:16.0f
             lifeSpanSeconds:2.2f
             fadeDurationSeconds:3.0f];
        }
        
    };
    
    void(^blockC)(void) = ^{
        self.autoSpawnDelta = 0.5f;
        
        //重力
        self.effect.gravity = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        int n = 100;
        for(int i = 0; i < n; i++)
        {
            //X,Y,Z速度
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            
            //创建粒子
            [self.effect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     randomYVelocity,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }
        
    };
    
    void(^blockD)(void) = ^{
        self.autoSpawnDelta = 3.2f;
        
        //重力
        self.effect.gravity = GLKVector3Make(0.0f, 0.0f, 0.0f);
        
        int n = 100;
        for(int i = 0; i < n; i++)
        {
            //X,Y速度
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            
            
            //GLKVector3Normalize 计算法向量
            //计算速度与方向
            GLKVector3 velocity = GLKVector3Normalize( GLKVector3Make(
                                                                      randomXVelocity,
                                                                      randomYVelocity,
                                                                      0.0f));
            
            [self.effect
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:velocity
             force:GLKVector3MultiplyScalar(velocity, -1.5f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.1f];
        }
        
    };
    
    //将4种不同效果的BLOCK块存储到数组中
    self.emitterBlocks = @[[blockA copy],[blockB copy],[blockC copy],[blockD copy]];
}


- (void)update{
    //时间间隔
    NSTimeInterval timeElapsed = self.timeSinceFirstResume;
    
    /*
     //上一次更新时间
     NSLog(@"timeSinceLastUpdate: %f", self.timeSinceLastUpdate);
     //上一次绘制的时间
     NSLog(@"timeSinceLastDraw: %f", self.timeSinceLastDraw);
     //第一次恢复时间
     NSLog(@"timeSinceFirstResume: %f", self.timeSinceFirstResume);
     //上一次恢复时间
     NSLog(@"timeSinceLastResume: %f", self.timeSinceLastResume);
     */
    //消耗时间
    self.effect.elapsedSeconds = timeElapsed;
    
    //动画时间 < 当前时间与上一次更新时间
    if(self.autoSpawnDelta < (timeElapsed - self.lastSpawnTime))
    {
        //更新上一次更新时间
        self.lastSpawnTime = timeElapsed;
        
        //获取当前选择的block
        void(^emitterBlock)(void) = [self.emitterBlocks objectAtIndex: self.currentEmitterIndex];
        
        //执行block
        emitterBlock();
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    [_effect prepareDraw];
    [_effect draw];
}

- (IBAction)changeIndex:(UIButton*)sender {
    self.currentEmitterIndex = sender.tag;
}



@end
