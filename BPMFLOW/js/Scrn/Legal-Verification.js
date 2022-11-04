var LedAgtGlobal = [{}];
var LfjFk = 0; var Dtl_Fk = 0; var Action = "Save";
var Agt_Loadhtml = "";
$(document).ready(function () {
    LedAgtGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    LedAgtGlobal[0].LeadId = GlobalXml[0].LeadID;
    LedAgtGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    LedAgtGlobal[0].BranchNm = GlobalXml[0].Branch;
    LedAgtGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    LedAgtGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    LedAgtGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    LedAgtGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    LedAgtGlobal[0].ServiceType = GlobalXml[0].ServiceType;
    LedAgtGlobal[0].RefPk = GlobalXml[0].RefPk;
    LedAgtGlobal[0].LajFk = GlobalXml[0].LajFk;
    LedAgtGlobal[0].LajAgtFK = GlobalXml[0].LajAgtFK;
    $("#agt_name").text(GlobalXml[0].JobAgentName);
    $("#lead_id").text(GlobalXml[0].LeadID);
    Agt_Loadhtml = GlobalXml[0].Agt_loadHtml;

    LfjFk = GlobalXml[0].LfjFk;

    if (LfjFk == 0) {
        fnSelLedAddr();
        Action = "Save";
    }
    else {
        fnSelSavedData();
        Action = "Edit";
    }

    fnDrawDatePicker();
    $("#" + Agt_Loadhtml + " .datepicker").each(function () {
        fnRestrictDate($(this));
    });
});

function fnSelLedAddr() {
    var PrcObj = { ProcedureName: "PrcShflLedAgtMgt", Type: "SP", Parameters: ["SelDetails", JSON.stringify(LedAgtGlobal)] };
    fnCallLOSWebService("SelDetails", PrcObj, fnAgentTechFinResult, "MULTI");
}

function fnSelSavedData() {
    var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: ["Select", JSON.stringify(LedAgtGlobal), "", "", LfjFk] };
    fnCallLOSWebService("SelDetails", PrcObj, fnAgentTechFinResult, "MULTI");
}

function fnAgentFinResult(ServiceFor, Obj, Param1, Param2) {
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServiceFor == "SelDetails") {
        var data = JSON.parse(Obj.result);
        if (data[0] && data[0] != null) {
            Dtl_Fk = data[0].DtlFk;
            var ActorType = data[0].ActorType == 0 ? "Applicant" : "CoApplicant";
            var CommonDiv = $(
                      '<div class="div-left grid-50">' +
                        '<p>' + LedAgtGlobal[0].LeadId + '</p>' +
                        '<p>' + data[0].AppNm + '</p>' +
                        '<p> <span>' + ActorType + '</span> , <span>' + data[0].Gender + '</span></p>' +
                        '<p>' + data[0].Contact + '</p>' +
                        '<p>' +  LedAgtGlobal[0].PrdNm + '</p>' +
                      '</div>' +
                      '<div class="div-right grid-50">' +
                        '<ul class="">' +
                          '<li class="width-9"> <span class="bg">' + data[0].AddrType + '</span> </li>' +
                          '<li class="width-12">' +
                            '<p>' + data[0].DoorNo + ',' + data[0].Street + '</p>' +
                            '<p>' + data[0].PlotNo + ',' + data[0].Building + '</p>' +
                            '<p>' + data[0].Area + ',' + data[0].District + '</p>' +
                            '<p>' + data[0].State + ',' + data[0].Country + '</p>' +
                            '<p>' + data[0].Pincode + '</p>' +
                          '</li>' +
                        '</ul>' +
                      '</div>' +
                      '<div class="clear"></div>');
            $(".field-content").append(CommonDiv);
            if (data.length > 0)
                fnSetValues(Agt_Loadhtml, data)
        }
    }
    if (ServiceFor == "Save_Agt_data") {
        var PkData = JSON.parse(Obj.result_1);
        Action = "Edit";
        LfjFk = PkData[0].HdrFk;
        Dtl_Fk = PkData[0].DtlFk;
    }
}
function fnReprtSts(elem) {
    var cls = $(elem).attr("class");
    if (cls == "icon-positive") {
        var contentdiv = $(".agent-content-drilldown").find("div.fidt2");
        var lihtml = $(contentdiv).find("ul.fom-controls li.div-right.status");
        $(lihtml).find("p.bg.bg1 i").attr("class", "icon-negative");
        $(lihtml).find("input[key=agt_rptstatus]").val(0);
    }
    else if (cls == "icon-negative") {
        var contentdiv = $(".agent-content-drilldown").find("div.fidt2");
        var lihtml = $(contentdiv).find("ul.fom-controls li.div-right.status");
        $(lihtml).find("p.bg.bg1 i").attr("class", "icon-positive");
        $(lihtml).find("input[key=agt_rptstatus]").val(1);
    }
}
function fnSaveChangedData()
{
    var HdrJson = {};
    HdrJson = fnGetFormValsJson_IdVal(Agt_Loadhtml);
    var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: ["Save", JSON.stringify(LedAgtGlobal), JSON.stringify(HdrJson),"",LfjFk,Dtl_Fk] };
    fnCallLOSWebService("Save_Agt_data", PrcObj, fnAgentFinResult, "MULTI");
}