//
//  SESettings.h
//  DM Tools
//
//  Created by hamouras on 4/5/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum SESettingType
{
	SettingTypeBoolean	= 0,
	SettingTypeNumber,
	SettingTypeString,
	SettingTypeSelection,
	SettingTypeAction
} SESettingType;

@interface SESetting : NSObject<NSCopying> {
@private
	NSString *		_label;
	SESettingType	_type;
	union
	{
		BOOL		booleanValue;
		NSInteger	integerValue;
		NSString *	stringValue;
	} _data;
	SEL				_selector;
	id				_target;
	id				_extras;
	UIColor*		_color;
	BOOL			_editable;
}
@property (nonatomic, copy) NSString *label;
@property (nonatomic, readonly) SESettingType type;
@property (nonatomic, assign) BOOL booleanValue;
@property (nonatomic, assign) NSInteger integerValue;
@property (nonatomic, copy) NSString * stringValue;
@property (nonatomic, copy) NSString * detailLabel;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id target;
@property (nonatomic, retain) id extras;
@property (nonatomic, retain) UIColor* color;
@property (nonatomic, assign) BOOL editable;

+ (SESetting *) booleanSetting:(NSString *)label withValue:(BOOL)value;
+ (SESetting *) numberSetting:(NSString *)label withValue:(NSInteger)value;
+ (SESetting *) stringSetting:(NSString *)label withValue:(NSString *)value;
+ (SESetting *) selectionSetting:(NSString *)label withOptions:(NSArray *)options selected:(NSInteger)selected;
+ (SESetting *) actionSetting:(NSString *)label withDetailLabel:(NSString*)detailLabel withAction:(SEL)action;

@end



@interface SESettings : NSObject<NSCopying> {
	NSMutableArray *	groupNames;
	NSMutableArray *	groups;
}

@property (nonatomic, readonly) NSArray *	groupNames;
@property (nonatomic, readonly) NSArray *	groups;

- (NSInteger) addGroup:(NSString *)group;
- (NSIndexPath *) addSetting:(SESetting *)setting atGroupIndex:(NSInteger)groupIndex;
- (void) addSetting:(SESetting *)setting atIndexPath:(NSIndexPath *)indexPath;
- (void) removeSettingAtIndexPath:(NSIndexPath *)indexPath;
- (void) removeSettingsOfGroupAtIndex:(NSInteger)index;
- (NSString *) groupAtIndex:(NSInteger)index;
- (SESetting *) settingAtIndexPath:(NSIndexPath *)indexPath;
- (SESetting *) settingAtIndex:(NSInteger)index inGroup:(NSInteger)groupIndex;

@end
