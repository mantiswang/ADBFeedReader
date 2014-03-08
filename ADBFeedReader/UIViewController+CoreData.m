//
//  UIViewController+CoreData.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+CoreData.h"

NSString const *kUIViewControllerManagedObjectContext = @"managedObjectContext";

@implementation UIViewController (CoreData)

@dynamic managedObjectContext;

#pragma mark - Accessors using runtime

- (NSManagedObjectContext *)managedObjectContext
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kUIViewControllerManagedObjectContext));
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    [self willChangeValueForKey:@"managedObjectContext"];
    objc_setAssociatedObject(self, (__bridge const void *)(kUIViewControllerManagedObjectContext), managedObjectContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"managedObjectContext"];
}

@end
