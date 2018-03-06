//
//  HBDBarButtonItem.h
//  NavigationHybrid
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HBDButtonActionBlock)(void);

@interface HBDBarButtonItem : UIBarButtonItem

@property(nonatomic, copy) HBDButtonActionBlock actionBlock;

- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style;

- (instancetype)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style;

@end
