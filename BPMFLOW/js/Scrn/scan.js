var DocGlobal = [{}];
var QryGlobal = [{}];
var PFPk = 0;
var IsFinalConfirm = "";
var chckpni = "";
var yes = "";
$(document).ready(function () {
    console.log("scan")
    DocGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    DocGlobal[0].DocAgtNm = GlobalXml[0].AgtNm;
    DocGlobal[0].DocAgtPk = GlobalXml[0].AgtFk;
    DocGlobal[0].DocBGeoFk = GlobalXml[0].BrnchFk;
    DocGlobal[0].DocPrdFk = GlobalXml[0].PrdFk;
    DocGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    DocGlobal[0].PrdGrpFk = GlobalXml[0].PrdGrpFk;

    $("#compsaveid").setProps(DocGlobal[0]);
    $("#Scan_LeadId").text(GlobalXml[0].LeadID);
    $("#Scan_LeadNm").text(GlobalXml[0].LeadNm);
    $("#Scan_Branch").text(GlobalXml[0].Branch);
    $("#Scan_Agent").text(GlobalXml[0].AgtNm);


    fnGetDocList();
    fnDrawDatePicker();
    fnchange();

    $("#Instdtldiv .datepicker").each(function () {
        fnRestrictDate($(this));
    });
    $(document).on("click", ".bank", function () {
        if ($(this).find("comp-help").find("input[name=helptext]").val() == "") {
            $(this).siblings("li.branch").find("comp-help").attr("helpfk", 0);
            $(this).siblings("li.branch").find("comp-help").find("input[name=helptext]").val("");
            $(this).siblings("li.branch").find("comp-help").find("input[name=helptext]").attr("val", "");
            $(this).find("comp-help").find("input[name=helptext]").attr("val", "");
        }
    });
    //fnGetPrd();


});

//function fnGetPrd() {
//    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["sel_prd"] };
//    fnCallLOSWebService("sel_prd", PrcObj, fnDocResult, "MULTI");
//}
function fnGetDocList() {

    var objProcData = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["DOC_LIST", JSON.stringify(DocGlobal)] }
    fnCallLOSWebService("DOC_LIST", objProcData, fnDocResult, "MULTI");
}
function fnsavedocdtls(yes) {
    debugger;

    window.grpFk = $("#prddiv i").attr("pk");
    var tbdiv = $("#Instdtldiv").attr("id");
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
        //if (Date.parse(dateToCompare1) < Date.parse(targetDate1)) {
        //    fnShflAlert("error", "Instrument Deposited Date Should not be Less than 90 days from Current Date!!");
        //    return false;
        //}

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


    var bnkval = $("#help_dep_bank").find("input[name='helptext']").val();
    if (bnkval == "") {
        fnShflAlert("error", "Deposited Bank Required!!");
        return false;
    }


    var filedate=$("#File_recdt").val();
    var date4 = filedate.substring(0, 2);
    var month4 = filedate.substring(3, 5);
    var year4 = filedate.substring(6, 10);
    var filerec_date = new Date(year4, month4 - 1, date4);
    var currentDate2 = new Date();
    if (filerec_date > currentDate2) {
        fnShflAlert("error", "File Received Date Should not be greater than Current Date!!");
        return false;
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
        fnShflAlert("error", "Bank name required!!");
        return false;

    }

    if ($("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val() != "") {
        if ($("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val() != $("#Instdtldiv").find("li.bnkpk input").attr("valtext")) {
            fnShflAlert("error", "Valid Bank name required!!");
            return false;
        }
    }
    if ($("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val() != "") {
        if ($("#Instdtldiv").find("li.branch comp-help").find("input[name='helptext']").val() == "") {
            fnShflAlert("error", "Branch name required!!");
            return false;
        }
    }
    if ($("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val() != "") {
        if ($("#Instdtldiv").find("li.branch comp-help").find("input[name='helptext']").val() != "") {
            if ($("#Instdtldiv").find("li.branch comp-help").find("input[name='helptext']").val() != $("#Instdtldiv").find("li.brnchpk input").attr("valtext")) {
                fnShflAlert("error", "Valid Branch name required!!");
                return false;
            }
        }
    }


    if (InsNo.length == count) {
        fnShflAlert("error", "Enter Proper Instrument No!!");
        return;
    }
    if ($("#File_recdt").val() == "") {
        fnShflAlert("error", "File Received Date Required!!");
        return;
    }
  
    //Functioncheck();
    var HdrJson = {}; var Action = "";
    HdrJson = fnGetFormValsJson_IdVal("Instdtldiv");
    Action = (PFPk > 0) ? "UPDATE" : "INSERT";
    var filedate = $("#File_recdt").val();
    var docdate = $("#docdate").val();
    var jsondata = [{ "Code": "R", "Date": filedate }, { "Code": "D", "Date": docdate }];
    var objProcData = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: [Action, JSON.stringify(DocGlobal), JSON.stringify(HdrJson), PFPk, grpFk, "", JSON.stringify(jsondata), yes] }
    fnCallLOSWebService("SAVE_DATA", objProcData, fnDocResult, "MULTI");
}

function fnDocResult(ServDesc, Obj, Param1, Param2) {
    debugger;
    if (!Obj.status) {
        fnShflAlert("error", Obj.error);
        return;
    }
    if (ServDesc == "DOC_LIST") {
        debugger;
        $(".documents.doc-list-view").empty();
        var Data = JSON.parse(Obj.result_1);
        var profeedtls = JSON.parse(Obj.result_2);
        var doc_dt = JSON.parse(Obj.result_3);
        if (doc_dt.length > 0) {
            $("#File_recdt").val(doc_dt[0].Dt);
            $("#docdate").val(doc_dt[1].Dt);
        }

        if (profeedtls.length > 0) {
            debugger;
            PFPk = profeedtls[0].LpcFK;

            if (profeedtls.length > 0) {
                fnSetValues("Instdtldiv", profeedtls);
            }
            var bnkpk = profeedtls[0].Bnkpk;
            var bnkname = profeedtls[0].BnkNm;
            var brnchpk = profeedtls[0].Branchfk;
            var brnchloc = profeedtls[0].Branchloc;
            var dep_bank_pk = profeedtls[0].dep_bank;
            var Code = profeedtls[0].bnkCode

            if (bnkpk > 0) {
                $("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").attr("val", bnkpk);
                $("#Instdtldiv").find("li.bank comp-help").find("input[name='helptext']").val(bnkname);
                $("#Instdtldiv").find("li.branch comp-help").attr("helpfk", bnkpk);
                $("#Instdtldiv").find("li.bnkpk input").val(bnkpk);
                $("#Instdtldiv").find("li.bnkpk input").attr("valtext", bnkname);

            }
            if (brnchpk > 0) {

                $("#Instdtldiv").find("li.branch comp-help").find("input[name='helptext']").attr("val", brnchpk);
                $("#Instdtldiv").find("li.branch comp-help").find("input[name='helptext']").val(brnchloc);
                $("#Instdtldiv").find("li.brnchpk input").val(brnchpk);
                $("#Instdtldiv").find("li.brnchpk input").attr("valtext", brnchloc);
            }
            if (dep_bank_pk > 0) {
                $("#help_dep_bank").find("input[name='helptext']").attr("val", dep_bank_pk);
                $("#help_dep_bank").find("input[name='helptext']").val(Code);
                $("#help_dep_bank").find("li.depo_bank input").val(dep_bank_pk);
                $("#help_dep_bank").find("li.depo_bank input").attr("valtext", Code);

            }

        }
        var ul = '';
        for (var i = 0; i < Data.length; i++) {
            if (Data[i].Actor == 1)
                apptype = "Applicant";
            var apptype = "";
            if (Data[i].Actor == 0) {
                apptype = "Applicant"
            }
            else if (Data[i].Actor == 1) {
                apptype = "CoApplicant";
            }
            else if (Data[i].Actor == 2) {
                apptype = "Guarantor";
            }
            ul += '<ul pk="' + Data[i].Pk + '"><li>' + Data[i].DocName + '<p><span class="bg">' + apptype + '</span><span class="bg">' + Data[i].Catogory + '</span> <span class="bg">' + Data[i].SubCatogory + '</span></p>' +
                '</li><li><i class="icon-document doc-view" docpath="' + Data[i].DocPath + '" onclick="fnOpenDocs(this)" ></i></li><li><i class="icon-delete"></i></li></ul>';
        }
        $(".documents.doc-list-view").append(ul);

        var GRPdtls = JSON.parse(Obj.result_4);

        if (GRPdtls.length > 0) {

            $("#prddiv i").attr("pk", GRPdtls[0].productpk);
            $("#LeadGrdPk").val(GRPdtls[0].productpk);
            $("#LeadGrdPk").attr("pcd", GRPdtls[0].ProductCode);
            $("#prddiv i").attr("class", GRPdtls[0].classNm);
            $("#prddiv p").text(GRPdtls[0].productnm);
        }

        var Pnicase = JSON.parse(Obj.result_5);

        if (Pnicase.length > 0) {
            chckpni = Pnicase[0].PNICASE;
            if (chckpni == "N") {
                if (!window.BO)
                    window.BO = 1;
                $("#div_append").append("<div id='Loadhtml'></div>")
                $("#Loadhtml").load('AgentPNI.html', function () {
                    $("#agt_title").hide();
                    $("#main_agtLeadDiv").hide();
                });
            }
        }
    }

        /*CHANGE 30/11/2016*/
        if (ServDesc == "SAVE_DATA") {
            debugger;
            PFPk = JSON.parse(Obj.result)[0].LpcFK;

            if (chckpni == "N") {
                fnCallScrnFnfrmBO(IsFinalConfirm);
            }
            else if (chckpni == "Y") {
                if (IsFinalConfirm != "") {
                    fnCallFinalConfirmation(IsFinalConfirm);
                    return;
                }
            }
        }
    }
//var count = 0;
        //var char1 = '';
        //var cc = '';
        //var InsNo = $("#InsmtNoId").val();
        //var InsNoLength = InsNo.length;
        //for (var i = 0; i < InsNo.length; i++) {
        //    char1 = InsNo.charAt(i);
        //    cc = char1.charCodeAt(0);
        //    if ((cc > 64 && cc < 91) || (cc > 96 && cc < 123)) {
        //        count++;
        //    }
        //}
        //if ($("#typpayment").val() != 'DD') {
        //    if (InsNoLength < 6) {
        //        fnShflAlert("error", "The Instrument No Must be Greater than 6 digits!!");
        //        return;
        //    }
        //}
        //if (InsNo.length == count) {
        //    fnShflAlert("error", "Enter Proper Instrument No!!");
        //    return;
        //}
        /*
        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }
        */

   
    //if (ServDesc == "sel_prd") {

    //    var PrdData = JSON.parse(Obj.result);
    //    var clsNm = ''
    //    var prd = ''

    //    for (var i = 0; i < PrdData.length; i++) {
    //        var liActive = "";
    //        if (PrdData[i].ProductCode == $("#LeadGrdPk").attr("pcd")) {
    //            liActive = 'class="active"'
    //        }
    //        if (PrdData[i].ProductCode == "HL") {
    //            clsNm = "icon-home-loan"
    //        }
    //        else if (PrdData[i].ProductCode == "LAP")
    //            clsNm = "icon-lap"
    //        else if (PrdData[i].ProductCode == "PL")
    //            clsNm = "icon-plot-loan"

    //        prd += '<li ' + liActive + ' cursor="pointer" ><i pcd= "' + PrdData[i].ProductCode + '" pk = "' + PrdData[i].productpk + '" class="' + clsNm + '"></i><p>' + PrdData[i].productnm + '</p></li>'
    //    }
    //    $("#ul_Prd").append(prd);
    //}



//function fnonpopopen() {
//    $("#ul_Prd").empty();
//    fnGetPrd();
//}
//function fnonclick(elem) {

//    $("#prddiv").empty();
//    $("#product_popupdiv").css("display", "none");
//    $("#LeadGrdPk").attr("pcd", $(elem).children("i").attr("pcd"));
//    $("#LeadGrdPk").val($(elem).children("i").attr("pk"));
//    var prdicon = $(elem).html();
//    $("#prddiv").append(prdicon);
//}

function fnOpenDocs(elem) {
    var path = $(elem).attr("docpath");
    localStorage.setItem("previewPath", path);
    $(".content-div").addClass("center-collapse");
    $("#div-document-content").show();
    $(".grid-type ul").removeClass("form-controls").addClass("grid-controls");
    popupclose();
    LoadHtmldoc('documents.html');
}
function fnCallScrnFn(FinalConfirm) {
    debugger;
    IsFinalConfirm = FinalConfirm;
    if (FinalConfirm == "true") {
        yes = "Y";
        var docdate = $("#docdate").val();
        if (docdate == "") {
            fnShflAlert("error", "File Sent Date Required !!");
            return false;
        }
        var date3 = docdate.substring(0, 2);
        var month3 = docdate.substring(3, 5);
        var year3 = docdate.substring(6, 10);
        var docketdate = new Date(year3, month3 - 1, date3);
        var currentDate2 = new Date();
        if (docketdate > currentDate2) {
            fnShflAlert("error", "File Sent Date Should not be greater than Current Date!!");
            return false;
        }
        fnsavedocdtls(yes);
    } else if (FinalConfirm == "false") {
        yes = "";
        fnsavedocdtls(yes);
    }
    
}
function fnpop() {

    $("#fold_nm").val(GlobalXml[0].LeadID);
    window.open("", "newWin", "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=20,top=20,width=600,height=600");
    PostForm.submit();
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

/*muthu(5/1/17)*/
$("#InsmtNoId").keydown(function (e) {  
    var key = e.keyCode || e.which;
    if (key == 190) {
        return false;
    }
});
/*end*/
$("#InstAmtId").keydown(function (e) {  
    var key = e.keyCode || e.which;
    if (key == 190) {
        return false;
    }
});
function DepsitedBankclick(rowjson) {    
    $("#Instdtldiv").find("li.depo_bank input[name='helptext']").val(rowjson.Code);
    $("#Instdtldiv").find("li.depo_bank input[key='dep_bank']").attr("valtext", rowjson.Gblpk);
    $("#Instdtldiv").find("li.depo_bank input[key='dep_bank']").attr("value", rowjson.Gblpk);
}

$(".currency").focusin(function () {
    debugger;
    var cur_val = FormatCleanComma($("#InstAmtId").val());
    $("#InstAmtId").val(cur_val);

});
//function compareDate() {
//    debugger;
//    var dateEntered = $("#datecheck").val();
//    var date = dateEntered.substring(0, 2);
//    var month = dateEntered.substring(3, 5);
//    var year = dateEntered.substring(6, 10);

//    var dateToCompare = new Date(year, month - 1, date);
//    //var monthToCompare = new Date(year, month - 1, date);

//    var currentDate = new Date();
//    var targetDate = new Date();
//    targetDate.setDate(currentDate.getDate() - 90);
//    targetDate.setHours(0);
//    targetDate.setMinutes(0);
//    targetDate.setSeconds(0);
//    if (Date.parse(dateToCompare) < Date.parse(targetDate)) {
//        fnShflAlert("error", "Selected Date is Should not be Less than 90 days from Current Date!!");
//        return;
//    }

//    if (dateToCompare > currentDate) {
//        fnShflAlert("error", "Selected Date is Should not be greater than Current Date ");
//        return;
//    }

//}
