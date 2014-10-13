//
//  MHFacebookImageViewerTapGestureRecognizer.h
//  FBImageViewController_Demo
//
//  Created by Firuz Narzikulov on 10/10/14.
//  Copyright (c) 2014 Michael Henry Pantaleon. All rights reserved.

//  Custom Gesture Recognizer that will Handle imageURL

#import <UIKit/UIKit.h>
#import "MHFacebookImageViewer.h"
#import "MHFacebookImageViewerCell.h"

@protocol MHFacebookImageViewerDatasource;

@interface MHFacebookImageViewerTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic, strong) NSURL * imageURL;
@property (nonatomic, strong) MHFacebookImageViewerOpeningBlock openingBlock;
@property (nonatomic, strong) MHFacebookImageViewerClosingBlock closingBlock;
@property (nonatomic, weak) id <MHFacebookImageViewerDatasource> imageDatasource;
@property (nonatomic, assign) NSInteger initialIndex;

@end