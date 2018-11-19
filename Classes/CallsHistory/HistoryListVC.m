//
//  HistoryListVC.m
//  linphone
//
//  Created by Gouthami Reddy on 17/11/18.
//

#import "HistoryListVC.h"
#import "HistoryCallHeaderCell.h"
#import "HistoryCallsCell.h"


#import "APIService.h"
#import "VKRemoveNull.h"


// calls type
typedef NS_ENUM(NSInteger, CallsType) {
    Calls_ALL,
    Calls_MISSED,
    Calls_Agency,
};

@interface HistoryListVC () <UITableViewDelegate, UITableViewDataSource>
{
    NSDateFormatter *date_formatter;
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
    
    // Reset missed call
    linphone_core_reset_missed_calls_count(LC);
    // Fake event
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Calls Helpers
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
            return [first_date compare: second_date];
        }];
        [section_dict setObject:childCalls_array forKey:@"calls"];
        [calls_sectionsArray replaceObjectAtIndex:i withObject:section_dict];
    }
    
    agency_callsArray = [calls_sectionsArray mutableCopy];
    [self.tbl_callList reloadData];
    NSLog(@"Final agency list array : %@", agency_callsArray);
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
        [self.tbl_callList reloadData];
    }
    else if (sender.tag == 11) {
        
        // agency call list...
        callListType = Calls_Agency;
        self.view_selectedLine.constant = 65;
        
        if (agency_callsArray.count == 0) {
            [self GetAgencyCallHistory_HTTPConnection];
        } else {
            [self.tbl_callList reloadData];
        }
        
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
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (callListType == Calls_Agency) {
        return agency_callsArray.count;
    }
    else {
        return self.sortedDays.count;
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
        
        NSArray *logs = [self.sections objectForKey:self.sortedDays[section]];
        return logs.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // cell creation...
    HistoryCallsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCallsCell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"HistoryCallsCell" bundle:nil] forCellReuseIdentifier:@"HistoryCallsCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCallsCell"];
    }
    
    if (callListType == Calls_Agency) {
        
        // call dict...
        NSDictionary *callMain_dict = [agency_callsArray objectAtIndex:indexPath.section];
        NSArray *call_array = [callMain_dict objectForKey:@"calls"];
        NSDictionary *call_dict = [call_array objectAtIndex:indexPath.row];
        
        NSString *user_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"caller_id_name"]];
        if (user_name.length == 0) {
            user_name = [NSString stringWithFormat:@"%@", [call_dict objectForKey:@"caller_id_number"]];
        }
        cell.lbl_name.text = [NSString stringWithFormat:@"%@", user_name];
    }
    else {
        
        id logId = [_sections objectForKey:_sortedDays[indexPath.section]][indexPath.row];
        LinphoneCallLog *log = [logId pointerValue];
        [cell update:log];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - APIs
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
