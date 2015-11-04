//
//  TKUsersViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 11/2/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TKUsersViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TKFriendsTableViewController.h"
#import "TKTweetsTableViewController.h"

@interface TKUsersViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@end

@implementation TKUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UI Actions
- (IBAction)viewUserAction:(id)sender
{
    [self loadUserWithId:self.userIdTextField.text];
}

- (IBAction)setLoggedUserAction:(id)sender
{
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    self.userIdTextField.text = store.session.userID;
}

- (IBAction)showFriendsAction:(id)sender
{
    [self loadFriendsForUserId:self.userIdTextField.text];
}

- (IBAction)showTweetsAction:(id)sender
{
    [self loadTweetsForUserId:self.userIdTextField.text];
}



// Given a twitter userID loads a TWTRUser and displays its information
// TWTRUser reference: https://dev.twitter.com/twitter-kit/ios-reference/twtruser
- (void)loadUserWithId:(NSString *)userId
{
    __weak TKUsersViewController *wself = self;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    [client loadUserWithID:userId completion:^(TWTRUser *user, NSError *error) {
        NSURL *imageURL = [NSURL URLWithString:user.profileImageURL];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        
        wself.profileImage.image = image;
        wself.fullNameLabel.text = user.name;
        wself.userNameLabel.text = user.screenName;
        wself.identifierLabel.text = user.userID;
    }];
    
}

// This is an example of a manually created request to the API.
// Given a userID we get the list of friends (users he/she follows)
// More on creating requests: https://docs.fabric.io/ios/twitter/access-rest-api.html#constructing-a-twitter-request-manually
// Twitter REST API reference: https://dev.twitter.com/rest/public
- (void)loadFriendsForUserId:(NSString *)userId
{
    if (!userId) {
        UIAlertController *alertNoUserId = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"No user ID"
                                                                        preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alertNoUserId animated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/friends/list.json";
    NSDictionary *params = @{@"id" : userId};
    NSError *clientError;

    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];

    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                NSArray *friends = json[@"users"];
                TKFriendsTableViewController *friendsViewController = [[TKFriendsTableViewController alloc] initWithFriends:friends];
                [self.navigationController pushViewController:friendsViewController animated:YES];

            } else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)loadTweetsForUserId:(NSString *)userId
{
    if (!userId) {
        UIAlertController *alertNoUserId = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"No user ID"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alertNoUserId animated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
    NSDictionary *params = @{@"id" : userId};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSArray *tweetsJSONArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                NSArray *tweets = [TWTRTweet tweetsWithJSONArray:tweetsJSONArray];
                
                TKTweetsTableViewController *tweetsTableVC = [[TKTweetsTableViewController alloc] initWithTweets:tweets];
                
                [self showViewController:tweetsTableVC sender:nil];
                
            } else {
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

@end
