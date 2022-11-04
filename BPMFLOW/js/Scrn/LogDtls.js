var LgIpDynAdd = '', LgIpDynAddServ = '', LgIpMcAdd = '', LgLatitude = '', LgLongitude = '', LgArea = '', LgCity = '', LgState = '', LgCountry = '';
var LgGlgeLatitude = '', LgGlgeLongitude = '', LgGlgeArea = '', LgGlgeCity = '', LgGlgeState = '', LgGlgeCountry = '', LgClientLoc = '';
var GooLat = '', GooLng = '', GooArea = '', GooCity = '', GooState = '', GooCountry = '', GooZipCode = '';
var LogJson = [{}];

$(document).ready(function () {
    initialize(); // GeoLocations.
    fngetLocalIP(); // Get Local IP
    GetServerUrl(); // Accessing Server URL.
    getUserMacIpAddress(); // Get Server IP Address.
});

// Accessing Server URL.
function GetServerUrl() {
    fnCallLOSWebService("Get_Server_Url", '', fnLogJSResult, "Url", '')
}

// Get Server IP Address.
function getUserMacIpAddress() {
    fnCallLOSWebService("UserMacIp", '', fnLogJSResult, "IP", '')
}

// GeoLocations.
function initialize() {
    if (window.navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (position) {
            var lat = position.coords.latitude;
            lng = position.coords.longitude; LgGlgeLatitude = lat; LgGlgeLongitude = lng;
            latlng = new google.maps.LatLng(lat, lng);
            geocoder = new google.maps.Geocoder();
            geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    if (results[0]) {
                        LgGlgeArea = results[0].formatted_address;
                    }
                    if (results[1]) {
                        for (var i = 0; i < results.length; i++) {
                            if (results[i].types[0] === "locality") {
                                LgGlgeCity = results[i].address_components[0].long_name;
                                LgGlgeState = results[i].address_components[2].long_name;
                                LgGlgeCountry = results[i].address_components[3].long_name;
                            }
                        }
                    }
                    else { console.log("No reverse geocode results.") }
                }
                else { console.log("Geocoder failed: " + status) }
            });
        },
        function () { console.log("Geolocation not available.") });
    }
}

// Get Local IP
function fngetLocalIP() {
    try {
        var RTCPeerConnection = window.webkitRTCPeerConnection || window.mozRTCPeerConnection;
        if (RTCPeerConnection) (function () {
            var rtc = new RTCPeerConnection({ iceServers: [] });
            if (1 || window.mozRTCPeerConnection) {
                rtc.createDataChannel('', { reliable: false });
            };

            rtc.onicecandidate = function (evt) {
                if (evt.candidate) grepSDP("a=" + evt.candidate.candidate);
            };
            rtc.createOffer(function (offerDesc) {
                grepSDP(offerDesc.sdp);
                rtc.setLocalDescription(offerDesc);
            }, function (e) { console.warn("offer failed", e); });


            var addrs = Object.create(null);
            addrs["0.0.0.0"] = false;
            function updateDisplay(newAddr) {
                if (newAddr in addrs) return;
                else addrs[newAddr] = true;
                var displayAddrs = Object.keys(addrs).filter(function (k) { return addrs[k]; });
                LgIpDynAdd = displayAddrs.join(" or perhaps ") || "n/a";
                LogJson[0].LgIpDynAdd = LgIpDynAdd;
            }

            function grepSDP(sdp) {
                var hosts = [];
                sdp.split('\r\n').forEach(function (line) {
                    if (~line.indexOf("a=candidate")) {
                        var parts = line.split(' '),
                            addr = parts[4],
                            type = parts[7];
                        if (type === 'host') updateDisplay(addr);
                    } else if (~line.indexOf("c=")) {
                        var parts = line.split(' '),
                            addr = parts[2];
                        updateDisplay(addr);
                    }
                });
            }
        })();
    } catch (ex) { }
}

/*** Common Functions Starts  ******/
function getBrowserName() {
    try {
        var browserName = navigator.appName;
        var nAgt = navigator.userAgent;
        var nameOffset, verOffset;
        if ((verOffset = nAgt.indexOf("Opera")) != -1) {
            browserName = "Opera";
            fullVersion = nAgt.substring(verOffset + 6);
            if ((verOffset = nAgt.indexOf("Version")) != -1)
                fullVersion = nAgt.substring(verOffset + 8);
        }
        else if ((verOffset = nAgt.indexOf("MSIE")) != -1) {
            browserName = "Microsoft Internet Explorer";
            fullVersion = nAgt.substring(verOffset + 5);
        }
        else if ((verOffset = nAgt.indexOf("Chrome")) != -1) {
            browserName = "Chrome";
            fullVersion = nAgt.substring(verOffset + 7);
        }
        else if ((verOffset = nAgt.indexOf("Safari")) != -1) {
            browserName = "Safari";
            fullVersion = nAgt.substring(verOffset + 7);
            if ((verOffset = nAgt.indexOf("Version")) != -1)
                fullVersion = nAgt.substring(verOffset + 8);
        }
        else if ((verOffset = nAgt.indexOf("Firefox")) != -1) {
            browserName = "Firefox";
        }
        else if ((nameOffset = nAgt.lastIndexOf(' ') + 1) < (verOffset = nAgt.lastIndexOf('/'))) {
            browserName = nAgt.substring(nameOffset, verOffset);
            fullVersion = nAgt.substring(verOffset + 1);
            if (browserName.toLowerCase() == browserName.toUpperCase()) {
                browserName = navigator.appName;
            }
        }
        return browserName + "-" + fullVersion;
    } catch (ex) { return ''; }
}

function AccessDevice() {
    try {
        if (typeof window.orientation == 'undefined') {
            return 1;//browser
        }
    } catch (ex) { return '' }
}

function getUserDetails(LgIpMcAdd) {
    //alert('https://freegeoip.net/json/' + LgIpMcAdd);

    try {
        $.getJSON('https://freegeoip.net/json/' + LgIpMcAdd, function (json) {
            LgCountry = json.country_name;
            LgState = json.region_name;
            LgCity = json.city;
            LgLatitude = json.latitude;
            LgLongitude = json.longitude;
            LgArea = json.zip_code;
            fnSetLogJsonValues();
        })
    }
    catch (ex) { }
}
/*** Common Functions Ends  ******/

/*** Call Back Functions Starts  ******/
function fnLogJSResult(servDesc, Obj, param1, param2) {

    if (servDesc == "UserMacIp") {
        LgIpMcAdd = Obj;
        getUserDetails(LgIpMcAdd);
    }
    else if (servDesc == "Get_Server_Url") {
        setLocalStorage("ServerUrl", Obj);
    }
}
/*** Call Back Functions Ends  ******/

function fnSetLogJsonValues() {

    LogJson[0].LgUsr = "";

    LogJson[0].LgTrsTyp = 0;
    LogJson[0].LgIpMcAdd = LgIpMcAdd;
    LogJson[0].LgMobRDesk = AccessDevice();
    LogJson[0].LgBrowser = getBrowserName();
    LogJson[0].RLgLatitude = LgGlgeLatitude == '' ? LgLatitude : LgGlgeLatitude;
    LogJson[0].RLgLongitude = LgGlgeLongitude == '' ? LgLongitude : LgGlgeLongitude;
    LogJson[0].RLgArea = LgGlgeArea == '' ? LgArea : LgGlgeArea;
    LogJson[0].RLgCity = LgGlgeCity == '' ? LgCity : LgGlgeCity;
    LogJson[0].RLgState = LgGlgeState == '' ? LgState : LgGlgeState;
    LogJson[0].RLgCountry = LgGlgeCountry == '' ? LgCountry : LgGlgeCountry;

}