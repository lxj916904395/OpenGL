//
//  ImageTailor.m
//  OpenGL-ES-006-天空盒子
//
//  Created by lxj on 2019/1/12.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "ImageTailor.h"

@implementation ImageTailor

+ (NSString*)imageTailorWithFile:(NSString*)imagename rowCount:(NSInteger)rowCount{
    //原始图片
    UIImage *originImage = [UIImage imageNamed:imagename];
    
    //图片边长
    long length = originImage.size.width/rowCount;
    
    long originsPoint[] = {
        length * 2,length,//右 right
        0,length,//左 left
        length,0,//上 top
        length,length * 2,//底 bottom
        length,length,//顶 front
        length * 3 ,length,//背面 back
    };
    
    //立方体的面数
    int faceCount = sizeof(originsPoint)/sizeof(originsPoint[0])/2;
    
    //上下文的区域大小
    CGSize size = {length,faceCount*length};
    
    //初始化绘图上下文
    UIGraphicsBeginImageContext(size);
    
    
    for (int i = 0 ; i+2 <= faceCount*2; i+=2) {
        //在原始图片对应位置裁剪出小图片
        CGImageRef imgref = CGImageCreateWithImageInRect(originImage.CGImage, CGRectMake(originsPoint[i], originsPoint[i+1], length, length));
        
        //转化成image
        UIImage *simg = [UIImage imageWithCGImage:imgref];
        
        //在绘图上下文相应frame出绘制裁剪的小图
        [simg drawInRect:CGRectMake(0, length*i/2, length, length)];
        
    }
    
    //从绘图上下文获取最终的图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (finalImage) {
      return  [self saveImg:finalImage];
    }
    
    return nil;
}

//存储图片
+ (NSString*)saveImg:(UIImage*)image{
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"sky.png"];
    
    NSLog(@"图片路径----%@",path);
    NSData *data = UIImagePNGRepresentation(image);
    
    [data writeToFile:path atomically:YES];
    
    return path;
}

@end
