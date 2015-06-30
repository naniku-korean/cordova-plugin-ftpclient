/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');

    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();

// type -> video, image
var fileTransfer = function( type ){
    var $log = $('#log');
    var success = function(data) {
        var text = $log.text();
        $log.text(text+JSON.stringify(data)+"\n");
    };

    var failure = function(message) {
        console.log(message);
        console.log("Error calling Hello Plugin");
        var text = $log.text();

        $log.text(text+JSON.stringify(message)+"\n")
    };

    ftpclient.keySetting(undefined, undefined, "");
    ftpclient.connect(success, failure, "183.111.29.3", "admin", "@qltkdgkfkekqlscl", true);
    ftpclient.changeRemoteDir(success, failure, "davinci");
    var data;
    if( type === 'video' ){
        data = $('#video').attr('src');
    } else {
        data = $('#img').attr('src');
    }

    data = ".."+data;
    if( data !== undefined ){
        ftpclient.asyncPutFile(success, failure, data, "test.mp4");
    }
};

var getMediaData = function( type ){
    var pictureOpt = {
        destinationType: Camera.DestinationType.FILE_URI,
        quality : 50,
        sourceType : Camera.PictureSourceType.PHOTOLIBRARY,
        mediaType: (type === 'video')? Camera.MediaType.VIDEO : Camera.MediaType.PICTURE
    };
    function onSuccess(imageData){
        var photo_split, reImageData;
        if (imageData.substring(0,21)=="content://com.android") {
            photo_split=imageData.split("%3A");
            reImageData="content://media/external/images/media/"+photo_split[1];
        } else {
            reImageData = imageData;
        }

        ftpclient.getPathFromMediaUri(function(data) {
            var text = $('#log').text();
            $('#log').text(text+JSON.stringify(data)+"\n");
            $('#'+type).attr('src', data);
            fileTransfer(type);

        }, function(data) {
            var text = $('#log').text();
            $('#log').text(text+JSON.stringify(data)+"\n");

        }, reImageData);

    }
    function onError(){
        console.log(arguments);
    }
    navigator.camera.getPicture(onSuccess, onError, pictureOpt);
};

$('button').on('click', function(e){
    var id = e.target.id;

    switch( id ){
        case "con":
            getMediaData('video');
            break;
        case "chooser":
            getMediaData('img');
            break;
    }

});