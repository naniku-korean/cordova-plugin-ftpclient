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
var fileTransfer = function( datas ){
    var $log = $('#log');
    var index = 0;
    var success = function(data) {
        console.log(data);
        var text = $log.text();
        $log.text(text+JSON.stringify(data)+"\n");
        if( data.value === "true"){
            var data;
            if( index < datas.length ){
                data = datas[index];
                var filename = data.substr(data.lastIndexOf('/')+1);
                if( data !== undefined ){
                    ftpclient.asyncPutFile(success, failure, data, encodeURIComponent(filename));
                    index += 1;
                }
            }
        }
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

    if( datas[0] !== undefined ){
        var filename = datas[0].substr(datas[0].lastIndexOf('/')+1);
        ftpclient.asyncPutFile(success, failure, datas[0], filename);
        index += 1;
    }

};

var getMediaData = function(type){
    var pictureOpt = {
        destinationType: Camera.DestinationType.FILE_URI,
        quality : 50,
        sourceType : Camera.PictureSourceType.PHOTOLIBRARY,
        mediaType: (type === 'video')? Camera.MediaType.VIDEO:Camera.MediaType.PICTURE
    };

    function onSuccess(data){
        var photo_split, rename;

        if (data.substring(0,21)=="content://com.android") {
            photo_split=data.split("%3A");
            rename="content://media/external/images/media/"+photo_split[1];
        } else {
            rename = data;
        }

        ftpclient.getPathFromMediaUri(function(data) {
            var listdata = $("#collapse").find('ul').listview('option', 'data');

            if( listdata === null ) {
                listdata = [];
            }
            listdata.push(data);
            var filename = data.substr(data.lastIndexOf('/')+1);
            $('#collapse').find('ul').append('<li><a herf="#">'+filename+'</a></li>');

            // set list data
            $("#collapse").find('ul').listview('option', 'data', listdata);

        }, function(data) {
            alert(JSON.stringify(data));
        }, rename);
    }
    function onError(){
        console.log(arguments);
    }

    navigator.camera.getPicture(onSuccess, onError, pictureOpt);

};

$('#select_v').on('click', function(e){
    getMediaData('video');
    return  false;
});

$('#select_i').on('click', function(e){
    getMediaData('img');
    return  false;
});

$('#send').on('click', function(e){
    var datas = $("#collapse").find('ul').listview('option', 'data');
    fileTransfer(datas);
    $('#log').scrollTop($('#log')[0].scrollHeight);
    return false;
});