//
//  HBDBarButtonItem.m
//
//  Created by Listen on 2017/11/26.
//

#import "HBDBarButtonItem.h"

@interface HBDBarButtonItem()

@end

@implementation HBDBarButtonItem

- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style {
    return [super initWithImage:image style:style target:self action:@selector(didButtonClick)];
}

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style{
    return [super initWithTitle:title style:style target:self action:@selector(didButtonClick)];
}

- (void)didButtonClick {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end
