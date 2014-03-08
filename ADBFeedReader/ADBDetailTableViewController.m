//
//  ADBDetailTableViewController.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBDetailTableViewController.h"
#import "NSString+HTML.h"

typedef NS_ENUM(NSInteger, Sections) {
    SectionHeader = 0,
    SectionDetail = 1
};

typedef NS_ENUM(NSInteger, HeaderRows) {
    SectionHeaderTitle = 0,
    SectionHeaderDate  = 1,
    SectionHeaderURL   = 2,
    SectionHeaderImage = 3
};

typedef NS_ENUM(NSInteger, DetailRows) {
    SectionDetailSummary = 0,
    SectionDetailImage   = 1
};

@interface ADBDetailTableViewController ()
<UIActionSheetDelegate,
ADBWebBrowserViewControllerDelegate,
ADBImageViewDelegate>

@end

@implementation ADBDetailTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Date
	if (self.item.date) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterMediumStyle];
		self.dateString = [formatter stringFromDate:self.item.date];
	}
	
	// Summary
	if (self.item.summary) {
		self.summaryString = self.item.summary;
	} else {
		self.summaryString = @"";
	}
    
    self.title = self.item.title;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(openURLPressed:)];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
            return 3;
        case 1:
            return self.item.image_url ? 2 : 1;
		default:
            return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get cell
	static NSString *CellIdentifier = @"CellA";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	// Display
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.font = [UIFont systemFontOfSize:15];
	if (self.item) {
		// Item Info
		NSString *itemTitle = self.item.title ? self.item.title : @"";
		
		// Display
		switch (indexPath.section) {
			case SectionHeader: {
				// Header
				switch (indexPath.row) {
					case SectionHeaderTitle:
						cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
						cell.textLabel.text = itemTitle;
						break;
					case SectionHeaderDate:
						cell.textLabel.text = self.dateString ? self.dateString : @"";
						break;
					case SectionHeaderURL:
						cell.textLabel.text = self.item.link ? self.item.link : @"";
						cell.textLabel.textColor = [UIColor blueColor];
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                        break;
				}
				break;
			}
			case SectionDetail: {
                switch (indexPath.row) {
					case SectionDetailSummary:
                        cell.textLabel.text = self.summaryString;
                        cell.textLabel.numberOfLines = 0;
                        break;
                    case SectionDetailImage: {
                        ADBImageView *imageView = [[ADBImageView alloc] initWithFrame:CGRectMake(10, 10, 280, 180)];
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageView.delegate = self;
                        imageView.caching = NO;
                        
                        // placeholder
                        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"];
                        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                        
                        // item media URL
                        NSURL *imageURL = [NSURL URLWithString:self.item.image_url];
                        [imageView setImageWithURL:imageURL placeholderImage:image];
                        
                        [cell.contentView addSubview:imageView];
                    }
                }
            }
            default:
                break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == SectionHeader) {
		// Regular
		return 34;
		
	} else {
        if (indexPath.row == SectionDetailSummary) {
            // Get height of summary
            CGSize size = [self.summaryString sizeWithFont:[UIFont systemFontOfSize:15]
                                     constrainedToSize:CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 16; // Add padding
        } else {
            return 200.0f;
        }
    }
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.item.link.length) {
        return;
    }
    
	// Link
	if (indexPath.section == SectionHeader && indexPath.row == SectionHeaderURL) {
		[self _openActionSheet];
    }
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self _openInSafari];
            break;
        case 1: {
            NSURL *url = [NSURL URLWithString:self.item.link];
            ADBWebBrowserViewController *webBrowserController = [[ADBWebBrowserViewController alloc] initWithURL:url delegate:self];
            [self presentViewController:webBrowserController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - ADBImageViewDelegate

- (void)adbImageView:(ADBImageView *)view willUpdateImage:(UIImage *)image
{
    view.alpha = 0.0;
    [UIView animateWithDuration:0.7 animations:^{ view.alpha = 1.0; }];
}

- (void)adbImageView:(ADBImageView *)view failedLoadingWithError:(NSError *)error
{
    NSLog(@"Image failed loading: %@", [error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Error Loading Image URL"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

#pragma mark - Actions

- (void)openURLPressed:(id)sender
{
    [self _openInSafari];
}

#pragma mark - Private

- (void)_openActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Open URL", nil)
                                                             delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Open in-app", nil];
    [actionSheet showInView:self.view];
}

- (void)_openInSafari
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.item.link]];
}

@end
