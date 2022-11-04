window.CustomElements = {};
window.CustomElements.List = [];

window.COMP_SCAN = {};
/* TIFF CODE */

COMP_SCAN._readyFn = [];
COMP_SCAN.CompReady = function (sel, fn) {
    var Obj = { selector: sel, fn: fn };
    COMP_SCAN._readyFn.push(Obj);
    if ($(sel).length > 0 && $(sel).html() != "") {
        fn();
    }
}

COMP_SCAN.fnShowProgress = function (selector) {
    selector = selector ? selector : "#scan_ImagePrw";
    var imagePrw = LoadingSCANElem.querySelector(selector);
    if (imagePrw != undefined && imagePrw != null) {
        if (imagePrw.hasOwnProperty("length") || imagePrw.selector)
            imagePrw = imagePrw[0];
    }
    var width = $(imagePrw).width();
    var height = $(imagePrw).height();
    var xModalDiv = $("<div id='scan_modalProgess'><h1 style='position:relative;font-size:13px;top:50%;color:#000;'>Processing your Request...</h1></div>");
    xModalDiv.css({
        'position': 'absolute',
        'top': 0,
        'left': 0,
        'z-index': '999999999999',
        'width': width,
        'height': height,
        'text-align': 'center',
        'vartical-aign': 'middle'
    });
    xModalDiv.remove();
    xModalDiv.appendTo(imagePrw);
}

COMP_SCAN.fnRemoveProgress = function () {
    $("#scan_modalProgess").remove();
}





/* PDF PART - START */

COMP_SCAN.PDFCANVAS = [];
COMP_SCAN.PDFTASK = [];

COMP_SCAN.convertDataURIToBinary = function (dataURI) {
    var BASE64_MARKER = ';base64,';
    var base64Index = dataURI.indexOf(BASE64_MARKER) + BASE64_MARKER.length;
    var base64 = dataURI.substring(base64Index);
    var raw = window.atob(base64);
    var rawLength = raw.length;
    var array = new Uint8Array(new ArrayBuffer(rawLength));

    for (var i = 0; i < rawLength; i++) {
        array[i] = raw.charCodeAt(i);
    }
    return array;
}


COMP_SCAN.fnLoadPdf = function (PDFbase64) {
    try {
        COMP_SCAN.fnShowProgress("#scan_ImagePrw");
        var dataUrl = "data:application/pdf;base64," + PDFbase64;
        var pdfAsArray = COMP_SCAN.convertDataURIToBinary(dataUrl);
        COMP_SCAN.fnPdfGetDocument(pdfAsArray);
    }
    catch (e) {
        COMP_SCAN.fnRemoveProgress();
        COMP_SCAN.fnErrorMsg(LoadingSCANElem, "Invalid PDF");
        console.log(e);
    }
}

if (PDFJS)
    PDFJS.disableWorker = true;
else
    console.log("PDF JS not loaded");

COMP_SCAN.fnPdfGetDocument = function (fileReader) {
    try {
        pdfPage = [];
        PDFJS.getDocument(fileReader).then(function getPdfHelloWorld(pdf) {
            var cnt = 0;
            var canvascnt = 0;
            $(".pdfcanvas").remove();
            for (var i = 1; i <= pdf.numPages; i++) {
                pdf.getPage(i).then(function getPageHelloWorld(page) {

                    var scale = 1.5;
                    var viewport = page.getViewport(scale);
                    COMP_SCAN.PDFCANVAS[canvascnt] = document.createElement('canvas');
                    COMP_SCAN.PDFCANVAS[canvascnt].className = "pdfcanvas";
                    COMP_SCAN.PDFCANVAS[canvascnt].style.display = "none";
                    var context = COMP_SCAN.PDFCANVAS[canvascnt].getContext('2d');
                    COMP_SCAN.PDFCANVAS[canvascnt].height = viewport.height;
                    COMP_SCAN.PDFCANVAS[canvascnt].width = viewport.width;
                    document.body.appendChild(COMP_SCAN.PDFCANVAS[canvascnt]);
                    COMP_SCAN.PDFTASK[canvascnt] = page.render({ canvasContext: context, viewport: viewport });

                    COMP_SCAN.PDFTASK[canvascnt].promise.then(function () {
                        cnt++;
                        if (cnt == COMP_SCAN.PDFCANVAS.length) {
                            var PDFcanList = $("canvas.pdfcanvas");
                            var arr = [];
                            PDFcanList.each(function () {
                                var img = this.toDataURL();
                                img = img.replace("data:image/jpg;base64,", "");
                                img = img.replace("data:image/jpeg;base64,", "");
                                img = img.replace("data:image/png;base64,", "");
                                var obj = { id: "", src: img };
                                arr.push(obj);
                            });
                            $(LoadingSCANElem).setImages({ id: "", src: arr }, true, true);
                            $(".pdfcanvas").remove();                            
                            COMP_SCAN.fnRemoveProgress();
                            console.clear();
                            console.log("PDF Conversion Completed.");
                        }
                    });
                    canvascnt++;
                    /*
                    pdfPage.push(page);
                    if (pdfPage.length == pdf.numPages) {
                        COMP_SCAN.fnCreatePdfPage();
                    }
                    */
                });
            }
        }, function (error) {
            COMP_SCAN.fnRemoveProgress();
            COMP_SCAN.fnErrorMsg(LoadingSCANElem, "Invalid PDF");
            console.log(error);
        });
    }
    catch (e) {
        COMP_SCAN.fnRemoveProgress();
        COMP_SCAN.fnErrorMsg(LoadingSCANElem, "Error in getting image from pdf document.");
    }
}


COMP_SCAN.fnCreatePdfPage = function () {
    try {
        COMP_SCAN.PDFCANVAS = [];
        COMP_SCAN.PDFTASK = []
        var cnt = 0;
        for (var i = 0; i < pdfPage.length; i++) {
            var scale = 1.5;
            var viewport = pdfPage[i].getViewport(scale);
            COMP_SCAN.PDFCANVAS[i] = document.createElement('canvas');
            COMP_SCAN.PDFCANVAS[i].id = "pdfcanvas_" + i;
            COMP_SCAN.PDFCANVAS[i].className = "pdfcanvas";
            var context = COMP_SCAN.PDFCANVAS[i].getContext('2d');
            COMP_SCAN.PDFCANVAS[i].height = viewport.height;
            COMP_SCAN.PDFCANVAS[i].width = viewport.width;
            COMP_SCAN.PDFTASK[i] = pdfPage[i].render({ canvasContext: context, viewport: viewport });

            COMP_SCAN.PDFTASK[i].promise.then(function () {
                COMP_SCAN.fnPDFCallBack(COMP_SCAN.PDFCANVAS[cnt], cnt);
                cnt++;
            });
        }
    }
    catch (e) {
        COMP_SCAN.fnRemoveProgress();
        COMP_SCAN.fnErrorMsg(LoadingSCANElem, "Error in getting image from pdf document.");
        console.log(e);
    }
}


COMP_SCAN.fnPDFCallBack = function (pdfObj, i) {
    console.log(pdfObj);
    console.log(i)
};

/* PDF PART - END */


//COMP_SCAN.SerUrlDomain = "http://shflappsvr.svsglobal.com/SHFLLOS_SCAN_RS/";
COMP_SCAN.SerUrlDomain = "http://shflappsvr.svsglobal.com/LOS_RS/";

var callcount = 0;

COMP_SCAN.fnTiff2Base64 = function (serviceFor, ImagePath, Limit, CallBack, ExtParam) {
    var formObj = { receivedImages: "0", previewFile: ImagePath, Imglimit: Limit };
    COMP_SCAN.fnCallScanService(serviceFor, formObj, CallBack, "TIFFPRW", ExtParam, "");
}


COMP_SCAN.fnFileHandler = function (serviceFor, data, callback, extParam1, extParam2, extParam3) {
    try {
        var URL = "";
        URL = COMP_SCAN.SerUrlDomain + "FileManager_Handler.ashx";
        try {
            COMP_SCAN.fnShowProgress("#scan_ImagePrw");
        }
        catch (ex) {
        }
        $.ajax({
            url: URL,
            type: "POST",
            data: data,
            contentType: false,
            processData: false,
            success: function (result) {
                try {
                    COMP_SCAN.fnRemoveProgress();
                    if (JSON.parse(result).status == false) {
                        alert("Error Processing Request!!");
                        console.log(JSON.parse(result).error);
                    }
                }
                catch (ex) { }
                if (serviceFor == "PDF_PREVIEW") { callback(serviceFor, result, extParam1, extParam2); }
                else {
                    var data = JSON.parse(JSON.parse(result).result);
                    data = JSON.parse(JSON.stringify(data).replace(/Base64/g, "src"));
                    callback(serviceFor, data, extParam1, extParam2);
                }
            },
            error: function (err) {
                //alert(err.statusText)
                alert("Request Error!!");
                console.log(err);
            }
        });
    }
    catch (e) {
        alert(e)
    }
}

COMP_SCAN.fnCallScanService = function (serviceFor, prcObject, callback, extParam1, extParam2, extParam3) {
    try { COMP_SCAN.fnShowProgress("#scan_ImagePrw"); }
    catch (e) { }
    var jsonData = null;
    var SerUrl = "";
    if (extParam1 == "TEXT") {
        jsonData = prcObject
        SerUrl = COMP_SCAN.SerUrlDomain + "FileManager_Handler.ashx";
    }
    else if (extParam1 == "SAVE_DOC_DB") {
        jsonData = JSON.stringify(prcObject);
        SerUrl = COMP_SCAN.SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService";
    }
    else {
        jsonData = JSON.stringify(prcObject);
        SerUrl = COMP_SCAN.SerUrlDomain + "RestServiceSvc.svc/fnTiffImagePreview";
    }
    $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        url: SerUrl,
        data: jsonData,
        processData: true,
        async: true,
        //crossDomain: true,
        success: function (data) {
            callcount++;
            console.log(callcount + " times called");
            try { COMP_SCAN.fnRemoveProgress(); }
            catch (e) { }
            if (extParam1 == "TIFFPRW") {
                var result = data;
                if (JSON.parse(result).status == false) {
                    alert("Error Processing Request!!");
                    console.log(JSON.parse(result).error);
                }
                if (JSON.parse(result).status == true) {
                    var Obj = JSON.parse(result);
                    var Imgdata = JSON.parse(Obj.result);
                    extParam3 = $.merge(extParam3 == "" ? [] : extParam3, Imgdata);
                    if (JSON.parse(result).isFinished == true || JSON.parse(result).pageCount == extParam3.length) {
                        callback(serviceFor, extParam3, extParam1, extParam2, "");
                        callcount = 0;
                    } else {
                        extParam3 = extParam3 == "" ? [] : extParam3
                        prcObject.receivedImages = extParam3.length;
                        COMP_SCAN.fnCallScanService(serviceFor, prcObject, callback, extParam1, extParam2, extParam3);
                    }
                }

            }
            else {
                callback(serviceFor, data, extParam1, extParam2, "");
            }
        },
        error: function (data, q, t) {
            COMP_SCAN.fnRemoveProgress();
            alert("funtion error")
            console.log('Error: ', data);
        }
    });
}


/* TIFF CODE */
COMP_SCAN.fnAllowNumber = function (evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
};

COMP_SCAN.fnUploadCallBack = function (serviceFor, Result, extParam1, extParam2, extParam3) {
    if (serviceFor == "SAVE_SELECTED_PAGEWISE") {
        var data = JSON.parse(JSON.parse(Result).result);
        if (data == null || data == undefined && data.length == 0) {
            return;
        }
        var query = "";
        for (var i = 0; i < data.length; i++) {
            var scancomp = LoadingSCANElem;
            if (scancomp != undefined && scancomp != null) {
                if (scancomp.hasOwnProperty("length") || scancomp.selector)
                    scancomp = scancomp[0];
            }
            var UlList = scancomp.querySelectorAll(".scan_right-scan ul");
            var ul = $(UlList[i]);
            var DocAct = ul.find(".scan_AplTyp").val();
            
            var DocActSubNo = ul.find(".scan_AplTypSub").val();

            var DocCat = ul.find(".scan_DocGrp").val();            
            var DocSubCat = ul.find(".scan_DocTyp").val();
            var DocNm = ul.find(".scan_DocNm").val();
            var DocPath = data[i];
            var leadFk = scancomp.LeadFk;
            var DocAgtNm = scancomp.DocAgtNm;
            var DocAgtPk = scancomp.DocAgtPk;
            var DocBGeoFk = scancomp.DocBGeoFk;
            var DocPrdFk = scancomp.DocPrdFk;
            var createdBy = "";
            var ModifiedBy = "";
            var createdDt = new Date();
            var ModifiedDt = new Date();
            if (DocPath && DocPath != 'null' && DocPath != undefined) {
                query += " INSERT INTO LosDocument(DocLedFk,DocAgtFk,DocBGeoFk,DocPrdFk,DocActor,DocSubActor,DocCat,DocSubCat,DocNm,DocPath,DocRowId,DocCreatedBy," +
                    "DocCreatedDt,DocModifiedBy,DocModifiedDt,DocDelFlg,DocDelId,DocPGrpFk) SELECT '" + leadFk + "','" + DocAgtPk + "','" + DocBGeoFk + "',NULL,'" + DocAct + "','" + DocActSubNo + "'," +
                    "'" + DocCat + "','" + DocSubCat + "','" + DocNm + "','" + DocPath + "',NEWID(),'" + createdBy + "',GETDATE(),'" + ModifiedBy + "',GETDATE(),0,0,'" + DocPrdFk + "' WHERE NOT EXISTS (SELECT 'X' FROM LosDocument (NOLOCK) WHERE DocPath='" + DocPath + "' AND DocLedFk = " + leadFk + " AND DocDelId=0 ); ";
            }
        }
        if (query == "")
            return;
        var obj = { ProcedureName: "$Query", Type: "T", QryTxt: query, Parameters: [query] };
        COMP_SCAN.fnCallScanService("SAVE_DOC_DB", obj, COMP_SCAN.fnTiffCallBack, "SAVE_DOC_DB", "", "");
    }
}


COMP_SCAN.fnCallFileUpload = function (serviceFor, data, callback, extParam1, extParam2) {

    //    COMP_SCAN_FILE.SerUrlDomain = "http://192.169.1.92/SHFLLOS_SCAN_RS/";    
    try {
        var URL = "";
        if (serviceFor == "UploadForm")
            URL = COMP_SCAN.SerUrlDomain + "FileUploadHandler.ashx";
        else
            URL = COMP_SCAN.SerUrlDomain + "FileManager_Handler.ashx";
        try {
            COMP_SCAN.fnShowProgress("#scan_ImagePrw");
        }
        catch (ex) {
        }
        $.ajax({
            url: URL,
            type: "POST",
            data: data,
            contentType: false,
            processData: false,
            async: true,
            success: function (result) {
                try {
                    COMP_SCAN.fnRemoveProgress();
                    if (JSON.parse(result).status == false) {
                        alert("Error Processing Request!!");
                        console.log(JSON.parse(result).error);
                    }
                }
                catch (ex) { }
                callback(serviceFor, result, extParam1, extParam2);
            },
            error: function (err) {
                //alert(err.statusText)
                COMP_SCAN.fnRemoveProgress();
                alert("Request Error ");
                console.log(err);
            }
        });
    }
    catch (e) {
        alert(e)
    }
};


COMP_SCAN.fnTiffCallBack = function (serviceFor, Result, extParam1, extParam2, extParam3) {
    if (serviceFor == "PDF_PREVIEW") {
        var data = JSON.parse(Result);
        var base64 = data.result;
        COMP_SCAN.fnLoadPdf(base64);
    }
    if (serviceFor == "SPLIT_TIFF" || serviceFor == "Folder_Preview") {
        var data = JSON.parse(JSON.stringify(Result).replace(/DocBase64/g, "src"));
        var ScanElem = extParam2;
        $(ScanElem).setImages({ id: "", src: data }, true, true);
    }
    if (serviceFor == "SAVE_DOC_DB") {
        if (JSON.parse(Result).status)
            alert("saved successfully!");
        else {
            alert("Error when saving document to the user account. User not exists / one of the given refernce is wrong");
            console.log("Error : " + JSON.parse(Result).error);
        }
    }
};

COMP_SCAN.extend = {
    CompReady: function (fn) {
        var scancomp = this;
        if (scancomp != undefined && scancomp != null) {
            if (scancomp.hasOwnProperty("length") || scancomp.selector)
                scancomp = scancomp[0];
        }
        scancomp._readyFn = fn;
    },
    setProps: function (PropsObj) {
        if (PropsObj != [] || PropsObj != null) {
            var scancomp = this;            
            if (scancomp != undefined && scancomp != null) {
                if (scancomp.hasOwnProperty("length") || scancomp.selector)
                    scancomp = scancomp[0];
            }
            window.LoadingSCANElem = scancomp;
            $(scancomp).prop("LeadFk", PropsObj.LeadFk);
            $(scancomp).prop("DocAgtNm", PropsObj.DocAgtNm);
            $(scancomp).prop("DocAgtPk", PropsObj.DocAgtPk);
            $(scancomp).prop("DocBGeoFk", PropsObj.DocBGeoFk);
            $(scancomp).prop("DocPrdFk", PropsObj.DocPrdFk);
        }
    },
    setImages: function (repeatDataSrc, appendFlag, base64Flag) {
        //var scancomp = this[0].shadowRoot;
        var scancomp = this;
        window.LoadingSCANElem = scancomp;
        if (scancomp != undefined && scancomp != null) {
            if (scancomp.hasOwnProperty("length") || scancomp.selector)
                scancomp = scancomp[0];
        }
        var RepeatId = (repeatDataSrc.id == "" || repeatDataSrc.id == null) ? "scan_thumbImgList" : repeatDataSrc.id;
        var repeatData = repeatDataSrc.src;
        if (repeatData[0].error && repeatData[0].error != null) {
            alert(repeatData[0].error);
            return;
        }
        if (repeatData.length >= 1) {
            var repeatsource = $(scancomp).prop("repeatSource");
            if (appendFlag != true) {
                scancomp.querySelector("#" + RepeatId).innerHTML = "";
            }
            var ImngLen = scancomp.querySelectorAll("#scan_thumbImgList li").length;
            ImngLen = (ImngLen && ImngLen != "NaN" && ImngLen != 0) ? ImngLen : 0;

            var repeatsourceTxt = "";
            for (var a = 0; a < repeatData.length; a++) {
                repeatsourceTxt += repeatsource;
                var data_keys = Object.keys(repeatData[a]);
                for (var i = 0; i < data_keys.length; i++) {
                    var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                    var txt = "";
                    var Data = repeatData[a][data_keys[i]];

                    var imgtypes = ["jpg", "jpeg", "jfif", "gif", "bmp", "png", "ppm", "pdf", "ico"];
                    var imgExt = Data.substring(Data.lastIndexOf(".") + 1, Data.length);
                    imgExt = imgExt ? imgExt : "";
                    imgExt = imgExt.toLowerCase();
                    

                    if (base64Flag == true && !(imgtypes.indexOf(imgExt) >= 0))
                        txt = "data:image/jpg;base64," + repeatData[a][data_keys[i]];
                    else
                        txt = repeatData[a][data_keys[i]];
                    repeatsourceTxt = repeatsourceTxt.replace(toReplace, txt);
                    var toReplaceCount = new RegExp("{{count}}", "g");
                    repeatsourceTxt = repeatsourceTxt.replace(toReplaceCount, ImngLen);
                    ImngLen++;
                }
            }

            if (appendFlag == true) {
                repeatsourceTxt = scancomp.querySelector("#" + RepeatId).innerHTML + repeatsourceTxt;
            }
            //repeatsourceTxt += '<div class="clear"></div>';

            scancomp.querySelector("#" + RepeatId).innerHTML = repeatsourceTxt;

            scancomp.querySelector("#scan_pagecnt").innerHTML = scancomp.querySelectorAll("#scan_thumbImgList li").length;
            $(scancomp.querySelectorAll("#" + RepeatId + " li")).show();

            var thumbimg = scancomp.querySelectorAll("ul.scan_thumbnail img");
            var pageno = scancomp.querySelector("#scan_txtPageNo");
            var ul = scancomp.querySelector("ul.scan_thumbnail");
            try {
                $(ul).sortable();
                $(ul).on('sortupdate', COMP_SCAN.fnSortChange);
                $(ul).disableSelection();
            }
            catch (e) { }

            $(scancomp.querySelectorAll("ul.scan_thumbnail li")).removeClass("scan_active");

            $(thumbimg).each(function () {
                $(this).click(function () {
                    var thumbprevimg = scancomp.querySelector(".scan_thumb-preview img");
                    thumbprevimg.src = $(this).attr("src");
                    var li = scancomp.querySelectorAll("ul.scan_thumbnail li");
                    $(ul).find("li").removeClass("scan_active");
                    $(this).parent().addClass("scan_active");
                    $(pageno).val(parseInt($(li).index($(this).parent())) + 1);
                })
            });
            $(scancomp.querySelector("#" + RepeatId + " li:first-child img")).click();
            $(pageno).val(1);

            $(ul).trigger('sortupdate');
        }
    },

    getImages: function (imageIndexString) {
        //var shadow = this[0].shadowRoot;
        var shadow = this;
        window.LoadingSCANElem = scancomp;
        if (shadow != undefined && shadow != null) {
            if (shadow.hasOwnProperty("length") || shadow.selector)
                shadow = shadow[0];
        }

        try {
            if (arguments.length > 1) {
                var args = Array.prototype.slice.call(arguments, 0);
                imageIndexString = args.toString();
            }
            imageIndexString = imageIndexString ? imageIndexString.toString() : imageIndexString;
        }
        catch (e) { }

        var imageIndex = [];
        /* Validations */

        if (!imageIndexString || imageIndexString == "")
            return [];
        if (this.prop("tagName").toUpperCase() != "COMP-SCAN")
            return [];

        /* Validations */

        if (imageIndexString.indexOf(",") > 0) {
            var arr = imageIndexString.split(",");
            for (var i = 0; i < arr.length; i++) {
                if (arr[i].indexOf("-") > 0) {
                    count = (arr[i].match(/-/g) || []).length;
                    if (count == 1) {
                        var splitted = arr[i].split("-");
                        for (var j = parseInt(splitted[0]) ; j <= parseInt(splitted[1]) ; j++) {
                            if (imageIndex.indexOf(parseInt(j)) == -1)
                                imageIndex.push(parseInt(j));
                        }
                    }
                }
                else {
                    if (arr[i].trim() != "" && !isNaN(arr[i]) && imageIndex.indexOf(parseInt(arr[i])) == -1)
                        imageIndex.push(parseInt(arr[i]));
                }

            }
        }
        else if (imageIndexString.indexOf("-") > 0) {
            count = (imageIndexString.match(/-/g) || []).length;
            if (count == 1) {
                var splitted = imageIndexString.split("-");
                for (var j = parseInt(splitted[0]) ; j <= parseInt(splitted[1]) ; j++) {
                    if (imageIndex.indexOf(parseInt(j)) == -1)
                        imageIndex.push(parseInt(j));
                }
            }
        }
        else {
            if (imageIndexString.trim() != "" && !isNaN(imageIndexString) && imageIndex.indexOf(parseInt(imageIndexString)) == -1)
                imageIndex.push(parseInt(imageIndexString));
        }
        var images = [];
        var ImageUL = shadow.querySelectorAll("ul.scan_thumbnail li img");
        var canvas = document.createElement("canvas");
        var ctx = canvas.getContext('2d');
        for (var k = 0; k < imageIndex.length; k++) {
            if (imageIndex[k] <= ImageUL.length) {
                //var src = ImageUL[imageIndex[k] - 1].src;
                canvas.width = ImageUL[imageIndex[k] - 1].naturalWidth;
                canvas.height = ImageUL[imageIndex[k] - 1].naturalHeight;
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.drawImage(ImageUL[imageIndex[k] - 1], 0, 0);
                ctx.save();
                ctx.restore();
                images.push(canvas.toDataURL("image/jpg"));
            }
            else {
                images.push("");
            }

        }
        return images;
    },

    MakeEmpty: function () {
        var scancomp = this;
        if (scancomp != undefined && scancomp != null) {
            if (scancomp.hasOwnProperty("length") || scancomp.selector)
                scancomp = scancomp[0];
        }
        var ImageUL = scancomp.querySelector("ul.scan_thumbnail");
        $(ImageUL).empty();
        var thumbprevimg = scancomp.querySelector(".scan_thumb-preview img");
        $(thumbprevimg).attr("src", "");
        var type = $(scancomp).attr("type");
        type = type ? type : "";
        type = type.toLowerCase();
        if (type == "save") {
            var saveUl = $(scancomp).find(".scan_right-scan");
            $(saveUl).find("ul").not("ul.scan_UlSave").remove();
        }
    },

    LoadImage: function (_Path) {
        var scancomp = this;
        if (scancomp != undefined && scancomp != null) {
            if (scancomp.hasOwnProperty("length") || scancomp.selector)
                scancomp = scancomp[0];
        }
        if (scancomp == undefined || !scancomp || scancomp.tagName.toUpperCase().indexOf("COMP-SCAN") == -1 || _Path == "" || _Path == null || _Path == undefined)
        { throw new Error("Wrong call, Either Path is not given or Component is not SCAN"); return; };
        window.LoadingSCANElem = scancomp;
        COMP_SCAN.fnShowProgress("#scan_ImagePrw");
        setTimeout(function () {
            COMP_SCAN.fnRemoveProgress();
            if (_Path.indexOf(".tif") == -1 || _Path.indexOf(".txt") > 0) {
                var formObj = new FormData();
                formObj.append("Action", "Folder_Preview");
                formObj.append("ViewType", 2);
                formObj.append("iscomp", "true");
                var FolderPath = _Path.substring(0, _Path.lastIndexOf("."));
                FolderPath = FolderPath.replace("_enc", "");
                if (_Path.indexOf(".txt") == -1)
                    FolderPath = _Path;
                formObj.append("PreviewPath", FolderPath);
                COMP_SCAN.fnFileHandler("Folder_Preview", formObj, COMP_SCAN.fnTiffCallBack, "TEXT", scancomp);
            }
            else {
                COMP_SCAN.fnTiff2Base64("SPLIT_TIFF", _Path, "-1", COMP_SCAN.fnTiffCallBack, scancomp);
            }
        }, 500);
    },

    LoadImageArr: function (arr) {
        var scancomp = this;
        if (scancomp != undefined && scancomp != null) {
            if (scancomp.hasOwnProperty("length") || scancomp.selector)
                scancomp = scancomp[0];
        }
        window.LoadingSCANElem = scancomp;
        if (scancomp != undefined && scancomp != null) {
            if (scancomp.hasOwnProperty("length") || scancomp.selector)
                scancomp = scancomp[0];
        }
        if (scancomp == undefined || !scancomp || scancomp.tagName.toUpperCase().indexOf("COMP-SCAN") == -1)
        { throw new Error("Wrong call, Either Path is not given or Component is not SCAN"); return; };
        if (typeof arr != "object" || arr.length == 0) {
            throw new Error("Wrong Input");
            return;
        }
        var normalImage = [];
        for (var i = 0; i < arr.length; i++) {
            var imgPath = "";
            var imgSrc = "";
            if (arr[i].hasOwnProperty("src")) {
                imgPath = arr[i].path.toLowerCase();
                imgSrc = arr[i].src;
            }
            else {
                imgPath = arr[i].toLowerCase();
                imgSrc = "";
            }
            var imgtypes = ["jpg", "jpeg", "jfif", "gif", "bmp", "png", "ppm", "pdf", "ico"];
            var imgExt = imgPath.substring(imgPath.lastIndexOf(".") + 1, imgPath.length);
            imgExt = imgExt ? imgExt : "";
            imgExt = imgExt.toLowerCase();
            if (imgtypes.indexOf(imgExt) != -1) {
                if (imgExt == "pdf") {
                    if (imgSrc && imgSrc.trim() != "")
                    { COMP_SCAN.fnLoadPdf(imgSrc); }
                    else
                    {

                        var formObj = new FormData();
                        formObj.append("Action", "PDF_PREVIEW");
                        var FolderPath = imgPath;                        
                        formObj.append("PreviewPath", FolderPath);
                        COMP_SCAN.fnFileHandler("PDF_PREVIEW", formObj, COMP_SCAN.fnTiffCallBack, "TEXT", scancomp);

                        //alert("Provision not given now");
                        //COMP_SCAN.fnLoadPdf(imgSrc);
                    }
                }
                else {
                    var img = COMP_SCAN.SerUrlDomain + imgPath;
                    if (arr[i].hasOwnProperty("src")) {
                        if (imgSrc && imgSrc.trim() != "") {
                            img = imgSrc;
                            img = img.replace("data:image/jpg;base64,", "");
                            img = img.replace("data:image/jpeg;base64,", "");
                            img = img.replace("data:image/png;base64,", "");
                        }
                    }
                    normalImage.push({ src: img });
                }
            }
            else if (imgPath.indexOf(".tif") > 0) {
                $(scancomp).LoadImage(imgPath);
            }
            else {
                $(scancomp).LoadImage(imgPath);
            }
        }
        if (normalImage.length > 0) {
            $(scancomp).setImages({ id: "", src: normalImage }, true, true);
        }
    }
};


//;(function ($) {
$.fn.extend(COMP_SCAN.extend);


COMP_SCAN.fnSortChange = function (event) {
    //var scancomp = document.getElementById("lead-entry-scan").shadowRoot;
    //var targetScan = $(event.target).closest("comp-scan-save");
    var targetScan = $(event.target).closest("div.custom-component");
    var scancomp = targetScan[0];
    var pageno = 1;
    $(scancomp.querySelectorAll("ul.scan_thumbnail li")).each(function () {
        $(this).children("i").text(pageno);
        pageno++;
    });
}

COMP_SCAN.fnErrorMsg = function (scancomp, ErrMsg) {
    $(scancomp.querySelector("#scan_ImagePrw")).prepend("<p style='background:#FFF;left: 20%; " +
        "padding:5px; font-size:13px;font-weight:bold;text-align:center;position:absolute;color:#CD4B5B;z-index:99;'" +
                       " id='scan_ScanErrmSg'>" + ErrMsg + " </p>");
    $("p#scan_ScanErrmSg").animate({ top: "100px" });
    setTimeout(function () { $("p#scan_ScanErrmSg").fadeOut(1000); }, 1000);
    setTimeout(function () { $("p#scan_ScanErrmSg").remove(); }, 2000);
};


var createComponent_scanSave = function (TagName, HtmlSrc) {

    var ElementProto = Object.create(HTMLElement.prototype);
    //var ElementProto = Object.create(Element.prototype);    

    //ElementProto.setImages = $.fn.setImages;
    //ElementProto.getImages = $.fn.getImages;
    //ElementProto.LoadImage = $.fn.LoadImage;

    ElementProto.LeadFk = 0;
    ElementProto.DocAgtNm = "";
    ElementProto.DocAgtPk = 0;
    ElementProto.DocBGeoFk = 0;
    ElementProto.DocPrdFk = 0;

    ElementProto.setImages = COMP_SCAN.extend.setImages;
    ElementProto.getImages = COMP_SCAN.extend.getImages;
    ElementProto.LoadImage = COMP_SCAN.extend.LoadImage;
    ElementProto.setProps = COMP_SCAN.extend.setProps;
    ElementProto.LoadImageArr = COMP_SCAN.extend.LoadImageArr;
    ElementProto.CompReady = COMP_SCAN.extend.CompReady;
    ElementProto._readyFn = null;


    ElementProto.repeatSource = '<li style="display:none"><i>{{count}}</i><img src="{{src}}"></li>';
    /* DEFINITIONS */

    ElementProto.createdCallback = function () {
        /* Fired when the Element is created */
    }
    ElementProto.attachedCallback = function () {
        /* Fired when the Element is attached to the document */

        /* Changing the content & Events */

        //var shadow = this.createShadowRoot();

        var shadow = this;
        var componentWidth = this.getAttribute("width") || this.width || "100%";
        var componentHeight = this.getAttribute("height") || this.height || "100%";
        var componentID = this.getAttribute("id") || this.id || "";
        var dataTxt = this.getAttribute("imagedata") || this.imagedata;
        //this.click = this.getAttribute("onclick") || this.onclick;
        var styles = this.getAttribute("compstyle") || this.compstyle;
        var themecolor = this.getAttribute("themecolor") || this.themecolor || "";
        var AppendData;

        styles = "<style>" + styles + "</style>"

        if (dataTxt && typeof dataTxt == "string") {
            dataTxt = dataTxt.replace(/}/g, "");
            dataTxt = dataTxt.replace(/{/g, "");
            AppendData = window[dataTxt];
        }
        else if (dataTxt != null && typeof dataTxt == "object") {
            AppendData = dataTxt;
        }
        var htmltoAppend = "";

        if (HtmlSrc && HtmlSrc != "") {
            var textContent = document.querySelector("#" + HtmlSrc).import;
            htmltoAppend = textContent.querySelector("custom-component").innerHTML;
        } else {
            htmltoAppend = document.getElementById("HtmlSrc").innerHTML;
        }

        if (AppendData && AppendData != null && typeof AppendData == "object") {
            var setData = AppendData.setData;
            if (setData && typeof setData == "object") {
                var data_keys = Object.keys(setData);
                for (var i = 0; i < data_keys.length; i++) {
                    var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                    htmltoAppend = htmltoAppend.replace(toReplace, setData[data_keys[i]]);
                }
            }
            shadow.innerHTML = htmltoAppend;
            this.innerHTML = htmltoAppend;

            //_ProtoType.ElementProto.innerHTML = htmltoAppend;
            var repeaters = shadow.querySelectorAll("[isrepeat=true]");
            var repeatDataSrc = AppendData.repeatData;
            var RepeatId = repeatDataSrc.id;
            var repeatData = repeatDataSrc.src;

            if (repeatData.length >= 1) {
                var repeatsource = shadow.querySelector("#" + RepeatId).innerHTML;
                shadow.querySelector("#" + RepeatId).innerHTML = "";
                var repeatsourceTxt = "";
                for (var a = 0; a < repeatData.length; a++) {
                    repeatsourceTxt += repeatsource;
                    var data_keys = Object.keys(repeatData[a]);
                    for (var i = 0; i < data_keys.length; i++) {
                        var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                        repeatsourceTxt = repeatsourceTxt.replace(toReplace, repeatData[a][data_keys[i]]);
                    }
                }
                repeatsourceTxt += '<div class="scan_clear"></div>';
                shadow.querySelector("#" + RepeatId).innerHTML = repeatsourceTxt;
            }
        }
        else { shadow.innerHTML = htmltoAppend; }

        //Load Docs
        LoadingSCANElem = this;
        /* Changing the content */

        //var scancomp = this.shadowRoot;
        var scancomp = this;

        /* OPTIONS - EVENTS */
        scancomp.querySelector("#scan_pagecnt").innerHTML = repeatData ? repeatData.length : 0;
        var pgcnt = (repeatData && repeatData.length > 0) ? 1 : 0;
        if (pgcnt > 0) {
            $(scancomp.querySelectorAll(".scan_thumbnail li")).show();
        }
        else {
            $(scancomp.querySelector(".scan_thumbnail")).hide();
        }
        $(scancomp.querySelector("#scan_txtPageNo")).val(pgcnt);

        var ul = scancomp.querySelector("ul.scan_thumbnail");
        if (repeatData && repeatData.length >= 1) {
            try {
                $(ul).sortable({
                    update: COMP_SCAN.fnSortChange
                });
                $(ul).disableSelection();
            }
            catch (e) { }
        }
        var viewthumbs = scancomp.querySelector(".scan_image-preview-option  .scan_icon-document");

        $(viewthumbs).click(function () {
            var thumbpre = scancomp.querySelector(".scan_thumb-preview");
            var thumb = ul;
            if ($(thumb).css("display") == "none") {
                $(thumb).show();
                $(thumbpre).css({ "width": "73.5%" });
            }
            else {
                $(thumb).hide();
                $(thumbpre).css({ "width": "100%" });
            }
        });

        var pageno = scancomp.querySelector("#scan_txtPageNo");
        var thumbimg = scancomp.querySelectorAll("ul.scan_thumbnail img");

        $(scancomp.querySelectorAll("ul.scan_thumbnail li")[0]).addClass("scan_active");

        $(thumbimg).each(function () {
            $(this).click(function () {
                var thumbprevimg = scancomp.querySelector(".scan_thumb-preview img");
                thumbprevimg.src = $(this).attr("src");
                var li = scancomp.querySelectorAll("ul.scan_thumbnail li");
                $(ul).find("li").removeClass("scan_active");
                $(this).parent().addClass("scan_active");
                $(pageno).val(parseInt($(li).index($(this).parent())) + 1);
            })
        });

        var uparrow = scancomp.querySelector(".scan_icon-up-arrow")
        $(uparrow).click(function () {
            var act = scancomp.querySelector("ul.scan_thumbnail >li.scan_active");
            var ActiveIndex = $(scancomp).find("ul.scan_thumbnail li").index(act);
            if (ActiveIndex == 0)
                return;
            var PrevChild = ActiveIndex;
            scancomp.querySelector("ul.scan_thumbnail li:nth-child(" + PrevChild + ") img").click();
        });

        var downarrow = scancomp.querySelector(".scan_icon-down-arrow")
        $(downarrow).click(function () {
            var act = scancomp.querySelector("ul.scan_thumbnail >li.scan_active");
            var Li_length = scancomp.querySelectorAll("ul.scan_thumbnail li").length;
            var ActiveIndex = $(scancomp).find("ul.scan_thumbnail li").index(act);
            if (ActiveIndex == Li_length - 1)
                return;
            var NextChild = ActiveIndex + 2;
            scancomp.querySelector("ul.scan_thumbnail li:nth-child(" + NextChild + ") img").click();
        });


        $(pageno).keypress(function (ev) {
            var keycode = (ev.keyCode ? ev.keyCode : ev.which);
            if (keycode == 13) {
                var pgno = $(pageno).val();
                //var src= scancomp.querySelector("ul.thumbnail li:nth-child(3) img").attr("src");
                if ($.isNumeric(pgno) && pgno <= parseInt($(scancomp.querySelector("#scan_pagecnt")).text())) {
                    scancomp.querySelector("ul.scan_thumbnail li:nth-child(" + pgno + ") img").click();
                    var act = scancomp.querySelector("ul.scan_thumbnail >li.scan_active");
                    $(act).removeClass("scan_active");
                    var newli = scancomp.querySelector("ul.scan_thumbnail li:nth-child(" + pgno + ")");
                    $(newli).addClass("scan_active");
                }
                else {
                    var imgList = scancomp.querySelectorAll("ul.scan_thumbnail li");
                    var Activeimg = scancomp.querySelector("ul.scan_thumbnail li.scan_active");
                    COMP_SCAN.fnErrorMsg(scancomp, " Page not available.");
                    $(pageno).val($(imgList).index(Activeimg) + 1);
                }
            }
        });



        var zoomin = scancomp.querySelector(".scan_icon-plus");
        $(zoomin).click(function () {

            var img = scancomp.querySelector(".scan_thumb-preview img");
            var Id = scancomp.querySelector(".scan_thumb-preview");
            var imgOrgWidth = $(img).width() + ($(img).width() * 5 / 100);
            var imgOrgHeight = $(img).height() + ($(img).height() * 5 / 100);
            $(img).css({
                "height": imgOrgHeight + "px",
                "width": imgOrgWidth + "px"
            });

            if ($(img).width() < $(Id).width() || $(img).height() < $(Id).height()) {
                $(img).css({ top: 0, left: 0 });
            }

            var maskWidth = $(Id).width();
            var maskHeight = $(Id).height();
            var imgPos = $(img).offset();
            var imgWidth = $(img).width();
            var imgHeight = $(img).height();
            var x1 = (imgPos.left + maskWidth) - imgWidth;
            var y1 = (imgPos.top + maskHeight) - imgHeight;
            var x2 = imgPos.left;
            var y2 = imgPos.top;

            //$("#Prw img").draggable({ containment: [x1, y1, x2, y2] });
            //$("#Prw img").draggable();
            //$("#Prw img").css({ cursor: 'move' });
            //$("#Prw canvas").css({ cursor: 'move' });

        });

        var zoomout = scancomp.querySelector(".scan_icon-minus");

        $(zoomout).click(function () {
            var img = scancomp.querySelector(".scan_thumb-preview img");
            var Id = scancomp.querySelector(".scan_thumb-preview");

            var imgOrgWidth = $(img).width() - ($(img).width() * 5 / 100);
            var imgOrgHeight = $(img).height() - ($(img).height() * 5 / 100);
            $(img).css({
                "height": imgOrgHeight + "px",
                "width": imgOrgWidth + "px"
            });

            if ($(img).width() < $(Id).width() || $(img).height() < $(Id).height()) {
                $(img).css({ top: 0, left: 0 });
            }

            var maskWidth = $(Id).width();
            var maskHeight = $(Id).height();
            var imgPos = $(img).offset();
            var imgWidth = $(img).width();
            var imgHeight = $(img).height();
            var x1 = (imgPos.left + maskWidth) - imgWidth;
            var y1 = (imgPos.top + maskHeight) - imgHeight;
            var x2 = imgPos.left;
            var y2 = imgPos.top;

            //$("#Prw img").draggable({ containment: [x1, y1, x2, y2] });
            //$("#Prw img").draggable();
            //$("#Prw img").css({ cursor: 'move' });
            //$("#Prw canvas").css({ cursor: 'move' });
        });


        var rotateleft = scancomp.querySelector(".scan_image-preview-option  .scan_icon-rotate-left");

        $(rotateleft).click(function () {
            var ImageToRotate = scancomp.querySelector(".scan_thumb-preview img");
            var OrgImg = scancomp.querySelector("ul.scan_thumbnail li.scan_active img");
            var degree = 270;
            var RotateImage = ImageToRotate;
            var divID = "rotate";
            var cnvasID = "canvas_" + divID;
            var cnvs = "<canvas style='width:100px;height:100px;display:none;' id='" + cnvasID + "' > </canvas>";
            if ($(document.querySelectorAll("#" + cnvasID)).length == 0)
                $("body").append(cnvs);
            var canvas = document.querySelector("#" + cnvasID);

            if (canvas) {
                var cContext = canvas.getContext('2d');
                var cw = RotateImage.naturalWidth,
                    ch = RotateImage.naturalHeight,
                    cx = 0,
                    cy = 0;

                //   Calculate new canvas size and x/y coorditates for image
                switch (degree) {
                    case 90:
                        cw = RotateImage.naturalHeight;
                        ch = RotateImage.naturalWidth;
                        cy = RotateImage.naturalHeight * (-1);
                        break;
                    case 180:
                        cx = RotateImage.naturalWidth * (-1);
                        cy = RotateImage.naturalHeight * (-1);
                        break;
                    case 270:
                        cw = RotateImage.naturalHeight;
                        ch = RotateImage.naturalWidth;
                        cx = RotateImage.naturalWidth * (-1);
                        break;
                }

                //  Rotate image            
                canvas.setAttribute('width', cw);
                canvas.setAttribute('height', ch);
                cContext.rotate(degree * Math.PI / 180);
                cContext.drawImage(RotateImage, cx, cy);
                var base64 = canvas.toDataURL("image/jpeg");
                $(RotateImage).attr("src", base64);
                $(OrgImg).attr("src", base64);

            } else {
                //  Use DXImageTransform.Microsoft.BasicImage filter for MSIE
                switch (degree) {
                    case 0: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=0)'; break;
                    case 90: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=1)'; break;
                    case 180: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=2)'; break;
                    case 270: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=3)'; break;
                }
            }
            //  });
        });

        var rotateright = scancomp.querySelector(".scan_image-preview-option  .scan_icon-rotate-right");

        $(rotateright).click(function () {

            var ImageToRotate = scancomp.querySelector(".scan_thumb-preview img");
            var OrgImg = scancomp.querySelector("ul.scan_thumbnail li.scan_active img");
            var degree = 90;
            var RotateImage = ImageToRotate;
            var divID = "rotate";
            var cnvasID = "canvas_" + divID;
            var cnvs = "<canvas style='width:100px;height:100px;display:none;' id='" + cnvasID + "' > </canvas>";
            if ($(document.querySelectorAll("#" + cnvasID)).length == 0)
                $("body").append(cnvs);
            var canvas = document.querySelector("#" + cnvasID);

            if (canvas) {
                var cContext = canvas.getContext('2d');
                var cw = RotateImage.naturalWidth, ch = RotateImage.naturalHeight, cx = 0, cy = 0;

                //   Calculate new canvas size and x/y coordinates for image
                switch (degree) {
                    case 90:
                        cw = RotateImage.naturalHeight;
                        ch = RotateImage.naturalWidth;
                        cy = RotateImage.naturalHeight * (-1);
                        break;
                    case 180:
                        cx = RotateImage.naturalWidth * (-1);
                        cy = RotateImage.naturalHeight * (-1);
                        break;
                    case 270:
                        cw = RotateImage.naturalHeight;
                        ch = RotateImage.naturalWidth;
                        cx = RotateImage.naturalWidth * (-1);
                        break;
                }

                //  Rotate image            
                canvas.setAttribute('width', cw);
                canvas.setAttribute('height', ch);
                cContext.rotate(degree * Math.PI / 180);
                cContext.drawImage(RotateImage, cx, cy);
                var base64 = canvas.toDataURL("image/jpeg");
                $(RotateImage).attr("src", base64);
                $(OrgImg).attr("src", base64);

            } else {
                //  Use DXImageTransform.Microsoft.BasicImage filter for MSIE
                switch (degree) {
                    case 0: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=0)'; break;
                    case 90: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=1)'; break;
                    case 180: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=2)'; break;
                    case 270: RotateImage.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(rotation=3)'; break;
                }
            }
        });

        var printer = scancomp.querySelector(".scan_image-preview-option  .scan_icon-printer");
        $(printer).click(function () {
            var contents = scancomp.querySelector(".scan_thumb-preview").innerHTML;
            contents = "<div><img src='" + scancomp.querySelector(".scan_thumb-preview img").src + "' /></div>";
            var printframe = document.createElement('iframe');
            printframe.name = "printframe";
            printframe.style.position = "absolute";
            printframe.style.top = "-1000000px";
            document.body.appendChild(printframe);
            var frameDoc = (printframe.contentWindow) ? printframe.contentWindow : (printframe.contentDocument.document) ? printframe.contentDocument.document : printframe.contentDocument;
            frameDoc.document.open();
            frameDoc.document.write('<html><head><title>Print</title>');
            frameDoc.document.write('</head><body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["printframe"].focus();
                window.frames["printframe"].print();
                document.body.removeChild(printframe);
            }, 500);
            return false;
        });

        var imgcrop = scancomp.querySelector(".scan_image-preview-option  .scan_icon-crop");

        var expandComp = scancomp.querySelector(".scan_image-preview-option .scan_icon-expand");
        $(expandComp).click(function (e) {
            e.preventDefault();
            $(this).hide();
            $(scancomp.querySelector(".scan_icon-collapse")).show();
            var comp = scancomp.querySelector(".custom-component");
            var FixedElems = $('*').filter(function () {
                var elems = ($(this).css('position') == 'fixed' && $(this).css('display') != 'none' ||
                    ($(this).css('z-index') >= 1 && !$(this).hasClass("scan_image-preview-option") && $(this).css('display') != 'none'));
                return elems;
            });
            window.hidedElems = FixedElems;
            window.hidedCompElems = $("comp-scan").filter(function () {
                var elems = $(this).css('display') != 'none';
                return elems;
            });
            $(FixedElems).hide();
            $(window.hidedCompElems).hide();
            $(scancomp).show();
            var ThumbPrw = scancomp.querySelector("div.scan_thumb-preview");
            var thumbnail = scancomp.querySelector("ul.scan_thumbnail");
            window.scanPrwHt = $(ThumbPrw).css("height");
            window.scanThumbHt = $(thumbnail).css("height");

            $(ThumbPrw).removeAttr("style");
            $(ThumbPrw).attr("style", "height:85vh;");
            $(thumbnail).removeAttr("style");
            $(thumbnail).attr("style", "height:85vh;");

            $(comp).css({
                //'width': '100%',
                //'height': '100%',
                'width': '100%',
                'height': '100%',
                'position': 'fixed',
                'top': 0,
                'left': 0,
                //'z-index': '9999',
                'text-align': 'center',
                'vartical-aign': 'middle'
            });
            window.overflowStyle = $("body").css("overflow");
            $("body").css("overflow", "hidden");
            $(thumbnail).hide();
        });

        var collapseComp = scancomp.querySelector(".scan_image-preview-option .scan_icon-collapse");
        $(collapseComp).click(function (e) {
            e.preventDefault();
            $(this).hide();
            $(scancomp.querySelector(".scan_icon-expand")).show();
            var host = scancomp;
            var OrigWidth = $(host).attr("width");
            try {
                $(window.hidedElems).show();
                $(window.hidedCompElems).show();
            } catch (e) { }
            $(scancomp.querySelector(".custom-component")).css({
                "width": OrigWidth,
                'height': '',
                'position': '',
                'top': '',
                'left': '',
                'z-index': '0',
                'text-align': 'center'
            });
            var ThumbPrw = scancomp.querySelector(".scan_thumb-preview");
            var thumbnail = scancomp.querySelector(".scan_thumbnail");

            $(ThumbPrw).removeAttr("style");
            $(ThumbPrw).attr("style", "height:" + scanPrwHt + ";");
            $(thumbnail).removeAttr("style");
            $(thumbnail).attr("style", "height:" + scanThumbHt + ";");
            $(thumbnail).hide();
            $("body").css("overflow", window.overflowStyle);
        });

        //scroll event
        var ThumbPrw = scancomp.querySelector(".scan_thumb-preview");
        $(ThumbPrw).bind('scroll', function () {
            var act = scancomp.querySelector("ul.scan_thumbnail >li.scan_active");
            var ActiveIndex = $(scancomp).find("ul.scan_thumbnail li").index(act) + 1;
            var len = scancomp.querySelectorAll("ul.scan_thumbnail >li").length;

            if ($(this).scrollTop() + $(this).innerHeight() >= $(this)[0].scrollHeight) {
                if (ActiveIndex != len) {
                    $(downarrow).click();
                    $(ThumbPrw).scrollTop(100);
                }

            }
            if ($(this).scrollTop() == 0) {
                if (ActiveIndex != 1) {
                    $(uparrow).click();
                    $(ThumbPrw).scrollTop(50);
                }
            }
        });

        var AppSelect = scancomp.querySelector(".scan_AplTyp");
        $(AppSelect).change(function () {
            var val = $(this).val();
            if (val > 0) {
                $(scancomp.querySelector(".scan_AplTypSub")).show();
            }            
            else {
                $(scancomp.querySelector(".scan_AplTypSub")).hide();
                $(scancomp.querySelector(".scan_AplTypSub")).val(1);
            }
        });

        // For Image preview
        $(document).keydown(function (e) {
            //shiftKey
            if ($(scancomp) && $(scancomp).is(":hover")) {
                switch (e.which) {
                    case 79: // Ctrl+Alt+O 
                        if (e.altKey && e.ctrlKey) {
                            var ZoomOut = scancomp.querySelector(".scan_icon-minus");
                            ZoomOut.click();
                        }
                        break;

                    case 73: // Ctrl+Alt+I
                        if (e.altKey && e.ctrlKey) {
                            var ZoomIn = scancomp.querySelector(".scan_icon-plus");
                            ZoomIn.click();
                        }
                        break;
                    case 37: // left
                        if (e.altKey && e.ctrlKey) {
                            var rotateleft = scancomp.querySelector(".scan_image-preview-option  .scan_icon-rotate-left");
                            rotateleft.click();
                        }
                        break;

                    case 39: // right        
                        if (e.altKey && e.ctrlKey) {
                            var rotateright = scancomp.querySelector(".scan_image-preview-option  .scan_icon-rotate-right");
                            rotateright.click();
                        }
                        break;

                    case 38: // up
                        var uparrow = scancomp.querySelector(".scan_icon-up-arrow");
                        uparrow.click();
                        break;

                    case 40: // down
                        var downarrow = scancomp.querySelector(".scan_icon-down-arrow");
                        downarrow.click();
                        break;

                    default: return; // exit 
                }
                e.preventDefault(); // prevent the default action
            }
        });

        var Annotation = scancomp.querySelector(".scan_image-preview-option .scan_icon-chat-o");


        var Output = scancomp.querySelector(".scan_image-preview-option #scan_scanOutput");

        $(Output).keypress(function () {
            var code = e.which | w.keycode;
            if (code == 32) {
                //$("#lead-entry-scan").getImages($(this).val());
            }
        });

        var rightScan = scancomp.querySelector(".scan_right-scan");

        var SaveOpt = scancomp.querySelector(".scan_right-scan .scan_icon-plus");
        $(SaveOpt).click(function () {
            var ultxt = $(scancomp.querySelector(".scan_right-scan .scan_UlSave")).html();
            $(rightScan).append("<ul>" + ultxt + "<i class='scan_icon-close scan_right'></i></ul>");
        });

        var closeUl = "comp-scan .scan_right-scan ul i.scan_icon-close";
        $(document).on("click", closeUl, function () {
            $(this).closest("ul").remove();
        });

        var Btnsavedoc = scancomp.querySelector(".scan_right-scan input.scan_savedoc");
        $(Btnsavedoc).click(function () {
            var saveasFile = true;
            var isErr = false;
            var LeadId = $(scancomp).prop("LeadFk");
            LeadId = LeadId ? LeadId : 0;
            if (LeadId == 0) {
                alert("Lead id is not set to save the document");
                return;
            }

            //$(scancomp).prop("LeadFk", PropsObj.LeadFk);
            //$(scancomp).prop("DocAgtNm", PropsObj.DocAgtNm);
            //$(scancomp).prop("DocBGeoFk", PropsObj.DocBGeoFk);

            var arrPageDtls = [];
            var ImagesList = scancomp.querySelectorAll("ul.scan_thumbnail li img");
            $(rightScan).find("ul").each(function () {
                var ul = $(this);
                var DocActVal = ul.find(".scan_AplTyp").val();
                var DocAct = ul.find(".scan_AplTyp option:selected").text();
                var DocCat = ul.find(".scan_DocGrp").val();
                var DocSubCat = ul.find(".scan_DocTyp").val();
                var DocNm = ul.find(".scan_DocNm").val();
                var FromNo = ul.find(".scan_PageFrom").val();
                var ToNo = ul.find(".scan_Pageto").val();
                var PageDtlsObj = {};
                var len = ImagesList.length;
                if (FromNo < 1 || ToNo > len) {
                    isErr = true;
                    alert("From to numbers wrong / Either exceeded or not correct");
                    return;
                }
                var FileName = "";
                if (saveasFile) {
                    FileName = DocAct + "/" + DocCat + "/" + DocSubCat + "/" + DocNm;
                }
                else {
                    FileName = DocAct + "_" + DocCat + "_" + DocSubCat + "_" + DocNm;
                }


                PageDtlsObj["DocNm"] = FileName;
                PageDtlsObj["From"] = FromNo;
                PageDtlsObj["To"] = ToNo;
                arrPageDtls.push(PageDtlsObj);
            });
            if (isErr)
                return;
            var imgCount = 0;
            var arrImgSet = [];
            var imageList = "";
            $(ImagesList).each(function () {
                imgCount++;
                var src = $(this).attr("src");
                src = src.replace("data:image/jpg;base64,", "");
                src = src.replace("data:image/jpeg;base64,", "");
                src = src.replace("data:image/png;base64,", "");
                for (var i = 0; i < arrPageDtls.length; i++) {
                    var List = arrPageDtls[i];
                    var from = List.From;
                    var to = List.To
                    if (imgCount >= List.From && imgCount <= List.To) {
                        if (!arrImgSet[i]) {
                            arrImgSet[i] = { DocNm: "", SrcList: [] };
                        }
                        arrImgSet[i].DocNm = List.DocNm.replace(/ /g, "_");
                        var img = arrImgSet[i].SrcList;
                        if (!img) {
                            arrImgSet[i].SrcList = [];
                            img = arrImgSet[i].SrcList;
                        }
                        img.push(src);
                        arrImgSet[i].SrcList = img;
                    }
                }
            });
            var formData = new FormData();
            formData.append("Action", "SAVE_SELECTED_PAGEWISE")
            formData.append("IsEncrypt", "true");
            formData.append("saveAsfile", saveasFile.toString());
            formData.append("setLength", arrImgSet.length);
            formData.append("ImageData", JSON.stringify(arrImgSet));
            formData.append("savepath", LeadId);
            COMP_SCAN.fnCallFileUpload("SAVE_SELECTED_PAGEWISE", formData, COMP_SCAN.fnUploadCallBack, "", "");
        });

        /* OPTIONS - EVENTS */

        /* RENDER - TYPE */

        var _type = this.getAttribute("type") || this.type || "viewer";
        if (_type == "save") {
            $(imgcrop).remove();
            $(Annotation).remove();
        }
        if (_type == "viewer") {
            var rightContent = scancomp.querySelector(".scan_right-scan");
            $(rightContent).remove();
            var leftContent = scancomp.querySelector(".scan_left-scan");
            $(leftContent).css({
                "width": "100%"
            });
            var title = scancomp.querySelector(".scan_scan-title");
            $(title).remove();

            $(viewthumbs).remove();
            $(printer).remove();
            $(rotateleft).remove();
            $(rotateright).remove();
            $(imgcrop).remove();
            $(Annotation).remove();
        }

        /* RENDER - TYPE */


        /* APLLY STYLES */

        if (componentWidth == "100%") {
            //componentWidth = $(scancomp).parent().width();
            //componentWidth = componentWidth.toString();
        }
        if (componentHeight == "100%") {
            //componentHeight = $(scancomp).parent().height();
            //componentHeight = componentHeight.toString();
        }

        var componentForStyles = scancomp.querySelector(".custom-component");
        componentHeight = componentHeight.replace("px", "");
        $(scancomp).css({
            "float": "left",
            "width": componentWidth,
            "height": componentHeight
        });

        $(componentForStyles).css({
            "width": componentWidth,
            "height": componentHeight - 10
        });

        if (componentWidth != "100%") {
            var width = componentWidth.replace("px", "");
            var componentIcons = scancomp.querySelectorAll(".scan_image-preview-option i");
            if (width <= 500)
                $(componentIcons).css({ "font-size": "15px" });
            else if (width <= 300)
                $(componentIcons).css({ "font-size": "11px" });
        }

        /*
        var parent = $(scancomp).parent();
        var prwHt = parent.height() - 75;
        prwHt = prwHt < 300 ? 300 : prwHt;
        $(scancomp.querySelector(".scan_thumb-preview")).css("height", prwHt);
        $(scancomp.querySelector(".scan_thumbnail")).css("height", prwHt);;
        */

        //$(scancomp.querySelector(".scan_scand-document")).css("height", componentHeight);
        //$(scancomp.querySelector(".scan_image-div")).css("height", componentHeight);

        var div1 = scancomp.querySelector(".scan_image-preview-option");
        var dvHt = $(div1).height();
        var fulHt = $(scancomp).height() == 0 ? componentHeight : $(scancomp).height();
        fulHt = fulHt.toString();
        fulHt = fulHt.replace("px", "");
        fulHt = fulHt < 200 ? 500 : fulHt;
        var minus = 30;
        if (_type == "save") {
            minus = 65;
        }
        var ht = fulHt - dvHt - minus;
        $(scancomp.querySelector(".scan_thumb-preview")).css("height", ht);
        $(scancomp.querySelector(".scan_thumbnail")).css("height", ht);

        var READY_FN_LIST = COMP_SCAN._readyFn;
        for (var i = 0; i < READY_FN_LIST.length; i++) {
            var fnObj = READY_FN_LIST[i];
            if ("#" + componentID == fnObj.selector) {
                var Rfn = fnObj.fn;
                if (Rfn && Rfn != null && Rfn != undefined && typeof Rfn == "function")
                    Rfn();
            }
        }        
    }
    ElementProto.detachedCallback = function () {
        /* Fired when the Element is removed */
    }
    ElementProto.attributeChangedCallback = function (attrName, oldValue, newValue) {
        //console.log(attrName + "=" + oldValue + "=" + newValue);
    }

    ElementProto.html = function () {
        return this.innerHTML;
    }

    /*  Register our tag and its properties as an element in the document. 
       So that document will understand the tag and parse it as we designed    */
    var MyElement = document.registerElement(TagName, { prototype: ElementProto });

    /* custom elements object */

    if (window.CustomElements != null && window.CustomElements != undefined) {
        var len = window.CustomElements.List.length;
        window.CustomElements.List[len] = TagName;
    }
    else {
        window.CustomElements = {};
        window.CustomElements.List = [];
        window.CustomElements.List[0] = TagName;

        window.CustomElements.find = function (tagNm) {
            if (window.CustomElements && window.CustomElements.List && window.CustomElements.List.length > 0) {
                var arr = window.CustomElements.List.toString().split(",");
                return arr.indexOf(tagNm.toLowerCase()) !== -1;
            }
            else {
                return false;
            }
        }
    }
    /* custom elements object */


};

createComponent_scanSave("comp-scan", "scan");