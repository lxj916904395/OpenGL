//
//  ParticleEffect.h
//  OpenGL-ES-粒子
//
//  Created by zhongding on 2019/1/18.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN


extern const GLKVector3 DefaultGravity;

@interface ParticleEffect : NSObject

@property(strong ,nonatomic) GLKEffectPropertyTexture *texture;
@property(strong ,nonatomic) GLKEffectPropertyTransform *tranform;

@property (nonatomic, assign) GLfloat elapsedSeconds;//耗时
@property(nonatomic,assign)GLKVector3 gravity;//重力

- (void)prepareDraw;

- (void)draw;

- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration;

@end

NS_ASSUME_NONNULL_END
