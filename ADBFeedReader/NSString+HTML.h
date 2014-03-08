//
//  NSString+HTML.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

/**
 Remove newlines and white space from string.

 @return A new string without white spaces and newlines
 */
- (NSString *)stringByRemovingNewLinesAndWhitespace;

@end