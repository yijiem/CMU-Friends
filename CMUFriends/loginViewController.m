//
//  loginViewController.m
//  CMUFriends
//
//  Created by Yijie Ma on 4/23/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "loginViewController.h"
#import "homeTableViewController.h"
#import "NearByPeople.h"

@interface loginViewController ()
@property (nonatomic, readonly, retain) IBOutlet UITextField *andrewIdTextField;
@property (nonatomic, readonly, retain) IBOutlet UITextField *password;
@property (strong, atomic) NSMutableArray *preloadedSortedPeople;
@property (strong, atomic) NSMutableArray *preloadedDistance;
@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.andrewIdTextField.delegate = self;
    self.password.delegate = self;
}

// hide text keyboard of UITextField when done
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouch:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.andrewIdTextField.text password:self.password.text
                                    block:^(PFUser *user, NSError *error) {
                                    if (user) {
                                    // Do stuff after successful login.
                                        
                                        /* report current user's location to back-end when user login in */
                                        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                                            if (!error) {
                                                // do something with the new geoPoint
                                                [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
                                                [[PFUser currentUser] saveInBackground];
                                            }
                                        }];
                                        
                                        /* pre-address data to fetch into home table view */
                                        /* query User object from back-end except the current user */
                                        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                                        [query whereKey:@"username" notEqualTo:[PFUser currentUser].username];
                                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                            if (!error) {
                                                
                                                /* generate sorted near by people array for display */
                                                self.preloadedSortedPeople = [NearByPeople sortByDistance:objects targetedLocation:[[PFUser currentUser] objectForKey:@"location"]];
                                                
                                                
                                                /* generate sorted distance array for display */
                                                self.preloadedDistance = [NearByPeople calculateDistance:self.preloadedSortedPeople targetedLocation:[[PFUser currentUser] objectForKey:@"location"]];
                                            }
                                        }];

                                        
                                        
                                        [self performSegueWithIdentifier:@"Login Success" sender:sender];
                                    } else {
                                    // The login failed. Check error to see why.
                                        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                          message:[error localizedDescription]
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"OK"
                                                                                otherButtonTitles:nil];
                                        [message show];
                                        self.andrewIdTextField.text = @"";
                                        self.password.text = @"";
                                    }
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Login Success"]) {
        if ([segue.destinationViewController isKindOfClass:[homeTableViewController class]]) {
            // do what you want to the next view
            homeTableViewController *htvc = (homeTableViewController *)segue.destinationViewController;
            htvc.sortedNearByPeople = self.preloadedSortedPeople;
            htvc.distance = self.preloadedDistance;
        }
    }
}


@end
