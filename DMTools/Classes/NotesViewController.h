//
//  NotesViewController.h
//  testsplitview
//
//  Created by hamouras on 30/07/2010.
//  Copyright Score Studios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SETableData.h"
#import "NoteViewController.h"

@class NoteEntry;

@interface NotesViewController : UITableViewController<NoteViewDelegate>
{
	NSMutableArray *			_sectionButtons;
	SETableData *				_notesTableData;
}

@property (nonatomic, readonly) SETableData * notesTableData;

- (BOOL) loadData:(NSString *)version;
- (void) saveData;

- (void)reloadData;

@end
