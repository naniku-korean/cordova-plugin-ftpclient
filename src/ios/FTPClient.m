#import "FTPClient.h"

CkoFtp2 *ftp = nil;

@implementation ftpClient

- (void) keySetting:(CDVInvokedUrlCommand*)command
{
    ftp = [[CkoFtp2 alloc] init];
    CDVPluginResult* result = nil;
    
    BOOL success;
    
    //  Any string unlocks the component for the 1st 30-days.
    success = [ftp UnlockComponent: @"Anything for 30-day trial"];
    // success
    if (success == YES) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                 messageAsString:@"true"];
    }
    // failure
    else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"false"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

//FTP 접속
- (void) connect:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = nil;
    
    NSString *host = [[command arguments] objectAtIndex:0];
    NSString *user = [[command arguments] objectAtIndex:1];
    NSString *pw = [[command arguments] objectAtIndex:2];
    NSString *restartNext = [[command arguments] objectAtIndex:3];
    
    
    ftp.Hostname = host;
    ftp.Username = user;
    ftp.Password = pw;
    
    BOOL success;
    
    //  Any string unlocks the component for the 1st 30-days.
    success = [ftp Connect];
    // success
    if (success == YES) {
        ftp.RestartNext = [restartNext isEqualToString:@"true"]? YES:NO;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:@"true"];
    }
    // failure
    else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"false"];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

// FTP 파일 전송
- (void) asyncPutFile:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = nil;

    NSString *localFile = [[command arguments] objectAtIndex:0];
    NSString *remoteFile = [[command arguments] objectAtIndex:1];
    
    BOOL success;
    
    success = [ftp AsyncPutFileStart: localFile
                      remoteFilename: remoteFile];
    
    if (success != YES) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"false"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    
    [self.commandDelegate runInBackground:^{
        int fileSize = 0;
        NSDictionary* sendData = nil;
        CDVPluginResult* result = nil;
        
        while (ftp.AsyncFinished != YES) {
            NSLog(@"%d%@", [ftp.AsyncBytesSent intValue], @"bytes send");
            NSLog(@"%d%@", [ftp.UploadTransferRate intValue], @"bytes send");
            
            sendData = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat: @"%d", [ftp.AsyncBytesSent intValue]], @"sendByte", [NSString stringWithFormat: @"%d", [ftp.UploadTransferRate intValue]], @"transferRate", nil];
            
            if ([ftp.AsyncBytesSent intValue] > 0 && fileSize == [ftp.AsyncBytesSent intValue]){
                sendData = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat: @"%i", ftp.AsyncSuccess], @"value", [NSString stringWithFormat: @"%@", ftp.AsyncLog], @"log", nil];
                
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat: @"%@", sendData]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [NSString stringWithFormat: @"%@", sendData]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                
                fileSize = [ftp.AsyncBytesSent intValue];
                
                [ftp SleepMs: [NSNumber numberWithInt: 1000]];
            }
        }
        if (ftp.AsyncSuccess == YES){
            sendData = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat: @"%i", ftp.AsyncSuccess, @"value", [NSString stringWithFormat: @"%d", [ftp.UploadTransferRate intValue], @"sendByte"], @"log"], nil];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
            NSLog(@"%@", @"File Uploaded");
        } else {
            sendData = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat: @"%i", ftp.AsyncSuccess], @"value", [NSString stringWithFormat: @"%@", ftp.AsyncLog], @"log", nil];
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat: @"%@", sendData]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
            NSLog(@"%@", ftp.AsyncLog);
        }
    }];
}


- (void) getRemoteFileSize:(CDVInvokedUrlCommand*)command
{
    
}
- (void) createRemoteDir:(CDVInvokedUrlCommand*)command
{
    
}
- (void) changeRemoteDir:(CDVInvokedUrlCommand*)command
{
    
}
- (void) deleteRemoteFile:(CDVInvokedUrlCommand*)command
{
    
}
- (void) disconnect:(CDVInvokedUrlCommand*)command
{
    
}

- (void)greet:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];

    [self success:result callbackId:callbackId];
}

@end