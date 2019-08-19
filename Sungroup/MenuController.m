//
//  DanhBaController.m
//  Sungroup
//
//  Created by DUY TAN on 18/3/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "MenuController.h"
#import "ViewController.h"
#import "MBProgressHUD.h"
#import "QuartzCore/QuartzCore.h"

@interface MenuController ()<MBProgressHUDDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    BOOL showMenu;
    NSMutableArray const*Title, *img, *imgname, *arrayForBool;
    NSMutableDictionary const* sectionContentDict;
    NSString const*TitleName;
    UIButton * btn_Top;
    UIActivityIndicatorView *spinner;
    UIView *loadingView;
    UILabel *loadingLabel;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!Title) {
      Title = [[NSMutableArray alloc ] initWithObjects:@"",@"Tin tức",@"Thông tin",@"Đăng xuất",nil];
    }
    if(!arrayForBool){
        arrayForBool = [NSMutableArray arrayWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],
                        [NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],nil];
    }
    if(!sectionContentDict){
        sectionContentDict = [[NSMutableDictionary alloc] init];
    }
    if(!imgname){
     imgname = [[NSMutableArray alloc]initWithObjects:@"",@"Tintuc",@"info_60",@"Dangxuat" ,nil];
    }
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return Title.count;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([[arrayForBool objectAtIndex:section]boolValue]){
        return [[sectionContentDict valueForKey:[Title objectAtIndex:section]] count];
    }
    if(section == 0 && section == 3){
        return 0;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellIdentifile = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifile];
    if(cell == Nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifile];
    }
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    BOOL manyCells  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
    if (!manyCells) {
        cell.textLabel.text = @"hung";
    }
    else{
        NSArray *content = [sectionContentDict valueForKey:[Title objectAtIndex:indexPath.section]];
        cell.textLabel.text = [content objectAtIndex:indexPath.row];
        UIFont *myfont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        cell.textLabel.font = myfont;
        cell.textLabel.textColor = [UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1.00];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section ==0){
    return 100;
    }
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{   UIView *headerView,* HVSection0;
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.tag = section;
    UILabel *headerString = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width-20-50, 50)];
    [[arrayForBool objectAtIndex:section] boolValue];
    
    headerString.text = [Title objectAtIndex:section];
    headerString.textAlignment = NSTextAlignmentLeft;
    headerString.textColor = [UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1.00];
    headerString.font = [UIFont fontWithName: @"HelveticaNeue-Light" size:14];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17,17, 15 , 15)];
    imageView.image= [UIImage imageNamed:[imgname objectAtIndex:section]];
    // create separator for header
    CGRect setFrame = CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1);
    UIView * seperatorView = [[UIView alloc]initWithFrame:setFrame];
    seperatorView.backgroundColor = [UIColor colorWithRed:0.271 green:0.349 blue:0.388 alpha:1.00];
    
    [headerView addSubview:imageView];
    [headerView addSubview:headerString];
    [headerView addSubview:seperatorView];
    
    
    if(section == 0){
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString * name = [defaults valueForKey:@"textField1Text"];
        HVSection0 = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,150)];
        //image cho slide menu
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17,30, 50 , 50)];
        imageView.layer.cornerRadius=imageView.bounds.size.width/2;
        imageView.layer.borderWidth=1.5;
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderColor=[[UIColor colorWithRed:1.000 green:0.733 blue:0.157 alpha:1.00] CGColor];
        imageView.layer.backgroundColor = [[UIColor whiteColor]CGColor];
        imageView.image = [UIImage imageNamed:@"hinhdaidien"];
        [HVSection0 addSubview:imageView];
        //username
        UILabel *headerLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(75,25, HVSection0.frame.size.width, 50.0)];
        headerLabel2.textColor=[UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1.00];
        headerLabel2.font = [UIFont fontWithName: @"HelveticaNeue-Medium" size:14];
        headerLabel2.text = name;
        [HVSection0 addSubview:headerLabel2];
        //email
        UILabel *headerLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(75,40, HVSection0.frame.size.width, 50.0)];
        headerLabel3.textColor=[UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1.00];
        //headerLabel3.text = mail;
        headerLabel3.font = [UIFont fontWithName: @"HelveticaNeue" size:11];
        // create separator for header
        CGRect setFrame1 = CGRectMake(0, 101, HVSection0.frame.size.width, 1);
         UIView * seperatorView1 = [[UIView alloc]initWithFrame:setFrame1];
         seperatorView1.backgroundColor = [UIColor colorWithRed:0.271 green:0.349 blue:0.388 alpha:1.00];
        
        [HVSection0 addSubview:headerLabel3];
        [HVSection0 addSubview:seperatorView1];
        return HVSection0;
        
    }

    UITapGestureRecognizer *headerTapped= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [headerView addGestureRecognizer:headerTapped];
    if(section == 3){
        seperatorView.hidden = YES;
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        collapsed       = !collapsed;
        [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
        //reload specific section animated
        NSRange range   = NSMakeRange(indexPath.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    if(indexPath.section == 1){
        loadingView = [[UIView alloc]initWithFrame:CGRectMake(85, 175, 150, 110)];
        loadingView.backgroundColor = [UIColor whiteColor];
        loadingView.clipsToBounds = YES;
        loadingView.layer.cornerRadius = 10.0;
        
        loadingLabel = [[UILabel alloc ]initWithFrame:CGRectMake(10, 70, 130, 22)];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textColor = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
        loadingLabel.text = @"Đợi tải tin..";
        loadingLabel.adjustsFontSizeToFitWidth = YES;
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.color = [UIColor colorWithRed:0.145 green:0.208 blue:0.247 alpha:1.00];
        spinner.frame = CGRectMake(55, 10, spinner.bounds.size.width, spinner.bounds.size.height);
        [self performSegueWithIdentifier:@"news" sender:self];
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:5];
        [loadingView addSubview:spinner];
        [loadingView addSubview:loadingLabel];
        [self.view addSubview:loadingView];
        [spinner startAnimating];
    }
    if(indexPath.section == 2){
        [self performSegueWithIdentifier:@"newempl" sender:self];
    }
    if(indexPath.section == 3){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
        alertController.view.tintColor = [UIColor colorWithRed:0.165 green:0.235 blue:0.267 alpha:1.00];
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 40)];
        customView.backgroundColor = [UIColor colorWithRed:0.200 green:0.275 blue:0.318 alpha:1.00];
        
        UILabel * lblAlert = [[UILabel alloc]initWithFrame:CGRectMake(100, 5, 100, 25)];
        lblAlert.text = @"Đăng Xuất";
        lblAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        lblAlert.textColor = [UIColor whiteColor];
        [customView addSubview:lblAlert];
        
        /*Chỉnh màu cho alert*/
        UIView *subView = alertController.view.subviews.firstObject;
        UIView *alertContentView = subView.subviews.firstObject;
        [alertContentView setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1]];
        /**/
        
        UILabel * lblContentAlert = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 250, 50)];
        lblContentAlert.text = @"Bạn có muốn đăng xuất tài khoản ?";
        lblContentAlert.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        lblContentAlert.numberOfLines = 1;
        lblContentAlert.textColor = [UIColor colorWithRed:0.239 green:0.310 blue:0.353 alpha:1.00];
        [alertController.view addSubview:lblContentAlert];
        [alertController.view addSubview:customView];
        
        UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Không" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Đăng xuất" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"valuecc"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"namecc"];
            ViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"logout1"];
            [self presentViewController:login animated:YES completion:nil];
        
        }];
        [alertController addAction:somethingAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
}
-(void)removeFromSuperview
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [loadingView removeFromSuperview];
}
@end
