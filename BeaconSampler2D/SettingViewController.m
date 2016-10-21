/*******************************************************************************
 * Copyright (c) 2014, 2016  IBM Corporation, Carnegie Mellon University and others
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // initialize
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    
    uuidList = [[NSMutableArray alloc] init];

    [defaults setObject:uuidList forKey:UUID_LIST];
    [defaults setObject:@"" forKey:SELECTED_UUID];
    
    hostList = [[NSMutableArray alloc] init];

    [defaults setObject:hostList forKey:HOST_LIST];
    [defaults setObject:@"" forKey:SELECTED_HOST];
    
    siteidList = [[NSMutableArray alloc] init];
    [defaults setObject:siteidList forKey:SITEID_LIST];
    [defaults setObject:@"" forKey:SELECTED_SITEID];
    

    [ud registerDefaults:defaults];
    
    self.uuidPicker.dataSource = self;
    self.uuidPicker.delegate = self;
    self.hostPicker.dataSource = self;
    self.hostPicker.delegate = self;
    self.siteidPicker.dataSource = self;
    self.siteidPicker.delegate = self;
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    NSUUID *device_uuid = [[UIDevice currentDevice] identifierForVendor];
    
    [ud setObject:platform forKey:PLATFORM];
    [ud setObject:[device_uuid UUIDString] forKey:DEVICEUUID];
    
    self.identifierCell.textLabel.text = platform;
    self.identifierCell.detailTextLabel.text = [device_uuid UUIDString];

    [self loadDefault];
}


- (void) loadDefault {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    // load user default
    [uuidList removeAllObjects];
    [uuidList addObjectsFromArray:[ud arrayForKey:UUID_LIST]];
    [hostList removeAllObjects];
    [hostList addObjectsFromArray:[ud arrayForKey:HOST_LIST]];
    [siteidList removeAllObjects];
    [siteidList addObjectsFromArray:[ud arrayForKey:SITEID_LIST]];
    
    selected_host = [ud stringForKey:SELECTED_HOST];
    selected_uuid = [ud stringForKey:SELECTED_UUID];
    selected_siteid = [ud stringForKey:SELECTED_SITEID];
    
    [self selectItem: selected_host ofPicker: self.hostPicker forList:hostList];
    [self selectItem: selected_uuid ofPicker: self.uuidPicker forList:uuidList];
    [self selectItem: selected_siteid ofPicker: self.siteidPicker forList:siteidList];

    
    [self.hostPicker reloadComponent:0];
    [self.uuidPicker reloadComponent:0];
    [self.siteidPicker reloadComponent:0];
    
    
    // Do any additional setup after loading the view.
}

- (void) selectItem:(id)item ofPicker:(UIPickerView*)picker forList:(NSArray*)list {
    if ([list indexOfObject:item] != NSNotFound) {
        [picker selectRow:[list indexOfObject:item] inComponent:0 animated:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.hostPicker) {
        return [hostList count];
    }
    if (pickerView == self.uuidPicker) {
        return [uuidList count];
    }
    if (pickerView == self.siteidPicker) {
        return [siteidList count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }

    if (pickerView == self.hostPicker) {
        retval.text = [hostList objectAtIndex:row];
    }
    if (pickerView == self.uuidPicker) {
        retval.text = [uuidList objectAtIndex:row];
        retval.font = [UIFont systemFontOfSize:11];
    }
    if (pickerView == self.siteidPicker) {
        retval.text = [siteidList objectAtIndex:row];
    }

    retval.numberOfLines = 1;
    [retval sizeToFit];
    return retval;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (pickerView == self.hostPicker) {
        if (row < [hostList count]) {
            selected_host = [hostList objectAtIndex:row];
            [ud setObject:selected_host forKey:SELECTED_HOST];
        }
    }
    if (pickerView == self.uuidPicker) {
        if (row < [uuidList count]) {
            selected_uuid = [uuidList objectAtIndex:row];
            [ud setObject:selected_uuid forKey:SELECTED_UUID];
        }
    }
    if (pickerView == self.siteidPicker) {
        if (row < [siteidList count]) {
            selected_siteid = [siteidList objectAtIndex:row];
            [ud setObject:selected_siteid forKey:SELECTED_SITEID];
        }
    }
    [ud synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addItem:(id)sender {
    UIAlertController *alertController;
    
    if (sender == self.addHost) {
        alertController = [UIAlertController alertControllerWithTitle:@"New Host" message:@"Enter the host name:" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"example.com:8080";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *colName = alertController.textFields[0].text;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString* pattern = @"^([-0-9a-zA-Z]+(\\.[-0-9a-zA-Z]+)+)(:[0-9]+)?$";
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            if ([[regex matchesInString:colName options:0 range:NSMakeRange(0, [colName length])] count] > 0 ) {
                [hostList addObject:colName];
                [ud setObject:hostList forKey:HOST_LIST];
            }
            [ud setObject:colName forKey:SELECTED_HOST];
            [ud synchronize];
            [self loadDefault];
        }]];
    }
    if (sender == self.addUUID) {
        alertController = [UIAlertController alertControllerWithTitle:@"New UUID" message:@"Enter the UUID:" preferredStyle:UIAlertControllerStyleAlert];

        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"00000000-0000-0000-0000-000000000000";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *colName = alertController.textFields[0].text;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString* pattern = @"[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}";
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            if ([[regex matchesInString:colName options:0 range:NSMakeRange(0, [colName length])] count] > 0 ) {
                [uuidList addObject:colName];
                [ud setObject:uuidList forKey:UUID_LIST];
            }
            [ud setObject:colName forKey:SELECTED_UUID];

            [ud synchronize];
            [self loadDefault];
        }]];

    }
    if (sender == self.addSiteID) {
        alertController = [UIAlertController alertControllerWithTitle:@"New Site ID" message:@"Enter the Site ID:" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *colName = alertController.textFields[0].text;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if ([colName length] > 0) {
                [siteidList addObject:colName];
                [ud setObject:siteidList forKey:SITEID_LIST];
            }
            [ud setObject:colName forKey:SELECTED_SITEID];

            [ud synchronize];
            [self loadDefault];
        }]];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
