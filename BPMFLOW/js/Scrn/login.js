var GlobalXml = [{}];
var gConfig = [];

setLocalStorage("BpmUrl", "http:///172.23.124.134//BPM_RS//");
setLocalStorage("LosUrl", "http:///172.23.124.134//CommonRS//");
setLocalStorage("LosDB", "[PRICING_BPMTEST]");

$(document).ready(function () {
    $("#right_panel").hide();

    $("#UsrPwd").keypress(function (e) {
        if (e.keyCode == 13 || e.which == 13) {
            fnLogin();
        }
    });

});

function fnLoginResult(ServDesc, Obj, Param1, Param2) {
    if (Obj.ResultCount == 0) {
        $("#ErrText").text("UserName/Password wrong.");
        return;
        //fnShflAlert("error", Obj.error);
        //return;
    }
    if (ServDesc == "USR_LOGIN") {
        var Data = JSON.parse(Obj.result_1);
        GlobalRoles = JSON.parse(Obj.result_2);
        GlobalBrnch = JSON.parse(Obj.result_3);

        GlobalXml[0].UsrCd = GlobalXml[0].UsrNm;
        GlobalXml[0].UsrPk = Data[0].UsrPk;
        GlobalXml[0].UsrNm = Data[0].UsrDispNm;
        GlobalXml[0].BpmPk = Data[0].BpmPk;

        localStorage.setItem("UsrPk",GlobalXml[0].UsrPk);
        localStorage.setItem("UsrCd", GlobalXml[0].UsrCd);
        localStorage.setItem("UsrNm", GlobalXml[0].UsrNm);        
        localStorage.setItem("UsrBrnch", GlobalBrnch[0].BrnchFk);
        localStorage.setItem("BpmPk", GlobalXml[0].BpmPk);
        
        

        location.href = "index.html";

        return;
        GlobalXml[0].IsRoleQc = "0";
        GlobalXml[0].IsBranch = "0";
        GlobalXml[0].IsAll = "0";
        GlobalXml[0].IsZone = "0";

        if (GlobalRoles.length > 0) {
            for (var i = 0; i < GlobalRoles.length; i++) {
                if (GlobalRoles[i].SubRole == 20) {
                    GlobalXml[0].IsZone = "1";
                }
                if (GlobalRoles[i].SubRole == 22) {
                    GlobalXml[0].IsRoleQc = "1";
                }
                if (GlobalRoles[i].SubRole == 10) {
                    GlobalXml[0].IsBranch = "1";
                }
                if (GlobalRoles[i].Role == 99) {
                    GlobalXml[0].IsAll = "1";
                }
                if (GlobalRoles[i].IsAdmin == "Y") {
                    GlobalXml[0].IsAdmin = "Y";
                }
            }
        }
        if (GlobalXml[0].IsAll == "1") {
            LoadHtmlDiv("cases.html");
            $("#link_Dash").show();
            $("#link_Dash").click(function () { LoadHtmlDiv("cases.html"); })
        }
        else if (GlobalXml[0].IsAdmin == "Y") {
            LoadHtmlDiv("admin.html");
            $("#link_Dash").show();
            $("#link_Dash").click(function () { LoadHtmlDiv("admin.html"); })
        }
        else {
            fnLoadDashDtls();
            $("#link_Dash").click(function () { fnLoadDashDtls(); })
        }
    }
    if (ServDesc == "CMP_CONFIG") {
        var gCmpConfig = []; 
        try { gCmpConfig = JSON.parse(Obj.result); } catch (e) { }
        if (gCmpConfig.length > 0) {
            for (var i = 0; i < gCmpConfig.length; i++) {
                gConfig[gCmpConfig[i].ConfigCd] = gCmpConfig[i].ConfigVal;
            }
        }
    }
}

function fnLogin() {
    
    GlobalXml[0].UsrNm = $("#UsrNm").val();
    GlobalXml[0].UsrPwd = $("#UsrPwd").val();

    if (GlobalXml[0].UsrNm == "" || GlobalXml[0].UsrPwd == "") {
        $("#ErrText").text("Enter User Name and password");
        return;
    } 

    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["USR_LOGIN", JSON.stringify(GlobalXml), "", ""] };
    fnCallWebService("USR_LOGIN", objProcData, fnLoginResult, "MULTI","");
    
    /*
    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["CMP_CONFIG"] };
    fnCallLOSWebService("CMP_CONFIG", objProcData, fnLoginResult, "MULTI", "");
    */
}