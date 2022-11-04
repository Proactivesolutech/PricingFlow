var RCUGlobal = [{}];
var Action = '';
var IsFinalConfirm = "";
var IsQcScreen = "0";
var globalvar = -1;
$(document).ready(function () {
    RCUGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    RCUGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    RCUGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    RCUGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    RCUGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    RCUGlobal[0].LeadId = GlobalXml[0].LeadID;
    RCUGlobal[0].AppNo = GlobalXml[0].AppNo;
    RCUGlobal[0].BranchNm = GlobalXml[0].Branch;
    RCUGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    RCUGlobal[0].Approver = '';
    IsQcScreen = $("#hiddenclass").val();
    fnRCULoadLeadDetails();

    $("#rcu_leadid").text(GlobalXml[0].LeadID);
    $("#rcu_applicant").text(GlobalXml[0].LeadNm);
    $("#rcu_appno").text(GlobalXml[0].AppNo);
    $("#rcu_brnch").text(GlobalXml[0].Branch);

    //fnDrawDatePicker();

});

function fnRCULoadLeadDetails() {
    var objProcData = { ProcedureName: "PrcShflRCU", Type: "SP", Parameters: ['Load', JSON.stringify(RCUGlobal), "", IsQcScreen] }
    fnCallLOSWebService("RCU_DTLS", objProcData, fnRCUResult, "MULTI");
}
function fnRCUResult(ServDesc, Obj, Param1, Param2) {
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServDesc == "Save") {
        if (IsFinalConfirm != "") {
        
            fnCallFinalConfirmation(IsFinalConfirm);
        }
    }
    if (ServDesc == "RCU_DTLS") {
        var DocInfo = JSON.parse(Obj.result_1);
        var ulhtml = '';
        if (DocInfo[0] && DocInfo[0] != null) {

            if (DocInfo.length > 0) {

                for (var doc = 0; doc < DocInfo.length; doc++) {
                    var ScreenClass = "";
                    var SampleClass = "";
                    var StatusCls = "icon-positive";
                    var Bg = "bg1";

                    if (DocInfo[doc].rcu_screened == 1)
                        ScreenClass = "active";

                    if (DocInfo[doc].rcu_sample == 1)
                        SampleClass = "active";

                    if (DocInfo[doc].rcu_status == 1) {
                        StatusCls = "icon-negative";
                        Bg = "bg2";
                    }

                    ulhtml =
                        $('<ul class="rowGrid">' + '<li>' + DocInfo[doc].DocName +
                              '<p><span class="bg">' + DocInfo[doc].Applicant + '</span> <span class="bg">' + DocInfo[doc].Catogory + '</span> <span class="bg">' + DocInfo[doc].SubCatogory + '</span></p>' +
                              ' </li>' +
                              '<li onclick="fnaddscreen(this)" val="' + DocInfo[doc].rcu_screened + '" class="' + ScreenClass + ' read-only icon-view-click ">' +
                              '<p><i class="icon-view"></i>' +
                              '</p>' +
                              '<input name="text" colkey="rcu_screened" type="hidden" value="' + DocInfo[doc].rcu_screened + '">' +
                              '<label>Screened</label>' +
                              '</li>' +
                              '<li onclick="fnaddsample(this)"; val="' + DocInfo[doc].rcu_sample + '" class="' + SampleClass + ' read-only icon-test-tube-view ">' +
                              '<p><i class="icon-test-tube findsample"></i>' +
                              '</p>' +
                              '<input name="text" colkey="rcu_sample" type="hidden" value="' + DocInfo[doc].rcu_sample + '">' +
                              '<label>Sampled</label>' +
                              '</li>' +
                              '<li class="status"><div class="bg ' + Bg + ' changediv"><i class="' + StatusCls + '" onclick="fnReprtSts(this)";></i>' +
                               '<input name="text" colkey="rcu_status" type="hidden" value="' + DocInfo[doc].rcu_status + '">' +
                              '</div></li>' +
                              '<li class="read-only">' +
                              '<label>Comments</label>' +
                              '<input type="text" name="text" value="' + DocInfo[doc].rcu_cmnts + '" colkey="rcu_cmnts">' +
                              '</li>' +
                              '<li style="display:none;" class="width-52">' +
                              '<input name="text" value="' + DocInfo[doc].Pk + '" colkey="rcu_docpk">' +
                              '</li>' +
                              '<li style="display:none;" class="width-52">' +
                              '<input name="text" value="' + DocInfo[doc].rcu_lapFk + '" colkey="rcu_lapFk">' +
                              '</li>' +
                              '<li style="display:none;" class="width-52">' +
                              '<input name="text" value="' + DocInfo[doc].rcu_pk + '" colkey="rcu_pk">' +
                              '</li>' +
                              '</ul>'
                        );
                    $("#appendul").append(ulhtml);
                }
            }
        }
        debugger;
        var gender = '';
        var actor = '';
        var Info = JSON.parse(Obj.result_2);
        $("#rcu_tenure").text(Info[0].Tenure);
        $(".Product_Icon").find("i").removeClass();
        $(".Product_Icon").find("i").addClass(Info[0].hdnPrdIcon);
        $(".Product_Icon").find("p").text(Info[0].hdnPrdNm);
        $("#rcu_amnt").text(FormatCurrency(Info[0].LoanAmount));

        var append = '';
        if (Info.length > 0) {
            for (var i = 0; i < Info.length; i++) {
                if (Info[i].Gender == 0) {
                    gender = "Male";
                }
                else {
                    gender = "Female";
                }

                if (Info[i].Actor == 0) {
                    actor = "Applicant";
                }
                else if (Info[i].Actor == 1) {
                    actor = "Co-Applicant";
                }
                else {
                    actor = "Gurantor";
                }


                append =
                    $('<div class="box-div rcu-new-list"  pk="' + Info[i].Lapfk + '" contentchanged id="rucActor_' + i + '">' +
                    '<div class="div-left grid-33">' +
             ' <ul class="form-controls">' +
              '  <li class="width-10 read-only">' +
                  '<label>' + actor + " " + 'Name</label>' +
                 '<p name="content">' + Info[i].FirstName + '</p>' +
            '  </li>' +
            '  <li class="width-24 read-only">' +
                  '<label>Gender</label>' +
                 '<p name="content">' + gender + '</p>' +
            '  </li>' +
             ' <li class="width-24 read-only">' +
                  '<label>DOB</label>' +
                 '<p name="content">' + Info[i].DOB + '</p>' +
              '</li>' +
              '</ul>' +
               '<ul class="form-controls rowGrid">' +
               '<li onclick="fnaddscreen(this)" val="0"  class="read-only icon-view-click width-10">' +
                         '<p><i class="icon-view"></i>' +
                         '</p>' +
                         '<input name="text" colkey="rcu_screened" type="hidden">' +
                         '<label>Screened</label>' +
                     '</li>' +
                          '<li onclick="fnaddsample(this)"; val="0" class="read-only icon-test-tube-view width-24">' +
                          '<p><i class="icon-test-tube findsample"></i>' +
                          '</p>' +
                          '<input name="text" colkey="rcu_sample" type="hidden" >' +
                          '<label>Sampled</label>' +
                     '</li>' +
                     ' <li class="status width-24"><div class="bg bg1"><i class="icon-positive" onclick="fnReprtSts(this)"></i>' +
                        ' <input name="text" colkey="rcu_status" type="hidden" value=0>' +
                          '</div></li>' +
                       '<div class="clear"></div>' +
                      '<li class="width-10 read-only rcudate">' +
                          '<label>Report Date</label>' +
                           ' <input name="text" colkey="rcu_lapFk" type="hidden" value="' + Info[i].Lapfk + '">' +
                         ' <input type="text" name="text" colkey="rcu_date" data-beatpicker="true" id="rcu_rpt_dt" />' +
                      '</li>' +                      
                      '<li class="width-24 read-only">' +
                         ' <label>Reference Id</label>' +
                          '<input type="text" name="text" colkey="rcu_refId" id="rcu_refId" />' +
                     ' </li>' +
                       '<li class="width-24 read-only samplerclass"  style="display:none;" >' +
                         ' <label>Name Of the Sampler</label>' +
                          '<input type="text" name="text" colkey="rcu_nameofsup" restrict="alphaonly" id="rcu_nameofsup" />' +
                     ' </li>' +
                        '<div class="clear"></div>' +
                     ' <li class="read-only rcu-comment">' +
                         ' <label>Comments</label>' +
                           '<textarea name="text" colkey="rcu_cmnts" id="rcu_cmnts"></textarea>' +
                           ' <input name="text" id="rcupk" colkey="rcu_pk" type="hidden" >' +
                     ' </li>' +
                 ' </ul>' +
                 '</div>' +
                 '<div class="grid-66 rcu-address div-right"></div>' +
                 '<div class="clear"></div>' +

         ' </div>');
                $("#append").append(append);
                globalvar = i;
            }
            
        }
        a();

        var appappend = '';
        var appInfo = JSON.parse(Obj.result_3);
        var addressname = '';
        if (appInfo.length > 0) {
            debugger;
            for (var j = 0; j < Info.length; j++) {
                var apppk = $("#rucActor_" + j).attr("pk");

                for (var i = 0; i < appInfo.length; i++) {
                    var addresstyp = appInfo[i].Addtyp;
                    if (addresstyp == 0) {
                        addressname = 'Residential Address';
                    }
                    else if (addresstyp == 3) {
                        addressname = "Office Address";
                    }
                    else {
                        addressname = "Business Address";
                    }
                    if (apppk == appInfo[i].lap) {
                        appappend =
                              $(
                             ' <ul class="form-controls div-left grid-50">' +
                      '<h2>' + addressname + '</h2>' +
                  '  <li class="width-8 read-only">' +
                      '<label>Door No</label>' +
                     '<p name="content">' + appInfo[i].doorno + '</p>' +
                '  </li>' +
                '  <li class="width-21 read-only">' +
                      '<label>Building</label>' +
                     '<p name="content">' + appInfo[i].build + '</p>' +
                '  </li>' +
                 ' <li class="width-8 read-only">' +
                      '<label>Plot No</label>' +
                     '<p name="content">' + appInfo[i].Plot + '</p>' +
                  '</li>' +
                    ' <li class="width-21 read-only">' +
                      '<label>Street</label>' +
                     '<p name="content">' + appInfo[i].Street + '</p>' +
                  '</li>' +
                    ' <li class="width-98p read-only">' +
                      '<label>Land Mark</label>' +
                     '<p name="content">' + appInfo[i].Land + '</p>' +
                  '</li>' +
                    ' <li class="width-98p read-only">' +
                      '<label>Town/Village/City</label>' +
                     '<p name="content">' + appInfo[i].Area + '</p>' +
                  '</li>' +
                    ' <li class="width-98p read-only">' +
                      '<label>District</label>' +
                     '<p name="content">' + appInfo[i].District + '</p>' +
                  '</li>' +
                    ' <li class="width-21 read-only">' +
                      '<label>State</label>' +
                     '<p name="content">' + appInfo[i].State + '</p>' +
                    ' <li class="width-6 read-only">' +
                      '<label>Pin</label>' +
                     '<p name="content">' + appInfo[i].Pin + '</p>' +
                  '</li>' +
                  '</ul>'
                               );
                        $("#rucActor_" + j).find(".rcu-address").append(appappend);
                    }

                }
            }
        }
        debugger;
        var object = JSON.parse(Obj.result_4);
        fnSetGridVal("rcugrid", "whole_div", object);
        if (object.length > 0) {
            for (var j = 0; j < Info.length; j++) {
                var statuspk = $("#rucActor_" + j).find("#rcupk").val();
                for (var i = 0; i < object.length; i++) {

                    if (object[i].rcu_status == 2) {
                        StatusCls = "icon-no-status";
                        Bg = "bg bg7";
                    }
                    if (object[i].rcu_status == 1) {
                        StatusCls = "icon-negative";
                        Bg = "bg bg2";
                    }
                    if (object[i].rcu_status == 0) {
                        StatusCls = "icon-positive";
                        Bg = "bg bg1";
                    }
                    if (object[i].rcu_screened == 1) {
                        screenActive = "active";

                    }
                    if (object[i].rcu_sample == 1) {
                        sampleActive = "active";

                    }
                    if (object[i].rcu_screened == 0) {
                        screenActive = "";

                    }
                    if (object[i].rcu_sample == 0) {
                        sampleActive = "";
                    }
                    if (object[i].rcu_pk == statuspk) {
                        $("#rucActor_" + j).find("li.status").children("div").removeClass();
                        $("#rucActor_" + j).find("li.status").children("div").addClass(Bg);
                        $("#rucActor_" + j).find("li.status").find("i").removeClass();
                        $("#rucActor_" + j).find("li.status").find("i").addClass(StatusCls);
                        $("#rucActor_" + j).find("li.icon-view-click").addClass(screenActive);
                        $("#rucActor_" + j).find("li.icon-test-tube-view").addClass(sampleActive);
                        if (sampleActive == "active") {
                            $("#rucActor_" + j).find("li.samplerclass").attr("style", "display:inline-block;");
                            $("#rucActor_" + j).find("li.samplerclass").find("input").addClass("mandatory");
                            $("#rucActor_" + j).find("li.icon-test-tube-view").attr("val", 1);
                        }
                    }
                }
            }
        }
        var loanInfo = JSON.parse(Obj.result_6);
        if (loanInfo.length > 0) {
            $("#rcu_amnt").text(FormatCurrency(loanInfo[0].LOAN_AMT));
        }
        var date = JSON.parse(Obj.result_7);
        if (date.length > 0) {
            $("#Rcudate").val(date[0].Dt);
        }
    }
}
function fnaddsample(SelObj) {
    if ($(SelObj).attr("val") == "0") {
        $(SelObj).attr("val", "1");
        $(SelObj).addClass("active");
        $(SelObj).siblings("li.samplerclass").attr("style", "display:inline-block;");
        $(SelObj).siblings("li.samplerclass").find("input").val("");
        $(SelObj).siblings("li.samplerclass").find("input").addClass("mandatory");
    }
    else {
        $(SelObj).attr("val", "0");
        $(SelObj).removeClass("active");

        $(SelObj).siblings("li.samplerclass").attr("style", "display:none;");
        $(SelObj).siblings("li.samplerclass").find("input").val("");
        $(SelObj).siblings("li.samplerclass").find("input").removeClass();
    }
    $(SelObj).children("input").val($(SelObj).attr("val"));

}
function fnaddscreen(SelObj) {
    if ($(SelObj).attr("val") == 0) {
        $(SelObj).attr("val", 1);
        $(SelObj).addClass("active");

    }
    else {
        $(SelObj).attr("val", 0);
        $(SelObj).removeClass("active");

    }
    $(SelObj).children("input").val($(SelObj).attr("val"));
}
function fnReprtSts(elem) {
    var cls = $(elem).attr("class");
    if (cls == "icon-positive") {
        $(elem).attr("class", "icon-negative");
        $(elem).siblings("input").val(1);
        $(elem).parent("div").removeClass("bg1");
        $(elem).parent("div").addClass("bg2");
    }
    else if (cls == "icon-negative") {
        $(elem).attr("class", "icon-no-status");
        $(elem).siblings("input").val(2);
        $(elem).parent("div").removeClass("bg2");
        $(elem).parent("div").addClass("bg7");
    }
    else if (cls == "icon-no-status") {
        $(elem).attr("class", "icon-positive");
        $(elem).siblings("input").val(0);
        $(elem).parent("div").removeClass("bg7");
        $(elem).parent("div").addClass("bg1");


    }
}
function fnrcuconfirmscreen() {
    debugger;
    var hh = globalvar;
    var ErrMsg = "";
    if (globalvar > -1) {
        for (i = 0; i <= globalvar; i++) {
            $("#rucActor_" + i).each(function () {
                if ($("#rucActor_" + i).find("li.samplerclass").find("input").attr("class") == "mandatory") {
                    if ($("#rucActor_" + i).find("li.samplerclass").find("input").val() == "") {
                        ErrMsg = ErrMsg == "" ? "Name of Sampler required!!" : ErrMsg + "<br/>Name of Sampler required!!";
                        return false;

                    }
                }
            });
        }
                if (ErrMsg != "") {
                    fnShflAlert("error", ErrMsg);
                    return false;
                }      
    }
    if (globalvar > -1) {
        for (i = 0; i <= globalvar; i++) {
            $("#rucActor_" + i).each(function () {
                if ($("#rucActor_" + i).find("li.rcudate").find("input[colkey=rcu_date]").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Report Date required!!" : ErrMsg + "<br/>Report Date required!!";
                        return false;
                    }
            });
        }
        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }

    }
    if (globalvar > -1) {
        for (i = 0; i <= globalvar; i++) {
            $("#rucActor_" + i).each(function () {
                var dateval = $("#rucActor_" + i).find("li.rcudate").find("input[colkey=rcu_date]").val();
                var date = dateval.substring(0, 2);
                var month = dateval.substring(3, 5);
                var year = dateval.substring(6, 10);
                var dateToCompare = new Date(year, month - 1, date);
                var currentDate = new Date();
                if (dateval != '') {
                    if (dateToCompare > currentDate) {
                        ErrMsg = ErrMsg == "" ? "Report Date Should not be greater than Current Date!!!!" : ErrMsg + "<br/>Report Date Should not be greater than Current Date!!!!";
                        return false;
                    }
                }
            });
        }
        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }

    }
    
    debugger;
    var AppJson = [];

    AppJson = fnGetGridVal("rcugrid", "")
    RCUGlobal[0].Rcu_date = $("#Rcudate").val();
    var objProcData =
           {
               ProcedureName: "PrcShflRCU",
               Type: "SP",
               Parameters:
               [
                   "Save", JSON.stringify(RCUGlobal), JSON.stringify(AppJson), IsQcScreen
               ]
           };
    fnCallLOSWebService("Save", objProcData, fnRCUResult, "MULTI");
}

function fnCallScrnFn(IsFinal) {
    debugger
    var cnt = 0;
    IsFinalConfirm = IsFinal;
    if (globalvar > -1) {
        for (i = 0; i <= globalvar; i++) {
            $("#rucActor_" + i).each(function () {           
                if (($("#rucActor_" + i).find("input[colkey=rcu_status]").val() > 0) ) {
                    cnt += 1;
                }
            });
        }
    }
    if (IsFinalConfirm == "true")
    {
        if(cnt > 0)
        {
            GlobalXml[0].TgtPageID = gAutoDec["RCUA"];
        }
        else
        {
            GlobalXml[0].TgtPageID=gAutoDec["DO"];
        }  
    }
    if (IsFinalConfirm == "true")
    {
        if (window.rcuflag != undefined) {
            RCUGlobal[0].Approver = 'A';
        }
    }
    if (IsFinalConfirm == "true") {
        debugger;
        var filedate = $("#Rcudate").val();
        if (filedate == "") {
        fnShflAlert("error", "RCU Inititiation Date Required !!");
        return false;
        }        
        var date4 = filedate.substring(0, 2);
        var month4 = filedate.substring(3, 5);
        var year4 = filedate.substring(6, 10);
        var filerec_date = new Date(year4, month4 - 1, date4);
        var currentDate2 = new Date();
        if (filerec_date > currentDate2) {
            fnShflAlert("error", "RCU Inititiation Date Should not be greater than Current Date!!");
            return false;
        }
    }

    fnrcuconfirmscreen();
}