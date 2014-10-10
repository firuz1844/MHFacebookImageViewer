//
//  UIImageView+MHFacebookImageViewer.h
//  FBImageViewController_Demo
//
//  Created by Firuz Narzikulov on 10/10/14.
//  Copyright (c) 2014 Michael Henry Pantaleon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHFacebookImageViewer.h"

@protocol MHFacebookImageViewerDatasource;

@interface UIImageView (MHFacebookImageViewer)

- (void) setupImageViewer;
- (void) setupImageViewerWithCompletionOnOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close;
- (void) setupImageViewerWithImageURL:(NSURL*)url;
- (void) setupImageViewerWithImageURL:(NSURL *)url onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close;
- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close;
- (void) setupImageViewerWithDatasource:(id<MHFacebookImageViewerDatasource>)imageDatasource initialIndex:(NSInteger)initialIndex onOpen:(MHFacebookImageViewerOpeningBlock)open onClose:(MHFacebookImageViewerClosingBlock)close;
- (void)removeImageViewer;

@end
