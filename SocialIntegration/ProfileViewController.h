//
//  ProfileViewController.h
//  FacebookTest
//
//  Created by Juan Andrés Blanco on 10/29/15.
//  Copyright © 2015 Maximiliano Gaitán. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ProfileViewController : UIViewController <FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *userMail;
@property (weak, nonatomic) IBOutlet UILabel *userBirthday;

@end
