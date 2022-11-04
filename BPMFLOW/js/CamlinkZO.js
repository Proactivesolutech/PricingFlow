var DocGlobal_1 = [{}];
var productCode;
$(document).ready(function () {   
    DocGlobal_1[0].LeadPk = GlobalXml[0].FwdDataPk;
    DocGlobal_1[0].GeoFk = GlobalXml[0].BrnchFk;
    DocGlobal_1[0].UsrPk = GlobalXml[0].UsrPk;
    $(".box-div.buttondiv").hide();
    
    var extraparam = JSON.stringify(GlobalBrnch);
    $("#Lead-help").attr("Extraparam", extraparam);
});

function Leadclick(rowjson) {

    $("#LeadDiv").find("li.Lead input[name='helptext']").val(rowjson.LeadId);
    $("#LeadDiv").find("li.Lead input[key='lead_id']").attr("valtext",rowjson.LeadId);
    $("#LeadDiv").find("li.Lead input[key='lead_id']").attr("value", rowjson.LeadId);
    $("#LGen_lead_prdicon").addClass(rowjson.hdnPrdIcon);
    $("#LGen_lead_prdnm").text(rowjson.hdnPrdNm);

    DocGlobal_1[0].LeadPk = rowjson.LeadPk;
    window.leadpk = DocGlobal_1[0].LeadPk;

    $("#Bal_LeadNm").text(rowjson.LeadName);
    $("#Bal_Branch").text(rowjson.BranchName);
    productCode = rowjson.hdnPrdCd;
    $(".box-div.buttondiv").show();
}

function fnGenerateCAM() {
    
    fnGenerateSanction("CAM");
}

function fnFinalGenCAM(){
    if (productCode == "HLBTTopup" || productCode == 'LAPBTTopup') {
        // CAM for BT
        fnGenerateReport("CAM", 0);
        // CAM for TOPUP
        setTimeout(function () {
            fnGenerateReport("CAM", 1);
        }, 200);

    } else {
        fnGenerateReport("CAM","");
    }
}

function fnGeneratePrpslNote() {
    fnGenerateReport("PROPOSALNOTE");
}
function fnGenerateRiskcalc() {
    fnGenerateSanction("RISKMATRIX");
}

function fnGenerateSanction(CallBackPrint) {
    CallBackPrint = CallBackPrint || "";
    CallBackPrint = CallBackPrint == "" ? "SANC" : CallBackPrint;
    GlobalXml[0].FwdDataPk = DocGlobal_1[0].LeadPk;
    var objProcData = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["CHECK_SANCTION", JSON.stringify(GlobalXml)] }
    fnCallLOSWebService("CHECK_SANCTION", objProcData, fnResult, "MULTI", CallBackPrint);
}

function fnGenerateDisburseMemo() {
    GlobalXml[0].LeadFk = DocGlobal_1[0].LeadPk;
    var objProcData = { ProcedureName: "PrcShflPostSanction", Type: "SP", Parameters: ["LoanExist_Check", JSON.stringify(GlobalXml)] }
    fnCallLOSWebService("LoanExist_Check", objProcData, fnResult, "MULTI", "");
}

function fnResult(ServiceFor, Obj, Param1, Param2) {
    if (ServiceFor == "CHECK_SANCTION") {
        debugger;
        var data = JSON.parse(Obj.result_1);
        var CAMdata = JSON.parse(Obj.result_2);
        var RSKdata = JSON.parse(Obj.result_3);

        if (Param2 == "SANC") {

            if (!data || data.length == 0 || data[0].flg == " ") {
                fnShflAlert("error", "Sanction Not yet Generated!");
                return;
            }
            for (var i = 0; i < data.length; i++) {
                fnGenerateReport((data[0].flg == "R" ? "SANCREJ" : "SANC"), data[i].sancNo);
            }
        }
        else if (Param2 == "CAM") {
            if (!CAMdata || CAMdata.length == 0) {
                fnShflAlert("error", "CAM Not yet Generated!");
                return;
            }
            fnFinalGenCAM();
        }
        else if (Param2 == "RISKMATRIX") {
            if (!RSKdata || RSKdata.length == 0) {
                fnShflAlert("error", "Risk calculation Matrix Not yet Generated!");
                return;
            }
            fnGenerateReport("RISKMATRIX");
        }        
    } 
    if (ServiceFor == "LoanExist_Check") {
        var data = JSON.parse(Obj.result);

        if (!data || data.length == 0) {
            fnShflAlert("error", "Loan Not yet Created!");
            return;
        }
        var left = 0, top = 0;
        for (var i = 0; i < data.length; i++) {
            fnGenerateReport("DISBURSE_MEMO", data[i].SancPk);
        }
    }
}

var pdfCount = 0;
var ReportService = getLocalStorage("PdfUrl");
//var ReportService = "http://14.142.36.105:8080/HtmlRender/JsonRender/JsonRender.svc/";
function fnGenerateReport(Type, refNo) {
    debugger;
    try { fnShowLOSProgress(); }
    catch (ex) { }

    var jsondata = {};
    var RepDetail = {};

    $.ajaxSetup({
        async: false
    });

    if (Type == "CAM") {
        var HTMLObj = $.getJSON('ReportFiles/CamSheet/CamSample.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/CamSheet/CamSample.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "CamSample_" + $("#Bal_LeadNm").text() + ".json";
        RepDetail.Inputparam = JSON.stringify({ "@LeadFk": leadpk, "@BTTOPflag": refNo });
    }
    if (Type == "SANC") {
        var HTMLObj = $.getJSON('ReportFiles/SanctionLetter/SanctionSample.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/SanctionLetter/SanctionSample.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "SanctionSample_" + $("#Bal_LeadNm").text() + ".json";
        var Gxml = GlobalXml;
        Gxml[0].sancNo = refNo;
        RepDetail.Inputparam = JSON.stringify({ "@Action": "PRINT_SANCTION", "@GlobalJson": JSON.stringify(Gxml) });
    }
    if (Type == "SANCREJ") {
        var HTMLObj = $.getJSON('ReportFiles/ProposalRejection/ProposalRejection.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/ProposalRejection/ProposalRejection.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "ProposalRejection_" + $("#Bal_LeadNm").text() + ".json";
        var Gxml = GlobalXml;
        Gxml[0].sancNo = refNo;
        RepDetail.Inputparam = JSON.stringify({ "@LeadPk": leadpk });
    }
    if (Type == "PROPOSALNOTE") {
        var HTMLObj = $.getJSON('ReportFiles/ProposalNote/ProposalNote.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/ProposalNote/ProposalNote.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "ProposalNote_"+$("#Bal_LeadNm").text()+".json";
        RepDetail.Inputparam = JSON.stringify({ "@LeadPk": leadpk });
    }
    if (Type == "RISKMATRIX") {
        var HTMLObj = $.getJSON('ReportFiles/Risk Calculation Matrix/riskcalculation.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/Risk Calculation Matrix/riskcalculation.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "riskcalculation" + $("#Bal_LeadNm").text() + ".json";
        RepDetail.Inputparam = JSON.stringify({ "@LeadPk": leadpk });
    }
    if (Type == "DISBURSE_MEMO") {
        var HTMLObj = $.getJSON('ReportFiles/DisbursementMemo/Disbursement Memo.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/DisbursementMemo/Disbursement Memo.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "Disbursement Memo_" + $("#Bal_LeadNm").text() + ".json";
        RepDetail.Inputparam = JSON.stringify({ "@LeadPk": leadpk, "@SancPk": refNo });
    }
    var DATAURL = ReportService + "JsonRender";
    jsondata.RepDetail = RepDetail;
    jQuery.support.cors = true;
    $.ajax({
        crossDomain: true,
        cache: false,
        type: "POST",
        url: DATAURL,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(jsondata),
        success: function (d) {

            try { fnRemoveLOSProgress(); }
            catch (ex) { }

            var resdata = JSON.parse(d.GenReportResult);
            if (resdata.Lst_ErrorLog != undefined) {
                fnShflAlert("error", resdata.Lst_ErrorLog[0].Message);
            }
            else {
                console.log(resdata);
                window.open(resdata, "_blankPDF" + pdfCount);
                pdfCount++;

            }
        },
        error: function (xhr, reason, ex) {
            try { fnRemoveLOSProgress(); }
            catch (ex) { }
            var err = $.parseJSON(xhr.responseText);
            if (err != null && xhr.status.toString() != "0") {
                fnShflAlert("error", 'Error Code : ' + xhr.status + "\nError Message :" + xhr.statusText);
            }
        }
    });

}
$(".Lead").on("click",function () {   
    $("#Lead-help input[name=helptext]").val("");
});
