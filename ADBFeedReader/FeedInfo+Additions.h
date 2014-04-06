//
//  FeedInfo+Additions.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import "FeedInfo.h"

@class ADBFeedInfoDTO;

@interface FeedInfo (Additions)

- (ADBFeedInfoDTO *)dtoRepresentation;

@end
