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

#import "SettingViewController.h"

#import "HLPBeaconSampler.h"
#import "HLPReferencePoint.h"

#define SAMPLING_COUNT @"sampling_count"
#define REFPOINT_LIST @"refpoint_list"
#define SELECTEDRP @"selected_rp"
#define SELECTEDX @"selected_x"
#define SELECTEDY @"selected_y"
#define SELECTEDZ @"selected_z"
#define MIN_X -100
#define MAX_X 100
#define MIN_Y -100
#define MAX_Y 100
#define MIN_Z -10
#define MAX_Z 10
#define MIN_F -3
#define MAX_F 10
#define STEP 0.1

@interface BeaconViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate, HLPBeaconSamplerDelegate, NSURLSessionDelegate> {
    NSMutableArray *referencePointList;
    HLPBeaconSampler *sampler;
    NSString *server_host;
    
    int counter;
    BOOL scanning;
    BOOL uploadFailed;
    
    double selected_x;
    double selected_y;
    double selected_z;
    HLPReferencePoint *selected_rp;
    NSString *selected_uuid;
    
    BOOL initialized;
}

@property (weak, nonatomic) IBOutlet UIPickerView *refpointPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *positionPicker;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UILabel *beacon_num;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIStepper *counterBtn;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

- (void) loadDefault;

@end
