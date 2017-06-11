#import <Foundation/Foundation.h>
#import "DWDownloader.h"
#import <UIKit/UIKit.h>

enum {
    DWDownloadStatusWait = 1,
    DWDownloadStatusStart,
    DWDownloadStatusDownloading,
    DWDownloadStatusPause,
    DWDownloadStatusFinish,
    DWDownloadStatusFail
};

typedef NSInteger DWDownloadStatus;

@interface DWDownloadItem : NSObject

@property NSInteger streamID;
@property NSInteger streamUserID;
@property (strong, nonatomic)NSString *streamTitle;
@property (strong, nonatomic)NSString *streamUserName;
@property (strong, nonatomic)NSString *streamHash;
@property (strong, nonatomic)NSString *definition;
@property (strong, nonatomic)NSString *videoId;
@property (strong, nonatomic)NSString *videoPath;
@property (assign, nonatomic)NSInteger videoFileSize;
@property (assign, nonatomic)NSInteger videoDownloadedSize;
@property (assign, nonatomic)float videoDownloadProgress;
@property (assign, nonatomic)DWDownloadStatus videoDownloadStatus;

@property (strong, nonatomic)DWDownloader *downloader;

- (id)initWithItem:(NSDictionary *)item;

- (NSDictionary *)getItemDictionary;
- (NSString*)description;

- (UIImage *)getDownloadStatusImage;

@end


@interface DWDownloadItems : NSObject

@property (strong, nonatomic)NSMutableArray *items;
@property (assign, atomic)BOOL isBusy;

- (id)initWithPath:(NSString *)path;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (BOOL)writeToPlistFile:(NSString*)filename;

@end
