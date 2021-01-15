//
//  HBDTitleView.h
//  NavigationHybrid
//
//  Created by Listen on 2018/3/6.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTRootView.h>

@interface HBDTitleView : UIView

- (instancetype)initWithRootView:(RCTRootView *)rootView layoutFittingSize:(CGSize)fittingSize navigationBarBounds:(CGRect)bounds;

@end
