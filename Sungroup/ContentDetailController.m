//
//  ContentDetailController.m
//  Sungroup
//
//  Created by Võ Duy Hùng  on 6/23/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "ContentDetailController.h"
#import "TrangChuController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "UIImageView+WebCache.h"
#define LINK  @"https://cms.sungroup.com.vn/node.json?type=tin_tuc&status=1&sort=changed&direction=desc&limit=6"
#define LINK_CMT_COUNT1 @"https://cms.sungroup.com.vn/node/%@.json"
#define LINK_GET_LIKE @"https://cms.sungroup.com.vn/api/vote/votingapi/select_votes.json"
#define LINK_SET_LIKE @"https://cms.sungroup.com.vn/api/vote/votingapi/set_votes.json"
@interface ContentDetailController ()<UIScrollViewDelegate,UIWebViewDelegate,UIScrollViewAccessibilityDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSString const*KEY,*titles,*images,*UserDefault,*NID,*content,*postDate,*view,*loaitin,*comment_count;
    UIButton *btn_Top;
    NSString *strForWebView;
    NSMutableArray * myObject;
    NSString *nid;
    NSDictionary * dictionary;
    UIWebView * web1;
    UIAlertController * alertControllerLike;
    UITextField * alertTextField1;
    CGSize contentSize;
    MBProgressHUD * hud1;
    NSString *Titlename1,*NameSearch;
    UIRefreshControl * refreshControl;
    UIImageView *star0,*star1,*star2,*star3,*star4,*star5;
    UIImageView *btnStar5,*btnStar4,*btnStar3,*btnStar2,*btnStar1;
    UIView *viewRateView,*viewTITLe,*viewTemp,*viewSeparator;
}
@property (weak, nonatomic) IBOutlet UIWebView *web;
@property (nonatomic,strong) UITableView * table;
@end
@implementation ContentDetailController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestURL];
    UserDefault = [[NSUserDefaults standardUserDefaults]objectForKey:@"KEY"];
//Swipe to right
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
//check nonnection internet
    Reachability *reachTest = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [reachTest  currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){
        UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Không có kết nối Internet.Hãy bật WIFI hoặc 3G để ứng dụng hoạt động!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    hud1 = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    hud1.label.text = @"Chờ hiển thị bài viết...";
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"timkiem"]){
        Titlename1 = @"NỘI DUNG TÌM KIẾM";
        NameSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"nameSearch"];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"tintuc"] || [[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"dimiss"] ){
            [self loadPost];
            Titlename1 = @"QUAY LẠI";
            NameSearch = @" ";
        }
    }
        //create webview in here
        web1 = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height)];
        [self requestWebView:[[NSUserDefaults standardUserDefaults] objectForKey:@"TitlePost"] :NameSearch :[[NSUserDefaults standardUserDefaults] objectForKey:@"date"] :[[NSUserDefaults standardUserDefaults] objectForKey:@"content_post"]];
        [self itemBar];
        viewTITLe = [[UIView alloc]init];
        viewSeparator = [[UIView alloc]init];
        [self itemBar];
}
-(void)requestWebView:(NSString *)tittlePost :(NSString *)nameSearch :(NSString *)datePost :(NSString *)contentPost{
    NSString *s1 = contentPost;
    NSError *error;
    NSString *pattern, * pattern1,* pattern2;
    pattern = @"<iframe.*?src";
    pattern1 = @"src.*?www.youtube.com";
    pattern2 = @"11pt; line-height: 20.5333px;";
    NSRegularExpression *subString1,* subString2,*subString3;
    subString1 = [NSRegularExpression regularExpressionWithPattern:pattern
                                                           options:NSRegularExpressionCaseInsensitive
                                                             error:&error];
    subString2 = [NSRegularExpression regularExpressionWithPattern:pattern1
                                                           options:NSRegularExpressionCaseInsensitive
                                                             error:&error];
    subString3 = [NSRegularExpression regularExpressionWithPattern:pattern2
                                                           options:NSRegularExpressionCaseInsensitive
                                                             error:&error];
    
    NSString *contentPosts = [subString1 stringByReplacingMatchesInString:s1
                                                             options:0
                                                               range:NSMakeRange(0, [s1 length])
                                                        withTemplate:@"<iframe width=\"100%\" height=\"350\" src"];
    
    contentPosts = [subString2 stringByReplacingMatchesInString:contentPosts
                                                   options:0
                                                     range:NSMakeRange(0, [contentPosts length])
                                              withTemplate:@"src=\"https://www.youtube.com"];
    
    contentPosts = [contentPosts stringByReplacingOccurrencesOfString:@"11pt; line-height: 20.5333px;" withString:@"20pt"];
    contentPosts = [contentPosts stringByReplacingOccurrencesOfString:@"11pt" withString:@"20pt"];
    strForWebView = [NSString stringWithFormat:@"<html> \n"
                     "<head> \n"
                     "<style type=\"text/css\"> \n"
                     "body {font-family: \"%@\"; font-size: %@pt; height: auto;padding-top: 20;padding-left: 20; padding-right: 20}\n"
                     "div {text-align: left}\n"
                     "img{max-width:100%%;height:auto !important;display:block !important; margin:0 auto}</style>\n"
                     "</head>\n"
                     "<body >"
                     "<h2>%@</h2>"
                     "<div>%@ %@</div>"
                     "%@ </body> \n"
                     "</html>",@"helvetica", [NSNumber numberWithInt:20],
                     tittlePost,nameSearch,datePost,contentPosts];
    web1.scrollView.delegate = self;
    web1.delegate = self;
    [web1 loadHTMLString:strForWebView baseURL:[NSURL URLWithString:@"http://www.youtube.com/"]];
    [web1 setScalesPageToFit:YES];
    web1.autoresizesSubviews = YES;
    web1.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    web1.scrollView.scrollEnabled = false;
    web1.scrollView.delegate = self;
    web1.scrollView.frame = web1.frame;
    [_myContentSize addSubview:web1];
    [self itemBar];
}
/** không cho link mở bằng UIWebView , phải mở bằng Safari.*/
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:
(NSURLRequest *)request navigationType:(UIWebViewNavigationType)
navigationType;
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked ){
        [[UIApplication sharedApplication]openURL:request.URL];
        return false;
    }
    return true;
}
//event swipeToRight
-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        [UIView animateWithDuration:0.3 animations:^{
            CGPoint Position = CGPointMake(self.view.frame.origin.x + 100.0, self.view.frame.origin.y);
            self.view.frame = CGRectMake(Position.x , Position.y , self.view.bounds.size.width, self.view.bounds.size.height);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}
//INITIALIZATION BARBUTTON
-(void)itemBar{
    UIButton *btn_back =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [btn_back setFrame:CGRectMake(0, 0, 20, 20)];
    
    UIButton *btn_commemt =  [UIButton buttonWithType:UIButtonTypeCustom];
    NSString * comment_c =[[NSUserDefaults standardUserDefaults]valueForKey:@"comment_count"];
    [btn_commemt setImage:[UIImage imageNamed:@"comment_60"] forState:UIControlStateNormal];
    [btn_commemt setFrame:CGRectMake(0, 0, 25, 25)];
    UILabel *lbl_Title1 = [[UILabel alloc]init];
    lbl_Title1.frame = CGRectMake(0, 5, 25, 10);
    lbl_Title1.text = comment_c;
    [lbl_Title1 setTextAlignment:NSTextAlignmentCenter];
    lbl_Title1.textColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
    [lbl_Title1 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
    [btn_commemt addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [btn_commemt addSubview:lbl_Title1];
    UIBarButtonItem *Bar_btnComment = [[UIBarButtonItem alloc] initWithCustomView:btn_commemt];
    self.navigationItem.rightBarButtonItem=Bar_btnComment;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"timkiem"]){
        [btn_back addTarget:self action:@selector(backButtonTimKiem:) forControlEvents:UIControlEventTouchUpInside];
        [btn_commemt setHidden:YES];
    }
    else
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"tintuc"]){
            [btn_back addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"dimiss"]){
        [btn_back addTarget:self action:@selector(backButtonDmiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn_back];

    UILabel *lbl_Title = [[UILabel alloc]init];
    lbl_Title.frame = CGRectMake(0, 0, 300, 20);
    lbl_Title.text = Titlename1;
    [lbl_Title setTextAlignment:NSTextAlignmentLeft];
    lbl_Title.textColor = [UIColor whiteColor];
    [lbl_Title setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    UIBarButtonItem *menuItemButton= [[UIBarButtonItem alloc] initWithCustomView:lbl_Title];
    NSArray *arrayButtonLeft= [[NSArray alloc] initWithObjects:barButton,menuItemButton, nil];
    self.navigationItem.leftBarButtonItems=arrayButtonLeft;
    
}
-(void)backButton:(UIButton *)sender{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"KEY"] isEqualToString:@"tintuc"]){
       [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
-(void)backButtonDmiss:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//GET JSON
-(NSMutableArray *)loadPost{
        myObject = [[NSMutableArray alloc]init];
        NSString* urlString;
        NSError * error = nil;
        urlString = [NSString  stringWithFormat:LINK];
        NSString *urltextEscaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL*url = [NSURL URLWithString:urltextEscaped];
        NSData * data=[NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if(data == nil){
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else {
            NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &error];
            titles = @"Title_detailView";
            images = @"Image_detailView";
            content = @"content_detailView";
            postDate = @"postDate_detailView";
            NID = @"nnid_detailView";
            view = @"view_detailView";
            comment_count = @"comment_detailView";
            for(NSDictionary * dict in json[@"list"])
            {
                @try {
                    NSArray *images_temp;
                    NSString *url_images;
                    NSArray *image_temp;
                    //GET TTTLE.
                    NSString *title_temp = [dict valueForKey:@"title"];
                    images_temp = [dict valueForKey:@"field_tin_tuc_hinh_dai_dien"];
                    if(images_temp.count == 0){
                        // break;
                    }else{
                        //GET IMAGE.
                        images_temp = [dict valueForKey:@"field_tin_tuc_hinh_dai_dien"][@"file"][@"uri"];
                        url_images = [NSString stringWithFormat:@"%@.json",images_temp];
                        NSError * error_thumnail;
                        NSURL*url_getThumnail = [NSURL URLWithString:url_images];
                        NSData * data_thumnail=[NSData dataWithContentsOfURL:url_getThumnail];
                        NSMutableDictionary  * json_thumnail = [NSJSONSerialization JSONObjectWithData:data_thumnail options: NSJSONReadingMutableContainers error: &error_thumnail];
                        image_temp = json_thumnail[@"url"];
                    }
                    int Nid = [[dict objectForKey:@"nid"] intValue];
                    NSString *IDD=[NSString stringWithFormat:@"%d",Nid];

                    int cmt = [[dict objectForKey:@"comment_count"]intValue];
                    NSString *cmt_count = [NSString stringWithFormat:@"%d",cmt];
                    
                    int viewValue = [[dict objectForKey:@"views"]intValue];
                    NSString *View = [NSString stringWithFormat:@"%d",viewValue];
                    
                    NSString *bodyContent;
                    NSArray * body = [dict valueForKey:@"body"];
                    if(body.count < 3){
                        bodyContent = @"Không có nội dung cho bài viết này";
                    }
                    else {
                        bodyContent = [dict valueForKey:@"body"][@"value"];
                    }
                    int secondsLeft = [[dict objectForKey:@"created"] intValue];
                    NSString *formattedDateString;
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEEE, dd'/'MM'/'YYYY"];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsLeft];
                    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
                    formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
                    
                    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                    nid = [defaults valueForKey:@"nid"];
                    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                  title_temp,titles,
                                  bodyContent,content,
                                  formattedDateString,postDate,
                                  image_temp,images,
                                  View,view,
                                  IDD,NID,
                                  cmt_count,comment_count,
                                  nil];
                    if ([[dictionary objectForKeyedSubscript:NID] isEqualToString:nid]){
                        dictionary = NULL;
                    }
                    [myObject addObject:dictionary];
                }
                @catch (NSException *exception) {
                    NSLog(@" ẩn 1 tin thiếu %@ ",exception);
                }
            }
        }
    return  myObject;
}
 // UP VIEW COUNT
-(void) requestURL{
    NSString *url_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"linkview"];
    NSString *url_email = [NSString stringWithFormat:@"%@",url_view];
    NSError * error_email;
    NSURL*url_getEmail = [NSURL URLWithString:url_email];
    NSData * data_email=[NSData dataWithContentsOfURL:url_getEmail];
    [NSJSONSerialization JSONObjectWithData:data_email options: NSJSONReadingMutableContainers error: &error_email];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [hud1 showAnimated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //method resize height webview
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    //on Top scroll;
     CGPoint top = CGPointMake(0, 0);
    [_myContentSize setContentOffset:top];
    [self viewsInsert];
    [hud1 hideAnimated:YES];
}
-(void)viewsInsert{
         contentSize = web1.scrollView.contentSize;
         CGRect mWebViewFrame = web1.bounds;
         mWebViewFrame.size.height = contentSize.height;
         web1.frame = mWebViewFrame;
         web1.contentMode = UIViewContentModeScaleAspectFit;
    if([UserDefault isEqualToString:@"tintuc"]||[UserDefault isEqualToString:@"dimiss"]){
        
        viewRateView = [[UIView alloc]initWithFrame:CGRectMake(0, contentSize.height, self.view.frame.size.width, 40)];
        viewRateView.backgroundColor = [UIColor whiteColor];
//get star
        star0 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star0-60"]];
        star0.frame = CGRectMake(self.view.frame.size.width - 140, 10, 18, 18);
        [star1 setContentMode:UIViewContentModeScaleAspectFit];
        [star0 setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap0 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar0:)];
        [singleTap0 setNumberOfTapsRequired:1];
        [star0 addGestureRecognizer:singleTap0];
        [viewRateView addSubview:star0];
        
        NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
        NSUInteger likeNumber = [self getLikeForNode:idNews];
        if(likeNumber == 0){
            star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
            star1.frame = CGRectMake(self.view.frame.size.width - 110, 10, 18, 18);
            [star1 setContentMode:UIViewContentModeScaleAspectFit];
            [star1 setUserInteractionEnabled:YES];
            UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar1:)];
            [singleTap setNumberOfTapsRequired:1];
            [star1 addGestureRecognizer:singleTap];
            [viewRateView addSubview:star1];
            
            star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
            star2.frame = CGRectMake(self.view.frame.size.width - 90, 10, 18, 18);
            [star2 setContentMode:UIViewContentModeScaleAspectFit];
            [star2 setUserInteractionEnabled:YES];
            UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar2:)];
            [singleTap2 setNumberOfTapsRequired:1];
            [star2 addGestureRecognizer:singleTap2];
            [viewRateView addSubview:star2];
            
            star3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
            star3.frame = CGRectMake(self.view.frame.size.width - 70, 10, 18, 18);
            [star3 setContentMode:UIViewContentModeScaleAspectFit];
            [star3 setUserInteractionEnabled:YES];
            UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar3:)];
            [singleTap3 setNumberOfTapsRequired:1];
            [star3 addGestureRecognizer:singleTap3];
            [viewRateView addSubview:star3];
            
            star4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
            star4.frame = CGRectMake(self.view.frame.size.width - 50, 10, 18, 18);
            [star4 setContentMode:UIViewContentModeScaleAspectFit];
            [star4 setUserInteractionEnabled:YES];
            UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar4:)];
            [singleTap4 setNumberOfTapsRequired:1];
            [star4 addGestureRecognizer:singleTap4];
            [viewRateView addSubview:star4];
            
            star5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
            star5.frame = CGRectMake(self.view.frame.size.width - 30, 10, 18, 18);
            [star5 setContentMode:UIViewContentModeScaleAspectFit];
            [star5 setUserInteractionEnabled:YES];
            UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar5:)];
            [singleTap5 setNumberOfTapsRequired:1];
            [star5 addGestureRecognizer:singleTap5];
            [viewRateView addSubview:star5];

            }else if(likeNumber > 0 && likeNumber <= 20){
                star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                star1.frame = CGRectMake(self.view.frame.size.width - 110, 10, 18, 18);
                [star1 setContentMode:UIViewContentModeScaleAspectFit];
                [star1 setUserInteractionEnabled:YES];
                UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar1:)];
                [singleTap setNumberOfTapsRequired:1];
                [star1 addGestureRecognizer:singleTap];
                [viewRateView addSubview:star1];
                
                star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                star2.frame = CGRectMake(self.view.frame.size.width - 90, 10, 18, 18);
                [star2 setContentMode:UIViewContentModeScaleAspectFit];
                [star2 setUserInteractionEnabled:YES];
                UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar2:)];
                [singleTap2 setNumberOfTapsRequired:1];
                [star2 addGestureRecognizer:singleTap2];
                [viewRateView addSubview:star2];
                
                star3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                star3.frame = CGRectMake(self.view.frame.size.width - 70, 10, 18, 18);
                [star3 setContentMode:UIViewContentModeScaleAspectFit];
                [star3 setUserInteractionEnabled:YES];
                UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar3:)];
                [singleTap3 setNumberOfTapsRequired:1];
                [star3 addGestureRecognizer:singleTap3];
                [viewRateView addSubview:star3];
                
                star4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                star4.frame = CGRectMake(self.view.frame.size.width - 50, 10, 18, 18);
                [star4 setContentMode:UIViewContentModeScaleAspectFit];
                [star4 setUserInteractionEnabled:YES];
                UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar4:)];
                [singleTap4 setNumberOfTapsRequired:1];
                [star4 addGestureRecognizer:singleTap4];
                [viewRateView addSubview:star4];
                
                star5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                star5.frame = CGRectMake(self.view.frame.size.width - 30, 10, 18, 18);
                [star5 setContentMode:UIViewContentModeScaleAspectFit];
                [star5 setUserInteractionEnabled:YES];
                UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar5:)];
                [singleTap5 setNumberOfTapsRequired:1];
                [star5 addGestureRecognizer:singleTap5];
                [viewRateView addSubview:star5];

                    }else if(likeNumber > 20 && likeNumber <= 40){
                        star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                        star1.frame = CGRectMake(self.view.frame.size.width - 110, 10, 18, 18);
                        [star1 setContentMode:UIViewContentModeScaleAspectFit];
                        [star1 setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar1:)];
                        [singleTap setNumberOfTapsRequired:1];
                        [star1 addGestureRecognizer:singleTap];
                        [viewRateView addSubview:star1];
                        
                        star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                        star2.frame = CGRectMake(self.view.frame.size.width - 90, 10, 18, 18);
                        [star2 setContentMode:UIViewContentModeScaleAspectFit];
                        [star2 setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar2:)];
                        [singleTap2 setNumberOfTapsRequired:1];
                        [star2 addGestureRecognizer:singleTap2];
                        [viewRateView addSubview:star2];
                        
                        star3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                        star3.frame = CGRectMake(self.view.frame.size.width - 70, 10, 18, 18);
                        [star3 setContentMode:UIViewContentModeScaleAspectFit];
                        [star3 setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar3:)];
                        [singleTap3 setNumberOfTapsRequired:1];
                        [star3 addGestureRecognizer:singleTap3];
                        [viewRateView addSubview:star3];
                        
                        star4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                        star4.frame = CGRectMake(self.view.frame.size.width - 50, 10, 18, 18);
                        [star4 setContentMode:UIViewContentModeScaleAspectFit];
                        [star4 setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar4:)];
                        [singleTap4 setNumberOfTapsRequired:1];
                        [star4 addGestureRecognizer:singleTap4];
                        [viewRateView addSubview:star4];
                        
                        star5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                        star5.frame = CGRectMake(self.view.frame.size.width - 30, 10, 18, 18);
                        [star5 setContentMode:UIViewContentModeScaleAspectFit];
                        [star5 setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar5:)];
                        [singleTap5 setNumberOfTapsRequired:1];
                        [star5 addGestureRecognizer:singleTap5];
                        [viewRateView addSubview:star5];

                        }else if(likeNumber > 40 && likeNumber <= 60){
                            star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                            star1.frame = CGRectMake(self.view.frame.size.width - 110, 10, 18, 18);
                            [star1 setContentMode:UIViewContentModeScaleAspectFit];
                            [star1 setUserInteractionEnabled:YES];
                            UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar1:)];
                            [singleTap setNumberOfTapsRequired:1];
                            [star1 addGestureRecognizer:singleTap];
                            [viewRateView addSubview:star1];
                            
                            star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                            star2.frame = CGRectMake(self.view.frame.size.width - 90, 10, 18, 18);
                            [star2 setContentMode:UIViewContentModeScaleAspectFit];
                            [star2 setUserInteractionEnabled:YES];
                            UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar2:)];
                            [singleTap2 setNumberOfTapsRequired:1];
                            [star2 addGestureRecognizer:singleTap2];
                            [viewRateView addSubview:star2];
                            
                            star3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                            star3.frame = CGRectMake(self.view.frame.size.width - 70, 10, 18, 18);
                            [star3 setContentMode:UIViewContentModeScaleAspectFit];
                            [star3 setUserInteractionEnabled:YES];
                            UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar3:)];
                            [singleTap3 setNumberOfTapsRequired:1];
                            [star3 addGestureRecognizer:singleTap3];
                            [viewRateView addSubview:star3];
                            
                            star4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                            star4.frame = CGRectMake(self.view.frame.size.width - 50, 10, 18, 18);
                            [star4 setContentMode:UIViewContentModeScaleAspectFit];
                            [star4 setUserInteractionEnabled:YES];
                            UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar4:)];
                            [singleTap4 setNumberOfTapsRequired:1];
                            [star4 addGestureRecognizer:singleTap4];
                            [viewRateView addSubview:star4];
                            
                            star5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                            star5.frame = CGRectMake(self.view.frame.size.width - 30, 10, 18, 18);
                            [star5 setContentMode:UIViewContentModeScaleAspectFit];
                            [star5 setUserInteractionEnabled:YES];
                            UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar5:)];
                            [singleTap5 setNumberOfTapsRequired:1];
                            [star5 addGestureRecognizer:singleTap5];
                            [viewRateView addSubview:star5];

                            }else if(likeNumber > 60 && likeNumber <= 80){
                                star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                star1.frame = CGRectMake(self.view.frame.size.width - 110, 10, 18, 18);
                                [star1 setContentMode:UIViewContentModeScaleAspectFit];
                                [star1 setUserInteractionEnabled:YES];
                                UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar1:)];
                                [singleTap setNumberOfTapsRequired:1];
                                [star1 addGestureRecognizer:singleTap];
                                [viewRateView addSubview:star1];
                                
                                star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                star2.frame = CGRectMake(self.view.frame.size.width - 90, 10, 18, 18);
                                [star2 setContentMode:UIViewContentModeScaleAspectFit];
                                [star2 setUserInteractionEnabled:YES];
                                UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar2:)];
                                [singleTap2 setNumberOfTapsRequired:1];
                                [star2 addGestureRecognizer:singleTap2];
                                [viewRateView addSubview:star2];
                                
                                star3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                star3.frame = CGRectMake(self.view.frame.size.width - 70, 10, 18, 18);
                                [star3 setContentMode:UIViewContentModeScaleAspectFit];
                                [star3 setUserInteractionEnabled:YES];
                                UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar3:)];
                                [singleTap3 setNumberOfTapsRequired:1];
                                [star3 addGestureRecognizer:singleTap3];
                                [viewRateView addSubview:star3];
                                
                                star4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                star4.frame = CGRectMake(self.view.frame.size.width - 50, 10, 18, 18);
                                [star4 setContentMode:UIViewContentModeScaleAspectFit];
                                [star4 setUserInteractionEnabled:YES];
                                UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar4:)];
                                [singleTap4 setNumberOfTapsRequired:1];
                                [star4 addGestureRecognizer:singleTap4];
                                [viewRateView addSubview:star4];
                                
                                star5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_gray_60"]];
                                star5.frame = CGRectMake(self.view.frame.size.width - 30, 10, 18, 18);
                                [star5 setContentMode:UIViewContentModeScaleAspectFit];
                                [star5 setUserInteractionEnabled:YES];
                                UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar5:)];
                                [singleTap5 setNumberOfTapsRequired:1];
                                [star5 addGestureRecognizer:singleTap5];
                                [viewRateView addSubview:star5];

                                }else if(likeNumber > 80 && likeNumber <=100){
                                    star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                    star1.frame = CGRectMake(self.view.frame.size.width - 110, 10, 18, 18);
                                    [star1 setContentMode:UIViewContentModeScaleAspectFit];
                                    [star1 setUserInteractionEnabled:YES];
                                    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar1:)];
                                    [singleTap setNumberOfTapsRequired:1];
                                    [star1 addGestureRecognizer:singleTap];
                                    [viewRateView addSubview:star1];
                                    
                                    star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                    star2.frame = CGRectMake(self.view.frame.size.width - 90, 10, 18, 18);
                                    [star2 setContentMode:UIViewContentModeScaleAspectFit];
                                    [star2 setUserInteractionEnabled:YES];
                                    UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar2:)];
                                    [singleTap2 setNumberOfTapsRequired:1];
                                    [star2 addGestureRecognizer:singleTap2];
                                    [viewRateView addSubview:star2];
                                    
                                    star3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                    star3.frame = CGRectMake(self.view.frame.size.width - 70, 10, 18, 18);
                                    [star3 setContentMode:UIViewContentModeScaleAspectFit];
                                    [star3 setUserInteractionEnabled:YES];
                                    UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar3:)];
                                    [singleTap3 setNumberOfTapsRequired:1];
                                    [star3 addGestureRecognizer:singleTap3];
                                    [viewRateView addSubview:star3];
                                    
                                    star4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                    star4.frame = CGRectMake(self.view.frame.size.width - 50, 10, 18, 18);
                                    [star4 setContentMode:UIViewContentModeScaleAspectFit];
                                    [star4 setUserInteractionEnabled:YES];
                                    UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar4:)];
                                    [singleTap4 setNumberOfTapsRequired:1];
                                    [star4 addGestureRecognizer:singleTap4];
                                    [viewRateView addSubview:star4];
                                    
                                    star5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_60"]];
                                    star5.frame = CGRectMake(self.view.frame.size.width - 30, 10, 18, 18);
                                    [star5 setContentMode:UIViewContentModeScaleAspectFit];
                                    [star5 setUserInteractionEnabled:YES];
                                    UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateStar5:)];
                                    [singleTap5 setNumberOfTapsRequired:1];
                                    [star5 addGestureRecognizer:singleTap5];
                                    [viewRateView addSubview:star5];
                                    }
        NSUserDefaults *defaults1=[NSUserDefaults standardUserDefaults];
        UILabel * views = [[UILabel alloc]initWithFrame:CGRectMake(90, 10, 30, 18)];
        views.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
        views.textAlignment = NSTextAlignmentLeft;
        views.text = [defaults1 valueForKey:@"viewtr"];
        [viewRateView addSubview:views];
        
        UILabel * luotxem = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 80, 18)];
        luotxem.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        luotxem.text = @"SỐ LƯỢT XEM";
        luotxem.textAlignment = NSTextAlignmentLeft;
        [viewRateView addSubview:luotxem];
        
        [_myContentSize addSubview:viewRateView];
        
        viewSeparator = [[UIView alloc]initWithFrame:CGRectMake(0, contentSize.height+40, self.view.frame.size.width, 5)];
        viewSeparator.backgroundColor = [UIColor colorWithRed:0.992 green:0.725 blue:0.157 alpha:1.00];
        [_myContentSize addSubview:viewSeparator];
        
        viewTITLe = [[UIView alloc]initWithFrame:CGRectMake(0, contentSize.height+45, self.view.frame.size.width, 480)];
        viewTITLe.backgroundColor = [UIColor blackColor];
        
        self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, viewTITLe.frame.size.width, viewTITLe.frame.size.height) style:UITableViewStyleGrouped];
        self.table.delegate = self;
        self.table.dataSource = self;
        self.table.sectionHeaderHeight = 6;
        self.table.sectionFooterHeight = 1;
        self.table.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00];
        self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.table.scrollEnabled = NO;
        [self.table registerNib:[UINib nibWithNibName:@"CellContent" bundle:nil] forCellReuseIdentifier:@"CellC"];
        [viewTITLe addSubview:self.table];
        [_myContentSize addSubview:viewTITLe];
        [_myContentSize addSubview:viewRateView];
             _myContentSize.contentSize = CGSizeMake(self.view.bounds.size.width, viewSeparator.bounds.size.height + viewTITLe.bounds.size.height + viewRateView.bounds.size.height + web1.bounds.size.height);
    }
    else {
             _myContentSize.contentSize = CGSizeMake(self.view.frame.size.width, web1.frame.size.height);
    }
}
-(void)alertChooseLike{
    alertControllerLike = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertControllerLike.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    
    /*Chỉnh màu cho alert*/
    UIView *subView = alertControllerLike.view.subviews.firstObject;
    UIView *alertContentView = subView.subviews.firstObject;
    [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];

    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 40)];
    customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
    
    UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(15, 7, 100, 25)];
    lblAlert.text = @"BÌNH CHỌN";
    lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    lblAlert.textColor = [UIColor whiteColor];
    [customView addSubview:lblAlert];
    
    UIImageView *DeleteBox = [[UIImageView alloc]initWithFrame:CGRectMake(240, 10, 15, 15)];
    DeleteBox.image = [UIImage imageNamed:@"close"];
    UITapGestureRecognizer * eventClose = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(eventClose:)];
    [DeleteBox addGestureRecognizer:eventClose];
    [DeleteBox setUserInteractionEnabled:YES];
    [customView addSubview:DeleteBox];
    [alertControllerLike.view addSubview:customView];

    UIView * lineStar5 = [[UIView alloc]initWithFrame:CGRectMake(15, 55, 240, 30)];
    UIImageView * imgStar5 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 100, 20)];
    imgStar5.image = [UIImage imageNamed:@"star_5"];
    imgStar5.contentMode = UIViewContentModeScaleAspectFit;
    [lineStar5 addSubview:imgStar5];
    btnStar5 = [[UIImageView alloc]initWithFrame:CGRectMake(220, 5, 20, 20)];
    btnStar5.image = [UIImage imageNamed:@"un_check"];
    btnStar5.layer.masksToBounds = YES;
    btnStar5.layer.cornerRadius = 10;
    [lineStar5 addSubview:btnStar5];
    UITapGestureRecognizer *eventTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapLine5:)];
    [lineStar5 addGestureRecognizer:eventTap5];
    [lineStar5 setUserInteractionEnabled:YES];
    [alertControllerLike.view addSubview:lineStar5];
    
    UIView * lineStar4 = [[UIView alloc]initWithFrame:CGRectMake(15, 85, 240, 30)];
    UIImageView * imgStar4 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 100, 20)];
    imgStar4.image = [UIImage imageNamed:@"star_4"];
    [lineStar4 addSubview:imgStar4];
    btnStar4 = [[UIImageView alloc]initWithFrame:CGRectMake(220, 5, 20, 20)];
    btnStar4.image = [UIImage imageNamed:@"un_check"];
    btnStar4.layer.masksToBounds = YES;
    btnStar4.layer.cornerRadius = 11;
    [lineStar4 addSubview:btnStar4];
    UITapGestureRecognizer *eventTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapLine4:)];
    [lineStar4 addGestureRecognizer:eventTap4];
    [alertControllerLike.view addSubview:lineStar4];
    
    UIView * lineStar3 = [[UIView alloc]initWithFrame:CGRectMake(15, 115, 240, 30)];
    UIImageView * imgStar3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 100, 20)];
    imgStar3.image = [UIImage imageNamed:@"star_3"];
    [lineStar3 addSubview:imgStar3];
    btnStar3 = [[UIImageView alloc]initWithFrame:CGRectMake(220, 5, 20, 20)];
    btnStar3.image = [UIImage imageNamed:@"un_check"];
    btnStar3.layer.masksToBounds = YES;
    btnStar3.layer.cornerRadius = 11;
    [lineStar3 addSubview:btnStar3];
    UITapGestureRecognizer *eventTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapLine3:)];
    [lineStar3 addGestureRecognizer:eventTap3];
    [alertControllerLike.view addSubview:lineStar3];
    
    UIView * lineStar2 = [[UIView alloc]initWithFrame:CGRectMake(15, 145, 240, 30)];
    UIImageView * imgStar2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 100, 20)];
    imgStar2.image = [UIImage imageNamed:@"star_2"];
    [lineStar2 addSubview:imgStar2];
    btnStar2 = [[UIImageView alloc]initWithFrame:CGRectMake(220, 5, 20, 20)];
    btnStar2.image = [UIImage imageNamed:@"un_check"];
    btnStar2.layer.masksToBounds = YES;
    btnStar2.layer.cornerRadius = 11;
    [lineStar2 addSubview:btnStar2];
    UITapGestureRecognizer *eventTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapLine2:)];
    [lineStar2 addGestureRecognizer:eventTap2];
    [alertControllerLike.view addSubview:lineStar2];
    
    UIView * lineStar1 = [[UIView alloc]initWithFrame:CGRectMake(15, 175, 240, 30)];
    UIImageView * imgStar1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 100, 20)];
    imgStar1.image = [UIImage imageNamed:@"star_1"];
    [lineStar1 addSubview:imgStar1];
    btnStar1 = [[UIImageView alloc]initWithFrame:CGRectMake(220, 5, 20, 20)];
    btnStar1.image = [UIImage imageNamed:@"un_check"];
    btnStar1.layer.masksToBounds = YES;
    btnStar1.layer.cornerRadius = 11;
    [lineStar1 addSubview:btnStar1];
    UITapGestureRecognizer *eventTap1 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapLine1:)];
    [lineStar1 addGestureRecognizer:eventTap1];
    [alertControllerLike.view addSubview:lineStar1];
    
    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertControllerLike dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Xác nhận" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
        NSString *str = [de valueForKey:@"value"];
        
        NSString *idNews = [de objectForKey:@"nidd"];
        [self setLikeForNode:idNews :str];
        [self viewsInsert];
        [self alertController];
        
    }];
    [alertControllerLike addAction:somethingAction];
    [alertControllerLike addAction:cancelAction];
    [self presentViewController:alertControllerLike animated:YES completion:^{}];
}
-(void)alertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 40)];
    customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
    
    UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(90, 5, 100, 25)];
    lblAlert.text = @"Thông báo";
    lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    lblAlert.textColor = [UIColor whiteColor];
    [customView addSubview:lblAlert];
    /*Chỉnh màu cho alert*/
    UIView *subView = alertController.view.subviews.firstObject;
    UIView *alertContentView = subView.subviews.firstObject;
    [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];
    UILabel * lblContentAlert = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 250, 50)];
    lblContentAlert.text = @"Bạn vừa vote thành công cho bài viết!";
    lblContentAlert.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblContentAlert.numberOfLines = 1;
    lblContentAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
    [alertController.view addSubview:lblContentAlert];
    [alertController.view addSubview:customView];
    
    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:somethingAction];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}
-(void)rateStar0:(UIGestureRecognizer *)recognizer {
    NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    [self setLikeForNode:idNews :@"0"];
    [self alertController];
    [self viewsInsert];
}
-(void)rateStar1:(UIGestureRecognizer *)recognizer {
    [self alertChooseLike];
}
-(void)rateStar2:(UIGestureRecognizer *)recognizer {
    [self alertChooseLike];
}
-(void)rateStar3:(UIGestureRecognizer *)recognizer {
    [self alertChooseLike];
}
-(void)rateStar4:(UIGestureRecognizer *)recognizer {
    [self alertChooseLike];
}
-(void)rateStar5:(UIGestureRecognizer *)recognizer {
    [self alertChooseLike];
}
BOOL check;
-(void)eventTapLine5:(UIGestureRecognizer *)recognizer {
    btnStar5.image = [UIImage imageNamed:@"check"];
    btnStar4.image = [UIImage imageNamed:@"un_check"];
    btnStar3.image = [UIImage imageNamed:@"un_check"];
    btnStar2.image = [UIImage imageNamed:@"un_check"];
    btnStar1.image = [UIImage imageNamed:@"un_check"];
    NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString * str80 = @"100";
    NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
    [de setObject:str80 forKey:@"value"];
    [de setObject:idNews forKey:@"nidd"];
    [de synchronize];
}
-(void)eventTapLine4:(UIGestureRecognizer *)recognizer {
    btnStar5.image = [UIImage imageNamed:@"un_check"];
    btnStar4.image = [UIImage imageNamed:@"check"];
    btnStar3.image = [UIImage imageNamed:@"un_check"];
    btnStar2.image = [UIImage imageNamed:@"un_check"];
    btnStar1.image = [UIImage imageNamed:@"un_check"];
    NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString * str80 = @"80";
    NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
    [de setObject:str80 forKey:@"value"];
    [de setObject:idNews forKey:@"nidd"];
    [de synchronize];
}
-(void)eventTapLine3:(UIGestureRecognizer *)recognizer {
    btnStar5.image = [UIImage imageNamed:@"un_check"];
    btnStar4.image = [UIImage imageNamed:@"un_check"];
    btnStar3.image = [UIImage imageNamed:@"check"];
    btnStar2.image = [UIImage imageNamed:@"un_check"];
    btnStar1.image = [UIImage imageNamed:@"un_check"];
    NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString * str80 = @"60";
    NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
    [de setObject:str80 forKey:@"value"];
    [de setObject:idNews forKey:@"nidd"];
    [de synchronize];
}
-(void)eventTapLine2:(UIGestureRecognizer *)recognizer {
    btnStar5.image = [UIImage imageNamed:@"un_check"];
    btnStar4.image = [UIImage imageNamed:@"un_check"];
    btnStar3.image = [UIImage imageNamed:@"un_check"];
    btnStar2.image = [UIImage imageNamed:@"check"];
    btnStar1.image = [UIImage imageNamed:@"un_check"];
    NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString * str80 = @"40";
    NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
    [de setObject:str80 forKey:@"value"];
    [de setObject:idNews forKey:@"nidd"];
    [de synchronize];
}
-(void)eventTapLine1:(UIGestureRecognizer *)recognizer {
    btnStar5.image = [UIImage imageNamed:@"un_check"];
    btnStar4.image = [UIImage imageNamed:@"un_check"];
    btnStar3.image = [UIImage imageNamed:@"un_check"];
    btnStar2.image = [UIImage imageNamed:@"un_check"];
    btnStar1.image = [UIImage imageNamed:@"check"];
    NSString *idNews = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString * str80 = @"20";
    NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
    [de setObject:str80 forKey:@"value"];
    [de setObject:idNews forKey:@"nidd"];
    [de synchronize];
}
-(void)eventClose:(UIGestureRecognizer *)recognizer {
   [alertControllerLike dismissViewControllerAnimated:YES completion:nil];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 40 ;
    }
    return 6 ;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *ViewContentHeader;
    if(section == 0){
        ViewContentHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.table.frame.size.width,30)];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 20)];
        label.text = @"BÀI VIẾT MỚI NHẤT";
        label.textColor = [UIColor colorWithRed:0.235 green:0.314 blue:0.349 alpha:1.00];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        [ViewContentHeader addSubview:label];
    }
    return ViewContentHeader;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellContentCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"CellC" forIndexPath:indexPath];
    if(Cell == nil){
        Cell = [[CellContentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellC"];
    }
    NSDictionary *tmpDict= [myObject objectAtIndex:indexPath.section];
    Cell.lableTitle.text =[tmpDict objectForKeyedSubscript:titles];
    [Cell.imgContent sd_setImageWithURL:[tmpDict objectForKeyedSubscript:images] placeholderImage:[UIImage imageNamed:@"600x600"]];
    return Cell;
}
//edit here
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud.label.text = NSLocalizedString(@"Đang tải nội dung...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
    NSDictionary * tmp = [myObject objectAtIndex:indexPath.section];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[tmp objectForKeyedSubscript:titles] forKey:@"TitlePost"];
    [defaults setObject:[tmp objectForKeyedSubscript:content] forKey:@"content_post"];
    [defaults setObject:[tmp objectForKeyedSubscript:postDate] forKey:@"date"];
    [defaults setObject:[tmp objectForKeyedSubscript:view] forKey:@"viewtr"];
    [defaults setObject:[tmp objectForKeyedSubscript:loaitin] forKey:@"taxa"];
    [defaults setObject:[tmp objectForKeyedSubscript:NID] forKey:@"nid"];
    [defaults setObject:[tmp objectForKeyedSubscript:comment_count] forKey:@"comment_count"];
    [defaults synchronize];
    //request data and reload table
    [self requestWebView:[tmp objectForKeyedSubscript:titles] :@" " :[tmp objectForKeyedSubscript:postDate] :[tmp objectForKeyedSubscript:content]];
    [viewRateView removeFromSuperview];
    [myObject removeAllObjects];
    [self loadPost];
    [self.table reloadData];
    [hud hideAnimated:YES];
        });
    });
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [hud1 showAnimated:NO];
}
-(void)LoadCMTCountRefresh{
    NSArray *nId = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString *linkURL = [NSString stringWithFormat:LINK_CMT_COUNT1,nId];
    NSError * error = nil;
    NSURL * URL = [NSURL URLWithString:linkURL];
    NSData * data = [NSData dataWithContentsOfURL:URL options:0 error:&error];
    NSMutableDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    [[NSUserDefaults standardUserDefaults]setObject:json[@"comment_count"] forKey:@"comment_count"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)comment:(UIButton *)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud.label.text = NSLocalizedString(@"Đang tải bình luận..", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"cmt" sender:self];
            [hud hideAnimated:YES];
        });
    });
}
-(void)backButtonTimKiem:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//function get like
-(NSInteger )getLikeForNode:(NSString *)idNode{
    NSInteger numLike = 0;
    NSString *post =[[NSString alloc] initWithFormat:@"{\"type\":\"results\",\"criteria\":{\"entity_id\":\"%@\",\"entity_type\":\"node\",\"tag\":\"vote\"}}",idNode];
    NSURL *url=[NSURL URLWithString:LINK_GET_LIKE];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"X-CSRF-Token"];
    [request setHTTPBody:postData];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:urlData options: NSJSONReadingMutableContainers error: &error];
    for(NSDictionary *str in json){
        if([str[@"function"] isEqualToString:@"average"] && [str[@"value_type"] isEqualToString:@"percent"]){
            numLike = [str[@"value"] integerValue];
        }
        
    }
    return numLike;
}
//function set like
-(void )setLikeForNode:(NSString *)idNode :(NSString *)likes{
    NSString *post =[[NSString alloc] initWithFormat:@"\{\"votes\": [{\"entity_id\": %@,\"value_type\": \"percent\",\"tag\": \"vote\",\"value\": %@}]}",idNode,likes];
    NSURL *url=[NSURL URLWithString:LINK_SET_LIKE];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"X-CSRF-Token"];
    [request setHTTPBody:postData];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:urlData options: NSJSONReadingMutableContainers error: &error];
}

@end
