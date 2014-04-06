//
//  ADBDetailTableViewController.h
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADBFeedItemDTO.h"
#import "ADBWebBrowserViewController.h"
#import "ADBImageView.h"

@interface ADBDetailTableViewController : UITableViewController

@property (nonatomic, strong) ADBFeedItemDTO *item;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *summaryString;

@end
