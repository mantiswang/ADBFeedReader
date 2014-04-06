//
//  FeedItem+Additions.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import "FeedItem.h"

@class ADBFeedItemDTO;

@interface FeedItem (Additions)

- (ADBFeedItemDTO *)dtoRepresentation;

@end
