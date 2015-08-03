#import <Cordova/CDV.h>
#import "include/CkoFtp2.h"

@interface FTPClient : CDVPlugin

extern CkoFtp2 *ftp;

- (void) keySetting:(CDVInvokedUrlCommand*)command;
- (void) connect:(CDVInvokedUrlCommand*)command;
- (void) asyncPutFile:(CDVInvokedUrlCommand*)command;
- (void) getRemoteFileSize:(CDVInvokedUrlCommand*)command;
- (void) createRemoteDir:(CDVInvokedUrlCommand*)command;
- (void) changeRemoteDir:(CDVInvokedUrlCommand*)command;
- (void) deleteRemoteFile:(CDVInvokedUrlCommand*)command;
- (void) getPathFromMediaUri:(CDVInvokedUrlCommand*)command;
- (void) abort:(CDVInvokedUrlCommand*)command;
- (void) disconnect:(CDVInvokedUrlCommand*)command;

@end
