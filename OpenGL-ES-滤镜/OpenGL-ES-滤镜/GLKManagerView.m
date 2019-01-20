//
//  GLKManagerView.m
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "GLKManagerView.h"
#import "ZFView.h"

@interface GLKManagerView ()
@property (strong ,nonatomic) ZFView *zfView;

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

- (void)setTextureImage:(UIImage*)immage{
    [_zfView setTextureImage:immage];
}

- (void)setupView{
    _zfView = [[ZFView alloc] init];
}

@end
