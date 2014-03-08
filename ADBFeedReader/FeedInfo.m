//
//  FeedInfo.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "FeedInfo.h"

@implementation FeedInfo

@dynamic title;
@dynamic author;
@dynamic link;
@dynamic summary;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> title: %@", [self class], self, self.title];
}

@end
