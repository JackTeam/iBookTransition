//
//  UIViewController+iBookTransition.m
//  iBookTransition
//
//  Created by 曾 宪华 on 14-2-25.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "UIViewController+iBookTransition.h"

#if DEBUG
#define ANIMATION_DURATION 0.7f
#else
#define ANIMATION_DURATION 0.7f
#endif

#define FLIP_GAP_WIDTH 70.0f

@implementation UIViewController (iBookTransition)

#pragma mark -
#pragma mark Helpers

- (CATransform3D)transformWithDegrees__:(CGFloat)degrees{
	
	return CATransform3DMakeRotation((M_PI/180)*degrees, 0.0f, 1.0f, 0.0);
	
}

- (UIImage*)contentsForView__:(UIView*)aView{
	
	UIGraphicsBeginImageContextWithOptions(aView.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[aView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}


#pragma mark -
#pragma mark Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	
	if (flag) {
		[[anim valueForKey:@"ContentsLayer"] removeFromSuperlayer];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
	
}


#pragma mark -
#pragma mark Animation Methods

- (void)diveInFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController style:(XHUIModalTransitionStyleAddition)style{
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
	BOOL _left = (style == kXHUIModalTransitionStyleDiveInFromLeft);
    
	UIImage *image=nil;
	UIGraphicsBeginImageContextWithOptions(toController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[toController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	CGRect originFrame = fromController.view.bounds;
	CGRect destFrame = toController.view.bounds;
	
	CGFloat diff = originFrame.size.height - destFrame.size.height;
	originFrame.origin.y -= diff;
	
	CALayer *contentsLayer = [CALayer layer];
	contentsLayer.frame = fromController.view.bounds;
	contentsLayer.backgroundColor = [UIColor viewFlipsideBackgroundColor].CGColor;
	[toController.view.layer addSublayer:contentsLayer];
	
	CALayer *backLayer = [CALayer layer];;
	backLayer.contents = (id)image.CGImage;
	backLayer.frame = destFrame;
	backLayer.contentsScale = [[UIScreen mainScreen] scale];
	backLayer.contentsGravity = kCAGravityCenter;
	[contentsLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.doubleSided = NO;
	frontLayer.frame = originFrame;
	frontLayer.zPosition = FLIP_GAP_WIDTH;
	frontLayer.contentsScale = [[UIScreen mainScreen] scale];
	frontLayer.contentsGravity = kCAGravityCenter;
	[contentsLayer addSublayer:frontLayer];
    
	[fromController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	frontLayer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
	UIGraphicsEndImageContext();
    
	//  animation vars
	
	CAAnimationGroup *animationGroup;
	CABasicAnimation *zPosAnimation;
	CAKeyframeAnimation *pathAnimation;
	CAKeyframeAnimation *transformAnimation;
	CAKeyframeAnimation *opactiyAnimation;
	CATransform3D transform;
	CGPoint toPoint;
	
	//  old controller animation
	
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = ANIMATION_DURATION;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	zPosAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
	zPosAnimation.fromValue = [NSNumber numberWithFloat:3000.0f];
	zPosAnimation.toValue = [NSNumber numberWithFloat:-3000.0f];
    
	transform = _left ? [self transformWithDegrees__:-60] : [self transformWithDegrees__:-60];
	transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	transformAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:transform], [NSValue valueWithCATransform3D:CATransform3DIdentity], nil];
    
	toPoint = _left ? CGPointMake(frontLayer.position.x-(frontLayer.frame.size.width/2.5), frontLayer.position.y) : CGPointMake(frontLayer.position.x+(backLayer.frame.size.width/2.5), frontLayer.position.y);
	pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:frontLayer.position], [NSValue valueWithCGPoint:toPoint], [NSValue valueWithCGPoint:frontLayer.position], nil];
	pathAnimation.calculationMode = kCAAnimationCubicPaced;
    
	opactiyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	opactiyAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:0.1f], nil];
	
	[animationGroup setAnimations:[NSArray arrayWithObjects:opactiyAnimation, zPosAnimation, transformAnimation, pathAnimation, nil]];
	[frontLayer addAnimation:animationGroup forKey:@"FlyOutAnimation"];
	
	
	// new controller animation
	
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = ANIMATION_DURATION;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animationGroup.delegate = self;
	[animationGroup setValue:contentsLayer forKey:@"ContentsLayer"];
	
	opactiyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	opactiyAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], nil];
    
	toPoint = _left ? CGPointMake(backLayer.position.x+(backLayer.frame.size.width/2.5),backLayer.position.y) : CGPointMake(backLayer.position.x-(backLayer.frame.size.width/2.5), backLayer.position.y);
	pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:backLayer.position], [NSValue valueWithCGPoint:toPoint], [NSValue valueWithCGPoint:backLayer.position], nil];
	pathAnimation.calculationMode = kCAAnimationCubicPaced;
    
	transform = _left ? [self transformWithDegrees__:-60] : [self transformWithDegrees__:60];
	transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	transformAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:transform], [NSValue valueWithCATransform3D:CATransform3DIdentity], nil];
	
	[animationGroup setAnimations:[NSArray arrayWithObjects:opactiyAnimation, transformAnimation, pathAnimation, nil]];
	[backLayer addAnimation:animationGroup forKey:@"FlyInAnimation"];
    
}

- (void)flyInFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController style:(XHUIModalTransitionStyleAddition)style{
	
	BOOL _left = (style == kXHUIModalTransitionStyleFlyInFromLeft);
	
	UIImage *image=nil;
	UIGraphicsBeginImageContextWithOptions(toController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[toController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	CGRect originFrame = fromController.view.bounds;
	CGRect destFrame = toController.view.bounds;
	
	CGFloat diff = originFrame.size.height - destFrame.size.height;
	originFrame.origin.y -= diff;
	
	CALayer *contentsLayer = [CALayer layer];
	contentsLayer.frame = fromController.view.bounds;
	contentsLayer.backgroundColor = [UIColor viewFlipsideBackgroundColor].CGColor;
	[toController.view.layer addSublayer:contentsLayer];
	
	CALayer *backLayer = [CALayer layer];;
	backLayer.contents = (id)image.CGImage;
	backLayer.frame = destFrame;
	backLayer.contentsScale = [[UIScreen mainScreen] scale];
	backLayer.contentsGravity = kCAGravityCenter;
	[contentsLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	[fromController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	frontLayer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
	UIGraphicsEndImageContext();
	
	frontLayer.doubleSided = NO;
	frontLayer.frame = originFrame;
	frontLayer.zPosition = FLIP_GAP_WIDTH;
	frontLayer.contentsScale = [[UIScreen mainScreen] scale];
	frontLayer.contentsGravity = kCAGravityCenter;
	[contentsLayer addSublayer:frontLayer];
	
	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = ANIMATION_DURATION-0.3f;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
	CAKeyframeAnimation *opactiyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	opactiyAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:0.1f], nil];
    
	CABasicAnimation *zPosAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
	zPosAnimation.toValue = [NSNumber numberWithFloat:0.0f];
	
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4f, 0.4f, 1.0f)];
    
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.calculationMode = kCAAnimationCubicPaced;
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, frontLayer.position.x, frontLayer.position.y);
	CGPathAddCurveToPoint(path, NULL, _left ? frontLayer.position.x + (frontLayer.frame.size.width/2) : frontLayer.position.x - (frontLayer.frame.size.width/2), frontLayer.position.y, _left ? frontLayer.position.x + (frontLayer.frame.size.width/1.4) : frontLayer.position.x - (frontLayer.frame.size.width/1.4), frontLayer.position.y, frontLayer.position.x, frontLayer.position.y);
	pathAnimation.path = path;
	CGPathRelease(path);
	[animationGroup setAnimations:[NSArray arrayWithObjects:scaleAnimation, opactiyAnimation, zPosAnimation, pathAnimation, nil]];
	[frontLayer addAnimation:animationGroup forKey:@"FlyOutAnimation"];
    
	opactiyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	opactiyAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], nil];
	
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = ANIMATION_DURATION-0.3f;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
	scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4f, 0.4f, 1.0f)];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
	zPosAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
	zPosAnimation.fromValue = [NSNumber numberWithFloat:-100.0f];
	zPosAnimation.toValue = [NSNumber numberWithFloat:100.0f];
    
	pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.calculationMode = kCAAnimationCubicPaced;
	path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, backLayer.position.x, backLayer.position.y);
	CGPathAddCurveToPoint(path, NULL,  !_left ? backLayer.position.x + (backLayer.frame.size.width/2) : backLayer.position.x - (backLayer.frame.size.width/2), backLayer.position.y, !_left ? backLayer.position.x + (backLayer.frame.size.width/1.4) : backLayer.position.x - (backLayer.frame.size.width/1.4), backLayer.position.y, backLayer.position.x, backLayer.position.y);
	pathAnimation.path = path;
	CGPathRelease(path);
    
	[animationGroup setAnimations:[NSArray arrayWithObjects:opactiyAnimation, zPosAnimation, scaleAnimation, pathAnimation, nil]];
	
	animationGroup.delegate = self;
	[animationGroup setValue:contentsLayer forKey:@"ContentsLayer"];
	[backLayer addAnimation:animationGroup forKey:@"FlyInAnimation"];
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	
}

- (void)splitHorizontalFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController{
    
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
	UIImage *image = nil;
	UIGraphicsBeginImageContextWithOptions(toController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[toController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	CGRect originFrame = fromController.view.bounds;
	CGRect destFrame = toController.view.bounds;
	
	CGFloat diff = originFrame.size.height - destFrame.size.height;
	originFrame.origin.y -= diff;
	
	CALayer *contentsLayer = [CALayer layer];
	contentsLayer.frame = fromController.view.bounds;
	contentsLayer.backgroundColor = [UIColor viewFlipsideBackgroundColor].CGColor;
	[toController.view.layer addSublayer:contentsLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.contents = (id)image.CGImage;
	backLayer.doubleSided = NO;
	backLayer.frame = destFrame;
	backLayer.zPosition = 200.0f;
	backLayer.contentsScale = [[UIScreen mainScreen] scale];
	backLayer.contentsGravity = kCAGravityCenter;
	[contentsLayer addSublayer:backLayer];
    
	[fromController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CALayer *leftLayer = [CALayer layer];
	leftLayer.zPosition = 0.0f;
	leftLayer.contents = (id)image.CGImage;
	leftLayer.masksToBounds = YES;
	leftLayer.frame = CGRectMake(floorf( originFrame.origin.x - ((originFrame.size.width/2)/2)), originFrame.origin.y, floorf(originFrame.size.width/2), originFrame.size.height);
	leftLayer.anchorPoint = CGPointMake(0.0f, 0.5f);
	leftLayer.contentsScale = [[UIScreen mainScreen] scale];
	leftLayer.contentsGravity = kCAGravityLeft;
	[contentsLayer addSublayer:leftLayer];
	
	CALayer *rightLayer = [CALayer layer];
	rightLayer.zPosition = 0.0f;
    
	rightLayer.contents = (id)image.CGImage;
	rightLayer.masksToBounds = YES;
	rightLayer.frame = CGRectMake(floorf(originFrame.size.width - ((originFrame.size.width/2)/2)) , originFrame.origin.y, floorf(originFrame.size.width/2), originFrame.size.height);
	rightLayer.anchorPoint = CGPointMake(1.0f, 0.5f);
	rightLayer.contentsScale = [[UIScreen mainScreen] scale];
	rightLayer.contentsGravity = kCAGravityRight;
	[contentsLayer addSublayer:rightLayer];
	
	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = (ANIMATION_DURATION+0.3f)/2;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	
	CABasicAnimation *transform = [CABasicAnimation animationWithKeyPath:@"transform"];
	transform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((M_PI/180)*90.0f, 0.0f, 1.0f, 0.0f)];
	CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
	position.toValue = [NSValue valueWithCGPoint:CGPointMake(leftLayer.position.x - 20.0f, leftLayer.position.y)];
	[animationGroup setAnimations:[NSArray arrayWithObjects:transform, position, nil]];
	[leftLayer addAnimation:animationGroup forKey:@"TopAnimation"];
	
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = (ANIMATION_DURATION+0.3f)/2;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	
	transform = [CABasicAnimation animationWithKeyPath:@"transform"];
	transform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((M_PI/180)*-90.0f, 0.0f, 1.0f, 0.0f)];
	position = [CABasicAnimation animationWithKeyPath:@"position"];
	position.toValue = [NSValue valueWithCGPoint:CGPointMake(rightLayer.position.x + 20.0f, rightLayer.position.y)];
	[animationGroup setAnimations:[NSArray arrayWithObjects:transform, position, nil]];
	[rightLayer addAnimation:animationGroup forKey:@"TopAnimation"];
    
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = (ANIMATION_DURATION+0.3f);
	animationGroup.fillMode = kCAFillModeRemoved;
	animationGroup.delegate = self;
	animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[animationGroup setValue:contentsLayer forKey:@"ContentsLayer"];
    
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityAnimation.fromValue = [NSNumber numberWithFloat:0.01f];
	opacityAnimation.toValue = [NSNumber numberWithFloat:1.0f];
	
	[animationGroup setAnimations:[NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil]];
	[backLayer addAnimation:animationGroup forKey:@"BackAnimation"];
	
}

- (void)splitVerticalFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController{
    
	UIImage *image=nil;
	UIGraphicsBeginImageContextWithOptions(toController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[toController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	CGRect originFrame = fromController.view.bounds;
	CGRect destFrame = toController.view.bounds;
	
	CGFloat diff = originFrame.size.height - destFrame.size.height;
	originFrame.origin.y -= diff;
	
	CALayer *contentsLayer = [CALayer layer];
	contentsLayer.frame = fromController.view.bounds;
	contentsLayer.backgroundColor = [UIColor viewFlipsideBackgroundColor].CGColor;
	[toController.view.layer addSublayer:contentsLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.shouldRasterize = YES;
	backLayer.contents = (id)image.CGImage;
	backLayer.doubleSided = NO;
	backLayer.frame = destFrame;
	backLayer.zPosition = 0.0f;
	backLayer.contentsScale = [[UIScreen mainScreen] scale];
	backLayer.contentsGravity = kCAGravityCenter;
	[contentsLayer addSublayer:backLayer];
	
	[fromController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CALayer *topLayer = [CALayer layer];
	topLayer.shouldRasterize = YES;
	topLayer.contents = (id)image.CGImage;
	topLayer.masksToBounds = YES;
	topLayer.frame = CGRectMake(originFrame.origin.x, originFrame.origin.y - floorf((originFrame.size.height/2)/2), originFrame.size.width, floorf(originFrame.size.height/2));
	topLayer.anchorPoint = CGPointMake(0.5f, 0.0f);
	topLayer.contentsScale = [[UIScreen mainScreen] scale];
	topLayer.contentsGravity = kCAGravityBottom;
	[contentsLayer addSublayer:topLayer];
    
	CALayer *bottomLayer = [CALayer layer];
	bottomLayer.shouldRasterize = YES;
	bottomLayer.contents = (id)image.CGImage;
	bottomLayer.masksToBounds = YES;
	bottomLayer.frame = CGRectMake(originFrame.origin.x, originFrame.size.height - floorf((originFrame.size.height/2)/2), originFrame.size.width, floorf(originFrame.size.height/2));
	bottomLayer.anchorPoint = CGPointMake(0.5f, 1.0f);
	bottomLayer.contentsScale = [[UIScreen mainScreen] scale];
	bottomLayer.contentsGravity = kCAGravityTop;
	[contentsLayer addSublayer:bottomLayer];
    
	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = ANIMATION_DURATION+0.2f;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	
	CABasicAnimation *transform = [CABasicAnimation animationWithKeyPath:@"transform"];
	transform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((M_PI/180)*90.0f, 1.0f, 0.0f, 0.0f)];
	CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
	position.toValue = [NSValue valueWithCGPoint:CGPointMake(topLayer.position.x, topLayer.position.y - 20.0f)];
	[animationGroup setAnimations:[NSArray arrayWithObjects:transform, position, nil]];
	[topLayer addAnimation:animationGroup forKey:@"TopAnimation"];
	
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = ANIMATION_DURATION+0.2f;
	animationGroup.removedOnCompletion = NO;
	animationGroup.fillMode = kCAFillModeForwards;
	
	transform = [CABasicAnimation animationWithKeyPath:@"transform"];
	transform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((M_PI/180)*-90.0f, 1.0f, 0.0f, 0.0f)];
	position = [CABasicAnimation animationWithKeyPath:@"position"];
	position.toValue = [NSValue valueWithCGPoint:CGPointMake(bottomLayer.position.x, bottomLayer.position.y + 20.0f)];
	[animationGroup setAnimations:[NSArray arrayWithObjects:transform, position, nil]];
	[bottomLayer addAnimation:animationGroup forKey:@"TopAnimation"];
	
	animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = (ANIMATION_DURATION+0.4f);
	animationGroup.fillMode = kCAFillModeRemoved;
	animationGroup.delegate = self;
	animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[animationGroup setValue:contentsLayer forKey:@"ContentsLayer"];
	
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityAnimation.fromValue = [NSNumber numberWithFloat:0.01f];
	opacityAnimation.toValue = [NSNumber numberWithFloat:1.0f];
	
	[animationGroup setAnimations:[NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil]];
	[backLayer addAnimation:animationGroup forKey:@"BackAnimation"];
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

- (void)flipWithGapFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController style:(XHUIModalTransitionStyleAddition)style{
    
	BOOL _left = (style == kXHUIModalTransitionStyleFlipLeftWithGap);
	
	UIImage *image=nil;
	UIGraphicsBeginImageContextWithOptions(toController.view.bounds.size, YES, [[UIScreen mainScreen] scale]);
	[toController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	CGRect originFrame = fromController.view.bounds;
	CGRect destFrame = toController.view.bounds;
    
	CGFloat diff = originFrame.size.height - destFrame.size.height;
	originFrame.origin.y -= diff;
    
	CALayer *contentsLayer = [CALayer layer];
	contentsLayer.frame = fromController.view.bounds;
	contentsLayer.backgroundColor = [UIColor viewFlipsideBackgroundColor].CGColor;
	[toController.view.layer addSublayer:contentsLayer];
	
	CATransformLayer *transformLayer = [CATransformLayer layer];
	transformLayer.frame = contentsLayer.bounds;
	[contentsLayer addSublayer:transformLayer];
	
	CALayer *backLayer = [CALayer layer];;
	backLayer.contents = (id)image.CGImage;
	backLayer.doubleSided = NO;
	backLayer.frame = destFrame;
	backLayer.zPosition = 0.0f;
	backLayer.transform = [self transformWithDegrees__:180.0f];
	backLayer.contentsScale = [[UIScreen mainScreen] scale];
	backLayer.contentsGravity = kCAGravityCenter;
	[transformLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	[fromController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	frontLayer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
	UIGraphicsEndImageContext();
	
	//frontLayer.contents = (id)[self contentsForView__:fromController.view].CGImage;
	frontLayer.doubleSided = NO;
	frontLayer.frame = originFrame;
	frontLayer.zPosition = FLIP_GAP_WIDTH;
	frontLayer.contentsScale = [[UIScreen mainScreen] scale];
	frontLayer.contentsGravity = kCAGravityCenter;
	[transformLayer addSublayer:frontLayer];
	
	CALayer *sideLayer = [CALayer layer];
	sideLayer.backgroundColor = [UIColor scrollViewTexturedBackgroundColor].CGColor;
	sideLayer.zPosition = FLIP_GAP_WIDTH/2;
	
	if (_left) {
		sideLayer.frame = CGRectMake(transformLayer.bounds.size.width-(FLIP_GAP_WIDTH/2), transformLayer.bounds.origin.y, FLIP_GAP_WIDTH, transformLayer.bounds.size.height);
		sideLayer.transform = [self transformWithDegrees__:-90.0f];
	} else {
		sideLayer.frame = CGRectMake(transformLayer.bounds.origin.x-(FLIP_GAP_WIDTH/2), transformLayer.bounds.origin.y, FLIP_GAP_WIDTH, transformLayer.bounds.size.height);
		sideLayer.transform = [self transformWithDegrees__:90.0f];
	}
    
	sideLayer.contentsScale = [[UIScreen mainScreen] scale];
	[transformLayer addSublayer:sideLayer];
    
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.toValue = [NSValue valueWithCATransform3D:[self transformWithDegrees__:_left ? 180.0f : 179.9f]];
	animation.duration = ANIMATION_DURATION+0.6;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.delegate = self;
	[animation setValue:contentsLayer forKey:@"ContentsLayer"];
	[transformLayer addAnimation:animation forKey:@"FlipAnimation"];
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
}


#pragma mark -
#pragma mark Presentation Methods

- (void)presentModalViewController:(UIViewController *)modalViewController withAnimationStyle:(XHUIModalTransitionStyleAddition)style{
	
	[self presentModalViewController:modalViewController animated:NO];
	
	switch (style) {
		case kXHUIModalTransitionStyleFlipRightWithGap:
			[self flipWithGapFromViewController:self toViewController:modalViewController style:style];
			break;
		case kXHUIModalTransitionStyleFlipLeftWithGap:
			[self flipWithGapFromViewController:self toViewController:modalViewController style:style];
			break;
		case kXHUIModalTransitionStyleSplitVertical:
			[self splitVerticalFromViewController:self toViewController:modalViewController];
			break;
		case kXHUIModalTransitionStyleSplitHorizontal:
			[self splitHorizontalFromViewController:self toViewController:modalViewController];
			break;
		case kXHUIModalTransitionStyleFlyInFromRight:
			[self flyInFromViewController:self toViewController:modalViewController style:style];
			break;
		case kXHUIModalTransitionStyleFlyInFromLeft:
			[self flyInFromViewController:self toViewController:modalViewController style:style];
			break;
		case kXHUIModalTransitionStyleDiveInFromRight:
			[self diveInFromViewController:self toViewController:modalViewController style:style];
			break;
		case kXHUIModalTransitionStyleDiveInFromLeft:
			[self diveInFromViewController:self toViewController:modalViewController style:style];
			break;
		default:
			break;
	}
    
}

- (void)dismissModalViewControllerWithAnimationStyle:(XHUIModalTransitionStyleAddition)style {
	
	UIViewController *fromController = self;
	if (self.navigationController) {
		fromController = self.navigationController;
	}
	
	UIViewController *modalViewController = fromController.modalViewController;
	if (!modalViewController) {
		modalViewController = fromController.parentViewController;
	}
    if (modalViewController) {
        switch (style) {
            case kXHUIModalTransitionStyleFlipRightWithGap:
                [self flipWithGapFromViewController:fromController toViewController:modalViewController style:style];
                break;
            case kXHUIModalTransitionStyleFlipLeftWithGap:
                [self flipWithGapFromViewController:fromController toViewController:modalViewController style:style];
                break;
            case kXHUIModalTransitionStyleSplitVertical:
                [self splitVerticalFromViewController:fromController toViewController:modalViewController];
                break;
            case kXHUIModalTransitionStyleSplitHorizontal:
                [self splitHorizontalFromViewController:fromController toViewController:modalViewController];
                break;
            case kXHUIModalTransitionStyleFlyInFromRight:
                [self flyInFromViewController:fromController toViewController:modalViewController style:style];
                break;
            case kXHUIModalTransitionStyleFlyInFromLeft:
                [self flyInFromViewController:fromController toViewController:modalViewController style:style];
                break;
            case kXHUIModalTransitionStyleDiveInFromRight:
                [self diveInFromViewController:fromController toViewController:modalViewController style:style];
                break;
            case kXHUIModalTransitionStyleDiveInFromLeft:
                [self diveInFromViewController:fromController toViewController:modalViewController style:style];
                break;
            default:
                break;
        }
        
    }
	
	[self dismissModalViewControllerAnimated:NO];
	
}

@end
