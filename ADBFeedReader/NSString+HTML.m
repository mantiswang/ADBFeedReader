//
//  NSString+HTML.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "NSString+HTML.h"

@implementation NSString (HTML)

#pragma mark - Instance Methods

- (NSString *)stringByRemovingNewLinesAndWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
