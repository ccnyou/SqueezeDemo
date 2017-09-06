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
#import "VGG16.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray<NSString *> *imagePaths;
@property (nonatomic, strong) SqueezeNet *squeezeNet;
@property (nonatomic, strong) VGG16 *vgg16;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)_showImage:(UIImage *)image {
    NSError *error;
    UIImage *scaledImage = [image scaleToSize:CGSizeMake(259, 259)]; //将输入图像scale到259*259
    UIImage *cropImage = [scaledImage cropToSize:CGSizeMake(227, 227)] ; //crop图像得到227*227，此即模型输入大小
    CVPixelBufferRef buffer = [UIImage pixelBufferFromCGImage:cropImage]; //将uiimage转到CVPixelBufferRef
    SqueezeNetOutput* output = [self.squeezeNet predictionFromImage:buffer error:&error]; //前向计算得到输出
    NSNumber *props = [output.classLabelProbs objectForKey:output.classLabel];
    CGFloat floatValue = [props floatValue];
    self.label.text = [NSString stringWithFormat:@"image %@: %@(%.2f)", @(self.currentIndex), output.classLabel, floatValue];
}

- (SqueezeNet *)squeezeNet {
    if (!_squeezeNet) {
        _squeezeNet = [[SqueezeNet alloc] init];
    }
    return _squeezeNet;
}

- (VGG16 *)vgg16 {
    if (!_vgg16) {
        _vgg16 = [[VGG16 alloc] init];
    }
    return _vgg16;
}

- (IBAction)onNextTouched:(id)sender {
    [self _loadWithSqueezeNet];
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)_loadWithSqueezeNet {
    self.currentIndex = 0;
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
    NSString *imagesPath = @"/Users/ervin/Desktop/香蕉数据/Error";
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesPath error:nil];
    for (NSString *imageFile in files) {
        NSString *fullName = [imagesPath stringByAppendingPathComponent:imageFile];
        if (![fullName containsString:@"jpg"]) {
            continue;
        }
        if ([fullName containsString:@".png"]) {
            continue;
        }
        [imagePaths addObject:fullName];
    }
    self.imagePaths = imagePaths;
    
    NSError *error = nil;
    for (NSString *imagePath in self.imagePaths) {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        UIImage *scaledImage = [image scaleToSize:CGSizeMake(259, 259)]; //将输入图像scale到259*259
        UIImage *cropImage = [scaledImage cropToSize:CGSizeMake(227, 227)] ; //crop图像得到227*227，此即模型输入大小
        cropImage = rotate(cropImage, UIImageOrientationRight);
//        NSString *filePath = [NSString stringWithFormat:@"%@_scaled.png", imagePath];
//        [cropImage writeToFile:filePath];
        CVPixelBufferRef buffer = [UIImage pixelBufferFromCGImage:cropImage]; //将uiimage转到CVPixelBufferRef
        SqueezeNetOutput* output = [self.squeezeNet predictionFromImage:buffer error:&error]; //前向计算得到输出
        NSString *tagName = output.classLabel;
        if ([tagName containsString:@"banana"]) {
            NSLog(@"%s %d ervinchen 识别香蕉成功, index = %@, tag = %@, name = %@", __FUNCTION__, __LINE__, @(self.currentIndex), tagName, imagePath);
        } else {
            NSLog(@"%s %d ervinchen 识别香蕉失败，index = %@, tag = %@, name = %@", __FUNCTION__, __LINE__, @(self.currentIndex), tagName, imagePath);
        }
        
        self.currentIndex++;
    }
}

- (void)_loadWithVGGNet {
    self.currentIndex = 0;
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
    NSString *imagesPath = @"~/Desktop/Banana";
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesPath error:nil];
    for (NSString *imageFile in files) {
        NSString *fullName = [imagesPath stringByAppendingPathComponent:imageFile];
        [imagePaths addObject:fullName];
    }
    self.imagePaths = imagePaths;
    
    NSError *error = nil;
    for (NSString *imagePath in self.imagePaths) {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        UIImage *scaledImage = [image scaleToSize:CGSizeMake(227, 224)]; //将输入图像scale到259*259
        // UIImage *cropImage = [scaledImage cropToSize:CGSizeMake(224, 224)] ; //crop图像得到227*227，此即模型输入大小
        CVPixelBufferRef buffer = [UIImage pixelBufferFromCGImage:scaledImage]; //将uiimage转到CVPixelBufferRef
        VGG16Output* output = [self.vgg16 predictionFromImage:buffer error:&error]; //前向计算得到输出
        NSString *tagName = output.classLabel;
        if ([tagName containsString:@"banana"]) {
            NSLog(@"%s %d ervinchen 识别香蕉成功, index = %@, tag = %@, name = %@", __FUNCTION__, __LINE__, @(self.currentIndex), tagName, imagePath);
        } else {
            NSLog(@"%s %d ervinchen 识别香蕉失败，index = %@, tag = %@, name = %@", __FUNCTION__, __LINE__, @(self.currentIndex), tagName, imagePath);
        }
        
        self.currentIndex++;
    }
}

@end
