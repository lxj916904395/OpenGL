//
//  ZFBufferUtil.h
//  OpenGL-ES-粒子
//
//  Created by zhongding on 2019/1/18.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/glext.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZFVertexAttribsBuffer : NSObject

@property (nonatomic, readonly) GLuint bufferName;//缓存区名字
@property (nonatomic, readonly) GLsizeiptr bufferSizeBytes;//缓冲区大小的字节数
@property (nonatomic, readonly) GLsizeiptr stride;//步长

@property (nonatomic, readonly) GLenum usage;

//根据模式绘制已经准备数据
//绘制
/*
 mode:模式
 first:是否是第一次
 count:顶点个数
 */
+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;

//初始
/*
 stride:步长
 count:顶点个数
 dataPtr:数据指针
 usage:用法
 */
- (id)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

//准备绘制
/*
 index:属性
 count:顶点个数
 offset:偏移量
 shouldEnable:是否可用
 */
- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

//绘制
/*
 mode:模式
 first:是否是第一次
 count:顶点个数
 */
- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

//接收数据`
/*
 stride:步长
 count:顶点个数
 dataPtr:数据指针
 */
- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

@end

NS_ASSUME_NONNULL_END
