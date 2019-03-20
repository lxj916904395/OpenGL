//
//  ViewController.m
//  ImageTest
//
//  Created by apple on 2019/3/13.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "ShaderViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *collectionView;
    NSArray *titles;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titles = @[@"灵魂出窍",@"镜像",@"电击",@"九宫格",@"模糊",@"抖动"];
    
    CGFloat width = self.view.frame.size.width/4;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = titles[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ShaderViewController *shadervc = [ShaderViewController new];
    shadervc.shaderStyle = (ShaderStyle)indexPath.row;
    shadervc.title = titles[indexPath.row];
    [self.navigationController pushViewController:shadervc animated:YES];
}


@end
