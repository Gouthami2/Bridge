//
//  HistoryCallsCell.h
//  linphone
//
//  Created by Gouthami Reddy on 17/11/18.
//

#import <UIKit/UIKit.h>

// protocol declear...
@protocol HistoryCallsCellDelegate;


// interface...
@interface HistoryCallsCell : UITableViewCell

@property (weak, nonatomic) id <HistoryCallsCellDelegate> delegate;
- (void)update:(LinphoneCallLog *)callLog;

// outlets...
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UIImageView *img_avatar;
@property (weak, nonatomic) IBOutlet UIImageView *img_callState;
@property (strong, nonatomic) IBOutlet UIButton *btn_checkbox;

// actions..
- (IBAction)detailButtonClicked:(UIButton *)sender;
- (IBAction)checkboxButtonClicked:(UIButton *)sender;

@end


// protocol
@protocol HistoryCallsCellDelegate<NSObject>

- (void)detailsClicked:(UIButton *)button cell:(HistoryCallsCell *)cell;
- (void)checkboxClicked:(UIButton *)button cell:(HistoryCallsCell *)cell;

@end
