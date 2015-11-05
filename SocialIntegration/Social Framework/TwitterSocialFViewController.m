//
//  SocialViewController.m
//  SocialIntegration
//
//  Created by Diego Varangot on 10/27/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TwitterSocialFViewController.h"
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountType.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLRequest.h>
#import "FriendTableViewCell.h"
#import "TweetsTableViewController.h"

@interface TwitterSocialFViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ACAccount *selectedAccount;
@property (weak, nonatomic) IBOutlet UILabel *twAccountFullName;
@property (weak, nonatomic) IBOutlet UILabel *twAccountUsername;
@property (weak, nonatomic) IBOutlet UILabel *twAccountIdentifier;
@property (nonatomic, strong) NSMutableArray *twFriends;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;

@end

@implementation TwitterSocialFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.twFriends = [[NSMutableArray alloc] init];
    [self.friendsTableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell"
                                                      bundle:nil]
                forCellReuseIdentifier:@"friendCell"];
}

- (void)setSelectedAccount:(ACAccount *)selectedAccount
{
    _selectedAccount = selectedAccount;
    self.twAccountFullName.text = selectedAccount.userFullName;
    self.twAccountUsername.text = selectedAccount.username;
    self.twAccountIdentifier.text = selectedAccount.identifier;
}

#pragma mark - IBAction methods

- (IBAction)showAccounts:(id)sender
{
    __weak TwitterSocialFViewController *wself = self;
    
    [self requestTwitterPermissionsWithCompletionBlock:^(bool permissionGranted, NSError *error) {
        UIAlertController *accountsActionSheet = [UIAlertController alertControllerWithTitle:@"Device TW accounts"
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
        for (ACAccount *account in [wself twitterAccounts]) {
            UIAlertAction *accountAction = [UIAlertAction actionWithTitle:account.username
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      wself.selectedAccount = account;
                                                                      [wself.twFriends removeAllObjects];
                                                                  }];
            [accountsActionSheet addAction:accountAction];
        }
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           [accountsActionSheet dismissViewControllerAnimated:YES
                                                                                                   completion:nil];
                                                       }];
        
        [accountsActionSheet addAction:cancel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself presentViewController:accountsActionSheet animated:YES completion:nil];
        });
        
    }];
}
- (IBAction)showFriends:(id)sender
{
    __weak TwitterSocialFViewController *wself = self;
    
    [self loadTwitterFriendsWithCompletionBlock:^(bool friendsLoaded, NSError *error) {
        if (friendsLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.friendsTableView reloadData];
            });
        }
    }];
}

- (IBAction)composeTweet:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [vc setInitialText:@"Some default text"];
        
        [self presentViewController:vc animated:YES completion:nil];
        
    } 
}

- (IBAction)showTweetsAction:(id)sender
{
    ACAccount *twitterAccount = self.selectedAccount;
    
    if (twitterAccount) {
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
        NSDictionary *param = @{@"id" : @""};
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodGET
                                                          URL:requestURL
                                                   parameters:param];

        [request setAccount:twitterAccount];
        
        __weak TwitterSocialFViewController *wself = self;
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSLog(@"Twitter HTTP response: %li", (long)[urlResponse statusCode]);
             
             if ([urlResponse statusCode] == 200) {
                 if (responseData) {
                     // handle the response data e.g.
                     NSError *jsonError;
                     NSArray *tweetsJSONArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                     TweetsTableViewController *tweetsTableVC = [[TweetsTableViewController alloc] initWithTweets:tweetsJSONArray];
                     
                     dispatch_sync(dispatch_get_main_queue(), ^(void){
                         [wself showViewController:tweetsTableVC sender:nil];
                     });
                     
                 } else {
                     NSLog(@"Error: %@", error);
                 }

             }
         }];
    }
   
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.twFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    NSDictionary *friend = (NSDictionary *)[self.twFriends objectAtIndex:indexPath.row];
    [cell setImageWithURL:[NSURL URLWithString:friend[@"picture"]]];
    cell.name.text = friend[@"name"];
    cell.socialIdentifier.text = [friend[@"id"] stringValue];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

#pragma  mark - Twitter methods

- (NSArray *)twitterAccounts
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeTwitter = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    return [account accountsWithAccountType:accountTypeTwitter];
}

- (void)requestTwitterPermissionsWithCompletionBlock:(void(^)(bool permissionGranted, NSError *error))completionBlock
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeTwitter = [account accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountTypeTwitter
                                     options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         completionBlock(granted, error);
     }];
}

- (BOOL)anyTwitterAccountLogged
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)loadTwitterFriendsWithCompletionBlock:(void(^)(bool friendsLoaded, NSError *error))completionBlock
{
    ACAccount *twitterAccount = self.selectedAccount;
    
    if (twitterAccount) {
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
        
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"cursor", @"0", @"screen_name", twitterAccount.username, @"count", @"500", nil];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodGET
                                                          URL:requestURL
                                                   parameters:param];
        [request setAccount:twitterAccount];
        
        __weak TwitterSocialFViewController *wself = self;
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSLog(@"Twitter HTTP response: %li", (long)[urlResponse statusCode]);
             
             if ([urlResponse statusCode] == 200) {
                 NSError *errorJson = nil;
                 NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorJson];
                 
                 NSMutableArray *twFriendsArray = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary *friendDictionary in responseDict[@"users"]) {
                     
                     if ([friendDictionary objectForKey:@"id"]) {
                         [twFriendsArray addObject:@{
                                                     @"id":friendDictionary[@"id"],
                                                     @"name":friendDictionary[@"name"],
                                                     @"picture":friendDictionary[@"profile_image_url"]
                                                     }];
                     }
                     
                 }
                 
                 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                                ascending:YES];
                 [twFriendsArray sortUsingDescriptors:@[sortDescriptor]];
                 
                 [wself.twFriends addObjectsFromArray:twFriendsArray];
                 
                 completionBlock(YES, nil);
             } else {
                 completionBlock(NO, error);
             }
         }];
    } else {
        completionBlock(NO, [NSError errorWithDomain:@"Twitter Domain"
                                                code:400
                                            userInfo:nil]);
    }
}

@end
