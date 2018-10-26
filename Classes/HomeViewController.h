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


- (IBAction)callHistory:(id)sender;
-(IBAction)Contacts:(id)sender;
-(IBAction)settingsicon:(id)sender;
- (IBAction)DailerMenu:(id)sender;
- (IBAction)ChatPlus:(id)sender;
- (IBAction)VideoConference:(id)sender;
- (IBAction)TextMessaging:(id)sender;
- (IBAction)conferenceCall:(id)sender;
@end


