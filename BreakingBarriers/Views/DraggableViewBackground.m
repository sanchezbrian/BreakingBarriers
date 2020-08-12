//
//  DraggableViewBackground.m
//  RKSwipeCards
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import <Parse/Parse.h>
#import "DraggableViewBackground.h"
#import "SavedText.h"

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    UILabel* correctLabel;
    UILabel* wrongLabel;
    int wrongCount;
    int rightCount;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1

@synthesize learnCards; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards
@synthesize numberOfCards;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        [self querySaved];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reShuffle) name:@"reShuffle" object:nil];
    }
    return self;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.origin.x + 80, self.frame.size.height - 100, 59, 59)];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 139, self.frame.size.height - 100, 59, 59)];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    correctLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 25, xButton.frame.origin.y - 35, 25, 25)];
    wrongLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, xButton.frame.origin.y - 35, 25, 25)];
    correctLabel.backgroundColor = [UIColor colorWithRed:76.0 / 255 green:175.0 / 255 blue:80.0 / 255 alpha:1];
    wrongLabel.backgroundColor = [UIColor colorWithRed:198.0 / 255 green:40.0 / 255 blue:40.0 / 255 alpha:1];
    correctLabel.textColor = UIColor.whiteColor;
    wrongLabel.textColor = UIColor.whiteColor;;
    correctLabel.textAlignment = NSTextAlignmentCenter;
    wrongLabel.textAlignment = NSTextAlignmentCenter;
    correctLabel.layer.cornerRadius = 3;
    wrongLabel.layer.cornerRadius = 3;
    correctLabel.layer.masksToBounds = YES;
    wrongLabel.layer.masksToBounds = YES;
    correctLabel.text = @"0";
    wrongLabel.text = @"0";
    [self addSubview:wrongLabel];
    [self addSubview:correctLabel];
    [self addSubview:menuButton];
    [self addSubview:messageButton];
    [self addSubview:xButton];
    [self addSubview:checkButton];
}

- (void)querySaved {
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects != nil) {
            self.learnCards = [objects mutableCopy];
            self.numberOfCards = [self.learnCards count];
            [self shuffleCards:self.learnCards];
            [self loadCards];
            NSLog(@"Success");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)shuffleCards:(NSMutableArray *)array {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger *numOfCards = [defaults integerForKey:@"number_of_cards"];
    if (numOfCards != nil) {
        self.numberOfCards = numOfCards;
    }
    NSUInteger countCards = self.numberOfCards;
    for (NSUInteger i = 0; i < countCards; i++) {
        NSUInteger nElements = [array count] - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSUInteger count = [array count];
    for (NSUInteger i = count - 1; i >= self.numberOfCards; i--) {
        [array removeObjectAtIndex:i];
    }
}

- (void)reShuffle {
    correctLabel.text = [NSString stringWithFormat:@"%d", 0];
    wrongLabel.text = [NSString stringWithFormat:@"%d", 0];
    rightCount = 0;
    wrongCount = 0;
    cardsLoadedIndex = 0;
    [allCards removeAllObjects];
    [self querySaved];
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(25, 15, self.frame.size.width - 50, correctLabel.frame.origin.y - 25)];
    SavedText *saved = self.learnCards[index];
    draggableView.sourceText.text = saved.sourceText;
    draggableView.targetText.text = saved.translatedText;
    //%%% placeholder for card-specific information
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([learnCards count] > 1) {
        NSInteger numLoadedCardsCap =(([learnCards count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[learnCards count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[learnCards count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            NSLog(@"%ld", (long)numLoadedCardsCap);
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}


//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    if (!c.cardSeen) {
        wrongCount += 1;
        wrongLabel.text = [NSString stringWithFormat:@"%d", wrongCount];
    }
    [allCards removeObject:c];
    [allCards addObject:c];
    [loadedCards removeObjectAtIndex:0]; //card was swiped, so it's no longer a "loaded card"
    cardsLoadedIndex--;
    if ([loadedCards count] == 0) {
        [loadedCards addObject:c];
    }
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        NSLog(@"%lu", (unsigned long)[allCards count]);
        NSLog(@"%ld", (long)cardsLoadedIndex);
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        if ([allCards count] - cardsLoadedIndex == 1) {
            [self addSubview:[loadedCards objectAtIndex:0]];
        } else {
            [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        }
    } else if (cardsLoadedIndex == [allCards count]) {
        [self insertSubview:[loadedCards objectAtIndex:0] atIndex:0];
    }
    cardsLoadedIndex++;//%%% loaded a card, so have to increment count
    c.frontHidden = YES;
    c.cardSeen = YES;
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    if (c.cardSeen) {
        wrongCount -= 1;
        wrongLabel.text = [NSString stringWithFormat:@"%d", wrongCount];
    }
    c.frontHidden = YES;
    rightCount += 1;
    correctLabel.text = [NSString stringWithFormat:@"%d", rightCount];
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
         [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
    }
    else if (cardsLoadedIndex == [allCards count]) {
        NSLog(@"Last Card");
        [self addSubview:[loadedCards objectAtIndex:0]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
    } else {
        [NSNotificationCenter.defaultCenter postNotificationName:@"noCardsLeft"  object:nil];
    }
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
