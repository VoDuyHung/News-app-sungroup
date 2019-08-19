//
//  ViewController.m
//  Sungroup
//
//  Created by DUY TAN on 18/3/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "TrangChuController.h"
#import "SWRevealViewController.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *txt_taikhoan;
@property (strong, nonatomic) IBOutlet UITextField *txt_pass;
@property (weak, nonatomic) IBOutlet UIImageView *_img_login;
@property (weak, nonatomic) IBOutlet UILabel *lbl_duytri;
@property (strong, nonatomic) UIWindow * windows;
@property (strong, nonatomic) UINavigationController * nav;
@end
#define IS_IPHONE6PLUS (([[UIScreen mainScreen] bounds].size.width)==414.0f && ([[UIScreen mainScreen]  bounds].size.height)==736.0f)
#define IS_IPHONE6 (([[UIScreen mainScreen]bounds].size.width)==375.0f && ([[UIScreen mainScreen]bounds].size.height)==667.0f)
#define IS_IPHONE5S5 (([[UIScreen mainScreen]bounds].size.width)==320.0f && ([[UIScreen mainScreen]bounds].size.height)==568.0f)
#define IS_IPHONE4S43 (([[UIScreen mainScreen]bounds].size.width)==320.0f && ([[UIScreen mainScreen]bounds].size.height)==480)
@implementation ViewController{
    NSString *strSessName,*strSessVal;
    UIButton * btn_upTop;
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txt_taikhoan.delegate = self;
    self.txt_pass.delegate = self;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *saveUsername = [def stringForKey:@"textField1Text"];
    NSString *savePassword = [def stringForKey:@"textField2Text"];
    //Save usernae+password
    self.txt_pass.text=savePassword; self.txt_taikhoan.text=saveUsername;
    [self interface];
    
    
}
-(void)interface{
    //add icon to txt_taikhoan and txt_pass
    
    UIView * containterTK = [[UIView alloc]init];
    [containterTK setFrame:CGRectMake(0.0f, 0.0f, 45.0f, 25.0f)];
    
    UIImageView *iconTK= [[UIImageView alloc] init];
    [iconTK setImage:[UIImage imageNamed:@"60tk.png"]];
    [iconTK setFrame:CGRectMake(10.0f, 0.0f, 23.0f, 23.0f)];
    [iconTK setBackgroundColor:[UIColor clearColor]];
    [containterTK addSubview:iconTK];
    [_txt_taikhoan setLeftView:containterTK];
    [_txt_taikhoan setLeftViewMode:UITextFieldViewModeAlways];
    
    
    UIView * containterP = [[UIView alloc]init];
    [containterP setFrame:CGRectMake(0.0f, 0.0f, 45.0f, 23.0f)];
    [containterP setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *iconP= [[UIImageView alloc] init];
    [iconP setImage:[UIImage imageNamed:@"60.png"]];
    [iconP setFrame:CGRectMake(10.0f, 0.0f, 23.0f, 23.0f)];
    [containterP addSubview:iconP];
    [_txt_pass setLeftView:containterP];
    [_txt_pass setLeftViewMode:UITextFieldViewModeAlways];
    
    //add switch to remmember login
    CGRect frame = CGRectMake(30, 327, 0, 0);
    switchLogin = [[UISwitch alloc]initWithFrame:frame];
    switchLogin.transform = CGAffineTransformMakeScale(0.5, 0.45);
    switchLogin.onTintColor = [UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00];
    [switchLogin addTarget:self action:@selector(SwitchClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchLogin];
    [switchLogin setOn:NO];
    
    [switchLogin setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_lbl_duytri setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:switchLogin
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_lbl_duytri
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:-18]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:switchLogin
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_lbl_duytri
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:switchLogin
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_lbl_duytri
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
    
    if (IS_IPHONE6PLUS){[ __img_login setImage:[UIImage imageNamed:@"1242x2208"]];}
    else if(IS_IPHONE6){ [__img_login setImage:[UIImage imageNamed:@"750x1334"]];}
    else if(IS_IPHONE5S5){[__img_login setImage:[UIImage imageNamed:@"640x1136"]];}
    else if(IS_IPHONE4S43){[__img_login setImage:[UIImage imageNamed:@"640x960"]];}
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * _value = [def stringForKey:@"stateOfSwitch"];
    if([_value compare:@"OFF"]== NSOrderedSame){
        switchLogin.on = NO;
    }
    else {
        switchLogin.on = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while moving to the other screen.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)keyboardWillAppear {
    // Move current view up / down with Animation
    if (self.view.frame.origin.y >= 0)
    {
        [self moveViewUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self moveViewUp:NO];
    }
}
-(void)keyboardWillDisappear {
    if (self.view.frame.origin.y >= 0)
    {
        [self moveViewUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self moveViewUp:NO];
    }
}
-(void)moveViewUp:(BOOL)bMovedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4]; // to slide the view up
    // NSInteger number = 260;
    CGRect rect = self.view.frame;
    if (bMovedUp) {
        if(IS_IPHONE5S5 ){
            rect.origin.y -= 80;
           // rect.size.height += 100;
            
        }
        if(IS_IPHONE4S43 ){
            rect.origin.y -= 225;
            rect.size.height += 60;
            
        }
        if(IS_IPHONE6){
            rect.origin.y -= 80;
            rect.size.height -= 40;
        }
        if(IS_IPHONE6PLUS){
            rect.origin.y -= 80;
            
        }
        
        
    } else {
        if(IS_IPHONE6){
            rect.origin.y += 80;
            rect.size.height += 40;
        }
        if(IS_IPHONE6PLUS){
            rect.origin.y += 80;
        }
        if(IS_IPHONE5S5){
            rect.origin.y += 80;
        //    rect.size.height -= 100;
            
        }
        if(IS_IPHONE4S43){
            rect.origin.y += 225;
            rect.size.height -= 60;
            
        }
    }
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (IBAction)SwitchClick:(UIButton *)sender {
    NSString *value = @"ON";
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(!switchLogin.on){
        value = @"OFF";
        [defaults setObject:value forKey:@"stateOfSwitch"];
    }
    else {
        [defaults setObject:value forKey:@"stateOfSwitch"];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { // ẩn bàn phím khi sửa xong
    [_txt_taikhoan endEditing:YES];
    [_txt_pass endEditing:YES];
    [_txt_taikhoan resignFirstResponder];
    [_txt_pass resignFirstResponder];
    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    if(_txt_taikhoan.editing == FALSE){
        
        _txt_taikhoan.placeholder = @"Tài khoản";
    }
    if(_txt_pass.editing == FALSE){
        
        _txt_pass.placeholder = @"Mật khẩu";
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{ //event for return key done or or of keyboard
    if( _txt_taikhoan.editing == TRUE){
        
        [_txt_taikhoan resignFirstResponder];
        [self moveViewUp:YES];
        [_txt_pass becomeFirstResponder];
        
    }else if(_txt_pass.editing == TRUE){
        //  self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
        [self btn_Login:0];
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [_txt_pass resignFirstResponder];
    
    [self moveViewUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:_txt_pass]&&[textField isEqual:_txt_taikhoan]){
        if  (self.view.frame.origin.y >= 0)
        {
            [self moveViewUp:YES];
        }
    }
    if(_txt_pass.editing == TRUE ){
        _txt_pass.placeholder = nil;
    }
    if(_txt_pass.editing == FALSE){
        
        _txt_pass.placeholder = @"Mật khẩu";
    }
    if(_txt_taikhoan.editing == TRUE ){
        _txt_taikhoan.placeholder = nil;
    }
    if(_txt_taikhoan.editing == FALSE){
        
        _txt_taikhoan.placeholder = @"Tài khoản";
    }
}
- (IBAction)btn_Login:(id)sender {
    
MBProgressHUD *hu = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
hu.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
hu.label.text = NSLocalizedString(@"Đang đăng nhập...", @"HUD loading title");
dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
if ([[_txt_taikhoan text] isEqualToString:@""] || [[_txt_pass text]isEqualToString:@""]) {
 UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Yêu cầu tài khoản và mật khẩu, vui lòng kiểm tra lại !" preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
 }];
 [alert addAction:ok];
 [self presentViewController:alert animated:YES completion:nil];
 }
 else {
 //check internet
 Reachability *reachTest = [Reachability reachabilityWithHostName:@"www.google.com"];
 NetworkStatus internetStatus = [reachTest  currentReachabilityStatus];
 if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){
 /// Create an alert if connection doesn't work,no internet connection
 UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Không có kết nối Internet.Hãy bật WIFI hoặc 3G để ứng dụng hoạt động!" preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
 }];
 [alert addAction:ok];
 [self presentViewController:alert animated:YES completion:nil];
 }
 else {
 //xoá cookie
 NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
 for (NSHTTPCookie *cookie in [storage cookies]) {
 [storage deleteCookie:cookie];
 }
 [[NSUserDefaults standardUserDefaults] synchronize];
 if(switchLogin.on == YES)
 {
 //save username
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:_txt_taikhoan.text forKey:@"textField1Text"];
 //save password
 [defaults setObject:_txt_pass.text forKey:@"textField2Text"];
 [defaults synchronize];
 
 } else
 {
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:@"" forKey:@"textField1Text"];
 [defaults setObject:@"" forKey:@"textField2Text"];
 [defaults synchronize];
 }

     NSString *post1 =[[NSString alloc] initWithFormat:@"{\"username\":\"%@\",\"password\":\"%@\"}",[_txt_taikhoan text],[_txt_pass text]];
     NSURL *url=[NSURL URLWithString:@"https://cms.sungroup.com.vn/api/mic/user/login"];
     NSData *postData = [post1 dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
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
     NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
     
     [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
     for (NSHTTPCookie * cookie in cookies)
     {
         strSessName=cookie.name;
         strSessVal=cookie.value;
     }
     //get token
     NSURL *urltoken=[NSURL URLWithString:@"https://cms.sungroup.com.vn/api/mic/user/token"];
     NSData *postData1 = [post1 dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     NSString *postLength1 = [NSString stringWithFormat:@"%lu", (unsigned long)[postData1 length]];
     NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] init];
     [request1 setURL:urltoken];
     [request1 setHTTPMethod:@"POST"];
     [request1 setValue:postLength1 forHTTPHeaderField:@"Content-Length"];
     [request1 setValue:@"application/json" forHTTPHeaderField:@"Accept"];
     [request1 setValue:[NSString stringWithFormat:@"%@=%@", strSessName, strSessVal] forHTTPHeaderField:@"Cookie"];
     [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
     [request1 setHTTPBody:postData1];
     NSHTTPURLResponse *response1 = nil;
     NSError *error1 = nil;
     NSData *urlData1=[NSURLConnection sendSynchronousRequest:request1
                                            returningResponse:&response1
                                                        error:&error1];
     NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:urlData1 options: NSJSONReadingMutableContainers error: &error1];
     [[NSUserDefaults standardUserDefaults] setObject:json[@"token"] forKey:@"token"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     /*end*/
 if (!urlData){
 Reachability *reachTest = [Reachability reachabilityWithHostName:@"www.google.com"];
 NetworkStatus internetStatus = [reachTest  currentReachabilityStatus];
 if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){
 UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Không có kết nối Internet.Hãy bật WIFI hoặc 3G để ứng dụng hoạt động!" preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
 [alert addAction:ok];
 [self presentViewController:alert animated:YES completion:nil];
 }
 }
 else{
NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:urlData options: NSJSONReadingMutableContainers error: &error];
if(json == NULL){
    UIAlertController *aleart = [UIAlertController alertControllerWithTitle:@"Thông báo !" message:@"Tài khoản đăng nhập không chính xác, vui lòng kiểm tra lại !" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [aleart addAction:ok];
    [self presentViewController:aleart animated:YES completion:nil];
}

 if(strSessName == nil || strSessVal == nil){
 UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Tài khoản đăng nhập không chính xác, vui lòng kiểm tra lại !" preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
      [alert dismissViewControllerAnimated:YES completion:nil];
 }];
 [alert addAction:ok];
 [self presentViewController:alert animated:YES completion:nil];

 }
      [hu hideAnimated:YES];
     UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
     MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
     hud1.label.text = @"Đang đăng nhập...";
     [self performSegueWithIdentifier:@"Login" sender:self];
     [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
     [hud1 hideAnimated:YES];
 }
 }
 }
    });
    });
    }
@end
