//
//  TableViewCell.h
//  Sungroup
//
//  Created by Võ Duy Hùng  on 6/27/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageSearch;
@property (weak, nonatomic) IBOutlet UILabel *titleSearch;
@property (weak, nonatomic) IBOutlet UILabel *contentSearch;
@property (weak, nonatomic) IBOutlet UILabel *ViewSearch;
@property (weak, nonatomic) IBOutlet UILabel *emailSearch;

@end
