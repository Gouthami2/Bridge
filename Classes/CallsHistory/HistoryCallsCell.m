//
//  HistoryCallsCell.m
//  linphone
//
//  Created by Gouthami Reddy on 17/11/18.
//

#import "HistoryCallsCell.h"

@implementation HistoryCallsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
- (void)update:(LinphoneCallLog *)callLog {
    
    if (callLog == NULL) {
        LOGW(@"Cannot update history cell: null callLog");
        return;
    }
    
    // outgoing cell...
    const LinphoneAddress *addr = linphone_call_log_get_to_address(callLog);
    UIImage *image = [UIImage imageNamed:@"ic_outgoingCall"];
    
    // incoming call...
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        if (linphone_call_log_get_status(callLog) != LinphoneCallMissed) {
            image = [UIImage imageNamed:@"ic_incomingCall"];
        } else {
            image = [UIImage imageNamed:@"ic_missedCall"];
        }
        addr = linphone_call_log_get_from_address(callLog);
    }
    self.img_callState.image = image;
    
    // user name...
    [ContactDisplay setDisplayNameLabel:self.lbl_name forAddress:addr];
    size_t count = bctbx_list_size(linphone_call_log_get_user_data(callLog)) + 1;
    if (count > 1) {
        self.lbl_name.text = [self.lbl_name.text stringByAppendingString:[NSString stringWithFormat:@" (%lu)", count]];
    }

    
    // [self.img_avatar setImage:[FastAddressBook imageForAddress:addr] bordered:NO withRoundedRadius:YES];
}

#pragma mark - ButtonActions
- (IBAction)detailButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(detailsClicked:cell:)]) {
        [self.delegate detailsClicked:sender cell:self];
    }
}

- (IBAction)checkboxButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(checkboxClicked:cell:)]) {
        [self.delegate checkboxClicked:sender cell:self];
    }
}
@end
