//
//  HistoryListVC.m
//  linphone
//
//  Created by Gouthami Reddy on 17/11/18.
//

#import "HistoryListVC.h"
#import "HistoryCallHeaderCell.h"
#import "AssistantView.h"
#import "PhoneMainView.h"
#import "linphone/core.h"
#import "HistoryListView.h"

#import "UsersHistoryCallsCell.h"
#import "AgencyHistoryCallsCell.h"


// calls type
typedef NS_ENUM(NSInteger, CallsType) {
    Calls_ALL,
    Calls_MISSED,
    Calls_Agency,
};

@interface HistoryListVC () <UITableViewDelegate, UITableViewDataSource, UsersHistoryCallsCellDelegate>
{
    NSDateFormatter *date_formatter;
    NSMutableArray *users_callsArray;
    NSMutableArray *agency_callsArray;
    
    CallsType callListType;
    //BOOL is_Agency;
}

@property(nonatomic, assign) BOOL missedFilter;
@property(nonatomic, strong) NSMutableDictionary *sections;
@property(nonatomic, strong) NSMutableArray *sortedDays;
@end

@implementation HistoryListVC

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                //tabBar:TabBarView.class
                                                                 tabBar:nil
                                //sideMenu:SideMenuView.class
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:HistoryDetailsView.class];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // allocations...
    users_callsArray = [[NSMutableArray alloc] init];
    agency_callsArray = [[NSMutableArray alloc] init];
    
    // date formate and location...
    date_formatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [date_formatter setLocale:usLocale];
    
    //
    callListType = Calls_ALL;
    self.view_callsTopMenu.hidden = NO;
    self.view_callsDeleteMenu.hidden = YES;
    
    // delegates...
    self.tbl_callList.delegate = self;
    self.tbl_callList.dataSource = self;
    self.tbl_callList.estimatedRowHeight = 45;
    self.tbl_callList.rowHeight = UITableViewAutomaticDimension;
    
    
    // Reset missed call
    linphone_core_reset_missed_calls_count(LC);
    // Fake event
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Background work...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self GetCallHistory_HTTPConnection];
        [self GetAgencyCallHistory_HTTPConnection];
    });
    
    
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadData)
                                               name:kLinphoneAddressBookUpdate
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadData)
                                               name:kLinphoneCallUpdate
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(coreUpdateEvent:)
                                               name:kLinphoneCoreUpdate
                                             object:nil];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneAddressBookUpdate object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneCoreUpdate object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneCallUpdate object:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Calls Helpers
- (void)coreUpdateEvent:(NSNotification *)notif {
    @try {
        // Invalid all pointers
        [self loadData];
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:@"LinphoneCoreException"]) {
            LOGE(@"Core already destroyed");
            return;
        }
        LOGE(@"Uncaught exception : %@", exception.description);
        abort();
    }
}

- (void)loadData {
    
    for (id day in self.sections.allKeys) {
        for (id log in self.sections[day]) {
            linphone_call_log_unref([log pointerValue]);
        }
    }
    
    const bctbx_list_t *logs = linphone_core_get_call_logs(LC);
    self.sections = [NSMutableDictionary dictionary];
    while (logs != NULL) {
        LinphoneCallLog *log = (LinphoneCallLog *)logs->data;
        if (!self.missedFilter || linphone_call_log_get_status(log) == LinphoneCallMissed) {
            NSDate *startDate = [self
                                 dateAtBeginningOfDayForDate:[NSDate
                                                              dateWithTimeIntervalSince1970:linphone_call_log_get_start_date(log)]];
            NSMutableArray *eventsOnThisDay = [self.sections objectForKey:startDate];
            if (eventsOnThisDay == nil) {
                eventsOnThisDay = [NSMutableArray array];
                [self.sections setObject:eventsOnThisDay forKey:startDate];
            }
            
            linphone_call_log_set_user_data(log, NULL);
            
            // if this contact was already the previous entry, do not add it twice
            LinphoneCallLog *prev = [eventsOnThisDay lastObject] ? [[eventsOnThisDay lastObject] pointerValue] : NULL;
            if (prev && linphone_address_weak_equal(linphone_call_log_get_remote_address(prev),
                                                    linphone_call_log_get_remote_address(log))) {
                bctbx_list_t *list = linphone_call_log_get_user_data(prev);
                list = bctbx_list_append(list, log);
                linphone_call_log_set_user_data(prev, list);
            } else {
                [eventsOnThisDay addObject:[NSValue valueWithPointer:linphone_call_log_ref(log)]];
            }
        }
        logs = bctbx_list_next(logs);
    }
    
    [self computeSections];
    
    //[super loadData];
    
    //    if (IPAD) {
    //        if (![self selectFirstRow]) {
    //            HistoryDetailsView *view = VIEW(HistoryDetailsView);
    //            [view setCallLogId:nil];
    //        }
    //    }
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate {
    
    // getting start date for the day...
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    NSDateComponents *dateComps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:inputDate];
    dateComps.hour = dateComps.minute = dateComps.second = 0;
    return [calendar dateFromComponents:dateComps];
}

- (void)computeSections {
    
    // calls sections sorting...
    NSArray *unsortedDays = [self.sections allKeys];
    _sortedDays = [[NSMutableArray alloc] initWithArray:[unsortedDays sortedArrayUsingComparator:^NSComparisonResult(NSDate *d1, NSDate *d2) {
        
        // reverse order
        return [d2 compare:d1];
    }]];
}

+ (void) saveDataToUserDefaults {
    
    const bctbx_list_t *logs = linphone_core_get_call_logs(LC);
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName: @"group.belledonne-communications.linphone.widget"];
    NSMutableArray *logsShare = [NSMutableArray array];
    NSMutableDictionary *tmpStoreDict = [NSMutableDictionary dictionary];
    NSMutableArray *addedContacts = [NSMutableArray array];
    while (logs) {
        LinphoneCallLog *log = (LinphoneCallLog *)logs->data;
        const LinphoneAddress *address = linphone_call_log_get_remote_address(log);
        
        // if contact is already to be display, skip
        if ([addedContacts containsObject:[NSString stringWithUTF8String:linphone_address_as_string_uri_only(address)]]) {
            logs = bctbx_list_next(logs);
            continue;
        }
        // if null log id, skip
        if (!linphone_call_log_get_call_id(log)) {
            logs = bctbx_list_next(logs);
            continue;
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:[NSString stringWithUTF8String:linphone_call_log_get_call_id(log)]
                 forKey:@"id"];
        [dict setObject:[NSString stringWithUTF8String:linphone_address_get_display_name(address)?:linphone_address_get_username(address)]
                 forKey:@"display"];
        UIImage *avatar = [FastAddressBook imageForAddress:address];
        if (avatar) {
            UIImage *image = [UIImage resizeImage:avatar
                                     withMaxWidth:200
                                     andMaxHeight:200];
            NSData *imageData = UIImageJPEGRepresentation(image, 1);
            [dict setObject:imageData
                     forKey:@"img"];
        }
        [tmpStoreDict setObject:dict
                         forKey:[NSDate dateWithTimeIntervalSince1970:linphone_call_log_get_start_date(log)]];
        [addedContacts addObject:[NSString stringWithUTF8String:linphone_address_as_string_uri_only(address)]];
        
        logs = bctbx_list_next(logs);
    }
    
    NSArray *sortedDates = [[NSMutableArray alloc]
                            initWithArray:[tmpStoreDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *d1, NSDate *d2) {
        return [d2 compare:d1];
    }]];
    
    // sort logs array on date
    for (NSDate *date in sortedDates) {
        [logsShare addObject:[tmpStoreDict objectForKey:date]];
        if (logsShare.count >= 4) //send no more data than needed
            break;
    }
    
    [mySharedDefaults setObject:logsShare forKey:@"logs"];
}

#pragma mark - Agency call Helpers
- (NSDate *)gettingNextMonthDate {
    
    NSDateComponents *date_components = [[NSDateComponents alloc] init];
    [date_components setMonth:-1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *month_date = [calendar dateByAddingComponents:date_components
                                                   toDate:[NSDate date]
                                                  options:0];
    return month_date;
}

- (NSDate *)gettingYesterdayDate {
    
    NSDateComponents *date_components = [[NSDateComponents alloc] init];
    [date_components setDay:-1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *month_date = [calendar dateByAddingComponents:date_components
                                                   toDate:[NSDate date]
                                                  options:0];
    return month_date;
}

- (NSString *)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)convertUserCalls_intoDaywideCalls:(NSArray *)users_array {
    
    // no of sections calculations...
    NSMutableArray *calls_sectionsArray = [[NSMutableArray alloc] init];
    for (int i=0; i<users_array.count; i++) {
        
        // agency call object taking...
        NSDictionary *call_dict = [[VKRemoveNull shared] filterNullsDictionary:[users_array objectAtIndex:i] WithEmpty:YES];
        NSString *start_stamp = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"start_stamp"]];
        if (start_stamp.length != 0) {
            
            // start stemp date...
            [date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *sStamp_date = [date_formatter dateFromString:start_stamp];
            
            // convert display formate...
            [date_formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *final_dateStr = [date_formatter stringFromDate:sStamp_date];
            NSDate *final_date = [date_formatter dateFromString:final_dateStr];
            
            // same date existed or not...
            BOOL index_existed = NO;
            for (int j=0; j<calls_sectionsArray.count; j++) {
                
                // section date..
                NSMutableDictionary *section_dict = [[calls_sectionsArray objectAtIndex:j] mutableCopy];
                [date_formatter setDateFormat:@"yyyy-MM-dd"];
                NSString *section_dateStr = [date_formatter stringFromDate:[section_dict objectForKey:@"date"]];
                
                // adding current date elemetns...
                if ([final_dateStr isEqualToString:section_dateStr]) {
                    
                    index_existed = YES;
                    NSMutableArray *calls_array = [[section_dict objectForKey:@"calls"] mutableCopy];
                    [calls_array addObject:call_dict];
                    
                    [section_dict setObject:calls_array forKey:@"calls"];
                    [calls_sectionsArray replaceObjectAtIndex:j withObject:section_dict];
                    break;
                }
            }
            
            if (index_existed == NO) {
                
                // add new elements...
                NSMutableDictionary *_dateDict = [[NSMutableDictionary alloc] init];
                [_dateDict setObject:final_date forKey:@"date"];
                [_dateDict setObject:[[NSArray alloc] initWithObjects:call_dict, nil] forKey:@"calls"];
                [calls_sectionsArray addObject:_dateDict];
            }
        }
    }
    NSLog(@"Final list array : %@", calls_sectionsArray);
    
    // sorting array ascending...
    [calls_sectionsArray sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        
        NSDate *first_date = [obj1 objectForKey:@"date"];
        NSDate *second_date = [obj2 objectForKey:@"date"];
        return [second_date compare: first_date];
    }];
    
    NSLog(@"Sort list array : %@", calls_sectionsArray);
    
    // sorting childs array...
    for (int i=0; i< calls_sectionsArray.count; i++) {
        
        NSMutableDictionary *section_dict = [[calls_sectionsArray objectAtIndex:i] mutableCopy];
        NSMutableArray *childCalls_array = [[section_dict objectForKey:@"calls"] mutableCopy];
        
        [childCalls_array sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            
            // starting date...
            NSString *first_str = [NSString stringWithFormat:@"%@", [obj1 objectForKey:@"start_stamp"]];
            [self->date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *first_date = [self->date_formatter dateFromString:first_str];
            
            // ending date...
            NSString *second_str = [NSString stringWithFormat:@"%@", [obj2 objectForKey:@"start_stamp"]];
            [self->date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *second_date = [self->date_formatter dateFromString:second_str];
            return [second_date compare: first_date];
        }];
        [section_dict setObject:childCalls_array forKey:@"calls"];
        [calls_sectionsArray replaceObjectAtIndex:i withObject:section_dict];
    }
    
    // Update UI main queue...
    dispatch_async(dispatch_get_main_queue(), ^{
        
        users_callsArray = [calls_sectionsArray mutableCopy];
        if (callListType == Calls_ALL) {
            [self.tbl_callList reloadData];
        }
        NSLog(@"Final users list array : %@", users_callsArray);
    });
}


- (void)convertCalls_intoDaywideCalls:(NSArray *)agency_array {
    
    // no of sections calculations...
    NSMutableArray *calls_sectionsArray = [[NSMutableArray alloc] init];
    for (int i=0; i<agency_array.count; i++) {
        
        // agency call object taking...
        NSDictionary *call_dict = [[VKRemoveNull shared] filterNullsDictionary:[agency_array objectAtIndex:i] WithEmpty:YES];
        NSString *start_stamp = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"start_stamp"]];
        if (start_stamp.length != 0) {
            
            // start stemp date...
            [date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *sStamp_date = [date_formatter dateFromString:start_stamp];
            
            // convert display formate...
            [date_formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *final_dateStr = [date_formatter stringFromDate:sStamp_date];
            NSDate *final_date = [date_formatter dateFromString:final_dateStr];
            
            // same date existed or not...
            BOOL index_existed = NO;
            for (int j=0; j<calls_sectionsArray.count; j++) {
                
                // section date..
                NSMutableDictionary *section_dict = [[calls_sectionsArray objectAtIndex:j] mutableCopy];
                [date_formatter setDateFormat:@"yyyy-MM-dd"];
                NSString *section_dateStr = [date_formatter stringFromDate:[section_dict objectForKey:@"date"]];
                
                // adding current date elemetns...
                if ([final_dateStr isEqualToString:section_dateStr]) {
                    
                    index_existed = YES;
                    NSMutableArray *calls_array = [[section_dict objectForKey:@"calls"] mutableCopy];
                    [calls_array addObject:call_dict];
                    
                    [section_dict setObject:calls_array forKey:@"calls"];
                    [calls_sectionsArray replaceObjectAtIndex:j withObject:section_dict];
                    break;
                }
            }
            
            if (index_existed == NO) {
                
                // add new elements...
                NSMutableDictionary *_dateDict = [[NSMutableDictionary alloc] init];
                [_dateDict setObject:final_date forKey:@"date"];
                [_dateDict setObject:[[NSArray alloc] initWithObjects:call_dict, nil] forKey:@"calls"];
                [calls_sectionsArray addObject:_dateDict];
            }
        }
    }
    NSLog(@"Final list array : %@", calls_sectionsArray);
    
    // sorting array ascending...
    [calls_sectionsArray sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        
        NSDate *first_date = [obj1 objectForKey:@"date"];
        NSDate *second_date = [obj2 objectForKey:@"date"];
        return [second_date compare: first_date];
    }];
    
    NSLog(@"Sort list array : %@", calls_sectionsArray);
    
    // sorting childs array...
    for (int i=0; i< calls_sectionsArray.count; i++) {
        
        NSMutableDictionary *section_dict = [[calls_sectionsArray objectAtIndex:i] mutableCopy];
        NSMutableArray *childCalls_array = [[section_dict objectForKey:@"calls"] mutableCopy];
        
        [childCalls_array sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            
            // starting date...
            NSString *first_str = [NSString stringWithFormat:@"%@", [obj1 objectForKey:@"start_stamp"]];
            [self->date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *first_date = [self->date_formatter dateFromString:first_str];
            
            // ending date...
            NSString *second_str = [NSString stringWithFormat:@"%@", [obj2 objectForKey:@"start_stamp"]];
            [self->date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *second_date = [self->date_formatter dateFromString:second_str];
            return [second_date compare: first_date];
        }];
        [section_dict setObject:childCalls_array forKey:@"calls"];
        [calls_sectionsArray replaceObjectAtIndex:i withObject:section_dict];
    }
    
    // Update UI main queue...
    dispatch_async(dispatch_get_main_queue(), ^{
        
        agency_callsArray = [calls_sectionsArray mutableCopy];
        if (callListType == Calls_Agency) {
            [self.tbl_callList reloadData];
        }
        NSLog(@"Final agency list array : %@", agency_callsArray);
    });
}

#pragma mark - ButtonAction
- (IBAction)deleteMenuButtonsClicked:(UIButton *)sender {
    
    if (sender.tag == 10) {
        self.view_callsTopMenu.hidden = NO;
        self.view_callsDeleteMenu.hidden = YES;
    }
    else if (sender.tag == 11) {
        
    }
    else if (sender.tag == 12) {
        
    }
}

- (IBAction)callsMenuButtonsClicked:(UIButton *)sender {
    
    
    if (sender.tag == 10) {
        
        // main call list...
        callListType = Calls_ALL;
        self.view_selectedLine.constant = 0;
        self.btn_edit.hidden = NO;
        [self.tbl_callList reloadData];
    }
    else if (sender.tag == 11) {
        
        // agency call list...
        callListType = Calls_Agency;
        self.view_selectedLine.constant = 65;
        self.btn_edit.hidden = YES;
        [self.tbl_callList reloadData];
    }
    else if (sender.tag == 12) {
        self.view_callsTopMenu.hidden = YES;
        self.view_callsDeleteMenu.hidden = NO;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    // cell creation...
    HistoryCallHeaderCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"HistoryCallHeaderCell" owner:nil options:nil]lastObject];
    if (callListType == Calls_Agency) {
        
        // call information...
        NSDictionary *call_dict = [agency_callsArray objectAtIndex:section];
        NSDate *call_date = [call_dict objectForKey:@"date"];
        
        [date_formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *date_str = [date_formatter stringFromDate:call_date];
        NSString *today_date = [date_formatter stringFromDate:[NSDate date]];
        NSString *yesterday_date = [date_formatter stringFromDate:[self gettingYesterdayDate]];
        
        // display information...
        if ([today_date isEqualToString:date_str]) {
            cell.lbl_headerTitle.text = @"Today";
        }
        else if ([yesterday_date isEqualToString:date_str]) {
            cell.lbl_headerTitle.text = @"Yesterday";
        }
        else {
            [date_formatter setDateFormat:@"EEE dd MMMM"];
            cell.lbl_headerTitle.text = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:call_date]];
        }
    }
    else {
        
        // call information...
        NSDictionary *call_dict = [users_callsArray objectAtIndex:section];
        NSDate *call_date = [call_dict objectForKey:@"date"];
        
        [date_formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *date_str = [date_formatter stringFromDate:call_date];
        NSString *today_date = [date_formatter stringFromDate:[NSDate date]];
        NSString *yesterday_date = [date_formatter stringFromDate:[self gettingYesterdayDate]];
        
        // display information...
        if ([today_date isEqualToString:date_str]) {
            cell.lbl_headerTitle.text = @"Today";
        }
        else if ([yesterday_date isEqualToString:date_str]) {
            cell.lbl_headerTitle.text = @"Yesterday";
        }
        else {
            [date_formatter setDateFormat:@"EEE dd MMMM"];
            cell.lbl_headerTitle.text = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:call_date]];
        }
        
        /*
        // call information...
        NSDate *eventDate = _sortedDays[section];
        NSDate *currentDate = [self dateAtBeginningOfDayForDate:[NSDate date]];
        
        // display information...
        if ([eventDate isEqualToDate:currentDate]) {
            cell.lbl_headerTitle.text = @"Today";
        }
        else if ([eventDate isEqualToDate:[currentDate dateByAddingTimeInterval:-3600 * 24]]) {
            cell.lbl_headerTitle.text = @"Yesterday";
        }
        else {
            cell.lbl_headerTitle.text = [LinphoneUtils timeToString:eventDate.timeIntervalSince1970 withFormat:LinphoneDateHistoryList]
            .uppercaseString;
        }*/
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (callListType == Calls_Agency) {
        return agency_callsArray.count;
    }
    else {
        return users_callsArray.count;
        //return self.sortedDays.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (callListType == Calls_Agency) {
        
        // call dict...
        NSDictionary *callMain_dict = [agency_callsArray objectAtIndex:section];
        NSArray *calls_array = [callMain_dict objectForKey:@"calls"];
        return [calls_array count];
    }
    else {
        
        // call dict...
        NSDictionary *callMain_dict = [users_callsArray objectAtIndex:section];
        NSArray *calls_array = [callMain_dict objectForKey:@"calls"];
        return [calls_array count];
        
        //NSArray *logs = [self.sections objectForKey:self.sortedDays[section]];
        //return logs.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (callListType == Calls_Agency) {
        
        // cell creation...
        AgencyHistoryCallsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AgencyHistoryCallsCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"AgencyHistoryCallsCell" bundle:nil] forCellReuseIdentifier:@"AgencyHistoryCallsCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"AgencyHistoryCallsCell"];
        }
        
        // call dict...
        NSDictionary *callMain_dict = [agency_callsArray objectAtIndex:indexPath.section];
        NSArray *call_array = [callMain_dict objectForKey:@"calls"];
        NSDictionary *call_dict = [call_array objectAtIndex:indexPath.row];
        
        // display infomration...
        NSString *from_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"caller_id_name"]];
        if (from_name.length == 0) {
            from_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"caller_id_number"]];
        }
        cell.lbl_fromName.text = [NSString stringWithFormat:@"%@", from_name];
        
        NSString *to_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"destination_number"]]; // duplicate key
        if (to_name.length == 0) {
            to_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"destination_number"]];
        }
        cell.lbl_toName.text = [NSString stringWithFormat:@"%@", to_name];
        
        // start date...
        cell.lbl_date.text = @"";
        [date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *start_stamp = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"start_stamp"]];
        if (start_stamp.length != 0) {
            
            NSDate *start_stampDate = [date_formatter dateFromString:start_stamp];
            [date_formatter setDateFormat:@"MMM dd, yyyy, hh:mm a"];
            cell.lbl_date.text = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:start_stampDate]];
        }
        int durationSeconds = [[NSString stringWithFormat:@"%@", [call_dict objectForKey:@"duration"]] intValue];
        cell.lbl_duration.text = [self timeFormatted:durationSeconds];
        
        
        // call state icons...
        NSString *call_state = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"call_status"]];
        // "call_status": "answered"
        if ([call_state isEqualToString:@"answered"]) {
            cell.img_callState.image = [UIImage imageNamed:@"ic_incomingCall"];
        }
        else if ([call_state isEqualToString:@"unanswered"]) {
            //
        }
        else if ([call_state isEqualToString:@"missed"]) {
            cell.img_callState.image = [UIImage imageNamed:@"ic_missedCall"];
        }
        else if ([call_state isEqualToString:@"sent_to_voicemail"]) {
             cell.img_callState.image = [UIImage imageNamed:@"ic_voicemail"];
        }
        else {
            cell.img_callState.image = [UIImage imageNamed:@"ic_outgoingCall"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
    else {
        
        // cell creation...
        UsersHistoryCallsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsersHistoryCallsCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"UsersHistoryCallsCell" bundle:nil] forCellReuseIdentifier:@"UsersHistoryCallsCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"UsersHistoryCallsCell"];
        }
        cell.delegate = self;
        
        
        // call dict...
        NSDictionary *callMain_dict = [users_callsArray objectAtIndex:indexPath.section];
        NSArray *call_array = [callMain_dict objectForKey:@"calls"];
        NSDictionary *call_dict = [call_array objectAtIndex:indexPath.row];
        
        // display infomration...
        NSString *to_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"destination_number"]]; // duplicate key
        if (to_name.length == 0) {
            to_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"destination_number"]];
        }
        cell.lbl_toName.text = [NSString stringWithFormat:@"%@", to_name];
        
    
        // start date...
        cell.lbl_date.text = @"";
        [date_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *start_stamp = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"start_stamp"]];
        if (start_stamp.length != 0) {
            
            NSDate *start_stampDate = [date_formatter dateFromString:start_stamp];
            [date_formatter setDateFormat:@"MMM dd, yyyy, hh:mm a"];
            cell.lbl_date.text = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:start_stampDate]];
        }
        int durationSeconds = [[NSString stringWithFormat:@"%@", [call_dict objectForKey:@"duration"]] intValue];
        cell.lbl_duration.text = [self timeFormatted:durationSeconds];
        
        // call state icons...
        NSString *call_state = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"call_status"]];
        // "call_status": "answered"
        if ([call_state isEqualToString:@"answered"]) {
            cell.img_callState.image = [UIImage imageNamed:@"ic_incomingCall"];
        }
        else if ([call_state isEqualToString:@"unanswered"]) {
            //
        }
        else if ([call_state isEqualToString:@"missed"]) {
            cell.img_callState.image = [UIImage imageNamed:@"ic_missedCall"];
        }
        else if ([call_state isEqualToString:@"sent_to_voicemail"]) {
            cell.img_callState.image = [UIImage imageNamed:@"ic_voicemail"];
        }
        else {
            cell.img_callState.image = [UIImage imageNamed:@"ic_outgoingCall"];
        }
        
//        id logId = [_sections objectForKey:_sortedDays[indexPath.section]][indexPath.row];
//        LinphoneCallLog *log = [logId pointerValue];
//        [cell update:log];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*if (callListType != Calls_Agency) {
        
        HistoryCallsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.btn_checkbox.hidden == YES) {
            
            id log = [_sections objectForKey:_sortedDays[indexPath.section]][indexPath.row];
            LinphoneCallLog *callLog = [log pointerValue];
            if (callLog != NULL && (!IPAD)) {
                const LinphoneAddress *addr = linphone_call_log_get_remote_address(callLog);
                [LinphoneManager.instance call:addr];
            }
        }
    }
    else  {
        NSLog(@"Agency table cell clicked");
    }*/
}

#pragma mark - CellButtonAction
- (void)callerDialButtonClicked:(UIButton *)button cell:(UsersHistoryCallsCell *)cell {
    
    // getting indexpath...
    NSIndexPath *index_path = [self.tbl_callList indexPathForCell:cell];
    NSLog(@"index - %d", (int)index_path.row);

    // call dict...
    NSDictionary *callMain_dict = [users_callsArray objectAtIndex:index_path.section];
    NSArray *call_array = [callMain_dict objectForKey:@"calls"];
    NSDictionary *call_dict = [call_array objectAtIndex:index_path.row];
    
    NSString *address = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"destination_number"]];
    if ([address length] > 0) {
        LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:address];
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
    }
    
}

//- (void)detailsClicked:(UIButton *)button cell:(HistoryCallsCell *)cell {
//
//    /*
//    // getting indexpath...
//    NSIndexPath *index_path = [self.tbl_callList indexPathForCell:cell];
//
//    // getting caller log...
//    id logId = [_sections objectForKey:_sortedDays[index_path.section]][index_path.row];
//    LinphoneCallLog *callLog = [logId pointerValue];
//    if (callLog != NULL) {
//        HistoryDetailsView *view = VIEW(HistoryDetailsView);
//        if (linphone_call_log_get_call_id(callLog) != NULL) {
//            // Go to History details view
//            [view setCallLogId:[NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)]];
//        }
//        [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
//    }*/
//}
//
//- (void)checkboxClicked:(UIButton *)button cell:(HistoryCallsCell *)cell {
//
//}

#pragma mark - APIs
- (void)GetCallHistory_HTTPConnection {
    
    //*** start indicator....
    
    
    
    // from and to dates...
    [date_formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *from_date = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:[self gettingNextMonthDate]]];
    NSString *to_date = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:[NSDate date]]];
    NSDictionary *profile_data = [[NSUserDefaults standardUserDefaults] objectForKey:kProfile];
    
    
    // params creation...
    NSMutableDictionary *params_dict = [[NSMutableDictionary alloc] init];
    [params_dict setObject:from_date forKey:@"from_date"];
    [params_dict setObject:to_date forKey:@"to_date"];
    [params_dict setObject:[NSString stringWithFormat:@"%@", [profile_data objectForKey:@"user_uuid"]] forKey:@"user_uuid"];
    
    
    // request...
    NSMutableURLRequest *request = [[APIService shared] request_withRaw:params_dict
                                                               withFile:@"call/gethistory"
                                                            requestType:@"POST"];
    NSURLSession *defaultSession = [[APIService shared] getURLSession];
    
    // call Api's...
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // JSON serialization...
                                          if (error == nil) {
                                              
                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                              NSLog(@"response data: %@", responseDict);
                                              NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                              
                                              if ([responseDict.allKeys containsObject:@"success"]) {
                                                  
                                                  NSDictionary *success_dict = [responseDict objectForKey:@"success"];
                                                  NSArray *calls_array = [success_dict objectForKey:@"calls"];
                                                  if (calls_array.count != 0) {
                                                      [self convertUserCalls_intoDaywideCalls: calls_array];
                                                  }
                                              }
                                          }
                                          else {
                                              NSLog(@"Error : %@", error.localizedDescription);
                                          }
                                          //*** end indicator....
                                      }];
    [dataTask resume];
}

- (void)GetAgencyCallHistory_HTTPConnection {
    
    //*** start indicator....
    
    // from and to dates...
    [date_formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *from_date = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:[self gettingNextMonthDate]]];
    NSString *to_date = [NSString stringWithFormat:@"%@", [date_formatter stringFromDate:[NSDate date]]];
    
    // params creation...
    NSMutableDictionary *params_dict = [[NSMutableDictionary alloc] init];
    [params_dict setObject:from_date forKey:@"from_date"];
    [params_dict setObject:to_date forKey:@"to_date"];
    
    // request...
    NSMutableURLRequest *request = [[APIService shared] request_withRaw:params_dict
                                                               withFile:@"call/getagencyhistory"
                                                            requestType:@"POST"];
    NSURLSession *defaultSession = [[APIService shared] getURLSession];
    
    // call Api's...
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // JSON serialization...
                                          if (error == nil) {
                                              
                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                              NSLog(@"response data: %@", responseDict);
                                              NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                              
                                              if ([responseDict.allKeys containsObject:@"success"]) {
                                                  
                                                  NSDictionary *success_dict = [responseDict objectForKey:@"success"];
                                                  NSArray *calls_array = [success_dict objectForKey:@"calls"];
                                                  if (calls_array.count != 0) {
                                                      [self convertCalls_intoDaywideCalls: calls_array];
                                                  }
                                              }
                                          }
                                          else {
                                              NSLog(@"Error : %@", error.localizedDescription);
                                          }
                                          //*** end indicator....
                                      }];
    [dataTask resume];
}

@end


/*
 {
 "ams_360_contact_uuid" = "<null>";
 "answer_stamp" = "2018-11-08 14:01:40";
 blacklisted = "<null>";
 "blue_timestamp" = "<null>";
 "call_direction" = outbound;
 "call_history_fs_uuid" = "f720e519-261f-3105-93ce-187480a53809";
 "call_length" = 0;
 "call_status" = answered;
 "call_uuid" = "9d0395ba-f74b-47f3-b219-acb9f3b5386e";
 "caller_id_name" = "Gouthami Bondugula";
 "caller_id_number" = 147;
 "cdr_json" = "<null>";
 "contact_uuid" = "<null>";
 "created_at" = "2018-11-08 14:02:13";
 "deleted_at" = "<null>";
 "destination_number" = 4706879775;
 "domain_name" = "qa-kotter-test.qa.kotter.net";
 "domain_uuid" = "c06407a8-c459-3682-975c-990554a3c804";
 duration = 5;
 "end_stamp" = "2018-11-08 14:01:35";
 "extension_uuid" = "6a77a816-2cfe-37ef-91c1-0d2075624bee";
 "extra_details" = "<null>";
 "hangup_cause" = "<null>";
 "manual_recording_filepath" = "<null>";
 "missed_call" = "<null>";
 "recording_deleted_at" = "<null>";
 "recording_filepath" = "<null>";
 "sent_to_voicemail" = "<null>";
 "start_stamp" = "2018-11-08 14:01:35";
 "time_to_answer" = 5;
 "updated_at" = "2018-11-29 20:24:38";
 "voicemail_filepath" = "<null>";
 }
 */
