//
//  TwitterKitViewController.m
//  TwitterKitTest
//
//  Created by Santiago Rama on 10/27/15.
//  Copyright © 2015 Santiago. All rights reserved.
//

#import "TwitterKitViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TwitterKitFriendsTableViewController.h"

@interface TwitterKitViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UIButton *viewAccountsButton;
@property (weak, nonatomic) IBOutlet UIButton *getEmailButton;

@property (weak, nonatomic) IBOutlet UIButton *loadTweetButton;
@property (weak, nonatomic) IBOutlet UITextField *tweetIdTextField;
@property (strong, nonatomic) TWTRTweetView *tweetView;

@property (weak, nonatomic) IBOutlet UIButton *loadUserButton;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;

@property (weak, nonatomic) IBOutlet UIButton *composeTweetButton;

@property (weak, nonatomic) IBOutlet UILabel *twAccountFullName;
@property (weak, nonatomic) IBOutlet UILabel *twAccountUsername;
@property (weak, nonatomic) IBOutlet UILabel *twAccountIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *twAccountLogged;

@end

@implementation TwitterKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //We initialize the TweetView so later we can set specific tweets on it later.
    [self setupTweetView];
    
    TWTRSession *session = [Twitter sharedInstance].sessionStore.session;
    self.twAccountLogged.text = session.userName;

}

# pragma mark - UI setup

- (void)setupTweetView
{
    self.tweetView = [[TWTRTweetView alloc] initWithTweet:nil style:TWTRTweetViewStyleCompact];
    // Just setting this view at the bottom, using all the screen's width
    self.tweetView.frame = CGRectMake(0,
                                      self.view.frame.size.height - self.tweetView.frame.size.height,
                                      self.view.frame.size.width,
                                      self.tweetView.frame.size.height);
    self.tweetView.showActionButtons = YES;
    self.tweetView.theme = TWTRTweetViewThemeLight;
    
    [self.view addSubview:self.tweetView];
}

#pragma mark - UI Actions

/*
 * Reference: https://docs.fabric.io/ios/twitter/authentication.html#log-in-button
 */
- (IBAction)loginTwitterAction:(id)sender
{
    __weak TwitterKitViewController *wself = self;
    
    /* This method will use the accounts stored on device to login.
     * If there are no accounts, a view controller will be presented for the user to login or register.
     * After the user successfully logs in, he/she will also be logged in the device
     */
     [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            
            wself.twAccountLogged.text = session.userName;
            
            TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
            [client loadUserWithID:session.userID completion:^(TWTRUser *user, NSError *error) {
                wself.twAccountFullName.text = user.name;
                wself.twAccountUsername.text = user.screenName;
                wself.twAccountIdentifier.text = user.userID;
            }];
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    //You can also use a default Twitter login button
    TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    //Set frame and add
    logInButton.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:logInButton];
}

/*
 As we can have multiple sessions, when we logout we need to specify the userID
 */
- (IBAction)logoutAction:(id)sender
{
    __weak TwitterKitViewController *wself = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Twitter accounts logged in"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    
    NSArray *sessions = [store existingUserSessions];
    
    for (TWTRSession *session in sessions) {
        UIAlertAction *sessionAction = [UIAlertAction actionWithTitle:session.userName
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [store logOutUserID:session.userID];
                                                                 
                                                                  wself.twAccountLogged.text = [Twitter sharedInstance].session.userName;
                                                              }];
        [alertController addAction:sessionAction];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 * Reference: https://docs.fabric.io/ios/twitter/authentication.html#managing-sessions
 */
- (IBAction)viewAccountsAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Twitter accounts logged in"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    
    NSArray *sessions = [store existingUserSessions];
    NSLog(@"Sessions array: %@", sessions);
    
    for (TWTRSession *session in sessions) {
        UIAlertAction *sessionAction = [UIAlertAction actionWithTitle:session.userName
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }];
        [alertController addAction:sessionAction];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    // Property for current session
    TWTRSession *lastSession = store.session;
    NSLog(@"Last session: %@", lastSession.userName);
    
    //Property for specific session
    TWTRSession *specificSession = [store sessionForUserID:@"123"];
    NSLog(@"specific session: %@", specificSession.userName);
}


/*
 Possible errors obtaining the email:
 - Access denied by user (TWTRErrorDomain, TWTRErrorCodeUserDeclinedPermission)
 - User didn't log in (TWTRErrorDomain, TWTRErrorCodeNoAuthentication)
 - User registered using phone number, so his email field is empty.
 - Application is not in the Twitter whitelist, or you are using old tokens. (TWTRAPIErrorDomain, TWTRAPIErrorCodeNotAuthorizedForEndpoint)
 
 This example will fail because this app is not whitelisted
 */
- (IBAction)getEmailAction:(id)sender
{
    if ([[[Twitter sharedInstance] sessionStore] session]) {
        TWTRShareEmailViewController* shareEmailViewController = [[TWTRShareEmailViewController alloc] initWithCompletion:^(NSString* email, NSError* error) {
            NSLog(@"Email %@, Error: %@", email, error);
            
        }];
        //shareEmailViewController needs to be presented, not pushed.
        [self presentViewController:shareEmailViewController animated:YES completion:nil];
        //It dismisses on user's action so no need to call dismissViewController:animated anywhere
    }
}


/*
 Given a tweetID loads a TWTRTweet and displays it in a previously created TWTRTweetView
 TWTRUser reference: https://dev.twitter.com/twitter-kit/ios-reference/twtruser
 TWTRTweetView reference: https://dev.twitter.com/twitter-kit/ios-reference/twtrtweetview
 */
- (IBAction)loadTweetAction:(id)sender
{
    __weak TwitterKitViewController *wself = self;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    [client loadTweetWithID:self.tweetIdTextField.text completion:^(TWTRTweet *tweet, NSError *error) {
        NSLog(@"Tweet %@, Error: %@", tweet, error);
        if (tweet) {
            [wself.tweetView configureWithTweet:tweet];            
        } else {
            NSLog(@"Failed to load tweet: %@", [error localizedDescription]);
        }
    }];
    
    //If you need to load more than one tweet you can pass an array and use loadTweetsWithIDs:completion:
    NSArray *tweetIDs = @[@"20", @"510908133917487104"];
    [client loadTweetsWithIDs:tweetIDs completion:^(NSArray *tweets, NSError *error) {
        NSLog(@"Tweets %@, Error: %@", tweets, error);
    }];
}

/*
 Given a twitter userID loads a TWTRUser
 TWTRUser reference: https://dev.twitter.com/twitter-kit/ios-reference/twtruser
 */
- (IBAction)loadUserAction:(id)sender
{
    __weak TwitterKitViewController *wself = self;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    [client loadUserWithID:self.userIdTextField.text completion:^(TWTRUser *user, NSError *error) {
        wself.twAccountFullName.text = user.name;
        wself.twAccountUsername.text = user.screenName;
        wself.twAccountIdentifier.text = user.userID;
    }];

}

/*
 Reference: https://docs.fabric.io/ios/twitter/compose-tweets.html
 */
- (IBAction)composeTweetAction:(id)sender
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:@"Some default text"];
    [composer setImage:[UIImage imageNamed:@"fabric"]];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
    
    //You can also create your App Card. The App Id you provide must be valid in order to render the App Card
    
    /*
     UIImage *image = [UIImage imageNamed:@"fabric"];
     TWTRCardConfiguration *card = [TWTRCardConfiguration appCardConfigurationWithPromoImage:image iPhoneAppID:@"12345" iPadAppID:nil googlePlayAppID:nil];
     TWTRComposerViewController *composerWithCard = [[TWTRComposerViewController alloc] initWithUserID:[[[Twitter sharedInstance] sessionStore] session].userID cardConfiguration:card];
     // Show the view controller
     [self showDetailViewController:composerWithCard sender:self];
     */
}

/*
 * This is an example of a manually created request to the API.
 * More on creating requests: https://docs.fabric.io/ios/twitter/access-rest-api.html#constructing-a-twitter-request-manually
 * Twitter REST API reference: https://dev.twitter.com/rest/public
 */
- (IBAction)showFriendsAction:(id)sender
{
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/friends/list.json";
    NSDictionary *params = @{@"id" : [[[[Twitter sharedInstance] sessionStore] session] userID]};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                NSArray *friends = json[@"users"];
                TwitterKitFriendsTableViewController *friendsViewController = [[TwitterKitFriendsTableViewController alloc] initWithFriends:friends];
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

@end
