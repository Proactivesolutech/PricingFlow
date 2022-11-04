var LedAgtGlobal = [{}];
var Action = ''
var IsFinalConfirm = "";
var PropDvCnt = 0;
var ActualPrpCnt = 0;


$(document).ready(function () {
    LedAgtGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    LedAgtGlobal[0].LeadId = GlobalXml[0].LeadID;
    LedAgtGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    LedAgtGlobal[0].AppNo = GlobalXml[0].AppNo;
    LedAgtGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    LedAgtGlobal[0].BranchNm = GlobalXml[0].Branch;
    LedAgtGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    LedAgtGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    LedAgtGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    LedAgtGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    LedAgtGlobal[0].PrdGrpFk = GlobalXml[0].PrdGrpFk;
    LedAgtGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    LedAgtGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    LedAgtGlobal[0].GrpCd = GlobalXml[0].GrpCd;
    
    LedAgtGlobal[0].Approver = "";
    if (LedAgtGlobal[0].PrdCd == "HLImp" || LedAgtGlobal[0].PrdCd == "HLExt") {
        $("#maintechnical_0 .extension").show();
        $("#maintechnical_0 .extension").find("input[name='text']").addClass("mandatory");
    }
    else if (LedAgtGlobal[0].PrdCd == "HL" || LedAgtGlobal[0].PrdCd == "LAP" || LedAgtGlobal[0].PrdCd == "PL") {
        $("#maintechnical_0 .extension").show();
        $("#maintechnical_0 .extension").find("input[name='text']").removeClass("mandatory");
    }
    else {
        $("#maintechnical_0 .extension").hide();
        $("#maintechnical_0 .extension").find("input[name='text']").removeClass("mandatory");
    }
    fnSelTechnicalLead();
    selectfocus();
  
});
$(function () {
    var isBC = window.FromBranchCredit;
    var isCO = window.CREDIT_APPROVER_NO;
    isCO = isCO ? isCO : "";
    isBC = isBC ? isBC : "";
    if (isCO == "" && isBC == "") {
        fnCallScrnFn = function (FinalConfirm) {
            
           var Cur_div_val;
            $("#Tech_approver").find(".div_content").each(function () {
                if ($(this).is(":visible")) {
                    Cur_div_val = $(this).attr("val");
                    $("#maintechnical_" + Cur_div_val).attr("check", "y");
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
                if(window.techflg != undefined)
                {
                    LedAgtGlobal[0].Approver = "A";
                }
            }
            fntechapprconfirmscreen(Cur_div_val);
        }
    }
});

function fnSelTechnicalLead() {
    var PrcObj = { ProcedureName: "PrcShflTechApprover", Type: "SP", Parameters: ["S", JSON.stringify(LedAgtGlobal)] };
    fnCallLOSWebService("SEL-LEAD", PrcObj, fnTechnicalFinResult, "MULTI");
}
function fnTechnicalFinResult(ServiceFor, Obj, Param1, Param2) {

    if (ServiceFor == "MANUALDEV_DATA") {
        var DevList = JSON.parse(Obj.result_1);
        var SelectedList = JSON.parse(Obj.result_2);
        fnSetDeviationData('man_deviation_TM', DevList, SelectedList);
    }
    if (ServiceFor == "ADD_MANUALDEV") {

    }

    if (!Obj.status) {
        fnShflAlert("error", Obj.error);
        return;
    }
   
    if (ServiceFor == "I") {
        if (IsFinalConfirm != "") {
            fnCallFinalConfirmation(IsFinalConfirm);
        }
    }

    if (ServiceFor == "SEL-LEAD") {
            
        var leadData = JSON.parse(Obj.result_1);
        var HdrInfo = JSON.parse(Obj.result_2);
        var techInfo = JSON.parse(Obj.result_3);
        var prpcnt = JSON.parse(Obj.result_4);    
        ActualPrpCnt = prpcnt[0].PrpCnt;
        
        var prdli = '';
        if (leadData[0] && leadData[0] != null) {
            $("#PrdName").attr("ProductFk", leadData[0].ProductFk);
            $("#PrdName").text(leadData[0].ProductName);
            if (leadData[0].LeadId.indexOf('<br/>') > 0) {
                var ledid = leadData[0].LeadId.split('<br/>');
                $('#LeadId').text(ledid[0]);
            }
            else {
                $("#LeadId").text(leadData[0].LeadId);
            }
            $("#LeadName").text(leadData[0].LeadNm);
            $("#Appno").text(leadData[0].AppNo);
            $("#BranchNm").attr("BranchFk", leadData[0].BranchFk);
            $("#BranchNm").text(leadData[0].BranchNm);
            prdli += '<i grpprdFk = "' + leadData[0].LedPGrpFk + '"class="' + leadData[0].GrpIconCls + '"></i><p prdfk="0" name ="content" id="PrdName">' + leadData[0].GrpNm + '</p>'
            $("#tech_product").append(prdli);
        }

        if (leadData[0].GrpIconCls == "icon-plot-loan") {
            $("#seltypprop li.pro-flat").remove();
            $("#seltypprop li.pro-independant").remove();
            $(".plot").show();
            $(".flat,.independant").hide();
            $("#plotdisp").hide();
            $(".tab5").css("display", "none");
        }

        if (HdrInfo.length > 0) {            
            fnAddPropTab(HdrInfo, techInfo);
        }
        $("#agents-popup").find("input,button,select,textarea").attr("disabled", true);
        $("#agents-popup-BC").find("input,button,select,textarea").attr("disabled", true);
    }

    if (ServiceFor == "DOCUMENT") {

        var ul_list = "";
        $("div.popup.documents.attach-icon.doc-list-view").empty();
        var Data = JSON.parse(Obj.result);
        for (var i = 0; i < Data.length; i++) {
            ul_list += '<ul pk="' + Data[i].Pk + '"><li>' + Data[i].DocName + '<p><span class="bg">' + Data[i].Actor + '</span><span class="bg">' + Data[i].Catogory + '</span> <span class="bg">' + Data[i].SubCatogory + '</span></p>' +
            '</li><li><i class="icon-document doc-view" docpath="' + Data[i].DocPath + '" onclick="fnOpenDocs(this)" ></i></li><li><i class="icon-delete"></i></li></ul>';
        }
        $("div.popup.documents.attach-icon.doc-list-view").append(ul_list);
    }

    if (ServiceFor == "Save_Deviation") {
        $("#manualdev").hide();
        $('#Deviation_Popup_T').hide();
    }
    if (ServiceFor == "Select_Dev") {
        
        var ManDev = JSON.parse(Obj.result);
        $("#DeviationLvl_T").val("");
        $("#DeviationRmks_T").val("");
        if (ManDev.length > 0) {
            $("#DeviationLvl_T").val(ManDev[0].tech_deviationLvl).trigger("change.select2");
            $("#DeviationRmks_T").val(ManDev[0].tech_DeviationRmks);
        }
        $("#Deviation_Popup_T").show();
     
    }

    
}

function fnAddPropTab(HdrInfo, techInfo) {    
    var Class = ""; var val = "maintechnical_0";
    
    for (var i = 0; i < HdrInfo.length; i++) {
        var PropertyHdr = [];
        PropertyHdr.push(HdrInfo[i]);
        var PrpString = "Property " + HdrInfo[i].tech_prop + " [Valuation " + HdrInfo[i].tech_valuation + "]";
        var seltypHtml = "";
        if (LedAgtGlobal[0].GrpCd.toUpperCase() == "LAP") {
            $("#maintechnical_0").find("li.pro-plot").remove();
            seltypHtml = "<li val='0' class='pro-flat' dvid=" + i + " onclick=fnPrpTypeSelection(this);>Flat</li><li val='2' class='pro-independant' dvid=" + i + " onclick=fnPrpTypeSelection(this);>Independant</li>"
        }
        else {
            seltypHtml = "<li val='0' class='pro-flat' dvid=" + i + " onclick=fnPrpTypeSelection(this);>Flat</li><li val='1' class='pro-plot' dvid=" + i + " onclick=fnPrpTypeSelection(this);>Plot</li><li val='2' class='pro-independant' dvid=" + i + " onclick=fnPrpTypeSelection(this);>Independant</li>"
        }

        if (i > 0) {

            $("#tech_ul_prop_tabs").append
           (
               "<li class='tab_" + i + "' PrpliCount ='" + i + "' onclick='fnshowprop(this);'><span> " + PrpString + " </span></li>"
           );

            $("#PropTabs").append('<div style="display:none;" valn="' + HdrInfo[i].tech_valuation + '" prop="' + HdrInfo[i].tech_prop + '" id="maintechnical_' + i + '" class="tab' + i + '-content div_content" val="' + i + '" propfk = "' + HdrInfo[i].prp_pk + '" contentchanged="true"check=""></div>');
            var content = $("#maintechnical_0").html();
            $("#maintechnical_" + i).html(content);
            $("#maintechnical_" + i + " .occupancy").empty();

            val = "maintechnical_" + i;

            $("#maintechnical_" + i + " .seltypprop").empty();
            $("#maintechnical_" + i + " .seltypprop").append(seltypHtml);                                               
            fnClearForm("maintechnical_" + i);
        }
        else {

           $("#maintechnical_0").attr("propfk", HdrInfo[0].prp_pk);
            $("#maintechnical_0").find("input[key='propfk']").val(HdrInfo[0].prp_pk);
            $(".tab_0").html(PrpString);
        }

        $("#maintechnical_" + i + " .propdetul").empty();
        $("#maintechnical_" + i + " .propdetul").append
          (
            "<li class='active tab3_" + i + "' onclick=fnshowpropdetails(this);>Property Valuation</li><li class='tab4_" + i + "' onclick=fnshowpropdetails(this);>Property Details</li><li class='tab5_" + i + "' onclick=fnshowpropdetails(this);>Construction Details</li>"
          );
        
        if (HdrInfo[i].tech_status == 0) {
            $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").find("i").attr("class", "icon-negative");
            $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").attr("class", "bg bg2");

        }
        else if (HdrInfo[i].tech_status == 1) {
            $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").find("i").attr("class", "icon-no-status");
            $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").attr("class", "bg bg7");

        }
        else if (HdrInfo[i].tech_status == 2) {
            $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").find("i").attr("class", "icon-positive");
            $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").attr("class", "bg bg1");

        }
        fnSetValues("maintechnical_" + i, PropertyHdr);
        $("#maintechnical_" + i).find("input[key='propfk']").val(HdrInfo[i].prp_pk);
        if (techInfo.length > 0) {
            
            for (var j = 0; j < techInfo.length; j++) {
                var PropertyDet = [];
                
                if (HdrInfo[i].prp_pk == techInfo[j].PrpFk && HdrInfo[i].tech_valuation == techInfo[j].apr_valuation) {
                    PropertyDet.push(techInfo[j]);
                    var lihtml = ''

                    if (techInfo[j].tech_proptyp == 0) {
                        lihtml += '<li val="S">Self Occupied</li><li val="L">Let Out</li><li val="I">Investment</li><li val="U">UnderConstruction</li>';
                        $("#maintechnical_" + i + " .occupancy").append(lihtml);
                        fnSetValues("maintechnical_" + i + " .maindiv-technical_flat", PropertyDet);
                        $("#maintechnical_" + i + " .flat").show();
                        $("#maintechnical_" + i + " .plot," + "#maintechnical_" + i + " .independant").hide();
                     
                    }
                    if (techInfo[j].tech_proptyp == 1) {
                        lihtml += '<li val="V">Vacant</li><li val="U">UnderConstruction</li>';                       
                        $("#maintechnical_" + i + " .occupancy").append(lihtml);
                        fnSetValues("maintechnical_" + i + " .maindiv-technical_plot", PropertyDet);
                        $("#maintechnical_" + i + " .plot").show();
                        $("#maintechnical_" + i + " .flat," + "#maintechnical_" + i + " .independant").hide();
                        $("#maintechnical_" + i + " .plotdisp").hide();

                        $("#maintechnical_" + i + " .tab5_" + i).css("display", "none");
                    }
                    if (techInfo[j].tech_proptyp == 2) {
                        lihtml += '<li val="S">Self Occupied</li><li val="L">Let Out</li><li val="I">Investment</li><li val="U">UnderConstruction</li>';
                        $("#maintechnical_" + i + " .occupancy").append(lihtml);
                        fnSetValues("maintechnical_" + i + " .maindiv-technical_independant", PropertyDet);
                        $("#maintechnical_" + i + " .independant").show();
                        $("#maintechnical_" + i + " .flat," + "#maintechnical_" + i + " .plot").hide();
                    }
                    if (techInfo[j].tech_possessiontyp == 1) {                        
                        $("#maintechnical_" + i + " .lease-period").css('display', 'inline-block');
                    }
                    if (techInfo[j].tech_possessiontyp == 0) {
                        $("#maintechnical_" + i + " .lease-period").css('display', 'none');
                    }
                    fnSetValues("maintechnical_" + i + " .maindiv-technical_prptype", PropertyDet);
                    fnSetValues("maintechnical_" + i + " .maindiv-technical_Construction", PropertyDet);
                    fnSetValues("maintechnical_" + i + " .maindiv-technical_prpval", PropertyDet);
                    fnSetValues("maintechnical_" + i + " .maindiv-technical_common", PropertyDet);
                    fnSetValues("maintechnical_" + i + " .maindiv-technical_boundary", PropertyDet);
                    fnSetValues("maintechnical_" + i + " .common", PropertyDet);

                    if (techInfo[j].tech_status == 0) {
                        $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").find("i").attr("class", "icon-negative");
                        $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").attr("class", "bg bg2");

                    }
       

                    else if (techInfo[j].tech_status == 1) {
                        $("#maintechnical_" + i ).find("[key='tech_status']").closest("div.bg").find("i").attr("class", "icon-no-status");
                        $("#maintechnical_" + i).find("[key='tech_status']").closest("div.bg").attr("class", "bg bg7");

                    }
                    else if (techInfo[j].tech_status == 2) {
                        $("#maintechnical_" + i ).find("[key='tech_status']").closest("div.bg").find("i").attr("class", "icon-positive");
                        $("#maintechnical_" + i ).find("[key='tech_status']").closest("div.bg").attr("class", "bg bg1");

                    }
                }
            }
        }
        //PropDvCnt = HdrInfo[i].tech_prop;
        
        PropDvCnt += 1;
    }
    // Cur_Active_Prop_li = $("#tech_ul_prop_tabs li[val='0']");
}

function fntechapprconfirmscreen(Cur_Div) {
    
    if (GlobalXml[0].IsAll != "1") {
        var ErrMsg = "";
        var buildupvalue;
        var superbldupvalue;
        var carpetvalue;
        var landvalue;
        var stgofConst;
        var buildage;
        var mktval;
        var prpvalue;
        var refno;
        var Propno = 0;
        var Valnno = 0;               
        ErrMsg = "";
        var FinErrMsg = "";
        var FinalArr = []; 
        var PrptmpCnt = Cur_Div;

        
        for (i = 0; i < PropDvCnt; i++) {
            var dvid = "";
            ErrMsg = "";
            dvid = "maintechnical_" + i;
            if (IsFinalConfirm == "false") {
                $("#maintechnical_" + Cur_Div).attr("check", "y");
                $("#" + dvid).attr("contentchanged", "false");
                if ($("#" + dvid).attr("check") == "y") { $("#" + dvid).attr("contentchanged", "true"); }
            }
            else { $("#" + dvid).attr("contentchanged", "true"); $("#" + dvid).attr("check", ""); }
            //$("#" + dvid).attr("check", "");
            stgofConst = $("#" + dvid).find("[key = 'tech_construction']").val();
            mktval = $("#" + dvid).find("[key = 'tech_mktval']").val();
            prpvalue = $("#" + dvid).find("[key = 'tech_proptyp']").attr("selval");
            refno = $("#" + dvid).find("[key = 'tech_Refno']").val();
            Propno = $("#" + dvid).attr("prop");
            Valnno = $("#" + dvid).attr("valn");
            //Validations
            //if (refno <= 0) {
            //    ErrMsg = ErrMsg == "" ? "Reference Number Required!!" : ErrMsg + "<br/>Reference Number Required!!";
            //}
            
            //if (mktval <= 0) {
            //    ErrMsg = ErrMsg == "" ? "Market value Required!!" : ErrMsg + "<br/>Market value Required!!<br/>";
            //}
            var Referror = fnconstChkMandatory(dvid + " .common");
            if (Referror != "") {
                ErrMsg = ErrMsg == "" ? Referror : ErrMsg + Referror;
            }
            var prpvalerror = fnconstChkMandatory(dvid + " .maindiv-technical_prpval");
            if (prpvalerror != "") {
                ErrMsg = ErrMsg == "" ? prpvalerror : ErrMsg + prpvalerror;
            }
            var boundaryerror = fnconstChkMandatory(dvid + " .maindiv-technical_boundary");

            if (boundaryerror != "") {
                ErrMsg = ErrMsg == "" ? boundaryerror : ErrMsg + boundaryerror;
            }

            var prptypeerror = fnconstChkMandatory(dvid + " .maindiv-technical_prptype");
            if (prptypeerror != "") {
                ErrMsg = ErrMsg == "" ? prptypeerror : ErrMsg + prptypeerror;
            }
            
            //Flat
            if (prpvalue == 0) {
                $("#" + dvid).find("[key = 'tech_buildapprauth']").attr("class", "mandatory");
                landvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_UDSarea']").val();
                buildupvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_buildarea']").val();
                superbldupvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_supbuildarea']").val();
                carpetvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_carpetarea']").val();                                          
                var flaterr = fnconstChkMandatory(dvid + " .maindiv-technical_flat");
                
                if (landvalue != "" && $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_udsmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "UDS Area Measurement Required!!</br>" : ErrMsg + "UDS Area Measurement Required!!</br>"; }
                if (buildupvalue != "" && $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_buildupmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "Buildup Area Measurement Required!!</br>" : ErrMsg + "Buildup Area Measurement Required!!</br>"; }
                if (superbldupvalue != "" && ($("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_supbuildmmt']").val() == ""))
                { ErrMsg = ErrMsg == "" ? "SuperBuildUp Area Measurement Required!!</br>" : ErrMsg + "SuperBuildUp Area Measurement Required!!</br>"; }
                if (carpetvalue != "" && $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_carpetmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "Carpet Area Measurement Required!!</br>" : ErrMsg + "Carpet Area Measurement Required!!</br>"; }

                ErrMsg = ErrMsg == "" ? flaterr : ErrMsg + flaterr;

                var consterr = fnconstChkMandatory(dvid + " .maindiv-technical_Construction");
                if ($("#" + dvid + " .maindiv-technical_Construction").find("[key = 'tech_buildingage']").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Age of Building Required !!" : ErrMsg + "Age of Building Required !!";
                }
                ErrMsg = ErrMsg == "" ? consterr : ErrMsg + consterr;
            }
                //Plot
            else if (prpvalue == 1) {
                $("#" + dvid).find("[key = 'tech_buildapprauth']").attr("class", "");
                var ploterr = fnconstChkMandatory(dvid + " .maindiv-technical_plot");
                ErrMsg = ErrMsg == "" ? ploterr : ErrMsg + ploterr;
            }
                //Independent
            else if (prpvalue == 2) {
                $("#" + dvid ).find("[key = 'tech_buildapprauth']").attr("class", "mandatory");
                landvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_landarea']").val();
                buildupvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_buildarea']").val();
                superbldupvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_supbuildarea']").val();
                carpetvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_carpetarea']").val();

                if (landvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_landmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "Land Area Measurement Required!!</br>" : ErrMsg + "Land Area Measurement Required!!</br>"; }
                if (buildupvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_buildupmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "Buildup Area Measurement Required!!</br>" : ErrMsg + "Buildup Area Measurement Required!!</br>"; }
                if (superbldupvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_supbuildmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "SuperBuildUp Area Measurement Required!!</br>" : ErrMsg + "SuperBuildUp Area Measurement Required!!</br>"; }
                if (carpetvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_carpetmmt']").val() == "")
                { ErrMsg = ErrMsg == "" ? "Carpet Area Measurement Required!!</br>" : ErrMsg + "Carpet Area Measurement Required!!</br>"; }

                var indeperr = fnconstChkMandatory(dvid + " .maindiv-technical_independant");
                ErrMsg = ErrMsg == "" ? indeperr : ErrMsg + indeperr;

                var consterr = fnconstChkMandatory(dvid + " .maindiv-technical_Construction");
                if ($("#" + dvid + " .maindiv-technical_Construction").find("[key = 'tech_buildingage']").val() == "") {
                    ErrMsg = ErrMsg == "" ? "Age of Building Required !!" : ErrMsg + "Age of Building Required !!";
                }
                ErrMsg = ErrMsg == "" ? consterr : ErrMsg + consterr;
            }
            
           

            var commonerr = fnconstChkMandatory(dvid + " .maindiv-technical_common");
            ErrMsg = ErrMsg == "" ? commonerr : ErrMsg + commonerr;

            if (prpvalue != 1 && (parseInt(buildupvalue) <= parseInt(carpetvalue))) {
                fnShflAlert("error", "BuildUp Area Must be greater than Carpet Area");
                return;
            }
            if (prpvalue != 1 && parseInt(superbldupvalue) <= parseInt(buildupvalue)) {
                fnShflAlert("error", "Super BuildUp Area  Must be greater than BuildUp Area")
                return;
            }
            if (prpvalue != 1 && parseInt(superbldupvalue) <= parseInt(carpetvalue)) {
                fnShflAlert("error", "Super BuildUp Area  Must be greater than Carpet Area")
                return;
            }
            if (landvalue == ("" || 0) && buildupvalue == ("" || 0) && superbldupvalue == ("" || 0) && carpetvalue == ("" || 0)) {
                ErrMsg = ErrMsg == "" ? "Land Area / SuperBuildUp Area / BuildUp Area / Carpet Area is Required!!" : ErrMsg + "Land Area / SuperBuildUp Area / BuildUp Area / Carpet Area is Required!!";
            }
            if (parseInt(stgofConst) > 100) {
                ErrMsg = ErrMsg == "" ? "Stage Of Construction Should not be greater than 100 !!" : ErrMsg + "<br/> Stage Of Construction Should not be greater than 100!!";
            }

            var boundryerror = check("#" + dvid + " .maindiv-technical_boundary");

            ErrMsg = ErrMsg == "" ? boundryerror : ErrMsg + '<br/>' + boundryerror;

            if (ErrMsg != "") {
                FinErrMsg = FinErrMsg == "" ? "<b>Property" + Propno + " [Valuation " + Valnno + "]</b><br/>" + ErrMsg : FinErrMsg + "<br/><b>Property" + Propno + " [Valuation " + Valnno + "]</b><br/>" + ErrMsg;               
            }
            //if (IsFinalConfirm == "false")
            //{
            //    i = PropDvCnt;
            //}
        }

        if (FinErrMsg != "") {
            fnShflAlert("error", FinErrMsg);
            return false;
        }
            //Saving Data 
        else {
            
            for (j = 0; j < PropDvCnt; j++) {
                var dvid = "";
                dvid = "maintechnical_" + j;
                var FinalData = {};

                if ($("#" + dvid).find("[key = 'tech_proptyp']").attr("selval") == 0) {
                    var flat = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_flat");
                    $.extend(FinalData, flat[0]);
                }
                else if ($("#" + dvid).find("[key = 'tech_proptyp']").attr("selval") == 1) {
                    var plot = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_plot");
                    $.extend(FinalData, plot[0]);
                }
                else if ($("#" + dvid).find("[key = 'tech_proptyp']").attr("selval") == 2) {
                    var independant = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_independant");
                    $.extend(FinalData, independant[0]);
                }

                var prptype = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_prptype");
                var construction = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_Construction");
                var prpval = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_prpval");
                var common = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_common");
                var boundary = fnGetFormValsJson_IdVal(dvid + " .maindiv-technical_boundary");
                var refno = fnGetFormValsJson_IdVal(dvid + " .common");
                $.extend(FinalData, construction[0]);
                $.extend(FinalData, prpval[0]);
                $.extend(FinalData, prptype[0]);
                $.extend(FinalData, common[0]);
                $.extend(FinalData, boundary[0]);
                $.extend(FinalData, refno[0]);

                //FinalData["propfk"] = $("#" + dvid).attr("propfk");               
                FinalArr.push(FinalData);
                //if (IsFinalConfirm == "false") {
                //    j = PropDvCnt;
                //}
            }

            var PrcObj = { ProcedureName: "PrcShflTechApprover", Type: "SP", Parameters: ['Save', JSON.stringify(LedAgtGlobal), JSON.stringify(FinalArr)] };
            fnCallLOSWebService("I", PrcObj, fnTechnicalFinResult, "MULTI");
        }
        //}    
    }
}

//function fnCallScrnFn(FinalConfirm) {
//    IsFinalConfirm = FinalConfirm;

//    if (IsFinalConfirm == "true" && ActualPrpCnt != PropDvCnt) {
//        fnShflAlert("error", "Some of the properties not yet verified. So, Confirm and Handover is not possible");
//        return;
//    }

//    fntechapprconfirmscreen();
//}

function fnSelectDocment() {
    $(".popup-bg.document-pop-content div.preview-icons.right").empty();
    var PrcObj = { ProcedureName: "PrcShflTechApprover", Type: "SP", Parameters: ["DOCUMENT", JSON.stringify(LedAgtGlobal)] };
    fnCallLOSWebService("DOCUMENT", PrcObj, fnTechnicalFinResult, "MULTI");
}

function check(boundarydiv) {
    var Error = '';
    var east = $(boundarydiv).find("[key='tech_Est']").val();
    var west = $(boundarydiv).find("[key='tech_Wst']").val();
    var south = $(boundarydiv).find("[key='tech_Sou']").val();
    var north = $(boundarydiv).find("[key='tech_Nor']").val();

    if (east != "" && west != "" && south != "" && north != "") {
        if (east.toLowerCase() == west.toLowerCase() || east.toLowerCase() == north.toLowerCase() || east.toLowerCase() == south.toLowerCase() || west.toLowerCase() == north.toLowerCase() || west.toLowerCase() == south.toLowerCase() || south.toLowerCase() == north.toLowerCase()) {
            Error = "Boundary Value should not be same !!";
        }
    }
    return Error;
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

function fnReprtSts(elem) {

    var cls = $(elem).attr("class");
    var lihtml = $(elem).closest("div.status");
    if (cls == "icon-positive") {
        $(lihtml).find("div.bg").attr("class", "bg bg2");
        $(lihtml).find("i").attr("class", "icon-negative");
        $(lihtml).find("input[key=tech_status]").val(0);
    }
    else if (cls == "icon-negative") {
        $(lihtml).find("div.bg").attr("class", "bg bg7");
        $(lihtml).find("i").attr("class", "icon-no-status");
        $(lihtml).find("input[key=tech_status]").val(1);
    }
    else if (cls == "icon-no-status") {
        $(lihtml).find("div.bg").attr("class", "bg bg1");
        $(lihtml).find("i").attr("class", "icon-positive");
        $(lihtml).find("input[key=tech_status]").val(2);
    }
}


function fnshowprop(elem) {
    
    var prvDiv = $("#tech_ul_prop_tabs").find(".active").attr("PrpliCount");
    var DivValue = fnCheck_IdVal("maintechnical_" + prvDiv);
    var dvid = "";
    dvid = "maintechnical_" + prvDiv;
    if (DivValue > 0) {           
        var ErrMsg = "";
        var buildupvalue;
        var superbldupvalue;
        var carpetvalue;
        var landvalue;
        var stgofConst;
        var buildage;
        var mktval;
        var prpvalue;
        var refno;         
        $("#" + dvid).attr("check", "y");
        stgofConst = $("#" + dvid).find("[key = 'tech_construction']").val();
        mktval = $("#" + dvid).find("[key = 'tech_mktval']").val();
        prpvalue = $("#" + dvid).find("[key = 'tech_proptyp']").attr("selval");
        refno = $("#" + dvid).find("[key = 'tech_Refno']").val();
        Propno = $("#" + dvid).attr("prop");
        Valnno = $("#" + dvid).attr("valn");
        //Validations
        var Referror = fnconstChkMandatory(dvid + " .common");
        if (Referror != "") {
            ErrMsg = ErrMsg == "" ? Referror : ErrMsg + Referror;
        }
        var prpvalerror = fnconstChkMandatory(dvid + " .maindiv-technical_prpval");
        if (prpvalerror != "") {
            ErrMsg = ErrMsg == "" ? prpvalerror : ErrMsg + prpvalerror;
        }

        var boundaryerror = fnconstChkMandatory(dvid + " .maindiv-technical_boundary");

        if (boundaryerror != "") {
            ErrMsg = ErrMsg == "" ? boundaryerror : ErrMsg + boundaryerror;
        }

        var prptypeerror = fnconstChkMandatory(dvid + " .maindiv-technical_prptype");
        if (prptypeerror != "") {
            ErrMsg = ErrMsg == "" ? prptypeerror : ErrMsg + prptypeerror;
        }

        //Flat
        if (prpvalue == 0) {
          
            $("#" + dvid).find("[key = 'tech_buildapprauth']").attr("class", "mandatory");
            landvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_UDSarea']").val();
            buildupvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_buildarea']").val();
            superbldupvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_supbuildarea']").val();
            carpetvalue = $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_carpetarea']").val();
            var flaterr = fnconstChkMandatory(dvid + " .maindiv-technical_flat");
            
            if (landvalue != "" && $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_udsmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "UDS Area Measurement Required!!</br>" : ErrMsg + "UDS Area Measurement Required!!</br>"; }
            if (buildupvalue != "" && $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_buildupmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "Buildup Area Measurement Required!!</br>" : ErrMsg + "Buildup Area Measurement Required!!</br>"; }
            if (superbldupvalue != "" && ($("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_supbuildmmt']").val() == ""))
            { ErrMsg = ErrMsg == "" ? "SuperBuildUp Area Measurement Required!!</br>" : ErrMsg + "SuperBuildUp Area Measurement Required!!</br>"; }
            if (carpetvalue != "" && $("#" + dvid + " .maindiv-technical_flat").find("[key = 'tech_carpetmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "Carpet Area Measurement Required!!</br>" : ErrMsg + "Carpet Area Measurement Required!!</br>"; }

            ErrMsg = ErrMsg == "" ? flaterr : ErrMsg + flaterr;           
            
            var consterr = fnconstChkMandatory(dvid + " .maindiv-technical_Construction");

            if ($("#" + dvid + " .maindiv-technical_Construction").find("[key = 'tech_buildingage']").val() == "") {
                ErrMsg = ErrMsg == "" ? "Age of Building Required !!" : ErrMsg + "Age of Building Required !!";
            }
            ErrMsg = ErrMsg == "" ? consterr : ErrMsg + consterr;

        }
            //Plot
        else if (prpvalue == 1) {
            $("#" + dvid).find("[key = 'tech_buildapprauth']").attr("class", "");
            var ploterr = fnconstChkMandatory(dvid + " .maindiv-technical_plot");
            ErrMsg = ErrMsg == "" ? ploterr : ErrMsg + ploterr;
        }
            //Independent
        else if (prpvalue == 2) {
            $("#" + dvid).find("[key = 'tech_buildapprauth']").attr("class", "mandatory");
            landvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_landarea']").val();
            buildupvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_buildarea']").val();
            superbldupvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_supbuildarea']").val();
            carpetvalue = $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_carpetarea']").val();

            if (landvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_landmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "Land Area Measurement Required!!</br>" : ErrMsg + "Land Area Measurement Required!!</br>"; }
            if (buildupvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_buildupmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "Buildup Area Measurement Required!!</br>" : ErrMsg + "Buildup Area Measurement Required!!</br>"; }
            if (superbldupvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_supbuildmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "SuperBuildUp Area Measurement Required!!</br>" : ErrMsg + "SuperBuildUp Area Measurement Required!!</br>"; }
            if (carpetvalue != "" && $("#" + dvid + " .maindiv-technical_independant").find("[key = 'tech_carpetmmt']").val() == "")
            { ErrMsg = ErrMsg == "" ? "Carpet Area Measurement Required!!</br>" : ErrMsg + "Carpet Area Measurement Required!!</br>"; }

            var indeperr = fnconstChkMandatory(dvid + " .maindiv-technical_independant");
            ErrMsg = ErrMsg == "" ? indeperr : ErrMsg + indeperr;

            var consterr = fnconstChkMandatory(dvid + " .maindiv-technical_Construction");
           
            if ($("#" + dvid + " .maindiv-technical_Construction").find("[key = 'tech_buildingage']").val() == "")
            {
                ErrMsg = ErrMsg == "" ? "Age of Building Required !!" : ErrMsg + "Age of Building Required !!";
            }
            ErrMsg = ErrMsg == "" ? consterr : ErrMsg + consterr;
        }



        var commonerr = fnconstChkMandatory(dvid + " .maindiv-technical_common");
        ErrMsg = ErrMsg == "" ? commonerr : ErrMsg + commonerr;

        if (prpvalue != 1 && (parseInt(buildupvalue) <= parseInt(carpetvalue))) {
            fnShflAlert("error", "BuildUp Area Must be greater than Carpet Area");
            return;
        }
        if (prpvalue != 1 && parseInt(superbldupvalue) <= parseInt(buildupvalue)) {
            fnShflAlert("error", "Super BuildUp Area  Must be greater than BuildUp Area")
            return;
        }
        if (prpvalue != 1 && parseInt(superbldupvalue) <= parseInt(carpetvalue)) {
            fnShflAlert("error", "Super BuildUp Area  Must be greater than Carpet Area")
            return;
        }
        if (landvalue == ("" || 0) && buildupvalue == ("" || 0) && superbldupvalue == ("" || 0) && carpetvalue == ("" || 0)) {
            ErrMsg = ErrMsg == "" ? "Land Area / SuperBuildUp Area / BuildUp Area / Carpet Area is Required!!" : ErrMsg + "Land Area / SuperBuildUp Area / BuildUp Area / Carpet Area is Required!!";
        }
        if (parseInt(stgofConst) > 100) {
            ErrMsg = ErrMsg == "" ? "Stage Of Construction Should not be greater than 100 !!" : ErrMsg + "<br/> Stage Of Construction Should not be greater than 100!!";
        }

        var boundryerror = check("#" + dvid + " .maindiv-technical_boundary");

        ErrMsg = ErrMsg == "" ? boundryerror : ErrMsg + '<br/>' + boundryerror;
        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }
    }
    else { $("#" + dvid).attr("check", ""); }
    var value = $(elem).attr("class").split("_");
    var cur_div = $("#PropTabs").find("#maintechnical_" + value[1]);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div").css("display", "none");
    $(".tab_" + value[1]).addClass("active");
    $(".tab_" + value[1]).siblings("li").removeClass("active");
}

function fnshowpropdetails(elem) {
    var value = $(elem).attr("class").split("_");
    var cur_ul = $("#maintechnical_" + value[1] + " ." + value[0] + "-content");
    $(cur_ul).css("display", "block");
    $(cur_ul).siblings("ul").css("display", "none");
    $(elem).addClass('active');
    $(elem).siblings().removeClass('active');
}

function fnPrpTypeSelection(elem) {
    
    var value = $(elem).attr("dvid");
    var Divid = "maintechnical_" + value;
    var PropOccli = $("#" + Divid).find("[key='tech_propoccupy']");
    var lihtml = ''
    
    fnClearForm(Divid + " .maindiv-technical_Construction");
    fnClearForm(Divid + " .plotdisp");
    fnClearForm(Divid + " .commonOccup");
    $("#" + Divid + " .occupancy").empty();

    if ($(elem).hasClass("pro-flat")) {             
        $("#" + Divid + " .flat").show();
        $("#" + Divid + " .plot," + "#" + Divid + " .independant").hide();
        $("#" + Divid + " .plotdisp").show();                          
        $("#" + Divid + " .tab5_" + value).show();

        lihtml += '<li val="S">Self Occupied</li><li val="L">Let Out</li><li val="I">Investment</li><li val="U">UnderConstruction</li>';
        $("#" + Divid + " .occupancy").append(lihtml);
        $("#" + Divid).find("input[key='tech_propoccupy']").attr("selval", "-1");
    }
    else if ($(elem).hasClass("pro-plot")) {                
        $("#" + Divid + " .plot").show();
        $("#" + Divid + " .flat," + "#" + Divid + " .independant").hide();
        $("#" + Divid + " .plotdisp").hide();        
        $("#" + Divid + " .tab5_" + value).hide();

        lihtml += '<li val="V">Vacant</li><li val="U"> UnderConstruction</li>';
        $("#" + Divid + " .occupancy").append(lihtml);
        $("#" + Divid).find("input[key='tech_propoccupy']").attr("selval", "-1");
    }
    else {                
        $("#" + Divid + " .independant").show();
        $("#" + Divid + " .flat," + "#" + Divid + " .plot").hide();
        $("#" + Divid + " .plotdisp").show();      
        $("#" + Divid + " .tab5_" + value).show();

        lihtml += '<li val="S">Self Occupied</li><li val="L">Let Out</li><li val="I">Investment</li><li val="U">UnderConstruction</li>';
        $("#" + Divid + " .occupancy").append(lihtml);
        $("#" + Divid).find("input[key='tech_propoccupy']").attr("selval", "-1");
    }  
}

function fnleaseperChange(obj) {
    
    $(obj).parent().closest('li').siblings().eq(0).find("[key='tech_leasepriod']").val("");
    if ($(obj).hasClass('lease-list'))      
        $(obj).parent().closest('li').siblings().eq(0).attr('style', 'display:inline-block');    
    else
        $(obj).parent().closest('li').siblings().eq(0).attr('style', 'display:none;');
}
function fnManualDeviation(){    
    $("#manualdev").show();
    fnSelManualDev_ZC();
}
function fnSelManualDev_ZC() {
    var PrcObj = { ProcedureName: "PrcShflManualDeviation", Type: "SP", Parameters: ["MANUALDEV_DATA", JSON.stringify(LedAgtGlobal), "", "T"] };
    fnCallLOSWebService("MANUALDEV_DATA", PrcObj, fnTechnicalFinResult, "MULTI");
}
function fnConfirmDeviation(divid) {
 /*
    var DevArr = [];
    var DevObj = {};
    var DevVal = $("#DeviationLvl_T").val();
    var DevRemarks = $("#DeviationRmks_T").val();
    if ($("#DeviationLvl_T option:selected").text().trim() == "Select" || $("#DeviationLvl_T option:selected").text().trim() == "" || DevRemarks == "") { fnShflAlert("error", "All Fields are Required in Deviation"); return; }

    DevObj["tech_deviationLvl"] = DevVal;
    DevObj["tech_DeviationRmks"] = DevRemarks;
    DevArr.push(DevObj);
    var PrcObj = { ProcedureName: "PrcShflTechApprover", Type: "SP", Parameters: ['Save_Deviation', JSON.stringify(LedAgtGlobal), "", JSON.stringify(DevArr)] };
    fnCallLOSWebService("Save_Deviation", PrcObj, fnTechnicalFinResult, "MULTI");
*/
    var selval = $("#ManualDeviationTech").val();
    if (selval == 0) {
        fnShflAlert("error", "Deviations Level Required!!");
        return;
    }
    fnSaveManualDeviation('man_deviation_TM', 'T', fnTechnicalFinResult, 'Save_Deviation', LedAgtGlobal)
}


function fnCheck_IdVal(FormID, IsClass) {
    
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
            if ($(this).attr("key") == "tech_rptdt" || $(this).attr("key") == "tech_status" || $(this).attr("key") == "tech_prpPk" || $(this).attr("key") == "tech_agtFk" || KeyVal == 0 || $(this).attr("key") == "propfk") {
                KeyVal = "";
            }
            if (KeyVal != "") { chkCount++; }
    });
    $(AppendOperator + FormID + " [name='select']").each(function () {      
            if (!($(this).is("[key]"))) { return; }
            IsKeyExists = 1;
            var keyTxt = $(this).attr("key");
            var keyVal = $(this).attr("selval");
            if (keyVal == "") { keyVal = -1;}
            if (keyVal != -1) { chkCount++; }
    
    });
    return chkCount;
}