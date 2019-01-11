//
//  ShaderUtil.m
//  OpenGL-ES-004-GLSL显示3D纹理
//
//  Created by zhongding on 2019/1/8.
//

#import "ShaderUtil.h"

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


@implementation ShaderUtil

+ (void)prepareToDrawWithAttrib:(GLuint)buffer index:(GLuint)index count:(GLint)count  stride:(GLsizei) stride stepOffet:(GLint )offset{
    NSAssert(buffer !=0,@"buffer is empty");
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glEnableVertexAttribArray(index);
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, stride, (GLfloat*)NULL+offset);
}

+ (void)lallocBuffer:(GLuint*)bufferSpace size:(GLsizeiptr)size data:(const GLvoid*)data usage:(GLenum)usage{
    glGenBuffers(1, bufferSpace);
    glBindBuffer(GL_ARRAY_BUFFER, *bufferSpace);
    glBufferData(GL_ARRAY_BUFFER, size, data, usage);
}


#pragma mark ***************** Program
+ (GLuint)glCreateProgramWithVpath:(NSString*)vPath fPath:(NSString *)fPath{

    GLuint vshader,fshader;
    [self compileShader:&vshader type:GL_VERTEX_SHADER path:vPath];
    [self compileShader:&fshader type:GL_FRAGMENT_SHADER path:fPath];
    
 
   GLuint program = glCreateProgram();
    
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    
    glDeleteShader(vshader);
    glDeleteShader(fshader);
    
    glLinkProgram(program);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        char message[1024];
        glGetProgramInfoLog(program, sizeof(message), NULL, message);
        NSString *err = [NSString stringWithUTF8String:message];
        NSLog(@"链接出错:%@",err);
        return 0;
    }
    
    NSLog(@"program link success");
    glUseProgram(program);
    return program;
}

+ (void)compileShader:(GLuint*)shader type:(GLenum)type path:(NSString*)path{
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!content || content.length == 0) {
        NSLog(@"读取着色器文件出错:%@",path);
        return;
    }
    const GLchar *source = [content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

    
}

@end
