//
//  NativeModalViewController.m
//  Navigation
//
//  Created by Listen on 2018/6/4.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "NativeModalViewController.h"
#import <NavigationHybrid/HBDModalViewController.h>

@interface NativeModalViewController ()

@end

@implementation NativeModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    HBDModalViewController *modal = self.hbd_modalViewController;
    
    //modal.maximumContentViewWidth = modal.view.bounds.size.width;
    //modal.contentViewMargins = UIEdgeInsetsZero;
    
    modal.measureBlock = ^CGSize(HBDModalViewController *modalViewController, CGSize limitSize) {
        CGSize size = limitSize;
        size.height = 200;
        return size;
    };
    
    modal.layoutBlock = ^(HBDModalViewController *modalViewController, CGRect contentViewDefaultFrame) {
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            safeAreaInsets = modalViewController.contentView.safeAreaInsets;
        }
        contentViewDefaultFrame.origin.y = CGRectGetHeight(modalViewController.view.bounds) - modalViewController.contentViewMargins.bottom - CGRectGetHeight(contentViewDefaultFrame) - safeAreaInsets.bottom;
        modalViewController.contentView.frame = contentViewDefaultFrame;
    };
    
    modal.showingAnimation = ^(HBDModalViewController *modalViewController, CGRect contentViewFrame, void (^completion)(BOOL finished)) {
        modalViewController.dimmingView.alpha = 0;
        CGRect frame = contentViewFrame;
        frame.origin.y = CGRectGetHeight(modalViewController.view.bounds);
        modalViewController.contentView.frame = frame;
        [UIView animateWithDuration:.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
            modalViewController.dimmingView.alpha = 1;
            modalViewController.contentView.frame = contentViewFrame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    modal.hidingAnimation = ^(HBDModalViewController *modalViewController, void (^completion)(BOOL finished)) {
        [UIView animateWithDuration:.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
            modalViewController.dimmingView.alpha = 0;
            CGRect frame = modalViewController.contentView.frame;
            frame.origin.y = CGRectGetHeight(modalViewController.view.bounds);
            modalViewController.contentView.frame = frame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    
}

- (IBAction)closeModal:(UIButton *)sender {
    [self.hbd_modalViewController hideWithAnimated:YES completion:^(BOOL finished) {
        
    }];
}

@end
