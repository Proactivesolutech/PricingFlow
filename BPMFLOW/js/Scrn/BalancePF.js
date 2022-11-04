var IsSancGen = 'N';

$(document).ready(function () {
    var extraparam = JSON.stringify(GlobalBrnch);
    $("#comp-help").attr("Extraparam", extraparam);
    $("#UsrDispNm").val(GlobalXml[0].UsrNm);
});

function Bnkclick(rowjson) {
    $("#Instdtldiv").find("li.branch comp-help").attr("helpfk", rowjson.Bankpk);
    $("#Instdtldiv").find("li.bnkpk input").val(rowjson.Bankpk)
}
function Leadclick(rowjson) {
    $("#LeadDiv").find("li.Lead comp-help").attr("helpfk", rowjson.LeadPk);
    $("#LeadDiv").find("li.LeadPk input").val(rowjson.LeadPk);
    $("#bal_lead_prdicon").addClass(rowjson.hdnPrdIcon);
    $("#bal_lead_prdnm").text(rowjson.hdnPrdNm);

    $("#Scan_LeadId").text(rowjson.LeadId);
    $("#Bal_LeadNm").text(rowjson.LeadName);
    $("#Bal_Branch").text(rowjson.BranchName);
    $("#Bal_Agt").text(rowjson.hdnAgents);
    $("#LedFk").val(rowjson.LeadPk);
    $("#AgtFk").val(rowjson.hdnAgtFk);
    $("#BgeoFk").val(rowjson.hdnBrnchFk);
    $("#LeadDiv").find("input[key='SanctionNo']").attr("value", rowjson.hdnSanctionNo);
    $("#div_Process").show();

    var objProcData = { ProcedureName: "PrcSHFLLosBalancePF", Type: "SP", Parameters: ["Search-Lead", null, rowjson.LeadPk] }
    fnCallLOSWebService("Search-Lead", objProcData, fnDocResult, "MULTI");
}

function fnchange() {
    $("#InsmtNoId").val("");
    var Type = $("#typpayment").val();
    if (Type == "D") {
        $("#InsmtNoId").attr({ restrict: "number", maxlength: "6" });
    }
    else {
        $("#InsmtNoId").attr({ restrict: "alphanumeric", maxlength: "12" });
    }
}

function fnDocResult(ServDesc, Obj, Param1, Param2) {

    if (!Obj.status) {
        fnShflAlert("error",Obj.error);
        return;
    }
    if (ServDesc == "Search-Lead") {
        $(".documents.doc-list-view").empty();
        $('.balance-pf-div').empty();
        $('#grid').hide();
        $('.pf-Summary-div').empty();
        $('#dvSummary').hide();

        $('#selsancNo').empty();

        var Data = JSON.parse(Obj.result_1);
        var Data1 = JSON.parse(Obj.result_2);
        
        if (Data.length > 0) {
            $('#grid').show();
            $('.balance-pf-div').append("<tr><th>PaymentType</th><th>Instrument No</th><th>Instrument Date</th><th>Instrument Amount</th><th>Bank name</th><th>Branch name</th><th>Instrument Deposit Date</th><th>Voucher</th><th>Deposited Bank</th></tr>");
            $("#ColPF").text(Data[0].ColPF);
            $("#BalPF").text(Data[0].BalPF);
            for (var i = 0; i < Data.length; i++) {
                $('.balance-pf-div').append("<tr><td>" + Data[i].ProTypePk + "</td><td>" + Data[i].InstNo + "</td><td>" + Data[i].InstDate + "</td><td>" + Data[i].InstAmount + "</td><td>" + Data[i].BankNm + "</td><td>" + Data[i].BankBchNm + "</td><td>" + Data[i].InstDepDate + "</td><td>" + Data[i].Voucher + "</td><td>" + Data[i].code + "</td></tr>");
            }
        }
      
        IsSancGen = Data1[0].IsSancGen;
       
        if (IsSancGen == 'Y') {
            var pfdata = JSON.parse(Obj.result_3);

            if (pfdata.length > 0) {
                $('.pf-Summary-div').append("<tr><th>Product</th><th>Sanction No</th><th>Total PF</th><th>Collected PF</th><th>Balance PF</th></tr");
                $('#selsancNo').append('<option value="">Select</option>');
                for (var i = 0; i < pfdata.length; i++) {
                    $('.pf-Summary-div').append("<tr><td><i class=" + pfdata[i].PrdIcon + "></i><p>" + pfdata[i].PrdNm + "</p></td><td>" + pfdata[i].SancNo + "</td><td>" + pfdata[i].TotalPF + "</td><td>" + pfdata[i].CollectedPF + "</td><td>" + pfdata[i].BalPF + "</td></tr>");
                    $('#selsancNo').append('<option value="' + pfdata[i].SancNo + '" BalPf="' + pfdata[i].BalPF + '">' + pfdata[i].SancNo + '</option>');
                }
                $('#dvSummary').show();
                selectfocus();
            }

            $('#selsancNo').addClass('mandatory');
            $('#SancNoli').show();
        }
        else {
            $('#selsancNo').removeClass('mandatory');
            $('#SancNoli').hide();
        }

    }

    if (ServDesc == "INSERT") {
       
        PFPk = JSON.parse(Obj.result)[0].LpcFK;
        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }

    }
}
  

function Brnchclick(rowjson) {
    $("#Instdtldiv").find("li.brnchpk input").val(rowjson.Brnchpk)
}
//Viewport Height Function Ends
$(".doc-view").click(function (e) {
    $(".content-div").addClass("center-collapse");
    $("#div-document-content").show();
    LoadHtmldoc('documents.html');
});
function LoadHtmldoc(HtmlPage) {
    $("#div-document-content").empty();
    $("#div-document-content").load(HtmlPage);
}

$(document).ready(function () {
    popupclose();
    selectfocus(); /* Custom Select2 plugin Function*/
});

function fnCallScrnFn(FinalConfirm) {
    IsFinalConfirm = "false";
    fnsavedocdtls();
}

function fnsavedocdtls() {

    var tbdiv = $('#Instdtldiv').attr('id');
    ErrMsg = fnChkMandatory(tbdiv);
    var dateval = $("#" + tbdiv + " [key='LpcInstrDt']").val();
    var count = 0;
    var char1 = '';
    var cc = '';
    if ($("#" + tbdiv + " [key='LpcInstrDt']").val() == "") {
        ErrMsg = ErrMsg == "" ? "Instrument Date Required!!" : ErrMsg + "Instrument Date Required!!";
    }
    if ($("#" + tbdiv + " [key='LpcInstrdepoDt']").val() == "") {
        ErrMsg = ErrMsg == "" ? "Instrument Deposit Date Required!!" : ErrMsg + "</br>" + "Instrument Deposit Date Required!!";
    }

    var date = dateval.substring(0, 2);
    var month = dateval.substring(3, 5);
    var year = dateval.substring(6, 10);
    var dateToCompare = new Date(year, month - 1, date);
    var currentDate = new Date();
    var targetDate = new Date();
    targetDate.setDate(currentDate.getDate() - 90);
    targetDate.setHours(0);
    targetDate.setMinutes(0);
    targetDate.setSeconds(0);
    if (dateval != '') {
        if (Date.parse(dateToCompare) < Date.parse(targetDate)) {
            fnShflAlert("error", "Instrument Date Should not be Less than 90 days from Current Date!!");
            return false;
        }

        if (dateToCompare > currentDate) {
            fnShflAlert("error", "Instrument Date Should not be greater than Current Date!!");
            return false;
        }
    }

    var dateval1 = $("#" + tbdiv + " [key='LpcInstrdepoDt']").val();
    /*change(muthu)28/12/16*/
    var instdate = $("#datecheck").val();
    var date2 = instdate.substring(0, 2);
    var month2 = instdate.substring(3, 5);
    var year2 = instdate.substring(6, 10);
    var instrumentdate = new Date(year2, month2 - 1, date2);
    /*end*/

    var date1 = dateval1.substring(0, 2);
    var month1 = dateval1.substring(3, 5);
    var year1 = dateval1.substring(6, 10);
    var dateToCompare1 = new Date(year1, month1 - 1, date1);
    var currentDate1 = new Date();
    var targetDate1 = new Date();
    targetDate1.setDate(currentDate1.getDate() - 90);
    targetDate1.setHours(0);
    targetDate1.setMinutes(0);
    targetDate1.setSeconds(0);
    if (dateval1 != '') {
        if (Date.parse(dateToCompare1) < Date.parse(targetDate1)) {
            fnShflAlert("error", "Instrument Deposited Date Should not be Less than 90 days from Current Date!!");
            return false;
        }

        if (dateToCompare1 > currentDate1) {
            fnShflAlert("error", "Instrument Deposited Date Should not be greater than Current Date!!");
            return false;
        }
        /*change(muthu)28/12/16*/
        if (dateToCompare1 < instrumentdate) {
            fnShflAlert("error", "Instrument Deposited Date Should be greater than Instrument Date!!");
            return false;
        }
        /*end*/
    }

    //help


    var InsNo = $("#InsmtNoId").val();
    var InsNoLength = InsNo.length;
    for (var i = 0; i < InsNo.length; i++) {
        char1 = InsNo.charAt(i);
        cc = char1.charCodeAt(0);
        if ((cc > 64 && cc < 91) || (cc > 96 && cc < 123)) {
            count++;
        }
    }

    if (ErrMsg != "") {
        fnShflAlert("error", ErrMsg);
        return false;
    }


    if ($("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val() == "") {
        fnShflAlert("error", "Select bank name!!");
        return false;

    }
    if ($("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val() != "") {
        if ($("#Instdtldiv").find("li.branch comp-help").find("input[name='helptext']").val() == "") {
            fnShflAlert("error", "Select branch name!!");
            return false;
        }
    }

    if (InsNo.length == count) {
        fnShflAlert("error", "Enter Proper Instrument No!!");
        return;
    }
    var bnkval = $("#help_dep_bank").find("input[name='helptext']").val();
    if (bnkval == "") {
        fnShflAlert("error", "Deposited Bank Required!!");
        return false;
    }

    if (IsSancGen == "Y") {
        var BalPF = Number(FormatCleanComma($("#selsancNo").select2().find(":selected").attr("BalPf")));
        var InstrAmt = Number(FormatCleanComma($("#" + tbdiv + " [key='LpcInstrAmt']").val()));
        if (InstrAmt > BalPF) {
            fnShflAlert("error", "Instrument Amount Should not be greater than Balance PF Amount!!");
            return false;
        }
    }
    //Functioncheck();
    var DocGlobal = {}; var Action = "", sancNo = "";
    DocGlobal = fnGetFormValsJson_IdVal("Instdtldiv");
    PFPk = $("#LeadDiv").find("li.LeadPk input").val();

    if (IsSancGen == "Y") {
        sancNo = $("#selsancNo").val();        
    }

    Action ="INSERT";
    var objProcData = { ProcedureName: "PrcSHFLLosBalancePF", Type: "SP", Parameters: [Action, JSON.stringify(DocGlobal), PFPk,"",sancNo] }
    fnCallLOSWebService("INSERT", objProcData, fnDocResult, "MULTI");
}

function DepsitedBankclick(rowjson) {
  
    $("#Instdtldiv").find("li.depo_bank input[name='helptext']").val(rowjson.Code);
    $("#Instdtldiv").find("li.depo_bank input[key='dep_bank']").attr("valtext", rowjson.Gblpk);
    $("#Instdtldiv").find("li.depo_bank input[key='dep_bank']").attr("value", rowjson.Gblpk);
}
