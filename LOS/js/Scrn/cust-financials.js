// JavaScript Document
$(".right-panel.div-right img").click(function () { window.location.reload(); });
FromBranchCredit = 1;
var ISMOVENXT = "";
window.IsBranCreditLoaded;
var INCOME_COMPONENTS;
var PK = '';
var whichDiv;
var FullIncomeLoaded = false;
var param = 0;
/* Custom select set value */
$.fn.setVal = function (SetValue) {
    var selectElement = this;
    var isCustSelect = $(this).hasClass("select-focus");
    var selected = $(this).find("input");
    $(this).find("ul li").removeClass("active");
    if (isCustSelect) {
        $(this).find("ul li").each(function () {
            var activeTxt = $(this).text();
            var activeVal = $(this).attr("val");
            activeVal = activeVal ? activeVal : "";
            if ((SetValue == activeTxt && activeVal == "") || (activeVal == SetValue && activeVal != "")) {
                if (activeVal != "")
                    SetValue = activeTxt;
                $(selected).val(SetValue);
                $(selected).attr("selval", activeVal);
                $(this).addClass("active");
            }
        });
    }
    else {
        return "";
    }
}
/* Custom select get value */
$.fn.getVal = function () {
    var isCustSelect = $(this).hasClass("select-focus");
    var value = "";
    if (isCustSelect) {
        var value = $(this).find("input").attr("selval");
        return value;
    }
    else {
        return "";
    }
};

/* Get only the text inside an element */
jQuery.fn.justtext = function () {
    return $(this).clone().children().remove().end().text().trim();
};

var CustFinGlobal = [{}];
/* Document ready function */
$(document).ready(function () {

    console.log("custfin");

    //Geetha
    //initSample();    

    $("#R_txtLoanAmt").focusout(function () {
        var val = $(this).justtext();
        if (val != "") {
            $(this).text(FormatCurrency(val));
        } else {
            $(this).text(0);
        }
    });

    fnGetIncomeComponents("INIT");
    $("#NHBapplicable").select2({
        minimumResultsForSearch: -1
    });
    $("#NHBpuccahouse").select2({
        minimumResultsForSearch: -1
    });
    $("#NHBcatogory").select2({
        minimumResultsForSearch: -1
    });
    
    CustFinGlobal[0].FwdDataPk = GlobalXml[0].FwdDataPk;
    CustFinGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    CustFinGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    CustFinGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    CustFinGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    CustFinGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    CustFinGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    CustFinGlobal[0].RoleFk = GlobalRoles[0].Role;
    CustFinGlobal[0].BrnchFk = GlobalXml[0].BrnchFk;
    CustFinGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    CustFinGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    CustFinGlobal[0].LeadID = GlobalXml[0].LeadID;
    CustFinGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    CustFinGlobal[0].AgtNm = GlobalXml[0].AgtNm;
    CustFinGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    CustFinGlobal[0].Branch = GlobalXml[0].Branch;
    param = GlobalXml[0].FwdDataPk;
   
    $(".category-info").click(function () {
        // For sub Loan types 
        if (window.CREDIT_APPROVER_NO)
            return;
        var ProductType = $(".category-icons").find("li:nth-child(1) i");
        var subProductType = $("#category-div .popup-content").find("ul:nth-child(1)");
        var isPrdChoosed = $(ProductType).attr("productchoosed");
        subProductType.empty();
        //if (isPrdChoosed == true || isPrdChoosed == "true") { return; }
        var GrpType = $(ProductType).attr("grpfk");
        var tempGlob = CustFinGlobal;
        tempGlob[0].GrpType = GrpType;
        var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SELECT_SUB_PRODUCTS", JSON.stringify(tempGlob)] };
        fnCallLOSWebService("SELECT_SUB_PRODUCTS", PrcObj, fnCustFinResult, "MULTI");
    });

    $("#NHBapplicable").change(function () {
        fnToggleFreezeNHB();
    });


    /* Set Default value for IonRange Slider */
    $(".income-container input[class^=range]").ionRangeSlider({
        min: 0, max: 200, from: 100,
        onChange: fnChangeSliderValue,
        onUpdate: fnUpdateSliderValue
    });    
    fnSelectAll();
    fnSelectCreditDet();
    fnSelectManualDeviationData();
    fnselectPFdetails();
    calcHeight(); //Viewport Height Function Starts
    categoryinfo(); /*income category popup*/
    commontabs(); //Common tab style
    querypopup();
    rightdocument(); /*Document Popup*/
    popupclose(); /*close popup function*/
    customselect(); /*Custom select Function*/
    
    fnEventWithDocumentTarget();

    $(".customer-financial-div .finance-tab i.icon-plus").click(function (e) {
        $("#SelectType").show();
    });

    /* Set the typed comments notes in respective Icon */
    $(".popup-bg .popup-content textarea").focusout(function () {
        try {
            var txt = $(this).val();
            $(remarksicon).attr("txtval", txt);
        }
        catch (e) { }
    });

    /* Set the typed comments notes in Liability Icon */
    //$(".popup-bg .popup-content").focusout(function () {
    //    try {

    //        var txt = $("#Liability-chat").find("textarea").val();
    //        var bounceNo = $("#Liability-chat").find("ul.form-controls li").find("[name = 'Bounce']").val();
    //        var DepBnk = $("#Liability-chat").find("ul.form-controls li").find("[name = 'DebtAmt']").val();

    //        $(Oblremarksicon).attr("txtval", txt);
    //        $(Oblremarksicon).attr("bounce", bounceNo);
    //        $(Oblremarksicon).attr("debtamount", DepBnk);
    //    }
    //    catch (e) { }
    //});

    /* SELECT INCOME TYPE TO ADD */
    $("#SelectType div.category-div ul li").click(function () {
        $(this).addClass("active");
        $(this).siblings("li").removeClass("active");
        var val = $(this).attr("val");
        $("#select-income-type").val(val);
    });

    /* Add Liability */
    $("#loan-type div.category-div ul li").click(function () {
        fniconPlusLiability(this);
    });

    /* TV, PD Feedback popup Hide */
    $("#bc_Feedback_div .icon-close").click(function () {
        $("#bc_Feedback_div").hide();
    });

    /* Date picker */
    fnDrawDatePicker();
    /* select Property*/

    $("#bc_Feedback_div .datepicker").each(function () {
        fnRestrictDate($(this));
    });
    //fnOpenPrpslInfo();
    editortooldisable();
 
});

function fnloaddata(result) {
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["LOAD_DATA", JSON.stringify(CustFinGlobal)] };
    fnCallLOSWebService("LOAD_DATA", PrcObj, fnCustFinResult, "MULTI",result);
}
/* Liability */
function fnopenLoanType(elem) {
    window.ActiveLiabilityDiv = elem;
    $("#loan-type").show();
}

/*Add new Applicant - Not usable here. bcoz it's been already declared */
function fnAddNewApplicant(e, elem, pk, AppData) {
    if (e)
        e.stopPropagation();
    var len = $(elem).siblings().length + 1;
    var actorType = AppData.Actor == 0 ? "Applicant" : AppData.Actor == 1 ? "Co-Applicant" : AppData.Actor == 2 ? "Guarantor" : "";
    var actorName = AppData.ApplicantName ? AppData.ApplicantName : "";
    var custIncType = AppData.customerClass;
    //custIncType = custIncType == -1 ? 0 : custIncType;
    $(elem).before("<li appPk='" + pk + "' val='" + len + "'><p>" + actorName + "</p> <span class='app-type'>" + actorType +
        "</span> <i style='display:none' class='icon-close' onclick='fnCloseAppDiv(event,this)'></i></li>");
    var apndTxt = $(".customer-financial-div[val=1]").html();
    apndTxt = $("<div appPk='" + pk + "' val='" + len + "' class='customer-financial-div'>" + apndTxt + "</div>");
    var uniq = uniqueID();
    apndTxt.find("[id*='lbl-onoffswitchi']").attr("id", "liabOnoff_" + uniq);
    apndTxt.find("[for*='lbl-onoffswitchi']").attr("for", "liabOnoff_" + uniq);

    $(".customer-financial-div").last().after(apndTxt);
    $(".customer-financial-div[val='" + len + "']").show();
    $(".customer-financial-div[val='" + len + "']").attr("custIncType", custIncType);
    $(".customer-financial-div[val='" + len + "']").siblings(".customer-financial-div").hide();

    $(".customer-financial-div[val='" + len + "']").find(".finance-tab li[num]:not('.li-icon-plus')").remove();
    $(".customer-financial-div[val='" + len + "']").find(".box-div.income-container[num]").empty();
    $(".customer-financial-div[val='" + len + "']").find(".box-div.bank-details ul[appfk]").remove();
    $(".customer-financial-div[val='" + len + "']").find(".liability-div div.income-scroll ul.form-controls[LapFk]").remove();
    $(".customer-financial-div[val='" + len + "']").find("li.obligation-li h4").html("<i class='icon-indian-rupee'></i> 0 ");
    $(".customer-financial .common-tabs li[val='" + len + "']").click();
}

/* Close Applicant Div - Not usable Here */
function fnCloseAppDiv(e, elem) {
    var appDiv = $(elem).closest(".customer-financial");
    var Li = $(elem).closest("li[val]");
    var liclick = $(Li).siblings("li[val]")[0];
    var val = $(Li).attr("val");
    var DivToClose = $(appDiv).find(".customer-financial-div[val='" + val + "']");
    $(Li).remove();
    $(DivToClose).remove();
    $(liclick).click();
}

/* Income tab close */
function fnCloseFinTab(e, elem) {
    e.stopPropagation();
    var appDiv = $(elem).closest(".customer-financial-div");
    var Li = $(elem).closest("li[num]");
    var num = $(Li).attr("num");
    var classNm = $(Li).attr("class");
    classNm = classNm.replace("active", "");
    var divClass = classNm.replace("income", "customer");
    divClass = divClass.trim();
    $(appDiv).find(".box-div.income-container ." + divClass + "[num=" + num + "] [restrict='number']").val(0).keyup();
    $(appDiv).find(".box-div.income-container ." + divClass + "[num=" + num + "]").remove();
    var LiList = $(Li).siblings("li");
    $(LiList)[0].click();
    $(Li).remove();
    //$(appDiv).find(".box-div.income-container ." + divClass + "[num=" + num + "] [restrict='number']").keyup();
    return;
}

/* Income type and name choosing */
function fnOpenOptionsToOpen(elem, divWhich) {
    whichDiv = $(elem).closest(".customer-financial-div");
    if (divWhich != null && divWhich == undefined && divWhich == "")
        whichDiv = divWhich;
    $("#SelectType").find("li[val]").removeClass("active");
    $("#txtIncomeNmAc").val("");
    $("#SelectType").show();    
}

/* Open Income Tab */
function fnOpenTab() {
    var txtName = $("#txtIncomeNmAc").val();
    var incometype = $("#select-income-type").val();

    if (txtName.trim() == "") {
        $("#txtIncomeNmAc").attr("placeholder", "Enter Any Name for Income");
        return;
    }


    if ($(whichDiv).find("div[incomename='" + txtName + "']").length > 0)
    { fnShflAlert("error", "Entered name is already added, Add another name."); return; }

    if ($(whichDiv).find("ul li." + incometype).length > 0) {
        //fnShflAlert("error", "Already " + incometype + " is added, Add in the same tab");
        //return;
    }

    var businessUL = $('<li num="1" class="income-business">' +
                        '<p><i class="icon-self-employed"></i>Business  <span class="income-editable" contenteditable="true">' + txtName + '</span></p>' +
                        '<h4 class="totalAvgAmt"><i class="icon-indian-rupee"></i>0</h4>' +
                        '<div class="finance-top">' +
                        '<i onclick="fnCloseFinTab(event,this)" class="icon-close"></i>' +
                        '</div>' +
						'<div class="onoffswitch2">' +
                        '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="myonoffswitch2" checked  />' +
                        '<label class="onoffswitch-label" for="myonoffswitch2"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> </label>' +
                        '</div>' +
                        '</li>');

    var salaryUL = $(' <li num="1" class="income-salary">' +
                        '<p><i class="icon-salaried"></i>Salary <span class="income-editable" contenteditable="true">' + txtName + '</span></p>' +
                        '<h4 class="totalAvgAmt"><i class="icon-indian-rupee"></i>0</h4>' +
                        '<div class="finance-top">' +
                        '<i onclick="fnCloseFinTab(event, this)" class="icon-close"></i>' +
                        '</div>' +
						 '<div class="onoffswitch2">' +
                        '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="myonoffswitch1" checked  />' +
                        '<label class="onoffswitch-label" for="myonoffswitch1"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> </label>' +
                        '</div>' +
                        '</li>');

    var cashUL = $(' <li num="1" class="income-cash">' +
                        '<p><i class="icon-no-proof"></i>Cash <span class="income-editable" contenteditable="true">' + txtName + '</span></p>' +
                        '<h4 class="totalAvgAmt"><i class="icon-indian-rupee"></i>0</h4>' +
                        '<div class="finance-top">' +
                        '<i onclick="fnCloseFinTab(event, this)" class="icon-close"></i>' +
                        '</div>' +
						'<div class="onoffswitch2">' +
                        '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="myonoffswitch3" checked />' +
                        '<label class="onoffswitch-label" for="myonoffswitch3"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> </label>' +
                        '</div>' +
                        '</li>');

    var bankUL = $('<li num="1" class="income-bank">' +
                        '<p><i class="icon-bank"></i>Bank <span class="income-editable" contenteditable="true">' + txtName + '</span></p>' +
                        '<h4 class="totalAvgAmt"><i class="icon-indian-rupee"></i>0</h4>' +
                        '<div class="finance-top">' +
                        '<i onclick="fnCloseFinTab(event, this)" class="icon-close"></i>' +
                        '</div>' +
						 '<div class="onoffswitch2">' +
                        '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="myonoffswitch4" checked />' +
                        '<label class="onoffswitch-label" for="myonoffswitch4"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> </label>' +
                        '</div>' +
                        '</li>');
    var otherUL = $('<li num="1"  class="income-other">' +
                    '<p><i class="icon-fixed-deposits"></i>Others <span class="income-editable" contenteditable="true">' + txtName + '</span></p>' +
                    '<h4 class="totalAvgAmt"><i class="icon-indian-rupee"></i>0</h4>' +
                    '<div class="finance-top"> <i onclick="fnCloseFinTab(event, this)" class="icon-close"></i>' +
                    '</div>' +
					 '<div class="onoffswitch2">' +
                    '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="myonoffswitch4" checked />' +
                    '<label class="onoffswitch-label" for="myonoffswitch4"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> </label>' +
                    '</div>' +
                    '</li>)');

    var businessHTML = $('<div num="1" incomename="' + txtName + '" class="customer-business">' +
                        '<textarea class="TxtRemarks" maxlength="500">Remarks</textarea>' +
                        '<div class="income-div incomerow">' +
                        '<ul particular="true" class="form-controls businessComp">' +
                        '</ul>' +
                        '<div class="grid-type income-details">' +
                        '<ul class="avgcol">' +
                        '</ul>' +
                        '<ul class="form-controls business-form">' +
                        '</ul>' +
                        '</div>' +
                        '<div class="div-right"><i icon="add-income-icon-plus" class="icon-plus" onclick="fnAddIncomeColumn(this,\'customer-business\')"></i></div>' +
                        '<div class="clear"></div>' +
                        '</div>' +
                        '</div>');

    var salaryHTML = $('<div num="1" incomename="' + txtName + '"  class="customer-salary">' +
                        '<div class="income-top">' +
                        '<div class="div-left">' +
                        '<label>Mode of Payment</label>' +
                        '<div class="select-focus" key="MoP">' +
                                '<input selval="" placeholder="--select--" onkeydown="return false" ondrop="return false" onpaste="return false" name="select"' +
                                ' class="autofill" >' +
                                '<i class="icon-down-arrow"></i>' +
                                '<ul class="custom-select" style="display: none;">' +
                                    '<li class="selected" val="C">cash</li>' +
                                    '<li val="B">Bank</li>' +
                                    '<li val="P">Partly Cash</li>' +
                                '</ul>' +
                            '</div>' +
                        '</div>' +
                        '<textarea class="TxtRemarks div-right" maxlength="500">Remarks</textarea>' +
                        '<div class="clear"></div>' +
                        '</div>' +
                        '<div class="income-div incomerow income-scroll">' +
                        '<ul particular="true" class="form-controls IncomeComp">' +
                        '</ul>' +
                        '<div class="grid-type income-details">' +
                        '<ul  class="avgcol">' +
                        '</ul>' +
                        '<ul class="form-controls">' +
                        '</ul>' +
                        '</div>' +
                        '<div class="div-right"><i icon="add-income-icon-plus" class="icon-plus" onclick="fnAddIncomeColumn(this, \'customer-salary\')"></i></div>' +
                        '<div class="clear"></div>' +
                        '</div>' +
                        '</div>');
    var cashHTML = $('<div num="1" incomename="' + txtName + '"  class="customer-cash">' +
                    '<textarea class="TxtRemarks" maxlength="500">Remarks</textarea>' +
                    '<div class="income-div incomerow">' +
                    '<ul particular="true" class="form-controls cashComp">' +
                    '</ul>' +
                    '<div class="grid-type income-details">' +
                    '<ul class="avgcol">' +
                        '</ul>' +
                    '<ul class="form-controls">          ' +
                    '</ul>' +
                    '</div>' +
                    '<div class="div-right"><i icon="add-income-icon-plus" class="icon-plus" onclick="fnAddIncomeColumn(this, \'customer-cash\')"></i></div>' +
                    '<div class="clear"></div>' +
                    '</div>' +
                    '</div>');
    var bankHTML = $('<div num="1" incomename="' + txtName + '"  class="customer-bank">' +
                    '<textarea class="TxtRemarks" maxlength="500">Remarks</textarea>' +
                    '<div class="income-div incomerow">' +
                    '<ul particular="true" class="form-controls bankComp">' +
                    '</ul>' +
                    '<div class="grid-type income-details">' +
                    '<ul class="avgcol">' +
                        '</ul>' +
                    '<ul class="form-controls">          ' +
                    '</ul>' +
                    '</div>' +
                    '<div class="div-right"><i icon="add-income-icon-plus" class="icon-plus" onclick="fnAddIncomeColumn(this, \'customer-bank\')"></i></div>' +
                    '<div class="clear"></div>' +
                    '</div>' +
                    '</div>');
    var otherHTML = $('<div num="1" incomename="' + txtName + '" class="customer-other">' +
                    '<textarea class="TxtRemarks" maxlength="500">Remarks</textarea>' +
                    //'<h5> Average </h5> <input type="text" />' + 
                    '<div class="incomerow">' +
                    '<div class="grid-type div-left">' +
                    '<ul particular="true" class="Ultitle form-controls">' +
                    '<li class="width-15">&nbsp</li>' +
                    '<li class="width-15">Period</li>' +
                    '<li class="width-15">Amount</li>' +
                    '<li class="width-23">Description</li>' +
                    '</ul>' +
                    '<ul class="form-controls">' +
                    '<li class="width-15">' +
                    '<p>Other Income<span contenteditable="true" class="percText right">100</span></p>' +
                    '   <input isOther="yes" type="text" value="" class="range" name="range" />' +
                    '</li>' +
                    '<li class="width-15">' +
                    '<div class="period select-focus">' +
                    '<input placeholder="Period" readonly onkeypress="return false" class="autofill">' +
                    '<i class="icon-down-arrow"></i>' +
                    '<ul class="custom-select">' +
                    '<li val="0">Yearly</li>' +
                    '<li val="1">Monthly</li>' +
                    '</ul>' +
                    '</div>' +
                    '</li>' +
                    '<li class="width-15 amount without-label">' +
                    '<input class="OtherInc currency" type="text" addless="other" restrict="number"/>' +
                    '<i class="icon-indian-rupee"></i>' +
                    '</li>' +
                    '<li class="width-23">' +
                    '<textarea class="desc"></textarea>' +
                    '</li>' +
                    '</ul>' +
                    '</div>' +
                    '<div class="div-right"><i icon="add-income-icon-plus" class="icon-plus" onclick="fnAddOtherColumn(this)"></i></div>' +
                    '<div class="clear"></div>' +
                                '</div>' +
                            '</div>');
    var div = $(whichDiv).find("." + incometype);
    var Divlen = $(div).length + 1;
    var DIVtxt = "";
    var Ultext = "";

    var custDivclass = incometype.replace("income", "customer");


    if (incometype == "income-business") {
        DIVtxt = businessHTML;
        Ultext = businessUL;
    }
    if (incometype == "income-salary") {
        DIVtxt = salaryHTML;
        Ultext = salaryUL;
    }
    if (incometype == "income-cash") {
        DIVtxt = cashHTML;
        Ultext = cashUL;
    }
    if (incometype == "income-bank") {
        DIVtxt = bankHTML;
        Ultext = bankUL;
    }
    if (incometype == "income-other") {
        DIVtxt = otherHTML;
        Ultext = otherUL;

        $(DIVtxt).find(".period").setVal("0");

        $(otherHTML).find(".period li").click(function () {
            setTimeout(function () { $("[restrict='number']").keyup(); }, 200);
        });

    }

    DIVtxt.attr("num", Divlen);
    Ultext.attr("num", Divlen);


    var swithID = Ultext.find("[id*='myonoffswitch']").attr("id");
    var uniq = uniqueID();
    Ultext.find("[id*='myonoffswitch']").attr("id", swithID + "_" + uniq);
    Ultext.find("[for*='myonoffswitch']").attr("for", swithID + "_" + uniq);

    $(whichDiv).find(".finance-tab li.li-icon-plus").before(Ultext);
    $(whichDiv).find(".box-div.income-container").append(DIVtxt);

    $(whichDiv).find(".finance-tab li[num='" + Divlen + "']").click();
    $($(whichDiv).find("." + custDivclass + "[num='" + Divlen + "'] input[class^=range]")).ionRangeSlider({
        min: 0, max: 200, from: 100,
        onChange: fnChangeSliderValue,
        onUpdate: fnUpdateSliderValue
    });
    $("#SelectType").hide();
    var div = $($(whichDiv).find("." + custDivclass + "[num='" + Divlen + "']"));
    var incomeComp;
    if (incometype != "income-other")
        incomeComp = fnSetIncomeComponent(div);
    var returnDiv = $(whichDiv).find(".box-div.income-container").find(DIVtxt);

    $(".income-container input[class^=range][addless='3']").each(function () {
        var slider = $(this).data("ionRangeSlider");
        slider.update({
            min: 0, max: 200, from: 100, from_fixed: true
        });
    });

    return returnDiv;
}

/* Build Applicant Summary */
function fnBuildApplicantSummary(_data, Info, BankData, Liabilitydata, ApplicantIncomeDetails, AgentVerf) {

    var customerClass = [{ name: "Salaried ", class: "icon-salaried" }, { name: "Self Employed", class: "icon-self-employed" },
     { name: "House wife", class: "" }, { name: "Pensioner", class: "" }, { name: "Student", class: "" }];
    var incomeClass = [{ name: "Proof ", class: "icon-proof" }, { name: "Collateral", class: "icon-no-proof" }, { name: "Surrogate", class: "icon-sorrogate" }];

    if (ApplicantIncomeDetails && ApplicantIncomeDetails.length > 0) {

        var custClass_tmp = [{ name: "Salaried ", class: "icon-salaried" }, { name: "Self Employed", class: "icon-self-employed" }];
        var incClass_tmp = [{ name: "Proof ", class: "icon-proof" }, { name: "No Proof", class: "icon-no-proof" }];

        var slryDtl = ApplicantIncomeDetails[0];
        var csClass = slryDtl.saltype;
        var inClass = slryDtl.proof;

        if (csClass && csClass >= 0 && csClass <= 1) {
            $(".category-icons").find("li:nth-child(2) i").attr("class", custClass_tmp[csClass].class);
            $(".category-icons").find("li:nth-child(2) p").text(custClass_tmp[csClass].name);
        } else {
            $(".category-icons").find("li:nth-child(2) i").attr("class", "");
            $(".category-icons").find("li:nth-child(2) p").html("Customer <br>Classification");
        }
        if (inClass && inClass >= 0 && inClass <= 1) {
            $(".category-icons").find("li:nth-child(3) i").attr("class", incClass_tmp[inClass].class);
            $(".category-icons").find("li:nth-child(3) p").text(incClass_tmp[inClass].name);
        } else {
            $(".category-icons").find("li:nth-child(3) i").attr("class", "");
            $(".category-icons").find("li:nth-child(3) p").html("Income <br>Classification");
        }
    }
    else {
        $(".category-icons").find("li:nth-child(2) i").attr("class", "");
        $(".category-icons").find("li:nth-child(2) p").html("Customer <br>Classification");
        $(".category-icons").find("li:nth-child(3) i").attr("class", "");
        $(".category-icons").find("li:nth-child(3) p").html("Income <br>Classification");
    }
    if (Info && Info != null) {
        $("#txtLeadID").text(Info.LeadId);
        $("#txtappNo").text(Info.ApplicationNo);
        $("#txtBrnchNm").text(Info.BranchName);
        $("#txtBrnchNm").attr("branchfk", Info.BranchFk);
        $("#txtLoanPurpose").text(Info.Purpose);
        //$('#txtLoanPurpose').prop('readonly', true);
        var shflPLR = parseInt($("#txtShflPLR").text());
        shflPLR = shflPLR ? shflPLR : 15;
        $("#txtShflPLR").html(shflPLR + ' <span class="percentage">%</span>');
        var loanAmtLkh = Info.LoanAmt / 100000;
        //$("#txtLoanAmt").val(FormatCurrency(Info.LoanAmt));
        $("#txtLoanAmt").text(FormatCurrency(Info.LoanAmt));
        $("#txtLoanAmt").attr("OrgValue", FormatCurrency(Info.LoanAmt));
        $("#txtLoanTenure").val(Info.Tenure);
        $("#txtElgLoanTenure").val(Info.Tenure);
        $("#txtSpread").val(Info.ROI - shflPLR);
        if (Info.ROI)
            $("#txtLoanROI").val(Info.ROI.replace("%", ""));
        var propVal = Info.MrkPropValue / 100000;
        //$("#txtShflPrpVal").val(FormatCurrency(Info.MrkPropValue));
        $("#txtShflPrpVal").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Info.MrkPropValue));
        $("#txtShflPrpVal").attr("OrgValue", FormatCurrency(Info.MrkPropValue));
        if (Info.ProductCode == "HLBTTopup" || Info.ProductCode == "HLBT" || Info.ProductCode == "HLTopup" ||
            Info.ProductCode == 'LAPBTTopup' || Info.ProductCode == 'LAPBT' || Info.ProductCode == 'LAPTopup' ||
            Info.ProductCode == "HLExt" || Info.ProductCode == "HLImp"
            ) {
            $("#LoanExist").show();
        }
        if (!Info.ProductFk || Info.ProductFk == "" || Info.ProductFk == "0") {
            $(".category-icons").find("li:nth-child(1) i").attr("ProductChoosed", false);
            $(".category-icons").find("li:nth-child(1) i").attr("class", Info.grpicon);
            $(".category-icons").find("li:nth-child(1) i").attr("grpfk", Info.ProductGrpFk);
            $(".category-icons").find("li:nth-child(1) i").attr("prdfk", "0");
            $(".category-icons").find("li:nth-child(1) i").attr("prdcode", Info.ProductCode);
            $(".category-icons").find("li:nth-child(1) i").attr("pk", "0");
            $(".category-icons").find("li:nth-child(1) p").text(Info.grpName);
        }
        else {
            $(".category-icons").find("li:nth-child(1) i").attr("ProductChoosed", true);
            $(".category-icons").find("li:nth-child(1) i").attr("class", Info.prdicon);
            $(".category-icons").find("li:nth-child(1) i").attr("grpfk", Info.ProductGrpFk);
            $(".category-icons").find("li:nth-child(1) i").attr("prdfk", Info.ProductFk);
            $(".category-icons").find("li:nth-child(1) i").attr("prdcode", Info.ProductCode);
            $(".category-icons").find("li:nth-child(1) i").attr("pk", Info.ProductFk);
            $(".category-icons").find("li:nth-child(1) p").text(Info.ProductName);
        }
    }
    $("#Brnch_summary.applicant-summary").empty();
    var data = _data;
    var Summary = "";
    var Mxcibil = -1;
    $("#MaxCibil").text(-1);
    for (var j = 0; j < data.length; j++) {        
        if (data[j].CIBILscore > Mxcibil)
        {
            $("#MaxCibil").text(data[j].CIBILscore);
            Mxcibil = data[j].CIBILscore;
        }       
        var custIncType = data[j].customerClass;
        Summary += '<div box="' + (j + 1) + '" AppFk="' + data[j].AppFk + '"  class="applicant-box">' +
                    '<div onclick="fnOpenCreditScreen_BC(event,this)" class="applicant-info div-left cursor"> <img src="images/photo.jpg" alt="" class="left"> </div>' +
                    '<div class="div-left">' +
                    '    <p key="Age" name="AGE" class="bg-tag bg1 age">' + data[j].Age + '</p>' +
                    '   <p class="ApplicantName center">' + data[j].ApplicantName + '</p>' +
                    '   <p class="Appincome-type center" incType="' + custIncType + '">' + (custIncType == -1 ? "" : customerClass[custIncType].name) + '</p>' +
                    '    <div class="appliant-verifications" LapFk="' + data[j].AppFk + '"> ' +
                    '    <span name="FIR" title="Field Investigation - Residencial" class="bg-tag bg8 cursor" onclick="fnAgentspopup_BC(this);">FIR</span> ' +
                    '    <span name="FIO" title="Field Investigation - Office" class="bg-tag bg8 cursor" onclick="fnAgentspopup_BC(this);">FIO</span> ' +
                    '    <span name="DV" title="Document verification" class="bg-tag bg8 cursor" onclick="fnAgentspopup_BC(this);">DV</span> ' +
                    '    <span name="CF" title="Collection FeedBack" class="bg-tag bg8 cursor" onclick="fnAgentspopup_BC(this);">CF</span>' +
                    '    <span name="TER" pk="0" class="bc_link_feeback bg bg8 cursor" flag="3" id="spantele_R">TE (R)</span> ' +
                    '    <span name="TEO" pk="0" class="bc_link_feeback bg bg8 cursor" flag="1" id="spantele">TE (O)</span> ' +
                    '    <span name="PD" pk="0" class="bc_link_feeback bg bg8 cursor" flag="2" id="spanpd">PD</span> ' +
                    ' </div>' +
                    ' </div>' +
                    '<div class="div-right applicant-income">' +
                    '    <div class="applicant-amount cursor">' +
                    '        <div class="left box-div">' +
                    '            <p class="income-amount"><i class="icon-indian-rupee"></i>0</p>' +
                    '            <h5>Income</h5>' +
                    '        </div>' +
                    '        <div class="left box-div">' +
                    '            <p class="liability-amount"><i class="icon-indian-rupee"></i>0</p>' +
                    '            <h5>Obligation</h5>' +
                    '        </div>' +
                    '        <div class="left box-div">' +
		            '            <p class="cibil-score">' + data[j].CIBILscore + '</p>' +
                    '            <h5>Cibil</h5>' +
                    '        </div>' +
	                '    </div>' +
                    '    </div>' +
                    '    <div class="clear"></div>' +
	                '</div>';

    }
    Summary += "<div class='clear'></div>";
    $("#Brnch_summary.applicant-summary").append(Summary);

    for (var i = 0; i < data.length; i++) {
        var custIncType = data[i].customerClass;
        //custIncType = custIncType == -1 ? 0 : custIncType;
        if (i > 0) {
            var elem = $(".customer-financial ul.common-tabs li.li-icon-plus");
            var AppActor = data[i].Actor;
            fnAddNewApplicant(null, elem, data[i].AppFk, data[i]);
        }
        else {
            var nm = data[i].ApplicantName ? data[i].ApplicantName : "";
            $(".customer-financial ul.common-tabs .applicant-li li:first-child p").text(nm);
            $(".customer-financial ul.common-tabs .applicant-li li:first-child").attr("appPk", data[i].AppFk);
            var actorType = data[i].Actor == 0 ? "Applicant" : data[i].Actor == 1 ? "Co-Applicant" : data[i].Actor == 2 ? "Guarantor" : "";
            $(".customer-financial ul.common-tabs .applicant-li li:first-child .app-type").text(actorType);
            $(".customer-financial .customer-financial-div").attr("appPk", data[i].AppFk);
            $(".customer-financial .customer-financial-div").attr("custIncType", custIncType);

        }
        // Build Bank data
        if (BankData) {
            var UlBankHtml = "";
            for (var k = 0; k < BankData.length; k++) {
                if (BankData[k].AppPk == data[i].AppFk) {
                    var actypeText = "";
                    var acctype = parseInt(BankData[k].AccountType);
                    switch (acctype) {
                        case 0:
                            actypeText = "Current";
                            break;
                        case 1:
                            actypeText = "Saving";
                            break;
                        case 2:                           
                            actypeText = "Overdraft";
                            break;
                        case 3:
                            actypeText = "Cash Credit";
                            break;
                        default:
                            break;
                    }

                    var AccTypeHTML = '     <div name="AccountType" class="select-focus">' +
                                  '       <input selval="' + BankData[k].AccountType + '" value="' + actypeText + '" ' +
                                  'placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                                  '      <i class="icon-down-arrow"></i>' +
                                  '     <ul class="custom-select">' +
                                  '      <li val="0">Current</li>' +
                                  '              <li val="1">Saving</li>' +
                                  '            <li val="2">Overdraft</li>' +
                                  '           <li val="3">Cash Credit</li>' +
                                  '        </ul>' +
                                  '     </div>';


                    UlBankHtml = $('<ul appFk="' + BankData[k].AppPk + '" bankpk="' + BankData[k].BankPk + '" class="form-controls">' +
                                  '        <li class="width-11">' +
                                  '          <input readonly name="AccountName" type="text" placeholder="" value="' + BankData[k].AccountName + '">' +
                                  '      </li>' +
                                  '     <li class="width-18">' +
                                 AccTypeHTML +
                                  '  </li>' +
                                  '        <li class="width-11">' +
                                  '         <input type="text" name="AccountNumber" placeholder="" value="' + BankData[k].AccountNumber + '">' +
                                  '      </li>' +
                                   '  <li class="width-9">' +
                                       ' <input type="text" placeholder="" name="OperativeSince" value="' + BankData[k].OperativeSince + '" class="datepickerdef" restrict="number">' +
                                   ' </li>' +
                                  '     <li class="width-32">' +
                                  //'      <input type="text" name="BankName" placeholder="" value="' + BankData[k].BankName + '">' +
                                  '<comp-help id="bank-help" name="BankName" txtcol="BankName" valcol="Bankpk" onrowclick="fnBnkclick" prcname="PrcShflScanBankhelp"' +
                                  ' width="100%"></comp-help>' +
                                  '   </li>' +
                                  '        <li class="width-18">' +
                                  //'         <input type="text" name="BranchName" placeholder="" value="' + BankData[k].BranchName + '">' +
                                  '<comp-help id="branch-help" name="BranchName" txtcol="Location" valcol="Brnchpk" helpfk="0" onrowclick="fnBrnchclick" ' +
                                  'prcname="PrcShflscanBranchhelp" width="100%"></comp-help>' +
                                  '      </li>' +
                                  '     <li class="width-22">' +
                                  '      <div name="bnkTran" class="select-focus">' +
                                  '            <input selval="-1" placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                                  '           <i class="icon-down-arrow"></i>' +
                                  '          <ul class="custom-select">' +
                                  '           <li val="0">&lt;6</li>' +
                                  '          <li val="1">6-18</li>' +
                                  '              <li val="2">&gt;18</li>' +
                                  '           </ul>' +
                                  '        </div>' +
                                  '</li>' +
                                  '        <li class="width-53">' +
                                  '         <input type="text" restrict="number" name="AvgBal" placeholder="" value="' + BankData[k].AvgBal + '">' +
                                  '      </li>' +
                                  '     <li class="width-53">' +
                                  '     <div name="InChqBounce" class="select-focus">' +
                                  '       <input selval="-1" placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                                  '      <i class="icon-down-arrow"></i>' +
                                  '     <ul class="custom-select">' +
                                  '      <li val="0">0</li>' +
                                  '     <li val="1">&lt;3</li>' +
                                  '    <li val="2">&gt;=3</li>' +
                                  '            </ul>' +
                                  '         </div>' +
                                  '      </li>' +
                                  '     <li class="width-5 align-center">' +
                                  '      <i name="Notes" txtval="' + BankData[k].Notes + '" class="icon-chat-o"></i> ' +
                                  '   </li>' +
                                  '  <li class="width-5 align-center">' +
                                  '      <i name="close" onclick="fnCloseBank(this)" class="icon-close"></i> ' +
                                  '   </li>' +
                                  '</ul>');

                    $(UlBankHtml).find("[name='bnkTran']").setVal(BankData[k].bnkTran);
                    $(UlBankHtml).find("[name='InChqBounce']").setVal(BankData[k].InChqBounce);
                    $(".customer-financial .customer-financial-div[appPk='" + data[i].AppFk + "']").find(".bank-details.box-div").append(UlBankHtml);
                    $(UlBankHtml).find("[name='BankName'] input").val(BankData[k].BankName);
                    $(UlBankHtml).find("[name='BankName'] input").attr("val", BankData[k].BankFk);
                    $(UlBankHtml).find("[name='BranchName']").attr("helpfk", BankData[k].BankFk);
                    $(UlBankHtml).find("[name='BranchName'] input").val(BankData[k].BranchName);                    
                    $(UlBankHtml).find("[name='BranchName'] input").attr("val", BankData[k].BranchFk);
                    fnDrawDefaultDatePicker();
                    $(".bank-details .datepicker,.datepickerdef").each(function () {
                        fnRestrictDate($(this));
                    });
                    fnInitiateSelect("bank-details", 1);
                }
            }
        }

        // Set Obligations if available 
        if (Liabilitydata) {
            //Loan Type 0 - Bike, 1 - Car, 2 - Two Wheeler, 3 - Home, 4 - LAP
            //Loan Included or Not 0 - Yes, 1 - No            
            //Loan Taken at Shriram 0 - No, 1 - Yes
            var LiabilityUL = "";
            for (var L = 0; L < Liabilitydata.length; L++) {

                if (Liabilitydata[L].LapFk == data[i].AppFk) {
                    var LoanTypCls = "";
                    var LoanTyp = parseInt(Liabilitydata[L].LoanType);
                    var ischkd = parseInt(Liabilitydata[L].OblIncExc);
                    var chkd = ischkd == 0 ? "checked" : "";
                    var isSvs = parseInt(Liabilitydata[L].IsSVS);
                    var svschk = isSvs == 0 ? "checked" : "";

                    switch (LoanTyp) {
                        case 0:
                            LoanTypCls = "icon-auto-loan";
                            break;
                        case 1:
                            LoanTypCls = "icon-car-loan";
                            break;
                        case 2:
                            LoanTypCls = "icon-two-wheeler-loan";
                            break;
                        case 3:
                            LoanTypCls = "icon-home-loan";
                            break;
                        case 4:
                            LoanTypCls = "icon-lap";
                            break;
                        case 5:
                            LoanTypCls = "icon-gold-loan";
                            break;
                        case 6:
                            LoanTypCls = "icon-personal-loan";
                            break;
                        case 7:
                            LoanTypCls = "icon-business";
                            break;
                        case 8:
                            LoanTypCls = "icon-term";
                            break;
                        case 9:
                            LoanTypCls = "icon-consumer-loan";
                            break;
                        case 10:
                            LoanTypCls = "icon-consumer-loan";
                            break;
                        default:
                            break;
                    }
                    LiabilityUL = $('  <ul liabilitypk = "' + Liabilitydata[L].OblPk + '" LapFk = "' + Liabilitydata[L].LapFk + '"class="form-controls">' +
                    '<li class="width-6a">' +
                    '   <div class="onoffswitch2">' +
                    '      <input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="lbl-onoffswitchi" ' + chkd + ' />' +
                    '     <label class="onoffswitch-label" for="lbl-onoffswitchi"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch">' +
                    '</span> </label>' +
                    '</div>' +
                    '                                </li>' +
                    '                               <li class="width-6c">' +
                    '                                  <div class="icon_img">' +
                    '                                     <i name="OblLoanType" LoanType="' + Liabilitydata[L].LoanType + '"class="' + LoanTypCls + '"></i> ' +
                    '<span class="svs-img">' +
                    '                                        <input class="img-switcher" id="lbl-img-switcher-default" type="checkbox" ' + svschk + ' />' +
                    '                                       <label for="lbl-img-switcher-default"></label>' +
                    '                                  </span>' +
                    '                             </div>' +
                    '                        </li>' +
                    '                       <li class="width-12">' +
                    '                          <input type="text" name="Bank" value = "' + Liabilitydata[L].Source + '">' +
                    '                     </li>' +
                    '                    <li class="width-15">' +
                    '                       <input type="text" name="RefNo" value = "' + Liabilitydata[L].RefNo + '">' +
                    '              </li>' +
                                   '<li class="width-10 without-label">'+
                                            '<i class="icon-indian-rupee"></i>'+
                                            '<input type="text" name="Lnamt" class="currency" restrict="number" value="' + Liabilitydata[L].Lnamt + '" >' +
                                        '</li>'+
                    '                  <li class="width-15 amount widthout-label">' +
                    '                     <input type="text" name="EMI" value = "' + FormatCurrency(Liabilitydata[L].EMI) +
                    '" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;" />' +
                    '                    <i class="icon-indian-rupee"></i>' +
                    '               </li>' +
                    '             <li class="width-15 amount widthout-label">' +
                    '                <input type="text" name="OutStandAmt" value = "' + FormatCurrency(Liabilitydata[L].OutStandingAmt) +
                    '" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;">' +
                    '               <i class="icon-indian-rupee"></i>' +
                    '          </li>' +
                    '         <li class="width-8a">' +
                    '            <input type="text" name="RemTerms" value = "' + Liabilitydata[L].Tenure +
                    '" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;">' +
                    '       </li>' +
                     '         <li class="width-8a">' +
                    '            <input type="text" name="Bounce" value = "' + Liabilitydata[L].OblBounce +
                    '"onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;">' +
                    '       </li>' +
                     '         <li class="width-12 DebtBank">' +
                    //'            <input type="text" name="DebtBank" value = "' + Liabilitydata[L].OblDebtBank + '">' +
                                    '<comp-help id="comp-help" txtcol="BankName" valcol="Bankpk" onrowclick="DebtBnkclick" prcname="PrcShflScanBankhelp" width="100%"></comp-help>' +
                                    '<input type="hidden" name="text" key="debt_bankName" value = "' + Liabilitydata[L].OblDebtBank + '">' +
                    '       </li>' +
                    '      <li class="width-6b"> <i name="Notes"  txtval="' + Liabilitydata[L].OblNotes +
                    '" class="icon-chat-o"></i> <i class="icon-close" onclick="fnCloseLiability(this)"></i></li>' +
                    ' </ul>');

                    var swithID = LiabilityUL.find("[id*='lbl-onoffswitchi']").attr("id");
                    var uniq = uniqueID();
                    uniq = uniq.toString();
                    LiabilityUL.find("[id*='lbl-onoffswitchi']").attr("id", swithID + "_" + uniq);
                    LiabilityUL.find("[for*='lbl-onoffswitchi']").attr("for", swithID + "_" + uniq);

                    var svsID = "svsID_";
                    uniq = uniqueID();
                    uniq = uniq.toString();
                    LiabilityUL.find("[id*='lbl-img-switcher-default']").attr("id", svsID + "_" + uniq);
                    LiabilityUL.find("[for*='lbl-img-switcher-default']").attr("for", svsID + "_" + uniq);

                    $(".customer-financial .customer-financial-div[appPk='" + data[i].AppFk + "']").
                            find(".liability-div div.income-scroll").append(LiabilityUL);
                    $(".customer-financial .customer-financial-div[appPk='" + data[i].AppFk + "'] .liability-div .TxtRemarks").
                        val(Liabilitydata[L].HdRmks);
                    $(".customer-financial .customer-financial-div[appPk='" + data[i].AppFk + "']").
                       find(".liability-div div.income-scroll ul").each(function () {
                           $(this).find("comp-help").find("[name = 'helptext']").val($(this).find("[key = 'debt_bankName']").val())
                       });
                }
            }
        }
        $("#Brnch_summary.applicant-summary").append('<div class="clear"></div>');
        $(".liability-div .grid-type ul.form-controls input[name=EMI]").keyup();
    }

    //changes by kani  on 31/12/2016 start

    if (AgentVerf && AgentVerf.length > 0) {

        $(".applicant-summary .appliant-verifications span").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
        $(".applicant-summary .appliant-verifications span").addClass("bg8");
        $(".prop-label-list span").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
        $(".prop-label-list span").addClass("bg8");


        $(".prop-label-list span").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
        $(".prop-label-list span").addClass("bg8");

        var StsRejTV = "";
        var StsPendingTV = "";
        var StsRejLV = "";
        var StsPendingLV = "";
        //$(".applicant-summary .appliant-verifications span[key='age']").addClass("bg1");
        for (var L = 0; L < AgentVerf.length; L++) {
            var LapFk = AgentVerf[L].LapFk;
            var Key = AgentVerf[L].serv;
            var status = AgentVerf[L].Status;
            if (Key == "TV") {
                var span = $(".prop-label-list span[name='" + Key + "']");
                $(span).removeClass("bg8");
                if (status == "0" || status == 0) { StsRejTV = "R" }
                if (status == "1" || status == 1) { StsPendingTV = "P" }
                if (status == "2" || status == 2) { }
                if (StsRejTV == "R") { $(span).removeClass("bg1 bg2 bg3 bg8"); $(span).addClass("bg2"); }
                if (StsPendingTV == "P" && StsRejTV == "") { $(span).removeClass("bg1 bg2 bg3 bg8"); $(span).addClass("bg3"); }
                if (StsRejTV == "" && StsPendingTV == "") { $(span).removeClass("bg1 bg2 bg3 bg8"); $(span).addClass("bg1"); }
            }
            else if (Key == "LV") {
                var span = $(".prop-label-list span[name='" + Key + "']");
                $(span).removeClass("bg8");
                if (status == "0" || status == 0) { StsRejLV = "R" }
                if (status == "1" || status == 1) { StsPendingLV = "P" }
                if (status == "2" || status == 2) { }
                if (StsRejLV == "R") { $(span).removeClass("bg1 bg2 bg3 bg8"); $(span).addClass("bg2"); }
                if (StsPendingLV == "P" && StsRejLV == "") { $(span).removeClass("bg1 bg2 bg3 bg8"); $(span).addClass("bg3"); }
                if (StsRejLV == "" && StsPendingLV == "") { $(span).removeClass("bg1 bg2 bg3 bg8"); $(span).addClass("bg1"); }
            }            
            else {
                if (LapFk != "" && LapFk != 0 ) {
                    var SummaryDiv = $(".applicant-summary").find(".applicant-box[AppFk='" + LapFk + "']");
                    var span = $(SummaryDiv).find(".appliant-verifications span[name='" + Key + "']");
                    $(span).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                    if (status == "0" || status == 0) { $(span).addClass("bg2"); }
                    if (status == "1" || status == 1) { $(span).addClass("bg3"); }
                    if (status == "2" || status == 2) { $(span).addClass("bg1"); }
                }
            }
        }
    }
    //changes by kani on 31/12/2016 end
}

/* Add a column in Income tab */
function fnAddIncomeColumn(elem, classNm) {
    var IncomeDiv = $(elem).closest("." + classNm);
    var num = $(IncomeDiv).attr("num");
    var html = $($("." + classNm + "[num=" + num + "] .income-details .form-controls")[0]).html();
    var Divlen = $(IncomeDiv).find(".income-details .form-controls").length;
    if (classNm == "customer-business")
        html = $("<ul class= 'form-controls business-form'>" + html + "</ul>");
    else
        html = $("<ul class= 'form-controls'>" + html + "</ul>");
    html.find(".li-income-title h4").html('<i class="icon-indian-rupee"></i> 0');
    $(IncomeDiv).find(".income-details").append(html);
    var retDiv = $(IncomeDiv).find(".income-details").find(html);
    $(retDiv).find(".li-income-title p").text("Period " + (Divlen + 1));
    $(retDiv).find(".li-income-title span.Business_DoF").text("DoF");
    $(retDiv).find("[restrict='number']").keyup();
    return retDiv;
}

/* Add a column for others income type */
function fnAddOtherColumn(elem) {
    var classNm = "customer-other"
    var IncomeDiv = $(elem).closest("." + classNm);
    var num = $(IncomeDiv).attr("num");
    var ul = $('<ul class="form-controls">' +
    '<li class="width-15">' +
    '<p>Other Income<span contenteditable="true" class="percText right">100</span></p>' +
    ' <input isOther="yes" type="text" value="" class="range" name="range" />' +
    '</li>' +
    '<li class="width-15">' +
    '<div class="period select-focus">' +
    '<input placeholder="Period" readonly onkeypress="return false" class="autofill">' +
    '<i class="icon-down-arrow">' +
    '</i>' +
    '<ul class="custom-select">' +
        '<li val="0">Yearly</li>' +
        '<li val="1">Monthly</li>' +
        '</ul>' + '</div>' + '</li>' +
    '<li class="width-15 amount without-label">' +
    '<input type="text" class="OtherInc currency" comppk="" addless="other" restrict="number">' +
    '<i class="icon-indian-rupee"></i></li>' +
    '<li class="width-23">' +
    '<textarea class="desc">' +
    '</textarea>' +
    '</li>' +
    '<i class="icon-close" onclick="fnCloseOtherCol(this)"></i>' +
    '</ul>');
    $(IncomeDiv).find(".incomerow .grid-type.div-left").append(ul);

    $(ul).find(".period").setVal("0");

    $(ul).find(".period li").click(function () {
        setTimeout(function () { $("[restrict='number']").keyup(); }, 200);
    });

    $(ul).find("[class^=range]").ionRangeSlider({
        min: 0, max: 200, from: 100,
        onChange: fnChangeSliderValue,
        onUpdate: fnUpdateSliderValue
    });

    $(ul).find(".period.select-focus").setVal("0");
    return $(IncomeDiv).find(".incomerow .grid-type.div-left").find(ul);
}

/* Close option for Others Column */
function fnCloseOtherCol(elem) {
    $(elem).closest(".form-controls").remove();
    $("[restrict='number']").keyup();
}

/* Select The Docs list */
function fnSelectDocment() {
    $(".popup-bg.document-pop-content div.preview-icons.right").empty();
    var pk = CustFinGlobal[0].LeadPk;
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["DOCUMENT", JSON.stringify(CustFinGlobal)] };
    fnCallLOSWebService("DOCUMENT", PrcObj, fnCustFinResult, "MULTI");
}

// Close Income colunm 
function fnCloseIncomeCol(elem) {
    var Grid = $(elem).closest(".grid-type.income-details");
    var divlen = $(Grid).find(".form-controls").length;
    if (divlen > 1)
        $(elem).closest(".form-controls").remove();
    $(Grid).find(".form-controls input").keyup();
}


/* Allows only Number Key Press */
function fnNumberKeyPress(e, elem) {
    var keyCode = e.which ? e.which : e.keyCode
    var ret = ((keyCode >= 48 && keyCode <= 57));
    return ret;
}

/* Allows only Alpha Key Press */
function fnAlphaKeyPress(e, elem) {

    var keyCode = e.which ? e.which : e.keyCode
    var ret = ((keyCode >= 65 && keyCode <= 90) || (keyCode >= 97 && keyCode <= 122));
    return ret;
}

/*Get the Income Components */
function fnGetIncomeComponents(divID) {
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["GET_INCOME_COMPONENTS", JSON.stringify(CustFinGlobal)] };
    fnCallLOSWebService("INCOME_COMP", PrcObj, fnCustFinResult, "MULTI", divID);
}

/* DB Results */
function fnCustFinResult(ServiceFor, Obj, Param1, Param2) {
    if (!Obj.status && ServiceFor != "PD_UPLOAD")
    { fnShflAlert("error", Obj.error); return; }


    if (ServiceFor == "LOAD_DATA")
    {
        
        var append = "";
        var data = JSON.parse(Obj.result);
        if(data.length > 0)
        {
            for (i = 0; i < data.length; i++) {
                append = '<div class="proposal-category" pk="' + data[i].Mpk + '"><h2 class="deviation-category-title cursor">' + data[i].Masname + '</h2>' +
                    '<div class="proposal-list" style="display:none"><textarea id="proposal_editor_' + i + '" name="text" key="proposaltxt"></textarea></div></div>';
                $(".deviation-mascategory").append(append);                
                fnReplaceEditor('proposal_editor_' + i);
            }            
            $(".proposal-category h2").click(function (e) {
                $(this).toggleClass("active");
                $(".deviation-mascategory").find(".proposal-category h2").not(this).removeClass("active");
                $(".deviation-mascategory").find(".proposal-list").not($(this).closest(".proposal-category").find(".proposal-list")).hide("fast");
                $(this).closest(".proposal-category").find(".proposal-list").toggle("fast");
            });

            var PropData = Param2;
            if (PropData.length > 0) {
                for (i = 0; i < PropData.length ; i++) {

                    $(".deviation-mascategory .proposal-category").each(function () {
                        if (PropData[i].ProposalPk == $(this).attr("pk")) {
                            var textareaid = $(this).find("textarea[key=proposaltxt]").attr("id");
                            $(this).find("textarea[key=proposaltxt]").val(PropData[i].Notes);
                            CKEDITOR.instances[textareaid].setData(PropData[i].Notes);
                        }
                    });
                }
            }

        }
    }
    
    if (ServiceFor == "TAX") {
        var TAXdata = JSON.parse(Obj.result_1);
        var TAX_Instdata = JSON.parse(Obj.result_2);                
        var tr = '';
        var chkunknsts = "";
        var bouncests = "";        
        tr = '<tr><th>Charge Name</th><th>Percentage(%)</th><th>Amount</th></tr>';
        for (var i = 0; i < TAXdata.length; i++) {
            tr += '<tr><td>' + TAXdata[i].CompNm + '</td><td>' + TAXdata[i].Per + '</td><td>' + TAXdata[i].TaxAmt + '</td></tr>';
        }
        $("#taxpf").empty();
        $("#taxpf").append(tr);

        var trIns = '';
        trIns = '<tr><th>Instrument No</th><th>Instrument Date</th><th>Instrument Amount</th><th>Deposited Date</th><th>Deposited Bank</th><th>BRS Status</th></tr>';

        $(".pf-amt-pop").removeClass("bg1 bg2 bg8");
        for (var i = 0; i < TAX_Instdata.length; i++) {
            trIns += '<tr><td>' + TAX_Instdata[i].LpcInstrNo + '</td><td>' + TAX_Instdata[i].LpcInstrAmt + '</td><td>' + TAX_Instdata[i].LpcInstrDt + '</td><td>' + TAX_Instdata[i].LpcInstrdepoDt + '</td><td>' + TAX_Instdata[i].BankNm + '</td><td>' + TAX_Instdata[i].Chq_sts + '</td></tr>';
            if (TAX_Instdata[i].Chq_sts == "Bounced")
            { bouncests = "Y"; }
            else if (TAX_Instdata[i].Chq_sts == "Unknown")
            { chkunknsts = "Y" }
        }
        if (bouncests == "Y") {
            $(".pf-amt-pop").addClass("bg2");
        }
        else if (bouncests == "" && chkunknsts == "Y") {
            $(".pf-amt-pop").addClass("bg8");
    }
        else if (bouncests == "" && chkunknsts == "") {
            $(".pf-amt-pop").addClass("bg1");

        }
        $("#taxpf_inst").empty();
        $("#taxpf_inst").append(trIns);
        $(".totPF, .PFinst").show();
        $(".RemPF").hide();
    }

    if (ServiceFor == "MANUALDEV_DATA") {
        var DevList = JSON.parse(Obj.result_1);
        var SelectedList = JSON.parse(Obj.result_2);
        fnSetDeviationData('DeviationDataDiv',DevList, SelectedList);
    }

    if (ServiceFor == "ADD_MANUALDEV") {
        $('#manualdev-popup-BC').hide();
    }

    if (ServiceFor == "SELECT_MANUALDEV") {
        $('#manualdev-popup-BC').show();

        var Data = JSON.parse(Obj.result);
        if (!Data || Data.length == 0) return;

        $('#BCDeviationLvl').val(Data[0].AppLvl);
        $('#BCDeviationRmks').val(Data[0].Rmks);

    }
    if (ServiceFor == "SELECT_CREDIT_DTLS") {
        var Data = JSON.parse(Obj.result_1);
        if (!Data || Data.length == 0) { return; } else {
            //$("#R_txtLoanAmt").val(FormatCurrency(Data[0].LOAN_AMT));
            $("#R_txtLoanAmt").text(FormatCurrency(Data[0].LOAN_AMT));
            $("#R_txtLoanROI").val(Data[0].ROI);
            $("#R_txtLoanTenure").val(Data[0].TENUR);
        }
        var date = JSON.parse(Obj.result_2);
        $("#File_Sent_dt").val(date[0].Dt);


    }
    if (ServiceFor == "SELECT_SUB_PRODUCTS") {
        var Data = JSON.parse(Obj.result);
        var subProductType = $("#category-div .popup-content").find("ul:nth-child(1)");
        subProductType.empty();
        if (!Data || Data.length == 0) {
            subProductType.append("<h2>Product</h2> No Products found for your details / Selected Group is not correct. Contact Admin <div class='clear'></div>");
            return;
        }
        var li = "";
        for (var i = 0; i < Data.length; i++) {
            li += "<li class='cursor'><i Pk='" + Data[i].Pk + "' class='" + Data[i].icon + "'></i><p>" + Data[i].Name + "</p></li>";
        }
        subProductType.append("<h2>Product</h2>" + li + "<div class='clear'></div>");
    }
    if (ServiceFor == "PD_UPLOAD") {
        var attch = "";
        try {
            var Result = JSON.stringify(Obj);
            var ResultObj = JSON.parse(JSON.parse(Result));

            if (ResultObj.status.toString() == "true") {
                var ResObj = JSON.parse(ResultObj.result);
                var Path = ResObj[0].toString();
                var n = Path.lastIndexOf("___") + 3;
                attch = '<span pk="0" path="' + Path + '" ><i class="icon-attach"></i>' + Path.substr(n, Path.length) + '</span>';
            }
        }
        catch (e) {
            attch = "";
        }
        $("#PDfileList").empty();
        $("#PDfileList").append(attch);
    }
    if (ServiceFor == "UPDATE_APP_EMP") {
        //$("#category-div").hide();
        var Data = JSON.parse(Obj.result_2);
        var ErrData = JSON.parse(Obj.result_1);
        if (ErrData[0].ERROR && ErrData[0].ERROR != "") {
            fnShflAlert("error", ErrData[0].ERROR);
            return;
        }
        if (!Data || Data.length == 0) {
            fnShflAlert("success", "Updated! <br/> note: Product not Updated..!");
            setTimeout(function () { $(".error-div").fadeOut("slow"); }, 300);
            return;
        }
        var Info = Data[0];
        if (Info.ProductCode == "HLBTTopup" || Info.ProductCode == "HLBT" || Info.ProductCode == "HLTopup" ||
            Info.ProductCode == 'LAPBTTopup' || Info.ProductCode == 'LAPBT' || Info.ProductCode == 'LAPTopup' ||
            Info.ProductCode == "HLExt" || Info.ProductCode == "HLImp"
            ) {
            $(".category-icons").find("li:nth-child(1) i").attr("prdcode", Info.ProductCode);
            $("#LoanExist").show();
        } else {
            $(".category-icons").find("li:nth-child(1) i").attr("prdcode", "");
            $("#LoanExist").hide();
        }

        var RefUl = '';
        if (Info.ProductCode.toUpperCase() == "HLTOPUP" || Info.ProductCode.toUpperCase() == "HLEXT" || Info.ProductCode.toUpperCase() == "HLIMP" || Info.ProductCode.toUpperCase() == "LAPTOPUP") {
            RefUl += ' <comp-help id="comp-help" txtcol="RefLoanNo" valcol="Loanpk" onrowclick="Loanclick" prcname="PrcShflRefNohelp" width="100%" LoanPk = "0" LoanNo = "" Extraparam = ' + param + '></comp-help>'
            $("#ExistingLoanUL li:nth-child(2)").empty();
            $("#ExistingLoanUL li:nth-child(2)").append(RefUl);
            
            //$("#ExistingLoanUL li.Bc_Reference").empty();
            //$("#ExistingLoanUL li.Bc_Reference").append(RefUl);
        } else {
            RefUl += '<input label="Reference Number" class="RefNo" type="text" placeholder="">'
            $("#ExistingLoanUL li:nth-child(2)").empty();
            $("#ExistingLoanUL li:nth-child(2)").append(RefUl);
        }

        fnShflAlert("success", "Updated..!");
        setTimeout(function () { $(".error-div").fadeOut("slow"); }, 300);
    }
    if (ServiceFor == "INSERT_FIN_DET") {
        if (Obj.status) {
            fnChangeCreditDetails(true);
        }

    }
    if (ServiceFor == "INSERT_CREDIT_DTLS") {
        if (Obj.status) {
            var CreditData = JSON.parse(Obj.result_1);
            if (CreditData && CreditData.length == 0)
            { fnShflAlert("error", "Error in saving credit details.. try again.. "); return; }
            var isConfm = ISMOVENXT ? ISMOVENXT : "";
            isConfm = isConfm.toLowerCase();
            if (isConfm == "true") {
                var Tele_Off = JSON.parse(Obj.result_3);
                var Tele_Res = JSON.parse(Obj.result_4);
                var PD = JSON.parse(Obj.result_5);
                if (!Tele_Off || Tele_Off.length == 0 || !Tele_Res || Tele_Res.length == 0 || !PD || PD.length == 0) {
                    fnShflAlert("warning", "Cannot Handover! Complete Televerification and PD for all and try again");
                    return;
                }
                if (Tele_Off[0].TELE_STS_OFF == 'FALSE' || Tele_Res[0].TELE_STS_RES == 'FALSE' || PD[0].PD_STS == 'FALSE') {
                    fnShflAlert("warning", "Cannot Handover! Complete Televerification and PD for all and try again");
                    return;
                }
            }
            var income = 0;
            var obligation = 0;
            $(".applicant-box").each(function () {
                var inc = Number(FormatCleanComma($(this).find(".income-amount").justtext()));
                inc = inc ? inc : 0;
                var Obl = Number(FormatCleanComma($(this).find(".liability-amount").justtext()));
                Obl = Obl ? Obl : 0;

                income = income + inc;
                obligation = obligation + Obl;
            });
            var incErr = "";
            if (income == 0)
                incErr += "income should not be zero <br>";
            if ((income - obligation) <= 0 || obligation == income)
                incErr += "Obligations should not be greater than or equal to income <br>";

            if (incErr != "") {
                fnShflAlert("warning", incErr);
                return;
            }
            if (ISMOVENXT != "") {
                fnCallFinalConfirmation(ISMOVENXT);
            }
        }
    }
    if (ServiceFor == "UPDATE_FB_POP") {
        var Data = JSON.parse(Obj.result);
        if (Data.length > 0)
        { $("#bc_Feedback_div").hide(); }     
    }
    if (ServiceFor == "INSERT_FB_POP") {
        var Data = JSON.parse(Obj.result);
        var FeedbackObj = $(".customer-financial-div[apppk='" + Data[0].sel_lapFk + "'] .bc_link_feeback[flag='" + Data[0].sel_Pop_typ + "']");
        $(FeedbackObj).attr("pk", Data[0].Pk);
        $("#bc_RptDt").val("");
        $("#bc_RptRmks").val("");
        $("#bc_Feedback_div").hide();       
    }
    if (ServiceFor == "INSERT_FB_POP" || ServiceFor == "UPDATE_FB_POP") {
        var Data = JSON.parse(Obj.result);
        if (Data && Data.length > 0 && FB_CLICKED != null) {
            var status = Param2[0].pop_rptstatus;
            $(FB_CLICKED).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
            if (status == "0" || status == 0) { $(FB_CLICKED).addClass("bg2"); }
            if (status == "1" || status == 1) { $(FB_CLICKED).addClass("bg3"); }
            if (status == "2" || status == 2) { $(FB_CLICKED).addClass("bg1"); }
        }
    }

    if (ServiceFor == "SELECT_FB_POP") {

        var teledata = JSON.parse(Obj.result_1);
        var pddata = JSON.parse(Obj.result_2);
        var TeleData_Ph = JSON.parse(Obj.result_3);
        var type = Param2;
        var tmpType = type == 1 ? 2 : 1;

        var tmpTeledata = $(teledata).filter(function () {
            return this.type == tmpType;
        });
        
        fnSelectFB_POP(type, tmpTeledata, pddata, TeleData_Ph);
    }
    if (ServiceFor == "DOCUMENT") {
        var ul_list = "";
        $("div.popup.documents.attach-icon.doc-list-view").empty();
        var doc_data = JSON.parse(Obj.result_1);
        for (var i = 0; i < doc_data.length; i++) {
            ul_list += "<ul pk=" + doc_data[i].Pk + "><li>" + doc_data[i].DocName + " <p><span class='bg'>" + doc_data[i].Catogory + "</span><span class='bg'>" +
                doc_data[i].SubCatogory + "</span><span class='bg'>" + doc_data[i].Actor + "</span></p></li></li><li><i class='icon-document doc-view'></i></li>" +
                "<li><i class='icon-delete'></i></li></ul>";
        }
        $("div.popup.documents.attach-icon.doc-list-view").append(ul_list);

      
    }
    if (ServiceFor == "INCOME_COMP") {
        var Resdata;
        if (Obj.ResultCount > 0)
            Resdata = JSON.parse(Obj.result_1);
        else
            Resdata = JSON.parse(Obj.result);
        var div = "";
        if (Param2 && Param2 != undefined && Param2 != null && Param2 != "")
            div = Param2;
        if (Resdata == null || Resdata.length == 0 || Resdata == undefined || div == null || div == "" || div == undefined)
        { return; }

        if (div == "INIT") {
            INCOME_COMPONENTS = Resdata;
            return;
        }
    }
    if (ServiceFor == "SelFinDetails") {

        var data1 = JSON.parse(Obj.result_1);
        var data2 = JSON.parse(Obj.result_2);
        var Bankdata = JSON.parse(Obj.result_3);
        var Liabilitydata = JSON.parse(Obj.result_4);
        var PfAmt = JSON.parse(Obj.result_5);
        var AppSalryDetails = JSON.parse(Obj.result_6);
        var ExistLn = JSON.parse(Obj.result_7);
        //changes by kani  on 31/12/2016 start

        var AgentData = JSON.parse(Obj.result_8);
        var RefData = JSON.parse(Obj.result_9);        
        var PropData = JSON.parse(Obj.result_10);
        
        fnloaddata(PropData);       

        //changes by kani  on 31/12/2016 end

        if (PfAmt && PfAmt.length > 0)
            $(".pf-amt-pop p").html("<i class='icon-indian-rupee'></i>" + FormatCurrency(PfAmt[0].PfAmt));

        //changes by kani  on 31/12/2016 start

        fnBuildApplicantSummary(data2, data1[0], Bankdata, Liabilitydata, AppSalryDetails, AgentData);

        //changes by kani  on 31/12/2016 end
        fnSelIncDetails();
        fnAddExistLn(ExistLn);
        fnAddRefDetails(RefData);        
    }
    if (ServiceFor == "SelectIncomeDetails") {
        var BusInc = JSON.parse(Obj.result_1);
        var BnkInc = JSON.parse(Obj.result_2);
        var CashInc = JSON.parse(Obj.result_3);
        var OtherInc = JSON.parse(Obj.result_4);
        var SalerInc = JSON.parse(Obj.result_5);
        var Nhbdata = JSON.parse(Obj.result_6);
        var NhbDepdData = JSON.parse(Obj.result_7);
        var HeaderTable = JSON.parse(Obj.result_8);
        // To SEt Income Data
        if (BusInc.length == 0 && BnkInc.length == 0 && CashInc.length == 0 && SalerInc.length == 0 && OtherInc.length == 0)
            fnSetDefaultIncomeTabs();
        else
            fnSetIncomeData(BusInc, BnkInc, CashInc, SalerInc, OtherInc)
        // TO Set NHB data
        fnSetNHBdata(Nhbdata, NhbDepdData);

        $(".avgcol input").attr("readonly", "readonly");

        // TO restrict key up during loading
        FullIncomeLoaded = true;
        $("[restrict='number']").keyup();
    }
    if (ServiceFor == "SelectPropDetails") {
        var PrpData = JSON.parse(Obj.result);
        fnSetPropDetails(PrpData);
    }
    if (ServiceFor == "UPDATE_PROP_DET") {
        $('#Prop_Popup_BC').hide();
    }


    if (ServiceFor == "DELETE") {

        fnSelectDocment();
    }

    //Geetha
    //if (ServiceFor == "GetPrpslInfo") {
    //    var Data = JSON.parse(Obj.result);        
    //    if (Data.length > 0) {
    //        CKEDITOR.instances['editor'].setData(Data[0].PrpslNoteInfo);
    //    }
    //    //$('#PrpslInfo-popup').show();               
    //}

    if (ServiceFor == "SavePrpslInfo") {
        $('#PrpslInfo-popup').hide();
    }
}


function fnGetFullFinancialData_new() {
    var isErr = false;
    var errMsg = "";
    var custCount = 0;
    var ArrObj = [];
    var LiaArrObj = [];
    $(".customer-financial-div").each(function () {
        var LapPk = $(this).attr("apppk");
        //var leftDiv = $(this).find("div.grid-50.div-left");
        var leftDiv = $(this).find("div.incom-box-div");
        var incomeDivs = $(leftDiv).find(".box-div.income-container div[num]");
        var Obj = {};
        $(incomeDivs).each(function (i) {
            var DivCls = $(this).attr("class").split(" ")[0];
            if (!Obj[DivCls])
                Obj[DivCls] = [];
            var iDiv = $(this).find(".incomerow");
            var remarks = $(this).find("textarea.TxtRemarks").val();
            var PayMentType = $(this).find("[key=MoP]").getVal() || "";
            var incomeName = $(this).attr("incomename");
            var arrInclude = [];
            $(iDiv).find("ul[particular='true'] li [name=onoffswitch]").each(function () {
                var isChecked = $(this).is(":checked");
                var checkbox = isChecked ? 0 : 1;
                arrInclude.push(checkbox);
            });
            //Loan Type 0 - Bike, 1 - Car, 2 - Two Wheeler, 3 - Home, 4 - LAP
            //Loan Included or Not 0 - Yes, 1 - No            
            //Loan Taken at Shriram 0 - No, 1 - Yes
            var percentageElement = $(iDiv).find('ul[particular="true"]');

            $(iDiv).find(".grid-type ul.avgcol li.amount").each(function (avgCnt) {
                var jsonObj = {};
                jsonObj["desctxt"] = "";
                jsonObj["remarks"] = remarks;
                jsonObj["PayMentType"] = PayMentType;
                jsonObj["DoF"] = "";
                jsonObj["incomeName"] = incomeName;
                var amt_avg = FormatCleanComma($(this).find("input").val());
                amt_avg = amt_avg == "" ? 0 : amt_avg;
                jsonObj["amount"] = amt_avg
                var comppk = $(this).find("input").attr("comppk");
                jsonObj["comppk"] = comppk;
                jsonObj["addless"] = $(this).find("input").attr("addless");
                jsonObj["MntYrname"] = "-1";
                jsonObj["isIncExc"] = arrInclude[avgCnt];
                jsonObj["bankNm"] = "";
                var perc = $(percentageElement).find("input[comppk='" + comppk + "']").val();
                jsonObj["LbiPerc"] = perc;
                jsonObj["Month"] = "-1";
                jsonObj["LapPk"] = LapPk;
                Obj[DivCls].push(jsonObj);
            });


            $(iDiv).find(".grid-type ul.form-controls").not(".Ultitle").each(function () {
                var monYrName = $(this).find(".li-income-title p").text();
                var monYrVal = 0;
                monYrName = monYrName ? monYrName : "";
                if (monYrName != "")
                    monYrVal = monYrName;
                else
                    monYrVal = "unnamed";

                var OtherDesc = "";

                if (DivCls == "customer-other") {
                    monYrVal = $(this).find(".select-focus").getVal();
                    OtherDesc = $(this).find("textarea").val();
                }
                var bankMonth = monYrVal;
                var DoF = $(this).find(".Business_DoF").text();

                var count = 0;
                $(this).find(".amount").each(function () {
                    var jsonObj = {};
                    jsonObj["desctxt"] = OtherDesc;
                    jsonObj["remarks"] = remarks;
                    jsonObj["PayMentType"] = PayMentType;
                    jsonObj["DoF"] = DoF;
                    jsonObj["incomeName"] = incomeName;

                    var txtBx = $(this).find("[restrict='number']");
                    var amt = FormatCleanComma($(txtBx).val());
                    var comppk = $(txtBx).attr("comppk");
                    amt = amt == "" ? 0 : amt;
                    var name = $(txtBx).attr("name");
                    var addless = $(txtBx).attr("addless");

                    jsonObj["amount"] = amt;
                    jsonObj["comppk"] = comppk;
                    var perc = $(percentageElement).find("input[comppk='" + comppk + "']").val();
                    if (DivCls == "customer-other") {
                        perc = $(this).closest(".form-controls").find("input[isother]").val();
                    }
                    jsonObj["LbiPerc"] = perc;
                    jsonObj["addless"] = addless;
                    if (DivCls == "customer-bank") {
                        monYrVal = name;
                    }
                    jsonObj["MntYrname"] = monYrVal;
                    jsonObj["isIncExc"] = arrInclude[count];
                    jsonObj["bankNm"] = "INDIAN";
                    jsonObj["Month"] = bankMonth;
                    jsonObj["LapPk"] = LapPk;
                    Obj[DivCls].push(jsonObj);
                    count++;
                });
            });
        });
        //bank insert
        Obj["Bank-Details"] = [];
        var BankUL = $(this).find("div.bank-details.box-div ul.form-controls[appfk]");
        $(BankUL).each(function () {
            var BankPk = $(this).attr("bankpk");
            var AppPK = $(this).attr("appfk");
            var AccountName = $(this).find("[name='AccountName']").val();
            var AccountType = $(this).find("[name='AccountType']").getVal();
            var AccountNumber = $(this).find("[name='AccountNumber']").val();
            var BankName = $(this).find("[name='BankName'] [name='helptext']").val() || "";
            var BankFk = $(this).find("[name='BankName'] [name='helptext']").attr("val") || "";
            if (BankName == "" || BankFk == "")
            { isErr = true; errMsg += "Choose Bank Name. <br/>"; }

            var BranchName = $(this).find("[name='BranchName'] [name='helptext']").val()
            var BranchFk = $(this).find("[name='BranchName'] [name='helptext']").attr("val");
            if (BranchName == "" || BranchFk == "")
            { isErr = true; errMsg += "Choose Branch Name. <br/>"; }

            var bnkTran = $(this).find("[name='bnkTran']").getVal();
            var AvgBal = Number($(this).find("[name='AvgBal']").val()) ? Number($(this).find("[name='AvgBal']").val()) : 0;
            var InChqBounce = $(this).find("[name='InChqBounce']").getVal();
            var Notes = $(this).find("[name='Notes']").attr("txtval");
            var Operative = $(this).find("[name='OperativeSince']").val();
            if (Operative.trim() != "") {
                var dateval = Operative;
                var date = dateval.substring(0, 2);
                var month = dateval.substring(3, 5);
                var year = dateval.substring(6, 10);
                var dateToCompare = new Date(year, month - 1, date);
                var currentDate = new Date();
                if (dateval != '') {
                    if (dateToCompare > currentDate) {
                        isErr = true; errMsg += "Operative since should not be greater than current date. <br/>"; 
                    }
                }
            }
            var BankObj = {
                bankPk: BankPk, appFk: AppPK, AccountName: AccountName, AccountType: AccountType, AccountNumber: AccountNumber,
                BankName: BankName, BranchName: BranchName, bnkTran: bnkTran, AvgBal: AvgBal, InChqBounce: InChqBounce, Notes: Notes,
                BankFk: BankFk, BranchFk: BranchFk, OperativeSince: Operative
            }
            Obj["Bank-Details"].push(BankObj);
        });

        //--bank--

        Obj["Liability-Details"] = [];
        //var LiabilityUL = $(this).find("div.grid-50.div-right.liability-div div.income-scroll ul.form-controls");
        var LiabilityUL = $(this).find("div.liability-div div.income-scroll ul.form-controls");
        $(LiabilityUL).each(function () {
            var LiabilityPk = $(this).attr("liabilitypk");
            var LapPK = $(this).attr("LapFk");
            var Source = $(this).find("[name='Bank']").val();
            var RefNo = $(this).find("[name='RefNo']").val();
            var EMI = Number(FormatCleanComma($(this).find("[name='EMI']").val())) ? Number(FormatCleanComma($(this).find("[name='EMI']").val())) : 0;
            var OutstandAmt = Number(FormatCleanComma($(this).find("[name='OutStandAmt']").val())) ? Number(FormatCleanComma($(this).find("[name='OutStandAmt']").val())) : 0;
            var tenure = Number($(this).find("[name='RemTerms']").val()) ? Number($(this).find("[name='RemTerms']").val()) : 0;
            var Notes = $(this).find("[name='Notes']").attr("txtval");
            var incexlswitch = $(this).find("[name='onoffswitch']").is(":checked") ? 0 : 1;
            var svsswitch = $(this).find(".img-switcher").is(":checked") ? 0 : 1;
            var OblTyp = $(this).find("[name='OblLoanType']").attr("LoanType");
            var Bounce = $(this).find("[name='Bounce']").val();
            var DepBnk = $(this).find("comp-help").find("[name='helptext']").val();
            var Lnamt = Number(FormatCleanComma($(this).find("[name='Lnamt']").val())) ? Number(FormatCleanComma($(this).find("[name='Lnamt']").val())) : 0;;
            if (OutstandAmt == "" || OutstandAmt == "")
            { isErr = true; errMsg += "Outstanding amount required. <br/>"; }
            if (EMI == "" || EMI == "")
            { isErr = true; errMsg += "EMI required. <br/>"; }
            var LiabilityObj = {
                LiabilityPk: LiabilityPk, LapPK: LapPK, Bank: Source, RefNo: RefNo, EMI: EMI,
                OutStandAmt: OutstandAmt, RemTerms: tenure, Notes: Notes,
                incexlswitch: incexlswitch, svsswitch: svsswitch, OblTyp: OblTyp, BounceNo: Bounce, DepBank: DepBnk, Lnamt: Lnamt
            }
            Obj["Liability-Details"].push(LiabilityObj);
        });
        ArrObj.push(Obj);
    });


    if (isErr) {        
        ArrObj = [{ error: true, text: errMsg }];
        return ArrObj;
    }
    else {
        return ArrObj;
    }
}

function fnSaveFinancialData(FromCO) {

    var ProposalArray = [];
    var ProposalData = {};
    var Proposal = [];
    $(".deviation-mascategory .proposal-category").each(function () {
            //var value = $(this).find("textarea[key=proposaltxt]").val();
            var textareaid = $(this).find("textarea[key=proposaltxt]").attr("id");            
            var value = CKEDITOR.instances[textareaid].getData() || "";
            if (value != "") {
                ProposalData = { 'pk': $(this).attr("pk"), 'Notes': value };
                Proposal.push(ProposalData);
            }
    });

    ProposalArray.push(Proposal);


    //if (!FromCO) {
    /*muthu(25/01/17)*/
    //var Rlnamt = FormatCleanComma($("#R_txtLoanAmt").val());
    var Rlnamt = FormatCleanComma($("#R_txtLoanAmt").justtext());
    var RRoi = $("#R_txtLoanROI").val();
    var RTenure = $("#R_txtLoanTenure").val();


    if (isNaN(Rlnamt) || isNaN(RRoi) || isNaN(RTenure)) {
        fnShflAlert("warning", "Enter valid number !!");
        return;
    }

    if (Number(Rlnamt) == 0 || Rlnamt == "") {
        fnShflAlert("warning", "Recommended Loan Amount Required!!");
        return;
    } else if (RRoi == "") {
        fnShflAlert("warning", "Recommended ROI Required!!");
        return;
    } else if (RTenure == "") {
        fnShflAlert("warning", "Recommended Tenure Required!!");
        return;
    }
    var E_loan = Number(FormatCleanComma($("#txtLoanAmt").justtext()));

    if (Rlnamt > E_loan) {
        fnShflAlert("warning", "Recommended Loan Amount Should not be Greater than Expected Loan Amount");
        return;
    }

    //if (RRoi < $("#txtLoanROI").val()) {
    //    fnShflAlert("warning", "Recommended ROI Should not Less than Expected ROI");
    //    return;
    //}

    /*end*/

    var incmClas = $(".category-info .category-icons li:nth-child(2)").find("i").attr("class");
    incmClas = incmClas.trim();
    var PrfClas = $(".category-info .category-icons li:nth-child(3)").find("i").attr("class");
    PrfClas = PrfClas.trim();

    var PrdPk = $(".category-info .category-icons li:nth-child(1)").find("i").attr("prdfk");
    if (!incmClas || incmClas == "" || !PrfClas || PrfClas == "" || PrdPk == "" || PrdPk == "0") {
        $(".category-info").css({
            "background-color": "rgba(255, 0, 0, 0.2)"
        });

        setTimeout(function () {
            $(".category-info").css({
                "background-color": ""
            });
        }, 2000);
        fnShflAlert("warning", "Select Product, Income and Proof types");
        return;
    }

    var PrdCode = $(".category-info .category-icons li:nth-child(1)").find("i").attr("prdcode");
    var emptyErr = "";



    if (PrdCode == "HLBT" || PrdCode == 'HLBTTopup' || PrdCode == "HLTopup" || PrdCode == 'LAPBT'
        || PrdCode == 'LAPTopup' || PrdCode == 'LAPBTTopup' || PrdCode == "HLExt" || PrdCode == "HLImp") {

        var ExstLen = $("#LoanExist").find("#ExistingLoanUL ul.form-controls").length;
        if (ExstLen == 0) {
            if (PrdCode == "HLExt" || PrdCode == "HLImp") {
                if (!confirm("Do you want to continue without giving Existing Loan details?"))
                    return;
            }
            else {
                fnShflAlert("warning", "Enter Existing Loan details.");
                return;
            }
        }

        $("#LoanExist").find("#ExistingLoanUL ul.form-controls").each(function () {

            if (PrdCode.toUpperCase() == "HLTOPUP" || PrdCode.toUpperCase() == "HLEXT" || PrdCode.toUpperCase() == "HLIMP" || PrdCode.toUpperCase() == "LAPTOPUP") {
                RefNo = $(this).find("comp-help").find("input[name='helptext']").val();
            }
            else {
                RefNo = $(this).find("input[class='RefNo']").val();
            }
            var BnkNm = $(this).find(".bnkInsName").val();
            var LoanAmt = $(this).find(".LoanAmt").val();
            var LoanTenure = $(this).find(".LoanTenure").val();
            if (BnkNm.trim() == "" || RefNo.trim() == "" || LoanAmt.trim() == "" || LoanTenure.trim() == "")
                emptyErr += "Enter All Fields of Existing Loan Details<br/>";
            /*var val = $(this).val() || "";
            var label = $(this).attr("label");
            val = val.toString();
            val = val.trim();
            if (val == "") 
                emptyErr += "Enter " + label + "<br/>";*/
        });
    }

    $(".customer-salary[num]").each(function () {
        var Mop = $(this).find("[key= MoP]").getVal();
        if (Mop == "")
            emptyErr += "Enter Payment Type </br>";
    });

    $(".Business_DoF").each(function () {
        var DoF = $(this).text();
        if (DoF == "" || DoF == "DoF" || isNaN(Date.parse(DoF)))
            emptyErr += "Enter Valid ITR - Date of Filing / DoF for Business <br/> Ex. Jan 2016 or 12-01-2016 or 12 Jan 2016 </br>";
    });

    if ($(".bank-details.box-div ul[appfk]").length == 0)
        emptyErr += "Enter atleast one bank detail. <br>";

    if (emptyErr != "") {
        fnShflAlert("warning", emptyErr);
        return;
    }


    //}
    var arrData = fnGetFullFinancialData_new();
    if (arrData[0].error) {
        fnShflAlert("warning", arrData[0].text);
        return;
    }
    var BsArr = [];
    var SalArr = [];
    var CashArr = [];
    var BnkArr = [];
    var OtherArr = [];
    var BankAccArr = [];
    var LiabilityArr = [];
    for (var i = 0; i < arrData.length; i++) {
        var bsns = arrData[i]["customer-business"];
        var slry = arrData[i]["customer-salary"];
        var cash = arrData[i]["customer-cash"];
        var bank = arrData[i]["customer-bank"];
        var other = arrData[i]["customer-other"];
        var BankAccDetails = arrData[i]["Bank-Details"];
        var LiabilityDetails = arrData[i]["Liability-Details"];
        if (bsns && bsns.length > 0)
            BsArr = BsArr.concat(bsns);
        if (slry && slry.length > 0)
            SalArr = SalArr.concat(slry);
        if (cash && cash.length > 0)
            CashArr = CashArr.concat(cash);
        if (bank && bank.length > 0)
            BnkArr = BnkArr.concat(bank);
        if (other && other.length > 0)
            OtherArr = OtherArr.concat(other);
        if (BankAccDetails && BankAccDetails.length > 0)
            BankAccArr = BankAccArr.concat(BankAccDetails);
        if (LiabilityDetails && LiabilityDetails.length > 0)
            LiabilityArr = LiabilityArr.concat(LiabilityDetails);
    }
    var nhbData = fnGetNhbClss();
    if (typeof nhbData == "string") {
        fnShflAlert("error", nhbData);
        return;
    }
    var NHBClsData = nhbData.NHB;
    var depndtArr = nhbData.DEPD;

    var ExistingLoanDetails = fnGetExistingLoanDetails();
    var ReferenceDetails = fnGetReferenceDetails();

    if (ExistingLoanDetails.ERROR && ExistingLoanDetails.ERROR != "") {
        fnShflAlert("error", ExistingLoanDetails.ERROR);
        return;
    }

    var incHead = fnGetIncomeHead();

    var detailJSON = [{
        business: JSON.stringify(BsArr), salary: JSON.stringify(SalArr), cash: JSON.stringify(CashArr),
        bank: JSON.stringify(BnkArr), other: JSON.stringify(OtherArr), incomeHead: JSON.stringify(incHead),
        NHBclss: JSON.stringify(NHBClsData),
        NHBdepndt: JSON.stringify(depndtArr), BankAcc: JSON.stringify(BankAccArr),
        Liability: JSON.stringify(LiabilityArr),
        ExistingLoan: JSON.stringify(ExistingLoanDetails),
        Reference: JSON.stringify(ReferenceDetails),
        manualDev : ""
    }];
    var fileSendDt = $("#File_Sent_dt").val();
    if ($("#File_Sent_dt").val() == "" && ISMOVENXT == "true") {
        fnShflAlert("error", "File Send Date Required!!");
        return false;
    }

    //date validation
    var date = fileSendDt.substring(0, 2);
    var month = fileSendDt.substring(3, 5);
    var year = fileSendDt.substring(6, 10);
    var currentDate = new Date();
    var dateToCompare = new Date(year, month - 1, date);
    if (dateToCompare > currentDate) {
        fnShflAlert("error", "File Send Date Should not be greater than Current Date!!");
        return false;
    }

    
    CustFinGlobal[0].B_date = $("#File_Sent_dt").val();
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["INSERT_FIN_DET", JSON.stringify(CustFinGlobal), JSON.stringify(detailJSON), "", "", "", "", "", JSON.stringify(ProposalArray)] };
    fnCallLOSWebService("INSERT_FIN_DET", PrcObj, fnCustFinResult, "MULTI");

    // Proposal Note saving function called    
    //fnConfirmPrpslInfo();
    // Save Manual Deviation
    fnSaveManualDevBC();
}


/*********** LIABILITY *************/

function fniconPlusLiability(icon) {
    $(icon).addClass("active");
    $(icon).siblings("li").removeClass("active");
    setTimeout(function () {
        $("#loan-type").hide();
        $(icon).removeClass("active");
    }, 200);
    var iconimg = $(icon).find("i");
    var iconCls = $(iconimg).attr("class");
    var lappk = $(ActiveLiabilityDiv).closest(".customer-financial-div").attr("apppk");
    var LoanTYpe = $(icon).index();
    var elem = ActiveLiabilityDiv;
    $(".customer-financial-div div.grid-50.div-right.liability-div");
    var ulLen = $(elem).parent("div").find(".grid-type ul.form-controls").length;
    var ulHtml = '  <ul LapFk="' + lappk + '" class="form-controls">' +
                    '<li class="width-6a">' +
                    '   <div class="onoffswitch2">' +
                    '      <input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="lbl-onoffswitchi" checked>' +
                    '     <label class="onoffswitch-label" for="lbl-onoffswitchi"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span>' +
                    ' </label>' +
                    '</div>' +
                    '                                </li>' +
                    '                               <li class="width-6c">' +
                    '                                  <div class="icon_img">' +
                    '                                     <i name="OblLoanType" LoanType="' + LoanTYpe + '" class="' + iconCls + '"></i> <span class="svs-img">' +
                    '                                        <input class="img-switcher" id="lbl-img-switcher-default" type="checkbox">' +
                    '                                       <label for="lbl-img-switcher-default"></label>' +
                    '                                  </span>' +
                    '                             </div>' +
                    '                        </li>' +
                    '                       <li class="width-12">' +
                    '                          <input type="text" name="Bank">' +
                    '                     </li>' +
                    '                    <li class="width-15">' +
                    '                       <input type="text" name="RefNo">' +
                    '              </li>' +
                    '<li class="width-10 without-label">' +
                                            '<i class="icon-indian-rupee"></i>' +
                                            '<input type="text" name="Lnamt" class="currency" restrict="number" value="" >' +
                                        '</li>' +
                    '                  <li class="width-15 amount widthout-label">' +
                    '                    <input type="text" name="EMI" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;" class="currency">' +
                    '                    <i class="icon-indian-rupee"></i>' +
                    '               </li>' +
                    '             <li class="width-15 amount widthout-label">' +
                    '            <input type="text" name="OutStandAmt" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;" class="currency">' +
                    '               <i class="icon-indian-rupee"></i>' +
                    '          </li>' +
                    '         <li class="width-8a">' +
                    '            <input type="text" name="RemTerms" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;">' +
                    '       </li>' +
                    '         <li class="width-8a">' +
                    '            <input type="text" name="Bounce" onkeypress="return fnNumberKeyPress(event,this);" ondrop="return false;" onpaste="return false;">' +
                    '       </li>' +
                    '         <li class="width-30">' +
                    //'            <input type="text" name="DebtBank">' +
                    '<comp-help id="comp-help" txtcol="BankName" valcol="Bankpk" onrowclick="DebtBnkclick" prcname="PrcShflScanBankhelp" width="100%"></comp-help>' +
                            '<input type="hidden" name="text" key="debt_bankName" value = "">' +
                    '       </li>' +
                    '      <li class="width-6b"> <i  name="Notes" class="icon-chat-o"></i> <i class="icon-close" onclick="fnCloseLiability(this)"></i></li>' +
                    ' </ul>';

    ulHtml = ulHtml.replace(/lbl-onoffswitch/g, "lbl-onoffswitch" + uniqueID());
    ulHtml = ulHtml.replace(/lbl-img-switcher/g, "lbl-img-switcher" + uniqueID());
    $(elem).parent("div").find(".grid-type .income-scroll").append(ulHtml);


}

function fnCloseLiability(elem) {
    var Grid = $(elem).closest(".liability-div .grid-type");
    var divlen = $(Grid).find(".form-controls").length;
    //if (divlen > 1)
    $(elem).closest(".form-controls").remove();
    divlen = $(Grid).find(".form-controls").length;
    if (divlen == 1) {
        $(Grid).closest(".liability-div").find("ul.finance-tab li h4").html('<i class="icon-indian-rupee"></i> 0');
        var mainDiv = $(Grid).closest(".customer-financial-div");
        $(".applicant-box[appfk='" + $(mainDiv).attr('apppk') + "']").find(".liability-amount").html('<i class="icon-indian-rupee"></i> 0');
    }
    $("[name='EMI']").keyup();
}


$(document).on("click", ".popup-bg.document-pop-content div.popup.documents.attach-icon.doc-list-view i.icon-delete", function () {
    if (confirm("do you want to delete?")) {
        var pk = $(this).closest("ul").attr("pk");
        var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["DELETE", JSON.stringify([{ DocDelPk: pk }])] };
        fnCallLOSWebService("DELETE", PrcObj, fnCustFinResult, "MULTI");
    }
});

function fnGetNhbClss() {
    var Appicable = $("#NHBapplicable").val();
    var PuccaHouse = $("#NHBpuccahouse").val();
    var HouseHldCatogory = $("#NHBcatogory").val();
    var HouseHldAnnInc = FormatCleanComma($("#txthouseaninc").val());
    var LocCode = $("#txtloccd").val();
    var LocNm = $("#txtlocnm").val();
    var Err = "";


    if (Appicable == '-1' || Appicable == '') {
        Err = "Enter NHB Applicable Details ";
    }
    var istrue = false;

    if (Appicable == "1") {
        istrue = true;
        if (PuccaHouse == "" || HouseHldCatogory == "" || HouseHldAnnInc == "" || LocCode == "" || LocNm == "")
            Err += "Enter All NHB Details ";
    }
    else if (Appicable == "0") {
        istrue = false;
    }
    var NHBClsData = [{
        NHBApplicable: Appicable, NHBPuccaHouse: PuccaHouse, NHBHouseHldCatogory: HouseHldCatogory, NHBHouseHldAnnInc: HouseHldAnnInc, NHBLocCode: LocCode,
        NHBLocNm: LocNm
    }];


    if (!istrue)
        NHBClsData = [];

    var jsonArr = [];
    var box_div = $(".content-div").find(".box-div");
    var leftDiv = $(box_div).find(".div-right.grid-50").not(".liability-div");
    $(leftDiv).find(".grid-type div.dependt ul.form-controls").each(function () {
        var jsonObj = {};
        var DepCOunt = $(this).find("input[name=depndtnm]").val();
        jsonObj["depndtnm"] = DepCOunt;
        var RefNo = $(this).find("input[name=depndtrefno]").val();
        jsonObj["depndtrefno"] = RefNo;
        var Prf = $(this).find("[name=depndtproof]").getVal();
        jsonObj["depndtproof"] = Prf;
        jsonArr.push(jsonObj);
    });

    if (!istrue && jsonArr.length > 0)
        Err += " NHB is not applicable. can't add dependent!";

    var jsonNHB = { NHB: NHBClsData, DEPD: jsonArr };
    if (Err == "")
        return jsonNHB;
    else
        return Err;
}

function fniconPlusDepndt(elem) {
    var ulDepndtHtml = $('<ul class="form-controls">' +
                             '<li class="width-33">' +
                             '<input class="txtdepndt" type="text" name="depndtnm">' +
                             '</li>' +
                             '<li class="width-10">' +
                             '<input class="txtrefno" type="text" name="depndtrefno">' +
                             '</li>' +
                             '<li class="width-23">' +
                             //'<input class="txtprf" type="text" name="depndtproof">' +
                            '     <div class="select-focus" name="depndtproof">' +
                            '       <input selval="" value="" placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                            '      <i class="icon-down-arrow"></i>' +
                            '     <ul class="custom-select">' +
                            '       <li val="0">Yes</li>' +
                            '       <li val="1">No</li>' +
                            '        </ul>' +
                            '     </div>' +
                             '</li>' +
                             '<li>' +
                             '<i class="icon-close" onclick="fnCloseDepndt(this)"></i>' +
                             '</li>' +
                             '</ul>');

    $(elem).parent("div").find(".grid-type div.dependt").append(ulDepndtHtml);
    return ulDepndtHtml;
}
function fnCloseDepndt(elem) {
    $(elem).closest(".form-controls").remove();

}
function fnSelectAll() {

    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SelFinDetails", JSON.stringify(CustFinGlobal)] };
    fnCallLOSWebService("SelFinDetails", PrcObj, fnCustFinResult, "MULTI");
}
function fnSelIncDetails() {

    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SelectIncomeDetails", JSON.stringify(CustFinGlobal)] };
    fnCallLOSWebService("SelectIncomeDetails", PrcObj, fnCustFinResult, "MULTI");

}

function fnCloseCredit_BC() {
    $("#credit-popup_DDE").hide();
    $("#credit-popup_DDE").find(".popup-content").empty();
    GlobalXml[0].IsAll = "0";
}

function fnOpenCreditScreen_BC(e, elem) {
    if (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
    }
    if (!window.DDE)
        window.DDE = 1;
    $("#credit-popup_DDE").show();
    $("#credit-popup_DDE").find(".popup-content").empty();
    $("#credit-popup_DDE").find(".popup-content").load("detail-data-entry.html", function () {
        GlobalXml[0].IsAll = "1";
    });

}
function fnSetNHBdata(Nhbdata, NhbDepdData) {
    if (Nhbdata && Nhbdata.length > 0) {
        $("#NHBapplicable").val("1").trigger("change");
        $("#NHBpuccahouse").val(Nhbdata[0].puccahouse);
        $("#NHBcatogory").val(Nhbdata[0].NHBcatogory);
        $("#txthouseaninc").val(FormatCurrency(Nhbdata[0].hosInc));
        $("#txtloccd").val(Nhbdata[0].Loccode);
        $("#txtloccd").closest("span").find("comp-help").find("[name = 'helptext']").val(Nhbdata[0].Loccode);
        $("#txtlocnm").val(Nhbdata[0].LocName);
    }
    else {
        $("#NHBapplicable").val("0").trigger("change");
    }
    fnToggleFreezeNHB();

    for (var i = 0; i < NhbDepdData.length; i++) {
        fniconPlusDepndt($("#NHbDepdAdd")[0]);
        var ul = $("#NHbDepdAdd").parent("div").find(".grid-type div.dependt ul.form-controls")[i];
        var Obj = NhbDepdData[i];
        var Keys = Object.keys(Obj);
        for (var j = 0; j < Keys.length; j++) {
            var elem = $(ul).find("[name='" + Keys[j] + "']");
            if (Keys[j] == "depndtproof")
                $(elem).setVal(Obj[Keys[j]]);
            else
                $(elem).val(Obj[Keys[j]]);
        }
    }
}

function fnSetDefaultIncomeTabs() {
    $(".customer-financial .common-tabs li[val='1']").click();
    return; // Default income tab not needed
    $(".customer-financial-div").each(function () {
        var custIncType = $(this).attr("custIncType");
        var income = custIncType == 1 ? "income-business" : custIncType == 0 ? "income-salary" : "income-other";
        var incomeName = custIncType == 1 ? "business" : custIncType == 0 ? "salary" : "other";
        $("#select-income-type").val(income);
        $("#txtIncomeNmAc").val(incomeName + "_1");
        whichDiv = $(this);
        fnOpenTab();
    });
    $(".customer-financial .common-tabs li[val='1']").click();
    //$(".common-tabs span li[val]").click();
}


function fnGetIncomeHead() {
    //LioLapFk, LioType, LioName, LioRmks, LioMoP, LioIncExc, LioSumAmt,LioRowId, LioCreatedBy, LioCreatedDt, LioModifiedBy, LioModifiedDt, LioDelFlg, LioDelId            
    var headJson = [];
    try {
        $(".customer-financial-div").each(function () {
            var LapFk = $(this).attr("apppk");
            $(this).find(".incom-box-div ul.finance-tab li[num]").each(function () {
                var obj = {};
                var Num = $(this).attr("num");
                var classNm = $(this).attr("class");
                var incExc = $(this).find("input[type=checkbox]").is(":checked") ? "0" : "1";
                classNm = classNm.replace("active", "");
                classNm = classNm.trim();
                var DivClsNm = classNm.replace("income", "customer");
                var incometype = $(this).hasClass("income-salary") ? 'S' :
                                    $(this).hasClass("income-business") ? 'B' :
                                    $(this).hasClass("income-cash") ? 'C' :
                                    $(this).hasClass("income-bank") ? 'BK' :
                                    $(this).hasClass("income-other") ? 'OT' : '';
                var incNm = $(this).find(".income-editable").text() || "";
                obj.LapFk = LapFk;
                obj.incometype = incometype;
                obj.incNm = incNm;
                obj.remarks = $("." + DivClsNm + "[num=" + Num + "] .TxtRemarks").val();
                obj.MoP = $("." + DivClsNm + "[num=" + Num + "] [key=MoP]").getVal();
                obj.incexc = incExc;
                obj.amount = Number(FormatCleanComma($(this).find(".totalAvgAmt").justtext())) || 0;
                headJson.push(obj);
            });

            var liabtyDiv = $(this).find(".liability-div");
            var lbtyAmt = FormatCleanComma($(this).find("li.obligation-li h4").justtext());
            var obj = {};
            obj.LapFk = LapFk;
            obj.incometype = 'OB';
            obj.incNm = 'Obligations';
            obj.remarks = $(liabtyDiv).find(".TxtRemarks").val();
            obj.MoP = '';
            obj.incexc = '0';
            obj.amount = Number(lbtyAmt) || 0;
            headJson.push(obj);
        });


    }
    catch (e) { headJson = []; }
    return headJson;
}

function fnSetIncomeData(business, bank, cash, salary, other) {
    //app-plus-icon    
    var BusinessComp = $(INCOME_COMPONENTS).filter(function (i, n) {
        return n.type == 1;
    });

    var SalaryComp = $(INCOME_COMPONENTS).filter(function (i, n) {
        return n.type == 2;
    });

    var CashComp = $(INCOME_COMPONENTS).filter(function (i, n) {
        return n.type == 3;
    });

    var BankComp = $(INCOME_COMPONENTS).filter(function (i, n) {
        return n.type == 4;
    });

    var BusinessCompLen = BusinessComp.length,
        SalaryCompLen = SalaryComp.length,
        CashCompLen = CashComp.length,
        BankCompLen = BankComp.length;

    if (salary && salary.length > 0) {
        $("#select-income-type").val("income-salary");
        var returnDiv;
        var retDivArr = [];
        var prevDivPk = 0;
        var curDivPk = 0;
        var newApp = false, newAppDone = false;

        var withoutFilter = $(salary).filter(function (i, n) {
            return (n.salmonth == -1 && n.salmonth == "-1");
        });
        var salary = $(salary).filter(function (i, n) {
            return (n.salmonth != -1 && n.salmonth != "-1");
        });
        var PrvHeadPk = 0;
        var CurHeadPk = 0;
        for (var i = 0; i < salary.length; i++) {
            var incnm = salary[i].HdIncName;
            $("#txtIncomeNmAc").val(incnm);
            whichDiv = $(".customer-financial-div[apppk='" + salary[i].AppPk + "']");
            var whichDivValue = $(whichDiv).attr("val");
            $(".customer-financial-div[val]").hide();
            $(".customer-financial-div[val=" + whichDivValue + "]").show();
            curDivPk = salary[i].AppPk;
            CurHeadPk = salary[i].HeadFk;
            var comppk = salary[i].comppk;
            if ((curDivPk != prevDivPk && prevDivPk != 0) || (PrvHeadPk != CurHeadPk && PrvHeadPk != 0)) {
                newApp = true; newAppDone = false;
            }
            else { newApp = false; }
            var currencySalValue = FormatCurrency(salary[i].salValue);
            var iconadd = null;
            if (i == 0) {
                returnDiv = fnOpenTab();
                retDivArr.push(returnDiv);
                addedColumn = $(returnDiv.find(".income-details .form-controls"));
            } else {
                iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                if (i > SalaryCompLen - 1) {
                    if (i % SalaryCompLen == 0) {
                        iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                        if (newApp) {
                            returnDiv = fnOpenTab();
                            retDivArr.push(returnDiv);
                            addedColumn = $(returnDiv.find(".income-details .form-controls"));
                        }
                        else {
                            addedColumn = fnAddIncomeColumn(iconadd, 'customer-salary');
                        }
                    }
                }
                else {
                    addedColumn = $(returnDiv.find(".income-details .form-controls"));
                }
            }

            prevDivPk = salary[i].AppPk;
            PrvHeadPk = CurHeadPk;
            $(returnDiv).find("[key=MoP]").setVal(salary[i].HdMoP);
            $(returnDiv).find(".TxtRemarks").val(salary[i].HdRmks);
            $(addedColumn.find(".amount input[comppk=" + comppk + "]")).val(currencySalValue);
            $(addedColumn).find(".li-income-title p").text(salary[i].salmonth);
        }
        var cnt = 0;
        var retCont = 0;
        $(withoutFilter).each(function (j) {
            var name = this.Name;
            var Amtval = this.salValue;
            var CompPk = this.comppk;
            if (cnt % SalaryCompLen == 0 && cnt != 0) {
                cnt = 0; retCont++; returnDiv = retDivArr[retCont];
            }
            else { returnDiv = retDivArr[retCont]; }
            var Percentage = this.percentage;
            var liindex = (cnt + 2);
            var AvgInput = $(returnDiv).find("ul.avgcol li input[comppk=" + CompPk + "]");
            var RangeInput = $(returnDiv).find("ul[particular='true'] li input[comppk=" + CompPk + "]");
            var CurLi = $(RangeInput).closest("li.slide");
            $(AvgInput).val(FormatCurrency(Amtval));
            var slider = RangeInput;
            var slider1 = $(slider).data("ionRangeSlider");
            if (slider1)
                slider1.update({
                    from: Percentage,
                    onChange: fnChangeSliderValue,
                    onUpdate: fnUpdateSliderValue
                });
            var isChecked = this.IncExc == 1 ? false : true;
            var checkBox = $(CurLi).find("[name='onoffswitch']");
            $(checkBox).prop("checked", isChecked);
            cnt++;
        });
    }

    if (business && business.length > 0) {
        $("#select-income-type").val("income-business");
        var returnDiv;
        var retDivArr = [];
        var prevDivPk = 0;
        var curDivPk = 0;
        var newApp = false, newAppDone = false;
        var addedColumn;
        var withoutFilter = $(business).filter(function (i, n) {
            return (n.busiyear == -1 && n.busiyear == "-1");
        });
        var business = $(business).filter(function (i, n) {
            return (n.busiyear != -1 && n.busiyear != "-1");
        });
        var PrvHeadPk = 0;
        var CurHeadPk = 0;
        for (var i = 0; i < business.length; i++) {
            var incnm = business[i].HdIncName;
            $("#txtIncomeNmAc").val(incnm);
            whichDiv = $(".customer-financial-div[apppk='" + business[i].AppPk + "']");
            var whichDivValue = $(whichDiv).attr("val");
            $(".customer-financial-div[val]").hide();
            $(".customer-financial-div[val=" + whichDivValue + "]").show();
            curDivPk = business[i].AppPk;
            CurHeadPk = business[i].HeadFk;
            var comppk = business[i].comppk;
            var currencyBusiValue = FormatCurrency(business[i].busiValue);
            if ((curDivPk != prevDivPk && prevDivPk != 0) || (PrvHeadPk != CurHeadPk && PrvHeadPk != 0)) {
                newApp = true; newAppDone = false;
            }
            else { newApp = false; }

            var iconadd = null;
            if (i == 0) {
                returnDiv = fnOpenTab();
                retDivArr.push(returnDiv);
                addedColumn = $(returnDiv.find(".income-details .form-controls"));
            } else {
                iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                if (i > BusinessCompLen - 1) {
                    if (i % BusinessCompLen == 0) {
                        iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                        if (newApp) {
                            returnDiv = fnOpenTab();
                            retDivArr.push(returnDiv);
                            addedColumn = $(returnDiv.find(".income-details .form-controls"));
                        }
                        else {
                            addedColumn = fnAddIncomeColumn(iconadd, 'customer-business');
                        }
                    }
                }
                else {
                    addedColumn = $(returnDiv.find(".income-details .form-controls"));
                }
            }

            prevDivPk = business[i].AppPk;
            PrvHeadPk = CurHeadPk;
            $(returnDiv).find(".TxtRemarks").val(business[i].HdRmks);
            $(addedColumn).find("input[comppk=" + comppk + "]").val(currencyBusiValue);
            $(addedColumn).find(".li-income-title p").text(business[i].busiyear);
            $(addedColumn).find(".li-income-title span.Business_DoF").text(business[i].ITRDoF);
        }
        var cnt = 0;
        var retCont = 0;
        $(withoutFilter).each(function (j) {
            var name = this.Name;
            var Percentage = this.percentage;
            var Amtval = this.busiValue;
            var CompPk = this.comppk;
            if (cnt % BusinessCompLen == 0 && cnt != 0) {
                cnt = 0; retCont++; returnDiv = retDivArr[retCont];
            }
            else { returnDiv = retDivArr[retCont]; }
            var liindex = (cnt + 2);

            var AvgInput = $(returnDiv).find("ul.avgcol li input[comppk=" + CompPk + "]");
            var RangeInput = $(returnDiv).find("ul[particular='true'] li input[comppk=" + CompPk + "]");
            var CurLi = $(RangeInput).closest("li.slide");

            var slider = RangeInput;
            var isChecked = this.IncExc == 1 ? false : true;
            $(AvgInput).val(FormatCurrency(Amtval));
            var checkBox = $(CurLi).find("[name='onoffswitch']");
            $(checkBox).prop("checked", isChecked);
            $(checkBox).trigger("change");
            slider = $(slider).data("ionRangeSlider");
            if (slider)
                slider.update({
                    from: Percentage,
                    onChange: fnChangeSliderValue,
                    onUpdate: fnUpdateSliderValue
                });
            cnt++;
        });
    }

    if (bank && bank.length > 0) {
        $("#select-income-type").val("income-bank");
        var returnDiv;
        var retDivArr = [];
        var prevDivPk = 0;
        var curDivPk = 0;
        var newApp = false, newAppDone = false;
        var withoutFilter = $(bank).filter(function (i, n) {
            return (n.day == -1 || n.day == "-1");
        });
        var bank = $(bank).filter(function (i, n) {
            return (n.day != -1 && n.day != "-1");
        });
        var PrvHeadPk = 0;
        var CurHeadPk = 0;
        for (var i = 0; i < bank.length; i++) {
            var incnm = bank[i].HdIncName;
            $("#txtIncomeNmAc").val(incnm);
            whichDiv = $(".customer-financial-div[apppk='" + bank[i].AppPk + "']");
            var whichDivValue = $(whichDiv).attr("val");
            $(".customer-financial-div[val]").hide();
            $(".customer-financial-div[val=" + whichDivValue + "]").show();
            curDivPk = bank[i].AppPk;
            CurHeadPk = bank[i].HeadFk;
            var comppk = bank[i].comppk;
            var currencyBnkValue = FormatCurrency(bank[i].bankValue);
            if ((curDivPk != prevDivPk && prevDivPk != 0) || (PrvHeadPk != CurHeadPk && PrvHeadPk != 0)) {
                newApp = true; newAppDone = false;
            }
            else { newApp = false; }
            var iconadd = null;
            if (i == 0) {
                returnDiv = fnOpenTab();
                retDivArr.push(returnDiv);
                addedColumn = $(returnDiv.find(".income-details .form-controls"));
            } else {
                iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                if (i > BankCompLen - 1) {
                    if (i % BankCompLen == 0) {
                        iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                        if (newApp) {
                            returnDiv = fnOpenTab();
                            retDivArr.push(returnDiv);
                            addedColumn = $(returnDiv.find(".income-details .form-controls"));
                        }
                        else {
                            addedColumn = fnAddIncomeColumn(iconadd, 'customer-bank');
                        }
                    }
                }
                else {
                    addedColumn = $(returnDiv.find(".income-details .form-controls"));
                }
            }


            prevDivPk = bank[i].AppPk;
            PrvHeadPk = CurHeadPk;
            $(returnDiv).find(".TxtRemarks").val(bank[i].HdRmks);
            $(addedColumn).find(".li-income-title p").text(bank[i].bankmonth);
            $(addedColumn).find(".amount input[comppk=" + comppk + "]").val(currencyBnkValue);
        }


        var cnt = 0;
        var retCont = 0;
        $(withoutFilter).each(function (j) {
            var name = this.Name;
            var Percentage = this.percentage;
            var Amtval = this.bankValue;
            var CompPk = this.comppk;
            if (cnt % BankCompLen == 0 && cnt != 0) {
                cnt = 0; retCont++; returnDiv = retDivArr[retCont];
            }
            else { returnDiv = retDivArr[retCont]; }
            var liindex = (cnt + 2);

            var AvgInput = $(returnDiv).find("ul.avgcol li input[comppk=" + CompPk + "]");
            var RangeInput = $(returnDiv).find("ul[particular='true'] li input[comppk=" + CompPk + "]");
            var CurLi = $(RangeInput).closest("li.slide");

            var slider = RangeInput;
            $(AvgInput).val(FormatCurrency(Amtval));
            slider = $(slider).data("ionRangeSlider");
            if (slider)
                slider.update({
                    from: Percentage,
                    onChange: fnChangeSliderValue,
                    onUpdate: fnUpdateSliderValue
                });
            cnt++;
        });


    }
    if (cash && cash.length > 0) {
        $("#select-income-type").val("income-cash");
        var returnDiv;
        var retDivArr = [];
        var prevDivPk = 0;
        var curDivPk = 0;
        var newApp = false, newAppDone = false;
        var withoutFilter = $(cash).filter(function (i, n) {
            return (n.cashyear == -1 || n.cashyear == "-1");
        });


        var cash = $(cash).filter(function (i, n) {
            return (n.cashyear != -1 && n.cashyear != "-1");
        });
        var PrvHeadPk = 0;
        var CurHeadPk = 0;
        for (var i = 0; i < cash.length; i++) {
            var incnm = cash[i].HdIncName;
            $("#txtIncomeNmAc").val(incnm);
            whichDiv = $(".customer-financial-div[apppk='" + cash[i].AppPk + "']");
            var whichDivValue = $(whichDiv).attr("val");
            $(".customer-financial-div[val]").hide();
            $(".customer-financial-div[val=" + whichDivValue + "]").show();
            curDivPk = cash[i].AppPk;
            CurHeadPk = cash[i].HeadFk;
            var comppk = cash[i].comppk;
            var currencyCashValue = FormatCurrency(cash[i].cashValue);
            if ((curDivPk != prevDivPk && prevDivPk != 0) || (PrvHeadPk != CurHeadPk && PrvHeadPk != 0)) {
                newApp = true; newAppDone = false;
            }
            else { newApp = false; }
            var iconadd = null;


            if (i == 0) {
                returnDiv = fnOpenTab();
                retDivArr.push(returnDiv);
                addedColumn = $(returnDiv.find(".income-details .form-controls"));
            } else {
                iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                if (i > CashCompLen - 1) {
                    if (i % CashCompLen == 0) {
                        iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                        if (newApp) {
                            returnDiv = fnOpenTab();
                            retDivArr.push(returnDiv);
                            addedColumn = $(returnDiv.find(".income-details .form-controls"));
                        }
                        else {
                            addedColumn = fnAddIncomeColumn(iconadd, 'customer-cash');
                        }
                    }
                }
                else {
                    addedColumn = $(returnDiv.find(".income-details .form-controls"));
                }
            }
            prevDivPk = cash[i].AppPk;
            PrvHeadPk = CurHeadPk;
            $(returnDiv).find(".TxtRemarks").val(cash[i].HdRmks);
            $(addedColumn.find(".amount input[comppk=" + comppk + "]")).val(currencyCashValue);
            $(addedColumn).find(".li-income-title p").text(cash[i].cashyear);
        }
        var cnt = 0;
        var retCont = 0;
        $(withoutFilter).each(function (j) {
            var name = this.Name;
            var Percentage = this.percentage;
            var Amtval = this.cashValue;
            var CompPk = this.comppk;
            if (cnt % CashCompLen == 0 && cnt != 0) {
                cnt = 0; retCont++; returnDiv = retDivArr[retCont];
            }
            else { returnDiv = retDivArr[retCont]; }
            var liindex = (cnt + 2);

            var AvgInput = $(returnDiv).find("ul.avgcol li input[comppk=" + CompPk + "]");
            var RangeInput = $(returnDiv).find("ul[particular='true'] li input[comppk=" + CompPk + "]");
            var CurLi = $(RangeInput).closest("li.slide");

            var slider = RangeInput;
            var isChecked = this.IncExc == 1 ? false : true;
            var checkBox = $(CurLi).find("[name='onoffswitch']");
            $(checkBox).prop("checked", isChecked);
            $(checkBox).trigger("change");
            $(AvgInput).val(FormatCurrency(Amtval));
            slider = $(slider).data("ionRangeSlider");
            if (slider)
                slider.update({
                    from: Percentage,
                    onChange: fnChangeSliderValue,
                    onUpdate: fnUpdateSliderValue
                });
            cnt++;
        });
    }

    if (other && other.length > 0) {
        $("#select-income-type").val("income-other");
        var returnDiv;
        var retDivArr = [];
        var prevDivPk = 0;
        var curDivPk = 0;
        var newApp = false, newAppDone = false;
        var PrvHeadPk = 0;
        var CurHeadPk = 0;
        for (var i = 0; i < other.length; i++) {
            var incnm = other[i].HdIncName;
            $("#txtIncomeNmAc").val(incnm);
            whichDiv = $(".customer-financial-div[apppk='" + other[i].AppPk + "']");
            var whichDivValue = $(whichDiv).attr("val");
            $(".customer-financial-div[val]").hide();
            $(".customer-financial-div[val=" + whichDivValue + "]").show();
            curDivPk = other[i].AppPk;
            CurHeadPk = other[i].HeadFk;

            if ((curDivPk != prevDivPk && prevDivPk != 0) || (PrvHeadPk != CurHeadPk && PrvHeadPk != 0)) {
                newApp = true; newAppDone = false;
            }
            else { newApp = false; }

            var iconadd = null;
            if (i == 0) {
                returnDiv = fnOpenTab();
                $(returnDiv).find(".TxtRemarks").val(other[i].HdRmks);
                retDivArr.push(returnDiv);
                $(returnDiv.find(".desc")).val(other[i].desc);
                $(returnDiv.find(".period")).setVal(other[i].period);
                $(returnDiv.find(".OtherInc")).val(FormatCurrency(other[i].OtherInc));
                $(returnDiv.find("input[isOther]")).data("ionRangeSlider").update({
                    from: other[i].percentage,
                    onChange: fnChangeSliderValue,
                    onUpdate: fnUpdateSliderValue
                });
            } else {
                iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                if (newApp) {
                    returnDiv = fnOpenTab();
                    retDivArr.push(returnDiv);
                    iconadd = $(returnDiv).find("[icon='add-income-icon-plus']");
                    addedColumn = $(returnDiv).find(".form-controls").not("ul.Ultitle");
                }
                else {
                    addedColumn = fnAddOtherColumn(iconadd);
                }
                $(addedColumn.find(".desc")).val(other[i].desc);
                $(addedColumn.find(".period")).setVal(other[i].period);
                $(addedColumn.find(".OtherInc")).val(FormatCurrency(other[i].OtherInc));
                $(addedColumn.find("input[isOther]")).data("ionRangeSlider").update({
                    from: other[i].percentage,
                    onChange: fnChangeSliderValue,
                    onUpdate: fnUpdateSliderValue
                });
            }
            prevDivPk = other[i].AppPk;
            PrvHeadPk = CurHeadPk;
            $(returnDiv).find(".TxtRemarks").val(other[i].HdRmks);
        }
    }

    setTimeout(function () {
        //$("[restrict='number']").keyup();
        //$("[name='EMI']").keyup();
        $(".customer-financial .common-tabs li[val='1']").click();
    }, 500);
}


function fnSetIncomeComponent(div) {

    var Resdata = INCOME_COMPONENTS;
    $(div).find(".businessComp").empty();
    $(div).find(".IncomeComp").empty();
    $(div).find(".cashComp").empty();
    $(div).find(".bankComp").empty();
    $(div).find(".otherComp").empty();

    $(div).find(".businessComp").append("<li>Particulars</li>");
    $(div).find(".IncomeComp").append("<li>Particulars</li>");
    $(div).find(".cashComp").append("<li>Particulars</li>");
    $(div).find(".bankComp").append("<li>Balance as of</li>");
    $(div).find(".otherComp").append("<li>Balance as of</li>");

    $(div).find(".grid-type .form-controls").empty();

    var bsCnt = 0;
    var salCnt = 0;
    var cashCnt = 0;
    var bankCnt = 0;
    var otherCnt = 0;
    var clsNm = $(div).attr("class");
    var num = $(div).attr("num");

    var type = '1';
    if (clsNm.indexOf("customer-business") != -1)
        type = '1';
    if (clsNm.indexOf("customer-salary") != -1)
        type = '2';
    if (clsNm.indexOf("customer-cash") != -1)
        type = '3';
    if (clsNm.indexOf("customer-bank") != -1)
        type = '4';
    if (clsNm.indexOf("customer-other") != -1)
        type = '5';

    var data = $(Resdata).filter(function (i, n) {
        return n.type == type;
    });

    for (var i = 0; i < data.length; i++) {

        var txtName = data[i].name;
        txtName = txtName.replace(/ /g, "_");
        var compPK = data[i].pk;
        var compcode = data[i].compcode;

        if (data[i].type == "1") {
            if (bsCnt == 0) {
                $(div).find(".grid-type .form-controls").append('<i class="icon-close" onclick="fnCloseIncomeCol(this)"></i><li class="li-income-title">' +
                    '<div class="business-title">' +
                    '<span spellcheck="false" title="Date of ITR Filing" class="Business_DoF" contenteditable="true">DoF</span>' +
                    '<p spellcheck="false" title="income period" contenteditable="true" class="incomeperiod">Period 1</p></div>' +
                    '<h4><i class="icon-indian-rupee"></i> 0</h4></li>');
                $(div).find(".grid-type .avgcol").append('<li><p>Average</p><h4><i class="icon-indian-rupee"></i></h4></li>');
            }
            var idPrefix = "Bscomp" + bsCnt + "_";
            var Ultext = $('<li class="slide"><div class="onoffswitch2"><input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" ' +
                        'id="' + idPrefix + 'myonoffswitch" checked>' +
                    '<label class="onoffswitch-label" for="' + idPrefix + 'myonoffswitch"> <span class="onoffswitch-inner"></span> ' +
                    '<span class="onoffswitch-switch"></span> </label></div>' +
                    (data[i].istotal == 1 ? '<div class="income-range"><p>' + data[i].name + '</p></div>' : '<div class="income-range"><p>' + data[i].name +
                    '<span contenteditable="true" class="percText right">100</span></p>' +
                    '<input isperc="' + data[i].isPerc + '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '" readonly addless="' + data[i].addless +
                    '" comppk="' + compPK + '" type="text" class="range1' + idPrefix + '" value="" name="range" class="currency"/></div>') +
                    '<div class="clear"></div></li>');

            var swithID = Ultext.find("[id*='myonoffswitch']").attr("id");
            var uniq = uniqueID();
            Ultext.find("[id*='myonoffswitch']").attr("id", swithID + "_" + uniq);
            Ultext.find("[for*='myonoffswitch']").attr("for", swithID + "_" + uniq);

            $(div).find(".businessComp").append(Ultext);

            $(div).find(".grid-type .avgcol").append('<li class="amount without-label"><i class="icon-indian-rupee"></i><input isperc="' + data[i].isPerc +
                '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  addless="' + data[i].addless + '" comppk="' + compPK + '" name="' + txtName +
                '" type="text" placeholder="" restrict="avg" class="currency"></li>');

            $(div).find(".grid-type .form-controls").append('<li class="amount without-label"><i class="icon-indian-rupee"></i><input isperc="' + data[i].isPerc +
                '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  comppk="' + compPK + '" type="text" name="' + txtName +
                '" placeholder="" addless="' + data[i].addless + '" restrict="number" class="currency"></li>');

            bsCnt++;

        }
        if (data[i].type == "2") {
            if (salCnt == 0) {
                $(div).find(".grid-type .form-controls").append('<i class="icon-close" onclick="fnCloseIncomeCol(this)"></i><li class="li-income-title">' +
                    '<p title="income period" contenteditable="true" class="incomeperiod">Period 1</p><h4><i class="icon-indian-rupee"></i>0</h4></li>');
                $(div).find(".grid-type .avgcol").append('<li><p>Average</p><h4><i class="icon-indian-rupee"></i></h4></li>');
            }
            var idPrefix = "Salcomp" + salCnt + "_";
            var Ultext = $('<li class="slide"><div class="onoffswitch2"><input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="' + idPrefix +
                'myonoffswitch" checked>' +
                '<label class="onoffswitch-label" for="' + idPrefix + 'myonoffswitch"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> ' +
                '</label>' +
                '</div>' +
                (data[i].istotal == 1 ? '<div class="income-range"><p>' + data[i].name + '</p></div>' : '<div class="income-range">' +
                '<p>' + data[i].name + '<span contenteditable="true" class="percText right">100</span></p>' +
                '<input isperc="' + data[i].isPerc + '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp +
                '"  readonly type="text" addless="' + data[i].addless + '" comppk="' + compPK + '" class="range1' + idPrefix + '" value="" name="range" class="currency"/></div>') +
                '<div class="clear"></div></li>');

            var swithID = Ultext.find("[id*='myonoffswitch']").attr("id");
            var uniq = uniqueID();
            Ultext.find("[id*='myonoffswitch']").attr("id", swithID + "_" + uniq);
            Ultext.find("[for*='myonoffswitch']").attr("for", swithID + "_" + uniq);

            $(div).find(".IncomeComp").append(Ultext);
            $(div).find(".grid-type .avgcol").append('<li class="amount without-label"><i class="icon-indian-rupee"></i><input isperc="' + data[i].isPerc +
                '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  addless="' + data[i].addless + '" comppk="' + compPK + '" name="' + txtName +
                '" type="text" placeholder="" restrict="avg" class="currency"></li>');

            $(div).find(".grid-type .form-controls").append('<li class="amount without-label"><i class="icon-indian-rupee"></i><input isperc="' + data[i].isPerc +
                '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  comppk="' + compPK + '" name="' + txtName +
                '" type="text" placeholder="" addless="' + data[i].addless + '" restrict="number" class="currency"></li>');
            salCnt++;
        }
        if (data[i].type == "3") {
            if (cashCnt == 0) {
                $(div).find(".grid-type .form-controls").append('<i class="icon-close" onclick="fnCloseIncomeCol(this)"></i><li class="li-income-title">' +
                    '<p title="income period" contenteditable="true" class="incomeperiod">Period 1</p><h4><i class="icon-indian-rupee"></i>0</h4></li>');
                $(div).find(".grid-type .avgcol").append('<li><p>Average</p><h4><i class="icon-indian-rupee"></i></h4></li>');
            }
            var idPrefix = "Cashcomp" + cashCnt + "_";
            var Ultext = $(' <li class="slide">' +
                        '<div class="onoffswitch2">' +
                        '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="' + idPrefix + 'myonoffswitch" checked>' +
                        '<label class="onoffswitch-label" for="' + idPrefix + 'myonoffswitch"> <span class="onoffswitch-inner"></span> ' +
                        '<span class="onoffswitch-switch"></span> </label>' +
                        '</div>' +
                        (data[i].istotal == 1 ? '<div class="income-range"><p>' + data[i].name + '</p></div>' :
                        '<div class="income-range">' +
                        '<p>' + data[i].name + '<span contenteditable="true" class="percText right">100</span></p>' +
                        '<input isperc="' + data[i].isPerc + '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  addless="' + data[i].addless +
                        '" readonly compcode="' + compcode + '" comppk="' + compPK + '" type="text" class="range1' + idPrefix + '" value="" name="range" class="currency"/>' +
                        '</div>') +
                        '<div class="clear"></div>' +
                        '</li>');

            var swithID = Ultext.find("[id*='myonoffswitch']").attr("id");
            var uniq = uniqueID();
            Ultext.find("[id*='myonoffswitch']").attr("id", swithID + "_" + uniq);
            Ultext.find("[for*='myonoffswitch']").attr("for", swithID + "_" + uniq);

            $(div).find(".cashComp").append(Ultext);

            $(div).find(".grid-type .avgcol").append('<li class="amount without-label"><i class="'+(data[i].isPerc == 1 ? "icon-percentage" : "icon-indian-rupee")+' "></i><input isperc="' + data[i].isPerc +
                '" compcode="' + compcode + '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  addless="' + data[i].addless + '" comppk="' + compPK + '" name="' + txtName +
                '" type="text" placeholder="" restrict="avg" class="currency"></li>');

            $(div).find(".grid-type .form-controls").append('<li class="amount without-label"><i class="' + (data[i].isPerc == 1 ? "icon-percentage" : "icon-indian-rupee") + '"></i><input isperc="' + data[i].isPerc +
                '" compcode="' + compcode + '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  comppk="' + compPK + '" name="' + txtName +
                '" type="text" placeholder="" addless="' + data[i].addless + '" restrict="number" class="currency"></li>');

            cashCnt++;
        }
        if (data[i].type == "4") {
            if (bankCnt == 0) {
                $(div).find(".grid-type .form-controls").append('<i class="icon-close" onclick="fnCloseIncomeCol(this)"></i><li class="li-income-title">' +
                    '<p title="income period" contenteditable="true" class="incomeperiod">Period 1</p><h4><i class="icon-indian-rupee"></i>0</h4></li>');
                $(div).find(".grid-type .avgcol").append('<li><p>Average</p><h4><i class="icon-indian-rupee"></i></h4></li>');
            }
            var idPrefix = "bankcomp" + bankCnt + "_";

            var Ultext = "";
            if (data[i].istotal == 1) {
                //Ultext = '<li class="without-rangeslider" day="' + data[i].name + '" comppk="' + compPK + '">' + data[i].name + '</li>';
                Ultext = '<li class="without-rangeslider" day="' + data[i].name + '" comppk="' + compPK + '"><p>' + data[i].name +
                    '<span contenteditable="true" class="percText right">100</span></p>' +
                        '</li>';
            }
            else {
                Ultext = '<li class="without-rangeslider" day="' + data[i].name + '" comppk="' + compPK + '"><p>On ' + data[i].name +
                        'th<span contenteditable="true" class="percText right">100</span></p>' +
                        '<input isperc="' + data[i].isPerc + '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  addless="' + data[i].addless +
                        '" readonly comppk="' + compPK + '" type="text" class="range1' + idPrefix + '" value="" name="range" class="currency"/></li>';
            }

            $(div).find(".bankComp").append(Ultext);

            $(div).find(".grid-type .avgcol").append('<li class="amount without-label"><i class="icon-indian-rupee"></i><input isperc="' + data[i].isPerc +
                '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  addless="' + data[i].addless + '" comppk="' + compPK + '" name="' + txtName +
                '" type="text" placeholder="" restrict="avg" class="currency"></li>');

            $(div).find(".grid-type .form-controls").append('<li class="amount without-label"><i class="icon-indian-rupee"></i><input isperc="' + data[i].isPerc +
                        '" SrcComp="' + data[i].srccomp + '" DstComp="' + data[i].dstcomp + '"  comppk="' + compPK + '" name="' + txtName +
                        '" type="text" placeholder="" addless="' + data[i].addless + '" restrict="number" class="currency"></li>');
            bankCnt++;
        }

    }


    $(div).find("input[class^=range]").ionRangeSlider({
        min: 0,
        max: 200,
        from: 100,
        onChange: fnChangeSliderValue,
        onUpdate: fnUpdateSliderValue
    });

    $(div).find("input[isperc=3]").attr("readonly", true);

    if (type == 3) {
        $(div).find("input[class^=range]").closest(".income-range").find(".percText").remove()
        var percInputs = $(div).find("input[class^=range]");
        for (var a = 0; a < percInputs.length; a++) {
            var percSlider = $(percInputs[a]).data("ionRangeSlider");
            if (percSlider)
                percSlider.update({
                    disable: true
                });
        }
    }    
}

function fnUpdateSliderValue(data) {
    if ($(data.input).attr("addless") == "3") {
        return;
    }
    var PercValue = data.from;
    $(data.input).closest("li").find("span.percText").text(PercValue);
    var isOther = $(data.input).attr("isOther");
    if (isOther == "yes") {
        $("[restrict='number']").keyup();
        return;
    }
    var comppk = $(data.input).attr("comppk");
    var MainincmDiv = $(data.input).closest(".income-div")
    var incmDiv = $(MainincmDiv).find(".income-details");
    var AvgInput = $(incmDiv).find(".avgcol input[comppk='" + comppk + "']");
    var AddLess = $(data.input).attr("addless");
    if (AddLess == "3") {
        return;
    }

    var totVal = 0;
    $(incmDiv).find("ul.form-controls").find(".amount input[comppk='" + comppk + "']").each(function () {
        var tmp = FormatCleanComma($(this).val());
        tmp = Number(tmp) ? tmp : 0;
        totVal = totVal + tmp;
    });
    var Actvalue = Number(totVal);
    $(AvgInput).attr("OrgVal", FormatCurrency(Actvalue));
    Actvalue = Actvalue ? Actvalue : 0;
    Actvalue = Math.round(Actvalue * PercValue / 100);
    Actvalue = Actvalue ? Actvalue : 0;
    $(AvgInput).val(FormatCurrency(Actvalue));
    $(data.input).closest("div[num]").find("[restrict='number']").keyup();
}

function fnChangeSliderValue(data) {
    if ($(data.input).attr("addless") == "3") {
        return;
    }

    var comppk = $(data.input).attr("comppk");
    var MainincmDiv = $(data.input).closest(".income-div");
    var incmDiv = $(MainincmDiv).find(".income-details");
    var AvgInput = $(incmDiv).find(".avgcol input[comppk='" + comppk + "']");
    var PercValue = data.from;
    $(data.input).closest("li").find("span.percText").text(PercValue);

    var isOther = $(data.input).attr("isOther");
    if (isOther == "yes") {
        $("[restrict='number']").keyup();
        return;
    }

    var totVal = 0
    $(incmDiv).find("ul.form-controls").find(".amount input[comppk='" + comppk + "']").each(function () {
        var tmp = $(this).val();
        tmp = Number(tmp) ? tmp : 0;
        totVal = totVal + tmp;
    });
    var Actvalue = Number(totVal);
    $(AvgInput).attr("OrgVal", Actvalue);
    Actvalue = Actvalue ? Actvalue : 0;
    Actvalue = Math.round(Actvalue * PercValue / 100);
    Actvalue = Actvalue ? Actvalue : 0;
    $(AvgInput).val(Actvalue);
    $(data.input).closest("div[num]").find("[restrict='number']").keyup();
}

$(function () {
    var isCO = window.CREDIT_APPROVER_NO;
    isCO = isCO ? isCO : "";
    if (isCO == "") {
        fnCallScrnFn = function (isMoveNext) {
            ISMOVENXT = isMoveNext;
            fnSaveFinancialData();
        }
    }
});

function fnChangeCreditDetails(isInsert) {
    var totalIncome = 0;
    var totalObligation = 0;
    var SalaryorSelf = true; // true -Salary ,  false - Self Employed
    var IsProof = true;
    var cibil = 0;
    var tenurevalue = $("#txtLoanTenure").val();
    var prevInc = 0, CurInc = 0;
    $("#Brnch_summary .applicant-box").each(function (i) {
        var proofLength = $(this).find(".icon-proof").length;
        var IncType = $(this).find(".Appincome-type").attr("incType");
        if (IncType != "0")
            SalaryorSelf = false;
        if (proofLength == 0)
            IsProof = false;        
        var IncAmt = FormatCleanComma($(this).find(".income-amount").justtext());
        IncAmt = parseInt(IncAmt) ? parseInt(IncAmt) : 0;
        totalIncome += IncAmt;
        var OblAmt = FormatCleanComma($(this).find(".liability-amount").justtext());
        OblAmt = parseInt(OblAmt) ? parseInt(OblAmt) : 0;
        totalObligation += OblAmt;

        CurInc = IncAmt - OblAmt;
        if (CurInc > prevInc || i == 0)
            cibil = $(this).find(".cibil-score").justtext();
        prevInc = CurInc;
    });

    var incmClas = $(".category-info .category-icons li:nth-child(2)").find("i").attr("class");
    if (incmClas.indexOf("icon-salaried") >= 0)
        SalaryorSelf = true;
    else
        SalaryorSelf = false;
    var PrfClas = $(".category-info .category-icons li:nth-child(3)").find("i").attr("class");
    if (PrfClas.indexOf("icon-proof") >= 0)
        IsProof = true;
    else
        IsProof = false;

    var Prdfk = $(".category-info .category-icons li:nth-child(1)").find("i").attr("prdfk");
    var prdcd = $(".category-info .category-icons li:nth-child(1)").find("i").attr("prdcode");
    if (Prdfk == "" || Prdfk == 0) {
        fnShflAlert("error", "select Product first!");
        return;
    }
    CustFinGlobal[0].PrdFk = Prdfk;

    var propVAl = FormatCleanComma($("#txtShflPrpVal").justtext());


    var netIncome, foirValue, cibil,  ElgLoanAmt, EmiAmt, Roi, spread, EstPrpValue, LTV;

    netIncome = totalIncome;    
    EstPrpValue = Number(propVAl);
    ElgLoanAmt = Number(FormatCleanComma($("#R_txtLoanAmt").justtext()));
    tenurevalue = $("#R_txtLoanTenure").val();
    if (tenurevalue < 10) {
        fnShflAlert("error", "Tenure should not be less than 10 months");
        return;
    }
    Roi = Number($("#R_txtLoanROI").val());
    spread = Roi - 15;
    LTV = (ElgLoanAmt / EstPrpValue) * 100;
    LTV = LTV.toFixed(2);
    EmiAmt = CreditFormulas.PMT(Roi, tenurevalue, ElgLoanAmt);
    var isLap = false;
    if (prdcd.trim().toUpperCase().indexOf("LAP") == 0) isLap = false;
    if (isLap)
        foirValue = (EmiAmt / (netIncome - totalObligation)) * 100;
    else
        foirValue = ((EmiAmt + totalObligation) / netIncome) * 100;
    

    /*
    var txtLoanLTV = $("#txtLoanLTV").val();
    txtLoanLTV = txtLoanLTV ? txtLoanLTV : 50;

    var txtLoanFOIR = $("#txtLoanFOIR").val();
    txtLoanFOIR = txtLoanFOIR ? txtLoanFOIR : 60;

    var netIncome = CreditFormulas.NetIncome(totalIncome, totalObligation);
    var foirValue = txtLoanFOIR || CreditFormulas.FOIR(netIncome);

    var SalTyep = "SAL";
    var RoiObj = { CIBIL: cibil, FOIR: foirValue };
    if (!SalaryorSelf) {
        SalTyep = "SELF";
        RoiObj = { IsIncomeProof: true, LTV: 50, CIBIL: cibil, FOIR: foirValue };
    }
    var Roi = CreditFormulas.ROI(SalTyep, RoiObj);
    Roi = Roi < 1 ? Roi * 100 : Roi;
    Roi = Roi.toFixed(2);
    var ElgLoanAmt = CreditFormulas.EligibleLoanAmt(netIncome, tenurevalue, propVAl, txtLoanLTV, txtLoanFOIR, Roi);
    // Recommended  By BC user 
    var R_roi = $("#R_txtLoanROI").val();
    //var R_loanamt = FormatCleanComma($("#R_txtLoanAmt").val());
    var R_loanamt = FormatCleanComma($("#R_txtLoanAmt").justtext());
    var R_tenur = $("#R_txtLoanTenure").val();

    ElgLoanAmt = R_loanamt;
    Roi = R_roi;
    tenurevalue = R_tenur;

    var spread = 15 - Roi;
    var expLnAmt = parseInt(FormatCleanComma($("#txtLoanAmt").attr("OrgValue")));
    if (ElgLoanAmt > expLnAmt)
        ElgLoanAmt = expLnAmt;
    var EmiAmt = CreditFormulas.PMT(Roi, tenurevalue, ElgLoanAmt);
    EmiAmt = EmiAmt ? EmiAmt : 0;

    var LTV = txtLoanLTV;
    var EstPrpValue = propVAl;

    var ElgLoanAmtLkh = ElgLoanAmt / 100000;
    $("#txtElgSpread , #txtElgLnAmt, #txtElgLnROI , #txtElgLnEMI").css({ "color": "red" });
    $("#txtElgSpread").val(spread);
    $("#txtElgLnAmt").val(ElgLoanAmtLkh);
    $("#txtElgLnAmt").attr("OrgValue", ElgLoanAmt);
    $("#txtElgLnROI").val(Roi);
    $("#txtElgLnEMI").val(EmiAmt);

    */

    if (isInsert) {
        foirValue = foirValue < 1 ? foirValue * 100 : foirValue;

        var CreditObj = [
                { AttrCd: "NET_INC", Value: netIncome },
                { AttrCd: "OBL", Value: totalObligation },
                { AttrCd: "CBL", Value: cibil },
                { AttrCd: "TENUR", Value: tenurevalue },
                { AttrCd: "LOAN_AMT", Value: ElgLoanAmt },
                { AttrCd: "EMI", Value: EmiAmt },
                { AttrCd: "ROI", Value: Roi },
                { AttrCd: "SPREAD", Value: spread },
                { AttrCd: "EST_PRP", Value: EstPrpValue },
                { AttrCd: "LTV", Value: LTV }
        ];
        if (isLap) {
            CreditObj.push(
            { AttrCd: "IIR", Value: foirValue }
            );
        }
        else {
            CreditObj.push(
            { AttrCd: "IIR", Value: foirValue }
            );
        }
        var detailJSON = [{
            business: '', salary: '', cash: '',
            bank: '', other: '', NHBclss: '',
            NHBdepndt: '', BankAcc: '',
            Liability: '',
            CreditJson: JSON.stringify(CreditObj)
        }];

        var PrcObj = {
            ProcedureName: "PrcShflCustFinancials", Type: "SP",
            Parameters: ["INSERT_CREDIT_DTLS", JSON.stringify(CustFinGlobal), JSON.stringify(detailJSON)]
        };
        fnCallLOSWebService("INSERT_CREDIT_DTLS", PrcObj, fnCustFinResult, "MULTI");
    }
}

function fnSaveCreditAttr() {
    /*
      Income
      Obligation
      IIR / FOIR Percentage
      Market Value
      Actual Value
      Market LTV
      Actual LTV
      Bureau Score
      Loan Amount
      Tenure
      ROI
      Spread
      EMI Amount
  */


}

FB_CLICKED = null;

function fnOnPopUpClick(PopObj) {
    FB_CLICKED = PopObj;
    $("#bc_Feedback_div input[name='text']").val("");
    $("#bc_Feedback_div textarea[name='text']").val("");
    $("#rptsts").attr("class", "icon-positive");
    $("#rptsts").closest("p.bg").attr("class", "bg bg1");
    $("#bc_Feedback_div input[key=pop_rptstatus]").val(2);
    $(".contact-details label").text("Details");
    $(".contact-details #ltv_Mob span").text("");
    $(".contact-details #ltv_Lnd span").text("");
    $("#PDfileList").empty();

    $("p.TVphNo").removeClass("active");

    var sel_Pop_typ = $(PopObj).attr("flag");

    var lapfk = $(PopObj).closest(".applicant-box").attr("appfk");
    $("#sel_lapFk").val(lapfk);

    var objProcData = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SELECT_FB_POP", JSON.stringify(CustFinGlobal), "", "", lapfk] }
    fnCallLOSWebService("SELECT_FB_POP", objProcData, fnCustFinResult, "MULTI", sel_Pop_typ);

    return;
}

function fnpopupconfirm() {
    
    var popupjson = {};
    var dateval = $("#bc_RptDt").val();
    var date = dateval.substring(0, 2);
    var month = dateval.substring(3, 5);
    var year = dateval.substring(6, 10);
    var dateToCompare = new Date(year, month - 1, date);
    var currentDate = new Date();
    if (dateval == "") {
        fnShflAlert("error", "Enter Report Date!!");
        return false;
    }
    if (dateval != '') {
        if (dateToCompare > currentDate) {
            fnShflAlert("error", "Report Date Should not be greater than Current Date!!");
            return false;
        }
    }
    var Pk = $("#bc_Feedback_div").attr("notepk");
    var notetype = $("#bc_Feedback_div").attr("notetype");
    popupjson = fnGetFormValsJson_IdVal("bc_Feedback_div");
    popupjson[0].sel_Pop_typ = notetype;
    Action = (Pk > 0) ? "UPDATE_FB_POP" : "INSERT_FB_POP";
    var mobilenum = $("p.TVphNo.active").find("span").text();
    popupjson[0].popmobile = mobilenum;
    //if (mobilenum == "" && notetype != 2) {
    //    fnShflAlert("error", "select verified Phone number!");
    //    return;
    //}
    var PD_FileJSON = [];
    $("#PDfileList span").each(function () {
        var path = $(this).attr("path");
        PD_FileJSON.push({ filePath: path });
    });
    var detailJSON = [{
        PDFileJson: JSON.stringify(PD_FileJSON)
    }];
    var objProcData = {
        ProcedureName: "PrcShflCustFinancials", Type: "SP",
        Parameters: [Action, JSON.stringify(CustFinGlobal), JSON.stringify(detailJSON), JSON.stringify(popupjson), Pk, notetype]
    };
    fnCallLOSWebService(Action, objProcData, fnCustFinResult, "MULTI", popupjson);
}


function fnAddBankRow(elem) {
    var cutDiv = $(elem).closest(".customer-financial-div");
    var apppk = $(cutDiv).attr("apppk");
    var usrnm = $(".applicant-box[appfk=" + apppk + "]").find(".ApplicantName").text();

    var UlBankHtml = $('<ul appFk="' + apppk + '" bankpk="0" class="form-controls">' +
                                '        <li class="width-11">' +
                                '          <input readonly name="AccountName" type="text" placeholder="" value="' + usrnm + '">' +
                                '      </li>' +
                                '     <li class="width-18">' +
                               '     <div name="AccountType" class="select-focus">' +
                                  '       <input selval="-1" value="" placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                                  '      <i class="icon-down-arrow"></i>' +
                                  '     <ul class="custom-select">' +
                                  '      <li val="0">Current</li>' +
                                  '      <li val="1">Saving</li>' +
                                  '      <li val="2">Overdraft</li>' +
                                  '      <li val="3">Cash Credit</li>' +
                                  '        </ul>' +
                                  '     </div>' +
                                '  </li>' +
                                '        <li class="width-11">' +
                                '         <input type="text" name="AccountNumber" placeholder="" value="">' +
                                '      </li>' +
                                '  <li class="width-9">'+
                                       ' <input type="text" placeholder="" name="OperativeSince" class="datepickerdef" restrict="number">' +
                                   ' </li>'+
                                '     <li class="width-32">' +
                              //'      <input type="text" name="BankName" placeholder="" value="' + BankData[k].BankName + '">' +
                                  '<comp-help id="bank-help" name="BankName" txtcol="BankName" valcol="Bankpk" onrowclick="fnBnkclick" prcname="PrcShflScanBankhelp"' +
                                  ' width="100%"></comp-help>' +
                                  '   </li>' +
                                  '        <li class="width-18">' +
                                  //'         <input type="text" name="BranchName" placeholder="" value="' + BankData[k].BranchName + '">' +
                                  '<comp-help id="branch-help" name="BranchName" txtcol="Location" valcol="Brnchpk" helpfk="0" onrowclick="fnBrnchclick" ' +
                                  'prcname="PrcShflscanBranchhelp" width="100%"></comp-help>' +
                                '    </li>' +
                                '     <li class="width-22">' +
                                '      <div name="bnkTran" class="select-focus">' +
                                '            <input selval="-1" placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                                '           <i class="icon-down-arrow"></i>' +
                                '          <ul class="custom-select">' +
                                '           <li val="0">&lt;6</li>' +
                                '          <li val="1">6-18</li>' +
                                '              <li val="2">&gt;18</li>' +
                                '           </ul>' +
                                '        </div>' +
                                '</li>' +
                                '<li class="width-53">' +
                                '         <input type="text" restrict="number" name="AvgBal" placeholder="" value="">' +
                                ' </li>' +
                                '<li class="width-53">' +
                                '     <div name="InChqBounce" class="select-focus">' +
                                '       <input selval="-1" placeholder="Select" onkeypress="return false" name="select" class="autofill">' +
                                '      <i class="icon-down-arrow"></i>' +
                                '     <ul class="custom-select">' +
                                '      <li val="0">0</li>' +
                                '     <li val="1">&lt;3</li>' +
                                '    <li val="2">&gt;=3</li>' +
                                '            </ul>' +
                                '         </div>' +
                                '</li>' +
                                '     <li class="width-5 align-center">' +
                                '      <i name="Notes" txtval="" class="icon-chat-o"></i> ' +
                                '   </li>' +
                                '  <li class="width-5 align-center">' +
                                '      <i name="close" onclick="fnCloseBank(this)" class="icon-close"></i> ' +
                                '   </li>' +
                                '</ul>');
    $(cutDiv).find(".bank-details").append(UlBankHtml);
    fnDrawDefaultDatePicker();
    $(".bank-details .datepicker,.datepickerdef").each(function () {
        fnRestrictDate($(this));
    });
    fnInitiateSelect("bank-details", 1);
}

function fnCloseBank(elem) {
    try {
        $(elem).closest("ul[appFk]").remove();
    } catch (e) { }
}


function fnReprtSts(elem) {
    var cls = $(elem).attr("class");
    var lihtml = $(elem).closest("li.div-right.status");
    if (cls == "icon-positive") {
        $(lihtml).find("p.bg").attr("class", "bg bg2");
        $(lihtml).find("i").attr("class", "icon-negative");
        $(lihtml).find("input[key=pop_rptstatus]").val(0);

    }
    else if (cls == "icon-negative") {
        $(lihtml).find("p.bg").attr("class", "bg bg7");
        $(lihtml).find("i").attr("class", "icon-no-status");
        $(lihtml).find("input[key=pop_rptstatus]").val(1);

    }
    else if (cls == "icon-no-status") {
        $(lihtml).find("p.bg").attr("class", "bg bg1");
        $(lihtml).find("i").attr("class", "icon-positive");
        $(lihtml).find("input[key=pop_rptstatus]").val(2);

    }
}


function fnSelectFB_POP(type, teledata, pddata, TV_Ph) {

    if (type == 1 || type == 3) {
        $("#mobnum").show();
        $("#bc_Feedback_div").attr("notetype", type);
        if (type == 1)
            $("#Feeback_title").text("Tele Verification - Office");
        else if (type == 3)
            $("#Feeback_title").text("Tele Verification - Residential");

        if (teledata.length > 0) {
            if (teledata[0].pop_rptstatus == 0) {
                $("#rptsts").attr("class", "icon-negative");
                $("#rptsts").closest("p").attr("class", "bg bg2");
            }
            else if (teledata[0].pop_rptstatus == 1) {
                $("#rptsts").attr("class", "icon-no-status");
                $("#rptsts").closest("p").attr("class", "bg bg7");
            }
            else if (teledata[0].pop_rptstatus == 2) {
                $("#rptsts").attr("class", "icon-positive");
                $("#rptsts").closest("p").attr("class", "bg bg1");
            }
            $("#spantele").attr("pk", teledata[0].LtvPk);
            $("#bc_Feedback_div").attr("notepk", teledata[0].LtvPk);
            fnSetValues("bc_Feedback_div", teledata);
            $("#bc_Feedback_div").show();
        }
        else {
            $("#bc_Feedback_div").attr("notepk", 0);
            $("#bc_RptDt").val("");
            $("#bc_RptRmks").val("");
        }

        if (TV_Ph.length > 0) {
            if (type == 3) {
                $(".contact-details label").text("Contact Details");
                $(".contact-details #ltv_Mob span").text(TV_Ph[0].LapMob);
                $(".contact-details #ltv_Mob").attr("PhNo", TV_Ph[0].LapMob);
                if (TV_Ph[0].LapRes == "") {
                    $(".contact-details #ltv_Lnd span").removeClass("icon-landline");
                }
                $(".contact-details #ltv_Lnd span").text(TV_Ph[0].LapRes);
                $(".contact-details #ltv_Lnd").attr("PhNo", TV_Ph[0].LapRes);
                var althtml;
                if (TV_Ph[0].alterno != "") {
                    althtml = '<i class="icon-mobile"></i>Alternate No : <span class="TVphNo" PhNo="' + TV_Ph[0].alterno + '">' + TV_Ph[0].alterno + '</span></p>';
                    $(".contact-details #ltv_alter").html(althtml);
                    $(".contact-details #ltv_alter").attr("PhNo", TV_Ph[0].alterno);
                }
                $(".contact-details #ltv_off").html("");
            }
            else if (type == 1) {
                $(".contact-details #ltv_alter").html("");
                $(".contact-details label").text("Contact Details");
                $(".contact-details #ltv_Mob span").text(TV_Ph[0].LapMob);
                $(".contact-details #ltv_Mob").attr("PhNo", TV_Ph[0].LapMob);
                $(".contact-details #ltv_Lnd span").text(TV_Ph[0].LapRes);
                $(".contact-details #ltv_Lnd").attr("PhNo", TV_Ph[0].LapRes);
                var offHTML = "";
                if (TV_Ph[0].OffNo != "") {
                    offHTML = '<i class="icon-landline"></i>Office No : <span class="TVphNo" PhNo="' + TV_Ph[0].OffNo + '">' + TV_Ph[0].OffNo + '</span></p>';
                    $(".contact-details #ltv_off").attr("PhNo", TV_Ph[0].OffNo);
                }
                else {
                    offHTML = '<i class="icon-landline"></i>Business No : <span class="TVphNo" PhNo="' + TV_Ph[0].BusNo + '">' + TV_Ph[0].BusNo + '</span></p>';
                    $(".contact-details #ltv_off").attr("PhNo", TV_Ph[0].BusNo);
                }
                $(".contact-details #ltv_off").html(offHTML);

            }
        }
        if (teledata.length > 0) {
            $("p.TVphNo[PhNo=" + teledata[0].appnumber + "]").addClass("active");
        }
        $("#PDattachDiv").hide();
        $("#bc_Feedback_div").show();

    }
    else if (type == 2) {
        $("#Feeback_title").text("Personal Discussion");
        $("#bc_Feedback_div").attr("notetype", 2);
        $("#mobnum").hide();

        $("#PDattachDiv").show();

        if (TV_Ph.length > 0) {
            $(".contact-details label").text("Contact Details");
            $(".contact-details #ltv_Mob span").text(TV_Ph[0].LapMob);
            $(".contact-details #ltv_Lnd span").text(TV_Ph[0].LapRes);
        }
        if (pddata.length > 0) {
            if (pddata[0].pop_rptstatus == 0) {
                $("#rptsts").attr("class", "icon-negative");
                $("#rptsts").closest("p").attr("class", "bg bg2");

            }
            else if (pddata[0].pop_rptstatus == 1) {
                $("#rptsts").attr("class", "icon-no-status");
                $("#rptsts").closest("p").attr("class", "bg bg7");

            }
            else if (pddata[0].pop_rptstatus == 2) {
                $("#rptsts").attr("class", "icon-positive");
                $("#rptsts").closest("p").attr("class", "bg bg1");

            }
            $("#spanpd").attr("pk", pddata[0].LpdPk);
            $("#bc_Feedback_div").attr("notepk", pddata[0].LpdPk);

            var DocPath = pddata[0].filepath;
            $("#PDfileList").empty();
            if (DocPath && DocPath != '' && DocPath != null) {
                var n = DocPath.lastIndexOf("___") + 3;
                var docfiles = '<span pk="0" path="' + DocPath + '" ><i class="icon-attach"></i>' + DocPath.substr(n, DocPath.length) + '</span>';
                $("#PDfileList").append(docfiles);
            }

            fnSetValues("bc_Feedback_div", pddata);
            $("#bc_Feedback_div").show();



        } else {
            $("#bc_Feedback_div").attr("notepk", 0);
            $("#bc_RptDt").val("");
            $("#bc_RptRmks").val("");
        }
        $("#bc_Feedback_div").show();
    }
}

$(document).on("click", "p.TVphNo", function (e) {
    if ($(this).find("span").text().trim() != "") {
        $("p.TVphNo").removeClass("active");
        $(this).addClass("active");
    }
});

function fnEventWithDocumentTarget() {
    //var BCLoaded = localStorage.getItem("isBCLoaded") || "";
    var BCLoaded = "false"
    if (BCLoaded != "true") {
        var defincnm = 1;
        // FOR INCOME EDITABLE NAME 
        $(document).on("keydown", ".income-editable,.li-income-title p[contenteditable],.li-income-title span.Business_DoF", function (e) {
            var keyCode = e.which ? e.which : e.keyCode;
            if (keyCode == 13) {
                $(this).focusout();
                return false;
            }
        });

        $(document).on("focusout", ".li-income-title p[contenteditable],.Business_DoF", function (e) {
            var txt = $(this).text();
            txt = txt.trim();
            var cls = $(this).attr("class");
            if (txt == "" && cls == "Business_DoF")
                $(this).text("DoF");
            else if (txt == "")
                $(this).text("Period");
        });

        $(document).on("keyup", ".income-editable", function (e) {

            var incName = $(this).text().trim();
            var AppDiv = $(this).closest(".customer-financial-div");
            var parentLi = $(this).closest("li[num]");
            var LiNum = $(parentLi).attr("num")
            var LiClass = $(parentLi).attr("class");
            LiClass = LiClass.replace("active", "");
            LiClass = LiClass.replace("income", "customer");
            LiClass = LiClass.trim();
            $(AppDiv).find(".box-div.income-container div." + LiClass + "[num=" + LiNum + "]").attr("incomename", incName);
        });

        $(document).on("focusout", ".income-editable", function (e) {
            var incName = $(this).text().trim();
            var AppDiv = $(this).closest(".customer-financial-div");
            var parentLi = $(this).closest("li[num]");
            var LiNum = $(parentLi).attr("num")
            var LiClass = $(parentLi).attr("class");
            LiClass = LiClass.replace("active", "");
            LiClass = LiClass.replace("income", "customer");
            LiClass = LiClass.trim();
            if (incName == "") {
                incName = "default_" + defincnm;
                $(this).text(incName);
                defincnm++;
            }

            if ($(AppDiv).find("div[incomename='" + incName + "']").length > 1) {
                fnShflAlert("error", "Entered name is already added, Add another name.");
                incName = "default_" + defincnm;
                $(this).text(incName);
                defincnm++;
            }
            $(AppDiv).find(".box-div.income-container div." + LiClass + "[num=" + LiNum + "]").attr("incomename", incName);
        });


        // Income Percentage Edit      
        $(document).on("keypress", "span.percText", function (e) {
            try {
                var elem = this;
                var keyCode = e.which ? e.which : e.keyCode
                var ret = ((keyCode >= 48 && keyCode <= 57) || keyCode == 46 || keyCode == 8 || keyCode == 37 || keyCode == 39);
                if (keyCode == 46) {
                    var txt = $(elem).justtext();
                    if (txt.replace(/[^.]/g, "").length > 0)
                        ret = false;
                }

                if (keyCode == 13) {
                    txt = $(elem).justtext() || "";
                    txt = txt.trim();
                    var value = Number(txt);
                    var slider = $(elem).closest("li").find("[name=range]").data("ionRangeSlider");
                    if (slider)
                        slider.update({
                            from: value,
                            onChange: fnChangeSliderValue,
                            onUpdate: fnUpdateSliderValue
                        });
                }
                return ret;
            }
            catch (e) { }

        });

        $(document).on("focusout", "span.percText", function (e) {
            try {
                var elem = this;
                var txt = $(elem).justtext() || "";
                txt = txt.trim();
                var value = Number(txt);
                var slider = $(elem).closest("li").find("[name=range]").data("ionRangeSlider");
                if (slider)
                    slider.update({
                        from: value,
                        onChange: fnChangeSliderValue,
                        onUpdate: fnUpdateSliderValue
                    });
            }
            catch (e) { }
        });

        /* Avoid typing in Average column */
        $(document).on("keypress", "[restrict='avg']", function (e) { return false; });

        /* Notes Popup */
        $(document).on("click", "li  .icon-chat-o", function (e) {
            var value = $(this).attr("txtval");
            value = value ? value : '';
            $("#comment-chat").find("textarea").val(value);
            window.remarksicon = this;
            $("#comment-chat").show();
        });

        /* Liablity Notes Popup */
        //$(document).on("click", "li .liability-Notes", function (e) {
        //    $("#comment-chat").hide();
        //    var value = $(this).attr("txtval");
        //    value = value ? value : '';
        //    var bouncevalue = $(this).attr("bounce");
        //    bouncevalue = bouncevalue ? bouncevalue : '';
        //    var Depvalue = $(this).attr("debtamount");
        //    Depvalue = Depvalue ? Depvalue : '';

        //    $("#Liability-chat").find("textarea").val(value);
        //    $("#Liability-chat").find("ul.form-controls li").find("[name = 'Bounce']").val(bouncevalue);
        //    $("#Liability-chat").find("ul.form-controls li").find("[name = 'DebtAmt']").val(Depvalue);
        //    window.Oblremarksicon = this;
        //    $("#Liability-chat").show();
        //});

        /* To restrict alphabetics and special characters*/
        $(document).on("keypress", "[restrict='number']", function (e) {
            try {
                if (fnNumberKeyPress(e, this))
                    return true;
                else
                    return false;
            }
            catch (e) { return false; }
        });

        /* onffswitch check box  */
        $(document).on("change", "[name='onoffswitch']", function (e) {
            var liablityLen = $(this).closest("ul.form-controls[lapfk]").length;
            var IncomeLi = $(this).closest("li[num]");
            var ApplicantDiv = $(this).closest(".customer-financial-div");
            if (liablityLen > 0)
            { $("input[name=EMI]").keyup(); }
            else {
                if ($(IncomeLi).hasClass("income-other") || $(IncomeLi).hasClass("income-bank")) {
                    $(this).prop("checked", true);
                    return;
                }
                else {
                    if (IncomeLi && IncomeLi.length > 0) {
                        var isChecked = $(this).is(":checked");
                        var cls = $(IncomeLi).attr("class");
                        cls = cls.replace("active", "");
                        cls = cls.trim();
                        cls = cls.replace("income", "customer");
                        var Num = $(IncomeLi).attr("num");
                        var div = $(ApplicantDiv).find(".box-div.income-container ." + cls + "[num='" + Num + "']");
                        $(div).find("[name='onoffswitch']").prop("checked", isChecked);
                        $("[restrict='number']").keyup();
                    } else {
                        $("[restrict='number']").keyup();
                    }
                }
            }
        });
        /* Avoid Total textbox keyin */
        $(document).on("keydown", "[restrict='number']", function (e) {
            if ($(this).attr("addless") == "3")
                return false;
        });

        /* Income textboxes Entry - Adding,Average, Total works */
        keyupcount = 0;
        window.isCashKeyup = false;
        $(document).on("keyup", "input[restrict='number']", function (e) {
            try {
                var divClass = $(this).closest("div[num]").attr("class");
                if (divClass == "customer-cash")
                    isCashKeyup = true;
                fnIncomeKeyUp(e, this);
            }
            catch (e) { }
        });

        /* EMI of obligations */
        $(document).on("keyup", ".liability-div .grid-type ul.form-controls input[name=EMI]", function () {
            
            var liability = 0;
            $(this).closest(".liability-div").find(".grid-type ul.form-controls input[name=EMI]").each(function () {
                var chk = $(this).closest("ul.form-controls").find("[name='onoffswitch']").is(":checked");
                if (chk)
                    liability += Number(FormatCleanComma($(this).val()));
            });            
            $(this).closest(".customer-financial-div").find("ul.finance-tab li.obligation-li h4").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(parseInt(liability)));
            var mainDiv = $(this).closest(".customer-financial-div");            
            $(".applicant-box[appfk='" + $(mainDiv).attr('apppk') + "']").find(".liability-amount").
                html('<i class="icon-indian-rupee"></i>' + FormatCurrency(parseInt(liability)));

            var totalObligation = 0;
            $("#Brnch_summary.applicant-summary .applicant-box[appfk]").each(function () {
                totalObligation += Number(FormatCleanComma($(this).find(".liability-amount").justtext())) || 0;
            });
            $("#totalObligation").html("<i class='icon-indian-rupee'></i>" + FormatCurrency(totalObligation));
        });

        /* Add New Applicant tabs */
        $(document).on("click", ".customer-financial .common-tabs li", function (e) {
            if ($(this).hasClass("li-icon-plus")) {
                fnAddNewApplicant(e, this, "0");
            } else {
                $(".customer-financial .common-tabs").find("li").removeClass("active");
                $(this).addClass("active");
                var val = $(this).attr("val");
                $(".applicant-box").hide();
                $(".applicant-box[box=" + val + "]").show();

                $(".customer-financial-div[val='" + val + "']").show();
                $(".customer-financial-div[val='" + val + "']").siblings(".customer-financial-div").hide();
                var len = $(".customer-financial-div[val='" + val + "']").find("ul.finance-tab li").length;
                if (len > 1) {
                    $(".customer-financial-div[val='" + val + "']").find("ul.finance-tab li:first-child").click();
                }
            }
        });

        /* Choose Income type and salary Proof */
        $(document).on("click", "ul.category-list li", function () {

            if (window.CREDIT_APPROVER_NO) { return; }
            var parent = $(this).parents("div.popup-content");
            var ullist = $(parent).find("ul.category-list");
            var ul = $(this).closest("ul.category-list");
            var index = $(ullist).index(ul);
            var clsnm = $(this).find("i").attr("class");
            var txt = $(this).find("p").html();
            var PrdFk = $(this).find("i").attr("pk");
            $(".category-icons").find("li:nth-child(" + (index + 1) + ") i").attr("class", clsnm);
            $(".category-icons").find("li:nth-child(" + (index + 1) + ") p").text(txt);

            if (index == 0) {
                $(".category-icons").find("li:nth-child(" + (index + 1) + ") i").attr("pk", PrdFk);
                $(".category-icons").find("li:nth-child(" + (index + 1) + ") i").attr("prdfk", PrdFk);
            }
            var salType = $(".category-icons").find("li:nth-child(2) i").attr("class");
            salType = salType.toLowerCase();
            var salPrf = $(".category-icons").find("li:nth-child(3) i").attr("class");
            salPrf = salPrf.toLowerCase();
            var PrdType = $(".category-icons").find("li:nth-child(1) i").attr("prdfk");
            PrdType = PrdType ? PrdType : "";
            if (salType == "icon-salaried")
            { salType = 0; }
            else if (salType == "icon-self-employed")
            { salType = 1; }
            else
            { salType = ""; }

            if (salPrf == "icon-proof")
            { salPrf = 0; }
            else if (salPrf == "icon-no-proof")
            { salPrf = 1; }
            else
            { salPrf = ""; }

            var tempCustFinGlobal = CustFinGlobal;
            tempCustFinGlobal[0].SalType = salType;
            tempCustFinGlobal[0].SalPrf = salPrf;
            tempCustFinGlobal[0].PrdType = PrdType;

            var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["UPDATE_APP_EMP", JSON.stringify(tempCustFinGlobal)] };
            fnCallLOSWebService("UPDATE_APP_EMP", PrcObj, fnCustFinResult, "MULTI");
        });

        /* Toggle Income tabs */
        $(document).on("click", "ul.finance-tab li:not(li.li-icon-plus)", function () {
            try {
                var classNm = $(this).attr("class");
                $(this).addClass("active");
                $(this).siblings().removeClass("active");
                var Num = $(this).attr("num");
                classNm = classNm.replace("active", "");
                classNm = classNm.trim();
                var divNm = classNm.replace("income", "customer");
                $(".box-div.income-container ." + divNm + "[num='" + Num + "']").show();
                $(".box-div.income-container ." + divNm + "[num='" + Num + "']").siblings().hide();
            }
            catch (e) { }
        });

        /* Comment for bank */
        $(document).on("click", ".bank-details .icon-chat-o", function () {
            $("#comment-chat").show();
        });

        /* Comment for bank */
        $(document).on("click", ".bc_link_feeback", function () {
            fnOnPopUpClick($(this));
        });

        $(document).on("click", "#spnprpslinfo", function () {
            fnOpenPrpslInfo();
        });

        //localStorage.setItem("isBCLoaded","true");
    }
}
function fnpop() {
    $("#fold_nm").val(GlobalXml[0].LeadID);
    window.open("", "newWin", "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=20,top=20,width=600,height=600");
    PostForm.submit();
}

var keyupcount = 0;

function fnIncomeKeyUp(e, elem) {
    if (!FullIncomeLoaded)
        return;
    //keyupcount++;
    //console.log(keyupcount);    
    try {
        var liindex = $(elem).closest("li").index();
        var IncomeUL = $(elem).closest("ul");
        var IncomeULTitle = $(IncomeUL).find(".li-income-title h4");
        var IncomeMainDiv = $(elem).closest("div[num]");
        var num = $(elem).closest("div[num]").attr("num");
        var divClass = $(elem).closest("div[num]").attr("class");
        if (!divClass || divClass == null || divClass == undefined || divClass == "")
            return;
        var mainDiv = $(elem).closest(".customer-financial-div");
        var AppPk = $(mainDiv).attr("apppk");
        var UlList = $(mainDiv).find("ul.finance-tab");
        var liClass = divClass.replace("customer", "income");
        var curLi = $(UlList).find("." + liClass + "[num=" + num + "]");
        var compPK = $(elem).attr("comppk");
        var incomeDiv = $(elem).closest(".income-details");
        var avgCol = $(incomeDiv).find(".avgcol");
        var percUL = $(IncomeMainDiv).find("ul[particular=true]");

        if ($(UlList).find("li").length == 1) { }
        else {
            if (divClass == "customer-business" || divClass == "customer-salary" || divClass == "customer-bank") {
                var isperc = $(elem).attr("isperc");
                var ulElem = $(elem).closest("ul.form-controls");
                if (isperc == 2) {
                    $(ulElem).find("input[isperc=1]").keyup();
                }
                // Margin works
                if (isperc == 1) {
                    var percval = FormatCleanComma($(elem).val());
                    percval = percval ? percval : 0;
                    var srccomp = $(elem).attr("srccomp");
                    var dstcomp = $(elem).attr("dstcomp");
                    var srcval = FormatCleanComma($(ulElem).find("input[comppk=" + srccomp + "]").val());
                    srcval = srcval ? srcval : 0;
                    var dstval = srcval * percval / 100;
                    dstval = Math.round(dstval);
                    $(ulElem).find("input[comppk=" + dstcomp + "]").val(FormatCurrency(dstval));
                    $(ulElem).find("input[isperc=3]").keyup();
                }

                // Percentage value of the current row.
                var percInput = $(percUL).find("input[comppk='" + compPK + "']").data("ionRangeSlider");
                if (percInput == undefined || percInput == null)
                    return;
                var perc = percInput.result.from;
                // All text Box with same component
                var inputListForAverge = $(incomeDiv).find(".form-controls input[comppk='" + compPK + "']");
                var avgval = 0;
                var cnt = 0;
                // Get average of the Entered Row
                $(inputListForAverge).each(function () {
                    if ($(this).attr("isperc") != "1" && $(this).attr("isperc") != 1) {
                        var val = parseInt(FormatCleanComma($(this).val()));
                        val = val ? val : 0;
                        avgval += val;
                        cnt++;
                    }
                });
                if (avgval != 0) {
                    avgval = Math.round(avgval / cnt);
                    // Set the avg Original value to avg column textbox
                    $(incomeDiv).find(".avgcol input[comppk='" + compPK + "']").attr("OrgVal", FormatCurrency(avgval));
                    // Set the avg - Percantge value to avg column textbox
                    avgval = Math.round(avgval * perc / 100);
                    $(avgCol).find("input[comppk='" + compPK + "']").val(FormatCurrency(avgval));
                }
                else {
                    $(avgCol).find("input[comppk='" + compPK + "']").val(0);
                }
                // Set the Period Column total
                var crntULTotal = 0;
                var inputcount = 0;
                $(IncomeUL).find("li.amount input").each(function () {
                    if ($(this).attr("isperc") != "1" && $(this).attr("isperc") != 1) {
                        var val = parseInt(FormatCleanComma($(this).val()));
                        val = val ? val : 0;
                        var AddLess = $(this).attr("addless");
                        if (AddLess != "3") {
                            val = AddLess == "1" ? val : -val;
                            crntULTotal = crntULTotal + val;
                            inputcount++;
                        }
                    }
                });
                if (divClass == "customer-bank")
                    crntULTotal = (crntULTotal / inputcount);
                $(IncomeUL).find("li.amount input[addless='3']").val(FormatCurrency(crntULTotal));
                $(IncomeULTitle).html("<i class='icon-indian-rupee'></i>" + FormatCurrency(crntULTotal) + "</h4>");

                // Set the Average Total to Average total and average Heading                    
                var AvgULTotal = 0;
                inputcount = 0;
                $(avgCol).find("li.amount input").each(function () {
                    if ($(this).attr("isperc") != "1" && $(this).attr("isperc") != 1) {
                        var val = parseInt(FormatCleanComma($(this).val()));
                        var compPk_inc = $(this).attr("comppk");

                        var tmp_slider = $(percUL).find("input[comppk='" + compPk_inc + "']");
                        var tmp_checkBx = $(tmp_slider).closest("li.slide").find("[name='onoffswitch']");
                        var isConsider = $(tmp_checkBx).is(":checked");
                        val = val ? val : 0;
                        var AddLess = $(this).attr("addless");
                        if (AddLess != "3" && (isConsider || divClass == "customer-bank")) {
                            val = AddLess == "1" ? val : -val;
                            AvgULTotal = AvgULTotal + val;
                            inputcount++;
                        }
                    }
                });
                if (divClass == "customer-bank")
                    AvgULTotal = Math.round(AvgULTotal / inputcount);
                else
                    AvgULTotal = Math.round(AvgULTotal);
                $(avgCol).find("li.amount input[addless='3']").val(FormatCurrency(AvgULTotal));

                var avgHead = $(curLi).find("h4");
                $(avgCol).find("h4").html("<i class='icon-indian-rupee'></i>" + FormatCurrency(AvgULTotal) + "");
                var avgHeadVal = AvgULTotal;
                if (divClass == "customer-business")
                    avgHeadVal = Math.round(AvgULTotal / 12);
                var avgHeadTxt = "<i class='icon-indian-rupee'></i>" + FormatCurrency(avgHeadVal) + "";
                $(avgHead).html(avgHeadTxt);
            }
            else if (divClass == "customer-cash") {

                var percInput = $(percUL).find("input[comppk='" + compPK + "']").data("ionRangeSlider");
                var perc = 100;
                if (percInput && percInput.result)
                    perc = percInput.result.from;

                var isperc = $(elem).attr("isperc");
                var compcode = $(elem).attr("compcode");
                var compPK = $(elem).attr("comppk");
                //IncomeUL
                var sales, purchase, grossmargn, GrsPrft, Expnse, NetMrgn, netTotal;
                var salesAMT, purchaseAMT, grossmargnAMT, GrsPrftAMT, ExpnseAMT, NetMrgnAMT, netTotalAMT;
                sales = $(IncomeUL).find("[compcode='C_SALES']");
                purchase = $(IncomeUL).find("[compcode='C_PUR']");
                grossmargn = $(IncomeUL).find("[compcode='C_GM']");
                GrsPrft = $(IncomeUL).find("[compcode='C_GP']");
                Expnse = $(IncomeUL).find("[compcode='C_EXP']");
                NetMrgn = $(IncomeUL).find("[compcode='C_NM']");
                netTotal = $(IncomeUL).find("[compcode='C_NET']");

                if (isCashKeyup) {
                    isCashKeyup = false;
                    var evt = $.Event("keyup");
                    evt.which = 13;
                    fnIncomeKeyUp(evt, sales);
                    fnIncomeKeyUp(evt, purchase);
                    fnIncomeKeyUp(evt, grossmargn);
                    fnIncomeKeyUp(evt, GrsPrft);
                    fnIncomeKeyUp(evt, Expnse);
                    fnIncomeKeyUp(evt, NetMrgn);
                }

                //if (compcode != "C_GP")
                //    $(IncomeUL).find("input[compcode='C_GP']").keyup();

                salesAMT = parseInt(FormatCleanComma($(sales).val() == "" ? 0 : $(sales).val())),
                purchaseAMT = parseInt(FormatCleanComma($(purchase).val() == "" ? 0 : $(purchase).val())),
                grossmargnAMT = parseInt(FormatCleanComma($(grossmargn).val() == "" ? 0 : $(grossmargn).val())),
                GrsPrftAMT = parseInt(FormatCleanComma($(GrsPrft).val() == "" ? 0 : $(GrsPrft).val())),
                ExpnseAMT = parseInt(FormatCleanComma($(Expnse).val() == "" ? 0 : $(Expnse).val())),
                NetMrgnAMT = parseInt(FormatCleanComma($(NetMrgn).val() == "" ? 0 : $(NetMrgn).val()));

                if (NetMrgnAMT != 0) {
                    $(GrsPrft).val(0);
                    var netPft = parseInt(Math.round(salesAMT * NetMrgnAMT / 100));
                    $(grossmargn).val(0);
                    $(purchase).val(0);
                    $(Expnse).val(0);
                    $(netTotal).val(FormatCurrency(netPft));

                    $(IncomeULTitle).html("<i class='icon-indian-rupee'></i>" + FormatCurrency(netPft) + "</h4>");
                }
                else {
                    var grsPft;
                    if (grossmargnAMT != 0) {
                        $(purchase).val(0);
                        grsPft = parseInt(Math.round(salesAMT * grossmargnAMT / 100));
                        $(GrsPrft).val(FormatCurrency(grsPft));
                        $(netTotal).val(FormatCurrency(grsPft - ExpnseAMT));
                        $(IncomeULTitle).html("<i class='icon-indian-rupee'></i>" + FormatCurrency(grsPft - ExpnseAMT) + "</h4>");
                    }
                    else {
                        grsPft = salesAMT - purchaseAMT;
                        $(GrsPrft).val(FormatCurrency(grsPft));
                        var netPft = grsPft - ExpnseAMT;
                        $(netTotal).val(FormatCurrency(netPft));
                        $(IncomeULTitle).html("<i class='icon-indian-rupee'></i>" + FormatCurrency(netPft) + "</h4>");
                    }
                }
                var inputListForAverge = $(incomeDiv).find(".form-controls input[comppk='" + compPK + "']");
                var avgval = 0;
                var cnt = 0;
                // Get average of the Entered Row
                $(inputListForAverge).each(function () {
                    if ($(this).attr("isperc") != "1" && $(this).attr("isperc") != 1) {
                        var val = parseInt(FormatCleanComma($(this).val()));
                        val = val ? val : 0;
                        avgval += val;
                        cnt++;
                    }
                });
                if (avgval != 0) {
                    avgval = Math.round(avgval / cnt);
                    // Set the avg Original value to avg column textbox
                    $(incomeDiv).find(".avgcol input[comppk='" + compPK + "']").attr("OrgVal", FormatCurrency(avgval));
                    // Set the avg - Percantge value to avg column textbox
                    avgval = Math.round(avgval * perc / 100);
                    $(avgCol).find("input[comppk='" + compPK + "']").val(FormatCurrency(avgval));
                }
                else {
                    $(avgCol).find("input[comppk='" + compPK + "']").val(0);
                }                

                // Set the Average Total to Average total and average Heading                    
                var AvgULTotal = 0;
                inputcount = 0;



                var TotalAvgInput = $(incomeDiv).find(".form-controls input[addless=3]");
                var avgval = 0;
                var cnt = 0;
                // Get average of the Entered Row
                $(TotalAvgInput).each(function () {
                    if ($(this).attr("isperc") != "1" && $(this).attr("isperc") != 1) {
                        var val = parseInt(FormatCleanComma($(this).val()));
                        val = val ? val : 0;
                        avgval += val;
                        cnt++;
                    }
                });
                if (avgval != 0) {
                    avgval = Math.round(avgval / cnt);
                    // Set the avg Original value to avg column textbox
                    // Set the avg - Percantge value to avg column textbox
                    avgval = Math.round(avgval * perc / 100);
                    $(avgCol).find("input[addless=3]").val(FormatCurrency(avgval));
                }
                else {
                    $(avgCol).find("input[addless=3]").val(0);
                }

                AvgULTotal = avgval || 0;

                AvgULTotal = Math.round(AvgULTotal);
                $(avgCol).find("li.amount input[addless='3']").val(FormatCurrency(AvgULTotal));

                var avgHead = $(curLi).find("h4");
                $(avgCol).find("h4").html("<i class='icon-indian-rupee'></i>" + FormatCurrency(AvgULTotal) + "");
                var avgHeadTxt = "<i class='icon-indian-rupee'></i>" + FormatCurrency(AvgULTotal) + "";
                $(avgHead).html(avgHeadTxt);
            }
            else if (divClass == "customer-other") {
                var isOther = false;
                if ($(elem).attr("addless") == "other") {
                    isOther = true;
                    var selectedval = $(IncomeUL).find(".period").getVal();
                    if (!selectedval || selectedval == "" || selectedval == "-1") {
                        fnShflAlert("error", "select period - Others ");
                        $(elem).val("");
                        return;
                    }
                }

                var oTherDiv = $(elem).closest(".grid-type.div-left").find(".form-controls");
                var otherLength = $(oTherDiv).find("[addless='other']").length;
                var OtherAmt = 0;
                if (otherLength > 0) {
                    $(oTherDiv).find("[addless='other']").each(function () {
                        var value = parseInt(FormatCleanComma($(this).val()));
                        var Otherperc = $(this).closest(".form-controls").find("input[isother]").val();
                        var YorM = $(this).closest(".form-controls").find(".period.select-focus").getVal()
                        value = parseInt(value).toString() == "NaN" ? 0 : parseInt(value);
                        if (YorM == "0") { value = Math.round(value / 12); }
                        value = Math.round(value * Otherperc / 100);
                        OtherAmt = OtherAmt + value;
                    });
                    OtherAmt = Math.round(OtherAmt);
                    $(curLi).find(".totalAvgAmt").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(OtherAmt));
                }
                else { $(curLi).find(".totalAvgAmt").html('<i class="icon-indian-rupee"></i> 0 '); }

            }


            // Set Grand total of salary to Applicant summary - COMMON
            var SalaryTotal = 0;
            $(UlList).find("li").not(".li-icon-plus").each(function () {
                var isConsider = $(this).find("[name='onoffswitch']").is(":checked");
                if (isConsider) {
                    var val = Number(FormatCleanComma($(this).find("h4").justtext()));
                    val = val ? val : 0;
                    SalaryTotal = SalaryTotal + val;
                }
            });
            SalaryTotal = Math.round(SalaryTotal);
            // set total Income to Applicant Summary
            $("#Brnch_summary.applicant-summary .applicant-box[appfk='" + AppPk + "']").find(".income-amount").html(
                "<i class='icon-indian-rupee'></i>" + FormatCurrency(SalaryTotal));

            var totalIncome = 0;
            $("#Brnch_summary.applicant-summary .applicant-box[appfk]").each(function () {
                totalIncome += Number(FormatCleanComma($(this).find(".income-amount").justtext())) || 0;
            });
            $("#totalIncome").html("<i class='icon-indian-rupee'></i>" + FormatCurrency(totalIncome));
        }
    }
    catch (e) {
        console.log(e);
        console.log(divClass);
    }
}


function fnToggleFreezeNHB() {
    var val = $("#NHBapplicable").val();
    var Ponterstyle = "auto";
    var select2 = true;
    if (val == "0")
    {
        Ponterstyle = "none"; select2 = true;
        $("#txtloccd").closest("span").find("comp-help").find("[name = 'helptext']").attr("readonly", true);
    }
    else
    {
        Ponterstyle = "auto"; select2 = false;
        $("#txtloccd").closest("span").find("comp-help").find("[name = 'helptext']").attr("readonly", false);
    }

    $('#NHBpuccahouse').select2({
        minimumResultsForSearch: -1,
        disabled: select2
    });
    $('#NHBcatogory').select2({
        minimumResultsForSearch: -1,
        disabled: select2
    });

    document.getElementById('NHBpuccahouse').style.pointerEvents = Ponterstyle;
    document.getElementById('NHBcatogory').style.pointerEvents = Ponterstyle;
    document.getElementById('txtlocnm').style.pointerEvents = Ponterstyle;
    document.getElementById('txthouseaninc').style.pointerEvents = Ponterstyle;
    document.getElementById('txtloccd').style.pointerEvents = Ponterstyle;
    document.getElementById('NHbDepdAdd').style.pointerEvents = Ponterstyle;
 
}

function fnPDattachMent(elem) {
    var savePth = "SHFL_DOCS/REPORTS/" + CustFinGlobal[0].LeadPk + "/";
    fnUploadReport(elem, 'PD_UPLOAD', savePth, fnCustFinResult);
}

function fnUploadReport(FileELEM, Action, savePath, callback, Param1, Param2) {
    var ELEM = $(FileELEM).get(0);
    var files = ELEM.files;
    if (files.length == 0) { return; }
    var UploadObj = new FormData();
    UploadObj.append("Action", "ReportUpload");
    UploadObj.append("savePath", savePath);
    for (var i = 0; i < files.length; i++) {
        UploadObj.append("file_" + i, files[i]);
    }
    fnLosCallFileUploadService(Action, UploadObj, callback, Param1, Param2);
}


function fnAddExitingLoanRow() {
    var ulLength = $("#LoanExist").find("#ExistingLoanUL ul.form-controls").length;
    if (ulLength >= 1)
    { fnShflAlert("warning", "Should not allow Multiple Rows."); return; }

    var PrdCode = $(".category-icons").find("li:nth-child(1) i").attr("prdcode");
    var RefUl = '';
    if (PrdCode.toUpperCase() == "HLTOPUP" || PrdCode.toUpperCase() == "HLEXT" || PrdCode.toUpperCase() == "HLIMP" || PrdCode.toUpperCase() == "LAPTOPUP") {
        RefUl += ' <comp-help id="comp-help" class="RefNo" txtcol="RefLoanNo" valcol="Loanpk" onrowclick="Loanclick" prcname="PrcShflRefNohelp" width="100%" LoanPk = "0" LoanNo = "" Extraparam = ' + param + '></comp-help>'
    } else {
        RefUl += '<input label="Reference Number" class="RefNo" type="text" placeholder="">'
    }
    var ul = ' <ul class="form-controls">' +
            '<li class="width-12">' +
            '   <input label="Bank/Insitution Name" class="bnkInsName" type="text" placeholder="" value="">' +
            '</li>' +
            '<li class="width-12 Bc_Reference">' +
                RefUl +
            '</li>' +
            '<li class="width-12 amount">' +
            '   <span>' +
            '       <i class="icon-indian-rupee"></i>' +
            '       <input label="Existing Loan Amount " class="LoanAmt currency" onkeypress="return fnNumberKeyPress(event,this);" type="text" placeholder="" value="">' +
            '   </span>' +
            '</li>' +
            '<li class="width-12 amount">' +
            '   <span>' +
            '       <input label="Remaining Tenure" class="LoanTenure" onkeypress="return fnNumberKeyPress(event,this);" type="text" placeholder="" value="">' +
            '   </span>' +
            '</li>' +
            '<li>' +
            '   <i class="icon-close" onclick="fnCloseExLoan(this)"></i>' +
            '</li>' +
            '   </ul>';
    $("#ExistingLoanUL").append(ul);
}

function fnCloseExLoan(elem) {
    $(elem).closest("ul.form-controls").remove();
}

function fnGetExistingLoanDetails() {

    var details = [];
    try {
        var err = "";
        var PrdCode = $(".category-icons").find("li:nth-child(1) i").attr("prdcode");
        $("#ExistingLoanUL ul.form-controls").each(function () {
            var RefNo;
            if (PrdCode.toUpperCase() == "HLTOPUP" || PrdCode.toUpperCase() == "HLEXT" || PrdCode.toUpperCase() == "HLIMP" || PrdCode.toUpperCase() == "LAPTOPUP") {
                RefNo = $(this).find("comp-help").find("input[name='helptext']").val();
            }
            else {
                RefNo = $(this).find("input[class='RefNo']").val();
            }
            var bnkNm = $(this).find("input[class='bnkInsName']").val();

            //var LoanAmt =$(this).find("input[class='LoanAmt']").val();
            var LoanAmt = FormatCleanComma($(this).find(".LoanAmt").val())
            var LoanTenure = $(this).find("input[class='LoanTenure']").val();


            if (bnkNm.trim() == "" || RefNo.trim() == "" || LoanAmt.trim() == "" || LoanTenure.trim() == "")
                err = "Enter All details of Existing Loan";
            details.push({ bank: bnkNm, RefNo: RefNo, amount: LoanAmt, tenure: LoanTenure });
        });
    }
    catch (e) {
        details = [];
    }
    if (err != "")
        details = { ERROR: err };

    return details;
}


function fnAddExistLn(data) {

    if (!data && data.length > 0)
        return;
    $("#ExistingLoanUL").empty();
    var ul = '';
    var PrdCode = $(".category-icons").find("li:nth-child(1) i").attr("prdcode");

    for (var i = 0; i < data.length; i++) {
        var RefUl = '';
        if (PrdCode.toUpperCase() == "HLTOPUP" || PrdCode.toUpperCase() == "HLEXT" || PrdCode.toUpperCase() == "HLIMP" || PrdCode.toUpperCase() == "LAPTOPUP") {
            RefUl += ' <comp-help id="comp-help" txtcol="RefLoanNo" valcol="Loanpk" onrowclick="Loanclick" prcname="PrcShflRefNohelp" width="100%" LoanPk = "0" LoanNo = "' + data[i].RefNo + '" Extraparam = ' + param + '></comp-help>'

        } else {
            RefUl += '<input label="Reference Number" class="RefNo" type="text" placeholder="" value="' + data[i].RefNo + '">'
        }
        ul += ' <ul class="form-controls existhelp" pk="' + data[i].Pk + '">' +
            '<li class="width-12">' +
            '   <input label="Bank/Insitution Name" class="bnkInsName" type="text" placeholder="" value="' + data[i].BankNm + '">' +
            '</li>' +
            '<li class="width-12">' +
            RefUl +
            //'   <input label="Reference Number" class="RefNo" type="text" placeholder="" value="' + data[i].RefNo + '">' +
            '</li>' +
            '<li class="width-12 amount">' +
            '   <span>' +
            '       <i class="icon-indian-rupee"></i>' +
            '       <input label="Existing Loan amount" class="LoanAmt currency" onkeypress="return fnNumberKeyPress(event,this);" type="text" placeholder="" value="' +
            FormatCurrency(data[i].Amount) + '" />' +
            '   </span>' +
            '</li>' +
             '<li class="width-12 amount">' +
            '   <span>' +
            '       <input label="Remaining Tenure" class="LoanTenure" onkeypress="return fnNumberKeyPress(event,this);" type="text" placeholder="" value="' +
            data[i].remaining + '" />' +
            '   </span>' +
            '</li>' +
            '<li>' +
            '   <i class="icon-close" onclick="fnCloseExLoan(this)"></i>' +
            '</li>' +
            '   </ul>';
    }
    $("#ExistingLoanUL").append(ul);
    $("#ExistingLoanUL").find("ul").each(function () {
        var loanNo = $(this).find("comp-help").attr("LoanNo");
        $(this).find("comp-help").find("input[name='helptext']").val(loanNo);
    });


}
function fnAddRefDetails(ReferenceData) {

    if (!ReferenceData && ReferenceData.length > 0)
        return;
    var refUl = ''
    var clsNm;
    var bg;
    for (var k = 0; k < ReferenceData.length; k++) {
        clsNm = ReferenceData[k].RefSts == 0 ? "icon-negative" : "icon-positive"
        bg = ReferenceData[k].RefSts == 0 ? "bg2" : "bg1"
        refUl += ' <ul class="form-controls" LarPk="' + ReferenceData[k].LarPk + '">' +
            '<li class="width-12">' +
            '   <input label="Reference Name" class="RefName" type="text" placeholder="" value="' + ReferenceData[k].ReferNm + '" readonly>' +
            '</li>' +
            '<li class="width-11">' +
            '   <input label="Mobile No" class="RefMobNo" type="text" placeholder="" value="' + ReferenceData[k].RefMobNo + '" readonly>' +
            '</li>' +
            '<li class="width-12">' +
            '   <input label="Office No" class="RefOffNo" type="text" placeholder="" value="' + ReferenceData[k].RefOffNo + '" readonly>' +
            '</li>' +
            '<li class="width-12">' +
            '   <input label="Residence No" class="RefResiNo" type="text" placeholder="" value="' + ReferenceData[k].RefTeleNo + '"readonly>' +
            '</li>' +
            '<li class="width-11  align-center">' +
            '<i name="Notes" txtval="' + ReferenceData[k].Summary + '" class="icon-chat-o"></i> ' +
            //'   <input label="Summary" class="RefSummary" type="text" placeholder="" maxlength="100" value="' + ReferenceData[k].Summary + '">' +
            '</li>' +
            '<li class="width-6 status status-small">' +
            '<p class="bg ' + bg + '"><i class="' + clsNm + '" id="rptsts_ref" onclick="fnRefReprtSts(this);"></i></p>' +
            '   <input label="Status" type="hidden" class="RefSts" type="text" placeholder="" value="' + ReferenceData[k].RefSts + '">' +
            '</li>' +
            '</ul>';
    }
    $("#ReferenceDiv").append(refUl);
}


function fnBnkclick(rowjson, comp) {
    $(comp).closest(".form-controls").find("#branch-help").attr("helpfk", rowjson.Bankpk);
}

function fnBrnchclick(rowjson, comp) {

}
function fnAgentspopup_BC(elem) {
    if ($(elem).hasClass("bg8")) {
        return;
    }

    var scrname = ''
    $('#agent_load_div_BC').empty(); flag = 1; lapfk = 0; ServiceType = -1;
    lapfk = $(elem).parent("div.appliant-verifications").attr("LapFk");
    scrname = $(elem).attr("name");
    if (scrname == "FIR") {
        ServiceType = 0;
        $("#agent_load_div_BC").load("field-investigation.html");
        $("#agents-popup-BC").show();

    }
    if (scrname == "FIO") {
        ServiceType = 1;
        $("#agent_load_div_BC").load("field-investigation.html");
        $("#agents-popup-BC").show();

    }
    if (scrname == "DV") {
        ServiceType = 2;
        $("#agent_load_div_BC").load("document-verification.html");
        $("#agents-popup-BC").show();

    }
    if (scrname == "CF") {
        ServiceType = 3;
        $("#agent_load_div_BC").load("field-investigation.html");
        $("#agents-popup-BC").show();

    }
    if (scrname == "LV") {
        ServiceType = 4;
        $("#agent_load_div_BC").load("LegalManager.html");
        $("#agents-popup-BC").show();

    }
    if (scrname == "TV") {
        ServiceType = 5;
        $("#agent_load_div_BC").load("technical-Manager.html");
        $("#agents-popup-BC").show();
    }
    GlobalXml[0].ServiceType = ServiceType;
}

$(document).on("keydown", '.Business_DoF,.incomeperiod', function (e) {

    var key = e.keyCode || e.which;
    if ($(this).text().length <= 12 || key == 8 || key == 37 || key == 39 || key == 46 || key == 9) {
        return true;
    } else {
        return false;
    }
});
function fnRefReprtSts(elem) {

    var cls = $(elem).attr("class");
    var lihtml = $(elem).closest("li.status-small");
    if (cls == "icon-positive") {
        $(lihtml).find("p.bg").attr("class", "bg bg2");
        $(lihtml).find("i").attr("class", "icon-negative");
        $(lihtml).find(".RefSts").val(0);
    }
    else if (cls == "icon-negative") {
        $(lihtml).find("p.bg").attr("class", "bg bg1");
        $(lihtml).find("i").attr("class", "icon-positive");
        $(lihtml).find(".RefSts").val(2);
    }
    //else if (cls == "icon-no-status") {
    //    $(lihtml).find("p.bg").attr("class", "bg bg1");
    //    $(lihtml).find("i").attr("class", "icon-positive");
    //    $(lihtml).find("input[key=agt_rptstatus]").val(2);
    //    $(lihtml).find("input[colkey=agt_DocSts]").val(2);
    //}
}

function fnGetReferenceDetails() {

    var Refdetails = [];
    $("#ReferenceDiv ul.form-controls").each(function () {
        var RefSummary = $(this).find("[name='Notes']").attr("txtval");
        var RefSts = $(this).find("input[class='RefSts']").val();
        var RefPk = $(this).attr("LarPk");
        Refdetails.push({ Summary: RefSummary, Status: RefSts, refFk: RefPk });
    });
    return Refdetails;

}
function fnsetPropInfo() {
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SelectPropDetails", JSON.stringify(CustFinGlobal)] };
    fnCallLOSWebService("SelectPropDetails", PrcObj, fnCustFinResult, "MULTI");

}
function fnSetPropDetails(PropAddressData) {

    if (!(PropAddressData.length > 0))
    { fnShflAlert("error", "No Property Details Available !!"); return; }
    else {
        var PropUl = ''
        $("#PropDiv_BC").empty();
        for (var i = 0; i < PropAddressData.length; i++) {
            PropUl += '<div class="div-left grid-50">' +
                      '<h2>Property Address : ' + (i + 1) + '</h2>' +
                        '<ul PropPk="' + PropAddressData[i].prp_pk + '" class="form-controls">' +
                    ' <li class="width-21">' +
                        '<label>Nearest Branch</label>' +
                                //'<input name="nrstBranch" type = "text" maxlength="100"value = "' + PropAddressData[i].PrpBranch + '"/>' +
                                ' <comp-help id="comp-help" txtcol="Location" valcol="Brnchpk" helpfk="0" onrowclick="Bc_Brnchclick" connect="bpm" prcname="PrcShflleadBranchhelp" width="100%"></comp-help>' +
                                        '<input type="hidden" placeholder="" name="text"key="BC_Prop_branch" restrict="alphaspace" maxlength="100" value = "' + PropAddressData[i].PrpBranch + '">' +
                    '</li>' +
                            ' <li class="width-21">' +
                        '<label>Distance</label>' +
                        '<input name="Distance" type="text" restrict = "number"maxlength="20" value ="' + PropAddressData[i].PrpDistance + '"/>' +
                                '<span class="kilometer">KM</span>' +
                    '</li>' +
                        '</ul>' +
                      '</div>' +
                      '<div class="div-right grid-50">' +
                            '<p>' + PropAddressData[i].Prpdoorno + ',' + ' ' + PropAddressData[i].Prpbuilding + '</p>' +
                            '<p>' + PropAddressData[i].Prpplotno + ',' + ' ' + PropAddressData[i].Prpstreet + '</p>' +
                            '<p>' + PropAddressData[i].Prparea + ',' + ' ' + PropAddressData[i].Prplandmark + '</p>' +
                            '<p>' + PropAddressData[i].Prpdistrict + ',' + ' ' + PropAddressData[i].Prpstate + '</p>' +
                            '<p>' + PropAddressData[i].Prpcountry + '</p>' + ' ' + PropAddressData[i].Prppincode + '</p>' +
                        '</div>' +
                      '<div class="clear"></div>' +
            '<div></br></div>'
        }
        $("#PropDiv_BC").append(PropUl);
        $("#PropDiv_BC").find("ul.form-controls").each(function () {
            $(this).find("comp-help").find("[name='helptext']").val($(this).find("[key = 'BC_Prop_branch']").val());
        });
        $("#Prop_Popup_BC").show();
    }
}
function fnConfirmProp() {
    var Propdetails = [];
    $("#PropDiv_BC ul.form-controls").each(function () {
        var PropBranch = $(this).find("comp-help").find("[name='helptext']").val();
        var PropDistance = $(this).find("input[name='Distance']").val();
        var PropFk = $(this).attr("PropPk");
        Propdetails.push({ NrBranch: PropBranch, Distance: PropDistance, PropPk: PropFk });
    });
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["UPDATE_PROP_DET", JSON.stringify(CustFinGlobal), "", "", "", "", JSON.stringify(Propdetails)] };
    fnCallLOSWebService("UPDATE_PROP_DET", PrcObj, fnCustFinResult, "MULTI");
}

//Geetha
function fnOpenPrpslInfo() {
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["GetPrpslInfo", JSON.stringify(CustFinGlobal), "", "", "", "", "", ""] };
    fnCallLOSWebService("GetPrpslInfo", PrcObj, fnCustFinResult, "MULTI");
}

function fnConfirmPrpslInfo() {
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SavePrpslInfo", JSON.stringify(CustFinGlobal), "", "", "", "", "", CKEDITOR.instances['editor'].getData()] };
    fnCallLOSWebService("SavePrpslInfo", PrcObj, fnCustFinResult, "MULTI");
}

function editortooldisable() {    
    $('#cke_16').prop('style', 'display:none');//Source
    $('#cke_17').prop('style', 'display:none');//Save   
    $('#cke_18').prop('style', 'display:none');//Newpage
    $('#cke_26').prop('style', 'display:none');//Template
    $('#cke_36').prop('style', 'display:none');//Form
    $('#cke_37').prop('style', 'display:none');//CheckBox
    $('#cke_38').prop('style', 'display:none');//RadioButton
    $('#cke_39').prop('style', 'display:none');//TextField
    $('#cke_40').prop('style', 'display:none');//TextArea
    $('#cke_41').prop('style', 'display:none');//SelectionField
    $('#cke_42').prop('style', 'display:none');//Button
    $('#cke_43').prop('style', 'display:none');//ImageButton
    $('#cke_44').prop('style', 'display:none');//Hiddenfield
    $('#cke_58').prop('style', 'display:none');//BlockQuote
    $('#cke_59').prop('style', 'display:none');//DivContainer
    $('#cke_64').prop('style', 'display:none');//LeftIndent
    $('#cke_65').prop('style', 'display:none');//RightIndent
    $('#cke_66').prop('style', 'display:none');//Language
    $('#cke_68').prop('style', 'display:none');//Link
    $('#cke_69').prop('style', 'display:none');//Unlink
    $('#cke_70').prop('style', 'display:none');//Anchor
    $('#cke_73').prop('style', 'display:none');//Flash
    $('#cke_76').prop('style', 'display:none');//Smiley  
    $('#cke_77').prop('style', 'display:none');//Special Char  
    $('#cke_78').prop('style', 'display:none');//PageBreak for printing  
    $('#cke_79').prop('style', 'display:none');//Iframe  
    $('#cke_86').prop('style', 'display:none');//ShowBlocks  
    $('#cke_87').prop('style', 'display:none');//About CKeditor  
    $('#cke_72').prop('style', 'display:none');//Image
}

function fnSelectCreditDet() {
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SELECT_CREDIT_DTLS", JSON.stringify(CustFinGlobal), "", "", "", "", "", ""] };
    fnCallLOSWebService("SELECT_CREDIT_DTLS", PrcObj, fnCustFinResult, "MULTI");
}

function fnPFTax() {
    $("#CApf").show();
    $("#spn_title").html("PF Received Details");
    fnselectPFdetails();

}

function fnselectPFdetails() {
    var taxGlobal = [{}];
    taxGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["CREDIT_TAX", JSON.stringify(taxGlobal)] };
    fnCallLOSWebService("TAX", PrcObj, fnCustFinResult, "MULTI");
}
/*  MANUAL DEVIATION WORKS */



function fnSaveManualDevBC() {
    fnSaveManualDeviation('DeviationDataDiv', 'C', fnCustFinResult, 'ADD_MANUALDEV',CustFinGlobal);
}


function fnSelectManualDeviationData() {
    var PrcObj = { ProcedureName: "PrcShflManualDeviation", Type: "SP", Parameters: ["MANUALDEV_DATA", JSON.stringify(CustFinGlobal), "","C"] };
    fnCallLOSWebService("MANUALDEV_DATA", PrcObj, fnCustFinResult, "MULTI");
}

/*  MANUAL DEVIATION WORKS */

/*NHB Location Code Help*/

function NHBLocRowclick(rowjson)
{
    $("#txtlocnm").val(rowjson.LocNm);
    $("#txtloccd").val(rowjson.LocCd);
}

var toolbar_less = [
    { name: 'clipboard', items: ['Undo', 'Redo'] },
    { name: 'editing', items: ['Format', 'FontSize', 'TextColor', 'BGColor', 'Bold', 'Italic', 'Underline', 'Strike', '-', 'RemoveFormat'] },
    { name: 'paragraph', items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl'] },
    { name: 'tools', items: ['Maximize'] }
];

function fnReplaceEditor(id) {    
    CKEDITOR.disableAutoInline = true;
    CKEDITOR.replace(id, {
        toolbar: toolbar_less
    });
}