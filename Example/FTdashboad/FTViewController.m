//
//  FTViewController.m
//  FTdashboad
//
//  Created by 1085192695@qq.com on 07/27/2020.
//  Copyright (c) 2020 1085192695@qq.com. All rights reserved.
//

#import "FTViewController.h"
#import "FTdashBoad.h"
@interface FTViewController ()
@property (weak, nonatomic) IBOutlet FTdashBoad *dashboadView;
@end

@implementation FTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.dashboadView createViewWithMinValue:0 maxValue:10 startAngle:M_PI_4 * 3 endAngle:M_PI_4 * 9 divideOfUint:10 countOfUnit:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addEvent:(id)sender {
    [self.dashboadView refreshDashboard:self.dashboadView.currentValue + 1];
}

- (IBAction)reduceEvent:(id)sender {
    [self.dashboadView refreshDashboard:self.dashboadView.currentValue - 1];
}
@end
