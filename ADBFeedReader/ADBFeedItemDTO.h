//
//  ADBFeedItemDTO.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 06/04/2014.
//  Copyright (c) 2014 Adam Burkepile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBFeedItemDTO : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * summary;
@property (nonatomic, copy) NSString * link;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * identifier;
@property (nonatomic, copy) NSString * image_url;
@property (nonatomic, strong) NSDate * update_date;
@property (nonatomic, strong) NSDate * date;

@end
