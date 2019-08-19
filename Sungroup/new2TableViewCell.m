//
//  new2TableViewCell.m
//  Sungroup
//
//  Created by Võ Duy Hùng  on 6/30/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "new2TableViewCell.h"

@implementation new2TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void) setFrame:(CGRect)frame
{
    float inset = 6.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 *inset;
    [super setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
