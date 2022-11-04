var LedAgtGlobal = [{}];
$(document).ready(function () {
    debugger;
    /* click upload file when clicking the span element */
    $("#Spn_reportupload").click(function () { $("#FIReportUpload").click(); });
    $("#FIReportUpload").on("change", function () {
        var savePth = "SHFL_DOCS/REPORTS/" + LedAgtGlobal[0].LeadPk + "/";
        fnUploadReport(this, 'FIR_UPLOAD', savePth, fnFieldInvResult);
    });

    LedAgtGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    LedAgtGlobal[0].LeadId = GlobalXml[0].LeadID;
    LedAgtGlobal[0].AppNo = GlobalXml[0].AppNo;
    LedAgtGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    LedAgtGlobal[0].BranchNm = GlobalXml[0].Branch;
    LedAgtGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    LedAgtGlobal[0].AgtNm = GlobalXml[0].AgtNm;
    LedAgtGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    LedAgtGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    LedAgtGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    LedAgtGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    LedAgtGlobal[0].LajFk=GlobalXml[0].LajFk;
    LedAgtGlobal[0].RefPk=GlobalXml[0].RefPk;
    LedAgtGlobal[0].LajAgtFK = GlobalXml[0].LajAgtFK;
    LedAgtGlobal[0].ServiceType = GlobalXml[0].ServiceType;
    fnFieldInvLoad();
});
function fnFieldInvLoad(elem) {
    var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: ["Select", JSON.stringify(LedAgtGlobal)] };
    fnCallLOSWebService("FieldDetails", PrcObj, fnFieldInvResult, "MULTI");
}
function fnFieldInvResult(ServiceFor, Obj, Param1, Param2) {
    if (ServiceFor == "FIR_UPLOAD") {
        alert(Obj);
        var UploadData = JSON.parse(Obj.result);
        console.log(UploadData);
    }
    if (ServiceFor == "FieldDetails") {
        return;
        var leadData = JSON.parse(Obj.result_1);
        if (leadData[0] && leadData[0] != null) {
            $("#PrdName").attr("ProductFk", leadData[0].ProductFk);
            $("#PrdName").text(leadData[0].ProductName);
            $("#LeadId").text(leadData[0].LeadId);
            $("#Appno").text(leadData[0].ApplicationNo);
            $("#BranchNm").attr("BranchFk", leadData[0].BranchFk);
            $("#BranchNm").text(leadData[0].BranchNm);
            $("#AgentName").attr("AgentFk", leadData[0].AgtFk);
            $("#AgentName").text(leadData[0].AgentName);
        }
        var data = JSON.parse(Obj.result_2);
        if (data[0] && data[0] != null) {
            var ActorType = "";
            if (data[0].ActorType == 2)
                ActorType = "Guarantor";
            else if (data[0].ActorType == 1)
                ActorType = "CoApplicant";
            else
                ActorType = "Applicant";

            var CommonDiv =
                      '<div class="div-left grid-50">' +
                        '<p>' + data[0].LeadId   + '</p>' +
                        '<p>' + data[0].AppNm    + '</p>' +
                        '<p> <span>' + ActorType + '</span> , <span>' + data[0].Gender + '</span></p>' +
                        '<p>' + data[0].Contact  + '</p>' +
                      '</div>' +
                      '<div class="div-right grid-50">' +
                        '<ul class="">' +
                          '<li class="width-9"> <span class="bg">' + data[0].AddrType + '</span> </li>' +
                          '<li class="width-12">' +
                            '<p>' + data[0].DoorNo  + ',' + data[0].Street   + '</p>' +
                            '<p>' + data[0].PlotNo  + ',' + data[0].Building + '</p>' +
                            '<p>' + data[0].Area    + ',' + data[0].District + '</p>' +
                            '<p>' + data[0].State   + ',' + data[0].Country  + '</p>' +
                            '<p>' + data[0].Pincode + '</p>' +
                          '</li>' +
                        '</ul>' +
                      '</div>' +
                      '<div class="clear"></div>' +
                    '</div>'
            $(".field-content").append(CommonDiv);
        }
    }
}
function fnReprtSts(elem) {
    alert($(".status").find("input[key=agt_rptstatus]").val());
    var cls = $(elem).attr("class");
    if (cls == "icon-positive") {
        var contentdiv = $("#maindiv").find("div.fidt2");
        var lihtml = $(contentdiv).find("ul.fom-controls li.div-right.status");
        $(lihtml).find("p.bg.bg1 i").attr("class", "icon-negative");
        $(lihtml).find("input[key=agt_rptstatus]").val(0);
    }
    else if (cls == "icon-negative") {
        var contentdiv = $("#maindiv").find("div.fidt2");
        var lihtml = $(contentdiv).find("ul.fom-controls li.div-right.status");
        $(lihtml).find("p.bg.bg1 i").attr("class", "icon-positive");
        $(lihtml).find("input[key=agt_rptstatus]").val(1);
    }
}
function fnSaveChangedData() {
    var HdrJson = {};
    if ($(".div-right.status").find("input[key=agt_rptstatus]").val() == "")
    {
        $(".div-right.status").find("input[key=agt_rptstatus]").val(0);
    }
    HdrJson = fnGetFormValsJson_IdVal("maindiv");
    var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: ["Save", JSON.stringify(LedAgtGlobal), JSON.stringify(HdrJson)] };
    fnCallLOSWebService("Save_Agt_data", PrcObj, fnFieldInvResult, "MULTI");
}

function fnUploadReport(FileELEM, Action, savePath, callback, Param1, Param2) {
    var ELEM = $(FileELEM).get(0);
    var files = ELEM.files;
    if (files.length == 0) { return; }
    var UploadObj = new FormData();
    UploadObj.append("Action", "ReportUpload");
    UploadObj.append("savePath", savePath);
    alert(UploadObj);
    for (var i = 0; i < files.length; i++) {
        UploadObj.append("file_" + i, files[i]);
    }
    fnCallFileUploadService(Action, UploadObj, callback, Param1, Param2);
}
