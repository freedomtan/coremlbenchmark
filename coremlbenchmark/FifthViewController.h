//
//  FifthViewController.h
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/6.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#ifndef FifthViewController_h
#define FifthViewController_h

#import <UIKit/UIKit.h>

#import "FirstViewController.h"
#import "UIImage+UIImage_resize_crop.h"
#import "SqueezeNet.h"

@interface FifthViewController : FirstViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@end

#endif /* FifthViewController_h */
