package com.nnk;

import com.chilkatsoft.*;

import org.apache.cordova.*;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;
import android.util.Log;

public class ftpClient extends CordovaPlugin {

    private static final String TAG = "FtpClient";
    private CkFtp2 ftp = new CkFtp2();
    private String host;
    private String user;
    private String password;
    private boolean restartNext;

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        PluginResult.Status status = PluginResult.Status.OK;

        try {
            if (action.equals("connect")) {
                this.host = data.getString(0);
                this.user = data.getString(1);
                this.password = data.getString(2);
                this.restartNext = data.getBoolean(3);

                connect(data.getString(0), data.getString(1), data.getString(2), data.getBoolean(3), callbackContext);

            } else if (action.equals("asyncPutFile")) {
                // FTP 파일 전송
                asyncPutFile(data.getString(0), data.getString(1), callbackContext);
            } else if (action.equals("getRemoteFileSize")) {
                // FTP 서버에 파일 크기
                getRemoteFileSize(data.getString(0), callbackContext);
            } else if (action.equals("createRemoteDir")) {
                // FTP 서버에 새로운 폴더 생성
                createRemoteDir(data.getString(0), callbackContext);
            } else if (action.equals("changeRemoteDir")) {
                // FTP 서버 폴더 변경
                changeRemoteDir(data.getString(0), callbackContext);
            } else if (action.equals("deleteRemoteFile")) {
                // FTP 서버 파일 삭제
                deleteRemoteFile(data.getString(0), callbackContext);
            }
        } catch (JSONException e) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION));
        }

        return true;
    }
    /**
    * host : 호스트 주소
    * user : 사용자 아이디
    * password  : 사용자 비밀번호
    * restartNext : 파일 이어보내기
    */
    public void connect(String host, String user, String password, boolean restartNext, CallbackContext callbackContext){
        boolean success;

        //  Any string unlocks the component for the 1st 30-days.
        success = ftp.UnlockComponent("Anything for 30-day trial");
        if (success != true) {
            Log.i(TAG, ftp.lastErrorText());
            return;
        }

        ftp.put_Hostname(host);
        ftp.put_Username(user);
        ftp.put_Password(password);

        success = ftp.Connect();
        int failReason = ftp.get_ConnectFailReason();
        //  The possible failure reasons are:
        //  0 = success
        //  Non-SSL socket fail reasons:
        //   1 = empty hostname
        //   2 = DNS lookup failed
        //   3 = DNS timeout
        //   4 = Aborted by application.
        //   5 = Internal failure.
        //   6 = Connect Timed Out
        //   7 = Connect Rejected (or failed for some other reason)
        //  SSL failure reasons:
        //   100 = Internal schannel error
        //   101 = Failed to create credentials
        //   102 = Failed to send initial message to proxy.
        //   103 = Handshake failed.
        //   104 = Failed to obtain remote certificate.
        //  300 = asynch op in progress
        //  301 = login failure.
        //
        if(success != true){
            callbackContext.error("connect fail reason = " + String.valueOf(failReason));
            Log.i(TAG, ftp.lastErrorText());
        } else {
            ftp.put_RestartNext(restartNext);
            callbackContext.success("connect success reason = " + String.valueOf(failReason));
        }
    }

    public void asyncPutFile(String localFileName, String remoteFileName, final CallbackContext callbackContext){
        boolean success;

        success = ftp.AsyncPutFileStart(localFileName,remoteFileName);
        if (success != true) {
            callbackContext.error(ftp.lastErrorText());
            Log.i(TAG, ftp.lastErrorText());
            return;
        }
        //  The application is now free to do anything else
        //  while the file is uploading.
        //  For this example, we'll simply sleep and periodically
        //  check to see if the transfer if finished.  While checking
        //  however, we'll report on the progress in both number
        //  of bytes tranferred and performance in bytes/second.

        this.cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try{
                    while (ftp.get_AsyncFinished() != true) {
                        Log.i(TAG, String.valueOf(ftp.get_AsyncBytesSent()) + " bytes sent");
                        Log.i(TAG, String.valueOf(ftp.get_UploadTransferRate()) + " bytes per second");
                        String data = "{ sendByte:"+  String.valueOf(ftp.get_AsyncBytesSent()) +
                                      ", transferRate:"+ String.valueOf(ftp.get_UploadTransferRate()) +" }";
                        JSONObject result = new JSONObject(data);

                        PluginResult progressResult = new PluginResult(PluginResult.Status.OK, result);
                        progressResult.setKeepCallback(true);
                        callbackContext.sendPluginResult(progressResult);

                        //  Sleep 1 second.
                        ftp.SleepMs(1000);
                    }

                    //  Did the upload succeed?
                    if (ftp.get_AsyncSuccess() == true) {
                        callbackContext.success(String.valueOf(ftp.get_AsyncSuccess()));
                        Log.i(TAG, "File Uploaded!");
                    }
                    else {
                        //  The error information for asynchronous ops
                        //  is in AsyncLog as opposed to LastErrorText
                        callbackContext.error(ftp.asyncLog());
                        Log.i(TAG, ftp.asyncLog());
                    }
                } catch (JSONException e){

                }
            }
        });

    }

    public void createRemoteDir(String newRemoteDir, CallbackContext callbackContext){
        boolean created = ftp.CreateRemoteDir(newRemoteDir);

        if( created ){
            callbackContext.success(String.valueOf(created));
            Log.i(TAG, "Create New Directory!");
        } else {
            callbackContext.error(String.valueOf(created));
            Log.i(TAG, ftp.lastErrorText());
        }
    }

    public void getRemoteFileSize(String remoteFilename, CallbackContext callbackContext){
        int fileSize = ftp.GetSizeByName(remoteFilename);

        if( fileSize > 0 ){
            callbackContext.success(fileSize);
            Log.i(TAG, "get file size!");
        } else {
            callbackContext.error(fileSize);
            Log.i(TAG, ftp.lastErrorText());
        }
    }

    public void changeRemoteDir(String remoteDir, CallbackContext callbackContext){
        boolean changed = ftp.ChangeRemoteDir(remoteDir);
        if( changed ){
            callbackContext.success(String.valueOf(changed));
            Log.i(TAG, "Change Directory!");
        } else {
            callbackContext.error(String.valueOf(changed));
            Log.i(TAG, ftp.lastErrorText());
        }
    }

    public void deleteRemoteFile(String remoteFilename, CallbackContext callbackContext){
        boolean delete = ftp.DeleteRemoteFile(remoteFilename);
        if( delete ){
            callbackContext.success(String.valueOf(delete));
            Log.i(TAG, "Delete File!");
        } else {
            callbackContext.error(String.valueOf(delete));
            Log.i(TAG, ftp.lastErrorText());
        }
    }

    static {
    	      // Important: Make sure the name passed to loadLibrary matches the shared library
    	      // found in your project's libs/armeabi directory.
    	      //  for "libchilkat.so", pass "chilkat" to loadLibrary
    	      //  for "libchilkatemail.so", pass "chilkatemail" to loadLibrary
    	      //  etc.
    	      //
    	      System.loadLibrary("chilkat");

    	      // Note: If the incorrect library name is passed to System.loadLibrary,
    	      // then you will see the following error message at application startup:
    	      //"The application <your-application-name> has stopped unexpectedly. Please try again."
    }
}