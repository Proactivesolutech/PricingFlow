var LdDtls = [];
$(document).ready(function () {
    fnAdminGetLead();
    $("#Lead_Info").show();
});

function fnAdminGetLead() {
    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["GETLEAD"] }
    fnCallLOSWebService("GETLEAD", objProcData, fnAdminResult, "MULTI");
}


function fnAdminResult(ServDesc, Obj, Param1, Param2) {
    if (!Obj.status) {
        fnShflAlert("error", Obj.error);
        return;
    }

    if (ServDesc == "GETLEAD") {
        LdDtls = JSON.parse(Obj.result);
        fnGetBpmHelpFor("LEAD_LIST", LdDtls);
    }
    if (ServDesc == "PENDING_LD_DTLS") {
        debugger;
        var Data = JSON.parse(Obj.result_1);
        var SetData;

        if (Data.length > 0)
            SetData = Data;
        else
            SetData = JSON.parse(Obj.result_2);

        GlobalXml[0].PrdCd = SetData[0].PCd;
        GlobalXml[0].PrdNm = SetData[0].PrdNm;
        GlobalXml[0].LeadNm = SetData[0].LeadNm;;
        GlobalXml[0].LeadID = SetData[0].LeadID;;
        GlobalXml[0].PrdFk = SetData[0].PrdFk;;
        GlobalXml[0].AgtNm = SetData[0].AgtNm;;
        GlobalXml[0].AgtFk = SetData[0].AgtFk;;
        GlobalXml[0].Branch = SetData[0].Branch;;
        GlobalXml[0].AppNo = SetData[0].AppNo;
        GlobalXml[0].GlobalDt = SetData[0].ServerDt;
        GlobalXml[0].LajFk = SetData[0].LajFk;
        GlobalXml[0].RefPk = SetData[0].Pk;
        GlobalXml[0].LajAgtFK = SetData[0].LajAgtFK;
        GlobalXml[0].JobAgentName = SetData[0].JobAgentName;
        GlobalXml[0].ServiceType = SetData[0].ServiceType;
        GlobalXml[0].LfjFk = SetData[0].LfjFk;
        GlobalXml[0].GrpCd = SetData[0].GrpCd;
        LoadHtmlDiv(Param2);
    }
}

function fnAdminListLead(LeadData, ScrnData) {
    debugger;
    if (LeadData.length > 0) {
        $("#admin_list_lead").empty();
        for (var i = 0; i < LeadData.length; i++) {
            var listdata = "";
            listdata += '<li val="HIS">SEE HISTORY</li>';
            if (ScrnData.length > 0) {
                $.grep(ScrnData, function (Elm) {
                    if (Elm.DataPk == LeadData[i].LeadPk) {
                        listdata += '<li val="' + Elm.Cd + '||' + Elm.Url + '||' + Elm.DpdFk + '">' + Elm.Page + '</li>';
                    }
                });
            }
            
            $("#admin_list_lead").append
            (
                '<ul>' +
                      '<li><i class="' + LeadData[i].PrdIcon + '"></i>' +
                        '<p>'+LeadData[i].PrdNm+'</p>' +
                      '</li>' +
                      '<li>' +
                        '<p class="disable">'+LeadData[i].LeadID+'</p>' +
                        '<p class="font-13">' + LeadData[i].LedNm + '</p>' +
                      '</li>' +
                      '<li>' + LeadData[i].Branch + '</li>' +
                      '<li>' +
                        '<p class="font-10">' + LeadData[i].Users + '</p>' +
                      '</li>' +
                      '<li class="status">' +
                        '<p class="font-13 thisVal=\'' + JSON.stringify(LeadData[i]) + '\'>' + LeadData[i].PageNm + '</p>' +
                        // class="bg bg1"  onclick=fnAdminViewData("C",this)
                      '</li>' +
                      '<li>' +
                          '<label>Completed Task</label>' +
                          '<div class="select-focus">' +
                              '<input id="sel_scrn_' + i + '" placeholder="Select" onkeypress="return false" selval="-1" name="select" class="autofill">' +
                              '<i class="icon-down-arrow"></i>' +
                              '<ul class="custom-select" style="display:none;">' +
                                  listdata +
                              '</ul>' +
                          '</div>' +
                      '</li>' +
                       '<li>' +
                           '<input type="button" thisVal=\'' + JSON.stringify(LeadData[i]) + '\' onclick=fnAdminViewData("P",this,"sel_scrn_' + i + '") value="Go"/>' +
                       '</li>' +
                      '<div class="clear"></div>' +
                    '</ul>'
              )
        }
    }
}

function fnAdminViewData(Action, StrLeadDtls, PgCd) {
    debugger;
    var LeadDtls = JSON.parse($(StrLeadDtls).attr("thisVal"));
    var Get_ScrnDtls = [];
    var Get_ScrObj = {};

    var URL = "";
    var LeadPk = LeadDtls.LeadPk;
    var version = LeadDtls.BnoBvmFk;
    GlobalXml[0].FwdDataPk = LeadPk;
    

    if (Action == "P") {
        if ($("#" + PgCd).attr("selval") == "HIS") {
           
            window.open("LeadHis.html?lead=" + LeadPk + "&version=" + version + "", "newWinCAM",
                            "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=30,top=30,width=1200,height=600");
            return;
        }

        var PageAttr = $("#" + PgCd).attr("selval").split("||");
        PgCd = PageAttr[0];
        URL = PageAttr[1];
        GlobalXml[0].DpdFk = PageAttr[2];

        if (PgCd.toUpperCase() == "FIR" || PgCd.toUpperCase() == "FIO" || PgCd.toUpperCase() == "CF" || PgCd.toUpperCase() == "DV"
            || PgCd.toUpperCase() == "TV" || PgCd.toUpperCase() == "LV") {
            fnShflAlert("warning", "Provision not provided !!");
            return false;           
        }       
    }
    else {
        PgCd = LeadDtls.BudCd;
        URL = LeadDtls.BudURL;
    }
    
    Get_ScrObj["DataPk"] = LeadPk;
    Get_ScrObj["Cd"] = PgCd;
    Get_ScrObj["KeyDpdFk"] = GlobalXml[0].DpdFk;

    if (PgCd == "FIR" || PgCd == "FIO" || PgCd == "FIS" || PgCd == "DV" || PgCd == "CF" || PgCd == "LV" || PgCd == "TV")
        GlobalXml[0].IsRoleQc = "1";
    else
        GlobalXml[0].IsRoleQc = "0";

    Get_ScrnDtls.push(Get_ScrObj);
    
    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["PENDING_LD_DTLS_ADM", JSON.stringify(GlobalXml), "", JSON.stringify(Get_ScrnDtls)] }
    fnCallLOSWebService("PENDING_LD_DTLS", objProcData, fnAdminResult, "MULTI", URL);
}