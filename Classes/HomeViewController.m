//
//  HomeViewController.m
//  linphone
//
//  Created by Gouthami Reddy on 11/29/18.
//

#import <Firebase/Firebase.h>
#import <FirebaseAuth/FirebaseAuth.h>
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

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // corners...
    [self cornerSetupMethod];
    
    //    _contactsIcon.layer.cornerRadius = 40;
    //    _contactsIcon.layer.masksToBounds = YES;
    //
    //    _callHistoryIcon.layer.cornerRadius = 40;
    //    _callHistoryIcon.layer.masksToBounds = YES;
    //
    //    _chatplusIcon.layer.cornerRadius = 40;
    //    _chatplusIcon.layer.masksToBounds = YES;
    //
    //    _textMessagingIcon.layer.cornerRadius = 40;
    //    _textMessagingIcon.layer.masksToBounds = YES;
    //
    //    _videoConferenceIcon.layer.cornerRadius = 40;
    //    _videoConferenceIcon.layer.masksToBounds = YES;
    //
    //    _conferenceCallIcon.layer.cornerRadius = 40;
    //    _conferenceCallIcon.layer.masksToBounds = YES;
    //
    //
    //    _contactsView.layer.borderWidth = 0.5;
    //    _contactsView.layer.borderColor = [[UIColor grayColor]CGColor];
    //    _contactsView.layer.cornerRadius = 10;
    //
    //    _callHistoryView.layer.borderWidth = 0.5;
    //    _callHistoryView.layer.borderColor = [[UIColor grayColor]CGColor];
    //    _callHistoryView.layer.cornerRadius = 10;
    //
    //    _chatPlusView.layer.borderWidth = 0.5;
    //   _chatPlusView.layer.borderColor = [[UIColor grayColor]CGColor];
    //    _chatPlusView.layer.cornerRadius = 10;
    //
    //    _textMessagingview.layer.borderWidth = 0.5;
    //   _textMessagingview.layer.borderColor = [[UIColor grayColor]CGColor];
    //    _textMessagingview.layer.cornerRadius = 10;
    //
    //       _conferenceCallView.layer.borderWidth = 0.5;
    //       _conferenceCallView.layer.borderColor = [[UIColor grayColor]CGColor];
    //       _conferenceCallView.layer.cornerRadius = 10;
    //
    //    _videoConferenceView.layer.borderWidth = 0.5;
    //     _videoConferenceView.layer.borderColor = [[UIColor grayColor]CGColor];
    //     _videoConferenceView.layer.cornerRadius = 10;
    //
    //    _AboutView.layer.borderWidth = 0.5;
    //     _AboutView.layer.borderColor = [[UIColor grayColor]CGColor];
    //     _AboutView.layer.cornerRadius = 10;
    //
    //
    //    _logoutView.layer.borderWidth = 0.5;
    //    _logoutView.layer.borderColor = [[UIColor grayColor]CGColor];
    //    _logoutView.layer.cornerRadius = 10;
    //
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 800);
//}

#pragma mark - Helper
- (void)cornerSetupMethod {
    
    for (UIView *chilld_view in self.view_row1.subviews) {
        
        // main view...
        chilld_view.layer.borderWidth = 0.5;
        chilld_view.layer.borderColor = [[UIColor grayColor]CGColor];
        chilld_view.layer.cornerRadius = 10;
        chilld_view.layer.masksToBounds = YES;
        
        // circle view...
        for (UIView *sub_child in chilld_view.subviews) {
            if (sub_child.tag == 10) {
                sub_child.layer.cornerRadius = sub_child.frame.size.width/2;
                sub_child.layer.masksToBounds = YES;
            }
        }
    }
    
    for (UIView *chilld_view in self.view_row2.subviews) {
        
        // main view...
        chilld_view.layer.borderWidth = 0.5;
        chilld_view.layer.borderColor = [[UIColor grayColor]CGColor];
        chilld_view.layer.cornerRadius = 10;
        chilld_view.layer.masksToBounds = YES;
        
        // circle view...
        for (UIView *sub_child in chilld_view.subviews) {
            if (sub_child.tag == 10) {
                sub_child.layer.cornerRadius = sub_child.frame.size.width/2;
                sub_child.layer.masksToBounds = YES;
            }
        }
    }
    
    for (UIView *chilld_view in self.view_row3.subviews) {
        
        // main view...
        chilld_view.layer.borderWidth = 0.5;
        chilld_view.layer.borderColor = [[UIColor grayColor]CGColor];
        chilld_view.layer.cornerRadius = 10;
        chilld_view.layer.masksToBounds = YES;
        
        // circle view...
        for (UIView *sub_child in chilld_view.subviews) {
            if (sub_child.tag == 10) {
                sub_child.layer.cornerRadius = sub_child.frame.size.width/2;
                sub_child.layer.masksToBounds = YES;
            }
        }
    }
    
    for (UIView *chilld_view in self.view_row4.subviews) {
        
        // main view...
        chilld_view.layer.borderWidth = 0.5;
        chilld_view.layer.borderColor = [[UIColor grayColor]CGColor];
        chilld_view.layer.cornerRadius = 10;
        chilld_view.layer.masksToBounds = YES;
        
        // circle view...
        for (UIView *sub_child in chilld_view.subviews) {
            if (sub_child.tag == 10) {
                sub_child.layer.cornerRadius = sub_child.frame.size.width/2;
                sub_child.layer.masksToBounds = YES;
            }
        }
    }
}

#pragma mark - ButtonActions
- (IBAction)DailerMenu:(id)sender {
    [PhoneMainView.instance popToView:DialerView.compositeViewDescription];
}

- (IBAction)settingsicon:(id)sender {
    [PhoneMainView.instance popToView:SettingsView.compositeViewDescription];
}

- (IBAction)callHistory:(id)sender {
    [PhoneMainView.instance popToView:HistoryListVC.compositeViewDescription];
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
    [PhoneMainView.instance changeCurrentView:AboutView.compositeViewDescription];
}

- (IBAction)logout:(id)sender {
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    [PhoneMainView.instance
     changeCurrentView:AssistantView.compositeViewDescription];
    [PhoneMainView.instance hideStatusBar:YES];
}




@end

