//
//  homeTableViewController.h
//  CMUFriends
//
//  Created by Yijie Ma on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AudioToolbox/AudioToolbox.h>

                                     /* modified by Yijie Ma */
@interface homeTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *showInMap;

@property (strong, atomic) NSMutableArray *sortedNearByPeople; // hold sortedNearByPeople list
@property (strong, atomic) NSMutableArray *distance; // hold distance


@end
