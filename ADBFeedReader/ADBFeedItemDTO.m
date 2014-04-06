//
//  ADBFeedItemDTO.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import "ADBFeedItemDTO.h"

@implementation ADBFeedItemDTO

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> title: %@", [self class], self, self.title];
}

@end
