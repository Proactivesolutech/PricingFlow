var LEGALGlobal = [{}];
var Action = '';
var IsFinalConfirm = "";
var ActualPrpCnt = 0;
var propdivcount = 0;
$(document).ready(function () {
    console.log("post");
    
    LEGALGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    LEGALGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    LEGALGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    LEGALGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    LEGALGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    LEGALGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    LEGALGlobal[0].AgtFk = GlobalXml[0].AgtFk; 
    LEGALGlobal[0].LeadId = GlobalXml[0].LeadID;
    LEGALGlobal[0].AppNo = GlobalXml[0].AppNo;
    LEGALGlobal[0].BranchNm = GlobalXml[0].Branch;
    LEGALGlobal[0].AgtNm = GlobalXml[0].AgtNm;
    LEGALGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    LEGALGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    LEGALGlobal[0].Approver = "";
    selectfocus();
    fnLegalLoadLeadDetails();
});
$(function () {
    
    var isBC = window.FromBranchCredit;
    var isCO = window.CREDIT_APPROVER_NO;
    isCO = isCO ? isCO : "";
    isBC = isBC ? isBC : "";
    if (isCO == "" && isBC == "") {
        
        fnCallScrnFn = function (FinalConfirm) {
            var Cur_div_val;
            $("#Legal_Approver").find(".div_content").each(function () {
                if ($(this).is(":visible")) {
                    Cur_div_val = $(this).attr("val");
                    $("#mainlegal_" + Cur_div_val).attr("check", "y");
                }
            });
            IsFinalConfirm = FinalConfirm;
            if (IsFinalConfirm == "true" && ActualPrpCnt != PropDvCnt) {
                Cur_div_val = 0;
                //fnShflAlert("error", "Some of the properties not yet verified. So, Confirm and Handover is not possible");
                //return;
            }
            if (IsFinalConfirm == "true")
            {
                debugger
                if(window.legalflg != undefined)
                {
                    LEGALGlobal[0].Approver = "A";
                }
            }
           
            fnlegalconfirmscreen(Cur_div_val);
        }
    }
});

function fnLegalLoadLeadDetails() {
    
    var objProcData = { ProcedureName: "PrcShflLegalVerification", Type: "SP", Parameters: ['Load', JSON.stringify(LEGALGlobal)] }
    fnCallLOSWebService("LEGAL_DTLS", objProcData, fnLEGALResult, "MULTI");
}
function fnLEGALResult(ServDesc, Obj, Param1, Param2) {

    if (ServDesc == "MANUALDEV_DATA") {
        var DevList = JSON.parse(Obj.result_1);
        var SelectedList = JSON.parse(Obj.result_2);
        fnSetDeviationData('man_deviation_LM', DevList, SelectedList);
    }
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServDesc == "Data_Save") {
        
        if (IsFinalConfirm != "") {
           // fnShflAlert("error", "Some of the properties not yet verified. So, Confirm and Handover is not possible");
            fnCallFinalConfirmation(IsFinalConfirm);
        }
    }

    if (ServDesc == "LEGAL_DTLS") {
        
        var HdrInfo = JSON.parse(Obj.result_1);
        var adrInfo = JSON.parse(Obj.result_2);
        var propsts = JSON.parse(Obj.result_3);
        var ownership = JSON.parse(Obj.result_4);
        var buildinfo = JSON.parse(Obj.result_5);
        var chck = JSON.parse(Obj.result_6);
        var prpcount = JSON.parse(Obj.result_7);
        ActualPrpCnt = prpcount[0].PrpCnt;
     
        if (HdrInfo[0] && HdrInfo[0] != null) {
            if (LEGALGlobal[0].LeadId.indexOf('<br/>') > 0) {
                var ledid = LEGALGlobal[0].LeadId.split('<br/>');
                $('#Leg_leadid').text(ledid[0]);
            }
            else {
                $("#Leg_leadid").text(LEGALGlobal[0].LeadId);
            }
            //$("#Leg_leadid").text(HdrInfo[0].Leg_leadid);
            $("#leg_applicant").text(LEGALGlobal[0].LeadNm);
            $("#leg_appno").text(HdrInfo[0].leg_appno);
            $("#leg_brnch").text(HdrInfo[0].leg_brnch);
            $("#leg_agency").text(HdrInfo[0].leg_agency);
            $("#leg_loanamt").text(HdrInfo[0].Loanamt);
            //$("#leg_dob").val(HdrInfo[0].rptdt);
        }
       
        if(adrInfo.length > 0)
        {
            fnaddprop(adrInfo, ownership, buildinfo, propsts, chck);
        }
        $("#agents-popup").find("input,button,select,textarea").attr("disabled", true);
       /* if (adrInfo[0] && adrInfo[0] != null) {
            $("#Leg_flatno").text(adrInfo[0].Leg_flatno);
            $("#Leg_build").text(adrInfo[0].Leg_build);
            $("#Leg_plotno").text(adrInfo[0].Leg_plotno);
            $("#Leg_street").text(adrInfo[0].Leg_street);
            $("#Leg_land").text(adrInfo[0].Leg_land);
            $("#Leg_town").text(adrInfo[0].Leg_town);
            $("#Leg_district").text(adrInfo[0].Leg_district);
            $("#Leg_state").text(adrInfo[0].Leg_state);
            $("#Leg_pin").text(adrInfo[0].Leg_pin);
        }*/
     
       
      
        //if (propertyval.length > 0)
        //    fnSetValues("propertyval_div", propertyval);
      
        //var lihtml = '';
        //if (ownership[0] && ownership[0] != null) {
        //    if (ownership.length > 0) {
        //        for (var adr = 0; adr < ownership.length; adr++) {
        //            var ownerName = ownership[adr].FirstName + " " + ownership[adr].MiddleName + " " + ownership[adr].LastName;
        //            var pk = ownership[adr].pk;
        //            lihtml = $('<li><input type="checkbox" name="checkbox" onclick="fnaddowner(this)"; key="leg_propertyOwner" pk="' + pk + '" val=0>' +
        //    ' <span> ' + ownerName + '</span>' +
        //                       '</li>');
        //            $("#ownership_div ul.appendul").append(lihtml);
        //        }
        //    }
        //}
        
       
        //if (buildinfo.length > 0)
        //if (buildinfo[0].leg_status == 0) {
        //    $("#rptsts").attr("class", "icon-negative");
        //    $("#rptsts").closest("div.bg").attr("class", "bg bg2");

        //}
        //else if (buildinfo[0].leg_status == 1) {
        //    $("#rptsts").attr("class", "icon-no-status");
        //    $("#rptsts").closest("div.bg").attr("class", "bg bg7");

        //}
        //else if (buildinfo[0].leg_status == 2) {
        //    $("#rptsts").attr("class", "icon-positive");
        //    $("#rptsts").closest("div.bg").attr("class", "bg bg1");

        //}
            //fnSetValues("dd", buildinfo);


     
     
        //if (chck.length > 0) {
        //    
        //    for (var i = 0; i < chck.length; i++) {
                
        //        $(".appendul").find("li input[type=checkbox]").each(function () {
        //            if (chck[i].pk == $(this).attr("pk")) {
        //                $(this).attr('checked', 'checked');
        //                $(this).attr("val", 1);
        //            }
        //        });
        //    }
        //}
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
        //$("div.popup.documents").show();
    }
    if (ServDesc == "Select_Dev") {
        var ManDev = JSON.parse(Obj.result);
        $("#DeviationLvl").val("");
        $("#DeviationRmks").val("");
        if (ManDev.length > 0) {
            $("#DeviationLvl").val(ManDev[0].leg_deviationLvl).trigger("change.select2");
            $("#DeviationRmks").val(ManDev[0].leg_DeviationRmks);
        }
        $("#manualdev-popup-L").show();
    }
    if (ServDesc == "Save_Deviation") {
        $('#manualdevlegal').hide();
       
    }

}
function fnaddowner(SelObj)
{
    if ($(SelObj).attr("val") == 0) {
        $(SelObj).attr("val", 1);
    }
    else
    {
        $(SelObj).attr("val", 0);
    }
   
    //if ($(SelObj).attr("checked") == 'checked')
    //{
    //    var AppJson = [], OwnerArray = [];
    //    var OwnerData = {};
    //    AppJson = fnGetFormValsJson_IdVal("dd");
    //    OwnerData = { 'pk': $(SelObj).attr("pk") };
    //    OwnerArray.push(OwnerData);
    //    var objProcData =
    //       {
    //           ProcedureName: "PrcShflLegalVerification",
    //           Type: "SP",
    //           Parameters:
    //           [
    //               'D', JSON.stringify(LEGALGlobal), JSON.stringify(AppJson), JSON.stringify(OwnerArray)
    //           ]
    //       };
    //    fnCallLOSWebService("delete", objProcData, fnLEGALResult, "MULTI");
    //    $(SelObj).removeAttr("checked");
    //}
}

function fnlegalconfirmscreen(Cur_Div)
{
    var ErrMsg = '';
    var FinErrMsg = '';
    if (GlobalXml[0].IsAll != "1") {       
       //ErrMsg = fnChkMandatory("propertyval_div");
        //var searchpd = $("#propertyval_div").find("[key = 'leg_serachperiod']").val();
     
        for (n = 0; n < PropDvCnt; n++) {
            var dvid = "";
            dvid = "mainlegal_" + n;
            ErrMsg = '';
            if (IsFinalConfirm == "false") {
                $("#mainlegal_" + Cur_Div).attr("check", "y");
                $("#" + dvid).attr("contentchanged", "false");
                if ($("#" + dvid).attr("check") == "y") { $("#" + dvid).attr("contentchanged", "true"); }
            }
            else { $("#" + dvid).attr("contentchanged", "true"); $("#" + dvid).attr("check", ""); }
            if ($("#" + dvid).attr("contentchanged") == "true") {
                var mainerror = fnconstChkMandatory(dvid);
                ErrMsg = ErrMsg == "" ? mainerror : ErrMsg + mainerror;
                var boundaryerror = check(dvid);
                ErrMsg = ErrMsg == "" ? boundaryerror : ErrMsg + boundaryerror;     
                var cnt = 0;
                if ($("#" + dvid).find("input[key=leg_ownertype]").attr("selval") == "S") {
                    $("#" + dvid + " .appendul").find("li input[type=checkbox]").each(function () {
                        if ($(this).attr("val") == 1) {
                            cnt++;
                        }
                    });
                    if (parseInt(cnt) > 1) {
                        fnShflAlert("error", "Select any one Property Ownership for property" + (n + 1));
                        return;
                    }

                }
                var jointcnt = 0;
                if ($("#" + dvid).find("input[key=leg_ownertype]").attr("selval") == "J") {
                    $("#" + dvid + " .appendul").find("li input[type=checkbox]").each(function () {
                        if ($(this).attr("val") == 1) {
                            jointcnt++;
                        }
                    });
                    if (parseInt(jointcnt) <= 1) {
                        //ErrMsg == "" ? "Select more than one Property Ownership" : ErrMsg + "Select more than one Property Ownership";
                        fnShflAlert("error", "Select more than one Property Ownership for property" + (n + 1));
                        return;
                    }
                }
                var count = 0;
                var len = $("#" + dvid + " .appendul").find("li input[type=checkbox]").length;
                $("#" + dvid + " .appendul").find("li input[type=checkbox]").each(function () {
                    if ($(this).attr("val") == 0) {
                        count++;
                    }

                });
                if (parseInt(len) == parseInt(count) && $("#" + dvid).find("input[key=leg_ownertype]").attr("selval") != "-1") {
                    fnShflAlert("error","Select Property ownership for property" + (n + 1));
                    return;
                }                
                if($("#" + dvid).find("[key = 'leg_serachperiod']").val() != ""){
                if ($("#" + dvid).find("[key = 'leg_serachperiod']").val() <= 0 || $("#" + dvid).find("[key = 'leg_serachperiod']").val() > 50) {
                    // ErrMsg = ErrMsg == "" ? "Search Period Should be grater than 0" : ErrMsg + "Search Period Should be grater than 0";
                    fnShflAlert("error", "Search Period value should be between 1 to 50 for property" + (n + 1));
                    return;
                }
                }
       
                if (ErrMsg != "") {
                    FinErrMsg = FinErrMsg == "" ? "<b>Property" + (n + 1) + "</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Property" + (n + 1) + "</b><br/>" + ErrMsg;
                }
            }                  
        }
        if (FinErrMsg != "") {
            fnShflAlert("error", FinErrMsg);
            return false;
        }

            //save data
        else {
            var FinalArr = [];
            var owner = [];
            var AppJson = [], OwnerArray = [];
            var OwnerData = {};
            for (k = 0; k < PropDvCnt; k++) {
                
                var finaldata = {};
                var dvid = "";
                dvid = "mainlegal_" + k;
                finaldata = fnGetFormValsJson_IdVal("mainlegal_" + k);
                FinalArr.push(finaldata);
                listItems = $("#mainlegal_" + k + " .appendul").find("li input[type=checkbox]").each(function () {
                    if ($(this).attr("val") == 1) {
                        var value = $("#mainlegal_" + k).attr("propfk");

                        OwnerData = { 'pk': $(this).attr("pk"), 'prpPk': value, 'LpoPk': $(this).attr("LpoPk") };
                        owner.push(OwnerData);
                    }
                });
            }
            AppJson.push(FinalArr);
            OwnerArray.push(owner);

            //var pk = $("#hiddenclass").val();
            //if (pk == "" || pk == undefined) {

            //    Action = 'Save'
            //}
            //else{
            //    Action = 'Edit'
            //}

            var objProcData =
                   {
                       ProcedureName: "PrcShflLegalVerification",
                       Type: "SP",
                       Parameters:
                       [
                           "Save", JSON.stringify(LEGALGlobal), JSON.stringify(AppJson), JSON.stringify(OwnerArray)
                       ]
                   };
            fnCallLOSWebService("Data_Save", objProcData, fnLEGALResult, "MULTI");
        }
    }
}
function fnReprtSts(elem) {

    var cls = $(elem).attr("class");
    if (cls == "icon-positive") {
        $(elem).attr("class", "icon-negative");
        $(elem).parent("div").removeClass("bg1");
        $(elem).parent("div").addClass("bg2");
        $(".changediv").find("input[key=leg_status]").val(0);
    }
    else if (cls == "icon-negative") {
        $(elem).attr("class", "icon-positive");
        $(elem).parent("div").removeClass("bg2");
        $(elem).parent("div").addClass("bg1");
        $(".changediv").find("input[key=leg_status]").val(1);
    }
}
function fnpop() {
    $("#fold_nm").val(GlobalXml[0].LeadID);
    window.open("", "newWin", "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=20,top=20,width=600,height=600");
    PostForm.submit();
}
function fnSelectDocment() {
    
    //$(".popup-bg.document-pop-content div.preview-icons.right").empty();
    //var PrcObj = { ProcedureName: "PrcShflLegalVerification", Type: "SP", Parameters: ["DOCUMENT", JSON.stringify(LEGALGlobal), "", ""] };
    //fnCallLOSWebService("DOCUMENT", PrcObj, fnLEGALResult, "MULTI");
    var objProcData = { ProcedureName: "PrcShflLegalVerification", Type: "SP", Parameters: ['DOCUMENT', JSON.stringify(LEGALGlobal)] }
    fnCallLOSWebService("DOCUMENT", objProcData, fnLEGALResult, "MULTI");
}

//function fnCallScrnFn(FinalConfirm) {
//    IsFinalConfirm = FinalConfirm;
//    if (IsFinalConfirm == "true" && ActualPrpCnt != PropDvCnt) {
//        fnShflAlert("error", "Some of the properties not yet verified. So, Confirm and Handover is not possible");
//        return;
//    }
//    fnlegalconfirmscreen();
//}
$(document).on("keyup", calculate());
function calculate() {

    var sum = 0;
    $(".total").each(function () {
        sum += $(this).val();

    });
    $("#aggreeValue").val(sum);
}


/* changes on 30/11/2016 */
function sum() {
    var astval = $("#leg_assetcst").val();
    var val = Number(FormatCleanComma(astval));
    var regchgval = $("#leg_regChrges").val();
    var val1 = Number(FormatCleanComma(regchgval));
    var stampchgval = $("#leg_StmpdutyChrges").val();
    var val2 = Number(FormatCleanComma(stampchgval));
    var agtval = parseInt(val) + parseInt(val1) + parseInt(val2)
    var total = FormatCurrency(agtval.toString());
    $("#leg_aggreeValue").val(total);
}
function fnReprtSts(elem) {

    var cls = $(elem).attr("class");
    var lihtml = $(elem).closest("div.status");
    if (cls == "icon-positive") {
        $(lihtml).find("div.bg").attr("class", "bg bg2");
        $(lihtml).find("i").attr("class", "icon-negative");
        $(lihtml).find("input[key=leg_status]").val(0);        
    }
    else if (cls == "icon-negative") {
        $(lihtml).find("div.bg").attr("class", "bg bg7");
        $(lihtml).find("i").attr("class", "icon-no-status");
        $(lihtml).find("input[key=leg_status]").val(1);
    }
    else if (cls == "icon-no-status") {
        $(lihtml).find("div.bg").attr("class", "bg bg1");
        $(lihtml).find("i").attr("class", "icon-positive");
        $(lihtml).find("input[key=leg_status]").val(2);
    }
}
function check(boundaryid) {

    var Error = '';
    var east = $("#" + boundaryid).find("[key='Leg_lftEst']").val();
    var west = $("#" + boundaryid).find("[key='Leg_lftWst']").val();
    var south = $("#" + boundaryid).find("[key='Leg_lftNor']").val();
    var north = $("#" + boundaryid).find("[key='Leg_lftSou']").val();
    if (east != "" && west != "" && south != "" && north != "") {
        if (east.toLowerCase() == west.toLowerCase() || east.toLowerCase() == north.toLowerCase() || east.toLowerCase() == south.toLowerCase() || west.toLowerCase() == north.toLowerCase() || west.toLowerCase() == south.toLowerCase() || south.toLowerCase() == north.toLowerCase()) {
            Error = "Boundary Value should not be same !!";
        }
    }
    return Error;
}
function fnaddprop(adrInfo, ownership, buildinfo, propsts, chck)
{
    
    var Class = ""; var val = "mainlegal_0";
    PropDvCnt = adrInfo.length;
    for (var i = 0; i < adrInfo.length; i++) {
        var PropertyHdr = [];
        PropertyHdr.push(adrInfo[i]);

        
    if (i > 0) {
        $("#legal_ul_prop_tabs").append
       (
           "<li class='tab_" + i + "' proplicount = '" + i + "' onclick=fnshowprop(this);><span> Property" + (i + 1) + "</span></li>"
       );

        $("#leg_propDiv").append('<div style="display:none;" id="mainlegal_' + i + '" class="tab' + i + '-content div_content" val="' + i + '" propfk = "' + adrInfo[i].PrpPk + '" contentchanged="true"check=""></div>');
        var content = $("#mainlegal_0").html();
        $("#mainlegal_" + i).html(content);
        val = "mainlegal_" + i;       
        $("#mainlegal_" + i).find("#ownership_div ul.appendul li.ownercheck").empty()
        fnClearForm("mainlegal_" + i);
    }
    else {
        $("#mainlegal_0").attr("propfk", adrInfo[0].PrpPk);
    }

    var lihtml = '';

    if (ownership.length > 0) {
        for (var adr = 0; adr < ownership.length; adr++) {
            var ownerName = ownership[adr].FirstName + " " + ownership[adr].MiddleName + " " + ownership[adr].LastName;
            var pk = ownership[adr].pk;
            lihtml = $('<li class="ownercheck"><input type="checkbox" name="checkbox" LpoPk ="0" onclick="fnaddowner(this)"; key="leg_propertyOwner" pk="' + pk + '" val=0>' +
    ' <span> ' + ownerName + '</span>' +
                       '</li>');
            $("#mainlegal_" + i).find("#ownership_div ul.appendul").append(lihtml);
        }
    }

   
   
    if (propsts.length > 0) {
        
        for (var j = 0; j < propsts.length; j++) {
            var stsdt = [];
            if (adrInfo[i].PrpPk == propsts[j].PrpPk) {
                stsdt.push(propsts[j]);
                fnSetValues("mainlegal_" + i + " .changediv", stsdt);
                if (propsts[j].leg_status == 0) {
                    $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").find("i").attr("class", "icon-negative");
                    $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").attr("class", "bg bg2");

                }
                else if (propsts[j].leg_status == 1) {
                    $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").find("i").attr("class", "icon-no-status");
                    $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").attr("class", "bg bg7");

                }
                else if (propsts[j].leg_status == 2) {
                    $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").find("i").attr("class", "icon-positive");
                    $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").attr("class", "bg bg1");

                }

            }
        }

    }
    if (buildinfo.length > 0) {
        
        var infordtl = []
        for (var k = 0; k < buildinfo.length; k++) {
            if (adrInfo[i].PrpPk == buildinfo[k].PrpPk) {
                infordtl.push(buildinfo[k]);
                if (buildinfo.length > 0) {
                    if (buildinfo[k].leg_status == 0) {
                        $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").find("i").attr("class", "icon-negative");                        
                        $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").attr("class", "bg bg2");

                    }
                    else if (buildinfo[k].leg_status == 1) {
                        $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").find("i").attr("class", "icon-no-status");
                        $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").attr("class", "bg bg7");

                    }
                    else if (buildinfo[k].leg_status == 2) {
                        $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").find("i").attr("class", "icon-positive");
                        $("#mainlegal_" + i).find("[key='leg_status']").closest("div.bg").attr("class", "bg bg1");
                    }
                    fnSetValues("mainlegal_" + i, infordtl);
                }
            }
        }
    }

    
    if (chck.length > 0) {

        
            for (var L = 0; L < chck.length; L++) {
                if (adrInfo[i].PrpPk == chck[L].PrpPk) {
                    $("#mainlegal_" + i +" .appendul").find("li input[type=checkbox]").each(function () {

                        if (chck[L].pk == $(this).attr("pk")) {
                            $(this).attr('checked', 'checked');
                            $(this).attr("val", 1);
                            $(this).attr("LpoPk", chck[L].LpoPk);
                        }

                    });
                
            }
        }
    }

    fnSetValues("mainlegal_" + i, PropertyHdr);
    }
}
function fnshowprop(elem) {
    
    var prvDiv = $("#legal_ul_prop_tabs").find(".active").attr("proplicount");
    var DivValue = fnCheckleg_IdVal("mainlegal_" + prvDiv);
    var dvid = "";
    dvid = "mainlegal_" + prvDiv;
    if (DivValue > 0) {  
        var ErrMsg = '';
        $("#" + dvid).attr("check", "y");
        var mainerror = fnconstChkMandatory(dvid);
        ErrMsg = ErrMsg == "" ? mainerror : ErrMsg + mainerror;
        var boundaryerror = check(dvid);
        ErrMsg = ErrMsg == "" ? boundaryerror : ErrMsg + boundaryerror;
        if (ErrMsg != "") {
            fnShflAlert("error", "<b>Property" + (Number(prvDiv) + 1) +"</b><br/>" + ErrMsg);
            return false;
        }
        var cnt = 0;
        if ($("#" + dvid).find("input[key=leg_ownertype]").attr("selval") == "S") {
            $("#" + dvid + " .appendul").find("li input[type=checkbox]").each(function () {
                if ($(this).attr("val") == 1) {
                    cnt++;
                }
            });
            if (parseInt(cnt) > 1) {
                fnShflAlert("error", "Select any one Property Ownership for property" + (Number(prvDiv) + 1));
                return;
            }

        }
        var jointcnt = 0;
        if ($("#" + dvid).find("input[key=leg_ownertype]").attr("selval") == "J") {
            $("#" + dvid + " .appendul").find("li input[type=checkbox]").each(function () {
                if ($(this).attr("val") == 1) {
                    jointcnt++;
                }
            });
            if (parseInt(jointcnt) <= 1) {
               // ErrMsg == "" ? "Select more than one Property Ownership" : ErrMsg + "Select more than one Property Ownership";
                fnShflAlert("error", "Select more than one Property Ownership for property" + (Number(prvDiv) + 1));
                return;
            }
        }
        var count = 0;
        var len = $("#" + dvid + " .appendul").find("li input[type=checkbox]").length;
        $("#" + dvid + " .appendul").find("li input[type=checkbox]").each(function () {
            if ($(this).attr("val") == 0) {
                count++;
            }

        });
        if (parseInt(len) == parseInt(count)) {
            fnShflAlert("error","Select Property ownership for property" + (Number(prvDiv) + 1));
            return;
        }
        if ($("#" + dvid).find("[key = 'leg_serachperiod']").val() != "") {
        if ($("#" + dvid).find("[key = 'leg_serachperiod']").val() <= 0 || $("#" + dvid).find("[key = 'leg_serachperiod']").val() > 50) {
           // ErrMsg = ErrMsg == "" ? "Search Period Should be grater than 0" : ErrMsg + "Search Period Should be grater than 0";
            fnShflAlert("error", "Search Period value should be between 1 to 50 for property" + (Number(prvDiv) + 1));
            return;
        }
    }
        //if ($("#" + dvid).find("[key = 'leg_serachperiod']").val() <= 0 && $("#" + dvid).find("[key = 'leg_serachperiod']").val() != "" && $("#" + dvid).find("[key = 'leg_serachperiod']").val() > 50) {
        //    // ErrMsg = ErrMsg == "" ? "Search Period Should be grater than 0" : ErrMsg + "Search Period Should be grater than 0";
        //    fnShflAlert("error", "Search Period value should be between 1 to 50 for property" + (n + 1));
        //    return;
        //}
    }
    else { $("#" + dvid).attr("check", ""); }
    var value = $(elem).attr("class").split("_");
    var cur_div = $("#leg_propDiv").find("#mainlegal_" + value[1]);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div").css("display", "none")
    $(".tab_" + value[1]).addClass("active");
    $(".tab_" + value[1]).siblings("li").removeClass("active");
}


function fnOpenManualDev() {
    
    //var objProcData = { ProcedureName: "PrcShflLegalVerification", Type: "SP", Parameters: ['Select_Dev', JSON.stringify(LEGALGlobal)] }
    //fnCallLOSWebService("Select_Dev", objProcData, fnLEGALResult, "MULTI");

    $("#manualdevlegal").show();
    fnSelManualDev_ZC();
}
function fnSelManualDev_ZC() {
    var PrcObj = { ProcedureName: "PrcShflManualDeviation", Type: "SP", Parameters: ["MANUALDEV_DATA", JSON.stringify(LEGALGlobal), "", "L"] };
    fnCallLOSWebService("MANUALDEV_DATA", PrcObj, fnLEGALResult, "MULTI");
}
function fnCnfmManualDeviation(divid) {
    
    //var DevArr = [];
    //var DevObj = {};
    //var DevVal = $("#DeviationLvl").val();
    //var DevRemarks = $("#DeviationRmks").val();
    //if ($("#DeviationLvl option:selected").text().trim() == "Select" || $("#DeviationLvl option:selected").text().trim() == "" || DevRemarks == "") { fnShflAlert("error", "All Fields are Required in Deviation"); return; }
    //DevObj["leg_deviationLvl"] = DevVal;
    //DevObj["leg_DeviationRmks"] = DevRemarks;

    //DevArr.push(DevObj);
    //var PrcObj = { ProcedureName: "PrcShflLegalVerification", Type: "SP", Parameters: ['Save_Deviation', JSON.stringify(LEGALGlobal), "", "", JSON.stringify(DevArr)] };
    //fnCallLOSWebService("Save_Deviation", PrcObj, fnLEGALResult, "MULTI");
    var selval = $("#ManualDeviationlegal").val();
    if (selval == 0) {
        fnShflAlert("error", "Deviations Level Required!!");
        return;
    }
    fnSaveManualDeviation('man_deviation_LM', 'L', fnLEGALResult, 'Save_Deviation', LEGALGlobal)
}
function fnCheckleg_IdVal(FormID, IsClass) {

    var KeyVal = "";
    var KeyJsonTxt = "";
    var IsKeyExists = 0;
    var KeyValObj = ""
    var AppendOperator = "#";
    var chkCount = 0;
    if (IsClass == 1) { AppendOperator = "." }
    $(AppendOperator + FormID + " [name='text']").each(function () {
        if (!($(this).is("[key]"))) { return; }
        if ($(this).hasClass("currency")) {
            $(this).val(FormatCleanComma($(this).val().trim()));
        }
        var AssignValue = $(this).val().trim();

        if (AssignValue == "") { if ($(this).is("[value]")) AssignValue = $(this).attr("value"); }
        IsKeyExists = 1;
        KeyVal = AssignValue;
        if ($(this).attr("key") == "rptdt" || $(this).attr("key") == "leg_status" || $(this).attr("key") == "PrpPk" || $(this).attr("key") == "hiddenkey" || KeyVal == 0 || $(this).attr("key") == "propfk") {
            KeyVal = "";
        }
        if (KeyVal != "") { chkCount++; }
    });
    $(AppendOperator + FormID + " [name='select']").each(function () {
        if (!($(this).is("[key]"))) { return; }
        IsKeyExists = 1;
        var keyTxt = $(this).attr("key");
        var keyVal = $(this).attr("selval");
        if (keyVal == "") { keyVal = -1; }
        if (keyVal != -1) { chkCount++; }

    });
    $(AppendOperator + FormID + " [name='checkbox']").each(function () {     
            if (!($(this).is("[key]"))) { return; }
            IsKeyExists = 1;
            var keyTxt = $(this).attr("key");
            var keyVal = ($(this).is(":checked")) ? 0 : 1;
            if (keyVal == 0) { chkCount++; }
        
    });
    return chkCount;
}
function fnconstChkMandatory(FormID) {
    var MandatoryMsg = "";
    var AppendOperator = "#";

    $(AppendOperator + FormID + "[contentchanged='true'] .mandatory").each(function () {
        var lbl_sibling; var label = "";

        if ($(this).parents("[contentchanged='false']").length > 0) {
        }
        else {
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
        }
    });

    return MandatoryMsg;
}
