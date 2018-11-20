//
//  AgencyHistoryCallsCell.h
//  linphone
//
//  Created by Gouthami Reddy on 19/11/18.
//

#import <UIKit/UIKit.h>

@interface AgencyHistoryCallsCell : UITableViewCell

// outlets...
@property (weak, nonatomic) IBOutlet UIImageView *img_avatar;
@property (weak, nonatomic) IBOutlet UIImageView *img_callState;

@property (weak, nonatomic) IBOutlet UILabel *lbl_fromName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_toName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UILabel *lbl_duration;

@end
