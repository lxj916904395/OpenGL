//
//  ImageTailor.h
//  OpenGL-ES-006-天空盒子
//
//  Created by lxj on 2019/1/12.
//  Copyright © 2019 lxj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageTailor : NSObject
+ (NSString*)imageTailorWithFile:(NSString*)imagename rowCount:(NSInteger)rowCount;
@end

NS_ASSUME_NONNULL_END
