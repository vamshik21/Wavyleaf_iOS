//
//  WLDataStorage.m
//  WavyLeafProject
//
//  Created by Eric Forbes on 4/17/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import "WLDataStorage.h"
#import "Reachability.h"

@implementation WLDataStorage

@synthesize udid, percentage, datetime, latitude, longitude, areatype, areavalue;

-(id)initWithUDID:(NSString *)uid PercentSeen:(NSString *)percent DateTime:(NSDate *)dt latitude:(double)lat longitude:(double)lon areaValue:(NSString *)areaVal areaType:(NSString *)areaType notes:(NSString *)note notesPlaceHolderText:(NSString *)placeholderText base64Image:(NSString *)base64Img treatment:(NSString *)treatment
{
    self = [super init];
    if (self){
        
        //Set the accessors
        [self setUdid:uid];
        [self setPercentage:percent];
        [self setDatetime:dt];
        [self setLatitude:lat];
        [self setLongitude:lon];
        [self setAreatype:areaType];
        [self setAreavalue:areaVal];
        [self setNote:note];
        [self setPicture:base64Img];
        [self setTreatment:treatment];
        
        //Set the placeholder text
        placeHolder = placeholderText;
        
        //Set the proper php script
        urlAsString = @"http://heron.towson.edu/wavyleaf/submit_point_with_pic.php";
        
        sendingLog = TRUE;
        
        
    }
    return self;
}




- (id)initWithName:(NSString *)userName BirthYear:(NSString *)userBirthYear Email:(NSString *)userEmail Education:(NSString *)userEducation OutdoorExp:(NSString *)outdoorExp GeneralPlantID:(NSString *)plantID WavyLeafID:(NSString *)wlID
{
    self = [super init];
    if (self){
        self.name = userName;
        self.birthyear = userBirthYear;
        self.email = userEmail;
        self.education = userEducation;
        self.outdoorexperience = outdoorExp;
        self.generalplantid = plantID;
        self.wavyleafid = wlID;
        
        //Set the proper PHP script
        urlAsString = @"http://heron.towson.edu/wavyleaf/submit_user.php";
        
        sendingLog = FALSE;
    }
    
    return self;
}



-(void)serializeAndStoreLog
{
    NSLog(@"--Serializing and storing log\n");
    //Send a Log
    if (sendingLog){
        
        //Verify values and change them to NULL when NULL
        //If areavalue is empty --> areatype+areavalue must be NULL values in JSON
        if ([self.areavalue isEqualToString:@""]){
            self.areatype = [NSNull null];
            self.areavalue = [NSNull null];
            //Else --> Convert areavalue to decimal
        } else {
            self.areavalue = [NSDecimalNumber decimalNumberWithString:self.areavalue];
        }
        
        
        //Check if Picture is empty
        if ([self.picture isEqualToString:@""]){
            //self.picture = [NSNull null];
            //set to "null" because backend server looks for picture "null"
            self.picture = @"null";
        }
        
        
        //If the Note is set to the placeholder or is empty... MAKE IT NULL
       /* if ([self.note isEqualToString:@""] || [self.note isEqualToString:placeHolder]){
            self.note = [NSNull null];
        }*/
        if ([self.note isEqualToString:placeHolder]) {
            self.note = @"";
            NSLog(@"Setting placeholder to empty value");
        }
        NSLog(@"Placeholder--> %@", placeHolder);
        NSLog(@"Text--> %@", self.note);
        //Convert coordinate doubles to type NSDecimalNumber
        NSDecimalNumber *lat = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[self latitude]];
        NSDecimalNumber *lon = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[self longitude]];
        
        //Convert NSDate to NSString
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyy-MM-dd HH:mm:ss zzz"];
        NSString *dateString = [format stringFromDate:[self datetime]];
        
        //Store attributes in a dictionary
        dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                      @"user_id":[self udid],
                      @"date":dateString,
                      @"latitude":lat,
                      @"longitude":lon,
                      @"percent":[self percentage],
                      @"areatype":[self areatype],
                      @"areavalue":[self areavalue],
                      @"notes":[self note],
                      @"picture":[self picture],
                      @"treatment":[self treatment]
                      }];
        
        
        //Create Account
    } else {
        
        //Store attributes in dictionary
        dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                      @"name":self.name,
                      @"birthyear":self.birthyear,
                      @"email":self.email,
                      @"education":self.education,
                      @"outdoorexperience":self.outdoorexperience,
                      @"generalplantid":self.generalplantid,
                      @"wavyleafid":self.wavyleafid}];
        
    }
    
    
    //Generate JSON data from Dictionary
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    
    
    
    
    //JSON generation successfull
    if ([jsonData length] > 0 && error == nil)
    {
        //Check for Internet only if sending Log --- WLAccountExtended Registration is already checking for internet
        if (sendingLog){
            if (![WLDataStorage checkInternet]){
                NSLog(@"--No internet, about to save to phone\n");
                [self saveToPhone:jsonData];
                return;
            }
        }
        
        NSLog(@"--About to send to server\n");
        //User Registration OR Log data WITH internet connection
        // Because we don't want to save REGISTRATION data
        [self sendToServer:jsonData];
        
        
    }
    else if ([jsonData length] == 0 && error == nil){
        // NSLog(@"No data returned. bo");
        
    }
    else if (error != nil){
        //NSLog(@"An error occurred wo= %@", error);
        
    }
    
}





-(void)sendToServer:(NSData *)jsonData
{
    @autoreleasepool {
        
        NSLog(@"--Sending to server\n");
        //Create URL to send request
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSLog(@"--URL: %@", urlAsString);
        //Create the request
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:jsonData];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"content-length"];
        
        //Convert JSON to string for debugging
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON STRING>>>>%@", jsonString);
        
        
        //ASYNC connection
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *jsonDataResponse, NSError *error) {
            
            //NSLog(@"Inside aync connection");
            if ([jsonDataResponse length] >0 && error == nil){
                
                //Convert JSON to Dictonary
                id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonDataResponse options:NSJSONReadingAllowFragments error:&error];
                
                
                if (jsonObject != nil && error == nil){
                    
                    //Check if object is a dictionary
                    if ([jsonObject isKindOfClass:[NSDictionary class]]){
                        
                        NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                        //NSLog(@"value -->%@", [deserializedDictionary valueForKey:@"success"]);
                        
                        if ([[deserializedDictionary valueForKey:@"success"] isEqual:@"1"]){
                            
                            if (!sendingLog){
                                //Set the user_id in application storage
                                //NSLog(@"USER ID: %@", [deserializedDictionary valueForKey:@"message"]);
                                [[NSUserDefaults standardUserDefaults] setValue:[deserializedDictionary valueForKey:@"message"] forKey:@"user_id"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                            
                            //ANY interactions with UIKit must go on main thread (because it may manipulate UI)
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate processSucceeded];
                            });
                            //NSLog(@"success!!!");
                            
                        } else if ([[deserializedDictionary valueForKey:@"success"] isEqual:@"0"]){
                            NSLog(@"WLDataStorage: Returning Message = %@", [deserializedDictionary valueForKey:@"message"]);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate processFailed];
                            });
                            
                        } else {
                            NSLog(@"WLDataStorage: Server returned something other than 0 or 1");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate processFailed];
                            });
                        }
                    } else {
                        NSLog(@"WLDataStorage: Received something other than a dictionary (Array maybe?)");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate processFailed];
                        });
                    }
                } else {
                    //Show error and return
                    NSLog(@"WLDataStorage: Could not deserialize the JSON data");
                    NSLog(@"Error: %@", error.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate processFailed];
                    });
                }
            } else if ([jsonDataResponse length] == 0 && error == nil){
                NSLog(@"WLDataStorage: Nothing was received back from the server");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate processFailed];
                });
                
            } else if (error != nil){
                NSLog(@"WLDataStorage: Error happened while sending data: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate processFailed];
                });
            }
            
        }];
    }
    
    
}




-(void)saveToPhone:(NSData *)jsonData
{
    //Create FILENAME
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"submitLog-%@", dateString];
    
    //Retrieve DOCUMENTS directory. Create the FILEPATH
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    //Save the NSData to the FILEPATH
    [jsonData writeToFile:filePath options:NSStringEncodingConversionAllowLossy error:nil];
    
    //Send delegate message
    [self.delegate processSaved];
}


+(void)sendToServer:(NSData *)jsonData withFilePath:(NSString *)filePath
{
    @autoreleasepool {
        NSLog(@"--Sending data to server NOW");
        //Set the proper php script
        //Remember this is a class method so i'm using a new urlAsString variable
        NSString *urlAsString = @"http://skappsrv.towson.edu/wavyleaf/submit_point_with_pic.php";
        
        //Create URL to send request
        NSURL *url = [NSURL URLWithString:urlAsString];
        
        //Create the request
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:jsonData];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"content-length"];
        
        //ASYNC connection
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *jsonDataResponse, NSError *error) {
            
            //NSLog(@"Inside aync connection");
            if ([jsonDataResponse length] >0 && error == nil){
                
                //Convert JSON to Dictonary
                id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonDataResponse options:NSJSONReadingAllowFragments error:&error];
                
                
                if (jsonObject != nil && error == nil){
                    
                    //Check if object is a dictionary
                    if ([jsonObject isKindOfClass:[NSDictionary class]]){
                        
                        NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                        
                        
                        if ([[deserializedDictionary valueForKey:@"success"] isEqual:@"1"]){
                            
                            //SUCCESS
                            NSLog(@"SUCCESS!\n\n");
                            //Remove from filesystem
                            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                            
                            
                        } else if ([[deserializedDictionary valueForKey:@"success"] isEqual:@"0"]){
                            
                            
                        } else {
                            
                        }
                    } else {
                        
                    }
                } else {
                    
                }
            } else if ([jsonDataResponse length] == 0 && error == nil){
                
                
            } else if (error != nil){
                
            }
            
        }];
    }
}


+(void)sendLocalDataToServer
{
    NSLog(@"--Checking for any local data + net connections");
    //Retrieve and store the Documents Directory Path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    
    //If there is something in the directory and there is an internet connection
    if ([directoryContent count] > 0){
        
        if ([self checkInternet]){
            
            for (NSString *fileName in directoryContent){
                
                NSLog(@"Sending %@", fileName);
                
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
                
                //Send data from phone to servee
                [self sendToServer:jsonData withFilePath:filePath];
            }
        } else {
            NSLog(@"No internet to upload saved data.");
        }
    } else {
        NSLog(@"No local data.");
    }
    
    
}



+(BOOL)connectedToNetwork
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL internet;
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)){
        internet = NO;
    } else {
        internet = YES;
    }
    return internet;
}

+(BOOL)checkInternet
{
    //Make sure we have internet connectivity
    if (![WLDataStorage connectedToNetwork]){
        //Show error message
        return NO;
    } else {
        return YES;
    }
}








-(void)successAlertLog
{
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your log has been successfully saved!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

-(void)successAlertUser
{
    //Generate a success popup
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Account has been successfully created!" message:nil delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
    
    [alert show];
}





















@end
