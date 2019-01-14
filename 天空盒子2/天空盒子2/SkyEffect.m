//
//  SkyEffect.m
//  天空盒子2
//
//  Created by zhongding on 2019/1/14.
//

#import "SkyEffect.h"

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


@implementation SkyEffect
{
    GLuint program;
    
    GLuint VAO;
    GLuint vertextBuffer;
    GLuint indexsBuffer;
}

//绘制立方体的三角形带索引
const GLubyte indices[14] = {
    1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1, 2
};

- (instancetype)init{
    if (self = [super init]) {
        
        [self setup];
        [self setupMatrix];
    }
    return self;
}

- (void)setup{
    _textureCube = [[GLKEffectPropertyTexture alloc] init];
    _textureCube.name = 0;
    _textureCube.enabled = YES;
    _textureCube.envMode = GLKTextureEnvModeReplace;
    _textureCube.target = GLKTextureTargetCubeMap;
    
    _xsize = _ysize = _zsize = 1;
    _transform = [[GLKEffectPropertyTransform alloc] init];
    
    _center = GLKVector3Make(0, 0, 0);
    
}

- (void)setupMatrix{
    
    GLfloat vertexs[8*3] = {
        -0.5, -0.5,  0.5,
        0.5, -0.5,  0.5,
        -0.5,  0.5,  0.5,
        0.5,  0.5,  0.5,
        
        -0.5, -0.5, -0.5,
        0.5, -0.5, -0.5,
        -0.5,  0.5, -0.5,
        0.5,  0.5, -0.5,
    };
    

    
    glGenBuffers(1, &vertextBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);

    glGenBuffers(1, &indexsBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexsBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
}

- (void)prepareDraw{
    
    if (!program) {
        [self loadProgram];
    }
    
    if(program){
        glUseProgram(program);
        
        
        GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(self.transform.modelviewMatrix,_center.x,_center.y,_center.z);
        
        modelviewMatrix = GLKMatrix4Scale(modelviewMatrix, _xsize, _ysize, _zsize);
        
        GLKMatrix4 modelviewprojection = GLKMatrix4Multiply(_transform.projectionMatrix, modelviewMatrix);
        
        
        GLfloat mvpMatrix = glGetUniformLocation(program, "mvpMatrix");
        glUniformMatrix4fv(mvpMatrix, 1, GL_FALSE, modelviewprojection.m);
        
        GLfloat cubmap = glGetUniformLocation(program, "textureCubeMap");
        glUniform1i(cubmap, 0);
        
        if (VAO ==0 ) {
            glGenVertexArraysOES(1, &VAO);
            glBindVertexArrayOES(VAO);
            
            glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer);
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat*)NULL+0);
        }else{
            glBindVertexArrayOES(VAO);
        }
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexsBuffer);
        
        if(_textureCube.enabled){
            glBindTexture(GL_TEXTURE_CUBE_MAP, _textureCube.name);
        }else{
            glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
        }
    }
}


- (void)loadProgram{
    
    GLuint vshader,fshader;
    
    NSString *vfile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *ffile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    
    [self compileShader:&vshader type:GL_VERTEX_SHADER file:vfile];
    [self compileShader:&fshader type:GL_FRAGMENT_SHADER file:ffile];
    
    program = glCreateProgram();
    
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    
    [self linkProgram];
    
    glDeleteShader(vshader);
    glDeleteShader(fshader);
}

- (void)linkProgram{
    glLinkProgram(program);
    
    GLint loglength ;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &loglength);
    if (loglength >0) {
        GLchar *log = malloc(loglength);
        glGetProgramInfoLog(program, loglength, &loglength, log);
        NSLog(@"program link err：%s",log);
        return;
    }
}

//编译shader
- (void)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString *)file{
    
    
    NSString *context = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar*)[context UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
    GLint loglength;
    
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &loglength);
    
    if (loglength >0) {
        
        GLchar *log = malloc(loglength);
        glGetShaderInfoLog(*shader, loglength, &loglength, log);
        NSLog(@"shader compile err:%s",log);
        
        return;
    }
}


- (void)draw{
    /*
     索引绘制方法
     glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
     参数列表:
     mode:指定绘制图元的类型,但是如果GL_VERTEX_ARRAY 没有被激活的话，不能生成任何图元。它应该是下列值之一: GL_POINTS, GL_LINE_STRIP,GL_LINE_LOOP,GL_LINES,GL_TRIANGLE_STRIP,GL_TRIANGLE_FAN,GL_TRIANGLES,GL_QUAD_STRIP,GL_QUADS,GL_POLYGON
     count:绘制图元的数量
     type 为索引数组(indices)中元素的类型，只能是下列值之一:GL_UNSIGNED_BYTE,GL_UNSIGNED_SHORT,GL_UNSIGNED_INT
     indices：指向索引数组的指针。
     */
    glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_BYTE, 0);
}

@end
