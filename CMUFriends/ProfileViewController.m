//
//  ProfileViewController.m
//  CMUFriends
//
//  Created by ZHANG YU on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "ProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h> // connect with faceboook.

// added by yu zhang
#import <Parse/Parse.h>

// added by yu zhang. to show the route between two person.
#import "MapViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *genderText;
@property (weak, nonatomic) IBOutlet UILabel *facebookText;
@property (weak, nonatomic) IBOutlet UILabel *emailText;
@property (weak, nonatomic) IBOutlet UILabel *departmentText;

@end

@implementation ProfileViewController
//@synthesize facebookID;

// added by yu zhang. For display all the friends nearby.
@synthesize sortedNearByPeople;

// added by yu zhang, to display two friends.
@synthesize userIndex;

// store the facebook ID.
NSString *facebookID;

- (IBAction)openFacebookLink:(id)sender {
    // open a facebook link.
    [self callFacebookApi: 1];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// added by yu zhang. To transfer data to the map view.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // when press the button "Show in the map", perform this to transfer the data to another
    // view controller.
    if([segue.identifier isEqualToString:@"profileToMapView"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.sortedNearByPeople = sortedNearByPeople;
        controller.userIndex = userIndex;
        return;
    }
}

- (void)callFacebookApi: (NSInteger)serviceType {
    // modified by yu zhang. To get facebook ID.
    NSString *graphPath = [NSString stringWithFormat:@"/%@", facebookID];
    
    NSLog(@"linke: %@", graphPath);
    
    /* make the API call */
    
    
    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id resultFB,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              
                              NSLog(@"result : %@",resultFB);
                              
                              // get the facebook id of the person.
                              NSString *id = [resultFB objectForKey:@"id"];
                              
                              NSString *link = NULL;
                              // facebook messgage.
                              if (serviceType == 0) {
                                    link = [NSString stringWithFormat:@"fb-messenger://user-thread/%@", id];
                              } else {
                                    link = [NSString stringWithFormat:@"http://www.facebook.com/%@", id];
                              }
                              
                              // send message to the specific person.
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                              
                              NSDictionary *userInfo = [error userInfo];
                              if (userInfo != NULL) {
                                  NSLog(@"The error of facebook api is: %@", userInfo);
                              }
                          }];

}


// send facebook message to the specific user.
- (IBAction) sendFacebookMessage {
    [self callFacebookApi: 0];
}

// modified by yu zhang. to transfer data through the array.
- (void)updateView
{
    /* get user object on the selected row */
    PFUser *user = (PFUser *) [self.sortedNearByPeople objectAtIndex:userIndex];
    
    facebookID = [user objectForKey:@"facebookID"];
    
    /* set up profile image */
    PFFile *theImage = [user objectForKey:@"image"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    
    if (image == nil) {
        // do nothing, just do not manually set image
    } else {
        [self.imageView setImage:image];
    }
    
    /* set up name, gender, facebookid, email */
    self.nameText.text = [user objectForKey:@"name"];
    self.genderText.text = [user objectForKey:@"gender"];
    self.facebookText.text = [user objectForKey:@"facebookID"];
    self.emailText.text = [user objectForKey:@"email"];
    self.departmentText.text = [user objectForKey:@"department"];
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
