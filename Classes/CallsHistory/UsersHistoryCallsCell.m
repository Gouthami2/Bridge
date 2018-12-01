//
//  UsersHistoryCallsCell.m
//  linphone
//
//  Created by Gouthami Reddy on 11/29/18.
//

#import "UsersHistoryCallsCell.h"

@implementation UsersHistoryCallsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)callerDialButtonClicked:(UIButton *)sender {
    
    if([self.delegate respondsToSelector:@selector(callerDialButtonClicked:cell:)]) {
        [self.delegate callerDialButtonClicked:sender cell:self];
    }
}

@end
