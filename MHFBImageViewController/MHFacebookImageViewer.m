//
// MHFacebookImageViewer.m
// Version 2.0
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "MHFacebookImageViewer.h"

///1 - maximum sensitive, 10 - minimum sensitive
NSInteger kDismissGestureSensitivity = 3;
CGFloat kMaxBlackMaskAlpha = 0.7f;
CGFloat kMinBlackMaskAlpha = 0.3f;
CGFloat kMaxImageScale = 2.5f;
CGFloat kMinImageScale = 1.0f;

static NSString * cellID = @"mhfacebookImageViewerCell";


@interface MHFacebookImageViewer() <UIGestureRecognizerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *_gestures;
    
    UICollectionView * _collectionView;
    UIView *_blackMask;
    UIImageView * _imageView;
    UIButton * _doneButton;
    UIView * _superView;
    
    CGPoint _panOrigin;
    CGRect _originalFrameRelativeToScreen;
    
    BOOL _isAnimating;
    BOOL _isDoneAnimating;
    
    UIStatusBarStyle _statusBarStyle;
}

@end

@implementation MHFacebookImageViewer

@synthesize imageURL = _imageURL;
@synthesize openingBlock = _openingBlock;
@synthesize closingBlock = _closingBlock;
@synthesize senderView = _senderView;
@synthesize initialIndex = _initialIndex;
@synthesize presentingViewController = _presentingViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [UIApplication sharedApplication].statusBarHidden = YES;
    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    
    // Compute Original Frame Relative To Screen
    CGRect newFrame = [_senderView convertRect:windowBounds toView:nil];
    newFrame.origin = CGPointMake(newFrame.origin.x, newFrame.origin.y);
    newFrame.size = _senderView.frame.size;
    _originalFrameRelativeToScreen = newFrame;
    
    // Add a CollectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //    [flowLayout setItemSize:self.view.frame.size];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:windowBounds collectionViewLayout:flowLayout];
    [_collectionView registerClass:[MHFacebookImageViewerCell class] forCellWithReuseIdentifier:cellID];
    
    [self.view addSubview:_collectionView];
    
    _collectionView.pagingEnabled = YES;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delaysContentTouches = YES;
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setContentOffset:CGPointMake(0, _initialIndex * windowBounds.size.width)];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _blackMask = [[UIView alloc] initWithFrame:windowBounds];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0f;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:_blackMask atIndex:0];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setImageEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];  // make click area bigger
    [_doneButton setImage:[UIImage imageNamed:@"Done"] forState:UIControlStateNormal];
    _doneButton.frame = CGRectMake(windowBounds.size.width - (51.0f + 9.0f),15.0f, 51.0f, 26.0f);
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - CollectionView datasource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(!self.imageDatasource) return 1;
    return [self.imageDatasource numberImagesForImageViewer:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        size = self.view.frame.size;
    } else {
        size = CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);
    }
    return size;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MHFacebookImageViewerCell * imageViewerCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [imageViewerCell loadAllRequiredViews];
    
    imageViewerCell.backgroundColor = [UIColor clearColor];
    imageViewerCell.originalFrameRelativeToScreen = _originalFrameRelativeToScreen;
    imageViewerCell.viewController = self;
    imageViewerCell.presentingViewController = _presentingViewController;

    imageViewerCell.collectionView = collectionView;    
    imageViewerCell.blackMask = _blackMask;
    imageViewerCell.closingBlock = _closingBlock;
    imageViewerCell.openingBlock = _openingBlock;
    imageViewerCell.superView = _senderView.superview;
    imageViewerCell.senderView = _senderView;
    imageViewerCell.doneButton = _doneButton;
    imageViewerCell.initialIndex = _initialIndex;
    imageViewerCell.statusBarStyle = _statusBarStyle;
    [imageViewerCell loadAllRequiredViews];
    imageViewerCell.backgroundColor = [UIColor clearColor];
    if(!self.imageDatasource) {
        // Just to retain the old version
        [imageViewerCell setImageURL:_imageURL defaultImage:_senderView.image imageIndex:0];
    } else {
        [imageViewerCell setImageURL:[self.imageDatasource imageURLAtIndex:indexPath.row imageViewer:self] defaultImage:[self.imageDatasource imageDefaultAtIndex:indexPath.row imageViewer:self]imageIndex:indexPath.row];
    }
    return imageViewerCell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Show

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"Rotate MHF");
}

- (void)presentFromViewController:(UINavigationController*)controller
{
    if (controller) {
        _presentingViewController= controller;
    } else {
        _presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    _presentingViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _presentingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [_presentingViewController presentViewController:self animated:NO completion:^{}];
}

- (void) dealloc {
    _presentingViewController = nil;
    _imageURL = nil;
    _senderView = nil;
    _imageDatasource = nil;
}

@end