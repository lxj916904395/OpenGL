//
//  ManagerView.h
//  OpenGL-ES-滤镜
//
//  Created by zhongding on 2019/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ManagerView : UIView

//图片
@property (nonatomic, strong) UIImage *image;
//色温值
@property (nonatomic, assign) CGFloat  colorTempValue;
//饱和度
@property (nonatomic, assign) CGFloat  saturationValue;
@end

NS_ASSUME_NONNULL_END
