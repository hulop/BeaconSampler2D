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

#import "BeaconViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "HLPUtil.h"

@interface BeaconViewController ()

@end

#define SAMPLING_UPLOAD_URL @"http://%@/LocationService/data/samplings"
#define REFERENCE_POINT_URL @"http://%@/LocationService/data/refpoints"

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"BeaconView didload");
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    [defaults setObject:@"0.0.0.0" forKey:SELECTED_HOST];
    [defaults setObject:@(30) forKey:SAMPLING_COUNT];
    [defaults setObject:@(0) forKey:SELECTEDX];
    [defaults setObject:@(0) forKey:SELECTEDY];
    [defaults setObject:@(0) forKey:SELECTEDZ];
    [ud registerDefaults:defaults];
    
    sampler = [HLPBeaconSampler sharedInstance];
    
    self.refpointPicker.dataSource = self;
    self.refpointPicker.delegate = self;
    self.positionPicker.dataSource = self;
    self.positionPicker.delegate = self;

    [self reset];
    [self loadDefault];
}

- (void) reset {
    referencePointList = [[NSMutableArray alloc] init];
    counter = (int)[[NSUserDefaults standardUserDefaults] integerForKey:SAMPLING_COUNT];
    self.counterBtn.value = counter;
    scanning = false;
    uploadFailed = false;
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"BeaconView didAppear");
    sampler.delegate = self;
}

- (IBAction)refresh:(id)sender {
    [self loadDefault];
}
- (IBAction)retry:(id)sender {
    [self uploadData];
}

- (void) loadDefault {
    //NSLog(@"BeaconView loadDefault %d", initialized);
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    server_host = [ud stringForKey:SELECTED_HOST];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:REFERENCE_POINT_URL, server_host]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 5;
    NSHTTPURLResponse *response = nil;
    NSError *error          = nil;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if (!error) {
            NSError *parseError     = nil;
            NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            
            if (!parseError) {
                for(NSDictionary *dic in resultArray) {
                    [temp addObject:[[HLPReferencePoint alloc] initWithJSON:dic]];
                }
                [ud setObject:resultArray forKey:REFPOINT_LIST];
            }
        } else {
            NSLog(@"%@", [error localizedDescription]);
            NSArray *array = [ud arrayForKey:REFPOINT_LIST];
            if (array) {
                for(NSDictionary *dic in array) {
                    [temp addObject:[[HLPReferencePoint alloc] initWithJSON:dic]];
                }
            }
        }

     
        if ([temp count] == 0) {
            for(float i = MIN_F; i <= MAX_F; i+=0.5) {
                HLPReferencePoint *rp = [[HLPReferencePoint alloc] init];
                rp.floor_num = i;
                rp.floor = [NSString stringWithFormat:@"%@%.1fF",(i<0?@"B":@""),(i<0?-i:i+1)];
                rp.x = 0;
                rp.y = 0;
                rp.name = rp.floor;
                rp._id = [[NSDictionary alloc] init];
                [temp addObject:rp];
            }
        }
        
        int rp_index = 0;
        for(HLPReferencePoint *rp in temp) {
            if([rp.floor isEqual:[ud stringForKey:SELECTEDRP]]) {
                break;
            }
            rp_index++;
        }
        if (rp_index >= [temp count]) {
            rp_index = 0;
        }
        selected_rp = [temp objectAtIndex:rp_index];
        
        //[NSThread sleepForTimeInterval:1.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            referencePointList = temp;
            [self.refpointPicker reloadComponent:0];
            [self.refpointPicker selectRow:rp_index inComponent:0 animated:NO];
         });
    }];
    
    selected_x = [ud doubleForKey:SELECTEDX];
    selected_y = [ud doubleForKey:SELECTEDY];
    selected_z = [ud doubleForKey:SELECTEDZ];
    [self.positionPicker selectRow:(int)((selected_x-MIN_X)/0.1) inComponent:0 animated:NO];
    [self.positionPicker selectRow:(int)((selected_y-MIN_Y)/0.1) inComponent:1 animated:NO];
    [self.positionPicker selectRow:(int)((selected_z-MIN_Z)/0.1) inComponent:2 animated:NO];
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.refpointPicker) {
        return 1;
    }
    if (pickerView == self.positionPicker) {
        return 3;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.refpointPicker) {
        return [referencePointList count];
    }
    if (pickerView == self.positionPicker) {
        switch (component) {
            case 0:
                return (MAX_X-MIN_X)/0.1+1;
            case 1:
                return (MAX_Y-MIN_Y)/0.1+1;
            case 2:
                return (MAX_Z-MIN_Z)/0.1+1;
        }
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (pickerView == self.refpointPicker) {
        if ([referencePointList count] <= row) {
            return;
        }
        selected_rp = [referencePointList objectAtIndex:row];
        [ud setObject:selected_rp.floor forKey:SELECTEDRP];
    }
    if (pickerView == self.positionPicker) {
        switch(component) {
            case 0:
                selected_x = MIN_X + row * STEP;
                [ud setObject:[NSNumber numberWithDouble:selected_x] forKey: SELECTEDX];
                break;
            case 1:
                selected_y = MIN_Y + row * STEP;
                [ud setObject:[NSNumber numberWithDouble:selected_y] forKey: SELECTEDY];
                break;
            case 2:
                selected_z = MIN_Z + row * STEP;
                [ud setObject:[NSNumber numberWithDouble:selected_z] forKey: SELECTEDZ];
                break;
        }
    }
    [ud synchronize];
    
}
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    
    if (pickerView == self.refpointPicker) {
        HLPReferencePoint *rp = [referencePointList objectAtIndex:row];
        retval.text = [rp toString];
    }
    if (pickerView == self.positionPicker) {
        switch (component) {
            case 0:
                retval.text = [NSString stringWithFormat:@"%.1f=x", MIN_X + 0.1*row];
                break;
            case 1:
                retval.text = [NSString stringWithFormat:@"%.1f=y", MIN_Y + 0.1*row];
                break;
            case 2:
                retval.text = [NSString stringWithFormat:@"%.1f=z", MIN_Z + 0.1*row];
                break;
        }
    }
    retval.numberOfLines = 1;
    [retval sizeToFit];
    return retval;
    
}

- (IBAction)startScan:(id)sender {

    [sampler setSamplingBeaconUUID:[[NSUserDefaults standardUserDefaults] stringForKey:SELECTED_UUID]];
    if ([sampler startRecording]) {
        scanning = true;
    }
    //[self updateUI];
}

- (IBAction)cancelScan:(id)sender {
    scanning = false;
    NSString *f = selected_rp.floor;
    [sampler stopRecording];
    [sampler reset];
    [self reset];
    [self updateUI];
}

- (IBAction)stopScan:(id)sender {
    scanning = false;
    NSString *f = selected_rp.floor;
    HLPPoint3D *point = [[HLPPoint3D alloc] initWithX:selected_x Y:selected_y Z:selected_z Floor:f];
    [sampler setSamplingLocation:point];
    [sampler stopRecording];
    [self prepareData];
    [sampler reset];
    [self reset];
    [self updateUI];
}

- (IBAction)changeCount:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:self.counterBtn.value ] forKey:SAMPLING_COUNT];
    [self reset];
    [self updateUI];
}

- (IBAction)doRetry:(id)sender {
}

- (void) prepareData {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *json = [sampler toJSON];
    
    NSMutableDictionary *meta = [[NSMutableDictionary alloc] init];
    [meta setObject:selected_rp.name forKey:@"name"];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [json setObject:info forKey:@"information"];
    [info setObject:[ud stringForKey:SELECTED_SITEID] forKey:@"site_id"];
    [info setObject:[NSNumber numberWithDouble:selected_x] forKey:@"x"];
    [info setObject:[NSNumber numberWithDouble:selected_y] forKey:@"y"];
    [info setObject:[NSNumber numberWithDouble:selected_z] forKey:@"z"];
    [info setObject:selected_rp._id forKey:@"refid"];
    [info setObject:selected_rp.floor forKey:@"floor"];
    [info setObject:[NSNumber numberWithFloat:selected_rp.floor_num] forKey:@"floor_num"];
    NSMutableArray *tags = [[NSMutableArray alloc] init];

    [tags addObject:[ud objectForKey:PLATFORM]];
    [tags addObject:[ud objectForKey:DEVICEUUID]];
    [info setObject:tags forKey:@"tags"];
        
    NSMutableDictionary *refpoint = [[NSMutableDictionary alloc] init];
    [refpoint setObject:@"refpoints" forKey:@"$ref"];
    [refpoint setObject:selected_rp._id forKey:@"$id"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_json.data", [HLPUtil dateString]]];
    
    NSString *metastr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:meta options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    NSString *datastr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    NSString *body = [NSString stringWithFormat:@"_metadata=%@&data=%@", metastr, datastr];
    
    [body writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [sampler reset];
    [self uploadData];
}

- (void) uploadData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *list = [HLPUtil getFileTypeOf:@"data" atPath:documentsDirectory];
 
    if ([list count] == 0) {
        return;
    }

    NSURLSessionConfiguration* myConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:myConfiguration
                                                            delegate:self
                                                       delegateQueue:[NSOperationQueue mainQueue]];
                               
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:SELECTED_HOST];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:SAMPLING_UPLOAD_URL, server]];

    NSString *path = [list objectAtIndex: 0];
    NSLog(@"upload %@", path);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSData alloc] initWithContentsOfFile:path];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if (!error) {
                                                    if ([response isMemberOfClass: [NSHTTPURLResponse class]]) {
                                                        if (((NSHTTPURLResponse*) response).statusCode == 200) {                                                                                                       //if ([Util deleteFile:path]) {

                                                            //[self uploadData];
                                                            //}
                                                            NSString *move = [documentsDirectory stringByAppendingPathComponent:@"done"];
                                                            if ([HLPUtil moveFile:path toDir:move]) {
                                                                [self uploadData];
                                                            }
                                                        }
                                                    }
                                                    [self updateUI];
                                                    
                                                } else {
                                                    NSLog(@"Session error %@", error);
                                                }
                                            }];
    
    [task resume];
}

- (void) updateUI {
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *list = [HLPUtil getFileTypeOf:@"data" atPath:documentsDirectory];
    
    self.count.text = [NSString stringWithFormat:@"%d", counter];
    self.beacon_num.text = [NSString stringWithFormat:@"%ld beacons", [sampler visibleBeaconCount]];
    
    [self.stopBtn setEnabled:scanning];
    [self.startBtn setEnabled:!scanning];
    [self.counterBtn setEnabled:!scanning];
    [self.refreshBtn setEnabled:!scanning];
    [self.cancelBtn setEnabled:scanning];
    [self.refpointPicker setUserInteractionEnabled:!scanning];
    [self.positionPicker setUserInteractionEnabled:!scanning];
    self.retryBtn.hidden = ([list count] == 0);
    [self.retryBtn setTitle:[NSString stringWithFormat:@"Retry(%ld)",[list count]] forState:UIControlStateNormal];
    //});
}

- (void)updated {
    int defCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:SAMPLING_COUNT];
    
    counter = defCount - (int)[sampler beaconSampleCount];
    NSLog(@"%ld,%ld,%ld", counter, defCount, [sampler beaconSampleCount]);
    if (counter <= 0 && [sampler isRecording]) {
        [self stopScan:nil];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    [self updateUI];
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
