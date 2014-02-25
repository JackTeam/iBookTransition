//
//  XHPresentModalViewController.m
//  iBookTransition
//
//  Created by 曾 宪华 on 14-2-25.
//  Copyright (c) 2014年 HUAJIE QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import "XHPresentModalViewController.h"

@interface XHPresentModalViewController ()

@end

@implementation XHPresentModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)buttonCilcked:(UIButton *)sender {
    [self dismissModalViewControllerWithAnimationStyle:kXHUIModalTransitionStyleFlipRightWithGap];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.502 green:0.000 blue:0.502 alpha:1.000];
    
    CGFloat size = CGRectGetWidth(self.view.bounds) * 0.5;
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, size, size);
    _button.center = self.view.center;
    _button.backgroundColor = [UIColor colorWithRed:0.000 green:0.251 blue:0.502 alpha:1.000];
    [_button setTitle:@"back" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithRed:0.251 green:0.502 blue:0.000 alpha:1.000] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonCilcked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
