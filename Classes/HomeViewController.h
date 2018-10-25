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
@property (strong, nonatomic) IBOutlet UIImageView *bridgeIcon;


- (IBAction)contacts:(id)sender;
- (IBAction)callHistory:(id)sender;
- (IBAction)chatPlus:(id)sender;
- (IBAction)textMessaging:(id)sender;
- (IBAction)videoConference:(id)sender;
- (IBAction)conferenceCalls:(id)sender;
- (IBAction)DailerMenu:(id)sender;
- (IBAction)settingsView:(id)sender;

@end


