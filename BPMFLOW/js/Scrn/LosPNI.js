var Action = "";
var MaxAdrTab = 0;
var CurSel_div;
var IsFinalConfirm = "";
var Agt_LnAmt = 0;
var IsAddrEmpty = 1;

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

    console.log("PNI");
    CurSel_div = $("#agt_addr_content_0");
    fnAgtSel();

    $(document).on("click", "#ul_coapp li", function () {
        AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id"));
        var IsAllEmpty = fnIsAllEmpty($(CurSel_div).attr("id"));
        if (!IsAllEmpty) {
            var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["INSERT_ADR", JSON.stringify(AgtGlobal), "", JSON.stringify(AdrJson)] };
            fnCallLOSWebService("DATA_SAVE_ADR", objProcData, fnAgtTrig, "MULTI", $(this));
        }
        else {
            $(CurSel_div).attr("contentchanged", "false");
            CurSel_div = $("#agt_addr_content_" + $(this).attr("val"));
            $("#ul_coapp li").removeClass("active");
            $(this).addClass("active");

            $(".app_Addr").css("display", "none");
            $("#agt_addr_content_" + $(this).attr("val")).css("display", "block");
        }
    });

    var param = JSON.stringify(GlobalBrnch);
   
    $("#fio_help").attr("Extraparam", param);
    $("#dv_help").attr("Extraparam", param);
    $("#cf_help").attr("Extraparam", param);
    $("#fir_help").attr("Extraparam", param);
});

function fnloadScreen() {
    var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["SELECT", JSON.stringify(AgtGlobal)] };
    fnCallLOSWebService("DATA_TBL", objProcData, fnAgtTrig, "MULTI", "");
}

function fnAgentPNIConfirmScreenFinal() {    
    var ErrMsg = '';
    var FinErrMsg = '';

    FinErrMsg = fnConfirmAddress();

    if (FinErrMsg != "") {
        fnShflAlert("error", FinErrMsg);
        return false;
    }
    var AdrJson = {};        
    AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id")); 
    var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["INSERT", JSON.stringify(AgtGlobal), "", JSON.stringify(AdrJson)] };
    fnCallLOSWebService("DATA_SAVE", objProcData, fnAgtTrig, "MULTI", "");
}
function Pinclick(rowjson, elem) {
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}

function fnAgtTrig(ServDesc, Obj, Param1, Param2) {
    
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServDesc == "DATA_TBL") {
        
        $("#agt_Info").attr("pk", "");                               



        var AgtData = JSON.parse(Obj.result_1);

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
        var AdrDtls = JSON.parse(Obj.result_2);
        if (AdrDtls.length > 0) {
            var empcount = 0;
            var todraw = 0;
            var actualLength = AdrDtls.length;
            for (var a = 0; a < AdrDtls.length; a++) {

                if (AdrDtls[a].agt_app_Typ >= 0 || AdrDtls[a].LaaFk > 0)
                    IsAddrEmpty = 0;

                if (IsAddrEmpty == 0 && AdrDtls[a].agt_app_Typ == 4)
                    IsAddrEmpty = 1;

                var SetValueFor = ""; var iAdr = [];
                iAdr.push(AdrDtls[a]);
                if (todraw == 0) {
                    SetValueFor = $(".app_Addr[val='0']").attr("id");
                    fnSetValues(SetValueFor, iAdr);
                    $(".app_Addr[val='0']").attr("emptyp", AdrDtls[a].agt_Addr_Type);
                    var valtxt = $(".app_Addr[val='0']").find("input[key=agt_app_pin]").val();
                    $(".app_Addr[val='0']").find("input[key=agt_app_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                    $("#li_Start").empty();
                    $("#li_Start").html(AdrDtls[a].ActorTyp);
                    todraw = 1;
                }
                else {
                    $("#ul_coapp").append('<li val="' + MaxAdrTab + '">' + AdrDtls[a].ActorTyp + '</li>');

                    var new_addr_div = $("<div style='display:none;' class='app_Addr' emptyp = '" + AdrDtls[a].agt_Addr_Type + "'val='" + MaxAdrTab + "' id='agt_addr_content_" + MaxAdrTab + "'contentchanged='false'></div>");
                    var content = $("#agt_addr_content_0").html();
                    new_addr_div.append(content);
                    $("#whole_addr_div").append(new_addr_div);

                    SetValueFor = "agt_addr_content_" + MaxAdrTab;
                    fnSetValues(SetValueFor, iAdr);
                    var valtxt = $("#" + SetValueFor).find("input[key=agt_app_pin]").val();
                    $("#" + SetValueFor).find("input[key=agt_app_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                }
                MaxAdrTab += 1;
            }
                
            $("#whole_addr_div [key]").each(function () {
                $(document).on("change", "#whole_addr_div [key]", function () {
                    $(this).closest(".app_Addr").attr("contentchanged", "true");
                });
            });
        }
        else {
            $("#fulagtdiv").hide();
            fnShflAlert("warning", "No Address Details Found");
        }

        if (AdrDtls.length == 1) {
            if (AdrDtls[0].agt_app_Typ == 4)
                IsAddrEmpty = 0;
        }
    }
    else if (ServDesc == "DATA_SAVE") {
        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }
    }
    else if (ServDesc == "DATA_SAVE_ADR") {
        CurSel_div = $("#agt_addr_content_" + $(Param2).attr("val"));
        $("#ul_coapp li").removeClass("active");
        $(Param2).addClass("active");

        $(".app_Addr").css("display", "none");
        $("#agt_addr_content_" + $(Param2).attr("val")).css("display", "block");

    }
    else if (ServDesc == "DELETE") {

        $("#Prp_AdrsDiv .common-tabs .tab_0").click();
    }

}


function fnAgtSel() {
    var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["SELECT_AGT", "", ""] };
    fnCallLOSWebService("DATA_SEL", objProcData, fnAgtlisave, "MULTI", "");

}

function fnAgtlisave(ServDesc, Obj, Param1, Param2) {
    
    if (ServDesc == "DATA_SEL") {
        var data = JSON.parse(Obj.result);
        if (data != null) {
            for (var i = 0; i < data.length; i++) {
                var htmlli = $('<li val="' + data[i].AgtPk + '" class="selected">' + data[i].AgtTitle + '</li>');
                $(".custom-select.agt_sel").append(htmlli);

            }
        }
        fnloadScreen();
    }
    if (ServDesc == "SEL_LEAD") {
        
        var lead_data = JSON.parse(Obj.result);
        $("#Agt_LeadId").text(lead_data[0].LeadID);
        $("#Agt_LeadNm").text(lead_data[0].LeadNm);
        $("#Agt_Branch").text(lead_data[0].BranchNm);
        $("#Agt_AppNo").text(lead_data[0].AppNo);
        Agt_LnAmt = lead_data[0].LnAmt;

        var gConfigXml = [{}];
        gConfigXml[0].BrnchFk = GlobalXml[0].BrnchFk;

        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["CMP_CONFIG_POLICY", JSON.stringify(gConfigXml), "gColFB"] };
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
            gConfig["gColFB"] = data[0].ConfigVal;
        }

        if (Agt_LnAmt > Number(gConfig["gColFB"])) {
            $("#agent-div").find("li.collection").attr("style", "display:block;");
            GlobalXml[0].TgtPageID = gAutoDec["CF"];
        }
        else {
            $("#agent-div").find("li.collection").attr("style", "display: none;");
            GlobalXml[0].TgtPageID = gAutoDec["CO"];
        }
    }
}


function fnsellead() {

    var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["SEL_LEAD", JSON.stringify(AgtGlobal)] };
    fnCallLOSWebService("SEL_LEAD", objProcData, fnAgtlisave, "MULTI", "");

}
function fnSelectDocment() {

    var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ['DOCUMENT', JSON.stringify(AgtGlobal), "", "", "", ""] };
    fnCallLOSWebService("DOCUMENT", objProcData, fnAgtlisave, "MULTI");
}

function fnCallScrnFn(FinalConfirm) {
    
    IsFinalConfirm = FinalConfirm;
    if (FinalConfirm.toString() == "true") {
        $("#agent-div").show();
        return;
    }

    fnAgentPNIConfirmScreenFinal();
}
/*window.count = 1;
function fnAddprop() {
    var li = ''
    var prphtml = $("#maindiv_0").html();
    var list = $("#Prp_AdrsDiv").find("ul.common-tabs li.add")
    $(list).before('<li count="' + count + '" class="tab_' + count + '" onclick="fnaddDiv(this);"onfocusout ="fnsavedata();">Property' + count + '<i onclick="fnBindliClose(this,event)" class="li-close icon-close"></i></li>');
    $(".tab_" + count).addClass("active");
    $(".tab_" + count).siblings("li").removeClass("active");
    $("#agt_Info").append('<div prppk = "0" class="tab-content" id="maindiv_' + count + '">' + prphtml + '</div>');
    var divcount = $("#agt_Info").find("#maindiv_" + count)
    $(divcount).siblings("div").hide();
    $(divcount).show();
    $("#maindiv_" + count).find("input[type='hidden']").val("0");
    $("#maindiv_" + count).find("input[key='agt_prtytyp']").attr("selval", "-1");
    count++;
}
function fnBindliClose(elem, e) {
    
    e.stopPropagation();
    var divno = $(elem).closest("li").attr("count")
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
            var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["DELETE", JSON.stringify(AgtGlobal), "", "", ""] };
            fnCallLOSWebService("DELETE", objProcData, fnAgtTrig, "MULTI", "");
        }
    }
}
function fnaddDiv(elem) {
    
    var value = $(elem).attr("class").split("_");
    var cur_div = $("#agt_Info").find("#maindiv_" + value[1]);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div").css("display", "none")
    $(".tab_" + value[1]).addClass("active");
    $(".tab_" + value[1]).siblings("li").removeClass("active");
}*/

function fnConfirmAddress() {
    
    var Cnt_Length = 0;
    var ErrMsg = ""; var FinErrMsg = "";

    var IsAllEmpty = fnIsAllEmpty($(CurSel_div).attr("id"));
    if (IsAllEmpty)
        $(CurSel_div).attr("contentchanged", "false");
    else if ($(CurSel_div).attr("emptyp") != "4")
        $(CurSel_div).attr("contentchanged", "true");
    
    Cnt_Length = $("#whole_addr_div .app_Addr[contentchanged='true'][emptyp!='4']").length;

    if (Cnt_Length == 0 && IsAddrEmpty == 1) {
        FinErrMsg = "Atleast fill one Office Address to Continue!! <br/>";
    }
    else {
        for (var k = 0; k < MaxAdrTab; k++) {
            var dvidA = "";
            dvidA = "agt_addr_content_" + k;
            ErrMsg = '';
            var applError = fnconstChkMandatory(dvidA);
            if (applError != "") {
                ErrMsg = ErrMsg == "" ? applError : ErrMsg + applError;
            }
            if ($("#" + dvidA).attr("contentchanged") == "true") {
                if ($("#" + dvidA).find("comp-help").find("input[name=helptext]").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Pincode Required!!" : ErrMsg + "Pincode Required!!<br/>";
                }
            }
            if ($("#" + dvidA).find("comp-help").find("input[name=helptext]").val() != "") {
                if ($("#" + dvidA).find("comp-help").find("input[name=helptext]").val() != $("#" + dvidA).find("input[key=agt_app_pin]").val()) {
                    ErrMsg = ErrMsg == "" ? "Valid Pincode Required!!" : ErrMsg + "Valid Pincode Required!!<br/>";
                }
            }
            if (ErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? "Address " + (k + 1) + " : " + ErrMsg : FinErrMsg + "Address " + (k + 1) + " : " + ErrMsg;
            }
        }
    }

    return FinErrMsg;
}

function fnagentPNIconfirm() {    
    var ErrMsg = '';
    var FinErrMsg = '';
    
    FinErrMsg = fnConfirmAddress();

    AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id"));
    AgtJson = fnGetComphelp("agt_DtlInfo", "");

    if (AgtJson.error == true) {
        FinErrMsg += AgtJson.text;
    }

    if (FinErrMsg != "") {
        fnShflAlert("error", FinErrMsg);
        return false;
    }
    
    var objProcData = { ProcedureName: "PrcShflPni", Type: "SP", Parameters: ["INSERT_AGT", JSON.stringify(AgtGlobal), JSON.stringify(AgtJson), JSON.stringify(AdrJson)] };
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
