//
//  TKTweetsTableViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 11/4/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TKTweetsTableViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TweetTableViewCell.h"

static NSString * const TwitterKitCellReuseIdentifier = @"TwitterKitCell";
static NSString * const TweetTableViewCellReuseIdentifier = @"TweetCell";

@interface TKTweetsTableViewController () <TWTRTweetViewDelegate>

@property (nonatomic, strong) NSArray *tweetsArray;

@end

@implementation TKTweetsTableViewController

// Reference: https://docs.fabric.io/ios/twitter/show-timelines.html#custom-tableview-of-static-tweets
- (TKTweetsTableViewController *)initWithTweets:(NSArray *)tweets
{
    self = [super init];
    
    if (self) {
        self.tweetsArray = tweets;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup tableview
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TwitterKitCellReuseIdentifier];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweetsArray[indexPath.row];
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TwitterKitCellReuseIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweetsArray[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}

@end
