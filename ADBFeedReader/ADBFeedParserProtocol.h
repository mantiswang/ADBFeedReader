//
//  ADBFeedParserProtocol.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBFeedInfoDTO.h"
#import "ADBFeedItemDTO.h"

@protocol ADBFeedParserDelegate;

@protocol ADBFeedParserProtocol <NSObject>

/**
 Makes a new request to the URL feed
 
 @return YES if request for the feed successfully started, NO otherwise
 */
- (BOOL)start;

/**
 Cancels the request and abort parsing
 */
- (void)stop;

@property (nonatomic, weak) id <ADBFeedParserDelegate> delegate;
@property (nonatomic, strong) NSURL *url;

@end

/**
 Delegate
 */
@protocol ADBFeedParserDelegate <NSObject>
@optional
- (void)feedParserDidStart:(id<ADBFeedParserProtocol>)parser;
- (void)feedParser:(id<ADBFeedParserProtocol>)parser didParseFeedInfo:(ADBFeedInfoDTO *)info;
- (void)feedParser:(id<ADBFeedParserProtocol>)parser didParseFeedItem:(ADBFeedItemDTO *)item;
- (void)feedParserDidFinish:(id<ADBFeedParserProtocol>)parser;
- (void)feedParser:(id<ADBFeedParserProtocol>)parser didFailWithError:(NSError *)error;
@end
