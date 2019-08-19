//
//  NewEmployee_TableViewController.m
//  Sungroup
//
//  Created by Toan Nguyen Duc on 3/25/16.
//  Copyright (c) 2016 DUY TAN. All rights reserved.
//

#import "NewEmployee_TableViewController.h"
#import "SWRevealViewController.h"

@interface NewEmployee_TableViewController ()
@property (nonatomic) NSArray const*namesArray;
@property (nonatomic) NSArray const*chitietArray;
@property (nonatomic) NSArray const*DonViArray;
@end

@implementation NewEmployee_TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //menu button
    self.tableView.separatorColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1.00];
    _tableViewEmpl.backgroundColor = [UIColor colorWithRed:0.898 green:0.922 blue:0.937 alpha:1.00];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"60-1"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UILabel *lbl_Title = [[UILabel alloc]init];
    lbl_Title.frame = CGRectMake(0, 0, 300, 20);
    lbl_Title.text = @"THÔNG TIN";
    [lbl_Title setTextAlignment:NSTextAlignmentLeft];
    lbl_Title.textColor = [UIColor whiteColor];
    [lbl_Title setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    UIBarButtonItem *menuItemButton= [[UIBarButtonItem alloc] initWithCustomView:lbl_Title];
    NSArray *arrayButtonLeft= [[NSArray alloc] initWithObjects:barButton,menuItemButton, nil];
    self.navigationItem.leftBarButtonItems=arrayButtonLeft;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    //search button
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17],NSForegroundColorAttributeName:[UIColor whiteColor]};
    //khai báo table
     [_tableViewEmpl registerNib:[UINib nibWithNibName:@"AboutCellXib" bundle:nil] forCellReuseIdentifier:@"About"];

    self.namesArray = @[@"Tên chương trình",@"Phiên bản",@"Ngày cập nhật",@"Chức năng",@"Tác giả"];
    
    self.chitietArray= @[@"Truyền thông nội bộ Sun Group",@"2.1.1",@"31/10/2016",@"Truyền thông nội bộ Sun Group",@"Ban CNTT & BTT"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.namesArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellNewEmployee_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"About" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(indexPath.row == 0){
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    cell.backgroundColor = [UIColor colorWithRed:0.898 green:0.922 blue:0.937 alpha:1.00];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = self.namesArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    cell.detailTextLabel.text = self.chitietArray[indexPath.row];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * viewheader = [[UIView alloc]initWithFrame:CGRectMake(0, 0,_tableViewEmpl.frame.size.width, 130)];
    viewheader.backgroundColor = [UIColor colorWithRed:0.180 green:0.251 blue:0.286 alpha:1.00];
    UIImageView * LogoSunGroup = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"600"]];
    LogoSunGroup.frame = CGRectMake(10, 20, 120, 100);
    
    UIView * viewInfo = [[UIView alloc]init];
    UIImageView * iconPin = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"60_add"]];
    iconPin.frame = CGRectMake(13, 33, 10, 10);
    UILabel * Address = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, 170, 30)];
    Address.textColor = [UIColor whiteColor];
    Address.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    Address.text = @"Tầng 7, Toà nhà ACB \n218 Bạch Đằng, TP.Đà Nẵng";
    Address.numberOfLines = 2;
    
    UIImageView * iconPhone = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"60_phone"]];
    iconPhone.frame = CGRectMake(12, 70, 10, 10);
    
    UILabel * numberPhone = [[UILabel alloc]initWithFrame:CGRectMake(30, 65, 170, 30)];
    numberPhone.textColor = [UIColor whiteColor];
    numberPhone.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    numberPhone.text = @"+84 511 3819 181 \n+84 511 3819 182";
    numberPhone.numberOfLines = 2;
    
    [viewInfo addSubview:iconPhone];
    [viewInfo addSubview:numberPhone];
    [viewInfo addSubview:Address];
    [viewInfo addSubview:iconPin];
    
    
    [viewheader addSubview:viewInfo];
    [viewheader addSubview:LogoSunGroup];
    
    [LogoSunGroup setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewInfo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:LogoSunGroup
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:viewheader
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:20]];
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:LogoSunGroup
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:viewheader
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:10]];
   [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:LogoSunGroup
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:viewheader
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:-10]];
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:LogoSunGroup
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:0
                                                          multiplier:1.0
                                                            constant:120]];
    
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:viewInfo
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:viewheader
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:10]];
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:viewInfo
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:viewheader
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:10]];
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:viewInfo
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:viewheader
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:-10]];
    [viewheader addConstraint:[NSLayoutConstraint constraintWithItem:viewInfo
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:LogoSunGroup
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:0]];

    return viewheader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 140;
}
@end
