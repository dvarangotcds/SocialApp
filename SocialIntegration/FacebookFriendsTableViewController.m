//
//  FacebookFriendsTableViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 11/5/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "FacebookFriendsTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FriendTableViewCell.h"

@interface FacebookFriendsTableViewController ()

@property (nonatomic, strong) NSMutableArray *facebookFriends;

@end

@implementation FacebookFriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"friendCell"];
    
    self.facebookFriends = [[NSMutableArray alloc] init];
    
    __weak FacebookFriendsTableViewController *wself = self;
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"id,picture,name", @"fields", nil];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends/"
                                                                   parameters:param
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        NSLog(@"Result: %@\nError: %@", result, error);

        for (NSDictionary *friendDictionary in result[@"data"]) {
            
            if ([friendDictionary objectForKey:@"id"]) {
                [wself.facebookFriends addObject:@{
                                                @"id":friendDictionary[@"id"],
                                                @"name":friendDictionary[@"name"],
                                                @"picture":friendDictionary[@"picture"][@"data"][@"url"] ? friendDictionary[@"picture"][@"data"][@"url"] : @""
                                                }];
            }
        }
        
        [wself.tableView reloadData];
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.facebookFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    
    NSDictionary *currentFriend = self.facebookFriends[indexPath.row];

    cell.name.text = currentFriend[@"name"];
    cell.socialIdentifier.text = currentFriend[@"id"];
    [cell setImageWithURL:[NSURL URLWithString:currentFriend[@"picture"]]];

    return cell;
}

@end
