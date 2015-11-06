//
//  FacebookSocialViewController.m
//  SocialIntegration
//
//  Created by Diego Varangot on 10/28/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "FacebookSocialViewController.h"
#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <Social/SLRequest.h>
#import "FriendTableViewCell.h"

@interface FacebookSocialViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ACAccount *selectedAccount;
@property (weak, nonatomic) IBOutlet UILabel *fbAccountFullName;
@property (weak, nonatomic) IBOutlet UILabel *fbAccountUsername;
@property (weak, nonatomic) IBOutlet UILabel *fbAccountIdentifier;
@property (nonatomic, strong) NSMutableArray *fbFriends;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;

@end

@implementation FacebookSocialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fbFriends = [[NSMutableArray alloc] init];
    [self.friendsTableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell"
                                                      bundle:nil]
                forCellReuseIdentifier:@"friendCell"];
    
}

- (void)setSelectedAccount:(ACAccount *)selectedAccount
{
    _selectedAccount = selectedAccount;
    self.fbAccountFullName.text = selectedAccount.userFullName;
    self.fbAccountUsername.text = selectedAccount.username;
    self.fbAccountIdentifier.text = selectedAccount.identifier;
}

#pragma mark - IBAction methods

- (IBAction)showAccounts:(id)sender
{
    __weak FacebookSocialViewController *wself = self;
    
    [self requestFacebookPermissionsWithCompletionBlock:^(bool permissionGranted, NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           wself.selectedAccount = [wself facebookLoggedAccount];
           [wself.fbFriends removeAllObjects];
       });
        
    }];
}
- (IBAction)showFriends:(id)sender
{
    __weak FacebookSocialViewController *wself = self;
    
    [self loadFacebookFriendsWithCompletionBlock:^(bool friendsLoaded, NSError *error) {
        if (friendsLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.friendsTableView reloadData];
            });
        }
    }];
}

- (IBAction)postToFacebook:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [vc setInitialText:@"Some default text"];
        
        [self presentViewController:vc animated:YES completion:nil];
        
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fbFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    NSDictionary *friend = (NSDictionary *)[self.fbFriends objectAtIndex:indexPath.row];
    [cell setImageWithURL:[NSURL URLWithString:friend[@"picture"]]];
    cell.name.text = friend[@"name"];
    cell.socialIdentifier.text = friend[@"id"];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

#pragma mark - Facebook methods
- (BOOL)anyFacebookAccountLogged
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

- (ACAccount *)facebookLoggedAccount
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeFacebook = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    return [account accountsWithAccountType:accountTypeFacebook].lastObject;
}

- (void)requestFacebookPermissionsWithCompletionBlock:(void(^)(bool permissionGranted, NSError *error))completionBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:
                                          ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"], (NSString *)ACFacebookAppIdKey, [NSArray arrayWithObjects:@"email", @"user_friends", nil], (NSString *)ACFacebookPermissionsKey, ACFacebookAudienceEveryone, (NSString *)ACFacebookAudienceKey, nil];
    
    [accountStore requestAccessToAccountsWithType:accountTypeFacebook
                                          options:options
                                       completion:^(BOOL granted, NSError *error)
     {
         completionBlock(granted, error);
     }];
}

- (void)requestFacebookPublishPermissionsWithCompletionBlock:(void(^)(bool permissionGranted, NSError *error))completionBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:
                                          ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"], (NSString *)ACFacebookAppIdKey, [NSArray arrayWithObjects:@"publish_actions",nil], (NSString *)ACFacebookPermissionsKey, ACFacebookAudienceEveryone, (NSString *)ACFacebookAudienceKey, nil];
    
    [accountStore requestAccessToAccountsWithType:accountTypeFacebook
                                          options:options
                                       completion:^(BOOL granted, NSError *error)
     {
         completionBlock(granted, error);
     }];
}

// - A user access token with user_friends permission is required to view the current person's friends.
// - This will only return any friends who have used (via Facebook Login) the app making the request.
// - If a friend of the person declines the user_friends permission, that friend will not show up in the friend list for this person.
- (void)loadFacebookFriendsWithCompletionBlock:(void(^)(bool friendsLoaded, NSError *error))completionBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:
                                          ACAccountTypeIdentifierFacebook];
    
    ACAccount *facebookLoggedAccounts = [accountStore accountsWithAccountType:accountTypeFacebook].lastObject;
    
    
    NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"id,picture,name", @"fields", nil];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:requestURL
                                               parameters:param];
    [request setAccount:facebookLoggedAccounts];
    [self.fbFriends removeAllObjects];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         NSLog(@"Facebook HTTP response: %li",
               (long)[urlResponse statusCode]);
         
         if ([urlResponse statusCode] == 200) {
             NSError *errorJson = nil;
             NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorJson];
             
             NSMutableArray *fbFriendsInfoArray = [[NSMutableArray alloc] init];
             
             for (NSDictionary *friendDictionary in responseDict[@"data"]) {
                 
                 if ([friendDictionary objectForKey:@"id"]) {
                     [fbFriendsInfoArray addObject:@{
                                                     @"id":friendDictionary[@"id"],
                                                     @"name":friendDictionary[@"name"],
                                                     @"picture":friendDictionary[@"picture"][@"data"][@"url"]
                                                     }];
                 }
             }
             
             
             //We sort them by name (A-Z order)
             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                            ascending:YES];
             [fbFriendsInfoArray sortUsingDescriptors:@[sortDescriptor]];
             
             [self.fbFriends addObjectsFromArray:fbFriendsInfoArray];
             completionBlock(YES, nil);
         } else {
             
             completionBlock(NO, [NSError errorWithDomain:@"Facebook Domain"
                                                     code:400
                                                 userInfo:nil]);
         }
     }];
}

@end
