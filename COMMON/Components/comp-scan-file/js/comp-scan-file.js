/// <reference path="../../js/lz-string.js" />/// <reference path="../../js/lz-string.js" />
window.CustomElements = {};
window.CustomElements.List = [];
var COMP_SCAN_FILE = {};

COMP_SCAN_FILE._readyFn = [];
COMP_SCAN_FILE.CompReady = function (sel, fn) {
    debugger;
    var Obj = { selector: sel, fn: fn };
    COMP_SCAN_FILE._readyFn.push(Obj);
    if ($(sel).length > 0 && $(sel).html() != "") {
        fn();
    }
}

COMP_SCAN_FILE.fnShowAllDoc = function (_path) {
    var formObj = new FormData();
    formObj.append("Action", "UploadShowDoc");
    formObj.append("SavePath", _path);
    COMP_SCAN_FILE.fnCallFileUpload("UploadDocs", formObj, COMP_SCAN_FILE.fnUploadCallBack, "", "");
};

COMP_SCAN_FILE.fnLoadScanApp = function (appName) {
    cnt = 0;
    appName = "COMP";
    var host = window.location.host.indexOf("http:") == 0 ? window.location.host : "http://" + window.location.host;
    if (host.indexOf("localhost:") >= 0)
        appName = "js/";
    else
        appName = appName + "/js/";
    var href = host + "/" + appName + "/jquery.signalR-2.1.2.js";
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.id="signalR"
    script.src = href;
    $("head").append(script);

    var scriptEl = document.createElement('script');
    scriptEl.type = "text/javascript";
    scriptEl.src = "http://localhost:8080/signalr/hubs";
    $("head").append(scriptEl);

    $("head").append("<script src='" + host + "/" + appName + "/lz-string.js' />");
    setTimeout(COMP_SCAN_FILE.LoadHub, 1000);
}


COMP_SCAN_FILE.LoadApplet = function (event) {
    loopcount = loopcount + 1;
    if (loopcount <= 15) {
        try {
            COMP_SCAN_FILE.fnLoadScanApp();
            return false;
        }
        catch (err) {
            COMP_SCAN_FILE.fnLoadScanApp();
            return false;
        }
    }
    else {
        console.log("loadapplet else");
    }
}

var ClientCount = 0;
var loopcount = 0;
var inc = 0;

COMP_SCAN_FILE.LoadHub = function LoadHub(event) {
    try {
        var ff = $.connection;
        if (ff != undefined) {
            if (cnt == 0) {
                cnt = cnt + 1;
                ClientCount = ClientCount + 1;
                $.connection.hub.url = "http://localhost:8080/signalr";
                var chat = $.connection.myHub;
                if (chat == undefined) {
                    cnt = 0;
                    COMP_SCAN_FILE.LoadApplet();
                }
                else {
                    var resCount = 0;
                    var imageArr = "";
                    inc = 0;
                    chat.client.addMessage = function (message, imgIndex, imgCount, Loopcompleted) {
                        resCount++;
                        inc++;
                        var evt = window.event;
                        var message1 = LZString.decompressFromUTF16(message);                        
                        message = message1;
                        message = message.replace("data:image/jpg;base64,", "");
                        message = message.replace("data:image/jpeg;base64,", "");
                        message = message.replace("data:image/png;base64,", "");
                        imageArr += message + ","
                        if (inc == imgCount) {                            
                            imageArr = imageArr.substring(0, imageArr.length - 1);
                            var formData = new FormData();
                            formData.append("Action", "SAVE_SELECTED_PAGEWISE")
                            formData.append("IsEncrypt", "true");
                            formData.append("saveAsfile", "true");
                            formData.append("setLength", imgCount);
                            formData.append("ImageData", imageArr);
                            var Scn = ScanUploadELEM.repositoryPath;
                            formData.append("savepath", Scn);
                            COMP_SCAN_FILE.fnCallFileUpload("SAVE_SCANED_IMG", formData, COMP_SCAN_FILE.fnUploadCallBack, "", "");
                            $.connection.hub.stop();
                        }
                        return false;
                    };
                    $.connection.hub.start({ waitForPageLoad: false }).done(function () {
                        console.log("started");
                    });
                    $.connection.hub.disconnected(function () {
                        console.log("disconnected");
                        //alert("Scan Completed");
                    });
                    chat.client.stopClient = function () {
                        console.log("stopClient");
                        $.connection.hub.stop();
                    };
                }
            }
            else {
                alert("clearint")
                clearInterval(COMP_SCAN_FILE.LoadHub);
            }
        }
        else {
            alert("connection undefined")
            COMP_SCAN_FILE.fnLoadScanApp();
        }
    }
    catch (e) {
        alert(e)
    }
    return false;
};

COMP_SCAN_FILE.OnDragEnter = function (e) {
    e.stopPropagation();
    e.preventDefault();
};

COMP_SCAN_FILE.OnDragOver = function (e) {
    e.stopPropagation();
    e.preventDefault();
};

COMP_SCAN_FILE.OnDrop = function (e) {
    e.stopPropagation();
    e.preventDefault();    
    ScanUploadELEM = $(e.target).parents("COMP-SCAN-FILE");
    if (ScanUploadELEM)
        ScanUploadELEM = ScanUploadELEM[0];
    selectedFiles = e.dataTransfer.files;
    COMP_SCAN_FILE.fnUploadDoc(selectedFiles, true);
};



COMP_SCAN_FILE.fnShowProgress = function () {
    var Div = ScanUploadELEM.querySelector(".scan_document-div");
    //var body = $(this.ie6 ? document.body : document);
    var width = $(Div).width();
    var height = $(Div).height();
    var xModalDiv = $("<div id='scan_modalProgess'><h1 style='font-size:13px; position:relative;  top:50%;color:#000;'>Processing Request..</h1></div>");
    xModalDiv.css({
        'position': 'absolute',
        'top': 0,
        'left': 0,
        'z-index': '1000',
        'width': width,
        'height': height,
        'text-align': 'center',
        'vartical-aign': 'middle'
    });
    xModalDiv.remove();
    xModalDiv.appendTo(Div);
}

COMP_SCAN_FILE.fnRemoveProgress = function () {
    $("#scan_modalProgess").remove();
}

COMP_SCAN_FILE.fnUploadCallBack = function (serviceFor, Result, extParam1, extParam2, extParam3) {
    if (!JSON.parse(Result).status) {
        return;
    }
    if (serviceFor == "SAVE_SCANED_IMG") {
        $(ScanUploadELEM).LoadDirectory();
    }
    if (serviceFor == "UploadDocs") {
        var Obj = JSON.parse(Result);
        var data = JSON.parse(Obj.result);
        var imgList = ScanUploadELEM.querySelector(".scan_attached-list");
        if (data == null || data.length == 0)
            return;
        var img = "";

        if (data[0].Error != "") {
            $(imgList).empty();
            $(imgList).append(data[0].Error);
            return;
        }
        if (data[0].Base64 || data[0].Base64 == "") {            
            for (var i = 0; i < data.length; i++) {
                var fullNm = "";                
                var fileNm = data[i].Filepath.substring(data[i].Filepath.lastIndexOf("/") + 1, data[i].Filepath.length);
                var indx = fileNm.lastIndexOf("__X__") == -1 ? 0 : fileNm.lastIndexOf("__X__") + 5;
                fileNm = fileNm.substring(indx);
                fullNm = fileNm;
                if (fileNm.length > 12)
                    fileNm = "<p title='" + fileNm + "'>" + fileNm.substring(0, 12) + "..</p>";
                else
                    fileNm = "<p title='" + fileNm + "'>" + fileNm + "</p>";
                if (data[i].FileType == ".pdf") {
                    img += "<li title='" + fullNm + "' ><img isBase64='true' pdf64='" + data[i].Base64 + "' FileType='" + data[i].FileType + "' Filepath='" + data[i].Filepath + "'  class='imgList' " +
                        "src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADUCAYAAADZTGx+AABhHklEQVR42u29CbAkV3UmfG8tb+l9VUtqNUL7xibL/AiERwwOFnsc/DbGM3KEFzABBsIEEMIYjC1smMHE4GEMnjADdmDkmRjPMMyYAGOIMfD/xjgMtgAbEEIb2pfepN6731J153w387t57q3MqqxX771+VXrZkf2qsrKyqm7ec8/2ne9Y55xZ39a39a18a6wPwfq2vlVvdn0I1rch5sZTytyAddVaF+j1rWKcbW5h4G83F47uU01IWmN405rqxq0LzMqa300lIB3ZF/LHTxlBaY2RcOBmTX3nO9/5bzMzM5eL+rPY1+fxypgWCwsL5uTJk93HH3/8f/3Mz/zMf86F44zs87Iv5gIz8UJix+Q7YjWbln2TCMhfbt269bnr03jltm63axYXF72QnDp1au6JJ5647ad+6qdeNz8/f1JePp0LylwuKG5SBQULxbhEsSggW+UmTa1P4RVekaw1jUbD/221WtPbtm274Stf+cr/95rXvOb58vIu2bfJvhEaXZlhE2tnjsv3xM3Ysi4gqycgIhym3W7757LteeMb33jrH/zBH7xFHp+bC8rWfOFqTqpPOC4CgoFvyz4rqr+1PoVXR0iazaYXkOnpaf9YzK3pG2+88fWf+tSnPi5+4D4IjezbYfrmC9jECck4CQiDCjZf0da3VdAiEIypqSkzOzvrnx86dMheddVVz/nsZz/7v37yJ3/yRXLqBbLvzIVk2hQRxnUBWWUB0bu/geuCsrpaZMOGDf7YY489Zi644IJt7373uz/0jne84/Vy6tNlPwcmcGJyrQvIWriJ64Ky8kICLQIB2bRpk49wQUjEeW/+3M/93Kt///d//9/KqZfk2mQHTGFq+3UBWUM3cn1beSHZuHGj2bJlizl27Jg5ePAgntuXvOQl1//Zn/3ZR+X4VXL6vtyBp1/SWBeQdW3ylBEScc69FhHtYfbv32+OHz/uTbDnPOc5F4iQ/OcXvOAFP56bXFpIxtbkakyiIKwLygpNltxph8MOLSIJW/PAAw/4xCJCwhdffPHG35Htta997a/kJteecfdL7H3G/JtOzS/eGfLig87v1nzfMVmF9huz+QEZ8Oe/852vP2ffvj18jfUsValcp85Jj1edP+jYWjunzvvcMp3bFD9k14teZObm5ryZ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'>" + fileNm + "</li>";
                }
                else if (data[i].FileType == ".doc" || data[i].FileType == ".docx") {
                    img += "<li title='" + fullNm + "' ><img isBase64='true' pdf64='" + data[i].Base64 + "' FileType='" + data[i].FileType + "' Filepath='" + data[i].Filepath + "'  class='imgList' " +
                        "src='data:image/jpeg;base64,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'>" + fileNm + "</li>";
                }
                else if (data[i].FileType == ".tiff" || data[i].FileType == ".tif") {
                    img += "<li title='" + fullNm + "' ><img isBase64='true' FileType='" + data[i].FileType + "' Filepath='" + data[i].Filepath + "'  class='imgList' " +
                        " src='data:image/png;base64,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'>" + fileNm + "</li>";
                }
                else {
                    img += "<li title='" + fullNm + "' ><img isBase64='true' FileType='" + data[i].FileType + "' Filepath='" + data[i].Filepath + "'  class='imgList' src='data:image/jpg;base64," + data[i].Base64 + "'>" + fileNm + "</li>";
                }
            }
        }
        else {
            for (var i = 0; i < data.length; i++) {
                var fullNm = "";
                var fileNm = data[i].DocPath.substring(data[i].DocPath.lastIndexOf("/") + 1, data[i].DocPath.length); fullNm = fileNm;
                fileNm = fileNm.substring(fileNm.lastIndexOf("__X__") + 1);
                var filetype = data[i].DocPath.substring(data[i].DocPath.lastIndexOf("."), data[i].DocPath.length);
                var alt = (filetype.toLowerCase() != ".tiff" && filetype.toLowerCase() != ".tif") ? "JPEG IMAGE" : "TIFF IMAGE";
                img += "<li title='" + fullNm + "' ><img isBase64='false' alt='" + alt + " - " + fileNm + "'  class='imgList' src='" + COMP_SCAN_FILE.SerUrlDomain + "/" + data[i].DocPath + "'/><p>" + fileNm + "</p> </li>";
            }
        }        
        $(imgList).empty();
        $(imgList).append(img);
        $(imgList).find("li").click(function () {
            $(this).toggleClass("scan_active-image");
        });
    }
};

COMP_SCAN_FILE.fnUploadDoc = function (Elem, Dragflg) {
    var files;
    if (!Dragflg) {
        var FileElem = $(Elem).get(0);
        files = FileElem.files;
    }
    else {
        files = Elem;
    }
    if (files.length == 0) return;    

    var formObj = new FormData();
    formObj.append("Action", "UploadShowDoc");
    var Scn = ScanUploadELEM.repositoryPath;
    if (Scn.split('/')[1] == '0') {
        $(ScanUploadELEM.querySelector(".scan_attached-list")).empty();
        $(ScanUploadELEM.querySelector(".scan_attached-list")).append("User Not logged in!");
        return;
    }
    formObj.append("SavePath", Scn);

    for (var i = 0; i < files.length; i++) {
        var fileName = files[i].name;
        var filetype = fileName.substring(fileName.lastIndexOf("."));
        var fileSize = files[i].size;
        var type = files[i].type;
        if (type.indexOf("image") == -1 && type.indexOf("pdf") == -1) {
            alert(filetype + " file type not allowed");
        }
        else {
            formObj.append("files_" + i, files[i]);
        }
    }
    COMP_SCAN_FILE.fnCallFileUpload("UploadDocs", formObj, COMP_SCAN_FILE.fnUploadCallBack, "", "");
    $(Elem).val("");
};

//COMP_SCAN_FILE.SerUrlDomain = "http://svschndt1419.svsglobal.com/TEMP_HOST_RS/";
//COMP_SCAN_FILE.SerUrlDomain = "http://192.169.1.92/SHFLLOS_SCAN_RS/";
COMP_SCAN_FILE.SerUrlDomain = "http://shflappsvr.svsglobal.com/LOS_RS/";

COMP_SCAN_FILE.fnCallFileUpload = function (serviceFor, data, callback, extParam1, extParam2) {

    
//    COMP_SCAN_FILE.SerUrlDomain = "http://192.169.1.92/SHFLLOS_SCAN_RS/";    
    try {
        var URL = "";
        if (serviceFor == "UploadForm")
            URL = COMP_SCAN_FILE.SerUrlDomain + "FileUploadHandler.ashx";
        else
            URL = COMP_SCAN_FILE.SerUrlDomain + "FileManager_Handler.ashx";
        try {
            COMP_SCAN_FILE.fnShowProgress();
        }
        catch (ex) {
        }        
        $.ajax({
            url: URL,
            type: "POST",
            data: data,
            contentType: false,
            processData: false,
            async:false,
            success: function (result) {
                try {
                    COMP_SCAN_FILE.fnRemoveProgress();
                    if (JSON.parse(result).status == false) {
                        alert(JSON.parse(result).error);
                    }
                }
                catch (ex) { }
                callback(serviceFor, result, extParam1, extParam2);
            },
            error: function (err) {
                //alert(err.statusText)
                COMP_SCAN_FILE.fnRemoveProgress();
                alert(err.statusText)
                console.log(err);
            }
        });
    }
    catch (e) {
        alert(e)
    }
}

COMP_SCAN_FILE.extend = {
    CompReady: function (fn) {
        var RepComp = this;
        if (RepComp != undefined && RepComp != null) {
            if (RepComp.hasOwnProperty("length") || RepComp.selector)
                RepComp = RepComp[0];
        }
        RepComp._readyFn = fn;
    },
    SetRepositoryProps: function (Obj) {
        var RepComp = this;
        if (RepComp != undefined && RepComp != null) {
            if (RepComp.hasOwnProperty("length") || RepComp.selector)
                RepComp = RepComp[0];
        }
        var userPk = Obj.userpk ? Obj.userpk : "0";
        userPk = userPk.toString();
        ScanUploadELEM = RepComp;
        if (userPk == "0") {
            $(RepComp.querySelector(".scan_attached-list")).empty();
            $(RepComp.querySelector(".scan_attached-list")).append("User Not logged in!");
            return;
        }
        $(RepComp).prop("repositoryPath", "REPOSITORY/" + userPk);
    },
    LoadDirectory: function () {
        var elem = this;        
        if (elem != undefined && elem != null) {
            if (elem.hasOwnProperty("length") || elem.selector != "")
                elem = elem[0];
        }
        ScanUploadELEM = elem;
        var _path = $(elem).prop("repositoryPath");
        if (_path.split("/")[1] == "0")
        {
            $(elem.querySelector(".scan_attached-list")).empty();
            $(elem.querySelector(".scan_attached-list")).append("User Not logged in!");
            return;
        }
        if (_path != null && _path != undefined && elem.tagName.toLowerCase() == "comp-scan-file") {
            COMP_SCAN_FILE.fnShowAllDoc(_path);
        }
    },
    getSelectedImages: function (path) {
        var elem = this;
        if (elem != undefined && elem != null) {
            if (elem.hasOwnProperty("length") || elem.selector != "")
                elem = elem[0];
        }
        var ImageLi = elem.querySelectorAll("ul.scan_attached-list li.scan_active-image");
        var pathList = [];
        $(ImageLi).each(function () {
            var imgPath = $(this).find("img").attr("filepath");
            var imgSrc = $(this).find("img").attr("src");
            var lst = imgPath.lastIndexOf(".");
            lst = lst == -1 ? 0 : lst;
            var filetype= imgPath.substring(lst+1);
            if (filetype.toLowerCase() == "pdf") {
                imgSrc = $(this).find("img").attr("pdf64");
            }
            var obj = { path: imgPath, src: imgSrc };
            pathList.push(obj);
        });
        return pathList;
    }
};

$.fn.extend(COMP_SCAN_FILE.extend);




var createComponent_scanFile = function (TagName, HtmlSrc) {

    var ElementProto = Object.create(HTMLElement.prototype);
    //var ElementProto = Object.create(Element.prototype);    
    
    ElementProto.LoadDirectory = COMP_SCAN_FILE.extend.LoadDirectory;
    ElementProto.getSelectedImages = COMP_SCAN_FILE.extend.getSelectedImages;
    ElementProto.SetRepositoryProps = COMP_SCAN_FILE.extend.SetRepositoryProps;

    ElementProto._readyFn = null;

    ElementProto.repeatSource = ' <li><img src="{{src}}" alt="" title=""><p>{{docnm}}</p></li>';
    ElementProto.repositoryPath = "REPOSITORY/0";
    /* DEFINITIONS */

    ElementProto.createdCallback = function () {
        /* Fired when the Element is created */
    }
    ElementProto.attachedCallback = function () {
        /* Fired when the Element is attached to the document */

        /* Changing the content & Events */

        //var shadow = this.createShadowRoot();
        var AppendData;
        var shadow = this;
        var componentWidth = this.getAttribute("width") || this.width || "100%";
        var componentHeight = this.getAttribute("height") || this.height || "100%";
        var componentID = this.getAttribute("id") || this.id || "";
        var dataTxt = this.getAttribute("imagedata") || this.imagedata;
        //this.click = this.getAttribute("onclick") || this.onclick;
        var styles = this.getAttribute("compstyle") || this.compstyle;
        var themecolor = this.getAttribute("themecolor") || this.themecolor || "";

        var _type = this.getAttribute("type") || this.type || "viewer";

        styles = "<style>" + styles + "</style>"

        if (dataTxt && typeof dataTxt == "string") {
            dataTxt = dataTxt.replace(/}/g, "");
            dataTxt = dataTxt.replace(/{/g, "");
            AppendData = window[dataTxt];
        }
        else if (typeof dataTxt == "object") {
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
        window.ScanUploadELEM = this;
        $(ScanUploadELEM.querySelector(".scan_attached-list")).empty();
        $(ScanUploadELEM.querySelector(".scan_attached-list")).append("User Not logged in!");
        /* Changing the content */
        /* OPTIONS - EVENTS */

        //var scancomp = this.shadowRoot;
        var scancomp = this;        
        // call the scanning app
        var callscan = scancomp.querySelector(".scan_callscan");
        $(callscan).click(function () {
            var DocFace = $(scancomp.querySelector(".scan_DocFace")).val();
            var DocColor = $(scancomp.querySelector(".scan_DocColor")).val();
            location.href = "DigiconC://digiconlauncher?Color=" + DocColor + "&DocumentFace=" + DocFace;
            COMP_SCAN_FILE.fnLoadScanApp();
        });

        var FileElem = scancomp.querySelector(".scan_drag-div");
        var fileInput = scancomp.querySelector(".scan_scan-file-upload");
        $(FileElem).click(function () {
            $(fileInput).click();
        });       
        FileElem.addEventListener("dragenter", COMP_SCAN_FILE.OnDragEnter, false);
        FileElem.addEventListener("dragover", COMP_SCAN_FILE.OnDragOver, false);
        FileElem.addEventListener("drop", COMP_SCAN_FILE.OnDrop, false);

        //List view of directory
        var listView = scancomp.querySelector(".scan_icon-list-view");
        $(listView).click(function () {
            alert("list view");
        });

        //thumb view of directory
        var thumbView = scancomp.querySelector(".scan_icon-thumbnails");
        $(thumbView).click(function () {
            alert("thumb view");
        });

        /*
        var selectedImage = scancomp.querySelector(".scan_selectedImage");
        $(selectedImage).click(function () {
            var filarr = [];
            $(".scan_attached-list li").each(function () {
                if ($(this).hasClass("scan_active-image")) {
                    filarr.push($(this).find("img").attr("filepath"))
                }
            });
        });        
        */
        /* OPTIONS - EVENTS */


        /* APLLY STYLES */
        var div1 = scancomp.querySelector(".scan_div1");
        var dvHt = $(div1).height();
        var fulHt = componentHeight ? componentHeight : $(scancomp).height();        
        fulHt = fulHt.toString();
        fulHt = fulHt.replace("px", "");
        fulHt = fulHt < 200 ? 500 : fulHt;        
        var UL = scancomp.querySelector("ul.scan_attached-list");
        var ht = fulHt - dvHt - 50;
        $(UL).css({
            "height": ht + "px"
        });
        componentHeight = componentHeight.replace("px", "");
        $(scancomp).css({
            "float": "left",
            "width": componentWidth,
            "height": componentHeight
        });

        var componentForStyles = scancomp.querySelector(".custom-component");
        
        $(componentForStyles).css({
            "float": "left",
            "width": componentWidth,
            "height": componentHeight - 10
        });
        $(scancomp.querySelector(".scan_box-div")).css("height", componentHeight - 25);

        var div1 = scancomp.querySelector(".scan_div1");
        var dvHt = $(div1).height();
        var fulHt = $(scancomp).height() == 0 ? componentHeight : $(scancomp).height();
        fulHt = fulHt.toString();
        fulHt = fulHt.replace("px", "");
        fulHt = fulHt < 200 ? 500 : fulHt;
        var minus = 30;
        if (_type == "save")
            minus = 50;
        var ht = fulHt - dvHt - minus;
     //   $(scancomp.querySelector(".scan_documents")).css("height", ht);        


        var READY_FN_LIST = COMP_SCAN_FILE._readyFn;
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

createComponent_scanFile("comp-scan-file", "scanfile");