//
//  AWPageControl.m
//  AWPageControl
//
//  Created by Emck on 2023/6/03.
//

#import "AWPageControl.h"


#pragma mark - AWPageControlDotView

@implementation AWPageControlDotView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [[NSColor clearColor] set]; // clean background
    NSRectFill(dirtyRect);
    NSRect sRect;
    if (self.status == AWPCDotSelected) {
        sRect = NSInsetRect(self.bounds, 0, 0);
        [[NSColor darkGrayColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:sRect];
        [path fill];
        [path stroke];
    }
    else if (self.status == AWPCDotUnRead) {
        sRect = NSInsetRect(self.bounds, self.bounds.size.width*0.2 , self.bounds.size.height*0.2);
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:sRect];
        path.lineWidth = 2;
        [[NSColor lightGrayColor] set];
        [path stroke];        
    }
    else if (self.status == AWPCDotRead) {
        sRect = NSInsetRect(self.bounds, self.bounds.size.width * 0.85 , self.bounds.size.height * 0.85);
        [[NSColor lightGrayColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:sRect];
        [path fill];
        [path stroke];
    }
}

@end


#pragma mark - AWPageControl

@interface AWPageControl ()
@property (nonatomic, strong) NSMutableArray *dotViewArray;     // save dot Views
@property (nonatomic, strong) NSButton  *leftButton;            // left button
@property (nonatomic, strong) NSButton  *rightButton;           // right button
@property (nonatomic, strong) NSButton  *endingButton;          // ending button
@property (nonatomic, assign) NSInteger totalPages;             // total pages
@property (nonatomic, assign) CGFloat   buttonRadius;           // button radius
@property (nonatomic, assign) CGFloat   buttonSpace;            // button Spaces
@end

@implementation AWPageControl

- (instancetype)initWithParentViewSize:(CGSize)size {
    self = [super init];
    if (self) {
        [self initWithSize:size Style:AWPCStyleBottom Height:50 BackgroundColor:[NSColor windowBackgroundColor]];
    }
    return self;
}

- (instancetype)initWithParentViewSize:(CGSize)size Style:(AWPageControlStyle)style Height:(NSInteger)height BackgroundColor:(NSColor *)backgroundColor {
    self = [super init];
    if (self) {
        [self initWithSize:size Style:style Height:height BackgroundColor:backgroundColor];
    }
    return self;
}

- (instancetype)initWithParentViewSize:(CGSize)size Data:(NSArray *)data {
    self = [super init];
    if (self) {
        [self initWithSize:size Data:data];
    }
    return self;
}

- (void)initWithSize:(CGSize)size Data:(NSArray *)data {
    if (data == nil) [self initWithSize:size Style:AWPCStyleBottom Height:50 BackgroundColor:[NSColor windowBackgroundColor]];
    else {
        @try {
            if (data.count != 3) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom control data format is invalid" userInfo:nil];
            if (![data[0] isKindOfClass:[NSNumber class]]) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom control style is invalid" userInfo:nil];
            if (![data[1] isKindOfClass:[NSNumber class]]) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom control height is invalid" userInfo:nil];
            if (![data[2] isKindOfClass:[NSColor class]])  @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom control backgroundColor is invalid" userInfo:nil];
            [self initWithSize:size Style:((NSNumber *)data[0]).intValue Height:((NSNumber *)data[1]).intValue BackgroundColor:data[2]];
        } @catch (NSException *exception) {
            @throw exception;
        }
    }
}

// init With Size
- (void)initWithSize:(CGSize)size Style:(AWPageControlStyle)style Height:(NSInteger)height  BackgroundColor:(NSColor *)backgroundColor {
    if (style == AWPCStyleTop) self.frame = NSMakeRect(0, size.height - height, size.width, height);    // top
    else self.frame = NSMakeRect(0, 0, size.width, height);     // bottom
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [backgroundColor CGColor];     // set backgroundColor

    self.dotSize         = 14;                          // dot Height
    self.dotSpace        = 24;                          // dot space
    self.buttonRadius    = 8;                           // default button Radius
    self.buttonSpace     = 40;                          // default button space
    [self customButton:AWPCButtonLeft   Size:NSMakeSize(86, 22) Title:@"Previous" Color:[NSColor blackColor] BackgroundColor:[NSColor whiteColor]];     // default left button
    [self customButton:AWPCButtonRight  Size:NSMakeSize(86, 22) Title:@"Next" Color:[NSColor whiteColor] BackgroundColor:[NSColor systemBrownColor]];   // default right button
    [self customButton:AWPCButtonEnding Size:NSMakeSize(86, 22) Title:@"Close" Color:[NSColor whiteColor] BackgroundColor:[NSColor systemTealColor]];   // default ending button
}


#pragma mark - AWPageControl customButton

- (void)customButton:(AWPageControlStyle)style Button:(NSArray *)button {
    if (button == nil) return;
    @try {
        if (button.count != 5) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom button data format is invalid" userInfo:nil];
        if (![button[0] isKindOfClass:[NSNumber class]]) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom button width is invalid" userInfo:nil];
        if (![button[1] isKindOfClass:[NSNumber class]]) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom button height is invalid" userInfo:nil];
        if (![button[2] isKindOfClass:[NSString class]]) @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom button title is invalid" userInfo:nil];
        if (![button[3] isKindOfClass:[NSColor class]])  @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom button color is invalid" userInfo:nil];
        if (![button[4] isKindOfClass:[NSColor class]])  @throw [NSException exceptionWithName:@"Exception" reason:@"AWPageControl custom button backgroundColor is invalid" userInfo:nil];
        [self customButton:style Size:NSMakeSize(((NSNumber *)button[0]).intValue, ((NSNumber *)button[1]).intValue) Title:button[2] Color:button[3] BackgroundColor:button[4]];
    } @catch (NSException *exception) {
        @throw exception;
    }
}
    
- (void)customButton:(AWPageControlStyle)style Size:(CGSize)size Title:(NSString *)title Color:(NSColor *)color BackgroundColor:(NSColor *)backgroundColor {
    NSButton *pageButton = [[NSButton alloc] initWithFrame:CGRectMake(0,0,size.width, size.height)];  // default origin is 0,0
    [[pageButton cell] setBackgroundColor:backgroundColor]; // set backgroundColor
    pageButton.title = title;                               // set title
    // set title color
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[pageButton attributedTitle]];
    NSRange rtitleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:rtitleRange];
    [pageButton setAttributedTitle:colorTitle];
    //
    pageButton.wantsLayer =YES;                             // enable Layer
    pageButton.layer.cornerRadius = self.buttonRadius;      // corner Radius
    pageButton.bordered = NO;                               // without bordered
    pageButton.target = self;
    pageButton.action = @selector(buttonClick:);
    pageButton.hidden = YES;
    CGFloat x = self.frame.size.width - (size.width + self.buttonSpace);    // count left space
    CGFloat y = (self.frame.size.height - size.height) / 2;                 // count right space
    switch (style) {
        case AWPCButtonLeft:
            pageButton.frame = CGRectMake(self.buttonSpace, y, size.width, size.height);
            if (self.leftButton) [self.leftButton removeFromSuperview];
            self.leftButton = pageButton;       // save left button
            break;
        case AWPCButtonRight:
            pageButton.frame = CGRectMake(x, y, size.width, size.height);
            if (self.rightButton) [self.rightButton removeFromSuperview];
            self.rightButton = pageButton;      // save right button
            break;
        case AWPCButtonEnding:
            pageButton.frame = CGRectMake(x, y, size.width, size.height);
            if (self.endingButton) [self.endingButton removeFromSuperview];
            self.endingButton = pageButton;     // save ending button
            break;
        default: break;
    }
    [self addSubview:pageButton];               // add button to Subview
}

- (void)setTotalPages:(NSInteger)totalPages {
    if (_totalPages >0) return;
    else _totalPages = totalPages;
    
    self.dotViewArray = [NSMutableArray arrayWithCapacity:totalPages];
    
    // create dot view
    for (int i = 0; i < totalPages; i++) {
        AWPageControlDotView *dotView = [[AWPageControlDotView alloc] initWithFrame:CGRectZero];
        dotView.status = AWPCDotUnRead;
        [self addSubview:dotView];
        [self.dotViewArray addObject:dotView];             // save dot view into array
    }
    // show button
    if (self.leftButton) self.leftButton.hidden = YES;
    if (self.rightButton) self.rightButton.hidden = (totalPages == 1 ? YES : NO);
    if (self.endingButton) self.endingButton.hidden = (totalPages == 1 ? NO : YES);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (!self.dotViewArray || self.dotViewArray.count == 0) return;

    CGFloat totalWidth = self.dotSize + (self.totalPages - 1) * (self.dotSpace + self.dotSize);
    CGFloat currentX = (self.frame.size.width - totalWidth) / 2;
    for (int i = 0; i < self.dotViewArray.count; i++) {
        AWPageControlDotView *dotView = self.dotViewArray[i];
        if (i == self.currentPage) dotView.status = AWPCDotSelected; // update DotSelected status
        // update frame
        CGFloat x = currentX;
        CGFloat y = (self.frame.size.height - self.dotSize) / 2;
        dotView.frame = CGRectMake(x, y, self.dotSize, self.dotSize);

        currentX = currentX + self.dotSize + self.dotSpace; // next dot X position
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (!self.dotViewArray || self.dotViewArray.count == 0) return;
    if (currentPage == self.currentPage || currentPage < 0 || currentPage >= self.dotViewArray.count) return;
    
    // change old status
    AWPageControlDotView *currentView = self.dotViewArray[self.currentPage];
    if (currentPage > self.currentPage) currentView.status = AWPCDotRead;   // go to right
    else currentView.status = AWPCDotUnRead; // go to left
    [currentView setNeedsDisplay:YES];
    
    // change new status
    _currentPage = currentPage;
    currentView = self.dotViewArray[self.currentPage];
    currentView.status = AWPCDotSelected;
    [currentView setNeedsDisplay:YES];
    
    // show button
    if (currentPage == 0) {                                         // is begin page
        self.leftButton.hidden   = YES;     // hidden left button
        self.rightButton.hidden  = NO;      // show right button
        self.endingButton.hidden = YES;     // hidden ending button
    }
    else if (currentPage >0 && currentPage < self.totalPages -1) {   // is middle page
        self.leftButton.hidden   = NO;      // show left button
        self.rightButton.hidden  = NO;      // show right button
        self.endingButton.hidden = YES;     // hidden ending button
    }
    else if (currentPage == self.totalPages -1) {                    // is end page
        self.leftButton.hidden   = NO;      // show left button
        self.rightButton.hidden  = YES;     // hidden right button
        self.endingButton.hidden = NO;      // show ending button
    }
    // will change page
    if (_delegate && [_delegate respondsToSelector: @selector(pageControl:didWillSelectPageAtIndex:)])
        [_delegate pageControl: self didWillSelectPageAtIndex: currentPage];       // Call delegate
}

- (void)buttonClick:(NSButton *)button {
    if (self.leftButton == button) self.currentPage = (self.currentPage -1 + self.totalPages) % self.totalPages;        // go to previous
    else if (self.rightButton == button) self.currentPage = (self.currentPage + 1 + self.totalPages) % self.totalPages; // go to next
    else if (self.endingButton == button) {                                                                             // click ending
        if (_delegate && [_delegate respondsToSelector: @selector(pageControl:didClickEndingButton:)])
            [_delegate pageControl: self didClickEndingButton: self.endingButton];  // Call delegate
    }
}

@end
