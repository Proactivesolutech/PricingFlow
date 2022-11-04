var DDEGlobal = [{}];
var DDEHdrJson = [{}];
var MaxliAppTab = 1;
var MaxliRefTab = 1;
var Cur_Active_Actor_li;
var Cur_Active_ref_li;
var Cur_Active_Dtl_li;
var Cur_Active_Adr_li;
var globalremarks;
var globalKycremarks;
var globalDocremarks;
var globalKycaddremarks;
var globalDocgenremarks;
var globalicon;
var globalicon;
var DocAppRef = 0;
var FinalErrMsg = "";
var FinalSelObj;
var IsFinalConfirm = "";
var globalrefno = "";
var globaldocrefno = "";
var globaldocgenrefno = "";
var emptypedtls = "";
var doccnt = "";
var Approver = "";

$(document).ready(function () {
    DDEGlobal = [{}];
    DDEGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    DDEGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    DDEGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    DDEGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    DDEGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    DDEGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    DDEGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    LogJson[0].LgUsr = GlobalXml[0].UsrNm;
    $("#dde_PrdType").text(GlobalXml[0].PrdNm);
    $("#dde_leadid").text(GlobalXml[0].LeadID);
    $("#dde_appno").text(GlobalXml[0].AppNo);
    $("#dde_brnch").text(GlobalXml[0].Branch);
    fnClearForm("dde_content_Pg");
    fnBindEvts("dde_content"); fnBindEvts("dde_ref"); fnBindEvts("legal_hier");
    fnobbind();
    validatebank();
    fnremarks();
    fnkycremarks();
    fnkycaddremarks();
    fndocremarks();
    fndocgenremarks();
    //fnddegetprdicon();
    validatepan();
    fnQDELoadLeadDetails("LdDtls");
    fnDDELoadDocDetails();
    //fnloadrefno();
    //fnloaddocrefno();
    //fnloaddocGenrefno();
    globalicon = document.querySelector(".Ob_grid").outerHTML;
    fnDrawDefaultDatePicker();

    $(document).on("click", ".obligation-div .icon-chat-o", function () {
        globalremarks = $(this).parents("li").siblings(".dde_ob_notes");
        var iconval = $(this).parents("li").siblings(".dde_ob_notes").find("input").val();
        $("textarea#dde_rem").val(iconval);
    });

    $(document).on("click", ".Kyc_div .icon-chat-o", function () {
        globalKycremarks = $(this).parents("li").siblings(".dde_kyc_notes");
        var iconval = $(this).parents("li").siblings(".dde_kyc_notes").find("input").val();
        $("textarea#dde_kycrem").val(iconval);
    });

    $(document).on("click", ".Kyc_Adddiv .icon-chat-o", function () {
        globalKycaddremarks = $(this).parents("li").siblings(".dde_kyc_addnotes");
        var iconval = $(this).parents("li").siblings(".dde_kyc_addnotes").find("input").val();
        $("textarea#dde_kycaddrem").val(iconval);
    });

    $(document).on("click", ".Doc_Gendiv .icon-chat-o", function () {
        globalDocgenremarks = $(this).parents("li").siblings(".Com_gennotes");
        var iconval = $(this).parents("li").siblings(".Com_gennotes").find("input").val();
        $("textarea#dde_Docgenrem").val(iconval);
    });

    $(document).on("click", ".Doc_div .icon-chat-o", function () {
        globalDocremarks = $(this).parents("li").siblings(".Com_notes");
        var iconval = $(this).parents("li").siblings(".Com_notes").find("input").val();
        $("textarea#dde_Docrem").val(iconval);
    });

    $(document).on("click", ".bank", function () {
        if ($(this).find("comp-help").find("input[name=helptext]").val() == "") {
            $(this).siblings("li.branch").find("comp-help").attr("helpfk", 0);
            $(this).siblings("li.branch").find("comp-help").find("input[name=helptext]").val("");
            $(this).siblings("li.branch").find("comp-help").find("input[name=helptext]").attr("val", "");
            $(this).find("comp-help").find("input[name=helptext]").attr("val", "");
            $(this).find("input[colkey=dde_Bank_bnkName1]").val("");
            $(this).find("input[colkey=dde_Bank_bnkName2]").val("");
            $(this).siblings("li.branch").find("input[colkey=dde_Bank_branch1]").val("");
            $(this).siblings("li.branch").find("input[colkey=dde_Bank_branch2]").val("");
        }
    });

    $(document).on("click", ".emp-salaried", function () {
        $(".salaried-div").attr("contentchanged", "true");
    });
    $(document).on("click", ".emp-self-prof", function () {
        $(".selfemp-div").attr("contentchanged", "true");
    });
    $(document).on("click", ".emp-housewife", function () {
        $(".salaried-div").hide();
        $(".selfemp-div").hide();
        $(".student-div").hide();
    });
    $(document).on("click", ".emp-pensioner", function () {
        $(".salaried-div").hide();
        $(".selfemp-div").hide();
        $(".student-div").hide();
    });
    $(document).on("click", ".emp-student", function () {
        $(".student-div").attr("contentchanged", "true");
    });

    $("#dde_div_appPop div.category-div ul li").click(function () {
      
        fniconPlusLiability(this);
    });
    Cur_Active_ref_li = $("#dde_ul_ref_tabs li[val='30']");
    Cur_Active_Dtl_li = $("#dde_whole_div_0 .det-content1");
    Cur_Active_Adr_li = $("#dde_whole_div_0 .address-list li[val=0]");


    $(".saleofz").find("comp-help").attr("extraparam", GlobalXml[0].BrnchFk);


});

function fncheckgenDoc(elem)
{
    $(elem).parents("li").siblings("li").find("comp-help").find("input[name=helptext]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genDocname]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genDoctPk]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genDocstatus]").attr("selval", -1).trigger("change");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genDocstatus]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genRefno]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genrefDate]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genValidDate]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_gennotes]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genrowPk]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genRefno]").attr("style", "display:inline-block");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").attr("style", "display:inline-block");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genValidDate]").attr("style", "display:inline-block");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_genrefDate]").attr("style", "display:inline-block");
}


function fncheckDoc(elem) {
    $(elem).parents("li").siblings("li").find("comp-help").find("input[name=helptext]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_Docname]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_DoctPk]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_Docstatus]").attr("selval", -1).trigger("change");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_Docstatus]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_notes]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_rowPk]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").attr("style", "display:inline-block");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").attr("style", "display:inline-block");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").attr("style", "display:inline-block");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").attr("style", "display:inline-block");
}


function callchange(elem) {
    fnClearForm("selfemp-clear", 1);
    fnClearForm("salaried-clear", 1);
}
function callrental(elem)
{
    $(elem).parents("li").siblings("li.rental").find("input").val(0);
    if (($(elem).val() == "Rental") || ($(elem).val() == "Paying Guest"))
    {  
        $(elem).parents("li").siblings("li.rental").attr("style", "display:block;");    
    }
    else
    {
        $(elem).parents("li").siblings("li.rental").attr("style", "display:none;");
    }
}
function validatetitle(elem) {
  
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($("#" + val + " .frstdiv").find("input[key='dde_gender']").val() == "Female") {
        if ($(elem).val() == "Mr") {
            fnShflAlert("error","Title and Gender Mismatch!");
            return;
        }
    }
    else {
        if ($(elem).val() != "Mr") {
            fnShflAlert("error","Title and Gender Mismatch!");
            return;
        }

    }
}
function validategender(elem) {

    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).val() == "Female") {
        if ($("#" + val + " .frstdiv").find("input[key='dde_title']").val() == "Mr") {
            fnShflAlert("error","Title and Gender Mismatch!");
            return;
        }
    }
    else {

        if ($("#" + val + " .frstdiv").find("input[key='dde_title']").attr("selval") != -1) {
            if ($("#" + val + " .frstdiv").find("input[key='dde_title']").val() != "Mr") {
                fnShflAlert("error","Title and Gender Mismatch!");
                return;
            }
        }
    }
}
//30/11/2016  Changes
function callselfemp(elem) {

    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    var finval = $(elem).val();
    var selval = $(elem).attr("selval");
    fnClearForm("selfemp-clear", 1);
    //$("#" + Id + " .selfemp-div").find("comp-help").find("input[name=helptext]").val("");
    $(elem).val(finval);
    $(elem).attr("selval", selval);
    $("#" + Id + " .selfemp-div").find(".othercls").hide();
    $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus_others']").removeAttr("class")
}

function fniconPlusLiability(elem) {

    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    var ObligationGrid = $("#" + val + " .obligation_grid");
    var icon = "";
    $(elem).addClass("active");
    $(elem).siblings("li").removeClass("active");
    setTimeout(function () {
        $("#dde_div_appPop").hide();
        $(elem).removeClass("active");
    }, 200);
    var iconimg = $(elem).find("i");
    var icon = $(iconimg).attr("class");
    var rem = $(iconimg).attr("val");
    if ($(ObligationGrid).css('display') == 'none') {
        $(ObligationGrid).css("display","block");
    }
    else {
        $(ObligationGrid).append(globalicon);
    }
    var len = ($(ObligationGrid).children("ul.rowGrid").length);
    $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass(icon);
    $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(rem);
    $(ObligationGrid).children("ul:last-child").find("#img-switcher").removeAttr('id');
    $(ObligationGrid).children("ul:last-child").find(".IsShri").attr('id', 'img-switcher' + val + len + '');
    $(ObligationGrid).children("ul:last-child").find(".imgli").removeAttr('for');
    $(ObligationGrid).children("ul:last-child").find(".imgli").attr('for', 'img-switcher' + val + len + '');

    $(ObligationGrid).children("ul:last-child").find("#myonoffswitchia").removeAttr('id');
    $(ObligationGrid).children("ul:last-child").find(".IsInclOnOff").attr('id', 'myonoffswitchia' + val + len + '');
    $(ObligationGrid).children("ul:last-child").find(".onoffswitch-label").removeAttr('for');
    $(ObligationGrid).children("ul:last-child").find(".onoffswitch-label").attr('for', 'myonoffswitchia' + val + len + '');
    $(ObligationGrid).children("ul:last-child").find("li i.icon-chat-o").val("");
    $("#dde_div_appPop").hide();
}

function validatebank() {

    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    var finalval = $("#" + Id).find("[key='dde_Fname']").val() + " " + $("#" + Id).find("[key='dde_Mname']").val() + " " + $("#" + Id).find("[key='dde_Lname']").val();
    $("#" + Id + " .bank-div .rowGrid").each(function () {
        $(this).find("[colkey=dde_Bank_Name1]").val(finalval);

    });
}

function validatepan() {

    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    $(document).on("focusout", "#" + Id + " [key='dde_pan_no']", function () {
        var ValUCase = UpperCase($(this).val());
        $(this).val(ValUCase);

        var RtnSts = ValidatePAN(ValUCase);
        if (RtnSts == false) {
            fnShflAlert("error", "Invalid PAN ID");
            $(this).focus();
            return;
        }
    });
}
function validatepancard(elem) {

    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var ValUCase = UpperCase($(elem).val());
        $(elem).val(ValUCase);
        var RtnSts = ValidatePAN(ValUCase);
        if (RtnSts == false) {
            fnShflAlert("error", "Invalid PAN ID for KYC Document details");
            $(elem).focus();
    }
}
//function fnloadrefno()
//{

//    var LapFk = $(Cur_Active_Actor_li).attr("Pk");
//    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["SelectRefno", JSON.stringify(DDEGlobal), '', '', LapFk] }
//    fnCallLOSWebService("DDE_Refno", objProcData, fnDDEResult, "MULTI");
//}

//function fnloaddocrefno() {

//    var LapFk = $(Cur_Active_Actor_li).attr("Pk");
//    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["SelectDocRefno", JSON.stringify(DDEGlobal), '', '', LapFk] }
//    fnCallLOSWebService("DDE_docRefno", objProcData, fnDDEResult, "MULTI");
//}

//function fnloaddocGenrefno() {

//    var LapFk = $(Cur_Active_Actor_li).attr("Pk");
//    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["SelectDocGenRefno", JSON.stringify(DDEGlobal), '', '', LapFk] }
//    fnCallLOSWebService("DDE_docgenRefno", objProcData, fnDDEResult, "MULTI");
//}
//$(document).on("blur", ".reference", function () {
//    var ErrMsg = "";

//    if (globalrefno.length > 0) {
//        for (i = 0; i < globalrefno.length; i++) {
//            if (globalrefno[i].REFNO != "") {
//            if ($(this).val() == globalrefno[i].REFNO) {
//                ErrMsg = ErrMsg == "" ? "Reference no already exists!!" : ErrMsg + "<br/>Reference no already exists!!";
//            }
//        }
//        }
//        if (ErrMsg != "") {
//            fnShflAlert("error", ErrMsg);
//            $(this).focus();
//        }
//    }
//});
//$(document).on("blur", ".doc_reference", function () {
//    var ErrMsg = "";
 
//    if (globaldocrefno.length > 0) {
//        for (i = 0; i < globaldocrefno.length; i++) {
//            if (globaldocrefno[i].REFNO != "") {
//                if ($(this).val() == globaldocrefno[i].REFNO) {
//                    ErrMsg = ErrMsg == "" ? "Reference no already exists!!" : ErrMsg + "<br/>Reference no already exists!!";
//                }
//            }
//        }
//        if (ErrMsg != "") {
//            fnShflAlert("error", ErrMsg);
//            $(this).focus();
//        }
//    }
//});
//$(document).on("blur", ".docgen_reference", function () {

//    var ErrMsg = "";
//    if (globaldocgenrefno.length > 0) {
//        for (i = 0; i < globaldocgenrefno.length; i++) {
//            if (globaldocgenrefno[i].REFNO != "") {
//                if ($(this).val() == globaldocgenrefno[i].REFNO) {
//                    ErrMsg = ErrMsg == "" ? "Reference no already exists!!" : ErrMsg + "<br/>Reference no already exists!!";
//                }
//            }
//        }
//        if (ErrMsg != "") {
//            fnShflAlert("error", ErrMsg);
//            $(this).focus();
//        }
//    }
//});

function fnAddresi(elem)
{
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).prop("checked")) {
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_flat").val();
        $("#" + val + " .selfemp-div").find(".ddeBflatno").val(val1).trigger("change");
        $("#" + val + " .selfemp-div").find(".ddeBflatno").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_build").val();
        $("#" + val + " .selfemp-div").find(".ddeBbuild").val(val1).trigger("change");
        $("#" + val + " .selfemp-div").find(".ddeBbuild").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_plot").val();
        $("#" + val + " .selfemp-div").find(".ddeBPlot").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBPlot").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_strt").val();
        $("#" + val + " .selfemp-div").find(".ddeBStrt").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBStrt").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_lnd").val();
        $("#" + val + " .selfemp-div").find(".ddeBlandmark").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBlandmark").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_twn").val();
        $("#" + val + " .selfemp-div").find(".ddeBtwn").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBtwn").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_dsrt").val();
        $("#" + val + " .selfemp-div").find(".ddeBdistrict").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBdistrict").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_stat").val();
        $("#" + val + " .selfemp-div").find(".ddeBstate").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBstate").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_pin").val();
        $("#" + val + " .selfemp-div").find(".ddeBpin").val(val1);
        $("#" + val + " .selfemp-div").find("comp-help").find("input[name=helptext]").val(val1);
        $("#" + val + " .selfemp-div").find(".ddeBpin").attr("readonly", "true");
        $("#" + val + " .selfemp-div").find(".ddeBpin").parents("li").find("comp-help").attr("readonly", "true");

    }
    else {

        $("#" + val + " .selfemp-div").find(".ddeBflatno").val("");
        $("#" + val + " .selfemp-div").find(".ddeBflatno").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBbuild").val("");
        $("#" + val + " .selfemp-div").find(".ddeBbuild").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBPlot").val("");
        $("#" + val + " .selfemp-div").find(".ddeBPlot").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBStrt").val("");
        $("#" + val + " .selfemp-div").find(".ddeBStrt").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBlandmark").val("");
        $("#" + val + " .selfemp-div").find(".ddeBlandmark").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBtwn").val("");
        $("#" + val + " .selfemp-div").find(".ddeBtwn").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBdistrict").val("");
        $("#" + val + " .selfemp-div").find(".ddeBdistrict").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBstate").val("");
        $("#" + val + " .selfemp-div").find(".ddeBstate").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBpin").val("");
        $("#" + val + " .selfemp-div").find(".ddeBpin").removeAttr("readonly");
        $("#" + val + " .selfemp-div").find(".ddeBpin").parent().find("comp-help").find("input[name=helptext]").val("");
        $("#" + val + " .selfemp-div").find(".ddeBpin").parents("li").find("comp-help").removeAttr("readonly");
    }

}
function fnAddpermanent(elem) {
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).prop("checked")) {

        var val1 = $("#" + val + " .present_permanent_div").find(".dde_flat").val();
        $("#" + val + " .present_permanent_div").find(".dde_pflat").val(val1).trigger("change");
        $("#" + val + " .present_permanent_div").find(".dde_pflat").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_build").val();
        $("#" + val + " .present_permanent_div").find(".dde_pbuild").val(val1).trigger("change");
        $("#" + val + " .present_permanent_div").find(".dde_pbuild").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_plot").val();
        $("#" + val + " .present_permanent_div").find(".dde_pPlot").val(val1);
        $("#" + val + " .present_permanent_div").find(".dde_pPlot").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_strt").val();
        $("#" + val + " .present_permanent_div").find(".dde_pstrt").val(val1);
        $("#" + val + " .present_permanent_div").find(".dde_pstrt").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_lnd").val();
        $("#" + val + " .present_permanent_div").find(".dde_plnd").val(val1);
        $("#" + val + " .present_permanent_div").find(".dde_plnd").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_twn").val();
        $("#" + val + " .present_permanent_div").find(".dde_ptwn").val(val1);
        $("#" + val + " .present_permanent_div").find(".dde_ptwn").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_dsrt").val();
        $("#" + val + " .present_permanent_div").find(".dde_pdist").val(val1);
        $("#" + val + " .present_permanent_div").find(".dde_pdist").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_stat").val();
        $("#" + val + " .present_permanent_div").find(".dde_pstat").val(val1);
        $("#" + val + " .present_permanent_div").find(".dde_pstat").attr("readonly", "true");
        var val1 = $("#" + val + " .present_permanent_div").find(".dde_pin").val();
        $("#" + val + " .present_permanent_div").find(".dde_pPin").val(val1);
        $("#" + val + " .present_permanent_div").find("comp-help").find("input[name=helptext]").val(val1);
        $("#" + val + " .present_permanent_div").find("dde_pre_per_hidden").val(0);
        $("#" + val + " .present_permanent_div").find(".dde_pPin").attr("readonly", "true");
        $("#" + val + " .present_permanent_div").find(".dde_pPin").parents("li").find("comp-help").attr("readonly", "true");

    }
    else {

        $("#" + val + " .present_permanent_div").find(".dde_pflat").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pflat").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pbuild").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pbuild").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pPlot").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pPlot").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pstrt").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pstrt").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_plnd").val("");
        $("#" + val + " .present_permanent_div").find(".dde_plnd").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_ptwn").val("");
        $("#" + val + " .present_permanent_div").find(".dde_ptwn").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pdist").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pdist").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pstat").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pstat").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pPin").val("");
        $("#" + val + " .present_permanent_div").find(".dde_pPin").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pPin").parents("li").find("comp-help").removeAttr("readonly");
        $("#" + val + " .present_permanent_div").find(".dde_pPin").parent().find("comp-help").find("input[name=helptext]").val("");
        $("#" + val + " .present_permanent_div").find(".premenent-aaddress").attr("contentchanged", "false");

    }


}

function fnLoadDocDatas(DocJson) {
    $(".popup.doc-list-view").empty();
    var Data = DocJson;
    var ul = '';
    for (var i = 0; i < Data.length; i++) {
        var apptype = Data[i].Actor == 1 ? "Applicant" : "CoApplicant";
        ul += '<ul pk="' + Data[i].Pk + '"><li>' + Data[i].DocName + '<p><span class="bg">' + apptype + '</span><span class="bg">' + Data[i].Catogory + '</span> <span class="bg">' + Data[i].SubCatogory + '</span></p>' +
            '</li><li><i class="icon-document doc-view" docpath="' + Data[i].DocPath + '" onclick="fnOpenDocs(this)" ></i></li><li><i class="icon-delete"></i></li></ul>';
    }
    $(".popup.doc-list-view").append(ul);
}
function fnOpenDocs(elem) {

    $("#document-content").css("display", "none");
    var path = $(elem).attr("docpath");
    localStorage.setItem("previewPath", path);
    $(".content-div").addClass("center-collapse");
    $("#div-document-content").show();
    $(".grid-type ul").removeClass("form-controls").addClass("grid-controls");
    popupclose();
    LoadHtmldoc('documents.html');
}

function LoadHtmldoc(HtmlPage) {
    $("#div-document-content").empty();
    $("#div-document-content").load(HtmlPage);
}

function fnobbind() {
    $(document).on("click", ".IsInclOnOff", function () {
        var closestobj = $(this).parents("li").siblings(".dde_ob_IsIncl");
        if ($(this).is(":checked")) {
            $(closestobj).children("input").val("0").trigger("change");
        }
        else {
            $(closestobj).children("input").val("1").trigger("change");
        }
    });
    $(document).on("click", ".IsShri", function () {
        var closestobj = $(this).parents("li").siblings(".dde_ob_IsShri");
        if ($(this).is(":checked")) {
            $(closestobj).children("input").val("0").trigger("change");
        }
        else {
            $(closestobj).children("input").val("1").trigger("change");
        }
    });
}

function fnremarks() {
    
    $(document).on("click", ".pop_bg", function () {
 
        var rem = $("textarea#dde_rem").val();
        $(globalremarks).children("input").val(rem).trigger("change");
        //$(globalremarks).parent().find("li.icn").find("i").attr("txtval", rem);
    });
}

function fnkycremarks()
{
    $(document).on("click", ".Kycpop_bg", function () {
        var rem = $("textarea#dde_kycrem").val();
        $(globalKycremarks).children("input").val(rem).trigger("change");
    });
}

function fnkycaddremarks() {
    $(document).on("click", ".Kycaddpop_bg", function () {
        var rem = $("textarea#dde_kycaddrem").val();
        $(globalKycaddremarks).children("input").val(rem).trigger("change");
    });
}
function fndocremarks() {
    $(document).on("click", ".Docpop_bg", function () {
        var rem = $("textarea#dde_Docrem").val();
        $(globalDocremarks).children("input").val(rem).trigger("change");
    });
}

function fndocgenremarks() {
    $(document).on("click", ".Docgenpop_bg", function () {
        var rem = $("textarea#dde_Docgenrem").val();
        $(globalDocgenremarks).children("input").val(rem).trigger("change");
    });
}
function fnBindWork(ctrlObj, Action) {
    var closestobj = $(ctrlObj).closest(".dde_cont");
    if ($(closestobj).is("[contentchanged]")) {
        $(closestobj).attr("contentchanged", Action);
        var val = (Action == "false") ? 0 : $(closestobj).attr("val");
        try {
            $(closestobj).children("input[type='hidden']").val(val);
        } catch (e) { }
    }
}

function fnBindEvts(id, Action) {
    $("#" + id).find("*").each(function () {
        if ($(this).is("[key]") || $(this).is("[colkey]")) {
            if (Action == 'CLEAR') {
                fnBindWork($(this), "false");
            }
            else {
                if ($(this).is("[key]"))
                    $(document).on("change", "#" + id + " [key]", function () {
                        fnBindWork($(this), "true");
                    });

                $(document).on("change", "#" + id + " [colkey]", function () {
                    fnBindWork($(this), "true");
                });
            }
        }
    });
}
function fnAddgendoc()
{
 
    var ErrMs = "";
    var c = 1;
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
        if ($(this).find("li").find("input[colkey=Com_genDoctype]").attr("selval") != -1) {
            if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                ErrMs = ErrMs == "" ? "Document Details: Document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Document name Required_Row:" + c + "!!";
                return false;
            }
            //else if ($(this).find("li").find("input[colkey=Com_genDocstatus]").attr("selval") == -1) {
            //    ErrMs = ErrMs == "" ? "Document Details: Select Document status Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Select Document status Required_Row:" + c + "!!";
            //    return false;
            //}
            else if (($(this).find("li").find("input[colkey=Com_genRefno]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_genRefno]").attr("style") == "display:inline-block")) {
                ErrMs = ErrMs == "" ? "Document Details: Reference no Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Reference no Required_Row:" + c + "!!";
                return false;
            }
            //else if (($(this).find("li").find("input[colkey=Com_genRecDate]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_genRecDate]").attr("style") == "display:inline-block")) {
            //    ErrMs = ErrMs == "" ? "Document Details: Received date Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Received date Required_Row:" + c + "!!";
            //    return false;
            //}

            else if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=Com_genDocname]").val()) {
                    ErrMs = ErrMs == "" ? "Document Details: Valid document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Valid document name Required_Row:" + c + "!!";
                    return false;
                }
            }
            c++;
        }
    });
    var c = 1;
    $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
        if ($(this).find("li").find("input[colkey='Com_genRecDate']").val().trim() != "") {
            var dateval = $(this).find("li").find("input[colkey='Com_genRecDate']").val()
            var date = dateval.substring(0, 2);
            var month = dateval.substring(3, 5);
            var year = dateval.substring(6, 10);
            var dateToCompare = new Date(year, month - 1, date);
            var currentDate = new Date();
            if (dateval != '') {
                if (dateToCompare > currentDate) {
                    ErrMs = ErrMs == "" ? "Received Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMs + "<br/>Received Date Should not be greater than Current Date_Row:" + c + "!!";
                    return false;
                }
            }
        }
        c++;
    });
    if (ErrMs != "") {
        fnShflAlert("error", ErrMs);
        return;
    }


    debugger

    var s = '';
    var close = '';

    s +=  '<ul class="grid-controls rowGrid box-docGEN-ul">'+
               '<li class="width-9">'+
                    '<div class="select-focus">'+
                        '<input placeholder="Select" onkeydown="return false" selval="-1" name="select" colkey="Com_genDoctype" class="autofill" onchange="fncheckgenDoc(this)">'+
                              '<i class="icon-down-arrow_1"></i>'+
                                   '<ul class="custom-select">'+
                                           '<li val="O">Original</li>'+
                                           '<li val="P">Photocopy</li>'+
                                           '<li val="C">Certified</li>'+
                                    '</ul>'+
                     ' </div>'+
                  ' </li>'+
                  '<li class="width-11">'+
                      '<comp-help id="comp-help" txtcol="DocumentName" valcol="DocPk" onrowclick="Comgenclick" prcname="PrcShflDocumenthhelp" width="100%"></comp-help>'+
                      '<input type="hidden" placeholder="" name="text" colkey="Com_genDocname" value="">'+
                      '<input type="hidden" placeholder="" name="text" colkey="Com_genDoctPk" value="">'+
                   '</li>'+
                   '<li class="width-9">'+
                  '<div class="select-focus">'+
                        '<input placeholder="Select" onkeydown="return false" selval="-1" name="select" colkey="Com_genDocstatus" onchange="fngenchange(this)" class="autofill">'+
                             '<i class="icon-down-arrow_1"></i>'+
                                   '<ul class="custom-select">'+
                                    '<li val="R">Received</li>'+
                                    '<li val="N">Not-Received</li>'+
                                    '<li val="E">Recorded</li>'+
                                       '</ul>'+
                                   '</div>'+
                             '</li>'+
                               '<li class="width-9">'+
                               '<input type="text" placeholder="" name="text" colkey="Com_genRefno" style="display:inline-block" class="docgen_reference" restrict="alphanumeric">'+
                              '</li>'+
                              '<li class="width-9">'+
                               '<input type="text" placeholder="" name="text" colkey="Com_genRecDate" style="display:inline-block" class="datepickerdef">'+
                              '  </li>'+
                              '  <li class="width-9 refdate">'+
                              '      <input type="text" placeholder="" name="text" colkey="Com_genrefDate" class="datepickerdef" />'+
                             '   </li>'+
                               ' <li class="width-9">'+
                             '       <input type="text" placeholder="" name="text" colkey="Com_genValidDate" style="display:inline-block" class="datepickerdef">'+
                             '   </li>'+
                             '   <li class="Com_icon width-9"> <i class="icon-chat-o" txtval=""></i> </li>'+
                             '   <li style="display:none;" class="Com_gennotes">'+
                            '        <input type="text" name="text" colkey="Com_gennotes" value="">'+
                           '     </li>'+
                           '     <li>'+
                           '         <input type="hidden" placeholder="" name="text" colkey="Com_genrowPk" value="">'+
                          '      </li>'+
                  '</ul>'

    $(".Doc_Gendiv").append(s);
    close += '<li><i class="icon-close" onclick="fnClosegenrow(this)"></i></li>';
    $(".Doc_Gendiv").children("ul:last-child").append(close);
    $(".Doc_Gendiv").children("ul:last-child").find(".datepickerdef").removeAttr("id");
    $(".Doc_Gendiv").children("ul:last-child").find(".datepickerdef").removeClass("hasDatepicker");
    fnDrawDefaultDatePicker();
    $(".Doc_Gendiv .datepicker,.datepickerdef").each(function () {
        fnRestrictDate($(this));
    });
    $(".Doc_Gendiv").children("ul:last-child").addClass("new");
    fnClearForm("new", 1);
    $(".Doc_Gendiv").find('.new').removeClass("new");
    fnInitiateSelect("Doc_Gendiv", 1);
}
function fnAdddoc() {

    var ErrMs = "";
    var c = 1;
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    $("#" + val + " .Doc_div .rowGrid").each(function () {
        if ($(this).find("li").find("input[colkey=Com_Doctype]").attr("selval") != -1) {
            if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                ErrMs = ErrMs == "" ? "Document Details: Document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Document name Required_Row:" + c + "!!";
                return false;
            }
            //else if ($(this).find("li").find("input[colkey=Com_Docstatus]").attr("selval") == -1) {
            //    ErrMs = ErrMs == "" ? "Document Details: Select Document status Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Select Document status Required_Row:" + c + "!!";
            //    return false;
            //}
            else if (($(this).find("li").find("input[colkey=Com_Refno]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_Refno]").attr("style") == "display:inline-block")) {
                ErrMs = ErrMs == "" ? "Document Details: Reference no Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Reference no Required_Row:" + c + "!!";
                return false;
            }
            //else if (($(this).find("li").find("input[colkey=Com_RecDate]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_RecDate]").attr("style") == "display:inline-block")) {
            //    ErrMs = ErrMs == "" ? "Document Details: Received date Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Received date Required_Row:" + c + "!!";
            //    return false;
            //}
          
            else if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=Com_Docname]").val()) {
                    ErrMs = ErrMs == "" ? "Document Details: Valid document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Valid document name Required_Row:" + c + "!!";
                    return false;
                }
            }
            c++;
        }
    });
    var c = 1;
    $("#" + val + " .Doc_div .rowGrid").each(function () {
        if ($(this).find("li").find("input[colkey='Com_RecDate']").val().trim() != "") {
            var dateval = $(this).find("li").find("input[colkey='Com_RecDate']").val()
            var date = dateval.substring(0, 2);
            var month = dateval.substring(3, 5);
            var year = dateval.substring(6, 10);
            var dateToCompare = new Date(year, month - 1, date);
            var currentDate = new Date();
            if (dateval != '') {
                if (dateToCompare > currentDate) {
                    ErrMs = ErrMs == "" ? "Received Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMs + "<br/>Received Date Should not be greater than Current Date_Row:" + c + "!!";
                    return false;
                }
            }
        }
        c++;
    });
    if (ErrMs != "") {
        fnShflAlert("error", ErrMs);
        return;
    }


    debugger

    var s = '';
    var close = '';

    s += '<ul class="grid-controls rowGrid box-doc-ul">' +
               '<li class="width-9">' +
                    '<div class="select-focus">' +
                        '<input placeholder="Select" onkeydown="return false" selval="-1" name="select" colkey="Com_Doctype" class="autofill" onchange="fncheckDoc(this)">' +
                              '<i class="icon-down-arrow_1"></i>' +
                                   '<ul class="custom-select">' +
                                           '<li val="O">Original</li>' +
                                           '<li val="P">Photocopy</li>' +
                                           '<li val="C">Certified</li>' +
                                    '</ul>' +
                     ' </div>' +
                  ' </li>' +
                  '<li class="width-11">' +
                      '<comp-help id="comp-help" txtcol="DocumentName" valcol="DocPk" onrowclick="Comclick" prcname="PrcShflDocumenthhelp" width="100%"></comp-help>' +
                      '<input type="hidden" placeholder="" name="text" colkey="Com_Docname" value="">' +
                      '<input type="hidden" placeholder="" name="text" colkey="Com_DoctPk" value="">' +
                   '</li>' +
                   '<li class="width-9">' +
                  '<div class="select-focus">' +
                        '<input placeholder="Select" onkeydown="return false" selval="-1" name="select" colkey="Com_Docstatus" onchange="fnchange(this)" class="autofill">' +
                             '<i class="icon-down-arrow_1"></i>' +
                                   '<ul class="custom-select">' +
                                    '<li val="R">Received</li>' +
                                    '<li val="N">Not-Received</li>' +
                                    '<li val="E">Recorded</li>' +
                                       '</ul>' +
                                   '</div>' +
                             '</li>' +
                               '<li class="width-9">' +
                               '<input type="text" placeholder="" name="text" colkey="Com_Refno" style="display:inline-block" class="doc_reference" restrict="alphanumeric">' +
                              '</li>' +
                              '<li class="width-9">' +
                               '<input type="text" placeholder="" name="text" colkey="Com_RecDate" style="display:inline-block" class="datepickerdef">' +
                              '  </li>' +
                              '  <li class="width-9 refdate">' +
                              '      <input type="text" placeholder="" name="text" colkey="Com_refDate" class="datepickerdef" />' +
                             '   </li>' +
                               ' <li class="width-9">' +
                             '       <input type="text" placeholder="" name="text" colkey="Com_ValidDate" style="display:inline-block" class="datepickerdef">' +
                             '   </li>' +
                             '   <li class="Com_icon width-9"> <i class="icon-chat-o" txtval=""></i> </li>' +
                             '   <li style="display:none;" class="Com_notes">' +
                            '        <input type="text" name="text" colkey="Com_notes" value="">' +
                           '     </li>' +
                           '     <li>' +
                           '         <input type="hidden" placeholder="" name="text" colkey="Com_rowPk" value="">' +
                          '      </li>' +
                  '</ul>'

    $("#" + val + " .Doc_div").append(s);
    close += '<li><i class="icon-close" onclick="fnCloserow(this)"></i></li>';
    $("#" + val + " .Doc_div").children("ul:last-child").append(close);
    $("#" + val + " .Doc_div").children("ul:last-child").find(".datepickerdef").removeAttr("id");
    $("#" + val + " .Doc_div").children("ul:last-child").find(".datepickerdef").removeClass("hasDatepicker");
    fnDrawDefaultDatePicker();
    $("#" + val + " .Doc_div .datepicker,.datepickerdef").each(function () {
        fnRestrictDate($(this));
    });
    $("#" + val + " .Doc_div").children("ul:last-child").addClass("new");
    fnClearForm("new", 1);
    $("#" + val + " .Doc_div").find('.new').removeClass("new");
    fnInitiateSelect("Doc_div", 1);
}
function fnchange(elem) {

    if ($(elem).val() == "Not-Received") {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").attr("style", "visibility:hidden");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").attr("style", "visibility:hidden");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").attr("style", "visibility:hidden");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").attr("style", "visibility:hidden");
    }
    else if ($(elem).val() == "Recorded") {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").attr("style", "display:none");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").attr("style", "display:inline-block");
    }
    else {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").attr("style", "display:inline-block");
    }
}
function fngenchange(elem) {

    if ($(elem).val() == "Not-Received") {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRefno]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genValidDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genrefDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRefno]").attr("style", "visibility:hidden");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").attr("style", "visibility:hidden");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genValidDate]").attr("style", "visibility:hidden");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genrefDate]").attr("style", "visibility:hidden");
    }
    else if ($(elem).val() == "Recorded") {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRefno]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").attr("style", "display:none");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genValidDate]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genrefDate]").attr("style", "display:inline-block");
    }
    else {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRefno]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genRecDate]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genValidDate]").attr("style", "display:inline-block");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_genrefDate]").attr("style", "display:inline-block");
    }
}
function fnCloserow(elem) {
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    var divlen = $("#" + val +" .Doc_div").find(".grid-controls.rowGrid.box-doc-ul").length;
        $(elem).closest("ul.grid-controls").remove();
    $("#" + val + " .Doc_div").attr("contentchanged", true);
}
function fnClosegenrow(elem) {
    var divlen = $(".Doc_Gendiv").find(".grid-controls.rowGrid.box-docGEN-ul").length;
        $(elem).closest("ul.grid-controls").remove();
    $(".Doc_Gendiv").attr("contentchanged", true);
}

function fnDocChk(elem) {
    if ($(elem).is(":checked")) {
        $(elem).parents("li").siblings("li").find("input[key = 'dde_adr_no']").attr("readonly", "true");
        $(elem).parents("li").siblings("li").find("input[key = 'dde_pan_no']").attr("readonly", "true");
        $(elem).parents("li").siblings("li").find("input[key = 'dde_vot_id']").attr("readonly", "true");
     
        $(elem).parents("li").siblings("li").find("input[key = 'dde_adr_no']").val("");
        $(elem).parents("li").siblings("li").find("input[key = 'dde_pan_no']").val("");
        $(elem).parents("li").siblings("li").find("input[key = 'dde_vot_id']").val("");    
    }
    else {
        $(elem).parents("li").siblings("li").find("input[key = 'dde_adr_no']").attr("readonly", false);
        $(elem).parents("li").siblings("li").find("input[key = 'dde_pan_no']").attr("readonly", false);
        $(elem).parents("li").siblings("li").find("input[key = 'dde_vot_id']").attr("readonly", false);      
    }

}
function fncleardata(elem)
{
    if($(elem).find("comp-help").find("input[name=helptext]").val() =="")
    {
        $(elem).siblings("li").find("input[colkey=dde_KycRefno]").val("").trigger("change");
        $(elem).siblings("li.date").find("input[colkey=dde_KycDate]").val("");
        $(elem).siblings("li.date").attr("style", "visibility:hidden");
        $(elem).siblings("li.refdate").find("input[colkey=dde_KycrefDate]").val("");
        $(elem).find("input[colkey=dde_KycDocument]").val("");
        $(elem).find("input[colkey=dde_KycPk]").val("");
    }
}
function fnclearadddata(elem) {
    if ($(elem).find("comp-help").find("input[name=helptext]").val() == "") {
        $(elem).siblings("li").find("input[colkey=dde_KycaddRefno]").val("").trigger("change");
        $(elem).siblings("li.date").find("input[colkey=dde_KycaddDate]").val("");
        $(elem).siblings("li.date").attr("style", "visibility:hidden");
        $(elem).siblings("li.refdate").find("input[colkey=dde_KycaddrefDate]").val("");
        $(elem).find("input[colkey=dde_KycaddDocument]").val("");
        $(elem).find("input[colkey=dde_KycaddPk]").val("");
    }
}
function fnQDELoadLeadDetails(Action, LapFk, QdeFk, RefFk) {
    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: [Action, JSON.stringify(DDEGlobal), JSON.stringify(LogJson), DocAppRef, LapFk, RefFk, QdeFk] }
    fnCallLOSWebService("DDE_LdDtls", objProcData, fnDDEResult, "MULTI", Action);
}


function fnDDELoadDocDetails() {
    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["DocLoad", JSON.stringify(DDEGlobal)] }
    fnCallLOSWebService("DDE_Doc", objProcData, fnDDEResult, "MULTI");
}

function fnDDEResult(ServDesc, Obj, Param1, Param2) {
    if (!Obj.status) {
        fnShflAlert("error",Obj.error);
        return;
    }
    /*muthuchange(16/12)*/
    if (ServDesc == "PrdUpdate") {
        $("#product_popupdiv").hide();
    }
    /*end*/
    if (ServDesc == "DDE_Doc") {
        
        var DocJson = JSON.parse(Obj.result_1);
        if (DocJson.length > 0) {
            fnLoadDocDatas(DocJson);
        }
        var salofzdata = JSON.parse(Obj.result_3);
        if (salofzdata.length > 0) {
            var location = salofzdata[0].Location ? salofzdata[0].Location : "";
            if (location != "") {
                $("#dde_content_Pg").find("li.saleofz comp-help").find("input[name='helptext']").val(salofzdata[0].Location);
                $("#dde_content_Pg").find("li.saleofz input[key=dde_builoc]").attr("valtext", salofzdata[0].Location);
            }
        }
        /*change08/12/16(muthu)*/
        var prdqdedata = JSON.parse(Obj.result_2)
        var classnm = ''; var text = '';
        if (prdqdedata[0].productpk == 4) {
            $("#prddiv i").attr("pk", 4);
            classnm = "icon-home-loan";
            text = "Home Loan";
        }
        if (prdqdedata[0].productpk == 5) {
            $("#prddiv i").attr("pk", 5);
            classnm = "icon-lap";
            text = "Loan Against Property";
        }
        if (prdqdedata[0].productpk == 6) {
            $("#prddiv i").attr("pk", 6);
            classnm = "icon-plot-loan";
            text = "Plot Loan";
        }
        var lihtml = ''
        lihtml = '<i class = ' + classnm + '></i><p>' + text + '</p>'
        $("#prddiv").append(lihtml)
        if (prdqdedata.length > 0) {
            $("#prddiv i").attr("pk", prdqdedata[0].productpk);
            Pgrpfk = prdqdedata[0].productpk;
            $("#LeadPrdPk").val(prdqdedata[0].productpk);
            $("#LeadPrdPk").attr("pcd", prdqdedata[0].PCd);
        }
        /*end*/
    }
    //if (ServDesc == "sel_icon") {    
    //    /*change(muthu)*/
    //    var prddata = JSON.parse(Obj.result);
    //    var clsNm = '';
    //    var prd = '';
    //    for (var i = 0; i < prddata.length; i++) {
    //        var liActive = "";
    //        if (prddata[i].ProductCode == $("#LeadPrdPk").attr("pcd")) {
    //            liActive = 'class="active"'
    //        }
    //        clsNm = prddata[i].classnm;
    //        prd += '<li ' + liActive + ' cursor="pointer" ><i pcd= "' + prddata[i].ProductCode + '" pk = "' + prddata[i].productpk + '" class="' + clsNm + '"></i><p>' + prddata[i].productnm + '</p></li>'
    //    }
    //    $("#ul_Prd").append(prd);
    //}
    /*end*/

    if (ServDesc == "DDE_LdDtls") {
        if (Param2 == "Ref") {
            fnSetValues("dde_ref_div_" + $(Cur_Active_ref_li).attr("val"), JSON.parse(Obj.result));
        }
        if (Param2 == "LdDtls") {

            var TabDtls = JSON.parse(Obj.result_1);

            if (TabDtls.length > 0) {     
                $("#dde_ul_app_tabs").empty();
                fnDdeAddNewTab(TabDtls);
                emptypedtls = TabDtls;
            }


        }
        if (JSON.parse(Obj.result_2)[0].FLG == 1) {
            debugger
            var data = JSON.parse(Obj.result_3);
            
            fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", data, 1);

        }
        else if (JSON.parse(Obj.result_2)[0].FLG == 2) {
            DocAppRef = JSON.parse(Obj.result_1)[0].AppFk;
          
            if (Param2 == "LdDtls") {
                
                var HdrInfo = JSON.parse(Obj.result_3);
                if (HdrInfo.length > 0) {
                    fnSetValues("dde_div_top_leadinfo", HdrInfo);
                }
            }

            try {
                debugger
                var FinalData = {};
                var FinalArr = [];
                var ReferenceData = {};
                var ReferArr = [];
                var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                $.extend(FinalData, JSON.parse(Obj.result_4)[0]);
                $.extend(FinalData, JSON.parse(Obj.result_5)[0]);
                $.extend(FinalData, JSON.parse(Obj.result_6)[0]);
                $.extend(FinalData, JSON.parse(Obj.result_7)[0]);
                $.extend(FinalData, JSON.parse(Obj.result_8)[0]);
                $.extend(FinalData, JSON.parse(Obj.result_9)[0]);
                FinalArr.push(FinalData);
                fnSetValues(Id, FinalArr);
                
                var otherdocuments = JSON.parse(Obj.result_4);
                if (otherdocuments.length > 0)
                {
                    if(otherdocuments[0].dde_chk_doc == 'Y')
                    {
                        $("#" + Id + " .seconddiv").find("input[key='dde_chk_doc']").prop("checked", true);
                        fnDocChk($("#" + Id + " .seconddiv").find("input[key='dde_chk_doc']"));
                    }
                }

                var rentype = JSON.parse(Obj.result_5);
                if (rentype.length > 0) {
                    if ((rentype[0].dde_Per_acc == 0) || (rentype[0].dde_Per_acc == 2)) {
                        $("#" + Id).find("li.rental").attr("style", "display:block;");
                    }
                }

                var chcktype = JSON.parse(Obj.result_6);
                if (chcktype.length > 0) {
                    if (chcktype[0].dde_pre_IsSameAdr == 0) {
                        var send = $("#" + Id + " .chcktypeclass").find("input[key='dde_pre_IsSameAdr']");
                        $("#" + Id + " .chcktypeclass").find("input[key='dde_pre_IsSameAdr']").prop("checked", true);
                        $("#" + Id + " .chcktypeclass").parent("ul").attr("contentchanged", "true");
                        fnAddpermanent(send);

                    }
                }
             
                var otherstyp = JSON.parse(Obj.result_4)[0].dde_Per_Religion;
                if (otherstyp.length > 0) {
                    if ((otherstyp != "-1") && (otherstyp != "H") && (otherstyp != "M") && (otherstyp != "C") && (otherstyp != "S") && (otherstyp != "B") && (otherstyp != "J")) {
                        $("#" + Id + " .personal-div").find("input[key='dde_Per_Religion']").val("Others");
                        $("#" + Id + " .personal-div").find(".otherclass").show();
                        $("#" + Id + " .personal-div").find("input[key='dde_Per_religion_other']").val(otherstyp);
                        $("#" + Id + " .personal-div").find("input[key='dde_Per_religion_other']").attr("class", "mandatory");
                    }
                }
                /*muthu(21/12/16)*/
                var commother = JSON.parse(Obj.result_4)[0].dde_Per_community_other;
             
                if (commother != null) {
                    if (commother.length > 0) {
                        var comm = JSON.parse(Obj.result_4)[0].dde_Per_community
                        if ((comm == "5")) {
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_community']").val("Others");
                            $("#" + Id + " .personal-div").find("#licommother").show();
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_edu_others']").val(commother);
                        }
                    }
                }
                /*end*/
                /*change (muthu)27/12/16*/
                var edu = JSON.parse(Obj.result_4)[0].dde_Per_education;
                if (edu == "5") {
                    $("#dde_univer_id").hide();
                }
                /*end*/
                /*muthu(22/12/16)*/
                var eduother = JSON.parse(Obj.result_4)[0].dde_Per_edu_others;
    
                if (eduother != null) {
                    if (eduother.length > 0) {
                        var edu = JSON.parse(Obj.result_4)[0].dde_Per_education;
                        if (edu == "4") {
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_education']").val("Others");
                            $("#" + Id + " .personal-div").find("#lieduother").show();
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_edu_others']").val(eduother);
                        }
                    }
                }
                /*end*/

                //30/11/2016  Changes
          
                var OCC = JSON.parse(Obj.result_4)[0].dde_occ_typeOfEmployment;
                if ((OCC == 2) || (OCC == 3) || (OCC == -1)) {
                    $("#" + Id + " .salaried-div").hide();
                    $("#" + Id + " .salaried-div").hide();
                    $("#" + Id + " .salaried-div").hide();
                }

              

               
                //30/11/2016  Changes
                if (JSON.parse(Obj.result_7).length > 0) {
                    var nat = JSON.parse(Obj.result_7)[0].dde_occSelf_NaturOfBus;
                    if (nat.length > 0) {

                        if ((nat != "-1") && (nat != "0") && (nat != "1") && (nat != "2") && (nat != "3") && (nat != "4") && (nat != "5") && (nat != "6") && (nat != "7")) {
                            $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus']").val("Others");
                            $("#" + Id + " .selfemp-div").find(".othercls").show();
                            $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus_others']").val(nat);
                            $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus_others']").attr("class", "mandatory");
                        }
                    }
                }

       
                //if (JSON.parse(Obj.result_7).length > 0) {
                //    var bustyp = JSON.parse(Obj.result_7)[0].dde_occSelf_typOfbus;
                //    if (bustyp != null) {
                //        if (bustyp == 1) {
                //            $("#" + Id + " .selfemp-div").find(".liorgan").hide();

                //        }
                //    }
                //}
               
                var reftyp = JSON.parse(Obj.result_4)[0].dde_Per_relationwitSvs;
                var ref = JSON.parse(Obj.result_4)[0].dde_Per_refNO;
                if (reftyp != null) {
                    if (reftyp.length > 0) {
                        if (reftyp != "N") {
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_relationwitSvs']").val("Yes");
                            $("#" + Id + " .personal-div").find(".refclass").show();
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_refNO']").val(ref);
                            $("#" + Id + " .personal-div").find("input[key='dde_Per_refNO']").attr("class", "mandatory");
                        }
                    }
                }
               
                var EmpClass = JSON.parse(Obj.result_4)[0].EmpClass;
                if (EmpClass != "") {
                    $("#" + Id).find("." + EmpClass).click();
                    $("#" + Id).find("input[key='dde_Occ_hidden']").val("0");
                    $("#" + Id).find(".det-content2").attr("contentchanged", "false");
                }

           debugger
                var setval = JSON.parse(Obj.result_4)[0].dde_occ_typeOfEmployment;
                if (setval == -1)
                {
                    if (JSON.parse(Obj.result_9)[0] != undefined )
                        {
                        var addtyp = JSON.parse(Obj.result_9)[0].AddType;
                        if (addtyp == -1) {
                            var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                            var setvaladd = JSON.parse(Obj.result_9);
                            fnSetValues(Id, setvaladd);
                        }
                    }
                }


                var BankDtls = JSON.parse(Obj.result_10);
                var Asset = JSON.parse(Obj.result_11);
                var Oblig = JSON.parse(Obj.result_12);

                var Credit = JSON.parse(Obj.result_13);
                fnddeSetGridDatas([], BankDtls, Asset, Oblig, Credit);


                if (Param2 == "LdDtls") {
                    var LgHier = JSON.parse(Obj.result_14);
                    fnddeSetGridDatas(LgHier, [], [], [], []);

                    var RefDtls = JSON.parse(Obj.result_15);

                    if (RefDtls.length > 0) {
                        for (var i = 0; i < RefDtls.length; i++) {
                            if (i > 0) {
                                fnddeAddNewRefTab($("#dde_ul_ref_tabs .DDERefAdd"));
                            }
                            $("#dde_ul_ref_tabs li[val='3" + i + "']").attr("Pk", RefDtls[i].pk);
                        }
                        fnSetValues("dde_ref_div_30", JSON.parse(Obj.result_26));
                    }
                    fnShowSelDiv('R', $("#dde_ul_ref_tabs li[val='30']"));
                    
                    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var dataInfo = JSON.parse(Obj.result_16);
                    if (dataInfo.length > 0) {

                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", dataInfo);


                    }
                    var dataInfo1 = JSON.parse(Obj.result_17);
                    if (dataInfo1.length > 0) {

                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", dataInfo1);

                    }

                    var dataInfo2 = JSON.parse(Obj.result_18);
                    if (dataInfo2.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", dataInfo2);
                    }
                   
                    var Asset = JSON.parse(Obj.result_19);
                    if (Asset.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", Asset)
                    }

                    var OB = JSON.parse(Obj.result_20);
                    if (OB.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", OB)
                    }

                    var CC = JSON.parse(Obj.result_21);
                    if (CC.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", CC)
                    }
               
                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var kyc = JSON.parse(Obj.result_22);
                    if (kyc.length > 0) {
                        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                        //fnSetGridVal("Kyc_div", Id, kyc);
                        for (i = 0; i < kyc.length; i++) {
                            if (kyc[i].dde_KycProof == "A") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            if (kyc[i].dde_KycProof == "I") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            if (kyc[i].dde_KycProof == "D") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                            }
                            if (kyc[i].dde_KycProof == "S") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                            }
                        }



                        $("#" + val + " .Kyc_div .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='dde_KycDocument']").val();
                            var DOCTYPE = $(this).find("li").find("input[colkey='dde_KycProof']").attr("selval");
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                            $(this).find("li comp-help").attr("helpfk", DOCTYPE);
                            var date = $(this).find("li.date").find("input[colkey=dde_KycDate]").val();
                            if (date != undefined) {
                                if (date.trim() != "") {
                                    $(this).find("li.date").attr("style", "display:inline-block");
                                }
                            }
                        });


                    }
                    else {
                        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                }


                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var docdtls = JSON.parse(Obj.result_23);
                    if (docdtls.length > 0) {

                        for (var doc = 0; doc < docdtls.length; doc++) {
                                fnAdddoc();
                        }
                        fnSetGridVal("Doc_div", val, docdtls);

                        $("#" + val + " .Doc_div .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='Com_Docname']").val();
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                        
                            if($(this).find("li").find("input[colkey='Com_Docstatus']").val() == "Not-Received")
                            {
                                $(this).find("li").find("input[colkey=Com_Refno]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_RecDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_ValidDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_refDate]").attr("style", "visibility:hidden");
                            }
                        });

                        var ll = docdtls.length;
                        var rowcount = 0;
                        $("#" + val + " .Doc_div .rowGrid").each(function () {
                            if (rowcount >= ll) {
                                $(this).remove();
                            }

                            rowcount += 1;
                        })
                    }
                else {
                        var rowcount = 0;
                        $("#" + val + " .Doc_div .rowGrid").each(function () {
                            if (rowcount > 0) {
                                $(this).remove();
                            }
                   
                            rowcount += 1;
                        })
                    }

                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var docdtls = JSON.parse(Obj.result_24);
                    if (docdtls.length > 0) {

                        for (var doc = 0; doc < docdtls.length; doc++) {
                                fnAddgendoc();
                        }
                        fnSetGridVal("Doc_Gendiv", val, docdtls);

                        $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='Com_genDocname']").val();
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                       
                            if ($(this).find("li").find("input[colkey='Com_genDocstatus']").val() == "Not-Received") {
                                $(this).find("li").find("input[colkey=Com_genRefno]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_genRecDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_genValidDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_genrefDate]").attr("style", "visibility:hidden");
                            }
                        });

                        var ll = docdtls.length;
                        var rowcount = 0;
                        $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                            if (rowcount >= ll) {
                                $(this).remove();
                            }
                            rowcount += 1;
                        })
                    }
                    else {
                        var rowcount = 0;
                        $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                            if (rowcount > 0) {
                                $(this).remove();
                            }

                            rowcount += 1;
                        })
                    }
                    debugger
                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var kycadddtls = JSON.parse(Obj.result_25);
                    if (kycadddtls.length > 0) {

                        for (var doc = 0; doc < kycadddtls.length; doc++) {
                           
                                fnAddKyc();
                        }
                        fnSetGridVal("Kyc_Adddiv", val, kycadddtls);


                        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='dde_KycaddDocument']").val();
                            var DOCTYPE = $(this).find("li").find("input[colkey='dde_KycaddProof']").attr("selval");
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                            $(this).find("li comp-help").attr("helpfk", DOCTYPE);
                            var date = $(this).find("li.date").find("input[colkey=dde_KycaddDate]").val();
                            if (date != undefined) {
                                if (date.trim() != "") {
                                    $(this).find("li.date").attr("style", "display:inline-block");
                                }
                            }
                        });

                        var ll = kycadddtls.length;
                        var rowcount = 0;
                        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                            if (rowcount >= ll) {
                                $(this).remove();
                            }
                            rowcount += 1;
                        })
                    }
                    else {
                        var rowcount = 0;
                        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                            if (rowcount > 0) {
                                $(this).remove();
                            }

                            rowcount += 1;
                        })
                    }
                   
                }
                else {
                   
                    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var dataInfo = JSON.parse(Obj.result_14);
                    if (dataInfo.length > 0) {

                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", dataInfo);


                    }
                    var dataInfo1 = JSON.parse(Obj.result_15);
                    if (dataInfo1.length > 0) {

                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", dataInfo1);

                    }

                    var dataInfo2 = JSON.parse(Obj.result_16);
                    if (dataInfo2.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", dataInfo2);
                    }
                    
                    var Asset = JSON.parse(Obj.result_17);
                    if (Asset.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", Asset)
                    }

                    var OB = JSON.parse(Obj.result_18);
                    if (OB.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", OB)
                    }

                    var CC = JSON.parse(Obj.result_19);
                    if (CC.length > 0) {
                        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", CC)
                    }
                
          
                    var kyc = JSON.parse(Obj.result_20);
                    if (kyc.length > 0) {
                        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                        //fnSetGridVal("Kyc_div", Id, kyc);
                        for (i = 0; i < kyc.length; i++) {
                            if (kyc[i].dde_KycProof == "A") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            if (kyc[i].dde_KycProof == "I") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            if (kyc[i].dde_KycProof == "D") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                            }
                            if (kyc[i].dde_KycProof == "S") {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                                $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                            }
                            else {
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                            }
                        }



                        $("#" + val + " .Kyc_div .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='dde_KycDocument']").val();
                            var DOCTYPE = $(this).find("li").find("input[colkey='dde_KycProof']").attr("selval");
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                            $(this).find("li comp-help").attr("helpfk", DOCTYPE);
                            var date = $(this).find("li.date").find("input[colkey=dde_KycDate]").val();
                            if (date != undefined) {
                                if (date.trim() != "") {
                                    $(this).find("li.date").attr("style", "display:inline-block");
                                }
                            }
                        });
                    }
                    else {
                        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                    }
                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var docdtls = JSON.parse(Obj.result_21);
                    if (docdtls.length > 0) {

                        for (var doc = 0; doc < docdtls.length; doc++) {
                                fnAdddoc();
                        }
                        fnSetGridVal("Doc_div", val, docdtls);
                        $("#" + val + " .Doc_div .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='Com_Docname']").val();
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                     
                            if ($(this).find("li").find("input[colkey='Com_Docstatus']").val() == "Not-Received") {
                                $(this).find("li").find("input[colkey=Com_Refno]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_RecDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_ValidDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_refDate]").attr("style", "visibility:hidden");
                            }
                        });
                        var ll = docdtls.length;
                        var rowcount = 0;
                        $("#" + val + " .Doc_div .rowGrid").each(function () {
                            if (rowcount >= ll) {
                                $(this).remove();
                            }

                            rowcount += 1;
                        })
                    }
                    else {
                        var rowcount = 0;
                        $("#" + val + " .Doc_div .rowGrid").each(function () {
                            if (rowcount > 0) {
                                $(this).remove();
                            }
                            rowcount += 1;
                        })
                    }

                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var docdtls = JSON.parse(Obj.result_22);
                    if (docdtls.length > 0) {

                        for (var doc = 0; doc < docdtls.length; doc++) {
                                fnAddgendoc();
                        }
                        fnSetGridVal("Doc_Gendiv", val, docdtls);

                        $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='Com_genDocname']").val();
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                            
                            if ($(this).find("li").find("input[colkey='Com_genDocstatus']").val() == "Not-Received") {
                                $(this).find("li").find("input[colkey=Com_genRefno]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_genRecDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_genValidDate]").attr("style", "visibility:hidden");
                                $(this).find("li").find("input[colkey=Com_genrefDate]").attr("style", "visibility:hidden");
                            }
                        });

                        var ll = docdtls.length;
                        var rowcount = 0;
                        $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                            if (rowcount >= ll) {
                                $(this).remove();
                            }
                            rowcount += 1;
                        })
                    }
                    else {
                        var rowcount = 0;
                        $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                            if (rowcount > 0) {
                                $(this).remove();
                            }

                            rowcount += 1;
                        })
                    }
                    debugger
                    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                    var kycadddtls = JSON.parse(Obj.result_23);
                    if (kycadddtls.length > 0) {

                        for (var doc = 0; doc < kycadddtls.length; doc++) {
                            
                                fnAddKyc();
                        }
                        fnSetGridVal("Kyc_Adddiv", val, kycadddtls);


                        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                            var DOCNM = $(this).find("li").find("input[colkey='dde_KycaddDocument']").val();
                            var DOCTYPE = $(this).find("li").find("input[colkey='dde_KycaddProof']").attr("selval");
                            $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                            $(this).find("li comp-help").attr("helpfk", DOCTYPE);
                            var date = $(this).find("li.date").find("input[colkey=dde_KycaddDate]").val();
                            if (date != undefined) {
                                if (date.trim() != "") {
                                    $(this).find("li.date").attr("style", "display:inline-block");
                                }
                            }
                        });

                        var ll = kycadddtls.length;
                        var rowcount = 0;
                        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                            if (rowcount >= ll) {
                                $(this).remove();
                            }
                            rowcount += 1;
                        })
                    }
                    else {
                        var rowcount = 0;
                        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                            if (rowcount > 0) {
                                $(this).remove();
                            }

                            rowcount += 1;
                        })
                    }

                }
                var valtxt = $("#" + Id).find("input[key=dde_pin]").val();
                $("#" + Id).find("input[key=dde_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);

                var valtxt = $("#" + Id).find("input[key=dde_permanent_pin]").val();
                $("#" + Id).find("input[key=dde_permanent_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);

                var valtxt = $("#" + Id).find("input[key=dde_occSal_offAddr_pin]").val();
                $("#" + Id).find("input[key=dde_occSal_offAddr_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);

                var valtxt = $("#dde_div_reference").find("input[key=dde_pin_ref]").val();
                $("#dde_div_reference").find("input[key=dde_pin_ref]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                
                if (Id == "dde_whole_div_0") {
                    $("#" + Id).find(".frstdiv input[key=dde_app_relation]").attr("selval", "Self");
                    $("#" + Id).find(".frstdiv input[key=dde_app_relation]").val("Self");
                    $("#" + Id).find(".frstdiv input[key=dde_app_relation]").attr("disabled", true);

                }
                else {
                    $("#" + Id).find(".frstdiv input[key=dde_app_relation]").attr("disabled", false);
                    $("#" + Id).find(".frstdiv input[key=dde_app_relation]").siblings("ul").find("li.remove").remove()
                }
              

            }
            catch (e) { console.log(e); }
        }
        fnShowSelDiv('D', $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .detailed-content li[val='20']"));
        fnShowSelDiv('A', $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .address-list li[val=0]"));
    }
    if (ServDesc == "DDE_DATA_SAVE") {

        DocAppRef = JSON.parse(Obj.result_1)[0].AppPk;

        $(Cur_Active_Actor_li).attr("Pk", JSON.parse(Obj.result_1)[0].LapFk);
        $(Cur_Active_ref_li).attr("pk", JSON.parse(Obj.result_1)[0].RefFk);

        $("#dde_content_Pg").find('.ContentChange').removeClass("ContentChange");
        fnBindEvts("dde_content", "CLEAR");
        fnBindEvts("dde_ref", "CLEAR");
        fnBindEvts("legal_hier", "CLEAR");
        var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        try {
            var LgHier = JSON.parse(Obj.result_2);
            var Ast = JSON.parse(Obj.result_3);
            var Obl = JSON.parse(Obj.result_4);

            var Credit = JSON.parse(Obj.result_5);
            var Bank = JSON.parse(Obj.result_6);
         
            var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
            var kyc = JSON.parse(Obj.result_7);
            if (kyc.length > 0) {
                var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                //fnSetGridVal("Kyc_div", Id, kyc);
                for (i = 0; i < kyc.length; i++) {
                    if (kyc[i].dde_KycProof == "A") {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                    }
                    else {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                    }
                    if (kyc[i].dde_KycProof == "I") {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                    }
                    else {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                    }
                    if (kyc[i].dde_KycProof == "D") {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                    }
                    else {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");

                    }
                    if (kyc[i].dde_KycProof == "S") {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycDocument]").val(kyc[i].dde_KycDocument);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycPk]").val(kyc[i].dde_KycPk);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycRefno]").val(kyc[i].dde_KycRefno);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycDate]").val(kyc[i].dde_KycDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_DOCPK]").val(kyc[i].dde_DOCPK);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycrefDate]").val(kyc[i].dde_KycrefDate);
                        $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_kyc_notes]").val(kyc[i].dde_kyc_notes);
                        $("#" + val + " .Kyc_div").attr("contentchanged", "false");
                    }
                    else {
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                        $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                    }
                }



                $("#" + val + " .Kyc_div .rowGrid").each(function () {
                    var DOCNM = $(this).find("li").find("input[colkey='dde_KycDocument']").val();
                    var DOCTYPE = $(this).find("li").find("input[colkey='dde_KycProof']").attr("selval");
                    $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                    $(this).find("li comp-help").attr("helpfk", DOCTYPE);
                    var date = $(this).find("li.date").find("input[colkey=dde_KycDate]").val();
                    if (date != undefined) {
                        if (date.trim() != "") {
                            $(this).find("li.date").attr("style", "display:inline-block");
                        }
                    }
                });
            }
            else {
                var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").val("Address Proof");
                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("selval", "A").trigger("change");
                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("comp-help").attr("helpfk", "A");
                $("#" + val + " .Kyc_div").find("ul:nth-child(2)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").val("Id Proof");
                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("comp-help").attr("helpfk", "I");
                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("selval", "I").trigger("change");
                $("#" + val + " .Kyc_div").find("ul:nth-child(3)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").val("DOB Proof");
                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("comp-help").attr("helpfk", "D");
                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("selval", "D").trigger("change");
                $("#" + val + " .Kyc_div").find("ul:nth-child(4)").find("input[colkey=dde_KycProof]").attr("disabled", true);

                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").val("Signature Proof");
                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("comp-help").attr("helpfk", "S");
                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("selval", "S").trigger("change");
                $("#" + val + " .Kyc_div").find("ul:nth-child(5)").find("input[colkey=dde_KycProof]").attr("disabled", true);
                $("#" + val + " .Kyc_div").attr("contentchanged", "false");

            }
            var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
            var docdtls = JSON.parse(Obj.result_8);
            if (docdtls.length > 0) {

                for (var doc = 0; doc < docdtls.length; doc++) {
                        fnAdddoc();
                }
                fnSetGridVal("Doc_div", val, docdtls);

                $("#" + val + " .Doc_div .rowGrid").each(function () {
                    var DOCNM = $(this).find("li").find("input[colkey='Com_Docname']").val();
                    $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                    if ($(this).find("li").find("input[colkey='Com_Docstatus']").val() == "Not-Received") {
                        $(this).find("li").find("input[colkey=Com_Refno]").attr("style", "visibility:hidden");
                        $(this).find("li").find("input[colkey=Com_RecDate]").attr("style", "visibility:hidden");
                        $(this).find("li").find("input[colkey=Com_ValidDate]").attr("style", "visibility:hidden");
                        $(this).find("li").find("input[colkey=Com_refDate]").attr("style", "visibility:hidden");
                    }
                });

                var ll = docdtls.length;
                var rowcount = 0;
                $("#" + val + " .Doc_div .rowGrid").each(function () {
                    if (rowcount >= ll) {
                        $(this).remove();
                    }

                    rowcount += 1;
                })
            }

            var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
            var docdtls = JSON.parse(Obj.result_9);
            if (docdtls.length > 0) {

                for (var doc = 0; doc < docdtls.length; doc++) {
                        fnAddgendoc();
                }
                fnSetGridVal("Doc_Gendiv", val, docdtls);

                $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                    var DOCNM = $(this).find("li").find("input[colkey='Com_genDocname']").val();
                    $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                
                    if ($(this).find("li").find("input[colkey='Com_genDocstatus']").val() == "Not-Received") {
                        $(this).find("li").find("input[colkey=Com_genRefno]").attr("style", "visibility:hidden");
                        $(this).find("li").find("input[colkey=Com_genRecDate]").attr("style", "visibility:hidden");
                        $(this).find("li").find("input[colkey=Com_genValidDate]").attr("style", "visibility:hidden");
                        $(this).find("li").find("input[colkey=Com_genrefDate]").attr("style", "visibility:hidden");
                    }
                });

                var ll = docdtls.length;
                var rowcount = 0;
                $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                    if (rowcount >= ll) {
                        $(this).remove();
                    }
                    rowcount += 1;
                })
            }
            debugger
            var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
            var kycadddtls = JSON.parse(Obj.result_10);
            if (kycadddtls.length > 0) {

                for (var doc = 0; doc < kycadddtls.length; doc++) {
                    
                        fnAddKyc();
                }
                fnSetGridVal("Kyc_Adddiv", val, kycadddtls);


                $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                    var DOCNM = $(this).find("li").find("input[colkey='dde_KycaddDocument']").val();
                    var DOCTYPE = $(this).find("li").find("input[colkey='dde_KycaddProof']").attr("selval");
                    $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
                    $(this).find("li comp-help").attr("helpfk", DOCTYPE);
                    var date = $(this).find("li.date").find("input[colkey=dde_KycaddDate]").val();
                    if (date != undefined) {
                        if (date.trim() != "") {
                            $(this).find("li.date").attr("style", "display:inline-block");
                        }
                    }
                });

                var ll = kycadddtls.length;
                var rowcount = 0;
                $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                    if (rowcount >= ll) {
                        $(this).remove();
                    }
                    rowcount += 1;
                })
            }
            
            //else {
            //    var rowcount = 0;
            //    $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
            //        if (rowcount > 0) {
            //            $(this).remove();
            //        }

            //        rowcount += 1;
            //    })
            //}
            fnddeSetGridDatas(LgHier, Bank, Ast, Obl, Credit, "PK")
        } catch (e) { console.log(e); }
        fnShowSelValues(Param2, FinalSelObj);
        //fnloadrefno();
        //fnloaddocrefno();
        //fnloaddocGenrefno();
    }
    if (ServDesc == "DDE_DEL") {
        fnClearAftClose(Param2);
    }
    //if (ServDesc == "DDE_Refno") {
    
    //    var ErrMsg = "";
    //    globalrefno = JSON.parse(Obj.result);
    //}
    //if (ServDesc == "DDE_docRefno") {
 
    //    var ErrMsg = "";
    //    globaldocrefno = JSON.parse(Obj.result);
    //}
    //if (ServDesc == "DDE_docgenRefno") {
      
    //    var ErrMsg = "";
    //    globaldocgenrefno = JSON.parse(Obj.result);
    //}
    validatebank();
}
function fnAddKyc()
{
   //debugger
   var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");

   if (GlobalXml[0].IsAll != "1") {
       ErrMsg = fnChkMandatory(val);
       var c = 1;
       if ($("#" + val + " .Kyc_Adddiv").is("[contentchanged='true']")) {
           $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
               if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                   if ($(this).find("li").find("input[colkey=dde_KycaddRefno]").val().trim() == "") {
                       ErrMsg = ErrMsg == "" ? "Reference no Required_Row:" + c + "!!" : ErrMsg + "<br/>Reference no Required_Row:" + c + "!!";
                       return false;
                   }
                   if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=dde_KycaddDocument]").val()) {
                       ErrMsg = ErrMsg == "" ? "Valid document name Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid document name Required_Row:" + c + "!!";
                       return false;
                   }
               }
                   c++;          
           });
           if (ErrMsg != "") {
               fnShflAlert("error", ErrMsg);
               return false;
           }
       }
   }

   //if (GlobalXml[0].IsAll != "1") {
   //    ErrMsg = fnChkMandatory(val);
   //    var c = 1;
   //    if ($("#" + val + " .Kyc_div").is("[contentchanged='true']")) {
   //        $("#" + val + " .Kyc_div .rowGrid").each(function () {
   //            if ($(this).find("li.date").attr("style") == "display:inline-block") {
   //                if ($(this).find("li.date").find("input[colkey='dde_KycDate']").val().trim() == "") {
   //                    ErrMsg = ErrMsg == "" ? "Validity date Required_Row:" + c + "!!" : ErrMsg + "<br/>Validity date Required_Row:" + c + "!!";
   //                    return false;
   //                }
   //            }
   //            c++;
   //        });
   //        if (ErrMsg != "") {
   //            fnShflAlert("error", ErrMsg);
   //            return false;
   //        }
   //    }
   //}
   
   if (GlobalXml[0].IsAll != "1") {
       ErrMsg = fnChkMandatory(val);
       var c = 1;
       if ($("#" + val + " .Kyc_Adddiv").is("[contentchanged='true']")) {
           $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
               if ($(this).find("li.date").attr("style") == "display:inline-block") {
                   if ($(this).find("li.date").find("input[colkey='dde_KycaddDate']").val().trim() != "") {
                       var dateval = $(this).find("li.date").find("input[colkey='dde_KycaddDate']").val()
                       var date = dateval.substring(0, 2);
                       var month = dateval.substring(3, 5);
                       var year = dateval.substring(6, 10);
                       var dateToCompare = new Date(year, month - 1, date);
                       var currentDate = new Date();
                       if (dateval != '') {
                           if (dateToCompare < currentDate) {
                               ErrMsg = ErrMsg == "" ? "Validity Date Should be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Validity Date Should be greater than Current Date_Row:" + c + "!!";
                               return false;
                           }
                       }
                   }
               }
               c++;
           });
       }
       if (ErrMsg != "") {
           fnShflAlert("error", ErrMsg);
           return false;
       }
   }
    debugger
   if (GlobalXml[0].IsAll != "1") {
       ErrMsg = fnChkMandatory(val);
       var c = 1;
       if ($("#" + val + " .Kyc_Adddiv").is("[contentchanged='true']")) {
           $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                   if ($(this).find("li.refdate").find("input[colkey='dde_KycaddrefDate']").val().trim() != "") {
                       var dateval = $(this).find("li.refdate").find("input[colkey='dde_KycaddrefDate']").val()
                       var date = dateval.substring(0, 2);
                       var month = dateval.substring(3, 5);
                       var year = dateval.substring(6, 10);
                       var dateToCompare = new Date(year, month - 1, date);
                       var currentDate = new Date();
                       if (dateval != '') {
                           if (dateToCompare > currentDate) {
                               ErrMsg = ErrMsg == "" ? "Reference Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Reference Date Should not be greater than Current Date_Row:" + c + "!!";
                               return false;
                           }
                       }
                   }
               c++;
           });
       }
       if (ErrMsg != "") {
           fnShflAlert("error", ErrMsg);
           return false;
       }
   }
    debugger
    var rowkyccount = $("#" + val + " .Kyc_Adddiv").children("ul.rowGrid").length + 1;
       
    var s = '';
    var close = '';
    s += '<ul class="grid-controls rowGrid box-kycadd-ul"><li class="width-10">'+
        //'<div class="select-focus"><input placeholder="Select" onkeydown="return false" selval="A" name="select" colkey="dde_KycaddProof" onchange="fnKycDoc(this)" class="autofill">' +
        //    '<i class="icon-down-arrow_1"></i><ul class="custom-select"><li val="A">Address Proof</li><li val="I">Id Proof</li><li val="D">DOB Proof</li><li val="S">Signature Proof</li>'+
        //                                        '</ul>'+
        //                                   '</div>'+       
        ' <input type="hidden" placeholder="" name="text" colkey="dde_KycaddProof">' +
         '<label class="chckother">Other Documents_' + rowkyccount + '</label>' +
                                        '</li>'+
                                        '<li class="width-10" onfocusout="fnclearadddata(this)">'+
                                            '<comp-help id="comp-help" txtcol="DocumentName" valcol="DocPk" helpfk="1" onrowclick="Docaddclick" prcname="PrcShflKychhelp" width="100%"></comp-help>' +
                                           ' <input type="hidden" placeholder="" name="text" colkey="dde_KycaddDocument">'+
                                           ' <input type="hidden" placeholder="" name="text" colkey="dde_KycaddPk">'+
                                      '  </li>'+
                                       ' <li class="width-10">'+
                                          '  <input type="text" placeholder="" name="text" colkey="dde_KycaddRefno" restrict="alphanumeric" class="reference" />'+
                                       ' </li>'+
                                       ' <li class="width-10 refdate">'+
                                       '     <input type="text" placeholder="" name="text" colkey="dde_KycaddrefDate" class="datepickerdef" />'+
                                       ' </li>'+
                                       ' <li class="width-10 date" style="visibility:hidden">'+
                                       '     <input type="text" placeholder="" name="text" colkey="dde_KycaddDate" class="datepickerdef" />'+
                                       ' </li>'+
                                      '  <li class="Kyc_icon"> <i class="icon-chat-o" txtval=""></i> </li>'+
                                      '  <li style="display:none;" class="dde_kyc_addnotes">'+
                                      '      <input type="text" name="text" colkey="dde_kyc_addnotes" value="">'+
                                      '  </li>'+
                                      '  <li>'+
                                     '       <input type="hidden" placeholder="" name="text" colkey="dde_addDOCPK">'+
                                     '   </li>'+
                                   ' </ul>'
    $("#" + val + " .Kyc_Adddiv").append(s);
    close += '<li><i class="icon-close" onclick="fnCloseaddkycrow(this)"></i></li>';
    $("#" + val + " .Kyc_Adddiv").children("ul:last-child").append(close);
    $("#" + val + " .Kyc_Adddiv").children("ul:last-child").find(".datepickerdef").removeAttr("id");
    $("#" + val + " .Kyc_Adddiv").children("ul:last-child").find(".datepickerdef").removeClass("hasDatepicker");
    fnDrawDefaultDatePicker();
    $("#" + val + " .Kyc_Adddiv .datepicker,.datepickerdef").each(function () {
        fnRestrictDate($(this));
    });s
    $(".Kyc_Adddiv").children("ul:last-child").find("li.date").attr("style", "visibility:hidden");
    $(".Kyc_Adddiv").children("ul:last-child").addClass("new");
    fnClearForm("new", 1);
    $(".Kyc_Adddiv").find('.new').removeClass("new");
    $("#" + val + " .Kyc_Adddiv").children("ul:last-child").find("input[colkey=dde_KycaddProof]").val(rowkyccount);
    //$("#" + val + " .Kyc_Adddiv").children("ul:last-child").find("li").find("comp-help").attr("helpfk", 1);

}

//30/11/2016  Changes
function validaterel() {
    var sel = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if (sel == "dde_whole_div_0") {
        $("#" + sel).find(".frstdiv input[key=dde_app_relation]").attr("selval", "Self");
        $("#" + sel).find(".frstdiv input[key=dde_app_relation]").val("Self");
        $("#" + sel).find(".frstdiv input[key=dde_app_relation]").attr("disabled", true);
    }
    else {
        $("#" + sel).find(".frstdiv input[key=dde_app_relation]").attr("disabled", false);
        $("#" + sel).find(".frstdiv input[key=dde_app_relation]").siblings("ul").find("li.remove").remove()
    }
}
/*muthu 22/12/16*/
function validateedu(elem) {
    
    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).val() != "Others") {
        $("#eduothertxtid").val("");
        $("#" + Id + " .personal-div").find(".educlass").hide();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_edu_others']").removeAttr("class");
        $(".per_div.dde_cont.det-content1.det_content").attr("contentchanged", "true");
    }
    else {
        $("#eduothertxtid").val("");
        $("#" + Id + " .personal-div").find(".educlass").show();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_edu_others']").addClass("mandatory");
        $(".per_div.dde_cont.det-content1.det_content").attr("contentchanged", "true");
    }
    if ($(elem).val() != "Illiterate") {
        $("#" + Id + " .personal-div").find("#dde_univer_id").show();
        $(".per_div.dde_cont.det-content1.det_content").attr("contentchanged", "true");
    }
    else {

        $("#" + Id + " .personal-div").find("#dde_univer_id").hide();
        $("#" + Id + " .personal-div").find("input[key='dde_ins_uni']").removeAttr("key");
        $(".per_div.dde_cont.det-content1.det_content").attr("contentchanged", "true");
    }
}
/*end*/
/*change(muthu)22/12/16*/
function validatecom(elem) {
   
    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).val() != "Others") {
        $("#Comotherid").val("");
        $("#" + Id + " .personal-div").find(".comclass").hide();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_community_other']").removeAttr("class");
        $(".per_div.dde_cont.det-content1.det_content").attr("contentchanged", "true");
    }
    else {
        $("#Comotherid").val("");
        $("#" + Id + " .personal-div").find(".comclass").show();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_community_other']").addClass("mandatory");
        $(".per_div.dde_cont.det-content1.det_content").attr("contentchanged", "true");

    }
}
/*end*/
//30/11/2016  Changes
function validatenature(elem) {
    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).val() != "Others") {
        $("#" + Id + " .selfemp-div").find(".othercls").hide();
        $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus_others']").removeAttr("class");
    }
    else {
        $("#" + Id + " .selfemp-div").find(".othercls").show();
        $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus_others']").val("");
        $("#" + Id + " .selfemp-div").find("input[key='dde_occSelf_NaturOfBus_others']").attr("class", "mandatory");
    }
}

function validateothers(elem) {
    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).val() != "Others") {
        $("#" + Id + " .personal-div").find(".otherclass").hide();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_religion_other']").removeAttr("class");
    }
    else {
        $("#" + Id + " .personal-div").find(".otherclass").show();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_religion_other']").val("");
        $("#" + Id + " .personal-div").find("input[key='dde_Per_religion_other']").attr("class", "mandatory");

    }
}

function validateref(elem) {
    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ($(elem).val() != "Yes") {
        $("#" + Id + " .personal-div").find(".refclass").hide();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_refNO']").removeAttr("class")
    }
    else {
        $("#" + Id + " .personal-div").find(".refclass").show();
        $("#" + Id + " .personal-div").find("input[key='dde_Per_refNO']").val("");
        $("#" + Id + " .personal-div").find("input[key='dde_Per_refNO']").attr("class", "mandatory");
    }
}

function fnOnChangeCall(Action, SelObj) {
    if (Action == "O") {
        if (SelObj == "")
            SelObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .obligation_grid input[colkey='dde_ob_emi1']");

        fnAddGridValues($(SelObj), "dde_ob_emi1", "obligation_grid", "obligation-div", "dde_ob_IsIncl");
    }
    else if (Action == "A") {
        fnAddGridValues($(SelObj), "dde_Asset_amt1", "asset_grid", "asset-div");
    }
    else if (Action == "C") {
        fnAddGridValues($(SelObj), "dde_cc_limit1", "credit_grid", "credit-div");
    }
}

function fnddeSetGridDatas(LgHier, BankDtls, Asset, Oblig, Credit, Action) {

    var Id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if (LgHier.length > 0) {
        for (var leg = 0; leg < LgHier.length; leg++) {
            if (leg > 0)
                fnAddLegalHier(Action);
        }
        fnSetGridVal("box-hier", "", LgHier);
    }
    if (BankDtls.length > 0) {

        for (var Bnk = 0; Bnk < BankDtls.length; Bnk++) {
            if (Bnk > 0)
                fnAddBank();
        }
        fnSetGridVal("bank-div", Id, BankDtls);
        //bank
       
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var ll = BankDtls.length;
        var rowcount = 0;
        $("#" + val + " .bank-div .rowGrid").each(function () {
            if (rowcount >= ll) {
                $(this).remove();
            }

            rowcount += 1;
        })
    }

    $("#" + val + " .bank-div .rowGrid").each(function () {
       
        var bnkpk = $(this).find("li.bank").find("input[colkey='dde_Bank_bnkName1']").val();
        var bnknm = $(this).find("li.bank").find("input[colkey='dde_Bank_bnkName2']").val();
        $(this).find("li.bank comp-help").find("input[name='helptext']").attr("val", bnkpk);
        $(this).find("li.bank comp-help").find("input[name='helptext']").val(bnknm);
        $(this).find("li.branch comp-help").attr("helpfk", bnkpk);

        var branchpk = $(this).find("li.branch").find("input[colkey='dde_Bank_branch1']").val();
        var branchknm = $(this).find("li.branch").find("input[colkey='dde_Bank_branch2']").val();
        $(this).find("li.branch comp-help").find("input[name='helptext']").attr("val", branchpk);
        $(this).find("li.branch comp-help").find("input[name='helptext']").val(branchknm);

    });


    if (Oblig.length > 0) {
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var ObligationGrid = $("#" + val + " .obligation_grid");

        var rowCount = 0;
        if (Action != "PK") {
            $("#" + val + " .obligation_grid .rowGrid").each(function () {
                if (rowCount > 0)
                    $(this).remove();
                else
                    $(ObligationGrid).css('display', "none");

                rowCount += 1;
            })

            for (var Obl1 = 0; Obl1 < Oblig.length; Obl1++) {

                if (Obl1 >= 0) {

                    if ($(ObligationGrid).css('display') == 'none') {
                        $(ObligationGrid).css("display","block");
                    }
                    else {
                        $(ObligationGrid).append(globalicon);

                        var len = Obl1 + 1;
                        $(ObligationGrid).children("ul:last-child").find("#img-switcher").removeAttr('id');
                        $(ObligationGrid).children("ul:last-child").find(".IsShri").attr('id', 'img-switcher' + val + len + '');
                        $(ObligationGrid).children("ul:last-child").find(".imgli").removeAttr('for');
                        $(ObligationGrid).children("ul:last-child").find(".imgli").attr('for', 'img-switcher' + val + len + '');
                        $(ObligationGrid).children("ul:last-child").find("#myonoffswitchia").removeAttr('id');
                        $(ObligationGrid).children("ul:last-child").find(".IsInclOnOff").attr('id', 'myonoffswitchia' + val + len + '');
                        $(ObligationGrid).children("ul:last-child").find(".onoffswitch-label").removeAttr('for');
                        $(ObligationGrid).children("ul:last-child").find(".onoffswitch-label").attr('for', 'myonoffswitchia' + val + len + '');
                    }
                    var ob = Oblig[Obl1].dde_ob_typofloan;
                    var obIs = (Oblig[Obl1].dde_ob_IsShri == 0) ? true : false;
                    var ObInc = (Oblig[Obl1].dde_ob_IsIncl == 0) ? true : false;

                    if (ob == 0) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-auto-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 1) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-car-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 2) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-two-wheeler-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 3) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-home-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 4) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-lap");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 5) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-gold-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 6) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-personal-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 7) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-business");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 8) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-term");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 9) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-consumer-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    else if (ob == 10) {
                        $(ObligationGrid).children("ul:last-child").find(".cls_Type").addClass("icon-other-loan");
                        $(ObligationGrid).children("ul:last-child").find(".dde_ob_typofloan").children("input").val(ob);
                    }
                    $(ObligationGrid).children("ul:last-child").find(".IsInclOnOff").prop("checked", ObInc);
                    $(ObligationGrid).children("ul:last-child").find(".IsShri").prop("checked", obIs);
                }

            }

            fnSetGridVal("obligation_grid", Id, Oblig);

            var OblObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .obligation_grid input[colkey='dde_ob_emi1']");
            fnOnChangeCall("O", $(OblObj));
        }
        else {
            fnSetGridVal("obligation_grid", Id, Oblig);
        }

    }
    if (Oblig.length > 0) {
        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", Oblig)

    }


  
    if (Asset.length > 0) {
        for (var Asst = 0; Asst < Asset.length; Asst++) {
            if (Asst > 0)
                fnAddAsset();
        }
        
        fnSetGridVal("asset_grid", Id, Asset);
       
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        if (Asset.length > 0) {
            fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", Asset)
        }
        var ll = Asset.length;
        var rowcount = 0;
        $("#" + val + " .asset_grid .rowGrid").each(function () {
            if (rowcount >= ll) {
                $(this).remove();
            }

            rowcount += 1;
        })
        var AstObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .asset_grid input[colkey='dde_Asset_amt1']");
        fnOnChangeCall("A", $(AstObj));
    }

    if (Credit.length > 0) {
        for (var Crd = 0; Crd < Credit.length; Crd++) {
            if (Crd > 0)
                fnAddCc();
        }
        fnSetGridVal("credit_grid", Id, Credit);
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var ll = Credit.length;
        var rowcount = 0;
        $("#" + val + " .credit_grid .rowGrid").each(function () {
            if (rowcount >= ll) {
                $(this).remove();
            }

            rowcount += 1;
        })
        var CrdObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .credit_grid input[colkey='dde_cc_limit1']");
        fnOnChangeCall("C", $(CrdObj));

        $("#" + val + " .credit_grid .rowGrid").each(function () {
           
            var bnkpk = $(this).find("li.bank").find("input[colkey='dde_cc_issuingbnk1']").val();
            var bnknm = $(this).find("li.bank").find("input[colkey='dde_cc_issuingbnk2']").val();
            $(this).find("li.bank comp-help").find("input[name='helptext']").attr("val", bnkpk);
            $(this).find("li.bank comp-help").find("input[name='helptext']").val(bnknm);
        });
    }
    if (Credit.length > 0) {
        fnSetValues("dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + "", Credit)

    }
}
function fnreference() {
    var refcount = 2;
    var icon_close = '<i onclick="fnBindliClose(this,event)" class="li-close icon-close"></i>';
    $("#dde_ul_ref_tabs").children("li").each(function () {
        if ($(this).text() == "") {
        }
        else if (refcount == 2) {
            $(this).text("Reference" + (refcount - 1));
            refcount += 1;
        }
        else {
            $(this).text("Reference" + (refcount - 1));
            $(this).append(icon_close);
            refcount += 1;
        }
    });
}


function ISSUEBnkclick(rowjson, elem) {

    $(elem).parent().find("input[colkey=dde_cc_issuingbnk1]").val(rowjson.Bankpk).trigger("change");
    $(elem).parent().find("input[colkey=dde_cc_issuingbnk2]").val(rowjson.BankName);
}
function obBnkclick(rowjson, elem) {

    $(elem).parent().find("input[colkey=dde_ob_bank1]").val(rowjson.Bankpk).trigger("change");
    $(elem).parent().find("input[colkey=dde_ob_bank2]").val(rowjson.BankName);
}
function fnddeAddNewRefTab(obj, Action) {
    if (Action == "Add") {
        fnDdeConfirmScreen('RA');
    }
    else {
        var Class = "";
        obj.remove();

        MaxliRefTab += 1;
        Class = "reftab" + MaxliRefTab;
        var icon_close = '<i onclick="fnBindliClose(this,event)" class="li-close icon-close"></i>';
        if (MaxliRefTab == 2) {
            $("#dde_ul_ref_tabs").append
       (
           "<li onclick=fnDdeConfirmScreen('R',this) pk='0' val='3" + (MaxliRefTab - 1) + "' class='" + Class + "'>" +
               'Reference ' + MaxliRefTab +
           '</li>'
       );
        }
        else {
            $("#dde_ul_ref_tabs").append
            (
                "<li onclick=fnDdeConfirmScreen('R',this) pk='0' val='3" + (MaxliRefTab - 1) + "' class='" + Class + "'>" +
                    'Reference ' + MaxliRefTab + icon_close +
                '</li>'
            );
        }
        $("#dde_ref").append('<div style="display:none;" contentchanged="false" id="dde_ref_div_3' + (MaxliRefTab - 1) + '" class="dde_cont tab' + MaxliRefTab + '-refcontent ref_content" val="3' + (MaxliRefTab - 1) + '"></div>');
        var content = $("#dde_ref_div_30").html();
        $("#dde_ref_div_3" + (MaxliRefTab - 1)).html(content);
        fnClearForm("dde_ref_div_3" + (MaxliRefTab - 1));
        $("#dde_ul_ref_tabs").append("<li onclick=fnddeAddNewRefTab(this,'Add') class='DDERefAdd'><i class='icon-plus'></i></li>");

        if (Action == "RA") {
            fnShowSelDiv('R', '#dde_ul_ref_tabs li[val=3' + (MaxliRefTab - 1) + ']');
        }
        fnreference();
    }
}


function fnBindliClose(ielem, e) {
    e.stopPropagation();

    if (GlobalXml[0].IsAll == "1")
        return;

    var lival = $(ielem).parent().attr("val");
    var DocrefPk = $(ielem).parent().attr("pk");
    if (DocrefPk > 0) {
        var confirmSts = confirm("Do you wish to Delete??");
        if (confirmSts == true) {
            fnDeleteSelectedTab(lival, DocrefPk);
            fnreference();
        }
    }
    else {
        fnClearAftClose(lival);
    }
}

function fnClearAftClose(lival) {
    $(".dde_cont[val=" + lival + "]").remove();
    $("#dde_ul_ref_tabs li[val=" + lival + "]").remove();
    Cur_Active_ref_li = $("#dde_ul_ref_tabs li[val='30']");
    $("#dde_ref .common-tabs li").removeClass("active");
    $(Cur_Active_ref_li).addClass("active");
    fnShowSelDiv('R', Cur_Active_ref_li);
    fnreference();
}

function fnDeleteSelectedTab(lival, DocrefPk) {
    var objProcData = {
        ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["D", JSON.stringify(DDEGlobal), JSON.stringify(LogJson), '', '', DocrefPk]
    }
    fnCallLOSWebService("DDE_DEL", objProcData, fnDDEResult, "MULTI", lival);
}

function fnDoValidation() {
    FinalErrMsg = "";
    var LoadHdrDiv = "dde_div_top_leadinfo";
    var LoadDiv = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    var LoadredDiv = "dde_ref_div_" + +$(Cur_Active_ref_li).attr("val");
    FinalErrMsg = fnChkMandatory(LoadHdrDiv);
    FinalErrMsg += fnChkMandatory(LoadDiv);
    FinalErrMsg += fnChkMandatory(LoadredDiv);
    FinalErrMsg += fnChkMandatory("legal_hier", 1, 0, "Legal Hier");
}


function fnDdeAddNewTab(DataVal) {
    var Class = "";
    var val = "dde_whole_div_0";
    for (var i = 0; i < DataVal.length; i++) {
        if (i == 0) {
            Class = "active"
            $("#dde_whole_div_0").attr("lapfk", DataVal[i].LapFk);
        }
        else {
            Class = "";
        }
        $("#dde_ul_app_tabs").append
        (
            "<li onclick=fnDdeConfirmScreen('T',this) CibilScr='" + DataVal[i].CibilScr + "' CusFk='" + DataVal[i].CusFk + "' Actor='" + DataVal[i].Actor + "' QdeFk = '" + DataVal[i].QdeFk + "' pk='" + DataVal[i].LapFk + "' val='" + i + "' class='" + Class + " applicant1-list tab" + (i + 1) + "'>" +
                '<p> ' + DataVal[i].FstNm + " " + DataVal[i].MidNm + " " + DataVal[i].LastNm + '</p>' +
                '<span class="app-type">' + DataVal[i].ActorNm + '</span>' +
            '</li>'
        );
        if (i > 0) {
            $("#dde_content").append('<div style="display:none;" id="dde_whole_div_' + MaxliAppTab + '" class="tab' + (i + 1) + '-content div_content highlight-applicant-details" val="' + MaxliAppTab + '" actornm="' + DataVal[i].ActorNm + '" lapfk="' + DataVal[i].LapFk + '" ></div>');
            var content = $("#dde_whole_div_0").html();
            $("#dde_whole_div_" + MaxliAppTab).html(content);
            val = "dde_whole_div_" + MaxliAppTab;
            $("#dde_whole_div_" + MaxliAppTab + " .datepicker").removeAttr("id");
            $("#dde_whole_div_" + MaxliAppTab + " .datepicker").removeClass("hasDatepicker");
            $("#dde_whole_div_" + MaxliAppTab + " .datepickerdef").removeAttr("id");
            $("#dde_whole_div_" + MaxliAppTab + " .datepickerdef").removeClass("hasDatepicker");
            fnDrawDefaultDatePicker();
            fnDrawDatePicker();
            $("#dde_content .datepicker,.datepickerdef").each(function () {
                fnRestrictDate($(this));
            });
            fnClearForm("dde_whole_div_" + MaxliAppTab);
            MaxliAppTab += 1;
        }
        fnKeyUpEvents(val);
    }
    Cur_Active_Actor_li = $("#dde_ul_app_tabs li[val='0']");
}

function fnAddGridValues(AddObj, colkey, GridClass, GriddivClass, InclClass) {
    var amtvalue = 0;
    $(AddObj).closest("." + GridClass).find("input[colkey='" + colkey + "']").each(function () {
        var IsAdd = 0;

        if (InclClass)
            IsAdd = $(this).parent().siblings("." + InclClass).children("input").val()

        var AddVal = 0;
        if (IsAdd == 0) {
            if ($(this).hasClass("currency")) {
                AddVal = $(this).val()
                AddVal = FormatCleanComma(AddVal.toString());
            }
            else
                AddVal = $(this).val();
        }

        amtvalue += Number(AddVal);
        $(this).closest("." + GriddivClass).find(".addicon h4").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(amtvalue.toString()));
    });
}

function fnKeyUpEvents(val) {
    $(document).on("keyup", "#" + val + " .asset_grid input[colkey='dde_Asset_amt1']", function () {
        fnOnChangeCall("A", $(this));
    });

    $(document).on("keyup", "#" + val + " .credit_grid input[colkey='dde_cc_limit1']", function () {
        fnOnChangeCall("C", $(this));
    });

    $(document).on("keyup", "#" + val + " .obligation_grid input[colkey='dde_ob_emi1']", function () {
        fnOnChangeCall("O", $(this));
    });
}
function fnShowSelDiv(Evt, SelObj) {
    if (Evt == 'T') {
        Cur_Active_Actor_li = SelObj;
        $(Cur_Active_Actor_li).addClass("active");
        $(Cur_Active_Actor_li).siblings().removeClass('active');
        $("#dde_content .div_content").css("display", "none");
        var displaydivval = $(Cur_Active_Actor_li).attr("val");
        $("#dde_whole_div_" + displaydivval).css("display","block");
    }
    else if (Evt == 'R') {
        Cur_Active_ref_li = SelObj;
        $(Cur_Active_ref_li).addClass("active");
        $(Cur_Active_ref_li).siblings().removeClass('active');
        $("#dde_ref .ref_content").css("display", "none");
        var displaydivval = $(Cur_Active_ref_li).attr("val");

        $("#dde_ref_div_" + displaydivval).css("display","block");
    }
    else if (Evt == 'D') {
        Cur_Active_Dtl_li = SelObj;

        $(Cur_Active_Dtl_li).addClass("active");
        $(Cur_Active_Dtl_li).siblings().removeClass('active');
        $(".det_content").css("display", "none");
        var displaydivval = $(Cur_Active_Dtl_li).attr("val");
        $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .det_content[val=" + displaydivval + "]").css("display","block");
    }
    else if (Evt == "A") {
        Cur_Active_Adr_li = SelObj;

        $(Cur_Active_Adr_li).addClass("active");
        $(Cur_Active_Adr_li).siblings().removeClass('active');

        if ($(Cur_Active_Adr_li).attr("val") == 0) {
            $(".present-aaddress").show();
            $(".premenent-aaddress").hide();
        }
        else {
            $(".premenent-aaddress").show();
            $(".present-aaddress").hide();
        }
    }
}

//function fnKycDoc(elem)
//{
//    //debugger
//    //var ErrMsg = "";
//    //var id = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
//    //var count = 0;
//    //$("#" + id + " .Kyc_div .rowGrid").each(function () {
//    //    if($(elem).val() == $(this).find("li").find("input[colkey=dde_KycProof]").val())
//    //    {
//    //        count += 1;
//    //    }

//    //});

//    //if (count > 1) {
//    //    ErrMsg = ErrMsg == "" ? "Type Of Proof already exists!!" : ErrMsg + "<br/>Type Of Proof already exists!!";
//    //}
//    //if (ErrMsg != "") {
//    //    $(elem).attr("selval", "-1");
//    //    $(elem).parents("li").siblings("li.date").attr("style", "display:none");
//    //    $(elem).parents("li").siblings("li").find("comp-help").find("input[name=helptext]").val("");
//    //    $(elem).parents("li").siblings("li").find("comp-help").find("input[name=helptext]").attr("val","");
//    //    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycDocument]").val("");
//    //    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycPk]").val("");
//    //    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").val("");
//    //    $(elem).parents("li").siblings("li").find("comp-help").attr("helpfk", "0");
//    //    $(elem).parents("li").siblings("li").find("input[colkey=dde_DOCPK]").val("");
//    //    $(elem).parents("li").siblings("li.date").find("input").val("");
//    //    $(elem).val("");
//    //        fnShflAlert("error", ErrMsg);
//    //      return false;
//    //}

//    $(elem).parents("li").siblings("li.date").attr("style", "display:none");
//    $(elem).parents("li").siblings("li").find("comp-help").find("input").val("");
//    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").val("");

//    if ($(elem).val() == 'Address Proof') { 
//        $(elem).parents("li").siblings("li").find("comp-help").attr("helpfk", "A"); 
//    }
//    else if ($(elem).val() == 'Id Proof') {
//        $(elem).parents("li").siblings("li").find("comp-help").attr("helpfk", "I");
//    }
//    else if ($(elem).val() == 'DOB Proof') {
//        $(elem).parents("li").siblings("li").find("comp-help").attr("helpfk", "D");
//    }
//    else if ($(elem).val() == 'Signature Proof') {
//        $(elem).parents("li").siblings("li").find("comp-help").attr("helpfk", "S");
//    }
//}
function Comgenclick(rowjson, elem) {
    $(elem).parents("li").find("input[colkey=Com_genDocname]").val(rowjson.DocumentName);
    $(elem).parents("li").find("input[colkey=Com_genDoctPk]").val(rowjson.DocPk);
    ErrMsg = "";
    var count = 0;
    debugger;
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
        if (($(this).find("input[colkey=Com_genDocname]").val() == $(elem).parents("li").find("input[colkey=Com_genDocname]").val()))
        {
            count += 1;
        }
    });
    if(count > 1)
    {
            $(elem).parents("li").find("input[colkey=Com_genDocname]").val("");
            $(elem).parents("li").find("input[colkey=Com_genDoctPk]").val("");
            $(elem).find("input[name=helptext]").val("");
            fnShflAlert("error", "Documents already given");
            return;
    }
}

function Comclick(rowjson, elem) {
    $(elem).parents("li").find("input[colkey=Com_Docname]").val(rowjson.DocumentName);
    $(elem).parents("li").find("input[colkey=Com_DoctPk]").val(rowjson.DocPk);
    ErrMsg = "";
    var count = 0;
    debugger;
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    $("#" + val + " .Doc_div .rowGrid").each(function () {
        if (($(this).find("input[colkey=Com_Docname]").val() == $(elem).parents("li").find("input[colkey=Com_Docname]").val())) {
            count += 1;
        }
    });
    if (count > 1) {
        $(elem).parents("li").find("input[colkey=Com_Docname]").val("");
        $(elem).parents("li").find("input[colkey=Com_DoctPk]").val("");
        $(elem).find("input[name=helptext]").val("");
        fnShflAlert("error", "Documents already given");
        return;
    }
}
function Docaddclick(rowjson,elem)
{
  
    $(elem).parent().find("input[colkey=dde_KycaddDocument]").val(rowjson.DocumentName).trigger("change");
    $(elem).parent().find("input[colkey=dde_KycaddPk]").val(rowjson.DocPk);
    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddrefDate]").val("");
    var validity = rowjson.Docvalidpk;
    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").val("");

    ErrMsg = "";
    var count = 0;
    debugger;
    var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    if ((rowjson.DocPk != 654) && (rowjson.DocPk != 653) && (rowjson.DocPk != 655) && (rowjson.DocPk != 656)) {
        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
            if (($(this).find("input[colkey=dde_KycaddDocument]").val() == $(elem).parents("li").find("input[colkey=dde_KycaddDocument]").val())) {
                count += 1;
            }
        });
        if (count > 1) {
            $(elem).parent().find("input[colkey=dde_KycaddDocument]").val("");
            $(elem).parent().find("input[colkey=dde_KycaddPk]").val("");
            $(elem).find("input[name=helptext]").val("");
            fnShflAlert("error", "Documents already given");
            return;
        }
    }
    if ((rowjson.DocPk != 654) && (rowjson.DocPk != 653) && (rowjson.DocPk != 655) && (rowjson.DocPk != 656)) {
        $("#" + val + " .Kyc_div .rowGrid").each(function () {
            if (($(this).find("input[colkey=dde_KycDocument]").val() == $(elem).parents("li").find("input[colkey=dde_KycaddDocument]").val())) {
                count += 1;
            }
        });
        if (count > 1) {
            $(elem).parent().find("input[colkey=dde_KycaddDocument]").val("");
            $(elem).parent().find("input[colkey=dde_KycaddPk]").val("");
            $(elem).find("input[name=helptext]").val("");
            fnShflAlert("error", "Documents already given");
            return;
        }
    }

    if(validity == 'Y')
    {
        $(elem).parents("li").siblings("li.date").find("input").val("");
        $(elem).parents("li").siblings("li.date").attr("style", "display:inline-block");
    }
    else {
        $(elem).parents("li").siblings("li.date").find("input").val("");
        $(elem).parents("li").siblings("li.date").attr("style", "visibility:hidden");
    }

    if(rowjson.DocPk == "283" )
    {
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").removeAttr("onblur");
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").addClass("adhar");
    }
    else if (rowjson.DocPk == "57") {
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").removeClass("adhar");
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").attr("onblur", "validatepancard(this)");
    }
    else
    {
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").removeClass("adhar");
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycaddRefno]").removeAttr("onblur");
    }

   

}

function Docclick(rowjson,elem)
{
  
    $(elem).parent().find("input[colkey=dde_KycDocument]").val(rowjson.DocumentName).trigger("change");
    $(elem).parent().find("input[colkey=dde_KycPk]").val(rowjson.DocPk);
    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycrefDate]").val("");
    var validity = rowjson.Docvalidpk;
    $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").val("");

    //ErrMsg = "";
    //var count = 0;
    //debugger;
    //var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
    //if ((rowjson.DocPk != 654) && (rowjson.DocPk != 653) && (rowjson.DocPk != 655) && (rowjson.DocPk != 656)) {
    //    $("#" + val + " .Kyc_div .rowGrid").each(function () {
    //        if (($(this).find("input[colkey=dde_KycProof]").val() == $(elem).parents("li").siblings("li").find("input[colkey=dde_KycProof]").val()) && ($(this).find("input[colkey=dde_KycDocument]").val() == $(elem).parents("li").find("input[colkey=dde_KycDocument]").val())) {
    //            count += 1;
    //        }
    //    });
    //    if (count > 1) {
    //        $(elem).parent().find("input[colkey=dde_KycDocument]").val("");
    //        $(elem).parent().find("input[colkey=dde_KycPk]").val("");
    //        $(elem).find("input[name=helptext]").val("");
    //        fnShflAlert("error", "Documents already given");
    //        return;
    //    }
    //}


    if(validity == 'Y')
    {
        $(elem).parents("li").siblings("li.date").find("input").val("");
        $(elem).parents("li").siblings("li.date").attr("style", "display:inline-block");
    }
    else {
        $(elem).parents("li").siblings("li.date").find("input").val("");
        $(elem).parents("li").siblings("li.date").attr("style", "visibility:hidden");
    }

    if(rowjson.DocPk == "283" )
    {
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").removeAttr("onblur");
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").addClass("adhar");
    }
    else if (rowjson.DocPk == "57") {
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").removeClass("adhar");
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").attr("onblur", "validatepancard(this)");
    }
    else
    {
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").removeClass("adhar");
        $(elem).parents("li").siblings("li").find("input[colkey=dde_KycRefno]").removeAttr("onblur");
    }

   

}
function fnAddLegalHier(Action) {
        var ErrMsg = "";
        ErrMsg = fnChkMandatory("legal_hier", 1, 0, "Legal Hier");

        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return;
        }


        var rowCount = 0;
        if (Action == 'PK') {
            $("#" + val + " .box-hier .rowGrid").each(function () {
                if (rowCount > 0)
                    $(this).remove();


                rowCount += 1;
            })
        }

        var s = '';
        $(".box-hier").append(document.querySelector(".box-hier-ul").outerHTML);
        s += '<li><i class="icon-close" onclick="fnCloseLegalHiger(this)"></i></li>';
        $(".box-hier").children("ul:last-child").append(s);
        $(".box-hier").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $(".box-hier").find('.new').removeClass("new");
    }


    function fnAddBank() {

        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var s = '';

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey='dde_Bank_AcNum1']").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Account Number Required!!" : ErrMsg + "<br/>Account Number Required!!";
                        return false;

                    }
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

       
        var c = 1;  
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey='dde_op_since1']").val().trim() != "") {
                        var dateval = $(this).find("li").find("input[colkey='dde_op_since1']").val()
                        var date = dateval.substring(0, 2);
                        var month = dateval.substring(3, 5);
                        var year = dateval.substring(6, 10);
                        var dateToCompare = new Date(year, month - 1, date);
                        var currentDate = new Date();
                        if (dateval != '') {
                            if (dateToCompare > currentDate) {
                                ErrMsg = ErrMsg == "" ? "Operative since Should not be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Operative since Should not be greater than Current Date_Row:" + c + "!!";
                                return false;
                            }
                        }
                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Bank Name is Required!!" : ErrMsg + "<br/> Bank Name is Required!!";
                        return false;

                    }
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

  
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {

                    if ($(this).find("li.bank").find("input[colkey=dde_Bank_bnkName2]").val() != $(this).find("li.bank comp-help").find("input[name='helptext']").val()) {
                        ErrMsg = ErrMsg == "" ? "Valid Bank Name is Required!!" : ErrMsg + "<br/>Valid Bank Name is Required!!";
                        return false;
                    }

                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }


        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() != "") {
                        if ($(this).find("li.branch comp-help").find("input[name='helptext']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Branch Name is Required!!" : ErrMsg + "<br/> Branch Name is Required!!";
                            return false;
                        }
                    }
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {

                    if ($(this).find("li.branch").find("input[colkey=dde_Bank_branch2]").val() != $(this).find("li.branch comp-help").find("input[name='helptext']").val()) {
                        ErrMsg = ErrMsg == "" ? "Valid Branch Name is Required!!" : ErrMsg + "<br/>Valid branch Name is Required!!";
                        return false;
                    }

                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }


        $("#" + val + " .bank-div").append(document.querySelector(".bank-div-ul").outerHTML);
        s += '<li> <i class="icon-close" onclick="fnCloseBank(this)"></i></li>';
        $("#" + val + " .bank-div").children("ul:last-child").append(s);
        $(".bank-div").children("ul:last-child").find(".datepickerdef").removeAttr("id");
        $(".bank-div").children("ul:last-child").find(".datepickerdef").removeClass("hasDatepicker");
        fnDrawDefaultDatePicker();
        $(".bank-div .datepicker,.datepickerdef").each(function () {
            fnRestrictDate($(this));
        });
        $("#" + val + " .bank-div").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $("#" + val + " .bank-div").find('.new').removeClass("new");
        $("#" + val + " .bank-div").children("ul:last-child").find("li.branch").find("comp-help").attr("helpfk", 0);
        validatebank();
        fnInitiateSelect("bank-div", 1);
    }

    function fnAddAsset(AddType) {
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        //$(".dde_cont.det-content4.det_content.ass_cont").attr({ contentchanged: "true", val: "23" });
        var s = '';
        if (GlobalXml[0].IsAll != "1" && AddType != "" && AddType != undefined) {
            ErrMsg = fnChkMandatory(val);
            $("#" + val + " .asset_grid .rowGrid").each(function () {
                if ($(this).find("[colkey='dde_Asset_amt1']").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Asset Amount Required!!" : ErrMsg + "<br/> Asset Amount Required!!";
                }
                else if ($(this).find("[colkey='dde_Asset_type1']").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Type Required!!" : ErrMsg + "<br/> Type Required!!";
                }
            });
            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                return false;
            }
        }

        $("#" + val + " .asset_grid").append(document.querySelector(".asset_grid_ul").outerHTML);
        s += '<li> <i class="icon-close" onclick="fnCloseAsset(this)"></i></li>';
        $("#" + val + " .asset_grid").children("ul:last-child").append(s);
        $("#" + val + " .asset_grid").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $("#" + val + " .asset_grid").find('.new').removeClass("new");
    }

    function fnAddCc(AddType) {
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");

        var s = '';
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .credit_cont").is("[contentchanged='true']")) {
                $("#" + val + " .credit_grid .rowGrid").each(function () {
                    if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Issuing Bank Name is Required!!" : ErrMsg + "<br/>Issuing Bank Name is Required!!";
                        return false;

                    }
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

 
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .credit_cont").is("[contentchanged='true']")) {
                $("#" + val + " .credit_grid .rowGrid").each(function () {

                    if ($(this).find("li.bank").find("input[colkey=dde_cc_issuingbnk2]").val() != $(this).find("li.bank comp-help").find("input[name='helptext']").val()) {
                        ErrMsg = ErrMsg == "" ? "Valid Issuing Bank Name is Required!!" : ErrMsg + "<br/>Valid Issuing Bank Name is Required!!";
                        return false;
                    }

                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1" && AddType != "" && AddType != undefined) {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .credit_cont").is("[contentchanged='true']")) {
                $("#" + val + " .credit_grid .rowGrid").each(function () {
                    if ($(this).find("[colkey='dde_cc_limit1']").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Limit Required!!" : ErrMsg + "<br/> Limit Required!!";
                    }
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }


        $("#" + val + " .credit_grid").append(document.querySelector(".credit_grid_ul").outerHTML);
        s += '<li> <i class="icon-close" onclick="fnCloseCreditcard(this)"></i></li>';
        $("#" + val + " .credit_grid").children("ul:last-child").append(s);
        $("#" + val + " .credit_grid").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $("#" + val + " .credit_grid").find('.new').removeClass("new");
    }

    function fnShowSelValues(Evt, SelObj) {
        debugger
        if (Evt != "RA")
            fnShowSelDiv(Evt, SelObj);
        if (Evt == 'T') {
            if (IsFinalConfirm != "") {
                fnCallFinalConfirmation(IsFinalConfirm);
                return;
            }

            var LapFk = $(Cur_Active_Actor_li).attr("Pk");
            var QdeFk = 0;
            if (LapFk == 0) { QdeFk = $(Cur_Active_Actor_li).attr("QdeFk"); }
            fnQDELoadLeadDetails("S", LapFk, QdeFk);
        }
        else if (Evt == 'R') {
            var RefFk = $(Cur_Active_ref_li).attr("pk");
            fnQDELoadLeadDetails("Ref", 0, 0, RefFk)
        }
        else if (Evt == 'RA') {
            fnddeAddNewRefTab($("#dde_ul_ref_tabs .DDERefAdd"), Evt);
        }
    }
    function showdiv() {
        debugger
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var rowcount = 0;
        $("#" + val + " .obligation_grid .headings").each(function () {
            rowcount += 1;
        })
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .obligation_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .obligation_grid").attr("style") == "display: block;") {
                    $("#" + val + " .obligation_grid .rowGrid").each(function () {

                        if ($(this).find("[colkey='dde_ob_outstnd1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Outstanding Amount Required!!" : ErrMsg + "<br/> Outstanding Amount Required!!";
                        }

                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .obligation_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .obligation_grid").attr("style") == "display: block;") {
                    $("#" + val + " .obligation_grid .rowGrid").each(function () {
               
                        if ($(this).find("[colkey='dde_ob_emi1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Emi Required!!" : ErrMsg + "<br/> Emi Required!!";
                        }
                
                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        window.flagvalue = "SET";
        $("#dde_div_appPop").show();
    }
    function Pinclick(rowjson, elem) {
        $(elem).siblings("input").val(rowjson.Pincode).trigger("change");
        $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
        $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
        $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
    }
    //bank
    function Bnkclick(rowjson, elem) {
    
        console.log(elem);
        $(elem).parent().find("input[colkey=dde_Bank_bnkName1]").val(rowjson.Bankpk).trigger("change");
        $(elem).parent().find("input[colkey=dde_Bank_bnkName2]").val(rowjson.BankName);
        $(elem).parent().siblings("li.branch").find("comp-help").attr("helpfk", rowjson.Bankpk);
        $(elem).parent().siblings("li.branch").find("comp-help").find("input[name=helptext]").val("");
        $(elem).parent().siblings("li.branch").find("comp-help").find("input[name=helptext]").attr("val", "");

    }
    function Brnchclick(rowjson, elem) {
  
        $(elem).parent().find("input[colkey=dde_Bank_branch1]").val(rowjson.Brnchpk).trigger("change");
        $(elem).parent().find("input[colkey=dde_Bank_branch2]").val(rowjson.Location);
    }

    function fnDdeConfirmScreen(Evt, SelObj) {
        debugger
        var val = "dde_whole_div_" + $(Cur_Active_Actor_li).attr("val");
        var ref = "dde_ref_div_" + $(Cur_Active_ref_li).attr("val");
   
  
        if ($("#" + val + " .occupation-div").find("input[key='dde_occ_typeOfEmployment']").val() == "Salaried")
        {
            $("#" + val + " .selfemp-div").attr("contentchanged", "false");
            $("#" + val + " .student-div").attr("contentchanged", "false");   
        }
        else if ($("#" + val + " .occupation-div").find("input[key='dde_occ_typeOfEmployment']").val() == "Self Employed")
        {
            $("#" + val + " .salaried-div").attr("contentchanged", "false");
            $("#" + val + " .student-div").attr("contentchanged", "false");
        }
        else if ($("#" + val + " .occupation-div").find("input[key='dde_occ_typeOfEmployment']").val() == "Student") {
            $("#" + val + " .selfemp-div").attr("contentchanged", "false");
            $("#" + val + " .salaried-div").attr("contentchanged", "false");
        }
        else{
            $("#" + val + " .salaried-div").attr("contentchanged", "false");
            $("#" + val + " .selfemp-div").attr("contentchanged", "false");
            $("#" + val + " .student-div").attr("contentchanged", "false");
        }


        /*MUTHU 22/12/16 */
        var emptypval = $("#type_emp_id").attr("selval");
        if (emptypval == -1) {
            $(".salaried-div.dde_cont.emp_Content").hide();
        }

        /*end*/
        /*muthu 04/1/17*/
        var actorval = $("#dde_ul_app_tabs").find(".active").attr("actor");
        if (actorval <= 1) {
            var divid = actorval > 0 ? "dde_whole_div_1" : "dde_whole_div_0";
            $("#" + divid + ".div_content").find("#firstdivid").attr("contentchanged", "true");
        } else {
            var divid = "dde_whole_div_2";
            $("#" + divid + ".div_content").find("#firstdivid").attr("contentchanged", "true");
        }  
        ErrMsg = fnChkMandatory(divid);
        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }
        /*end*/
        debugger
        if ($("#" + val + " .frstdiv").find("input[key='dde_gender']").val() == "Female") {
            if (($("#" + val + " .frstdiv").find("input[key='dde_title']").val() != "Ms") && ($("#" + val + " .frstdiv").find("input[key='dde_title']").val() != "Mrs")){ 
                fnShflAlert("error","Title and Gender Mismatch!");
                return;
            }
        }
        else {
            if ($("#" + val + " .frstdiv").find("input[key='dde_title']").val() != "Mr") {
                fnShflAlert("error","Title and Gender Mismatch!");
                return;
            }

        }
        //}



        var rowcount = 0;
        $("#" + val + " .obligation_grid .headings").each(function () {
            rowcount += 1;
        })

   debugger
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .obligation_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .obligation_grid").attr("style") == "display: block;") {
                    $("#" + val + " .obligation_grid .rowGrid").each(function () {

                        if ($(this).find("[colkey='dde_ob_outstnd1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Outstanding Amount Required_Row:"+c+"!!" : ErrMsg + "<br/> Outstanding Amount Required_Row:"+c+"!!";
                        }
                        c++;
                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .obligation_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .obligation_grid").attr("style") == "display: block;") {
                    $("#" + val + " .obligation_grid .rowGrid").each(function () {

                        if ($(this).find("[colkey='dde_ob_emi1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Emi Required_Row:"+c+"!!" : ErrMsg + "<br/> Emi Required_Row"+c+"!!";
                        }
                        c++;
                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }



    
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .ass_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .ass_cont").find("textarea[key=dde_Asset_Remarks]").val() != "")
                {
                    $("#" + val + " .asset_grid .rowGrid").each(function () {
                   
                        if (($(this).find("[colkey='dde_Asset_des1']").val() != "") || ($(this).find("[colkey='dde_Asset_type1']").attr("selval") != -1)) {
                            if ($(this).find("[colkey='dde_Asset_amt1']").val() == "") {
                                ErrMsg = ErrMsg == "" ? "Asset Amount Required_Row:"+c+"!!" : ErrMsg + "<br/> Asset Amount Required_Row:"+c+"!!";
                            }
                            else if ($(this).find("[colkey='dde_Asset_type1']").val() == "") {
                                ErrMsg = ErrMsg == "" ? "Type Required_Row:" + c + "!!" : ErrMsg + "<br/> Type Required_Row:" + c + "!!";
                            }
                        }
                        c++;
                    });
                }
                else {
                    $("#" + val + " .asset_grid .rowGrid").each(function () {

                        if ($(this).find("[colkey='dde_Asset_amt1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Asset Amount Required_Row:" + c + "!!" : ErrMsg + "<br/> Asset Amount Required_Row:" + c + "!!";
                        }
                        else if ($(this).find("[colkey='dde_Asset_type1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Type Required_Row:" + c + "!!" : ErrMsg + "<br/> Type Required_Row:" + c + "!!";
                        }
                        c++;
                    });

                }

                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .credit_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .credit_cont").find("textarea[key=dde_cc_remarks]").val() != "") {
                    $("#" + val + " .credit_grid .rowGrid").each(function () {
                        if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Issuing Bank Name Required_Row:" + c + "!!" : ErrMsg + "<br/>Issuing Bank Name Required_Row:" + c + "!!";
                            return false;

                        }
                        c++;
                    });
                }
                else {
                    $("#" + val + " .credit_grid .rowGrid").each(function () {
                        if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Issuing Bank Name Required_Row:" + c + "!!" : ErrMsg + "<br/>Issuing Bank Name Required_Row:" + c + "!!";
                            return false;
                        }
                        c++;
                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

    
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .credit_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .credit_cont").find("textarea[key=dde_cc_remarks]").val() != "") {
                    $("#" + val + " .credit_grid .rowGrid").each(function () {
                        if ($(this).find("li.bank").find("input[colkey=dde_cc_issuingbnk2]").val() != $(this).find("li.bank comp-help").find("input[name='helptext']").val()) {
                            ErrMsg = ErrMsg == "" ? "Valid Issuing Bank Name Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid Issuing Bank Name Required_Row:" + c + "!!";
                            return false;
                        }
                        c++;
                    });
                }
                else {
                    $("#" + val + " .credit_grid .rowGrid").each(function () {
                        if ($(this).find("li.bank").find("input[colkey=dde_cc_issuingbnk2]").val() != $(this).find("li.bank comp-help").find("input[name='helptext']").val()) {
                            ErrMsg = ErrMsg == "" ? "Valid Issuing Bank Name Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid Issuing Bank Name Required_Row:" + c + "!!";
                            return false;
                        }
                        c++;
                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .credit_cont").is("[contentchanged='true']")) {
                if ($("#" + val + " .credit_cont").find("textarea[key=dde_cc_remarks]").val() != "") {


                    $("#" + val + " .credit_grid .rowGrid").each(function () {
                        if (($(this).find("[colkey='dde_cc_cno1']").val() != "") || ($(this).find("[colkey='dde_cc_ctype1']").attr("selval") != -1)) {
                            if ($(this).find("[colkey='dde_cc_limit1']").val() == "") {
                                ErrMsg = ErrMsg == "" ? "Limit Required_Row:" + c + "!!" : ErrMsg + "<br/> Limit Required_Row:" + c + "!!";
                            }
                        }
                        c++;
                    });
                }
                else {
                    $("#" + val + " .credit_grid .rowGrid").each(function () {
                        if ($(this).find("[colkey='dde_cc_limit1']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Limit Required_Row:" + c + "!!" : ErrMsg + "<br/> Limit Required_Row:" + c + "!!";
                        }
                        c++;
                    });
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }



       
            if ($("#" + val + " .personal-div").find("input[key=dde_Per_Religion]").attr("selval") == "") {
                fnShflAlert("error","Select Religion");
                return;
            }
        
      
            if ($("#" + val + " .personal-div").find("input[key=dde_Per_community]").attr("selval") == -1) {
                fnShflAlert("error", "Select Community");
                return;
            }


            if ($("#" + val + " .personal-div").find("input[key=dde_Per_Fat_hus_Fname]").val() == "") {
                fnShflAlert("error", "Father/Husband name required");
                return;
            }
        
        if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
            if ($("#" + val + " .present-aaddress").find("input[key=dde_Per_acc]").attr("selval") == -1) {
                fnShflAlert("error","Select Accomodation type");
                return;
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
                if (($("#" + val + " .present-aaddress").find("comp-help").find("input[name=helptext]").val().trim() == "")) {
                    ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "<br/> Pincode Required!!";
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
                if (($("#" + val + " .present-aaddress").find("comp-help").find("input[name=helptext]").val().trim() != "")) {
                    if (($("#" + val + " .present-aaddress").find("comp-help").find("input[name=helptext]").val() != $("#" + val + " .present-aaddress").find("input[key=dde_pin]").val())) {
                        ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
                    }
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
           
                if (($("#" + val + " .present-aaddress").find(".residing").find("input[key=dde_residing_yrs]").val() == ""))
                {
                    ErrMsg = ErrMsg == "" ? "No Of Years Residing Required!!" : ErrMsg + "<br/> No Of Years Residing Required!!";
                }      
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {

                if (($("#" + val + " .present-aaddress").find(".residing").find("input[key=dde_residing_yrs]").val() <= 0)) {
                    ErrMsg = ErrMsg == "" ? "No Of Years Residing Must be greater than 0!!" : ErrMsg + "<br/> No Of Years Residing Must be greater than 0!!";
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
                if ($("#" + val + " .present-aaddress").find(".rental").attr("style") == "display:block;") {
                    if ($("#" + val + " .present-aaddress").find(".rental").find("input[key=dde_rental]").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Rental Amount required!!" : ErrMsg + "<br/> Rental Amount required!!";
                        if (ErrMsg != "") {
                            fnShflAlert("error", ErrMsg);
                            return false;
                        }
                    }
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
                if ($("#" + val + " .present-aaddress").find(".rental").attr("style") == "display:block;") {
                    if ($("#" + val + " .present-aaddress").find(".rental").find("input[key=dde_rental]").val() != "") {
                        if (($("#" + val + " .present-aaddress").find(".rental").find("input[key=dde_rental]").val() <= 0)) {
                            ErrMsg = ErrMsg == "" ? "Rental Amount Must be greater than 0!!" : ErrMsg + "<br/> Rental Amount Must be greater than 0!!";
                        }
                        if (ErrMsg != "") {
                            fnShflAlert("error", ErrMsg);
                            return false;
                        }
                    }
                }
            }
        }
    

   
  
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey='dde_Bank_AcNum1']").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Account Number Required_Row:"+c+"!!" : ErrMsg + "<br/>Account Number Required_Row:"+c+"!!";
                        return false;

                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        var c = 1;
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey='dde_op_since1']").val().trim() != "") {
                        var dateval = $(this).find("li").find("input[colkey='dde_op_since1']").val()
                        var date = dateval.substring(0, 2);
                        var month = dateval.substring(3, 5);
                        var year = dateval.substring(6, 10);
                        var dateToCompare = new Date(year, month - 1, date);
                        var currentDate = new Date();
                        if (dateval != '') {
                            if (dateToCompare > currentDate) {
                                ErrMsg = ErrMsg == "" ? "Operative since Should not be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Operative since Should not be greater than Current Date_Row:" + c + "!!";
                                return false;
                            }
                        }
                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Bank Name Required_Row:" + c + "!!" : ErrMsg + "<br/> Bank Name Required_Row:" + c + "!!";
                        return false;

                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
    
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {

                    if ($(this).find("li.bank").find("input[colkey=dde_Bank_bnkName2]").val() != $(this).find("li.bank comp-help").find("input[name='helptext']").val()) {
                        ErrMsg = ErrMsg == "" ? "Valid Bank Name is Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid Bank Name is Required_Row:" + c + "!!";
                        return false;
                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {
                    if ($(this).find("li.bank comp-help").find("input[name='helptext']").val() != "") {
                        if ($(this).find("li.branch comp-help").find("input[name='helptext']").val() == "") {
                            ErrMsg = ErrMsg == "" ? "Branch Name Required_Row:" + c + "!!" : ErrMsg + "<br/> Branch Name Required_Row:" + c + "!!";
                            return false;
                        }
                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .det-content3").is("[contentchanged='true']")) {
                $("#" + val + " .bank-div .rowGrid").each(function () {

                    if ($(this).find("li.branch").find("input[colkey=dde_Bank_branch2]").val() != $(this).find("li.branch comp-help").find("input[name='helptext']").val()) {
                        ErrMsg = ErrMsg == "" ? "Valid Branch Name Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid branch Name Required_Row:" + c + "!!";
                        return false;
                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        /*muthu(6/1/17)*/
        if ($("#dde_content_Pg").find("li.saleofz comp-help").find("input[name='helptext']").val() != "") {
            if ($("#dde_content_Pg").find("li.saleofz comp-help").find("input[name='helptext']").val() != $("#dde_content_Pg").find("li.saleofz input[key=dde_builoc]").attr("valtext")) {
                fnShflAlert("error", "Valid SaleOffice Required!!");
                return false;
            }
        }
        /*end*/

        var lessval1 = $("#" + val + " .occupation-div").find("input[key=dde_occSal_no_of_month]").val();
        var totval1 = $("#" + val + " .occupation-div").find("input[key=dde_occSal_tot_emp]").val();
        if (parseInt(lessval1) > parseInt(totval1)) {
            fnShflAlert("error","Total employment should be greater than No. of Month Employed");
            return;
        }
        /*MUTHU 20/12/16*/
        var valueocctyp = $(".occupation-div").find("input[key=dde_occSal_typeOfOrg]").attr("selval");
        if (valueocctyp == -1) {
            $(".occupation-div").find("input[key=dde_occSal_typeOfOrg]").attr("selval", "5");
        }
        /*END*/

        var lessval = $("#" + val + " .occupation-div").find("input[key=dde_occSelf_noOfyrsCurrent]").val();
        var totval = $("#" + val + " .occupation-div").find("input[key=dde_occSelf_tot_bus]").val();
        if (parseInt(lessval) > parseInt(totval)) {
            fnShflAlert("error","Total business period should be greater than No.ofYears in Current Business");
            return;
        }
        if ($(".occupation-div").find("input[key=dde_occSal_typeOfOrg]").attr("selval") == -1) {
            $(".occupation-div").find("input[key=dde_occSal_typeOfOrg]").attr("selval", "");
        }

   

        if (GlobalXml[0].IsAll != "1") {

            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .seconddiv").find("input[key='dde_chk_doc']").prop("checked") == false) {
                if ($("#" + val + " [key='dde_adr_no']").val() == "" && $("#" + val + " [key='dde_pan_no']").val() == "" && $("#" + val + " [key='dde_vot_id']").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Aadhaar Number / PAN / Voter Id Required!!" : ErrMsg + "<br/> Aadhaar Number / PAN / Voter Id Required!!";
                }
            }

            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                return false;
            }
        }
  
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + ref).is("[contentchanged='true']")) {
            
                if (($("#" + ref).find("comp-help").find("input[name=helptext]").val().trim() != "")) {
                    if (($("#" + ref).find("comp-help").find("input[name=helptext]").val() != $("#" + ref).find("input[key=dde_pin_ref]").val())) {
                        ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
                    }
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .premenent-aaddress").is("[contentchanged='true']")) {

                if (($("#" + val + " .premenent-aaddress").find("comp-help").find("input[name=helptext]").val().trim() == "")) {
                    ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "<br/> Pincode Required!!";
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .premenent-aaddress").is("[contentchanged='true']")) {

                if (($("#" + val + " .premenent-aaddress").find("comp-help").find("input[name=helptext]").val().trim() != "")) {
                    if (($("#" + val + " .premenent-aaddress").find("comp-help").find("input[name=helptext]").val().trim() != $("#" + val + " .premenent-aaddress").find("input[key=dde_permanent_pin]").val().trim())) {
                        ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
                    }
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .salaried-div").is("[contentchanged='true']")) {
                if ($("#" + val).find(".salaried-div").find(".address-div").find("comp-help").find("input[name=helptext]").val().trim() == "") {
                    ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "<br/> Pincode Required!!";
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .salaried-div").is("[contentchanged='true']")) {

                if (($("#" + val + " .salaried-div").find("comp-help").find("input[name=helptext]").val().trim() != "")) {
                    if (($("#" + val + " .salaried-div").find("comp-help").find("input[name=helptext]").val().trim() != $("#" + val + " .salaried-div").find("input[key=dde_occSal_offAddr_pin]").val().trim())) {
                        ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
                    }
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .selfemp-div").is("[contentchanged='true']")) {
                if ($("#" + val).find(".selfemp-div").find(".address-div").find("comp-help").find("input[name=helptext]").val().trim() == "") {
                    ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "<br/> Pincode Required!!";
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .selfemp-div").is("[contentchanged='true']")) {

                if (($("#" + val + " .selfemp-div").find("comp-help").find("input[name=helptext]").val().trim() != "")) {
                    if (($("#" + val + " .selfemp-div").find("comp-help").find("input[name=helptext]").val().trim() != $("#" + val + " .selfemp-div").find("input[key=dde_occSal_offAddr_pin]").val().trim())) {
                        ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
                    }
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            if ($("#" + val + " .student-div").is("[contentchanged='true']")) {

                if (($("#" + val + " .student-div").find("comp-help").find("input[name=helptext]").val().trim() != "")) {
                    if (($("#" + val + " .student-div").find("comp-help").find("input[name=helptext]").val().trim() != $("#" + val + " .student-div").find("input[key=dde_occSal_offAddr_pin]").val().trim())) {
                        ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
                    }
                }
                if (ErrMsg != "") {

                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
    
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_div").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_div .rowGrid").each(function () {
                    if (($(this).find("li").find("input[colkey=dde_KycProof]").attr("selval") != -1) && ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "")) {
                        if (($(this).find("li").find("input[colkey=dde_KycRefno]").val().trim() == "") && ($(this).find("li").find("input[colkey=dde_KycPk]").val() != 654) && ($(this).find("li").find("input[colkey=dde_KycPk]").val() != 655) && ($(this).find("li").find("input[colkey=dde_KycPk]").val() != 656)) {
                            ErrMsg = ErrMsg == "" ? "Reference no Required_Row:" + c + "!!" : ErrMsg + "<br/>Reference no Required_Row:" + c + "!!";
                            return false;
                        }
                        c++;
                    }
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                        }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_div").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_div .rowGrid").each(function () {
                    if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                            if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=dde_KycDocument]").val()) {
                                ErrMsg = ErrMsg == "" ? "Valid document name Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid document name Required_Row:" + c + "!!";
                                return false;
                            }
                        }
                        c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        
        
        //if (GlobalXml[0].IsAll != "1") {
        //    ErrMsg = fnChkMandatory(val);
        //    var c = 1;
        //    if ($("#" + val + " .Kyc_div").is("[contentchanged='true']")) {
        //        $("#" + val + " .Kyc_div .rowGrid").each(function () {
        //            if ($(this).find("li.date").attr("style") == "display:inline-block")
        //            {
        //                if ($(this).find("li.date").find("input[colkey='dde_KycDate']").val().trim() == "") {
        //                    ErrMsg = ErrMsg == "" ? "Validity date Required_Row:" + c + "!!" : ErrMsg + "<br/>Validity date Required_Row:" + c + "!!";
        //                    return false;
        //                }
        //            }
        //            c++;
        //        });
        //        if (ErrMsg != "") {
        //            fnShflAlert("error", ErrMsg);
        //            return false;
        //        }
        //    }
        //}
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_div").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_div .rowGrid").each(function () {
                    if ($(this).find("li.date").attr("style") == "display:inline-block") {
                        if ($(this).find("li.date").find("input[colkey='dde_KycDate']").val().trim() != "") {
                            var dateval = $(this).find("li.date").find("input[colkey='dde_KycDate']").val()
                            var date = dateval.substring(0, 2);
                            var month = dateval.substring(3, 5);
                            var year = dateval.substring(6, 10);
                            var dateToCompare = new Date(year, month - 1, date);
                            var currentDate = new Date();
                            if (dateval != '') {
                                if (dateToCompare < currentDate) {
                                    ErrMsg = ErrMsg == "" ? "Validity Date Should be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Validity Date Should be greater than Current Date_Row:" + c + "!!";
                                    return false;
                                }
                            }
                        }
                    }
                    c++;
                });
            }
            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                return false;
                                }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_div").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_div .rowGrid").each(function () {
                        if ($(this).find("li.refdate").find("input[colkey='dde_KycrefDate']").val().trim() != "") {
                            var dateval = $(this).find("li.refdate").find("input[colkey='dde_KycrefDate']").val()
                            var date = dateval.substring(0, 2);
                            var month = dateval.substring(3, 5);
                            var year = dateval.substring(6, 10);
                            var dateToCompare = new Date(year, month - 1, date);
                            var currentDate = new Date();
                            if (dateval != '') {
                                if (dateToCompare >= currentDate) {
                                    ErrMsg = ErrMsg == "" ? "Reference Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Reference Date Should not be greater than Current Date_Row:" + c + "!!";
                                    return false;
                            }
                        }
                    }
                    c++;
                });
            }
            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                return false;
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_Adddiv").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                    if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                        if ($(this).find("li").find("input[colkey=dde_KycaddRefno]").val().trim() == "") {
                            ErrMsg = ErrMsg == "" ? "Reference no Required_Row:" + c + "!!" : ErrMsg + "<br/>Reference no Required_Row:" + c + "!!";
                            return false;
                        }
                        if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=dde_KycaddDocument]").val()) {
                            ErrMsg = ErrMsg == "" ? "Valid document name Required_Row:" + c + "!!" : ErrMsg + "<br/>Valid document name Required_Row:" + c + "!!";
                            return false;
                        }
                    }
                    c++;
                });
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_Adddiv").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                    if ($(this).find("li.date").attr("style") == "display:inline-block") {
                        if ($(this).find("li.date").find("input[colkey='dde_KycaddDate']").val().trim() != "") {
                            var dateval = $(this).find("li.date").find("input[colkey='dde_KycaddDate']").val()
                            var date = dateval.substring(0, 2);
                            var month = dateval.substring(3, 5);
                            var year = dateval.substring(6, 10);
                            var dateToCompare = new Date(year, month - 1, date);
                            var currentDate = new Date();
                            if (dateval != '') {
                                if (dateToCompare < currentDate) {
                                    ErrMsg = ErrMsg == "" ? "Validity Date Should be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Validity Date Should be greater than Current Date_Row:" + c + "!!";
                                    return false;
                                }
                            }
                        }
                    }
                    c++;
                });
            }
            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                return false;
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Kyc_Adddiv").is("[contentchanged='true']")) {
                $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
                        if ($(this).find("li.refdate").find("input[colkey='dde_KycaddrefDate']").val().trim() != "") {
                            var dateval = $(this).find("li.refdate").find("input[colkey='dde_KycaddrefDate']").val()
                            var date = dateval.substring(0, 2);
                            var month = dateval.substring(3, 5);
                            var year = dateval.substring(6, 10);
                            var dateToCompare = new Date(year, month - 1, date);
                            var currentDate = new Date();
                            if (dateval != '') {
                                if (dateToCompare > currentDate) {
                                    ErrMsg = ErrMsg == "" ? "Reference Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMsg + "<br/>Reference Date Should not be greater than Current Date_Row:" + c + "!!";
                                    return false;
                                }
                            }
                        }
                    c++;
                });
            }
            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                return false;
            }
        }
        var ErrMs = "";
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Doc_div").is("[contentchanged='true']")) {
                $("#" + val + " .Doc_div .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey=Com_Doctype]").attr("selval") != -1) {
                        if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                            ErrMs = ErrMs == "" ? "Document Details: Document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Document name Required_Row:" + c + "!!";
                            return false;
                        }
                        //else if ($(this).find("li").find("input[colkey=Com_Docstatus]").attr("selval") == -1) {
                        //    ErrMs = ErrMs == "" ? "Document Details: Select Document status Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Select Document status Required_Row:" + c + "!!";
                        //    return false;
                        //}
                        else if (($(this).find("li").find("input[colkey=Com_Refno]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_Refno]").attr("style") == "display:inline-block")) {
                            ErrMs = ErrMs == "" ? "Document Details: Reference no Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Reference no Required_Row:" + c + "!!";
                            return false;
                        }
                        //else if (($(this).find("li").find("input[colkey=Com_RecDate]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_RecDate]").attr("style") == "display:inline-block")) {
                        //    ErrMs = ErrMs == "" ? "Document Details: Received date Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Received date Required_Row:" + c + "!!";
                        //    return false;
                        //}

                        else if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                            if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=Com_Docname]").val()) {
                                ErrMs = ErrMs == "" ? "Document Details: Valid document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Valid document name Required_Row:" + c + "!!";
                                return false;
                            }
                        }
                        c++;
                    }
                });
            }
            if (ErrMs != "") {
                fnShflAlert("error", ErrMs);
                return;
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            var c = 1;
            if ($("#" + val + " .Doc_div").is("[contentchanged='true']")) {
                $("#" + val + " .Doc_div .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey='Com_RecDate']").val().trim() != "") {
                        var dateval = $(this).find("li").find("input[colkey='Com_RecDate']").val()
                        var date = dateval.substring(0, 2);
                        var month = dateval.substring(3, 5);
                        var year = dateval.substring(6, 10);
                        var dateToCompare = new Date(year, month - 1, date);
                        var currentDate = new Date();
                        if (dateval != '') {
                            if (dateToCompare > currentDate) {
                                ErrMs = ErrMs == "" ? "Received Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMs + "<br/>Received Date Should not be greater than Current Date_Row:" + c + "!!";
                                return false;
                            }
                        }
                    }
                    c++;
                });
            }
            if (ErrMs != "") {
                fnShflAlert("error", ErrMs);
                return;
            }
        }


        var ErrMs = "";
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            if ($("#" + val + " .Doc_Gendiv").is("[contentchanged='true']")) {
                $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey=Com_genDoctype]").attr("selval") != -1) {
                        if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                            ErrMs = ErrMs == "" ? "Document Details: Document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Document name Required_Row:" + c + "!!";
                            return false;
                        }
                        //else if ($(this).find("li").find("input[colkey=Com_genDocstatus]").attr("selval") == -1) {
                        //    ErrMs = ErrMs == "" ? "Document Details: Select Document status Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Select Document status Required_Row:" + c + "!!";
                        //    return false;
                        //}
                        else if (($(this).find("li").find("input[colkey=Com_genRefno]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_genRefno]").attr("style") == "display:inline-block")) {
                            ErrMs = ErrMs == "" ? "Document Details: Reference no Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Reference no Required_Row:" + c + "!!";
                            return false;
                        }
                        //else if (($(this).find("li").find("input[colkey=Com_genRecDate]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_genRecDate]").attr("style") == "display:inline-block")) {
                        //    ErrMs = ErrMs == "" ? "Document Details: Received date Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Received date Required_Row:" + c + "!!";
                        //    return false;
                        //}

                        else if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") {
                            if ($(this).find("li comp-help").find("input[name=helptext]").val() != $(this).find("li").find("input[colkey=Com_genDocname]").val()) {
                                ErrMs = ErrMs == "" ? "Document Details: Valid document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Valid document name Required_Row:" + c + "!!";
                                return false;
                            }
                        }
                        c++;
                    }
                });
            }
            if (ErrMs != "") {
                fnShflAlert("error", ErrMs);
                return;
            }
        }
        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(val);
            var c = 1;
            var c = 1;
            if ($("#" + val + " .Doc_Gendiv").is("[contentchanged='true']")) {
                $("#" + val + " .Doc_Gendiv .rowGrid").each(function () {
                    if ($(this).find("li").find("input[colkey='Com_genRecDate']").val().trim() != "") {
                        var dateval = $(this).find("li").find("input[colkey='Com_genRecDate']").val()
                        var date = dateval.substring(0, 2);
                        var month = dateval.substring(3, 5);
                        var year = dateval.substring(6, 10);
                        var dateToCompare = new Date(year, month - 1, date);
                        var currentDate = new Date();
                        if (dateval != '') {
                            if (dateToCompare > currentDate) {
                                ErrMs = ErrMs == "" ? "Received Date Should not be greater than Current Date_Row:" + c + "!!" : ErrMs + "<br/>Received Date Should not be greater than Current Date_Row:" + c + "!!";
                                return false;
                            }
                        }
                    }
                    c++;
                });
            }
            if (ErrMs != "") {
                fnShflAlert("error", ErrMs);
                return;
            }
        }

        if (GlobalXml[0].IsAll != "1") {
            ErrMsg = fnChkMandatory(ref);
            if ($("#" + ref).is("[contentchanged='true']")) {
                if (($("#" + ref).find("li").find("input[key=dde_ref_mobno]").val().trim() == "")) {
                    ErrMsg = ErrMsg == "" ? "Reference details Mobile no Required!!" : ErrMsg + "<br/> Reference details Mobile no Required!!";
                }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }
            }
        }

        /*muthu*/
        if ($("#" + val + " .occupation-div").find("input[key=dde_occSelf_msme]").attr("selval") == -1) {
            $("#" + val + " .occupation-div").find("input[key=dde_occSelf_msme]").attr("selval", "");
        }
        debugger
        FinalSelObj = SelObj;
        if (Evt == 'T') {
            debugger
            if ($(Cur_Active_Actor_li).attr("val") == $(SelObj).attr("val") && IsFinalConfirm == "") {
                return;
            }
        }
        else if (Evt == 'D') {
            if ($(Cur_Active_Dtl_li).attr("val") == $(SelObj).attr("val")) {
                return;
            }
        }
        else if (Evt == 'R') {
            if ($(Cur_Active_ref_li).attr("val") == $(SelObj).attr("val")) {
                return;
            }
        }
        else if (Evt == 'A') {
            if ($(Cur_Active_Adr_li).attr("val") == $(SelObj).attr("val")) {
                return;
            }
        }
        else if (Evt == 'RA') {

        }
        else {
            return;
        }

        var DocrefPk = 0; var LoadredDiv; var IsOcc = 0;
        var DocPk = 0; var LoadDiv; var ActorNm = ""; var Actor = 0;
        var AppJson = {}, HdrJson = {}, LegalJson = {}, CreditJson = {}, ObliJson = {}, AssetJson = {}, BankJson = {};
        var KycJson = {}, KycaddJson={};
        var Docjson = {}, DocgenJson = {};

        LoadDiv = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val"));
        LoadredDiv = $("#dde_ref_div_" + $(Cur_Active_ref_li).attr("val"));




        if ($("#" + LoadDiv.attr("id") + " .present-aaddress").is("[contentchanged='true']") ||
            $("#" + LoadDiv.attr("id") + " .premenent-aaddress").is("[contentchanged='true']")) {
            $("#" + LoadDiv.attr("id") + " .per_div").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " input[key='dde_Personal_hidden']").val("20");
        }

        if ($("#" + LoadDiv.attr("id") + " .premenent-aaddress").is("[contentchanged='true']") ||
            $("#" + LoadDiv.attr("id") + " .present-aaddress").is("[contentchanged='true']")) {
            $("#" + LoadDiv.attr("id") + " .per_div").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " input[key='dde_Personal_hidden']").val("20");
        }

        if ($("#" + LoadDiv.attr("id") + " .frstdiv").is("[contentchanged='true']")) {
            $("#" + LoadDiv.attr("id") + " .seconddiv").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " .per_div").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " input[key='dde_Personal_hidden']").val("20");
            $("#" + LoadDiv.attr("id") + " input[key='dde_pre_per_hidden']").val($(Cur_Active_Adr_li).attr("val"));
        }
        else if ($("#" + LoadDiv.attr("id") + " .seconddiv").is("[contentchanged='true']")) {
            $("#" + LoadDiv.attr("id") + " .frstdiv").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " .per_div").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " input[key='dde_Personal_hidden']").val("20");
            $("#" + LoadDiv.attr("id") + " input[key='dde_pre_per_hidden']").val($(Cur_Active_Adr_li).attr("val"));
        }
        else if ($("#" + LoadDiv.attr("id") + " .per_div").is("[contentchanged='true']")) {
            $("#" + LoadDiv.attr("id") + " .frstdiv").attr("contentchanged", "true");
            $("#" + LoadDiv.attr("id") + " .seconddiv").attr("contentchanged", "true");
        }
        $("#" + LoadDiv.attr("id") + " .emp_Content").each(function () {
            if ($(this).attr("contentchanged") == "true" && IsOcc == 0) {
                IsOcc = 1;
                $("#" + LoadDiv.attr("id") + " .det-content2").attr("contentchanged", "true");
                $("#" + LoadDiv.attr("id") + " input[key='dde_Occ_hidden']").val("21");
            }
        });
        if ($("#" + val + " .present-aaddress").is("[contentchanged='true']")) {
            $("#" + val + " .present-aaddress").find("input[key=dde_pre_per_hidden]").val(0);
            if ($("#" + val + " .present-aaddress").find("input[key='dde_pre_IsSameAdr']").prop("checked") == true)
            {
                $("#" + val + " .premenent-aaddress").attr("contentchanged", "true");           
            }

        }



        if (GlobalXml[0].IsAll != "1") {
            fnDoValidation();


            if (FinalErrMsg != "") {
                fnShflAlert("error", FinalErrMsg);
                return;
            }
        }
    


        DocrefPk = $(Cur_Active_ref_li).attr("pk");
        DocPk = $(Cur_Active_Actor_li).attr("Pk");
        Actor = $(Cur_Active_Actor_li).attr("Actor");
        ActorNm = $(Cur_Active_Actor_li).children("span").text();
        CusFk = $(Cur_Active_Actor_li).attr("CusFk");
        CibilScr = $(Cur_Active_Actor_li).attr("CibilScr");

        LoadDiv.find("*").each(function () {
            if ($(this).is("[contentchanged]")) {
                if ($(this).attr("contentchanged") == "true") {
                    var closestobj = $(this).closest(".dde_cont");
                    $(closestobj).addClass("ContentChange");
                }
            }
        });

        if ($(LoadredDiv).attr("contentchanged") == "true") {
            $(LoadredDiv).addClass("ContentChange");
        }
        /*end*/
    
        $("#" + val + " .Kyc_div .rowGrid").each(function () {
            if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                $(this).find("li").find("input[colkey=dde_KycDocument]").val("");
                $(this).find("li").find("input[colkey=dde_KycPk]").val("");
                $(this).find("li").find("input[colkey=dde_KycRefno]").val("");
                $(this).find("li").find("input[colkey=dde_KycDate]").val("");
            }
        });

        $("#" + val + " .Kyc_Adddiv .rowGrid").each(function () {
            if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                $(this).find("li").find("input[colkey=dde_KycaddDocument]").val("");
                $(this).find("li").find("input[colkey=dde_KycaddPk]").val("");
                $(this).find("li").find("input[colkey=dde_KycaddRefno]").val("");
                $(this).find("li").find("input[colkey=dde_KycaddDate]").val("");
            }
        });
        debugger
        if (LoadDiv.find(".Kyc_Adddiv").attr("contentchanged") == "true")
        {
            LoadDiv.find(".dde_kyc_hidden").val("26");
        }
        else
        {
            LoadDiv.find(".dde_kyc_hidden").val("0");
        }
        if (LoadDiv.find(".Doc_div").attr("contentchanged") == "true")
        {
            LoadDiv.find(".dde_doc_hidden").val("27");
        }
        else
        {
            LoadDiv.find(".dde_doc_hidden").val("0");
        }
           
             
        if (LoadDiv.find(".Doc_Gendiv").attr("contentchanged") == "true")
        {
            LoadDiv.find(".dde_docgen_hidden").val("28");
        }
        else {
            LoadDiv.find(".dde_docgen_hidden").val("0");
        }

        if ($("#legal_hier").attr("contentchanged") == "true")
            LegalJson = fnGetGridVal("box-hier", "");
        else
            LegalJson = [];

        if (LoadDiv.find(".det-content6").attr("contentchanged") == "true")
            CreditJson = fnGetGridVal("credit_grid", LoadDiv.attr("id"));
        else
            CreditJson = [];

        if (LoadDiv.find(".det-content5").attr("contentchanged") == "true") {

            ObliJson = fnGetGridVal("obligation_grid", LoadDiv.attr("id"));
        }
        else
            ObliJson = [];

        if (LoadDiv.find(".det-content4").attr("contentchanged") == "true")
            AssetJson = fnGetGridVal("asset_grid", LoadDiv.attr("id"));
        else
            AssetJson = [];

        if (LoadDiv.find(".det-content3").attr("contentchanged") == "true")
            BankJson = fnGetGridVal("bank-div", LoadDiv.attr("id"));
        else
            BankJson = [];
   
        if (LoadDiv.find(".Kyc_div").attr("contentchanged") == "true")
            KycJson = fnGetGridVal("Kyc_div", LoadDiv.attr("id"));
        else
            KycJson = [];

        if (LoadDiv.find(".Kyc_Adddiv").attr("contentchanged") == "true")
            KycaddJson = fnGetGridVal("Kyc_Adddiv", LoadDiv.attr("id"));
        else
            KycaddJson = [];


        if (LoadDiv.find(".Doc_div").attr("contentchanged") == "true")
            Docjson = fnGetGridVal("Doc_div", LoadDiv.attr("id"));
        else
            Docjson = [];
        debugger
        if (LoadDiv.find(".Doc_Gendiv").attr("contentchanged") == "true")
            DocgenJson = fnGetGridVal("Doc_Gendiv", LoadDiv.attr("id"));
        else
            DocgenJson = [];
        
        AppJson = fnGetFormValsJson_IdVal("ContentChange", 1);

        if (GlobalXml[0].IsAll == "1") {
            fnShowSelValues(Evt, SelObj);
            return;
        }

        if (AppJson.length == 0 && LegalJson.length == 0 && CreditJson.length == 0 && ObliJson.length == 0 && AssetJson.length == 0 && BankJson.length == 0 && KycJson.length == 0 && KycaddJson.length ==0 && Docjson.length == 0 && DocgenJson.length == 0) {
            fnShowSelValues(Evt, SelObj);
            return;
        }
        var prdval = '';
        var prdval = $("#prddiv i").attr("pk");
        var builocpk = $("#dde_content_Pg").find("li.saleofz input[key=dde_builoc]").attr("value");
        debugger
        HdrJson = [{
            AppNo: GlobalXml[0].AppNo,
            AgtNm: GlobalXml[0].AgtNm,
            AgtFk: GlobalXml[0].AgtFk,
            PAppNo: $("#dde_PAppNo").val(),
            BuiLoc: $("#dde_builoc").val(),
            ActorNm: ActorNm,
            Actor: Actor,
            CusFk: CusFk,
            CibilScr: CibilScr,
            grpprdfk: prdval,
            saleofzpk: builocpk,
            Approverflag: Approver,
            Abt_us: $("#dde_Abtus").attr("selval"),
            kyc_hid :  LoadDiv.find(".dde_kyc_hidden").val(),
            doc_hid: LoadDiv.find(".dde_doc_hidden").val(),
            docgen_hid: LoadDiv.find(".dde_docgen_hidden").val()
        }];
        var objProcData =
               {
                   ProcedureName: "PrcShflDDEEntry",
                   Type: "SP",
                   Parameters:
                   [
                       "Save", JSON.stringify(DDEGlobal), JSON.stringify(LogJson), DocAppRef, DocPk, DocrefPk, 0,
                       JSON.stringify(HdrJson), JSON.stringify(AppJson), JSON.stringify(LegalJson), JSON.stringify(CreditJson),
                       JSON.stringify(ObliJson), JSON.stringify(AssetJson), JSON.stringify(BankJson), JSON.stringify(KycJson),
                        JSON.stringify(Docjson), JSON.stringify(DocgenJson), JSON.stringify(KycaddJson)
                   ]
               };
        fnCallLOSWebService("DDE_DATA_SAVE", objProcData, fnDDEResult, "MULTI", Evt);
    }



    $(function () {
        var isCO = window.DDE;
        isCO = isCO ? isCO : "";
        if (isCO == "") {
            fnCallScrnFn = function (FinalConfirm) {
                fnConfirmDDE(FinalConfirm)
            }
        }
    });


    function fnConfirmDDE(FinalConfirm)
    {
        IsFinalConfirm = FinalConfirm;
        var ErrMsg = "";
        var appname = "";
        if (IsFinalConfirm == "true") {
                for (i = 0; i < emptypedtls.length ; i++) {
                    if (emptypedtls[i].Emptyp == -1)
                    {
                        $("#dde_content").find(".div_content").each(function () {
                            if (emptypedtls[i].LapFk == $(this).attr("lapfk")) {
                if ($(this).find(".occupation-div").find("input[key='dde_occ_typeOfEmployment']").attr("selval") == -1) {
                    appname = $(this).attr("actornm");
                    ErrMsg = ErrMsg == "" ? "Type of Employment Required!!_" + appname : ErrMsg + "<br/> Type of Employment Required!!_" + appname;
                }
                        }
            });
                    }
                }
            if (ErrMsg != "") {
                fnShflAlert("error", ErrMsg);
                IsFinalConfirm = "";
                return false;
            }
        }
        var ErrMsg = "";
        if (IsFinalConfirm == "true") {    
            var divlength = $("#dde_content").find(".div_content").length;
            var val = "dde_whole_div_" + divlength;   
                for (j = 0; j < emptypedtls.length ; j++) {
                    if (emptypedtls[j].Kyccnt < 4) {
                        for (i = 0; i < divlength; i++) {
                            var c = 0;
                            if (emptypedtls[j].LapFk == $("#dde_whole_div_" + i).attr("lapfk")) {
                                $("#dde_whole_div_" + i + " .Kyc_div .rowGrid").each(function () {
                                    if ($(this).find("input[name=helptext]").val() == "") {
                                                    c++;
                                                }
                                });
                                if (c > 0) {
                                            var appname = $("#dde_whole_div_" + i).attr("actornm");
                                            ErrMsg = ErrMsg == "" ? "Fill all the Type of proof in Kyc Document details!!_" + $("#dde_whole_div_" + i).attr("actornm") : ErrMsg + "<br/> Fill all the Type of proof in Kyc Document details!!_" + $("#dde_whole_div_" + i).attr("actornm");
                                        }
                            }
                    }
                    }
                    else
                    {
                        for (i = 0; i < divlength; i++) {
                            var c = 0;
                            if ((emptypedtls[j].LapFk == $("#dde_whole_div_" + i).attr("lapfk")))
                                if (($("#dde_whole_div_" + i).attr("style") == "display: block") || ($("#dde_whole_div_" + i).attr("style") == undefined)) {
                                $("#dde_whole_div_" + i + " .Kyc_div .rowGrid").each(function () {
                                    if ($(this).find("input[name=helptext]").val() == "") {
                                        c++;
                                    }
                                });
                                if (c > 0) {
                                    var appname = $("#dde_whole_div_" + i).attr("actornm");
                                    ErrMsg = ErrMsg == "" ? "Fill all the Type of proof in Kyc Document details!!_" + $("#dde_whole_div_" + i).attr("actornm") : ErrMsg + "<br/> Fill all the Type of proof in Kyc Document details!!_" + $("#dde_whole_div_" + i).attr("actornm");
                                }
                            }
                        }
                    }
            }           
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    IsFinalConfirm = "";
                    return false;
                }
        }

        if (IsFinalConfirm == "false")
        {
            if (window.flag != undefined) {
                Approver = window.flag;
            }
        }
    
        fnDdeConfirmScreen("T", $(Cur_Active_Actor_li));
    }
    function fnClosekycrow(elem) {
        var divlen = $(".Kyc_div").find(".grid-controls.rowGrid.box-kyc-ul").length;
        if (divlen > 1)
            $(elem).closest("ul.grid-controls").remove();
        $(".Kyc_div").attr("contentchanged", true);
    }
    function fnCloseaddkycrow(elem) {
        var divlen = $(".Kyc_Adddiv").find(".grid-controls.rowGrid.box-kycadd-ul").length;
        $(elem).closest("ul.grid-controls").remove();
        var cnt = 1;
        debugger
        $(".Kyc_Adddiv .rowGrid").each(function ()
        {
            $(this).find("input[colkey=dde_KycaddProof]").val(cnt);
            $(this).find(".chckother").text("Other Documents_" + cnt);
            cnt++;
        })
        $(".Kyc_Adddiv").attr("contentchanged", true);
    }
    
    function fnCloseLegalHiger(elem) {
        var divlen = $(".box-div.box-hier").find(".grid-controls.rowGrid.box-hier-ul").length;
        if (divlen > 1)
            $(elem).closest("ul.grid-controls").remove();
        $("#legal_hier").attr("contentchanged", true);
    }
    /*change(muthu)2/1/16*/
    function fnCloseBank(elem) {
        $(elem).closest("ul.grid-controls.rowGrid.bank-div-ul").remove();
        var LoadDiv = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val"));
        LoadDiv.find(".dde_cont.det-content3.det_content").attr("contentchanged", "true");
        $("#bank_hid_id").attr("value", "22");
    }
    /*end*/
    function fnCloseAsset(elem) {
        $(elem).closest("ul.grid-controls.rowGrid.asset_grid_ul").remove();
        var LoadDiv = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val"));
        LoadDiv.find(".det-content4").attr("contentchanged", "true");
        var AstObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .asset_grid input[colkey='dde_Asset_amt1']");
        fnOnChangeCall("A", $(AstObj));
    }
    function fnCloseObligation(elem) {   
        $(elem).closest("ul.grid-controls.rowGrid.Ob_grid").remove();
        var LoadDiv = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val"));
        LoadDiv.find(".det-content5").attr("contentchanged", "true");
        var OblObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .obligation_grid input[colkey='dde_ob_emi1']");
        fnOnChangeCall("O", $(OblObj));

    }
    function fnCloseCreditcard(elem) {
        $(elem).closest("ul.grid-controls.rowGrid.credit_grid_ul").remove();
        var LoadDiv = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val"));
        LoadDiv.find(".det-content6").attr("contentchanged", "true");
        var CrdObj = $("#dde_whole_div_" + $(Cur_Active_Actor_li).attr("val") + " .credit_grid input[colkey='dde_cc_limit1']");
        fnOnChangeCall("C", $(CrdObj));
    }

    function fnpop() {
        $("#fold_nm").val(GlobalXml[0].LeadID);
        window.open("", "newWin", "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=20,top=20,width=600,height=600");
        PostForm.submit();
    }
    /* chenges 7/12/16(muthu)*/
    //function fnddegetprdicon() {
    //    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["SEL_PRD"] };
    //    fnCallLOSWebService("sel_icon", objProcData, fnDDEResult, "MULTI");
    //}

    //function fnonpopopen() {
    //    $("#ul_Prd").empty();
    //    fnddegetprdicon();
    //}
    //function fnonclick(elem) {
    //    if (flagvalue == "SET") {
    //        return false;
    //    }
    //    $("#prddiv").empty();
    //    $("#product_popupdiv").css("display", "none");
    //    $("#LeadPrdPk").attr("pcd", $(elem).children("i").attr("pcd"));
    //    $("#LeadPrdPk").val($(elem).children("i").attr("pk"));
    //    var prdicon = $(elem).html();
    //    $("#prddiv").append(prdicon);
    //    var prdval = $("#prddiv i").attr("pk");
    //    var HdrJson = [{ grpprdfk: prdval }];
    //    var objProcData = { ProcedureName: "PrcShflDDEEntry", Type: "SP", Parameters: ["PrdPkUpdate", JSON.stringify(DDEGlobal), "", "", "", "", "", JSON.stringify(HdrJson)] };
    //    fnCallLOSWebService("PrdUpdate", objProcData, fnDDEResult, "MULTI");
    //}
    /*end*/
    function SaleOfzclick(rowjson) {
        $("#dde_content_Pg").find("li.saleofz input[key=dde_builoc]").val(rowjson.Gblpk);
        $("#dde_content_Pg").find("li.saleofz input[key=dde_builoc]").attr("valtext", rowjson.Location);
        $(".grid-66.div-left.dde_cont.frstdiv").attr("contentchanged", "true");
    }
    /*Muthu(5/1/17)*/

    $(document).on("keydown", "#residingId",function (e) {
        var key = e.keyCode || e.which;
        var txtval = $("#residingId").val();
        if (key == 190) {
            if (txtval.indexOf(".") >= 0) {
                return false;
            }
            return true;
        }
    });
    /*end*/
