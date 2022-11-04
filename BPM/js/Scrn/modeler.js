setLocalStorage("BpmUrl", "http:///172.23.124.134//BPM_RS//");
debugger;
var idval;
var CurDate = new Date();
var EditElemet = null; //Selected Process
var eventObj = null; //Selected Process Event Object
var EditURL = ""; // File Upload Path.
var FlowPk = 0;
var BPM_DB = null;
var isPageorURL = 0; // Page -0 , URL - 1
var isDiagramLocal = true; // True - Local DB, False - Edit Mode.
var pageType = 1; // 1 - Task/Start/End , 2 - Decision, 4 - SubProcess.
var SavedXml = ""; var elementRegistry; var MainFlowFk = 0;
var bpmnModeler; var SubProcJSON = []; var FlowOption = [];
var RolJson = [];
var CurrentOpenProc = 1; // 3 - Open, 1 - Template, 2 -Version Change

var GlobalXml = [{}];
GlobalXml[0].UsrPk = "";
GlobalXml[0].FlowFk = "";
GlobalXml[0].FlowXml = "";
GlobalXml[0].ElemId = "";
GlobalXml[0].CurPage = "";
GlobalXml[0].FlowNm = "";
GlobalXml[0].FlowVersNo = "";
GlobalXml[0].FlowDpdFk = "";
GlobalXml[0].createPageType = 0;


var UpdateFlg = false; // True - Edit Selected Form Element, False - No Form Element is Selected.
var UpdateDiv = ""; // Selected div Form Element.

var ElementPropertiy = [
    { elem: "input", type: "text", value: "", dispNm: "TextBox", label: "Label", col: "" },
    { elem: "select", option: '["Option1","Option2","Option3"]', dispNm: "Select", label: "Label", col: "" },
    { elem: "input", type: "button", value: "Save", onclick: "", dispNm: "Button", col: "" },
    { elem: "input", type: "number", value: "", dispNm: "Number", label: "Label", col: "" },
    { elem: "input", type: "number", value: "", dispNm: "Amount", label: "Label", col: "" },
	{ elem: "input", type: "file", dispNm: "Attachment", label: "Label", disabled: "true", onchange: "fnFileAttacher(this,true)", col: "" },//added by Vijay S for Point 2, multiple: "false" 
    { elem: "input", type: "password", value: "", dispNm: "Password", label: "Label", col: "" },
    // { elem: "input", type: "file", value: "",disabled:true, dispNm: "Upload", label: "Label", col: "" },
    { elem: "textarea", type: "", value: "", dispNm: "textarea", label: "Label", col: "" },
    // { elem: "input", type: "checkbox", value: '["Option1","Option2","Option3"]', dispNm: "CheckBox", label: "Label", col: "" },
    //{ elem: "select", option: '["Enter Query"]', type: "query", dispNm: "Select-Query", label: "Label", col: "" },
    { elem: "input", type: "text", value: "", dispNm: "Integration", label: "Label", col: "2", usrtype: "config_integration" }//added by Vijay S for Point 9
];

$(document).ready(function () {
    $('file')
    console.log("java script loaded");
    // debugger;

    fnLoadXML(0); // Get All Flows.
    selUserRole(); // Get All Roles and Details for Tag PopUp (Location & Product)
    fnCreateTempDB(); // Create Local DB
    fnSetSelectOptions(); //Add Form Controls based on JSON.
    fnaddPage();
    /* Dynamically Assign Text to Process based on Task Name */
    $("#elementDescText").keyup(function () {

        var txt = $(this).val();
        if (EditElemet != null) {
            try {
                var model = bpmnModeler.get('modeling');
                model.updateProperties(EditElemet, {
                    name: txt
                });
            }
            catch (e) { alert(e) }
        }
    });

    /* Tool Icon ON or OFF */
    fnEnableDisableTools("Disable");

    /* File Upload Change Event */
    $("#htmlFile").change(function () { fnSaveUploadForm('file') })

    /* Load New Diagram by Default */
    fnNewDiagram();

    /*
    var BackButton = document.querySelector('#back-button');
    BackButton.addEventListener('click', function () {

    GlobalXml[0].ElemId = "";

    for (var i = 0; i < SubProcJSON.length; i++) {
    if (SubProcJSON[i].DestFlowFk == FlowPk) {
    GlobalXml[0].ElemId = SubProcJSON[i].Id;
    }
    }

    var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["FETCH_BACKPROC", "", JSON.stringify(GlobalXml)] };
    fnCallWebService("FETCH_BACKPROC_DATA", objProcData, fnBPMResult, "MULTI");

    });
    */
    $("#designDiv-form-area,#designDiv-form-area-2,#designDiv-form-area-3").sortable();
    // $("#designDiv-form-area li,#designDiv-form-area-2 li,#designDiv-form-area-3 li").draggable();
    $("#designDiv-form-area .li-add-elem ui-draggable,#designDiv-form-area-2 .li-add-elem,#designDiv-form-area-3 .li-add-elem ui-draggable").draggable({
        revert: "invalid",
        refreshPositions: true,
        drag: function (event, ui) {
            ui.helper.addClass("draggable");

        },
        stop: function (event, ui) {

            if ($.ui.ddmanager.drop(ui.helper.data("draggable"), event)) {

                if (idval == 0) {
                    ElementPropertiy[$(this).attr("value")].col = idval;
                    fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area");
                }
                else if (idval == 1) {
                    ElementPropertiy[$(this).attr("value")].col = idval;
                    fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area-2");
                }
                else if (idval == 2) {
                    ElementPropertiy[$(this).attr("value")].col = idval;
                    fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area-3");
                }
            }
            else {

            }
        }

    });
    $("#designDiv-form-area li,#designDiv-form-area-2 li,#designDiv-form-area-3 li").droppable({
        drop: function (event, ui) {
            if ($("#designDiv-form-area").length == 0) {
                $("#designDiv-form-area").html("");
            }
            if ($("#designDiv-form-area-2").length == 0) {
                $("#designDiv-form-area-2").html("");
            }
            if ($("#designDiv-form-area-3").length == 0) {
                $("#designDiv-form-area-3").html("");
            }
            ui.draggable.addClass("dropped");

            if ($("*").hasClass("dropped") == true) {
                $("li").removeClass("li-add-elem ui-draggable draggable dropped");
                $("li").addClass("li-add-elem ui-draggable");
            }
        }
    });
});

/** li tag set and get values Starts ***/
$.fn.setVal = function (SetValue) {
    var isCustSelect = $(this).hasClass("cust-select");
    var selected = $(this).find(".selected");
    $(this).find("ul li").removeClass("active");
    if (isCustSelect) {
        $(this).find("ul li").each(function () {
            var activeTxt = $(this).text();
            var activeVal = $(this).attr("value");
            activeVal = activeVal ? activeVal : "";
            if ((SetValue == activeTxt && activeVal == "") || (activeVal == SetValue && activeVal != "")) {
                $(selected).text(SetValue);
                $(this).addClass("active");
            }
        });
    }
    else {
        throw new Error("The selected element is not custom select element.");
    }
}

$.fn.getVal = function () {
    var isCustSelect = $(this).hasClass("cust-select");
    var value = "";
    if (isCustSelect) {
        value = $(this).find(".selected").text();
        var activeTxt = $(this).find("ul li.active").text();
        var activeVal = $(this).find("ul li.active").attr("value");
        activeVal = activeVal ? activeVal : "";
        if (activeVal != "") {
            return activeVal;
        }
        else {
            return value;
        }
    }
    else {
        throw new Error("The selected element is not custom select element.");
    }
}

/** li tag set and get values Ends ***/
function fnsetval(id) {
    idval = id;
    // console.log(idval);
}
/* Draw Form Controls based on JSON Data */
function fnSetSelectOptions() {
    $("li").removeClass("dropped");
    $("#SelAddField").html('');
    var opt = "";
    for (var i = 0; i < ElementPropertiy.length; i++) {
        $("#SelAddField").append('<span style="height:100%;"><li class="li-add-elem" style="height:2% !important;cursor:move;z-index:1;" value="' + i + '"> ' + ElementPropertiy[i].dispNm.toUpperCase() + '<i class="right fa fa-arrows" style="cursor:move;margin-left: 10px;"></i></li></span>');
    }

    //    $(".li-add-elem").click(function () {
    //        fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area");
    //    });

    $("#SelAddField .li-add-elem").draggable({
        revert: "invalid",
        refreshPositions: true,
        drag: function (event, ui) {
            ui.helper.addClass("draggable");

        },
        stop: function (event, ui) {

            if ($.ui.ddmanager.drop(ui.helper.data("draggable"), event)) {

                if (idval == 0) {
                    ElementPropertiy[$(this).attr("value")].col = idval;
                    fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area");
                }
                else if (idval == 1) {
                    ElementPropertiy[$(this).attr("value")].col = idval;
                    fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area-2");
                }
                else if (idval == 2) {
                    ElementPropertiy[$(this).attr("value")].col = idval;
                    fnAddPageElem(ElementPropertiy[$(this).attr("value")], "designDiv-form-area-3");
                }
            }
            else {

            }
        }

    });
    $("#designDiv-form-area,#designDiv-form-area-2,#designDiv-form-area-3").droppable({
        drop: function (event, ui) {
            if ($("#designDiv-form-area").length == 0) {
                $("#designDiv-form-area").html("");
            }
            if ($("#designDiv-form-area-2").length == 0) {
                $("#designDiv-form-area-2").html("");
            }
            if ($("#designDiv-form-area-3").length == 0) {
                $("#designDiv-form-area-3").html("");
            }
            ui.draggable.addClass("dropped");

            if ($("*").hasClass("dropped") == true) {
                $("li").removeClass("li-add-elem ui-draggable draggable dropped");
                $("li").addClass("li-add-elem ui-draggable");
                $(".li-add-elem").css("left", "0px");
                $(".li-add-elem").css("top", "0px");
            }
        }

    });
}

function fnOpen() {

    // debugger;
    fnLoadXML(0);
    fnEnableDisableTools('Enable');


}
/***** Disable or Enable Tools *****/
function fnEnableDisableTools(Status) {

    if (Status == "Disable") {
        $(".icon-save").css("pointer-events", "none");
        $(".icon-tools").css("pointer-events", "none");
    }
    else {
        $(".icon-save").css("pointer-events", "");
        $(".icon-tools").css("pointer-events", "");
    }
}
/*** Tools ON or OFF *******/
function fnhideorshowTool() {
    $("#palatte_bpm").toggle();

    if ($(".li-tools i").css("pointer-events") != "none") {
        $(".li-tools").toggleClass("active");
    }
}

/** Get Flow or Process Details from Pk / Get All Flow Details ******/
function fnLoadXML(Pk) {

    if (Pk == -1) {
        fnShflAlert("warning", "Select Project to load");
        return;
    }
    GlobalXml[0].FlowFk = Pk;
    MainFlowFk = Pk;

    var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["GET_FLOW_XML", "", JSON.stringify(GlobalXml), ""] }
    fnCallWebService("FLOW_XML", objProcData, fnBPMResult, "MULTI", Pk);
}

/*************** Callback Functions ******************************/
function fnBPMResult(ServDesc, Obj, Param1, Param2) {

    if (!Obj.status && ServDesc != "UploadForm") {
        fnShflAlert("error", Obj.error);
        return;
    }

    if (ServDesc == "SAVE_ROLES_RTN") { //Roles Save Call Back - Edit Mode.
        fnShflAlert("success", "Roles Assigned!!");
    }
    if (ServDesc == "SAVE_SUBP_RTN") {  //SubProcess Save Call Back - Edit Mode.
        fnShflAlert("success", "SubProcess Saved!!");
        $("#HtmlBuilder_SP").hide();
    }
    if (ServDesc == "NEW_PROJ") { //Flow Save Call Back
        var Data = JSON.parse(Obj.result);
        //ADDED BY VIJAY S FOR Point 10 PIVOT REPORT GENERATION
        //if (GlobalXml[0].FlowVersNo == "")
            fnPivotRptGeneration(Data[0].FlowFk);
        fnNewDiagram();
        return;

        if (Data != null && Data.length > 0) {
            fnLoadXML(Data[0].FlowFk);
            GlobalXml[0].FlowXml = "";            
        }
    }
    if (ServDesc == "LOAD_ROLES") { //Roles & Tags Call Back
        var Data = JSON.parse(Obj.result_1);
        var PrdLocDtls = JSON.parse(Obj.result_2);
        var UsrDtls = JSON.parse(Obj.result_3);
        var TrigDtls = JSON.parse(Obj.result_4);

        var opt = "";

        // Roles Assign
        $("#sel_PrdLoc").empty();

        if (Data == null || Data.length == 0) {
        }
        else {
            for (var i = 0; i < Data.length; i++) {
                opt += "<option value='" + Data[i].RolePk + "'>" + Data[i].Roles + "</option>";
            }
        }

        $("#sel_PickRole").append(opt);
        $("#sel_PickRole").select2({
            width: '100%',
            theme: "classic",
            tags: false,
            minimumInputLength: 1,
            maximumSelectionLength: 1
        });

        $("#Role_Dtls_Pop .select2-selection--multiple").css("height", "100px");

        // Tags Assign
        opt = "";
        for (var i = 0; i < PrdLocDtls.length; i++) {
            var IsSel = "";
            if (PrdLocDtls[i].IsSel == 1) IsSel = "selected";
            opt += "<option " + IsSel + " value='" + PrdLocDtls[i].Pk + "'>" + PrdLocDtls[i].Text + "</option>";
        }

        $("#sel_PrdLoc").append(opt);
        $("#sel_PrdLoc").select2({
            width: '100%',
            theme: "classic",
            tags: false,
            minimumInputLength: 1
        });

        opt = "";
        for (var i = 0; i < UsrDtls.length; i++) {
            opt += "<option value='" + UsrDtls[i].UsrPk + "'>" + UsrDtls[i].UsrDispNm + "</option>";
        }
        $("#sel_ProcOwner").append(opt);

        $("#tag-popup .select2-selection--multiple").css("height", "100px");

        opt = "";
        for (var i = 0; i < TrigDtls.length; i++) {
            opt += "<option value='" + TrigDtls[i].TrigPk + "'>" + TrigDtls[i].TrigNm + "</option>";
        }
        $("#sel_TriggerSel").append(opt);

        fnSavePrdLocTags();
    }
    if (ServDesc == "UploadForm") { //Call back for Upload File(Server Upload)
        var data = Obj.split("~$#");
        var fileURL = data[1];
        if (fileURL != "" && fileURL != null)
        { EditURL = fileURL; }
        else
        {
            fnShflAlert("error", "Error Occured");
            return;
        }
        $("#htmlFilecontent").load(fileURL, function (e) {
        });
        return;
    }
    if (ServDesc == "SAVE_PAGE") { //Call back for Page Save - Edit Mode
        var Data = JSON.parse(Obj.result);
        if (Data == null || Data.length == 0) {
            fnShflAlert("error", "Error occured while saving page");
            return;
        }
        GlobalXml[0].CurPage = Data[0].PagePk;
        fnShflAlert("success", "Page successfully saved");
    }
    if (ServDesc == "FLOW_XML") { // Flow Details and Global Xml Values Set Call back
         debugger;
        var Data = JSON.parse(Obj.result_1); // Flow List
        FlowOption = JSON.parse(Obj.result_2); //Sub Process List, other than Selected Process will come.//CHANGE


        if (Data == null || Data.length == 0) {
            isDiagramLocal = true;
            fnShflAlert("warning", "No data found");
            return;
        }

        if (Param2 == 0) {
            $("#div_Proclist").empty();
            for (var i = 0; i < Data.length; i++) {
                $("#div_Proclist").append(
                 "<ul class='ulProc' FlowFk='" + Data[i].FlowPk + "'><li>" + Data[i].FlowNm + "</li>"
                )
            }

            $(".ulProc").click(function () {
                $(".ulProc").removeClass("active");
                $("#projSelect").val($(this).attr("FlowFk"));
                $(this).addClass("active");
            });
            return;
        }

        GlobalXml[0].FlowNm = Data[0].FlowNm;
        GlobalXml[0].FlowVersNo = Data[0].FlowVersNo;
        GlobalXml[0].FlowDpdFk = Data[0].BpmFk; //BpmPk
        GlobalXml[0].FlowFk = Data[0].FlowPk;
        diagramXML = Data[0].FlowXml;
        fnLoadDiagram(diagramXML);
        FlowPk = Data[0].FlowPk;
        isDiagramLocal = true;


        // CHANGE BEGINNING


        UIDetails = JSON.parse(Obj.result_3);
        roleDetails = JSON.parse(Obj.result_4);

        if (CurrentOpenProc == 3 || CurrentOpenProc == 2) {
            GlobalXml[0].FlowXml = "Edit";
            $(".icon-save").css("pointer-events", "");

            if (CurrentOpenProc == 3) {
                $("#sel_version_div").html("");
                $("#sel_VerHis").html("");

                var ToSendFlowFk = GlobalXml[0].FlowDpdFk;
                var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["GET_FLOW_VERSIONS", "", "", "", "", "", ToSendFlowFk] }
                fnCallWebService("FLOW_XML_VERSIONS", objProcData, fnBPMResult, "MULTI");
            }
        }
        else {
            $("#sel_version_div").html("");
            $("#sel_VerHis").html("");

            GlobalXml[0].FlowXml = "New";
            $(".icon-save").css("pointer-events", "");
            fnSetDefaultVer([]);
        }

        fnEditorTemplate();
        $("#ProcName").text(Data[0].FlowNm);
        $("#txt_ProcRmks").val(Data[0].Rmks);
        $("#open-popup").hide();

        fnCreateTempDB();
        if (UIDetails.length > 0) {
            for (var i = 0; i < UIDetails.length; i++) {
                fnInsertElemDetails(UIDetails[i].IsStrt, UIDetails[i].ElemId, UIDetails[i].ElemCd, UIDetails[i].ElemDesc, UIDetails[i].ElemHtml, UIDetails[i].ElemPageUrl, UIDetails[i].Pagetype, UIDetails[i].SelProcId, UIDetails[i].Rmks, UIDetails[i].IsAuto, UIDetails[i].ElemIsRtnNeed);
            }
        }

        if (roleDetails.length > 0) {

            BPM_DB.transaction(function (tx) {
                for (var i = 0; i < roleDetails.length; i++) {
                    var Query = "INSERT INTO BPM_ROLE_MAS(RolId,RolNm,RolFk)" +
                        " SELECT '" + roleDetails[i].RolId + "', '" + roleDetails[i].RolNm + "', " + roleDetails[i].RolFk + "";
                    tx.executeSql(Query, [], function (tx, result) {
                        isDone = true;
                        //CHANGES ENDING
                    });
                }
            });
        }

        return;
    }
    if (ServDesc == "FLOW_XML_VERSIONS") {// Versions List for Selected Flow.
        var FlowVers = JSON.parse(Obj.result);
        fnSetDefaultVer(FlowVers);
    }
    if (ServDesc == "PAGE_CHECK_EXCL") { // Page Check for Decision Process.
        $("#designDiv-form-area,#designDiv-form-area-2,#designDiv-form-area-3").html('');
        $("#htmlFilecontent").html('');

        var Data = JSON.parse(Obj.result);
        GlobalXml[0].CurPage = 0;
        try {
            $("#txt_TskRmks").val(Data[0].Rmks);
        } catch (e) { }
        fnLoadDefaultPage('decision', Param2, 'designDiv-form-area');
        fnLoadDefaultPage('decision', Param2, 'designDiv-form-area-2');
        fnLoadDefaultPage('decision', Param2, 'designDiv-form-area-3');

        var title = Param2.element.businessObject.name == undefined ? "" : Param2.element.businessObject.name;
        $("#dialogDiv").css("display", "block");
        //$("#dialogDiv .popup-div.popup-div-large .pop-content").css("width", "70%");//modified by Vijay S
        $("#dialogDiv .popup-div.popup-div-large .pop-content").css("width", "95%");

    }
    if (ServDesc == "PAGE_CHECK") {  // Page Check for All Tasks other than Decision.
        UpdateFlg = false;
        UpdateDiv = "";

        $("#Pagetitle").text(Param2.element.businessObject.name == undefined ? "TASK" : Param2.element.businessObject.name);

        var Data = JSON.parse(Obj.result);
        if (Data != null && Data.length != 0) {
            GlobalXml[0].CurPage = Data[0].PagePk;

            $("#script_div").html(Data[0].PageScript); /** Only for Script Task **/
            $("#txt_TskRmks").val(Data[0].Rmks);

            fnEnableDisableTabs(1); // Remove All Active Classes Before.

            if (Data[0].PageUrl != "" && Data[0].PageUrl != null) { // If Saved Page is Uploaded.
                $("#htmlFile").val(Data[0].PageUrl);
                $("#htmlFile").change();
                $("#htmlFilecontent").load(Data[0].PageUrl);
                fnEnableDisableDivs("Attach");
            }
            if (Data[0].PageJson != "" && Data[0].PageJson != null) { // If Saved Page is Builded.
                var PageJson = JSON.parse(Data[0].PageJson);
                fnEnableDisableDivs("Build");
                for (var i = 0; i < PageJson.length; i++) {
                    fnAddPageElem(PageJson[i], 'designDiv-form-area');
                }
            }
        }
        else {
            GlobalXml[0].CurPage = "";
        }
    }
    if (ServDesc == "FETCH_SUBPROC_DATA") { //Sub Process Datas Call Back.
        try {
            var SubProc = JSON.parse(Obj.result);
            if (SubProc.length > 0) {
                var ViewXml = SubProc[0].XmlData;
                FlowPk = SubProc[0].DestFlowFk;

                var IsDone = 0;
                for (var i = 0; i < SubProcJSON.length; i++) {
                    if (SubProcJSON[i].Id == GlobalXml[0].ElemId) {
                        IsDone = 1;
                        SubProcJSON[i].SrcFlowFk = SubProc[0].SrcFlowFk;
                        SubProcJSON[i].DestFlowFk = SubProc[0].DestFlowFk;
                    }
                }

                if (IsDone == 0)
                    SubProcJSON.push({ Id: GlobalXml[0].ElemId, SrcFlowFk: SubProc[0].SrcFlowFk, DestFlowFk: SubProc[0].DestFlowFk })

                $("#SubdialogDiv").css("display", "block");
                fnViewBpmDig(ViewXml);
            }
            else {
                fnShflAlert("error", "No SubProcess Attached to View")
            }
        } catch (e) { }
    }

    if (ServDesc == "FETCH_BACKPROC_DATA") { // Fetch Previous Process from Sub Process.
        try {
            var SubProc = JSON.parse(Obj.result);
            var ToLoadXml = SubProc[0].XmlData;

            FlowPk = SubProc[0].SrcFlowFk;

            if (SubProc[0].SrcFlowFk == MainFlowFk) {
                fnLoadXML(MainFlowFk);
                GlobalXml[0].ElemId = "";
                SubProcJSON = [];
            } else {
                $("#SubdialogDiv").css("display", "block");
                fnViewBpmDig(ToLoadXml);
            }
        } catch (e) { }
    }
}

/* Tabs Enabling */
function fnEnableDisableTabs(PopFlg) {
    if (PopFlg == 1) {
        $("#common-tabs li").removeClass("active"); // Roles,General,Form
        $("#selPageTyp li").removeClass("active"); //URL,Build Source.
        $("#ul_dec_list li").removeClass("active"); //Auto, Decision.

        $("#common-tabs li[val=0]").addClass("active");
        $("#m-tab1").css("display", "block");
        $("#m-tab2").css("display", "none"); $("#m-tab3").css("display", "none");
    }
    else if (PopFlg == 2) {
        $("#ul_ProcTab li").removeClass("active");
        $("#ul_ProcTab li[val=0]").addClass("active");
        $("#div_content_Process .proc-tab").css("display", "none");
        $("#div_Gen_Proc").css("display", "block");
    }
}

/* Div Enabling */
function fnEnableDisableDivs(divFlg) {

    if (divFlg == "Attach") {
        $("#selPageTyp li[val=1]").addClass("active");
        $(".attach-content").css("display", "block");
        $(".screen-content").css("display", "none");
    }
    else if (divFlg == "Build") {
        $("#selPageTyp li[val=0]").addClass("active");
        $(".attach-content").css("display", "none");
        $(".screen-content").css("display", "block");
    }
}

/* Tag Pop Up Works */
function fnSavePrdLocTags() {
    $("#div_Tags").html("");

    $("#sel_PrdLoc option").each(function (e) {
        if ($(this).is(":selected")) {
            $("#div_Tags").append('<span class="bg">' + $(this).text() + '</span>');
        }
    });
    $("#div_Tags").append("<i class='icon-tag'></i> Tags");
    if ($("#tag-popup").css("display") == "block") {
        $("#tag-popup").hide();
    }
}

/* Attach New Process to a SubProcess*/
function fnAttachNewProc(scrInfo) {
    $("#div_sel_Flow").html('');

    var selhtml = $("#div_sel_Flow");

    for (var i = 0; i < FlowOption.length; i++) {
        selhtml.append("<ul class='ulSProc' FlowFk='" + FlowOption[i].FlowFk + "'><li>" + FlowOption[i].FlowNm + "</li>");
    }
    var ToSendId = scrInfo.element.id;
    $("#btn_save_subp").attr("onclick", "fnSaveSubProc('" + ToSendId + "')");

    $(".ulSProc").click(function () {
        $(".ulSProc").removeClass("active");
        $("#sel_Flow").val($(this).attr("FlowFk"));
        $(this).addClass("active");
    });

    $("#HtmlBuilder_SP").show();
}

/* Save the Selected SubProcess */
function fnSaveSubProc(SubProcId) {

    GlobalXml[0].ElemId = SubProcId;
    var sel_Flow = document.getElementById("sel_Flow");

    if (isDiagramLocal) {
        fnInsertElemDetails(0, SubProcId, "", SubProcId + "_Desc", "", "", 4, sel_Flow.value, "", 0);
    }
    else {
        var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["SAVE_SUBP", "", JSON.stringify(GlobalXml), "", "", sel_Flow.value] };
        fnCallWebService("SAVE_SUBP_RTN", objProcData, fnBPMResult, "MULTI");
    }
}

/** Back Button Visibility ***/
function fnBtnVisibilitySt(Flg) {
    if (Flg == 1) {
        $("#back-button").css("display", "none");
    }
    else if (Flg == 2) {
        $("#back-button").css("display", "inline-block");
    }
}

/*** BPMN Viewvwer ***/
function fnViewBpmDig(ViewXml) {

    $("#canvas-view").empty();
    (function (BpmnViewer, $) {

        // create modeler
        var bpmnViewer = new BpmnViewer({
            container: '#canvas-view'
        });

        // import function
        function importviewXML(xml) {
            // import diagram
            bpmnViewer.importXML(xml, function (err) {
                if (err) {
                    return console.error('could not import BPMN 2.0 diagram', err);
                }
                fnBtnVisibilitySt(2);

                var canvas = bpmnViewer.get('canvas');
                var elementReg = bpmnViewer.get('elementRegistry');
                var elements = elementReg.filter(function (element) {
                    return element;
                });

                //color Elements.
                for (var i in elements) {

                    var Type = elements[i].type;
                    var id = elements[i].id;

                    if (Type.indexOf("Event") > 0) {
                        canvas.addMarker(id, 'events');
                    }
                    else if (Type.indexOf("Task") > 0 || Type.indexOf("SubProcess") > 0) {
                        canvas.addMarker(id, 'tasks');
                    }
                    else if (Type.indexOf("Gateway") > 0) {
                        canvas.addMarker(id, 'gateways');
                    }
                }

                // zoom to fit full viewport
                canvas.zoom('fit-viewport');
            });

            var eventBus = bpmnViewer.get('eventBus');

            // you may hook into any of the following events
            var events = [
              'element.click'
            ];

            events.forEach(function (event) {
                eventBus.on(event, function (e) {
                    try {
                        if (e.element.type == "bpmn:SubProcess") {
                            var TxtArea = $(".djs-container textarea");
                            fnGetSubProcXml(e);
                        }
                    }
                    catch (ex) {
                        console.log("Error: " + ex);
                    }
                });
            })
        }
        $("#SubdialogDiv #palatte_bpm").css("display", "none");
        // import xml
        importviewXML(ViewXml);

    })(window.BpmnJS, window.jQuery);
}

/*** Get SubProcess from Local DB - Add Mode ***/
function fnGetSubProcXml(e) {
    var ElemId = e.element.id;
    GlobalXml[0].ElemId = ElemId;

    if (isDiagramLocal) {

        fnAttachNewProc(e);

        BPM_DB.transaction(function (tx) {
            var CheckExists = "SELECT ElemSubProcId FROM BPM_ELEMENT_DETL WHERE ElemID='" + ElemId + "' AND ElemPageType = 4";
            var resCount = 0;

            tx.executeSql(CheckExists, [], function (tx, result) {
                resCount = result.rows.length;
                if (resCount > 0) {
                    var data = result.rows;
                    $("#sel_Flow").val(data[0]["ElemSubProcId"]);
                    $(".ulSProc").removeClass("active");
                    $(".ulSProc").each(function () {
                        if ($(this).attr("FlowFk") == data[0]["ElemSubProcId"]) {
                            $(this).addClass("active");
                        }
                    })
                }
            })
        });
    }
    else {
        fnShowSubProcAtt()
    }
}

/*** Get SubProcess Attached from DB - Edit Mode ***/
function fnShowSubProcAtt() {
    GlobalXml[0].FlowXml = "";

    var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["FETCH_SUBPROC", "", JSON.stringify(GlobalXml)] };
    fnCallWebService("FETCH_SUBPROC_DATA", objProcData, fnBPMResult, "MULTI");
}

/*** BPMN Modelere ****/
function fnLoadDiagram(diagramXML) {

    $("#canvas-model").empty();
    fnBtnVisibilitySt(1);

    (function (BpmnModeler, $) {

        // create modeler
        bpmnModeler = new BpmnModeler({
            container: '#canvas-model'
        });

        elementRegistry = null;

        // import function
        function importXML(xml) {

            if (xml != "") {
                // import diagram
                bpmnModeler.importXML(xml, function (err) {

                    if (err) {
                        return console.error('could not import BPMN 2.0 diagram', err);
                    }

                    var canvas = bpmnModeler.get('canvas');
                    elementRegistry = bpmnModeler.get('elementRegistry');
                    var elements = elementRegistry.filter(function (element) {
                        return element;
                    });

                    //color Elements.
                    for (var i in elements) {

                        var Type = elements[i].type;
                        var id = elements[i].id;

                        if (Type.indexOf("Event") > 0) {
                            canvas.addMarker(id, 'events');
                        }
                        else if (Type.indexOf("Task") > 0 || Type.indexOf("SubProcess") > 0) {
                            canvas.addMarker(id, 'tasks');
                        }
                        else if (Type.indexOf("Gateway") > 0) {
                            canvas.addMarker(id, 'gateways');
                        }
                    }
                    // zoom to fit full viewport
                    canvas.zoom('fit-viewport');

                });
            }
            else {

            }

            var eventBus = bpmnModeler.get('eventBus');
            // you may hook into any of the following events
            var events = [
              'element.dblclick',
              'shape.added'
            ];

            events.forEach(function (event) {
                eventBus.on(event, function (e) {
                    //console.log(e);

                    if (event == "shape.added") {
                        fnGenerateId(e.element.id); // Generate Unique ID.
                    }
                    if (event == "element.dblclick") {
                        try {
                            debugger
                            UpdateFlg = false;
                            UpdateDiv = "";
                            $("#getDetails").html('');
                            fnClearDeginDialogDIv();
                            BPM_DB.transaction(function (tx) {
                                var Query = "SELECT * FROM BPM_ELEMENT_DETL";
                                tx.executeSql(Query, [], function (tx, result) {
                                    var data = result.rows;
                                });
                            });
                            fnGetXMLData();
                            BPM_DB.transaction(function (tx) {
                                var Query = "SELECT * FROM BPM_ELEMENT_DETL";
                                tx.executeSql(Query, [], function (tx, result) {
                                    var data = result.rows;
                                });
                            });
                            EditURL = "";
                            EditElemet = "";
                            RolJson = [];

                            EditElemet = e.element;
                            eventObj = e;

                            var left = e.originalEvent.offsetX;
                            var top = e.originalEvent.offsetY;
                            $("#script_div").html("");
                            $("#txt_TskRmks").val("");
                            $("#script_div").css("display", "none");
                            $("#elementDescText").val('');
                            $("#elementDescCd").val('');
                            $("#elementDescText").val(e.element.businessObject.name);
                            $("#designDiv-form-area,#designDiv-form-area-2,#designDiv-form-area-3").html("");
                            $("#htmlFilecontent").html('');
                            $("#htmlFile").val("../BPMFLOW/SVS_Prototype/");
                            $("#ul_dec_list").css("display", "none");
                            $("#ul_auto_dec").hide();
                            $("#choosePageType").css("display", "block");
                            $("#auto_txt_cnd").val("");
                            $("#btn_SavPg").removeAttr('disabled');
                            $("#btn_SavPg").css('background-color', '#f80e55');
                            $("#form_right").css("display", "block");

                            fnLoadDecisionPg(0);

                            var TxtArea = $(".djs-container textarea");
                            TxtArea.show();
                            TxtArea.removeAttr("disabled");
                            $("#selPageTyp li[val=1]").css("display", "inline-block");
                            fnEnableDisableDivs("Attach");
                            $(".m-tab3").css("display", "inline-block");

                            if (e.element.type == "bpmn:Task" || e.element.type.toLowerCase() == "bpmn:usertask" ||
                                e.element.type.toLowerCase() == "bpmn:endevent" || e.element.type.toLowerCase() == "bpmn:scripttask"
                                || e.element.type.toLowerCase() == "bpmn:startevent") {  // Modified JPR                          

                                if (e.element.type.toLowerCase() == "bpmn:endevent" || e.element.type.toLowerCase() == "bpmn:startevent") {
                                    $(".m-tab3").css("display", "none");
                                }

                                try {
                                    fnShowRoles();
                                } catch (ex) { }

                                TxtArea.hide();
                                isPageorURL = 0; // url page
                                pageType = 1;

                                var ElemId = e.element.id;

                                if (isDiagramLocal) {
                                    fnLoadPageforElement(ElemId, 0);
                                }
                                else {

                                    if (e.element.type.toLowerCase() == "bpmn:startevent") {
                                        $("#btn_SavPg").attr('disabled', 'disabled');
                                        $("#btn_SavPg").css('background-color', '#de96b1');
                                    }

                                    GlobalXml[0].ElemId = ElemId;
                                    GlobalXml[0].createPageType = 1;
                                    var objProcData = {
                                        ProcedureName: "PrcShflBpm_Build", Type: "SP",
                                        Parameters: ["PAGE_CHECK", "", JSON.stringify(GlobalXml)]
                                    };
                                    fnCallWebService("PAGE_CHECK", objProcData, fnBPMResult, "MULTI", e);
                                }
                                //Added by VM For hide BUILD Div
                                $("#selPageTyp li").removeClass("active");
                                $("#selPageTyp li[val=0]").css("display", "none");
                                $("#form_right").css("display", "none");
                                $("#designDiv").css("display", "none");
                                fnEnableDisableDivs("Attach");


                                var title = e.element.businessObject.name == undefined ? "" : e.element.businessObject.name;
                                if (e.element.type == "bpmn:ScriptTask")
                                    $("#script_div").css("display", "inline-block");

                                $("#dialogDiv").css("display", "block");
                                $("#dialogDiv .popup-div.popup-div-large .pop-content").css("width", "95%");//modified by Vijay S
                                $("#spn_title").text(title);
                            }
                            else if (e.element.type == "bpmn:ExclusiveGateway") { // added JPR
                              //  fnchkoutgoing(e, "decision");
                                var outgoing = e.element.businessObject.outgoing;
                                for (var i = 0; i < outgoing.length; i++) {
                                    var btnName = "";
                                    if (outgoing[i].targetRef.name != undefined && outgoing[i].targetRef.name != "") {
                                        if (outgoing[i].name == undefined || outgoing[i].name == "") {
                                            fnShflAlert("error", "Add Output Names to the Gate");
                                            TxtArea.hide();
                                            return;
                                        }
                                    }
                                    else {
                                        fnShflAlert("error", "Add Output Task Names to the Gate");
                                        TxtArea.hide();
                                        return;
                                    }
                                }
                                $("#selPageTyp li").removeClass("active");
                                $("#selPageTyp li[val=1]").css("display", "none");
                                fnEnableDisableDivs("Build");
                                $("#form_right").css("display", "none");

                                fnShowRoles();
                                TxtArea.hide();
                                // $("#ul_dec_list").css("display", "block");
                                $("#ul_auto_dec").show();
                                $("#choosePageType").css("display", "none");

                                //Added JPR
                                isPageorURL = 1; // page design
                                pageType = 2;
                                $("#FileuploadDIV").hide();

                                fnLoadDecisionPg(0);

                                var ElemId = e.element.id;
                                isDiagramLocal = true;
                                if (isDiagramLocal) {
                                    fnLoadPageforElement(ElemId, 1, e, 0);
                                      $("#dialogDiv").css("display", "block");
                                    $("#dialogDiv .popup-div.popup-div-large .pop-content").css("width", "95%");//modified by Vijay S
                                    $("#spn_title").text(title);
                                }
                                else {
                                    GlobalXml[0].ElemId = ElemId;
                                    GlobalXml[0].createPageType = 2;
                                    var objProcData = {
                                        ProcedureName: "PrcShflBpm_Build", Type: "SP",
                                        Parameters: ["PAGE_CHECK", "", JSON.stringify(GlobalXml)]
                                    };
                                    fnCallWebService("PAGE_CHECK_EXCL", objProcData, fnBPMResult, "MULTI", e);
                                }
                            }

                            else if (e.element.type == "bpmn:SubProcess") {
                                fnGetSubProcXml(e);
                            }
                            else if (e.element.type == "bpmn:ParallelGateway") {
                                /*
                                $("#selPageTyp li").removeClass("active");
                                $("#selPageTyp li[val=1]").css("display", "none");
                                fnEnableDisableDivs("Build");
                                $("#form_right").css("display", "none");

                                fnShowRoles();
                                $("#choosePageType").css("display", "none");
                                var ElemId = e.element.id;
                                var outgoing = e.element.businessObject.outgoing;
                                $("#designDiv-form-area").empty();
                                fnLoadDefaultPage("parallel", e, "designDiv-form-area");
                                var title = e.element.businessObject.name == undefined ? "" : e.element.businessObject.name;
                                $("#dialogDiv").css("display", "block");
                                $("#dialogDiv .popup-div.popup-div-large .pop-content").css("width", "70%");
                                $("#spn_title").text(title);
                                */
                            }
                            else if (e.element.type == "bpmn:Lane") {
                                var ElemId = e.element.id;
                                fnopenRolepop(TxtArea, ElemId);
                            }
                            else if (e.element.type == "bpmn:Participant") {

                                elementRegistry = bpmnModeler.get('elementRegistry');
                                var elements = elementRegistry.filter(function (element) {
                                    return element;
                                });

                                var IsLaneExists = 0;
                                for (var i in elements) {
                                    if (elements[i].type == "bpmn:Lane") {
                                        IsLaneExists = 1;
                                        return;
                                    }
                                }

                                if (IsLaneExists == 0) {
                                    var ElemId = e.element.id;
                                    fnopenRolepop(TxtArea, ElemId);
                                }
                            }

                        }
                        catch (ex) {
                            console.log("Error: " + ex);
                        }
                    }
                });
            });
        }

        if (diagramXML == "")
            bpmnModeler.createDiagram(function (err) {
                if (err) {
                    return console.error('could not create BPMN 2.0 diagram', err);
                }
                importXML("");
            });
        else
            importXML(diagramXML);

    })(window.BpmnJS, window.jQuery);
}

function fnShowRoles() {

    $("#lbl_Roles").text("");

    elementRegistry = bpmnModeler.get('elementRegistry');
    var elements = elementRegistry.filter(function (element) {
        return element;
    });

    jQuery.grep(elements, function (Elm) {
        var RoleLabel = "";
        if (Elm.type == "bpmn:Lane") {
            var ChildObj = [];
            ChildObj = Elm.businessObject.flowNodeRef;

            jQuery.grep(ChildObj, function (child) {
                if (child.id == EditElemet.id && child.$type != "label") {
                    $("#lbl_Roles").text(Elm.businessObject.name);
                }
            });
        }
    });

    if ($("#lbl_Roles").text() == "") {
        jQuery.grep(elements, function (Elm) {
            var RoleLabel = "";
            if (Elm.type == "bpmn:Participant") {
                var ChildObj = [];
                ChildObj = Elm.children;
                jQuery.grep(ChildObj, function (child) {
                    if (child.id == EditElemet.id && child.type != "label") {
                        $("#lbl_Roles").text(Elm.businessObject.name);
                    }
                });
            }
        });
    }
}

function fnopenRolepop(TxtArea, ElemId) {

    TxtArea.attr("disabled", "disabled");
    $("#btn_Asg_Role").click("");

    $("#btn_Asg_Role").click(function (evt) { evt.preventDefault(); fnAssignRoles(ElemId); });
    $("#Role_Dtls_Pop").show();

    if (TxtArea.val() != "") {
        var ToSetVal = $("#sel_PickRole option:contains(" + TxtArea.val() + ")").val();
        $("#sel_PickRole").val(ToSetVal).trigger("change");
    }
    else {
        $("#sel_PickRole").val("").trigger("change");
    }

}

function fnAssignRoles(EventElemId) {

    var sel_Role = document.getElementById("sel_PickRole");
    var SelRoleText = $("#sel_PickRole option:selected").text();

    var TxtArea = $(".djs-container textarea");
    TxtArea.val(SelRoleText);

    if (isDiagramLocal) {
        try {
            BPM_DB.transaction(function (tx) {
                var CheckExists = "SELECT 'x' FROM BPM_ROLE_MAS WHERE RolId='" + EventElemId + "'";
                var resCount = 0;
                var isDone = false;

                tx.executeSql(CheckExists, [], function (tx, result) {
                    resCount = result.rows.length;
                    if (resCount == 0) {
                        var Query = "INSERT INTO BPM_ROLE_MAS(RolId,RolNm,RolFk)" +
                            " SELECT '" + EventElemId + "', '" + SelRoleText + "', " + sel_Role.value + "";

                        tx.executeSql(Query, [], function (tx, result) {
                            isDone = true;
                            if (result.rowsAffected != 0) {
                                $("#Role_Dtls_Pop").hide();
                            }
                            else {
                                fnShflAlert("error", "Roles not Saved.");
                            }
                        });
                    }
                    else {
                        var Query = "UPDATE BPM_ROLE_MAS SET RolNm = '" + SelRoleText + "',RolFk=" + sel_Role.value + " WHERE RolId = '" + EventElemId + "'";
                        tx.executeSql(Query, [], function (tx, result) {
                            isDone = true;
                            if (result.rowsAffected != 0) {
                                $("#Role_Dtls_Pop").hide();
                            }
                            else {
                                fnShflAlert("error", "Roles not Saved.");
                            }
                        });
                    }
                });
            });
        } catch (e) { alert("error " + e); }
    }
    else {
        var ToSendRolJson = [];

        ToSendRolJson.push({ "LaneId": EventElemId, "RolFk": sel_Role.value })

        var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["SAVE_ROLES", "", JSON.stringify(GlobalXml), "", JSON.stringify(ToSendRolJson)] };
        fnCallWebService("SAVE_ROLES_RTN", objProcData, fnBPMResult, "MULTI");
    }

}




function fnLoadDecisionPg(IsAuto) {

    if (IsAuto == 0) {
        $("#auto_decision_div").hide();
        //$("#designDiv").css("display", "block");
        $("#designDiv").css("display", "inline-flex");
    }
    else {
        $("#auto_decision_div").show();
        $("#designDiv").css("display", "none");
    }
}

function fnGetFlowSeqJSON() {

    debugger
    elementRegistry = bpmnModeler.get('elementRegistry');
    var elements = elementRegistry.filter(function (element) {
        return element;
    });

    //Txtdownload(JSON.stringify(elements));
    //return;

    var ProcessJSON = []; var SeqJSON = []; var Incoming = []; var Outgoing = []; var LaneSet = []; var IsPartGiven = 0;

    var SE = elements.filter(it => it.type === "bpmn:StartEvent")
    if (SE.length == 0) {
        fnShflAlert("error", "Add StartEvent for the Process");
        return;
    }
    var EE = elements.filter(it => it.type === "bpmn:EndEvent")
    if (EE.length == 0) {
        fnShflAlert("error", "Add EndEvent for the Process");
        return;
    }

    for (var i in elements) {

        var ParentId = ""; var ProcId = ""; var ScrLabel = ""; var sourceRef = ""; var TargetRef = "";
        var eventDefinitions = "";

        var Type = elements[i].type;
        var id = elements[i].id;
   
        if (Type != "label") {

            try {
                ParentId = elements[i].businessObject.$parent.id;
            } catch (e) { ParentId = ""; }

            try {
                ScrLabel = elements[i].businessObject.name;
            } catch (e) { ScrLabel = ""; }

            try {
                eventDefinitions = elements[i].businessObject.eventDefinitions[0].$type;
            } catch (e) { eventDefinitions = ""; }

            if (Type == "bpmn:Participant") {
                IsPartGiven = 1;
                ProcId = elements[i].businessObject.processRef.id;
            }
            else { ProcId = ""; }

            var InObj; var OutObj; var LaneObj;

            if (Type == "bpmn:Lane") {
                var LaneObj = elements[i].businessObject.flowNodeRef;
                if (LaneObj != undefined) {
                    for (var lane = 0; lane < LaneObj.length; lane++) {
                        LaneSet.push({ LaneName: elements[i].businessObject.name, LaneId: elements[i].id, LaneFlowNodeId: LaneObj[lane].id })
                    }
                }
            }
            else if (Type == "bpmn:MessageFlow") {
                InObj = elements[i].businessObject.sourceRef;

                if (InObj != undefined) {
                    Incoming.push({ ProcId: elements[i].id, SourceId: InObj.id })
                }

                OutObj = elements[i].businessObject.targetRef;

                if (OutObj != undefined) {
                    Outgoing.push({ ProcId: elements[i].id, TargetId: OutObj.id })
                }
            }
            else {
                InObj = elements[i].businessObject.incoming;

                if (InObj != undefined) {
                    for (var j = 0; j < InObj.length; j++) {
                        Incoming.push({ ProcId: elements[i].id, SourceId: InObj[j].sourceRef.id })
                    }
                }

                OutObj = elements[i].businessObject.outgoing;

                if (OutObj != undefined) {
                    for (var z = 0; z < OutObj.length; z++) {
                        Outgoing.push({ ProcId: elements[i].id, TargetId: OutObj[z].targetRef.id })
                    }
                }
            }

            var ProcType = ((eventDefinitions) && eventDefinitions != "") ? eventDefinitions : elements[i].type;

            ProcessJSON.push({
                ProcType: ProcType,
                id: elements[i].id,
                ParentId: (ParentId == undefined) ? "" : ParentId,
                ProcId: ProcId,
                ProcLabel: (ScrLabel == undefined) ? "" : ScrLabel,
                eventDefn: (eventDefinitions == undefined) ? "" : eventDefinitions
            });
        }
    }
    if (LaneSet.length <= 0 && IsPartGiven == 0) {
        fnShflAlert("error", "Specify Roles for the Process");
        return;
    }
    else {

        var IsNameExists = 0;
        for (var Ln = 0; Ln < LaneSet.length; Ln++) {
            if (LaneSet[Ln].LaneName == undefined || LaneSet[Ln].LaneName == "") {
                IsNameExists = 1;
            }
        }
        if (IsNameExists == 1) {
            fnShflAlert("error", "Lane Name Required for All Lanes.");
            return;
        }
        else {

            bpmnModeler.saveXML({ format: true }, function (err, xml) {
                if (err) {
                    console.error('diagram save failed', err);
                } else {
                    SavedXml = xml;
                    fnSaveNewFlow(SavedXml, ProcessJSON, Incoming, Outgoing, LaneSet);
                }
            });
        }
    }
}

//added by Vijay S for Point 10 BPM Pivot Report 
function fnPivotRptGeneration(Pk) {
    var name, query, type, sessionDbId, URL;
    name = $("#ProcName").text();// + "_" + (!!GlobalXml[0].FlowVersNo ? (parseInt(GlobalXml[0].FlowVersNo) + 1) : "1");
    query = "PrcProcessReport ~:@ " + Pk;
    type = 1111;
    sessionDbId = "BPM";
    URL = "http://192.169.5.226/ABIS_SERVICES/Reports_Service/PrfoitRpt.asmx/new_rpt";

    $.ajax({
        type: "POST",
        url: URL,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: { param: name, param1: query, param2: query, param3: type, pageinfo: sessionDbId },
        dataType: "html",
        success: function (data) {
            //var objProcData = { ProcedureName: "PrcRmvFrmSymenu", Type: "SP", Parameters: [Pk.toString()] };
            //debugger;
            //fnCallWebService("Pivot_Rpt", objProcData, fnBPMResult, "MULTI", "");
        },
        error: function (data) {
            console.log("Error in Pivot Report Generation");
        }
    });
}

function fnBuildElem(id) {
    var Obj = {};
    $("#getDetails input").each(function () {
        if ($(this).attr("type") == "checkbox")
            Obj[$(this).attr("propName")] = $(this).prop("checked");
        else
            Obj[$(this).attr("propName")] = $(this).val();
    });

    if (UpdateFlg == true) {
        fnAddPageElem(Obj, UpdateDiv);
        UpdateFlg = false;
        UpdateDiv = "";
    }
    else {
        fnAddPageElem(Obj, id);
    }
    $("#myModal").css("display", "none");
}

function fnGetElemDetails(Elem) {
    $("#getDetails").html('');
    var Outerli = $("<li></li>");

    var Prop = Object.keys(Elem);
    var text = "";
    var isLabel = "";
    var isMand = false;
    var isHidden = false;//added by Vijay S
    for (var i = 0; i < Prop.length; i++) {
        var Attribute = Prop[i].toUpperCase();
        if (Attribute != "DISPNM") {

            if (Attribute == "innerText") { Attribute = "Text"; }

            var disabled = "";
            //modified by Vijay S for file attachement control
            //if (i == 0 || Prop[i] == "type") { disabled = "style='display:none;'"; Attribute = ""; }           
            if (i == 0 || Prop[i] == "type" || Prop[i] == "disabled" || Prop[i] == "col" || Prop[i] == "multiple" || Prop[i] == "onchange" || (Prop[i] == "value" && !!Elem.usrtype && Elem.usrtype == "config_integration")) { disabled = "style='display:none;'"; Attribute = ""; }
            else { Attribute += ":"; }

            //modified for Point 7
            if (Prop[i] != "isMandatory" && Prop[i] != "isHideHistory" && !Prop[i].startsWith("usrtype"))
                text += "" + Attribute + "<input propName='" + Prop[i] + "' type='text' value='" + Elem[Prop[i]] + "' " + disabled + "/>";
            else {
                if (Prop[i] == "isMandatory") isMand = Elem[Prop[i]] == true ? "checked" : "";
                if (Prop[i] == "isHideHistory") isHidden = Elem[Prop[i]] == true ? "checked" : "";
            }

            if (Prop[i].toLowerCase() == "label")
                isLabel = true;
        }
    }

    //added by Vijay S for Point 9
    if (!!xmlStr && !!Elem.usrtype && Elem.usrtype == "config_integration") {
        var Nodes = $(xmlStr).find("Node");                

        text += "<input propname='usrtype' value='config_integration' style='display:none;'><input propname='usrtype-value' value='' style='display:none;'>"
                + "DataSource<select id='usrtype_integration_1' name='DataSource' onchange='usrtypeSelectChange(this, $(this).val())'>"
                + "<option>--Select--</option>";

        for (var i = 0; i < Nodes.length; i++) { text += "<option>" + $(Nodes[i]).attr("TableName") + "</option>"; }

        text += "</select>"
                + "ColumnValue<select id='usrtype_integration_2' name='ColumnValue' onchange='usrtypeSelectChange(this, $(this).val())'>"
                + "<option>--Select--</option>"
                + "</select>";
    }

    if (Elem[Prop[0]] == "input" || Elem[Prop[0]] == "select" || Elem[Prop[0]] == "textarea") {//modified by Vijay for Point 7
        text += "<div style='text-align:center;'><input style='width: auto;' propName='isMandatory' type='checkbox' " + isMand + " />  Mandatory field <input style='width: auto;' propName='isHideHistory' type='checkbox' " + isHidden + " />  Hide in history </div>";
    }

    Outerli.append(text);            
    $("#getDetails").append(Outerli);
    if (!!Elem.value) {//for filling the values on second time opening 
        var val = JSON.parse(Elem.value);
        usrtypeSelectChange(Outerli.find("#usrtype_integration_1")[0], val.DataSource);
        usrtypeSelectChange(Outerli.find("#usrtype_integration_2")[0], val.ColumnValue);
    }
    UpdateFlg = false;
    UpdateDiv = "";
}

function usrtypeSelectChange(Elem, selected) {
    //assign the value to the current drop down and assign the drop down list for second drop down from config file    
    var selectedID = $(Elem).attr("id");
    var selectedIDNum = parseInt(selectedID.match(/\d$/));
    var selectedNext = $("[id^='usrtype_integration_" + (selectedIDNum + 1) + "'");
    //gettign details from config fiel xmlStr
    if (selectedNext.length > 0) {
        selectedNext.html("<option>--Select--</option>");
        var columns = $(xmlStr).find("Node[TableName='" + selected + "']").attr("ColList").split(",");
        for (var i = 0; i < columns.length; i++) { selectedNext.append("<option>" + columns[i] + "</option>"); }
    }    
    $(Elem).val(selected);
    var textObj = {}; var Prop = $("[id^='usrtype_integration_");    
    for (var i = 0; i < Prop.length; i++) { textObj[$(Prop[i]).attr("name")] = $(Prop[i]).val(); }
    $("input[propname='value']").attr("value", JSON.stringify(textObj));//assigning the values
    $("input[propname='usrtype-value']").attr("value", JSON.stringify(textObj));//assigning the values
}

function fnAddPageElem(Elem, appendDiv) {

    var Prop = Object.keys(Elem);
    var ElemId;
    var DynamElement;

    var Outerli = document.createElement("li");
    var Outerdiv = document.createElement("div");
    Outerdiv.className = "form-field left";

    for (var i = 0; i < Prop.length; i++) {

        if (i == 0) {
            DynamElement = document.createElement(Elem[Prop[i]]);
            DynamElement.id = Elem[Prop[i]] + "_" + guid();
            ElemId = DynamElement.id;
            Outerli.id = "li_" + ElemId;
            Outerdiv.id = "div_" + ElemId;
            Outerdiv.setAttribute("onclick", "fnEditElem('" + Outerdiv.id + "')");
            Outerdiv.setAttribute("disabled", "disabled");
            if (Elem["label"] != undefined && Elem["label"] != "") {
                Outerdiv.innerHTML = "<label class='frm-lbl'> " + Elem["label"] + " </label>";
            }
            Outerdiv.setAttribute("JsonData", JSON.stringify(Elem));
            Outerdiv.appendChild(DynamElement);
        }
        if (Elem[Prop[1]] == "checkbox") {
            if (Prop[i] != "value") {
                try {
                    DynamElement[Prop[i]] = Elem[Prop[i]];
                    DynamElement.setAttribute(Prop[i], Elem[Prop[i]]);
                }
                catch (e) {
                    DynamElement.setAttribute(Prop[i], Elem[Prop[i]]);
                }
            }
            //            else {
            //                var jsondata = JSON.parse(Elem[Prop[i]]);
            //                var op = "";
            //                for (var y = 0; y < jsondata.length; y++) {
            ////                    DynamElement[Prop[i]] = jsondata[i];
            ////                    DynamElement.setAttribute(Prop[i], jsondata[i]);
            // 
            //                    op += "<input type='checkbox' name = " + jsondata[i] + "/>jsondata[i]</br>";

            //                }
            //                    $(Elem[Prop[1]]).append(op); 
            //            }
        }
        else if (Elem[Prop[0]] == "select") {
            if (i == 0) {
                if (Elem[Prop[2]] == "query")
                    fnAddNormalSelectOptions(Elem[Prop[1]], DynamElement, 1);
                else
                    fnAddNormalSelectOptions(Elem[Prop[1]], DynamElement);
            }
        }
        else {
            try {
                DynamElement[Prop[i]] = Elem[Prop[i]];
                DynamElement.setAttribute(Prop[i], Elem[Prop[i]]);
            }
            catch (e) {
                DynamElement.setAttribute(Prop[i], Elem[Prop[i]]);
            }
        }
    }
    //added by Vijay S---Starts here for Point 2
    if (!!Elem.type && Elem.type == "file") {
        $(DynamElement).wrap('<div class="fileuplddiv"></div>');
        $(DynamElement).after('<div class="fileupldremark">Remarks: <input class="fileupldinput" type="text"></div>');
        $(DynamElement).after('<span title="Remove File" class="fileupldremove" style="margin-left: -15px;"></span>');
    }
    //added by Vijay S---Ends here

    //added by Vijay S---Starts here for Point 9
    //if (!!Elem.usrtype && Elem.usrtype == "config_integration") {
    //    var textObj = {};
    //    for (var i = 0; i < Prop.length; i++) {
    //        if (Prop[i].startsWith("usrtype_")) {
    //            var txt = Prop[i].substring(Prop[i].lastIndexOf("_") + 1)
    //            textObj[txt] = Elem[Prop[i]];
    //        }
    //    }
    //    $(Outerdiv.getElementsByTagName("input")).val(JSON.stringify(textObj));        
    //    $(Outerdiv.getElementsByTagName("input")).attr("contenteditable", "false");
    //}
    //added by Vijay S---Ends here

    if (UpdateFlg == true) {
        $("#" + appendDiv).after(Outerdiv);
        $("#" + appendDiv).remove();
    }
    else {
        Outerli.appendChild(Outerdiv);
        Outerli.innerHTML = Outerli.innerHTML + '<i delid=li_' + ElemId + ' style="cursor:pointer;" class="delli icon-delete right"></i>';
        document.getElementById(appendDiv).appendChild(Outerli);
    }

    $("#prop-list").css("display", "none");
    $("#inp-list").css("display", "block");

    $(".delli").click(function () {
        var delid = $(this).attr("delid");
        $("#" + delid).remove();

        UpdateFlg = false;
        UpdateDiv = "";

        $("#prop-list").css("display", "none");
        $("#inp-list").css("display", "block");
    });
}

function fnSaveUploadForm(type) {

    $("#htmlFilecontent").html("");
    $("#htmlFilecontent").load($("#htmlFile").val());
    EditURL = $("#htmlFile").val();

    //$("#htmlFilecontent").load(data[0]["ElemPageUrl"]);

    /*
    $("#htmlFilecontent").html("");
    var fileElem = $("#htmlFile").get(0);

    var files = fileElem.files;
    if (files.length == 0) {
        alert("Select file to attach");
        return;
    }
    var fileType = files[0].type;
    if (fileType != "text/html" && fileType != "application/xml") {
        alert("Select only html / aspx file");
        return;
    }
    var fileName = files[0].name;
    var fileSize = files[0].size;

    //alert(" file size is "+parseInt(fileSize/1024) + "Kb")
    var formObj = new FormData();
    formObj.append(files[0].name, files[0]);
    formObj.append("fileName", fileName);
    formObj.append("fileType", fileType);
    formObj.append("SavePath", "UploadedForms/" + GlobalXml[0].FlowFk);
    fnUploadFiles("UploadForm", formObj, fnBPMResult);
    */
}

function fnSaveUpdatePage(type, form) {
debugger
var SelVal = $("#selPageTyp .active").attr("val");
var ErrDesc = "";
   if ($("#elementDescCd").val() == "") {
    ErrDesc += "Enter Code"
    }
    if ($("#elementDescText").val() == "")
    {
        ErrDesc += "Enter Task"
   }
    if (ErrDesc != "")
    {
        fnShflAlert("error", ErrDesc);
        return;

    }//Added by Vijay S
    //SelVal - 0 Build , 1 - attach page
    //isPageorURL - 1 Url , 0 - json
    if (SelVal == 0) isPageorURL = 1;
    else isPageorURL = 0;

    if (isDiagramLocal) {
        fnStorePageInTempDB();
        return;
    }
}



function fnExportFile(FileType, Content, fileNm) {
    var a = document.createElement("a");
    var file = new Blob([Content], { type: FileType });
    a.href = URL.createObjectURL(file);
    a.download = fileNm;
    a.click();
}


function fnEditElem(divId) {

    $(".form-field").css({ "background": "" });
    $("#" + divId).css({ "background": "#DDDDDD" });
    var JsonData = $("#" + divId).attr("jsondata");
    var data = JSON.parse(JsonData)
    fnGetElemDetails(data);
    UpdateFlg = true;
    UpdateDiv = divId;
    $("#prop-list").css("display", "block");
    //$("#inp-list").css("display", "none");//modified by Vijay S
    $("#myModal").css("display", "block");
}


function fnCHangeXml(CalProc) {
    $(".li-tools").removeClass("active");
    $(".li-tools").addClass("active");
    var value = $("#projSelect").val();
    CurrentOpenProc = CalProc;

    if (value != "") {
        fnLoadXML(value);
    }
}

function selUserRole() {
    var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["LOAD_ROLES", "", JSON.stringify(GlobalXml), ""] };
    fnCallWebService("LOAD_ROLES", objProcData, fnBPMResult, "MULTI", "");
}

function fnClearForm(id) {
    $("#" + id).html("");
    $("#prop-list").css("display", "none");
    $("#inp-list").css("display", "block");
    UpdateFlg = false;
    UpdateDiv = "";
}

function fnSetDefaultVer(FlowVers) {
    $("#sel_version_div").html("");
    $("#sel_VerHis").html("");

    if (FlowVers.length > 0) {
        for (var i = 0; i < FlowVers.length; i++) {
            $("#sel_version_div").append("<option Rmks='" + FlowVers[i].Rmks + "' value=" + FlowVers[i].FlowFk + ">" + FlowVers[i].VerNo + "</option>");
            $("#sel_VerHis").append("<option Rmks='" + FlowVers[i].Rmks + "' value=" + FlowVers[i].FlowFk + ">" + FlowVers[i].VerNo + "</option>");
        }
        $("#sel_version_div").val(GlobalXml[0].FlowFk);
        $("#sel_VerHis").val(GlobalXml[0].FlowFk);
        $("#txt_VerHis").val($('option:selected', $("#sel_VerHis")).attr('Rmks'));
    }
    else {
        $("#sel_version_div").append("<option Rmks='' value='0'>Version 1</option>");
        $("#sel_VerHis").append("<option Rmks='' value='0'>Version 1</option>");
    }
}
function fnNewDiagram() {


    $(".li-tools").removeClass("active");
    var ProcNm = $("#ProcName").text();

    fnEnableDisableTools("Enable");
    CurrentOpenProc = 1;
    $(".li-tools").addClass("active");
    fnSetDefaultVer([])
    $(".ulProc").removeClass("active");
    $("#projSelect").val("0");
    $("#txt_ProcRmks").val("");
    $("#txt_VerHis").val("");

    //Added JPR
    GlobalXml[0].FlowNm = ProcNm;
    GlobalXml[0].FlowFk = "";
    GlobalXml[0].FlowXml = "";
    GlobalXml[0].ElemId = "";
    GlobalXml[0].CurPage = "";
    GlobalXml[0].createPageType = 0;
    GlobalXml[0].FlowVersNo = "";
    GlobalXml[0].FlowDpdFk = "";

    fnCreateTempDB();
    fnLoadDiagram("");
    isDiagramLocal = true;
    fnCreateNewFlow(ProcNm);

}

function fnLoadDefaultPage(type, e, DivID) {
    $("#AddField").hide();
    var outgoing = e.element.businessObject.outgoing;

    for (var i = 0; i < outgoing.length; i++) {
        var btnName = "";
        if (type == "decision") {
            btnName = outgoing[i].name == undefined ? 'default_text' : outgoing[i].name;
        }
        else if (type == "parallel") {
            btnName = outgoing[i].targetRef.name == undefined ? 'default_text' : outgoing[i].targetRef.name;
        }

        var obj = {};
        obj.elem = "input";
        obj.type = "button";
        obj.value = btnName;
        obj.label = "Target Page -  " + (outgoing[i].targetRef.name == undefined ? 'default_text' : outgoing[i].targetRef.name);
        obj.TgtId = outgoing[i].targetRef.id;
        fnAddPageElem(obj, DivID);
    }
}

// Added JPR
function fnCreateTempDB() {
    try {
        if (window.openDatabase) {
            window.BPM_DB = openDatabase('BPM_DB', '1.0', 'BPM PROCESS DB CONTAINS DETAILS AND PAGES', 2 * 1024 * 1024);
            BPM_DB.transaction(function (tx) {

                // Drop previous tables when loading first time
                tx.executeSql("DROP TABLE IF EXISTS BPM_FLOW_MAS;");
                tx.executeSql("DROP TABLE IF EXISTS BPM_ELEMENT_DETL;");
                tx.executeSql("DROP TABLE IF EXISTS BPM_ROLE_MAS;");

                tx.executeSql('CREATE TABLE IF NOT EXISTS BPM_FLOW_MAS(FlowPk INTEGER PRIMARY KEY AUTOINCREMENT,FlowName TEXT,FlowXml TEXT)');

                tx.executeSql('CREATE TABLE IF NOT EXISTS BPM_ELEMENT_DETL (IsStrt INTEGER,FlowFk INTEGER,ElemPk INTEGER PRIMARY KEY AUTOINCREMENT,ElemID TEXT,' +
                    'ElemDesc TEXT,ElemPageHtml TEXT,ElemPageUrl TEXT,ElemPageType INTEGER, ElemActDt DATE,ElemDelId INTEGER, IsAuto INTEGER,' +
                    'CmdTxt TEXT, ElemScript TEXT,ElemSubProcId INTEGER, ElmRmks TEXT, ElmCd TEXT,ElmIsRtnNeed INTEGER)');

                tx.executeSql('CREATE TABLE IF NOT EXISTS BPM_ROLE_MAS(RolePk INTEGER PRIMARY KEY AUTOINCREMENT,RolId TEXT,RolNm TEXT,RolFk TEXT)');
            });
            // fnTruncateTempDB();
        }
    }
    catch (e) {
        alert(e)
    }
}

// Added JPR
function fnTruncateTempDB() {
    try {
        if (window.openDatabase) {
            if (BPM_DB == null) { fnCreateTempDB(); return; }

            BPM_DB.transaction(function (tx) {
                tx.executeSql("DELETE FROM BPM_ELEMENT_DETL;");
                tx.executeSql("DELETE FROM BPM_FLOW_MAS;");
                tx.executeSql("DELETE FROM BPM_ROLE_MAS;");
            });
        }
    }
    catch (e) {
        alert(e)
    }
}
// Added JPR

// Added JPR
function fnCreateNewFlow(ProcNm) {
    try {
        if (window.openDatabase) {
            //if (BPM_DB == null) { fnCreateTempDB(); }
            fnCreateTempDB();
            BPM_DB.transaction(function (tx) {
                tx.executeSql("INSERT INTO BPM_FLOW_MAS(FlowName,FlowXml) VALUES('" + ProcNm + "','')");
            });
        }
    }
    catch (e) {
        alert(e)
    }
}

function fnLoadPageforElement(ElemId, urlOrPage, e, IsAuto) {
    debugger
    try {
        BPM_DB.transaction(function (tx) {
            var Query = "SELECT * FROM BPM_ELEMENT_DETL WHERE ElemID='" + ElemId + "' AND ElemDelId = 0;";
            tx.executeSql(Query, [], function (tx, result) {

                $("#designDiv-form-area,#designDiv-form-area-2,#designDiv-form-area-3").html("");
                $("#htmlFilecontent").html('');
                $("#txt_TskRmks").val("");
                $("#elementDescCd").val("");
                $("#sel_Automatic").prop("checked", false);
                $("#elementIsRtnNeed").prop("checked", true);
                //-----Edited by VM
                //if (result.rows.length == 0) {
                //    if (urlOrPage == 1)
                //        fnLoadDefaultPage('decision', e, 'designDiv-form-area');
                //        fnLoadDefaultPage('decision', e, 'designDiv-form-area-2');
                //        fnLoadDefaultPage('decision', e, 'designDiv-form-area-3');
                //    return;
                //}
                var data = result.rows;
                fnEnableDisableTabs(1);
                if (data.length != 0) {
                    $("#txt_TskRmks").val(data[0]["ElmRmks"]);
                    $("#elementDescCd").val(data[0]["ElmCd"]);
                    $("#sel_Automatic").prop("checked", data[0]["IsAuto"]);
                    $("#elementIsRtnNeed").prop("checked", data[0]["ElmIsRtnNeed"]);
                }
                if (urlOrPage == 1) {//Added by VM
                    fnEnableDisableDivs("Build");
                    fnLoadDefaultPage('decision', e, 'designDiv-form-area');
                    return
                }
                if (data.length != 0) {
                    if (data[0]["ElemPageUrl"] != "" && data[0]["ElemPageUrl"] != null) {
                        fnEnableDisableDivs("Attach");
                        $("#htmlFile").val(data[0]["ElemPageUrl"]);
                        $("#htmlFile").change();
                        //$("#htmlFilecontent").load(data[0]["ElemPageUrl"], function (e) { });

                        var htmlPath = data[0]["ElemPageUrl"];
                        var StrIndex = htmlPath.indexOf("~") + 1;
                        var StrFulLen = htmlPath.length;
                        //$("#htmlFile").val(htmlPath.substring(StrIndex, StrFulLen));
                    }
                    //else {
                    if (data[0]["ElemPageHtml"] != "" && data[0]["ElemPageHtml"] != null) { // If Saved Page is Builded.
                        fnEnableDisableDivs("Attach");
                        var PageJson = JSON.parse(data[0]["ElemPageHtml"] == "" ? "[]" : data[0]["ElemPageHtml"]);
                        for (var i = 0; i < PageJson.length; i++) {
                            if (PageJson[i].col == 0 || PageJson[i].col == undefined) {
                                fnAddPageElem(PageJson[i], "designDiv-form-area");
                            }
                            else if (PageJson[i].col == 1) {
                                fnAddPageElem(PageJson[i], "designDiv-form-area-2");
                            }
                            else if (PageJson[i].col == 2) {
                                fnAddPageElem(PageJson[i], "designDiv-form-area-3");
                            }
                        }
                    }
                    //if (e.element.type == "bpmn:ExclusiveGateway") { // added JPR

                    //    if (urlOrPage == 1)
                    //        fnLoadDefaultPage('decision', e, 'designDiv-form-area');
                    //    return;
                    //}
                }
            });

        });
    }
    catch (e) { alert(e) }
}

function fnSelectPageTable() {
    BPM_DB.transaction(function (tx) {
        var CheckExists = "SELECT * FROM BPM_ELEMENT_DETL WHERE ElemDelId = 0 ";
        var resCount = 0;
        tx.executeSql(CheckExists, [], function (tx, result) {
            //alert(result.rows.length);
            return result.rows;
        });
    });

}

function fnInsertElemDetails(IsStrt, ElemId, ElemCd, ElemDesc, ElemHtml, ElemPageUrl, Pagetype, SelProcId, Rmks, IsAuto, ElemIsRtnNeed) {

    IsAuto = (IsAuto == true) ? 1 : 0;
    ElemIsRtnNeed = (ElemIsRtnNeed == true) ? 1 : 0;
    var CndExp = $("#auto_decision_div").css("display") == "block" ? $("#auto_txt_cnd").val() : "";

    try {
        BPM_DB.transaction(function (tx) {
            var CheckExists = "SELECT 'x' FROM BPM_ELEMENT_DETL WHERE ElemID='" + ElemId + "' AND ElemDelId = 0 ";
            var resCount = 0;
            var isDone = false;
            tx.executeSql(CheckExists, [], function (tx, result) {
                if (Rmks != "") { $("#txt_TskRmks").val(Rmks); }
                resCount = result.rows.length;
                if (resCount == 0) {
                    var Query = "INSERT INTO BPM_ELEMENT_DETL(IsStrt,FlowFk,ElemID,ElemDesc,ElemPageHtml,ElemPageUrl,ElemPageType,ElemActDt,ElemDelId,IsAuto,CmdTxt,ElemScript,ElemSubProcId,ElmRmks,ElmCd,ElmIsRtnNeed) " +
                        " SELECT " + IsStrt + ",0,'" + ElemId + "','" + ElemDesc + "','" + ElemHtml + "','" + ElemPageUrl + "','" + Pagetype + "','" + CurDate + "',0, " + IsAuto + ", '" + CndExp + "','" + $("#script_div").text() + "', " + SelProcId + ",'" + $("#txt_TskRmks").val() + "', '" + ElemCd + "','" + ElemIsRtnNeed + "'";
                    tx.executeSql(Query, [], function (tx, result) {
                        isDone = true;
                        if (result.rowsAffected != 0) {
                            //alert("Page added successfully.");
                            if ($("#dialogDiv").css("display") == "block")
                                $("#dialogDiv").hide();

                            if ($("#HtmlBuilder_SP").css("display") == "block")
                                $("#HtmlBuilder_SP").hide();
                        }
                        else {
                            fnShflAlert("error", "Page not saved.");
                        }
                    });
                }
                else {
                    var Query = "UPDATE BPM_ELEMENT_DETL SET IsStrt = " + IsStrt + ",ElemDesc='" + ElemDesc + "',ElemPageUrl='" + ElemPageUrl + "'," +
                                "ElemPageType='" + Pagetype + "',ElemPageHtml='" + ElemHtml + "', IsAuto = " + IsAuto + " , CmdTxt = '" + CndExp + "'," +
                                "ElemScript = '" + $("#script_div").text() + "' , ElemSubProcId = " + SelProcId + "," +
                                "ElmRmks = '" + $("#txt_TskRmks").val() + "',ElmCd = '" + ElemCd + "',ElmIsRtnNeed='" + ElemIsRtnNeed + "'" +
                                "WHERE ElemId = '" + ElemId + "'";
                    tx.executeSql(Query, [], function (tx, result) {
                        isDone = true;
                        if ($("#dialogDiv").css("display") == "block")
                            $("#dialogDiv").hide();

                        // alert("Page added successfully.");
                    });
                }
            });
        });
    } catch (e) { alert("error " + e); }
}


function fnStorePageInTempDB() {
    //var formData = $('#source').val();
    debugger
    if ($("#elementDescCd").val() == "") {
        fnShflAlert("error", "Task Code Required !!");
        return false;
    }
    else if ($("#elementDescCd").val().length > 5) {
        fnShflAlert("error", "Task Code should not Exceed 5 Characters !!");
        return false;
    }
    if (EditElemet.type.toLowerCase() == "bpmn:endevent" || EditElemet.type.toLowerCase() == "bpmn:startevent") {
        var IsStrt = (EditElemet.type.toLowerCase() == "bpmn:startevent") ? 1 : 0;
        fnInsertElemDetails(IsStrt, EditElemet.id, $("#elementDescCd").val(), EditElemet.id + " Desc", "", "", pageType, 0, "", 0, $("#elementIsRtnNeed").is(':checked'));
        return;
    }

    // Added JPR
    var ErrDesc = "";
    var Url = EditURL;

    var htmltxt = "";
    //Added VM 
    if (pageType == 2) {
        var JsonData = [];
        var Nmcnt = 0;

        $("#designDiv-form-area .form-field,#designDiv-form-area-2 .form-field,#designDiv-form-area-3 .form-field").each(function () {
            var j = $(this).attr("jsondata");
            var dn = JsonData.filter(it => it.value.toUpperCase() === JSON.parse(j).value.toUpperCase() ) 
            //var dn = contains(JsonData, 'value', JSON.parse(j).value.toup)
            if (dn.length == 0) {
                JsonData.push(JSON.parse(j));
            }
            else {
                Nmcnt = 1;
            }
        });
        if (Nmcnt == 1) {
            ErrDesc += "Enter Different Output Names for EX Gate! <br/>";
        }
    }
    //--------------------
    if (isPageorURL == 0) {
        if (Url == "" || Url == null || Url == "0") {
            ErrDesc += "No Page is found. please attach page! <br/>";
        }
        htmltxt = "";
    }
    else if (isPageorURL == 1) {
        //Url = "";
        var JsonData = [];

        $("#designDiv-form-area .form-field,#designDiv-form-area-2 .form-field,#designDiv-form-area-3 .form-field").each(function () {
            var j = $(this).attr("jsondata");
            //if (isJson(j)) //commented by Vijay S as its not required
           JsonData.push(JSON.parse(j));

        //    var dn = contains(JsonData, 'value', JSON.parse(j).value)
        //    if (dn == true) {
        //        JsonData.push(JSON.parse(j));
        //    }
        //    else {
        //        ErrDesc += "Enter Different Output Names for EX Gate! <br/>";
        //    }
        });

        htmltxt = JSON.stringify(JsonData);
        if (htmltxt == "[]") {
            ErrDesc += "Add Fields to save page! <br/>";
        }
    }

    if (ErrDesc != "") {
        fnShflAlert("error", ErrDesc);
    }
    else {
        var IsStrt = (EditElemet.type.toLowerCase() == "bpmn:startevent") ? 1 : 0;
        var IsAuto = $("#sel_Automatic").is(":checked");
        fnInsertElemDetails(IsStrt, EditElemet.id, $("#elementDescCd").val(), EditElemet.id + " Desc", htmltxt, Url, pageType, 0, "", IsAuto, $("#elementIsRtnNeed").is(':checked'));
    }
}


function fnSaveNewFlow(Sendxml, ProcJSON, Incoming, Outgoing, LaneSet) {

    var ProcNm = $("#ProcName").text();
    var ErrDesc = "";
    if (ProcNm == null || ProcNm == undefined || ProcNm.trim() == "" || ProcNm.trim() == "Untitled") {
        fnShflAlert("error", "Process shouldn't be Untitled");
        $("#ProcName").focus();
        return;
    }
    for (var i = 0; i < ProcJSON.length; i++) {
        if (ProcJSON[i].ProcType != "bpmn:Collaboration" && ProcJSON[i].ProcType != "bpmn:Participant" && ProcJSON[i].ProcType != "bpmn:Lane" && ProcJSON[i].ProcType != "bpmn:SequenceFlow") 
            {
                if (ProcJSON[i].ProcLabel == "") {
                    fnShflAlert("error", "Task Name & Code Required for All Tasks !!!");
                    return;
                }
            }
        }

    BPM_DB.transaction(function (tx) {
        var CheckExists = "SELECT * FROM BPM_ELEMENT_DETL WHERE ElemDelId = 0 ";
        var resCount = 0;
        tx.executeSql(CheckExists, [], function (tx, result) {
            var PageData = result.rows;
            if (PageData == null || PageData == "" || PageData == undefined || PageData.length == 0) {
                fnShflAlert("error", "Page Specification Required !!!");
                return;
            }
            var StPg = 0;
            for (var i = 0; i < PageData.length; i++) {
                if (PageData[i].IsStrt == 1) {
                    StPg = 1;
                }
            }
            if (StPg == 0) {
                fnShflAlert("error", "Page Specification for Start Page is Mandatory !!!");
                return;
            }
            for (var i = 0; i < PageData.length; i++) {
                if (PageData[i].ElemPageUrl == "" && PageData[i].ElemPageType == 1 && PageData[i].ElemID.substring(0, 4) == "Task" ) {
                    fnShflAlert("error", "Attach Page for All Tasks!");
                    return;
                }

            }

            Txtdownload(Sendxml);
            var Action = (GlobalXml[0].FlowXml == "Edit") ? "PrcEdit" : "PrcSave";
            var EditPk = (GlobalXml[0].FlowXml == "Edit") ? GlobalXml[0].FlowDpdFk : 0;
            // var TblName = $("#txttblnm").val();
            var objProcData =
            {
                ProcedureName: "PrcShflBpmProcess",
                Type: "SP",
                Parameters:
                [
                    Action, $("#ProcName").text(), Sendxml, JSON.stringify(ProcJSON), JSON.stringify(Incoming), JSON.stringify(Outgoing),
                    JSON.stringify(PageData), JSON.stringify(LaneSet), JSON.stringify(GlobalXml), $("#txt_ProcRmks").val(),
                    $("#sel_TriggerSel").val(), EditPk//, TblName
                ]
            };

            fnCallWebService("NEW_PROJ", objProcData, fnBPMResult, "MULTI", "");

        });
    });
}


function fnShowDialog(div, title, width, height) {
    $(div).dialog({
        title: title,
        width: width,
        height: height,
        //maxWidth: 600,
        maxHeight: 600
    });
}

function fnClearDeginDialogDIv() {
    $("#elementDescText").val('');
    $("#elementDescCd").val('');
    fnEnableDisableTabs(1);
    $("#htmlFile").val('../BPMFLOW/SVS_Prototype/');
    $("#designDiv-form-area,#designDiv-form-area-2,#designDiv-form-area-3").html('');
    $("#htmlFilecontent").html('');
}

function fnEditorTemplate() {

    if (GlobalXml[0].FlowXml == "Edit" || GlobalXml[0].FlowXml == "New") {
        GlobalXml[0].ElemId = "";
        GlobalXml[0].CurPage = "";
        GlobalXml[0].createPageType = 0;
        isDiagramLocal = true;
        fnCreateNewFlow($("#ProcName").text());
    }
    else {
        fnShflAlert("warning", "No Flow is selected to change Version.");
    }
}

function fnGenerateId(Id) {
    //return;

    if (GlobalXml[0].FlowXml != "Edit") {
        bpmnModeler.invoke(function (elementRegistry, modeling) {

            if (Id == "") {
                // once user updates id in input field
                var elementsId = elementRegistry.filter(function (element) {
                    return element;
                });

                for (var eId in elementsId) {
                    var newId = elementsId[eId].id + "_" + generateGuid();
                    var serviceTaskShape = elementRegistry.get(elementsId[eId].id);

                    if (serviceTaskShape.type != "label") {
                        modeling.updateProperties(serviceTaskShape, {
                            id: newId
                        });
                    }
                }
            }
            else {
                var newId_Edit = Id + "_" + generateGuid();
                var serviceTaskShape_Edit = elementRegistry.get(Id);

                if (serviceTaskShape_Edit.type != "label") {
                    modeling.updateProperties(serviceTaskShape_Edit, {
                        id: newId_Edit
                    });
                }
            }
        });
    }
    return true;
}

function Txtdownload(text) {
    var dt = new Date();
    var filename = "ModelXml_" + dt.toString().replace(/ /g, "_") + dt.getTime();
    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    element.setAttribute('download', filename);

    element.style.display = 'none';
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}

function fnExportSVG() {
    drawInlineSVG($("svg"));
}


function drawInlineSVG(SVGelem) {
    try {
        if (SVGelem != undefined && SVGelem != null) {
            if (SVGelem.hasOwnProperty("length") || SVGelem.selector)
                SVGelem = SVGelem[0];
        }
        var rawSVG = $(SVGelem).html();
        rawSVG = "<svg xmlns='http://www.w3.org/2000/svg' xmlns:svg='http://www.w3.org/2000/svg' >" + rawSVG + "</svg>";
        var svg = new Blob([rawSVG], { type: "image/svg+xml;charset=utf-8" }),
        domURL = self.URL || self.webkitURL || self,
        url = domURL.createObjectURL(svg),
        img = new Image();
        img.width = 5000;
        img.height = 9000;
        var canvas = document.createElement("canvas");
        canvas.width = 5000;
        canvas.height = 9000;
        var ctx = canvas.getContext('2d');
        img.onload = function () {
            ctx.drawImage(this, 0, 0);
            domURL.revokeObjectURL(url);
            var link = document.createElement("a");
            link.href = canvas.toDataURL();
            link.download = "file.png";
            link.click();
        };
        img.src = url;
    }
    catch (e) {
        console.log(e);
    }
}
function fnchkoutgoing(e,type) {
    debugger
    var outgoing = e.element.businessObject.outgoing;
    for (var i = 0; i < outgoing.length; i++) {
        var btnName = "";
        if (type == "decision") {
            if (outgoing[i].name == undefined || outgoing[i].name == "") {
                fnShflAlert("error", "Add Outputs to the Gate");
                TxtArea.hide();
                return false;
            }
        }
    }

}
function fnaddPage() {
    var objProcData = { ProcedureName: "PrcShflBpm_Build", Type: "SP", Parameters: ["GetFlowPage", "", JSON.stringify(GlobalXml), ""] }
    fnCallWebService("FLOW_XML", objProcData, fnaddSourcPg, "MULTI");
}
function fnaddSourcPg(ServDesc, Obj) {
    var data = JSON.parse(Obj.result);
    var option = '<option value ="0" selected>Choose Page</option>';
    for (var i = 0; i < data.length; i++) {
        option += '<option value ="' + data[i].htmlFile + '">' + data[i].PageNm + '</option>';

    }

    $("#htmlFile").append(option);
}
function contains(arr, key, val) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i][key] === val) return true;
    }
    return false;
}
