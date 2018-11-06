//
//  FirstViewController.m
//  coremlbenchmark
//
//  Created by Koan-Sin Tan on 2018/11/5.
//  Copyright © 2018 Koan-Sin Tan. All rights reserved.
//

#import "FirstViewController.h"
#import "UIImage+UIImage_resize_crop.h"

@interface FirstViewController () {
    MobileNet *model;
}
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    mc = [[MLModelConfiguration alloc] init];
    // mc.computeUnits = MLComputeUnitsCPUOnly;
    // mc.computeUnits = MLComputeUnitsCPUAndGPU;
    // mc.computeUnits = MLComputeUnitsAll;
    model = [[MobileNet alloc] initWithConfiguration: mc error: nil];

    self->numberOfResults = 0;
    [self.tableView registerClass:UITableViewCell.self forCellReuseIdentifier: @"cell"];
    // [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (session == nil)
        [self setupCamera];
    else
        [session startRunning];
}

- (void) labelImage: (CIImage *) ciImage {
    UIImage *uiImage =  [UIImage imageWithCIImage: ciImage];
    CGFloat inputImageSize = 224.0;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval start, stop;
        MobileNetOutput *o;
        
        float minLen = (uiImage.size.width > uiImage.size.height) ? uiImage.size.height : uiImage.size.width;
        UIImage *croppedSquareImage = [[uiImage resizeTo: CGSizeMake(inputImageSize * uiImage.size.width / minLen, inputImageSize * uiImage.size.height / minLen)] cropToSquare];
        
        start = [[NSDate date] timeIntervalSince1970];
        o = [self->model predictionFromImage: [croppedSquareImage pixelBuffer] error:nil];
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
    });
}

- (nonnull UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = [self->sortedArray objectAtIndex: indexPath.row];

    return cell;
}

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // store only top 5 results
    return (numberOfResults > 5) ? 5 : numberOfResults;
}

- (void) setupCamera {
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    
    NSDictionary *rgbOutputSettings = [NSDictionary
                                       dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                       forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([session canAddOutput:videoDataOutput])
        [session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:cvImage];
    [self labelImage: ciImage];
}

@end
