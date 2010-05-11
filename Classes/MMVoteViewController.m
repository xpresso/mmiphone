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

#import "MMVoteViewController.h"

#import "MMVoteDataSource.h"

#import "MMVoteModel.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MMVoteViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) initWithTrackUri:(NSString*)trackUri query:(NSDictionary*)query {
  if (self = [super init]) {
    self.variableHeightRows = YES;
    self.tableViewStyle = UITableViewStyleGrouped;
    
    self.dataSource = [[[MMVoteDataSource alloc] initWithTrackUri:trackUri] autorelease];
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  self.navigationItem.rightBarButtonItem =
  [[[UIBarButtonItem alloc] initWithTitle:@"Send Vote" style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(confirm)] autorelease];
}

- (void)confirm {
  TTAlertViewController* alert = [[[TTAlertViewController alloc]
                                   initWithTitle:@"Send Vote"
                                   message:@"Sure you want to send your vote?"] autorelease];
  [alert addButtonWithTitle:@"Yes" URL:
   [NSString stringWithFormat:@"mmiphone://vote/send/%@",
    [(MMVoteModel*)self.dataSource.model trackUri]]];
  [alert addCancelButtonWithTitle:@"No" URL:nil];
  [alert showInView:[self view] animated:YES];
}

- (void)send:(NSString*)trackUri {
  TTDINFO(@"Send vote for: %@", trackUri);
  [self dismissModalViewControllerAnimated:NO];
}

@end