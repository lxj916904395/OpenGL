//
//  ZFView.h
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFView : UIView

- (void)setTextureImage:(UIImage*)immage;
//饱和度
- (void)setSaturationValue:(CGFloat)saturation;
//色温值
- (void)setTemperatureValue:(CGFloat)temperature;
@end

NS_ASSUME_NONNULL_END
