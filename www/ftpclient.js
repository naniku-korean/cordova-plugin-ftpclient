/*global cordova, module*/

module.exports = {
    connect: function (successCallback, errorCallback, host, user, password, restartNext) {

        var arg = [ host, user, password, restartNext];

        cordova.exec(successCallback, errorCallback, "ftpClient", "connect", arg);
    },

    asyncPutFile: function (successCallback, errorCallback, local, remote) {

        var arg = [ local, remote ];
        cordova.exec(successCallback, errorCallback, "ftpClient", "asyncPutFile", arg);
    },

    getRemoteFileSize: function(successCallback, errorCallback, remoteFileName){
        var arg = [ remoteFileName ];
        cordova.exec(successCallback, errorCallback, "ftpClient", "getRemoteFileSize", arg);
    },

    changeRemoteDir: function(successCallback, errorCallback, remoteDir){
        var arg = [ remoteDir ];
        cordova.exec(successCallback, errorCallback, "ftpClient", "changeRemoteDir", arg);
    },

    createRemoteDir: function(successCallback, errorCallback, remoteNewDir){
        var arg = [ remoteNewDir ];
        cordova.exec(successCallback, errorCallback, "ftpClient", "createRemoteDir", arg);
    },

    deleteRemoteFile: function(successCallback, errorCallback, remoteFileName){
        var arg = [ remoteFileName ];
        cordova.exec(successCallback, errorCallback, "ftpClient", "deleteRemoteFile", arg);
    },

    keySetting: function(successCallback, errorCallback, key){
        var arg = [ key ];
        cordova.exec(successCallback, errorCallback, "ftpClient", "keySetting", arg);
    },

    disconnect: function(successCallback, errorCallback){
        var arg = [];
        cordova.exec(successCallback, errorCallback, "ftpClient", "disconnect", arg);
    }
};
