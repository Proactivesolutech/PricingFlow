var QDEGlobal = [{}];
var QryGlobal = [{}];
var QDEHdrJson = [{}];
var qde_MaxTabNo = 0;
var Prev_Active_li;
var Cur_Active_li;
var IsFinalConfirm = "";
var IsNewData = false;
var Pgrpfk;

$(document).ready(function () {
    QDEGlobal = [{}];
    
    QDEGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    QDEGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    QDEGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    QDEGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    QDEGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    QDEGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    QDEGlobal[0].PrdGrpFk = GlobalXml[0].PrdGrpFk;

    LogJson[0].LgUsr = GlobalXml[0].UsrNm;

    fnClearForm("qde_content", 1);
    Cur_Active_li = $("#qde_ul_app_tabs li[val='0']");

    fnQDELoadLeadDetails();
    selectfocus();

    //$("#qde_btn_Caption").click(function () {        
    //    if ($("#qde_apptyp").val().trim() == "") {
    //        $("#qde_mand_apptyp").css("display", "block");
    //    }
    //    else {
    //        $("#qde_mand_apptyp").css("display", "none");
    //        $("#qde_div_appPop").css("display", "none");
    //        fnQdeAddNewTab($("#qde_ul_app_tabs .QDEAdd"), "", $("#qde_apptyp").val());
    //    }
    //});

    $(".icon-coapplicant").click(function (e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        $("#qde_div_appPop").css("display", "none");
        fnQdeAddNewTab($("#qde_ul_app_tabs .QDEAdd"), "", $(this).text());
    });

    $(".icon-guarantor").click(function (e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        $("#qde_div_appPop").css("display", "none");
        fnQdeAddNewTab($("#qde_ul_app_tabs .QDEAdd"), "", $(this).text());
    });

    fnBindEvts();
    //fngetprdicon();

});

function fnBindliClose(ielem, e) {

    e.stopPropagation();

    if (GlobalXml[0].IsAll == "1")
        return;

    var lival = $(ielem).parent().attr("val");
    var DocPk = $(ielem).parent().attr("pk");

    if (DocPk > 0) {
        var confirmSts = confirm("Do you wish to Delete??");
        if (confirmSts == true) {
            fnDeleteSelectedTab(lival, DocPk);
        }
    }
    else {
        fnClearAftClose(lival);
    }

}
//Vishali
function Pinclick(rowjson, elem)
{   
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}

function fnDeleteSelectedTab(lival, DocPk) {
    var HdrJson = [{ DocPk: DocPk }];

    var objProcData = { ProcedureName: "PrcShflQDEEntry", Type: "SP", Parameters: ["D", JSON.stringify(QDEGlobal), JSON.stringify(HdrJson), "", JSON.stringify(LogJson)] }
    fnCallLOSWebService("QDE_DEL", objProcData, fnQDEResult, "MULTI", lival);
}

function fnClearAftClose(lival) {
    $(".qde_content[val=" + lival + "]").remove();
    $("#qde_ul_app_tabs li[val=" + lival + "]").remove();
    qde_MaxTabNo -= 1;
    Cur_Active_li = $("#qde_ul_app_tabs li[val='0']");
    $("#qde_div_appdtls .common-tabs li").removeClass("active");
    $(Cur_Active_li).addClass("active");
    fnShowseldiv();
}

/************************** Screen Specific Events ********************/
function fnBindEvts() {

    $("#qde_div_appdtls .datepicker").each(function () {
        fnRestrictDate($(this));
    });


    function fnGenerateReport() {
        var objProcData = { ProcedureName: "LOS_formsoftcelldata", Type: "SP", Parameters: [GlobalXml[0].LeadID] }
        fnCallLOSWebService("SoftCell", objProcData, fnQDEResult, "MULTI", "");
    }

    $(document).on("focusout", "#qde_div_appdtls [key='qde_txt_pan']", function () {
        var ValUCase = UpperCase($(this).val());
        $(this).val(ValUCase);

        var RtnSts = ValidatePAN(ValUCase);
        if (RtnSts == false) {
            fnShflAlert("error", "Invalid PAN ID");
            $(this).focus();
            return;
        }
    });

    $("#qde_div_appdtls [key]").each(function () {
        $(document).on("change", "#qde_div_appdtls [key]", function () {
            var lival = $(this).closest(".qde_content").attr("val");
            $(this).closest(".qde_content").children(".qde_ChildConent").attr("contentchanged", "true");
            $("#qde_ul_app_tabs li[val=" + lival + "]").attr("contentchanged", "true");
        });
    });
}

function fnQDELoadLeadDetails() {
    var objProcData = { ProcedureName: "PrcShflQDEEntry", Type: "SP", Parameters: ["LdDtls", JSON.stringify(QDEGlobal), "", "", JSON.stringify(LogJson)] }
    fnCallLOSWebService("QDE_LdDtls", objProcData, fnQDEResult, "MULTI");
}


function SoftCellDownload() {
    window.open("http://uatshrihome.shriramcity.me/SHFLRestServices/UATAddonServices/reportFiles/PDFFiles/" + GlobalXml[0].LeadID + ".pdf");
}


function fnQDEResult(ServDesc, Obj, Param1, Param2) {
    
    if (!Obj.status && ServDesc != "SOftCellACK" && ServDesc != "SOftCellDOWNLD") {
        fnShflAlert("error", Obj.error);
        return;
    }

    if (ServDesc == "UPDATEGPRD") {
        $("#product_popupdiv").hide();
    }
    if (ServDesc == "SoftCell") {
        var Query = JSON.parse(Obj.result);
        var Objt = { InputString: Query[0].Column1 }
        fnCallLOSWebService("SOftCellACK", Objt, fnQDEResult, "SOftCellInput", "");
    }
    if (ServDesc == "SOftCellACK") {
        var ResultData = JSON.parse(Obj);
        //var AckId=Data["ACKNOWLEDGEMENT-ID"];
        var Obj = { AckNo: ResultData["ACKNOWLEDGEMENT-ID"], AckDateTime: ResultData["HEADER"]["REQUEST-RECEIVED-TIME"], LeadNo: GlobalXml[0].LeadID };
        fnCallLOSWebService("SOftCellDOWNLD", Obj, fnQDEResult, "SOftCellResult", "");

    }

    if (ServDesc == "QDE_LdDtls") {
        
        var Data = JSON.parse(Obj.result_1);
        var classname = ''
        var text = ''

        $("#QDE_LeadId").text(Data[0].Nm);
        if (Data[0].productpk == 4) {
            $("#prddiv i").attr("pk", "4");
            classname = "icon-home-loan";
            text = "Home Loan";

        }
        else if (Data[0].productpk == 5) {
            $("#prddiv i").attr("pk", "5");
            classname = "icon-lap";
            text = "Loan Against Property";
        }
        else if (Data[0].productpk == 6) {
            $("#prddiv i").attr("pk", "6");
            classname = "icon-plot-loan";
            text = "Plot Loan";
        }
        var lihtml = ''
        lihtml = '<i class = ' + classname + '></i><p>' + text + '</p>'
        $("#prddiv").append(lihtml)
        $("#QDE_LeadId").text(GlobalXml[0].LeadID);
        $("#QDE_LeadNm").text(GlobalXml[0].LeadNm);
        $("#QDE_Branch").text(GlobalXml[0].Branch);
        if (Data.length > 0) {
            $("#prddiv i").attr("pk", Data[0].productpk);
            Pgrpfk = Data[0].productpk;
            $("#LeadPrdPk").val(Data[0].productpk);
            $("#LeadPrdPk").attr("pcd", Data[0].PCd);
        }


        var DocPks = JSON.parse(Obj.result_2);

        for (var i = 0; i < DocPks.length; i++) {
            if (i > 0) {

                fnQdeAddNewTab($("#qde_ul_app_tabs .QDEAdd"), "Edit", DocPks[i].ActorNm);
            }
            $("#qde_ul_app_tabs li[val='" + DocPks[i].TabNo + "']").attr("Pk", DocPks[i].Pk);
            $("#qde_ul_app_tabs li[val='" + DocPks[i].TabNo + "']").attr("actor", DocPks[i].Actor);
            $("#qde_ul_app_tabs li[val='" + DocPks[i].TabNo + "']").attr("subactor", DocPks[i].SubActor);
        }
        fnGetSelDivValues();

        var DocJson = JSON.parse(Obj.result_3);
        fnLoadDocDatas(DocJson);
        var docld = JSON.parse(Obj.result_4);
        if (docld.length > 0) {
            $(".qde_content").find("input[key=qde_txt_mob]").val(docld[0]["MOBNO"]);
            $(".qde_content").find("input[key=qde_txt_cibil]").val(docld[0]["CIBIL"]);
            $(".qde_content").find("input[key=qde_dt_dob]").val(docld[0]["DOB"]);

                }

    }

    if (ServDesc == "QDE_DATA_SAVE") {
        var Data = JSON.parse(Obj.result);
        $(Prev_Active_li).attr("Pk", Data[0].Pk);

        if (IsNewData == true) {
            fnqdeAddNewData();
        }
        else {
            fnShowseldiv();
            fnGetSelDivValues();
        }
    }

    if (ServDesc == "QDE_DEL") {
        fnClearAftClose(Param2);
    }

    if (ServDesc == "QDE_SEL_DATA") {
        
        var Data = JSON.parse(Obj.result);
        var displaydivval = $(Cur_Active_li).attr("val");
        var set_val_divid = $(".qde_content[val = '" + displaydivval + "']").attr("id");

        $(Cur_Active_li).attr("isel", 1);
        fnSetValues(set_val_divid, Data);
        
        if (Data[0].qde_chk_doc == "0") {           
            $("#" + set_val_divid).find("input[key = 'qde_txt_aadhar']").attr("readonly", "true");
            $("#" + set_val_divid).find("input[key = 'qde_txt_pan']").attr("readonly", "true");            
            $("#" + set_val_divid).find("input[key = 'qde_txt_VotId']").attr("readonly", "true");
        }
        else if (Data[0].qde_chk_doc == "1") {
            $("#" + set_val_divid).find("input[key = 'qde_txt_aadhar']").attr("readonly", false);
            $("#" + set_val_divid).find("input[key = 'qde_txt_pan']").attr("readonly", false);            
            $("#" + set_val_divid).find("input[key = 'qde_txt_VotId']").attr("readonly", false);
        }
        var valtxt = $(".qde_content[val = '" + displaydivval + "']").find("input[key=qde_txt_Pin]").val();
        $(".qde_content[val = '" + displaydivval + "']").find("input[key=qde_txt_Pin]").parent().find("comp-help").find("input[name=helptext]").val(valtxt);
    }
    //if (ServDesc == "sel_icon") {
    //    
    //    var prddata = JSON.parse(Obj.result);
    //    var clsNm = '';
    //    var prd = '';
    //    for (var i = 0; i < prddata.length; i++) {
    //        var liActive = "";
    //        if (prddata[i].ProductCode == $("#LeadPrdPk").attr("pcd")) {
    //            liActive = 'class="active"'
    //        }
    //        //if (prddata[i].ProductCode == "HL") {
    //        //    clsNm = "icon-home-loan"
    //        //}
    //        //else if (prddata[i].ProductCode == "LAP")
    //        //    clsNm = "icon-lap"
    //        //else if (prddata[i].ProductCode == "PL")
    //        //    clsNm = "icon-plot-loan"
    //        clsNm = prddata[i].classnm;
    //        prd += '<li ' + liActive + ' cursor="pointer" ><i pcd= "' + prddata[i].ProductCode + '" pk = "' + prddata[i].productpk + '" class="' + clsNm + '"></i><p>' + prddata[i].productnm + '</p></li>'
    //    }
    //    $("#ul_Prd").append(prd);
    //}
}
function fnqdeAddNewData() {
    $("#qde_div_appPop").css("display", "block");
    IsNewData = false;
}

function fnLoadDocDatas(DocJson) {
    $(".popup.doc-list-view").empty();
    var Data = DocJson;
    var ul = '';
    for (var i = 0; i < Data.length; i++) {
        var apptype = 0;
        if (Data[i].Actor == 2)
            apptype = "Guarantor"
        else if (Data[i].Actor == 1)
            apptype = "CoApplicant";
        else
            apptype = "Applicant";

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

function fnShowseldiv() {
    $("#qde_div_appdtls .qde_content").css("display", "none")

    var displaydivval = $(Cur_Active_li).attr("val");
    $(".qde_content[val = '" + displaydivval + "']").css("display", "block");
}

function fnGetSelDivValues() {
    var DocPk = $(Cur_Active_li).attr("Pk");
    var isSel = $(Cur_Active_li).attr("isel");

    var HdrJson = [{ DocPk: $(Cur_Active_li).attr("Pk") }];

    if (IsFinalConfirm != "") {
        fnCallFinalConfirmation(IsFinalConfirm);
    }

    if (DocPk > 0 && isSel == 0) {
        var objProcData = { ProcedureName: "PrcShflQDEEntry", Type: "SP", Parameters: ["S", "", JSON.stringify(HdrJson), "", JSON.stringify(LogJson)] }
        fnCallLOSWebService("QDE_SEL_DATA", objProcData, fnQDEResult, "MULTI");
    }
}

function fnConfirmScreen(selliObj) {
    
    var AppJson = []; var HdrJson = []; var Prevselli = 0; var LoadDiv = ""; var DocPk = 0;
    var Action = ""; var ErrMSg = ""; var Actor = 0; var SubActor = 1;

    Prevselli = $(Cur_Active_li).attr("val");
    Actor = $(Cur_Active_li).attr("actor");
    SubActor = $(Cur_Active_li).attr("subactor");
    ActorNm = $(Cur_Active_li).text();
    DocPk = $(Cur_Active_li).attr("Pk");

    LoadDiv = $("#qde_div_appdtls div[val='" + Prevselli + "']").attr("id");

    if (GlobalXml[0].IsAll != "1") {

        ErrMsg = fnChkMandatory(LoadDiv);
        
        if (!($("#" + LoadDiv + " [key='qde_chk_doc']").is(":checked"))){
        if ($("#" + LoadDiv + " [key='qde_txt_aadhar']").val() == "" && $("#" + LoadDiv + " [key='qde_txt_pan']").val() == "" && $("#" + LoadDiv + " [key='qde_txt_VotId']").val() == "") {
            ErrMsg = ErrMsg == "" ? "Aadhaar Number / PAN / Voter Id is Required!!" : ErrMsg + "<br/> Aadhaar Number / PAN / Voter Id is Required!!";
            }
        }
        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }
        if ($("#" + LoadDiv + " [key='qde_txt_cibil']").val() < 1 || $("#" + LoadDiv + " [key='qde_txt_cibil']").val() > 900) {
            fnShflAlert("error", "Enter CIBIL value between 1 to 900");
            return false;
        }
    }

    if (GlobalXml[0].IsAll != "1") {

        ErrMsg = fnChkMandatory(LoadDiv);

        if ($("#" + LoadDiv + " [name='helptext']").val() == "" )
            {
            ErrMsg = ErrMsg == "" ? "Pincode required !!" : ErrMsg + "<br/> Pincode Required!!";
        }

        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }
    }

    if (GlobalXml[0].IsAll != "1") {
        ErrMsg = fnChkMandatory(LoadDiv);
        if ($("#" + LoadDiv + " [name='helptext']").val() != "") {
            if ($("#" + LoadDiv + " [name='helptext']").val() != $("#" + LoadDiv + " [key='qde_txt_Pin']").val()) {
                ErrMsg = ErrMsg == "" ? "Valid Pincode required !!" : ErrMsg + "<br/>Valid Pincode Required!!";
            }
        }
        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            return false;
        }
    }

    Prev_Active_li = Cur_Active_li;
    Cur_Active_li = selliObj;

    $("#qde_div_appdtls .common-tabs li").removeClass("active");
    $(Cur_Active_li).addClass("active");
    
    fnFetchApplAddr('', 'Edit');

    if (GlobalXml[0].IsAll == "1") {
        fnShowseldiv();
        fnGetSelDivValues();
        return;
    }

    if ($(Prev_Active_li).attr("contentchanged") == "false") {
        
        if (IsNewData == false) {
            fnShowseldiv();
            fnGetSelDivValues();
        }
        else {
            fnqdeAddNewData();
        }
        return;
    }
    
    var prdval = '';
    var prdval = $("#prddiv i").attr("pk");
    HdrJson = [{ selActor: Actor, subactor: SubActor, DocPk: DocPk, ActorNm: ActorNm, grpprdfk: prdval }];
    AppJson = fnGetFormValsJson_IdVal(LoadDiv);
    Action = (DocPk > 0) ? "E" : "A";
    var objProcData =
            {
                ProcedureName: "PrcShflQDEEntry",
                Type: "SP",
                Parameters:
                [
                    Action, JSON.stringify(QDEGlobal), JSON.stringify(HdrJson), JSON.stringify(AppJson), JSON.stringify(LogJson)
                ]
            };

    fnCallLOSWebService("QDE_DATA_SAVE", objProcData, fnQDEResult, "MULTI", "");

    $("#qde_div_appdtls .common-tabs li").not(".QDEAdd").attr("contentchanged", "false");
    $("#qde_div_appdtls .qde_content .qde_ChildConent").attr("contentchanged", "false");
}

function fnQdeAddNewTab(obj, Action, AppNm) {
    
    var SubActr = 1;
    if (Action == "New") {
        $("#qde_apptyp").val("");
        $("#qde_apptyp").attr("selval", "-1");
        $("#qde_mand_apptyp").css("display", "none");

        IsNewData = true;
        fnConfirmScreen(Cur_Active_li);
        return;
    }
    if (Pgrpfk && Pgrpfk > 0)
        $("#LeadPrdPk").val(Pgrpfk);
    var Class = ""; var ActorNm = "";
    var icon_close = '<i onclick="fnBindliClose(this,event)" class="li-close icon-close"></i>';

    obj.remove();
    qde_MaxTabNo += 1;
    var count = '';
    if (AppNm != "" && AppNm != undefined) {
        ActorNm = AppNm
    }
    else {
        ActorNm = 'Co-Applicant-' + qde_MaxTabNo;
    }
    if (ActorNm == "Co-Applicant") {
        count = 1;
    }
    else {
        count = 2;
    }
    //
    //if ($(AppNm).attr("val") == "1")
    //{
    //    ActorNm = "Co-Applicant";
    //}
    //else
    //{
    //    ActorNm = "Gurantor";
    //}

    if (Action != "Edit") {
        $("#qde_div_appdtls .common-tabs li").removeClass("active");
        Class = 'class="active"';
    }

    //if ($("#qde_apptyp").attr("selval") > 0)
    //    SubActr = ($("#qde_ul_app_tabs li[actor='" + $("#qde_apptyp").attr("selval") + "']").length) + 1;
    SubActr = ($("#qde_ul_app_tabs li[actor='" + count + "']").length) + 1;

    $("#qde_ul_app_tabs").append('<li contentchanged="false" isel="0" Pk="0" actor="' + count + '" subactor="' + SubActr + '" val="' + qde_MaxTabNo + '" onclick="fnConfirmScreen(this)" ' + Class + '>' + ActorNm + '' + icon_close + '</li>');
    $("#qde_ul_app_tabs").append("<li class='QDEAdd' onclick=fnQdeAddNewTab(this,'New')><i class='icon-plus'></i></li>");

    $("#qde_div_appdtls").append('<div class="qde_content" val="' + qde_MaxTabNo + '" id="qde_div_content_' + qde_MaxTabNo + '" style="display:none;"></div>');

    var content = $("#qde_div_content_" + (qde_MaxTabNo - 1)).html();
    $("#qde_div_content_" + qde_MaxTabNo).html(content);
    $("#qde_div_content_" + qde_MaxTabNo).find("input[key = 'qde_txt_aadhar']").attr("readonly", false);
    $("#qde_div_content_" + qde_MaxTabNo).find("input[key = 'qde_txt_pan']").attr("readonly", false);    
    $("#qde_div_content_" + qde_MaxTabNo).find("input[key = 'qde_txt_VotId']").attr("readonly", false);
    
    $("#qde_div_content_" + qde_MaxTabNo + " .datepicker").removeAttr("id");
    $("#qde_div_content_" + qde_MaxTabNo + " .datepicker").removeClass("hasDatepicker");
    fnDrawDatePicker();
    

    $("#qde_div_content_" + qde_MaxTabNo + " .qde_ChildConent").attr("contentchanged", "false");
    $("#qde_div_content_" + qde_MaxTabNo + " .Addr_Chkbx").css("display", "block");
    
   // a();
    $("#qde_div_appdtls .datepicker").each(function () {
        fnRestrictDate($(this));
    });
   
    fnInitiateSelect("qde_div_content_" + qde_MaxTabNo);
    fnClearForm("qde_div_content_" + qde_MaxTabNo);

    if (Action != "Edit") {
        Prev_Active_li = Cur_Active_li;
        Cur_Active_li = $("#qde_ul_app_tabs li[val='" + qde_MaxTabNo + "']");
        $(Cur_Active_li).addClass("active");
        fnShowseldiv();
    }
}

function fnCallScrnFn(FinalConfirm) {
    IsFinalConfirm = FinalConfirm;
    fnConfirmScreen(Cur_Active_li);
}
function fnpop() {
    $("#fold_nm").val(GlobalXml[0].LeadID);
    window.open("", "newWin", "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=20,top=20,width=600,height=600");
    PostForm.submit();
}
$(document).on("keydown", "#CIBIL_ID", function (e) {
    var key = e.keyCode || e.which;
    var val = $("#CIBIL_ID").val();
    if (key == 109) {
        if (val.indexOf("-") >= 0) {
            return false;
        }
        return true;
    }
});

function fnFetchApplAddr(obj, Type) {
    
    var CurrdivId = "#qde_div_content_" + $(Cur_Active_li).attr("val");
    var AppDivId = "#qde_div_content_0";
    var AddrChked = false;

    AddrChked = Type == "Auto" ? $(obj).prop("checked") : $(CurrdivId + " [key='qde_chk_ApplAddr']")[0].checked;

    if (AddrChked == true) {
        var AppAddr = $(AppDivId + " [key='qde_txt_DoorNo']").val();
        $(CurrdivId + " [key='qde_txt_DoorNo']").val(AppAddr).trigger("change");
        $(CurrdivId + " [key='qde_txt_DoorNo']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_BuildNo']").val();
        $(CurrdivId + " [key='qde_txt_BuildNo']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_BuildNo']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_PlotNo']").val();
        $(CurrdivId + " [key='qde_txt_PlotNo']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_PlotNo']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_Street']").val();
        $(CurrdivId + " [key='qde_txt_Street']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_Street']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_LandMark']").val();
        $(CurrdivId + " [key='qde_txt_LandMark']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_LandMark']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_TownVil']").val();
        $(CurrdivId + " [key='qde_txt_TownVil']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_TownVil']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_DisCity']").val();
        $(CurrdivId + " [key='qde_txt_DisCity']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_DisCity']").attr("readonly", "true");

        var AppAddr = $(AppDivId + " [key='qde_txt_State']").val();
        $(CurrdivId + " [key='qde_txt_State']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_State']").attr("readonly", "true");
      
        var AppAddr = $(AppDivId + " [key='qde_txt_Pin']").val();
        $(CurrdivId + " [key='qde_txt_Pin']").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_Pin']").parent().find("comp-help").find("input[name=helptext]").val(AppAddr);
        $(CurrdivId + " [key='qde_txt_Pin']").closest("li").find("comp-help").attr("readonly", "true");
    }

    if (Type == "Auto" && AddrChked == false) {
        
        $(CurrdivId + " [key='qde_txt_DoorNo']").val("");
        $(CurrdivId + " [key='qde_txt_DoorNo']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_BuildNo']").val("");
        $(CurrdivId + " [key='qde_txt_BuildNo']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_PlotNo']").val("");
        $(CurrdivId + " [key='qde_txt_PlotNo']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_Street']").val("");
        $(CurrdivId + " [key='qde_txt_Street']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_LandMark']").val("");
        $(CurrdivId + " [key='qde_txt_LandMark']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_TownVil']").val("");
        $(CurrdivId + " [key='qde_txt_TownVil']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_DisCity']").val("");
        $(CurrdivId + " [key='qde_txt_DisCity']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_State']").val("");
        $(CurrdivId + " [key='qde_txt_State']").attr("readonly", false);
        $(CurrdivId + " [key='qde_txt_Pin']").val("");        
        $(CurrdivId + " [key='qde_txt_Pin']").parent().find("comp-help").find("input[name=helptext]").val("");
        $(CurrdivId + " [key='qde_txt_Pin']").closest("li").find("comp-help").attr("readonly", false);
    }

}


//function fngetprdicon() {
//    var objProcData = { ProcedureName: "PrcShflQDEEntry", Type: "SP", Parameters: ["SEL_PRD"] };
//    fnCallLOSWebService("sel_icon", objProcData, fnQDEResult, "MULTI");
//}

//function fnonpopopen() {
//    
//    $("#ul_Prd").empty();
//    fngetprdicon();
//}
//function fnonclick(elem) {
//    
//    $("#prddiv").empty();
//    $("#product_popupdiv").css("display", "none");
//    $("#LeadPrdPk").attr("pcd", $(elem).children("i").attr("pcd"));
//    $("#LeadPrdPk").val($(elem).children("i").attr("pk"));
//    var prdicon = $(elem).html();
//    $("#prddiv").append(prdicon);
//    //var val = $(Cur_Active_li).attr("val");
//    //$(".qde_content[val=" + val + "]").children(".qde_ChildConent").attr("contentchanged", "true");
//    //$(Cur_Active_li).attr("contentchanged", "true");
//    var prdval = $("#prddiv i").attr("pk");
//    var HdrJson = [{ grpprdfk: prdval }];

//    var objProcData = { ProcedureName: "PrcShflQDEEntry", Type: "SP", Parameters: ["PrdPkUpdate", JSON.stringify(QDEGlobal), JSON.stringify(HdrJson)] };
//    fnCallLOSWebService("UPDATEGPRD", objProcData, fnQDEResult, "MULTI");
//}
function fnDocChk(elem) {
    if($(elem).is(":checked"))
    {
        $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_aadhar']").attr("readonly", "true");
        $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_pan']").attr("readonly", "true");        
        $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_VotId']").attr("readonly", "true");
        $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_aadhar']").val("");
        $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_pan']").val("");        
        $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_VotId']").val("");
    }
    else{
    $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_aadhar']").attr("readonly", false);
    $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_pan']").attr("readonly", false);    
    $(elem).closest("li").closest("ul").find("input[key = 'qde_txt_VotId']").attr("readonly", false);
    }

}