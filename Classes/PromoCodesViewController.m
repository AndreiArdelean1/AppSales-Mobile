//
//  PromoCodesViewController.m
//  AppSales
//
//  Created by Ole Zorn on 13.08.11.
//  Copyright 2011 omz:software. All rights reserved.
//

#import "PromoCodesViewController.h"
#import "PromoCodesAppViewController.h"
#import "ASAccount.h"
#import "Product.h"
#import "BadgedCell.h"

@implementation PromoCodesViewController

@synthesize sortedApps;

- (instancetype)initWithAccount:(ASAccount *)anAccount {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		account = anAccount;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[account managedObjectContext]];
				
		self.title = NSLocalizedString(@"Promo Codes", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"PromoCodes"];
	}
	return self;
}

- (void)viewDidLoad {
	[self reloadData];
}

- (void)contextDidChange:(NSNotification *)notification {
	NSSet *relevantEntityNames = [NSSet setWithObject:@"PromoCode"];
	NSSet *insertedObjects = notification.userInfo[NSInsertedObjectsKey];
	NSSet *updatedObjects = notification.userInfo[NSUpdatedObjectsKey];
	NSSet *deletedObjects = notification.userInfo[NSDeletedObjectsKey];
	
	BOOL shouldReload = NO;
	for (NSManagedObject *insertedObject in insertedObjects) {
		if ([relevantEntityNames containsObject:insertedObject.entity.name]) {
			shouldReload = YES;
			break;
		}
	}
	if (!shouldReload) {
		for (NSManagedObject *updatedObject in updatedObjects) {
			if ([relevantEntityNames containsObject:updatedObject.entity.name]) {
				shouldReload = YES;
				break;
			}
		}
	}
	if (!shouldReload) {
		for (NSManagedObject *deletedObject in deletedObjects) {
			if ([relevantEntityNames containsObject:deletedObject.entity.name]) {
				shouldReload = YES;
				break;
			}
		}
	}
	if (shouldReload) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
	}
}

- (void)reloadData {
	NSArray *allApps = [[account.products allObjects] sortedArrayUsingComparator:^NSComparisonResult(Product *product1, Product *product2) {
		NSInteger productID1 = product1.productID.integerValue;
		NSInteger productID2 = product2.productID.integerValue;
		if (productID1 < productID2) {
			return NSOrderedDescending;
		} else if (productID1 > productID2) {
			return NSOrderedAscending;
		}
		return NSOrderedSame;
	}];
	
	self.sortedApps = [allApps filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Product *product, NSDictionary *bindings) {
		return !product.hidden.boolValue && !(product.parentSKU.length > 1); // In-App Purchases don't have promo codes, so don't include them.
	}]];
	
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		return YES;
	}
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sortedApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	BadgedCell *cell = (BadgedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[BadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	Product *app = sortedApps[indexPath.row];
	
	NSFetchRequest *unusedPromoCodesRequest = [[NSFetchRequest alloc] init];
	[unusedPromoCodesRequest setEntity:[NSEntityDescription entityForName:@"PromoCode" inManagedObjectContext:[app managedObjectContext]]];
	[unusedPromoCodesRequest setPredicate:[NSPredicate predicateWithFormat:@"product == %@ AND used == FALSE", app]];
	NSInteger count = [[app managedObjectContext] countForFetchRequest:unusedPromoCodesRequest error:nil];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.badgeCount = count;
	cell.textLabel.text = [app displayName];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Product *product = sortedApps[indexPath.row];
	PromoCodesAppViewController *vc = [[PromoCodesAppViewController alloc] initWithProduct:product];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

@end
