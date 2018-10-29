//
//  HomeViewController.h
//  linphone
//
//  Created by Gouthami Reddy on 10/25/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"


@interface HomeViewController : UIViewController <UICompositeViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIImageView *colour;
@property (strong, nonatomic) IBOutlet UIImageView *bridgeicon;
@property (strong, nonatomic) IBOutlet UIButton *DailerMenu;
@property (strong, nonatomic) IBOutlet UIButton *settingsicon;
@property (strong, nonatomic) IBOutlet UIButton *contacts;
@property (strong, nonatomic) IBOutlet UILabel *contactsLabel;
@property (strong, nonatomic) IBOutlet UIButton *callHistory;
@property (strong, nonatomic) IBOutlet UILabel *callHistoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *chatPlus;
@property (strong, nonatomic) IBOutlet UILabel *chatPlusLabel;
@property (strong, nonatomic) IBOutlet UIButton *textMessaging;
@property (strong, nonatomic) IBOutlet UILabel *textMessagingLabel;
@property (strong, nonatomic) IBOutlet UIButton *conferenceCall;
@property (strong, nonatomic) IBOutlet UILabel *conferenceCallLable;
@property (strong, nonatomic) IBOutlet UIButton *videoConference;
@property (strong, nonatomic) IBOutlet UILabel *videoConferenceLabel;
@property (strong, nonatomic) IBOutlet UIButton *aboutClicked;

@property (strong, nonatomic) IBOutlet UILabel *AboutLabel;
@property (strong, nonatomic) IBOutlet UIButton *logout;
@property (strong, nonatomic) IBOutlet UILabel *logoutLabel;
@property (strong, nonatomic) IBOutlet UIStackView *contactsStack;
@property (strong, nonatomic) IBOutlet UIStackView *callHistoryStack;
@property (strong, nonatomic) IBOutlet UIStackView *chatPlusStack;
@property (strong, nonatomic) IBOutlet UIStackView *textMessagingStack;
@property (strong, nonatomic) IBOutlet UIStackView *conferenceCallStack;
@property (strong, nonatomic) IBOutlet UIStackView *videoConferenceStack;
@property (strong, nonatomic) IBOutlet UIStackView *aboutStack;
@property (strong, nonatomic) IBOutlet UIStackView *logoutStack;
@property (strong, nonatomic) IBOutlet UIView *contactsView;
@property (strong, nonatomic) IBOutlet UIView *callHistoryView;
@property (strong, nonatomic) IBOutlet UIView *chatPlusView;
@property (strong, nonatomic) IBOutlet UIView *textMessagingview;
@property (strong, nonatomic) IBOutlet UIView *conferenceCallView;
@property (strong, nonatomic) IBOutlet UIView *videoConferenceView;
@property (strong, nonatomic) IBOutlet UIView *AboutView;
@property (strong, nonatomic) IBOutlet UIView *logoutView;


@end


