//
//  SearchTableViewController.m
//  Sungroup
//
//  Created by Võ Duy Hùng  on 6/27/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "SearchTableViewController.h"
#import "TableViewCell.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "UIScrollView+EmptyDataSet.h"
#define LINK_SEARCH @"https://cms.sungroup.com.vn/api/search/search_node/retrieve.json?keys=%@"
@interface SearchTableViewController ()<UISearchBarDelegate,NSXMLParserDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
// UISearchBarDelegate    : delegate for searchBarTextDidEndEditing
// UISearchDisplayDelegate : delegate for display searchBar
// NSXMLParserDelegate     : delegate for convertEntiesInString
// MBProgressHUDDelegate   : for progressHud
// UIScrollView+EmptyDataSet : empty table

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableString const * resultStringg;//đổi retain thành copy
- (NSString *)convertEntiesInString:(NSString*)convertString;
@end

@implementation SearchTableViewController{
    NSArray const*tableData,*begin;
    NSString const*titleSearch,*snippetSearch,*createdSearch,* nameSearch, *contentSearch;
    NSMutableArray *myObject;
    UILabel * lbl;
    NSMutableDictionary *dictionary;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//ADD SWIPE EVENT
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.emptyDataSetSource = self;
    self.table.emptyDataSetDelegate = self;
//INITIALIZATION SEARCHBAR
     self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
     self.searchBar.delegate = self;
     self.searchBar.searchBarStyle = UISearchBarIconSearch;
     self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
     self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
     self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
     self.searchBar.keyboardType = UIKeyboardTypeDefault;
     self.searchBar.returnKeyType = UIReturnKeySearch;
     self.searchBar.placeholder=@"Tìm kiếm";
     self.searchBar.barTintColor = [UIColor whiteColor];
     self.searchBar.tintColor = [UIColor whiteColor];
    [[UITextField appearanceWhenContainedIn:[self.searchBar class], nil]setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [ self.searchBar setBackgroundColor:[UIColor colorWithRed:0.235 green:0.314 blue:0.349 alpha:1.00]];
    [self.view addSubview: self.searchBar];
    [[UINavigationBar appearance]setShadowImage:[UIImage new]];
//INITIALIZATION BUTTON BAR
    UIButton *btn_back =  [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_back setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [btn_back setFrame:CGRectMake(0, 0, 20, 20)];
    [btn_back addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    UILabel *lbl_Title = [[UILabel alloc]init];
    lbl_Title.frame = CGRectMake(0, 0, 300, 20);
    lbl_Title.text = @"TÌM KIẾM";
    [lbl_Title setTextAlignment:NSTextAlignmentLeft];
    lbl_Title.textColor = [UIColor whiteColor];
    [lbl_Title setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    UIBarButtonItem *menuItemButton= [[UIBarButtonItem alloc] initWithCustomView:lbl_Title];
    NSArray *arrayButtonLeft= [[NSArray alloc] initWithObjects:barButton,menuItemButton, nil];
    self.navigationItem.leftBarButtonItems=arrayButtonLeft;
//turn off border for navigationbar
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//REGISTER CELL XID
    [_table registerNib:[UINib nibWithNibName:@"Search_tableviewcell" bundle:nil] forCellReuseIdentifier:@"Search_tableviewcell"];
}
//EVENT SWIPE LEFT TO RIGHT
-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        [UIView animateWithDuration:0.3 animations:^{
            CGPoint Position = CGPointMake(self.view.frame.origin.x + 100.0, self.view.frame.origin.y);
            self.view.frame = CGRectMake(Position.x , Position.y , self.view.frame.size.width, self.view.frame.size.height);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}
//EVENT SEARCH BUTTON
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [ self.searchBar  setSearchResultsButtonSelected:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud.label.text = NSLocalizedString(@"Đang tìm kiếm...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ self.searchBar  resignFirstResponder];
            [_table reloadData];
            [hud hideAnimated:YES];
        });
    });
   
}
//EVENT BACK BUTTON

-(void)backButton:(UIButton*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//SEARCH WHEN EDIT TEXT
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [lbl removeFromSuperview];
    [[UITextField appearanceWhenContainedIn:[self class], nil]setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [self.searchBar resignFirstResponder];
    Reachability *reachTest = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [reachTest  currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){  //Check connection internet 
        UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Không có kết nối Internet.Hãy bật WIFI hoặc 3G để ứng dụng hoạt động!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK acction") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        myObject = [[NSMutableArray alloc]init];
        NSString *searchText = searchBar.text;
        NSString* urlString;
        NSError * error = nil;
        urlString = [NSString  stringWithFormat: LINK_SEARCH,searchText];
        NSString *urltextEscaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL*url = [NSURL URLWithString:urltextEscaped];
        NSData * data=[NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if(data == nil){
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else {
            NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &error];
            titleSearch = @"title";
            snippetSearch = @"snippet";
            createdSearch = @"date";
            nameSearch = @"nameSearch";
            contentSearch = @"content";
            for(NSDictionary * tmp in json){
                @try{
                NSString * title = [tmp valueForKey:@"title"];
                NSString * snippet = [tmp valueForKey:@"snippet"];
                int createDate = [[tmp objectForKey:@"created"] intValue];
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"' - 'dd'/'MM'/'YYYY' - 'HH:mm"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:createDate];
                [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"vi_VN"]];
                NSString *formattedDateString = [[dateFormatter stringFromDate:date]capitalizedString];
                NSString * nameValue = [tmp valueForKey:@"node"][@"name"];
                NSString * content;
               content =[tmp valueForKey:@"node"][@"body"][@"und"][0][@"value"];
                dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              title,titleSearch,
                              snippet,snippetSearch,
                              formattedDateString,createdSearch,
                              nameValue,nameSearch,
                              content,contentSearch,
                              nil];
                if ([dictionary objectForKeyedSubscript:contentSearch]==NULL){
                    dictionary = NULL;
                }
                [myObject addObject:dictionary];
                [myObject removeObjectIdenticalTo:[NSNull null]];
                    
                }
                
                @catch (NSException *exception) {
                    NSLog(@"EXCEPTION %@",exception);
                }
            }
        }
    }
    if([myObject count] == 0){
        lbl =[[UILabel alloc]initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.table.bounds), 20)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        NSString * text1 = [NSString stringWithFormat:@"Tìm thấy %ld kết quả \"%@\"",(unsigned long)[myObject count],[self.searchBar text]];
        NSString * text = [NSString stringWithFormat:@"%@", text1];
        lbl.text = text;
        [self.table addSubview:lbl];
    }
     [self.searchBar setText:@""];
}
//event for return key done or or of keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSUserDefaults *defaults2=[NSUserDefaults standardUserDefaults];
    NSString *key1= @"1";
    [defaults2 setObject:key1 forKey:@"nullTable"];
    [defaults2 synchronize];
    return YES;
}
/*Empty Data in tableView*/
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{   UIEdgeInsets edgeInset = UIEdgeInsetsMake(100,100, 100, 100);
    UIImage * img = [[UIImage imageNamed:@"1474438738_Document"] resizableImageWithCapInsets:edgeInset resizingMode:UIImageResizingModeStretch];
    return img;
}
/*- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
//turnoff border of navigationbar
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    NSString * text1,*text;
    NSDictionary *attributes;
    if([myObject count] == 0){
        
        text1 = [NSString stringWithFormat:@"Tìm thấy %ld kết quả \"%@\"",(unsigned long)[myObject count],[self.searchBar text]];
        text = [NSString stringWithFormat:@"%@", text1];
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentCenter;
        attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
                                     NSForegroundColorAttributeName: [UIColor colorWithRed:0.655 green:0.714 blue:0.741 alpha:1.00],
                                     NSParagraphStyleAttributeName: paragraph};
    }
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}*/
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor colorWithRed:0.271 green:0.349 blue:0.388 alpha:1.00];
}
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
// ẩn bàn phím khi sửa xong
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.searchBar endEditing:YES];
    [self searchBarTextDidEndEditing:self.searchBar];
    [self.searchBar resignFirstResponder];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [myObject count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
// static NSString *simpleTableIdentifier = @"small";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Search_tableviewcell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Search_tableviewcell"];
    }
    NSDictionary * tmpdict= [myObject objectAtIndex:indexPath.section];
//add data to TITLE
    cell.titleSearch.text = [tmpdict objectForKeyedSubscript:titleSearch];
//add data to NAME_DATE
    NSString * datetime = [tmpdict objectForKeyedSubscript:createdSearch];
    NSString * nameCreate = [tmpdict objectForKeyedSubscript:nameSearch];
    NSString * nameCreate_datetime = [nameCreate stringByAppendingString:datetime];
    cell.emailSearch.text = nameCreate_datetime;
//add data to SNIPPET
    NSString *string = [tmpdict objectForKeyedSubscript:snippetSearch];
    SearchTableViewController *converter = [[SearchTableViewController alloc]init];
// convert html -> string
    NSString *str2 =[converter convertEntiesInString:string];
    cell.contentSearch.text = str2;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.contentColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
    hud.label.text = NSLocalizedString(@"Đang tải nội dung...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *tmpDict1 = [myObject objectAtIndex:indexPath.section];
            NSUserDefaults *defaults1=[NSUserDefaults standardUserDefaults];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:contentSearch] forKey:@"content_post"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:titleSearch] forKey:@"TitlePost"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:createdSearch] forKey:@"date"];
            [defaults1 setObject:[tmpDict1 objectForKeyedSubscript:nameSearch] forKey:@"nameSearch"];
            NSString *key= @"timkiem";
            [defaults1 setObject:key forKey:@"KEY"];
            [defaults1 synchronize];
            [self performSegueWithIdentifier:@"contentSearch" sender:self];
            [hud hideAnimated:YES];
        });
    });
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 40 ;
    }
    return 5;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerResult;
    if(section == 0){
    headerResult = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.table.frame), 40)];
    UILabel * lableResult = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.table.frame), headerResult.frame.size.height)];
    NSString * text = [NSString stringWithFormat:@"Tìm thấy %ld kết quả",(unsigned long)[myObject count]];
    lableResult.text = text;
    lableResult.textAlignment = UIStackViewAlignmentCenter;
    lableResult.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [headerResult addSubview:lableResult];
    }
    return headerResult;
}
@end
