//
//  ViewController.m
//  OpenGL-ES-滤镜
//
//  Created by lxj on 2019/1/20.
//  Copyright © 2019 lxj. All rights reserved.
//

#import "ViewController.h"
#import "GLKManagerView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet GLKManagerView *managerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.managerView setTextureImage:[UIImage imageNamed:@"Lena"]];
}

//色温改变
- (IBAction)changeTemperature:(UISlider*)sender {
    [_managerView setTemperatureValue:sender.value];
}

//饱和度改变
- (IBAction)changeSaturation:(UISlider*)sender {
    [_managerView setSaturationValue:sender.value];
}

@end
