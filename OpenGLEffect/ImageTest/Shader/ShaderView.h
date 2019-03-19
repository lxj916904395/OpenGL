//
//  ShaderView.h
//  ImageTest
//
//  Created by apple on 2019/3/15.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ShaderStyle) {
    ShaderStyleSoulout,//灵魂出窍
    ShaderStyleMirroring,//镜像
    ShaderStyleElectric,//电击
    ShaderStyleSudoku,//九宫格
    ShaderStyleDim,//模糊
};

@interface ShaderView : UIView
@property (strong, nonatomic) UIImage *image;

@property (assign ,nonatomic) ShaderStyle shaderStyle;
- (void)distory;
@end

NS_ASSUME_NONNULL_END
