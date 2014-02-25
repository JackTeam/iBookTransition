//
//  UIViewController+iBookTransition.h
//  iBookTransition
//
//  Created by 曾 宪华 on 14-2-25.
//  Copyright (c) 2014年 HUAJIE QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kXHUIModalTransitionStyleFlipRightWithGap = 0,
	kXHUIModalTransitionStyleFlipLeftWithGap,
	kXHUIModalTransitionStyleSplitVertical,
	kXHUIModalTransitionStyleSplitHorizontal,
	kXHUIModalTransitionStyleFlyInFromRight,
	kXHUIModalTransitionStyleFlyInFromLeft,
	kXHUIModalTransitionStyleDiveInFromRight,
	kXHUIModalTransitionStyleDiveInFromLeft,
    
} XHUIModalTransitionStyleAddition;

@interface UIViewController (iBookTransition)

- (void)presentModalViewController:(UIViewController *)modalViewController withAnimationStyle:(XHUIModalTransitionStyleAddition)style;

- (void)dismissModalViewControllerWithAnimationStyle:(XHUIModalTransitionStyleAddition)style;

@end
