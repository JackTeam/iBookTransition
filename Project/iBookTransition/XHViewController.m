//
//  XHViewController.m
//  iBookTransition
//
//  Created by 曾 宪华 on 14-2-25.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHViewController.h"

#import "XHPresentModalViewController.h"

@interface XHViewController ()

@end

@implementation XHViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    [_button setTitle:@"Show" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithRed:0.251 green:0.502 blue:0.000 alpha:1.000] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonCilcked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)buttonCilcked:(UIButton *)sender {
    [self presentModalViewController:[[XHPresentModalViewController alloc] init] withAnimationStyle:kXHUIModalTransitionStyleFlipLeftWithGap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
