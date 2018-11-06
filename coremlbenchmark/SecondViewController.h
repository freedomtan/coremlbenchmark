//
//  SecondViewController.h
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/5.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FirstViewController.h"
#import "UIImage+UIImage_resize_crop.h"
#import "MobileNetV2.h"

@interface SecondViewController : FirstViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@end
