//
//  GLContainerView.m
//  01-多滤镜处理
//
//  Created by CC老师 on 2018/3/5.
//  Copyright © 2018年 CC老师. All rights reserved.
//

#import "ZFView.h"
#import <AVFoundation/AVFoundation.h>
#import "ManagerView.h"
@interface ManagerView()

@property (nonatomic, strong) ZFView *glView;

@end

@implementation ManagerView

#pragma mark - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupGLView];
}

#pragma mark - Setup
- (void)setupGLView {
    //获取GLView
    self.glView = [[ZFView alloc] initWithFrame:self.bounds];
    //添加到self上
    [self addSubview:self.glView];
}

#pragma mark - Private
- (void)layoutGlkView {
    
    //获取图片尺寸
    CGSize imageSize = self.image.size;
    
    //Returns a scaled CGRect that maintains the aspect ratio specified by a CGSize within a bounding CGRect.
    //返回一个在Self.bounds范围的CGRect,根据imagaSize的一个纵横比
    CGRect frame = AVMakeRectWithAspectRatioInsideRect(imageSize, self.bounds);
    
    //修改glView的frame
    self.glView.frame = frame;
    
    //应用于视图的比例因子
    self.glView.contentScaleFactor = imageSize.width / frame.size.width;
}

#pragma mark - Public
- (void)setImage:(UIImage *)image {
    //设置图片
    _image = image;
    
    //GLView
    [self layoutGlkView];
    //渲染图片
    [self.glView setImage:_image];
}

//修改色温
- (void)setColorTempValue:(CGFloat)colorTempValue {
    
    _colorTempValue = colorTempValue;
    //glView获取色温
    self.glView.temperature = colorTempValue;
}

//修改饱和度
- (void)setSaturationValue:(CGFloat)saturationValue {
    _saturationValue = saturationValue;
    //glView获取饱和度
    self.glView.saturation = saturationValue;
}



@end
