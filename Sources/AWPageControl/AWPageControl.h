//
//  AWPageControl.h
//  AWPageControl
//
//  Created by Emck on 2023/6/03.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class AWPageControl;

// AWPageControl Delegate
@protocol AWPageControlDelegate <NSObject>
@optional
-(void)pageControl:(AWPageControl *)pageControl didWillSelectPageAtIndex: (NSInteger)index;
-(void)pageControl:(AWPageControl *)pageControl didSelectPageAtIndex    : (NSInteger)index;
-(void)pageControl:(AWPageControl *)pageControl didClickEndingButton    : (id) sender;
@end


// AWPageControlDotView
typedef NS_ENUM(NSUInteger, AWPageControlDotStatus) {
    AWPCDotSelected,
    AWPCDotUnRead,
    AWPCDotRead
};

@interface AWPageControlDotView : NSView
@property (nonatomic, assign) AWPageControlDotStatus status;
@end


// AWPageControl
typedef NS_ENUM(NSUInteger, AWPageControlStyle) {
    AWPCStyleTop,            // top
    AWPCStyleBottom,         // bottom
    AWPCButtonLeft,          // left button
    AWPCButtonRight,         // right button
    AWPCButtonEnding         // ending button
};

@interface AWPageControl : NSView

@property (nonatomic, strong) id<AWPageControlDelegate> delegate;   // AWPageControl Delegate
@property (nonatomic, assign) NSInteger currentPage;                // current page
@property (nonatomic, assign) CGFloat  dotSize;                     // dot size
@property (nonatomic, assign) CGFloat  dotSpace;                    // dot space

- (instancetype)initWithParentViewSize:(CGSize)size;
- (instancetype)initWithParentViewSize:(CGSize)size Style:(AWPageControlStyle)style Height:(NSInteger)height BackgroundColor:(NSColor *)backgroundColor;
- (instancetype)initWithParentViewSize:(CGSize)size Data:(NSArray *)data;

// custom Button style(AWPCButtonLeft,AWPCButtonRight,AWPCButtonEnding) with title and color
- (void)customButton:(AWPageControlStyle)style Size:(CGSize)size Title:(NSString *)title Color:(NSColor *)color BackgroundColor:(NSColor *)backgroundColor;
- (void)customButton:(AWPageControlStyle)style Button:(NSArray *)button;
- (void)setTotalPages:(NSInteger)totalPages;


@end

NS_ASSUME_NONNULL_END

