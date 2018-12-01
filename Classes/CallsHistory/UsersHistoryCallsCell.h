//
//  UsersHistoryCallsCell.h
//  linphone
//
//  Created by Gouthami Reddy on 11/29/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// protocol declear...
@protocol UsersHistoryCallsCellDelegate;

@interface UsersHistoryCallsCell : UITableViewCell

// outlets...
@property (weak, nonatomic) IBOutlet UIImageView *img_avatar;
@property (weak, nonatomic) IBOutlet UIImageView *img_callState;

@property (weak, nonatomic) IBOutlet UILabel *lbl_toName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UILabel *lbl_duration;

// elements...
@property (weak, nonatomic) id <UsersHistoryCallsCellDelegate> delegate;

@end


// protocol...
@protocol UsersHistoryCallsCellDelegate <NSObject>
- (void)callerDialButtonClicked:(UIButton *)button cell:(UsersHistoryCallsCell *)cell;
@end

NS_ASSUME_NONNULL_END
