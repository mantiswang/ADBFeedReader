//
//  FeedItem.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FeedItem : NSManagedObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * summary;
@property (nonatomic, copy) NSString * link;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * identifier;
@property (nonatomic, copy) NSString * image_url;
@property (nonatomic, strong) NSDate * update_date;
@property (nonatomic, strong) NSDate * date;

@end
