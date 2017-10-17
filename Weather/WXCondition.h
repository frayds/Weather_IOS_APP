//
//  WXCondition.h
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

#import <Mantle/Mantle.h>

//MTLJSONSerializing协议:如何从JSON映射到Objective-C的属性
@interface WXCondition : MTLModel<MTLJSONSerializing>

//天气数据的属性
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

-(NSString *)imageName;


@end
