// JavaScript Document

//function to fix height of iframe!
var calcHeight = function () {
    var WindowHeight = $(window).height();
    $('.left-panel ul').css({ 'height': WindowHeight - 45 + 'px' });
    var toppanelheight = $('.top-panel').outerHeight();
    var titlelheight = $('.title').outerHeight();
    var sublheight = $('.dashboard-div .grid-33 h2,.dashboard-div .grid-50 h2,.dashboard-div h2').outerHeight();
    var bottombtns = $('.form-btns').outerHeight();
    //$('.content-height').css({ 'height': WindowHeight - 105 + 'px' });
    // var dashboardbox = $('.dashboard-div .box-div').css('margin');
    $('.right-panel .display-table').css({ 'height': WindowHeight - 50 + 'px' });
    $('.roles-div-height').css({ 'height': WindowHeight - toppanelheight - 0 + 'px' });
    $('.content-div, #div-document-content').css({ 'height': WindowHeight - toppanelheight - titlelheight - bottombtns - 0 + 'px' });
    $('.content-div .dashboard-div .box-div, .content-div .dashboard-div .query_box-div, .content-div .dashboard-div .box-div.cases-login').css({ 'height': WindowHeight - toppanelheight - titlelheight - sublheight - bottombtns - 16 + 'px' });
	$('.content-div .dashboard-div .box-div.agent-box-div').css({ 'height': WindowHeight - toppanelheight - titlelheight - sublheight - bottombtns - 260 + 'px' });
    $('.right-height').css({ 'height': WindowHeight - 20 + 'px' });
    $('.query-height').css({ 'height': WindowHeight - 60 + 'px' });
    $('.div-half-height .query_box-div').height($('.div-half-height').outerHeight() / 4 - sublheight);
    $('.div-half-height .dashboard-title .box-div').height($('.div-half-height').outerHeight() / 4 - sublheight);
}

function customfocus() {

    $(document).on("focus", ".autofill", function () {
        $(this).siblings(".autofill-border").show();
    });

    $(document).on("focusout", ".autofill,.select-focus .icon-down-arrow", function () {
        var Prt_obj = $(this).parent();
        $(Prt_obj).find(".autofill-border").hide();
        setTimeout(function () { $(Prt_obj).find(".custom-select").hide(); }, 200);
    });

    $(document).on("keydown", ".autofill", function (e) {
        var selected = $(this).siblings(".custom-select").children("li.selected");

        if (e.keyCode == 13) { // enter
            if ($(this).siblings(".custom-select").is(":visible")) {
                selectOption(selected);
            } else {
                $(this).siblings(".custom-select").show();
            }
        }
        if (e.keyCode == 38) { // up
            $(this).siblings(".custom-select").children("li").removeClass("selected");
            if (selected.prev().length == 0) {
                selected.siblings().last().addClass("selected");
            } else {
                selected.prev().addClass("selected");
            }
        }
        if (e.keyCode == 40) { // down
            $(this).siblings(".custom-select").children("li").removeClass("selected");
            if (selected.next().length == 0) {
                selected.siblings().first().addClass("selected");
            } else {
                selected.next().addClass("selected");
            }
        }
    });

    $(document).on("click", ".custom-select li", function () {
        selectOption($(this));
    });

    $(document).on("mouseover", ".custom-select li", function () {
        $(this).parent(".custom-select").children("li").removeClass("selected");
        $(this).addClass("selected");
    });


    $(document).on("click", ".autofill,.select-focus .icon-down-arrow", function () {
        $(this).parent().find(".custom-select").toggle();
    });


    function selectOption(selObj) {
        var PrevVal = $(selObj).parent().siblings(".autofill").val();
        $(selObj).parent().siblings(".autofill").val($(selObj).text());

        if (PrevVal != $(selObj).text())
            setTimeout(function () {
                $(selObj).parent().siblings(".autofill").trigger("change");
            },300) 

        $(selObj).parent().siblings(".autofill").attr("selval", $(selObj).attr("val"));
        $(selObj).closest(".select-focus .custom-select").hide();
    }
}

function selectfocus() {
    try {
        $('.select').select2({
            minimumResultsForSearch: -1
        });
        $(".select").each(function () {
            if ($(this).val() == null || $(this).val() == undefined || $(this).val() == "")
                $(this).val($(this).children().eq(0).val()).trigger('change.select2');
                //$(this).val($(this).children().eq(0).val());
        })
    }
    catch (e) {
        console.log(e);
    }
}

function fnInitiateSelect(id, IsClass) {
    /*
    try {
        $("#qde_div_content_" + (qde_MaxTabNo) + " .select").select2('destroy');
    }
    catch (e) {
        console.log(e);
    }

    */
    var AppendOperator = "#";
    if (IsClass == 1) { AppendOperator = "." }

    $(AppendOperator + id + " select.select").removeClass("select2-hidden-accessible");
    $(AppendOperator + id + " .select2-container").remove();
    $(AppendOperator + id + " select.select").select2({ minimumResultsForSearch: -1 });
    $(AppendOperator + id + " .select2-container").css("display", "block");
    $(AppendOperator + id + " .select").each(function () {
        if ($(this).val() == null || $(this).val() == undefined || $(this).val() == "")
            $(this).val($(this).children().eq(0).val()).trigger('change.select2');
           // $(this).val($(this).children().eq(0).val());
    })
}

function guid() {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
          .toString(16)
          .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
      s4() + '-' + s4() + s4() + s4();
}

function fnAddNormalSelectOptions(optns, id, Flg) {
    var options = JSON.parse(optns);
    var op = "";
    for (var i = 0; i < options.length; i++) {
        if (i == 0 && Flg == 0)
            op += "<option>--SELECT--</option>";
        op += "<option>" + options[i] + "</option>";
    }
    $(id).append(op);
}

function commontabs() {
    $(".common-tabs-active li").click(function (e) {
        $(this).addClass('active');
        $(this).siblings().removeClass('active');
    });
    /*for(var n=1; n<10; n++){
		}*/
    $(".tab1").click(function (e) {
        $(".tab1-content").show().siblings().hide();
    });
    $(".tab2").click(function (e) {
        $(".tab2-content").show().siblings().hide();
    });
    $(".tab3").click(function (e) {
        $(".tab3-content").show().siblings().hide();
    });
    $(".tab4").click(function (e) {
        $(".tab4-content").show().siblings().hide();
    });
    $(".tab5").click(function (e) {
        $(".tab5-content").show().siblings().hide();
    });
    $(".tab6").click(function (e) {
        $(".tab6-content").show().siblings().hide();
    });
    $(".tab7").click(function (e) {
        $(".tab7-content").show().siblings().hide();
    });
    $(".tab8").click(function (e) {
        $(".tab8-content").show().siblings().hide();
    });
    $(".tab9").click(function (e) {
        $(".tab9-content").show().siblings().hide();
    });
    $(".tab10").click(function (e) {
        $(".tab10-content").show().siblings().hide();
    });
}

function commonquery() {
    $(".query-box .query-info i.icon-down-arrow").click(function (e) {
        $(this).parents('.query-box').children('.query-detail').toggle();
        $(this).parents('.query-box').siblings().children('.query-detail').hide();
    });
}

function comment() {
    $(".query-detail .icon-reply").click(function (e) {
        $(this).parents('.query-detail').children(".comment-div").toggle();
    });
}
function query() {
    commonquery();
    comment();
}

function fnDrawDatePicker() {
    $(".datepicker").each(function () {

       // try { alert(""); $(this).datepicker("destroy"); } catch (e) { }
        $(this).datepicker({
            changeMonth: true,
            changeYear: true,
            dateFormat: "dd/mm/yy",
            yearRange: '1900:1998',
            defaultDate: '01/01/1998'
        });
    });
}

function fnDrawDefaultDatePicker() {
    $(".datepickerdef").each(function () {

        // try { alert(""); $(this).datepicker("destroy"); } catch (e) { }
        $(this).datepicker({
            changeMonth: true,
            changeYear: true,
            dateFormat: "dd/mm/yy"
        });
    });
}

function popupclose() {

    $(document).on("click", ".popup-header .icon-close, .doc-view", function () {
        $(this).closest(".popup-bg").hide();
    });

   // $(".popup-header .icon-close, .doc-view").click(function (e) {
      //  $(".popup-bg").hide();
   // });
}

function querypopup() {
    //$(".right-query-content i.icon-plus,.subjective-div i.icon-plus,.property-sum .icon-warning").click(function (e) {
    //    $("#subjective-div").show();
    //});
}

/*Product or category popup*/
function categoryPopup() {

    $(".category-icon").click(function () {
        $(".category-popup").show();
        try { fnonpopopen($(this)); } catch (e) { }
        popupclose();
    });

    $(".category-div li").css('', 'pointer');
    $(document).on("click", ".category-div li", function (e) {
        e.stopImmediatePropagation();
        $(this).addClass("active").siblings().removeClass("active");
        try { fnonclick($(this)); } catch (e) { }
    });
}
/*Scan or Attach click*/
function scanAttachClick() {
    $(".attach-click").click(function (e) {
        $(".document-attach").show();
        $(".document-attach").siblings().not(".clear").hide();        
    });
    $(".scan-click").click(function (e) {
        $(".scand-document").show();
        $(".scand-document").siblings().not(".clear").hide();
    });
    $(".document-attach .icon-close, .scand-document .icon-close").click(function (e) {
        $(".document-entry").show();
        $(".document-entry").siblings().not(".clear").hide();
    });
}
/*Scan or Attach click End*/
/*Scand or Attached Document image Preview*/
function scanDocPreview() {
    $(".image-preview-option .icon-document").click(function (e) {
        $("ul.thumbnail").toggle();
    });

    $(".image-preview-option .icon-expand").click(function (e) {
        $(this).toggleClass('icon-collapse');
        $(".image-div").toggleClass('expand-div');
    });

    $(".image-preview-option .icon-close").click(function (e) {
        $("#div-document-content").hide();
        $(".content-div").removeClass('center-collapse');
    });
}

function rightdocument() {
    $(".lead-information .icon-document").click(function (e) {
        $(".document-pop-content").show();
    });
}


function categoryinfo() {
    $(".category-info .category-icons").click(function (e) {
        $("#category-div").show();
    });
}

function LoadHtmlDiv(HtmlPage) {
    var versionNo = "?$$$v=1.0.3$$$"
    if (HtmlPage.indexOf("v=") == -1) {
        HtmlPage = HtmlPage + versionNo;
    }
    $("#div-user-content").empty();
    $("#div-user-content").attr("pagename", HtmlPage);
    $("#div-user-content").load(HtmlPage);
}

function LoadHtmlDivSer(HtmlPage) {
    $("#div-user-content").empty();
    $("#div-user-content").load(SerUrlDomain + "/" + HtmlPage);
}

function fnSetGridVal(FormId, divId, Data) {
    if (Data.length <= 0)
        return;

    var keyArr = Object.keys(Data[0]);

    if (divId == "") { LoopGrid = $("." + FormId + " .rowGrid"); }
    else { LoopGrid = $("#" + divId).find("." + FormId + " .rowGrid"); }
    var j = 0;

    LoopGrid.each(function () {
        if (j < Data.length) {
            for (var i = 0; i < keyArr.length; i++) {
                var TgtObj = $(this).find("[colkey=" + keyArr[i] + "]");
                var inp_type = $(TgtObj).attr("name");

                if (inp_type == "text") {
                    if ($(TgtObj).hasClass("currency")) {
                        var val = Data[j][keyArr[i]].toString();
                        $(TgtObj).val(FormatCurrency(val));
                    }
                    else
                        $(TgtObj).val(Data[j][keyArr[i]]);

                }
                else if (inp_type == "select") {
                    $(TgtObj).attr("selval", Data[j][keyArr[i]]);

                    $(TgtObj).siblings("ul").children("li").each(function () {
                        if ($(TgtObj).attr("selval") == $(this).attr("val")) {
                            $(TgtObj).val($(this).html());
                        }
                    });
                }
                else if (inp_type == "select2") {
                    $(TgtObj).val(Data[j][keyArr[i]]).trigger("change.select2");
                    $(TgtObj).val(Data[j][keyArr[i]]);
                }
                else if (inp_type == "checkbox") {
                    if (Data[j][keyArr[i]] == 0) {
                        $(TgtObj).prop("checked", true);
                    }
                    else {
                        $(TgtObj).prop("checked", false);
                    }
                }
            }
        }
        j++;
    });
}

function fnGetGridVal(FormId, divId) {
    debugger;
    var RtnGridJson = [];
    var ErrMsg = "";

    if (divId == "") { LoopGrid = $("." + FormId + " .rowGrid"); }
    else { LoopGrid = $("#" + divId).find("." + FormId + " .rowGrid"); }

    LoopGrid.each(function () {

        var RtnObj = {}; var key = ""; var IsRowValInserted = 0;
        var thisChild = $(this).find("[colkey]");

        $(thisChild).each(function () {

            if ($(this).attr("name") == "text") {
                var AssignVal = 0;
                key = $(this).attr("colkey");
                RtnObj[key] = "";
                AssignVal = $(this).val().trim();

                if (AssignVal == "") {
                    if ($(this).is("[value]") && IsRowValInserted == 1)
                        AssignVal = $(this).attr("value");
                }
                if (AssignVal != "") {
                    if (IsRowValInserted == 0) IsRowValInserted = 1;

                    if ($(this).hasClass("currency")) {
                        AssignVal = FormatCleanComma(AssignVal);
                    }

                    RtnObj[key] = AssignVal;
                }
            }
            else if ($(this).attr("name") == "select2") {
                key = $(this).attr("colkey");
                RtnObj[key] = "-1";

                if ($(this).val() != -1 && $(this).val() != "" && $(this).val() != null && $(this).val() != undefined) {
                    if (IsRowValInserted == 0) IsRowValInserted = 1;
                    RtnObj[key] = $(this).val();
                }
            }
            else if ($(this).attr("name") == "select") {
                key = $(this).attr("colkey");
                RtnObj[key] = "-1";

                if ($(this).attr("selval") != -1) {
                    if (IsRowValInserted == 0) IsRowValInserted = 1;
                    RtnObj[key] = $(this).attr("selval");
                }
            }
            else if ($(this).attr("name") == "checkbox") {
                if (IsRowValInserted == 0) IsRowValInserted = 1;
                key = $(this).attr("colkey");
                RtnObj[key] = "0";

                if ($(this).is(":checked")) {
                    RtnObj[key] = "0";
                } else {
                    RtnObj[key] = "1";
                }
            }

        });
        if (IsRowValInserted == 1)
            RtnGridJson.push(RtnObj);
    });
    //console.log(RtnGridJson);
    return RtnGridJson;
}

function fnGetComphelp(FormId, divId) {
    debugger;
    var RtnGridJson = [];
    var ErrMsg = "";

    if (divId == "") { LoopGrid = $("." + FormId + " .rowGrid"); }
    else { LoopGrid = $("#" + divId).find("." + FormId + " .rowGrid"); }
    var isErr = false;

    LoopGrid.each(function () {

        var RtnObj = {}; var key = ""; var IsRowValInserted = 1;
        var thisChild = $(this).find("input[name='helptext']:visible");
        var inputfield = $(this).closest("li").find("input[colkey]");

        $(thisChild).each(function () {

            if ($(this).attr("val") != "") {

                var AssignVal = $(this).attr("val");
                var txt = $(this).val() || "";
                txt = txt.trim();
                if (!AssignVal || AssignVal == "" || txt == "") {
                    isErr = true;
                    ErrMsg += $(this).closest("span.icon-sales-manager").siblings("label").justtext() + " Required!! <br/>";
                }


                inputfield.each(function () {
                    var colkey = $(this).attr("colkey");
                    RtnObj[colkey] = $(this).attr("value");
                });
              
                key = "agt_AgtFk";

                RtnObj[key] = AssignVal;
            }
        });


        if (IsRowValInserted == 1)
            RtnGridJson.push(RtnObj);
    });
 
    if (isErr)
        return { error: true, text: ErrMsg };
    else
        return RtnGridJson;
}

function fnClearForm(FormID, IsClass) {

    var AppendOperator = "#";
    if (IsClass == 1) { AppendOperator = "." }

    $(AppendOperator + FormID + " [name='text']").each(function () {
        $(this).val("");
    });

    $(AppendOperator + FormID + " [name='select']").each(function () {
        var Option = $(this).siblings("ul").children("li").eq(0).val();

        if (isNaN(Option))
            $(this).attr("selval", "");
        else
            $(this).attr("selval", "-1");

        $(this).val("");
    });

    $(AppendOperator + FormID + " [name='select2']").each(function () {
        $(this).val("");
    });

    $(AppendOperator + FormID + " [name='checkbox']").each(function () {
        $(this).prop("checked", false);
    });

    //$(AppendOperator + FormID + " .datepicker").val(GlobalXml[0].GlobalDt);
}

function fnGetFormValsJson_IdVal(FormID, IsClass) {
    var KeyVal = [];
    var KeyJsonTxt = "";
    var IsKeyExists = 0;
    var KeyValObj = {};

    var AppendOperator = "#";
    if (IsClass == 1) { AppendOperator = "." }

    $(AppendOperator + FormID + " [name='content']").each(function () {
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
    $(AppendOperator + FormID + " [name='text']").each(function () {
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

    $(AppendOperator + FormID + " [name='select2']").each(function () {
        if ($(this).parents("[contentchanged='false']").length > 0) {
        }
        else {
            if (!($(this).is("[key]"))) { return; }

            IsKeyExists = 1;
            var keyTxt = $(this).attr("key");
            var keyVal = $(this).val();
            KeyValObj[keyTxt] = keyVal;

            KeyJsonTxt += keyTxt + ",";
        }
    });

    $(AppendOperator + FormID + " [name='select']").each(function () {
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

    $(AppendOperator + FormID + " [name='checkbox']").each(function () {
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
    // console.log(KeyJsonTxt);
    if (IsKeyExists == 1)
        KeyVal.push(KeyValObj);

    return KeyVal;
}

function fnChkMandatory(FormID, IsGrid, IsClass, GridNm) {
    
    var MandatoryMsg = "";
    var AppendOperator = "";

    if (IsClass == 1) AppendOperator = ".";
    else AppendOperator = "#";

    /*********** Grid Mandatory Validations **************/
    if (IsGrid == 1) {
        $(AppendOperator + FormID + "[contentchanged='true'] .mandatory").each(function () {
            var label = "";

            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if ($(this).is(":visible") && ($(this).attr("name") == "text" || $(this).attr("name") == "select" || $(this).attr("name") == "select2") && ($(this).val().trim() == "" || $(this).val().trim() == "-1")) {
                    var thisrowGrid = $(this).closest("ul.rowGrid");
                    var index = $(thisrowGrid).children("li").index($(this).closest("li"));
                    var labelList = $(thisrowGrid).siblings("ul").not(".rowGrid");
                    label = labelList.children().eq(index).children("label").text();

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required @Row-" + (($(thisrowGrid).index()) - 1) + "!! <br/>";
                }
            }
        });

        if (MandatoryMsg != "")
            MandatoryMsg = "<br/><b>" + GridNm + "</b><br/>" + MandatoryMsg;
    }
    /*********** Grid Mandatory Validations **************/

    /*********** Form Mandatory Validations **************/
    else {
        $(AppendOperator + FormID + " [contentchanged='true'] .mandatory").each(function () {
            var lbl_sibling; var label = "";

            if ($(this).parents("[contentchanged='false']").length > 0) {
            }
            else {
                if ($(this).is(":visible") && $(this).attr("name") == "text" && (($(this).val().trim() == "") || ($(this).val().trim() == "0"))) {
                    lbl_sibling = $(this).siblings("label");
                    label = $(lbl_sibling).text();
                    if (label == "") { label = $(this).attr("placeholder"); }

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required!! <br/>";
                }
                if ($(this).is(":visible") && $(this).attr("name") == "select" && ($(this).attr("selval") == "-1") || ($(this).attr("selval") == "")) {
                    lbl_sibling = $(this).closest(".select-focus");
                    lbl_sibling = lbl_sibling.siblings("label");
                    label = $(lbl_sibling).text();

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required!! <br/>";
                }
                if ($(this).is(":visible") && $(this).attr("name") == "select2" && ($(this).val().trim() == "" || $(this).val().trim() == "-1")) {
                    lbl_sibling = $(this);
                    lbl_sibling = lbl_sibling.siblings("label");
                    label = $(lbl_sibling).text();

                    if (label != "" && label != undefined)
                        MandatoryMsg += label + " Required!! <br/>";
                }
            }
        });
    }    
    /*********** Form Mandatory Validations **************/
    return MandatoryMsg;
}


function fnSetValues(content_id, Data, IsChange) {
    if (Data.length <= 0)
        return;

    var keyArr = Object.keys(Data[0]);

    for (var j = 0; j < Data.length; j++) {
        for (var i = 0; i < keyArr.length; i++) {
            var TgtObj = $("#" + content_id).find("[key=" + keyArr[i] + "]");
            var inp_type = $(TgtObj).attr("name");

            if (inp_type == "text") {
                if ($(TgtObj).hasClass("currency")) {
                    var val = Data[j][keyArr[i]].toString();
                    $(TgtObj).val(FormatCurrency(val));
                }
                else {
                    $(TgtObj).val(Data[j][keyArr[i]]);
                }
                if (IsChange == 1) { $(TgtObj).change(); }
            }
            else if (inp_type == "content") {
                if ($(TgtObj).hasClass("currency")) {
                    var val = Data[j][keyArr[i]].toString();
                    $(TgtObj).text(FormatCurrency(val));
                }
                else {
                    $(TgtObj).text(Data[j][keyArr[i]]);
                }
                if (IsChange == 1) { $(TgtObj).change(); }
            }
            else if (inp_type == "select") {
                $(TgtObj).attr("selval", Data[j][keyArr[i]]);

                $(TgtObj).siblings("ul").children("li").each(function () {
                    if ($(TgtObj).attr("selval") == $(this).attr("val")) {
                        if (IsChange == 1) { $(TgtObj).change(); }
                        $(TgtObj).val($(this).html());
                    }
                });
            }
            else if (inp_type == "select2") {
                $(TgtObj).val(Data[j][keyArr[i]]).trigger("change.select2");
                
            }
            else if (inp_type == "checkbox") {
                if (Data[j][keyArr[i]] == 0) {
                    $(TgtObj).prop("checked", true);
                }
                else {
                    $(TgtObj).prop("checked", false);
                }
                if (IsChange == 1) { $(TgtObj).change(); }
            }
        }
    }
}

/*Custom Select starts*/
function customselect() {
    $('.cust-select').click(function (e) {
        $(this).children('ul').toggle();
    });
    $('.cust-select ul li').click(function (e) {
        $(this).toggleClass('active');
        $(this).siblings().removeClass('active');
        var val = $(this).text();
        var selval = $(this).attr("val");

        $(this).parent('ul').siblings('span.selected').text(val).trigger("change");
        $(this).parent('ul').siblings('span.selected').attr("selval", selval).trigger("change");
    });
    $(".cust-select").mouseleave(function (e) {
        $(".cust-select ul").hide();
    });
}
/*Custom Select ends*/

$(document).ready(function () {

    //$(this).find('.grid-type').removeClass("grid-type");


    //common form labels starts	
    $(".doc-view").click(function (e) {
        $(".content-div").addClass("center-collapse");
        $("#div-document-content").show();
		$(".grid-type ul").removeClass("form-controls").addClass("grid-controls");
        popupclose();
        LoadHtmldoc('documents.html');
    });
	
    function LoadHtmldoc(HtmlPage) {
        $("#div-document-content").empty();
        $("#div-document-content").load(HtmlPage);
    }


    $(".form-fields li input").click(function (e) {
        if ($('.form-fields li input').is(":empty")) {
            $(this).siblings().addClass("label-origin");
            $(this).parent().siblings().children().removeClass("label-origin");
        }
        else {
            $(this).siblings().removeClass("label-origin");
        }
    });
    //common form labels Ends	

    //Viewport Height Function Starts	
    calcHeight();
    //Viewport Height Function Ends
    LoadHtmlDiv('Login.html');
    $("#link_Dash").hide();

    //Common tab style
    commontabs();
    query();
    categoryPopup() /*Product or category popup*/
    scanAttachClick() /*Scan or Attach click*/
    popupclose();/* popup close function*/

    categoryinfo();/* categoryinfo function*/

    querypopup();

    rightdocument();

    //selectfocus(); /* Custom Select2 plugin Function*/

    customselect();/* Custom Select Function*/

    $(".right-icons i.icon-chat").click(function (e) {
        $(".right-content-div").toggle();
    });

    $(".right-icons i.icon-clock").click(function (e) {
        $("#tracking-div").toggle();
    });
	
	$(".right-icons i.icon-folder").click(function (e) {
	    var usrpk = GlobalXml[0].UsrPk;
	    $("#scanfileid").SetRepositoryProps({ userpk: usrpk });
	    $("#scanfileid").LoadDirectory();
	    $(".folder-popup").toggle();
    });

	customfocus();
});
$(window).resize(function () { calcHeight(); })
.load(function () { calcHeight(); });

jQuery.fn.justtext = function () {
    return $(this).clone().children().remove().end().text().trim();
};

function validatePAN() {
    var PANNo = $("#pannumber").val();
    var isValid = pan_validate(PANNo);
    alert(isValid.toString());
}

function pan_validate(panNum) {
    //var regpan = /^([a-zA-Z]){5}([0-9]){4}([a-zA-Z]){1}?$/;
    var regpan = /^([a-zA-Z]{5})(\d{4})([a-zA-Z]{1})$/;
    return regpan.test(panNum);
}

function fnOpenCustomerDetails() {
    localStorage.setItem("LeadPK", GlobalXml[0].FwdDataPk);
    window.open("CustomerInfo.html", "_blank");
}

function fnIsAllEmpty(FormID, IsClass) {
    var MandatoryMsg = "";
    var AppendOperator = "#";
    var IsAllEmpty = true;

    if (IsClass == 1) { AppendOperator = "." }

    $(AppendOperator + FormID + " [name='text']").each(function () {
        if ($(this).is(":visible")) {
            if ($(this).val().trim() != "" && $(this).val().trim() != "0") {
                IsAllEmpty = false;
            }
        }
    });

    if (IsAllEmpty) {
        $(AppendOperator + FormID + " [name='select']").each(function () {
            if ($(this).is(":visible")) {
                if ((this).attr("selval") != "-1") {
                    IsAllEmpty = false;
                }
            }
        });
    }

    if (IsAllEmpty) {
        $(AppendOperator + FormID + " [name='select2']").each(function () {
            if ($(this).is(":visible")) {
                if ($(this).val() != "" && $(this).val() != "-1") {
                    IsAllEmpty = false;
                }
            }
        });
    }

    if (IsAllEmpty) {
        $(AppendOperator + FormID + " [name='helptext']").each(function () {
            if ($(this).is(":visible")) {
                if ($(this).val().trim() != "" && $(this).val().trim() != "0") {
                    IsAllEmpty = false;
                }
            }
        });
    }

    return IsAllEmpty;
}



// MANUAL DEVIATION common - start

function fnSetDeviationData(DivID, DevList, SelectedList) {
    if (DivID && DivID.indexOf("#") != 0)
        DivID = "#" + DivID;


    // Deviation Search

    $(DivID).find(".deviation-search").keyup(function (e) {
        var dynam_div = $(this).closest(".deviation-main").attr("id");
        fnSearchDeviation(dynam_div, this);
    });

    DevList = DevList || [];
    SelectedList = SelectedList || [];

    if (SelectedList.length > 0 && $(DivID).find(".deviation-level").length > 0) {
        $(DivID).find(".deviation-level").val(SelectedList[0].Level).trigger("change.select2");
    }    
    $(DivID).find(".deviation-height").empty();
    var Deviaition = '';
    var curCategory = '', prevCategory = '';
    for (var i = 0; i < DevList.length; i++) {
        curCategory = DevList[i].category;
        if (i == 0 || curCategory != prevCategory) {
            if (i != 0)
                Deviaition += '</ul></div>';
            Deviaition += '<div class="deviation-category"><h2 class="deviation-category-title cursor">' + curCategory + '</h2><ul class="deviation-list-ul">';
        }
        var BoxId = uniqueID();
        Deviaition += '  <li Pk="' + DevList[i].Pk + '">' +
                        '         <div class="onoffswitch3">' +
                        '            <input Pk="' + DevList[i].Pk + '" type="checkbox" name="onoffswitch" class="onoffswitch-checkbox deviation-check" id="' + BoxId + '" >' +
                        '           <label class="onoffswitch-label" for="' + BoxId + '"> <span class="onoffswitch-inner"></span> <span class="onoffswitch-switch"></span> </label>' +
                        '      </div>' + DevList[i].text +
                        '  </li>';

        prevCategory = curCategory;
    }

    $(DivID).find(".deviation-height").append(Deviaition);
    $(DivID).find(".deviation-list-ul").hide();
    $(DivID).find(".deviation-category h2").click(function (e) {
        var dynam_div = $(this).closest(".deviation-main");
        if (($(dynam_div).find(".deviation-search").val() || "").trim() != "")
            $(dynam_div).find(".deviation-search").val("").keyup();
        $(this).toggleClass("active");
        $(dynam_div).find(".deviation-category h2").not(this).removeClass("active");
        $(dynam_div).find(".deviation-list-ul").not($(this).closest(".deviation-category").find(".deviation-list-ul")).hide("fast");
        $(this).closest(".deviation-category").find(".deviation-list-ul").toggle("fast");
    });

    for (var j = 0; j < SelectedList.length; j++) {
        $(DivID).find(".deviation-list-ul li input[Pk=" + SelectedList[j].Selected + "]").prop("checked", true);
    }
    if (SelectedList && SelectedList.length > 0)
        $(DivID).find(".deviation-search").val("::").keyup();
}


function fnSearchDeviation(DivID, elem) {
    if (DivID && DivID.indexOf("#") != 0)
        DivID = "#" + DivID;
    var txt = ($(elem).val() || "").trim().toLowerCase();
    if (txt == "") {
        $(".deviation-list-ul li").show();
        $(".deviation-list-ul").hide();
        $(".deviation-category h2").removeClass("active");
    }
    else if (txt.indexOf(":") == 0) {
        if (txt == "::") {
            $(DivID).find(".deviation-list-ul").show();
            $(DivID).find(".deviation-list-ul li .deviation-check").each(function () {
                var dynam_div = $(this).closest(".deviation-main");
                var ischecked = $(this).is(":checked");
                if (ischecked)
                    $(dynam_div).find(this).closest("li").show();
                else
                    $(dynam_div).find(this).closest("li").hide();
            });
        }
        if (txt == ":::") {
            $(DivID).find(".deviation-list-ul").show();
            $(DivID).find(".deviation-list-ul li .deviation-check").each(function () {                
                var ischecked = $(this).is(":checked");
                if (!ischecked)
                    $(this).closest("li").show();
                else
                    $(this).closest("li").hide();
            });
        }
    }
    else {
        $(DivID).find(".deviation-category").each(function () {
            var isFiltered = false;
            var h2 = ($(this).find("h2").text() || "").trim().toLowerCase();
            if (h2.indexOf(txt) >= 0) {
                isFiltered = true;
                $(this).find("ul.deviation-list-ul").show();
                $(this).find("ul.deviation-list-ul li").show();
            } else { $(this).find("ul.deviation-list-ul").hide(); }

            if (!isFiltered) {
                $(this).find("ul.deviation-list-ul li").each(function () {
                    var litxt = ($(this).justtext() || "").trim().toLowerCase();
                    if (litxt.indexOf(txt) >= 0) {
                        $(this).closest("ul.deviation-list-ul").show();
                        $(this).show();
                    } else { $(this).hide(); }
                });
            }
        });
    }
}

function fnGetSelectedDeviation(DivID) {
    if (DivID && DivID.indexOf("#") != 0)
        DivID = "#" + DivID;
    var arr = [];
    var devLevel = $(DivID).find(".deviation-level").val() || "";
    devLevel = devLevel == 0 ? "" : devLevel;
    $(DivID).find(".deviation-list-ul li .deviation-check").each(function () {        
        var ischecked = $(this).is(":checked");
        var Pk = $(this).attr("Pk");
        if (ischecked) {
            var text = $(this).closest("li").justtext();
            arr.push({ Pk: Pk, text: text, level: devLevel });
        }
    });
    return arr;
}

function fnCollapseAllDeviation(DivID) {
    if (DivID && DivID.indexOf("#") != 0)
        DivID = "#" + DivID;

    if (($(DivID).find(".deviation-search").val() || "").trim() != "")
        $(DivID).find(".deviation-search").val("").keyup();

    if ($(DivID).find(".deviation-list-ul").is(":visible")) {
        $(DivID).find(".deviation-list-ul").hide("fast");
        $(DivID).find(".deviation-category h2").removeClass("active");
    }
    else {
        $(DivID).find(".deviation-list-ul").toggle("fast");
        $(DivID).find(".deviation-category h2").toggleClass("active");
    }
}

function fnHighlightText(DivID, text) {
    var src_str = $("#" + DivID).html();
    var term = text;
    term = term.replace(/(\s+)/, "(<[^>]+>)*$1(<[^>]+>)*");
    var pattern = new RegExp("(" + term + ")", "gi");
    src_str = src_str.replace(pattern, "<mark>$1</mark>");
    src_str = src_str.replace(/(<mark>[^<>]*)((<[^>]+>)+)([^<>]*<\/mark>)/, "$1</mark>$2<mark>$4");
    $("#" + DivID).html(src_str);
}

function fnSaveManualDeviation(DivID, type, callback, ServFor, GlobXml) {
    var devData = fnGetSelectedDeviation(DivID);
    var detailJson = { DeviationJson: JSON.stringify(devData) }
    var GJson = GlobXml;
    var PrcObj = { ProcedureName: "PrcShflManualDeviation", Type: "SP", Parameters: ["ADD_MANUALDEV", JSON.stringify(GlobXml), JSON.stringify(detailJson), type] };
    fnCallLOSWebService(ServFor, PrcObj, callback, "MULTI");
}


// MANUAL DEVIATION common - end




/*********** unique ID *************/
var uniqNo = 1;
function uniqueID() {
    var d = new Date(),
        m = d.getMilliseconds() + "",
        u = ++d + m + (++uniqNo === 10000 ? (uniqNo = 1) : uniqNo);

    return "id_" + u;
}
/*********** unique ID *************/


function JSONToCSVConvertor(JSONData, ShowLabel, FileNm) {

    //If JSONData is not an object then JSON.parse will parse the JSON string in an Object
    var arrData = typeof JSONData != 'object' ? JSON.parse(JSONData) : JSONData;

    var CSV = '';
    //Set Report title in first row or line

    // CSV += ReportTitle + '\r\n\n';

    //This condition will generate the Label/Header
    if (ShowLabel) {
        var row = "";

        //This loop will extract the label from 1st index of on array
        for (var index in arrData[0]) {
            //Now convert each value to string and comma-seprated
            row += index + ',';
        }

        row = row.slice(0, -1);

        //append Label row with line break
        CSV += row + '\r\n';
    }

    //1st loop is to extract each row
    for (var i = 0; i < arrData.length; i++) {
        var row = "";

        //2nd loop will extract each column and convert it in string comma-seprated
        for (var index in arrData[i]) {
            row += arrData[i][index] + ',';
        }

        row = row.slice(0, row.length - 1);

        //add a line break after each row
        CSV += row + '\r\n';
    }

    if (CSV == '') {
        alert("Invalid data");
        return;
    }

    //Generate a file name
    var fileName = FileNm;

    //Initialize file format you want csv or xls
    var uri = 'data:text/csv;charset=utf-8,' + escape(CSV);

    //this trick will generate a temp <a /> tag
    var link = document.createElement("a");
    link.href = uri;

    //set the visibility hidden so it will not effect on your web-layout
    link.style = "visibility:hidden";
    link.download = fileName + ".csv";

    //this part will append the anchor tag and remove it after automatic click
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}