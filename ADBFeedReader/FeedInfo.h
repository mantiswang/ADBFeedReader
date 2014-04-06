//
//  FeedInfo.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FeedInfo : NSManagedObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *summary;

@end
