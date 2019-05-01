#import <libactivator/libactivator.h>
#include <dispatch/dispatch.h>
#import <SpringBoard/SBApplication.h>
#import <MediaRemote/MediaRemote.h>

#define LASendEventWithName(eventName) \
	[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *MusicEvents_startedEventName = @"com.kaneb.musicstarted";
static NSString *MusicEvents_endedEventName = @"com.kaneb.musicended";

@interface MusicEventsDataSource : NSObject <LAEventDataSource> {}

+ (id)sharedInstance;

@end

@implementation MusicEventsDataSource{
    int _nowPlayingAppPID;
}

+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}

+ (void)load {
	[self sharedInstance];
}

- (id)init {
	if ((self = [super init])) {
		if (LASharedActivator.isRunningInsideSpringBoard) {
            [LASharedActivator registerEventDataSource:self forEventName:MusicEvents_startedEventName];
            [LASharedActivator registerEventDataSource:self forEventName:MusicEvents_endedEventName];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nowPlayingAppChanged) name:(__bridge NSString*) kMRMediaRemoteNowPlayingApplicationDidChangeNotification object:nil];
		}
	}
	return self;
}

-(void)nowPlayingAppChanged{
    MRMediaRemoteGetNowPlayingApplicationPID(dispatch_get_main_queue(), ^(int PID) {
        if (PID !=_nowPlayingAppPID){
            if (_nowPlayingAppPID==0){
                LASendEventWithName(MusicEvents_startedEventName);
            } else if (PID==0){
                LASendEventWithName(MusicEvents_endedEventName);
            }
            _nowPlayingAppPID=PID;
        }
    });
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
    if ([eventName isEqualToString:MusicEvents_startedEventName]){
        return @"Music started";
    } else if ([eventName isEqualToString:MusicEvents_endedEventName]){
        return @"Music ended";
    } else {
        return @"Music events error";
    }
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Media Playback";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
    if ([eventName isEqualToString:MusicEvents_startedEventName]){
        return @"Music started";
    } else if ([eventName isEqualToString:MusicEvents_endedEventName]){
        return @"Music ended/music app closed";
    } else {
        return @"Music events error";
    }
}

- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode {
	return YES;
}
@end
