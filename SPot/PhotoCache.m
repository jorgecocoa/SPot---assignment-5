//
//  PhotoCache.m
//  SPot
//
//  Created by Jorge García-Luengo on 16/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import "PhotoCache.h"

@interface PhotoCache ()

@property (strong, nonatomic) NSFileManager *fileManager;
@property (nonatomic) NSUInteger maximunChacheSize;

@end

@implementation PhotoCache

#pragma mark - accessors -------------

- (NSFileManager *)fileManager //the file manager
{
    if  (!_fileManager) _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}


- (NSURL *)URLForCache
{
    NSURL *urlCache = [self.fileManager URLForDirectory:NSCachesDirectory
                                               inDomain:NSUserDomainMask
                                      appropriateForURL:nil
                                                 create:NO
                                                  error:nil];
    NSError *error = nil;
    NSURL *photoFolder = [urlCache URLByAppendingPathComponent:@"Photos"];
    
    if (![self.fileManager fileExistsAtPath:[photoFolder path]]) {
        [self.fileManager createDirectoryAtURL:photoFolder
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
    }
    return photoFolder;
}

- (NSURL *)photoPath
{
    NSArray *urls = [self.fileManager URLsForDirectory:NSCachesDirectory
                                             inDomains:NSUserDomainMask];
    NSURL *cacheFolder = urls[0];
    NSURL *photoFolder = [cacheFolder URLByAppendingPathComponent:@"Photos"];
    return photoFolder;
}

#pragma mark - methods ---------------

#define DATE_KEY @"date"
#define FILE_SIZE_KEY @"file size"
#define URL_KEY @"url"

- (NSArray *)filesInCache
{
    NSURL *cacheURL = [self URLForCache];
    
    NSDirectoryEnumerator *directoryEnumerator = [self.fileManager enumeratorAtURL:cacheURL
                                                        includingPropertiesForKeys:@[NSURLContentAccessDateKey, NSURLFileSizeKey]
                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                      errorHandler:nil];
    NSMutableArray *filesInMutableArray = [[NSMutableArray alloc] init];
    
    for (NSURL *url in directoryEnumerator) {
        NSDate *date;
        [url getResourceValue:&date forKey:NSURLContentAccessDateKey error:nil];
        NSNumber *bytes;
        [url getResourceValue:&bytes forKey:NSURLFileSizeKey error:nil];
        
        [filesInMutableArray addObject:@{DATE_KEY: date, FILE_SIZE_KEY:bytes, URL_KEY: url}];
    }
    
    NSSortDescriptor *keyForSorting = [[NSSortDescriptor alloc] initWithKey:DATE_KEY ascending:YES];
    
    return [filesInMutableArray sortedArrayUsingDescriptors:@[keyForSorting]];
}


- (void)putPhotosInCahe:(NSData *)photoData toURL:(NSURL *)photoURL
{
    if (![photoURL isFileURL]) {
        NSURL *file = [self createLocalUrlForFile:photoURL];
        [self makeRoomForImageData:photoData];
        [photoData writeToURL:file atomically:YES];
    }
    [self filesInCache];
}

- (NSURL *)createLocalUrlForFile:(NSURL *)url
{
    NSString *lastPart = [url lastPathComponent];
    return [[self URLForCache] URLByAppendingPathComponent:lastPart];
}

- (NSData *)retrivePhotosFromCacheWithURL:(NSURL *)photoURL
{
    NSURL *photoURLToFile = [self createLocalUrlForFile:photoURL];
    NSData *data;

    if ([self.fileManager fileExistsAtPath:[photoURLToFile path]]) {
        data = [[NSData alloc] initWithContentsOfURL:photoURLToFile];
        //NSLog(@"chechking %u", [data length]);
    } else {
        data = [[NSData alloc] initWithContentsOfURL:photoURL];
    }
    
    return data;
}

- (void)makeRoomForImageData:(NSData *)photoData
{
    NSUInteger imageSize = [photoData length];
    NSArray *arrayOfFiles = [self filesInCache];
    NSLog(@"checking on array of files: %@", arrayOfFiles);
    NSUInteger cacheSizeBeforeAddingData = 0;
    for (int i=0; i<[arrayOfFiles count];  i++)
    {
        NSLog(@"for loop filesize%@", arrayOfFiles[i][FILE_SIZE_KEY]);
        cacheSizeBeforeAddingData += [arrayOfFiles[i][FILE_SIZE_KEY] integerValue];
    }
    NSLog(@"cacheSizeBeforeAddingData: %u",cacheSizeBeforeAddingData);
    for (int i = 0; (cacheSizeBeforeAddingData>([self maximunChacheSize]-imageSize)); i++) {
        [self.fileManager removeItemAtURL:arrayOfFiles[i][URL_KEY] error:nil];
        if ([arrayOfFiles[i][FILE_SIZE_KEY] isKindOfClass:[NSNumber class]]) {
            cacheSizeBeforeAddingData -= [(NSNumber *)arrayOfFiles[i][FILE_SIZE_KEY] integerValue];
            NSLog(@"restando %u", [(NSNumber *)arrayOfFiles[i][FILE_SIZE_KEY] integerValue]);
        }
    }
}

#define IPHONE_MAX_CACHE_SIZE 3000000
#define IPAD_MAX_CACHE_SIZE 12000000

- (NSUInteger)maximunChacheSize
{
    if (!_maximunChacheSize) _maximunChacheSize = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? IPAD_MAX_CACHE_SIZE : IPHONE_MAX_CACHE_SIZE;
    return _maximunChacheSize;
}

@end
