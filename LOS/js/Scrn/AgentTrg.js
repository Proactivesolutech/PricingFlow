var Action = "";
var MaxAdrTab = 0;
var CurSel_div;
var IsFinalConfirm = "";
var GrpPrdFk = '';
var Agt_LnAmt = 0;
var IsAgtLapTrig = false;

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
    AgtGlobal[0].PrdGrpFk = GlobalXml[0].PrdGrpFk;
    AgtGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    GlobalXml[0].DpdFk = null;
    fnsellead();

    //$("#agt_Info").find("*").each(function () {
    //    if ($(this).is("[key]")) {
    //        $(this).addClass("mandatory");
    //    }
    //});

    CurSel_div = $("#agt_addr_content_0");
    fnAgtSel();
    fnagtgprdicon();
    $(document).on("click", "#ul_coapp li", function () {        
        $(CurSel_div).attr("contentchanged", "true");
        var EmpType = $(CurSel_div).attr("emptyp")
        if (EmpType == 4 || EmpType == -1)
        {          
            if (!($(CurSel_div).find("[key='agt_app_DoorNo']").val()!="" ||$(CurSel_div).find("[key='agt_app_Building']").val()!="" ||$(CurSel_div).find("[key='agt_app_PlotNo']").val()!="" ||$(CurSel_div).find("[key='agt_app_Street']").val()!="" ||$(CurSel_div).find("[key='agt_app_Landmark']").val()!="" ||$(CurSel_div).find("[key='agt_app_Area']").val()!="" ||$(CurSel_div).find("[key='agt_app_District']").val()!="" ||$(CurSel_div).find("[key='agt_app_State']").val()!="" ||$(CurSel_div).find("comp-help").find("input[name='helptext']").val()!="" ) ){
                $(CurSel_div).attr("contentchanged", "false");
            }
        }                                       
        AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id"));
        var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["INSERT_ADR", JSON.stringify(AgtGlobal), "", "", JSON.stringify(AdrJson)] };
        fnCallLOSWebService("DATA_SAVE_ADR", objProcData, fnAgtTrig, "MULTI", $(this));
    });

});

function Pinclick(rowjson, elem) {
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}
function fnloadScreen() {
    var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["SELECT", JSON.stringify(AgtGlobal)] };
    fnCallLOSWebService("DATA_TBL", objProcData, fnAgtTrig, "MULTI", "");
}

function fnAgentConfirmScreenFinal() {
    debugger
    var ErrMsg = '';
    var FinErrMsg = '';    
        for (n = 0; n < count; n++) {
            var dvid = "";
            dvid = "maindiv_" + n;
            ErrMsg = '';
            var addrCount = 0;
            //LoadDiv = $("#fulagtdiv").attr("id");
            Error = fnconstChkMandatory(dvid);
            pinError = $("#" + dvid + " #comp-help").find("input[name=helptext]").val();
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
            if (pinError == "") {
                ErrMsg = ErrMsg == "" ? "Pincode required!!" : ErrMsg + "Pincode required";
            }
            if (pinError != "") {
                if (pinError != $("#" + dvid).find("input[key=agt_pin]").val()) {
                    ErrMsg = ErrMsg == "" ? "Valid Pincode required!!" : ErrMsg + "Valid Pincode required";
                }
            }
            if (ErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? "<b>Property" + (n + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Property" + (n + 1) + "</b><br/>" + ErrMsg;
            }
        }
        for (var k = 0; k < MaxAdrTab; k++) {
            var dvidA = "";
            dvidA = "agt_addr_content_" + k;
            ErrMsg = '';
            //if ($("#" + dvidA).attr("emptyp") == -1)
            //{
            //    addrCount += 1;
            //}
            //if (addrCount == MaxAdrTab)
            //{
            //    $("#agt_addr_content_0").attr("contentchanged", "true");
            //}
            //LoadDiv = $("#fulagtdiv").attr("id");            
            var applError = fnconstChkMandatory(dvidA);
            pinAppError = $("#" + dvidA + " #comp-help").find("input[name=helptext]").val();
            if (applError != "") {
                ErrMsg = ErrMsg == "" ? applError : ErrMsg + applError;
            }
            if ($("#" + dvidA).attr("contentchanged") == "true") {
                if (pinAppError == "") {
                    ErrMsg = ErrMsg == "" ? "Pincode required!!" : ErrMsg + "Pincode required";
                }
            }
            if (pinAppError != "") {
                if (pinAppError != $("#" + dvidA).find("input[key=agt_app_pin]").val()) {
                    ErrMsg = ErrMsg == "" ? "Valid Pincode required!!" : ErrMsg + "Valid Pincode required";
                }
            }
            if (ErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? "<b>Address" + (k + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Address" + (k + 1) + "</b><br/>" + ErrMsg;
            }
        }

    

    if (FinErrMsg != "") {
        fnShflAlert("error", FinErrMsg);
        return false;
    }    
        //savedata
    
        var AdrJson = {};
        var HdrJson = fngetpropdet("maindiv", 0, count);
        AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id"));
        var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["INSERT", JSON.stringify(AgtGlobal), JSON.stringify(HdrJson), "", JSON.stringify(AdrJson)] };
        fnCallLOSWebService("DATA_SAVE", objProcData, fnAgtTrig, "MULTI", "");
    
}


function fnAgtTrig(ServDesc, Obj, Param1, Param2) {
    
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    /*CHANGE(MUTHU)17/12/16*/
    if (ServDesc == "Sel_icon_Prd") {
        
        var prddata = JSON.parse(Obj.result);
        var clsNm = '';
        var prd = '';
        if (prddata.length > 0) {
            if (prddata[0].productpk == 4) {
                $("#prddiv i").attr("pk", 4);
                classnm = prddata[0].icon_class;
                text = prddata[0].prdname;
            }
            if (prddata[0].productpk == 5) {
                $("#prddiv i").attr("pk", 5);
                classnm = prddata[0].icon_class;
                text = prddata[0].prdname;
            }
            if (prddata[0].productpk == 6) {
                $("#prddiv i").attr("pk", 6);
                classnm = prddata[0].icon_class;
                text = prddata[0].prdname;
            }
            var lihtml = ''
            lihtml = '<i class = ' + classnm + '></i><p>' + text + '</p>'
            $("#prddiv").append(lihtml);
            $("#prddiv i").attr("pk", prddata[0].productpk);
            $("#LeadPrdPk").val(prddata[0].productpk);
            $("#LeadPrdPk").attr("pcd", prddata[0].PCd);
        }
    }

    /*END*/
    if (ServDesc == "DATA_TBL") {
        
        $("#agt_Info").attr("pk", "");
        var Adrsdata = JSON.parse(Obj.result_1);        
        Action = JSON.parse(Obj.result_2)[0].Action;
        var AgtData = JSON.parse(Obj.result_3);
        if (Adrsdata && Adrsdata.length > 0) {
            

            for (var j = 0; j < Adrsdata.length; j++) {
                var adrsdataval = [];
                adrsdataval.push(Adrsdata[j]);
                fnSetValues("maindiv_" + j, adrsdataval);
                var valtxt = $("#maindiv_" + j).find("input[key=agt_pin]").val();
                $("#maindiv_" + j).find("input[key=agt_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                $("#maindiv_" + j).find("input[key=agt_prppk]").val(Adrsdata[j].agt_prpPk);
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
        var AdrDtls = JSON.parse(Obj.result_4);
        
        if (AdrDtls.length > 0) {
            var empcount = 0;
            var todraw = 0;
            var actualLength = AdrDtls.length;
            for (var a = 0; a < AdrDtls.length; a++) {

                if (AdrDtls[a].agt_Addr_Type != 3) {

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

                        var new_addr_div = $("<div style='display:none;' class='app_Addr' emptyp = '" + AdrDtls[a].agt_Addr_Type + "'val='" + MaxAdrTab + "' id='agt_addr_content_" + MaxAdrTab + "'contentchanged='true'></div>");
                        var content = $("#agt_addr_content_0").html();
                        new_addr_div.append(content);
                        $("#whole_addr_div").append(new_addr_div);

                        SetValueFor = "agt_addr_content_" + MaxAdrTab;
                        fnSetValues(SetValueFor, iAdr);
                        var valtxt = $("#"+SetValueFor).find("input[key=agt_app_pin]").val();
                        $("#" + SetValueFor).find("input[key=agt_app_pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);

                    }

                    if (AdrDtls[a].agt_Addr_Type == -1 )
                    {
                        $("#agt_addr_content_" + MaxAdrTab).attr("contentchanged", "false");
                        empcount++;
                    }
                    if (empcount == actualLength)
                        {
                        $("#agt_addr_content_0").attr("contentchanged", "true");
                    }
                    if (AdrDtls[a].agt_Addr_Type == 4) {
                        $("#agt_addr_content_" + MaxAdrTab).attr("contentchanged", "false");
                    }

                    MaxAdrTab += 1;
                }
                else{
                   actualLength--;
                }
                //$(".adr_content").attr("contentchanged", "false");
               //$("#agt_addr_content_0 .adr_content").attr("contentchanged", "true");
            }
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

        $(".adr_content").attr("contentchanged", "false");
        $("#agt_addr_content_" + $(Param2).attr("val") + " .adr_content").attr("contentchanged", "true");
    }
    else if (ServDesc == "DELETE") {

        $("#Prp_AdrsDiv .common-tabs .tab_0").click();
    }

}


function fnAgtSel() {
    var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["SELECT_AGT", "", ""] };
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
        if (GlobalXml[0].GrpCd == "LAP" && Number(Agt_LnAmt) > Number(gConfig["gLnAmtLap"]))
            IsAgtLapTrig = true;
        
        if (Agt_LnAmt > Number(gConfig["gColFB"]))
        {
            $("#agent-div").find("li.collection").attr("style", "display:block;");
            GlobalXml[0].TgtPageID = gAutoDec["CF"];
        }
        else
        {
            $("#agent-div").find("li.collection").attr("style", "display: none;");
            GlobalXml[0].TgtPageID = gAutoDec["CO"];
        }

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
}


function fnsellead() {

    var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["SEL_LEAD", JSON.stringify(AgtGlobal)] };
    fnCallLOSWebService("SEL_LEAD", objProcData, fnAgtlisave, "MULTI", "");

}
function fnSelectDocment() {

    var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ['DOCUMENT', JSON.stringify(AgtGlobal), "", "", "", ""] };
    fnCallLOSWebService("DOCUMENT", objProcData, fnAgtlisave, "MULTI");
}

function fnCallScrnFn(FinalConfirm) {
    IsFinalConfirm = FinalConfirm;

    if (FinalConfirm.toString() == "true") {
        if (IsAgtLapTrig) {
            fnLapAgtCase();
        }
        $("#agent-div").show();
        return;
    }
    fnAgentConfirmScreenFinal();
}

function fnLapAgtCase() {

    try{
        var LapAgtCnt = $("#agent-div .tech_div").length;
        $("#agent-div .h2Title").remove();

        for (var j = 1; j < LapAgtCnt; j++) {
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
                $('#div_tech_ver_' + i + ' #techverid_0').attr("selval", -1);
                $('#div_tech_ver_' + i + ' input[colkey="agt_PrpKey"]').val((ChkPropCnt + 1));
                $('#div_tech_ver_' + i + ' #techverid_0').attr("id", "techverid_" + i);
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
window.count = 1;
function fnAddprop() {
    

    var li = ''

    var prphtml = $("#maindiv_0").html();
    var list = $("#Prp_AdrsDiv").find("ul.common-tabs li.add")
    $(list).before('<li prpcount="' + count + '" class="prop_tab tab_' + count + '" onclick="fnaddDiv(this);"onfocusout ="fnsavedata();">Property' + (count + 1)+ '<i onclick="fnBindliClose(this,event)" class="li-close icon-close"></i></li>');
    $(".tab_" + count).addClass("active");
    $(".tab_" + count).siblings("li").removeClass("active");


    $("#agt_Info").append('<div prppk = "0" class="tab-content" id="maindiv_' + count + '" contentchanged="true">' + prphtml + '</div>');
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
            var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["DELETE", JSON.stringify(AgtGlobal), "", "", "", propFK] };
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
function fnagentconfirm() {
    
    var ErrMsg = '';
    var FinErrMsg = '';

    
        for (var n = 0; n < count; n++) {
            var dvid = "";
            dvid = "maindiv_" + n;
            ErrMsg = '';
            //LoadDiv = $("#fulagtdiv").attr("id");
            Error = fnconstChkMandatory(dvid);
            pinError = $("#" + dvid + " #comp-help").find("input[name=helptext]").val();            
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
            if (pinError == "") {
                ErrMsg = ErrMsg == "" ? "Pincode required!!" : ErrMsg + "Pincode required";
            }
            if (pinError != "") {
                if (pinError != $("#" + dvid).find("input[key=agt_pin]").val()) {
                    ErrMsg = ErrMsg == "" ? "Valid Pincode required!!" : ErrMsg + "Valid Pincode required";
                }
            }
            if (ErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? "<b>Property" + (n + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Property" + (n + 1) + "</b><br/>" + ErrMsg;
            }
        }

        for (var k = 0; k < MaxAdrTab; k++) {
            var dvidA = "";
            dvidA = "agt_addr_content_" + k;
            ErrMsg = '';
            //LoadDiv = $("#fulagtdiv").attr("id");
            var applError = fnconstChkMandatory(dvidA);
            pinAppError = $("#" + dvidA + " #comp-help").find("input[name=helptext]").val();
            if (applError != "") {
                ErrMsg = ErrMsg == "" ? applError : ErrMsg + applError;
            }            
            if ($("#" + dvidA).attr("contentchanged") == "true"){
            if (pinAppError == "") {
                ErrMsg = ErrMsg == "" ? "Pincode required!!" : ErrMsg + "Pincode required";
                }
            }
            if (pinAppError != "") {
                if (pinAppError != $("#" + dvidA).find("input[key=agt_app_pin]").val()) {
                    ErrMsg = ErrMsg == "" ? "Valid Pincode required!!" : ErrMsg + "Valid Pincode required";
                }
            }

            if (ErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? "<b>Address" + (k + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Address" + (k + 1) + "</b><br/>" + ErrMsg;
            }
        }
        


        if ($("#fldinsres").attr('selval') == -1) {
            FinErrMsg = FinErrMsg == "" ? "Field investigation(Residence) Required !!"  : FinErrMsg + "<br/>Field investigation(Residence) Required !!";
        }
        if ($("#fldofzid").attr('selval') == -1) {
            FinErrMsg = FinErrMsg == "" ? "Field investigation(Office) Required!!" : FinErrMsg + "<br/>Field investigation(Office) Required!!";
        }
        if ($("#docverid").attr('selval') == -1) {
            FinErrMsg = FinErrMsg == "" ? "Document Verification Required!!" : FinErrMsg + "<br/>Document Verification Required!!";
        }
        if ($("#colfedbackid").attr('selval') == -1 && Agt_LnAmt > Number(gConfig["gColFB"])) {
            FinErrMsg = FinErrMsg == "" ? "Collection Feedback Required!!" : FinErrMsg + "<br/>Collection Feedback Required!!";
        }
        if ($("#legalverid").attr('selval') == -1) {
            FinErrMsg = FinErrMsg == "" ? "Legal Verification Required!!" : FinErrMsg + "<br/>Legal Verification Required!!";
        }

        if (IsAgtLapTrig) {

            var ReqdValidation = 0;
            var OldPropNo = 0;
            var PropNo = 0;

            var LapAgtCnt = $("#agent-div .tech_div").length;
            for (var j = 0; j < LapAgtCnt; j++) {
                OldPropNo = PropNo;
                PropNo = Number($("#div_tech_ver_" + j).attr("prop")) + 1;
                var selStringId = "#techverid_" + j;
                var selVal = $(selStringId).attr('selval');
                var cmpErrMsg = "";

                if (OldPropNo != PropNo)
                    ReqdValidation = 0;

                if (selVal == -1 && ReqdValidation == 0) {
                    ReqdValidation = 1;
                    FinErrMsg = FinErrMsg == "" ? "Technical Verification for Property " + PropNo + " Required!!" :
                            FinErrMsg + "<br/>Technical Verification for Property " + PropNo + " Required!!";
                }
                
                if (OldPropNo != PropNo && ReqdValidation == 0) {
                    $("#agent-div .tech_div[prop=" + (PropNo - 1) + "]").each(function () {
                        var id = $(this).attr("id");
                        id = Number(id[id.length - 1]);
                        var cmpStringId = "#techverid_" + id;
                        var Cmp_Val = $(cmpStringId).attr('selval');

                        if (Cmp_Val == selVal && cmpStringId != selStringId) {
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
            if ($("#techverid_0").attr('selval') == -1) {
                FinErrMsg = FinErrMsg == "" ? "Technical Verification Required!!" : FinErrMsg + "<br/>Technical Verification Required!!";
            }
        }
        
        if (FinErrMsg != "") {
            fnShflAlert("error", FinErrMsg);
            return;
        }

        var HdrJson = fngetpropdet("maindiv", 0, count);
        var PGrpFk;
        PGrpFk = $("#prddiv i").attr("pk");
        AdrJson = fnGetFormValsJson_IdVal($(CurSel_div).attr("id"));
        AgtJson = fnGetGridVal("agt_DtlInfo", "");
        var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["INSERT_AGT", JSON.stringify(AgtGlobal), JSON.stringify(HdrJson), JSON.stringify(AgtJson), JSON.stringify(AdrJson), "", PGrpFk, IsAgtLapTrig] };
        fnCallLOSWebService("DATA_SAVE", objProcData, fnAgtTrig, "MULTI", "");

}

    /*CHANGE(MUTHU)17/12/16*/
    function fnagtgprdicon() {
        
        var objProcData = { ProcedureName: "PrcShflAgtTrig", Type: "SP", Parameters: ["SEL_PRD", JSON.stringify(AgtGlobal)] };
        fnCallLOSWebService("Sel_icon_Prd", objProcData, fnAgtTrig, "MULTI", "");
    }
    /*END*/
  
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

    