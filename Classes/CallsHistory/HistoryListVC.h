//
//  HistoryListVC.h
//  linphone
//
//  Created by Gouthami Reddy on 17/11/18.
//

#import <UIKit/UIKit.h>

#import "PhoneMainView.h"
#import "UICompositeView.h"

@interface HistoryListVC : UIViewController <UICompositeViewDelegate>

// outlets...
@property (weak, nonatomic) IBOutlet UIView *view_callsTopMenu;
@property (weak, nonatomic) IBOutlet UIView *view_callsDeleteMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_selectedLine;
@property (weak, nonatomic) IBOutlet UITableView *tbl_callList;
@property (strong, nonatomic) IBOutlet UIIconButton *btn_edit;

- (IBAction)deleteMenuButtonsClicked:(UIButton *)sender;
- (IBAction)callsMenuButtonsClicked:(UIButton *)sender;

@end
