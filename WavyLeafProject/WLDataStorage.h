//
//  WLDataStorage.h
//  WavyLeafProject
//
//  Created by Eric Forbes on 4/17/13.
//  Copyright (c) 2013 Eric Forbes. All rights reserved.
//

#import <Foundation/Foundation.h>


//Protocol definition starts here
@protocol WLDataStorageDelegate <NSObject>
@required
-(void)processSucceeded;
-(void)processFailed;
-(void)processSaved;
@end
//Protocol definition ends here


@interface WLDataStorage : NSObject <NSURLConnectionDelegate>
{
    //Delegate to respond back
    id <WLDataStorageDelegate> _delegate;
    NSMutableDictionary *dictionary;
    NSString *placeHolder;//Takes the incoming classes note's placeholder.. to compare if it's empty or not
    NSString *urlAsString;
    BOOL sendingLog;//Determine if user is sending log or creating account
    
    
}

@property (nonatomic, strong) id delegate;

//Required Attributes for Submit_Points.php
@property (nonatomic) NSString *udid;
@property (nonatomic) NSString *percentage;
@property (nonatomic) NSDate *datetime;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

//Non-Required Attributes for Submit_Points.php
@property (nonatomic) id note;
@property (nonatomic) id areavalue;//ID because it can either be decimal or NULL
@property (nonatomic) id areatype;//ID because it can either be decimal or NULL
@property (nonatomic) id picture;//ID because it can either be string or NULL

//Required Attributes for Submit_User.php
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *birthyear;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *education;
@property (nonatomic) NSString *outdoorexperience;
@property (nonatomic) NSString *generalplantid;
@property (nonatomic) NSString *wavyleafid;
@property (nonatomic) NSString *treatment;



//Main Initializer for Submitting Points
-(id)initWithUDID:(NSString *)uid PercentSeen:(NSString *)percent DateTime:(NSDate *)dt latitude:(double)lat longitude:(double)lon areaValue:(NSString *)areaVal areaType:(NSString *)areaType notes:(NSString *)notes notesPlaceHolderText:(NSString *)placeholderText base64Image:(NSString*)base64Img treatment:(NSString*)treatment;

//Main Intializer for Submitting User
-(id)initWithName:(NSString *)userName BirthYear:(NSString *)userBirthYear Email:(NSString *)userEmail Education:(NSString *)userEducation OutdoorExp:(NSString *)outdoorExp GeneralPlantID:(NSString *)plantID WavyLeafID:(NSString *)wlID;


//Methods
-(void)serializeAndStoreLog;
-(void)successAlertLog;
-(void)successAlertUser;
-(void)sendToServer:(NSData *)jsonData;
+(void)sendToServer:(NSData *)jsonData withFilePath:(NSString *)filePath;
-(void)saveToPhone:(NSData *)jsonData;
+(void)sendLocalDataToServer;
+(BOOL)connectedToNetwork;
+(BOOL)checkInternet;





@end
