//
//  ProfileViewController.h
//  CMUFriends
//
//  Created by ZHANG YU on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

//@property (strong, nonatomic) NSString *facebookID;
//@property (strong, nonatomic) UIImage *profileImage;
//@property (strong, nonatomic) NSString *profileName;
//@property (strong, nonatomic) NSString *profileGender;
//@property (strong, nonatomic) NSString *profileEmail;
//@property (strong, nonatomic) NSString *profileDepartment;

// added by yu zhang. To import the sorted nearby people from the HometableView.
@property (strong, atomic) NSMutableArray *sortedNearByPeople; // hold sortedNearByPeople list

// added by yu zhang. To show the location of the specific person.
@property NSInteger userIndex;

@end
