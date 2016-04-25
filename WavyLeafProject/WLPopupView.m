//
//  WLPopupView.m
//  Wavyleaf
//
//  Created by Eric Forbes on 9/25/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLPopupView.h"
#import "WLline.h"

@interface WLPopupView ()

@end

@implementation WLPopupView
@synthesize first;

- (id)init
{
    self = [super init];
    if (self){
        
        //Create the green line (view) between text
        WLline *myLine = [[WLline alloc] initWithFrame:CGRectMake(20, 197, 217, 2.2)];
        [[self view] addSubview:myLine];
        myLine = [[WLline alloc] initWithFrame:CGRectMake(20, 255, 217, 2.2)];
        [[self view] addSubview:myLine];
        [self set_wavyLabel:wavyLabel];
        
        //Set the application version label
        versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
