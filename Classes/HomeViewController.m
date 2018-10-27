//
//  HomeViewController.m
//  linphone
//
//  Created by Gouthami Reddy on 10/25/18.
//

#import "HomeViewController.h"
#import "PhoneMainView.h"
#import "UICompositeView.h"
#import <QuartzCore/QuartzCore.h>

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
    
    _contacts.layer.borderWidth = 0.2;
    _contacts.layer.borderColor = [[UIColor grayColor]CGColor];
    _contacts.layer.cornerRadius = 10;
    
    _videoConference.layer.borderWidth = 0.2;
    _videoConference.layer.borderColor = [[UIColor grayColor]CGColor];
    _videoConference.layer.cornerRadius = 10;
    
    _chatPlus.layer.borderWidth = 0.2;
   _chatPlus.layer.borderColor = [[UIColor grayColor]CGColor];
    _chatPlus.layer.cornerRadius = 10;
    
    _textMessaging.layer.borderWidth = 0.2;
   _textMessaging.layer.borderColor = [[UIColor grayColor]CGColor];
    _textMessaging.layer.cornerRadius = 10;
    
       _conferenceCall.layer.borderWidth = 0.2;
       _conferenceCall.layer.borderColor = [[UIColor grayColor]CGColor];
       _conferenceCall.layer.cornerRadius = 10;
    
    _callHistory.layer.borderWidth = 0.2;
    _callHistory.layer.borderColor = [[UIColor grayColor]CGColor];
    _callHistory.layer.cornerRadius = 10;
    
    _About.layer.borderWidth = 0.2;
     _About.layer.borderColor = [[UIColor grayColor]CGColor];
     _About.layer.cornerRadius = 10;
    
    
    _logout.layer.borderWidth = 0.2;
    _logout.layer.borderColor = [[UIColor grayColor]CGColor];
    _logout.layer.cornerRadius = 10;
    
    
    
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
- (IBAction)contacts:(id)sender {
     [PhoneMainView.instance popToView:ContactsListView.compositeViewDescription];
}
- (IBAction)chatPlus:(id)sender {
    [PhoneMainView.instance popToView:ChatsListView.compositeViewDescription];
}
- (IBAction)videoConference:(id)sender {
}
- (IBAction)textMessaging:(id)sender {
}
- (IBAction)conferenceCall:(id)sender {
   
}
- (IBAction)About:(id)sender {
    [PhoneMainView.instance
     changeCurrentView:AboutView.compositeViewDescription];

}

- (IBAction)logout:(id)sender {
    [PhoneMainView.instance
     changeCurrentView:AssistantView.compositeViewDescription];
    [PhoneMainView.instance hideStatusBar:YES];
}




@end
