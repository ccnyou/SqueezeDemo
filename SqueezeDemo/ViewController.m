//
//  ViewController.m
//  SqueezeDemo
//
//  Created by 聪宁陈 on 2017/7/12.
//  Copyright © 2017年 ccnyou. All rights reserved.
//

#import "ViewController.h"
#import "SqueezeNet.h"
#import "UIImage+scale.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, strong) NSArray<NSString *> *imagePaths;
@property (nonatomic, strong) SqueezeNet *squeezeNet;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *imagePath = [self.imagePaths objectAtIndex:self.currentImageIndex];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [self _showImage:image];
}

- (void)_showImage:(UIImage *)image {
    NSError *error;
    UIImage *scaledImage = [image scaleToSize:CGSizeMake(259, 259)]; //将输入图像scale到259*259
    UIImage *cropImage = [scaledImage cropToSize:CGSizeMake(227, 227)] ; //crop图像得到227*227，此即模型输入大小
    CVPixelBufferRef buffer = [UIImage pixelBufferFromCGImage:cropImage]; //将uiimage转到CVPixelBufferRef
    SqueezeNetOutput* output = [self.squeezeNet predictionFromImage:buffer error:&error]; //前向计算得到输出
    NSNumber *props = [output.classLabelProbs objectForKey:output.classLabel];
    CGFloat floatValue = [props floatValue];
    self.label.text = [NSString stringWithFormat:@"image %@: %@(%.2f)", @(self.currentImageIndex), output.classLabel, floatValue];
    self.imageView.image = image;
}

- (SqueezeNet *)squeezeNet {
    if (!_squeezeNet) {
        _squeezeNet = [[SqueezeNet alloc] init];
    }
    return _squeezeNet;
}

- (NSArray *)imagePaths {
    if (!_imagePaths) {
        _imagePaths = [self _loadImagePaths];
    }
    return _imagePaths;
}

- (IBAction)onNextTouched:(id)sender {
    self.currentImageIndex++;
    if (self.currentImageIndex >= self.imagePaths.count) {
        self.currentImageIndex = 0;
    }
    
    NSString *imagePath = [self.imagePaths objectAtIndex:self.currentImageIndex];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [self _showImage:image];
}

- (NSArray *)_loadImagePaths {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *dir = [bundle bundlePath];
    NSString *imagePath = [dir stringByAppendingPathComponent:@"Images"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:imagePath];
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
    for (NSString *file in enumerator) {
        NSString *filePath = [imagePath stringByAppendingPathComponent:file];
        [imagePaths addObject:filePath];
    }
    return imagePaths;
}

@end
