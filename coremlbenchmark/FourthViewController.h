//
//  FourthViewController.h
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/6.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#ifndef FourthViewController_h
#define FourthViewController_h

#import <UIKit/UIKit.h>

#import "FirstViewController.h"
#import "UIImage+UIImage_resize_crop.h"
#import "ResNet50.h"

@interface FourthViewController : FirstViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@end

#endif /* FourthViewController_h */
