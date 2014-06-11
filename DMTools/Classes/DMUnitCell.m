//
//  DMUnitCell.m
//  DM Tools
//
//  Created by hamouras on 3/21/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMUnitCell.h"
#import "DMDataManager.h"
#import "DMUnit.h"
#import "DMNumber.h"

@implementation DMUnitCell

@synthesize backView = _backView;
@synthesize name = _name, icon = _icon, hp = _hp;
@synthesize initiative = _initiative;
@synthesize statusButton = _statusButton, accessoryButton = _accessoryButton;
@synthesize attribLabels = _attribLabels, attribValues = _attribValues, stateIcons = _stateIcons;

- (id) initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]) != nil)
	{
        // Initialization code
	}
    return self;
}

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
*/

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected
			  animated:animated];

    // Configure the view for the selected state
}
*/

- (void)dealloc
{
	[_stateIcons release];
	[_attribValues release];
	[_attribLabels release];
	[_accessoryButton release];
	[_statusButton release];
	[_initiative release];
	[_hp release];
	[_icon release];
	[_name release];
	[_backView release];
	
	[super dealloc];
}

- (void) setupWithUnit:(DMUnit *)unit forActiveTable:(BOOL)activeTable
{
	const BOOL blodied = activeTable && (unit.HP.value <= unit.HP.maxValue / 2);
	_name.textColor = blodied ? [UIColor redColor] : [UIColor blackColor];
	_name.text = unit.name;
	_icon.image = unit.avatar;
	_hp.text = [unit.HP toShortString];
	_initiative.text = [unit.initiative totalToString];
	
	NSArray* statusIcons = [DMDataManager statusIcons];
	UIColor* defaultColor = [UIColor blueColor];
	UIColor* plusModColor = [UIColor greenColor];
	UIColor* minusModColor = [UIColor redColor];
	const NSUInteger maxStates = _stateIcons.count;
	const NSUInteger maxAttribs = _attribValues.count;
	NSAssert( maxAttribs == _attribLabels.count, @"wrong number of attrib labels" );
	NSUInteger numStates = 0;
	NSUInteger numAttribs = 0;
	for( DMGroup* group in unit.groups )
	{
		switch( group.type )
		{
			case DMGroupTypeBoolean:
				if( numStates < maxStates )
				{
					for( DMBoolean* boolean in group.items )
					{
						NSInteger displayIndex = boolean.display;
						if( displayIndex
						   && boolean.value
						   && displayIndex < statusIcons.count )
						{
							UIImage* image = [statusIcons objectAtIndex:displayIndex];
							UIImageView* imageView = [_stateIcons objectAtIndex:numStates];
							imageView.image = image;
							
							++numStates;
							if( numStates == maxStates )
								break;
						}
					}
				}
				break;

			case DMGroupTypeValue:
			case DMGroupTypeValueModifier:
				if( numAttribs < maxAttribs )
				{
					NSUInteger index = 0;
					for( DMNumber* number in group.items )
					{
						if( number.display )
						{
							NSString* labelName = [group.keys objectAtIndex:index];
							UILabel* attribLabel = [_attribLabels objectAtIndex:numAttribs];
							UILabel* attribValue = [_attribValues objectAtIndex:numAttribs];
							attribLabel.text = ( labelName.length <= 3 ) ? labelName : [labelName substringToIndex:3];
							attribValue.text = [number totalToString];
							NSInteger modifier = number.modifier;
							if( modifier > 0 )
								attribValue.textColor = plusModColor;
							else if( modifier < 0 )
								attribValue.textColor = minusModColor;
							else
								attribValue.textColor = defaultColor;
							
							++numAttribs;
							if( numAttribs == maxAttribs )
								break;
						}
						++index;
					}
				}
				break;
				
			default:
				break;
		};
	}
	
	while( numStates < maxStates )
	{
		UIImageView* imageView = [_stateIcons objectAtIndex:numStates++];
		imageView.image = nil;
	}
	
	while( numAttribs < maxAttribs )
	{
		UILabel* attribLabel = [_attribLabels objectAtIndex:numAttribs];
		UILabel* attribValue = [_attribValues objectAtIndex:numAttribs];
		attribLabel.text = @"";
		attribValue.text = @"";
		++numAttribs;
	}
		
	_statusButton.enabled = activeTable;
	_accessoryButton.enabled = activeTable;
	
	self.accessoryType = activeTable ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDetailDisclosureButton;
	self.selectionStyle = activeTable ? UITableViewCellSelectionStyleGray : UITableViewCellSelectionStyleBlue;
	self.showsReorderControl = activeTable;
}

@end
