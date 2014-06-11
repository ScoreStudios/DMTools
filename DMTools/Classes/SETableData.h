//
//  SETableData.h
//  DM Tools
//
//  Created by hamouras on 06/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SETableSection : NSObject {
	NSString*			_name;
	BOOL				_expanded;
	BOOL				_editable;
	NSMutableArray*		_rows;
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isEditable) BOOL editable;
@property (nonatomic, readonly) NSArray* rows;

- (NSComparisonResult) compare:(id)otherObject;

@end


@interface SETableData : NSObject {
	NSMutableArray*		_sections;
}

@property (nonatomic, readonly) NSArray * sections;

- (SETableSection *) section:(NSUInteger)sectionIndex;
- (NSString*) sectionName:(NSUInteger)sectionIndex;
- (BOOL) sectionHeaderIsExpanded:(NSUInteger)sectionIndex;
- (BOOL) sectionHeaderIsEditable:(NSUInteger)sectionIndex;
- (void) sectionHeader:(NSUInteger)sectionIndex setExpanded:(BOOL)expanded;
- (void) sectionHeader:(NSUInteger)sectionIndex setEditable:(BOOL)editable;

- (NSUInteger) numberOfExpandedRowsAtSection:(NSUInteger)sectionIndex;
- (NSUInteger) numberOfRowsAtSection:(NSUInteger)sectionIndex;
- (NSArray *) rowsAtSection:(NSUInteger)sectionIndex;
- (id) objectAtSection:(NSUInteger)sectionIndex atRow:(NSUInteger)rowIndex;

- (BOOL) sectionWithHeaderExists:(NSString *)header;
- (NSUInteger) indexOfSectionWithHeader:(NSString *)header;

- (NSUInteger) addSectionWithHeader:(NSString *)header;
- (void) removeSection:(NSUInteger)sectionIndex;

- (BOOL) objectExists:(id)object inSection:(NSUInteger)sectionIndex;
- (NSUInteger) indexOfObject:(id)object inSection:(NSUInteger)sectionIndex;

- (NSUInteger) addObject:(id)object atSection:(NSUInteger)sectionIndex;
- (void) removeObjectAtSection:(NSUInteger)sectionIndex atRow:(NSUInteger)rowIndex;

- (void) removeAllObjects;
- (void) removeAllSections;

- (void) sort;
- (void) sortSection:(NSUInteger)sectionIndex;

@end
