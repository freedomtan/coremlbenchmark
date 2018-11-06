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

- (void) labelImage: (CIImage *) ciImage {
    UIImage *uiImage =  [UIImage imageWithCIImage: ciImage];
    CGFloat inputImageSize = 224.0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval start, stop;
        MobileNetV2Output *o;
        
        float minLen = (uiImage.size.width > uiImage.size.height) ? uiImage.size.height : uiImage.size.width;
        UIImage *croppedSquareImage = [[uiImage resizeTo: CGSizeMake(inputImageSize * uiImage.size.width / minLen, inputImageSize * uiImage.size.height / minLen)] cropToSquare];
        
        start = [[NSDate date] timeIntervalSince1970];
        o = [self->model predictionFromInput__0: [croppedSquareImage pixelBuffer] error: nil];
        stop = [[NSDate date] timeIntervalSince1970];
        self.resultLabel.text = o.classLabel;
        
        if (self->runningAverage <= 0.0) {
            self->runningAverage = stop - start;
            self->minimumTime = self->runningAverage;
        } else {
            self->runningAverage = 0.1 * (stop - start) + self->runningAverage * 0.9;
            if ((stop - start) < self->minimumTime)
                self->minimumTime = stop - start;
        }
        
        // min, instantaneous, running average
        self.fpsLabel.text = [NSString stringWithFormat: @"%2.2f ms, %2.2f ms, %2.2f ms", self->minimumTime * 1000, ((stop - start) * 1000), self->runningAverage * 1000];
        self->sortedArray = [o.classLabelProbs keysSortedByValueUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
            if ([obj2 floatValue] > [obj1 floatValue])
                return (NSComparisonResult)NSOrderedDescending;
            else
                return (NSComparisonResult)NSOrderedAscending;
        }];
        self->numberOfResults = 5;
        [self.tableView reloadData];
        // self->sortedArray
    });
}


@end
