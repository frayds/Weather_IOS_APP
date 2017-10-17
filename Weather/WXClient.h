//
//  WXClient.h
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

@import CoreLocation;
#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>



@interface WXClient : NSObject


- (RACSignal *)catchJSONFromURL:(NSURL *)url;
- (RACSignal *)catchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)catchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)catchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;


@end
