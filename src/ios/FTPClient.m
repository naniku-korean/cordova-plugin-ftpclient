#import "FTPClient.h"

CkoFtp2 *ftp = nil;

@implementation ftpClient

- (void) keySetting:(CDVInvokedUrlCommand*)command
{
    ftp = [[CkoFtp2 alloc] init];
    CDVPluginResult* result = nil;
    
    NSString *key = [[command arguments] objectAtIndex:0];
    
    if (key == nil || [key isEqual:@"null"] || [key isEqual:@""]) {
        key = @"Anything for 30-day trial";
    }
    
    BOOL success;
    
    //  Any string unlocks the component for the 1st 30-days.
    success = [ftp UnlockComponent: key];
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
    [self.commandDelegate runInBackground:^{
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
            ftp.RestartNext = [restartNext isEqual:@"true"]? YES:NO;
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:@"true"];
        }
        // failure
        else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"false"];
        }
    
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

// FTP 파일 전송
- (void) asyncPutFile:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
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
    
    
        int fileSize = 0;
        NSString* sendData = nil;
        
        while (ftp.AsyncFinished != YES) {
            NSLog(@"%d%@", [ftp.AsyncBytesSent intValue], @"bytes send");
            NSLog(@"%d%@", [ftp.UploadTransferRate intValue], @"bytes send");
            NSLog(@"%d%@", fileSize, @" - fileSize");
            sendData = [NSString stringWithFormat:@"{sendByte:%d, transferRate:%d}",[ftp.AsyncBytesSent intValue], [ftp.UploadTransferRate intValue]];
            
            if ([ftp.AsyncBytesSent intValue] > 0 && fileSize == [ftp.AsyncBytesSent intValue]){
                sendData = [NSString stringWithFormat: @"{value:%@, log:%@}", ftp.AsyncSuccess?@"true":@"false", ftp.AsyncLog];
                
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat: @"%@", sendData]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                
                [ftp Disconnect];
                return;
            } else {
                NSLog(@"%@%@", sendData, @" - sendData");
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [NSString stringWithFormat: @"%@", sendData]];
                [result setKeepCallback:[NSNumber numberWithBool:YES]];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                
                fileSize = [ftp.AsyncBytesSent intValue];
                
                [ftp SleepMs: [NSNumber numberWithInt: 1000]];
            }
        }
        if (ftp.AsyncSuccess == YES){
            sendData = [NSString stringWithFormat: @"{value:%@, log:%@}", ftp.AsyncSuccess?@"true":@"false", ftp.AsyncLog];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat: @"%@", sendData]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
            NSLog(@"%@", @"File Uploaded");
        } else {
            sendData = [NSString stringWithFormat: @"{value:%@, log:%@}", ftp.AsyncSuccess?@"true":@"false", ftp.AsyncLog];
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat: @"%@", sendData]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
            NSLog(@"%@", ftp.AsyncLog);
        }
    }];
}

- (void) getRemoteFileSize:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        NSString *file = [[command arguments] objectAtIndex:0];
    
        NSNumber *fileSize = [ftp GetSizeByName:file];
        if ([fileSize intValue] > 0) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat: @"%d", [fileSize intValue]]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat: @"%@", ftp.LastErrorText]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

- (void) createRemoteDir:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        NSString *folder = [[command arguments] objectAtIndex:0];
    
        BOOL created = [ftp CreateRemoteDir:folder];
    
        if (created) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"false"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

- (void) changeRemoteDir:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        NSString *folder = [[command arguments] objectAtIndex:0];
    
        BOOL changed = [ftp ChangeRemoteDir:folder];
    
        if (changed) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"false"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}
- (void) deleteRemoteFile:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        NSString *file = [[command arguments] objectAtIndex:0];
    
        BOOL changed = [ftp DeleteRemoteFile:file];
    
        if (changed) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"true"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"false"];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

- (void) getPathFromMediaUri:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* result = nil;
    

}

- (void) disconnect:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        BOOL disconnected = [ftp Disconnect];
    
        if (disconnected) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat: @"%i", disconnected]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat: @"%i", disconnected]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

@end