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

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>


#define UUID_LIST @"uuid_list"
#define SELECTED_UUID @"selected_uuid"
#define HOST_LIST @"host_list"
#define SELECTED_HOST @"selected_host"
#define SITEID_LIST @"siteid_list"
#define SELECTED_SITEID @"selected_siteid"  
#define PLATFORM @"platform"
#define DEVICEUUID @"device_uuid"
#define CTRLUSER_LIST @"ctrl_user_list"
#define SELECTED_CTRLUSER @"selected_ctrl_user"

@interface SettingViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate> {
    NSString *selected_host;
    NSString *selected_uuid;
    NSString *selected_siteid;
    NSString *selected_ctrl_user;
    NSMutableArray *uuidList;
    NSMutableArray *hostList;
    NSMutableArray *siteidList;
    NSMutableArray *ctrlUserList;
    
    id btnForAlert;
}

@property (weak, nonatomic) IBOutlet UIPickerView *hostPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *uuidPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *siteidPicker;

@property (weak, nonatomic) IBOutlet UIButton *addHost;
@property (weak, nonatomic) IBOutlet UIButton *addUUID;
@property (weak, nonatomic) IBOutlet UIButton *addSiteID;
@property (weak, nonatomic) IBOutlet UITableViewCell *identifierCell;


@end
