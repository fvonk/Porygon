//
//  ViewController.m
//  Porygon-Demo
//
//  Created by DevinShine on 2017/6/12.
//
//  Copyright (c) 2017 DevinShine <devin.xdw@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "ViewController.h"
#import "DVSPorygon.h"
#import "UIImage+Cropping.h"
@import YPImagePicker;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISlider *complexitySlider;
@property (nonatomic) DVSPorygon *porygon;
@property (nonatomic) UIImage *currentImage;
@property (nonatomic) UIImage *originImage;
@property (nonatomic) float complexity;

@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) ImageController *imageController;
@property (weak, nonatomic) IBOutlet UITextField *colorsTextView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapgGesture;
@property (weak, nonatomic) IBOutlet UILabel *verticesCount;
@property (weak, nonatomic) IBOutlet UITextField *colorTolerance;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UITextField *minSquare;
@property (weak, nonatomic) IBOutlet UITextField *maxSquare;
@property (weak, nonatomic) IBOutlet UILabel *roughLabel;
@property (weak, nonatomic) IBOutlet UIButton *generateButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _porygon = [[DVSPorygon alloc] init];
    
    _slider.minimumValue = DVS_MIN_VERTEX_COUNT;
    _slider.maximumValue = DVS_MAX_VERTEX_COUNT;
    _porygon.vertexCount = 3000;
    _slider.value = _porygon.vertexCount;
    
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue setMaxConcurrentOperationCount:1];
    self.currentImage = [UIImage imageNamed:@"photo"];
    self.originImage = [UIImage imageNamed:@"photo"];
    self.imageView.image = self.currentImage;
    
    [self updateEstimate];
    [self updatePorygon];

//    [[SVGHandler alloc] init];
}
- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    self.currentImage = self.originImage;
}

-(void)updatePorygon {
    [_operationQueue cancelAllOperations];
    __weak typeof(self)weakSelf = self;
    [self.porygon setColorTolerance:_colorTolerance.text.floatValue];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *resultImage = [weakSelf.porygon lowPolyWithImage:weakSelf.currentImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = resultImage;
        });
    }];
    [_operationQueue addOperation:operation];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (_porygon.vertexCount != sender.value) {
        _porygon.vertexCount = sender.value;
        [_verticesCount setText:[NSString stringWithFormat:@"%.0f", sender.value]];
        [self updatePorygon];
    }
}

- (IBAction)complexityChanged:(UISlider *)sender {
    if (_complexity != _complexitySlider.value) {
        self.complexity = _complexitySlider.value;
        
        [self updateEstimate];
    }
}

-(void)updateEstimate {
    float maxSquareEstimate = pow(2, -_complexitySlider.value);
    
    _porygon.vertexCount = 3000 + pow(2, self.complexity) * 2;
    [_slider setValue:_porygon.vertexCount animated:YES];
    [_verticesCount setText:[NSString stringWithFormat:@"%d", _porygon.vertexCount]];
    self.colorTolerance.text = [NSString stringWithFormat:@"%.2f", 0.8 / self.complexity];
    
    [self updatePorygon];
    
    self.maxSquare.text = [NSString stringWithFormat:@"%f", maxSquareEstimate];
    self.minSquare.text = [NSString stringWithFormat:@"%f", maxSquareEstimate * 0.1];
    self.roughLabel.text = [NSString stringWithFormat:@"~ %0.f groups", (1 / maxSquareEstimate) * 2 * 9 / _complexitySlider.value];
}

- (IBAction)generateSVG:(UIButton *)sender {
    [self.generateButton setEnabled:NO];
    [self.porygon setColorTolerance:_colorTolerance.text.floatValue];
    [self.porygon setMinSquare:_minSquare.text.floatValue];
    [self.porygon setMaxSquare:_maxSquare.text.floatValue];
    
    self.resultLabel.text = @"processing...";
    [self.progressView setProgress:0.0 animated:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.porygon generateSVG:^(double prog) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:(float)prog animated:YES];
            });
        } andCompletion:^(NSString *svgString, NSString *result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.generateButton setEnabled:YES];
                
                NSData *svgData = [svgString dataUsingEncoding:NSUTF8StringEncoding];
                NSURL *filePath = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"svg"]];
                [svgData writeToURL:filePath atomically:YES];
                
                NSArray *objectsToShare = @[filePath];
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
                [self presentViewController:activityVC animated:YES completion:nil];
                
                self.resultLabel.text = result;
            });
        }];
    });

}

- (IBAction)makeNewPhoto:(UIButton *)sender {
    _imageController = [[ImageController alloc] init];
    [_imageController setImageDidGetter:self];
    
    YPImagePicker *ypImagePicker = [_imageController showImages];
    [self presentViewController:ypImagePicker animated:YES completion:nil];
}

-(void)imageDidGet:(UIImage *)image {
    self.originImage = image;
    self.currentImage = image;
    [self updatePorygon];
}

- (void)setCurrentImage:(UIImage *)currentImage {
    UIImage *compressedImage = [currentImage compressImage];
    
    int colors = _colorsTextView.text.intValue;
    _currentImage = [UIImage convertImageToIndexed:compressedImage noOfColors:colors withoutTransformation:YES];
}

@end
