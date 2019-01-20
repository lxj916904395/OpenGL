//
//  GLKManagerView.h
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLKManagerView : UIView
//饱和度
- (void)setSaturationValue:(CGFloat)saturation;
//色温值
- (void)setTemperatureValue:(CGFloat)temperature;
- (void)setTextureImage:(UIImage*)immage;

@end

NS_ASSUME_NONNULL_END
