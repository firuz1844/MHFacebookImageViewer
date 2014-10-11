//
//  MHFacebookImageViewerCell.m
//  FBImageViewController_Demo
//
//  Created by Firuz Narzikulov on 10/10/14.
//  Copyright (c) 2014 Michael Henry Pantaleon. All rights reserved.
//

#import "MHFacebookImageViewerCell.h"
#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"

@interface MHFacebookImageViewerCell ()

@end

@implementation MHFacebookImageViewerCell

@synthesize originalFrameRelativeToScreen = _originalFrameRelativeToScreen;
@synthesize rootViewController = _rootViewController;
@synthesize viewController = _viewController;
@synthesize blackMask = _blackMask;
@synthesize closingBlock = _closingBlock;
@synthesize openingBlock = _openingBlock;
@synthesize doneButton = _doneButton;
@synthesize senderView = _senderView;
@synthesize imageIndex = _imageIndex;
@synthesize superView = _superView;
@synthesize defaultImage = _defaultImage;
@synthesize initialIndex = _initialIndex;
@synthesize panGesture = _panGesture;

- (void) loadAllRequiredViews{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    __scrollView = [[UIScrollView alloc]initWithFrame:frame];
    __scrollView.delegate = self;
    __scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:__scrollView];
    [_doneButton addTarget:self
                    action:@selector(close:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void) setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex {
    _imageIndex = imageIndex;
    _defaultImage = defaultImage;
    
    
    _senderView.alpha = 0.0f;
    if(!__imageView){
        __imageView = [[UIImageView alloc]init];
        [__scrollView addSubview:__imageView];
        __imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    __block UIImageView * _imageViewInTheBlock = __imageView;
    __block MHFacebookImageViewerCell * _justMeInsideTheBlock = self;
    __block UIScrollView * _scrollViewInsideBlock = __scrollView;
    
    [__imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:defaultImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [_scrollViewInsideBlock setZoomScale:1.0f animated:YES];
        [_imageViewInTheBlock setImage:image];
        _imageViewInTheBlock.frame = [_justMeInsideTheBlock centerFrameFromImage:_imageViewInTheBlock.image];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Image From URL Not loaded");
        [_imageViewInTheBlock setImage:[UIImage imageNamed:@"Done"]];
    }];
    
    if(_imageIndex==_initialIndex && !_isLoaded){
        __imageView.frame = _originalFrameRelativeToScreen;
        [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
            __imageView.frame = [self centerFrameFromImage:__imageView.image];
            CGAffineTransform transf = CGAffineTransformIdentity;
            // Root View Controller - move backward
            _rootViewController.view.transform = CGAffineTransformScale(transf, 0.95f, 0.95f);
            // Root View Controller - move forward
            //                _viewController.view.transform = CGAffineTransformScale(transf, 1.05f, 1.05f);
            _blackMask.alpha = kMaxBlackMaskAlpha;
        }   completion:^(BOOL finished) {
            if (finished) {
                _isAnimating = NO;
                _isLoaded = YES;
                if(_openingBlock)
                    _openingBlock();
            }
        }];
        
    }
    __imageView.userInteractionEnabled = YES;
    [self addPanGestureToView:__imageView];
    [self addMultipleGesture];
    
}

#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    _panGesture.cancelsTouchesInView = NO;
    _panGesture.delegate = self;
    UICollectionView * superCollectionView = (UICollectionView*) [[[view superview] superview] superview];
    if ([superCollectionView isKindOfClass:[UICollectionView class]]) {
        [superCollectionView.panGestureRecognizer requireGestureRecognizerToFail:_panGesture];
    }
    [view addGestureRecognizer:_panGesture];
    [_gestures addObject:_panGesture];
    
}

# pragma mark - Avoid Unwanted Horizontal Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:__scrollView];
    return fabs(translation.y) > fabs(translation.x) ;
}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    _panOrigin = __imageView.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_isAnimating;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer == _panGesture) {
        return YES;
    }
    return NO;
}

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(__scrollView.zoomScale != 1.0f || _isAnimating)return;
    if(_imageIndex==_initialIndex){
        if(_senderView.alpha!=0.0f)
            _senderView.alpha = 0.0f;
    }else {
        if(_senderView.alpha!=1.0f)
            _senderView.alpha = 1.0f;
    }
    // Hide the Done Button
    [self hideDoneButton];
    __scrollView.bounces = NO;
    CGSize windowSize = _blackMask.bounds.size;
    CGPoint currentPoint = [panGesture translationInView:__scrollView];
    CGFloat y = currentPoint.y + _panOrigin.y;
    CGRect frame = __imageView.frame;
    frame.origin.y = y;
    
    __imageView.frame = frame;
    
    CGFloat yDiff = abs((y + __imageView.frame.size.height/2) - windowSize.height/2);
    _blackMask.alpha = MAX(kMaxBlackMaskAlpha - yDiff/(windowSize.height/0.5),kMinBlackMaskAlpha);
    
    if ((panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) && __scrollView.zoomScale == 1.0f) {
        
        if(_blackMask.alpha < kMaxBlackMaskAlpha - kDismissGestureSensitivity * 0.02) {
            [self dismissViewController];
        }else {
            [self rollbackViewController];
        }
    }
}

#pragma mark - Just Rollback
- (void)rollbackViewController
{
    _isAnimating = YES;
    [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
        __imageView.frame = [self centerFrameFromImage:__imageView.image];
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _isAnimating = NO;
        }
    }];
}


#pragma mark - Dismiss
- (void)dismissViewController
{
    _isAnimating = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideDoneButton];
        __imageView.clipsToBounds = YES;
        CGFloat screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        CGFloat imageYCenterPosition = __imageView.frame.origin.y + __imageView.frame.size.height/2 ;
        BOOL isGoingUp =  imageYCenterPosition < screenHeight/2;
        [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
            if(_imageIndex==_initialIndex){
                __imageView.frame = _originalFrameRelativeToScreen;
            }else {
                __imageView.frame = CGRectMake(__imageView.frame.origin.x, isGoingUp?-screenHeight:screenHeight, __imageView.frame.size.width, __imageView.frame.size.height);
            }
            CGAffineTransform transf = CGAffineTransformIdentity;
            _rootViewController.view.transform = CGAffineTransformScale(transf, 1.0f, 1.0f);
            _blackMask.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                //                [_viewController.view removeFromSuperview];
                //                [_viewController removeFromParentViewController];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                [_viewController dismissViewControllerAnimated:NO completion:^{
                    _senderView.alpha = 1.0f;
                    [UIApplication sharedApplication].statusBarHidden = NO;
                    [UIApplication sharedApplication].statusBarStyle = _statusBarStyle;
                    _isAnimating = NO;
                    if(_closingBlock)
                        _closingBlock();
                }];
            }
        }];
    });
}

#pragma mark - Compute the new size of image relative to width(window)
- (CGRect) centerFrameFromImage:(UIImage*) image {
    if(!image) return CGRectZero;
    
    CGRect windowBounds = _rootViewController.view.bounds;
    CGSize newImageSize = [self imageResizeBaseOnWidth:windowBounds
                           .size.width oldWidth:image
                           .size.width oldHeight:image.size.height];
    // Just fit it on the size of the screen
    newImageSize.height = MIN(windowBounds.size.height,newImageSize.height);
    return CGRectMake(0.0f, windowBounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat) newWidth oldWidth:(CGFloat) oldWidth oldHeight:(CGFloat)oldHeight {
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    return CGSizeMake(newWidth, newHeight);
    
}

# pragma mark - UIScrollView Delegate
- (void)centerScrollViewContents {
    CGSize boundsSize = _rootViewController.view.bounds.size;
    CGRect contentsFrame = __imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    __imageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return __imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _isAnimating = YES;
    [self hideDoneButton];
    [self centerScrollViewContents];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    _isAnimating = NO;
}

- (void)addMultipleGesture {
    UITapGestureRecognizer *twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTwoFingerTap:)];
    twoFingerTapGesture.numberOfTapsRequired = 1;
    twoFingerTapGesture.numberOfTouchesRequired = 2;
    [__scrollView addGestureRecognizer:twoFingerTapGesture];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [__scrollView addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDobleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [__scrollView addGestureRecognizer:doubleTapRecognizer];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    __scrollView.minimumZoomScale = kMinImageScale;
    __scrollView.maximumZoomScale = kMaxImageScale;
    __scrollView.zoomScale = 1;
    [self centerScrollViewContents];
}

#pragma mark - For Zooming
- (void)didTwoFingerTap:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = __scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, __scrollView.minimumZoomScale);
    [__scrollView setZoomScale:newZoomScale animated:YES];
}

#pragma mark - Showing of Done Button if ever Zoom Scale is equal to 1
- (void)didSingleTap:(UITapGestureRecognizer*)recognizer {
    if(_doneButton.superview){
        [self hideDoneButton];
    }else {
        if(__scrollView.zoomScale == __scrollView.minimumZoomScale){
            if(!_isDoneAnimating){
                _isDoneAnimating = YES;
                [self.viewController.view addSubview:_doneButton];
                _doneButton.alpha = 0.0f;
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    _doneButton.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [self.viewController.view bringSubviewToFront:_doneButton];
                    _isDoneAnimating = NO;
                }];
            }
        }else if(__scrollView.zoomScale == __scrollView.maximumZoomScale) {
            CGPoint pointInView = [recognizer locationInView:__imageView];
            [self zoomInZoomOut:pointInView];
        }
    }
}

#pragma mark - Zoom in or Zoom out
- (void)didDobleTap:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:__imageView];
    [self zoomInZoomOut:pointInView];
}

- (void) zoomInZoomOut:(CGPoint)point {
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = __scrollView.zoomScale > (__scrollView.maximumZoomScale/2)?__scrollView.minimumZoomScale:__scrollView.maximumZoomScale;
    
    CGSize scrollViewSize = __scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [__scrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark - Hide the Done Button
- (void) hideDoneButton {
    if(!_isDoneAnimating){
        if(_doneButton.superview) {
            _isDoneAnimating = YES;
            _doneButton.alpha = 1.0f;
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                _doneButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                _isDoneAnimating = NO;
                [_doneButton removeFromSuperview];
            }];
        }
    }
}

- (void)close:(UIButton *)sender {
    self.userInteractionEnabled = NO;
    [sender removeFromSuperview];
    [self dismissViewController];
}

- (void) dealloc {
    
}

@end
