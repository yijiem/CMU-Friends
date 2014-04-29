//
//  ProfileViewController.m
//  CMUFriends
//
//  Created by ZHANG YU on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "ProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h> // connect with faceboook.

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *genderText;
@property (weak, nonatomic) IBOutlet UILabel *facebookText;
@property (weak, nonatomic) IBOutlet UILabel *emailText;
@property (weak, nonatomic) IBOutlet UILabel *departmentText;

@end

@implementation ProfileViewController
@synthesize facebookID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction) sendFacebookMessage  {
    
    NSString *graphPath = [NSString stringWithFormat:@"/%@", facebookID];
    
    /* make the API call */
    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result6,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              
                              NSLog(@"result : %@",result6);
                              
                              // get the facebook id of the person.
                              NSString *id = [result6 objectForKey:@"id"];
                              NSString *link = [NSString stringWithFormat:@"fb-messenger://user-thread/%@", id];
                              
                              // send message to the specific person.
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                              
                              NSDictionary *userInfo = [error userInfo];
                              if (userInfo != NULL) {
                                    NSLog(@"The error of facebook api is: %@", userInfo);
                              }
                          }];
}

- (void)updateView
{
    [self.imageView setImage:self.profileImage];
    self.nameText.text = self.profileName;
    self.genderText.text = self.profileGender;
    self.facebookText.text = self.facebookID;
    self.emailText.text = self.profileEmail;
    self.departmentText.text = self.profileDepartment;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
