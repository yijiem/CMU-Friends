//
//  NearByPeople.h
//  CMUFriends
//
//  Created by Yijie Ma on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface NearByPeople : NSObject

// sort nearby user by distance
+ (NSMutableArray *) sortByDistance:(NSArray *)unsortedPeople
                   targetedLocation:(PFGeoPoint *)targetedPoint;
// calculate and return a distance array
+ (NSMutableArray *) calculateDistance:(NSMutableArray *)sortedPeople
                      targetedLocation:(PFGeoPoint *)targetedPoint;
@end
