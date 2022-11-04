var SerUrlDomain = "http://shflappsvr.svsglobal.com/BPM_RS/";


function fnCallWebService(serviceFor, prcObject, callback, extParam1, extParam2, extParam3) {
    var jsonData = prcObject;
    try {
        fnShowProgress();
    }
    catch (ex) {
    }
    var SerUrl = "";  
    if (extParam1 == "MULTI") {
        SerUrl = SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService"
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