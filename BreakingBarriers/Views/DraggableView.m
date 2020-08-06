//
//  DraggableView.m
//  RKSwipeCards
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize tapGestureRecognizer;
@synthesize sourceText;
@synthesize targetText;
@synthesize overlayView;
@synthesize backView;
@synthesize frontView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setUpCards];
        
        sourceText = [[UILabel alloc]initWithFrame:CGRectMake(8, self.frame.size.height / 2 - 100, self.frame.size.width - 16, 200)];
        sourceText.textColor = [UIColor blackColor];
        sourceText.numberOfLines = 0;
        sourceText.textAlignment = NSTextAlignmentCenter;
        targetText = [[UILabel alloc]initWithFrame:CGRectMake(8, self.frame.size.height / 2 - 100, self.frame.size.width - 16, 200)];
        targetText.textColor = [UIColor blackColor];
        targetText.numberOfLines = 0;
        targetText.textAlignment = NSTextAlignmentCenter;
        [sourceText setFont:[UIFont systemFontOfSize:25]];
        [targetText setFont:[UIFont systemFontOfSize:25]];
        [backView addSubview:targetText];
        [frontView addSubview:sourceText];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flipCard:)];
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [self addGestureRecognizer:panGestureRecognizer];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.bounds.size.width / 2 - 50, self.bounds.size.height / 2 - 50, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
    }
    return self;
}

- (void)setUpCards {
    self.frontHidden = YES;
    
    // set front card
    self.frontView = [[UIView alloc]initWithFrame:self.bounds];
    self.frontView.layer.cornerRadius = 15;
    [self.frontView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.frontView.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.frontView.layer setShadowRadius:1.0];
    [self.frontView.layer setShadowOpacity:0.5];
    self.frontView.clipsToBounds = false;
    self.frontView.layer.masksToBounds = false;
    self.frontView.backgroundColor = UIColor.whiteColor;
    
    // set back card
    self.backView = [[UIView alloc]initWithFrame:self.bounds];
    self.backView.layer.cornerRadius = 15;
    [self.backView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.backView.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.backView.layer setShadowRadius:1.0];
    [self.backView.layer setShadowOpacity:0.5];
    self.backView.clipsToBounds = false;
    self.backView.layer.masksToBounds = false;
    self.backView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.frontView];
    [self addSubview:self.backView];
}

- (void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

- (void)flipCard:(UITapGestureRecognizer *)tap {
    if (self.frontHidden) {
        UIViewAnimationOptions transitionOption = UIViewAnimationOptionTransitionFlipFromLeft;
        [UIView transitionFromView:self.backView toView:self.frontView duration:0.5 options:(transitionOption | UIViewAnimationOptionShowHideTransitionViews) completion:^(BOOL finished) {
            NSLog(@"Success! for back to front");
            self.frontHidden = NO;
        }];
    } else {
        UIViewAnimationOptions transitionOption = UIViewAnimationOptionTransitionFlipFromRight;
        [UIView transitionFromView:self.frontView toView:self.backView duration:0.5 options:(transitionOption | UIViewAnimationOptionShowHideTransitionViews) completion:^(BOOL finished) {
            NSLog(@"Success! for front to back");
            self.frontHidden = YES;
        }];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    
    overlayView.alpha = MIN(fabsf(distance)/100, 0.4);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint center = self.center;
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         overlayView.alpha = 0;
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         overlayView.alpha = 0;
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)rightClickAction
{
    self.originalPoint = self.center;
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         overlayView.alpha = 0;
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    self.originalPoint = self.center;
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         overlayView.alpha = 0;
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}



@end
