
var SerLOSUrlDomain;
var UNOServiceURl = "http://uatshrihome.shriramcity.me/SHFLRestServices/UATAddonServices/SoftCell/";

function fnCallLOSWebService(serviceFor, prcObject, callback, extParam1, extParam2, extParam3) {
    SerLOSUrlDomain = getLocalStorage("LosUrl");
    var jsonData = prcObject;
    try {
        fnShowLOSProgress();
    }
    catch (ex) {
    }
    var SerUrl = "";
    debugger;
    if (extParam1 == "MULTI")
        SerUrl = SerLOSUrlDomain + "RestServiceSvc.svc/fnDataAccessService"
    else if (extParam1 == "IP")
        SerUrl = SerLOSUrlDomain + "RestServiceSvc.svc/GetLocalIpAddress"
    else if (extParam1 == "Url")
        SerUrl = SerLOSUrlDomain + "RestServiceSvc.svc/GetServerUrl"
    else if (extParam1 == "GenerateOTP")
        SerUrl = SerLOSUrlDomain + "RestServiceSvc.svc/fnAadharGenerateOTP";
    else if (extParam1 == "AadharDetails")
        SerUrl = SerLOSUrlDomain + "RestServiceSvc.svc/fnGetAadharDetails";
    else if (extParam1 == "SOftCellInput")
        SerUrl = UNOServiceURl + "SoftCellService.svc/GetSoftCellDataLOS";
    else if (extParam1 == "SOftCellResult")
        SerUrl = UNOServiceURl + "SoftCellService.svc/SoftCellAcknowledementLOS";
    else if (extParam1 == "ExecQuery") {
        SerUrl = SerLOSUrlDomain + "RestServiceSvc.svc/fnExecDBQuery";
    }

    $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: SerUrl,
        data: JSON.stringify(jsonData),
        processData: true,
        dataType: "json",
        success: function (data) {
            var obj = null;
            if (extParam1 == "MULTI" || extParam1 == "GenerateOTP" || extParam1 == "AadharDetails")
                obj = JSON.parse(data);
            else
                obj = data;
            try {
                fnRemoveLOSProgress();
            }
            catch (ex) { }

            if (extParam3 != "" && extParam3 != undefined) { if (extParam3.indexOf("false") <= 0) { $("#" + extParam3).removeAttr("disabled"); } }
            callback(serviceFor, obj, extParam1, extParam2, extParam3);
        },
        error: function (data, q, t) {
            console.log(serviceFor + "," + data);
            console.log('Error: ', data);
            
            try {
                SoftCellDownload()
            }
            catch (e) { }
        }
    });
}

function fnCallLOSCommonWebService(serviceFor, data, callback, extParam1, extParam2) {
    SerLOSUrlDomain = getLocalStorage("LosUrl");
    try {
        fnShowLOSProgress();
    }
    catch (ex) {
    }
    $.ajax({
        url: SerLOSUrlDomain + "CommonHandler.ashx?Typ=" + extParam1,
        type: "POST",
        data: data,
        contentType: false,
        processData: false,
        success: function (result) {
            try {
                fnRemoveLOSProgress();
            }
            catch (ex) { }
            callback(serviceFor, result, extParam1, extParam2);
        },
        error: function (err) {
            console.log(err);
        }
    });

}

function fnShowLOSProgress() {
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

function fnRemoveLOSProgress() {
    $("#modalProgess").remove();
}

function fnLosCallFileUploadService(serviceFor, formData, callback, extParam1, extParam2, callback_2) {
    SerLOSUrlDomain = getLocalStorage("LosUrl");
    try {
        var URL = SerLOSUrlDomain + "FileUploadHandler.ashx";
        try {
            fnShowLOSProgress();
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
                    fnRemoveLOSProgress();
                    if (JSON.parse(result).status == false) {
                        alert(JSON.parse(result).error);
                    }
                }
                catch (ex) { }
                callback(serviceFor, result, extParam1, extParam2);
            },
            error: function (err) {
                fnRemoveLOSProgress();
                alert(err.statusText)
                console.log(err);
            }
        });
    }
    catch (e) {
        alert(e)
    }
}