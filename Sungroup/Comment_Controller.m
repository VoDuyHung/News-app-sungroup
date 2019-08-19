//
//  Comment_Controller.m
//  Sungroup
//
//  Created by Võ Duy Hùng  on 8/24/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "Comment_Controller.h"
#import "Cell1CMT_Controler.h"
#import "Cell2CMT_Controler.h"
#import "UIScrollView+EmptyDataSet.h" // nếu table rỗng 21/6
#import "UIImageView+WebCache.h" // load image in cell with SDWebImage
#define LINK_CMT @"https://cms.sungroup.com.vn/node/%@.json"
#define LINK_CMT2 @"https://cms.sungroup.com.vn/api/mic/%@/%@.json"
#define LINK_POST_CMT @"https://cms.sungroup.com.vn/api/mic/comment/"
#define IS_IPHONE5S5 (([[UIScreen mainScreen]bounds].size.width)==320.0f && ([[UIScreen mainScreen]bounds].size.height)==568.0f)
#define IS_IPHONE4S43 (([[UIScreen mainScreen]bounds].size.width)==320.0f && ([[UIScreen mainScreen]bounds].size.height)==480)
@interface Comment_Controller ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,UITextViewDelegate>{
NSMutableArray  *myObject,*MainArray;
NSDictionary *dictionary;
NSString *bodyComment,*dateComment,*userPostComment,*imagePostComment,*idcmt,*idSubcmt;
NSInteger possition;
UITextView *txtSendCmt,* alertTextField1;
UIView * view;
UIAlertController *alertController;
CGFloat  FrameKeyBoard;
}
@end
@implementation Comment_Controller
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.TableViewComment.delegate = self;
    self.TableViewComment.dataSource = self;
//DYNAMIC HEIGHT CELL
    self.TableViewComment.estimatedRowHeight = 70.0;
    self.TableViewComment.rowHeight = UITableViewAutomaticDimension;
    [_TableViewComment setNeedsLayout];
    [_TableViewComment layoutIfNeeded];
    [self.TableViewComment reloadData];
//EVENT KEYBOARD
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

}
- (void)viewDidLoad {
    [super viewDidLoad];
//REGISTER CELL XID
    [_TableViewComment registerNib:[UINib nibWithNibName:@"Cell1CMT" bundle:nil] forCellReuseIdentifier:@"CellCMT1"];
    [_TableViewComment registerNib:[UINib nibWithNibName:@"Cell2CMT" bundle:nil] forCellReuseIdentifier:@"CellCMT2"];
    
//INITIALIZATION VIEW CMT MAIN
    view = [[UIView alloc ]initWithFrame:CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame),50)];
    view.backgroundColor = [UIColor colorWithRed:0.780 green:0.808 blue:0.839 alpha:1.00];
    txtSendCmt  = [[UITextView alloc]initWithFrame:CGRectMake(10,5, CGRectGetWidth(self.view.frame) - 55, 35)];
    txtSendCmt.text = @"Nhập bình luận...";
    txtSendCmt.delegate = self;
    txtSendCmt.backgroundColor = [UIColor whiteColor];
    txtSendCmt.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    txtSendCmt.layer.masksToBounds = YES;
    txtSendCmt.layer.cornerRadius = 3;
    txtSendCmt.returnKeyType = UIReturnKeyDone;
    txtSendCmt.autocorrectionType = UITextAutocorrectionTypeNo;
    txtSendCmt.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    txtSendCmt.textColor = [UIColor lightGrayColor];
    txtSendCmt.keyboardType = UIKeyboardTypeDefault;
    txtSendCmt.scrollEnabled = YES;
    [view addSubview:txtSendCmt];
    UIButton * btn_sendCMT = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(txtSendCmt.frame)+20, 10, 25, 25)];
    [btn_sendCMT setImage:[UIImage imageNamed:@"flyIcon"] forState:UIControlStateNormal];
    [btn_sendCMT addTarget:self action:@selector(sendCMT:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn_sendCMT];
    [self.view addSubview:view];
    
    UIImageView * bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BG_Comment"]];
    _TableViewComment.backgroundView = bg;
//REMOVE EMPTY CELL
    _TableViewComment.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    NSArray *nId = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    NSString *linkURL = [NSString stringWithFormat:LINK_CMT,nId];
    NSLog(@"linkURRL %@",linkURL);
    NSError * error = nil;
    NSURL * URL = [NSURL URLWithString:linkURL];
    NSData * data = [NSData dataWithContentsOfURL:URL options:0 error:&error];
    if(error){NSLog(@"đây là lỗi data %@",error);}
    NSMutableDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error){NSLog(@"đây là lỗi json %@",error);}
    [[NSUserDefaults standardUserDefaults]setObject:json[@"comments"] forKey:@"sendComment"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self loadData];
//INITIALIZATION BTN BAR
    UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [btn_back setFrame:CGRectMake(0, 0, 20, 20)];
    [btn_back addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn_back];
    UILabel *lbl_Title = [[UILabel alloc]init];
    lbl_Title.frame = CGRectMake(0, 0, 300, 20);
    lbl_Title.text = @"QUAY LẠI";
    [lbl_Title setTextAlignment:NSTextAlignmentLeft];
    lbl_Title.textColor = [UIColor whiteColor];
    [lbl_Title setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    UIBarButtonItem *menuItemButton= [[UIBarButtonItem alloc] initWithCustomView:lbl_Title];
    NSArray *arrayButtonLeft= [[NSArray alloc] initWithObjects:barButton,menuItemButton, nil];
    self.navigationItem.leftBarButtonItems=arrayButtonLeft;
}
//delegate cho textfield khi text bắt đầu sửa
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"Nhập bình luận..."]){
        textView.text = @"";
        textView.textColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    }
    [textView becomeFirstResponder];
}
//delegate cho textfield khi text kêt thuc sửa
-(void)textViewDidEndEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@""]){
        textView.text = @"Nhập bình luận...";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}
//CONVERT STRING -> HTML
-(NSString *)convertHTML:(NSString *)html {
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}
/*Empty Data in tableView*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"1474377966_Message"];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
//turnoff border of navigationbar
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    NSString *text = [NSString stringWithFormat:@"Bài viết này không có bình luận"];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.655 green:0.714 blue:0.741 alpha:1.00]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = [NSString stringWithFormat:@"Hãy bình luận ở phía dưới!"];
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.655 green:0.714 blue:0.741 alpha:1.00],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor colorWithRed:0.271 green:0.349 blue:0.388 alpha:1.00];
}
-(void)loadData{
    myObject = [[NSMutableArray alloc]init];
    NSArray *jsonComment = [[NSUserDefaults standardUserDefaults]valueForKey:@"sendComment"];
    for(NSString *dict in jsonComment){
        NSString * uri = [NSString stringWithFormat:@"%@.json",[dict valueForKey:@"uri"]];
        NSLog(@"uri %@",uri);
        NSError *error = nil;
        NSURL *url = [NSURL URLWithString:uri];
        NSData * data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        NSMutableDictionary * json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
        NSString * commentBody;
        NSString * IsSubComment;
            if([json[@"comment_body"] count] !=0){
                commentBody = [json[@"comment_body"][@"value"] stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
                commentBody = [commentBody stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            }else{
                commentBody = @"";
        }
        if(json[@"parent"] == NULL){
            IsSubComment = @"YES";
        }else{
            IsSubComment = @"NO";
        }
        /*Fetch NodeID*/
        NSString * nodeNews = [json valueForKey:@"node"][@"id"];
        /*Fetch cid*/
        NSString * idComment = [json valueForKey:@"cid"];
        /*Fetch create*/
        int secondsLeft = [[json valueForKey:@"created"] intValue];
        NSString *formattedDateString;
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, dd' tháng 'MM' năm 'YYYY"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:secondsLeft];
        [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
        formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
        /*Fetch authorResource*/
        NSString * authorResource = [json valueForKey:@"author"][@"resource"];
        /*Fetch authorID*/
        NSString * authorID = [json valueForKey:@"author"][@"id"];
        /*Fetch name */        
        NSString *urlCmt = [NSString stringWithFormat:LINK_CMT2,authorResource,authorID];
        NSURL *url_nameCmt = [NSURL URLWithString:urlCmt];
        NSData * dataCmt=[NSData dataWithContentsOfURL:url_nameCmt options:0 error:&error];
        NSMutableDictionary  * jsonCmt = [NSJSONSerialization JSONObjectWithData:dataCmt options: NSJSONReadingMutableContainers error: &error];
        NSString *name = [jsonCmt valueForKey:@"name"];
        if(name == NULL){
            name = @"voduyhung58@gmail.com";
        }
        /*Fetch Image*/
        NSString * imageCmt;
        NSArray * pic = jsonCmt[@"picture"];
        if(pic == (id)[NSNull null]){
            imageCmt = @"600x600";
        }else{
            imageCmt= [jsonCmt valueForKey:@"picture"][@"url"];
        }
        NSString * idCMT =[dict valueForKey:@"id"];
                   dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          imageCmt,@"imageCmtt",
                          [self convertHTML:commentBody],@"bodyComment",
                          nodeNews,@"idPost",
                          idCMT,@"idcmt",
                          formattedDateString,@"dateComment",
                          name,@"userPostComment",
                          IsSubComment,@"values",
                          idComment,@"commentID",
                          json[@"parent"][@"id"],@"parentvalues",
                          
                           @"0",@"numcmt",
                          @"0",@"numcmtt",
                         
                          nil];
            
            [myObject addObject:dictionary];
         }
        NSLog(@"myObject %@",myObject);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return myObject.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
//SORT CELL CMT
-(NSMutableArray *)sortArray :(NSMutableArray *)sendArray{
    NSString *cpm1,*cpm2;
    MainArray = [NSMutableArray array];
    for(int i = 0; i< myObject.count; i++){
        if([[[myObject objectAtIndex:i] objectForKeyedSubscript:@"values"] isEqualToString:@"YES"]){
            [MainArray addObject:myObject[i]];
        }else{
            NSInteger index = -1;
            for (int k = 0; k < MainArray.count; k++) {
                cpm1 = [NSString stringWithFormat:@"%@",[[myObject objectAtIndex:i] objectForKeyedSubscript:@"parentvalues"]];
                if(index == -1){
                    cpm1 = [NSString stringWithFormat:@"%@",[[myObject objectAtIndex:i] objectForKeyedSubscript:@"parentvalues"]];
                    cpm2 = [NSString stringWithFormat:@"%@",[[MainArray objectAtIndex:k] objectForKeyedSubscript:@"idcmt"]];
                    if([cpm2 isEqualToString:cpm1]){
                        index = k;
                    }
                }else{
                    cpm1 = [NSString stringWithFormat:@"%@",[[MainArray objectAtIndex:k] objectForKeyedSubscript:@"parentvalues"]];
                    cpm2 = [NSString stringWithFormat:@"%@",[[myObject objectAtIndex:i] objectForKeyedSubscript:@"parentvalues"]];
                    if([cpm2 isEqualToString:cpm1]){
                        index = k;
                    }else{
                        break;
                    }
                }
                
            }
            [MainArray insertObject:myObject[i] atIndex:(index+1)];
        }
    }
    return MainArray;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self sortArray:myObject];
    NSDictionary * tmpDict = [MainArray objectAtIndex:indexPath.section];
    if([[tmpDict objectForKeyedSubscript:@"values"]isEqualToString:@"NO"]){
      Cell1CMT_Controler *cell1 = [_TableViewComment dequeueReusableCellWithIdentifier:@"CellCMT1" forIndexPath:indexPath];
        cell1.lbl_ContentCell1.text=[tmpDict objectForKeyedSubscript:@"bodyComment"];
        cell1.lbl_dateCell1.text=[tmpDict objectForKeyedSubscript:@"dateComment"];
        cell1.lbl_NameCell1.text =[tmpDict objectForKeyedSubscript:@"userPostComment"];
        [cell1.img_Avatar sd_setImageWithURL:[tmpDict objectForKeyedSubscript:@"imageCmtt"] placeholderImage:[UIImage imageNamed:@"hinhdaidien"]];
        cell1.img_Avatar.layer.borderColor = [UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00].CGColor;
        cell1.backgroundColor = [UIColor clearColor];
        [cell1.btn_trloiCMT1 addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
        ;
        return cell1;
    }
    else {
      Cell2CMT_Controler *cell2 = [_TableViewComment dequeueReusableCellWithIdentifier:@"CellCMT2" forIndexPath:indexPath];
        cell2.lbl_dateCell2.text = [tmpDict objectForKeyedSubscript:@"dateComment"];
        cell2.lbl_nameCell2.text =[tmpDict objectForKeyedSubscript:@"userPostComment"];
        cell2.lbl_contentCell2.text=[tmpDict objectForKeyedSubscript:@"bodyComment"];
        [cell2.img_Cell2 sd_setImageWithURL:[tmpDict objectForKeyedSubscript:@"imageCmtt"] placeholderImage:[UIImage imageNamed:@"hinhdaidien"]];
        cell2.img_Cell2.layer.borderColor = [UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00].CGColor;
        cell2.backgroundColor = [UIColor clearColor];
        [cell2.btn_tloiCMT2 addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
        return cell2;
    }
    return 0;
}

-(void)backButton:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)actionButton:(id)sender {
    /*CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_TableViewComment];
    NSIndexPath *indexPath = [_TableViewComment indexPathForRowAtPoint:buttonPosition];
    NSDictionary *tmpDict= [MainArray objectAtIndex:indexPath.section];
    idcmt = [tmpDict objectForKeyedSubscript:@"idPost"];
    idSubcmt = [tmpDict objectForKeyedSubscript:@"commentID"];
    possition = indexPath.section;
    [[NSUserDefaults standardUserDefaults] setObject:idcmt forKey:@"aaaa"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.translatesAutoresizingMaskIntoConstraints = NO;
    alertController.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    
    Chỉnh màu cho alert
    UIView *subView = alertController.view.subviews.firstObject;
    UIView *alertContentView = subView.subviews.firstObject;
    [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 40)];
    customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
    
    UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(100, 5, 100, 25)];
    lblAlert.text = @"TRẢ LỜI";
    lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    lblAlert.textColor = [UIColor whiteColor];
    [customView addSubview:lblAlert];
    
    UIView *viewForTextField = [[UIView alloc] initWithFrame:CGRectMake(0, 160, 270,40)];
    viewForTextField.backgroundColor = [UIColor colorWithRed:0.808 green:0.847 blue:0.863 alpha:1.00];
    
    alertTextField1 = [[UITextView alloc]initWithFrame:CGRectMake(10,5, 250, 30)];
    alertTextField1.keyboardType = UIKeyboardTypeDefault;
    alertTextField1.backgroundColor = [UIColor whiteColor];
    alertTextField1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    alertTextField1.layer.masksToBounds = YES;
    alertTextField1.layer.cornerRadius = 5;
    alertTextField1.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    alertTextField1.textColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    alertTextField1.delegate = self;
    alertTextField1.scrollEnabled = YES;
    
    UILabel * lblContentAlert = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 250, 50)];
    lblContentAlert.text = [tmpDict objectForKeyedSubscript:@"bodyComment"];
    lblContentAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    lblContentAlert.numberOfLines = 5;
    lblContentAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
    [alertController.view addSubview:lblContentAlert];
    
    UIImageView * imageAlert = [[UIImageView alloc]initWithFrame:CGRectMake(10, 50, 40, 40)];
    NSString *avatar_user = [tmpDict objectForKeyedSubscript:@"imageCmtt"];
    NSURL *url_avatar=[NSURL URLWithString:avatar_user];
    NSData *data = [NSData dataWithContentsOfURL:url_avatar];
    UIImage *imageP = [UIImage imageWithData:data];
    imageAlert.image = imageP;
    if(imageP == nil){
        imageAlert.image  = [UIImage imageNamed:@"hinhdaidien"];
    }
    imageAlert.layer.masksToBounds = YES;
    imageAlert.layer.cornerRadius = 20;
    imageAlert.layer.borderColor = [[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]CGColor];
    imageAlert.layer.borderWidth = 2.0;
    
    UILabel * lblNameAlert = [[UILabel alloc]initWithFrame:CGRectMake(60, 50, 200, 25)];
    lblNameAlert.text = [tmpDict objectForKeyedSubscript:@"userPostComment"];
    lblNameAlert.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    lblNameAlert.numberOfLines = 5;
    lblNameAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
    [alertController.view addSubview:lblNameAlert];
    
    UILabel * lblDateAlert = [[UILabel alloc]initWithFrame:CGRectMake(60, 65, 200, 25)];
    lblDateAlert.text = [tmpDict objectForKeyedSubscript:@"dateComment"];
    lblDateAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
    lblDateAlert.numberOfLines = 5;
    lblDateAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
    [alertController.view addSubview:lblDateAlert];
    
    [alertController.view addSubview:imageAlert];
    [viewForTextField addSubview:alertTextField1];
    [alertController.view addSubview:viewForTextField];
    [alertController.view addSubview:customView];

    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [alertController dismissViewControllerAnimated:YES completion:nil];
    [self moveViewUp:NO];
    
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Trả lời" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [self eventAnswerCMT];
    view.frame = CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame), 50);
    }];
    [alertController addAction:somethingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
    view.frame = CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame), 50);*/
   
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_TableViewComment];
    NSIndexPath *indexPath = [_TableViewComment indexPathForRowAtPoint:buttonPosition];
    NSDictionary *tmpDict= [MainArray objectAtIndex:indexPath.section];
    idcmt = [tmpDict objectForKeyedSubscript:@"idPost"];
    idSubcmt = [tmpDict objectForKeyedSubscript:@"commentID"];
    possition = indexPath.section;
    [[NSUserDefaults standardUserDefaults] setObject:idcmt forKey:@"aaaa"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    if(IS_IPHONE5S5 || IS_IPHONE4S43){
    alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.translatesAutoresizingMaskIntoConstraints = NO;
    alertController.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    //Chỉnh màu cho alert
    UIView *subView = alertController.view.subviews.firstObject;
    UIView *alertContentView = subView.subviews.firstObject;
    [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 25)];
    customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
     
     UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(100, 2, 100, 20)];
     lblAlert.text = @"TRẢ LỜI";
     lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
     lblAlert.textColor = [UIColor whiteColor];
     [customView addSubview:lblAlert];
     
     UIView *viewForTextField = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 270,40)];
     viewForTextField.backgroundColor = [UIColor colorWithRed:0.808 green:0.847 blue:0.863 alpha:1.00];
     
     alertTextField1 = [[UITextView alloc]initWithFrame:CGRectMake(10,5, 250, 30)];
     alertTextField1.keyboardType = UIKeyboardTypeDefault;
     alertTextField1.backgroundColor = [UIColor whiteColor];
     alertTextField1.returnKeyType = UIReturnKeyDone;
     alertTextField1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
     alertTextField1.layer.masksToBounds = YES;
     alertTextField1.layer.cornerRadius = 5;
     alertTextField1.autocorrectionType = UITextAutocorrectionTypeNo;
     alertTextField1.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
     alertTextField1.textColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
     alertTextField1.delegate = self;
     alertTextField1.scrollEnabled = YES;
     
     UILabel * lblContentAlert = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 250, 30)];
     lblContentAlert.text = [tmpDict objectForKeyedSubscript:@"bodyComment"];
     lblContentAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
     lblContentAlert.numberOfLines = 5;
     lblContentAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
     [alertController.view addSubview:lblContentAlert];
     
     UIImageView * imageAlert = [[UIImageView alloc]initWithFrame:CGRectMake(10, 30, 40, 40)];
     NSString *avatar_user = [tmpDict objectForKeyedSubscript:@"imageCmtt"];
     NSURL *url_avatar=[NSURL URLWithString:avatar_user];
     NSData *data = [NSData dataWithContentsOfURL:url_avatar];
     UIImage *imageP = [UIImage imageWithData:data];
     imageAlert.image = imageP;
     if(imageP == nil){
     imageAlert.image  = [UIImage imageNamed:@"hinhdaidien"];
     }
     imageAlert.layer.masksToBounds = YES;
     imageAlert.layer.cornerRadius = 20;
     imageAlert.layer.borderColor = [[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]CGColor];
     imageAlert.layer.borderWidth = 2.0;
     
     UILabel * lblNameAlert = [[UILabel alloc]initWithFrame:CGRectMake(60, 30, 200, 25)];
     lblNameAlert.text = [tmpDict objectForKeyedSubscript:@"userPostComment"];
     lblNameAlert.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
     lblNameAlert.numberOfLines = 5;
     lblNameAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
     [alertController.view addSubview:lblNameAlert];
     
     UILabel * lblDateAlert = [[UILabel alloc]initWithFrame:CGRectMake(60, 45, 200, 25)];
     lblDateAlert.text = [tmpDict objectForKeyedSubscript:@"dateComment"];
     lblDateAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
     lblDateAlert.numberOfLines = 5;
     lblDateAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
     [alertController.view addSubview:lblDateAlert];
     
     [alertController.view addSubview:imageAlert];
     [viewForTextField addSubview:alertTextField1];
     [alertController.view addSubview:viewForTextField];
     [alertController.view addSubview:customView];
     
     UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     [alertController dismissViewControllerAnimated:YES completion:nil];
     [self moveViewUp:NO];
     
     }];
     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Trả lời" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
     [self eventAnswerCMT];
     view.frame = CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame), 50);
     }];
     [alertController addAction:somethingAction];
     [alertController addAction:cancelAction];
     [self presentViewController:alertController animated:YES completion:^{}];
     view.frame = CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame), 50);
    }
    else {
        alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
        alertController.view.translatesAutoresizingMaskIntoConstraints = NO;
        alertController.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
        //Chỉnh màu cho alert
        UIView *subView = alertController.view.subviews.firstObject;
        UIView *alertContentView = subView.subviews.firstObject;
        [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];
         UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 40)];
         customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
         
         UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(100, 5, 100, 25)];
         lblAlert.text = @"TRẢ LỜI";
         lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
         lblAlert.textColor = [UIColor whiteColor];
         [customView addSubview:lblAlert];
         
         UIView *viewForTextField = [[UIView alloc] initWithFrame:CGRectMake(0, 160, 270,40)];
         viewForTextField.backgroundColor = [UIColor colorWithRed:0.808 green:0.847 blue:0.863 alpha:1.00];
         
         alertTextField1 = [[UITextView alloc]initWithFrame:CGRectMake(10,5, 250, 30)];
         alertTextField1.keyboardType = UIKeyboardTypeDefault;
         alertTextField1.backgroundColor = [UIColor whiteColor];
         alertTextField1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
         alertTextField1.layer.masksToBounds = YES;
         alertTextField1.layer.cornerRadius = 5;
         alertTextField1.returnKeyType = UIReturnKeyDone;
         alertTextField1.autocorrectionType = UITextAutocorrectionTypeNo;
         alertTextField1.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
         alertTextField1.textColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
         alertTextField1.delegate = self;
         alertTextField1.scrollEnabled = YES;
         
         UILabel * lblContentAlert = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 250, 50)];
         lblContentAlert.text = [tmpDict objectForKeyedSubscript:@"bodyComment"];
         lblContentAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
         lblContentAlert.numberOfLines = 5;
         lblContentAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
         [alertController.view addSubview:lblContentAlert];
         
         UIImageView * imageAlert = [[UIImageView alloc]initWithFrame:CGRectMake(10, 50, 40, 40)];
         NSString *avatar_user = [tmpDict objectForKeyedSubscript:@"imageCmtt"];
         NSURL *url_avatar=[NSURL URLWithString:avatar_user];
         NSData *data = [NSData dataWithContentsOfURL:url_avatar];
         UIImage *imageP = [UIImage imageWithData:data];
         imageAlert.image = imageP;
         if(imageP == nil){
         imageAlert.image  = [UIImage imageNamed:@"hinhdaidien"];
         }
         imageAlert.layer.masksToBounds = YES;
         imageAlert.layer.cornerRadius = 20;
         imageAlert.layer.borderColor = [[UIColor colorWithRed:0.992 green:0.729 blue:0.157 alpha:1.00]CGColor];
         imageAlert.layer.borderWidth = 2.0;
         
         UILabel * lblNameAlert = [[UILabel alloc]initWithFrame:CGRectMake(60, 50, 200, 25)];
         lblNameAlert.text = [tmpDict objectForKeyedSubscript:@"userPostComment"];
         lblNameAlert.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
         lblNameAlert.numberOfLines = 5;
         lblNameAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
         [alertController.view addSubview:lblNameAlert];
         
         UILabel * lblDateAlert = [[UILabel alloc]initWithFrame:CGRectMake(60, 65, 200, 25)];
         lblDateAlert.text = [tmpDict objectForKeyedSubscript:@"dateComment"];
         lblDateAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
         lblDateAlert.numberOfLines = 5;
         lblDateAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
         [alertController.view addSubview:lblDateAlert];
         
         [alertController.view addSubview:imageAlert];
         [viewForTextField addSubview:alertTextField1];
         [alertController.view addSubview:viewForTextField];
         [alertController.view addSubview:customView];
         
         UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         [alertController dismissViewControllerAnimated:YES completion:nil];
         [self moveViewUp:NO];
         }];
         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Trả lời" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
         [self eventAnswerCMT];
         view.frame = CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame), 50);
         }];
         [alertController addAction:somethingAction];
         [alertController addAction:cancelAction];
         [self presentViewController:alertController animated:YES completion:^{}];
         view.frame = CGRectMake(0,[[UIScreen mainScreen]bounds].size.height - 90, CGRectGetWidth(self.view.frame), 50);
    }
}
//POST CMT
-(void)eventAnswerCMT{
    NSString* detailString1 = alertTextField1.text;
    //convert return key enter to \n in string
    detailString1 = [detailString1 stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    detailString1 = [detailString1 stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if([detailString isEqualToString:@""]){
        NSLog(@"KHÔNG CHO ĐĂNG");
    }
    else {
    [self postComment:idcmt:idSubcmt:detailString1];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, dd' tháng 'MM' năm 'YYYY"];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
    
    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                  alertTextField1.text,@"bodyComment",
                  [dateFormatter stringFromDate:[NSDate date]],@"dateComment",
                  [[NSUserDefaults standardUserDefaults] objectForKey:@"textField1Text"],@"userPostComment",
                  @"NO",@"values",
                  idSubcmt,@"parentvalues",
                  nil];
    [myObject addObject: dictionary];
    NSLog(@"myObject %@",myObject);
    [self sortArray:myObject];
    [_TableViewComment reloadData];
    }
}
//EVENT KEYBOAD
- (void)viewWillDisappear:(BOOL)animated
{
// unregister for keyboard notifications while moving to the other screen.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}
-(void)keyboardFrame:(NSNotification *)notification{
    FrameKeyBoard = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
}

-(void)moveViewUp:(BOOL)bMovedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    CGRect rect = view.frame;
    if (bMovedUp) {
      
        rect.origin.y -= FrameKeyBoard;
        
        
    } else {
        rect.origin.y += FrameKeyBoard;

    }
    view.frame = rect;
    [UIView commitAnimations];
}
-(void)keyboardWillAppear {
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
}
//POST CMT
-(void)postComment:(NSString *)newsComment :(NSString *)idComments :(NSString *)stringComment{
    
    NSString *post =[[NSString alloc] initWithFormat:@"{\"nid\":\"%@\",\"pid\":\"%@\",\"subject\":\"Comment Subject Text\",\"comment_body\":{\"und\":[{\"value\":\"%@\"}]}}",newsComment,idComments,stringComment];
    NSURL *url=[NSURL URLWithString:LINK_POST_CMT];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
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
    [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
}
//POST CMT MAIN
-(void)postComment1:(NSString *)newsComment :(NSString *)stringComment{
    
    NSString *post =[[NSString alloc] initWithFormat:@"{\"nid\":\"%@\",\"subject\":\"Comment Subject Text\",\"comment_body\":{\"und\":[{\"value\":\"%@\"}]}}",newsComment,stringComment];
    NSURL *url=[NSURL URLWithString:LINK_POST_CMT];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
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
    [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
}
NSString* detailString;
//SEND CMT MAIN
-(void)sendCMT:(UIButton *)sender{
    NSString *nId = [[NSUserDefaults standardUserDefaults]objectForKey:@"nid"];
    detailString = txtSendCmt.text;
    /*convert return key enter to \n in string*/
    detailString = [detailString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    detailString = [detailString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSLog(@"detail1 %@",detailString);
    if([detailString isEqualToString:@""]){
        [txtSendCmt resignFirstResponder];
        [self moveViewUp:NO];
    }
    else {
    [self postComment1:nId:detailString];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, dd' tháng 'MM' năm 'YYYY"];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
    
    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                  txtSendCmt.text,@"bodyComment",
                  [dateFormatter stringFromDate:[NSDate date]],@"dateComment",
                  [[NSUserDefaults standardUserDefaults] objectForKey:@"textField1Text"],@"userPostComment",
                  @"YES",@"values",
                  nil];
    [myObject addObject: dictionary];
    [self sortArray:myObject];
    [_TableViewComment reloadData];
    [txtSendCmt resignFirstResponder];
    [self moveViewUp:NO];
    [self alertController];
    
    }
}

-(void)alertController {
    UIAlertController *alertController1 = [UIAlertController alertControllerWithTitle:@"\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
    alertController1.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 40)];
    customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
    
    UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(90, 5, 100, 25)];
    lblAlert.text = @"Thông báo";
    lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    lblAlert.textColor = [UIColor whiteColor];
    [customView addSubview:lblAlert];
    
    /*Chỉnh màu cho alert*/
    UIView *subView = alertController1.view.subviews.firstObject;
    UIView *alertContentView = subView.subviews.firstObject;
    [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];
    /**/
    
    UILabel * lblContentAlert = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 250, 50)];
    lblContentAlert.text = @"Bạn đã bình luận thành công!";
    lblContentAlert.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    lblContentAlert.numberOfLines = 1;
    lblContentAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
    [alertController1.view addSubview:lblContentAlert];
    [alertController1.view addSubview:customView];
    
    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController1 dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController1 addAction:somethingAction];
    [self presentViewController:alertController1 animated:YES completion:^{}];
    
}
@end
