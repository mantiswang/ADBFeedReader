//
//  ADBFeedInfoDTO.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBFeedInfoDTO : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * author;
@property (nonatomic, copy) NSString * link;
@property (nonatomic, copy) NSString * summary;

@end
