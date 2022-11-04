var PostSancGlobal = [{}];
var Action = "Add";
var IsFinalConfirm = "";
var FinalErrMsg = "";
var postsanc_frm = "";
var Cur_Active_Prop_li;
var PropDvCnt = 0;
var SellerDetHide = "N";
var BTLnCreated = "Y";
var ExistLnFinInst = "";
var Globalrefno;
var globalDocremarks;
var IsBTandTopupLn = '';
var MaxApprover = 0;
var CurApprover = 0;
var ExactLnAmt = 0;
var InstrSts = '';
var lyfInsAdtoLn = '';
var genInsAdtoLn = '';
$(document).ready(function () {
    PostSancGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    PostSancGlobal[0].LeadPk = GlobalXml[0].FwdDataPk; //For Common SP
    PostSancGlobal[0].LeadId = GlobalXml[0].LeadID;
    PostSancGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    PostSancGlobal[0].BranchNm = GlobalXml[0].Branch;
    PostSancGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    PostSancGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    PostSancGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    PostSancGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    PostSancGlobal[0].AppNo = GlobalXml[0].AppNo;
    PostSancGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    PostSancGlobal[0].SancPk = GlobalXml[0].DpdFk;
    PostSancGlobal[0].PrdGrpFk = GlobalXml[0].PrdGrpFk;
    PostSancGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    PostSancGlobal[0].GrpCd = GlobalXml[0].GrpCd;
    PostSancGlobal[0].Approver = "";
    postsanc_frm = GlobalXml[0].PostSanc_Frm;

    CurApprover = GlobalXml[0].DLvlNo;
    
    if (PostSancGlobal[0].LeadId.indexOf('<br/>') > 0) {
        var ledid = PostSancGlobal[0].LeadId.split('<br/>');
        $('#psq_LeadId').text(ledid[0]);
    }
    else {
        $('#psq_LeadId').text(PostSancGlobal[0].LeadId);
    }
    $(document).on("click", ".Doc_div .icon-chat-o", function () {
        globalDocremarks = $(this).parents("li").siblings(".Com_notes");
        var iconval = $(this).parents("li").siblings(".Com_notes").find("input").val();
        $("textarea#Com_Docrem").val(iconval);
    });
    $('#psq_Branch').text(PostSancGlobal[0].BranchNm);
    $('#psq_AppNo').text(PostSancGlobal[0].AppNo);
    selectfocus();
    fnProposalDetails();
    fnGetCollatreal();
    fnloadrefno();
    fnremarks();
    fnOpenDeviationFatcors_DA();

    var param = JSON.stringify(GlobalBrnch);
    $("#Seller_help").attr("Extraparam", param);
});
$(".MainTab-div").on("click", "li.tab2.collateral_tab2", function () {
    
    //$(".tab2-content").show().siblings().hide();
    $(".collateral2").show().siblings().hide();
    $(".tab1").removeClass("active");
    $(".tab2").addClass("active");
});
$(".MainTab-div").on("click", "li.tab1.collateral_tab1", function () {
    
    //$(".tab1-content.collateral").show().siblings().hide();
    $(".collateral1").show().siblings().hide();
    $(".tab2").removeClass("active");
    $(".tab1").addClass("active");
});
function fnProposalDetails() {
   
    var PrcObj = { ProcedureName: "PrcShflPostSanction", Type: "SP", Parameters: ["Load", JSON.stringify(PostSancGlobal)] };
    fnCallLOSWebService("Load", PrcObj, fnProposalResult, "MULTI");
}
function fnGetCollatreal() {
    var PrcObj = { ProcedureName: "PrcShflPostSanction", Type: "SP", Parameters: ["Search-Collateral", JSON.stringify(PostSancGlobal)] };
    fnCallLOSWebService("Search-Collateral", PrcObj, fnDocResult, "MULTI");
}
function fnloadrefno() {
    
    var objProcData = { ProcedureName: "PrcShflPostSanction", Type: "SP", Parameters: ["SelectRefno", JSON.stringify(PostSancGlobal)] }
    fnCallLOSWebService("Com_Refno", objProcData, fnDocResult, "MULTI");
}
    
function fnremarks()
{
        $(document).on("click", ".pop_bg", function () {
            var rem = $("textarea#Com_Docrem").val();
            $(globalDocremarks).children("input").val(rem).trigger("change");
            
        });
}
function fnchange(elem)
{
    if($(elem).val() == "N")
    {
        $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").val("");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_Refno]").attr("style", "display:none");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_RecDate]").attr("style", "display:none");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").attr("style", "display:none");
        $(elem).parents("li").siblings("li").find("input[colkey=Com_refDate]").attr("style", "display:none");
    }
    else if($(elem).val() == "E")
    {
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
function fnDocResult(ServDesc, Obj, Param1, Param2) {
    
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServDesc == "Com_Refno") {
        
        Globalrefno = JSON.parse(Obj.result);
    }

    if (ServDesc == "Search-Collateral") {
        $(".MainTab-div").empty();

        var Data_Tab = JSON.parse(Obj.result_1);
        var Data_Tab_Content = JSON.parse(Obj.result_2);
        var TabDiv = '<ul class="common-tabs">';
        var TabContentDiv = '<div><div key="' + Data_Tab_Content[0].CltPk + '_' + Data_Tab_Content[0].CltCd + '" class="tab1-content collateral1"><ul class="form-controls">';
        for (i = 0; i < Data_Tab.length ; i++) {
            if (i == 0)
                TabDiv += '<li  class="collateral_tab'+(i+1)+' active tab' + (i + 1) + '">' + Data_Tab[i].CltName + '</li>';
            else
                TabDiv += '<li  class="collateral_tab' + (i + 1) + ' tab' + (i + 1) + '">' + Data_Tab[i].CltName + '</li>';
        }
        TabDiv += '<li><i class="icon-plus"></i></li></ul>';
        var CurentTab = Data_Tab_Content[0].CltCd;
        var tabCnt = 1;
        for (i = 0; i < Data_Tab_Content.length; i++) {
            if (Data_Tab_Content[i].CltCd != CurentTab) {
                TabContentDiv += "<div class='clear'></div></ul></div><div key='" + Data_Tab_Content[i].CltPk + "_" + Data_Tab_Content[i].CltCd + "' class='tab" + (tabCnt + 1) + "-content collateral"+ (tabCnt + 1) +"'><ul class='form-controls'>";
                CurentTab = Data_Tab_Content[i].CltCd;
                tabCnt++;
            }
            if (Data_Tab_Content[i].ClaCtrlTyp == "S") {
                TabContentDiv += "<li class='width-1'><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><select key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "'  name='select2' key='lead_incometyp' class='select mandatory " + Data_Tab_Content[i].CltCd + "'>";
                for (j = 0; j < Data_Tab_Content[i].Combo_Value.split(',').length; j++) {
                    if (Data_Tab_Content[i].Combo_Value.split(',')[j] == Data_Tab_Content[i].LcdVal)
                        TabContentDiv += " <option value='" + Data_Tab_Content[i].Combo_Value.split(',')[j] + "'  selected='selected' >" + Data_Tab_Content[i].Combo_Text.split(',')[j] + "</option>";
                    else
                        TabContentDiv += " <option value='" + Data_Tab_Content[i].Combo_Value.split(',')[j] + "'>" + Data_Tab_Content[i].Combo_Text.split(',')[j] + "</option>";
                }
                TabContentDiv += "</select></li>";
            }
            else if (Data_Tab_Content[i].ClaCtrlTyp == "T")
                TabContentDiv += "<li class='width-15 '><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input type='text' maxlength='100' class='" + Data_Tab_Content[i].CltCd + "' name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "'  value='" + Data_Tab_Content[i].LcdVal + "'></li>";
            else if (Data_Tab_Content[i].ClaCtrlTyp == "A" && Data_Tab_Content[i].ClaName == "Value" && tabCnt == 1)
                TabContentDiv += "<li class='width-15 amount'><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input type='text' maxlength='100' name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "' class='currency mandatory Value " + Data_Tab_Content[i].CltCd + "' restrict='number' value='" + Data_Tab_Content[i].LcdVal + "'><i class='icon-indian-rupee'></i></li>";
            else if (Data_Tab_Content[i].ClaCtrlTyp == "A" && Data_Tab_Content[i].ClaName == "Paid value")
                TabContentDiv += "<li class='width-15 amount'><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input type='text' maxlength='100' name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "' class='currency mandatory Paid " + Data_Tab_Content[i].CltCd + "' restrict='number' value='" + Data_Tab_Content[i].LcdVal + "'><i class='icon-indian-rupee'></i></li>";
            else if (Data_Tab_Content[i].ClaCtrlTyp == "A" && Data_Tab_Content[i].ClaName == "Maturity Value")
                TabContentDiv += "<li class='width-15 amount'><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input type='text' maxlength='100' name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "' class='currency mandatory Maturity " + Data_Tab_Content[i].CltCd + "' restrict='number' value='" + Data_Tab_Content[i].LcdVal + "'><i class='icon-indian-rupee'></i></li>";
            else if (Data_Tab_Content[i].ClaCtrlTyp == "A")
                TabContentDiv += "<li class='width-15 amount'><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input type='text' maxlength='100' name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "' class='currency mandatory " + Data_Tab_Content[i].CltCd + "' restrict='number' value='" + Data_Tab_Content[i].LcdVal + "'><i class='icon-indian-rupee'></i></li>";
            else if (Data_Tab_Content[i].ClaCtrlTyp == "D" && Data_Tab_Content[i].ClaName == "Document Date")
                TabContentDiv += "<li class='width-15 '><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input class='TodayDate  " + Data_Tab_Content[i].CltCd + "' maxlength='10' type='text'  name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "' value='" + Data_Tab_Content[i].LcdVal + "' class='mandatory " + Data_Tab_Content[i].CltCd + "'></li>";
            else if (Data_Tab_Content[i].ClaCtrlTyp == "D")
                TabContentDiv += "<li class='width-15 '><label Class'Name'>" + Data_Tab_Content[i].ClaName + "</label><input class='datepicker  " + Data_Tab_Content[i].CltCd + "' maxlength='10' type='text'  name='text' key='" + Data_Tab_Content[i].ClaPk + "_" + Data_Tab_Content[i].CltPk + "' value='" + Data_Tab_Content[i].LcdVal + "' class='mandatory " + Data_Tab_Content[i].CltCd + "'></li>";
        }
        TabContentDiv += "<div class='clear'></div></ul></div></div>";

        $(".MainTab-div").prepend(TabContentDiv);
        $(".MainTab-div").prepend(TabDiv);

        $("#Main_Content .TodayDate").each(function () {
            
            $(this).datepicker({
                changeMonth: true,
                changeYear: true,
                dateFormat: "dd/mm/yy",
                yearRange: '1900:2017',
                defaultDate: '01/01/2017',
                maxDate: 0
            });
        });
        $("#Main_Content .datepicker").each(function () {            
            $(this).datepicker({
                changeMonth: true,
                changeYear: true,
                dateFormat: "dd/mm/yy",
                yearRange: '1900:2017',
                defaultDate: '01/01/2017',
            });
        });

        $('.select').select2({
            minimumResultsForSearch: -1
        });
        $(".tab2-content").hide();
        $('.currency').trigger('focusout');
        $("#Main_Content .datepicker").each(function () {
            fnRestrictDate($(this));
        });
    }
    if (ServDesc == "INSERT") {
        PFPk = JSON.parse(Obj.result)[0].LpcFK;
        if (IsFinalConfirm != "") {
            if (MaxApprover && MaxApprover != CurApprover && CurApprover != 0)
                fnCallFinalConfirmation(IsFinalConfirm, 'D');
            else
                fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }
    }
}

function fnProposalResult(ServiceFor, Obj, Param1, Param2) {
    if (ServiceFor == "SHOW_DEVIATION") {
        var DevList = JSON.parse(Obj.result_1);
        var MaxDevApp = JSON.parse(Obj.result_2);
        fnBuildDeviationTable_DA(DevList, MaxDevApp);
    }

    if (ServiceFor == "MANUALDEV_DATA") {
        var DevList = JSON.parse(Obj.result_1);
        var SelectedList = JSON.parse(Obj.result_2);
        fnSetDeviationData('man_deviation_div', DevList, SelectedList);
    }
    if (ServiceFor == "Save_Deviation") {
        $("#manualdev").hide();
    }


    if (ServiceFor == "DOCUMENT") {
        var ul_list = "";
        $("div.popup.documents.attach-icon.doc-list-view").empty();
        var docdata = JSON.parse(Obj.result);
        for (var i = 0; i < docdata.length; i++) {
            ul_list += '<ul pk="' + docdata[i].Pk + '"><li>' + docdata[i].DocName + '<p><span class="bg">' + docdata[i].Actor + '</span><span class="bg">' + docdata[i].Catogory + '</span> <span class="bg">' + docdata[i].SubCatogory + '</span></p>' +
            '</li><li><i class="icon-document doc-view" docpath="' + docdata[i].DocPath + '" onclick="fnOpenDocs(this)" ></i></li><li><i class="icon-delete"></i></li></ul>';
        }
        $("div.popup.documents.attach-icon.doc-list-view").append(ul_list);
    }

    if (!Obj.status) {
        alert(Obj.error);
        return;
    }

    if (ServiceFor == "Save") {

        
        if (IsFinalConfirm != "") {
            //After Disbursement Approval, Loan number is generating
            if (IsFinalConfirm == "true" && postsanc_frm == "Disburse_Appr" && MaxApprover == CurApprover) {
                PostSancGlobal[0].Approver = "A";
                var lnno = JSON.parse(Obj.result);
                alert("Loan Number - " + lnno[0].LoanNo + " generated successfully!!");
            }
            if (MaxApprover && MaxApprover != CurApprover && CurApprover != 0)
                fnCallFinalConfirmation(IsFinalConfirm, 'D');
            else
                fnCallFinalConfirmation(IsFinalConfirm);
            return;
        }
    }

    var LeadInfo, ApplDet, GIDet, GINomineeDet, LIDet, LINomineeDet, BankDet, PayDet, SelDet, sel, Agtdata, propdet, prddet;
    var PKDet;

    if (ServiceFor == "Load") {
        
        LeadInfo = JSON.parse(Obj.result_1);
        ApplDet = JSON.parse(Obj.result_2);
        GIDet = JSON.parse(Obj.result_3);
        GINomineeDet = JSON.parse(Obj.result_4);
        LIDet = JSON.parse(Obj.result_5)
        LINomineeDet = JSON.parse(Obj.result_6);
        BankDet = JSON.parse(Obj.result_7);
        AppChqDet = JSON.parse(Obj.result_8);
        PayDet = JSON.parse(Obj.result_9);
        SelDet = JSON.parse(Obj.result_10);
        Agtdata = JSON.parse(Obj.result_11);
        propdet = JSON.parse(Obj.result_12);
        prddet = JSON.parse(Obj.result_13);
        Docdet = JSON.parse(Obj.result_14);        
        var MaxApproverData = JSON.parse(Obj.result_15);
        if (MaxApproverData && MaxApproverData.length > 0)
            MaxApprover = MaxApproverData[0].MaxApproverLevel;
        if (LeadInfo && LeadInfo.length > 0) {

                ExactLnAmt = LeadInfo[0].psq_Lnamt
                PostSancGlobal[0].SancHdrPk = LeadInfo[0].SancHdrPk;

                    //Hide Seller Details 
                SellerDetHide = LeadInfo[0].SellerDetHide;

                    //BT Loan Created - Checking
                BTLnCreated = LeadInfo[0].BTLnCreated;

                    //Existing Loan Financial Institue
                ExistLnFinInst = LeadInfo[0].ExistLnFinInst;

                    //General Insurance is not visible for Topup prd in BTandTopup Loan
                IsBTandTopupLn = LeadInfo[0].IsBTandTopupLn;

                    //PF Instrument Clearance Status
                InstrSts = LeadInfo[0].PFIstrSts;
        }

        $('#prdicon').addClass('' + prddet[0].PrdIcon + '');
        $('#prdcode').text(prddet[0].PrdNm);

        for (var i = 0; i < Agtdata.length; i++) {
            if (i == 0) {
                $(".Agt").append('<option value="-1">Select</option>');
            }
            $(".Agt").append('<option value ="' + Agtdata[i].AgtPk + '">' + Agtdata[i].firstnm + " " + Agtdata[i].midnm + " " + Agtdata[i].lname + '</option>');
        }
       
        if (ApplDet.length > 0) {
           
            $('.psq_sel_LyfInsur_Per').empty();
            $('.psq_sel_GenInsur_Per').empty();
            for (var i = 0; i < ApplDet.length; i++) {
                if (i == 0) {
                    $('.psq_sel_LyfInsur_Per').append('<option value="-1" appname = " ">Select</option>');
                    $('.psq_sel_GenInsur_Per').append('<option value="-1" appname = " ">Select</option>');
                }
                $('.psq_sel_LyfInsur_Per').append('<option value =' + ApplDet[i].LapPk + ' appname = "' + ApplDet[i].CusNm + '" >' + ApplDet[i].ApplTyp + '</option>');
                $('.psq_sel_GenInsur_Per').append('<option value =' + ApplDet[i].LapPk + ' appname = "' + ApplDet[i].CusNm + '" >' + ApplDet[i].ApplTyp + '</option>');
            }
        }

        if (BankDet.length > 0) {
            $('.psq_sel_BankName').empty();
            for (var i = 0; i < BankDet.length; i++) {
                if (i == 0) {
                    $('.psq_sel_BankName').append('<option value ="-1" IFSC="" AccNo="">Select</option>');
                }
                $('.psq_sel_BankName').append('<option value =' + BankDet[i].LbkPk + ' IFSC = "' + BankDet[i].Ifsc + '" AccNo = "' + BankDet[i].AccNo + '">' + BankDet[i].BankName + '</option>');
            }
        }



        if (LeadInfo[0].IsBTandTopupLn == "Y" && (PostSancGlobal[0].PrdCd.toUpperCase() == "HLTOPUP" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPTOPUP")) {
            $('.dvGenIns').hide();            
        }

        //Property Details
        if (propdet.length > 0) {
            fnAddPropTab(propdet, SelDet);
        }
        
        fnSetSellerDetails(SelDet, propdet);

        //Payable To list binding
        InfavourlistBind();
        

        if (SellerDetHide == "Y") {
            $('.postsanction-seller').attr('style', 'display:none');
        }
        else {
            $('.postsanction-seller').attr('style', 'display:block');
        }
  

        if (GIDet.length > 0 || LIDet.length > 0) {
            Action = "Edit";

            fnSetValues("SanctionDet-div", GIDet);
            fnSetValues("SanctionDet-div", LIDet);
              //Vishali Insurer help   (Lyf Insurance)   
            var valtxt = $("#SanctionDet-div").find("input[key=psq_LyfInsurerName]").val();
            $("#SanctionDet-div").find("input[key=psq_LyfInsurerName]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
            //Vishali Insurer help   (General Insurance)   
            var valtxt = $("#SanctionDet-div").find("input[key=psq_GenInsurerName]").val();
            $("#SanctionDet-div").find("input[key=psq_GenInsurerName]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
            fnBindGridVal(GINomineeDet, LINomineeDet, AppChqDet, PayDet);
            fndomanual();
        }
        else {
            Action = "Add";
            $('#psq_LyfInsurAmt').val(LeadInfo[0].psq_Lnamt);
            $('#psq_LyfInsurPremium').val(LeadInfo[0].LiPremium);
            $('#psq_GenInsurAmt').val(LeadInfo[0].psq_Lnamt);
            $('#psq_GenInsurPremium').val(LeadInfo[0].GiPremium);

            //$('#UlSellerAddr').hide();
            //$('#psq_SelAGent').hide();            
          
        }

        fnSetValues("SanctionDet-div", LeadInfo);
        fnLTVCalc();
        //If Loan is exist already, then Combined LTV should display  
        if (PostSancGlobal[0].PrdCd.toUpperCase() == "HLEXT" || PostSancGlobal[0].PrdCd.toUpperCase() == "HLIMP" || PostSancGlobal[0].PrdCd.toUpperCase() == "HLTOPUP" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPTOPUP") {
            if(Number(FormatCleanComma($("#SanctionDet-div [key='psq_Lnamt']").justtext())) != Number(FormatCleanComma($("#SanctionDet-div [key='psq_hdn_ltvlnamt']").val()))){
                $('#liCombMvLtv').show();
                $('#liCombAvLtv').show();
            }
        }

        if ($("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val() == 0 || $("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val() == "0" || $("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val() == "") {
            $("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val(LeadInfo[0].psq_Lnamt);
        }

        if (Docdet.length > 0) {
            for (var k = 0; k < Docdet.length; k++) {
                    fnAdddoc();
            }
            fnSetGridVal("Doc_div", "Document_div", Docdet);
       
            $(".Doc_div .rowGrid").each(function () {
                var DOCNM = $(this).find("li").find("input[colkey='Com_Docname']").val();
                $(this).find("li comp-help").find("input[name='helptext']").val(DOCNM);
            });

            $(".Doc_div .rowGrid").each(function () {
                if ($(this).find("li").find("select[colkey=Com_Docstatus]").val() == "N") {
                    $(this).parents("li").siblings("li").find("input[colkey=Com_Refno]").attr("style", "display:none");
                    $(this).parents("li").siblings("li").find("input[colkey=Com_RecDate]").attr("style", "display:none");
                    $(this).parents("li").siblings("li").find("input[colkey=Com_ValidDate]").attr("style", "display:none");
                }
            });
        }

        if (Action == "Edit") {
            fnEMICalc();            
        }

        if (Action == "Add") {
            $('#dvSellerPaymentDet').find('select').each(function () {
                if (this.id == "psq_sel_infavlist") {
                    $(this).next().hide();
                }
            });
            selectfocus();
        }
        fnRemPFCalc();

        //Collected PF Istrument Status
        if (InstrSts == 'U') {
            $("#dvColPF").removeClass('bg1');
            $("#dvColPF").addClass('bg8');
            if (postsanc_frm == "Disburse_Appr")
            {
                $("#SanctionDet-div [key='psq_ovrride']").attr("disabled", false);
            }           
        }
        if (InstrSts == 'B') {
            $("#dvColPF").removeClass('bg1');
            $("#dvColPF").addClass('bg2');
            if (postsanc_frm == "Disburse_Appr") {
                $("#SanctionDet-div [key='psq_ovrride']").attr("disabled", true);
            }
        }
        else if (InstrSts == 'C') {
            $("#dvColPF").removeClass('bg8');
            $("#dvColPF").addClass('bg1');
            if (postsanc_frm == "Disburse_Appr") {
                $("#SanctionDet-div [key='psq_ovrride']").attr("disabled", true);
            }
        }
    }

    if (ServiceFor == "PaymentSchedule") {
        var MatrixData = JSON.parse(Obj.result);
        var tr = '';
        tr = '<tr><th>Period</th><th>Payment Date</th><th>Opening Balance</th><th>EMI</th><th>Interest</th><th>Principal</th><th>Current Balance</th></tr>';
        for (var i = 0; i < MatrixData.length; i++) {
            tr += '<tr><td>' + MatrixData[i].PERIOD + '</td><td>' + MatrixData[i].PAYDATE + '</td><td>' + MatrixData[i].OPENING_BAL + '</td><td>' + MatrixData[i].PAYMENT + '</td><td>' + MatrixData[i].INTEREST + '</td><td>' + MatrixData[i].PRINCIPAL + '</td><td>' + MatrixData[i].CURRENT_BALANCE + '</td></tr>';
        }
        $("#RepayMatrix").empty();
        $("#RepayMatrix").append(tr);
        $("#rePaymtMx").show();
    }

    if (ServiceFor == "TAX") {
        var TAXdata = JSON.parse(Obj.result_1);
        var TAX_Instdata = JSON.parse(Obj.result_2);

        var tr = '';
        tr = '<tr><th>Charge Name</th><th>Percentage(%)</th><th>Amount</th></tr>';
        for (var i = 0; i < TAXdata.length; i++) {
            tr += '<tr><td>' + TAXdata[i].CompNm + '</td><td>' + TAXdata[i].Per + '</td><td>' + TAXdata[i].TaxAmt + '</td></tr>';
        }

        var trIns = '';
        trIns = '<tr><th>Instrument No</th><th>Instrument Date</th><th>Instrument Amount</th><th>Deposited Date</th><th>Deposited Bank</th><th>BRS Status</th></tr>';

        for (var i = 0; i < TAX_Instdata.length; i++) {
            
            trIns += '<tr><td>' + TAX_Instdata[i].LpcInstrNo + '</td><td>' + TAX_Instdata[i].LpcInstrDt + '</td><td>' + TAX_Instdata[i].LpcInstrAmt + '</td><td>' + TAX_Instdata[i].LpcInstrdepoDt + '</td><td>' + TAX_Instdata[i].BankNm + '</td><td>' + TAX_Instdata[i].Chq_sts + '</td></tr>';
        }

        $("#taxpf").empty();
        $("#taxpf").append(tr);

        $("#taxpf_inst").empty();
        $("#taxpf_inst").append(trIns);

        $(".totPF").show();
        $(".RemPF").hide();
    }

    if (ServiceFor == "BalPF") {
        
        var RemPFdata = JSON.parse(Obj.result);
        var finalVal = 0;
        if (RemPFdata && RemPFdata.length > 0) {
            var tr = '';
            tr = '<tr><th>Charge Name</th><th>Percentage(%)</th><th>Amount</th></tr>';
            for (var i = 0; i < RemPFdata.length; i++) {
                tr += '<tr><td>' + RemPFdata[i].CompNm + '</td><td>' + RemPFdata[i].CompPer + '</td><td>' + RemPFdata[i].RemPF + '</td></tr>';
                if (RemPFdata[i].CompCd == "PFVAL") { finalVal = RemPFdata[i].RemPF; }
                if (RemPFdata[i].CompCd == "PF") { $("#balPf_wout_Tax").val(RemPFdata[i].RemPF); }
            }
            $("#SanctionDet-div [key='psq_balpfamt']").text(FormatCurrency(finalVal));
            $("#Remainingpf").empty();
            $("#Remainingpf").append(tr);

            //PF Adjustment enable/disable
            if ($("#SanctionDet-div [key='psq_balpfamt']").justtext() == "" || Number(FormatCleanComma($("#SanctionDet-div [key='psq_balpfamt']").justtext())) <= 0) {
                $("#SanctionDet-div [key='psq_pfamt_DedFrmLn']").attr("disabled", true);
            }
            else {
                $("#SanctionDet-div [key='psq_pfamt_DedFrmLn']").attr("disabled", false);
            }

            $(".RemPF").show();
}
    }
}
function Pinclick(rowjson, elem) {
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}
function fnAdddoc()
{
    
    var ErrMs = "";
    var c = 1;
    $(".Doc_div .rowGrid").each(function () {
        if ($(this).find("li").find("select[colkey=Com_Doctype]").val() != -1) {
            if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                ErrMs = ErrMs == "" ? "Document Details: Document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Document name Required_Row:" + c + "!!";
                return false;
            }
            //else if ($(this).find("li").find("select[colkey=Com_Docstatus]").val() == -1) {
            //    ErrMs = ErrMs == "" ? "Document Details: Select Document status Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Select Document status Required_Row:" + c + "!!";
            //    return false;
            //}
            else if (($(this).find("li").find("input[colkey=Com_Refno]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_Refno]").attr("style")=="display:inline-block")) {
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
        else
        {
            if ($(this).find("li").find("select[colkey=Com_Doctype]").val() == -1)
            {
                if (($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") ||
                    ($(this).find("li").find("input[colkey=Com_Refno]").val().trim() != "") ||
                    ($(this).find("li").find("select[colkey=Com_Docstatus]").val() != -1) ||
                    ($(this).find("li").find("input[colkey=Com_RecDate]").val().trim() != "") ||
                    ($(this).find("li").find("input[colkey=Com_RecDate]").val().trim() != "") ||
                    ($(this).find("li").find("input[colkey=Com_ValidDate]").val().trim() != "")
                    )
                {
                    ErrMs = ErrMs == "" ? "Document Details: Type of Proof Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Type of Proof Required_Row:" + c + "!!";
                    return false;
                }
            }
            c++;
        }
    });
    var c = 1;
    $(".Doc_div .rowGrid").each(function () {
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

    var s = '';
    var close = '';

    s += '<ul class="grid-controls rowGrid box-doc-ul">' +
                '<li class="width-9">'+
                        '<select name="select2" colkey="Com_Doctype" class="select"  onchange="fncheckDoc(this)">'+
                            '<option value="-1">Select</option>'+
                            '<option value="O">Original</option>'+
                            '<option value="P">Photocopy</option>'+
                            '<option value="C">Certified</option>'+
                        '</select>'+
                    '</li>'+
                  '<li class="width-11">' +
                      '<comp-help id="comp-help" txtcol="DocumentName" valcol="DocPk" onrowclick="Docclick" prcname="PrcShflDocumenthhelp" width="100%"></comp-help>' +
                      '<input type="hidden" placeholder="" name="text" colkey="Com_Docname" value="">' +
                      '<input type="hidden" placeholder="" name="text" colkey="Com_DoctPk" value="">' +
                   '</li>' +
                   '<li class="width-9">' +
                       ' <select name="select2" colkey="Com_Docstatus" class="select" onchange="fnchange(this)">'+
                            '<option value="-1">Select</option>'+
                            '<option value="R">Received</option>'+
                            '<option value="N">Not-Received</option>'+
                            '<option value="E">Recorded</option>'+
                       ' </select>'+
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

        $(".Doc_div").append(s);
        close += '<li><i class="icon-close" onclick="fnCloserow(this)"></i></li>';
        $(".Doc_div").children("ul:last-child").append(close);
        $(".Doc_div").children("ul:last-child").find(".datepickerdef").removeAttr("id");
        $(".Doc_div").children("ul:last-child").find(".datepickerdef").removeClass("hasDatepicker");
        fnDrawDefaultDatePicker();
        $(".Doc_div .datepicker,.datepickerdef").each(function () {
            fnRestrictDate($(this));
        });
        $(".Doc_div").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $(".Doc_div").find('.new').removeClass("new");
        fnInitiateSelect("Doc_div", 1);
}
function fnCloserow(elem)
{
    var divlen = $(".Doc_div").find(".grid-controls.rowGrid.box-doc-ul").length;
            $(elem).closest("ul.grid-controls").remove();
}
//Adding multiple tab - property
function fnAddPropTab(propdet, SelDet) {
    
    var Class = ""; var val = "psq_prop_div_0";
    PropDvCnt = propdet.length;
    for (var i = 0; i < propdet.length; i++) {

        var property = [];
        divId = "psq_prop_div_" + i;
        var k = 0;
        property.push(propdet[i]);

        if (i > 0) {
            $("#psq_ul_prop_tabs").append
           (
               "<li class='tab_" + i + " propDiv' licount='" + i + "' onclick=fnshowprop(this);><span> Property" + (i + 1) + "</span></li>"
           );

            $("#PostSancProperty").append('<div style="display:none;" id="psq_prop_div_' + i + '" class="tab' + i + '-content div_content property" val="' + i + '" propfk = "' + propdet[i].psq_PrpFK + '" contentchanged="true"></div>');
            var content = $("#psq_prop_div_0").html();
            $("#psq_prop_div_" + i).html(content);

            fnInitiateSelect("psq_prop_div_" + i);
            val = "psq_prop_div_" + i;
            fnClearForm("psq_prop_div_" + i);
        }
        else {
            $("#psq_prop_div_0").attr("propfk", propdet[0].psq_PrpFK);         
            
        }
        if (PostSancGlobal[0].GrpCd.toUpperCase() == "PL") {
     
            $("#psq_prop_div_" + i).find("#psq_seller_div_" + i + "_0").find("[key='psq_SellerType']").find("option").each(function () {
                if ($(this).val() == "B") { $(this).remove();}
            });
        }
        $("#psq_prop_div_" + i).find(".seller_div").attr("id", "psq_seller_div_" + i + "_0");
        $("#psq_prop_div_" + i).find("#psq_seller_div_" + i + "_0").attr("propfk", propdet[i].psq_PrpFK);
        $("#psq_prop_div_" + i).find(".seller_div").attr("class", "tab0-content div_content seller_div psq_seller_div_" + i + "_0");
       // $("#psq_prop_div_" + i).find("#psq_seller_div_" + i + "_0").find("[key='psq_SellerType']").attr("onchange", 'fnSellerTypChange(this,"psq_seller_div_' + i + "_" + 0 + '")')
       
        fnSetValues("psq_prop_div_" + i + " .dvprptype", property);

        $("#psq_prop_div_" + i + " .ulpropoccupancy").empty();

        if (propdet[i].psq_proptyp == 0) {
            $("#psq_prop_div_" + i + " .ulpropoccupancy").append('<option value="-1">Select</option><option value="S">Self Occupied</option><option value="L">Let Out</option><option value="I">Investment</option><option value="U">UnderConstruction</option>');

            fnSetValues("psq_prop_div_" + i + " .dvflat", property);
            $("#psq_prop_div_" + i + " .flat").show();
            $("#psq_prop_div_" + i + ".plot," + "#psq_prop_div_" + i + " .independant").hide();

            fnSetValues("psq_prop_div_" + i + " .dvConstruction", property);
            $("psq_prop_div_" + i + " .dvConstruction").show();
        }
        if (propdet[i].psq_proptyp == 1) {
            $("#psq_prop_div_" + i + " .ulpropoccupancy").append('<option value="-1">Select</option><option value="S">Self Occupied</option><option value="L">Let Out</option><option value="I">Investment</option><option value="U">UnderConstruction</option>');

            fnSetValues("psq_prop_div_" + i + " .dvplot", property);
            $("#psq_prop_div_" + i + " .plot").show();
            $("#psq_prop_div_" + i + " .flat," + "#psq_prop_div_" + i + " .independant," + "#psq_prop_div_" + i + " .plotdisp").hide();
            $("psq_prop_div_" + i + " .dvConstruction").hide();
        }
        if (propdet[i].psq_proptyp == 2) {
            $("#psq_prop_div_" + i + " .ulpropoccupancy").append('<option value="-1">Select</option><option value="S">Self Occupied</option><option value="L">Let Out</option><option value="I">Investment</option><option value="U">UnderConstruction</option>');

            fnSetValues("psq_prop_div_" + i + " .dvindependant", property);
            $("#psq_prop_div_" + i + " .independant").show();
            $("#psq_prop_div_" + i + " .flat," + "#psq_prop_div_" + i + " .plot").hide();

            fnSetValues("psq_prop_div_" + i + " .dvConstruction", property);
            $("psq_prop_div_" + i + " .dvConstruction").show();
        }
        if (propdet[i].psq_possessiontyp == 1) {
            $("#psq_prop_div_" + i + " .lease-period").css('display', 'inline-block');
        }
        fnSetValues("psq_prop_div_" + i + " .dvCommon", property);
        fnSetValues("psq_prop_div_" + i + " .dvpropvaluation", property);

        $("#psq_prop_div_" + i).find("input[type='hidden']").val(propdet[i].psq_AstCstPK);
    }
    //fnInitiateSelect("PostSancSeller");
    
    //~ISSUE
    //$("#psq_prop_div_0").find("#PostSancSeller li").eq(0).click();
    
    Cur_Active_Prop_li = $("#psq_ul_prop_tabs li[val='0']");
}
function Insurarclick(rowjson,elem)
{
    $(elem).parents("li").find(".insname").val(rowjson.ShortDescription);
    $(elem).parents("li").find(".insPk").val(rowjson.InPk);

}
function Docclick(rowjson, elem) {
    $(elem).parents("li").find("input[colkey=Com_Docname]").val(rowjson.DocumentName);
    $(elem).parents("li").find("input[colkey=Com_DoctPk]").val(rowjson.DocPk);

    
    var count = 0;
      
    $(".Doc_div .rowGrid").each(function () {
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

function fncheckDoc(elem) {
    $(elem).parents("li").siblings("li").find("comp-help").find("input[name=helptext]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_Docname]").val("");
    $(elem).parents("li").siblings("li").find("input[colkey=Com_DoctPk]").val("");
    $(elem).parents("li").siblings("li").find("select[colkey=Com_Docstatus]").val("-1").trigger("change");
    $(elem).parents("li").siblings("li").find("select[colkey=Com_Docstatus]").val("");
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
function fnshowprop(elem) {
   
    var value = $(elem).attr("licount");
    var cur_div = $("#PostSancProperty").find("#psq_prop_div_" + value);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div").css("display", "none")
    $(".tab_" + value).addClass("active");
    $(".tab_" + value).siblings("li").removeClass("active");       
    $(cur_div).find("#psq_seller_div_"+ value +"_0").css("display", "block");
    $(cur_div).find("#psq_seller_div_" + value + "_0").siblings("div.div_content").css("display", "none");
    $(cur_div).find("#psq_ul_seller_tabs").find("li.tab_0").addClass("active");
    $(cur_div).find("#psq_ul_seller_tabs").find("li.tab_0").siblings("li").removeClass("active");
}

function BindApplName(obj, InsTyp) {
    
    var selname = $(obj).find(":selected").attr("appname");
    if (InsTyp == "LI") {
        $('#LyfInsur_PerNm_Selected').val(selname);
    }
    else {
        $('#GenInsur_PerNm_Selected').val(selname);
    }
}

//Binding Buyer bank IFSC and AccNo 
function BindBankDet(obj) {
    var ifsc = $(obj).find(":selected").attr('IFSC');
    var AccNo = $(obj).find(":selected").attr('AccNo');

    $(obj).parent().closest('li').siblings().eq(1).find('input').val(ifsc);
    $(obj).parent().closest('li').siblings().eq(2).find('input').val(AccNo);
}

//For Life/General insurer, premium amt and insurer name is binding automatically
function BindInFavorDet(obj) {
    
    var InsPremiumAmt = 0;
    var InsurerName = "";
    var FinArr = [];
    var FinObj = {};
    var lifInsCnt = 0;
    var genInsCnt = 0;
    $("#SanctionDet-div").find(".seller_div").each(function () {

        FinObj = {};
        if ($(this).find("[key = 'psq_SellerType']").val() == "S") {
            FinObj["SelTyp"] = $(this).find("[key = 'psq_SellerType']").val();
            FinObj["SelNm"] = $(this).find("[key = 'psq_SellerName']").val();
        }
        else
            FinObj["SelTyp"] = $(this).find("[key = 'psq_SellerType']").val();
            FinObj["BuilderNm"] = $(this).find("[key = 'psq_SellerName']").attr("valtext");
            FinArr.push(FinObj);
    });
    
    if ($(obj).val() == "L") {
        $("#dvSellerPaymentDet").find(".paydet-div-ul").each(function () {
            if($(this).find("[colkey='psq_PayableTo']").val()=="L")
            {
                lifInsCnt++;
            }
            if (lifInsCnt > 1) {
                $(obj).val("-1").trigger("change.select2");
                fnShflAlert("error", "Already Selected !!");
                return false;
            }
        });

    }
    if ($(obj).val() == "G") {
        $("#dvSellerPaymentDet").find(".paydet-div-ul").each(function () {
            if ($(this).find("[colkey='psq_PayableTo']").val() == "G") {
                genInsCnt++;
            }
            if (genInsCnt > 1) {
                $(obj).val("-1").trigger("change.select2");
                fnShflAlert("error", "Already Selected !!");
                return false;
            }
        });

    }
    if ($(obj).val() == "L") {

        InsPremiumAmt = $('#psq_LyfInsurPremium').val();
        InsurerName = $('#psq_LyfInsurerName').val();
        $(obj).parent().closest('li').siblings().eq(3).hide();
        $(obj).parent().closest('li').siblings().eq(2).show();
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", true);
        $(obj).parent().parent().find("li").eq(3).find('input[type=text]').attr("disabled", true);
    }
    else if ($(obj).val() == "G") {
        InsPremiumAmt = $('#psq_GenInsurPremium').val();
        InsurerName = $('#psq_GenInsurerName').val();
        $(obj).parent().closest('li').siblings().eq(3).hide();
        $(obj).parent().closest('li').siblings().eq(2).show();
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", true);
        $(obj).parent().parent().find("li").eq(3).find('input[type=text]').attr("disabled", true);
    }

    else if ($(obj).val() == "O") {        
        //InsurerName = $(obj).parent().closest('li').siblings().eq(2).find("input[name='text']").val();
        $(obj).parent().closest('li').siblings().eq(3).hide();        
        $(obj).parent().closest('li').siblings().eq(2).show();
        $(obj).parent().closest('li').siblings().eq(2).find("input[type='text']").val(" ");
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", false);
        $(obj).parent().parent().find("li").eq(3).find('input[type=text]').attr("disabled", false);


    }
    
    else if ($(obj).val() == "S") {        
        var Optionsel = '';
        for (var i = 0; i < FinArr.length; i++) {
            if (FinArr[i].SelTyp == "S") {
                Optionsel +=  ' <li val="' + FinArr[i].SelNm + '">' + FinArr[i].SelNm + '</li>'
               // Optionsel +=  '<option value="' + FinArr[i].SelNm + '">' + FinArr[i].SelNm + '</option>'
    }   
        }
     //   Optionsel = '<option value="">Select</option>' + Optionsel;
        $(obj).parent().closest('li').siblings().eq(2).hide();
        $(obj).parent().closest('li').siblings().eq(3).find("ul").empty();
        $(obj).parent().closest('li').siblings().eq(3).find("ul").append(Optionsel);
       // $(obj).parent().closest('li').siblings().eq(3).find("select").empty();
        //$(obj).parent().closest('li').siblings().eq(3).find("select").append(Optionsel);
        $(obj).parent().closest('li').siblings().eq(3).show();
        $(obj).parent().closest('li').siblings().eq(3).find("select").val("");
        //$(obj).parent().closest('li').siblings().eq(3).find("select").val("").trigger("change.select2")
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", false);

        
    }   
    else if ($(obj).val() == "B") {       
        var Optionsel = '';
        for (var i = 0; i < FinArr.length; i++) {
            if (FinArr[i].SelTyp == "B") {
                Optionsel += ' <li val="' + FinArr[i].BuilderNm + '">' +FinArr[i].BuilderNm + '</li>'
                //Optionsel += '<option value="' + FinArr[i].BuilderNm + '">' + FinArr[i].BuilderNm + '</option>'
            }
        }
      //  Optionsel = '<option value="">Select</option>' + Optionsel;
        $(obj).parent().closest('li').siblings().eq(2).hide();
        $(obj).parent().closest('li').siblings().eq(3).find("ul").empty();
        $(obj).parent().closest('li').siblings().eq(3).find("ul").append(Optionsel);
        //$(obj).parent().closest('li').siblings().eq(3).find("select").empty();
        //$(obj).parent().closest('li').siblings().eq(3).find("select").append(Optionsel);
        $(obj).parent().closest('li').siblings().eq(3).show();
        $(obj).parent().closest('li').siblings().eq(3).find("select").val("");
        //$(obj).parent().closest('li').siblings().eq(3).find("select").val("").trigger("change.select2")
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", false);

        
    }
    else if ($(obj).val() == "F") {
        InsurerName = ExistLnFinInst;
        $(obj).parent().closest('li').siblings().eq(2).find('input[type=text]').show();
        $(obj).parent().closest('li').siblings().eq(3).hide();
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", false);
        $(obj).parent().parent().find("li").eq(3).find('input[type=text]').attr("disabled", false);
    }
    if ($(obj).val() == "C") {             
        InsurerName = $('.psq_sel_LyfInsur_Per').find('option').eq(1).attr("appname");
        console.log(InsurerName);
        $(obj).parent().closest('li').siblings().eq(3).hide();
        $(obj).parent().closest('li').siblings().eq(2).show();
        $(obj).parent().closest('li').siblings().eq(1).find('input').attr("disabled", false);
        $(obj).parent().parent().find("li").eq(3).find('input[type=text]').attr("disabled", true);
    }
   
    $(obj).parent().closest('li').siblings().eq(1).find('input').val(InsPremiumAmt);
    $(obj).parent().parent().find("li").eq(3).find('input[type=hidden]').val(InsurerName);
    //$(obj).parent().closest('li').prev().find('input[type=hidden]').val(infavVal)
   //$(obj).parent().closest('li').siblings().eq(2).find('input[type=hidden]').val(InsurerName);
   $(obj).parent().closest('li').siblings().eq(2).find('input[name=text]').val(InsurerName);
  
}

//Cheque No mandate for PDC on paymode change
function fnChequeMandate(obj) {
    if ($(obj).val() == "P") {
        $(obj).parent().closest('li').siblings().eq(3).find('input').addClass('mandatory');
        $(obj).parent().closest('li').siblings().eq(3).find('input').attr("readonly", false);

        $(obj).parent().closest('li').siblings().eq(4).find('input').addClass('mandatory');
        $(obj).parent().closest('li').siblings().eq(4).find('input').attr("readonly", false);
    }
    else {
        $(obj).parent().closest('li').siblings().eq(3).find('input').removeClass('mandatory');
        $(obj).parent().closest('li').siblings().eq(3).find('input').attr("readonly", true);
        $(obj).parent().closest('li').siblings().eq(3).find('input').val('');

        $(obj).parent().closest('li').siblings().eq(4).find('input').removeClass('mandatory');
        $(obj).parent().closest('li').siblings().eq(4).find('input').attr("readonly", true);
        $(obj).parent().closest('li').siblings().eq(4).find('input').val('');
    }
}

//Adding new row to grid
function fnAddGrid(Type, LoadType) {
    
    FinalErrMsg = "";
    if (Type == "LI") {
        if (LoadType == "" || LoadType == undefined) {
            FinalErrMsg = fnChkMandatory("dvLiNomDet", 1, 0, "Life Insurance Nominee");
            if (FinalErrMsg != "") {
                fnShflAlert("error", FinalErrMsg);
                return;
            }
        }

        $(".linominee-div").append(document.querySelector(".linominee-div-ul").outerHTML);
        $(".linominee-div").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $(".linominee-div").find('.new').removeClass("new");

        fnInitiateSelect("linominee-div", 1);
    }
    else if (Type == "GI") {

        if (LoadType == "" || LoadType == undefined) {
            FinalErrMsg = fnChkMandatory("dvGiNomDet", 1, 0, "General Insurance Nominee");
            if (FinalErrMsg != "") {
                fnShflAlert("error", FinalErrMsg);
                return;
            }
        }

        $(".ginominee-div").append(document.querySelector(".ginominee-div-ul").outerHTML);
        $(".ginominee-div").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $(".ginominee-div").find('.new').removeClass("new");

        fnInitiateSelect("ginominee-div", 1);
    }
    else if (Type == "BanDet") {

        if (LoadType == "" || LoadType == undefined) {
            FinalErrMsg = fnChkMandatory("dvbankdet", 1, 0, "Buyer Bank Detail");
            if (FinalErrMsg != "") {
                fnShflAlert("error", FinalErrMsg);
                return;
            }
        }
        $(".bankdet-div").append(document.querySelector(".bankdet-div-ul").outerHTML);
        $(".bankdet-div").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $(".bankdet-div").find('.new').removeClass("new");

        fnInitiateSelect("bankdet-div", 1);
    }
    else if (Type == "PayDet") {
        
        if (LoadType == "" || LoadType == undefined) {
           
            FinalErrMsg = fnChkMandatory("dvSellerPaymentDet", 1, 0, "Seller/Builder/Insurer Payment Detail");

            
            if (FinalErrMsg == ""){
            $("#dvSellerPaymentDet").find("[colkey = 'psq_InstruAmt']").each(function () {
                FinalErrMsg += $(this).val() == 0 ? "Valid Amount Required in Payment Detail !!" : "";
             });
            }
            FinalErrMsg += fnPayablAmtCalc();          
            if (FinalErrMsg != "") {
                fnShflAlert("error", FinalErrMsg);
                return;
            }
           
        }

        $(".paydet-div").append(document.querySelector(".paydet-div-ul").outerHTML);
        $(".paydet-div").children("ul:last-child").addClass("new");
        fnClearForm("new", 1);
        $(".paydet-div").find('.new').removeClass("new");

        fnInitiateSelect("paydet-div", 1);
    }
}

//While editing, grid rows and values binding
function fnBindGridVal(GINomineeDet, LINomineeDet, AppChqDet, PayDet) {
    if (GINomineeDet.length > 0) {
        fnClearForm('ginominee-div', 1);
        
        for (var ginom = 1; ginom < GINomineeDet.length ; ginom++) {
            fnAddGrid("GI", "Auto");
        }
        fnSetGridVal("ginominee-div", "", GINomineeDet);
    }

    if (LINomineeDet.length > 0) {
        fnClearForm('linominee-div', 1);
        for (var linom = 1; linom < LINomineeDet.length ; linom++) {
            fnAddGrid("LI", "Auto");
        }

        fnSetGridVal("linominee-div", "", LINomineeDet);
    }

    if (AppChqDet.length > 0) {
        fnClearForm('bankdet-div', 1);
        for (var bnkdet = 1; bnkdet < AppChqDet.length ; bnkdet++) {
            fnAddGrid("BanDet", "Auto");
        }

        fnSetGridVal("bankdet-div", "", AppChqDet);
    }

    if (PayDet.length > 0) {
        fnClearForm('paydet-div', 1);
        
        for (var paydt = 1; paydt < PayDet.length ; paydt++) {
            fnAddGrid("PayDet", "Auto");
        }

        for (var paydt = 0; paydt < PayDet.length; paydt++) {
            if (PayDet[paydt].psq_PayableTo == 'S' || PayDet[paydt].psq_PayableTo == 'B') {
                PayDet[paydt].psq_InFavour = PayDet[paydt].psq_InFavour_seller;
            }
            else {
                PayDet[paydt].psq_InFavour = PayDet[paydt].psq_InFavour;
            }
        }
        fnSetGridVal("paydet-div", "", PayDet);
        
        $("#dvSellerPaymentDet").find("ul.paydet-div-ul").each(function () {
            $(this).find("li").eq(3).find('input[type=text]').val($(this).find("[colkey  = 'psq_InFavour']").val());
        });
        //fnInitiateSelect("paydet-div", 1);
    }
}

//Confirm
function fnCallScrnFn(FinalConfirm) {
    IsFinalConfirm = FinalConfirm;
    fnSaveDetails();
}

//Check for mandatory
function fnMandValidation() {
    
    FinalErrMsg = "";
    var ErrMs = "";
    var lnamtError = "";
    var LifInsError = "";
    var GenInsError = "";
    var InsError = "";
    var lnamt = "";

    FinalErrMsg = fnChkMandatory("SanctionDet-div");
    FinalErrMsg += fnChkMandatory("dvLiNomDet", 1, 0, "Life Insurance Nominee");
    FinalErrMsg += fnChkMandatory("dvGiNomDet", 1, 0, "General Insurance Nominee");
    FinalErrMsg += fnChkMandatory("dvbankdet", 1, 0, "Buyer Bank Detail");
    FinalErrMsg += fnChkMandatory("dvSellerPaymentDet", 1, 0, "Seller/Builder/Insurer Payment Detail");
    if (FinalErrMsg == "") {
        $("#dvSellerPaymentDet").find("[colkey = 'psq_InstruAmt']").each(function () {
            FinalErrMsg += $(this).val() == 0 ? "Valid Amount Required in Seller/Builder/Insurer Payment Detail!!" : "";
        });
    }
    //When div is visible false common function is not working    
    $("#dvbankdet[contentchanged='true'] .mandatory").each(function () {
        var label = "";

        if ($(this).parents("[contentchanged='false']").length > 0) {
        }
        else {
            if (!$(this).is(":visible") && ($(this).attr("name") == "text" || $(this).attr("name") == "select2") && ($(this).val() == "" || $(this).val() == "-1")) {
                var thisrowGrid = $(this).closest("ul.rowGrid");
                var index = $(thisrowGrid).children("li").index($(this).closest("li"));
                var labelList = $(thisrowGrid).siblings("ul").not(".rowGrid");
                label = labelList.children().eq(index).children("label").text();

                if (label != "" && label != undefined)
                    ErrMs += label + " Required @Row-" + (($(thisrowGrid).index()) - 1) + "!! <br/>";
            }
        }
    });

    if (ErrMs != "") {
        FinalErrMsg += "<br/><b>Buyer Bank Detail</b><br/>" + ErrMs;
    }

    ErrMs = "";

    $("#dvSellerPaymentDet[contentchanged='true'] .mandatory").each(function () {
        var label = "";

        if ($(this).parents("[contentchanged='false']").length > 0) {
        }
        else {
            if (!$(this).is(":visible") && ($(this).attr("name") == "text" || $(this).attr("name") == "select" || $(this).attr("name") == "select2") && ($(this).val().trim() == "" || $(this).val().trim() == "-1")) {
                var thisrowGrid = $(this).closest("ul.rowGrid");
                var index = $(thisrowGrid).children("li").index($(this).closest("li"));
                var labelList = $(thisrowGrid).siblings("ul").not(".rowGrid");
                label = labelList.children().eq(index).children("label").text();

                if (label != "" && label != undefined)
                    ErrMs += label + " Required @Row-" + (($(thisrowGrid).index()) - 1) + "!! <br/>";
            }
        }
    });
    
    if (lyfInsAdtoLn == "L") {
        LifInsError = "Life Insurer";
        $(".paydet-div-ul").each(function () {
            if ($(this).find("[colkey = 'psq_PayableTo']").val() == "L") {
                LifInsError = "";
            }
        });
    }
    LifInsError = LifInsError == "" ? LifInsError : "Payable to Required for " + LifInsError + "!!</br>";
    if (genInsAdtoLn == "G") {
        GenInsError = "General Insurer";
        $(".paydet-div-ul").each(function () {
            if ($(this).find("[colkey = 'psq_PayableTo']").val() == "G") {
                GenInsError = "";
            }
        });
    }
    GenInsError = GenInsError == "" ? GenInsError : "Payable to Required for " + GenInsError + "!!</br>";
    
    $(".paydet-div-ul").each(function () {
        lnamtError = "";
        if ($(this).find("[colkey = 'psq_PayableTo']").val() == "G" || $(this).find("[colkey = 'psq_PayableTo']").val() == "L") {
            lnamtError = "LoanAmount";
        }
        else if ($(this).find("[colkey = 'psq_PayableTo']").val() != "G" || $(this).find("[colkey = 'psq_PayableTo']").val() != "L")
        {
            lnamt = "Y";
        }
        else {
            lnamtError = "LoanAmount";
        }
    });
    lnamtError = lnamt == "Y" ? "" : "LoanAmount";
    lnamtError = lnamtError == "" ? lnamtError : "Payable to Required for " + lnamtError + "!!";
    
    if (ErrMs != "") {
        FinalErrMsg += "<br/><b>Seller/Builder/Insurer Payment Detail</b><br/>" + ErrMs;
    }
    if (ErrMs == "") {
        FinalErrMsg +=  LifInsError  + GenInsError  + lnamtError;
    }

    //Property Valuation details
    for (var i = 0; i < PropDvCnt; i++) {
        ErrMs = "";

        $("#psq_prop_div_" + i + "[contentchanged='true'] .mandatory").each(function () {
            var lbl_sibling; var label = "";

            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if (!$(this).is(":visible") && $(this).attr("name") == "text" && ($(this).val().trim() == "" || $(this).val().trim() == "0")) {
                    if ($(this).attr("key") == "psq_assetcst" || $(this).attr("key") == "psq_aggreeValue") {
                        lbl_sibling = $(this).siblings("label");
                        label = $(lbl_sibling).text();
                        if (label == "") { label = $(this).attr("placeholder"); }

                    if (label != "" && label != undefined)
                        ErrMs += label + " Required!! <br/>";
                }
            }
         }


        });
        if (ErrMs != "") {
            FinalErrMsg += "<br/><b>Property" + (i + 1) + "</b><br/>" + ErrMs;
        }
    }

    //if (postsanc_frm == "PostSancCopy" || postsanc_frm == "PostSancQC") {
    //    var sellerinfo = $(".seller_div").find("select[key=psq_SellerType]").val();

    //    if (sellerinfo == 'S') {
    //        if ($("#UlSellerAddr").find("comp-help").find("input[name=helptext]").val().trim() == "") {
    //            ErrMs += "Pincode Required!!";
    //        }

    //    }
    //    if (sellerinfo == 'S') {
    //        if (($("#UlSellerAddr").find("comp-help").find("input[name=helptext]").val().trim()  != "")) {
    //            if (($("#UlSellerAddr").find("comp-help").find("input[name=helptext]").val() != $("#UlSellerAddr").find("input[key=psq_SellerPin]").val())) {
    //                ErrMs += "Valid Pincode Required!!";
    //            }
    //        }

    //    }
    //    if (ErrMs != "") {
    //        FinalErrMsg += ErrMs;
    //    }
    //}
    
    if( $("#SanctionDet-div").find("input[key=psq_LyfInsurerName]").parent().find("comp-help").find("input[name=helptext]").val().trim() =="")
        {
        ErrMs += "Life Insurance: Insurer name Required!! <br/>";
        }   

    if( $("#SanctionDet-div").find("input[key=psq_LyfInsurerName]").parent().find("comp-help").find("input[name=helptext]").val().trim() !=""){
        if( $("#SanctionDet-div").find("input[key=psq_LyfInsurerName]").parent().find("comp-help").find("input[name=helptext]").val() !=  $("#SanctionDet-div").find("input[key=psq_LyfInsurerName]").val()) {
            ErrMs += "Life Insurance: Valid Insurer name Required!! <br/>";
            }
    }
    if ($("#SanctionDet-div").find("input[key=psq_GenInsurerName]").is(":visible") && $("#SanctionDet-div").find("input[key=psq_GenInsurerName]").parent().find("comp-help").find("input[name=helptext]").val().trim() == "") {
        ErrMs += "General Insurance: Insurer name Required!! <br/>";
    }

    if ($("#SanctionDet-div").find("input[key=psq_GenInsurerName]").parent().find("comp-help").find("input[name=helptext]").val().trim() != "") {
        if ($("#SanctionDet-div").find("input[key=psq_GenInsurerName]").parent().find("comp-help").find("input[name=helptext]").val() != $("#SanctionDet-div").find("input[key=psq_GenInsurerName]").val()) {
            ErrMs += "General Insurance: Valid Insurer name Required!! <br/>";
        }
    }
    
    var c = 1;
    $(".Doc_div .rowGrid").each(function () {
        if ($(this).find("li").find("select[colkey=Com_Doctype]").val() != -1) {
            if ($(this).find("li comp-help").find("input[name=helptext]").val().trim() == "") {
                ErrMs = ErrMs == "" ? "Document Details: Document name Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Document name Required_Row:" + c + "!!";
                return false;
            }
            //else if ($(this).find("li").find("select[colkey=Com_Docstatus]").val() == -1) {
            //    ErrMs = ErrMs == "" ? "Document Details: Select Document status Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Select Document status Required_Row:" + c + "!!";
            //    return false;
            //}

            else if (($(this).find("li").find("input[colkey=Com_Refno]").val().trim() == "") && ($(this).find("li").find("input[colkey=Com_Refno]").attr("style")=="display:inline-block")) {
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
        else {
            if ($(this).find("li").find("select[colkey=Com_Doctype]").val() == -1) {
                if (($(this).find("li comp-help").find("input[name=helptext]").val().trim() != "") ||
                    ($(this).find("li").find("input[colkey=Com_Refno]").val().trim() != "") ||
                    ($(this).find("li").find("select[colkey=Com_Docstatus]").val() != -1) ||
                    ($(this).find("li").find("input[colkey=Com_RecDate]").val().trim() != "") ||
                    ($(this).find("li").find("input[colkey=Com_RecDate]").val().trim() != "") ||
                    ($(this).find("li").find("input[colkey=Com_ValidDate]").val().trim() != "")
                    ) {
                    ErrMs = ErrMs == "" ? "Document Details: Type of Proof Required_Row:" + c + "!!" : ErrMs + "<br/>Document Details: Type of Proof Required_Row:" + c + "!!";
                    return false;
                }
            }
            c++;
        }
    });
   
       var c = 1;   
       $(".Doc_div .rowGrid").each(function () {
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
        FinalErrMsg += ErrMs;
    }
}

//Save Details
function fnSaveDetails() {
    
    var Error = "";
    var sellerError = "";
    fnMandValidation();
       
 /*   if (SellerDetHide == "N") {
    
        Error = fnsellerChkMandatory();
        sellerError = fnCheckseller("psq_prop_div");
    }           */
     
    FinalErrMsg += fnPayablAmtCalc();
    //FinalErrMsg = FinalErrMsg == "" ? Error : FinalErrMsg + Error;
    //FinalErrMsg = FinalErrMsg == "" ? sellerError : FinalErrMsg + sellerError;
    if (FinalErrMsg != "") {
        fnShflAlert("error", FinalErrMsg);
        return;
    }
    else {
        if (IsFinalConfirm == "true") {
            $("#psq_hdn_confirm").val(1);
        }
        
        //Colletral Div 
        var tab1 = false;
        var tab2 = false;
        var tab_1 = false;
        var tab_2 = false;
        $('#Main_Content .SS').each(function () {
            if ($(this)[0].className.indexOf("currency") >= 0)
            {
                if($(this).val() != "" && $(this).val() != "0")
                    tab1 = true;
            }
           else if ($(this).val() != "" && $(this).val() != "-1")
            {
                tab1=true;
            }
        });
        $('#Main_Content .PM').each(function () {
            if ($(this)[0].className.indexOf("currency") >= 0) {
                if ($(this).val() != "" && $(this).val() != "0")
                    tab2 = true;
            }
            else if ($(this).val() != "" && $(this).val() != "-1") {
                tab2 = true;
            }
        });
        if (tab2) {
            $('#Main_Content .PM').each(function () {
                if ($(this)[0].className.indexOf("currency") >= 0) {
                    if ($(this).val() == "" || $(this).val() == "0") {
                        try {
                            fnShflAlert("error", $(this).parent()[0].children[0].innerHTML + " is Required");
                            tab_2 = true;
                            return false;
                        }
                        catch (e) { }
                    }
                }
                else if ($(this).val() == "") {
                    try {
                        fnShflAlert("error", $(this).parent()[0].children[0].innerHTML + " is Required");
                        tab_2 = true;
                        return false;
                    }
                    catch (e) { }
                }
            });
        }
        if (tab1)
        {
            $('#Main_Content .SS').each(function () {
                if ($(this)[0].className.indexOf("currency") >= 0) {
                    if ($(this).val() == "" || $(this).val() == "0") {
                        try {
                            fnShflAlert("error", $(this).parent()[0].children[0].innerHTML + " is Required");
                            tab_1 = true;
                            return false;
                        }
                        catch (e) { }
                    }
                }
                else if ($(this).val() == "") {
                    try {
                        fnShflAlert("error", $(this).parent()[0].children[0].innerHTML + " is Required");
                        tab_1 = true;
                        return false;
                    }
                    catch (e) { }
                }
            });
        }
        
        if (tab_1||tab_2)
            return;
        if (tab1) {
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            if ($("#Main_Content .TodayDate").val() != "") {
                try {
                    var from = $("#Main_Content .TodayDate").val().split("/");
                    var f = new Date(from[2], from[1] - 1, from[0]);
                    if (f > today) {
                        fnShflAlert("error", "Document Date Should No Exceed Today");
                        return;
                    }
                }
                catch (ex) {
                    fnShflAlert("error", "Invalid Document Date");
                    return;
                }
            }
            else {
                fnShflAlert("error", "Document Date is Required");
                return;
            }
            var maturityam = $("#Main_Content .Maturity").val();
            var valueam = $("#Main_Content .Value").val();
            var paidam = $("#Main_Content .Paid").val();

            if ($("#Main_Content .Maturity").val() == "") {
                fnShflAlert("error", "Maturity Value is Required");
                return;
            }
            else if ($("#Main_Content .Value").val() == "") {
                fnShflAlert("error", "Value is Required");
                return;
            }
            else if ($("#Main_Content .Paid").val() == "") {
                fnShflAlert("error", "Paid is Required");
                return;
            }
            else if (Number(FormatCleanComma(maturityam)) <= Number(FormatCleanComma(valueam))) {
                fnShflAlert("error", "Maturity Value Should Be Greater Than Value");
                return;
            }
            else if (Number(FormatCleanComma(valueam)) < Number(FormatCleanComma(paidam))) {
                fnShflAlert("error", "Value Should Be Greater Than or equal to Paid Value");
                return;
            }
        }
        var actLnAmt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val())); 
        
        //Automatic Decision making for FIS or DO
        
        var SancDivJson = fnGetFormValsJson_IdVal("SanctionDet-div");
        var LINomDet = fnGetGridVal("linominee-div", "");
        var GINomDet = fnGetGridVal("ginominee-div", "");
        var BankDet = fnGetGridVal("bankdet-div", "");
        var paydet = fnGetGridVal("paydet-div", "");
        var Docdet = fnGetGridVal("Doc_div", "");

        var propvaldet = fngetpropdet("psq_prop_div");
        var sellerDet = fngetsellerdet("psq_prop_div");



        var LnDetInsert = "N", PfOvrride = null;
        
        if (postsanc_frm == "Disburse_Appr") {
            if (InstrSts == "U") {
                PfOvrride = $("#SanctionDet-div [key='psq_ovrride']")[0].checked == true ? 'Y' : 'N';
            }

            if (IsFinalConfirm == "true") {
                if (MaxApprover == CurApprover) {
                    PostSancGlobal[0].Approver = "A";
                    LnDetInsert = "Y";
                }

                if (Number(FormatCleanComma($("#SanctionDet-div [key='psq_balpfamt']").justtext())) > 0 && $("#SanctionDet-div [key='psq_pfamt_DedFrmLn']")[0].checked == false) {
                    fnShflAlert("error", "PF collection is not completed.");
                    return;
                }

                if (InstrSts == "U" && $("#SanctionDet-div [key='psq_ovrride']")[0].checked == false) {
                    fnShflAlert("error", "Cheque clearance Required.");
                    return;
                }

                if (BTLnCreated == "N") {
                    fnShflAlert("error", "Balance Transfer Loan is not yet Disbursed.");
                    return;
                }
            }
        }
        


        var HdrJsonTemp = {}; var Action = "";
        HdrJsonTemp = fnGetFormValsJson_IdVal("Main_Content");
        var HdrJson = [];
        var keys = [];
        for (var k in HdrJsonTemp[0]) keys.push(k);
        for (var i = 0; i < keys.length; i++) {
            if (keys[i].indexOf('_') > -1) {
                var item = {}
                item["LcdCltFk"] = keys[i].split('_')[1];
                item["LcdClaFk"] = keys[i].split('_')[0];
                item["LcdVal"] = HdrJsonTemp[0][keys[i]];
                HdrJson.push(item);
            }
        }
        
      
        var objProcData =
               {
                   ProcedureName: "PrcShflPostSanction",
                   Type: "SP",
                   Parameters:
                   [
                       "Save", JSON.stringify(PostSancGlobal), JSON.stringify(SancDivJson), JSON.stringify(LINomDet), JSON.stringify(GINomDet),
                       JSON.stringify(BankDet), JSON.stringify(paydet), LnDetInsert, JSON.stringify(propvaldet), JSON.stringify(HdrJson),
                       JSON.stringify(Docdet), JSON.stringify(sellerDet), null, PfOvrride
                   ]
               };

        fnCallLOSWebService("Save", objProcData, fnProposalResult, "MULTI");
    }
}

function fnSelectDocment() {
    var objProcData = { ProcedureName: "PrcShflLegalVerification", Type: "SP", Parameters: ['DOCUMENT', JSON.stringify(PostSancGlobal)] };
    fnCallLOSWebService("DOCUMENT", objProcData, fnProposalResult, "MULTI");
}

//Delete Row in a Grid
function fnDelGridRow(elem, type) {
    var ulcnt = 0;
    if (type == "LI") {
        ulcnt = $(".linominee-div.grid-type").find(".form-controls.rowGrid.linominee-div-ul").length;
        if (ulcnt > 1)
            $(elem).closest("ul.form-controls.rowGrid.linominee-div-ul").remove();
    }
    else if (type == "GI") {
        ulcnt = $(".ginominee-div.grid-type").find(".form-controls.rowGrid.ginominee-div-ul").length;
        if (ulcnt > 1)
            $(elem).closest("ul.form-controls.rowGrid.ginominee-div-ul").remove();
    }
    else if (type == "BankDet") {
        ulcnt = $(".bankdet-div.grid-type").find(".form-controls.rowGrid.bankdet-div-ul").length;
        if (ulcnt > 1)
            $(elem).closest("ul.form-controls.rowGrid.bankdet-div-ul").remove();
    }
    else if (type == "PayDet") {
        ulcnt = $(".seller-dt.grid-type.paydet-div").find(".form-controls.rowGrid.paydet-div-ul").length;
        if (ulcnt > 1)
            $(elem).closest("ul.form-controls.rowGrid.paydet-div-ul").remove();
    }
}

//Onchange values handling in edit mode
function fndomanual() {
    $('.bankdet-div-ul').find('input', 'select').each(function () {
        if (this.value == "PDC") {
            $(this).parent().closest('li').siblings().eq(3).find('input').addClass('mandatory');
            $(this).parent().closest('li').siblings().eq(4).find('input').addClass('mandatory');
        }
    });
}

//EMI Calculation
function fnEMICalc() {
    var EmiAmt = 0;
    var LnAmt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_Lnamt']").justtext()));    
    var LIPremium = $("#psq_LyfInsurPremium").val() != "" ? Number(FormatCleanComma($("#psq_LyfInsurPremium").val())) : 0;
    var GIPremium = $("#psq_GenInsurPremium").val() != "" ? Number(FormatCleanComma($("#psq_GenInsurPremium").val())) : 0;

    if ($("#SanctionDet-div [key='psq_LyfInsur_AddtoLn']")[0].checked == true) {
        LnAmt += LIPremium;
        lyfInsAdtoLn = "L";
    }
    else {
        lyfInsAdtoLn = "";
    }
    if ($("#SanctionDet-div [key='psq_GenInsur_AddtoLn']")[0].checked == true) {
        LnAmt += GIPremium;
        genInsAdtoLn = "G";
    }
    else {
        genInsAdtoLn = "";
    }

    var IntRate = Number($("#SanctionDet-div [key='psq_ROI']").justtext());
    var Tenure = Number($("#SanctionDet-div [key='psq_Tenure']").justtext());

    //Geetha
    $("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val(LnAmt);

    EmiAmt = CreditFormulas.PMT(IntRate, Tenure, LnAmt);
    $('#psq_EmiAmt').val(EmiAmt);
}

function sum(obj) {
    var agrmntval = $(obj).parent().closest('li').parent().children().find('input').eq(0).val() == "" ? 0 : Number(FormatCleanComma($(obj).parent().closest('li').parent().children().find('input').eq(0).val()));
    var regchrge = $(obj).parent().closest('li').parent().children().find('input').eq(1).val() == "" ? 0 : Number(FormatCleanComma($(obj).parent().closest('li').parent().children().find('input').eq(1).val()));
    var stmpchrge = $(obj).parent().closest('li').parent().children().find('input').eq(2).val() == "" ? 0 : Number(FormatCleanComma($(obj).parent().closest('li').parent().children().find('input').eq(2).val()));
    var amentamt = $(obj).parent().closest('li').parent().children().find('input').eq(3).val() == "" ? 0 : Number(FormatCleanComma($(obj).parent().closest('li').parent().children().find('input').eq(3).val()));
    var legestimate = $(obj).parent().closest('li').parent().children().find('input').eq(4).val() == "" ? 0 : Number(FormatCleanComma($(obj).parent().closest('li').parent().children().find('input').eq(4).val()));

    var total = parseInt(agrmntval) + parseInt(regchrge) + parseInt(stmpchrge) + parseInt(amentamt) + parseInt(legestimate);

    var asstcst = FormatCurrency(total.toString());
    $(obj).parent().closest('li').parent().children().find('input').eq(5).val(asstcst);

    fnLTVCalc();
}

function fnLTVCalc() {
    var i = 0;
    var avltv = 0, combavltv = 0;
    var totlnamt = 0;
    var asstcst = 0;

    var actlnamt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_Lnamt']").justtext()));

    totlnamt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_hdn_ltvlnamt']").val()));

    for (i = 0; i < PropDvCnt; i++) {
        asstcst += Number(FormatCleanComma($("#psq_prop_div_" + i + " [key='psq_assetcst']").val()));
    }

    if (actlnamt != 0 && asstcst != 0) {
        avltv = (actlnamt / asstcst * 100).toFixed(2);
        $("#psq_avltv").val(avltv.toString());

        if (PostSancGlobal[0].PrdCd.toUpperCase() == "HLEXT" || PostSancGlobal[0].PrdCd.toUpperCase() == "HLIMP" || PostSancGlobal[0].PrdCd.toUpperCase() == "HLTOPUP" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPTOPUP") {
            avltv = 0;
            avltv = (totlnamt / asstcst * 100).toFixed(2);
        }

        $("#psq_combavltv").val(avltv.toString());
    }
}

//get all property div values
function fngetpropdet(FormID, IsClass) {
    var KeyVal = [];
    var KeyJsonTxt = "";
    var IsKeyExists = 0;
    var KeyValObj = {};
    var lpcnt = 0;

    while (lpcnt < PropDvCnt) {
        KeyJsonTxt = "";
        IsKeyExists = 0;
        KeyValObj = {};
        var AppendOperator = "#";
        if (IsClass == 1) { AppendOperator = "." }

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

        if (IsKeyExists == 1)
            KeyValObj["PropFk"] = $(AppendOperator + FormID + "_" + lpcnt).attr("propfk");
        KeyVal.push(KeyValObj);

        lpcnt += 1;
    }

    return KeyVal;
}

//Geetha
function fnPayablAmtCalc() {
    
    var instramt = 0, Err = "";
    var FinalLnAmt = 0;
    var ActualLnAmt = 0
    var balPF = 0
    ActualLnAmt = ExactLnAmt;
    //ActualLnAmt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val()));
    if ($(".ltvAndPf-val").find("[key = 'psq_pfamt_DedFrmLn']").is(":checked"))
    {
        balPF = Number(FormatCleanComma($("#dvRemPF").find("[key = 'psq_balpfamt']").justtext()));
        ActualLnAmt = ExactLnAmt - balPF;
}
    $("#dvSellerPaymentDet").find("ul.paydet-div-ul").each(function(){
        if (!($(this).find("[colkey= 'psq_PayableTo']").val() == "L" || $(this).find("[colkey= 'psq_PayableTo']").val() == "G")) {
            instramt += Number(FormatCleanComma($(this).find("[colkey = 'psq_InstruAmt']").val().trim()));
        }
    });
   
    if (ActualLnAmt < instramt) {
        Err = "Payable Amount exceeds Loan Amount";
    }
    return Err;
}
//If some of the values given, Mandatory class adding to input 
//function fnDynamicMand(type) {
//    var InsID = "", NomId = "";
//    var valcnt = 0;
//    var gridvalcnt = 0;

//    if (type == "LI") {
//        InsID = "#ulLyfInsDet";
//    }
//    else if (type == "GI") {
//        InsID = "#ulGenInsDet";
//    }
//    else if (type == "LINom") {
//        NomId = ".linominee-div-ul";
//        InsID = "#ulLyfInsDet";
//    }
//    else if (type == "GINom") {
//        NomId = ".ginominee-div-ul";
//        InsID = "#ulGenInsDet";
//    }

//    //Nominee Details
//    if (NomId != "") {
//        $(NomId).find('input', 'select', 'check').each(function () {
//            if (this.value != "" || this.value == "on") {
//                gridvalcnt += 1;
//            }
//        });

//        $(NomId).find('input', 'select').each(function () {
//            if (gridvalcnt > 0) {
//                $(this).addClass('mandatory');
//            }
//            else {
//                $(this).removeClass('mandatory');
//            }
//        });  
//    }

//    //Insurance details
//    $(InsID).find('input', 'select', 'check').each(function () {
//        if (this.value != "" || this.value == "on"){
//            valcnt += 1;
//        }
//    });

//    $(InsID).find('input', 'select').each(function () {
//        if (valcnt > 0 || gridvalcnt > 0) {
//                $(this).addClass('mandatory');
//            }
//        else {
//            $(this).removeClass('mandatory');
//        }
//    });

//    return false;
//}


function fnrePaymtMx() {
    var LnAmt = 0;
    //LnAmt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_Lnamt']").justtext()));

    //if ($("#SanctionDet-div [key='psq_LyfInsur_AddtoLn']")[0].checked == true) {
    //    LnAmt += Number(FormatCleanComma($("#SanctionDet-div [key='psq_LyfInsurPremium']").val()));
    //}

    //if ($("#SanctionDet-div [key='psq_GenInsur_AddtoLn']")[0].checked == true) {
    //    LnAmt += Number(FormatCleanComma($("#SanctionDet-div [key='psq_GenInsurPremium']").val()));
    //}

    LnAmt = Number(FormatCleanComma($("#SanctionDet-div [key='psq_hdn_finalLnAmt']").val()));
    var IntRate = Number($("#SanctionDet-div [key='psq_ROI']").justtext());
    var Tenure = Number($("#SanctionDet-div [key='psq_Tenure']").justtext());
    var EmiDueDt = $("#SanctionDet-div [key='psq_EmiDueDt']").val();

    var PrcObj = { ProcedureName: "PrcShflPaymentSchedule", Type: "SP", Parameters: [LnAmt, IntRate, Tenure, EmiDueDt] };
    fnCallLOSWebService("PaymentSchedule", PrcObj, fnProposalResult, "MULTI");
}

//function fnSellerTypChange(obj, formId) {
//    
    
//    var divId = '';    
//    var PropDivCnt = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
//    var sellerDiv = $($(obj).closest(".postsanction-seller").find(".seller_div")[0]);

//    divId = "psq_prop_div_" + PropDivCnt;
//    //var SelTyp = $("#" + divId + " #psq_seller_div_" + PropDivCnt + "_0").find("[key='psq_SellerType']").val();
//    var SelTyp = $(sellerDiv).find("[key='psq_SellerType']").val();
//    if (formId != "psq_seller_div_" + PropDivCnt + "_0")
//    {
//        if (SelTyp != $(obj).val()) {                       
//            $("#" + divId).find("#" + formId).find('#psq_buildercin').hide();
//            $("#" + divId).find("#" + formId).find('#UlSellerAddr').hide();
//            $("#" + divId).find("#" + formId).find('#psq_SelAGent').hide();
//            $("#" + divId).find("#" + formId).find('#checkAgt').hide();
//            //$("#SanctionDet-div [key='psq_CIN']").val(' ');
//            $("#" + divId).find("#" + formId).find("input[key='psq_CIN']").val(' ');
//            fnClearForm_psq(divId, formId, "UlSellerAddr");
//            fnClearForm_psq(divId, formId, "checkAgt");
//            $("#" + divId).find("#" + formId).find(".buildermas").hide();
//            $("#" + divId).find("#" + formId).find("[key='psq_SellerType']").val("-1");
//            fnShflAlert("error", "Choose Same Seller Type!!");
//            return false;
//    }
//        }
//    if ($(obj).val() == "-1") {
//        $("#" + divId).find("#" + formId).find('#psq_buildercin').hide();
//        $("#" + divId).find("#" + formId).find('#UlSellerAddr').hide();
//        $("#" + divId).find("#" + formId).find('#psq_SelAGent').hide();
//        $("#" + divId).find("#" + formId).find('#checkAgt').hide();
//        //$("#SanctionDet-div [key='psq_CIN']").val(' ');
//        $("#" + divId).find("#" + formId).find("input[key='psq_CIN']").val(' ');
//        fnClearForm_psq(divId, formId, "UlSellerAddr");
//        fnClearForm_psq(divId, formId, "checkAgt");
//        $("#" + divId).find("#" + formId).find(".buildermas").hide();
//    }
//    else if ($(obj).val() == "S") {
//        $("#" + divId).find("#" + formId).find(".buildermas").empty();
//        $("#" + divId).find("#" + formId).find(".buildermas").show();
//        $("#" + divId).find("#" + formId).find('#psq_SelAGent').hide();
//        $("#" + divId).find("#" + formId).find('#psq_buildercin').hide();
//        $("#" + divId).find("#" + formId).find('#UlSellerAddr').show();
//        $("#" + divId).find("#" + formId).find('#checkAgt').show();
//        $("#" + divId).find("#" + formId).find("input[key='psq_CIN']").val(' ');
//        //$("#SanctionDet-div [key='psq_CIN']").val(' ');
//        fnClearForm_psq(divId, formId, "checkAgt");
//        $("#" + divId).find("#" + formId).find(".buildermas input").attr("type", "text");
//        var html = $('<label>Seller Name</label><input type="text" name="text" key="psq_SellerName">');
//        $("#" + divId).find("#" + formId).find(".buildermas").append(html);
//    }
//    else {
//        $("#" + divId).find("#" + formId).find(".buildermas").empty();
//        $("#" + divId).find("#" + formId).find(".buildermas").show();
//        $("#" + divId).find("#" + formId).find('#psq_SelAGent').hide();
//        $("#" + divId).find("#" + formId).find('#psq_buildercin').show();
//        $("#" + divId).find("#" + formId).find('#UlSellerAddr').hide();
//        $("#" + divId).find("#" + formId).find('#checkAgt').show();
//        fnClearForm_psq(divId, formId, "UlSellerAddr");
//        fnClearForm_psq(divId, formId, "checkAgt");
//        var html = $('<label>Builder Name</label><comp-help id="comp-help" txtcol="BuilderName" valcol="GPk" onrowclick="builderclick" prcname="PrcShflBuilderhelp" width="100%"></comp-help>' + '<input type="hidden"  valtext="" name="text" key="psq_SellerName">' + '<input type="hidden"  valtext="" name="text" key="psq_BuilderPk">');
//        $("#" + divId).find("#" + formId).find(".buildermas").append(html);
//    }
//    InfavourlistBind(divId,formId);
    
//}
/*muthu(16/1/17)*/
function builderclick(rowjson) {
    
    var propDiv = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
    var activeDiv = $("#psq_prop_div_" + propDiv).find("#psq_ul_seller_tabs li.common.active").attr("value");
    var cur_div = $("#psq_prop_div_" + propDiv).find("#psq_seller_div_" + propDiv  + '_' + activeDiv);
    $(cur_div).find("li.buildermas input[name='helptext']").val(rowjson.BuilderName);
    $(cur_div).find("li.buildermas input[key='psq_SellerName']").attr("valtext", rowjson.BuilderName);
    $(cur_div).find("li.buildermas input[key='psq_SellerName']").attr("value", rowjson.BuilderName);
    $(cur_div).find("li.buildermas input[key='psq_BuilderPk']").attr("value", rowjson.GPk);
    $(cur_div).find("ul").attr("contentchanged", "true");
    //$("#SanctionDet-div").find("li.buildermas input[name='helptext']").val(rowjson.BuilderName);
    //$("#SanctionDet-div").find("li.buildermas input[key='psq_SellerName']").attr("valtext", rowjson.BuilderName);
    //$("#SanctionDet-div").find("li.buildermas input[key='psq_SellerName']").attr("value", rowjson.BuilderName);
    
    //$(".box-div.seller_div ul").attr("contentchanged", "true");
}
/*end*/

//function InfavourlistBind(divId,id) {
    
//    $('.psq_PayableTo').empty();
//    var InfavorOpt = "";
//    var lifInsOpt = "";
//    var GenInsOpt = "";
//    var SellerOpt = "";
//    var BuildOpt = "";
//    var OtherOpt = "";
//    var CusOpt = "";
//    var selectOpt = "";
//    var BankOpt = "";

//    //General Insurance is not visible for Topup prd in BTandTopup Loan


//    lifInsOpt = '<option value="L">Life Insurer</option>';
//    GenInsOpt = '<option value="G">General Insurer</option>';    
//    CusOpt = '<option value="C">Customer</option>';
//    OtherOpt = '<option value="O">Others</option>';
//    selectOpt = '<option value="-1">Select</option>';
//    BankOpt = '<option value="F">Bank/HFC</option>';
//    var selCnt = 0;
//    var BuildCnt = 0;
//    //Based on seller
//    var sellerInfavor = '';
//    var builderInfavor = '';
//    $("#SanctionDet-div").find(".seller_div").each(function () {
       
//        if ($(this).find("[key = 'psq_SellerType']").val() == "S") {
//            sellerInfavor = '<option value="S">Seller</option>';
//    }
//        if ($(this).find("[key = 'psq_SellerType']").val() == "B") {
//            builderInfavor = '<option value="B">Builder</option>';
//    }
//    });
//    //For BT Product,  existing Bank/Financial Institue option is added in payable to option 
//    if (PostSancGlobal[0].PrdCd.toUpperCase() == "HLBT" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPBT") {
//        InfavorOpt = selectOpt + lifInsOpt + GenInsOpt + BankOpt + sellerInfavor + builderInfavor + OtherOpt;
//    }
//    else if (IsBTandTopupLn == "Y" && (PostSancGlobal[0].PrdCd.toUpperCase() == "HLTOPUP" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPTOPUP")) {
//        InfavorOpt = selectOpt + lifInsOpt + sellerInfavor + builderInfavor + OtherOpt;
//    }
//    else if (SellerDetHide == "Y") {
//        InfavorOpt = selectOpt + lifInsOpt + GenInsOpt + CusOpt + sellerInfavor + builderInfavor + OtherOpt;
//    }
//    else {
//        InfavorOpt = selectOpt + lifInsOpt + GenInsOpt + sellerInfavor + builderInfavor + OtherOpt;
//    }
        
//    $('.psq_PayableTo').find('option').each(function () {
//        if ($(this).val() == "S") {            
//            selCnt++;
//        }
//        if ($(this).val() == "B") {            
//            BuildCnt++;
//        }
//    });
//    if (selCnt == 0 || BuildCnt == 0) {
//        $('.psq_PayableTo').append(InfavorOpt);
//    }

//    //if (SellerDetHide == "Y") {
//    //    $("#SanctionDet-div").find("#PostSancSeller").each(function () {
//    //        $(this).attr('style', 'display:none');});
//    //    $('.psq_PayableTo').append('<option value="-1">Select</option><option value="C">Customer</option><option value="G">General Insurer</option><option value="L">Life Insurer</option>' + InfavorOpt);
//    //}
//    //else {
//    //    $("#SanctionDet-div").find("#PostSancSeller").each(function () {
//    //        $(this).attr('style', 'display:block');
//    //    });
//    //    $('.psq_PayableTo').append('<option value="-1">Select</option><option value="G">General Insurer</option><option value="L">Life Insurer</option>' + InfavorOpt); 
//    //}
//}
function InfavourlistBind(divId, id) {
    
    var InfavorOpt = "";
    var lifInsOpt = "";
    var GenInsOpt = "";
    var SellerOpt = "";
    var BuildOpt = "";
    var OtherOpt = "";
    var CusOpt = "";
    var selectOpt = "";
    var BankOpt = "";
    var cnt = 0;
    var selCnt = 0;
    var BuildCnt = 0;
    $('.psq_PayableTo').find('option').each(function () {
        if ($(this).val() == "S") {
            selCnt++;
        }
        if ($(this).val() == "B") {
            BuildCnt++;
        }

        cnt++;
    });

    //General Insurance is not visible for Topup prd in BTandTopup Loan
    lifInsOpt = '<option value="L">Life Insurer</option>';
    GenInsOpt = '<option value="G">General Insurer</option>';
    CusOpt = '<option value="C">Customer</option>';
    OtherOpt = '<option value="O">Others</option>';
    selectOpt = '<option value="-1">Select</option>';
    BankOpt = '<option value="F">Bank/HFC</option>';

    //Based on seller
    var sellerInfavor = '';
    var builderInfavor = '';

    $("#SanctionDet-div").find(".seller_div").each(function () {

        if ($(this).find("[key = 'psq_SellerType']").val() == "S") {
            sellerInfavor = '<option value="S">Seller</option>';
        }
        if ($(this).find("[key = 'psq_SellerType']").val() == "B") {
            builderInfavor = '<option value="B">Builder</option>';
        }
    });
    //For BT Product,  existing Bank/Financial Institue option is added in payable to option 
    if (PostSancGlobal[0].PrdCd.toUpperCase() == "HLBT" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPBT") {
        InfavorOpt = selectOpt + lifInsOpt + GenInsOpt + BankOpt  + OtherOpt;
    }
    else if (IsBTandTopupLn == "Y" && (PostSancGlobal[0].PrdCd.toUpperCase() == "HLTOPUP" || PostSancGlobal[0].PrdCd.toUpperCase() == "LAPTOPUP")) {
        InfavorOpt = selectOpt + lifInsOpt + OtherOpt;
    }
    else if (SellerDetHide == "Y") {
        InfavorOpt = selectOpt + lifInsOpt + GenInsOpt + CusOpt  + OtherOpt;
    }
    else if (SellerDetHide == "N") {
        InfavorOpt = selectOpt + lifInsOpt + GenInsOpt + sellerInfavor + builderInfavor + OtherOpt;
    }

    if ((selCnt == 0 && sellerInfavor != "") || (BuildCnt == 0 && builderInfavor != "")) {

        $('.paydet-div-ul').find('select').each(function () {

            if ($(this).attr("colkey") == 'psq_PayableTo') {                
                var curvalue = $(this).val();
                $(this).empty();
                $(this).append(InfavorOpt);
                $(this).val(curvalue);
            }
        });

    }

    if (selCnt != 0 && sellerInfavor == "") {

        $('.paydet-div-ul').find('select').each(function () {

            if ($(this).attr("colkey") == 'psq_PayableTo') {
                var curvalue = $(this).val();
                $(this).empty();
                $(this).append(InfavorOpt);
                if (curvalue == "S"){
                    $(this).val("-1").trigger("change.select2");
                    $(this).closest("ul").find("input[name = 'text']").val("");
                    $(this).closest("ul").find("[name = 'select2']").val("-1").trigger("change.select2");
                    $(this).closest("ul").find("[name = 'select']").val("");
                }
                else{
                    $(this).val(curvalue);
                }
            }
        });

    }
    if (BuildCnt != 0 && builderInfavor == "") {

        $('.paydet-div-ul').find('select').each(function () {

            if ($(this).attr("colkey") == 'psq_PayableTo') {
                var curvalue = $(this).val();
                $(this).empty();
                $(this).append(InfavorOpt);
                if (curvalue == "B") {
                    $(this).val("-1").trigger("change.select2");
                    $(this).closest("ul").find("input[name = 'text']").val("");
                    $(this).closest("ul").find("[name = 'select2']").val("-1").trigger("change.select2");
                    $(this).closest("ul").find("[name = 'select']").val("");
                }
                else{
                    $(this).val(curvalue);
                }
            }
        });

    }
    if (cnt == 0) {
        $('.paydet-div-ul').find('select').each(function () {

            if ($(this).attr("colkey") == 'psq_PayableTo') {
                var curvalue = $(this).val();
                $(this).empty();
                $(this).append(InfavorOpt);
               // $(this).val(curvalue);
                $(this).val('-1');
            }
        });
    }
}
/*function fnAddSeller(elem) {
    
    var divId = '';
    var sellerId = '';    
    var option = '';
    var ErrMsg = '';
    var SelTyp = ''
   var ptBuiler = '';
    var PropDivCnt = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
    divId = "psq_prop_div_" + PropDivCnt;
    var PropFk = $('#' + divId).attr("propfk");    
    var selvalCnt = Number($("#SanctionDet-div").find("#" + divId).find("#psq_ul_seller_tabs li.common").last().attr("value"));
    var SellerCount = selvalCnt + 1;   
    sellerId = "psq_seller_div_" + PropDivCnt + "_" +SellerCount;
    //validation for seller 
    var cur_sel_Typ = $("#" + divId + " #psq_seller_div_" + PropDivCnt + "_" + selvalCnt).find("[key = 'psq_SellerType']").val();
    if (cur_sel_Typ == "-1")
    {
        fnShflAlert("error", "Seller Type Required !!");
        return;
    }
    Cur_Sel_error = fnchkselMandatory(PropDivCnt, selvalCnt);
    if (Cur_Sel_error != "") {
        fnShflAlert("error", Cur_Sel_error);
        return;
}
   
    ptBuiler = PostSancGlobal[0].GrpCd.toUpperCase() == "PL" ? "" : '<option value="B">Builder</option>';
    
    var mainHtml = $("#psq_seller_div_0_0").html();     
    var sellerLi = '<li value = ' + SellerCount + ' class="tab_' + SellerCount + ' common" onclick="fnshowseller(this);">Seller' + (SellerCount + 1) + '<i class="li-close icon-close"></i></li>'
    var sellerDiv = '<div id="psq_seller_div_' + PropDivCnt + "_" + SellerCount + '" val="' + SellerCount + '" propfk="' + PropFk + '" sellerpk="0" class="tab' + SellerCount + '-content div_content seller_div psq_seller_div_' + PropDivCnt + "_" + SellerCount + '" contentchanged="true"style="display:none;">' + mainHtml + '</div>'
    //var sellerSelect = '<label>Type of Seller</label>' +
    //                    '<select name="select2" key="psq_SellerType" class="select mandatory">' +
    //                                '<option value="-1">Select</option>' +
    //                                '<option value="S">Seller</option>' +
    //                                ptBuiler
    //                                //'<option value="B">Builder</option>'+
    //                            '</select>'

    $(elem).closest("li").before(sellerLi);
    $("#" + divId).find("#PostSancSeller").append(sellerDiv);
    $("#" + divId).find("#" + sellerId).attr("sellerpk", "0");  
    //$("#" + divId).find("#" + sellerId).find("li.seller").empty();
    //$("#" + divId).find("#" + sellerId).find("li.seller").append(sellerSelect);


    fnInitiateSelect("PostSancSeller");
    $("#" + divId).find("#" + sellerId).find("[key='psq_agnttype']").prop("disabled", true);
    $("#" + divId).find("#psq_ul_seller_tabs").find("li.tab_" + SellerCount).addClass("active");
    $("#" + divId).find("#psq_ul_seller_tabs").find("li.tab_" + SellerCount).siblings("li").removeClass("active");
    $("#" + divId).find("#" + sellerId).show();
    $("#" + divId).find("#" + sellerId).siblings("div.div_content").css("display", "none");
    $("#" + divId).find("#" + sellerId).find('#psq_buildercin').hide();
    $("#" + divId).find("#" + sellerId).find('#UlSellerAddr').hide();
    $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').hide();
    $("#" + divId).find("#" + sellerId).find('#checkAgt').hide();
    $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
    fnClearForm_psq(divId,sellerId,"UlSellerAddr");
    $("#" + divId).find("#" + sellerId).find(".buildermas").hide();
    $("#" + divId).find("#" + sellerId).find("input[key='psq_agnttype']").attr("valtext", "");
    $("#" + divId).find("#" + sellerId).find("input[key='psq_agnttype']").attr("value", "");
    $("#" + divId).find("#" + sellerId).find("input[key='psq_agnttype']").attr("valcol", "");
    
}*/
function fnshowseller(elem) {
    
    var ErrMsg = '';
    var value = $(elem).attr("value");
    var PropDivCnt = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
    var cur_div_active = Number($("#psq_prop_div_" + PropDivCnt).find("#PostSancSeller li.common.active").attr("value"));
    var cur_sel_Typ = $("#psq_prop_div_" + PropDivCnt + " #psq_seller_div_" + PropDivCnt + "_" + cur_div_active);
    //if (cur_sel_Typ == "-1") {
    //    fnShflAlert("error", "Seller Type Required !!");
    //    return;
    //}
    //Cur_Sel_show_error = fnchkselMandatory(PropDivCnt, cur_div_active);
    //if (Cur_Sel_show_error != "") {
    //    fnShflAlert("error", Cur_Sel_show_error);
    //    return;
    //}


    //ErrMsg = fnsellerChkMandatory("psq_prop_div_" + PropDivCnt, cur_div_active);
    //var buildNm = $("#psq_prop_div_" + PropDivCnt + " #psq_seller_div_" + cur_div_active).find("comp-help").find("input[name=helptext]").val();
    //if (buildNm == "" && $("#psq_prop_div_" + PropDivCnt + " #psq_seller_div_" + PropDivCnt  + '_' + cur_div_active).find("[key = 'psq_SellerType']").val() == "B") {
    //    ErrMsg = ErrMsg == "" ? "Builder Name Required!!": ErrMsg + "Builder Name Required!!";
    //}
    //if (ErrMsg != "") {
    //    fnShflAlert("error", ErrMsg);
    //    return;
    //}
    var cur_div = $("#psq_prop_div_" + PropDivCnt).find("#psq_seller_div_" + PropDivCnt + '_' + value);
    $(cur_div).css("display", "block");
    $(cur_div).siblings("div.div_content").css("display", "none")
    $("#psq_prop_div_" + PropDivCnt).find("#psq_ul_seller_tabs").find("li.tab_" + value).addClass("active");
    $("#psq_prop_div_" + PropDivCnt).find("#psq_ul_seller_tabs").find("li.tab_" + value).siblings("li").removeClass("active");
}
/*function fnsellerliClose(elem, e) {
    
    e.stopPropagation();    
    var PropDivCnt = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
    var divno = $(elem).closest("li").attr("value");
    var PrvDiv = Number($(elem).closest("li").attr("value")) - 1;
    var sellerPk = Number($("#psq_prop_div_" + PropDivCnt).find("#psq_seller_div_" + PropDivCnt + '_' + divno).attr("sellerpk"));
   

    if (sellerPk == 0 || sellerPk == "0") {
        $("#psq_prop_div_" + PropDivCnt).find("#psq_seller_div_" + PropDivCnt + '_' + divno).remove();
        $(elem).closest("li").remove();
        $("#psq_prop_div_" + PropDivCnt).find("#psq_seller_div_" + PropDivCnt + '_' + PrvDiv).show();
    }
    else {
        var confirmSts = confirm("Do you wish to Delete??");
        if (confirmSts == true) {
            $("#psq_prop_div_" + PropDivCnt).find("#psq_seller_div_" + PropDivCnt + '_' + divno).remove();
            $(elem).closest("li").remove();                   
            var PrcObj = { ProcedureName: "PrcShflPostSanction", Type: "SP", Parameters: ["Delete_Seller", JSON.stringify(PostSancGlobal), "", "", "", "", "", "", "", "", "", "", sellerPk] };
            fnCallLOSWebService("Delete_Seller", PrcObj, fnProposalResult, "MULTI");
        }

    }
}*/
function fnSetSellerDetails(SelDet, propdet) {
    
    var divId = '';
    var sellerId = '';
    var ptBuiler = "";
    ptBuiler = PostSancGlobal[0].GrpCd.toUpperCase() == "PL" ? "" : '<option value="B">Builder</option>';
    if (SelDet.length > 0 && propdet.length > 0) {
        for (var i = 0; i < propdet.length; i++) {
            divId = "psq_prop_div_" + i;
            var k = 0;
            
            for (var j = 0; j < SelDet.length; j++) {
                var sellerDet = [];
                sellerId = "psq_seller_div_" + i + '_' + k;
                if (propdet[i].psq_PrpFK == SelDet[j].PropFk) {
                    sellerDet.push(SelDet[j]);                    
                    if(k > 0){                                       
                    var mainHtml = $("#psq_seller_div_0_0").html();
                    var sellerLi = '<li value = ' + k + ' class="tab_' + k + ' common" onclick="fnshowseller(this);">Seller' + (k + 1) + '</li>'
                    var sellerDiv = '<div id="psq_seller_div_' + i + '_' + k + '" val="' + k + '" propfk="' + SelDet[j].PropFk + '" sellerpk="' + SelDet[j].psq_hdn_Sellerpk + '" class="tab' + k + '-content div_content seller_div psq_seller_div_' + i + '_' + k + '" contentchanged="true"style="display:none;">' + mainHtml + '</div>'
                    var sellerSelect = '<label>Type of Seller</label>' +
                                        '<select name="select2" key="psq_SellerType" class="select mandatory"disabled>' +
                                                    '<option value="-1">Select</option>' +                                                                                                      
                                                   '<option value="S">Seller</option>' +
                                                   //'<option value="B">Builder</option>'+
                                                   ptBuiler +
                                                '</select>'
                    $("#" + divId).find("#psq_ul_seller_tabs").append(sellerLi);
                    $("#" + divId).find("#PostSancSeller").append(sellerDiv);                                      
                    $("#" + divId).find("#" + sellerId).find("li.seller").empty();
                    $("#" + divId).find("#" + sellerId).find("li.seller").append(sellerSelect);            
                                                     
                 }
                    else {
                        $("#" + divId).find("#" + sellerId).attr("sellerpk", SelDet[j].psq_hdn_Sellerpk);
                        $("#" + divId).find("#" + sellerId).attr("propfk", SelDet[j].PropFk);
                    }
                    //fnInitiateSelect(sellerId);
                    $("#" + divId).find("#psq_ul_seller_tabs").find("li.tab_" + k).addClass("active");
                    $("#" + divId).find("#psq_ul_seller_tabs").find("li.tab_" + k).siblings("li").removeClass("active");
                    $("#" + divId).find("#" + sellerId).show();
                    $("#" + divId).find("#" + sellerId).siblings("div.div_content").css("display", "none");
                    $("#" + divId).find("#" + sellerId).find('#psq_buildercin').hide();
                    $("#" + divId).find("#" + sellerId).find('#UlSellerAddr').hide();
                    $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').hide();
                    $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
                    fnClearForm_psq(divId,sellerId,"UlSellerAddr");
                    $("#" + divId).find("#" + sellerId).find(".buildermas").hide();
                    if (SelDet[j].psq_SellerType == "-1") {
                        $("#" + divId).find("#" + sellerId).find('#psq_buildercin').hide();
                        $("#" + divId).find("#" + sellerId).find('#UlSellerAddr').hide();
                       // $("#" + divId).find("#" + sellerId).find('#chkagent').hide();
                        $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').hide();
                        $("#" + divId).find("#" + sellerId).find('#checkAgt').hide();
                        fnClearForm_psq(divId, sellerId, "checkAgt");
                        $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
                        fnClearForm_psq(divId ,sellerId , " .UlSellerAddr");
                        $("#" + divId).find("#" + sellerId).find(".buildermas").hide();
                     

                    }
                    else if (SelDet[j].psq_SellerType == "S") {
                        $("#" + divId).find("#" + sellerId).find(".buildermas").empty();
                        $("#" + divId).find("#" + sellerId).find(".buildermas").show();
                        //$("#" + divId).find("#" + sellerId).find('#chkagent').show();
                        $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').show();
                        $("#" + divId).find("#" + sellerId).find('#psq_buildercin').hide();
                        $("#" + divId).find("#" + sellerId).find('#UlSellerAddr').show()
                        $("#" + divId).find("#" + sellerId).find("input[key='psq_CIN']").val(' ');
                        
                        fnClearForm_psq(divId, sellerId, "checkAgt");
                        $("#" + divId).find("#" + sellerId).find('#checkAgt').show();
                        $("#" + divId).find("#" + sellerId).find(".buildermas input").attr("type", "text");
                        var html = $('<label>Seller Name</label><input type="text" name="text" key="psq_SellerName">');
                        $("#" + divId).find("#" + sellerId).find(".buildermas").append(html);
                        
                    }
                    else {
                        $("#" + divId).find("#" + sellerId).find(".buildermas").empty();
                        $("#" + divId).find("#" + sellerId).find(".buildermas").show();
                       // $("#" + divId).find("#" + sellerId).find('#chkagent').show();
                        $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').show();
                        $("#" + divId).find("#" + sellerId).find('#psq_buildercin').show();
                        $("#" + divId).find("#" + sellerId).find('#UlSellerAddr').hide();
                        fnClearForm_psq(divId, sellerId, "UlSellerAddr");
                        fnClearForm_psq(divId, sellerId, "checkAgt");
                        $("#" + divId).find("#" + sellerId).find('#checkAgt').show();
                        var html = $('<label>Builder Name</label><comp-help id="comp-help" txtcol="BuilderName" valcol="GPk" onrowclick="builderclick" prcname="PrcShflBuilderhelp" width="100%"></comp-help>' +
                                    '<input type="hidden" class="mandatory" valtext="" name="text" key="psq_SellerName">' + '<input type="hidden"  valtext="" name="text" key="psq_BuilderPk">');
                        $("#" + divId).find("#" + sellerId).find(".buildermas").append(html);
                        
                    }


                    
                      //InfavourlistBind(divId, sellerId);
                    fnSetValues(divId + " #psq_seller_div_" + i + '_' + k, sellerDet);
                    if (SelDet[j].psq_check_agt == "0") {
                        $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').show();
                    }
                    else if (SelDet[j].psq_check_agt == "1") {
                        $("#" + divId).find("#" + sellerId).find('#psq_SelAGent').hide();
                    }
                  
                    if (SelDet[j].psq_SellerType == "S") {
                        var valtxt = $("#" + divId).find("#" + sellerId).find("input[key=psq_SellerPin]").val();
                        $("#" + divId).find("#" + sellerId).find("input[key=psq_SellerPin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas").find("input[key='psq_SellerName']").val(SelDet[j].psq_SellerName);
                    } else {
                        $("#" + divId).find("#" + sellerId).find("li.buildermas comp-help").find("input[name='helptext']").val(SelDet[j].psq_SellerName);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas input[key='psq_SellerName']").attr("valtext", SelDet[j].psq_SellerName);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas input[key='psq_SellerName']").attr("value", SelDet[j].psq_SellerName);
                        $("#" + divId).find("#" + sellerId).find("li.buildermas input[key='psq_BuilderPk']").attr("value", SelDet[j].psq_BuilderPk);

                    }
                    $("#" + divId).find("#" + sellerId).find("li.psq-SelAGent").find("input[key='psq_agnttype']").attr("valtext", SelDet[j].AgtName);
                    $("#" + divId).find("#" + sellerId).find("li.psq-SelAGent").find("input[key='psq_agnttype']").attr("value", SelDet[j].psq_agnttype);
                    $("#" + divId).find("#" + sellerId).find("li.psq-SelAGent comp-help").find("input[name='helptext']").val(SelDet[j].AgtName);
                    
               
                        $("#" + divId).find("#" + sellerId).find("li.buildermas").find("input[key='psq_SellerName']").attr("readonly", true);
                        $("#" + divId).find(".li-close").attr("onclick", "");
                        $("#" + divId).find("#" + sellerId).find("comp-help").attr("onrowclick", "");
                        $("#" + divId).find("#" + sellerId).find("comp-help").attr("readonly", "true");
                        $("#" + divId).find("#" + sellerId).find("input[name='helptext']").prop("readonly", "true");                           
                                     
                    k++;
                }
            }   
            //~ISSUE
            //$("#psq_prop_div_" + i).find("#PostSancSeller li").eq(0).click();
        }
        //fnInitiateSelect("postsanction-seller", 1);
    }
}
function fnChangeseller(elem) {
    
    var infavVal = $(elem).attr("selval");
   // $(elem).parent().closest('li').siblings().eq(3).find('input[type=hidden]').val(infavVal);
    $(elem).parent().closest('li').prev().find('input[type=hidden]').val(infavVal)
    //$(".infavIns").find("input[type='hidden']").val(infavVal);
}
function fngetsellerdet(FormID, IsClass) {
    
    var KeyVal = [];
    var KeyJsonTxt = "";
    var IsKeyExists = 0;
    var KeyValObj = {};
    var lpcnt = 0;
    while (lpcnt < PropDvCnt) {
        KeyJsonTxt = "";
        IsKeyExists = 0;
        KeyValObj = {};
        var AppendOperator = "#";
        if (IsClass == 1) { AppendOperator = "." }

        $(AppendOperator + FormID + "_" + lpcnt).find(".seller_div").each(function () {
            KeyJsonTxt = "";
            IsKeyExists = 0;
            KeyValObj = {};
            $(this).find("[name='text']").each(function () {                       
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
            });

            $(this).find("[name='select2']").each(function () {
                if (!($(this).is("[key]"))) { return; }
                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                var keyVal = $(this).val();
                KeyValObj[keyTxt] = keyVal;
                KeyJsonTxt += keyTxt + ",";
            });
            $(this).find(" [name='checkbox']").each(function () {
                if (!($(this).is("[key]"))) { return; }

                IsKeyExists = 1;
                var keyTxt = $(this).attr("key");
                var keyVal = ($(this).is(":checked")) ? "Y" : "N";
                KeyValObj[keyTxt] = keyVal;
                KeyJsonTxt += keyTxt + ",";
            });


            if (IsKeyExists == 1)
                //KeyValObj["PropFk"] = $(AppendOperator + FormID + "_" + lpcnt).attr("propfk");
                KeyValObj["PropFk"] = $(this).attr("propfk");
            KeyValObj["psq_hdn_Sellerpk"] = $(this).attr("sellerpk");
            KeyVal.push(KeyValObj);
        });
        lpcnt += 1;        
    }    
    return KeyVal;
}

function fnClearForm_psq(divId, sellerId, FormID, IsClass) {
   
    var AppendOperator = "#";
    if (IsClass == 1) { AppendOperator = "." }

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='text']").each(function () {
        $(this).val("");
    });

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='select']").each(function () {
        var Option = $(this).siblings("ul").children("li").eq(0).val();

        if (isNaN(Option))
            $(this).attr("selval", "");
        else
            $(this).attr("selval", "-1");

        $(this).val("");
    });

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='select2']").each(function () {
        $(this).val("");
    });

    $(AppendOperator + divId).find(AppendOperator + sellerId).find(AppendOperator + FormID + " [name='checkbox']").each(function () {
        $(this).prop("checked", false);
    });

    //$(AppendOperator + FormID + " .datepicker").val(GlobalXml[0].GlobalDt);
}

function fncheckAgt(elem) {
    
    var chkCnt = 0;
    var ErrMsg = '';
    var propDiv = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
    $("#psq_prop_div_" + propDiv).find(".seller_div").each(function () {
        var chk = $(this).find("[key='psq_check_agt']");
        if ($(chk).prop('checked')) { chkCnt++; }
    });

    if ( chkCnt > 1 )
    {
        $(elem).prop("checked", false);
        fnShflAlert("error", "Select One seller for one Property");        
        return false;
        //$(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").prop("disabled", true);
    }      
    $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li.psq-SelAGent").find("input[key='psq_agnttype']").attr("valtext", "");
    $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li.psq-SelAGent").find("input[key='psq_agnttype']").attr("value", "");
    $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li.psq-SelAGent").find("input[key='psq_agnttype']").attr("valcol", "");    
    $(elem).parent().closest('li').siblings().find("input[name='helptext']").val("");
    if ($(elem).parent().closest('li').find("[name='checkbox']").prop('checked')) {        

        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").val("");
        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li").show();        
}
    else {
        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").val("");        
        $(elem).parent().closest('li').siblings().find("[key='psq_agnttype']").closest("li").hide();        
    }
   
}
/*function fnCheckseller(FormID) {
    var IsKeyExists = 0;  
    var lpcnt = 0;
    var chkCount = '';
    var ErrMsg = '';
    while (lpcnt < PropDvCnt) {
        IsKeyExists = 0;
        chkCount = '';
        var AppendOperator = "#";    
        $(AppendOperator + FormID + "_" + lpcnt).find(".seller_div").each(function () {
           var  elem = this;
           $(elem).find("[key='psq_SellerType']").each(function () {
                var keyVal = $(this).val();
                    $(elem).find("[name='checkbox']").each(function () {
                        var keyVal = ($(this).is(":checked")) ? 0 : 1;
                        if (keyVal == 0) { chkCount = 'Y' }
                    });
            });

        });
        if (chkCount != 'Y') {
            ErrMsg = ErrMsg == "" ? "<br/><b>Property" + (lpcnt + 1) + "</b><br/>Trigger Atleast One Agent !!" : ErrMsg + "<br/><b>Property" + (lpcnt + 1) + "</b><br/>Trigger Atleast One Agent !!";
        }
        lpcnt += 1;
    }

    return ErrMsg;
}

function fnsellerChkMandatory(FormID) {
    
    var MandatoryMsg = "";   
    var FinalErrMsg = '';
    var Mainid = '';
    var ErrMsg = ''
    
    for (var i = 0; i < PropDvCnt; i++) {
                
        ErrMsg = '';
        selvalCnt = Number($("#SanctionDet-div").find("#psq_prop_div_" + i).find("#psq_ul_seller_tabs li.common").last().attr("value"));
        for (var j = 0; j <= selvalCnt; j++) {
         
            Mainid = "#psq_prop_div_" + i + " #psq_seller_div_" + i + "_" + j;
            $(Mainid).find("input").removeClass("mandatory");
            $(Mainid).find("[name=select2]").removeClass("mandatory");
            if ($(Mainid).find("[name='checkbox']").prop('checked')) {
                $(Mainid).find("[key='psq_agnttype']").addClass("mandatory");
            }
            else {
                $(Mainid).find("[key='psq_agnttype']").removeClass("mandatory");
            }
            if ($(Mainid).find("[key = 'psq_SellerType']").val() == "S") {              
                    
                    $(Mainid).find("input").each(function () {
                        if ($(this).attr("key") != 'psq_SellerBuild' && $(this).attr("key") != 'psq_SellerLndMrk' && $(this).attr("key") != 'psq_SellerSt' && $(this).attr("key") != 'psq_CIN' && $(this).attr("key") != 'psq_agnttype') {
                            $(this).addClass("mandatory");
    }
                    });
                    $(Mainid).find("[name=select2]").each(function () {
                        $(this).addClass("mandatory");
                    });

            }
            else if ($(Mainid).find("[key = 'psq_SellerType']").val() == "B") {                            
                $(Mainid).find("input").each(function () {
                        if ($(this).attr("key") == 'psq_SellerName' || $(this).attr("key") == 'psq_CIN') {
                            $(this).addClass("mandatory");
    }
                    });
                $(Mainid).find("[name=select2]").each(function () {
                        if ($(this).attr("key") == 'psq_SellerType')
                            $(this).addClass("mandatory");
                    });
                
    }
    else {
                $(Mainid).find("[name=select2]").each(function () {
                        if ($(this).attr("key") == 'psq_SellerType')
                            $(this).addClass("mandatory");
                    });
               

            }
            MandatoryMsg = '';
            $(Mainid + "  [contentchanged='true'] .mandatory").each(function () {
                var lbl_sibling; var label = "";
                if ($(this).attr("name") == "text" && (($(this).val().trim() == "") || ($(this).val().trim() == "0"))) {
                    lbl_sibling = $(this).siblings("label");
                    label = $(lbl_sibling).text();
                    if (label == "") { label = $(this).attr("placeholder"); }

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required!! <br/>";
                }
                if ($(this).attr("name") == "select" && ($(this).attr("selval") == "-1") || ($(this).attr("selval") == "")) {
                    lbl_sibling = $(this).closest(".select-focus");
                    lbl_sibling = lbl_sibling.siblings("label");
                    label = $(lbl_sibling).text();

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required!! <br/>";
                }
                if ($(this).attr("name") == "select2" && ($(this).val().trim() == "" || $(this).val().trim() == "-1")) {
                    lbl_sibling = $(this);
                    lbl_sibling = lbl_sibling.siblings("label");
                    label = $(lbl_sibling).text();

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required!! <br/>";
                }
            });

            $(Mainid).find("input").removeClass("mandatory");
            $(Mainid).find("[name=select2]").removeClass("mandatory");

            if (MandatoryMsg != "") {
                ErrMsg += "<br/><b>Seller" + (j + 1) + "</b><br/>" + MandatoryMsg + "<br/>";
            }
}       
        if (ErrMsg != "") {
            FinalErrMsg = FinalErrMsg == "" ? "<br/><b>Property" + (i + 1) + "</b><br/>" + ErrMsg + "<br/>" : FinalErrMsg + "<br/><b>Property" + (i + 1) + "</b><br/>" + ErrMsg + "<br/>" ;
        }
    }
    return FinalErrMsg;
    }
function fnchkselMandatory(propval, cur_typ) {

    var ErrMsg = '';
    var FinErrMsg = '';
    if ($("#psq_prop_div_" + propval + " #psq_seller_div_" + propval + "_" + cur_typ).find("[key = 'psq_SellerType']").val() == "S") {
        $("#psq_prop_div_" + propval + " #psq_seller_div_" + propval + "_" + cur_typ).each(function () {
            $(this).find("input").removeClass("mandatory");
            $(this).find("[name=select2]").removeClass("mandatory");
            if ($(this).find("[name='checkbox']").prop('checked')) {
                $(this).find("[key='psq_agnttype']").addClass("mandatory");
            }
            else {
                $(this).find("[key='psq_agnttype']").removeClass("mandatory");
            }
            $(this).find("input").each(function () {
                if ($(this).attr("key") != 'psq_SellerBuild' && $(this).attr("key") != 'psq_SellerLndMrk' && $(this).attr("key") != 'psq_SellerSt' && $(this).attr("key") != 'psq_CIN' && $(this).attr("key") != 'psq_SellerLndMrk' && $(this).attr("key") != 'psq_agnttype') {
                    $(this).addClass("mandatory");
                }
            });
            $(this).find("[name=select2]").each(function () {
                $(this).addClass("mandatory");
            });
        });
    }
    else if ($("#psq_prop_div_" + propval + " #psq_seller_div_" + propval + "_" + cur_typ).find("[key = 'psq_SellerType']").val() == "B") {
        $("#psq_prop_div_" + propval + " #psq_seller_div_" + propval + "_" + cur_typ).each(function () {
            $(this).find("input[name='text']").removeClass("mandatory");
            $(this).find("select[name='select2']").removeClass("mandatory");
            if ($(this).find("[name='checkbox']").prop('checked')) {
                $(this).find("[key='psq_agnttype']").addClass("mandatory");
            }
            else {
                $(this).find("[key='psq_agnttype']").removeClass("mandatory");
            }
            $(this).find("input").each(function () {
                if ($(this).attr("key") == 'psq_SellerName' || $(this).attr("key") == 'psq_CIN') {
                    $(this).addClass("mandatory");
                }
            });
            $(this).find("[name=select2]").each(function () {
                if ($(this).attr("key") == 'psq_SellerType')
                    $(this).addClass("mandatory");
            });
        });
    }
    else {
        $("#psq_prop_div_" + propval + " #psq_seller_div_" + propval + "_" + cur_typ).each(function () {
            $(this).find("input[name='text']").removeClass("mandatory");
            $(this).find("select[name='select2']").removeClass("mandatory");
            $(this).find("[name=select2]").each(function () {
                if ($(this).attr("key") == 'psq_SellerType')
                    $(this).addClass("mandatory");
            });
        });

    }
    $("#psq_prop_div_" + propval + " #psq_seller_div_" + propval + "_" + cur_typ + " [contentchanged='true'] .mandatory").each(function () {
        var lbl_sibling; var label = "";
        if ($(this).attr("name") == "text" && (($(this).val().trim() == "") || ($(this).val().trim() == "0"))) {
            lbl_sibling = $(this).siblings("label");
            label = $(lbl_sibling).text();
            if (label == "") { label = $(this).attr("placeholder"); }

            if (label != "" && label != undefined)
                ErrMsg += label + " Required!! <br/>";
        }
        if ($(this).attr("name") == "select" && ($(this).attr("selval") == "-1") || ($(this).attr("selval") == "")) {
            lbl_sibling = $(this).closest(".select-focus");
            lbl_sibling = lbl_sibling.siblings("label");
            label = $(lbl_sibling).text();

            if (label != "" && label != undefined)
                ErrMsg += label + " Required!! <br/>";
        }
        if ($(this).attr("name") == "select2" && ($(this).val().trim() == "" || $(this).val().trim() == "-1")) {
            lbl_sibling = $(this);
            lbl_sibling = lbl_sibling.siblings("label");
            label = $(lbl_sibling).text();

            if (label != "" && label != undefined)
                ErrMsg += label + " Required!! <br/>";
        }
    });
    if (ErrMsg != "") {
        FinErrMsg = "<br/><b>Seller" + (cur_typ + 1) + "</b><br/>" + ErrMsg + "<br/>";
    }
    return FinErrMsg;
}*/
function fnmanualdev() {
    $("#manualdev").show();
    $("#ManualDeviationLevel").select2({
        minimumResultsForSearch: -1
    });
    fnSelManualDev_ZC();
}

function fnSelManualDev_ZC() {
    var PrcObj = { ProcedureName: "PrcShflManualDeviation", Type: "SP", Parameters: ["MANUALDEV_DATA", JSON.stringify(PostSancGlobal), "", "D"] };
    fnCallLOSWebService("MANUALDEV_DATA", PrcObj, fnProposalResult, "MULTI"); 
}

function fnCnfmManualDeviation(divid) {
    var selval = $("#ManualDeviationLevel").val() || 0;
    if (selval == 0 || selval == "" || selval == "0") {
        fnShflAlert("error", "Deviations Level Required!!");
        return;
    }
    fnSaveManualDeviation('man_deviation_div', 'D', fnProposalResult, 'Save_Deviation', PostSancGlobal)
}
function fnInfatxt(elem)
{
    var value = $(elem).val();
    $(elem).closest("li").find("input[type='hidden']").val(value);
    console.log(value);
}

$(document).on("click", "#dvTotPF", function () {
    $("#CApf").show();
    $(".PFinst").hide();
    $("#spn_title").html("PF Details");
    var PFvalue = parseInt(FormatCleanComma($(this).find("span").text()));
    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["CREDIT_TAX", JSON.stringify(PostSancGlobal), "", "", "", PFvalue] };
    fnCallLOSWebService("TAX", PrcObj, fnProposalResult, "MULTI");
});

$(document).on("click", "#dvColPF", function () {
    $("#CApf").show();
    $(".PFinst").show();
    $("#spn_title").html("PF Details");
    var PFvalue = parseInt(FormatCleanComma($(this).find("span").text()));
    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["CREDIT_TAX", JSON.stringify(PostSancGlobal), "", "", "", PFvalue] };
    fnCallLOSWebService("TAX", PrcObj, fnProposalResult, "MULTI");
});

$(document).on("click", "#dvRemPF", function () {
    $("#CApf").show();
    $("#spn_title").html("Remaining PF Details");
    $(".totPF, .PFinst").hide();
    $(".RemPF").show();

    fnRemPFCalc();
});

function fnRemPFCalc(){
    var LeadFk = PostSancGlobal[0].LeadFk;
    var TotPF = Number(FormatCleanComma($("#SanctionDet-div [key='psq_totpfamt']").justtext())).toFixed(2);
    var ColPF = Number(FormatCleanComma($("#SanctionDet-div [key='psq_colpfamt']").justtext())).toFixed(2);
    var Waiver = Number(FormatCleanComma($("#SanctionDet-div [key='psq_waiveramt']").val())).toFixed(2);

    var PrcObj = { ProcedureName: "PrcShflRemPFCalc", Type: "SP", Parameters: [LeadFk, TotPF, ColPF, Waiver] };
    fnCallLOSWebService("BalPF", PrcObj, fnProposalResult, "MULTI");
}

function fnOpenDeviationFatcors_DA() {
    var PrcObj = { ProcedureName: "PrcShflPostSanction", Type: "SP", Parameters: ["SHOW_DEVIATION", JSON.stringify(PostSancGlobal)] };
    fnCallLOSWebService("SHOW_DEVIATION", PrcObj, fnProposalResult, "MULTI");
}

function fnBuildDeviationTable_DA(DevList,maxapp) {
    isDeviationTable = true;
    $("#deviation-popup-da .popup-content").empty();
    $("#deviation-popup-da").show();
    $("#deviation-popup-da input[type=button]").hide();
    if (DevList.length == 0)
        return;
    var maxApp = 5;
    if (maxapp && maxapp.length > 0)
        maxApp = maxapp[0].MaxApproverLevel;
    var devTbl = "<table style='text-align: left;' border='0'> <tr><th>Stage</th><th>Deviation Factor</th><th>ApplicableTo</th><th>Status</th><th>Arrived</th><th style='display:none;'>Deviation</th><th style='display:none;'>Base</th>" +
        "<th>Approval Level</th><th>Remarks</th></tr>";
    for (var i = 0; i < DevList.length; i++) {
        devTbl += "<tr " + (DevList[i].status == "D" ? "style='color:red;'" : "") + " ><td>" + DevList[i].stage + "</td><td>" + DevList[i].AttrDesc + "</td><td>" + DevList[i].ApplicableTo + "</td><td>" + (DevList[i].status == "N" ? "No Deviation" : "Deviated") + "</td>" +
            "<td>" + DevList[i].Arrived + "</td><td style='display:none;'>" + DevList[i].Deviated + "</td><td style='display:none;'>" + DevList[i].baseval + "</td><td>Level " + DevList[i].approvedBy + "</td><td>" + DevList[i].remarks + "</td></tr>";
    }
    devTbl += "</table>";

    devTbl = $(devTbl);
    $(devTbl).find("td").css({ "padding": "5px 0px" });
    $("#deviation-popup-da .popup-content").append(devTbl); 
    var appUsr = [
       { level: 1, user: 'ZCA' },
       { level: 2, user: 'HO' },
       { level: 3, user: 'HCO' },
       { level: 4, user: 'COO' },
       { level: 5, user: 'MD' },
    ];
    var usrlist = "<table style='margin-top:50px;text-align: left;' border='0'> <tr><th>Level</th><th>Approver</th></tr>";
    for (var j = 0; j < maxApp; j++) {
        usrlist += "<tr><td>" + appUsr[j].level + "</td><td>" + appUsr[j].user + "</td></tr>";
    }
    usrlist += "</table>";

    usrlist = $(usrlist);
    $(usrlist).find("td").css({ "padding": "5px 0px" });
    $("#deviation-popup-da .popup-content").append(usrlist);

}
function agtclick(rowjson) {
    var propDiv = $("#PostSancProperty").find("li.propDiv.active").attr("licount");
    var activeDiv = $("#psq_prop_div_" + propDiv).find("#psq_ul_seller_tabs li.common.active").attr("value");
    var cur_div = $("#psq_prop_div_" + propDiv).find("#psq_seller_div_" + propDiv + '_' + activeDiv);
    $(cur_div).find("li.psq-SelAGent input[name='helptext']").val(rowjson.AgentName);
    $(cur_div).find("li.psq-SelAGent input[key='psq_agnttype']").attr("valtext", rowjson.AgentName);
    $(cur_div).find("li.psq-SelAGent input[key='psq_agnttype']").attr("value", rowjson.Agtpk);
    $(cur_div).find("li.psq-SelAGent input[key='psq_agnttype']").attr("valcol", rowjson.Agtpk);
    $(cur_div).find("ul").attr("contentchanged", "true");
}

 