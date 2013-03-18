//
//  ImageViewController.m
//  SPot
//
//  Created by Jorge García-Luengo on 09/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import "ImageViewController.h"
#import "FlickrFetcher.h"
#import "PhotoCache.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) PhotoCache *photoCache;
@end

@implementation ImageViewController

- (PhotoCache *)photoCache
{
    if (!_photoCache) _photoCache = [[PhotoCache alloc] init];
    return _photoCache;
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView && self.imageURL) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        NSURL *imageURL = self.imageURL;
        
        [self.spinner startAnimating];
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            //do I have that image in my cache?!?!?! check URL
            NSData *imageData;
            //if so, load it from there...
            NSLog(@"%@", self.imageURL);
            imageData = [self.photoCache retrivePhotosFromCacheWithURL:self.imageURL];
            NSLog(@"bites in image retrieved %u", [imageData length]);
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            if (self.imageURL == imageURL) {
                [self.photoCache putPhotosInCahe:imageData toURL:self.imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        [self.scrollView zoomToRect:[self rectToFitZoomToScrollViewBounds:self.imageView.image] animated:YES];
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;

    [self resetImage]; // cause even if it is in setImageIdentifier, view is not loaded there jet (called by prepareForSegue
    self.titleBarButtonItem.title = self.title;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView zoomToRect:[self rectToFitZoomToScrollViewBounds:self.imageView.image] animated:YES];

}

- (CGRect)rectToFitZoomToScrollViewBounds:(UIImage *)image
{
    CGRect resultRect;
    self.scrollView.zoomScale = 1.0;
    
    CGFloat imageWidth = image.size.width;
    CGFloat imagaHeigth = image.size.height;
    CGFloat ratioImageHeight = image.size.height/image.size.width; //cuantas veces es mas alta que ancha

    CGFloat ratioScrollHeight = self.scrollView.bounds.size.height/self.scrollView.bounds.size.width; //cuantas veces es la pantalla mas alta que ancha
    
    if (ratioImageHeight >= ratioScrollHeight) {
        resultRect = CGRectMake(0, 0, imageWidth, imageWidth*ratioScrollHeight);
    } else if (ratioImageHeight < ratioScrollHeight) {
        resultRect = CGRectMake(0, 0, imagaHeigth/ratioScrollHeight, imagaHeigth);
    }
    return resultRect;
}





@end
