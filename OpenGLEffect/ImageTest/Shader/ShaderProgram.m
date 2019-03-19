//
//  ShaderProgram.m
//  ImageTest
//
//  Created by apple on 2019/3/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ShaderProgram.h"

@implementation ShaderProgram
+ (GLuint)programWithVertext:(NSString*)vertextName fragment:(NSString *)fragmentName{
    
    GLuint fragmentShader,vertexShader;
    
    NSString *vpath = [[NSBundle mainBundle] pathForResource:vertextName ofType:nil];
    NSString *ppath = [[NSBundle mainBundle] pathForResource:fragmentName ofType:nil];
    
    if (![self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER path:ppath])
        return 0;
    
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER path:vpath])
        return 0;
    
    
    GLuint _program = glCreateProgram();
    
    //把shader 与program 关联
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    
    //链接
    glLinkProgram(_program);
    
    //获取链接状态
    GLint linkstatus;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkstatus);
    if (linkstatus != GL_TRUE) {
        //错误日志
        GLint loglength;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &loglength);
        GLchar *message = malloc(loglength);
        glGetProgramInfoLog(_program, loglength, &loglength, message);
        NSLog(@"program 链接出错:%s",message);
        return NO;
    }
    //删除shader
    glDeleteShader(fragmentShader);
    
    glUseProgram(_program);
    return _program;
}



//编译shader
+ (BOOL)compileShader:(GLuint*)shader type:(GLenum)type path:(NSString*)path{
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!content.length ) {
        NSLog(@"shader 无内容");
        return NO;
    }
    //转化为c字符串
    const GLchar *source = (GLchar*)[content UTF8String];
    
    *shader = glCreateShader(type);
    //绑定shader内容
    glShaderSource(*shader, 1, &source, NULL);
    //编译shader
    glCompileShader(*shader);
    
    GLint loglength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &loglength);
    if (loglength) {
        GLchar *message = malloc(loglength);
        glGetShaderInfoLog(*shader, loglength, &loglength, message);
        NSLog(@"shader 编译出错: %s",message);
        return NO;
    }
    NSLog(@"shader 编译成功");
    return YES;
}


@end
