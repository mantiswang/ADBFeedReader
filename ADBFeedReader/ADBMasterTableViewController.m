//
//  ADBMasterTableViewController.m
//  ADBFeedReader
//
//  Created by Alberto De Bortoli on 20/05/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ADBMasterTableViewController.h"
#import "ADBDetailTableViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import "FeedInfo+Additions.h"
#import "FeedItem+Additions.h"
#import "ADBFeedParser.h"
#import "ADBFeedInfoDTO.h"
#import "ADBFeedItemDTO.h"
#import "ADBConstants.h"

@interface ADBMasterTableViewController () <
UISearchDisplayDelegate,
ADBImageViewDelegate>

@property (nonatomic, strong) NSArray *itemsToDisplay;
@property (nonatomic, strong) NSMutableArray *parsedItems;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) id<ADBFeedParserProtocol> feedParser;

@end

@implementation ADBMasterTableViewController

- (instancetype)initWithFeedParser:(id<ADBFeedParserProtocol>)feedParser
{
    NSAssert(feedParser != nil, @"feedParser parameter must not be nil");
    
    self = [super init];
    if (self) {
        _feedParser = feedParser;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.navigationController) {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    // setup
    self.title = NSLocalizedString(@"Loading...", nil);
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateStyle:NSDateFormatterShortStyle];
    [self.formatter setTimeStyle:NSDateFormatterShortStyle];
    self.parsedItems = [[NSMutableArray alloc] init];
    self.itemsToDisplay = [NSArray array];
    
    // refresh button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshButtonPressed:)];
    
    // Check for Internet connectivity
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    // No Internet connection
    if (reach.currentReachabilityStatus == NotReachable) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        if ([fetchedObjects count]) {
            NSMutableArray *dtoObjects = [NSMutableArray arrayWithCapacity:[fetchedObjects count]];
            for (FeedItem *feedItem in fetchedObjects) {
                ADBFeedItemDTO *feedItemDTO = [feedItem dtoRepresentation];
                [dtoObjects addObject:feedItemDTO];
            }
            self.itemsToDisplay = dtoObjects;
            [self.tableView reloadData];
        }
    }
    
    // Internet connection available
    else {
        [self _refreshFeed];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ADBFeedParserDelegate

- (void)feedParserDidStart:(ADBFeedParser *)parser
{
    NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(ADBFeedParser *)parser didParseFeedInfo:(ADBFeedInfoDTO *)info
{
    NSLog(@"Parsed Feed Info: “%@”", info.title);
    self.title = info.title;
    [self _persistedInfoObject:info];
}

- (void)feedParser:(ADBFeedParser *)parser didParseFeedItem:(ADBFeedItemDTO *)item
{
    NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (item) {
        [self.parsedItems addObject:item];
    }
    [self _persistedItemObject:item];
}

- (void)feedParserDidFinish:(ADBFeedParser *)parser
{
    NSLog(@"Finished Parsing");
    [self _updateTableWithParsedItems];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Can't save: %@", [error localizedDescription]);
    }
}

- (void)feedParser:(ADBFeedParser *)parser didFailWithError:(NSError *)error
{
    NSLog(@"Finished Parsing With Error: %@", error);
    
    if (self.parsedItems.count == 0) {
        self.title = NSLocalizedString(@"Failed", nil); // Show failed message in title
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Parsing Incomplete", nil)
                                                        message:NSLocalizedString(@"There was an error during the parsing of this feed. Not all of the feed items could parsed.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self _updateTableWithParsedItems];
}

#pragma mark - Core Data

- (BOOL)_persistedInfoObject:(ADBFeedInfoDTO *)feedInfo
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", feedInfo.title];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    FeedInfo *info = nil;
    
    // already existing on database
    if ([fetchedObjects count]) {
        info = [fetchedObjects lastObject];
    }
    
    // not existing on database
    else {
        info = [NSEntityDescription insertNewObjectForEntityForName:@"FeedInfo" inManagedObjectContext:self.managedObjectContext];
    }
    
    info.title = feedInfo.title;
    info.author = feedInfo.author;
    info.link = feedInfo.link;
    info.summary = feedInfo.summary;
    
    return [self.managedObjectContext save:nil];
}

- (BOOL)_persistedItemObject:(ADBFeedItemDTO *)feedItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", feedItem.title];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    FeedItem *item = nil;
    
    // already existing on database
    if ([fetchedObjects count]) {
        item = [fetchedObjects lastObject];
    }
    
    // not existing on database
    else {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem" inManagedObjectContext:self.managedObjectContext];
    }
    
    item.title = feedItem.title;
    item.summary = feedItem.summary;
    item.link = feedItem.link;
    item.content = feedItem.content;
    item.identifier = feedItem.identifier;
    item.image_url = feedItem.image_url;
    item.update_date = feedItem.update_date;
    item.date = feedItem.date;
    
    return [self.managedObjectContext save:nil];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        // Return the number of rows in the section.
        return [self.itemsToDisplay count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        for (UIView *view in cell.imageView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    FeedItem *item = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        item = [self.itemsToDisplay objectAtIndex:indexPath.row];
    }
    
    if (item) {
        // Process
        NSString *itemTitle = item.title ? item.title : NSLocalizedString(@"[No Title]", nil);
        NSString *itemSummary = item.summary ? item.summary : NSLocalizedString(@"[No Summary]", nil);
        
        // Set
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.text = itemTitle;
        NSMutableString *subtitle = [NSMutableString string];
        if (item.date) [subtitle appendFormat:@"%@: ", [self.formatter stringFromDate:item.date]];
        [subtitle appendString:itemSummary];
        cell.detailTextLabel.text = subtitle;
        
        // Load image
        ADBImageView *imageView = [[ADBImageView alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.delegate = self;
        imageView.caching = NO;
        
        // placeholder
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        // item media URL
        NSURL *imageURL = [NSURL URLWithString:item.image_url];
        [imageView setImageWithURL:imageURL placeholderImage:image];
        
        cell.imageView.image = image;
        [cell.imageView addSubview:imageView];
    }
    
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ADBDetailTableViewController *detail = [[ADBDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detail.item = (ADBFeedItemDTO *)[self.itemsToDisplay objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
    
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ADBImageViewDelegate

- (void)adbImageView:(ADBImageView *)view willUpdateImage:(UIImage *)image
{
    view.alpha = 0.0;
    [UIView animateWithDuration:0.7 animations:^{ view.alpha = 1.0; }];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self _filterContentForSearchText:searchString
                                scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                       objectAtIndex:[self.searchDisplayController.searchBar
                                                      selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailItem"]) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:nil
                                                                      action:nil];
        [[self navigationItem] setBackBarButtonItem:backButton];
        ADBDetailTableViewController *detailViewController = segue.destinationViewController;
        detailViewController.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = nil;
        ADBFeedItemDTO *feedItem = nil;
        
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            feedItem = [self.searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            feedItem = [self.itemsToDisplay objectAtIndex:indexPath.row];
        }
        
        detailViewController.item = feedItem;
    }
}

#pragma mark - Actions

- (void)refreshButtonPressed:(id)sender
{
    [self _refreshFeed];
}

#pragma mark - Private

- (void)_refreshFeed
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    // No Internet connection
    if (reach.currentReachabilityStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet", nil)
                                                            message:NSLocalizedString(@"Whoops, missing internet connection!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ah, I see... x_x", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    // Internet connection available
    else {
        self.title = NSLocalizedString(@"Refreshing...", nil);
        [self.parsedItems removeAllObjects];
        [self.feedParser stop];
        [self.feedParser start];
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)_filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@", searchText];
    
    self.searchResults = [self.itemsToDisplay filteredArrayUsingPredicate:resultPredicate];
}

- (void)_updateTableWithParsedItems
{
    self.itemsToDisplay = [self.parsedItems sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
    [self.tableView reloadData];
}

@end
