//
//  UIViewController+CoreData.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CoreData)

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
