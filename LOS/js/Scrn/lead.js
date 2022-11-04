var LedGlobal = [{}];
var IsFinal = "";
var IsExs = false;

$(document).ready(function () {
   
    LedGlobal = [{}];
    LedGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    LedGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    LedGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    fnSelBranch();
    fnGetPrd();
    if (gConfig["gLdIns"] == 1)
    {
        fnmakereadonly();
    }
    else
    {
        $("input[key=lead_dob]").attr("data-beatpicker", "true");
        $("input[key=lead_dob]").addClass("datepicker");
        a();
        $("#mainLeadDiv .datepicker").each(function () {
            fnRestrictDate($(this));
        });
    }
    
    var param = JSON.stringify(GlobalBrnch);
    $("#agent-help").attr("Extraparam", param);
   

});


function fnSelBranch() {
    var PrcObj = { ProcedureName: "PrcShflLead", Type: "SP", Parameters: ["Sel-Branch"] };
    fnCallLOSWebService("Sel-Branch", PrcObj, fnLeadFinResult, "MULTI");
}
function fnmakereadonly()
{
    $("#mainLeadDiv").find("select[key=lead_incometyp]").attr("disabled", true);
    $("#mainLeadDiv").find("input[key=lead_mktval]").attr("readonly", "true");
    $("#mainLeadDiv").find("input[key=lead_loanamt]").attr("readonly", "true");
    $("#mainLeadDiv").find("input[key=lead_tenure]").attr("readonly", "true");
    $("#mainLeadDiv").find("input[key=lead_obl]").attr("readonly", "true");
    $("#mainLeadDiv").find("input[key=lead_cibil]").attr("readonly", "true");
    $("#mainLeadDiv").find("input[key=lead_prvloanRcard]").attr("disabled", true);
    $("#mainLeadDiv").find("input[key=lead_defloanRcard]").attr("disabled", true);
    $("#mainLeadDiv").find("input[key=lead_proof]").attr("disabled", true);
    $("#ROIID").attr("contentEditable", false);
    $("#lead_id").attr("readonly", "true");
    $(".bank").find("comp-help").attr("readonly", "true");
    $("input[key=lead_ApplicantNm]").attr("readonly", "true");
    $("input[key=lead_mobile]").attr("readonly", "true");
    $("input[key=lead_dob]").attr("readonly", "true");
}
function fnInsert() {
    debugger;
    var Action = ''
    var HdrJson = {};
    HdrJson = fnGetFormValsJson_IdVal("mainLeadDiv");
    if ($("#leadpk").val() == '') {
        Action = "Insert-Lead";
        IsExs = false;
    }
    else {
        Action = "UPDATE";
    }
    if (gConfig["gLdIns"] == 1) {
        if (Action == "Insert-Lead") {
            fnShflAlert("error", "Lead Cannot be created");
            return false;
        }
    }
    if (IsExs == true) {
        fnShflAlert("error", "Lead Processed to Next Stage, Unable to Edit!!");
        return false;
    }
    /*change(4/1/17)(MUTHU)*/
    var ErrMsg = fnChkMandatory("mainLeadDiv");
    if (ErrMsg != "") {
        fnShflAlert("error", ErrMsg);
        return false;
    }
    var dob = $("#dobid").val();
    if (dob == "") {
        fnShflAlert("error", "Date Of Birth Required!!");
        return false;
    }
    if ($("#mainLeadDiv").find("li.bank comp-help").find("input[name='helptext']").val() == "") {
        fnShflAlert("error", "Branch name required!!");
        return false;

    }
    if ($("#mainLeadDiv").find("li.bank comp-help").find("input[name='helptext']").val() != "") {
        if ($("#mainLeadDiv").find("li.bank comp-help").find("input[name='helptext']").val() != $("#mainLeadDiv").find("li.bank").find("input[key=lead_Branch]").attr("valtext")) {
            fnShflAlert("error", "Valid Branch name required!!");
            return false;
        }
    }
    if ($("#mainLeadDiv").find("li.branch comp-help").find("input[name='helptext']").val() == "") {
        fnShflAlert("error", "Agent name required!!");
        return false;

    }
    if( $('#mainLeadDiv li').find("select[key='ld_loanpurpose']").val()=="-1"){
        fnShflAlert("error", "Purpose of loan required!!");
        return false;

    }
    if ($("#mainLeadDiv").find("li.branch comp-help").find("input[name='helptext']").val() != "") {
        if ($("#mainLeadDiv").find("li.branch comp-help").find("input[name='helptext']").val() != $("#mainLeadDiv").find("li.branch").find("input[key=lead_Agent]").attr("valtext")) {
            fnShflAlert("error", "Valid Agent name required!!");
            return false;
        }
    }
    var value = $("#ROIID").text();
    if (value == "0" || value == "") {
        fnShflAlert("error", "ROI Required!!");
        return false;
    }
    var cibil = $("#cibilid").val();
    if (cibil == "") {
        fnShflAlert("error", "CIBIL Required!!");
        return false;
    }
     /*end*/
    
    var PrcObj = { ProcedureName: "PrcShflLead", Type: "SP", Parameters: [Action, JSON.stringify(LedGlobal), JSON.stringify(HdrJson)] };
    fnCallLOSWebService("Insert-Lead", PrcObj, fnLeadFinResult, "MULTI", Action);
}

function fnSetGlobalVersion(LeadObj) {
    if (LeadObj[0].lead_bt == "Y") {
        GlobalXml[0].CurVerFlowPk = gConfig["gBTFlow"];
    }
    else {
        if (LeadObj[0].lead_pni == "N")
            GlobalXml[0].CurVerFlowPk = gConfig["gPIFlow"];
        else
            GlobalXml[0].CurVerFlowPk = gConfig["gPNIFlow"];
    }
}

function fnLeadFinResult(ServiceFor, Obj, Param1, Param2) {

    if (!Obj.status) {
        fnShflAlert("error", Obj.error);
        return;
    }

    if (ServiceFor == "Insert-Lead") {
        //fnClearForm("mainLeadDiv");
        var LoadDash = 0;
        var Leadpk = JSON.parse(Obj.result);
        
        var GlobVerFk = GlobalXml[0].CurVerFlowPk;
        fnSetGlobalVersion(Leadpk);

        if (Param2 == "Insert-Lead") {
            GlobalXml[0].FwdDataPk = Leadpk[0].leadpk;
            fnGetLeadDtls(GlobalXml[0].CurVerFlowPk);
        }
        else {
            GlobalXml[0].FwdDataPk = $("#leadpk").val();
            debugger;
            if (IsExs == false && GlobVerFk != GlobalXml[0].CurVerFlowPk)
                fnGetLeadDtls(GlobalXml[0].CurVerFlowPk);
            else
                LoadDash = 1;
        }
        if (IsFinal != "" && LoadDash == 1) {
            fnCallFinalConfirmation(IsFinal);
            return;
        }
    }

    //if (ServiceFor == "Search-Lead") {
        
    //    var Leaddata = JSON.parse(Obj.result);
    //    var lilead = ''
    //    for (var j = 0 ; j < Leaddata.length; j++) {
    //        lilead += '<ul pcd="' + Leaddata[j].PCd + '" PrdPk="' + Leaddata[j].PrdPk + '" ledpk="' + Leaddata[j].LeadPk + '" onclick="fnselectLead(this);"><li>' + Leaddata[j].LeadNm + '<p><span class="bg">' + Leaddata[j].LeadId + '</span><span class="bg">' + Leaddata[j].BranchNm + '</span><span class="bg">' + Leaddata[j].ProductNm + '</span></p></li></ul>'
    //    }
    //    $(".popup.documents.attach-icon.doc-list-view").empty();
    //    $(".popup.documents.attach-icon.doc-list-view").append(lilead);
    //    $("#select-content").show();
    //}
    if (ServiceFor == "Sel-Branch") {
        //var brndata = JSON.parse(Obj.result_1);
        //  var branch = ''
        //var option = '<option value ="0" selected>Choose Your Location...</option>';
        // for (var i = 0; i < brndata.length; i++) {
        //      branch += '<li val ="' + brndata[i].BranchPk + '">' + brndata[i].BranchNm + '</li>';
        //}
        //  $("#Brn").append(branch);

        //    var Agtdata = JSON.parse(Obj.result_2);
        //   var Agent = ''
        //var option = '<option value ="0" selected>Choose Your Location...</option>';
        //      for (var i = 0; i < Agtdata.length; i++) {
        //   Agent += '<li val ="' + Agtdata[i].AgtPk + '">' + Agtdata[i].firstnm + '' + Agtdata[i].midnm + '' + Agtdata[i].lname + '</li>';
        // }
        //   $("#Agt").append(Agent);

        var leadno = JSON.parse(Obj.result_3);
         //$("#leadno").text(leadno[0].Leadid);
         $("input[key='lead_id']").val(leadno[0].Leadid);

        var PrdPk = JSON.parse(Obj.result_4);
        $("#prddiv i").attr("pk", PrdPk[0].productpk);
        $("#LeadPrdPk").val(PrdPk[0].productpk);
        $("#LeadPrdPk").attr("pcd", PrdPk[0].PCd);
    }
    if (ServiceFor == "S") {
        debugger;
        var LeadInfo = JSON.parse(Obj.result);
        if (LeadInfo.length > 0)
            fnSetValues("mainLeadDiv", LeadInfo);

        IsExs = LeadInfo[0].IsExists;
        $("#mainLeadDiv").find("li.bank comp-help").find("input[name='helptext']").val(LeadInfo[0].BranchNm);
        $("#mainLeadDiv").find("li.bank input[key=lead_Branch]").attr("valtext", LeadInfo[0].BranchNm);
        $("#mainLeadDiv").find("li.branch comp-help").find("input[name='helptext']").val(LeadInfo[0].AgentName);
        $("#mainLeadDiv").find("li.branch input[key=lead_Agent]").attr("valtext", LeadInfo[0].AgentName);
        // changed by nirupama 01/31/2017
        /*  if (LeadInfo[0].lead_pni == "Y") {
            $("#chk_Prop").prop("checked", true);
        }
        else
            $("#chk_Prop").prop("checked", false);

        if (LeadInfo[0].lead_bt == "Y") {
            $("#chk_topup").prop("checked", true);
        }
        else
            $("#chk_topup").prop("checked", false); */
        //
        if (LeadInfo[0].lead_pni == "N" && LeadInfo[0].lead_bt == "N")
        {
            $('select[key="ld_loanpurpose"]').val("0").change();
        }
        else if (LeadInfo[0].lead_pni == "N" && LeadInfo[0].lead_bt == "Y")
        {
            $('select[key="ld_loanpurpose"]').val("1").change();
        }
        else if (LeadInfo[0].lead_pni == "Y" && LeadInfo[0].lead_bt == "N")
        {
            $('select[key="ld_loanpurpose"]').val("2").change();
        }

        fnSetGlobalVersion(LeadInfo);

        $("#select-content").hide();
    }
    if (ServiceFor == "sel_prd") {

        var PrdData = JSON.parse(Obj.result);
        var clsNm = ''
        var prd = ''

        for (var i = 0; i < PrdData.length; i++) {
            var liActive = "";
            if (PrdData[i].ProductCode == $("#LeadPrdPk").attr("pcd")) {
                liActive = 'class="active"'
            }
            if (PrdData[i].ProductCode == "HL") {
                clsNm = "icon-home-loan"
            }
            else if (PrdData[i].ProductCode == "LAP")
                clsNm = "icon-lap"
            else if (PrdData[i].ProductCode == "PL")
                clsNm = "icon-plot-loan"

            prd += '<li ' + liActive + ' cursor="pointer" ><i pcd= "' + PrdData[i].ProductCode + '" pk = "' + PrdData[i].productpk + '" class="' + clsNm + '"></i><p>' + PrdData[i].productnm + '</p></li>'
        }
        $("#ul_Prd").append(prd);
    }
}

function Brnchclick(rowjson) {    
    $("#mainLeadDiv").find("li.bank input[key=lead_Branch]").val(rowjson.BranchPk);
    $("#mainLeadDiv").find("li.bank input[key=lead_Branch]").attr("valtext", rowjson.Location);
}
function Agentclick(rowjson) {
    $("#mainLeadDiv").find("li.branch input[key=lead_Agent]").val(rowjson.Agtpk);
    $("#mainLeadDiv").find("li.branch input[key=lead_Agent]").attr("valtext", rowjson.AgentName);
}
function fnCallScrnFn(FinalConfirm) {
    IsFinal = "false";
    fnInsert();
}
//function fnselectLead(elem) {
//    var leadPk = $(elem).attr("ledpk");
//    $("#LeadPrdPk").val($(elem).attr("PrdPk"));
//    $("#LeadPrdPk").attr("pcd", $(elem).attr("pcd"));

//    var div_content = $("#ul_Prd li i[pk='" + $(elem).attr("PrdPk") + "']").parent();
//    $("#prddiv").empty();
//    var prdicon = $(div_content).html();
//    $("#prddiv").append(prdicon);

//    var PrcObj = { ProcedureName: "PrcShflLead", Type: "SP", Parameters: ["S", "", "", leadPk] };
//    fnCallLOSWebService("S", PrcObj, fnLeadFinResult, "MULTI");
//}
$("#select-content .icon-close").click(function () {
    $("#select-content").hide();
});
$("#product-content .icon-close").click(function () {
    $("#product-content").hide();
});

function fnGetPrd() {
    var PrcObj = { ProcedureName: "PrcShflLead", Type: "SP", Parameters: ["sel_prd"] };
    fnCallLOSWebService("sel_prd", PrcObj, fnLeadFinResult, "MULTI");
}
function fnonpopopen() {
    $("#ul_Prd").empty();
    fnGetPrd();
}
function fnonclick(elem) {
    $("#prddiv").empty();
    $("#product_popupdiv").css("display", "none");
    $("#LeadPrdPk").attr("pcd", $(elem).children("i").attr("pcd"));
    $("#LeadPrdPk").val($(elem).children("i").attr("pk"));
    var prdicon = $(elem).html();
    $("#prddiv").append(prdicon);
}
//$("#chk_Prop").click()
//{
//    
//    if ($("#chk_Prop").prop("checked", true)) {

//        $("#chk_topup").prop("checked", false);
//        $("#chk_topup").attr("disabled", true);
//    }
//    else if ($("#chk_Prop").prop("checked", false)) {
//        $("#chk_Prop").prop("checked", false);
//        $("#chk_topup").attr("disabled", false);
//    }
//}
function fnchkprop() {   
    if ($("#chk_Prop").prop("checked") == true) {
        $("#chk_topup").prop("checked", false);
        $("#chk_topup").attr("disabled", true);
    }
    else if ($("#chk_Prop").prop("checked") == false) {
        //$("#chk_topup").prop("checked", false);
        $("#chk_topup").attr("disabled", false);
    }

}
function fnchktopup() {
    if ($("#chk_topup").prop("checked") == true) {
        $("#chk_Prop").prop("checked", false);
        $("#chk_Prop").attr("disabled", true);
    }
    else if ($("#chk_topup").prop("checked") == false) {
        //$("#chk_topup").prop("checked", false);
        $("#chk_Prop").attr("disabled", false);
    }

}
function fnLedSearch() {
    debugger;
    var param = JSON.stringify(GlobalBrnch);
    $("#lead_help").attr("extraparam", param);
    $("#lead_help .enter-icon").trigger("click");
}

function Searchclick(rowdata) {
    $("#prddiv").find("i").attr("class", "");
    if (rowdata.hdnPCd == 'HL') {
        $("#prddiv i").attr("class", "icon-home-loan");
        $("#prddiv p").text("Home Loan");
    } else if (rowdata.hdnPCd == 'LAP') {
        $("#prddiv i").attr("class", "icon-lap");
        $("#prddiv p").text("Loan Against Property");
    } else if (rowdata.hdnPCd == 'PL') {
        $("#prddiv i").attr("class", "icon-plot-loan");
        $("#prddiv p").text("Plot Loan");
    }
    var PrcObj = { ProcedureName: "PrcShflLead", Type: "SP", Parameters: ["S", "", "", rowdata.hdnLeadPk] };
    fnCallLOSWebService("S", PrcObj, fnLeadFinResult, "MULTI");
}

$(document).on("keydown", "#cibilid", function (e) {
    debugger;
    var key = e.keyCode || e.which;
    var val = $("#cibilid").val();
    if (key == 109) {
        if (val.indexOf("-") >= 0) {
            return false;
        }
        return true;
    }
});
