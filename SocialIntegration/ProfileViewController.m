//
//  ProfileViewController.m
//  FacebookTest
//
//  Created by Juan Andrés Blanco on 10/29/15.
//  Copyright © 2015 Maximiliano Gaitán. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoutButton = [[FBSDKLoginButton alloc] init];
    self.logoutButton.delegate = self;
    //self.logoutButton.center = self.view.center;
    
    CGRect btFrame = self.logoutButton.frame;
    btFrame.origin.x = 70;
    btFrame.origin.y = 500;
    self.logoutButton.frame = btFrame;
    
    [self.view addSubview:self.logoutButton];
    

    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"email, name, picture.type(large), birthday, friends"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
         if (!error) {
             NSLog(@"result: %@", result);
             NSDictionary *dict = (NSDictionary *)result;

             self.userName.text = [dict objectForKey:@"name"];
             self.userBirthday.text = [dict objectForKey:@"birthday"];
             self.userMail.text = [dict objectForKey:@"email"];
             
             NSString *imageString = [[[dict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
             NSURL *url = [[NSURL alloc] initWithString:imageString];
             NSData *data = [[NSData alloc] initWithContentsOfURL:url];
             UIImage *tmpImage = [[UIImage alloc] initWithData:data];
             self.userProfilePic.image = tmpImage;
             
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    //FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    //[loginManager logOut];
    //[FBSDKProfile setCurrentProfile:nil];
    
    [self performSegueWithIdentifier:@"showLogin" sender:loginButton];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{}

@end
