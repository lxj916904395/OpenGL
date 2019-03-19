//
//  CollectionViewCell.m
//  ImageTest
//
//  Created by apple on 2019/3/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if ( self = [super initWithFrame:frame]) {
        
        _label = [UILabel new];
        _label.frame = self.bounds;
        _label.textColor = [UIColor redColor];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
        CGFloat random = arc4random()%256/255.0;
        self.contentView.backgroundColor = [UIColor colorWithRed:random green:random blue:random alpha:1];
    }
    return self;
}
@end
