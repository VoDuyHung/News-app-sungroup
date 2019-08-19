//
//  News_TableViewCell.m
//  Sungroup
//
//  Created by Toan Nguyen Duc on 3/24/16.
//  Copyright (c) 2016 DUY TAN. All rights reserved.
//

#import "News_TableViewCell.h"

@implementation News_TableViewCell{
    
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
-(void)webViewDidStartLoad:(UIWebView *)webView{
    _loadView.backgroundColor = [UIColor redColor];
    NSLog(@"load web");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"load web");
}

@end
