//
//  WXCondition.m
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

#define MPS_TO_MPH 2.236f

#import "WXCondition.h"

@implementation WXCondition

+(NSDictionary *)imageMap
{
    //static NSDictionary
    static NSDictionary *_imageMap=nil;
    //the relation between the image and the weather
    _imageMap=@{
                @"01d" : @"weather-clear",
                @"02d" : @"weather-few",
                @"03d" : @"weather-few",
                @"04d" : @"weather-broken",
                @"09d" : @"weather-shower",
                @"10d" : @"weather-rain",
                @"11d" : @"weather-tstorm",
                @"13d" : @"weather-snow",
                @"50d" : @"weather-mist",
                @"01n" : @"weather-moon",
                @"02n" : @"weather-few-night",
                @"03n" : @"weather-few-night",
                @"04n" : @"weather-broken",
                @"09n" : @"weather-shower",
                @"10n" : @"weather-rain-night",
                @"11n" : @"weather-tstorm",
                @"13n" : @"weather-snow",
                @"50n" : @"weather-mist",
                };
    
    return _imageMap;
}
//get the image name
-(NSString *)imageName
{
    return [WXCondition imageMap][self.icon];
}


//Key is the property name of WXCondition, and value is the path to JSON
+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

//the transformer of NSDate property
+(NSValueTransformer *)dateJSONTransformer
{
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
    
}

+(NSValueTransformer *)sunriseJSONTransformer
{
    return  [self dateJSONTransformer];
}

+(NSValueTransformer *)sunsetJSONTransformer
{
    return  [self dateJSONTransformer];
}

+(NSValueTransformer *)conditionDescriptionJSONTransformer
{
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+(NSValueTransformer *)conditionJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

+(NSValueTransformer *)iconJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}


//every second per meter -----> every hour per mile
+(NSValueTransformer *)windSpeedJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}

 //Kelvin----->Fahrenheit
+(NSValueTransformer *)temperatureJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithBlock:^(NSNumber *Ktemp) {
        return @(Ktemp.floatValue*1.8-459.67);
    }];
}

+(NSValueTransformer *)tempHighJSONTransformer
{
    return [self temperatureJSONTransformer];
}

+(NSValueTransformer *)tempLowJSONTransformer
{
    return [self temperatureJSONTransformer];
}


@end
