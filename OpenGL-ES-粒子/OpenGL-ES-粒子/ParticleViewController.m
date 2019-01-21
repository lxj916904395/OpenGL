//
//  ParticleViewController.m
//  OpenGL-ES-粒子
//
//  Created by zhongding on 2019/1/21.
//

#import "ParticleViewController.h"

//
//                       _o666o_
//                      o8888888o
//                      88" . "88
//                      (| -_- |)
//                      0\  =  /0
//                    ___/`---'\___
//                  .' \|     |// '.
//                 / \|||  :  |||// \
//                / _||||| -:- |||||- \
//               |   | \  -  /// |     |
//               | \_|  ''\---/''  |_/ |
//               \  .-\__  '-'  ___/-. /
//             ___'. .'  /--.--\  `. .'___
//          ."" '<  `.___\_<|>_/___.' >' "".
//         | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//         \  \ `_.   \_ __\ /__ _/   .-` /  /
//     66666`-.____`.___ \_____/___.-`___.-'66666
//                       88888
//
//
//     666666666666666666666666666666666666666666
//
//               佛祖保佑         永无BUG
//
//			
//

@interface ParticleViewController ()

//粒子图层
@property(strong ,nonatomic) CAEmitterLayer *emitterLayer;


@end

@implementation ParticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor blackColor];
    
    
    _emitterLayer = [[CAEmitterLayer alloc] init];
    [self.view.layer addSublayer:_emitterLayer];
    
    //发射源尺寸
    _emitterLayer.emitterSize = CGSizeMake(100, 100);
    //粒子发射模式
    _emitterLayer.emitterMode = kCAEmitterLayerPoints;
    //发射源形状
    _emitterLayer.emitterShape = kCAEmitterLayerCircle;
    //发射源中心点
    _emitterLayer.emitterPosition = CGPointMake(100, 100);
    
    
    //粒子对象
    CAEmitterCell *cell  = [[CAEmitterCell alloc] init];
    
    //名称
    cell.name = @"我是栗子";
    //粒子c产生率
    cell.birthRate = 20;
    //粒子生命周期
    cell.lifetime = 13;
    //粒子速度
    cell.velocity = 15;
    //粒子速度变化范围
    cell.velocityRange = 100;
    //x,y,z方向上的加速度分量,三者默认都是0
    cell.yAcceleration = 15;

    //指定纬度,纬度角代表了在x-z轴平面坐标系中与x轴之间的夹角，默认0:
    cell.emissionLongitude = M_PI; // 向左
    //发射角度范围,默认0，以锥形分布开的发射角度。角度用弧度制。粒子均匀分布在这个锥形范围内;
    cell.emissionRange = M_PI_4; // 围绕X轴向左90度
    
    // 缩放比例, 默认是1
    cell.scale = 0.2;
    // 缩放比例范围,默认是0
    cell.scaleRange = 0.1;
    // 在生命周期内的缩放速度,默认是0
    cell.scaleSpeed = 0.02;
    // 粒子的内容，为CGImageRef的对象
    cell.contents = (id)[[UIImage imageNamed:@"circle_white"] CGImage];
    //颜色
    cell.color = [[UIColor colorWithRed:0.3 green:0.4f blue:0.6 alpha:1.f] CGColor];
    
    // 粒子颜色red,green,blue,alpha能改变的范围,默认0
    cell.redRange = 1.f;
    cell.greenRange = 1.f;
    cell.blueRange = 0.8;
    cell.alphaRange = 0.8;
    
    // 粒子颜色red,green,blue,alpha在生命周期内的改变速度,默认都是0
    cell.redSpeed = 1.f;
    cell.blueSpeed = 1.f;
    
    cell.alphaSpeed = -0.1f;
    
    // 添加
    _emitterLayer.emitterCells = @[cell];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [self locationFromTouchEvent:event];
    [self setBallInPsition:point];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [self locationFromTouchEvent:event];
    [self setBallInPsition:point];
}

/**
 * 获取手指所在点
 */
- (CGPoint)locationFromTouchEvent:(UIEvent *)event{
    UITouch * touch = [[event allTouches] anyObject];
    return [touch locationInView:self.view];
}

/**
 * 移动发射源到某个点上
 */
- (void)setBallInPsition:(CGPoint)position{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //创建基础动画
        CABasicAnimation * anim = [CABasicAnimation animationWithKeyPath:@"emitterCells.colorBallCell.scale"];
        //fromValue
        anim.fromValue = @0.2f;
        //toValue
        anim.toValue = @0.5f;
        //duration
        anim.duration = 1.f;
        //线性起搏，使动画在其持续时间内均匀地发生
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        // 用事务包装隐式动画
        [CATransaction begin];
        //设置是否禁止由于该事务组内的属性更改而触发的操作。
        [CATransaction setDisableActions:YES];
        //为colorBallLayer 添加动画
        [self.emitterLayer addAnimation:anim forKey:nil];
        //为colorBallLayer 指定位置添加动画效果
        [self.emitterLayer setValue:[NSValue valueWithCGPoint:position] forKeyPath:@"emitterPosition"];
        //提交动画
        [CATransaction commit];
    });
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
