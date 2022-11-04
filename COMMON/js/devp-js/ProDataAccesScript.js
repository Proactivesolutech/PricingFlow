
var SerUrlDomain;
var ScanSerUrlDomain = "";

function fnCallWebService(serviceFor, prcObject, callback, extParam1, extParam2, extParam3) {

    SerUrlDomain = getLocalStorage("BpmUrl");
    var jsonData = prcObject;
    try {
        fnShowProgress();
    }
    catch (ex) {
    }
    var SerUrl = "";  
    if (extParam1 == "MULTI") {
        SerUrl = SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService";
    }
    if (extParam1 == "FOLDER") {
        SerUrl = ScanSerUrlDomain + "RestServiceSvc.svc/fnCreateFolder";
    }
    if (!jsonData.ConnString) { jsonData.ConnString = ""; }
    $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: SerUrl,
        data: JSON.stringify(jsonData),
        processData: true,
        dataType: "json",
        success: function (data) {
            var obj = null;
            if (extParam1 == "MULTI")
                obj = JSON.parse(data);
            else
                obj = data;

            try {
                fnRemoveProgress();
            }
            catch (ex) { }

            if (extParam3 != "" && extParam3 != undefined) { if (extParam3.indexOf("false") <= 0) { $("#" + extParam3).removeAttr("disabled"); } }
            callback(serviceFor, obj, extParam1, extParam2, extParam3);
        },
        error: function (data, q, t) {
            console.log('Error: ', data);            
        }
    });
}

function fnShowProgress() {
    var body = $(this.ie6 ? document.body : document);
    var width = body.width();
    var height = body.height();

    var xModalDiv = $("<div id='modalProgess'><img style='position:fixed; top:40%; left:46%;' src='../common/assets/images/ajax-loader.gif'/>'</div>");
    xModalDiv.css({
        'position': 'absolute',
        'top': 0,
        'left': 0,
        'opacity': '0.5',
        'z-index': '1000',
        'width': width,
        'height': height,
        'text-align': 'center',
        'vartical-aign': 'middle',
        'background-color': '#FFF'
    });
    xModalDiv.remove();
    xModalDiv.appendTo("body");
}

function fnRemoveProgress() {
    $("#modalProgess").remove();
}



function fnCallFileUploadService(serviceFor, formData, callback, extParam1, extParam2, callback_2) {
    SerUrlDomain = getLocalStorage("BpmUrl");
    try {
        var URL = SerUrlDomain + "FileUploadHandler.ashx";
        try {
            fnShowProgress();
        }
        catch (ex) {
        }
        $.ajax({
            url: URL,
            type: "POST",
            data: formData,
            contentType: false,
            processData: false,           
            success: function (result) {
                try {
                    fnRemoveProgress();
                    if (JSON.parse(result).status == false) {
                        alert(JSON.parse(result).error);
                    }
                }
                catch (ex) { }
                callback(serviceFor, result, extParam1, extParam2);
            },
            error: function (err) {
                fnRemoveProgress();
                alert(err.statusText)
                console.log(err);
            }
        });
    }
    catch (e) {
        alert(e)
    }
}