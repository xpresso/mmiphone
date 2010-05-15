//
// Copyright 2010 Joakim Bodin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MMStatusDataSource.h"

#import "MMStatusModel.h"
#import "MMStatus.h"
#import "MMPlaylistTrack.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMStatusDataSource

@synthesize timeUntilVote = _timeUntilVote;
@synthesize tableView = _tableView;
@synthesize timeFormatter = _timeFormatter;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _statusModel = [[MMStatusModel alloc] init];
    
    _timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"mm:ss"];
  }
  
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_INVALIDATE_TIMER(_nextTrackInTimer);
  
  TT_RELEASE_SAFELY(_timeFormatter);
  TT_RELEASE_SAFELY(_tableView);
  TT_RELEASE_SAFELY(_timeUntilVote);
  TT_RELEASE_SAFELY(_statusModel);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _statusModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [[NSMutableArray alloc] init];
  NSMutableArray* sections = [[NSMutableArray alloc] init];
  
  TTTableSubtitleItem* playingTrackItem = nil;
  NSMutableArray* playlistTrackItems = [[NSMutableArray alloc] init];
  if ([_statusModel.tracks count] > 0) {
    MMPlaylistTrack* currentTrack = [_statusModel.tracks objectAtIndex:0];
    
    playingTrackItem = [TTTableSubtitleItem itemWithText:currentTrack.title
                        subtitle:[NSString stringWithFormat:@"%@ - %@",
                                  currentTrack.album, currentTrack.artist]];
    
    for (MMPlaylistTrack* track in _statusModel.tracks) {
      if (track == currentTrack) {
        continue;
      }
      
      TTTableSubtitleItem* playlistTrackItem = [TTTableSubtitleItem itemWithText:track.title
                                            subtitle:[NSString stringWithFormat:@"%@ - %@",
                                                      track.album, track.artist]
                                            URL:track.uri];
      [playlistTrackItems addObject:playlistTrackItem];
    }
  }
  else {
    playingTrackItem = [TTTableSubtitleItem itemWithText:
                        NSLocalizedString(@"No song playing", @"") subtitle:@" "];
  }
  
  
  
  NSString *nextTrackInText = [NSString stringWithFormat:
                               NSLocalizedString(@"Next track in: %@", @""),
                               [self.timeFormatter stringFromDate:
                                _statusModel.status.timeUntilVote]];
  
  TTTableGrayTextItem* nextTrackInItem = [TTTableGrayTextItem itemWithText:nextTrackInText];
  
  NSMutableArray* currentTrackItems = [[NSMutableArray alloc] init];
  [currentTrackItems addObject:playingTrackItem];
  [currentTrackItems addObject:nextTrackInItem];
  
  [sections addObject:@""];
  [items addObject:currentTrackItems];
  TT_RELEASE_SAFELY(currentTrackItems);
  
  [sections addObject:NSLocalizedString(@"Upcoming Playlist", @"")];
  [items addObject:playlistTrackItems];
  TT_RELEASE_SAFELY(playlistTrackItems);
  
  self.items = items;
  self.sections = sections;
  TT_RELEASE_SAFELY(items);
  TT_RELEASE_SAFELY(sections);
  
  self.tableView = tableView;
  self.timeUntilVote = _statusModel.status.timeUntilVote;
  
  [_nextTrackInTimer invalidate];
  _nextTrackInTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
    selector:@selector(updateNextTrackIn:) userInfo:nil repeats:YES];
}
               
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateNextTrackIn:(NSTimer*)timer {
  NSTimeInterval nextTimeUntilVote = [self.timeUntilVote timeIntervalSince1970];
  nextTimeUntilVote -= 1.0;
  if (nextTimeUntilVote <= 0) {
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
    return;
  }
  
  NSString *nextTrackInText = [NSString stringWithFormat:
                               NSLocalizedString(@"Next track in: %@", @""),
                               [self.timeFormatter stringFromDate:self.timeUntilVote]];
  
  TTTableGrayTextItem* nextTrackInItem = [[self.items objectAtIndex:0] objectAtIndex:1];
  nextTrackInItem.text = nextTrackInText;
  
  self.timeUntilVote = [NSDate dateWithTimeIntervalSince1970:nextTimeUntilVote];
  
  [self.tableView reloadRowsAtIndexPaths:
      [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]]
    withRowAnimation:UITableViewRowAnimationNone];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Music Machine server was not found", @"");
}

@end
