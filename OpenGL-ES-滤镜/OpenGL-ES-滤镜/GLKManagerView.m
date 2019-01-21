//
//  GLKManagerView.m
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "GLKManagerView.h"
#import "ZFView.h"

#import <AVFoundation/AVFoundation.h>

@interface GLKManagerView ()
@property (strong ,nonatomic) ZFView *zfView;
@property(strong ,nonatomic) UIImage *image;

@end

@implementation GLKManagerView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupView];
}

//饱和度
- (void)setSaturationValue:(CGFloat)saturation{
    [_zfView setSaturationValue:saturation];
}

//色温值
- (void)setTemperatureValue:(CGFloat)temperature{
    [_zfView setTemperatureValue:temperature];
}

- (void)setTextureImage:(UIImage*)image{
    self.image = image;
    [_zfView setTextureImage:image];
    [self resetFrame];
}

- (void)resetFrame{
    
    CGSize imagesize = self.image.size;
    
    //返回一个适配屏幕大小的新frame
    CGRect frame = AVMakeRectWithAspectRatioInsideRect(imagesize, self.bounds);
    
    self.zfView.frame = frame;
    
    self.zfView.contentScaleFactor = imagesize.width/imagesize.height;
    
}

- (void)setupView{
    _zfView = [[ZFView alloc] init];
    [self addSubview:_zfView];
}

@end
