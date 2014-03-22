//
//  WMBradenCellSelectTableViewCell.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMBradenCellSelectTableViewCell.h"
#import "WMBradenCellTableViewCell.h"
#import "WCBradenCell+Custom.h"
#import "DocumentManager.h"

@interface WMBradenCellSelectTableViewCell()

@property (readonly, nonatomic) BOOL isHighlightedOrSelected;
@property (strong, nonatomic) NSManagedObjectID *bradenCellObjectID;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;

- (void)handleMemoryWarning;
- (void)handleDocumentClosed;

@end

@implementation WMBradenCellSelectTableViewCell

@synthesize bradenCell=_bradenCell, bradenCellObjectID=_bradenCellObjectID, managedObjectContext=_managedObjectContext;
@synthesize opaqueNotificationObservers=_opaqueNotificationObservers;

- (BOOL)isHighlightedOrSelected
{
    return self.isHighlighted || self.isSelected;
}

+ (NSDictionary *)titleAttributes
{
    static NSDictionary *DefinitionTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                     paragraphStyle, NSParagraphStyleAttributeName,
                                     nil];
    });
    return DefinitionTitleAttributes;
}

+ (NSDictionary *)titleSelectedAttributes
{
    static NSDictionary *DefinitionTitleSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        DefinitionTitleSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont boldSystemFontOfSize:15.0], NSFontAttributeName,
                                             [UIColor whiteColor], NSForegroundColorAttributeName,
                                             paragraphStyle, NSParagraphStyleAttributeName,
                                             nil];
    });
    return DefinitionTitleSelectedAttributes;
}

+ (NSDictionary *)descAttributes
{
    static NSDictionary *DefinitionDescAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DefinitionDescAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    paragraphStyle, NSParagraphStyleAttributeName,
                                    nil];
    });
    return DefinitionDescAttributes;
}

+ (NSDictionary *)descSelectedAttributes
{
    static NSDictionary *DefinitionDescSelectedAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSLineBreakByWordWrapping;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        DefinitionDescSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                            paragraphStyle, NSParagraphStyleAttributeName,
                                            nil];
    });
    return DefinitionDescSelectedAttributes;
}

+ (CGFloat)recommendedHeightForBradenCell:(WCBradenCell *)bradenCell forWidth:(CGFloat)width
{
    CGFloat height = 0.0;
	// draw title
    NSString *string = bradenCell.title;
    CGSize aSize = [string sizeWithAttributes:[self titleAttributes]];
    height += aSize.height;
    // draw desc
    string = bradenCell.primaryDescription;
    if ([bradenCell.secondaryDescription length] > 0) {
        string = [string stringByAppendingFormat:@" OR %@", bradenCell.secondaryDescription];
    }
    aSize = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                              attributes:[self descAttributes]
                                 context:nil].size;
    height += aSize.height;
    height += 8.0;
    height = fmaxf(44.0, height);
    return height;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __weak __typeof(self) weakSelf = self;
        // listen for low memory
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                                        object:nil
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *notification) {
                                                                        [weakSelf handleMemoryWarning];
                                                                    }];
        [self.opaqueNotificationObservers addObject:observer];
        // listen for document closure and delete
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kDocumentDeletedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handleDocumentClosed];
                                                                 }];
        [self.opaqueNotificationObservers addObject:observer];
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:kDocumentClosedNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:^(NSNotification *notification) {
                                                                     [weakSelf handleDocumentClosed];
                                                                 }];
        [self.opaqueNotificationObservers addObject:observer];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        _bradenCell = nil;
        _bradenCellObjectID = nil;
        // stop listening
        for (id observer in _opaqueNotificationObservers) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        _opaqueNotificationObservers = nil;;
    }
}

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (WCBradenCell *)bradenCell
{
    if (nil == _bradenCell && nil != _bradenCellObjectID) {
        _bradenCell = (WCBradenCell *)[_managedObjectContext objectWithID:_bradenCellObjectID];
    }
    return _bradenCell;
}

- (void)setBradenCell:(WCBradenCell *)bradenCell
{
	if (_bradenCell == bradenCell) {
		return;
	}
	// else
	[self willChangeValueForKey:@"bradenCell"];
	_bradenCell = bradenCell;
	[self didChangeValueForKey:@"bradenCell"];
    _bradenCellObjectID = [bradenCell objectID];
    _managedObjectContext = [bradenCell managedObjectContext];
	[self setNeedsDisplay];
}

- (void)handleMemoryWarning
{
    _bradenCell = nil;
}

- (void)handleDocumentClosed
{
    _bradenCell = nil;
    _bradenCellObjectID = nil;
    _managedObjectContext = nil;
}

- (void)drawContentView:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(self.customContentView.bounds, self.separatorInset);
	CGFloat width = CGRectGetWidth(rect);
	CGFloat x = CGRectGetMinX(rect);
	CGFloat y = 4.0;
	// draw title
    NSString *string = [NSString stringWithFormat:@"%@ (%@)", self.bradenCell.title, self.bradenCell.value];
    NSDictionary *textAttributes = nil;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMBradenCellSelectTableViewCell titleSelectedAttributes];
    } else {
        textAttributes = [WMBradenCellSelectTableViewCell titleAttributes];
    }
    CGSize aSize = [string sizeWithAttributes:textAttributes];
	[string drawAtPoint:CGPointMake(x, y) withAttributes:textAttributes];
    y += aSize.height;
    // draw score if not expanded, otherwise must draw desc, and then if scored, draw score
    string = self.bradenCell.primaryDescription;
    if (self.isHighlightedOrSelected) {
        textAttributes = [WMBradenCellSelectTableViewCell descSelectedAttributes];
    } else {
        textAttributes = [WMBradenCellSelectTableViewCell descAttributes];
    }
    if ([self.bradenCell.secondaryDescription length] > 0) {
        string = [string stringByAppendingFormat:@" OR %@", self.bradenCell.secondaryDescription];
    }
    aSize = CGSizeMake(width, CGFLOAT_MAX);
    CGRect boundingRect = [string boundingRectWithSize:aSize
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:textAttributes
                                               context:nil];
    boundingRect.origin.x = x;
    boundingRect.origin.y = y;
    [string drawInRect:boundingRect withAttributes:textAttributes];
}

@end
