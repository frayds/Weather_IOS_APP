//
//  WXController.m
//  Weather
//
//  Created by 濮一帆 on 17/1/3.
//  Copyright © 2017年 濮一帆. All rights reserved.
//

#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WXManager.h"




@interface WXController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation WXController


//Initialize at the first time
- (id)init {
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"H:mm a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    self.screenHeight=[UIScreen mainScreen].bounds.size.height;
    UIImage *background;
    
    if([self isBetweenFromHour:6 toHour:18])
    {
        background=[UIImage imageNamed:@"bg.jpg"];
    }
    else
    {
        background=[UIImage imageNamed:@"bg2.jpg"];
    }

    
    
    self.backgroundImageView=[[UIImageView alloc] initWithImage:background];
    
    self.backgroundImageView.contentMode=UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFill －－－－Stretch picture to make it can occupy full screen
    
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView=[[UIImageView alloc]init];
    self.blurredImageView.contentMode=UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha=0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];//To achieve ground-glass effect
    [self.view addSubview:self.blurredImageView];

    self.tableView=[[UITableView alloc] init];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorColor=[UIColor colorWithWhite:1 alpha:0.2];//Set the color
    self.tableView.pagingEnabled=YES;
    [self.view addSubview:self.tableView];
    
    
    
    CGRect headerFrame=[UIScreen mainScreen].bounds;//the size of the table and screen
    
    CGFloat inset=20;//to make sure that all labels are evenly distributed and in the center
    
    CGFloat temperatureHeight=110;
    CGFloat hiloHeight=40;
    CGFloat iconHeight=30;
    
    CGRect hiloFrame=CGRectMake(inset,
                                headerFrame.size.height-hiloHeight,
                                headerFrame.size.width-(2*inset),
                                hiloHeight);
    
    CGRect temperatureFrame=CGRectMake(inset, headerFrame.size.height-(temperatureHeight+hiloHeight), headerFrame.size.width-(2*inset), temperatureHeight);
    
    CGRect iconFrame=CGRectMake(inset, temperatureFrame.origin.y-iconHeight, iconHeight, iconHeight);
    
    CGRect conditionsFrame=iconFrame;
    conditionsFrame.size.width=self.view.bounds.size.width-(((2*inset)+iconHeight)+10);
    conditionsFrame.origin.x=iconFrame.origin.x+(iconHeight+10);
    
    
    
    //set the current view as your table header
    UIView *header=[[UIView alloc]initWithFrame:headerFrame];
    header.backgroundColor= [UIColor clearColor];
    self.tableView.tableHeaderView=header;
    
    
    //creat every label that displays meteorological data
    //bottom left
    UILabel *temperatureLabel=[[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor=[UIColor clearColor];
    temperatureLabel.textColor=[UIColor whiteColor];
    temperatureLabel.text=@"0°";
    temperatureLabel.font=[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    //bottom left
    UILabel *hiloLabel=[[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor=[UIColor clearColor];
    hiloLabel.textColor=[UIColor whiteColor];
    hiloLabel.text=@"0° / 0°";
    hiloLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    //top
    UILabel *cityLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor=[UIColor clearColor];
    cityLabel.textColor=[UIColor whiteColor];
    cityLabel.text=@"Loading.......";
    cityLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment=NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel=[[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor=[UIColor clearColor];
    conditionsLabel.textColor=[UIColor whiteColor];
    conditionsLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.text=@"clear";
    [header addSubview:conditionsLabel];
    
    //Add an image view of the weather icon
    UIImageView *iconView=[[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode=UIViewContentModeScaleAspectFit;
    iconView.backgroundColor=[UIColor clearColor];
    UIImage *icon=[UIImage imageNamed:@"weather-broken"];
    [iconView setImage:icon];
    [header addSubview:iconView];

    
    
    [[RACObserve([WXManager sharedManager], currentCondition)deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(WXCondition *newCondition)
     {
         if(newCondition)
         {
             temperatureLabel.text=[NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
             conditionsLabel.text=[newCondition.condition capitalizedString];
             cityLabel.text=[newCondition.locationName capitalizedString];

             //create an image and set it as the icon for the view
             iconView.image=[UIImage imageNamed:[newCondition imageName]];
             
         }
     }];
    
    RAC(hiloLabel,text)=[[RACSignal combineLatest:@[
                                                   RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                   RACObserve([WXManager sharedManager], currentCondition.tempLow)
                                                   ]
                                          reduce:^(NSNumber *hi,NSNumber*low){
                                              return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                                          }]
    deliverOn:[RACScheduler mainThreadScheduler]];
    
    
    
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
    }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
     deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(NSArray *newForecast) {
        [self.tableView reloadData];
    }];
    
    
    //start
    [[WXManager sharedManager] findCurrentLocation];
    
    
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds=self.view.bounds;
    
    self.backgroundImageView.frame=bounds;
    self.blurredImageView.frame=bounds;
    self.tableView.frame=bounds;
}


// 1
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Hourly forecast
    if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    // daily forecast
    return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"CellIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor=[UIColor whiteColor];
    cell.detailTextLabel.textColor=[UIColor whiteColor];
    
    if(indexPath.section==0)
    {
        //The first row is the header cell
        if(indexPath.row==0)
        {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else
        {
            //weather in every hour
            WXCondition *weather =[WXManager sharedManager].hourlyForecast[indexPath.row-1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    
    else if (indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else
        {
            WXCondition *weather=[WXManager sharedManager].dailyForecast[indexPath.row-1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

#pragma control the state condition
// Controls the appearance of the status bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title
{
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text=title;
    cell.detailTextLabel.text=@"";
    cell.imageView.image=nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}


- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",weather.tempHigh.floatValue,weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //Gets the height and content offset of the scroll view
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    //The alpha upper limit is 1
    CGFloat percent = MIN(position / height, 1.0);

    self.blurredImageView.alpha = percent;
}


#pragma mark -compareDate
- (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour
{
    NSDate *date6 = [self getCustomDateWithHour:6];
    NSDate *date18 = [self getCustomDateWithHour:18];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date6]==NSOrderedDescending && [currentDate compare:date18]==NSOrderedAscending)
    {
        NSLog(@"the current time is between %ld:00-%ld:00 ！", (long)fromHour, (long)toHour);
        return YES;
    }
    return NO;
}
- (NSDate *)getCustomDateWithHour:(NSInteger)hour
{
    //get current time
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //set a special time point
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
