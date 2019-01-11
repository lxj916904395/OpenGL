//
//  ShaderUtil.h
//  OpenGL-ES-004-GLSL显示3D纹理
//
//  Created by zhongding on 2019/1/8.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
NS_ASSUME_NONNULL_BEGIN

@interface ShaderUtil : NSObject


+ (GLuint)glCreateProgramWithVpath:(NSString*)vPath fPath:(NSString *)fPath;

+ (void)lallocBuffer:(GLuint*)bufferSpace size:(GLsizeiptr)size data:(const GLvoid*)data usage:(GLenum)usage;

+ (void)prepareToDrawWithAttrib:(GLuint)buffer index:(GLuint)index count:(GLint)count  stride:(GLsizei) stride stepOffet:(GLint )offset;

@end

NS_ASSUME_NONNULL_END
