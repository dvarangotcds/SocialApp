//
//  TweetsTableViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 11/5/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TweetsTableViewController.h"
#import "TweetTableViewCell.h"

@interface TweetsTableViewController ()

@property (nonatomic, strong) NSArray *tweets;

@end

@implementation TweetsTableViewController

- (TweetsTableViewController *)initWithTweets:(NSArray *)tweets
{
    self = [super init];
    
    if (self) {
        self.tweets = tweets;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"TweetTableViewCell"
                                                      bundle:nil]
         forCellReuseIdentifier:@"tweetCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    NSDictionary *tweet = self.tweets[indexPath.row];
    cell.tweetLabel.text = tweet[@"text"];
    
    return cell;
}

@end
