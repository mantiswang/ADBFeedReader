//
//  FeedInfo+Additions.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import "FeedInfo+Additions.h"
#import "ADBFeedInfoDTO.h"

@implementation FeedInfo (Additions)

- (ADBFeedInfoDTO *)dtoRepresentation
{
    ADBFeedInfoDTO *retVal = [[ADBFeedInfoDTO alloc] init];
    retVal.title = self.title;
    retVal.author = self.author;
    retVal.link = self.link;
    retVal.summary = self.summary;
    return retVal;
}

@end
