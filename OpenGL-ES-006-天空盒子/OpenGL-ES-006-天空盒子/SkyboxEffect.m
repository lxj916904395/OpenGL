//
//  SkyboxEffect.m
//  OpenGL-ES-006-天空盒子
//
//  Created by lxj on 2019/1/12.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "SkyboxEffect.h"

const static int vertex_num = 24;
const static int index_num = 2*6+2;
@implementation SkyboxEffect{
    //顶点坐标buffer
    GLuint vertexBufferID;
    //索引数组
    GLuint indexBufferID;
    
    GLuint vertexArrayBufferID;
    
    GLuint program;
}

- (instancetype)init{
    if (self = [super init]) {
        
        _textureCube = [[GLKEffectPropertyTexture alloc] init];
        //开启纹理
        _textureCube.enabled = YES;
        
        //纹理用于计算其输出片段颜色的模式,看GLKTextureEnvMode
        /*
         GLKTextureEnvModeReplace, 输出颜色由从纹理获取的颜色.忽略输入的颜色
         GLKTextureEnvModeModulate, 输出颜色是通过将纹理颜色与输入颜色来计算所得
         GLKTextureEnvModeDecal,输出颜色是通过使用纹理的alpha组件来混合纹理颜色和输入颜色来计算的。
         */
        _textureCube.envMode = GLKTextureEnvModeReplace;
        
        //纹理名称
        _textureCube.name = 0;
        
        //设置使用的纹理纹理类型
        /*
         GLKTextureTarget2D  --2D纹理 等价于OpenGL 中的GL_TEXTURE_2D
         GLKTextureTargetCubeMa  --立方体贴图 等价于OpenGL 中的GL_TEXTURE_CUBE_MAP
         */
        _textureCube.target = GLKTextureTargetCubeMap;
        
        
        _transform = [[GLKEffectPropertyTransform alloc] init];
        
        //默认中心点
        _center = GLKVector3Make(0, 0, 0);
        
        //默认放大倍数
        _xsize = _ysize = _zsize = 1;
        
        [self setupVertex];
        
    }
    return self;
}

- (void)setupVertex{
    //立方体8个角的坐标
    const float vertexs[vertex_num] = {
        -0.5, -0.5,  0.5,
        0.5, -0.5,  0.5,
        -0.5,  0.5,  0.5,
        0.5,  0.5,  0.5,
        -0.5, -0.5, -0.5,
        0.5, -0.5, -0.5,
        -0.5,  0.5, -0.5,
        0.5,  0.5, -0.5,
    };
    
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
    
    
    GLuint indexs[index_num] = {
        1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1, 2
    };
    
    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexs), indexs, GL_STATIC_DRAW);
}


- (void)loadProgram{
    
    if (!program) {
        GLuint vershader,fragshader;
        NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
        NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
        
        [self compileShader:&vershader type:GL_VERTEX_SHADER file:vfile];
        [self compileShader:&fragshader type:GL_FRAGMENT_SHADER file:ffile];
        
        program = glCreateProgram();
        
        glAttachShader(program, vershader);
        glAttachShader(program, fragshader);
        
     //   glBindAttribLocation(program, GLKVertexAttribPosition,
                 //            "position");
        
        //链接出错
        if(![self linkProgram]){
            
            if (vershader) {
                //是使shaderx失效
                glAttachShader(program, vershader);
                glDeleteShader(vershader);
            }
            
            if (fragshader) {
                glAttachShader(program, fragshader);
                glDeleteShader(fragshader);
            }
            
            if (program) {
                glDeleteProgram(program);
                program = 0;
            }
            return;
        }
        glDeleteShader(vershader);
        glDeleteShader(fragshader);
    }
}

//链接program
- (BOOL)linkProgram{
    
    glLinkProgram(program);
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) {
        
        GLint loglength;
        //获取日志长度
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &loglength);
        
        //错误信息
        GLchar *log = malloc(loglength);
        glGetProgramInfoLog(program, loglength, &loglength, log);
        
        NSLog(@"program link err :%s",log);
        return NO;
    }
    NSLog(@"program successs");
    return YES;
}



//编译shader

- (BOOL)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString*)file{
    
    NSString * content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar*)[content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
    GLint loglength ;
    
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &loglength);
    
    //获取shader日志,
    //存在日志，则编译shader出错
    if (loglength) {
        
        GLchar *log = malloc(loglength);
        glGetShaderInfoLog(*shader, loglength, &loglength, log);
        
        NSLog(@"shader log : %s",log);
        return NO;
    }
    return YES;
}

//绘制
- (void)draw{
    
    glDrawElements(GL_TRIANGLE_STRIP, index_num, GL_UNSIGNED_INT, 0);
}

//准备绘制
- (void)preparDraw{
    
    [self loadProgram];
    
    if (program) {
        glUseProgram(program);
        
        GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(_transform.modelviewMatrix, _center.x, _center.y, _center.z);
        
        modelviewMatrix =  GLKMatrix4Scale(modelviewMatrix, _xsize, _ysize, _zsize);
        
        GLKMatrix4 modelviewProjectionMatrix = GLKMatrix4Multiply(_transform.projectionMatrix, modelviewMatrix);
        
        
        //为当前程序对象指定Uniform变量的值
        /*
         什么叫MVPMatrix?
         MVPMatrix,本质上就是一个变换矩阵.用来把一个世界坐标系的点转换成裁剪空间的位置.在前面我
         说过,学过OpenGL 的人都知道.3D物体从建模到最终显示到屏幕上需要经历以下几个阶段:
         1.对象空间(Object space)
         2.世界空间(World Space)
         3.照相机空间(Camera Space/Eye Space)
         4.裁剪空间(Clipping Space)
         5.设备空间(normalized device space)
         6.视口空间(Viewport)
         
         从对象空间到世界空间的变换叫做Model-To-World变换,
         从世界空间到照相机空的变换叫做Worl-To-View变换,
         从照相机空间到裁剪空间变换叫做View-TO-Pojection变换.
         合起来,从对象空间-裁剪空间的这个过程就是我们所说的MVP变换.
         这里的每一个变换都是乘以一个矩阵,3个矩阵相乘最后还是一个矩阵.
         这就传递到顶点着色器中的MVPMatrix矩阵.
         
         gl_Position = u_mvpMatrix * vec4(a_position, 1.0);
         
         
         glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
         参数1:location,要更改的uniforms变量的位置
         参数2:cout ,更改矩阵的个数
         参数3:transpose,指是否要转置矩阵,并将它作为uniform变量的值,必须为GL_FALSE
         参数4:value ,指向count个数的元素指针.用来更新uniform变量的值.
         
         为当前程序对象指定Uniform变量的值
         */
        
        GLfloat  mvpMatrix = glGetUniformLocation(program, "mvpMatrix");
        //把转换后的矩阵传入顶点s着色器
        glUniformMatrix4fv(mvpMatrix, 1, GL_FALSE, modelviewProjectionMatrix.m);
        
        //一个纹理采样均匀变量
        /*
         void glUniform1f(GLint location,  GLfloat v0);
         为当前程序对象指定Uniform变量的值
         location:指明要更改的uniform变量的位置
         v0:在指定的uniform变量中要使用的新值
         */
        GLfloat textureCubeMap = glGetUniformLocation(program, "textureCubeMap");
        glUniform1i(textureCubeMap, 0);
        
    
    
    if (vertexArrayBufferID == 0) {
           //OES 拓展类
        glGenVertexArraysOES(1, &vertexArrayBufferID);
        glBindVertexArrayOES(vertexArrayBufferID);

        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
        
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);
    }else{
        // 调用恢复所有先前编写的顶点属性指针与vertexarrayId
        glBindVertexArrayOES(vertexArrayBufferID);
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    
    if (_textureCube.enabled) {
        //绑定纹理
        //参数1:纹理类型
        //参数2:纹理名称
        glBindTexture(GL_TEXTURE_CUBE_MAP, _textureCube.name);
    }else{
        //绑定一个空的
        glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    }
    }
}


@end
