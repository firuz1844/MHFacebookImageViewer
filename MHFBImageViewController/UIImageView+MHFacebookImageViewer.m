//
//  UIImageView+MHFacebookImageViewer.m
//  FBImageViewController_Demo
//
//  Created by Firuz Narzikulov on 10/10/14.
//  Copyright (c) 2014 Michael Henry Pantaleon. All rights reserved.
//

#import "UIImageView+MHFacebookImageViewer.h"
#import "MHFacebookImageViewer.h"
#import "MHFacebookImageViewerTapGestureRecognizer.h"

@interface UIImageView()<UITabBarControllerDelegate>

@property (nonatomic, retain) UINavigationController *presentingViewController;

@end

@implementation UIImageView (MHFacebookImageViewer)


UINavigationController *_presentingViewController;



- (void) setupImageViewer {
    [self setupImageViewerWithCompletionOnOpen:nil onClose:nil];
}

- (void) setupImageViewerWithCompletionOnOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close {
    [self setupImageViewerWithImageURL:nil onOpen:open onClose:close];
}

- (void) setupImageViewerWithImageURL:(NSURL*)url {
    [self setupImageViewerWithImageURL:url onOpen:nil onClose:nil];
}


- (void) setupImageViewerWithImageURL:(NSURL *)url onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close{
    self.userInteractionEnabled = YES;
    MHFacebookImageViewerTapGestureRecognizer *  tapGesture = [[MHFacebookImageViewerTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.imageURL = url;
    tapGesture.openingBlock = open;
    tapGesture.closingBlock = close;
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
}


- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close {
    [self setupImageViewerWithDatasource:imageDatasource initialIndex:0 onOpen:open onClose:close];
}

- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource initialIndex:(NSInteger)initialIndex onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close{
    self.userInteractionEnabled = YES;
    MHFacebookImageViewerTapGestureRecognizer *  tapGesture = [[MHFacebookImageViewerTapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.imageDatasource = imageDatasource;
    tapGesture.openingBlock = open;
    tapGesture.closingBlock = close;
    tapGesture.initialIndex = initialIndex;
    [self addGestureRecognizer:tapGesture];
    tapGesture = nil;
}


#pragma mark - Handle Tap
- (void) didTap:(MHFacebookImageViewerTapGestureRecognizer*)gestureRecognizer {
    
    MHFacebookImageViewer * imageBrowser = [[MHFacebookImageViewer alloc]init];
    imageBrowser.senderView = self;
    imageBrowser.imageURL = gestureRecognizer.imageURL;
    imageBrowser.openingBlock = gestureRecognizer.openingBlock;
    imageBrowser.closingBlock = gestureRecognizer.closingBlock;
    imageBrowser.imageDatasource = gestureRecognizer.imageDatasource;
    imageBrowser.initialIndex = gestureRecognizer.initialIndex;
    [imageBrowser presentFromViewController:_presentingViewController];
}

- (void) dealloc {
    
}

- (void) setPresentingViewController:(UINavigationController *)presentingViewController {
    _presentingViewController = presentingViewController;
}

#pragma mark Removal
- (void)removeImageViewer
{
    for (UIGestureRecognizer * gesture in self.gestureRecognizers)
    {
        if ([gesture isKindOfClass:[MHFacebookImageViewerTapGestureRecognizer class]])
        {
            [self removeGestureRecognizer:gesture];
            
            MHFacebookImageViewerTapGestureRecognizer *  tapGesture = (MHFacebookImageViewerTapGestureRecognizer *)gesture;
            tapGesture.imageURL = nil;
            tapGesture.openingBlock = nil;
            tapGesture.closingBlock = nil;
        }
    }
}

@end