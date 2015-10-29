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

@interface FacebookSocialViewController ()

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
    // Do any additional setup after loading the view.
    
}

#pragma mark - IBAction methods

- (IBAction)showAccounts:(id)sender
{
    __weak FacebookSocialViewController *wself = self;
    
    [self requestFacebookPermissionsWithCompletionBlock:^(bool permissionGranted, NSError *error) {
        UIAlertController *accountsActionSheet = [UIAlertController alertControllerWithTitle:@"Device FB accounts"
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
        for (ACAccount *account in [wself fbFriends]) {
            UIAlertAction *accountAction = [UIAlertAction actionWithTitle:account.username
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      wself.selectedAccount = account;
                                                                      [wself.fbFriends removeAllObjects];
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
    __weak FacebookSocialViewController *wself = self;
    
    [self loadFacebookFriendsWithCompletionBlock:^(bool friendsLoaded, NSError *error) {
        if (friendsLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.friendsTableView reloadData];
            });
        }
    }];
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
    cell.socialIdentifier.text = [friend[@"id"] stringValue];
    
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
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:@"778491468881760", (NSString *)ACFacebookAppIdKey, [NSArray arrayWithObjects:@"email",nil], (NSString *)ACFacebookPermissionsKey, ACFacebookAudienceEveryone, (NSString *)ACFacebookAudienceKey, nil];
    
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
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:@"778491468881760", (NSString *)ACFacebookAppIdKey, [NSArray arrayWithObjects:@"publish_actions",nil], (NSString *)ACFacebookPermissionsKey, ACFacebookAudienceEveryone, (NSString *)ACFacebookAudienceKey, nil];
    
    [accountStore requestAccessToAccountsWithType:accountTypeFacebook
                                          options:options
                                       completion:^(BOOL granted, NSError *error)
     {
         completionBlock(granted, error);
     }];
}

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
