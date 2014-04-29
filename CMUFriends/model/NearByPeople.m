//
//  NearByPeople.m
//  CMUFriends
//
//  Created by Yijie Ma on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "NearByPeople.h"
@implementation NearByPeople

+ (NSMutableArray *) sortByDistance:(NSArray *)unsortedPeople
                   targetedLocation:(PFGeoPoint *)targetedPoint
{
    
    NSMutableArray *sortedPeople = [(NSArray*)unsortedPeople mutableCopy];
    NSMutableArray *distance = [[NSMutableArray alloc] init];
    /* add to distance array */
    for (PFObject *object in unsortedPeople) {
        PFGeoPoint *currentLocation = [object objectForKey:@"location"];
        NSNumber *n = [NSNumber numberWithDouble:[targetedPoint distanceInMilesTo:currentLocation]];
        NSLog(@"distance = %@", n);
        [distance addObject:n];
    }
    
    /* bubble sort */
    for (int i = 0; i < unsortedPeople.count - 1; i++) {
        for (int j = 0; j < unsortedPeople.count - i - 1; j++) {
            if ([distance[j] compare:distance[j + 1]] == NSOrderedDescending) {
                [sortedPeople exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                [distance exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
        }
    }
    
    return sortedPeople;
}

+ (NSMutableArray *) calculateDistance:(NSMutableArray *)sortedPeople
                      targetedLocation:(PFGeoPoint *)targetedPoint
{
    NSMutableArray *distance = [[NSMutableArray alloc] init];
    for (PFObject *object in sortedPeople) {
        PFGeoPoint *currentLocation = [object objectForKey:@"location"];
        NSNumber *n = [NSNumber numberWithDouble:[targetedPoint distanceInMilesTo:currentLocation]];
        NSLog(@"distance = %@", n);
        [distance addObject:n];
    }
    
    return distance;
}

@end
