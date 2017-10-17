
//  WXDailyForecast.m
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    //get the path of wxcondition
    NSMutableDictionary *paths= [[super JSONKeyPathsByPropertyKey] mutableCopy];

    //change the paths
    paths[@"locationName"]=@"city.name";
    paths[@"humidity"]=@"humidity";
    paths[@"windBearing"]=@"deg";
    paths[@"windSpeed"]=@"speed";
    paths[@"temperature"]=@"temp.day";
    paths[@"tempHigh"]=@"temp.max";
    paths[@"tempLow"]=@"temp.min";
    
    return paths;
}

@end
