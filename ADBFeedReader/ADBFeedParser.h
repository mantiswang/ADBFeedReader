//
//  ADBXMLParser.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ADBFeedParserProtocol.h"

@class FeedInfo;
@class FeedItem;

// Errors & codes
extern NSString *const ADBErrorDomain;

typedef NS_ENUM(NSInteger, ADBErrorCode) {
    ADBErrorCodeConnectionFailed, /* Connection failed */
    ADBErrorCodeFeedParsingError, /* NSXMLParser encountered a parsing error */
    ADBErrorCodeFeedValidationError, /* NSXMLParser encountered a validation error */
    ADBErrorCodeGeneral /* ADBFeedParser general error */
};

@class ADBFeedParser;

@interface ADBFeedParser : NSObject <ADBFeedParserProtocol, NSXMLParserDelegate>

/**
 Designated initializer
 
 @return a ADBFeedReader object
 @param url, the url of the feed
 */
- (id)initWithURL:(NSURL *)url;

@end
