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

@interface MMStatus : NSObject {
  NSDate*   _playtime;
  NSDate*   _timeUntilVote;
  NSNumber* _numVotes;
  BOOL _hasVoted;
}

@property (nonatomic, retain) NSDate*   playtime;
@property (nonatomic, retain) NSDate*   timeUntilVote;
@property (nonatomic, retain) NSNumber* numVotes;
@property (nonatomic) BOOL hasVoted;

@end
