//
//  ADBImageView.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "ADBImageView.h"

static CGFloat kADBImageViewTimoutInterval = 30.0;

@interface ADBImageView (Private)
- (void)_loadImage;
@end

@implementation ADBImageView {
    
    NSURL *_url;
    NSString *_cachePath;
    UIImageView *_placeholder;
    UIActivityIndicatorView *_activityIndicator;
    
    // Networking
    NSURLConnection *_connection;
    NSMutableData *_data;
	
	id <ADBImageViewDelegate> __weak _delegate;
}

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.clipsToBounds = YES;
        self.caching = YES;
        
        [self setUserInteractionEnabled:YES];
        [self setOpaque:YES];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.clipsToBounds = YES;
        self.caching = YES;
        
        [self setUserInteractionEnabled:YES];
        [self setOpaque:YES];
    }
    
    return self;
}

#pragma mark - ADBImageView

- (void)setImageWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage;
{ 
    // Defaults
    _url = imageURL;
    
    self.placeholder = [[UIImageView alloc] initWithImage:placeholderImage];
    self.placeholder.frame = self.bounds;
    [self addSubview:self.placeholder];
    
    [self _loadImage];
}

- (void)reloadWithUrl:(NSURL *)url
{
    [self cancelLoad];
    self.image = nil;
    self.placeholder.hidden = NO;
    _url = url;
    [self _loadImage];
}

- (void)cancelLoad
{
    [_connection cancel];
    _connection = nil;
    self.data = nil;
}

#pragma mark - NSURLConnection Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [[NSMutableData alloc] initWithLength:0];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{
    [self.data appendData:incrementalData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{    
    [_activityIndicator stopAnimating];
    
    if ([_delegate respondsToSelector:@selector(adbImageView:failedLoadingWithError:)]) {
        [_delegate adbImageView:self failedLoadingWithError:error];
    }
    
    [_connection cancel];
    _connection = nil;
    self.data = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
    [_activityIndicator stopAnimating];
    
    UIImage *imageData = [UIImage imageWithData:self.data];
    
    if ([_delegate respondsToSelector:@selector(adbImageView:willUpdateImage:)]) {
        [_delegate adbImageView:self willUpdateImage:imageData];
    }
    
    self.image = imageData;
    self.placeholder.hidden = YES;
    
    [_connection cancel];
    _connection = nil;
	self.data = nil;
	
    if ([_delegate respondsToSelector:@selector(adbImageView:didLoadImage:)]) {
        [_delegate adbImageView:self didLoadImage:imageData];
    }
}

#pragma mark - Private methods

- (void)_loadImage
{
    self.image = nil;
    self.placeholder.hidden = NO;
    
    if ([[_url absoluteString] isEqualToString:@""]) {
        return;
    }
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _activityIndicator.center = center;
    [self addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:kADBImageViewTimoutInterval];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

@end
