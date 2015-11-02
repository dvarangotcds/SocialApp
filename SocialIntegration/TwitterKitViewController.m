//
//  TwitterKitViewController.m
//  TwitterKitTest
//
//  Created by Santiago Rama on 10/27/15.
//  Copyright © 2015 Santiago. All rights reserved.
//

#import "TwitterKitViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TKFriendsTableViewController.h"

@interface TwitterKitViewController ()

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;

@end

@implementation TwitterKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UI Actions

// Reference: https://docs.fabric.io/ios/twitter/authentication.html#log-in-button
- (IBAction)loginTwitterAction:(id)sender
{
    __weak TwitterKitViewController *wself = self;
    
    // This method will use the accounts stored on device to login.
    // If there are no accounts, a view controller will be presented for the user to login or register.
    // After the user successfully logs in, he/she will also be logged in the device
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {

            TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
            [client loadUserWithID:session.userID completion:^(TWTRUser *user, NSError *error) {
                wself.fullNameLabel.text = user.name;
                wself.userNameLabel.text = user.screenName;
                wself.identifierLabel.text = user.userID;
            }];

        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    //You can also use a default Twitter login button like this
    TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    // Set frame and add
    logInButton.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:logInButton];
}


// We can have multiple sessions, so when we logout we need to specify the userID
- (IBAction)logoutAction:(id)sender
{
    // Retrieve all the logged sessions and show in an action sheet to select
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSArray *sessions = [store existingUserSessions];
    
    UIAlertController *logoutActionSheet = [UIAlertController alertControllerWithTitle:@"Twitter accounts logged in"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    __weak TwitterKitViewController *wself = self;
    
    for (TWTRSession *session in sessions) {
        UIAlertAction *sessionAction = [UIAlertAction actionWithTitle:session.userName
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [store logOutUserID:session.userID];
                                                                  wself.fullNameLabel.text = @"";
                                                                  wself.userNameLabel.text = @"";
                                                                  wself.identifierLabel.text = @"";
                                                              }];
        [logoutActionSheet addAction:sessionAction];
    }
    
    [logoutActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:logoutActionSheet animated:YES completion:nil];
}

// We can get all the sessions logged, a specific session using userId parameter, or the last one
// Reference: https://docs.fabric.io/ios/twitter/authentication.html#managing-sessions
- (IBAction)viewAccountsAction:(id)sender
{
    // We need the session store object to retrieve sessions
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    
    // This is how we get the array of all sessions
    NSArray *sessions = [store existingUserSessions];
    NSLog(@"Sessions array: %@", sessions);
    
    // Property for current session
    TWTRSession *lastSession = store.session;
    NSLog(@"Last session: %@", lastSession.userName);
    
    //Property for specific session
    NSString *userID = @"123";
    TWTRSession *specificSession = [store sessionForUserID:userID];
    NSLog(@"specific session (%@): %@", userID, specificSession.userName);
    
    //To show them in an action sheet
    UIAlertController *sessionsActionSheet = [UIAlertController alertControllerWithTitle:@"Twitter accounts logged in"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak TwitterKitViewController *wself = self;
    
    for (TWTRSession *session in sessions) {
        UIAlertAction *sessionAction = [UIAlertAction actionWithTitle:session.userName
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  wself.fullNameLabel.text = @""; //Note that in the TWTRSession we don't have the full name, we need to get the TWTRUser if we need this
                                                                  wself.userNameLabel.text = session.userName;
                                                                  wself.identifierLabel.text = session.userID;
                                                              }];
        [sessionsActionSheet addAction:sessionAction];
    }
    
    [sessionsActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:sessionsActionSheet animated:YES completion:nil];
}

// Possible errors obtaining the email:
// - Access denied by user (TWTRErrorDomain, TWTRErrorCodeUserDeclinedPermission)
// - User didn't log in (TWTRErrorDomain, TWTRErrorCodeNoAuthentication)
// - User registered using phone number, so his email field is empty.
// - Application is not in the Twitter whitelist, or you are using old tokens. (TWTRAPIErrorDomain, TWTRAPIErrorCodeNotAuthorizedForEndpoint)
// 
// This example will fail because this app is not whitelisted. To whitelist your application you need to complete this form: https://support.twitter.com/forms/platform
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

@end
