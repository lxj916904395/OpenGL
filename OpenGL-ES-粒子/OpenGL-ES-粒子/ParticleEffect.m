//
//  ParticleEffect.m
//  OpenGL-ES-粒子
//
//  Created by zhongding on 2019/1/18.
//

#import "ParticleEffect.h"
#import "ZFVertexAttribsBuffer.h"

//
//                       _o666o_
//                      o8888888o
//                      88" . "88
//                      (| -_- |)
//                      0\  =  /0
//                    ___/`---'\___
//                  .' \|     |// '.
//                 / \|||  :  |||// \
//                / _||||| -:- |||||- \
//               |   | \  -  /// |     |
//               | \_|  ''\---/''  |_/ |
//               \  .-\__  '-'  ___/-. /
//             ___'. .'  /--.--\  `. .'___
//          ."" '<  `.___\_<|>_/___.' >' "".
//         | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//         \  \ `_.   \_ __\ /__ _/   .-` /  /
//     66666`-.____`.___ \_____/___.-`___.-'66666
//                       88888
//
//
//     666666666666666666666666666666666666666666
//
//               佛祖保佑         永无BUG
//

//自定义粒子数据结构体
typedef struct {
    //发射位置
    GLKVector3 emissionPosition;
    GLKVector3 emissionVelocity;//发射速度
    GLKVector3 emissionGravity;//发射重力
    GLKVector2 emissionSize;//发射尺寸
    GLKVector2 emissionTimeAndLife;//发射时间与寿命
}ParticleAttributes;

//顶点着色器属性标识符
typedef enum {
    ParticleEmissionPosition = 0,//粒子发射位置
    ParticleEmissionVelocity,//粒子发射速度
    ParticleEmissiongravity,//粒子发射重力
    ParticleSize,//粒子发射大小
    ParticleEmissionTimeAndLife,//粒子发射时间和寿命
} VertexParticleAttrib;


//GLSL程序Uniform 参数
typedef enum
{
    PariticleMVPMatrix,//MVP矩阵
    PariticleSamplers2D,//Samplers2D纹理
    PariticleElapsedSeconds,//耗时
    PariticleGravity,//重力
    PariticleNumUniforms//Uniforms个数
}ParticleUniforms;


@interface ParticleEffect ()
{
    GLuint program;
    NSMutableData *particleData;
    GLint uniforms[PariticleNumUniforms];//Uniforms数组
    
    ZFVertexAttribsBuffer * particleBuffer;
}
//是否更新粒子数据
@property (nonatomic, assign, readwrite) BOOL particleDataWasUpdated;
//粒子个数
@property (nonatomic, assign, readonly) NSUInteger numberOfParticles;
@end

@implementation ParticleEffect

- (instancetype)init{
    if ( self = [super init]) {
        
        _texture = [[GLKEffectPropertyTexture alloc] init];
        _texture.name = 0;
        _texture.target = GLKTextureTarget2D;
        _texture.enabled = YES;
        _texture.envMode = GLKTextureEnvModeReplace;
        
        _tranform = [[GLKEffectPropertyTransform alloc] init];
        
        particleData = [NSMutableData new];
    }
    return self;
}

#pragma mark ***************** 绘制

- (void)prepareDraw{
    if (!program) {
        [self loadProgram];
    }
    
    if (program) {
        glUseProgram(program);
        
        GLKMatrix4 modelviewProjectionMatrix = GLKMatrix4Multiply(_tranform.projectionMatrix, _tranform.modelviewMatrix);
        //顶点着色器mvp矩阵传值
        glUniformMatrix4fv(uniforms[PariticleMVPMatrix], 1, 0,modelviewProjectionMatrix.m);

        // 一个纹理采样均匀变量
        /*
         glUniform1f(GLint location,  GLfloat v0);
         
         location:指明要更改的uniform变量的位置
         v0:指明在指定的uniform变量中要使用的新值
         */
        glUniform1f(uniforms[PariticleSamplers2D], 0);
        
        //粒子物理值
        //重力
        /*
         void glUniform3fv(GLint location,  GLsizei count,  const GLfloat *value);
         参数列表：
         location:指明要更改的uniform变量的位置
         count:指明要更改的向量个数
         value:指明一个指向count个元素的指针，用来更新指定的uniform变量。
         
         */
        glUniform3fv(uniforms[PariticleGravity], 1, self.gravity.v);
        
        //耗时
        glUniform1fv(uniforms[PariticleElapsedSeconds], 1, &_elapsedSeconds);
        
        //粒子数据更新
        if(self.particleDataWasUpdated)
        {
            //缓存区为空,且粒子数据大小>0
            if(particleBuffer == nil && [particleData length] > 0)
                
            {  // 顶点属性没有送到GPU
                //初始化缓存区
                /*
                 1.数据大小  sizeof(CCParticleAttributes)
                 2.数据个数 (int)[self.particleAttributesData length] /
                 sizeof(CCParticleAttributes)
                 3.数据源  [self.particleAttributesData bytes]
                 4.用途 GL_DYNAMIC_DRAW
                 */
                
                //数据大小
                GLsizeiptr size = sizeof(ParticleAttributes);
                //个数
                int count = (int)[particleData length] /
                sizeof(ParticleAttributes);
                
                particleBuffer =
                [[ZFVertexAttribsBuffer alloc]
                 initWithAttribStride:size
                 numberOfVertices:count
                 bytes:[particleData bytes]
                 usage:GL_DYNAMIC_DRAW];
            }
            else
            {
                //如果已经开辟空间,则接收新的数据
                /*
                 1.数据大小 sizeof(CCParticleAttributes)
                 2.数据个数  (int)[self.particleAttributesData length] /
                 sizeof(CCParticleAttributes)
                 3.数据源 [self.particleAttributesData bytes]
                 */
                
                //数据大小
                GLsizeiptr size = sizeof(ParticleAttributes);
                //个数
                int count = (int)[particleData length] /
                sizeof(ParticleAttributes);
                
                [particleBuffer
                 reinitWithAttribStride:size
                 numberOfVertices:count
                 bytes:[particleData bytes]];
            }
            
            //恢复更新状态为NO
            self.particleDataWasUpdated = NO;
        }
        
        //准备顶点数据
        [particleBuffer
         prepareToDrawWithAttrib:ParticleEmissionPosition
         numberOfCoordinates:3
         attribOffset:
         offsetof(ParticleAttributes, emissionPosition)
         shouldEnable:YES];
        
        //准备粒子发射速度数据
        [particleBuffer
         prepareToDrawWithAttrib:ParticleEmissionVelocity
         numberOfCoordinates:3
         attribOffset:
         offsetof(ParticleAttributes, emissionVelocity)
         shouldEnable:YES];
        
        //准备重力数据
        [particleBuffer
         prepareToDrawWithAttrib:ParticleEmissiongravity
         numberOfCoordinates:3
         attribOffset:
         offsetof(ParticleAttributes, emissionGravity)
         shouldEnable:YES];
        
        //准备粒子size数据
        [particleBuffer
         prepareToDrawWithAttrib:ParticleSize
         numberOfCoordinates:2
         attribOffset:
         offsetof(ParticleAttributes, emissionSize)
         shouldEnable:YES];
        
        //准备粒子的持续时间和渐隐时间数据
        [particleBuffer
         prepareToDrawWithAttrib:ParticleEmissionTimeAndLife
         numberOfCoordinates:2
         attribOffset:
         offsetof(ParticleAttributes, emissionTimeAndLife)
         shouldEnable:YES];
        
        //将所有纹理绑定到各自的单位
        /*
         void glActiveTexture(GLenum texUnit);
         
         该函数选择一个纹理单元，线面的纹理函数将作用于该纹理单元上，参数为符号常量GL_TEXTUREi ，i的取值范围为0~K-1，K是OpenGL实现支持的最大纹理单元数，可以使用GL_MAX_TEXTURE_UNITS来调用函数glGetIntegerv()获取该值
         
         可以这样简单的理解为：显卡中有N个纹理单元（具体数目依赖你的显卡能力），每个纹理单元（GL_TEXTURE0、GL_TEXTURE1等）都有GL_TEXTURE_1D、GL_TEXTURE_2D等
         */
        glActiveTexture(GL_TEXTURE0);
        
        if(_texture.name && _texture.enabled){
            glBindTexture(GL_TEXTURE_2D, _texture.name);
        }else{
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }
}

- (void)draw{
    //禁用深度缓冲区写入
    glDepthMask(GL_FALSE);
    
    //绘制
    /*
     1.模式
     2.开始的位置
     3.粒子个数
     */
    [particleBuffer drawArrayWithMode:GL_POINTS startVertexIndex:0 numberOfVertices:(int)self.numberOfParticles];
    
    //启用深度缓冲区写入
    glDepthMask(GL_TRUE);
}

#pragma mark ***************** 粒子设置

- (ParticleAttributes)particleAtIndex:(NSInteger)index{
    //bytes:指向接收者内容的指针
    //获取粒子属性结构体内容
    ParticleAttributes *p  =  (ParticleAttributes*)[particleData bytes];
    return p[index];
}

- (void)setParticle:(ParticleAttributes)particle index:(NSInteger)index{
    //mutableBytes:指向可变数据对象所包含数据的指针
    //获取粒子属性结构体内容
    ParticleAttributes *p = (ParticleAttributes*)[particleData mutableBytes];
    p[index] = particle;
    
    //更改粒子状态! 是否更新
    self.particleDataWasUpdated = YES;
}

- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration{
    
    ParticleAttributes particle ;
    particle.emissionPosition = aPosition;
    particle.emissionSize = GLKVector2Make(aSize, aDuration);
    particle.emissionGravity = aForce;
    particle.emissionVelocity = aVelocity;

    //向量(耗时,发射时长)
    particle.emissionTimeAndLife = GLKVector2Make(_elapsedSeconds, _elapsedSeconds + aSpan);
    
    BOOL foundSlot = NO;

    long count = self.numberOfParticles;
    
    for (int i = 0; i < count &&!foundSlot ; i++){
        
        ParticleAttributes older = [self particleAtIndex:i];
        
        //如果旧的例子的发射时长 小于 耗时,则该粒子已经消失，替换s新的粒子
        if (older.emissionTimeAndLife.y < _elapsedSeconds) {
            [self setParticle:particle index:i];
            //是否替换
            foundSlot = YES;
        }
    }
    
    //发射出去的粒子都没有消亡，都还显示在屏幕上，则添加新的粒子
    if(!foundSlot){
        [particleData appendBytes:&particle length:sizeof(particle)];
        //粒子数据是否更新
        self.particleDataWasUpdated = YES;
    }
}

//获取粒子个数
- (NSUInteger)numberOfParticles{
    long count = [particleData length]/sizeof(ParticleAttributes);
    return count;
}
#pragma mark *****************load shader

- (void)loadProgram{
    GLuint vshader,fshader;
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    
    [self compileShader:&vshader type:GL_VERTEX_SHADER file:vfile];
    [self compileShader:&fshader type:GL_FRAGMENT_SHADER file:ffile];
    
    program = glCreateProgram();
    
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    
    [self bindAttribs];
    [self linkProgram];
    [self bindUniforms];
    
    if (vshader)
    {
        glDetachShader(program, vshader);
        glDeleteShader(vshader);
    }
    if (fshader)
    {
        glDetachShader(program, fshader);
        glDeleteShader(fshader);
    }
}

- (void)bindAttribs{
    //位置
    glBindAttribLocation(program, ParticleEmissionPosition,
                         "a_emissionPosition");
    //速度
    glBindAttribLocation(program, ParticleEmissionVelocity,
                         "a_emissionVelocity");
    //重力
    glBindAttribLocation(program, ParticleEmissiongravity,
                         "a_emissionForce");
    //大小
    glBindAttribLocation(program, ParticleSize,
                         "a_size");
    //持续时间、渐隐时间
    glBindAttribLocation(program, ParticleEmissionTimeAndLife,
                         "a_emissionAndDeathTimes");
}

- (void)bindUniforms{
    // 获取uniform变量的位置.
    //MVP变换矩阵
    uniforms[PariticleMVPMatrix] = glGetUniformLocation(program,"u_mvpMatrix");
    //纹理
    uniforms[PariticleSamplers2D] = glGetUniformLocation(program,"u_samplers2D");
    //重力
    uniforms[PariticleGravity] = glGetUniformLocation(program,"u_gravity");
    //持续时间、渐隐时间
    uniforms[PariticleElapsedSeconds] = glGetUniformLocation(program,"u_elapsedSeconds");
}

- (void)linkProgram{
    
    
    //链接Programe
    glLinkProgram(program);
    //打印链接program的日志信息
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
        
        return;
    }
    
    [self validateProgram];
}

- (void)validateProgram{
    glValidateProgram(program);
    
    GLint loglength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &loglength);
    
    GLint status;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    
    if (loglength >0 || status == GL_FALSE) {
        GLchar *log = (GLchar *)malloc(loglength);
        glGetProgramInfoLog(program, loglength, &loglength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
        return;
    }
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *sourc = (GLchar*)[content UTF8String];
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &sourc, NULL);
    glCompileShader(*shader);
    
    GLint loglength ;
    
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &loglength);
    if (loglength > 0) {
        
        GLchar *log = (GLchar*)malloc(loglength);
        glGetShaderInfoLog(*shader, loglength, &loglength, log);
        NSLog(@"shader err :%s",log);
        return;
    }
}

const GLKVector3 DefaultGravity = {0.0f, -9.80665f, 0.0f};

@end
