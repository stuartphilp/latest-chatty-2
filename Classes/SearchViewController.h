//
//  SearchViewController.h
//  LatestChatty2
//
//  Created by Alex Wayne on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController {
  IBOutlet UISearchBar *terms;
  IBOutlet UISearchBar *author;
  IBOutlet UISearchBar *parentAuthor;
}

@end
