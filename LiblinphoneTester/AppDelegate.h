//
//  AppDelegate.h
//  LinphoneTester
//
//  Created by guillaume on 28/05/2014.
//
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(strong, nonatomic) FIRDatabaseReference *ref;

self.ref = [[FIRDatabase database] reference];

@end
