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
    
   
    _contactsIcon.layer.cornerRadius = 37;
    _contactsIcon.layer.masksToBounds = YES;
    
    _callHistoryIcon.layer.cornerRadius = 37;
    _callHistoryIcon.layer.masksToBounds = YES;
    
    _chatplusIcon.layer.cornerRadius = 37;
    _chatplusIcon.layer.masksToBounds = YES;
    
    _textMessagingIcon.layer.cornerRadius = 37;
    _textMessagingIcon.layer.masksToBounds = YES;
    
    _videoConferenceIcon.layer.cornerRadius = 37;
    _videoConferenceIcon.layer.masksToBounds = YES;
    
    _conferenceCallIcon.layer.cornerRadius = 37;
    _conferenceCallIcon.layer.masksToBounds = YES;
    
    
    _contactsView.layer.borderWidth = 0.5;
    _contactsView.layer.borderColor = [[UIColor grayColor]CGColor];
    _contactsView.layer.cornerRadius = 10;
    
    _callHistoryView.layer.borderWidth = 0.5;
    _callHistoryView.layer.borderColor = [[UIColor grayColor]CGColor];
    _callHistoryView.layer.cornerRadius = 10;
    
    _chatPlusView.layer.borderWidth = 0.5;
   _chatPlusView.layer.borderColor = [[UIColor grayColor]CGColor];
    _chatPlusView.layer.cornerRadius = 10;
    
    _textMessagingview.layer.borderWidth = 0.5;
   _textMessagingview.layer.borderColor = [[UIColor grayColor]CGColor];
    _textMessagingview.layer.cornerRadius = 10;
    
       _conferenceCallView.layer.borderWidth = 0.5;
       _conferenceCallView.layer.borderColor = [[UIColor grayColor]CGColor];
       _conferenceCallView.layer.cornerRadius = 10;
    
    _videoConferenceView.layer.borderWidth = 0.5;
     _videoConferenceView.layer.borderColor = [[UIColor grayColor]CGColor];
     _videoConferenceView.layer.cornerRadius = 10;
    
    _AboutView.layer.borderWidth = 0.5;
     _AboutView.layer.borderColor = [[UIColor grayColor]CGColor];
     _AboutView.layer.cornerRadius = 10;
    
    
    _logoutView.layer.borderWidth = 0.5;
    _logoutView.layer.borderColor = [[UIColor grayColor]CGColor];
    _logoutView.layer.cornerRadius = 10;
    
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 800);
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
- (IBAction)aboutClicked:(id)sender {

    [PhoneMainView.instance
     changeCurrentView:AboutView.compositeViewDescription];

}

- (IBAction)logout:(id)sender {
    [PhoneMainView.instance
     changeCurrentView:AssistantView.compositeViewDescription];
    [PhoneMainView.instance hideStatusBar:YES];
}




@end
