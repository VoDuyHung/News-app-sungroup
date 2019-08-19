//
//  News_TableViewCell.h
//  Sungroup
//
//  Created by Toan Nguyen Duc on 3/24/16.
//  Copyright (c) 2016 DUY TAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface News_TableViewCell : UITableViewCell <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *img_thum;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_content;
@property (weak, nonatomic) IBOutlet UILabel *lbl_email;

@property (weak, nonatomic) IBOutlet UILabel *lbl_view;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIWebView *loadView;


@end
