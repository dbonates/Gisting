//
//  MainViewController.m
//  Gisting
//
//  Created by Daniel Bonates on 5/8/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "MainViewController.h"
#import "GitManager.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"

@interface MainViewController ()
@end

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MGScrollView *scroller = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:scroller];
    MGTableBoxStyled *section = MGTableBoxStyled.box;
    [scroller.boxes addObject:section];
    // a default row size
    CGSize rowSize = (CGSize){self.view.size.width-20, 40};
    
    // a header row
    MGLineStyled *header = [MGLineStyled lineWithLeft:@"My First Table" right:nil size:rowSize];
    header.leftPadding = header.rightPadding = 16;
    [section.topLines addObject:header];
    
    // a string on the left and a horse on the right
    MGLineStyled *row1 = [MGLineStyled lineWithLeft:@"Left text"
                                              right:[UIImage imageNamed:@"horse.png"] size:rowSize];
    [section.topLines addObject:row1];
    
    // a string with Mush markup
    MGLineStyled *row2 = MGLineStyled.line;
    row2.multilineLeft = @"This row has **bold** text, //italics// text, __underlined__ text, "
    "and some `monospaced` text. The text will span more than one line, and the row will "
    "automatically adjust its height to fit.|mush";
    row2.minHeight = 40;
    [section.topLines addObject:row2];
    [scroller layoutWithSpeed:0.3 completion:nil];
    [scroller scrollToView:section withMargin:8];
    
    //[[GitManager sharedManager] setupForGists:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
