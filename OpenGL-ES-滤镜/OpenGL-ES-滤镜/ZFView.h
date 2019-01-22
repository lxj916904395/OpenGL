//
//  ZFView.h
//  OpenGL-ES-滤镜
//
//  Created by zhongding on 2019/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFView : UIView
@property(strong ,nonatomic) UIImage *image;
@property(assign ,nonatomic) CGFloat temperature;
@property(assign ,nonatomic) CGFloat saturation;

@end

NS_ASSUME_NONNULL_END
