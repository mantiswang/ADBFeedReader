//
//  FeedItem.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "FeedItem.h"

@implementation FeedItem

@dynamic title;
@dynamic summary;
@dynamic link;
@dynamic content;
@dynamic identifier;
@dynamic image_url;
@dynamic update_date;
@dynamic date;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> title: %@", [self class], self, self.title];
}

@end
