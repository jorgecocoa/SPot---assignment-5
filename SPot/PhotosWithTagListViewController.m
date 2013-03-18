//
//  PhotosWithTagListViewController.m
//  SPot
//
//  Created by Jorge García-Luengo on 09/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import "PhotosWithTagListViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotos.h"


@interface PhotosWithTagListViewController ()
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) RecentPhotos *recentPhotos;

@end

@implementation PhotosWithTagListViewController

- (RecentPhotos *)recentPhotos
{
    if (!_recentPhotos) _recentPhotos = [[RecentPhotos alloc] init];
    
    return _recentPhotos;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLatestPhotosFromFlickr];
    [self.refreshControl addTarget:self
                            action:@selector(loadLatestPhotosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)loadLatestPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loaderQ = dispatch_queue_create("flickr tag loader", NULL);
    dispatch_async(loaderQ, ^{
        NSArray *latestPhotos = [self photosWithTag];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = latestPhotos;
            [self.refreshControl endRefreshing];
        });
    });
    
}

- (void)setPhotoListTag:(NSString *)tagForPhoto
{
    _tag = tagForPhoto;
    //[self.tableView reloadData]; //no se si sea necesario!!
}

- (NSArray *)photosWithTag
{
    NSMutableArray *photoTotalList = [[FlickrFetcher stanfordPhotos] mutableCopy];
    for (int i = 0; i<[photoTotalList count]; i++) {
        NSRange range = [photoTotalList[i][FLICKR_TAGS] rangeOfString:self.tag];
        if (!range.length) {
            [photoTotalList removeObjectAtIndex:i];
            i --;
        }
    }
    NSArray *finalArray = [photoTotalList copy];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES];
    NSSortDescriptor *secondSortDescriptot = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_DESCRIPTION ascending:YES];
    
    return [finalArray sortedArrayUsingDescriptors:@[sortDescriptor, secondSortDescriptot]];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url;
                    if (self.splitViewController) {
                        url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatOriginal];
                    } else {
                        url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                    }
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                    self.recentPhotos.photoID = self.photos[indexPath.row][FLICKR_PHOTO_ID];
                }
            }
        }
    }
}

@end
