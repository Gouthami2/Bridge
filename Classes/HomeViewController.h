//
//  HomeViewController.h
//  linphone
//
//  Created by Gouthami Reddy on 11/29/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "HistoryListVC.h"


@interface HomeViewController : UIViewController <UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *view_row1;
@property (weak, nonatomic) IBOutlet UIView *view_row2;
@property (weak, nonatomic) IBOutlet UIView *view_row3;
@property (weak, nonatomic) IBOutlet UIView *view_row4;


@end


