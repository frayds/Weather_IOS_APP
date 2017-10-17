//
//  WXManager.m
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"
#import <TSMessages/TSMessage.h>


@interface WXManager ()


@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;

@end

@implementation WXManager

+(instancetype)sharedManager
{
    static id _sharedManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _sharedManager=[[self alloc] init];
    });
    
    return _sharedManager;
}


-(id)init
{
    if(self=[super init])
    {
        //create a locationmanager.
        _locationManager=[[CLLocationManager alloc] init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        
        
        _client=[[WXClient alloc] init];
        
        //Return the signal's ReactiveCocoa script to observe its currentLocation
        [[[[RACObserve(self, currentLocation)ignore:nil] flattenMap:^(CLLocation *newLocation) {
            return [RACSignal merge:@[
                                      [self updateCurrentConditions],
                                      [self updateDailyForecast],
                                      [self updateHourlyForecast]
                                      ]];
            //The signal is passed to the observer on the main thread
        }] deliverOn:[RACScheduler mainThreadScheduler]]
         //Whenever an error occurs, a banner is displayed
        subscribeError:^(NSError *error) {
            [TSMessage showNotificationWithTitle:@"Erroe" subtitle:@"There was a problem" type:TSMessageNotificationTypeError];
        }];
    }
    return self;
}

-(void)findCurrentLocation
{
    self.isFirstUpdate=YES;
    
    if(self.locationManager==nil)
    {
        self.locationManager=[[CLLocationManager alloc] init];
    }
    self.locationManager.delegate=self;
    
    //[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        NSLog(@"is beyond the IOS8");
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status==kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"Wait for authorization of user");
    }
    else if(status==kCLAuthorizationStatusAuthorizedAlways||status==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        NSLog(@"Authorization successed");
        // start using current location
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"Authorization failed");
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(self.isFirstUpdate)
    {
        self.isFirstUpdate=NO;
        return;
    }
    
    CLLocation *location=[locations lastObject];
    
    //set currentlocation will start the RACObservable
    self.currentLocation=location;
    
    
    if(location.horizontalAccuracy>0)
    {
        
        [self.locationManager stopUpdatingLocation];
    }
    
    
}

-(RACSignal *)updateCurrentConditions
{
    return [[self.client catchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition)
            {
                self.currentCondition=condition;
            }];
}

-(RACSignal *)updateHourlyForecast
{
    return [[self.client catchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *condition)
            {
                self.hourlyForecast=condition;
            }];
}

-(RACSignal *)updateDailyForecast
{
    return  [[self.client catchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *condition)
             {
                 self.dailyForecast=condition;
             }];
}



@end
