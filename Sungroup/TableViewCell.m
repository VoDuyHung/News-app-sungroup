//
//  TableViewCell.m
//  Sungroup
//
//  Created by Võ Duy Hùng  on 6/27/16.
//  Copyright © 2016 DUY TAN. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}
//LUI CELL VAO 5.0
-(void) setFrame:(CGRect)frame
{
    float inset = 5.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 *inset;
    [super setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
