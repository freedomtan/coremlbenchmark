//
//  SecondViewController.m
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/5.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController () {
    MobileNetV2 *model;
}
@end

@implementation SecondViewController
@dynamic tableView;
@dynamic resultLabel;
@dynamic fpsLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    MLModelConfiguration *mc = [[MLModelConfiguration alloc] init];
    // mc.computeUnits = MLComputeUnitsCPUOnly;
    // mc.computeUnits = MLComputeUnitsCPUAndGPU;
    // mc.computeUnits = MLComputeUnitsAll;
    model = [[MobileNetV2 alloc] initWithConfiguration: mc error: nil];
}


@end
