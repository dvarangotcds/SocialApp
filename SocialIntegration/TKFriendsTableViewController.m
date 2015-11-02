//
//  TKFriendsTableViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 10/29/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TKFriendsTableViewController.h"
#import "FriendTableViewCell.h"

@interface TKFriendsTableViewController ()

@property (nonatomic, strong) NSMutableArray *twFriends;

@end

@implementation TKFriendsTableViewController

- (TKFriendsTableViewController *)initWithFriends:(NSArray *)friends
{
    self = [super init];
    
    if (self) {
        self.twFriends = [[NSMutableArray alloc] initWithArray:friends];
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell"
                                                      bundle:nil]
         forCellReuseIdentifier:@"friendCell"];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.twFriends.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    NSDictionary *friend = (NSDictionary *)[self.twFriends objectAtIndex:indexPath.row];
    [cell setImageWithURL:[NSURL URLWithString:friend[@"profile_image_url"]]];
    cell.name.text = friend[@"name"];
    cell.socialIdentifier.text = [friend[@"id"] stringValue];

    return cell;
}

@end
