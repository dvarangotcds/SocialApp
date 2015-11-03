//
//  ViewController.m
//  FacebookTest
//
//  Created by Juan Andrés Blanco on 10/28/15.
//  Copyright © 2015 Maximiliano Gaitán. All rights reserved.
//

#import "ViewController.h"
#import "ProfileViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([FBSDKAccessToken currentAccessToken]) //to know if the user is already logged in
    {
        [self performSegueWithIdentifier:@"showProfile" sender:self];
    }
    else{
        
        self.loginButton = [[FBSDKLoginButton alloc] init];
        self.loginButton.delegate = self;
        
        CGRect btFrame = self.loginButton.frame;
        btFrame.origin.x = 70;
        btFrame.origin.y = 500;
        self.loginButton.frame = btFrame;
        
        [self.view addSubview:self.loginButton];
        
        //for more permissions visit https://developers.facebook.com/docs/facebook-login/permissions/v2.5
        
        self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_birthday"];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate methods 

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error  {
    if(!result.isCancelled){
        if(!error){
            NSLog(@"You've Logged in");

            [self performSegueWithIdentifier:@"showProfile" sender:loginButton];
        }
        else{
            NSLog(@"An error occured, can't log in");
        }
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{}



@end
