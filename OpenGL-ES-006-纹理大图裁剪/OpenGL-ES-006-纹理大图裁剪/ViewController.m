//
//  ViewController.m
//  OpenGL-ES-006-纹理大图裁剪
//
//  Created by zhongding on 2019/1/11.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //原图
    UIImage *oldImage = [UIImage imageNamed:@"skybox3.jpg"];
    
    //计算小图的边长
    long length = oldImage.size.width/4;
    
    //小图截取的坐标
    long origins[] = {
        0,length,//左
        length*2,length,//右
        length,length,//前
        length*3,length,//后
        length,0,//顶
        length,length*2//底
    };
    
    //小图的数量
    int count = sizeof(origins)/sizeof(origins[0])/2;
    
    //上下文绘图宽高
    CGSize size = {length,length*count};
    
    //创建绘图上下文
    UIGraphicsBeginImageContext(size);
    for (int i = 0; i+2 <=count*2;i+=2){
        
        //从原图中截取小图
        CGImageRef ref = CGImageCreateWithImageInRect(oldImage.CGImage, CGRectMake(origins[i], origins[i+1], length, length));
        
        UIImage *image = [UIImage imageWithCGImage:ref];
        
        //绘制截取的小图
        [image drawInRect:CGRectMake(0, length*i/2, length, length)];
    }
    
    //从上下文获取最终图片
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //显示最终图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150*count)];
    imageView.image = finalImage;
    [self.view addSubview:imageView];
    
    [self saveImage:finalImage];
}

//图片写入沙盒
- (void)saveImage:(UIImage*)image{
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"sky.png"];
    
    NSData *data = UIImagePNGRepresentation(image);

    [data writeToFile:path atomically:YES];
}


@end
