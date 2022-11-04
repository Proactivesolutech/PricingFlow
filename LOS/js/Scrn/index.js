setLocalStorage("BpmUrl", "http://192.169.1.92//LOS_NEW_RS//BPM_RS/");
setLocalStorage("LosUrl", "http://192.169.1.92//LOS_NEW_RS//LOS_RS/");
setLocalStorage("PdfUrl", "http://192.169.1.92//LOS_NEW_RS//JSONRender//JsonRender.svc/");
setLocalStorage("LosDB", "[SHFL_LOS]");

var GlobalXml = [{}];
var GlobalRoles = [];
var GlobalBrnch = [];
var gAutoDec = [];
var IsHaveQuery = false;
GlobalXml[0].IsRoleQc = "0";
GlobalXml[0].IsBranch = "0";

$(document).ready(function () {    

    dropButton();

    $("#return-popup .icon-close").click(function (e) {
        $("#return-popup").hide();
    });

    $("#list_newflow .icon-close").click(function (e) {
        $("#list_newflow").hide();
    });

    $("#tracking-div .icon-close").click(function (e) {
        $("#tracking-div").hide();
    });

    $(document).on("click", "#lead_add, #PF_add", function () {
        fnBtnTemplate(2);
    });
    $(document).on("click", "#cam_san", function () {
        fnBtnTemplate(2);
    });
});

function fnCallBackFromBpm(Action, ResultSet1, ResultSet2, ResultSet3, ResultSet4, ResultSet5) {
    /*  1. Method for BPM Access to get Option List ( Return, Confirm & Move next, Conditions etc ) 
        5. Method to get the Previous Processes Executed User List with Roles ( For Query Module )
        ResultSet1 - Page Details, ResultSet2 - Return Details , ResultSet3 - Button Details 
    */
   
    
    if (Action == "GET_PGDTLS") {
        if (ResultSet1[0].PageUrl != "" && ResultSet1[0].PageUrl != null)
            LoadHtmlDiv(ResultSet1[0].PageUrl);
        else {
            $("#div-user-content").empty();
            var PageJson = JSON.parse(ResultSet1[0].PageJson);
            $("#div-user-content").append('<div class="box-div"><ul id="designDiv-form-area" class="form-labels"></div>');

            for (var i = 0; i < PageJson.length; i++) {
                fnAddPageElem(PageJson[i], 'designDiv-form-area');
            }
        }
        fnBtnTemplate(1, ResultSet2, ResultSet3,ResultSet1);
        fnLeadTrack(ResultSet4);
        fnSetQueryData();
    }

    /* 2. Method for BPM Access to Insert next flow ( Action for Option List ) */
    else if (Action == "FORWARD_DATA" || Action == "DEV_FORWARD_DATA") {
        if ($("#return-popup").css("display") == "block") {
            $("#return-popup").hide();
        }
        fnLoadDashDtls();
        fnBtnTemplate(0);
    }

        /* 3. Method to get the Pending List from BPM ( Cases List )
           4. Method to get the List of Process, the role involves ( does not include Process having Trigger ) 
              ResultSet1 - Data List , ResultSet2 - Role Parameter.
        */
    else if (Action == "GET_PENDINGS_LIST") {
        fnBtnTemplate(0);
        fnBuildDashDatas(ResultSet1, ResultSet2);
        $(".drop-list").css("display", "none");
    }

    else if (Action == "LEAD_CREATE") {
        if ($("#list_newflow").css("display") == "block") {
            $("#list_newflow").hide();
        }
        fnLoadDashDtls();
    }
    else if (Action == "LEAD_LIST") {
        fnAdminListLead(ResultSet1, ResultSet2)
    }
}

function fnSetQueryData(){

    QryGlobal = [{}];
    QryGlobal[0].FlowFk = GlobalXml[0].CurVerFlowPk;
    QryGlobal[0].ProcFk = GlobalXml[0].CurProcFk;
    QryGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    QryGlobal[0].UsrFk = GlobalXml[0].UsrPk;
    QryGlobal[0].UsrNm = GlobalXml[0].UsrNm;
    QryGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    QryGlobal[0].LeadID = GlobalXml[0].LeadID;
    QryGlobal[0].AgtNm = GlobalXml[0].AgtNm;
 
    $("#QueryDiv").setQueryProps(QryGlobal[0]);
    $("#QueryDiv").setQuery();
}
/************Start Lead Track Details***********************************/
function fnLeadTrack(data)
{
    var n = 0;

    $("#tracking-div").empty();
    $("#tracking-div").append
     (
        '<div class="popup-div popup-large">' +
            '<div class="popup-header">' +
                '<h2>Case Tracker <i class="icon-close div-right"></i></h2>'+
            '</div>' + 
            '<div class="popup-content">' +
                 '<div class="tracking-div">' +
                    '<ul class="form-controls">'+
                        '<li style="text-align: center;">' +
                            ' <i class="icon-home-loan"></i>'+
                            '<p>'+ GlobalXml[0].PrdNm +'</p>'+
                        '</li>'+
                        '<li class="width-1 read-only">'+
                            '<label>Lead ID</label>'+
                            '<p>'+ GlobalXml[0].LeadID +'</p>'+
                        '</li>'+
                        ' <div class="clear"></div>'+
                    '</ul>'+
                    '<div class="tracking-content">' +
                        '<div id="border_div" class="track-border"></div>' +
                        '<div id="track_data_div" class="history-main">' +
                            '<h3 style="visibility:hidden;">Data Entry</h3>'+
                    '</div>' +
                 '</div>' +
            '</div>'+
        '</div>'
     );
     
    for (var i = 0; i < data.length; i++) {
        var StsCls = "bg1"; var EmptyClass = "";
        var nbsp = data[i].Dt + '(' + data[i].Tim + ')';

        if (data[i].HisPk == 0) {
            n += 50;
            StsCls = "bg";
            EmptyClass = "class='empty-div'";
            nbsp = "&nbsp;"
        }
        if (data[i].HisPk == 1) {
            n += 125;
            StsCls = "bg3";
        }
        else
            n += 125;

        $("#track_data_div").append
        (
            '<div  class="history-sub">' +
                 '<h4>'+ data[i].PgCd +'</h4>'+
                 '<span class="'+ StsCls +' round"></span>'+
                 '<p ' + EmptyClass + '>' + nbsp + '</p>' +
             '</div>' 
        );
    }
    $("#border_div").css("width", n.toString() + "px")
}


/************End Lead Track Details**********************************/

/***************************************************** Call Back Functions Starts *****************************************************************/
function fnBtnTemplate(Flg, RtnDetails, JsonBtnData,RtnDetails_1) {
    
    $("#btn_Trigger").hide();
    $("#temp_btn_option").empty();
    $("#temp_rtn_option").empty();
    $("#drop-button").show();
    $("#drop-button .icon-down-arrow").show();
    gAutoDec = [];

    if (Flg == 2) {
        $("#div_btnTemplate").show();
        $("#drop-button .icon-down-arrow").hide();
    }
    else if (Flg == 1) {
        $("#div_btnTemplate").show();

        if (JsonBtnData.length == 0) {

            if (RtnDetails.length > 0) {
                if (RtnDetails_1[0].IsRtnNeed == 1)
                {
                    $("#temp_btn_option").append
               (
                   '<li onclick=fnMoveNxtLevel("",0)>Confirm &amp; Handover</li>' +
                   '<li onclick=fnReturn()>Return</li>'
               );
                }
                else
                {
                    $("#temp_btn_option").append
               (
                 '<li onclick=fnMoveNxtLevel("",0)>Confirm &amp; Handover</li>'
               );
                }
               
            }
            else {
                $("#temp_btn_option").append
                (
                  '<li onclick=fnMoveNxtLevel("",0)>Confirm &amp; Handover</li>'
                );
            }
        }
        else {
            for (var btn = 0; btn < JsonBtnData.length; btn++) {
                var JsonData = JSON.parse(JsonBtnData[btn].JsonData);
                var IsAuto = JsonBtnData[btn].IsAuto;

                if (IsAuto == 1 && btn == 0) {
                    $("#temp_btn_option").append
                        (
                            '<li onclick=fnMoveNxtLevel("Auto",1)>Confirm &amp; Handover</li>'
                        );
                }

                for (var i = 0; i < JsonData.length; i++) {
                    if (IsAuto == 1) {
                        gAutoDec[JsonData[i].value] = JsonData[i].TgtId;
                    }
                    else {
                        var IsReject = (JsonData[i].value == "Reject") ? "R" : "";
                        var rejectionRemarksIcon = "";
                        if (IsReject == "R") {
                            rejectionRemarksIcon = "<i onclick='fnReadRejectionRmks(this,event)' id='rejectionRmks' class='icon-chat-o right'></i>";
                        }
                        $("#temp_btn_option").append
                        (
                            '<li onclick=fnMoveNxtLevel(\'' + JsonData[i].TgtId + '\',1,\'\',"' + IsReject + '")>' + JsonData[i].value + rejectionRemarksIcon + '</li>'
                        );
                    }
                }
            }
            if (RtnDetails.length > 0)
            {
                if (RtnDetails_1[0].IsRtnNeed == 1)
                    $("#temp_btn_option").append('<li onclick=fnReturn()>Return</li>');
            }
                
        }

        if (RtnDetails.length > 0) {
            if (RtnDetails_1[0].IsRtnNeed == 1) {
                $("#QryRtnTrigger").empty();

                for (var i = 0; i < RtnDetails.length; i++) {
                    $("#QryRtnTrigger").append
                    (
                        '<li binddata=\'' + JSON.stringify(RtnDetails[i]) + '\'>' + RtnDetails[i].PgNm + '</li>'
                    );
                }

                $("#QryRtnTrigger li").click(function () {
                    var IsSel = 0;
                    var selOption = $("input[name='Qry_opt']:checked").val();

                    var Strbinddata = $(this).attr("binddata");
                    binddata = JSON.parse(Strbinddata);

                    GlobalXml[0].TgtPageID = binddata.FlowId;
                    fnMoveNxtLevel(GlobalXml[0].TgtPageID, 0, selOption);
                });
            }
        }
    }
    else {
        $("#div_btnTemplate").hide();
        $(".drop-list").css("display", "none");
    }
}

function fnBuildDashDatas(Data, FlowData) {

    var HtmlPage = "dashboard.html";
    if (FlowData.length > 0) {
        $("#div_btnTemplate").show();
        $("#drop-button").hide();
        //$("#btn_Trigger").show();

        $("#div_flow_list").empty();

        /*
        GlobalXml[0].PIFlow = FlowData[0].FlowPk;
        GlobalXml[0].PNIFlow = FlowData[1].FlowPk;
        GlobalXml[0].BTFlow = FlowData[2].FlowPk;
        */

        for (var j = 0; j < FlowData.length; j++) {

            $("#div_flow_list").append
            (
                '<li onclick=fnGetLeadDtls(' + FlowData[j].FlowPk + ')>' + FlowData[j].FlowNm + '</li>'
            );
        }
    }
    else {
        $("#btn_Trigger").hide();
    }

    $("#div-user-content").empty();
    $("#div-user-content").load(HtmlPage, function (e) {
        var LosReqdDtls = [];

        for (var i = 0; i < Data.length; i++) {
            LosReqdDtls.push({ DataPk: Data[i].DataPk, Cd: Data[i].Cd, KeyDpdFk: Data[i].KeyDpdFk, HisPk: Data[i].PcPk })
        }
       
        var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["PENDING_LD_DTLS", JSON.stringify(GlobalXml), "", JSON.stringify(LosReqdDtls)] }
        fnCallLOSWebService("PENDING_LD_DTLS", objProcData, fnIndexResult, "MULTI", Data);
    });

}

function fnDrawDashboard(Data,AgData,leddata, AgtId) {
    
    var Appenddiv = $("#home_dashboard");
    var AgtAppenddiv = $("#Agt_home_dashboard");

    GlobalXml[0].LajFk = 0;
    GlobalXml[0].RefPk = 0;
    GlobalXml[0].LajAgtFK = 0;
    GlobalXml[0].ServiceType = 0;


    if (GlobalXml[0].IsBranch == "1") {
        $("#lead_add").css("display", "block");
        $("#PF_add").css("display", "block");

    }
    else {
        $("#lead_add").css("display", "none");
        $("#PF_add").css("display", "none");
    }

    if (GlobalXml[0].IsRoleQc == "1") {
        $("#cam_san").css("display", "none");
    }
    else {
        $("#cam_san").css("display", "block");
    }
    if (Data.length > 0) {       
        //COMP_DASHBRD.CompReady("#" + GlobalXml[0].DashDiv , function () {
        $(Appenddiv).setDashBoard(Data);
        //$("#right_panel").css("display:none")
        //});
    }
    if (GlobalXml[0].IsRoleQc == "1" && leddata.length > 0) {
        //COMP_DASHBRD.CompReady("#" + AgtId + GlobalXml[0].DashDiv, function () {
        $(AgtAppenddiv).setDashBoard(leddata, '', AgData,'');
        //});
    }
}

function fnSetWidth(Action) {
    var Tabs;
    $("#second_tab").empty();

    if (Action == "show") {
        $("#second_tab").addClass("div-half-height");
        $("#second_tab").html
        (
           '<comp-query width="100%" type="list" id="dashboardQuery"></comp-query>' +
           '<comp-dashboard width="100%" type="agent" id="Agt_home_dashboard"> </comp-dashboard>'
        );
    }
    else {
        $("#second_tab").removeClass("div-half-height");
        $("#second_tab").html
        (
           '<comp-query width="100%" type="list" id="dashboardQuery"></comp-query>'
        );
    }
    
    var DashGlobal = [{}];
    DashGlobal[0].FlowFk = GlobalXml[0].CurVerFlowPk;
    DashGlobal[0].ProcFk = GlobalXml[0].CurProcFk;
    DashGlobal[0].UsrFk = GlobalXml[0].UsrPk;
    DashGlobal[0].UsrNm = GlobalXml[0].UsrNm;
    DashGlobal[0].AgtNm = GlobalXml[0].AgtNm;

    $("#dashboardQuery").setQueryProps(DashGlobal[0]);
    $("#dashboardQuery").setQuery();
}

function fnIndexResult(ServDesc, Obj, Param1, Param2) {
    debugger
    if (!Obj.status) {
        fnShflAlert("error",Obj.error);
        return;
    }
    if (ServDesc == "IS_PENDING_QUERY") {
        var Data = JSON.parse(Obj.result);
        
        if (GlobalXml[0].RtnOption == 0) {
            if (Data[0].QryExists == "0") {

                if (window["fnCallScrnFn"]) {
                    fnCallScrnFn("true", Param2);
                }
                else {
                    fnShflAlert("error", "No Common Function found !!");
                }
            }
            else
                fnShflAlert("error", "Resolve the pending Queries for this Lead!!");
        }
        else {
            fnCallFinalConfirmation("true");
        }
        
    }
    if (ServDesc == "LEAD_DTLS") {
        var Data = JSON.parse(Obj.result);
        fnGetBpmHelpFor("LEAD_CREATE", Data, Param2, GlobalXml[0].UsrCd);
    }
    else if (ServDesc == "PENDING_LD_DTLS") {
        var Data = JSON.parse(Obj.result_1);
        var AgData = JSON.parse(Obj.result_2);
        var leddata = [];
        try { leddata = JSON.parse(Obj.result_3); } catch (e) { }

        var FinalDashArr = [];
        var FinalAgtArr = [];

        /*var finaldata = $.merge(Data, Param2);*/
        for (var i = 0; i < Param2.length; i++) {
            var finDash; var finAgt;

            for (var j = 0; j < Data.length; j++) {
                if (Data[j].LedFk == Param2[i].DataPk && Data[j].HisPk == Param2[i].PcPk) {
                    finDash = $.extend(Data[j], Param2[i]);
                    FinalDashArr.push(finDash);
                }

            }

            if (AgData.length > 0) {
                for (var k = 0; k < AgData.length; k++) {
                    if (AgData[k].LedFk == Param2[i].DataPk && AgData[k].HisPk == Param2[i].PcPk) {
                        finAgt = $.extend(AgData[k], Param2[i]);
                        FinalAgtArr.push(finAgt);
                    }

                }
            }
        }

        fnDrawDashboard(FinalDashArr, FinalAgtArr, leddata, "Agt_");
    }
}

function fnGetLeadDtls(FlowPk) {
    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["LEAD_DTLS", JSON.stringify(GlobalXml)] }
    fnCallLOSWebService("LEAD_DTLS", objProcData, fnIndexResult, "MULTI", FlowPk);
}
/***************************************************** Call Back Functions Ends *****************************************************************/

/***************************************************** Send BPM Request Starts *********************************************************************/

/*  1. Method for BPM Access to get Option List ( Return, Confirm & Move next, Conditions etc ) 
        5. Method to get the Previous Processes Executed User List with Roles ( For Query Module )
        ResultSet1 - Page Details, ResultSet2 - Return Details , ResultSet3 - Button Details 
*/
function fnLoadDataStatus(row, Id) {
    
    Id = Id ? Id : "";

    var RowNo = $(row).attr("rowNo");
    var rowpk = $(row).attr("Pk");
    var Appenddiv = $("#" + Id + "home_dashboard");
    var RowJson;

    if (Id != "Agt_")
        RowJson = $(Appenddiv)[0].DataSource[RowNo];
    
    var DropDownData = $(Appenddiv)[0].DropDownData;
    var FilterData = $(DropDownData).filter(function () {
        return this.Pk == rowpk;
    });
    
    if (RowJson == undefined)
        var RowJson = FilterData[0];

    var HisPk = RowJson.PcPk;
    var PrdCd = RowJson.PCd;
    var LeadNm = RowJson.LeadNm;
    var LeadID = RowJson.LeadID;
    var PrdFk = RowJson.PrdFk;
    var Branch = RowJson.Branch;
    var AppNo = RowJson.AppNo;
    var AgtNm = RowJson.AgtNm;
    var AgtFk = RowJson.AgtFk;
    var BranchFk = RowJson.BpmBranchFk;
    var Pk = RowJson.DataPk;
    var FlowPk = RowJson.FlowPk;
    var BfwFk = RowJson.BfwFk;

    GlobalXml[0].HisPK = HisPk;
    GlobalXml[0].FwdDataPk = Pk;
    GlobalXml[0].CurVerFlowPk = FlowPk;
    GlobalXml[0].CurProcFk = BfwFk;
    GlobalXml[0].BrnchFk = BranchFk;
    GlobalXml[0].PrdCd = PrdCd;
    GlobalXml[0].PrdNm = RowJson.PrdNm;
    GlobalXml[0].LeadNm = LeadNm;
    GlobalXml[0].LeadID = LeadID;
    GlobalXml[0].PrdFk = PrdFk;
    GlobalXml[0].AgtNm = AgtNm;
    GlobalXml[0].AgtFk = AgtFk;
    GlobalXml[0].Branch = Branch;
    GlobalXml[0].AppNo = AppNo;
    GlobalXml[0].GlobalDt = RowJson.ServerDt;
    GlobalXml[0].TgtPageID = "";
    GlobalXml[0].LajFk = RowJson.LajFk;
    GlobalXml[0].RefPk = RowJson.Pk;
    GlobalXml[0].LajAgtFK = RowJson.LajAgtFK;
    GlobalXml[0].JobAgentName = RowJson.JobAgentName;
    GlobalXml[0].ServiceType = RowJson.ServiceType;
    GlobalXml[0].LfjFk = RowJson.LfjPk;
    GlobalXml[0].PrdGrpFk = RowJson.PrdGrpFk;
    GlobalXml[0].DpdFk = RowJson.DpdFk;
    GlobalXml[0].GrpCd = RowJson.GrpCd;
    GlobalXml[0].CLvlNo = RowJson.CLvlNo;
    GlobalXml[0].DLvlNo = RowJson.DLvlNo;

    $("#right_panel").show();

    fnGetBpmHelpFor("GET_PGDTLS", HisPk, BfwFk, Pk, FlowPk, GlobalXml[0].UsrPk, BranchFk)
}

/* 2. Method for BPM Access to Insert next flow ( Action for Option List ) */
function fnMoveNxtLevel(TgtPgId, DblEntry, RtnOption, Param1) {
    if (Param1 == "R") {
        var rmks = ($("#rejectionRmks").attr("remarks") || "").trim();
        if (rmks == "")
        {
            fnShflAlert("warning", "Enter Rejection Remarks.");
            setTimeout(function () { $(".error-div").fadeOut("slow"); }, 300);
            $("#rejection-popup").show();
            return;
        }
        var objProcData = { ProcedureName: "PrcShflRejectionRemark", Type: "SP", Parameters: ["REJECTION_REMARKS", GlobalXml[0].FwdDataPk, rmks, GlobalXml[0].UsrNm] }
        fnCallLOSWebService("REJECTION_REMARKS", objProcData, fnIndexResult, "MULTI", Param1);
    }
    if (TgtPgId == "Auto") { TgtPgId = GlobalXml[0].TgtPageID; }
    RtnOption = (RtnOption == 2 || RtnOption == 1) ? RtnOption : 0;

    GlobalXml[0].TgtPageID = TgtPgId;
    GlobalXml[0].DblEntry = DblEntry;
    GlobalXml[0].RtnOption = RtnOption;

    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["IS_PENDING_QUERY", JSON.stringify(GlobalXml)] }
    fnCallWebService("IS_PENDING_QUERY", objProcData, fnIndexResult, "MULTI", Param1);

}

function fnConfirmScreenFinal() {
    if (window["fnCallScrnFn"]) {
        fnCallScrnFn("false");
    }
    else {
        fnShflAlert("error", "No Common Function found !!");
    }
}

function fnCallFinalConfirmation(IsMoveNext, DevTyp) {

    if (IsMoveNext == "true")
    {
        
        if (DevTyp && DevTyp != "") {
            var LvlNo = (DevTyp == "D") ? GlobalXml[0].DLvlNo : GlobalXml[0].CLvlNo;

            fnGetBpmHelpFor("DEV_FORWARD_DATA", GlobalXml[0].UsrPk, GlobalXml[0].HisPK, GlobalXml[0].BrnchFk, LvlNo, DevTyp);

            GlobalXml[0].TgtPageID = "";
            GlobalXml[0].DblEntry = 0;
            GlobalXml[0].RtnOption = 0;
        }
        else {
            fnGetBpmHelpFor("FORWARD_DATA", GlobalXml[0].HisPK, GlobalXml[0].CurProcFk, GlobalXml[0].FwdDataPk, GlobalXml[0].CurVerFlowPk,
                        GlobalXml[0].UsrPk, GlobalXml[0].TgtPageID, GlobalXml[0].DblEntry, GlobalXml[0].RtnOption, GlobalXml[0].BrnchFk,
                        GlobalXml[0].DpdFk);

            GlobalXml[0].TgtPageID = "";
            GlobalXml[0].DblEntry = 0;
            GlobalXml[0].RtnOption = 0;
        }
    }
    else
        fnLoadDashDtls();
}


/* 3. Method to get the Pending List from BPM ( Cases List )
   4. Method to get the List of Process, the role involves ( does not include Process having Trigger ) 
       ResultSet1 - Data List , ResultSet2 - Role Parameter.
*/
function fnLoadDashDtls() {
    $("#right_panel").hide();
    $(".right-content-div").hide();
    $("#third_tab").hide();
    $("#link_Dash").show();
    $("#Lead_His").show();

    fnGetBpmHelpFor("GET_PENDINGS_LIST", GlobalXml[0].UsrPk, GlobalXml[0].UsrCd);
}

/***************************************************** Send BPM Request Ends *********************************************************************/

function LoadHtmlLoginDiv(HtmlPage, Role, ToAppend) {

    $("#div-user-content").empty();
    $("#div-user-content").load(HtmlPage, function (e) {
        
    });
}

function fnLoadQrytoPick(QrytoSend, DynamElementId) {
    var objProcData = { ProcedureName: "$Query", QryTxt: QrytoSend, Parameters: [] };
    fnCallWebService("BIND_SEL_DATA", objProcData, fnProjResult, "MULTI", DynamElementId);
}

function fnAddPageElem(Elem, appendDiv) {
    
    var Prop = Object.keys(Elem);
    var ElemId;
    var DynamElement;

    var Outerli = document.createElement("li");
    var Outerdiv = document.createElement("div");
    Outerdiv.className = "form-field";

    for (var i = 0; i < Prop.length; i++) {

        if (i == 0) {
            DynamElement = document.createElement(Elem[Prop[i]]);
            DynamElement.id = Elem[Prop[i]] + "_" + guid();
            ElemId = DynamElement.id;
            Outerli.id = "li_" + ElemId;
            Outerdiv.id = "div_" + ElemId;
            Outerdiv.setAttribute("disabled", "disabled");
            if (Elem["label"] != undefined && Elem["label"] != "") {
                Outerdiv.innerHTML = "<label class='frm-lbl'> " + Elem["label"] + " </label>";
            }
            Outerdiv.setAttribute("JsonData", JSON.stringify(Elem));
            Outerdiv.appendChild(DynamElement);
        }

        if (Elem[Prop[0]] == "select") {
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
    Outerli.appendChild(Outerdiv);
    document.getElementById(appendDiv).appendChild(Outerli);
    $("#prop-list").css("display", "none");
    $("#inp-list").css("display", "block");
    $("#" + Outerli.id).css("display", "block");
    $("#" + Outerli.id).css("width", "300px");
}

function fnReturn() {
    $("#return-popup").show();
}

function fnShowFlowDtls() {
    $("#list_newflow").show();
}


function dropButton() {
    $("#drop-button i").click(function (e) {
        e.stopImmediatePropagation();
        $("#" + $(this).parent().attr("id") + " .drop-list").toggle();
    });
}

function fnLoadagtjob(ele) {
    var dashboard = $(ele).closest("comp-dashboard");
    var leadpk = $(ele).attr("leadpk");
    if (dashboard != undefined && dashboard != null) {
        if (dashboard.hasOwnProperty("length") || dashboard.selector)
            dashboard = dashboard[0];
    }
    if ($(dashboard).find(".agt-lead-drop-down").length > 0)
    { $(dashboard).find(".agt-lead-drop-down").remove(); return; }

    var dropDownData = dashboard.DropDownData;        
    var repeatSrc = dashboard.AgtrepeatSource;
    var apndSrc =  "";
    for (var a = 0; a < dropDownData.length; a++) {
        if (dropDownData[a].LajLedFk == leadpk) {
            var data_keys = Object.keys(dropDownData[a]);
            var apndSrc_1 = repeatSrc;
            for (var i = 0; i < data_keys.length; i++) {
                var toReplaceRowNo = new RegExp("{{rowNo}}", "g");
                apndSrc_1 = apndSrc_1.replace(toReplaceRowNo, a);

                var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                apndSrc_1 = apndSrc_1.replace(toReplace, dropDownData[a][data_keys[i]]);
            }

            apndSrc += apndSrc_1;
        }
    }
    $(ele).after(apndSrc);
}


/* FOR REJECTION REMARKS */
function fnSetRejectionRemarks() {
    var remarks = ($('#rejection-textarea').val() || "").trim();
    if (remarks == "") {
        fnShflAlert("warning", "Enter Rejection Remarks.");
        setTimeout(function () { $(".error-div").fadeOut("fast"); }, 500);
        $('#rejection-textarea').focus();
        return;
    }
    /*if (remarks.split(/\s+/).length < 20) {
        fnShflAlert("warning", "Rejection Remarks should be minimum 20 words.");
        setTimeout(function () { $(".error-div").fadeOut("fast"); }, 800);
        $('#rejection-textarea').focus();
        return;
    }
    */
    $('#rejectionRmks').attr('remarks', remarks);
    setTimeout(function () { $("#rejection-popup").fadeOut("fast"); }, 100);
}

function fnCancelRejctionRmks() {
    if (confirm("do you want to cancel?")) {
        $('#rejection-textarea').val('');
        $('#rejectionRmks').attr('remarks', '');
        setTimeout(function () { $("#rejection-popup").fadeOut("fast"); }, 100);
    }
}


function fnReadRejectionRmks(elem, e) {
    var event = e || window.event;    
    if (event.target && event.target.tagName && event.target.tagName == "I") {
        e.stopImmediatePropagation();
        var rmk = $('#rejectionRmks').attr('remarks')
        $('#rejection-textarea').val(rmk);
        setTimeout(function () { $("#rejection-popup").fadeIn("fast"); }, 100);
    }
}