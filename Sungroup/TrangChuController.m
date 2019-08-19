//
//  TrangChuController.m
//  Sungroup
//
//  Created by DUY TAN on 18/3/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "TrangChuController.h"
#import "SWRevealViewController.h"
#import "NSString+HTML.h"
#import "UIScrollView+EmptyDataSet.h" // nếu table rỗng 21/6
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "new2TableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SSARefreshControl.h"
#define IS_IPHONE6PLUS (([[UIScreen mainScreen] bounds].size.width)==414.0f && ([[UIScreen mainScreen]  bounds].size.height)==736.0f)
#define IS_IPHONE6 (([[UIScreen mainScreen]bounds].size.width)==375.0f && ([[UIScreen mainScreen]bounds].size.height)==667.0f)
#define LINK @"https://cms.sungroup.com.vn/node.json?type=tin_tuc&status=1&sort=changed&direction=desc&limit=15&page=0"
#define LINK1 @"https://cms.sungroup.com.vn/node.json?type=tin_tuc&status=1&sort=changed&direction=desc&limit=15&page=%@"
@interface TrangChuController ()<UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,UIWebViewDelegate,UIScrollViewDelegate,SSARefreshControlDelegate>{
    NSMutableArray *arr_ObjectJson;
    NSDictionary const *dic_ObjectJson;
    NSString const *obj_title,*obj_Email,*obj_description,* obj_Images,*obj_Link,*obj_Postdate,*obj_View,*obj_Nid,*obj_Commentcount,*obj_IDComment;
    UIButton *btn_Top,*btn_head,*btn_prev,*btn_page1,*btn_page2,*btn_page3,*btn_page4,*btn_page5,*btn_next,*btn_last ;
    NSString *page_First,*page_last,*page_Current,*page_Next,*page_Prev;
    NSMutableDictionary const *json;
    NSString *totalView;
    UIView* view;
}
@property (nonatomic, strong) NSMutableString * resultStringg;
@property (nonatomic, strong) SSARefreshControl *refreshControl;
- (NSString *)convertEntiesInString:(NSString*)convertString;
@end
@implementation TrangChuController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view");
    //Initialization refresh controler;
    self.refreshControl = [[SSARefreshControl alloc] initWithScrollView:self.tableView andRefreshViewLayerType:SSARefreshViewLayerTypeOnScrollView];
    self.refreshControl.delegate = self;
    
    Reachability *reachTest = [Reachability reachabilityWithHostName:@"www.google.com"]; //Kiểm tra mạng
    NetworkStatus internetStatus = [reachTest  currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){
        UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Không có kết nối Internet.Hãy bật WIFI hoặc 3G để ứng dụng hoạt động!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:LINK];
        NSUserDefaults *de = [NSUserDefaults standardUserDefaults];
        [de setObject:urlString forKey:@"URLL"];
         [self loadData:urlString];
        if([page_last integerValue] == 1){
            [self resizeDistantButton:true:true:false:false:false];
        }
        else if([page_last integerValue] == 2){
            [self resizeDistantButton:true:true:true:false:false];
        }else if([page_last integerValue] == 3){
            [self resizeDistantButton:true:true:true:true:false];
        }
        else if([page_last integerValue] >= 4){
            [self resizeDistantButton:true:true:true:true:true];
        }
        [self interface];
        if([page_last integerValue] == 0){
            view.hidden = true;
        }
        else{
            view.hidden = false;
            _tableView.bounds = CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height-30);
        }
        if([[[btn_page3 titleLabel] text] integerValue] > [page_last integerValue]){
            btn_next.enabled = false;
        }else{
            btn_next.enabled = true;
        }
    }
    [self interface];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    //khai bao cell cho table
    [_tableView registerNib:[UINib nibWithNibName:@"News_TableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"news2" bundle:nil] forCellReuseIdentifier:@"cell1"];
}
- (void)beganRefreshing {
    [self loadDataSource];
}
- (void)loadDataSource {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
            NSString * urlString = [de valueForKey:@"URLL"];
            [self loadData:urlString];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
        
    });
}
//event appActived for refresh
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appActived:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
//event remove appActived for refresh
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//event appactived
-(void)appActived:(NSNotification*)note{
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud1.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud1.label.text = NSLocalizedString(@"Đang tải nội dung...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [hud1 hideAnimated:YES];
        });
    });
}

-(void)resizeDistantButton : (BOOL)button1 : (BOOL)button2 :(BOOL)button3 : (BOOL)button4 : (BOOL)button5{
    view = [[UIView alloc ]initWithFrame:CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 82, CGRectGetWidth(self.view.frame), 50)];
    view.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00];
    if(button1 == true && button2 == true && button3 == true && button4 == true && button5 == true){
        [self.view addSubview:view];
        
        btn_head = [[UIButton alloc] init];
        UIImage * imageHeadPress = [UIImage imageNamed:@"paging_icon_first"];
        [btn_head setBackgroundImage:imageHeadPress forState:UIControlStateNormal];
        [btn_head.heightAnchor constraintEqualToConstant:20].active=true;
        [btn_head.widthAnchor constraintEqualToConstant:20].active=true;
        [btn_head addTarget:self action:@selector(headPress_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_prev = [[UIButton alloc] init];
        UIImage *imagePrev = [UIImage imageNamed:@"prev"];
        [btn_prev setBackgroundImage:imagePrev forState:UIControlStateNormal];
        [btn_prev.heightAnchor constraintEqualToConstant:20].active=true;
        [btn_prev.widthAnchor constraintEqualToConstant:20].active=true;
        [btn_prev addTarget:self action:@selector(prevPress_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_page1 = [[UIButton alloc] init];
        [btn_page1 setTitle:@"1" forState:UIControlStateNormal];
        btn_page1.clipsToBounds = YES;
        btn_page1.layer.cornerRadius = 15;
        [btn_page1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page1.heightAnchor constraintEqualToConstant:30].active=true;
        [btn_page1.widthAnchor constraintEqualToConstant:30].active=true;
        [btn_page1 addTarget:self action:@selector(page1Press_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_page2 = [[UIButton alloc] init];
        [btn_page2 setTitle:@"2" forState:UIControlStateNormal];
        btn_page2.clipsToBounds = YES;
        btn_page2.layer.cornerRadius = 15;
        [btn_page2.heightAnchor constraintEqualToConstant:30].active=true;
        [btn_page2.widthAnchor constraintEqualToConstant:30].active=true;
        [btn_page2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page2 addTarget:self action:@selector(page2Press_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_page3 = [[UIButton alloc] init];
        [btn_page3.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page3 setTitle:@"3" forState:UIControlStateNormal];
        btn_page3.clipsToBounds = YES;
        btn_page3.layer.cornerRadius = 15;
        [btn_page3.heightAnchor constraintEqualToConstant:30].active=true;
        [btn_page3.widthAnchor constraintEqualToConstant:30].active=true;
        [btn_page3.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page3 addTarget:self action:@selector(page3Press_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_page4 = [[UIButton alloc] init];
        [btn_page4.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page4 setTitle:@"4" forState:UIControlStateNormal];
        btn_page4.clipsToBounds = YES;
        btn_page4.layer.cornerRadius = 15;
        [btn_page4.heightAnchor constraintEqualToConstant:30].active=true;
        [btn_page4.widthAnchor constraintEqualToConstant:30].active=true;
        [btn_page4.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page4 addTarget:self action:@selector(page4Press_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_page5 = [[UIButton alloc] init];
        [btn_page5.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page5 setTitle:@"5" forState:UIControlStateNormal];
        btn_page5.clipsToBounds = YES;
        btn_page5.layer.cornerRadius = 15;
        [btn_page5.heightAnchor constraintEqualToConstant:30].active=true;
        [btn_page5.widthAnchor constraintEqualToConstant:30].active=true;
        [btn_page5.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [btn_page5 addTarget:self action:@selector(page5Press_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_next = [[UIButton alloc] init];
        UIImage *imageNext = [UIImage imageNamed:@"next"];
        [btn_next setBackgroundImage:imageNext forState:UIControlStateNormal];
        [btn_next.heightAnchor constraintEqualToConstant:20].active=true;
        [btn_next.widthAnchor constraintEqualToConstant:20].active=true;
        [btn_next addTarget:self action:@selector(nextPress_Event:) forControlEvents:UIControlEventTouchUpInside];

        btn_last = [[UIButton alloc] init];
        UIImage *imagebtn_last = [UIImage imageNamed:@"paging_icon_last"];
        [btn_last setBackgroundImage:imagebtn_last forState:UIControlStateNormal];
        [btn_last.heightAnchor constraintEqualToConstant:20].active=true;
        [btn_last.widthAnchor constraintEqualToConstant:20].active=true;
        [btn_last addTarget:self action:@selector(lastPress_Event:) forControlEvents:UIControlEventTouchUpInside];
        UIStackView *stackViewRow0= [[UIStackView alloc]init];
        stackViewRow0.axis = UILayoutConstraintAxisHorizontal;
        stackViewRow0.distribution = UIStackViewDistributionEqualSpacing;
        stackViewRow0.alignment = UIStackViewAlignmentCenter;
        if( IS_IPHONE6PLUS || IS_IPHONE6){
            stackViewRow0.spacing = 15;
        }
        else {
            stackViewRow0.spacing = 5;
        }
        [stackViewRow0 addArrangedSubview:btn_head];
        [stackViewRow0 addArrangedSubview:btn_prev];
        [stackViewRow0 addArrangedSubview:btn_page1];
        [stackViewRow0 addArrangedSubview:btn_page2];
        [stackViewRow0 addArrangedSubview:btn_page3];
        [stackViewRow0 addArrangedSubview:btn_page4];
        [stackViewRow0 addArrangedSubview:btn_page5];
        [stackViewRow0 addArrangedSubview:btn_next];
        [stackViewRow0 addArrangedSubview:btn_last];
        stackViewRow0.translatesAutoresizingMaskIntoConstraints = false;
        [view addSubview:stackViewRow0];
        [stackViewRow0.centerXAnchor constraintEqualToAnchor:(view.centerXAnchor) constant:0].active = true;
        [stackViewRow0.centerYAnchor constraintEqualToAnchor:(view.centerYAnchor) constant:-5].active = true;
    }else
        if(button1 == true && button2 == true && button3 == true && button4 == true && button5 == false){
            [self.view addSubview:view];
            btn_head = [[UIButton alloc] init];
            UIImage * imageHeadPress = [UIImage imageNamed:@"paging_icon_first"];
            [btn_head setBackgroundImage:imageHeadPress forState:UIControlStateNormal];
            [btn_head.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_head.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_head addTarget:self action:@selector(headPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_prev = [[UIButton alloc] init];
            UIImage *imagePrev = [UIImage imageNamed:@"prev"];
            [btn_prev setBackgroundImage:imagePrev forState:UIControlStateNormal];
            [btn_prev.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_prev.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_prev addTarget:self action:@selector(prevPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page1 = [[UIButton alloc] init];
            [btn_page1 setTitle:@"1" forState:UIControlStateNormal];
            btn_page1.clipsToBounds = YES;
            btn_page1.layer.cornerRadius = 15;
            [btn_page1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page1.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page1.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page1 addTarget:self action:@selector(page1Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page2 = [[UIButton alloc] init];
            [btn_page2 setTitle:@"2" forState:UIControlStateNormal];
            btn_page2.clipsToBounds = YES;
            btn_page2.layer.cornerRadius = 15;
            [btn_page2.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page2.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page2 addTarget:self action:@selector(page2Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page3 = [[UIButton alloc] init];
            [btn_page3 setTitle:@"3" forState:UIControlStateNormal];
            btn_page3.clipsToBounds = YES;
            btn_page3.layer.cornerRadius = 15;
            [btn_page3.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page3.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page3.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page3 addTarget:self action:@selector(page3Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page4 = [[UIButton alloc] init];
            [btn_page4 setTitle:@"4" forState:UIControlStateNormal];
            btn_page4.clipsToBounds = YES;
            btn_page4.layer.cornerRadius = 15;
            [btn_page4.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page4.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page4.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page4 addTarget:self action:@selector(page4Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_next = [[UIButton alloc] init];
            UIImage *imageNext = [UIImage imageNamed:@"next"];
            [btn_next setBackgroundImage:imageNext forState:UIControlStateNormal];
            [btn_next.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_next.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_next addTarget:self action:@selector(nextPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_last = [[UIButton alloc] init];
            UIImage *imagebtn_last = [UIImage imageNamed:@"paging_icon_last"];
            [btn_last setBackgroundImage:imagebtn_last forState:UIControlStateNormal];
            [btn_last.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_last.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_last addTarget:self action:@selector(lastPress_Event:) forControlEvents:UIControlEventTouchUpInside];
            UIStackView *stackViewRow0= [[UIStackView alloc]init];
            stackViewRow0.axis = UILayoutConstraintAxisHorizontal;
            stackViewRow0.distribution = UIStackViewDistributionEqualSpacing;
            stackViewRow0.alignment = UIStackViewAlignmentCenter;
            if(IS_IPHONE6PLUS || IS_IPHONE6){
                stackViewRow0.spacing = 25;
                
            }
            else {
                stackViewRow0.spacing = 15;
            }
            [stackViewRow0 addArrangedSubview:btn_head];
            [stackViewRow0 addArrangedSubview:btn_prev];
            [stackViewRow0 addArrangedSubview:btn_page1];
            [stackViewRow0 addArrangedSubview:btn_page2];
            [stackViewRow0 addArrangedSubview:btn_page3];
            [stackViewRow0 addArrangedSubview:btn_page4];
            [stackViewRow0 addArrangedSubview:btn_next];
            [stackViewRow0 addArrangedSubview:btn_last];
            stackViewRow0.translatesAutoresizingMaskIntoConstraints = false;
            [view addSubview:stackViewRow0];
            [stackViewRow0.centerXAnchor constraintEqualToAnchor:(view.centerXAnchor) constant:0].active = true;
            [stackViewRow0.centerYAnchor constraintEqualToAnchor:(view.centerYAnchor) constant:-5].active = true;
        }
        else if(button1 == true && button2 == true && button3 == true && button4 == false && button5 == false){
            [self.view addSubview:view];
            btn_head = [[UIButton alloc] init];
            UIImage * imageHeadPress = [UIImage imageNamed:@"paging_icon_first"];
            [btn_head setBackgroundImage:imageHeadPress forState:UIControlStateNormal];
            [btn_head.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_head.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_head addTarget:self action:@selector(headPress_Event:) forControlEvents:UIControlEventTouchUpInside];            //button prev
            btn_prev = [[UIButton alloc] init];
            UIImage *imagePrev = [UIImage imageNamed:@"prev"];
            [btn_prev setBackgroundImage:imagePrev forState:UIControlStateNormal];
            [btn_prev.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_prev.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_prev addTarget:self action:@selector(prevPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page1 = [[UIButton alloc] init];
            [btn_page1 setTitle:@"1" forState:UIControlStateNormal];
            btn_page1.clipsToBounds = YES;
            btn_page1.layer.cornerRadius = 15;
            [btn_page1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page1.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page1.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page1 addTarget:self action:@selector(page1Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page2 = [[UIButton alloc] init];
            [btn_page2 setTitle:@"2" forState:UIControlStateNormal];
            btn_page2.clipsToBounds = YES;
            btn_page2.layer.cornerRadius = 15;
            [btn_page2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page2.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page2.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page2 addTarget:self action:@selector(page2Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page3 = [[UIButton alloc] init];
            [btn_page3 setTitle:@"3" forState:UIControlStateNormal];
            btn_page3.clipsToBounds = YES;
            btn_page3.layer.cornerRadius = 15;
            [btn_page3.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page3.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page3.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page3 addTarget:self action:@selector(page3Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_next = [[UIButton alloc] init];
            UIImage *imageNext = [UIImage imageNamed:@"next"];
            [btn_next setBackgroundImage:imageNext forState:UIControlStateNormal];
            [btn_next.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_next.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_next addTarget:self action:@selector(nextPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_last = [[UIButton alloc] init];
            UIImage *imagebtn_last = [UIImage imageNamed:@"paging_icon_last"];
            [btn_last setBackgroundImage:imagebtn_last forState:UIControlStateNormal];
            [btn_last.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_last.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_last addTarget:self action:@selector(lastPress_Event:) forControlEvents:UIControlEventTouchUpInside];
            UIStackView *stackViewRow0= [[UIStackView alloc]init];
            stackViewRow0.axis = UILayoutConstraintAxisHorizontal;
            stackViewRow0.distribution = UIStackViewDistributionEqualSpacing;
            stackViewRow0.alignment = UIStackViewAlignmentCenter;
            if(IS_IPHONE6 || IS_IPHONE6PLUS){
                stackViewRow0.spacing = 25;
            }
            else {
                stackViewRow0.spacing = 15;
            }
            [stackViewRow0 addArrangedSubview:btn_head];
            [stackViewRow0 addArrangedSubview:btn_prev];
            [stackViewRow0 addArrangedSubview:btn_page1];
            [stackViewRow0 addArrangedSubview:btn_page2];
            [stackViewRow0 addArrangedSubview:btn_page3];
            [stackViewRow0 addArrangedSubview:btn_next];
            [stackViewRow0 addArrangedSubview:btn_last];
            stackViewRow0.translatesAutoresizingMaskIntoConstraints = false;
            [view addSubview:stackViewRow0];
            [stackViewRow0.centerXAnchor constraintEqualToAnchor:(view.centerXAnchor) constant:0].active = true;
            [stackViewRow0.centerYAnchor constraintEqualToAnchor:(view.centerYAnchor) constant:-5].active = true;
        }else if(button1 == true && button2 == true && button3 == false && button4 == false && button5 == false){
            [self.view addSubview:view];
            btn_head = [[UIButton alloc] init];
            UIImage * imageHeadPress = [UIImage imageNamed:@"paging_icon_first"];
            [btn_head setBackgroundImage:imageHeadPress forState:UIControlStateNormal];
            [btn_head.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_head.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_head addTarget:self action:@selector(headPress_Event:) forControlEvents:UIControlEventTouchUpInside];            //button prev
            btn_prev = [[UIButton alloc] init];
            UIImage *imagePrev = [UIImage imageNamed:@"prev"];
            [btn_prev setBackgroundImage:imagePrev forState:UIControlStateNormal];
            [btn_prev.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_prev.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_prev addTarget:self action:@selector(prevPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page1 = [[UIButton alloc] init];
            [btn_page1 setTitle:@"1" forState:UIControlStateNormal];
            btn_page1.clipsToBounds = YES;
            btn_page1.layer.cornerRadius = 15;
            [btn_page1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page1.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page1.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page1 addTarget:self action:@selector(page1Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page2 = [[UIButton alloc] init];
            [btn_page2 setTitle:@"2" forState:UIControlStateNormal];
            btn_page2.clipsToBounds = YES;
            btn_page2.layer.cornerRadius = 15;
            [btn_page2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page2.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page2.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page2 addTarget:self action:@selector(page2Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_next = [[UIButton alloc] init];
            UIImage *imageNext = [UIImage imageNamed:@"next"];
            [btn_next setBackgroundImage:imageNext forState:UIControlStateNormal];
            [btn_next.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_next.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_next addTarget:self action:@selector(nextPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_last = [[UIButton alloc] init];
            UIImage *imagebtn_last = [UIImage imageNamed:@"paging_icon_last"];
            [btn_last setBackgroundImage:imagebtn_last forState:UIControlStateNormal];
            [btn_last.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_last.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_last addTarget:self action:@selector(lastPress_Event:) forControlEvents:UIControlEventTouchUpInside];
            UIStackView *stackViewRow0= [[UIStackView alloc]init];
            stackViewRow0.axis = UILayoutConstraintAxisHorizontal;
            stackViewRow0.distribution = UIStackViewDistributionEqualSpacing;
            stackViewRow0.alignment = UIStackViewAlignmentCenter;
            if(IS_IPHONE6 || IS_IPHONE6PLUS){
                stackViewRow0.spacing = 30;
            }
            else {
                stackViewRow0.spacing = 20;
            }
            [stackViewRow0 addArrangedSubview:btn_head];
            [stackViewRow0 addArrangedSubview:btn_prev];
            [stackViewRow0 addArrangedSubview:btn_page1];
            [stackViewRow0 addArrangedSubview:btn_page2];
            [stackViewRow0 addArrangedSubview:btn_next];
            [stackViewRow0 addArrangedSubview:btn_last];
            stackViewRow0.translatesAutoresizingMaskIntoConstraints = false;
            [view addSubview:stackViewRow0];
            [stackViewRow0.centerXAnchor constraintEqualToAnchor:(view.centerXAnchor) constant:0].active = true;
            [stackViewRow0.centerYAnchor constraintEqualToAnchor:(view.centerYAnchor) constant:-5].active = true;
        }else if(button1 == true && button2 == false && button3 == false && button4 == false && button5 == false) {
            [self.view addSubview:view];
            btn_head = [[UIButton alloc] init];
            UIImage * imageHeadPress = [UIImage imageNamed:@"paging_icon_first"];
            [btn_head setBackgroundImage:imageHeadPress forState:UIControlStateNormal];
            [btn_head.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_head.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_head addTarget:self action:@selector(headPress_Event:) forControlEvents:UIControlEventTouchUpInside];
            
            btn_prev = [[UIButton alloc] init];
            UIImage *imagePrev = [UIImage imageNamed:@"prev"];
            [btn_prev setBackgroundImage:imagePrev forState:UIControlStateNormal];
            [btn_prev.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_prev.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_prev addTarget:self action:@selector(prevPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_page1 = [[UIButton alloc] init];
            [btn_page1 setTitle:@"1" forState:UIControlStateNormal];
            btn_page1.clipsToBounds = YES;
            btn_page1.layer.cornerRadius = 15;
            [btn_page1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            [btn_page1.heightAnchor constraintEqualToConstant:30].active=true;
            [btn_page1.widthAnchor constraintEqualToConstant:30].active=true;
            [btn_page1 addTarget:self action:@selector(page1Press_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_next = [[UIButton alloc] init];
            UIImage *imageNext = [UIImage imageNamed:@"next"];
            [btn_next setBackgroundImage:imageNext forState:UIControlStateNormal];
            [btn_next.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_next.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_next addTarget:self action:@selector(nextPress_Event:) forControlEvents:UIControlEventTouchUpInside];

            btn_last = [[UIButton alloc] init];
            UIImage *imagebtn_last = [UIImage imageNamed:@"paging_icon_last"];
            [btn_last setBackgroundImage:imagebtn_last forState:UIControlStateNormal];
            [btn_last.heightAnchor constraintEqualToConstant:20].active=true;
            [btn_last.widthAnchor constraintEqualToConstant:20].active=true;
            [btn_last addTarget:self action:@selector(lastPress_Event:) forControlEvents:UIControlEventTouchUpInside];
            UIStackView *stackViewRow0= [[UIStackView alloc]init];
            stackViewRow0.axis = UILayoutConstraintAxisHorizontal;
            stackViewRow0.distribution = UIStackViewDistributionEqualSpacing;
            stackViewRow0.alignment = UIStackViewAlignmentCenter;
            if(IS_IPHONE6 || IS_IPHONE6PLUS){
                stackViewRow0.spacing = 30;
            }
            else {
                stackViewRow0.spacing = 20;
            }
            [stackViewRow0 addArrangedSubview:btn_head];
            [stackViewRow0 addArrangedSubview:btn_prev];
            [stackViewRow0 addArrangedSubview:btn_page1];
            [stackViewRow0 addArrangedSubview:btn_next];
            [stackViewRow0 addArrangedSubview:btn_last];
            stackViewRow0.translatesAutoresizingMaskIntoConstraints = false;
            [view addSubview:stackViewRow0];
            [stackViewRow0.centerXAnchor constraintEqualToAnchor:(view.centerXAnchor) constant:0].active = true;
            [stackViewRow0.centerYAnchor constraintEqualToAnchor:(view.centerYAnchor) constant:-5].active = true;
        }
}

-(void) interface {
    NSInteger current = [page_Current integerValue] + 1;
    if (current%5==0) {
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if(current%5 ==1){
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if (current % 5 ==2){
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if (current % 5 ==3){
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }else if (current % 5 ==4){
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    if([[[btn_page1 titleLabel] text] integerValue] == 1){
        
        btn_prev.enabled = NO;
        btn_head.enabled = NO;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    //Initialization barbutton menu
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"60-1"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    //[button addTarget:self action:@selector(reveal1:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    //Initialization search button
    UIButton *btn_Search =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_Search setImage:[UIImage imageNamed:@"icon_search.png"] forState:UIControlStateNormal];
    [btn_Search setFrame:CGRectMake(0, 0, 20, 20)];
    [btn_Search addTarget:self action:@selector(btn_Search:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton_Search = [[UIBarButtonItem alloc] initWithCustomView:btn_Search];
    self.navigationItem.rightBarButtonItem = barButton_Search;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17],NSForegroundColorAttributeName:[UIColor whiteColor]};
}
/*- (IBAction)reveal1:(id)sender {
    [self LocalNotifiation];
}
-(void)LocalNotifiation{
    UILocalNotification * local = [[UILocalNotification alloc]init];
    local.fireDate = [[NSDate date]dateByAddingTimeInterval:7];
    local.timeZone = [NSTimeZone defaultTimeZone];
    local.alertBody = @"Push news";
    NSDictionary * user = @{@"id" : @"48038",};
    local.userInfo = user;
    [[UIApplication sharedApplication] scheduleLocalNotification:local];
}*/
- (IBAction)btn_Search:(id)sender {
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud1.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud1.label.text = NSLocalizedString(@"Đợi...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"search" sender:self];
            [hud1 hideAnimated:YES];
        });
    });
}
    //Fetch json and elements from server
- (NSMutableArray *)loadData: (NSString*)urlPar{
    self.navigationItem.title = @"TIN TỨC";
    
    NSError * error = nil;
    NSURL*url = [NSURL URLWithString:urlPar];
    NSData * data=[NSData dataWithContentsOfURL:url options:0 error:&error];
    if(error){NSLog(@"%@",error);}
    json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    if(error){NSLog(@"%@",error);}
    
    arr_ObjectJson = [[NSMutableArray alloc] init];
    obj_title = @"title_TrangChu";
    obj_Nid = @"NID_TrangChu";
    obj_Email = @"mail_TrangChu";
    obj_description= @"value_TrangChu";
    obj_Images=@"image_TrangChu";
    obj_Link = @"link_TrangChu";
    obj_Postdate =@"Date_TrangChu";
    obj_View = @"view_TrangChu";
    obj_Commentcount = @"comment_TrangChu";
    obj_IDComment = @"comment_ID";
    page_First = [[NSMutableArray alloc] initWithArray:[json[@"first"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]]][5];
    page_last = [[NSMutableArray alloc] initWithArray:[json[@"last"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]]][5];
    NSMutableArray * self_Array=[[NSMutableArray alloc] initWithArray:[json[@"self"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]]];
    NSInteger self_temp = [self_Array[5] integerValue] ;
    page_Current = [NSString stringWithFormat:@"%ld",(long)self_temp];
    
    NSInteger current = [page_Current integerValue] + 1;
    if (current%5==0) {
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if(current%5 ==1){
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if (current % 5 ==2){
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if (current % 5 ==3){
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }else if (current % 5 ==4){
        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
        
        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    NSString const *next = json[@"next"];
    if(next == NULL){
        next= json[@"self"];
    }
    else{
        next= json[@"next"];
    }
    NSMutableArray * next_Array=[[NSMutableArray alloc] initWithArray:[next componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]]];
    page_Next = next_Array[5];
    NSString const *prev = json[@"prev"];
    if(prev == NULL){
        prev= json[@"self"];
    }
    else{
        prev= json[@"prev"];
    }
    NSMutableArray * prev_Array=[[NSMutableArray alloc] initWithArray:[prev componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]]];
    page_Prev = prev_Array[5];
    //get values from json --> list
    for(NSDictionary * dict in json[@"list"])
    {
        @try {
            //GET TTTLE.
            NSString *title_temp;
            if( [dict valueForKey:@"title"] == [NSNull null]){
                title_temp = @"Không có tiêu đề";
            }
            else {
                title_temp = [dict valueForKey:@"title"];
            }
            //GET IMAGE.
            NSString * images;
            NSArray *image_temp;
            NSArray *images_temp = [dict valueForKey:@"field_tin_tuc_hinh_dai_dien"];
            if(images_temp == (id)[NSNull null]){
                images = @"600x600";
            }else{
            images = [dict valueForKey:@"field_tin_tuc_hinh_dai_dien"][@"file"][@"uri"];
            NSString *url_images = [NSString stringWithFormat:@"%@.json",images];
            NSError * error_thumnail;
            NSURL*url_getThumnail = [NSURL URLWithString:url_images];
            NSData * data_thumnail=[NSData dataWithContentsOfURL:url_getThumnail];
            NSMutableDictionary  * json_thumnail = [NSJSONSerialization JSONObjectWithData:data_thumnail options: NSJSONReadingMutableContainers error: &error_thumnail];
            image_temp = json_thumnail[@"url"];
            }
            //GET BODY
            NSString * body_content;
            NSArray  * body = [dict valueForKey:@"body"];
            if(body == (id)[NSNull null]){
                body_content = @"không có nội dung cho bài viết này";
            }else{
                body_content = [dict valueForKey:@"body"][@"value"];
            }
            //GET URL.
            NSString *link_load;
            NSString * links = [dict valueForKey:@"url"];
            if(links == (id)[NSNull null]){
                link_load = nil;
            }else{
                link_load = [dict valueForKey:@"url"];
            }
            int secondsLeft;
             NSString *formattedDateString;
            int date = [[dict objectForKey:@"created"] intValue];
            if(date == (int)[NSNull null]){
                secondsLeft = 28/9/2016;
            }
            else {
            secondsLeft = [[dict objectForKey:@"created"] intValue];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, dd'/'MM'/'YYYY"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsLeft];
            [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
            formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
            }
            //GET VIEW POST
            int const view1 = [[dict objectForKey:@"views"] intValue];
            NSString *threadKey=[NSString stringWithFormat:@"%d",view1];
            //GET CMT COUT
            int const cmt = [[dict objectForKey:@"comment_count"]intValue];
            NSString *cmt_count = [NSString stringWithFormat:@"%d",cmt];
            //GET NID
            int const nid = [[dict valueForKey:@"nid"]intValue];
            NSString *IDD= [NSString stringWithFormat:@"%d",nid];
            //GET CMT ID
            NSArray const * getIdComment = [dict valueForKey:@"comments"];
            
            dic_ObjectJson = [NSDictionary dictionaryWithObjectsAndKeys:
                          formattedDateString,obj_Postdate,
                          title_temp,obj_title,
                          body_content,obj_description,
                          link_load,obj_Link,
                          threadKey,obj_View,
                          IDD,obj_Nid,
                          cmt_count,obj_Commentcount,
                          getIdComment,obj_IDComment,
                          image_temp,obj_Images,
                          nil];
            [arr_ObjectJson addObject:dic_ObjectJson];
        }
        @catch (NSException *exception) {
            NSLog(@" ẩn 1 tin thiếu %@ ",exception);
        }
    }
    return arr_ObjectJson;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arr_ObjectJson.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
/*data empty in tableView*/
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Không tìm thấy tin";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //turnoff border of navigationbar
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    //
    return [[NSAttributedString alloc] initWithString:text attributes:nil];
}
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = [NSString stringWithFormat:@"không có bài đăng ở trang này"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:[attributedString.string rangeOfString:text]];
    
    return attributedString;
}
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor colorWithRed:0.271 green:0.349 blue:0.388 alpha:1.00];
}
/////////////////////////////////////////////////////////////////////
////////////////////////convert HTML to String////////////////////////
- (id)init{
    if([super init]){
        self.resultStringg = [NSMutableString string];
    }
    return self;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.resultStringg appendString:string];
}
- (NSString *)convertEntiesInString:(NSString*)convertString{
    if(convertString == nil){
        NSLog(@"ERROR : Parameter string is nil");
    }
    NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>",convertString];
    NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[NSXMLParser alloc] initWithData:data];
    [xmlParse setDelegate:self];
    [xmlParse parse];
    return [NSString stringWithFormat:@"%@",self.resultStringg];
}
- (void)dealloc {
    self.resultStringg = nil;
}
/////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        new2TableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        NSDictionary *tmpDict= [arr_ObjectJson objectAtIndex:0];
        cell1.lbl_titleMain.text=[tmpDict objectForKeyedSubscript:obj_title];
        cell1.lbl_EmailMain.text=[tmpDict objectForKeyedSubscript:obj_Postdate];
        cell1.lg_lbl_view.text = [tmpDict objectForKeyedSubscript:obj_View];
        if([[UIScreen mainScreen]bounds].size.width > 320){
        [cell1.img_thumlage sd_setImageWithURL:[tmpDict objectForKeyedSubscript:obj_Images] placeholderImage: [UIImage imageNamed:@"1100x600"]];
        }
        else {
        [cell1.img_thumlage sd_setImageWithURL:[tmpDict objectForKeyedSubscript:obj_Images] placeholderImage: [UIImage imageNamed:@"1200x800"]];
        }
        return cell1;
    }
    else
    {
        News_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSDictionary *tmpDict= [arr_ObjectJson objectAtIndex:indexPath.section];
        cell.lbl_email.text=[tmpDict objectForKeyedSubscript:obj_Postdate];
        cell.lbl_view.text=[tmpDict objectForKeyedSubscript:obj_View];
        //subString demo
        NSString *string = [tmpDict objectForKeyedSubscript:obj_description];
        // convert html -> string
        TrangChuController *converter = [[TrangChuController alloc]init];
        NSString *str2 =[converter convertEntiesInString:string];
        NSString * titleString = [tmpDict objectForKeyedSubscript:obj_title];
        NSString * titleAppendEnter = [titleString stringByAppendingString:@"\n"];
        NSString * Space = @"              ";
        NSString * SpaceAppendEnter = [Space stringByAppendingString:@"\n"];
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentLeft;
        NSDictionary *attributeTitle = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:15],
                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSParagraphStyleAttributeName: paragraph};
        NSDictionary *attributeContent = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13],
                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSParagraphStyleAttributeName: paragraph};
        NSDictionary *attributeSpace = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:3],
                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSParagraphStyleAttributeName: paragraph};
        NSMutableAttributedString * Title = [[NSMutableAttributedString alloc] initWithString:titleAppendEnter attributes:attributeTitle];
        NSAttributedString * content = [[NSAttributedString alloc] initWithString:str2 attributes:attributeContent];
        NSAttributedString * content1 = [[NSAttributedString alloc] initWithString:SpaceAppendEnter attributes:attributeSpace];
        [Title appendAttributedString:content1];
        [Title appendAttributedString:content];
        cell.lbl_content.attributedText = Title;
        [cell.img_thum sd_setImageWithURL: [tmpDict objectForKeyedSubscript:obj_Images] placeholderImage:[UIImage imageNamed:@"600x600"]];
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud1.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud1.label.text = NSLocalizedString(@"Đang tải nội dung...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *tmpDict1 = [arr_ObjectJson objectAtIndex:indexPath.section];
            NSUserDefaults *defaults1=[NSUserDefaults standardUserDefaults];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_description] forKey:@"content_post"];
            NSLog(@"content %@",[defaults1 valueForKey:@"content_post"]);
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_title] forKey:@"TitlePost"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_Link] forKey:@"linkview"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_Postdate] forKey:@"date"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_View] forKey:@"viewtr"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_Nid] forKey:@"nid"];
            NSLog(@"nid %@",[defaults1 valueForKey:@"nid"]);
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_Commentcount] forKey:@"comment_count"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:obj_IDComment] forKey:@"comments"];
            [defaults1 setObject:@"0" forKey:@"IsFirstLoad"];
            NSString *key= @"tintuc";
            [defaults1 setObject:key forKey:@"KEY"];
            [defaults1 synchronize];
            [self performSegueWithIdentifier:@"loadcontent" sender:self];
            [hud1 hideAnimated:YES];
        });
    });
}
// adjust height for header in section
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    return 6;
}
// adjust height for header in row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 295;
            break;
        default:
            return 115;
            break;
    }
}
-(void)loadPage: (NSInteger)totalPage :(NSInteger)currentPage :(BOOL*)firstLoad{
    currentPage = currentPage;
    btn_last.enabled = YES;
    btn_prev.enabled = YES;
    btn_next.enabled = YES;
    btn_last.enabled = YES;
    btn_page1.hidden = false;
    btn_page2.hidden = false;
    btn_page3.hidden = false;
    btn_page4.hidden = false;
    btn_page5.hidden = false;
    NSInteger numpage1,numpage2,numpage3,numpage4,numpage5;
    NSInteger pagePosition = currentPage % 5;
    switch (pagePosition) {
        case 0:
            [self resizeDistantButton:true:true:true:true:true];
            numpage5 = currentPage;
            numpage4 = currentPage - 1;
            numpage3 = currentPage - 2;
            numpage2 = currentPage - 3;
            numpage1 = currentPage - 4;
            [btn_page5 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage5] forState:UIControlStateNormal];
            [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
            [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
            [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
            [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
            [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
            [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
            [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
            [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
            [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
            [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn_page5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            break;
        case 1:
            switch (totalPage) {
                case 2:
                    [self resizeDistantButton:true :true :false :false :false];
                    numpage1 = currentPage;
                    numpage2 = currentPage + 1;
                    [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                    [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    break;
                case 3:
                    [self resizeDistantButton:true :true :true :false :false];
                    numpage1 = currentPage;
                    numpage2 = currentPage + 1;
                    numpage3 = currentPage + 2;
                    [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                    [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    break;
                case 4:
                    [self resizeDistantButton:true :true :true :true :false];
                    numpage1 = currentPage;
                    numpage2 = currentPage + 1;
                    numpage3 = currentPage + 2;
                    numpage4 = currentPage + 3;
                    [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                    [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    break;
                default:
                    if(currentPage == totalPage){
                        [self resizeDistantButton:true :false :false :false :false];
                        numpage1 = currentPage;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }else if((currentPage + 1) == totalPage){
                        [self resizeDistantButton:true :true :false :false :false];
                        numpage1 = currentPage;
                        numpage2 = currentPage + 1;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }else if((currentPage + 2) == totalPage){
                        [self resizeDistantButton:true :true :true :false :false];
                        numpage1 = currentPage;
                        numpage2 = currentPage + 1;
                        numpage3 = currentPage + 2;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }else if((currentPage + 3) == totalPage){
                        [self resizeDistantButton:true :true :true :true :false];
                        numpage1 = currentPage;
                        numpage2 = currentPage + 1;
                        numpage3 = currentPage + 2;
                        numpage4 = currentPage + 3;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }else{
                        [self resizeDistantButton:true :true :true :true :true];
                        numpage1 = currentPage;
                        numpage2 = currentPage + 1;
                        numpage3 = currentPage + 2;
                        numpage4 = currentPage + 3;
                        numpage5 = currentPage + 4;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                        [btn_page5 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage5] forState:UIControlStateNormal];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }
                    break;
            }
            break;
        case 2:
            switch (totalPage) {
                case 3:
                    [self resizeDistantButton:true :true :true :false :false];
                    numpage1 = currentPage - 1;
                    numpage2 = currentPage;
                    numpage3 = currentPage + 1;
                    [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                    [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    break;
                case 4:
                    [self resizeDistantButton:true :true :true :true :false];
                    numpage1 = currentPage - 1;
                    numpage2 = currentPage;
                    numpage3 = currentPage + 1;
                    numpage3 = currentPage + 2;
                    [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                    [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    break;
                default:
                    if(currentPage == totalPage){
                        [self resizeDistantButton:true :true :false :false :false];
                        numpage1 = currentPage - 1;
                        numpage2 = currentPage;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }else if((currentPage + 1) == totalPage){
                        [self resizeDistantButton:true :true :true :false :false];
                        numpage1 = currentPage - 1;
                        numpage2 = currentPage;
                        numpage3 = currentPage + 1;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }else if((currentPage + 2) == totalPage){
                        [self resizeDistantButton:true :true :true :true :false];
                        numpage1 = currentPage - 1;
                        numpage2 = currentPage;
                        numpage3 = currentPage + 1;
                        numpage4 = currentPage + 2;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }else{
                        [self resizeDistantButton:true :true :true :true :true];
                        numpage1 = currentPage - 1;
                        numpage2 = currentPage ;
                        numpage3 = currentPage + 1;
                        numpage4 = currentPage + 2;
                        numpage5 = currentPage + 3;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                        [btn_page5 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage5] forState:UIControlStateNormal];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }
                    break;
            }
            break;
        case 3:
            switch (totalPage) {
                case 4:
                    [self resizeDistantButton:true :true :true :true :false];
                    numpage1 = currentPage - 2;
                    numpage2 = currentPage - 1;
                    numpage3 = currentPage;
                    numpage4 = currentPage + 1;
                    [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                    [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                    [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    break;
                default:
                    if(currentPage  == totalPage){
                        [self resizeDistantButton:true :true :true :false :false];
                        numpage1 = currentPage - 2;
                        numpage2 = currentPage - 1;
                        numpage3 = currentPage;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        
                        
                    }else if((currentPage + 1) == totalPage){
                        [self resizeDistantButton:true :true :true :true :false];
                        numpage1 = currentPage - 2;
                        numpage2 = currentPage - 1;
                        numpage3 = currentPage;
                        numpage4 = currentPage + 1;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        
                    }else{
                        [self resizeDistantButton:true :true :true :true :true];
                        numpage1 = currentPage - 2;
                        numpage2 = currentPage - 1;
                        numpage3 = currentPage;
                        numpage4 = currentPage + 1;
                        numpage5 = currentPage + 2;
                        [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                        [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                        [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                        [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                        [btn_page5 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage5] forState:UIControlStateNormal];
                        [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                        [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                        [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }
                    break;
            }
            break;
        case 4:
            if(currentPage == totalPage){
                [self resizeDistantButton:true :true :true :true :false];
                numpage1 = currentPage - 3;
                numpage2 = currentPage - 2;
                numpage3 = currentPage - 1;
                numpage4 = currentPage;
                [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                [btn_page4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }else if(totalPage == 4){
                [self resizeDistantButton:true :true :true :true :false];
                numpage1 = currentPage - 3;
                numpage2 = currentPage - 2;
                numpage3 = currentPage - 1;
                numpage4 = currentPage;
                [btn_page1 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage1] forState:UIControlStateNormal];
                [btn_page2 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage2] forState:UIControlStateNormal];
                [btn_page3 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage3] forState:UIControlStateNormal];
                [btn_page4 setTitle:[NSString stringWithFormat:@"%ld",(long)numpage4] forState:UIControlStateNormal];
                [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
                [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
                [btn_page4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
    }
    if([[[btn_page1 titleLabel] text] integerValue] == 1){
        btn_page1.enabled = false;
        btn_prev.enabled = false;
        btn_head.enabled = false;
    }
    if(([[[btn_page1 titleLabel] text] integerValue] > [page_last integerValue]) || ([[[btn_page2 titleLabel] text] integerValue] > [page_last integerValue]) || ([[[btn_page3 titleLabel] text] integerValue] > [page_last integerValue]) || ([[[btn_page4 titleLabel] text] integerValue] > [page_last integerValue]) || ([[[btn_page5 titleLabel] text] integerValue] > [page_last integerValue])){
        btn_next.enabled = false;
        btn_last.enabled = false;
    }else{
        btn_next.enabled = true;
        btn_last.enabled = true;
    }
    if(!firstLoad){
    [arr_ObjectJson removeAllObjects];
    NSInteger pageload = currentPage - 1;
    NSString* urlString1 = [NSString  stringWithFormat:LINK1,[NSString stringWithFormat:@"%ld",(long)pageload]];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.contentColor =[UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
        hud.label.text = NSLocalizedString(@"Đang tải tin tức...", @"HUD loading title");
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults * de = [NSUserDefaults standardUserDefaults];
            [de setObject:urlString1 forKey:@"URLL"];
            [self loadData:urlString1];
            [self.tableView reloadData];
            [hud hideAnimated:YES];
            });
        });
    }
}
-(void)headPress_Event:(id)sender{
    NSInteger total = [page_last integerValue] + 1;
    [self loadPage:total :1 : FALSE];
}
-(void)prevPress_Event:(id)sender{
    NSInteger total = [page_last integerValue] + 1;
    NSInteger current = [[[btn_page1 titleLabel] text] integerValue] -1;
    [self loadPage:total :current : FALSE];
}
-(void)page1Press_Event:(id)sender{
    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSInteger total = [page_last integerValue] + 1;
    NSInteger current = [[[btn_page1 titleLabel] text] integerValue];
    [self loadPage:total :current : FALSE];
    [btn_page1 setEnabled:FALSE];
    [btn_page2 setEnabled:TRUE];
    [btn_page3 setEnabled:TRUE];
    [btn_page4 setEnabled:TRUE];
    [btn_page5 setEnabled:TRUE];
}
-(void)page2Press_Event:(id)sender{
    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    
    [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    NSInteger total = [page_last integerValue] +1;
    NSInteger current = [[[btn_page2 titleLabel] text] integerValue];
    [self loadPage:total :current : FALSE];
    [btn_page1 setEnabled:TRUE];
    [btn_page2 setEnabled:FALSE];
    [btn_page3 setEnabled:TRUE];
    [btn_page4 setEnabled:TRUE];
    [btn_page5 setEnabled:TRUE];
}
-(void)page3Press_Event:(id)sender{
    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    
    [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    NSInteger total = [page_last integerValue]+1;
    NSInteger current = [[[btn_page3 titleLabel] text] integerValue];
    [self loadPage:total :current : FALSE];
    [btn_page1 setEnabled:TRUE];
    [btn_page2 setEnabled:TRUE];
    [btn_page3 setEnabled:FALSE];
    [btn_page4 setEnabled:TRUE];
    [btn_page5 setEnabled:TRUE];
}
-(void)page4Press_Event:(id)sender{
    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
    [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    
    [btn_page5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    NSInteger total = [page_last integerValue]+1;
    NSInteger current = [[[btn_page4 titleLabel] text] integerValue];
    [self loadPage:total :current : FALSE];
    [btn_page1 setEnabled:TRUE];
    [btn_page2 setEnabled:TRUE];
    [btn_page3 setEnabled:TRUE];
    [btn_page4 setEnabled:FALSE];
    [btn_page5 setEnabled:TRUE];
}
-(void)page5Press_Event:(id)sender{
    [btn_page1 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page2 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page3 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page4 setBackgroundColor:[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00]];
    [btn_page5 setBackgroundColor:[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]];
    
    [btn_page1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_page5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSInteger total = [page_last integerValue]+1;
    NSInteger current = [[[btn_page5 titleLabel] text] integerValue];
    [self loadPage:total :current : FALSE];
    [btn_page1 setEnabled:TRUE];
    [btn_page2 setEnabled:TRUE];
    [btn_page3 setEnabled:TRUE];
    [btn_page4 setEnabled:TRUE];
    [btn_page5 setEnabled:FALSE];
}
-(void)nextPress_Event:(id)sender{
    NSInteger total = [page_last integerValue]+1;
    NSInteger current = [[[btn_page5 titleLabel] text] integerValue]+1;
    [self loadPage:total :current : FALSE];
}
-(void)lastPress_Event:(id)sender{
    NSInteger total = [page_last integerValue]+1;
    [self loadPage:total :total : FALSE];
    btn_next.enabled = false;
    btn_prev.enabled = true;
}
@end
