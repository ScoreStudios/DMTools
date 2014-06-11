//
//  SESettings.m
//  DM Tools
//
//  Created by hamouras on 4/5/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "SESettings.h"


@implementation SESetting
@synthesize label = _label, type = _type, extras = _extras, selector = _selector, target = _target, color = _color, editable = _editable;
@dynamic booleanValue, integerValue, stringValue, detailLabel;

+ (SESetting *) booleanSetting:(NSString *)label withValue:(BOOL)value
{
	SESetting *setting = [SESetting new];
	setting->_type = SettingTypeBoolean;
	setting.label = label;
	setting.booleanValue = value;
	return [setting autorelease];
}

+ (SESetting *) numberSetting:(NSString *)label withValue:(NSInteger)value
{
	SESetting *setting = [SESetting new];
	setting->_type = SettingTypeNumber;
	setting.label = label;
	setting.integerValue = value;
	return [setting autorelease];
}

+ (SESetting *) stringSetting:(NSString *)label withValue:(NSString *)value
{
	SESetting *setting = [SESetting new];
	setting->_type = SettingTypeString;
	setting.label = label;
	setting.stringValue = value;
	return [setting autorelease];
}

+ (SESetting *) selectionSetting:(NSString *)label withOptions:(NSArray *)options selected:(NSInteger)selected
{
	SESetting *setting = [SESetting new];
	setting->_type = SettingTypeSelection;
	setting.label = label;
	setting.integerValue = selected;
	setting.extras = options;
	return [setting autorelease];
}

+ (SESetting *) actionSetting:(NSString *)label withDetailLabel:(NSString *)detailLabel withAction:(SEL)action
{
	SESetting *setting = [SESetting new];
	setting->_type = SettingTypeAction;
	setting.label = label;
	setting.detailLabel = detailLabel;
	setting.selector = action;
	return [setting autorelease];
}

- (BOOL) booleanValue
{
	NSAssert(_type == SettingTypeBoolean, @"setting type mismatch");
	return _data.booleanValue;
}

- (NSInteger) integerValue
{
	NSAssert(_type == SettingTypeNumber || _type == SettingTypeSelection, @"setting type mismatch");
	return _data.integerValue;
}

- (NSString *) stringValue
{
	NSAssert(_type == SettingTypeString, @"setting type mismatch");
	return _data.stringValue;
}

- (NSString *) detailLabel
{
	NSAssert(_type == SettingTypeAction, @"setting type mismatch");
	return _data.stringValue;
}

- (void) setBooleanValue:(BOOL)value
{
	NSAssert(_type == SettingTypeBoolean, @"setting type mismatch");
	_data.booleanValue = value;
}

- (void) setIntegerValue:(NSInteger)value
{
	NSAssert(_type == SettingTypeNumber || _type == SettingTypeSelection, @"setting type mismatch");
	_data.integerValue = value;
}

- (void) setStringValue:(NSString *)value
{
	NSAssert(_type == SettingTypeString, @"setting type mismatch");
	if (_data.stringValue != value)
	{
		[_data.stringValue release];
		_data.stringValue = [value copy];
	}
}

- (void) setDetailLabel:(NSString *)string
{
	NSAssert(_type == SettingTypeAction, @"setting type mismatch");
	if (_data.stringValue != string)
	{
		[_data.stringValue release];
		_data.stringValue = [string copy];
	}
}

- (id) copyWithZone:(NSZone *)zone
{
	SESetting *setting = [SESetting new];
	setting->_type = _type;
	switch (_type)
	{
		case SettingTypeBoolean:
			setting.booleanValue = _data.booleanValue;
			break;
		case SettingTypeNumber:
		case SettingTypeSelection:
			setting.integerValue = _data.integerValue;
			break;
		case SettingTypeString:
		case SettingTypeAction:
			setting.stringValue = _data.stringValue;
			break;
		default:
			NSAssert(0, @"invalid value type");
			break;
	}
	setting.selector = _selector;
	setting.target = _target;
	setting.extras = _extras;
	setting.color = _color;
	setting.editable = _editable;
	return setting;
}

- (void)dealloc
{
	[_color release];
	[_extras release];
	switch (_type)
	{
		case SettingTypeBoolean:
		case SettingTypeNumber:
		case SettingTypeSelection:
			break;
		case SettingTypeAction:
		case SettingTypeString:
			[_data.stringValue release];
			break;
		default:
			NSAssert(0, @"invalid value type");
			break;
	}
	[_label release];
	[super dealloc];
}

@end




@implementation SESettings
@synthesize groupNames, groups;

- (id) init
{
	self = [super init];
	if (self)
	{
		groupNames = [NSMutableArray new];
		groups = [NSMutableArray new];
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	SESettings *settings = [SESettings new];
	settings->groupNames = [groupNames copyWithZone:zone];
	settings->groups = [groups copyWithZone:zone];

	return settings;
}

- (void) dealloc
{
	[groups release];
	[groupNames release];
	
	[super dealloc];
}

- (NSInteger) addGroup:(NSString *)group
{
	[groupNames addObject:group];
	[groups addObject:[NSMutableArray array]];
	return groups.count - 1;
}

- (NSIndexPath *) addSetting:(SESetting *)setting atGroupIndex:(NSInteger)groupIndex
{
	if (groupIndex >= groups.count)
	{
		NSAssert(0, @"group index out of bounds");
		return nil;
	}

	NSMutableArray *group = [groups objectAtIndex:groupIndex];
	[group addObject:setting];
	return [NSIndexPath indexPathForRow:group.count - 1
							  inSection:groupIndex];
}

- (void) addSetting:(SESetting *)setting atIndexPath:(NSIndexPath *)indexPath
{
	NSInteger groupIndex = indexPath.section;
	if (groupIndex >= groups.count)
	{
		NSAssert(0, @"group index out of bounds");
		return;
	}
	
	NSMutableArray *group = [groups objectAtIndex:groupIndex];
	[group insertObject:setting
				atIndex:indexPath.row];
}

- (void) removeSettingAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger groupIndex = indexPath.section;
	if (groupIndex >= groups.count)
	{
		NSAssert(0, @"group index out of bounds");
		return;
	}
	
	NSMutableArray *group = [groups objectAtIndex:groupIndex];
	[group removeObjectAtIndex:indexPath.row];
}

- (void) removeSettingsOfGroupAtIndex:(NSInteger)index
{
	if (index >= groups.count)
	{
		NSAssert(0, @"group index out of bounds");
		return;
	}
	
	NSMutableArray *group = [groups objectAtIndex:index];
	[group removeAllObjects];
}

- (NSString *) groupAtIndex:(NSInteger)index
{
	return [groupNames objectAtIndex:index];
}

- (SESetting *) settingAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *group = [groups objectAtIndex:indexPath.section];
	return [group objectAtIndex:indexPath.row];
}

- (SESetting *) settingAtIndex:(NSInteger)index inGroup:(NSInteger)groupIndex
{
	NSArray *group = [groups objectAtIndex:groupIndex];
	return [group objectAtIndex:index];
}

@end
