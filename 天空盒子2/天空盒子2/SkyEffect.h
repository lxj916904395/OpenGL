//
//  SkyEffect.h
//  天空盒子2
//
//  Created by zhongding on 2019/1/14.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkyEffect : NSObject

@property (strong ,nonatomic) GLKEffectPropertyTransform *transform;
@property (strong ,nonatomic) GLKEffectPropertyTexture *textureCube;

@property (assign ,nonatomic) int xsize;
@property (assign ,nonatomic) int ysize;
@property (assign ,nonatomic) int zsize;
@property (assign ,nonatomic) GLKVector3 center;
- (void)prepareDraw;
- (void)draw;


@end

NS_ASSUME_NONNULL_END
