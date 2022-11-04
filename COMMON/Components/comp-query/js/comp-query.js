var COMP_QUERY = {};
var BpmURL = getLocalStorage("BpmUrl") + "RestServiceSvc.svc/fnDataAccessService";
var gDbName = getLocalStorage("LosDB");

(function ($) {
    $.fn.setQuery = function () {

        var elem = this;
        if (elem != undefined && elem != null) {
            if (elem.hasOwnProperty("length") || elem.selector)
                elem = elem[0];
        }
        
        GlobalXml[0].IsAll = 0;
        var Qelem = elem;
        var LeadFk = Qelem.LeadFk;
        var Raised_User = Qelem.UsrFk;
        var FlowFk = Qelem.FlowFk;
        var ProcFk = Qelem.ProcFk;
        var Qtype = elem.getAttribute("type") || elem.type;
        Qtype = Qtype ? Qtype : "";
        var where = " AND QrhKeyFk = " + LeadFk + " ";
        if (Qtype.toLowerCase() == "list") {
            where = "";
        }

        var data_qry = "DECLARE @HdrRef TABLE(HdrFk BIGINT);"

        data_qry += "INSERT INTO @HdrRef(HdrFk)" +
                    "SELECT QrdQrhFk FROM" +
                    "(" +
	                    " SELECT  QroQrdFk 'QrdFk'" +
	                    " FROM	QryOut " +
	                    " WHERE	QrOUsrFk = " + Raised_User +
	                    " UNION ALL " +
	                    " SELECT  QrIQrdFk 'QrdFk'" +
	                    " FROM	QryIn " +
	                    " WHERE	QrIUsrFk = " + Raised_User +
                    ")A" +
                    " JOIN QryDtls(NOLOCK) ON QrdPk = QrdFk AND QrdDelid = 0" +
                    " GROUP BY QrdQrhFk;"

        data_qry += " SELECT DISTINCT a.QrhPk hdrpk,a.QrhKeyFk,a.QrhBvmFk,e.QrcNm category,d.UsrPk usrPk,d.UsrDispNm users,CONVERT(VARCHAR,a.QrhCreatedDt,103) date, a.QrhKeyFk KeyFk," +
                        "KeyNm LedNm, '' LedId, ISNULL(QrhSoln,0) Soln ,ISNULL([UsrInvolve],'')[UsrInvolve]" +
                        " FROM QryHdr(NOLOCK) a " +
                        " JOIN QryDtls(NOLOCK) b ON a.QrhPk=b.QrdQrhFk AND b.QrdSeqNo = 1  AND (a.QrhSoln is null or a.QrhSoln!=1)  AND EXISTS(SELECT 'X' FROM @HdrRef WHERE HdrFk = QrdQrhFk)" +
                        " JOIN QryOut(NOLOCK) c ON b.QrdPk = c.QroQrdFk AND c.QroDelid = 0" +
                        " JOIN GenUsrMas(NOLOCK) D ON d.UsrPk=c.QrOUsrFk" +
                        " JOIN QryCategory(NOLOCK) e ON a.QrhQrcFk=e.QrcPk  " +
                        " JOIN " + gDbName + ".dbo.BpmFlowKeyTable(NOLOCK) L ON L.KeyPk=a.QrhKeyFk " +
                        " LEFT JOIN (SELECT T.QrdQrhFk,STUFF((SELECT ',' + CONVERT(varchar(10),  x.usr)" +
                        " FROM (select * from (select * from (select QrdQrhFk,QriUsrFk [usr] from QryDtls   left join Qryin  on QrdPk= QriQrdFk)a"+
                        "  union all "+
                        "  (select QrdQrhFk,QrOUsrFk [usr] from QryDtls   left join Qryout on QrdPk= QroQrdFk ) ) t"+
                        "  where [usr] != " + Raised_User + ") x" +
                        " WHERE x.QrdQrhFk = t.QrdQrhFk" +
                        " GROUP BY x.usr" +
                        " FOR XML PATH ('')), 1, 1, '')[UsrInvolve]" +
                        " FROM (select * from (select * from (select QrdQrhFk,QriUsrFk [usr] from QryDtls   left join Qryin  on QrdPk= QriQrdFk)a"+
                        " union all "+
                        " (select QrdQrhFk,QrOUsrFk [usr] from QryDtls   left join Qryout on QrdPk= QroQrdFk ) ) t"+
                        "  where [usr] != " + Raised_User + ") T" +
                        " GROUP BY T.QrdQrhFk) T ON a.QrhPk=T.QrdQrhFk" +
                        where +
                        " ORDER BY a.QrhPk DESC; ";
        data_qry += " SELECT h.QrhPk hdrpk,c.UsrPk usrPk,c.UsrDispNm usr,b.QrdNotes msg, h.QrhKeyFk KeyFk  " +
                        " FROM QryIn(NOLOCK) a " +
                        " JOIN QryDtls(NOLOCK) b ON a.QrIQrdFk=b.QrdPk AND EXISTS(SELECT 'X' FROM @HdrRef WHERE HdrFk = QrdQrhFk)" +
                        " JOIN QryOut(NOLOCK) e ON b.QrdPk = e.QroQrdFk AND a.QrIQroFk = e.QrOPk AND e.QroDelid = 0" +
                        " JOIN GenUsrMas(NOLOCK) c ON e.QrOUsrFk=c.UsrPk " +
                        " JOIN QryHdr(NOLOCK) h ON b.QrdQrhFk=h.QrhPk " +
                        where +
                        " GROUP BY h.QrhPk,c.UsrPk,c.UsrDispNm,b.QrdNotes,h.QrhKeyFk,b.QrdPk " +
                        " ORDER BY h.QrhPk,b.QrdPk;";
                     // alert(data_qry);
        var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: data_qry, Parameters: [], HtmlString: "" };
        
        $.ajax({
            type: "POST",
            url: BpmURL,
            contentType: "application/json;charset=utf-8",
            data: JSON.stringify(objProcData),
            dataType: "json",
            success: function (data) {
                COMP_QUERY.form_data(JSON.parse(data), elem);
                //alert(JSON.parse(JSON.parse(data).result_1)[0].KeyFk);
            },
            error: function (result) { }
        });
    };
})(jQuery);

COMP_QUERY.extend = {
    setQueryProps: function (QProps) {
        if (!QProps && QProps == null) {
            return;
        }
        var elem = this;
        if (elem != undefined && elem != null) {
            if (elem.hasOwnProperty("length") || elem.selector)
                elem = elem[0];
        }
        $(elem).prop("UsrNm", QProps.UsrNm);
        $(elem).prop("LeadFk", QProps.LeadFk);
        $(elem).prop("UsrFk", QProps.UsrFk);
        $(elem).prop("FlowFk", QProps.FlowFk);
        $(elem).prop("ProcFk", QProps.ProcFk);
        $(elem).prop("LeadNm", QProps.LeadNm);
        $(elem).prop("LeadID", QProps.LeadID);

        $(elem).find("#query_leadNo").html(QProps.LeadID);
        $(elem).find("#query_leadName").html(QProps.LeadNm);
        $(elem).find("#UsrRaised").html(QProps.UsrNm);
    }
};

$.fn.extend(COMP_QUERY.extend);

COMP_QUERY.createComponent_query = function (TagName, HtmlSrc) {

    var ElementProto = Object.create(HTMLElement.prototype);
    //ElementProto = Object.create(Element.prototype);  

    ElementProto.createdCallback = function () {

    }

    ElementProto.setQueryProps = COMP_QUERY.extend.setQueryProps;

    ElementProto.LeadFk = 0;
    ElementProto.UsrFk = 0;
    ElementProto.FlowFk = 0;
    ElementProto.ProcFk = 0;
    ElementProto.UsrNm = "";
    ElementProto.LeadNm = "";
    ElementProto.LeadID = "";

    ElementProto.attachedCallback = function () {

        /* Changing the content */
        var shadow = this;
        var repeatsource = "";
       // $(shadow).setQuery();
    }
    ElementProto.detachedCallback = function () {

    }
    ElementProto.attributeChangedCallback = function (attrName, oldValue, newValue) {

    }

    var MyElement = document.registerElement(TagName, { prototype: ElementProto });

    COMP_QUERY.LeadPage = function (d, elem) {
        var j = JSON.parse(d.result)
        
        var Get_ScrnDtls = [];
        var Get_ScrObj = {};
        if (j.length > 0) {
            GlobalXml[0].FwdDataPk = j[0].KeyFk;
            Get_ScrObj["DataPk"] = j[0].KeyFk;
            Get_ScrObj["Cd"] = j[0].BudCd;
            var PgCd = j[0].BudCd;
            var PgNm = j[0].PgNm;
            if (PgCd == "FIR" || PgCd == "FIO" || PgCd == "FIS" || PgCd == "DV" || PgCd == "CF" || PgCd == "LV" || PgCd == "TV")
                GlobalXml[0].IsRoleQc = "1";
            else
                GlobalXml[0].IsRoleQc = "0";

            Get_ScrnDtls.push(Get_ScrObj);

            if (PgCd.toUpperCase() == "FIR" || PgCd.toUpperCase() == "FIO" || PgCd.toUpperCase() == "CF" || PgCd.toUpperCase() == "DV") {
                fnShflAlert("warning", "Provision not provided for "+ PgNm +" !!");
                return false;
            }
            else {
                var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["PENDING_LD_DTLS_ADM", JSON.stringify(GlobalXml), "", JSON.stringify(Get_ScrnDtls)] }
                fnCallLOSWebService(j[0].BudURL, objProcData, fnLeadInfo, "MULTI", URL);
            }
        }
        else
        {
            alert("No Page");
        }
    }
    function fnLeadInfo(ServDesc, Obj, Param1, Param2) {
        
       
            var Data = JSON.parse(Obj.result_1);
            var SetData;

            if (Data.length > 0)
                SetData = Data;
            else
                SetData = JSON.parse(Obj.result_2);

            GlobalXml[0].PrdCd = SetData[0].PCd;
            GlobalXml[0].PrdNm = SetData[0].PrdNm;
            GlobalXml[0].LeadNm = SetData[0].LeadNm;;
            GlobalXml[0].LeadID = SetData[0].LeadID;;
            GlobalXml[0].PrdFk = SetData[0].PrdFk;;
            GlobalXml[0].AgtNm = SetData[0].AgtNm;;
            GlobalXml[0].AgtFk = SetData[0].AgtFk;; 
            GlobalXml[0].Branch = SetData[0].Branch;;
            GlobalXml[0].AppNo = SetData[0].AppNo;
            GlobalXml[0].GlobalDt = SetData[0].ServerDt;
            GlobalXml[0].LajFk = SetData[0].LajFk;
            GlobalXml[0].RefPk = SetData[0].Pk;
            GlobalXml[0].LajAgtFK = SetData[0].LajAgtFK;
            GlobalXml[0].JobAgentName = SetData[0].JobAgentName;
            GlobalXml[0].ServiceType = SetData[0].ServiceType;
            GlobalXml[0].LfjFk = SetData[0].LfjFk;
            GlobalXml[0].DpdFk = SetData[0].DpdFk;
            GlobalXml[0].IsAll = 1;
            
            LoadHtmlDiv(ServDesc);
        
    }
    var src = [];
    
    COMP_QUERY.form_data = function (d, elem) {
        var shadow = elem;
        //if (d.result_1 != "[]") {
        
        var LeadFk = shadow.LeadFk;
        var Raised_User = shadow.UsrFk;
        var UsrNm = shadow.UsrNm;
        var FlowFk = shadow.FlowFk;
        var ProcFk = shadow.ProcFk;
        var LeadNm = shadow.LeadNm || "";
        var LeadID = shadow.LeadID || "";
        LeadNm = LeadNm == "" ? "" : LeadNm;
        LeadID = LeadID == "" ? "" : LeadID;
        src = [];
        var j = JSON.parse(d.result_1)

        for (var i = 0; i < j.length; i++) {
            LeadNm = LeadNm == "" ? j[i].LedNm : LeadNm;
            LeadID = LeadID == "" ? j[i].LedId : LeadID;
            ProcessIDKey = j[i].KeyFk;
            var bg = "query_bg3";
            var icon = "query_icon-pending";
            var visibile = "display:block;pointer-events:none;";
            var Msg = "Pending";
            var Sts = "0";
            var reply = "display:block;pointer-events:initial;"
            var cursor = "cursor:pointer;"
            var Paging = "display:none;"

            if (j[i].Soln == "1") {
                bg = "query_bg1";
                icon = "query_icon-positive";
                Msg = "Resolved";
                Sts = "1";
            }
            else if (j[i].Soln == "2") {
                bg = "query_bg2";
                icon = "query_icon-negative";
                Msg = "Not Ok";
                Sts = "2";
            }
            if (shadow.LeadFk == "0") {
                Paging = "display:block;"
            }

            if (j[i].usrPk == Raised_User) {
                visibile = "display:block;pointer-events:initial;";
                if (j[i].Soln == "1") 
                    cursor = "cursor:no-drop;"
            }
            else
            {
                visibile = "display:block;";
                cursor = "cursor:no-drop;"
            }
            
            src.push({
                Query_Category: j[i].category, LeadRef: LeadID, Lead_Name: LeadNm, LeadInfo_LeadFk: j[i].KeyFk, LeadInfo_PageVersion: j[i].QrhBvmFk, LeadInfo_UserFk: shadow.UsrFk, Raised_id: j[i].UsrInvolve, Raised_User: j[i].users, Raise_date: j[i].date,
                Query: j[i].Qry, hdrpk: j[i].hdrpk, bg: bg, PendingCls: icon,Paging:Paging, visibility: visibile, PendingMsg: Msg, Sts: Sts, reply: reply,
                cursor: cursor
            });
            LeadNm = ""; LeadID = "";
        }
        var usrsrc = [];
        
        var u = JSON.parse(d.result_2);
        for (var i = 0; i < u.length; i++) {
            //Added by Vijay S
            var msgData = u[i].msg; var attachmentData = ""; var pathData = "";
            var typeOf = function () { try { return typeof JSON.parse(u[i].msg); } catch (e) { return "";}};
            if (typeOf() == "object") {
                var queryObj = JSON.parse(u[i].msg);
                msgData = queryObj.QueryComment;
                pathData = queryObj.QueryFilePath;
                var QueryAttach = queryObj.QueryAttachments;
                for (var j = 0; j < QueryAttach.length; j++) {
                    attachmentData += "<a class='fileDownload' href='..\\Rs\\" + pathData + QueryAttach[j] + "' download>" + QueryAttach[j].substring(QueryAttach[j].lastIndexOf("___") + 3) + "</a>,  ";
                }
            }
            if (!!attachmentData) {
                attachmentData = attachmentData.trim().replace(/,$/, '');
                usrsrc.push({ hdrpk: u[i].hdrpk, Pk: u[i].usrPk, Name: u[i].usr, Msg: msgData, QueryAttachments: attachmentData });
            } else
                usrsrc.push({ hdrpk: u[i].hdrpk, Pk: u[i].usrPk, Name: u[i].usr, Msg: msgData, QueryAttachments: "No Attachments" });
        }
     
        var source = src;

        var globaldata = {
            repeatData: { id: "QueryList", src: source, usr: usrsrc },
            setData: []
        };

        var loginusr = "Administrator";
        var AppendData = globaldata;
        var htmltoAppend = "";
        if (HtmlSrc && HtmlSrc != "") {
            var textContent = document.querySelector("#" + HtmlSrc).import;
            htmltoAppend = textContent.querySelector("custom-component").innerHTML;
        } else {
            htmltoAppend = document.getElementById("HtmlSrc").innerHTML;
        }

        if (AppendData != null && typeof AppendData == "object") {
            var setData = AppendData.setData;
            if (setData && typeof setData == "object") {
                var data_keys = Object.keys(setData);
                for (var i = 0; i < data_keys.length; i++) {
                    var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                    htmltoAppend = htmltoAppend.replace(toReplace, setData[data_keys[i]]);
                }
            }
            shadow.innerHTML = htmltoAppend;

            var comp = shadow;
            
            var Qtype = comp.getAttribute("type") || comp.type;
            Qtype = Qtype ? Qtype : "";
            $(comp).find("#query_leadNo").html(comp.LeadID);
            $(comp).find("#query_leadName").html(comp.LeadNm);
            $(comp).find("#UsrRaised").html(comp.UsrNm);
            
            var componentWidth = comp.getAttribute("width") || comp.width || "100%";
         //   var componentHeight = comp.getAttribute("height") || comp.height || "100%";
            var themecolor = comp.getAttribute("themecolor") || comp.themecolor || "";
            var style = comp.getAttribute("style") || comp.style || "";

            var repeatDataSrc = AppendData.repeatData;
            var RepeatId = repeatDataSrc.id;
            var repeatData = repeatDataSrc.src;
            var users = repeatDataSrc.usr;
            repeatsource = shadow.querySelector("#" + RepeatId).innerHTML;
            if (!localStorage.getItem("QryRaisehtml") || localStorage.getItem("QryRaisehtml") == "" || localStorage.getItem("QryRaisehtml") == undefined)
                localStorage.setItem("QryRaisehtml", repeatsource);
            else
                repeatsource = localStorage.getItem("QryRaisehtml");
            shadow.querySelector("#" + RepeatId).innerHTML = "";
            if (repeatData.length >= 1) {
                shadow.querySelector("#" + RepeatId).innerHTML = "";
                var repeatsourceTxt = "";
                var Globalsrc = "";
                var grpusrs = [];
                var tmpusrs = [{}];
                for (var i = 0; i < repeatData.length; i++) {
                    tmpusrs = [];
                    tmpusrs.push({ hdr_pk: repeatData[i].hdrpk });
                    //grpusrs.push({ hdr_pk: repeatData[i].hdrpk });
                    for (var j = 0; j < users.length; j++) {
                        if (users[j]["hdrpk"] == repeatData[i].hdrpk) {
                            tmpusrs.push({ Name: users[j]["Name"], msg: users[j]["Msg"]});
                        }
                    }
                    grpusrs.push(tmpusrs);
                }
                var MsgPk = [];
                for (var a = 0; a < repeatData.length; a++) {
                    repeatsourceTxt += repeatsource;
                    var usrexists = false;
                    var data_keys = Object.keys(repeatData[a]);
                    for (var i = 0; i < data_keys.length; i++) {
                        var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                        repeatsourceTxt = repeatsourceTxt.replace(toReplace, repeatData[a][data_keys[i]]);
                    }
                    var msgsrc = $(repeatsourceTxt).find(".query_reply-div").html();
                    var tmppk = "";
                    //for (var x = 0; x < users.length; x++) {
                    //    if (loginusr == users[x]["Name"]) {
                    //        tmppk = users[x]["hdrpk"];
                    //        break;
                    //    }
                    //    else
                    //    { users.splice(x,1); }
                    //}
                    var pkref = repeatData[a].hdrpk;
                    var msgsrctxt = "";
                    //if (MsgPk.indexOf(repeatData[a].hdrpk) == -1) {
                    for (var j = 0; j < users.length; j++) {
                        if (users[j]["hdrpk"] == repeatData[a].hdrpk) {
                            if (MsgPk.indexOf(repeatData[a].hdrpk) == -1)
                                MsgPk.push(repeatData[a].hdrpk);
                            msgsrctxt += msgsrc;
                            var comm_keys = Object.keys(users[j]);
                            for (var k = 0; k < comm_keys.length; k++) {
                                var toReplace = new RegExp("{{" + comm_keys[k] + "}}", "g");
                                msgsrctxt = msgsrctxt.replace(toReplace, users[j][comm_keys[k]]);
                            }
                            usrexists = true;
                        }

                    }
                    //}

                    var html = $(repeatsourceTxt);

                    html.find('.query_reply-div div').replaceWith(msgsrctxt);

                    $(repeatsourceTxt).find(".query_reply-div").replaceWith(msgsrctxt);
                    if (usrexists == true) { Globalsrc += "<div class=\"query_notify-cnt\">" + html.html() + "</div>"; }

                    repeatsourceTxt = "";
                }
                shadow.querySelector("#" + RepeatId).innerHTML = Globalsrc;
            }
            //CKEDITOR.replace("rplyTxtArea", {toolbar : [{ name: 'basicstyles', items: ['Bold', 'Italic', 'Strike'] }]});
        }
        else { }
        // }
        shadow1 = elem;

        var currentDate = new Date();
        var day = currentDate.getDate();
        var month = currentDate.getMonth() + 1;
        var year = currentDate.getFullYear();
        var usr_qry = "select usrpk,UsrDispNm Users from GenUsrMas(NOLOCK) WHERE UsrDelID = 0 AND usrpk!="+shadow.UsrFk;


        var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: usr_qry, Parameters: [], HtmlString: "" };

        //$.ajax({
        //    type: "POST",
        //    url: BpmURL,
        //    contentType: "application/json;charset=utf-8",
        //    data: JSON.stringify(objProcData),
        //    dataType: "json",
        //    success: function (data) {
        //        COMP_QUERY.usr_data(JSON.parse(data));
        //    },
        //    error: function (result) { }
        //});

        var opt = "";
        var optcategry = "";
        COMP_QUERY.usr_data = function (data) {
            
            opt = "";
            var res = JSON.parse(data.result);
            for (var i = 0; i < res.length; i++) {
                opt += "<option value='" + res[i].usrpk + "'>" + res[i].Users + "</option>";
            }

            var sel_Toaddr = $(elem.querySelector("#query_sel_Toaddr"));
            $(sel_Toaddr).empty();
            $(sel_Toaddr).append(opt);
            $(sel_Toaddr).select2({
                width: '100%',
                theme: "classic",
                tags: false,
                minimumInputLength: 1
            });

            //var sel_ReplyTo = $(elem.querySelectorAll(".query_sel_ReplyTo"));
            //$(sel_ReplyTo).each(function () {
            //    
            //    $(this).append(opt);

            //    $(this).select2({
            //        width: '100%',
            //        theme: "classic",
            //        tags: false,
            //        minimumInputLength: 1,
            //    });
            //    // $(this).val($(this).find('option[text="' + $(this).parent(".query_comment-div").children()[3].innerHTML + '"]').val()).trigger("change");
            //    var selectedValues = new Array();
            //    selectedValues = $(this).parent(".query_comment-div").children(".query_Raised_id")[0].value.split(",");
            //    $(this).val(selectedValues).trigger('change');
            //});
        }
        COMP_QUERY.usr_data_1 = function (data, e) {
            
            opt = "";
            var res = JSON.parse(data.result);
            for (var i = 0; i < res.length; i++) {
                opt += "<option value='" + res[i].usrpk + "'>" + res[i].Users + "</option>";
            }
           
       
            
            var select = $(e.currentTarget).parent(".query_pending-icon").parent(".query_details").children(".query_comment-div").children(".query_sel_ReplyTo")[0];
            $(select).empty();
            $(select).append(opt);
                
            $(select).select2({
                    width: '100%',
                    theme: "classic",
                    tags: false,
                    minimumInputLength: 1,
                });
                // $(this).val($(this).find('option[text="' + $(this).parent(".query_comment-div").children()[3].innerHTML + '"]').val()).trigger("change");
                var selectedValues = new Array();
                selectedValues = $(select).parent(".query_comment-div").children(".query_Raised_id")[0].value.split(",");
                $(select).val(selectedValues).trigger('change');
           
        }

        var query_Sts = $(shadow1.querySelectorAll(".query_Sts"));
        $(query_Sts).click(function (e) {
            e.preventDefault();
            
            if ($(this).css("cursor") == "no-drop")
                return;

            if ($(this).attr("sts") == "0") {
                $(this).attr("sts", "1");
                $(this).removeClass("query_bg3");
                $(this).addClass("query_bg1");
                $(this).children("i").removeClass("query_icon-pending");
                $(this).children("i").addClass("query_icon-positive");
                $(this).children("span").html("Resolved");
            }
            else if ($(this).attr("sts") == "1") {
                $(this).attr("sts", "2");
                $(this).removeClass("query_bg1");
                $(this).addClass("query_bg2");
                $(this).children("i").removeClass("query_icon-positive");
                $(this).children("i").addClass("query_icon-negative");
                $(this).children("span").html("Not Ok");
            }
            else if ($(this).attr("sts") == "2") {
                $(this).attr("sts", "0");
                $(this).removeClass("query_bg2");
                $(this).addClass("query_bg3");
                $(this).children("i").removeClass("query_icon-negative");
                $(this).children("i").addClass("query_icon-pending");
                $(this).children("span").html("Pending");
            }

            var Qry = "UPDATE QryHdr SET QrhSoln = '" + $(this).attr("sts") + "' WHERE QrhPk = " + $(".query_hdrpk").val() + "";

            var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: Qry, Parameters: [], HtmlString: "" };

            $.ajax({
                type: "POST",
                url: BpmURL,
                contentType: "application/json;charset=utf-8",
                data: JSON.stringify(objProcData),
                dataType: "json",
                success: function (data) {
                    
                },
                error: function (result) { console.log(result); }
            });
        });

        var plus = $(shadow1.querySelector(".query_box-div .query_icon-plus"));
        var popup = shadow1.querySelector("#query_plus-popup");

        //document.write("<b>" + day + "/" + month + "/" + year + "</b>")         

        $(shadow1.querySelector("#query_Issuedt")).text(day + "/" + month + "/" + year);


        $(plus).click(function (e) {

            var Qry = "select QrcNm category,QrcPk Pk from QryCategory";

            var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: Qry, Parameters: [], HtmlString: "" };

            $.ajax({
                type: "POST",
                url: BpmURL,
                contentType: "application/json;charset=utf-8",
                data: JSON.stringify(objProcData),
                dataType: "json",
                success: function (data) {
                    COMP_QUERY.show_data(JSON.parse(data));
                },
                error: function (result) { }
            });

            var usr_qry = " SELECT usrpk,UsrDispNm Users FROM GenUsrMas(NOLOCK) " +
                             " WHERE EXISTS(SELECT 'X' FROM BpmNextOpUsr(NOLOCK) WHERE UsrPk = BnoUsrFk " +
                             " AND BnoBvmFk = " + GlobalXml[0].CurVerFlowPk +
                             " AND BnoDataPk =  " + GlobalXml[0].FwdDataPk + ")" +
                             " AND usrpk != " + shadow.UsrFk + " AND UsrDelId=0 ";


            var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: usr_qry, Parameters: [], HtmlString: "" };

            $.ajax({
                type: "POST",
                url: BpmURL,
                contentType: "application/json;charset=utf-8",
                data: JSON.stringify(objProcData),
                dataType: "json",
                success: function (data) {
                    COMP_QUERY.usr_data(JSON.parse(data));
                },
                error: function (result) { }
            });


            $(popup).toggle();
        });


        COMP_QUERY.show_data = function (data) {
            optcategry = "";
            var res = JSON.parse(data.result);
            for (var i = 0; i < res.length; i++) {
                optcategry += "<option value='" + res[i].Pk + "'>" + res[i].category + "</option> ";
            }
            var sel_QryRaise = $(shadow1.querySelector("#query_sel_QryRaised"));
            $(sel_QryRaise).empty();
            $(sel_QryRaise).each(function () {
                $(this).append(optcategry);
                $(this).select2({
                    width: '100%',
                    theme: "classic",
                    tags: false,
                    minimumInputLength: 1
                });
            });
        }
        var close = $(shadow1.querySelector("#query_plus-popup .query_icon-close"));

        $(close).click(function (e) {
            $(popup).hide();
        });

        var icondownarrow = $(shadow1.querySelectorAll(".query_icon-drop-down-arrow"));
        $(icondownarrow).each(function () {
            $(this).click(function (e) {
                e.stopImmediatePropagation();
                $(this).parent().siblings(".query_details").toggle();
            });
        });


        var notify_divchild = $(shadow1.querySelector("#QueryList div.query_notify-cnt:first-child"));


        var notify_div = $(shadow1.querySelector("#QueryList"));

        var btnReply = $(shadow1.querySelectorAll(".query_comment-icon i.query_icon-chat,i.query_icon-reply"));
        var btnDrilldown = $(shadow1.querySelectorAll(".query_comment-icon i.query_icon-chat,i.icon-drill-down"));
        
        $(btnDrilldown).each(function () {
            $(this).click(function (e) {

                

                data_qry = "SELECT top 1 BnoCreatedDt CrDt,dbo.gefgGetDesc(BudPk,2) PgNm,BudURL,BnoDataPk KeyFk,BudCd FROM BpmNextOpUsr " +
              " inner JOIN BpmUiDefn ON BnoBudFk=BudPk AND BudDelId=0" +
              " WHERE BnoDataPk = " + $(this).parent(".query_pending-icon")[0].children[2].value + "AND BnoUsrFk =" + $(this).parent(".query_pending-icon")[0].children[3].value + "" +
              " order by BnoCreatedDt desc";

                var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: data_qry, Parameters: [], HtmlString: "" }; 
                
                $.ajax({
                    type: "POST",
                    url: BpmURL,
                    contentType: "application/json;charset=utf-8",
                    data: JSON.stringify(objProcData),
                    dataType: "json",
                    success: function (data) {
                        COMP_QUERY.LeadPage(JSON.parse(data), elem);
                        //alert(JSON.parse(JSON.parse(data).result_1)[0].KeyFk);
                    },
                    error: function (result) { }
                });
               
            });
        });

        $(btnReply).each(function () {
            $(this).click(function (e) {
                

                var usr_qry = " SELECT usrpk,UsrDispNm Users FROM GenUsrMas(NOLOCK) " +
				              " WHERE EXISTS(SELECT 'X' FROM BpmNextOpUsr(NOLOCK) WHERE UsrPk = BnoUsrFk " +
                              " AND BnoBvmFk = " + $(this).parent(".query_pending-icon")[0].children[4].value +
                              " AND BnoDataPk =  " + $(this).parent(".query_pending-icon")[0].children[2].value + ")" + 
                              " AND usrpk != " + shadow.UsrFk + " AND UsrDelId=0 "
                var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: usr_qry, Parameters: [], HtmlString: "" };
                $.ajax({
                    type: "POST",
                    url: BpmURL,
                    contentType: "application/json;charset=utf-8",
                    data: JSON.stringify(objProcData),
                    dataType: "json",
                    success: function (data) {
                        COMP_QUERY.usr_data_1(JSON.parse(data), e);
                    },
                    error: function (result) { }
                });
                $(this).parent().parent().find(".query_comment-div").toggle();
            });
        });

        function GetAttachmntDtls(QueryBox, cmnt) {
            //Added by Vijay S for file uploader
            var cmtObj = {}; var fileArr = []; var fileincrement = 0;
            if ($(QueryBox).find("input[type='file']").length > 0) {
                $(QueryBox).find("input[type='file']").each(function () {
                    var ELEM = $(this).get(0);
                    var files = ELEM.files;
                    if (files.length == 0) { return; }
                    //Uploads the file into Server and enter the details into File_Upload table
                    fnFileAttacher(this, false);
                    //Add the file details along with the comment to add them into Query table
                    for (var i = 0; i < files.length; i++) {
                        fileArr[fileincrement++] = (files[i].path).substring(files[i].path.lastIndexOf("/") + 1);
                        if (!cmtObj.QueryFilePath) cmtObj.QueryFilePath = (files[i].path).substring(0, files[i].path.lastIndexOf("/"));
                    }
                    $(this).closest("li").remove();
                });
                cmtObj.QueryComment = cmnt;
                cmtObj.QueryAttachments = fileArr;
                //cmnt = JSON.stringify(cmtObj);
                return cmtObj;
            }
        }

        var btnSend = $(shadow1.querySelectorAll(".query_btnSend"));

        $(btnSend).each(function () {
            $(this).click(function (e) {
                var usr_fk = [];
                var elem = this;
                var Qelem = $(elem).parents("comp-query");
                if (Qelem != undefined && Qelem != null) {
                    if (Qelem.hasOwnProperty("length") || Qelem.selector)
                        Qelem = Qelem[0];
                }

                var leadId = Qelem.LeadFk;
                var Raised_User = Qelem.UsrFk;
                var UsrNm = Qelem.UsrNm;
                var FlowFk = Qelem.FlowFk;
                var ProcFk = Qelem.ProcFk;

                // $(this).parent().parent().find(".sel_ReplyTo").val();
                var QueryBox = $(this).closest(".query_comment-div");
                var cmnt = $(QueryBox).find(".rplyTxt").val();
                
                //Added by Vijay S for file uploader
                var cmtObj = GetAttachmntDtls(QueryBox, cmnt);

                var cmnt1 = $(QueryBox).find(".rplyTxt");
                var status = $(QueryBox).find(".query_pending-icon .query_reply-div");
                var sel_ReplyTo = $(QueryBox).find(".query_sel_ReplyTo :selected");
                var sel_ReplyTo1 = $(QueryBox).find(".query_sel_ReplyTo");
                var hdr_pk = $(this).closest(".query_notify-cnt").find(".query_hdrpk").val();
                if (sel_ReplyTo != [] && cmnt != "") {
                    for (var i = 0; i < sel_ReplyTo.length; i++) {
                        usr_fk.push($(sel_ReplyTo[i]).val());
                    }
                    var date = month + "/" + day + "/" + year;
                    var qry = " declare @dtls_pk int";
                    qry += " declare @Out_pk int";
                    qry += " insert into QryDtls (qrdqrhfk,qrddate,qrdnotes,QrdSeqNo,QrdRowId,QrdCreatedBy,QrdCreatedDt,QrdModifiedBy,QrdModifiedDt)";
                    qry += " values (" + hdr_pk + ",'" + date + "','" + JSON.stringify(cmtObj)/*cmnt added by Vijay S*/ + "',2,NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                    qry += " set @dtls_pk=SCOPE_IDENTITY()";
                    qry += " insert into QryOut (QrOQrdFk,QrOUsrFk,QrORowId,QrOCreatedBy,QrOCreatedDt,QrOModifiedBy,QrOModifiedDt) values " +
                        "(@dtls_pk," + Raised_User + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                    qry += " set @Out_pk=SCOPE_IDENTITY()";
                    for (var j = 0; j < usr_fk.length; j++) {
                        qry += " insert into QryIn (qriqrdfk,QrIQrOFk,QrIUsrFk,QrIRowId,QrICreatedBy,QrICreatedDt,QrIModifiedBy,QrIModifiedDt) " +
                            "values (@dtls_pk,@Out_pk," + usr_fk[j] + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                    }

                    var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: qry, Parameters: [], HtmlString: "" };

                    $.ajax({
                        type: "POST",
                        url: BpmURL,
                        contentType: "application/json;charset=utf-8",
                        data: JSON.stringify(objProcData),
                        dataType: "json",
                        success: function (data) {

                            COMP_QUERY.appenddt();
                            $(Qelem).setQuery();
                        },
                        error: function (result) { }
                    });

                    COMP_QUERY.appenddt = function () {
                        for (var i = 0; i < sel_ReplyTo.length; i++) {
                            $(status).append("<div> <i class='query_icon-customer'></i><span>" + $(sel_ReplyTo[i]).text() + "  :  " + cmnt + "</span><br/></div> ");

                        }
                        $(sel_ReplyTo1).val("").trigger("change");
                        $(cmnt1).val("");
                    }



                }
            });
        });




        var btnQrySend = $(shadow1.querySelector("#query_btnQrySend"));
        $(btnQrySend).click(function (e) {
            var str, reply_str = "";
            var usr_fk = [];
            var elem = this;
            var Qelem = $(elem).parents("comp-query");
            if (Qelem != undefined && Qelem != null) {
                if (Qelem.hasOwnProperty("length") || Qelem.selector)
                    Qelem = Qelem[0];
            }
            str = localStorage.getItem("QryRaisehtml");
            //var LeadFk = $(this).parent().parent().parent().find("#query_leadNo").text();
            var leadName = $(Qelem).find("#query_leadName").text();
            //var Raised_User = $(this).parent().parent().parent().find("#query_UsrRaised").text();
            var Raise_date = $(Qelem).find("#query_Issuedt").text();
            var categryfk = $(Qelem).find("#query_sel_QryRaised :selected");
            var sel_ReplyTo = $(Qelem).find("#query_sel_Toaddr :selected");
            var cmnt = $(Qelem).find(".commentTxt").val();

            //Added by Vijay S for file uploader
            var cmtObj = GetAttachmntDtls(Qelem, cmnt);

            var LeadFk = Qelem.LeadFk;
            var Raised_User = Qelem.UsrFk;
            var UsrNm = Qelem.UsrNm;
            var FlowFk = Qelem.FlowFk;
            var ProcFk = Qelem.ProcFk;

            if (sel_ReplyTo != [] && cmnt != "") {
                for (var i = 0; i < sel_ReplyTo.length; i++) {
                    reply_str += "<div> <i class='query_icon-customer'></i><span>" + $(sel_ReplyTo[i]).text() + "  :  " + cmnt + "</span><br/></div> ";
                    usr_fk.push($(sel_ReplyTo[i]).val());
                }
                str = str.replace("{{Query_Category}}", $(categryfk).text());
                str = str.replace("{{Query}}", cmnt);
                str = str.replace("{{LeadRef}}", LeadFk);
                str = str.replace("{{Lead_Name}}", leadName);
                str = str.replace("{{Raised_User}}", UsrNm);
                str = str.replace("{{Raise_date}}", Raise_date);
                // str += str.replace("{{Query_Raised_For}}", categryfk);
                var tmphtml = $(str);
                tmphtml.find(".query_details").css('display', 'block');
                tmphtml.find('.query_reply-div div').replaceWith(reply_str);
                $(this).parent().parent().parent().find("#query_sel_Toaddr").val("").trigger("change");
                $(this).parent().parent().find("textarea").val("");
                //details.toggle();

                var date = month + "/" + day + "/" + year;
                var ins_qry = "DECLARE @hdr_pk int";
                ins_qry += " DECLARE @dtls_pk int";
                ins_qry += " DECLARE @Out_pk int";
                ins_qry += " INSERT INTO QryHdr (QrhKeyFk,QrhBvmFk,QrhBfwFk,QrhRowId,QrhCreatedBy,QrhCreatedDt,QrhModifiedBy,QrhModifiedDt,QrhQrcFk) " +
                           " VALUES (" + LeadFk + "," + FlowFk + "," + ProcFk + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "'," + $(categryfk).val() + ")";
                ins_qry += " set @hdr_pk=SCOPE_IDENTITY()";
                ins_qry += " insert into QryDtls (QrdQrhFk,QrdDate,QrdRowId,QrdNotes,QrdSeqNo,QrdCreatedBy,QrdCreatedDt,QrdModifiedBy,QrdModifiedDt) values(@hdr_pk,'" + date + "',NEWID(),'" + JSON.stringify(cmtObj)/*cmnt added by Vijay S*/ + "',1,'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                ins_qry += " set @dtls_pk=SCOPE_IDENTITY()";
                ins_qry += " insert into QryOut (QrOQrdFk,QrOUsrFk,QrORowId,QrOCreatedBy,QrOCreatedDt,QrOModifiedBy,QrOModifiedDt) " +
                            " values (@dtls_pk," + Raised_User + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                ins_qry += " set @Out_pk=SCOPE_IDENTITY()";
                for (var j = 0; j < usr_fk.length; j++) {
                    ins_qry += " insert into QryIn (qriqrdfk,QrIQrOFk,QrIUsrFk,QrIRowId,QrICreatedBy,QrICreatedDt,QrIModifiedBy,QrIModifiedDt) values (@dtls_pk,@Out_pk," + usr_fk[j] + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                }
                ins_qry += " select max(QrhPk) pk  from QryHdr";

                var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: ins_qry, Parameters: [], HtmlString: "" };

                $.ajax({
                    type: "POST",
                    url: BpmURL,
                    contentType: "application/json;charset=utf-8",
                    data: JSON.stringify(objProcData),
                    dataType: "json",
                    success: function (data) {
                        //  show_data(JSON.parse(data));
                        var d = JSON.parse(data);
                        var arr = JSON.parse(d.result);
                        $("#QueryList").append(tmphtml);
                        COMP_QUERY.callback(elem, arr[0].pk);
                        $(popup).hide();
                        $(shadow1).setQuery();
                    },
                    error: function (result) { }
                });


                //  $("#QueryList").append(tmphtml);

                //var wrap = $(notify_html);
                //wrap.find("#sel_QryRaised").remove();
                //$(notify_div).append(wrap);
                // Replyto();
            }
        });

        //var opt = ["<option value=\"BranchOps\">BranchOps</option>", "<option value=\"ZonalOps\">ZonalOps</option>"];
        COMP_QUERY.callback = function (elem, pk) {

            // $(elem).parent().parent().parent().parent().find(".hdrpk").val();

            var icondownarrow1 = $(shadow1.querySelectorAll(".query_icon-drop-down-arrow")).last();
            $(icondownarrow1).each(function () {
                $(this).click(function (e) {
                    $(this).parent().siblings(".query_details").toggle();
                });
            });
            var btnReply1 = $(shadow1.querySelectorAll(".query_comment-icon i.query_icon-chat,i.query_icon-reply")).last();
            $(btnReply1).each(function () {
                $(this).click(function (e) {
                    e.stopImmediatePropagation();
                    $(this).parent().parent().find(".query_comment-div").toggle();
                });
            });

            var sel_ReplyTo = $(shadow1.querySelectorAll(".query_sel_ReplyTo")).last();

            $(sel_ReplyTo).each(function () {
                $(this).append(opt);
                $(this).select2({
                    width: '100%',
                    theme: "classic",
                    tags: false,
                    minimumInputLength: 1,
                    enable : "false"
                });
            });
            var btnSend = $(shadow1.querySelectorAll(".query_btnSend")).last();

            $(btnSend).each(function () {
                $(this).click(function (e) {

                    var Qelem = $(elem).parents("comp-query");
                    if (Qelem != undefined && Qelem != null) {
                        if (Qelem.hasOwnProperty("length") || Qelem.selector)
                            Qelem = Qelem[0];
                    }
                    var LeadFk = Qelem.LeadFk;
                    var Raised_User = Qelem.UsrFk;
                    var FlowFk = Qelem.FlowFk;
                    var ProcFk = Qelem.ProcFk;
                    var UsrNm = Qelem.UsrNm;

                    var usr_fk = [];
                    var QueryBox = $(this).closest(".query_comment-div");
                    $(this).closest(".query_notify-cnt").find(".query_hdrpk").val(pk);
                    // $(this).parent().parent().find(".sel_ReplyTo").val();
                    var cmnt = $(QueryBox).find(".rplyTxt").val();
                    var cmnt1 = $(QueryBox).find(".rplyTxt");
                    var status = $(QueryBox).find(".query_pending-icon .query_reply-div");
                    var sel_ReplyTo = $(QueryBox).find(".query_sel_ReplyTo :selected");
                    var sel_ReplyTo1 = $(QueryBox).find(".query_sel_ReplyTo");
                    var hdr_pk = $(this).closest(".query_notify-cnt").find(".query_hdrpk").val();
                    if (sel_ReplyTo != [] && cmnt != "") {
                        for (var i = 0; i < sel_ReplyTo.length; i++) {
                            usr_fk.push($(sel_ReplyTo[i]).val());
                        }
                        var date = month + "/" + day + "/" + year;
                        var qry = " declare @dtls_pk int";
                        qry += " declare @Out_pk int";
                        qry += " insert into QryDtls (qrdqrhfk,qrddate,qrdnotes,QrdSeqNo,QrdRowId,QrdCreatedBy,QrdCreatedDt,QrdModifiedBy,QrdModifiedDt)";
                        qry += " values (" + hdr_pk + ",'" + date + "','" + cmnt + "',2,NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                        qry += " set @dtls_pk=SCOPE_IDENTITY()";
                        qry += " insert into QryOut (QrOQrdFk,QrOUsrFk,QrORowId,QrOCreatedBy,QrOCreatedDt,QrOModifiedBy,QrOModifiedDt)" +
                                " values (@dtls_pk," + Raised_User + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                        qry += " set @Out_pk=SCOPE_IDENTITY()";
                        for (var j = 0; j < usr_fk.length; j++) {
                            qry += " insert into QryIn (qriqrdfk,QrIQrOFk,QrIUsrFk,QrIRowId,QrICreatedBy,QrICreatedDt,QrIModifiedBy,QrIModifiedDt) " +
                            "values (@dtls_pk,@Out_pk," + usr_fk[j] + ",NEWID(),'" + UsrNm + "','" + date + "','" + UsrNm + "','" + date + "')";
                        }

                        var objProcData = { ProcedureName: "$Query", Type: "", QryTxt: qry, Parameters: [], HtmlString: "" };

                        $.ajax({
                            type: "POST",
                            url: BpmURL,
                            contentType: "application/json;charset=utf-8",
                            data: JSON.stringify(objProcData),
                            dataType: "json",
                            success: function (data) {

                                COMP_QUERY.appenddt();
                            },
                            error: function (result) { }
                        });

                        COMP_QUERY.appenddt = function () {
                            for (var i = 0; i < sel_ReplyTo.length; i++) {
                                $(status).append("<div> <i class='query_icon-customer'></i><span>" + $(sel_ReplyTo[i]).text() + "  :  " + cmnt + "</span><br/></div> ");

                            }
                            $(sel_ReplyTo1).val("").trigger("change");
                            $(cmnt1).val("");
                        }



                    }
                });
            });
        }


        //var sel_QryRaised = $(shadow1.querySelectorAll(".sel_QryRaised"));
        //$(sel_QryRaised).each(function () {
        //    $(this).append(optcategry);
        //    $(this).select2({
        //        width: '100%',
        //        theme: "classic",
        //        tags: false,
        //        minimumInputLength: 1
        //    });
        //});




        var sel_ReplyTo = $(shadow1.querySelectorAll(".select2-selection--multiple"));

        $(sel_ReplyTo).each(function () {
            $(this).css("height", "1px");
        });


        /* APPLY STYLES */
        if (componentWidth == "100%") {
            //componentWidth = $(comp).parent().width();
            //componentWidth = componentWidth.toString();
        }
        /*
        if (componentHeight == "100%") {
            componentHeight = $(comp).parent().height();
            componentHeight = componentHeight.toString();
        }
        */
        var componentForStyles = comp.querySelector(".query_notification-div");
    //    componentHeight = componentHeight.replace("px", "");


        $(window).resize(function () {
            var NotifyDiv = comp.querySelector(".query_notify-div");
            var QBox = comp.querySelector(".query_box-div");
            if ($(window).width() > 768) {
                $(NotifyDiv).css({
                  //  "height": componentHeight - 50,
                    "overflow-y": "auto",
                    "margin": "5px"
                });
                $(comp).css({
                    "float": "left",
                    "width": componentWidth,
                  //  "height": componentHeight
                });

                $(componentForStyles).css({
                    "width": componentWidth,
                 //   "height": componentHeight
                });

                //$(QBox).css({
                //    "width": componentWidth,
                //    "height": componentHeight - 10
                //});
            }
            else {
                $(NotifyDiv).css({
                //    "height": "auto",
                    "overflow-y": "auto",
                    "margin": "5px"
                });
                $(comp).css({
                    "float": "left",
                    "width": componentWidth,
                  //  "height": "auto"
                });

                $(componentForStyles).css({
                    "width": componentWidth,
                 //   "height": "auto"
                });


                //$(QBox).css({
                //    "width": componentWidth,
                //    "height": "auto"
                //});
            }
        }).resize();

        if (Qtype.toLowerCase() == "list") {
            var qplus = comp.querySelector(".query_icon-plus");
            var popup = comp.querySelector("#query_plus-popup");
            $(qplus).remove();
            $(popup).remove();

        }

    }

};



COMP_QUERY.createComponent_query("comp-query", "query");

//added by Vijay S
var ProcessIDKey = 0;
function fnreplyAttach(elem)
{
    var newElem = $(elem).clone();
    newElem.removeAttr("onchange");
    fnFileAttacher(newElem, true);
    var liElem = $("<li class='query_fileupld'>" + newElem[0].files[0].name + " <span class='query_fileupldremove' title='Remove Attachment' onclick='$(this).parent().remove();'></span></li>");
    liElem.prepend(newElem);
    liElem.appendTo($(elem).parent().prev());
    $(elem).val('');    
}
