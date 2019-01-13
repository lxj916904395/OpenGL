//
//  SkyboxEffect.h
//  OpenGL-ES-006-天空盒子
//
//  Created by lxj on 2019/1/12.
//  Copyright © 2019 lxj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
NS_ASSUME_NONNULL_BEGIN

@interface SkyboxEffect : NSObject

//变换
@property (strong ,nonatomic) GLKEffectPropertyTransform *transform;
//立体纹理
@property (strong, nonatomic) GLKEffectPropertyTexture *textureCube;


@property (assign ,nonatomic) GLKVector3 center;
@property (assign ,nonatomic) float xsize;
@property (assign ,nonatomic) float ysize;
@property (assign ,nonatomic) float zsize;

- (void)draw;
- (void)preparDraw;

@end

NS_ASSUME_NONNULL_END
