//
//  QuerryPhotosViewController.m
//  SPot
//
//  Created by Jorge García-Luengo on 08/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import "QuerryPhotosViewController.h"
#import "FlickrFetcher.h"

@interface QuerryPhotosViewController ()

@property (nonatomic, strong) NSOrderedSet *taglList;
@property (nonatomic, strong) NSArray *wrongStrings;
@end

@implementation QuerryPhotosViewController

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

- (NSArray *)wrongStrings
{
    if (!_wrongStrings)_wrongStrings =@[@"cs193pspot", @"portrait", @"landscape"];
    return _wrongStrings;
}

- (NSOrderedSet *)taglList
{
    if (!_taglList) {
        _taglList = [[NSOrderedSet alloc] initWithArray:[self arrayOfPhotoTags]];
    }
    return _taglList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photos = [FlickrFetcher stanfordPhotos];
    //[self loadLatestPhotosFromFlickr];

    [self.refreshControl addTarget:self
                           action:@selector(loadLatestPhotosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)loadLatestPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loaderQ = dispatch_queue_create("flickr latest loader", NULL);
    dispatch_async(loaderQ, ^{
        NSArray *latestPhotos = [FlickrFetcher stanfordPhotos]; //esto no funciona poque seguramente está afectando a algún UI!!
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = latestPhotos;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
    
}


- (NSArray *)removeUnwantedTagsFrom:(NSArray *)tags
{
    NSMutableArray *mutbleTag = [[NSMutableArray alloc] initWithArray:tags];
    
    for (int i=0; i<[mutbleTag count]; i++) {
        for (int j=0; j<[self.wrongStrings count]; j++) {
            NSRange range = [mutbleTag[i] rangeOfString:self.wrongStrings[j]];
            if (range.length) {
                [mutbleTag removeObjectAtIndex:i];
                i--;
                break;
            }
        }
    }
    return [mutbleTag copy];
}

- (NSUInteger)numberOfPhotosWithTheTag:(NSString *)tag
{
    NSInteger numberOfPhotos = 0;
    for (NSDictionary *photo in self.photos) {
        NSRange range = [photo[FLICKR_TAGS] rangeOfString:tag]; 
        if (range.length) {
            numberOfPhotos += 1;
        }
    }
    return numberOfPhotos;
}

- (NSArray *)arrayOfPhotoTags
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for (NSDictionary *photo in self.photos) {
        NSString *tagsInPhoto = photo[FLICKR_TAGS];
        [tags addObjectsFromArray:[tagsInPhoto componentsSeparatedByString:@" "]];
    }
    NSArray *finalArray = [self removeUnwantedTagsFrom:[tags copy]];
    return [finalArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show List"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotoListTag:)]) {
                    UITableViewCell *senderCell = sender;
                    [segue.destinationViewController performSelector:@selector(setPhotoListTag:) withObject:senderCell.textLabel.text];
                    [segue.destinationViewController setTitle:senderCell.textLabel.text];
                }
            }
        }
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taglList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Tags";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    
    cell.textLabel.text = self.taglList[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self numberOfPhotosWithTheTag:self.taglList[indexPath.row]]];
    
    return cell;
}



@end
