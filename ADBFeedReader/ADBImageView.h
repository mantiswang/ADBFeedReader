//
//  ADBImageView.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADBImageView;

@protocol ADBImageViewDelegate <NSObject>
@optional
- (void)adbImageView:(ADBImageView *)view willUpdateImage:(UIImage *)image;
- (void)adbImageView:(ADBImageView *)view didLoadImage:(UIImage *)image;
- (void)adbImageView:(ADBImageView *)view failedLoadingWithError:(NSError *)error;
@end

@interface ADBImageView : UIImageView

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, assign, getter = isCaching) BOOL caching;
@property (nonatomic, assign) NSTimeInterval cacheTime;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) UIImageView *placeholder;
@property (nonatomic, weak) id<ADBImageViewDelegate> delegate;

- (void)setImageWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage;
- (void)cancelLoad;

@end
