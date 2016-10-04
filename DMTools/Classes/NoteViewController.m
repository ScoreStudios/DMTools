//
//  NoteViewController.m
//  DM Tools
//
//  Created by Paul Caristino on 6/5/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteEntry.h"
#import "LibraryViewController.h"


@implementation NoteViewController

@synthesize notesbox;
@synthesize titlefield;
@synthesize detailsfield;
@synthesize groupfield;
@synthesize delegate;


- (id) initWithNote:(NoteEntry *)note
{
    if ((self = [super initWithNibName:@"NoteViewController"
								bundle:nil]))
	{
        currentNote = [note retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.preferredContentSize = CGSizeMake(320.0, 480.0);
	if (currentNote != nil)
	{
		titlefield.text = currentNote.title;
		detailsfield.text = currentNote.details;
		groupfield.text = currentNote.group;
		groupfield.enabled = NO;
		groupfield.textColor = [UIColor grayColor];
		notesbox.text = currentNote.notes;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (currentNote != nil)
	{
		currentNote.title  = titlefield.text;
		currentNote.details = detailsfield.text;
		// skip group
		currentNote.notes = notesbox.text;

		[delegate noteView:self
			  modifiedNote:currentNote];
	}
	else
	{
		currentNote = [[NoteEntry alloc] init];
		currentNote.title = titlefield.text;
		currentNote.details = detailsfield.text;
		currentNote.group = groupfield.text;
		currentNote.notes = notesbox.text;
		
		[delegate noteView:self
				 addedNote:currentNote];
	}
}

/*
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	return YES;
}

 */
/*
- (IBAction) cancelNoteButton: (id) event
{
	[self dismissModalViewControllerAnimated:YES];
	self.notesView = nil;
	self.currentNote = nil;
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES;
}

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
 */
/*
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return self.view;
}
*/
- (void)viewDidUnload
{
    [super viewDidUnload];
	
	[currentNote release];
	currentNote = nil;
}


- (void)dealloc
{
	[currentNote release];
	[notesbox release];
	[titlefield release];
	[detailsfield release];
	[groupfield release];
    [super dealloc];
}

@end
