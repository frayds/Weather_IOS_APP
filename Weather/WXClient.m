//
//  WXClient.m
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

#define apikey @"9f74c10463564beaf2cf64727c8d807f"

@interface WXClient ()
//manage the API URL session
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WXClient
-(id)init
{
    if(self=[super init])
    {
        NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
        _session =[NSURLSession sessionWithConfiguration:config];
    }
    return  self;
}

-(RACSignal *)catchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching: %@",url.absoluteString);
    
    //return signal
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber)
            {
              //catch information
                NSURLSessionDataTask *dataTask=[self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse *response, NSError *error) {
                    // Handle retrieved data
                    
                    if(!error)
                    {
                        NSError *jsonError=nil;
                        id json=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                        
                        
                        if(!jsonError)
                        {
                            [subscriber sendNext:json];
                        }
                        
                        else
                        {
                            [subscriber sendError:jsonError];
                        }
                        
                    }
                    
                    else
                    {
                        [subscriber sendError:error];
                    }
                    
                    [subscriber sendCompleted];
                    
                    
                }];

                [dataTask resume];
                
                return [RACDisposable disposableWithBlock:^{
                    [dataTask cancel];
                }];
                
            }] doError:^(NSError *error) {
                NSLog(@"%@",error);
            }];
}


-(RACSignal *)catchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    //use lation and lonation to catch date
    NSString *urlString=[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%@",coordinate.latitude,coordinate.longitude,apikey];
    
    NSURL *url=[NSURL URLWithString:urlString];
    
    //map the date
    return  [[self catchJSONFromURL:url] map:^(NSDictionary *json) {
        //use MTLJSONAdapter to transfer JSON to WXCondition
        WXCondition *model=[MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json  error:nil];
        return model;
    }];
}

-(RACSignal *)catchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    //the same above
    NSString *urlString=[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=%@",coordinate.latitude,coordinate.longitude,apikey];
    NSURL *url=[NSURL URLWithString:urlString];
    
    return [[self catchJSONFromURL:url] map:^(NSDictionary *json)
            {
                //use JSON ”list”key to create RACSequence。
                RACSequence *list=[json[@"list"] rac_sequence];
                
              
                return [[list map:^(NSDictionary *item)
                        {
                          
                            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
                        }]array];
            }];
}

-(RACSignal *)catchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
   
    NSString *urlString=[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&appid=%@",coordinate.latitude,coordinate.longitude,apikey];
    
    NSURL *url=[NSURL URLWithString:urlString];
    
    
    return [[self catchJSONFromURL:url] map:^(NSDictionary *json)
            {
                
                RACSequence *list=[json [@"list"] rac_sequence];
                
                return [[list map:^(NSDictionary *item)
                        {
                            return  [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
                        }] array];
                
            }];
}

@end
