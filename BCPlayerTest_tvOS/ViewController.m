//
//  ViewController.m
//  BCPlayerTest_tvOS
//
//  Created by 신승환 on 2020/07/02.
//  Copyright © 2020 신승환. All rights reserved.
//

#import <BrightcoveIMA/BrightcoveIMA.h>
#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>

#import "ViewController.h"

@import KCPSDK;

@interface ViewController () <KCPBCOVTVPlayerViewDelegate, BCOVPlaybackControllerDelegate, PlaybackRateTabBarItemViewDelegate, IMAWebOpenerDelegate>

// Brightcove Player
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (strong, nonatomic) id<BCOVPlaybackController> playbackController;
@property (strong, nonatomic) id<BCOVPlaybackSession> playbackSession;
@property (strong, nonatomic) BCOVPlaybackService *playbackService;
@property (strong, nonatomic) KCPBCOVTVPlayerView *playerView;
@property (strong, nonatomic) BCOVTVPlayerViewOptions *options;
@property (strong, nonatomic) BCOVVideo *video;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _options = [[BCOVTVPlayerViewOptions alloc] init];
    [_options setPresentingViewController:self];
    
    _playerView = [[KCPBCOVTVPlayerView alloc] initWithOptions:_options];
    [_playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_videoContainerView addSubview:_playerView];
    [NSLayoutConstraint activateConstraints:@[[_playerView.topAnchor constraintEqualToAnchor:_videoContainerView.topAnchor],
                                              [_playerView.rightAnchor constraintEqualToAnchor:_videoContainerView.rightAnchor],
                                              [_playerView.leftAnchor constraintEqualToAnchor:_videoContainerView.leftAnchor],
                                              [_playerView.bottomAnchor constraintEqualToAnchor:_videoContainerView.bottomAnchor]]];
       
    [_playerView setDelegate:self];
       
    _playbackService = [Kcp getPlaybackService];
    [_playbackService findVideoWithVideoID:@"6167057370001"
                                parameters:nil
                                completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
        if (error)
        {
            NSLog(@"[BCP] PlaybackService error ==> %@", [error debugDescription]);
        }
        else
        {
            self.video = video;
               
            [self createPlaybackController];
            [self configPlayerView];
               
            [self videoPlay];
        }
    }];
}

- (void)createPlaybackController
{
    IMAAdsRenderingSettings *renderSettings = [[IMAAdsRenderingSettings alloc] init];
    [renderSettings setWebOpenerPresentingController:self];
    [renderSettings setWebOpenerDelegate:self];
    
    _playbackController = [Kcp getPlaybackControllerWithRenderSettings:renderSettings
                                                            playerView:_playerView];


    _playbackController.autoAdvance = YES;
    _playbackController.autoPlay = YES;
    [_playbackController setDelegate:self];
}

- (void)configPlayerView
{
    [_playerView setPlaybackController:_playbackController];
    [_playerView configure];
}

- (void)videoPlay
{
    [BCOVPlaybackControllerHelper playWithVideo:_video
                                playbackService:_playbackService
                                     completion:^(BOOL success, BCOVVideo * _Nullable video, NSArray<BCOVVideo *> * _Nullable arrVidoes, NSError * _Nullable error) {
        if (success)
        {
//            [self.playerView setTitle:[video getName]];

            [self.playerView setVideos:arrVidoes];
            [self.playbackController setVideos:arrVidoes];
        }
        else
        {
            if (error)
            {
                NSLog(@"[BCP] error => %@", [error debugDescription]);
            }
        }
    }];
}


#pragma mark - KCPBCOVTVPlayerView delegate methods

- (void)didMoveProgressBar
{
    NSLog(@"Did move progress bar");
}

- (void)didStop
{
    NSLog(@"stop");
}

- (void)didTapFastForward
{
    NSLog(@"fast forward");
}

- (void)didTapRewind
{
    NSLog(@"rewind");
}

- (void)didUpdateAudioLanguageWithLanguageCode:(NSString * _Nullable)languageCode
{
    NSLog(@"Did update audio language to %@", languageCode);
}

- (void)didUpdateSubtitleLanguageWithLanguageCode:(NSString * _Nullable)languageCode
{
    NSLog(@"Did update subtitle language to %@", languageCode);
}

- (void)didUpdatePlaybackSpeedWithRate:(float)rate
{
    NSLog(@"Did update playback speed to %f", rate);
}



#pragma mark - BCOVPlaybackController delegate methods

- (void)playbackController:(id<BCOVPlaybackController>)controller
didAdvanceToPlaybackSession:(id<BCOVPlaybackSession>)session
{
    NSLog("ViewController Debug - Advanced to new session.")
}

- (void)playbackController:(id<BCOVPlaybackController>)controller
           playbackSession:(id<BCOVPlaybackSession>)session
  didReceiveLifecycleEvent:(BCOVPlaybackSessionLifecycleEvent *)lifecycleEvent
{
    _playbackSession = session;
    NSLog(@"[BCP] BCP Life cycle event ==> %@", lifecycleEvent.eventType);
    if ([lifecycleEvent.eventType isEqualToString:kBCOVPlaybackSessionLifecycleEventEnd])
    {
        NSLog(@"[BCP] Playback ended");
    }
    else if ([lifecycleEvent.eventType isEqualToString:kBCOVPlaybackSessionLifecycleEventFail])
    {
        NSLog(@"[BCP] Playback failed");
    }
    else if ([lifecycleEvent.eventType isEqualToString:kBCOVPlaybackSessionLifecycleEventPlay])
    {
        NSLog(@"[BCP] Playback started");
    }
}


#pragma mark - PlaybackRateTabBarItemView delegate method
- (void)didSelectPlaybackSpeed:(CGFloat)rate
{
    _playbackSession.player.rate = rate;
}


#pragma mark - IMAWebOpener delegate methods

- (void)webOpenerDidCloseInAppBrowser:(NSObject *)webOpener
{
    [_playbackController resumeAd];
}


#pragma mark - BCOVIMAPlaybackSessionDelegate

- (void)willCallIMAAdsLoaderRequestAdsWithRequest:(IMAAdsRequest *)adsRequest forPosition:(NSTimeInterval)position {
    adsRequest.vastLoadTimeout = 3000.;
    NSLog(@"ViewController Debug - IMAAdsRequest.vastLoadTimeout set to %.1f milliseconds.", adsRequest.vastLoadTimeout);
}

@end
