
// JavaScript source code
isAuth = false;
$(document).ready(function () {
    calcHeight(); //Viewport Height Function Starts
    commontabs(); //Common tab style
    querypopup();
    rightdocument(); /*Document Popup*/
    popupclose(); /*close popup function*/


    $(document).keypress(function (e) {
        if ($(".master-screens").length > 0) {
            debugger;
            var letter = e.key;
            if (letter == "u") { fnOpenScreen("U") }
            if (letter == "r") { fnOpenScreen("R") }
            if (letter == "b") { fnOpenScreen("BR") }
            if (letter == "g") { fnOpenScreen("MAP") }
            if (letter == "m") { fnOpenScreen("BL") }
            if (letter == "i") { fnOpenScreen("IM") }
            if (letter == "q") {
                //if (isAuth == true) fnOpenScreen("Q")
                fnOpenScreen("Q");
            }
            if (letter == "f") { fnOpenScreen("F") }
        }
    });

});


function fnOpenScreen(type) {
    if (type == "U") {
        LoadHtmlDiv('../Users/UserMas.html?$$$v=1.0.0$$$')
    }
    else if (type == "R") {
        LoadHtmlDiv('../Users/RoleMas.html?$$$v=1.0.0$$$')
    }
    else if (type == "BR") {
        LoadHtmlDiv('../Users/GeoMas.html?$$$v=1.0.0$$$')
    }
    else if (type == "MAP") {
        LoadHtmlDiv('../Users/GeoMapMas.html?$$$v=1.0.0$$$')
    }
    else if (type == "BL") {
        LoadHtmlDiv('../Masters/buildermas.html?$$$v=1.0.0$$$')
    }
    else if (type == "IM") {
        LoadHtmlDiv('../Masters/Insurar.html?$$$v=1.0.0$$$')
    }
    else if (type == "Q") {
        LoadHtmlDiv('../Masters/ExecQuery.html?$$$v=1.0.0$$$')
    }
    else if (type == "F") {
        LoadHtmlDiv('../Masters/FileMgr.html?$$$v=1.0.0$$$')
    }
}

function fnchangeAuthentication() {
    isAuth = true;
}