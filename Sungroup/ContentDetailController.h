//
//  ContentDetailController.h
//  Sungroup
//
//  Created by Võ Duy Hùng  on 6/23/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellContentCell.h"
@interface ContentDetailController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *myContentSize;
@property (weak, nonatomic) IBOutlet UIView *ViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *TitlePost;
@property (weak, nonatomic) IBOutlet UILabel *DatePost;


@end
