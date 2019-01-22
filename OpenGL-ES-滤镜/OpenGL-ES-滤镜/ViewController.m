//
//  ViewController.m
//  OpenGL-ES-滤镜
//
//  Created by zhongding on 2019/1/22.
//

#import "ViewController.h"
#import "ManagerView.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet ManagerView *manageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.manageView.image = [UIImage imageNamed:@"Lena"];
}

- (IBAction)temperatureChange:(UISlider*)sender {
    self.manageView.colorTempValue = sender.value;
}
- (IBAction)saturationChange:(UISlider*)sender {
    self.manageView.saturationValue = sender.value;
}

@end
