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
                                                              //statusBar:StatusBarView.class
                                                              statusBar:nil
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 600);
}

- (IBAction)DailerMenu:(id)sender {
    [PhoneMainView.instance popToView:DialerView.compositeViewDescription];
}
- (IBAction)settingsicon:(id)sender {
     [PhoneMainView.instance popToView:SettingsView.compositeViewDescription];
}

- (IBAction)callHistory:(id)sender {
     [PhoneMainView.instance popToView:HistoryListView.compositeViewDescription];
}
- (IBAction)Contacts:(id)sender {
     [PhoneMainView.instance popToView:ContactsListView.compositeViewDescription];
}
- (IBAction)ChatPlus:(id)sender {
}
- (IBAction)VideoConference:(id)sender {
}
- (IBAction)TextMessaging:(id)sender {
}
- (IBAction)conferenceCall:(id)sender {
    
}





@end
