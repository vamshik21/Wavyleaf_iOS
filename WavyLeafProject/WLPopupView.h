//
//  WLPopupView.h
//  Wavyleaf
//
//  Created by Eric Forbes on 9/25/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLPopupView : UIViewController

{

    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UIView *wavyLabel;
}

@property (nonatomic) UIView *_wavyLabel;
@property (nonatomic) BOOL first;

@end
