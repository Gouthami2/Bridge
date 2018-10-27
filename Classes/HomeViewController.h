//
//  HomeViewController.h
//  linphone
//
//  Created by Gouthami Reddy on 10/25/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"


@interface HomeViewController : UIViewController <UICompositeViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *colour;
@property (strong, nonatomic) IBOutlet UIImageView *bridgeicon1;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *contacts;
@property (strong, nonatomic) IBOutlet UIButton *videoConference;

@property (strong, nonatomic) IBOutlet UIButton *callHistory;
@property (strong, nonatomic) IBOutlet UIButton *chatPlus;

@property (strong, nonatomic) IBOutlet UIButton *textMessaging;

@property (strong, nonatomic) IBOutlet UIButton *conferenceCall;
@property (strong, nonatomic) IBOutlet UIButton *About;
@property (strong, nonatomic) IBOutlet UIButton *logout;


@end


