//
//  CellContentCell.m
//  Sungroup
//
//  Created by Võ Duy Hùng  on 7/29/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "CellContentCell.h"

@implementation CellContentCell

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
