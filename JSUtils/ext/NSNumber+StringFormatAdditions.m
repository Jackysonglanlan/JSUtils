//
//  NSNumber+StringFormatAdditions.m
//
//  Created by Nick Forge on 30/01/10.
//  Copyright 2010 Nick Forge. All rights reserved.
//

#import "NSNumber+StringFormatAdditions.h"

NSNumberFormatter *sharedNumberFormatterDecimalStyle = nil;
NSNumberFormatter *sharedNumberFormatterCurrencyStyle = nil;
NSNumberFormatter *sharedNumberFormatterPercentStyle = nil;
NSNumberFormatter *sharedNumberFormatterScientificStyle = nil;
NSNumberFormatter *sharedNumberFormatterSpellOutStyle = nil;

static NSString *kSharedNumberFormatterDecimalStyleLock = @"kSharedNumberFormatterDecimalStyleLock";
static NSString *kSharedNumberFormatterCurrencyStyleLock = @"kSharedNumberFormatterCurrencyStyleLock";
static NSString *kSharedNumberFormatterPercentStyleLock = @"kSharedNumberFormatterPercentStyleLock";
static NSString *kSharedNumberFormatterScientificStyleLock = @"kSharedNumberFormatterScientificStyleLock";
static NSString *kSharedNumberFormatterSpellOutStyleLock = @"kSharedNumberFormatterSpellOutStyleLock";


@implementation NSNumber (NSNumber_StringFormatAdditions)


#pragma mark -
//------------------------------------------------------------------------------
//
//	stringWithNumberStyle Methods
//
//------------------------------------------------------------------------------
#pragma mark stringWithNumberStyle Methods

- (NSString *)jsStringWithNumberStyle:(NSNumberFormatterStyle)style
{
	NSNumberFormatter *formatter = nil;
	switch (style) {
		case NSNumberFormatterDecimalStyle:
			if (sharedNumberFormatterDecimalStyle) {
				formatter = sharedNumberFormatterDecimalStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterDecimalStyleLock) {
				if (sharedNumberFormatterDecimalStyle == nil) {
					sharedNumberFormatterDecimalStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterDecimalStyle.numberStyle = NSNumberFormatterDecimalStyle;
				}
			}
			formatter = sharedNumberFormatterDecimalStyle;
			break;
			
		case NSNumberFormatterCurrencyStyle:
			if (sharedNumberFormatterCurrencyStyle) {
				formatter = sharedNumberFormatterCurrencyStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterCurrencyStyleLock) {
				if (sharedNumberFormatterCurrencyStyle == nil) {
					sharedNumberFormatterCurrencyStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterCurrencyStyle.numberStyle = NSNumberFormatterCurrencyStyle;
				}
			}
			formatter = sharedNumberFormatterCurrencyStyle;
			break;
			
		case NSNumberFormatterPercentStyle:
			if (sharedNumberFormatterPercentStyle) {
				formatter = sharedNumberFormatterPercentStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterPercentStyleLock) {
				if (sharedNumberFormatterPercentStyle == nil) {
					sharedNumberFormatterPercentStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterPercentStyle.numberStyle = NSNumberFormatterPercentStyle;
				}
			}
			formatter = sharedNumberFormatterPercentStyle;
			break;
			
		case NSNumberFormatterScientificStyle:
			if (sharedNumberFormatterScientificStyle) {
				formatter = sharedNumberFormatterScientificStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterScientificStyleLock) {
				if (sharedNumberFormatterScientificStyle == nil) {
					sharedNumberFormatterScientificStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterScientificStyle.numberStyle = NSNumberFormatterScientificStyle;
				}
			}
			formatter = sharedNumberFormatterScientificStyle;
			break;
			
		case NSNumberFormatterSpellOutStyle:
			if (sharedNumberFormatterSpellOutStyle) {
				formatter = sharedNumberFormatterSpellOutStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterSpellOutStyleLock) {
				if (sharedNumberFormatterSpellOutStyle == nil) {
					sharedNumberFormatterSpellOutStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterSpellOutStyle.numberStyle = NSNumberFormatterSpellOutStyle;
				}
			}
			formatter = sharedNumberFormatterSpellOutStyle;				
			break;
			
		default:
			break;
	}
	return [formatter stringFromNumber:self];
}

#pragma mark -
//------------------------------------------------------------------------------
//
//	numberWithString Methods
//
//------------------------------------------------------------------------------
#pragma mark numberWithString Methods

+ (NSNumber *)jsNumberWithString:(NSString *)string
                     numberStyle:(NSNumberFormatterStyle)style
{
	NSNumberFormatter *formatter = nil;
	switch (style) {
		case NSNumberFormatterDecimalStyle:
			if (sharedNumberFormatterDecimalStyle) {
				formatter = sharedNumberFormatterDecimalStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterDecimalStyleLock) {
				if (sharedNumberFormatterDecimalStyle == nil) {
					sharedNumberFormatterDecimalStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterDecimalStyle.numberStyle = NSNumberFormatterDecimalStyle;
				}
			}
			formatter = sharedNumberFormatterDecimalStyle;
			break;
			
		case NSNumberFormatterCurrencyStyle:
			if (sharedNumberFormatterCurrencyStyle) {
				formatter = sharedNumberFormatterCurrencyStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterCurrencyStyleLock) {
				if (sharedNumberFormatterCurrencyStyle == nil) {
					sharedNumberFormatterCurrencyStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterCurrencyStyle.numberStyle = NSNumberFormatterCurrencyStyle;
				}
			}
			formatter = sharedNumberFormatterCurrencyStyle;
			break;
			
		case NSNumberFormatterPercentStyle:
			if (sharedNumberFormatterPercentStyle) {
				formatter = sharedNumberFormatterPercentStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterPercentStyleLock) {
				if (sharedNumberFormatterPercentStyle == nil) {
					sharedNumberFormatterPercentStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterPercentStyle.numberStyle = NSNumberFormatterPercentStyle;
				}
			}
			formatter = sharedNumberFormatterPercentStyle;
			break;
			
		case NSNumberFormatterScientificStyle:
			if (sharedNumberFormatterScientificStyle) {
				formatter = sharedNumberFormatterScientificStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterScientificStyleLock) {
				if (sharedNumberFormatterScientificStyle == nil) {
					sharedNumberFormatterScientificStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterScientificStyle.numberStyle = NSNumberFormatterScientificStyle;
				}
			}
			formatter = sharedNumberFormatterScientificStyle;
			break;
			
		case NSNumberFormatterSpellOutStyle:
			if (sharedNumberFormatterSpellOutStyle) {
				formatter = sharedNumberFormatterSpellOutStyle;
				break;
			}
			@synchronized(kSharedNumberFormatterSpellOutStyleLock) {
				if (sharedNumberFormatterSpellOutStyle == nil) {
					sharedNumberFormatterSpellOutStyle = [[NSNumberFormatter alloc] init];
					sharedNumberFormatterSpellOutStyle.numberStyle = NSNumberFormatterSpellOutStyle;
				}
			}
			formatter = sharedNumberFormatterSpellOutStyle;				
			break;
			
		default:
			break;
	}
	return [formatter numberFromString:string];
}
@end
