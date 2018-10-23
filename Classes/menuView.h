//
//  menuView.h
//  linphone
//
//  Created by Gouthami Reddy on 10/22/18.
//


#import "menuView.h"

#import <UIKit/UIKit.h>
#import "AssistantView.h"

@interface menuView :AssistantView <UICompositeViewDelegate>

@property(nonatomic,strong) UIView *menuView1;
@property (strong, nonatomic) IBOutlet UIImageView *bridgeicon;

@end
