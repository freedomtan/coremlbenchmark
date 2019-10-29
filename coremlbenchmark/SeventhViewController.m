//
//  SixthViewController.m
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/6.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#import "SeventhViewController.h"

@interface SeventhViewController () {
    VGG16 *model;
}
@end

@implementation SeventhViewController
@dynamic tableView;
@dynamic resultLabel;
@dynamic fpsLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    model = [[VGG16 alloc] initWithConfiguration: mc error: nil];
}

- (void) labelImage: (CIImage *) ciImage {
    UIImage *uiImage =  [UIImage imageWithCIImage: ciImage];
    CGFloat inputImageSize = 224.0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval start, stop;
        VGG16Output *o;
        
        float minLen = (uiImage.size.width > uiImage.size.height) ? uiImage.size.height : uiImage.size.width;
        CVPixelBufferRef pixelBuffer = [[[uiImage resizeTo: CGSizeMake(inputImageSize * uiImage.size.width / minLen, inputImageSize * uiImage.size.height / minLen)] cropToSquare] pixelBuffer];
        
        start = [[NSDate date] timeIntervalSince1970];
        o = [self->model predictionFromImage: pixelBuffer error: nil];
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
