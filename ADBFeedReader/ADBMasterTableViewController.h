//
//  ADBMasterTableViewController.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CoreData.h"
#import "ADBFeedParserProtocol.h"
#import "ADBImageView.h"

@interface ADBMasterTableViewController : UITableViewController <ADBFeedParserDelegate>

- (instancetype)initWithFeedParser:(id<ADBFeedParserProtocol>)feedParser;

@end
