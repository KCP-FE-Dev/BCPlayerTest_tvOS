//
//  ViewController.m
//  BCPlayerTest_tvOS
//
//  Created by 신승환 on 2020/07/02.
//  Copyright © 2020 신승환. All rights reserved.
//

#import "ViewController.h"
#import <BrightcovePlayerSDK/BrightcovePlayerSDK.h>
#import <BrightcoveIMA/BrightcoveIMA.h>
#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>

@import KCPSDK;

@interface ViewController () <BCOVTVPlayerViewDelegate, BCOVPlaybackControllerDelegate, IMAWebOpenerDelegate>

// Brightcove Player
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (strong, nonatomic) id<BCOVPlaybackController> playbackController;
@property (strong, nonatomic) BCOVPlaybackService *playbackService;
//@property (strong, nonatomic) BCOVTVPlayerView *playerView;
@property (strong, nonatomic) KCPBCOVTVPlayerView *playerView;
@property (strong, nonatomic) BCOVTVPlayerViewOptions *options;
@property (strong, nonatomic) BCOVVideo *video;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_options setPresentingViewController:self];
    
    _playerView = [[KCPBCOVTVPlayerView alloc] initWithOptions:_options];
    [_videoContainerView addSubview:_playerView];
    
    [_playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
       
    
    [NSLayoutConstraint activateConstraints:@[[_playerView.topAnchor constraintEqualToAnchor:_videoContainerView.topAnchor],
                                              [_playerView.rightAnchor constraintEqualToAnchor:_videoContainerView.rightAnchor],
                                              [_playerView.leftAnchor constraintEqualToAnchor:_videoContainerView.leftAnchor],
                                              [_playerView.bottomAnchor constraintEqualToAnchor:_videoContainerView.bottomAnchor]]];
       
    [_playerView setDelegate:self];
       
    _playbackService = [Kcp getPlaybackService];
       
    [_playbackService findVideoWithReferenceID:@"6167057370001"
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


    [_playbackController setIsAutoAdvance:YES];
    [_playbackController setIsAutoPlay:YES];
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
//            [self.playerView setVideos:arrVidoes];
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


#pragma mark - BCOVPlaybackController delegate methods
- (void)playbackController:(id<BCOVPlaybackController>)controller
           playbackSession:(id<BCOVPlaybackSession>)session
  didReceiveLifecycleEvent:(BCOVPlaybackSessionLifecycleEvent *)lifecycleEvent
{
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


#pragma mark - IMAWebOpener delegate methods
- (void)webOpenerDidCloseInAppBrowser:(NSObject *)webOpener
{
    [_playbackController resumeAd];
}


@end
