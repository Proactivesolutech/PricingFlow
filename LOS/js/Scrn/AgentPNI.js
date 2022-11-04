var Action = "";
var MaxAdrTab = 0;
var CurSel_div;
var IsFinalConfirm = "";
var Agt_LnAmt = 0;
var count = 1;
var IsAgtTchTrig = false;

$(document).ready(function () {
    AgtGlobal = [{}];
    AgtGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    AgtGlobal[0].AgtNm = GlobalXml[0].AgtNm;
    AgtGlobal[0].AppNo = GlobalXml[0].AppNo;
    AgtGlobal[0].FwdDataPk = GlobalXml[0].FwdDataPk;
    AgtGlobal[0].LeadID = GlobalXml[0].LeadID;
    AgtGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    AgtGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    AgtGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    AgtGlobal[0].BrnchFk = GlobalXml[0].BrnchFk;
    AgtGlobal[0].BranchNm = GlobalXml[0].Branch;
    AgtGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    AgtGlobal[0].AppNo = GlobalXml[0].AppNo;
    fnsellead();
    //$("#agt_Info").find("*").each(function () {
    //    if ($(this).is("[key]")) {
    //        $(this).addClass("mandatory");
    //    }
    //});
    CurSel_div = $("#agt_addr_content_0");
    fnAgtSel();
    var param1 = JSON.stringify(GlobalBrnch);
    $("#legalverid_help").attr("Extraparam", param1);
    $("#techverid_0_help").attr("Extraparam", param1);

/*Changes By kani on 29/12/2016*/
  /*  $("#chk_Prop").attr("checked", false);
    $("#chk_Prop").click(function () {
        fnshoworHideDatas();
    });

    $(document).on("click", "#ul_coapp li", function () {
        AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id"));
        var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["INSERT_ADR", JSON.stringify(AgtGlobal), "", "", JSON.stringify(AdrJson)] };
        fnCallLOSWebService("DATA_SAVE_ADR", objProcData, fnAgtTrig, "MULTI", $(this));
    });*/
    });
/*function fnshoworHideDatas(Action) {
    var chk = $("#chk_Prop").is(":checked");
    if (Action != "S") {
        fnClearForm("Prp_AdrsDiv");
    }

    if (chk) {
        $("#legal_ver").hide();
        $("#tech_ver").hide();
        //$("#fldofz").hide();
        $("#Prp_AdrsDiv").hide();
    }
    else {
        $("#legal_ver").show();
        $("#tech_ver").show();
        $("#fldofz").show();
        $("#Prp_AdrsDiv").show();
    }
}*/
/*Changes By kani on 29/12/2016*/
function fnloadScreen() {
    
    var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["SELECT", JSON.stringify(AgtGlobal)] };
    fnCallLOSWebService("DATA_TBL", objProcData, fnAgtTrig, "MULTI", "");
}
function Pinclick(rowjson, elem) {
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}

function fnAgentcrdPNIConfirmScreenFinal() {
    /*var HdrJson = fngetpropdet("maindiv", 0, count);
    LoadDiv = $("#fulagtdiv").attr("id");
    ErrMsg = fnChkMandatory(LoadDiv);
    if (ErrMsg != "") {
        fnShflAlert("error", ErrMsg);
        return false;
    }*/
    /*Changes By kani on 29/12/2016*/
    
    var ErrMsg = '';
    var FinErrMsg = '';
    for (var n = 0; n < count; n++) {
        var dvid = "";
        dvid = "maindiv_" + n;
        ErrMsg = '';
        Error = fnconstChkMandatory(dvid);
        flatError = fnflatValidation("#" + dvid + " .valdflat");
        plotError = fnplotValidation("#" + dvid + " .valdplot");
        buildError = fnbuidValidation("#" + dvid + " .valdbuild");
        streetError = fnstreetValidation("#" + dvid + " .valdstreet");
        landmarkError = fnlandmarkValidation("#" + dvid + " .valdLM");
        if (Error != "") {
            ErrMsg = ErrMsg == "" ? Error : ErrMsg + Error;
        }
        if (flatError != "") {
            ErrMsg = ErrMsg == "" ? flatError : ErrMsg + "<br/>" + flatError;
        }
        if (plotError != "") {
            ErrMsg = ErrMsg == "" ? plotError : ErrMsg + "<br/>" + plotError;
        }
        if (buildError != "") {
            ErrMsg = ErrMsg == "" ? buildError : ErrMsg + "<br/>" + buildError;
        }
        if (streetError != "") {
            ErrMsg = ErrMsg == "" ? streetError : ErrMsg + "<br/>" + streetError;
        }
        if (landmarkError != "") {
            ErrMsg = ErrMsg == "" ? landmarkError : ErrMsg + "<br/>" + landmarkError;
        }
        if ($("#" + dvid).find("comp-help").find("input[name=helptext]").val() == "") {
            ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "<br/>Pincode Required!!";
        }
        if ($("#" + dvid).find("comp-help").find("input[name=helptext]").val() != "") {
            if ($("#" + dvid).find("comp-help").find("input[name=helptext]").val() != $("#" + dvid).find("input[key=agt_pin]").val()) {
                ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
            }
        }
        if (ErrMsg != "") {
            FinErrMsg = FinErrMsg == "" ? "<b>Property" + (n + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Property" + (n + 1) + "</b><br/>" + ErrMsg;
        }
    }
    if (FinErrMsg != "") {
        fnShflAlert("error", FinErrMsg);
        return false;
    }
    var HdrJson = fngetpropdet("maindiv", 0, count);
    /*Changes By kani on 29/12/2016*/    
    var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["INSERT", JSON.stringify(AgtGlobal), JSON.stringify(HdrJson), ""] };
    fnCallLOSWebService("DATA_SAVE", objProcData, fnAgtTrig, "MULTI", "");
}


function fnAgtTrig(ServDesc, Obj, Param1, Param2) {
    
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServDesc == "DATA_TBL") {
        
        $("#agt_Info").attr("pk", "");
        var Adrsdata = JSON.parse(Obj.result_1);
        var IsPrpNotIden = JSON.parse(Obj.result_2)[0].PrpIden;
        Action = JSON.parse(Obj.result_2)[0].Action;

       /* if (IsPrpNotIden == 1)
            $("#chk_Prop").prop("checked", true);
        else
            $("#chk_Prop").prop("checked", false);

        fnshoworHideDatas("S");*/

        var AgtData = JSON.parse(Obj.result_3);
        if (Adrsdata && Adrsdata.length > 0) {


            for (var j = 0; j < Adrsdata.length; j++) {
                var adrsdataval = [];
                adrsdataval.push(Adrsdata[j]);
                fnSetValues("maindiv_" + j, adrsdataval);
                var valtxt = $("#maindiv_" + j).find("input[key=agt_pin]").val();
                $("#maindiv_" + j).find("input[key=agt_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                $("#maindiv_" + j).find("input[key='agt_prppk']").val(Adrsdata[j].agt_prpPk);
                if (Adrsdata.length - 1 != j)
                    fnAddprop();
            }
            //fnSetValues("agt_Info", Adrsdata);
            //$("#agt_Info").attr("pk", Adrsdata[0].agt_prpPk);
        }
        if (AgtData && AgtData.length > 0) {
            for (var i = 0; i < AgtData.length; i++) {

                var TgtObj = $(".agt_DtlInfo input[colkey='agt_SrvTyp'][value='" + AgtData[i].agt_SrvTyp + "']").siblings("input");
                if (!TgtObj && TgtObj.length == 0)
                    return;

                $(TgtObj).attr("selval", AgtData[i].agt_AgtFk);

                $(TgtObj).siblings("ul").children("li").each(function () {
                    if ($(TgtObj).attr("selval") == $(this).attr("val")) {
                        $(TgtObj).val($(this).html());
                    }
                });

            }
        }


    }
    else if (ServDesc == "DATA_SAVE") {
        $("#agent-div").empty();
        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }

    }
        /*Changes By kani on 29/12/2016*/

    /*else if (ServDesc == "DATA_SAVE_ADR") {
        CurSel_div = $("#agt_addr_content_" + $(Param2).attr("val"));
        $("#ul_coapp li").removeClass("active");
        $(Param2).addClass("active");

        $(".app_Addr").css("display", "none");
        $("#agt_addr_content_" + $(Param2).attr("val")).css("display", "block");

        $(".adr_content").attr("contentchanged", "false");
        $("#agt_addr_content_" + $(Param2).attr("val") + " .adr_content").attr("contentchanged", "true");
    }*/

        /*Changes By kani on 29/12/2016*/
    else if (ServDesc == "DELETE") {

        $("#Prp_AdrsDiv .common-tabs .tab_0").click();
    }

}


function fnAgtSel() {
    var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["SELECT_AGT", "", ""] };
    fnCallLOSWebService("DATA_SEL", objProcData, fnAgtlisave, "MULTI", "");

}

function fnAgtlisave(ServDesc, Obj, Param1, Param2) {
    
    if (ServDesc == "DATA_SEL") {
        var data = JSON.parse(Obj.result);
        //if (data != null) {
        //    for (var i = 0; i < data.length; i++) {
        //        var htmlli = $('<li val="' + data[i].AgtPk + '" class="selected">' + data[i].AgtTitle + '</li>');
        //        $(".custom-select.agt_sel").append(htmlli);

        //    }
        //}
        fnloadScreen();
    }
    if (ServDesc == "SEL_LEAD") {

        var lead_data = JSON.parse(Obj.result);

        if (lead_data[0].LeadID.indexOf('<br/>') > 0) {
            var ledid = lead_data[0].LeadID.split('<br/>');
            $('#Agt_LeadId').text(ledid[0]);
        }
        else {
            $('#Agt_LeadId').text(lead_data[0].LeadID);
        }

        $("#Agt_LeadNm").text(lead_data[0].LeadNm);
        $("#Agt_Branch").text(lead_data[0].BranchNm);
        $("#Agt_AppNo").text(lead_data[0].AppNo);
        Agt_LnAmt = lead_data[0].LnAmt;

        var gConfigXml = [{}];
        gConfigXml[0].BrnchFk = GlobalXml[0].BrnchFk;
        gConfigXml[0].GrpFk = GlobalXml[0].PrdGrpFk;

        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["CMP_CONFIG_POLICY", JSON.stringify(gConfigXml), "gAgtTchTrig"] };
        fnCallLOSWebService("CMP_CONFIG_POLICY", objProcData, fnAgtlisave, "MULTI", "");
    }
    if (ServDesc == "DOCUMENT") {

        var ul_list = "";
        $("div.popup.documents.attach-icon.doc-list-view").empty();
        var docdata = JSON.parse(Obj.result);
        for (var i = 0; i < docdata.length; i++) {
            ul_list += '<ul pk="' + docdata[i].Pk + '"><li>' + docdata[i].DocName + '<p><span class="bg">' + docdata[i].Actor + '</span><span class="bg">' + docdata[i].Catogory + '</span> <span class="bg">' + docdata[i].SubCatogory + '</span></p>' +
            '</li><li><i class="icon-document doc-view" docpath="' + docdata[i].DocPath + '" onclick="fnOpenDocs(this)" ></i></li><li><i class="icon-delete"></i></li></ul>';
        }
        $("div.popup.documents.attach-icon.doc-list-view").append(ul_list);
    }

    if (ServDesc == "CMP_CONFIG_POLICY") {
        
        var data = JSON.parse(Obj.result);
        if (data != null && data.length != 0) {
            gConfig["gAgtTchTrig"] = data[0].ConfigVal;
        }

        if (Agt_LnAmt > Number(gConfig["gAgtTchTrig"])) {
            IsAgtTchTrig = true;
        }
    }
}


function fnsellead() {

    var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["SEL_LEAD", JSON.stringify(AgtGlobal)] };
    fnCallLOSWebService("SEL_LEAD", objProcData, fnAgtlisave, "MULTI", "");

}
function fnSelectDocment() {

    var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ['DOCUMENT', JSON.stringify(AgtGlobal), "", "", "", ""] };
    fnCallLOSWebService("DOCUMENT", objProcData, fnAgtlisave, "MULTI");
}

$(function () {
    var isBO = window.BO;
    isBO = isBO ? isBO : "";
    if (isBO == "") {
        fnCallScrnFn = function (FinalConfirm) {
            fnSaveFinal(FinalConfirm);
        }
    }
    else {
        fnCallScrnFnfrmBO = function (FinalConfirm) {
            fnSaveFinal(FinalConfirm);
        }
    }
});


function fnSaveFinal(FinalConfirm) {
    
    IsFinalConfirm = FinalConfirm;
    if (FinalConfirm.toString() == "true") {
        if (IsAgtTchTrig) {
            fnAgtCase();
        }
        $("#agent-div").show();
        return;
    }
    fnAgentcrdPNIConfirmScreenFinal();
}

function fnAgtCase() {
    
    try {
        var AgtCnt = $("#agent-div .tech_div").length;
        $("#agent-div .h2Title").remove();

        for (var j = 1; j < AgtCnt; j++) {
            $('#div_tech_ver_' + j).remove();
        }

        var AgtCount = 2;
        var PropCnt = Number($("#Prp_AdrsDiv .common-tabs li.prop_tab").length);
        var Agt_Dynamic = AgtCount * PropCnt;
        var ChkPropCnt = 0; var PrevPrpCnt = 0;

        for (var i = 0; i < Agt_Dynamic; i++) {

            if (i > 0) {
                var AppendwithTech = $('#div_tech_ver_' + (i - 1));
                if (PrevPrpCnt != ChkPropCnt)
                    AppendwithTech = $('#h2_title_' + (i - 1));

                var TechCopyContent = $('<li class="hiddenAgency rowGrid tech_div" prop="' + ChkPropCnt + '" id="div_tech_ver_' + i + '">');
                TechCopyContent.append($("#div_tech_ver_0").html());
                $(AppendwithTech).after(TechCopyContent);
                //$('#div_tech_ver_' + i + ' #techverid_0').attr("selval","");
                $('#div_tech_ver_' + i + ' input[colkey="agt_PrpKey"]').val((ChkPropCnt + 1));
                $('#div_tech_ver_' + i + ' #techverid_0_help').attr("id", "techverid_" + i + "_help");
            }
            else
                $("#div_tech_ver_" + i).before("<div class='h2Title' id='h2_title_" + i + "'><h2>Property " + (ChkPropCnt + 1) + "</h2></div>");

            PrevPrpCnt = ChkPropCnt;

            if (i % 2 > 0) {
                ChkPropCnt += 1;

                if ((ChkPropCnt + 1) <= PropCnt)
                    $("#div_tech_ver_" + i).after("<div class='h2Title' id='h2_title_" + i + "'><h2>Property " + (ChkPropCnt + 1) + "</h2></div>");
            }
        }
    } catch (e) { FinalConfirm = "false"; }
}

function fnAddprop() {
    var li = ''
    var prphtml = $("#maindiv_0").html();
    var list = $("#Prp_AdrsDiv").find("ul.common-tabs li.add")
    $(list).before('<li prpcount="' + count + '" class="prop_tab tab_' + count + '" onclick="fnaddDiv(this);"onfocusout ="fnsavedata();">Property' + (count + 1) + '<i onclick="fnBindliClose(this,event)" class="li-close icon-close"></i></li>');
    $(".tab_" + count).addClass("active");
    $(".tab_" + count).siblings("li").removeClass("active");
    $("#agt_Info").append('<div prppk = "0" class="tab-content" id="maindiv_' + count + '"contentchanged="true">' + prphtml + '</div>');
    var divcount = $("#agt_Info").find("#maindiv_" + count)
    $(divcount).siblings("div").hide();
    $(divcount).show();
    $("#maindiv_" + count).find("input[type='hidden']").val("0");
    $("#maindiv_" + count).find("input[key='agt_prtytyp']").attr("selval", "-1");
    count++;
}
function fnBindliClose(elem, e) {
    e.stopPropagation();
    var divno = $(elem).closest("li").attr("prpcount")
    var propFK = $("#maindiv_" + divno).find("input[type='hidden']").val();
    if (GlobalXml[0].IsAll == "1")
        return;
    if (propFK == 0) {
        $(elem).closest("li").remove();
        $("#maindiv_" + divno).remove();
        count--;
        $("#Prp_AdrsDiv .common-tabs .tab_0").click();

    }
    else {
        var confirmSts = confirm("Do you wish to Delete??");
        if (confirmSts == true) {
            $(elem).closest("li").remove();
            $("#maindiv_" + divno).remove();
            count--;
            var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["DELETE", JSON.stringify(AgtGlobal), "", "", propFK] };
            fnCallLOSWebService("DELETE", objProcData, fnAgtTrig, "MULTI", "");
        }


    }
}


function fnaddDiv(elem) {
    
    var value = $(elem).closest("li").attr("prpcount");
    var cur_div = $("#agt_Info").find("#maindiv_" + value);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div").css("display", "none")
    $(".tab_" + value).addClass("active");
    $(".tab_" + value).siblings("li").removeClass("active");
    }
function fngetpropdet(FormID, IsClass, cnt) {
    
    var KeyVal = [];
    var KeyJsonTxt = "";
    var IsKeyExists = 0;
    var KeyValObj = {};
    var dvno = "";
    var lpcnt = 0;


    while (lpcnt < cnt) {
        KeyJsonTxt = "";
        IsKeyExists = 0;
        KeyValObj = {};
        var AppendOperator = "#";
        if (IsClass == 1) { AppendOperator = "." }

        var dvno = lpcnt.toString();

        $(AppendOperator + FormID + "_" + lpcnt + " [name='content']").each(function () {
            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if (!($(this).is("[key]"))) { return; }

                if ($(this).hasClass("currency")) {
                    $(this).text(FormatCleanComma($(this).text()));
                }
                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                KeyValObj[keyTxt] = $(this).text();

                KeyJsonTxt += keyTxt + ",";
            }
        });
        $(AppendOperator + FormID + "_" + lpcnt + " [name='text']").each(function () {
            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if (!($(this).is("[key]"))) { return; }

                if ($(this).hasClass("currency")) {
                    $(this).val(FormatCleanComma($(this).val().trim()));
                }

                var AssignValue = $(this).val().trim();
                if (AssignValue == "") { if ($(this).is("[value]")) AssignValue = $(this).attr("value"); }
                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                KeyValObj[keyTxt] = AssignValue;

                KeyJsonTxt += keyTxt + ",";
            }
        });

        $(AppendOperator + FormID + "_" + lpcnt + " [name='select']").each(function () {
            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if (!($(this).is("[key]"))) { return; }

                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                var keyVal = $(this).attr("selval");
                KeyValObj[keyTxt] = keyVal;

                KeyJsonTxt += keyTxt + ",";
            }
        });

        $(AppendOperator + FormID + "_" + lpcnt + " [name='checkbox']").each(function () {
            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if (!($(this).is("[key]"))) { return; }

                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                var keyVal = ($(this).is(":checked")) ? 0 : 1;
                KeyValObj[keyTxt] = keyVal;

                KeyJsonTxt += keyTxt + ",";
            }
        });
        if (IsKeyExists == 1)
            KeyValObj["divno"] = lpcnt;
        KeyVal.push(KeyValObj);

        lpcnt += 1;
    }

    return KeyVal;
}
function fnagentconfirmcrdPNI() {
    
    /* var ErrMsgAgt = "";
     var HdrJson = fngetpropdet("maindiv", 0, count);
     LoadDiv = $("#fulagtdiv").attr("id");
     ErrMsgAgt = fnChkMandatory(LoadDiv);
     if (ErrMsgAgt != "") {
         fnShflAlert("error", ErrMsgAgt);
         return false;
     }
     if ($("#legalverid").attr('selval') == -1) {
         fnShflAlert("error", "Legal Verification Required!! ");
         return;
     }*/
    
    var ErrMsg = '';
    var FinErrMsg = '';
    for (var n = 0; n < count; n++) {
        var dvid = "";
        dvid = "maindiv_" + n;
        ErrMsg = '';
        Error = fnconstChkMandatory(dvid);
        /* CERSAI VALIDATIONS */
        flatError = fnflatValidation("#" + dvid + " .valdflat");
        plotError = fnplotValidation("#" + dvid + " .valdplot");
        buildError = fnbuidValidation("#" + dvid + " .valdbuild");
        streetError = fnstreetValidation("#" + dvid + " .valdstreet");
        landmarkError = fnlandmarkValidation("#" + dvid + " .valdLM");
        if (Error != "") {
            ErrMsg = ErrMsg == "" ? Error : ErrMsg + Error;
        }
        if (flatError != "") {
            ErrMsg = ErrMsg == "" ? flatError : ErrMsg + "<br/>" + flatError;
        }
        if (plotError != "") {
            ErrMsg = ErrMsg == "" ? plotError : ErrMsg + "<br/>" + plotError;
        }
        if (buildError != "") {
            ErrMsg = ErrMsg == "" ? buildError : ErrMsg + "<br/>" + buildError;
        }
        if (streetError != "") {
            ErrMsg = ErrMsg == "" ? streetError : ErrMsg + "<br/>" + streetError;
        }
        if (landmarkError != "") {
            ErrMsg = ErrMsg == "" ? landmarkError : ErrMsg + "<br/>" + landmarkError;
        }
        if ($("#" + dvid).find("comp-help").find("input[name=helptext]").val() == "") {
            ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "<br/>Pincode Required!!";
        }
        if ($("#" + dvid).find("comp-help").find("input[name=helptext]").val() != "") {
            if ($("#" + dvid).find("comp-help").find("input[name=helptext]").val() != $("#" + dvid).find("input[key=agt_pin]").val()) {
                ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "<br/>Valid Pincode Required!!";
            }
        }
        if (ErrMsg != "") {
            FinErrMsg = FinErrMsg == "" ? "<b>Property" + (n + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Property" + (n + 1) + "</b><br/>" + ErrMsg;
        }
        /* CERSAI VALIDATIONS */
    }

    
    var LegalDiv = $("#agent-div").find("comp-help#legalverid_help").find("input[name=helptext]");
    var LegalProp = LegalDiv.attr("val");
    if (LegalDiv.val() == "" || (!LegalProp) || LegalProp == "") {
        FinErrMsg = FinErrMsg == "" ? "Legal Verification Required!!" : FinErrMsg + "<br/>Legal Verification Required!!";
    }
    
    if (IsAgtTchTrig) {
        var ReqdValidation = 0;
        var OldPropNo = 0;
        var PropNo = 0;

        var AgtCnt = $("#agent-div .tech_div").length;
        for (var j = 0; j < AgtCnt; j++) {
            OldPropNo = PropNo;
            PropNo = Number($("#div_tech_ver_" + j).attr("prop")) + 1;
            var selStringId = $("#agent-div").find("comp-help#techverid_" + j + "_help").find("input[name=helptext]");
            var selVal = $(selStringId).attr('val');
            var cmpErrMsg = "";

            if (OldPropNo != PropNo)
                ReqdValidation = 0;

            if (((!selVal) || selVal == "" || $(selStringId).val() == "") && ReqdValidation == 0) {
                ReqdValidation = 1;
                FinErrMsg = FinErrMsg == "" ? "Technical Verification for Property " + PropNo + " Required!!" :
                        FinErrMsg + "<br/>Technical Verification for Property " + PropNo + " Required!!";
            }

            if (OldPropNo != PropNo && ReqdValidation == 0) {
                $("#agent-div .tech_div[prop=" + (PropNo - 1) + "]").each(function () {
                    var id = $(this).attr("id");
                    id = Number(id[id.length - 1]);
                    var cmpStringId = $("#agent-div").find("comp-help#techverid_" + id + "_help").find("input[name=helptext]");
                    var Cmp_Val = $(cmpStringId).attr('val');

                    if (Cmp_Val == selVal && $(cmpStringId).val() == $(selStringId).val() &&
                        $(cmpStringId).parents("comp-help").attr("id") != $(selStringId).parents("comp-help").attr("id")) {
                        cmpErrMsg = "Different Agents should be selected for Property " + PropNo;
                    }
                });
            }

            if (cmpErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? cmpErrMsg : FinErrMsg + "<br/>" + cmpErrMsg;
            }
        }
    }
    else {

        var TechDiv = $("#agent-div").find("comp-help#techverid_0_help").find("input[name=helptext]");
        var TechProp = TechDiv.attr("val");
        if (TechDiv.val() == "" || (!TechProp) || TechProp == "") {
            FinErrMsg = FinErrMsg == "" ? "Technical Verification Required!!" : FinErrMsg + "<br/>Technical Verification Required!!";
        }
    }

    if (FinErrMsg != "") {
        fnShflAlert("error", FinErrMsg);
        return false;
    }

    var HdrJson = fngetpropdet("maindiv", 0, count);
    AgtJson = fnGetComphelp("agt_DtlInfo", "");

    
    var objProcData = { ProcedureName: "PrcShflAgtPNI", Type: "SP", Parameters: ["INSERT_AGT", JSON.stringify(AgtGlobal), JSON.stringify(HdrJson), JSON.stringify(AgtJson), "", IsAgtTchTrig] };
    fnCallLOSWebService("DATA_SAVE", objProcData, fnAgtTrig, "MULTI", "");

}
function fnconstChkMandatory(FormID) {
    var MandatoryMsg = "";
    var AppendOperator = "#";

    $(AppendOperator + FormID + "[contentchanged='true'] .mandatory").each(function () {
        var lbl_sibling; var label = "";
        if ($(this).attr("name") == "text" && ($(this).val().trim() == "" || $(this).val().trim() == "0")) {
            lbl_sibling = $(this).siblings("label");
            label = $(lbl_sibling).text();
            if (label == "") { label = $(this).attr("placeholder"); }

            if (label != "" && label != undefined)
                MandatoryMsg += label + " Required!! <br/>";
        }
        if ($(this).attr("name") == "select" && $(this).attr("selval") == "-1") {
            lbl_sibling = $(this).closest(".select-focus");
            lbl_sibling = lbl_sibling.siblings("label");
            label = $(lbl_sibling).text();

            if (label != "" && label != undefined)
                MandatoryMsg += label + " Required!! <br/>";

        }
    });

    return MandatoryMsg;
}
