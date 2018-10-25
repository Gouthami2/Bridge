//
//  HomeViewController.m
//  linphone
//
//  Created by Gouthami Reddy on 10/25/18.
//

#import "HomeViewController.h"

#import "PhoneMainView.h"
#import "UICompositeView.h"

@implementation HomeViewController

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                //tabBar:TabBarView.class
                                                                 tabBar:nil
                                                               sideMenu:SideMenuView.class
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription { 
    return self.class.compositeViewDescription;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)DailerMenu:(id)sender {
}
- (IBAction)settingsView:(id)sender {
}
- (IBAction)contacts:(id)sender {
}
- (IBAction)callHistory:(id)sender {
}
- (IBAction)chatPlus:(id)sender {
}
- (IBAction)textMessaging:(id)sender {
}
- (IBAction)videoConference:(id)sender {
}
- (IBAction)conferenceCalls:(id)sender {
}




@end
