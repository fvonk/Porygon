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
#import "CenterScrollView.h"
#import "UIImage+Cropping.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet CenterScrollView *scrollView;
@property (nonatomic) DVSPorygon *porygon;
@property (nonatomic) UIImage *currentImage;
@property (weak, nonatomic) IBOutlet UIButton *cropButton;

@property (nonatomic) NSOperationQueue *operationQueue;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _porygon = [[DVSPorygon alloc] init];
    
    _slider.minimumValue = DVS_MIN_VERTEX_COUNT;
    _slider.maximumValue = DVS_MAX_VERTEX_COUNT;
    _slider.value = _porygon.vertexCount;
    
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 3;
    [_scrollView setContentSize:_imageView.frame.size];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue setMaxConcurrentOperationCount:1];
    self.currentImage = [UIImage imageNamed:@"camera"];
    self.imageView.image = self.currentImage;
    [self updateImageConstraints];
    
    [_cropButton setHidden:YES];
    
    [self updatePorygon];
}

-(void)updatePorygon {
    [_operationQueue cancelAllOperations];
    __weak typeof(self)weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *resultImage = [weakSelf.porygon lowPolyWithImage:weakSelf.currentImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = resultImage;
            [weakSelf updateImageConstraints];
        });
    }];
    [_operationQueue addOperation:operation];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (_porygon.vertexCount != sender.value) {
        _porygon.vertexCount = sender.value;
        [self updatePorygon];
    }
}

- (IBAction)generateSVG:(UIButton *)sender {
    NSString *svgString = [_porygon generateSVG];
    NSData *svgData = [svgString dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *filePath = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"svg"]];
    [svgData writeToURL:filePath atomically:YES];
    
    NSArray *objectsToShare = @[filePath];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)getImageFromGallery:(UIButton *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.currentImage = image;
    [self updatePorygon];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCurrentImage:(UIImage *)currentImage {
    
    CIImage *coreImage = [[CIImage alloc] initWithImage:currentImage];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:coreImage forKey:kCIInputImageKey];
    [filter setValue:@0.5 forKey:kCIInputIntensityKey];
    
    EAGLContext *openGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    CIContext *context = [CIContext contextWithEAGLContext:openGLContext];
    
    CIImage *outputImage = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImageResult = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:cgImageResult];
    
    _currentImage = [resultImage compressImage];
}


- (IBAction)cropImage:(UIButton *)sender {
    CGFloat scale = 1 / _scrollView.zoomScale;
    CGRect visibleRect = CGRectMake(_scrollView.contentOffset.x * scale, _scrollView.contentOffset.y * scale, _scrollView.bounds.size.width * scale, _scrollView.bounds.size.height * scale);
    CGImageRef ref = CGImageCreateWithImageInRect(_imageView.image.CGImage, visibleRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:ref];
    
    _currentImage = croppedImage;
    _imageView.image = croppedImage;
    [self updateImageConstraints];
}

-(void)updateImageConstraints {
    _imageWidthConstraint.constant = _imageView.image.size.width;
    _imageHeightConstraint.constant = _imageView.image.size.height;
    CGFloat scaleHeight = _scrollView.frame.size.width / _imageView.image.size.width;
    CGFloat scaleWidth = _scrollView.frame.size.height / _imageView.image.size.height;
    _scrollView.minimumZoomScale = MAX(scaleWidth, scaleHeight);
    _scrollView.zoomScale = MAX(scaleWidth, scaleHeight);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [_cropButton setHidden:scrollView.zoomScale <= _scrollView.minimumZoomScale];
}

@end
