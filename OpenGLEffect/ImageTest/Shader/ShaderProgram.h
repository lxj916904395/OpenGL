//
//  ShaderProgram.h
//  ImageTest
//
//  Created by apple on 2019/3/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShaderProgram : NSObject
+ (GLuint)programWithVertext:(NSString*)vertextPath fragment:(NSString *)fragmentPath;
@end

NS_ASSUME_NONNULL_END
