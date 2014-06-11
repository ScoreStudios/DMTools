//
//  NoteViewController.h
//  DM Tools
//
//  Created by Paul Caristino on 6/5/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEAutoInputViewController.h"

@class LibraryViewController;
@class NoteEntry;
@protocol NoteViewDelegate;

@interface NoteViewController : SEAutoInputViewController {
	UITextView *notesbox;
	UITextField *titlefield;
	UITextField *detailsfield;
	UITextField *groupfield;
	NoteEntry *currentNote;
	
	id<NoteViewDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITextView *notesbox;
@property (nonatomic, retain) IBOutlet UITextField *titlefield;
@property (nonatomic, retain) IBOutlet UITextField *detailsfield;
@property (nonatomic, retain) IBOutlet UITextField *groupfield;
@property (nonatomic, assign) id<NoteViewDelegate> delegate;

- (id) initWithNote:(NoteEntry *)note;

@end

@protocol NoteViewDelegate

@required
- (void) noteView:(NoteViewController *)noteView addedNote:(NoteEntry *)note;
- (void) noteView:(NoteViewController *)noteView modifiedNote:(NoteEntry *)note;

@end