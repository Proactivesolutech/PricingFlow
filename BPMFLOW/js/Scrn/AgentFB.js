var LedAgtGlobal = [{}];
var RptJson = [];
var LfjFk = 0; var Dtl_Fk = 0; var Action = "Save";
var Agt_Loadhtml = "";
var IsFinalConfirm = "";
var showdata = "";


$(document).ready(function () {
    debugger;
    LedAgtGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    $("#Spn_reportupload").click(function () { $("#FIReportUpload").click(); });
    $("#FIReportUpload").on("change", function () {
        var savePth = "SHFL_DOCS/REPORTS/" + LedAgtGlobal[0].LeadPk + "/";
        fnUploadReport(this, 'FIR_UPLOAD', savePth, fnAgentResult);
    });

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
    //$("#agt_name").text(GlobalXml[0].AgtNm);

    if (GlobalXml[0].LeadID.indexOf('<br/>') > 0) {
        var ledid = GlobalXml[0].LeadID.split('<br/>');
        $('#lead_id').text(ledid[0]);
    }
    else {
        $('#lead_id').text(GlobalXml[0].LeadID);
    }

    Agt_Loadhtml = GlobalXml[0].Agt_loadHtml;

    LfjFk = GlobalXml[0].LfjFk;

    if (LedAgtGlobal[0].ServiceType == 5) {
        $("#agt_Scr_Typ").text("Technical Verification");
    }
    else if (LedAgtGlobal[0].ServiceType == 4) {
        $("#agt_Scr_Typ").text("Legal Verification");
    }
    else if (LedAgtGlobal[0].ServiceType == 3) {
        $("#agt_Scr_Typ").text("Collection Feedback");
        $("#Scrn_Nm").text("Collection Feedback");
    }
    else if (LedAgtGlobal[0].ServiceType == 2) {
        $("#agt_Scr_Typ").text("Document Verification");
    }
    else if (LedAgtGlobal[0].ServiceType == 1) {
        $("#agt_Scr_Typ").text("Field Investigation(Office)");
        $("#Scrn_Nm").text("Field Investigation(Office)");
    }
    else if (LedAgtGlobal[0].ServiceType == 0) {
        $("#agt_Scr_Typ").text("Field Investigation(Residence)");
        $("#Scrn_Nm").text("Field Investigation(Residence)");
    }
    else if (LedAgtGlobal[0].ServiceType == 6) {
        $("#agt_Scr_Typ").text("Seller Verification");
        $("#Scrn_Nm").text("Seller Verification");
    }

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
$(function () {
    var isBC = window.FromBranchCredit;
    var isCO = window.CREDIT_APPROVER_NO;
    isCO = isCO ? isCO : "";
    isBC = isBC ? isBC : "";
    if (isCO == "" && isBC == "") {
        fnCallScrnFn = function (FinalConfirm) {
            IsFinalConfirm = FinalConfirm;
            fnSaveChangedData();
        }
    }

});
function fnSelLedAddr() {
    var PrcObj = { ProcedureName: "PrcShflLedAgtMgt", Type: "SP", Parameters: ["SelDetails", JSON.stringify(LedAgtGlobal)] };
    fnCallLOSWebService("SelDetails", PrcObj, fnAgentResult, "MULTI", "Add");
}

function fnSelSavedData() {
    
    try {
        if (flag == 1) {
            showdata = lapfk + '~' + ServiceType
        }
        else
            showdata = "";
    }
    catch (e) {
        showdata = "";
    }
    var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: ["Select", JSON.stringify(LedAgtGlobal), "", "", LfjFk, "", "", "", showdata] };
    fnCallLOSWebService("SelDetails", PrcObj, fnAgentResult, "MULTI", "Edit");
}

function fnAgentResult(ServiceFor, Obj, Param1, Param2) {

    if (!Obj.status && ServiceFor != "FIR_UPLOAD") {
        console.log(Obj);
        alert(Obj.error);
        return;
    }

    if (ServiceFor == "FIR_UPLOAD") {
        try {
            var Result = JSON.stringify(Obj);
            var ResultObj = JSON.parse(JSON.parse(Result));

            if (ResultObj.status.toString() == "true") {
                var ResObj = JSON.parse(ResultObj.result);
                for (var i = 0; i < ResObj.length; i++) {
                    var Path = ResObj[i].toString();
                    var n = Path.lastIndexOf("_") + 1;

                    $("#attach_spn").append('<span pk="0" ><i class="icon-attach"></i>'
                        + Path.substr(n, Path.length) + '</span>');

                    var PathObj = {};
                    PathObj["RptPath"] = Path;
                    PathObj["RptDocFk"] = 0;
                    PathObj["RptPk"] = 0;

                    RptJson.push(PathObj);
                }
            }
        } catch (e) { console.log(e); }
    }
    if (ServiceFor == "SelDetails") {
        debugger;
        var data; var DocData = [];
        var AdrData=[];
        if (Param2 == "Add") {
            if (LedAgtGlobal[0].ServiceType == 2) {
                data = JSON.parse(Obj.result_1);
                //DocData = JSON.parse(Obj.result_2);
                AdrData = JSON.parse(Obj.result_2);
            }
            else {
                data = JSON.parse(Obj.result);
            }
        }
        else {
            RptJson = JSON.parse(Obj.result_1);
            data = JSON.parse(Obj.result_2);

            if (LedAgtGlobal[0].ServiceType == 2) {
              //  DocData = JSON.parse(Obj.result_3);
            }
        }

        $("#attach_spn").empty();
        if (RptJson.length > 0) {
            for (var j = 0; j < RptJson.length; j++) {
                var Path = RptJson[j].RptPath.toString();
                var n = Path.lastIndexOf("_") + 1;

                $("#attach_spn").append('<span pk="' + RptJson[j].RptPk + '" ><i class="icon-attach"></i>'
                    + Path.substr(n, Path.length) + '</span>');
            }
        }

        if (DocData.length > 0) {

            for (var i = 0; i < DocData.length; i++) {

                $(".agt_Doc_ver").append(
                    '<ul class="rowGrid">' +
                      '<li>' +
                        '<h5>' + DocData[i].DocCategory + '</h5>' +
                        '<p>' + DocData[i].DocSubCategory + '-' + DocData[i].DocNm + '</p>' +
                      '</li>' +
                      '<li>' +
                      '<i class="icon-document doc-view" docpath="' + DocData[i].DocPath + '" onclick="fnOpenDocs(this)"></i>' +
                      '</li>' +
                      '<li>' +
                        '<textarea name="text" colkey="agt_DocRmks">' + DocData[i].agt_DocRmks + '</textarea>' +
                      '</li>' +
                      '<li class="div-right status">' +
                        '<p class="bg bg1"><i class="icon-positive" id ="docsts' + [i] + '" onclick="fnReprtSts(this);"></i></p>' +
                        '<input type="hidden" name="text" colkey="agt_DocSts" value="' + DocData[i].agt_DocSts + '"/>' +
                      '</li>' +
                       '<li>' +
                        '<input type="hidden" name="text" colkey="agt_DocFk" value="' + DocData[i].agt_DocFk + '"/>' +
                        '<input type="hidden" name="text" colkey="DPk" value="' + DocData[i].DPk + '"/>' +
                      '</li>' +
                    '</ul>'
                );
                if (DocData[i].agt_DocSts == 0) {

                    $("#docsts" + i).attr("class", "icon-negative");
                    $("#docsts" + i).closest("p.bg").attr("class", "bg bg2");
                }
                if (DocData[i].agt_DocSts == 1) {
                    $("#docsts" + i).attr("class", "icon-no-status");
                    $("#docsts" + i).closest("p.bg").attr("class", "bg bg7");
                }
                if (DocData[i].agt_DocSts == 2) {
                    $("#docsts" + i).attr("class", "icon-positive");
                    $("#docsts" + i).closest("p.bg").attr("class", "bg bg1");
                }
            }
        }

        if (data[0] && data[0] != null ) {
            $("#agt_name").text(data[0].AgentName);
            Dtl_Fk = data[0].DtlFk;

            var ActorType = "Applicant";
            if (data[0].ActorType == 2)
                ActorType = "Guarantor";
            else if (data[0].ActorType == 1)
                ActorType = "CoApplicant";

            if (data[0].agt_rptstatus == 0) {
                $(".fidt2 #rptsts").attr("class", "icon-negative");
                $(".fidt2 #rptsts").closest("p").attr("class", "bg bg2");

            }
            else if (data[0].agt_rptstatus == 1) {
                $(".fidt2 #rptsts").attr("class", "icon-no-status");
                $(".fidt2 #rptsts").closest("p").attr("class", "bg bg7");

            }
            else if (data[0].agt_rptstatus == 2) {
                $(".fidt2 #rptsts").attr("class", "icon-positive");
                $(".fidt2 #rptsts").closest("p").attr("class", "bg bg1");

            }
            //12/1/2017 -nirupama
            var addiv = '';
            debugger;
            if (AdrData.length > 0)
            {
                 addiv = '<div class="div-right grid-50">' +
                            '<ul class="">' +
                              '<li class="width-9"> <span class="bg">' + AdrData[1].AddrType + '</span> </li>' +
                             // '<li class="width-9" style="display:"' + AdrData[1].slrnmdisp + '> <b>' + AdrData[1].SellerNm + '</b> </li>' +
                              '<li class="width-12">' +
                                '<p>' + AdrData[1].DoorNo + ',' + ' ' + AdrData[1].Street + '</p>' +
                                '<p>' + AdrData[1].PlotNo + ',' + ' ' + AdrData[1].Building + '</p>' +
                                '<p>' + AdrData[1].Area + ',' + ' ' + AdrData[1].District + '</p>' +
                                '<p>' + AdrData[1].State + ',' + ' ' + AdrData[1].Country + '</p>' +
                                '<p>' + AdrData[1].Pincode + '</p>' +
                              '</li>' +
                            '</ul>' +
                          '</div>'
            }
            //12 / 1 / 2017 - nirupama
            var CommonDiv = $(
                      '<div class="div-left grid-50">' +                                               
                        '<b>' + data[0].AppNm + '</b>' +
                        '<p> <span>' + ActorType + '</span> , <span>' + data[0].Gender + '</span></p>' +
                        '<p>' + data[0].Contact + '</p>' +
                         '<p>' + LedAgtGlobal[0].PrdNm + '</p>' +
                      '</div>' +
                      '<div class="div-right grid-50">' +
                        '<ul class="">' +
                          '<li class="width-9"> <span class="bg">' + data[0].AddrType + '</span> </li>' +
                          '<li class="width-9" style="display:"' + data[0].slrnmdisp + '> <b>' + data[0].SellerNm + '</b> </li>' +
                          '<li class="width-12">' +
                            '<p>' + data[0].DoorNo + ',' + ' ' + data[0].Street + '</p>' +
                            '<p>' + data[0].PlotNo + ',' + ' ' + data[0].Building + '</p>' +
                            '<p>' + data[0].Area + ',' + ' ' + data[0].District + '</p>' +
                            '<p>' + data[0].State + ',' + ' ' + data[0].Country + '</p>' +
                            '<p>' + data[0].Pincode + '</p>' +
                          '</li>' +
                        '</ul>' +
                      '</div>' + addiv +
                      '<div class="clear"></div>');
            $(".field-content").append(CommonDiv);
            fnSetValues(Agt_Loadhtml, data)
            if (data[0].AddrType == "Builder Details") {
                $("#agt_Scr_Typ").text("Builder Verification");
                $("#Scrn_Nm").text("Builder Verification");
            }
        }

        $("#agents-popup-BC").find("input,button,select,textarea").attr("disabled", true);
        $("#agents-popup").find("input,button,select,textarea").attr("disabled", true);
    }
    if (ServiceFor == "Save_Agt_data") {
        var PkData = JSON.parse(Obj.result_1);
        Action = "Edit";
        LfjFk = PkData[0].HdrFk;
        Dtl_Fk = PkData[0].DtlFk;
        IsFinalConfirm = (PkData[0].IsNext == 1) ? "true" : "false";

        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }

        var DocData = JSON.parse(Obj.result_2);
        if (DocData.length > 0) {
            $("#agt_name").text(DocData[0].AgentName);
            for (var j = 0; j < DocData.length; j++) {
                var DocObj = (($(".agt_Doc_ver input[colkey='agt_DocFk'])").val()) == DocData[j].agt_DocFk) ?
                    $(".agt_Doc_ver input[colkey='agt_DocFk'])") : null;
                if (DocObj != null)
                    $(DocObj).siblings("input[colkey='DPk']").val(DocData[j].DPk);
            }
        }
    }
}
function fnReprtSts(elem) {

    var cls = $(elem).attr("class");
    var lihtml = $(elem).closest("li.div-right.status");
    if (cls == "icon-positive") {
        $(lihtml).find("p.bg").attr("class", "bg bg2");
        $(lihtml).find("i").attr("class", "icon-negative");
        $(lihtml).find("input[key=agt_rptstatus]").val(0);
        $(lihtml).find("input[colkey=agt_DocSts]").val(0);
    }
    else if (cls == "icon-negative") {
        $(lihtml).find("p.bg").attr("class", "bg bg7");
        $(lihtml).find("i").attr("class", "icon-no-status");
        $(lihtml).find("input[key=agt_rptstatus]").val(1);
        $(lihtml).find("input[colkey=agt_DocSts]").val(1);
    }
    else if (cls == "icon-no-status") {
        $(lihtml).find("p.bg").attr("class", "bg bg1");
        $(lihtml).find("i").attr("class", "icon-positive");
        $(lihtml).find("input[key=agt_rptstatus]").val(2);
        $(lihtml).find("input[colkey=agt_DocSts]").val(2);
    }
}
function fnSaveChangedData() {
    debugger;
    var mandDiv = $('#agtFB').attr('id');
    ErrMsg = fnChkMandatory(mandDiv);
    ErrMsg += fnChkMandatory("commonDiv", 1, 0, "Agent_Feedback");
    var DateFld = $(".fidt2").find("[key = 'agt_rptdt']").val();
    if (DateFld == "") {
        ErrMsg = ErrMsg == "" ? "Report Date is Required!!" : ErrMsg + "Report Date is Required!!";
    }
    var date = DateFld.substring(0, 2);
    var month = DateFld.substring(3, 5);
    var year = DateFld.substring(6, 10);
    var dateToCompare = new Date(year, month - 1, date);
    var currentDate = new Date();
    if (dateToCompare > currentDate) {
        fnShflAlert("error", "Report Date Should not be greater than Current Date ");
        return false;
    }
    if (ErrMsg != "") {
        fnShflAlert("error", ErrMsg);
        return false;
    }
    var HdrJson = {}; var DtlJson = {};
    HdrJson = fnGetFormValsJson_IdVal(Agt_Loadhtml);
    DtlJson = fnGetGridVal("agt_Doc_ver", "");
    var AgtSts = (IsFinalConfirm == "true") ? 1 : 0;

    var PrcObj = { ProcedureName: "PrcShflAgtMgmt", Type: "SP", Parameters: [Action, JSON.stringify(LedAgtGlobal), JSON.stringify(HdrJson), JSON.stringify(DtlJson), LfjFk, Dtl_Fk, AgtSts, JSON.stringify(RptJson)] };
    fnCallLOSWebService("Save_Agt_data", PrcObj, fnAgentResult, "MULTI");
}

//function fnCallScrnFn(FinalConfirm) {
//    IsFinalConfirm = FinalConfirm;
//    fnSaveChangedData();
//}
function fnUploadReport(FileELEM, Action, savePath, callback, Param1, Param2) {
    var ELEM = $(FileELEM).get(0);
    var files = ELEM.files;
    if (files.length == 0) { return; }
    var UploadObj = new FormData();
    UploadObj.append("Action", "ReportUpload");

    UploadObj.append("savePath", savePath);
    for (var i = 0; i < files.length; i++) {
        UploadObj.append("file_" + i, files[i]);
    }
    fnLosCallFileUploadService(Action, UploadObj, callback, Param1, Param2);
}
function fnOpenDocs(elem) {

    var path = $(elem).attr("docpath");
    localStorage.setItem("previewPath", path);
    $(".content-div").addClass("center-collapse");
    $("#div-document-content").show();
    $(".grid-type ul").removeClass("form-controls").addClass("grid-controls");
    popupclose();
    LoadHtmldoc('documents.html');
}
$(document).on("keyup", calculate());
function calculate() {

    var sum = 0;
    $(".total").each(function () {
        sum += $(this).val();

    });
    $("#agtval").val(sum);
}
/* Changes On 30/11/2016 */
function sum() {
    var astval = $("#agt_AstCost").val();
    var val = Number(FormatCleanComma(astval));
    var regchgval = $("#agt_Regchg").val();
    var val1 = Number(FormatCleanComma(regchgval));
    var stampchgval = $("#agt_stmpchg").val();
    var val2 = Number(FormatCleanComma(stampchgval));
    var agtval = parseInt(val) + parseInt(val1) + parseInt(val2)
    var total = FormatCurrency(agtval.toString());
    $("#agt_agtval").val(total);
}