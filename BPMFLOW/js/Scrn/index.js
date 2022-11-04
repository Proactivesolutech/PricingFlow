setLocalStorage("BpmUrl", "http:///172.23.124.134//BPM_RS//");
setLocalStorage("LosUrl", "http:///172.23.124.134//CommonRS//");
setLocalStorage("LosDB", "[PRICING_BPM_TRAINING]");

var GlobalXml = [{}];var UsrDataPk = 0;
var GlobalRoles = [];
var GlobalBrnch = [];
var gAutoDec = [];
var IsHaveQuery = false;
GlobalXml[0].IsRoleQc = "0";
GlobalXml[0].IsBranch = "0";
var cnt = 0;
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

function removeprop() {
    var ht = 0;
    $("#content_box").toggleClass("showhide");
    if ($("#content_box").height() < 130) {
        $("#content_box").toggleClass("showhide");
     //   $("#boxdiv").height('100px')
    }
    if ($("#content_box").height() > 230) {
        ht = $("#content_box").height() / 2;
        $("#boxdiv").height("" + ht + "px");
    }
    else {
        $("#boxdiv").height("345px");
    }
}

//addded by Vijay S for Point 7
//returns the object with list of controls having the isHideHistory field
function findHiddenInHistoryFields(resObj) {
    var key = "", value = "", retObj = {};
    var HideresObjs = resObj.filter(function (obj) { return obj["FlowJson"].indexOf("isHideHistory") > -1 });
    for (var i = 0; i < HideresObjs.length; i++) {
        var labelArr = [], PgNm = HideresObjs[i].PgNm;
        var JsonObj = JSON.parse(HideresObjs[i].FlowJson).filter(function (obj) { return obj["isHideHistory"] == true });
        for (var j = 0; j < JsonObj.length; j++) { labelArr.push(JsonObj[j].label); }
        retObj[PgNm] = labelArr;
    }
    return retObj;
}

function fnDrawPrevScrDatas(Obj) {
	curprcfk = JSON.parse(Obj.result_1)[0].PcPk;
    var MaxRwCnt = 0;var columncnt = 1;
    var MaxRwCnt = JSON.parse(Obj.result_6)[0].MaxRowCount;
    //added by Vijay S for Point 7
    var AttachmentString = Obj.result_7;
    var AttachmentSet = JSON.parse(AttachmentString);
    var isAttachmentPresent = AttachmentSet.length > 0 ? true : false;
    var resultCnt = Obj.ResultCount - MaxRwCnt;
    var removeFromFldLstArr = findHiddenInHistoryFields(JSON.parse(Obj.result_2));    
    try {
        var Content = "";
        
        if (MaxRwCnt > 0) {
            var LoopLen = MaxRwCnt + resultCnt;
            for (var i = resultCnt; i < LoopLen; i++) {
                var Result_Obj = JSON.parse(Obj["result_" + i]);
                var htmldata = JSON.parse(Obj["result_" + LoopLen])[i - resultCnt];
                var data_keys = Object.keys(Result_Obj[0]);
                var Header = [];

                //for (var kyData = 0; kyData < data_keys.length ; kyData++) {
                //    Header += '<th style="font-weight: bold;border: 1px solid black;border-width: 1px 1px 1px 1px;background-color: lightgray;padding: 3px;text-align: center;page-break-inside: avoid !important;" scope="col">' + data_keys[kyData] + '</th>';
                //}

                //for (var keyVal = 0; keyVal < Result_Obj.length; keyVal++) {
                //    Content += "<tr style='vertical-align: top; padding: 3px; page-break-inside: avoid !important;'>";
                //    for (var kyDatas = 0; kyDatas < data_keys.length ; kyDatas++) {
                //        Content += '<td>' + Result_Obj[keyVal][data_keys[kyDatas]] + '</td>';
                //    }
                //    Content += "</tr>";
                //}

                debugger;

                for (var keyVal = 0; keyVal < Result_Obj.length; keyVal++) {
                    var ExpTypicon = "";

                    if (Result_Obj[keyVal].Expense_Type == "Repair & Maintainence") {
                        ExpTypicon = "icon-repair";
                    }
                    else if (Result_Obj[keyVal].Expense_Type == "Stationery") {
                        ExpTypicon = "icon-stationery";
                    }
                    else if (Result_Obj[keyVal].Expense_Type == "Travel") {
                        ExpTypicon = "icon-travel";
                    }
                    else {
                        ExpTypicon = "icon-food";
                    }
                    //Added by Vijay S for Point 7                   
                    var FldLst = (Result_Obj[keyVal].FldLst).split(",");
                    var RemoveLst = removeFromFldLstArr[Result_Obj[keyVal].PgNm];
                    if (!!FldLst && !!RemoveLst && FldLst.length > 0 && RemoveLst.length > 0) {                                                
                        var xx = RemoveLst.filter(function (val) {
                            if (FldLst.indexOf(val) > -1) { FldLst.splice(FldLst.indexOf(val),1); }
                        });
                        Result_Obj[keyVal].FldLst = FldLst.join();
                    }                    

                    var AprOrRej = (Result_Obj[keyVal].AprOrRej == 1) ? "Rejected":"Approved";
                    var AprIcom = (Result_Obj[keyVal].AprOrRej == 1) ? "red-bg" : "green-bg";
                    var FieldLst = [];
                    var AmtVal = 0;
                    try{
                        AmtVal = Result_Obj[keyVal].Amount;
                    } catch (e) { AmtVal = 0; }

                    if (AmtVal > 0) {
//                        Content = Content +
//                        '<li>' +
//                        '<div class="div-left">' +
//                          '<h3>' + Result_Obj[keyVal].FlowNm + '</h3>' +
//                          '<p><span class="name">' + Result_Obj[keyVal].User + '</span>&nbsp; &nbsp; &nbsp;<span><i class="icon-calendar"></i> ' + Result_Obj[keyVal].ExecDt + ' </span> <div class="clear"></div></p>' +
//                        '</div>' +
//                        '<div class="div-left">' +
//                          '<i class="' + ExpTypicon + '"></i>' +
//                          '<span>' +
//                           '<h3>' + Result_Obj[keyVal].Payable_To + '</h3>' +
//                           '<p>' + Result_Obj[keyVal].Cost_Centre + '</p>' +
//                          '</span>' +
//                        '</div>' +
//                        '<div class="div-right amount">' +
//                          '<i class="icon-indian-rupee"></i><span>' + Result_Obj[keyVal].Amount + '</span>' +
//                        '</div>' +
//                        '<div class="clear"></div>' +
//                         '<p>' + Result_Obj[keyVal].Remarks + '</p>' +
                        //                      '</li>';
                        Content = Content +
                            '<li>' +
                            '<div class="div-left">' +
                                '<h3>' + Result_Obj[keyVal].FlowNm + '</h3>' +
                                '<p><span class="name" style="font-size:14px !Important;">' + Result_Obj[keyVal].User + '</span>&nbsp; &nbsp; &nbsp;<span><i class="icon-calendar"></i> ' + Result_Obj[keyVal].ExecDt + '</span> <div class="clear"></div></p>' +

                            '</div><div><h3>' + Result_Obj[keyVal].PgNm + '</h3></div>' +
                            '<div class="div-right status">' +
                                '<span class="' + AprIcom + '">' + AprOrRej + '</span>' +
                            '</div>' +
                        //                                                    '<div class="clear"></div>' +
                        //                                                    '<p>' + Result_Obj[keyVal].Approver_Remarks + '</p>' +
                        //                                                    '</li>';
                        // console.log(Result_Obj[keyVal].FldLst);

                        '<div class="clear"></div>';

                        columncnt = 1;                        
                        FieldLst.push(Result_Obj[keyVal].FldLst.split(",").splice(0, Result_Obj[keyVal].FldLst.split(",").length));
                        Content = Content + '<table style="border:none;background-color:#f5f5f5 !Important;"><tr id="rowdata_' + i + '" colspan=2 keyfk=' + htmldata['KeyFk'] + ' datapk=' + htmldata['DataPk'] + ' flowfk=' + htmldata['FlowFk'] + ' hispk=' + htmldata['HisPk'] + '  style="background-color:#f5f5f5;">';
                        for (var b = 0; b < FieldLst[0].length; b++) {
                            //   if (FieldLst[0][b].toLowerCase().indexOf('flowfk')==-1 && FieldLst[0][b].toLowerCase().indexOf('lastmodifiedtime')==-1 && FieldLst[0][b].toLowerCase().indexOf('isactive')==-1) {
                            //added by Vijay S
                            var tdText = Result_Obj[keyVal][FieldLst[0][b]] || "";
                            if (!!isAttachmentPresent && !!tdText && AttachmentString.indexOf('"' + tdText + '"') > 0) {
                                for (var filenum = 0; filenum < AttachmentSet.length; filenum++) {
                                    if (AttachmentSet[filenum].FileupldNewnm == tdText) {
                                        tdText = "<a class='fileDownload' href='" + AttachmentSet[filenum].FileupldPath + "' download>" + tdText.substring(tdText.lastIndexOf("___") + 3) + "</a>" + AttachmentSet[filenum].FileupldRemarks;
                                        break;
                                    }
                                }
                            }

                            Content = Content + '<td style="border:none;background-color:#f5f5f5 !Important;padding:2px !Important"><span>' + FieldLst[0][b] + ' : ' + tdText + '</span></td>';
                            columncnt = columncnt + 1;
                                if (columncnt > 4) {
                                    Content = Content + '</tr><tr>';
                                    columncnt = 1;
                                }
                        }
                        Content = Content + '</table>';
                        Content = Content + '</li>';
                    }
                    else {
                        Content = Content +
                            '<li>' +
                            '<div class="div-left">' +
                                '<h3>' + Result_Obj[keyVal].FlowNm + '</h3>' +
                                '<p><span class="name" style="font-size:14px !Important;">' + Result_Obj[keyVal].User + '</span>&nbsp; &nbsp; &nbsp;<span><i class="icon-calendar"></i> ' + Result_Obj[keyVal].ExecDt + '</span> <div class="clear"></div></p>' +
                                
                            '</div><div><h3>' + Result_Obj[keyVal].PgNm + '</h3></div>' +
                            '<div class="div-right status">' +
                                '<span class="' + AprIcom + '">' + AprOrRej + '</span>' +
                            '</div><div  id="container" style="float:right !Important; display:none"><input type="Button" class="button" onclick="ConfirmDialog(this,' + i + ');" style="float:right !Important;" name="Reevaluate" value="Reevaluate"></div>' + 
                            //<input type="Button" class="button" style="float:right !Important;" name="Reevaluate" value="Reevaluate"></div>' +
//                                                    '<div class="clear"></div>' +
//                                                    '<p>' + Result_Obj[keyVal].Approver_Remarks + '</p>' +
//                                                    '</li>';
                       // console.log(Result_Obj[keyVal].FldLst);

                        '<div class="clear"></div>';

                        columncnt = 1;
                        FieldLst.push(Result_Obj[keyVal].FldLst.split(",").splice(0, Result_Obj[keyVal].FldLst.split(",").length));
                        Content = Content + '<table style="border:none;background-color:#f5f5f5 !Important;"><tr id="rowdata_' + i + '" colspan=2 keyfk=' + htmldata['KeyFk'] + ' datapk=' + htmldata['DataPk'] + ' flowfk=' + htmldata['FlowFk'] + ' hispk=' + htmldata['HisPk'] + '  style="background-color:#f5f5f5;">';
                        for (var b = 0; b < FieldLst[0].length; b++) {
                         //   if (FieldLst[0][b].toLowerCase().indexOf('flowfk')==-1 && FieldLst[0][b].toLowerCase().indexOf('lastmodifiedtime')==-1 && FieldLst[0][b].toLowerCase().indexOf('isactive')==-1) {
                            //added by Vijay S
                            var tdText = Result_Obj[keyVal][FieldLst[0][b]] || "";
                            if (!!isAttachmentPresent && !!tdText && AttachmentString.indexOf('"' + tdText + '"') > 0) {
                                for (var filenum = 0; filenum < AttachmentSet.length; filenum++) {
                                    if (AttachmentSet[filenum].FileupldNewnm == tdText) {
                                        tdText = "<a class='fileDownload' href='" + AttachmentSet[filenum].FileupldPath + "' download>" + tdText.substring(tdText.lastIndexOf("___") + 3) + "</a>" + AttachmentSet[filenum].FileupldRemarks;
                                        break;
                                    }
                                }                                
                            }

                            Content = Content + '<td style="border:none;background-color:#f5f5f5 !Important;padding:2px !Important"><span>' + FieldLst[0][b] + ' : ' + tdText + '</span></td>';                            
                            columncnt = columncnt + 1;
                                if (columncnt > 4) {
                                    Content = Content + '</tr><tr>';
                                    columncnt = 1;
                                }
//                                if (b % 3 == 0 && b != 0) {

//                                    Content = Content + '</tr><tr>';
//                                }
                          //  }
                        }
                        Content = Content + '</table>';
                        Content = Content + '</li>';
                    }
                }
                //$("#div-user-content").append
                //('<table border="1" cellpadding="1" cellspacing="1" id="#ListDt" style="width:60%;border-collapse: collapse; border-spacing: 0; border: 0; font-size: 14px; margin: 5px 0;">' +
                //  '<thead  style="display: table-header-group;">' +
                //    '<tr class="bg-gray">' +
                //     Header +
                //    '</tr>' +
                //  '</thead>' +
                //  '<tbody style="display: table-row-group;">' +
                //  Content +
                //  '</tbody>' +
                //'</table>');
            }
        }
    } catch (e) {  }

    var Data_Ld = '<div class="expense-flow box-div" id="boxdiv" style="height:367px !Important;overflow:auto;">' +
              '<ul>' +
                Content +
              '</ul>' +
              '<div class="clear"></div>' +
            '</div>';
    $("#div-user-content").append(Data_Ld);
}
function fnCallBackFromBpm(Action, ResultSet1, ResultSet2, ResultSet3, ResultSet4, ResultSet5) {
    /*  1. Method for BPM Access to get Option List ( Return, Confirm & Move next, Conditions etc ) 
        5. Method to get the Previous Processes Executed User List with Roles ( For Query Module )
        ResultSet1 - Page Details, ResultSet2 - Return Details , ResultSet3 - Button Details 
    */
   
    
    if (Action == "GET_PGDTLS") {
        
        $(".dashboard-div").hide();
        if (ResultSet1[0].PageUrl != "" && ResultSet1[0].PageUrl != null) {
            LoadHtmlDiv(ResultSet1[0].PageUrl);
        }
        else {
            $("#div-user-content").empty();
            $("#div-user-content").append('<h1 style="display:inline-block;">' + ResultSet1[0].PgNm + '</h1><h1 style="display:inline-block;margin-left:37% !Important;">Process Id - ' + UsrDataPk + '</h1><h1 style="display:inline-block;float:right;">' + ResultSet1[0].Branch_Name + '</h1>');
            $("#hdr_title").html("<strong>" + ResultSet1[0].SbfdProcLabel + "</strong>");

            var final_PageJson = [];
            var PageJson = JSON.parse(ResultSet1[0].PageJson);
            var ValueJson = JSON.parse(ResultSet5.result_5);

            for (var j = 0; j < PageJson.length; j++) {
                var finalExpObj;
                for (var i = 0; i < ValueJson.length; i++) 
                    if (PageJson[j].label == ValueJson[i].label) {
                        finalExpObj = $.extend(PageJson[j], ValueJson[i]);
                        //added by Vijay S
                        if (finalExpObj.type == "file" && finalExpObj.disabled == "true") delete finalExpObj['disabled'];
                        delete finalExpObj['LeadPk'];
                        final_PageJson.push(finalExpObj);
                    }
            }
        

            $("#div-user-content").append('<div class="box-div" id="content_box" style="height:150px ;overflow:auto;"><ul id="designDiv-form-area" class="form-labels"></div><div class="slider"></div>');//edited by Vijay for dragbar
            for (var i = 0; i < final_PageJson.length; i++) {
                    if (final_PageJson[i].col == 0 || final_PageJson[i].col == undefined) {
                        fnAddPageElem(final_PageJson[i], 'designDiv-form-area');
                    }
//                    else if (final_PageJson[i].col == 1) {
//                        fnAddPageElem(final_PageJson[i], 'designDiv-form-area-2');
//                    }
			}
			// $("#content_box").css("display", "-webkit-box")
			$("#content_box").css("display", "flex")
			$("#content_box").append('<ul id="designDiv-form-area-2" style="padding-right:9%"  class="form-labels">');
			$("#designDiv-form-area").css("padding-right","9%")
			for (var i = 0; i < final_PageJson.length; i++) {

									 if (final_PageJson[i].col == 1) {
										fnAddPageElem(final_PageJson[i], 'designDiv-form-area-2');
									}
								}
			$("#content_box").append('<ul id="designDiv-form-area-3" class="form-labels">');
			for (var i = 0; i < final_PageJson.length; i++) {

				if (final_PageJson[i].col == 2) {
					fnAddPageElem(final_PageJson[i], 'designDiv-form-area-3');
				}
			}
            //commented by Vijay S
            //$("#content_box").prepend('<input type ="button" id="hidebtn" onclick="removeprop()" value="Show/Hide" name="hdbtn" style="float:right;right:2%;position:fixed;" />');
        }
        //added by Vijay s for Point 9 (no content should be there, in Integration Control)
        $("[usrtype='config_integration']").val("");
        fnBtnTemplate(1, ResultSet2, ResultSet3, ResultSet1);
        fnDrawPrevScrDatas(ResultSet5);
        fnLeadTrack(ResultSet4);
        fnSetQueryData();
    }

    /* 2. Method for BPM Access to Insert next flow ( Action for Option List ) */
    else if (Action == "FORWARD_DATA" || Action == "DEV_FORWARD_DATA") {
        if ($("#return-popup").css("display") == "block") {
            $("#return-popup").hide();
        }
        //fnLoadDashDtls();
        fnBtnTemplate(0);

    }

        /* 3. Method to get the Pending List from BPM ( Cases List )
           4. Method to get the List of Process, the role involves ( does not include Process having Trigger ) 
              ResultSet1 - Data List , ResultSet2 - Role Parameter.
        */
    else if (Action == "GET_PENDINGS_LIST") {
        fnBtnTemplate(0);
        //fnBuildDashDatas(ResultSet1, ResultSet2);
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
                        '<li class="width-1 read-only">'+
                            '<b><p>'+ GlobalXml[0].LeadNm +'</p></b>'+
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
    $("#border_div").css("width", "1200px")
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

        
        for (var btn = 0; btn < JsonBtnData.length; btn++) {
            var JsonData = JSON.parse(JsonBtnData[btn].JsonData);
            var IsAuto = JsonBtnData[btn].IsAuto;

            if (IsAuto == 1 && btn == 0) {
                $("#temp_btn_option").append
                    (
                        '<li onclick=fnMoveNxtLevel_new("Auto",1)>Confirm &amp; Handover</li>'
                    );
            }

            for (var i = 0; i < JsonData.length; i++) {
                if (IsAuto == 1) {
                    gAutoDec[JsonData[i].value] = JsonData[i].TgtId;
                }
                else {
                    var IsReject = (JsonData[i].value == "Reject") ? "R" : "";
                    var rejectionRemarksIcon = "";
                    if (IsReject == "RE") {
                        rejectionRemarksIcon = "<i onclick='fnReadRejectionRmks(this,event)' id='rejectionRmks' class='icon-chat-o right'></i>";
                    }
                    $("#temp_btn_option").append
                    (
                        '<li onclick=fnMoveNxtLevel_new(\'' + JsonData[i].TgtId + '\',1,\'\',"' + IsReject + '")>' + JsonData[i].value + rejectionRemarksIcon + '</li>'
                    );
                }
            }

        }

        return;

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
    return;
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
    
    /*
    var DashGlobal = [{}];
    DashGlobal[0].FlowFk = GlobalXml[0].CurVerFlowPk;
    DashGlobal[0].ProcFk = GlobalXml[0].CurProcFk;
    DashGlobal[0].UsrFk = GlobalXml[0].UsrPk;
    DashGlobal[0].UsrNm = GlobalXml[0].UsrNm;
    DashGlobal[0].AgtNm = GlobalXml[0].AgtNm;

    $("#dashboardQuery").setQueryProps(DashGlobal[0]);
    $("#dashboardQuery").setQuery();
    
    */
}

function fnIndexResult(ServDesc, Obj, Param1, Param2) {
    
    if (!Obj.status) {
        fnShflAlert("error", Obj.error);
        return;
    }
    if (ServDesc == "Location") {
        var Data = JSON.parse(Obj.result);
        for (var i = 0; i < Data.length; i++) {
            $("#" + Param2 + "").append('<option value ='+Data[i].GeoPk+' >'+Data[i].GeoNm+'</option>');
        }
           // alert(Data[0].GeoNm);
        //return
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
    UsrDataPk = Pk;
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
			//DynamElement.id = Elem["label"].replace(/ /g, "_");
            DynamElement.id = Elem["label"] != null ? Elem["label"].replace(/ /g, "_") : "";//Edited by Vijay S on 31-7-2017
            DynamElement.className = "Elem_Inp_Val";
            DynamElement.value = Elem["value"];
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
//                    if (ElemId.indexOf('Branch') != -1 || ElemId.indexOf('Location') != -1) {
//                        var objProcData = { ProcedureName: "PrcBpmSelect", Type: "SP", Parameters: ["Location", JSON.stringify(GlobalXml)] }
//                        fnCallWebService("Location", objProcData, fnIndexResult, "MULTI", ElemId);
//                    }
//                    else {
                        fnAddNormalSelectOptions(Elem[Prop[1]], DynamElement);
                    //}
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

    //added by Vijay S---Starts here
    if (!!Elem.type && Elem.type == "file") {
        $(DynamElement).wrap('<div class="fileuplddiv"></div>');
        $(DynamElement).after('<div class="fileupldremark">Remarks: <input class="fileupldinput" type="text"></div>');
        $(DynamElement).after('<span title="Remove" class="fileupldremove"></span>');
    }
    $(document).on('click', '.fileupldremove', function () {
        if (!!$(this).prev() && $(this).prev().attr("type") == "file" && $(this).prev().val() != '') $(this).prev().val('');        
    });
    //added by Vijay S---Ends here

    Outerli.appendChild(Outerdiv);
    document.getElementById(appendDiv).appendChild(Outerli);
//    $("#" + ElemId).css("margin-top", "-1%");
//    $("#" + ElemId).css("position", "absolute");
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