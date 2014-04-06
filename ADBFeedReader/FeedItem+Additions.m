//
//  FeedItem+Additions.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import "FeedItem+Additions.h"
#import "ADBFeedItemDTO.h"

@implementation FeedItem (Additions)

- (ADBFeedItemDTO *)dtoRepresentation
{
    ADBFeedItemDTO *retVal = [[ADBFeedItemDTO alloc] init];
    retVal.title = self.title;
    retVal.summary = self.summary;
    retVal.link = self.link;
    retVal.content = self.content;
    retVal.identifier = self.identifier;
    retVal.image_url = self.image_url;
    retVal.update_date = self.update_date;
    retVal.date = self.date;
    return retVal;
}

@end
