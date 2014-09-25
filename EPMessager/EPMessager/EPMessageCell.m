//
//  EPMessageCell.m
//  EPMessager
//
//  Created by Leo Reubelt on 9/25/14.
//  Copyright (c) 2014 ENHATCH. All rights reserved.
//

#import "EPMessageCell.h"

@implementation EPMessageCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setupMessageLabel];
}

#pragma mark - Setup Views

- (void)setupMessageLabel
{
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
    self.textLabel.font = [UIFont systemFontOfSize:16];
}

@end
