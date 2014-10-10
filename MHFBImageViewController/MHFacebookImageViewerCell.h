//
//  MHFacebookImageViewerCell.h
//  FBImageViewController_Demo
//
//  Created by Firuz Narzikulov on 10/10/14.
//  Copyright (c) 2014 Michael Henry Pantaleon. All rights reserved.
//


typedef void (^MHFacebookImageViewerOpeningBlock)(void);
typedef void (^MHFacebookImageViewerClosingBlock)(void);

#import <UIKit/UIKit.h>

@interface MHFacebookImageViewerCell : UICollectionViewCell <UIGestureRecognizerDelegate,UIScrollViewDelegate>{
    UIImageView * __imageView;
    UIScrollView * __scrollView;
    NSMutableArray *_gestures;
    CGPoint _panOrigin;
    BOOL _isAnimating;
    BOOL _isDoneAnimating;
    BOOL _isLoaded;
}

@property(nonatomic,assign) CGRect originalFrameRelativeToScreen;
@property(nonatomic,weak) UIViewController * rootViewController;
@property(nonatomic,weak) UIViewController * viewController;
@property(nonatomic,weak) UIView * blackMask;
@property(nonatomic,weak) UIButton * doneButton;
@property(nonatomic,weak) UIImageView * senderView;
@property(nonatomic,assign) NSInteger imageIndex;
@property(nonatomic,weak) UIImage * defaultImage;
@property(nonatomic,assign) NSInteger initialIndex;
@property(nonatomic,strong) UIPanGestureRecognizer* panGesture;

@property (nonatomic,weak) MHFacebookImageViewerOpeningBlock openingBlock;
@property (nonatomic,weak) MHFacebookImageViewerClosingBlock closingBlock;

@property(nonatomic,weak) UIView * superView;

@property(nonatomic) UIStatusBarStyle statusBarStyle;

- (void) loadAllRequiredViews;
- (void) setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex;

@end