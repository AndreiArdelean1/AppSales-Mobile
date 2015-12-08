//
//  ReviewSummaryView.m
//  AppSales
//
//  Created by Ole Zorn on 27.07.11.
//  Copyright 2011 omz:software. All rights reserved.
//

#import "ReviewSummaryView.h"

@implementation ReviewSummaryView

@synthesize dataSource, delegate;

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		BOOL iPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
		barViews = [NSMutableArray new];
		barLabels = [NSMutableArray new];
		
		for (int rating = 5; rating >= 1; rating--) {
			CGRect barFrame = [self barFrameForRating:rating];
			
			UILabel *starLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(CGRectGetMinX(barFrame) - 90 - 10, CGRectGetMidY(barFrame) - 15, 90, 29))];
			starLabel.backgroundColor = [UIColor clearColor];
			starLabel.textAlignment = NSTextAlignmentRight;
			starLabel.textColor = [UIColor darkGrayColor];
			starLabel.shadowColor = [UIColor whiteColor];
			starLabel.shadowOffset = CGSizeMake(0, 1);
			starLabel.font = [UIFont systemFontOfSize:15.0];
			starLabel.text = [@"" stringByPaddingToLength:rating withString:@"\u2605" startingAtIndex:0];
			[self addSubview:starLabel];
			
			UIView *barBackgroundView = [[UIView alloc] initWithFrame:barFrame];
			barBackgroundView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
			barBackgroundView.userInteractionEnabled = NO;
			[self addSubview:barBackgroundView];
			
			UIView *barView = [[UIView alloc] initWithFrame:barBackgroundView.frame];
			barView.backgroundColor = [UIColor colorWithRed:0.541 green:0.612 blue:0.671 alpha:1.0];
			barView.userInteractionEnabled = NO;
			[self addSubview:barView];
			[barViews addObject:barView];
			
			UIButton *showReviewsButton = [UIButton buttonWithType:UIButtonTypeCustom];
			CGRect showReviewsButtonFrame = CGRectMake(10, barBackgroundView.frame.origin.y - 2, self.bounds.size.width - 20, CGRectGetHeight(barFrame) + 4);
			[showReviewsButton setBackgroundImage:[[UIImage imageNamed:@"ReviewBarButton"] stretchableImageWithLeftCapWidth:8 topCapHeight:0] forState:UIControlStateHighlighted];
			showReviewsButton.frame = showReviewsButtonFrame;
			showReviewsButton.tag = rating;
			[self insertSubview:showReviewsButton atIndex:0];
			[showReviewsButton addTarget:self action:@selector(showReviews:) forControlEvents:UIControlEventTouchUpInside];
			
			UILabel *barLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(barFrame) + 5, barFrame.origin.y, 30, barFrame.size.height)];
			barLabel.backgroundColor = [UIColor clearColor];
			barLabel.textColor = [UIColor darkGrayColor];
			barLabel.font = [UIFont systemFontOfSize:13.0];
			barLabel.adjustsFontSizeToFitWidth = YES;
			barLabel.shadowColor = [UIColor whiteColor];
			barLabel.shadowOffset = CGSizeMake(0, 1);
			
			[self addSubview:barLabel];
			[barLabels addObject:barLabel];
		}
		
		if (!iPad) {
			UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - 44, self.bounds.size.width - 20, 1)];
			separator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
			[self addSubview:separator];
		}
		
		UIButton *allReviewsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		if (iPad) {
			CGRect barFrame = [self barFrameForRating:0];
			allReviewsButton.frame = CGRectMake(CGRectGetMaxX(barFrame) - 145 - 5, CGRectGetMinY(barFrame), 145, 28);
		} else {
			allReviewsButton.frame = CGRectMake(110, self.bounds.size.height - 37, 145, 28);
		}
		[allReviewsButton setBackgroundImage:[[UIImage imageNamed:@"AllReviewsButton"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateNormal];
		[allReviewsButton setBackgroundImage:[[UIImage imageNamed:@"AllReviewsButtonHighlighted"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateHighlighted];
		[allReviewsButton setTitle:NSLocalizedString(@"Show All Reviews", nil) forState:UIControlStateNormal];
		[allReviewsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
		allReviewsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
		[allReviewsButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		allReviewsButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
		[allReviewsButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		allReviewsButton.tag = 0;
		[self addSubview:allReviewsButton];
		[allReviewsButton addTarget:self action:@selector(showReviews:) forControlEvents:UIControlEventTouchUpInside];
		if (iPad) {
			CGRect barFrame = [self barFrameForRating:0];
			averageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(barFrame) - 90 - 10, allReviewsButton.frame.origin.y, 90, 29)];
		} else {
			averageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, allReviewsButton.frame.origin.y, 90, 29)];
		}
		averageLabel.font = [UIFont boldSystemFontOfSize:15.0];
		averageLabel.backgroundColor = [UIColor clearColor];
		averageLabel.textColor = [UIColor darkGrayColor];
		averageLabel.textAlignment = NSTextAlignmentRight;
		[self addSubview:averageLabel];
		
		if (iPad) {
			CGRect barFrame = [self barFrameForRating:0];
			sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(barFrame) + 5, allReviewsButton.frame.origin.y, 30, allReviewsButton.frame.size.height)];
		} else {
			sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, allReviewsButton.frame.origin.y, 30, allReviewsButton.frame.size.height)];
		}
		sumLabel.font = [UIFont systemFontOfSize:13.0];
		sumLabel.backgroundColor = [UIColor clearColor];
		sumLabel.textColor = [UIColor darkGrayColor];
		[self addSubview:sumLabel];
	}
	return self;
}

- (void)reloadDataAnimated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
	}
	NSMutableDictionary *ratings = [NSMutableDictionary dictionary];
	NSMutableDictionary *unreadRatings = [NSMutableDictionary dictionary];
	NSInteger total = 0;
	NSInteger starSum = 0;
	NSInteger max = 0;
	for (NSInteger rating = 5; rating >= 1; rating--) {
		NSInteger n = [self.dataSource reviewSummaryView:self numberOfReviewsForRating:rating];
		total += n;
		starSum += n * rating;
		if (n > max) max = n;
		[ratings setObject:@(n) forKey:@(rating)];
		NSInteger unread = [self.dataSource reviewSummaryView:self numberOfUnreadReviewsForRating:rating];
		[unreadRatings setObject:@(unread) forKey:@(rating)];
	}
	
	for (NSInteger rating = 5; rating >= 1; rating--) {
		NSInteger numberOfReviews = [ratings[@(rating)] integerValue];
		float percentage = (total == 0) ? 0 : (float)numberOfReviews / (float)max;
		CGRect barFrame = [self barFrameForRating:rating];
		barFrame.size.width = barFrame.size.width * percentage;
		[barViews[5 - rating] setFrame:barFrame];
		
		UILabel *barLabel = barLabels[5 - rating];
		barLabel.text = [NSString stringWithFormat:@"%li", (long)numberOfReviews];
		if ([unreadRatings[@(rating)] integerValue] > 0) {
			barLabel.font = [UIFont boldSystemFontOfSize:13.0];
			barLabel.textColor = [UIColor colorWithRed:0.141 green:0.439 blue:0.847 alpha:1.0];
		} else {
			barLabel.font = [UIFont systemFontOfSize:13.0];
			barLabel.textColor = [UIColor darkGrayColor];
		}
	}
	sumLabel.text = [NSString stringWithFormat:@"%li", (long)total];
	
	float average = (float)starSum / (float)total;
	NSNumberFormatter *averageFormatter = [[NSNumberFormatter alloc] init];
	[averageFormatter setMinimumFractionDigits:1];
	[averageFormatter setMaximumFractionDigits:1];
	averageLabel.text = [NSString stringWithFormat:@"\u2205 %@", [averageFormatter stringFromNumber:@(average)]];
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (CGRect)barFrameForRating:(NSInteger)rating {
	BOOL iPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
	if (!iPad) {
		CGRect barFrame = CGRectMake(110, 12 + (5-rating) * 30, 145, 24);
		return barFrame;
	} else {
		CGRect barFrame = CGRectMake(150, 105 + (5 - rating) * 45, 467, 35);
		return barFrame;
	}
}

- (void)showReviews:(UIButton *)button {
	if (self.delegate && [self.delegate respondsToSelector:@selector(reviewSummaryView:didSelectRating:)]) {
		[self.delegate reviewSummaryView:self didSelectRating:button.tag];
	}
}


@end
