function fnBPMProjResult(ServDesc, Obj, Param1, Param2) {

    if (!Obj.status) {
        fnShflAlert("error",Obj.error);
        return;
    }

    /*  1. Method for BPM Access to get Option List ( Return, Confirm & Move next, Conditions etc ) & 
        5. Method to get the Previous Processes Executed User List with Roles ( For Query Module ) */
    if (ServDesc == "GET_PGDTLS") {
        var PageDtls = JSON.parse(Obj.result_1);
        var RtnDetails = JSON.parse(Obj.result_2);
        var BtnDetails = JSON.parse(Obj.result_3);
        var HisDtls = JSON.parse(Obj.result_4);
        //if (BtnDetails[0].JsonData == "")
		if (BtnDetails.length == 0 ||  BtnDetails[0].JsonData == "")//Edited by Vijay S 31-7-2017
            BtnDetails = [];

        fnCallBackFromBpm(ServDesc, PageDtls, RtnDetails, BtnDetails, HisDtls, Obj);
    }

    // 2. Method for BPM Access to Insert next flow ( Action for Option List )
    if (ServDesc == "FORWARD_DATA" || ServDesc == "DEV_FORWARD_DATA") {
        //fnCallBackFromBpm(ServDesc);
        fnBtnTemplate(0);
        fnSelectKeyList();
    }

    /*  3. Method to get the Pending List from BPM ( Cases List )
        4. Method to get the List of Process, the role involves ( does not include Process having Trigger ) */
    if (ServDesc == "GET_PENDINGS_LIST") {
        GlobalXml[0].UsrPk = JSON.parse(Obj.result_1)[0].UsrFk;
        var Data = JSON.parse(Obj.result_2);
        //var Data2 = JSON.parse(Obj.result_3);
        //fnCallBackFromBpm(ServDesc, Data, []);
    }

    if (ServDesc == "LEAD_CREATE") {
        //fnCallBackFromBpm(ServDesc);
        fnBtnTemplate(0);
        fnSelectKeyList();
    }

    if (ServDesc == "LEAD_LIST") {
        var Data1 = JSON.parse(Obj.result_1);
        var Data2 = JSON.parse(Obj.result_2);
        //fnCallBackFromBpm(ServDesc, Data1, Data2);
    }
}

function fnGetBpmHelpFor(Action, Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, Param9, Param10) {
    
    if (Action == "GET_PGDTLS") {
        var GlobalBpmXml = [{}];
        
        GlobalBpmXml[0].HisPK = Param1;
        GlobalBpmXml[0].CurProcFk = Param2;
        GlobalBpmXml[0].FwdDataPk = Param3;
        GlobalBpmXml[0].CurVerFlowPk = Param4;
        GlobalBpmXml[0].UsrPk = Param5;
        GlobalBpmXml[0].BrnchFk = Param6;
        
        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["GET_ENTRY_STS", JSON.stringify(GlobalBpmXml)] }
        fnCallWebService(Action, objProcData, fnBPMProjResult, "MULTI");
    }

    else if (Action == "FORWARD_DATA") {
        var GlobalBpmXml = [{}];

        GlobalBpmXml[0].HisPK = Param1;
        GlobalBpmXml[0].CurProcFk = Param2;
        GlobalBpmXml[0].FwdDataPk = Param3;
        GlobalBpmXml[0].CurVerFlowPk = Param4;
        GlobalBpmXml[0].UsrPk = Param5;
        GlobalBpmXml[0].TgtPageID = Param6;
        GlobalBpmXml[0].DblEntry = Param7;
        GlobalBpmXml[0].BrnchFk = Param9;
        GlobalBpmXml[0].SanFk = Param10;
        
        var ValData = [];

        debugger;

        $("#designDiv-form-area .form-field,#designDiv-form-area-2 .form-field,#designDiv-form-area-3 .form-field").each(function () {
            var InpObj = $(this).find(".Elem_Inp_Val");
            var ValObj = {};
            ValObj["id"] = $(InpObj).attr("id");
			//added by Vijay S
            if (!!$(InpObj).attr("type") && $(InpObj).attr("type") == "file") {
                //var remarksText = (!!$(InpObj).parent().find(".fileupldinput") && !!$(InpObj).parent().find(".fileupldinput").val().trim()) ? " (" + $(InpObj).parent().find("input[type='text']").val() + ")" : "";
                var files = $(InpObj).get(0).files;
                var value = "";
                for (var i = 0; i < files.length; i++) {
                    var path = files[i].path;
                    //value += "<a class=''fileDownload'' href=''../RS/" + path + "'' download>" + path.substring(path.lastIndexOf("___") + 3)+ "</a>" + remarksText ;
                    value += path.substring(path.lastIndexOf("/") + 1) + "|";
                }                
                ValObj["idval"] = value.replace(/\|$/,"");
            } else
				ValObj["idval"] = $(InpObj).val();

            ValData.push(ValObj);
            // console.log(ValData);
        });

        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["FORWARD_DATA", JSON.stringify(GlobalBpmXml), JSON.stringify(ValData), Param8, GlobalXml[0].IsReject] };
        fnCallWebService(Action, objProcData, fnBPMProjResult, "MULTI");
    }
    else if (Action == "DEV_FORWARD_DATA") {
        var GlobalBpmXml = [{}];

        GlobalBpmXml[0].UsrPk = Param1;
        GlobalBpmXml[0].HisPK = Param2;
        GlobalBpmXml[0].BrnchFk = Param3;
        GlobalBpmXml[0].LvlNo = Param4;
        
        var objProcData = { ProcedureName: "PrcBpmDevMatrix", Type: "SP", Parameters: ["DEV_FORWARD_DATA", JSON.stringify(GlobalBpmXml), Param5] };
        fnCallWebService(Action, objProcData, fnBPMProjResult, "MULTI");
    }
    else if (Action == "GET_PENDINGS_LIST") {
        var GlobalBpmXml = [{}];

        GlobalBpmXml[0].UsrPk = Param1;
        GlobalBpmXml[0].UsrCd = Param2;
        
        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["GET_ENTRY_DATA", JSON.stringify(GlobalBpmXml)] }
        fnCallWebService(Action, objProcData, fnBPMProjResult, "MULTI", Param1);
    }
    else if (Action == "LEAD_CREATE") {
        var objProcData = { ProcedureName: "PrcLeadListing", Type: "SP", Parameters: [Param2, JSON.stringify(Param1), Param3] }
        fnCallWebService(Action, objProcData, fnBPMProjResult, "MULTI", Param1);
    }
    else if (Action == "LEAD_LIST") {
        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["LEADHIS", "", JSON.stringify(Param1)] }
        fnCallWebService(Action, objProcData, fnBPMProjResult, "MULTI");
    }
}

//added by Vijay for getting web-config details
function fnGetAppSettingsValue(prcObject,propertyName) {    
    var Url = getLocalStorage("BpmUrl") + "RestServiceSvc.svc/fnGetAppSettingsValue";
    $.ajax({
        url: Url,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"ConfigKey":"' + prcObject + '"}',
        success: function (result) {            
            GlobalXml[0][propertyName] = JSON.parse(result).ConfigValue;
        },
        error: function (result) {            
            console.log('Error: ', result);
        }
    });
}

//Added by Vijay S for File Attachment field
function fnFileAttacher(elem, isOnChange) {    
    var savePath = GlobalXml[0].FileUpldPath + "/" + (!!GlobalXml[0].FwdDataPk ? GlobalXml[0].FwdDataPk : ProcessIDKey) + "/";
    if (!!isOnChange && isOnChange == true) {
        var ELEM = $(elem).get(0);
        var files = ELEM.files;
        if (files.length == 0) { return; }
        else {
            for (var i = 0; i < files.length; i++) {
                var d = new Date();
                files[i].path = savePath + d.toLocaleString().replace(/[\/,: ]+/gi, "-") + "___" + files[i].name;
                console.log(files[i]);
            }
        }
    } else fnFileUploadHandler(elem, 'Attachment_UPLOAD', savePath, fnFileUploadHandlerResult);    
}

function fnFileUploadHandler(FileELEM, Action, savePath, callback, Param1, Param2) {
    var ELEM = $(FileELEM).get(0);
    Param1 = ELEM.id;
    var files = ELEM.files;
    if (files.length == 0) { return false; }
    var UploadObj = new FormData();
    var remarksText = (!!$(ELEM).parent().find(".fileupldinput") && !!$(ELEM).parent().find(".fileupldinput").val() && !!$(ELEM).parent().find(".fileupldinput").val().trim()) ? " (" + $(ELEM).parent().find("input[type='text']").val() + ")" : "";
    UploadObj.append("Action", "Attachment_UPLOAD");
    UploadObj.append("savePath", savePath);
    UploadObj.append("ProcKey", (!!GlobalXml[0].FwdDataPk ? GlobalXml[0].FwdDataPk : ProcessIDKey));
    UploadObj.append("RefKey", (!!GlobalXml[0].HisPK ? GlobalXml[0].HisPK : 0));
    UploadObj.append("Remarks", remarksText);
    for (var i = 0; i < files.length; i++) {
        UploadObj.append("file_" + i, files[i]);
        UploadObj.append("filepath_" + i, files[i].path);
    }
    fnFileUploadService(Action, UploadObj, callback, Param1, Param2);
}

function fnFileUploadService(serviceFor, formData, callback, extParam1, extParam2, callback_2) {
    debugger;
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

function fnFileUploadHandlerResult(ServiceFor, Obj, Param1, Param2) {        
    if(!!Obj) console.log("Error in " + Obj);
}