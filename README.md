# cordova-plugin-ftpclient
cordova plugin ftpclient

##FTP Client 
	
	window.ftpclient   //cordova interface ftp object
	var success = function( data ){
		console.log( data );
	}
	
	var failure = function( data ){
		console.log( data );
	}
	

###Function
- __keySetting__:  Chilkat library 라이센스 등록 (사용하기전 먼저 실행해야 한다.) 'ftpclient.keySetting(success, failure, key);'.
	>Quick Example
	
		ftpclient.keySetting(success, failure, "Anything for 30-day trial");

- __connect__: FTP 서버 접속 `ftpclient.connect(success, failure, host, username, password, restartNext);`
	-  reasons
		- '0' success
        - '1' = empty hostname
        - '2' = DNS lookup failed
        - '3' = DNS timeout
        - '4' = Aborted by application.
        - '5' = Internal failure.
        - '6' = Connect Timed Out
        - '7' = Connect Rejected (or failed for some other reason)        
        - '100' = Internal schannel error
        - '101' = Failed to create credentials
        - '102' = Failed to send initial message to proxy.
        - '103'= Handshake failed.
        - '104' = Failed to obtain remote certificate.
        - '300' = asynch op in progress
        - '301' = login failure.
		
	> Quick Example
	
		ftpclient.connect(success, failure, "112.169.59.106", "*****", "*****", true);

- __asyncPutFile__: FTP 서버로 파일 전송 `ftpclient.asyncPutFile(success, failure, localFile, remoteFileName);`
	-  전송 중인 경우: 'sendByte(전송량), transferRate(전송률)' <type:object>
	-  전송 완료 경우: 'true'
	-  전송 실패 경우: 'false'
	> Quick Example
	
		 ftpclient.asyncPutFile(success, failure, "../storage/emulated/0/DCIM/Camera/20150617_141616.mp4", "test.mp4");

- __getRemoteFileSize__: FTP 서버 파일 크기`ftpclient.getRemoteFileSize(success, failure, remoteFileName);`
	-	파일이 있는 경우: '00000000' <byte 단위>
	-	파일이 없는 경우: '-1'
	> Quick Example
	
		 ftpclient.getRemoteFileSize(success, failure, "test.mp4");

- __changeRemoteDir__: FTP 서버 폴더 이동 `ftpclient.changeRemoteDir(success, failure, remoteDir);` 
	-	폴더가 있는 경우:  'true'
	-	폴더가 없는 경우:  'faslse'
	> Quick Example
	
		 ftpclient.changeRemoteDir(success, failure, "0000");

- __createRemoteDir__: FTP 서버 폴더 생성 `ftpclient.createRemoteDir(success, failure, remoteDir);`
	-	폴더 생성: 'true'
	-	폴더가 생성되지 않으면: 'false'
	> Quick Example
	
		 ftpclient.createRemoteDir(success, failure, "niku");
	
- __deleteRemoteFile__: FTP 서버 파일 삭제 `ftpclient.deleteRemoteFile(success, failure, remoteFileName);`
	-	파일이 삭제된 경우: 'true'
	-	파일이 없어 삭제가 불가한 경우 : 'false'
	> Quick Example
	
		 ftpclient.deleteRemoteFile(success, failure, "config.xml");

## Installation

    cordova plugin add https://github.com/naniku-korean/cordova-plugin-ftpclient
	
	
## Delete
	
	cordova plugin remove ftp_client
	