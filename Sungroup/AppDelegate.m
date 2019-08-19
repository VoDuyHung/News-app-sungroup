//
//  AppDelegate.m
//  Sungroup
//
//  Created by DUY TAN on 18/3/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//
#import "AppDelegate.h"
#import "ContentDetailController.h"
#import "SWRevealViewController.h"
#define LINK @"https://cms.sungroup.com.vn/mobile_data/push_notifications"
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    NSDictionary * userInfor = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //UILocalNotification * userInfor = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(userInfor){
        //[self application:application didReceiveLocalNotification:userInfor];
        [self application:application didReceiveRemoteNotification:userInfor];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
      if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }
     return YES;
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString * token = [NSString stringWithFormat:@"%@",deviceToken];
    NSLog(@"token %@",token.description);
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString *post =[[NSString alloc] initWithFormat:@"{\"token\":\"%@\",\"type\":\"ios\"}",token];
    NSURL *url=[NSURL URLWithString:@"https://cms.sungroup.com.vn/mobile_data/push_notifications"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"lol %@, %@", error, error.localizedDescription);
}
-(void)pushToContent {
            self.window = [[UIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
            UIStoryboard * story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController * v= [story instantiateViewControllerWithIdentifier:@"d"];
            self.window.rootViewController = v;
            [self.window makeKeyAndVisible];
            ContentDetailController*qaDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"detailVC"];
            UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:qaDetailViewController];
            navigation.navigationBar.barTintColor = [UIColor colorWithRed:0.235 green:0.314 blue:0.349 alpha:1.00];
            navigation.navigationBar.translucent = NO;
            navigation.navigationBar.tintColor = [UIColor colorWithRed:0.235 green:0.314 blue:0.349 alpha:1.00];
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate.window.rootViewController presentViewController:navigation animated:YES completion:nil];
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    if(application.applicationState != UIApplicationStateActive){
        NSString *linkURL = [NSString stringWithFormat:@"https://cms.sungroup.com.vn/node/%@.json",[notification.userInfo valueForKey:@"id"]];
        NSError * error = nil;
        NSURL * URL = [NSURL URLWithString:linkURL];
        NSData * data = [NSData dataWithContentsOfURL:URL options:0 error:&error];
        NSMutableDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSString * body_content;
        NSArray  * body = json[@"body"];
        if(body == (id)[NSNull null]){
            body_content = @"không có nội dung cho bài viết này";
        }else{
            body_content = [json valueForKey:@"body"][@"value"];
        }
        NSString *title_temp;
        if( [json valueForKey:@"title"] == [NSNull null]){
            title_temp = @"Không có tiêu đề";
        }
        else {
            title_temp = [json valueForKey:@"title"];
        }
        int secondsLeft;
        NSString *formattedDateString;
        int date = [[json objectForKey:@"created"] intValue];
        if(date == (int)[NSNull null]){
            secondsLeft = 28/9/2016;
        }
        else {
            secondsLeft = [[json objectForKey:@"created"] intValue];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, dd'/'MM'/'YYYY"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsLeft];
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
            formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
        }
        NSString *link_load;
        NSString * links = [json valueForKey:@"url"];
        if(links == (id)[NSNull null]){
            link_load = nil;
        }else{
            link_load = [json valueForKey:@"url"];
        }
        int const view1 = [[json objectForKey:@"views"] intValue];
        NSString *threadKey=[NSString stringWithFormat:@"%d",view1];
        int const cmt = [[json objectForKey:@"comment_count"]intValue];
        NSString *cmt_count = [NSString stringWithFormat:@"%d",cmt];
        NSArray const * getIdComment = [json valueForKey:@"comments"];
        [[NSUserDefaults standardUserDefaults]setObject:body_content forKey:@"content_post"];
        [[NSUserDefaults standardUserDefaults]setObject:title_temp forKey:@"TitlePost"];
        [[NSUserDefaults standardUserDefaults]setObject:formattedDateString forKey:@"date"];
        [[NSUserDefaults standardUserDefaults]setObject:link_load forKey:@"linkview"];
        [[NSUserDefaults standardUserDefaults]setObject:threadKey forKey:@"viewtr"];
        [[NSUserDefaults standardUserDefaults]setObject:cmt_count forKey:@"comment_count"];
        [[NSUserDefaults standardUserDefaults]setObject:[notification.userInfo valueForKey:@"id"] forKey:@"nid"];
        [[NSUserDefaults standardUserDefaults]setObject:getIdComment forKey:@"comments"];
        [[NSUserDefaults standardUserDefaults]setObject:@"dimiss" forKey:@"KEY"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self pushToContent];
    }

}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if(application.applicationState != UIApplicationStateActive){
        NSString *linkURL = [NSString stringWithFormat:@"https://cms.sungroup.com.vn/node/%@.json",[[userInfo valueForKey:@"aps"]valueForKey:@"id"]];
        NSError * error = nil;
        NSURL * URL = [NSURL URLWithString:linkURL];
        NSData * data = [NSData dataWithContentsOfURL:URL options:0 error:&error];
        NSMutableDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSString * body_content;
        NSArray  * body = json[@"body"];
        if(body == (id)[NSNull null]){
            body_content = @"không có nội dung cho bài viết này";
        }else{
            body_content = [json valueForKey:@"body"][@"value"];
        }
        NSString *title_temp;
        if( [json valueForKey:@"title"] == [NSNull null]){
            title_temp = @"Không có tiêu đề";
        }
        else {
            title_temp = [json valueForKey:@"title"];
        }
        int secondsLeft;
        NSString *formattedDateString;
        int date = [[json objectForKey:@"created"] intValue];
        if(date == (int)[NSNull null]){
            secondsLeft = 28/9/2016;
        }
        else {
            secondsLeft = [[json objectForKey:@"created"] intValue];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, dd'/'MM'/'YYYY"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsLeft];
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
            formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
        }
        NSString *link_load;
        NSString * links = [json valueForKey:@"url"];
        if(links == (id)[NSNull null]){
            link_load = nil;
        }else{
            link_load = [json valueForKey:@"url"];
        }
        int const view1 = [[json objectForKey:@"views"] intValue];
        NSString *threadKey=[NSString stringWithFormat:@"%d",view1];
        int const cmt = [[json objectForKey:@"comment_count"]intValue];
        NSString *cmt_count = [NSString stringWithFormat:@"%d",cmt];
        NSArray const * getIdComment = [json valueForKey:@"comments"];
        [[NSUserDefaults standardUserDefaults]setObject:body_content forKey:@"content_post"];
        [[NSUserDefaults standardUserDefaults]setObject:title_temp forKey:@"TitlePost"];
        [[NSUserDefaults standardUserDefaults]setObject:formattedDateString forKey:@"date"];
        [[NSUserDefaults standardUserDefaults]setObject:link_load forKey:@"linkview"];
        [[NSUserDefaults standardUserDefaults]setObject:threadKey forKey:@"viewtr"];
        [[NSUserDefaults standardUserDefaults]setObject:cmt_count forKey:@"comment_count"];
        [[NSUserDefaults standardUserDefaults]setObject:[[userInfo valueForKey:@"aps"]valueForKey:@"id"] forKey:@"nid"];
        [[NSUserDefaults standardUserDefaults]setObject:getIdComment forKey:@"comments"];
        [[NSUserDefaults standardUserDefaults]setObject:@"dimiss" forKey:@"KEY"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self pushToContent];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}
/*- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if(application.applicationState != UIApplicationStateActive){
        NSString *linkURL = [NSString stringWithFormat:@"https://cms.sungroup.com.vn/node/%@.json",[[userInfo valueForKey:@"aps"]valueForKey:@"id"]];
        NSError * error = nil;
        NSURL * URL = [NSURL URLWithString:linkURL];
        NSData * data = [NSData dataWithContentsOfURL:URL options:0 error:&error];
        NSMutableDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSString * body_content;
        NSArray  * body = json[@"body"];
        if(body == (id)[NSNull null]){
            body_content = @"không có nội dung cho bài viết này";
        }else{
            body_content = [json valueForKey:@"body"][@"value"];
        }
        NSString *title_temp;
        if( [json valueForKey:@"title"] == [NSNull null]){
            title_temp = @"Không có tiêu đề";
        }
        else {
            title_temp = [json valueForKey:@"title"];
        }
        int secondsLeft;
        NSString *formattedDateString;
        int date = [[json objectForKey:@"created"] intValue];
        if(date == (int)[NSNull null]){
            secondsLeft = 28/9/2016;
        }
        else {
            secondsLeft = [[json objectForKey:@"created"] intValue];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, dd'/'MM'/'YYYY"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsLeft];
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
            formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
        }
        NSString *link_load;
        NSString * links = [json valueForKey:@"url"];
        if(links == (id)[NSNull null]){
            link_load = nil;
        }else{
            link_load = [json valueForKey:@"url"];
        }
        int const view1 = [[json objectForKey:@"views"] intValue];
        NSString *threadKey=[NSString stringWithFormat:@"%d",view1];
        int const cmt = [[json objectForKey:@"comment_count"]intValue];
        NSString *cmt_count = [NSString stringWithFormat:@"%d",cmt];
        NSArray const * getIdComment = [json valueForKey:@"comments"];
        [[NSUserDefaults standardUserDefaults]setObject:body_content forKey:@"content_post"];
        [[NSUserDefaults standardUserDefaults]setObject:title_temp forKey:@"TitlePost"];
        [[NSUserDefaults standardUserDefaults]setObject:formattedDateString forKey:@"date"];
        [[NSUserDefaults standardUserDefaults]setObject:link_load forKey:@"linkview"];
        [[NSUserDefaults standardUserDefaults]setObject:threadKey forKey:@"viewtr"];
        [[NSUserDefaults standardUserDefaults]setObject:cmt_count forKey:@"comment_count"];
        [[NSUserDefaults standardUserDefaults]setObject:[[userInfo valueForKey:@"aps"]valueForKey:@"id"] forKey:@"nid"];
        [[NSUserDefaults standardUserDefaults]setObject:getIdComment forKey:@"comments"];
         [[NSUserDefaults standardUserDefaults]setObject:@"dimiss" forKey:@"KEY"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self pushToContent];
    }
}*/
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
