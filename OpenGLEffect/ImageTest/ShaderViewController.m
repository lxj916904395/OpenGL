//
//  ShaderViewController.m
//  ImageTest
//
//  Created by apple on 2019/3/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ShaderViewController.h"

@interface ShaderViewController ()
{
    ShaderView *shader;
}
@end

@implementation ShaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    [self.view addGestureRecognizer:tap];
    
    CGFloat scale = self.view.frame.size.width/self.view.frame.size.height;
    shader  = [[ShaderView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:shader];
    shader.contentScaleFactor = scale;
    shader.image = [UIImage imageNamed:@"11.jpg"];
    shader.shaderStyle = self.shaderStyle;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 //   [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    [shader distory];
    shader = nil;
    
    NSLog(@"%s",__func__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
