var COMP_DASHBRD = {};
var COMP_DASHBRD_LOADED = false;
COMP_DASHBRD._readyFn = [];

COMP_DASHBRD.CompReady = function (sel, fn) {
    debugger;
    var Obj = { selector: sel, fn: fn };
    COMP_DASHBRD._readyFn.push(Obj);
    if ($(sel).length > 0 && $(sel).html() != "") {
        fn();
    }
}


COMP_DASHBRD.extend = {
    CompReady: function (fn) {
        var DashBrd = this;
        if (DashBrd != undefined && DashBrd != null) {
            if (DashBrd.hasOwnProperty("length") || DashBrd.selector)
                DashBrd = DashBrd[0];
        }
        DashBrd._readyFn = fn;
    },
    setDashBoard: function (repeatDataSrc, appendFlag, DropDownData) {
        debugger;
        var DashBrd = this;
        if (DashBrd != undefined && DashBrd != null) {
            if (DashBrd.hasOwnProperty("length") || DashBrd.selector)
                DashBrd = DashBrd[0];
        }
        var repeatData = repeatDataSrc;
        DashBrd.DataSource = repeatData;
        DashBrd.DropDownData = DropDownData;
        var repeatsource = $(DashBrd).prop("repeatSource");

        var dashtype = DashBrd.type || $(DashBrd).attr("type") || "lead";
        dashtype = dashtype.toLowerCase();
        repeatsource = DashBrd.repeatSource;

        if (dashtype == "agent")
        { repeatsource = DashBrd.repeatagtleadSource; }
        if (repeatData.length >= 1) {
            DashBrd.querySelector("#Comp-dashBrdList").innerHTML = "";
            var repeatsourceTxt = "";
            for (var a = 0; a < repeatData.length; a++) {
                repeatsourceTxt += repeatsource;
                var data_keys = Object.keys(repeatData[a]);
                for (var i = 0; i < data_keys.length; i++) {
                    var toReplaceRowNo = new RegExp("{{rowNo}}", "g");
                    repeatsourceTxt = repeatsourceTxt.replace(toReplaceRowNo, a);

                    var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                    repeatsourceTxt = repeatsourceTxt.replace(toReplace, repeatData[a][data_keys[i]]);
                }
            }
            repeatsourceTxt += '<div class="clear"></div>';
            DashBrd.querySelector("#Comp-dashBrdList").innerHTML = repeatsourceTxt;

        }
        var heading = '<ul style="background-color : #E5E5E5;">' +
                '<li class="read-only" style="width:36% !Important">' +
                    '<label class="disable"></label>' +
                    '<p style="font-weight: bolder;" class="">Process Name</p>' +
                '</li>' +
                 '<li style="width:15% !Important">' +
                   '<p style="font-weight: bolder;">Process Id</p>' +
                 '</li>' +
                '<li style="width:28% !Important">' +
      '<p style="font-weight: bolder;">Time</p>' +
                 '</li>' +
                '<li class="status" style="white-space:nowrap;">' +
                    '<p style="font-weight: bolder;">Last Modified</p>' +
                '</li>' +
                '<div class="clear"></div>' +
         '</ul>';
        $("#Comp-dashBrdList").prepend(heading);
    }
}


$.fn.extend(COMP_DASHBRD.extend);

var createComponent_dashboard = function (TagName, HtmlSrc) {

    var ElementProto = Object.create(HTMLElement.prototype);

    ElementProto.setDashBoard = COMP_DASHBRD.extend.setDashBoard;
    ElementProto._readyFn = null;

    ElementProto.setDashboardList = function (Id, Src) {
        var comp = this;
        if (comp.lengh > 0)
            comp = this[0];

        if (this.tagName != "COMP-DASHBOARD")
            return;
        var elem = comp.querySelector("#" + Id) || comp.querySelector("#Comp-dashBrdList");
        var dashtype = comp.type || $(comp).attr("type") || "lead";
        dashtype = dashtype.toLowerCase();
        var rptSrc = comp.repeatSource;
        if (dashtype == "agent")
        { rptSrc = comp.AgtrepeatSource; }
        var repeatData = Src;
        comp.DataSource = repeatData;

        if (repeatData.length >= 1) {
            var repeatsource = rptSrc;
            elem.innerHTML = "";
            var repeatsourceTxt = "";
            for (var a = 0; a < repeatData.length; a++) {
                repeatsourceTxt += repeatsource;
                var data_keys = Object.keys(repeatData[a]);
                for (var i = 0; i < data_keys.length; i++) {
                    var toReplaceRowNo = new RegExp("{{rowNo}}", "g");
                    repeatsourceTxt = repeatsourceTxt.replace(toReplaceRowNo, a);

                    var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                    repeatsourceTxt = repeatsourceTxt.replace(toReplace, repeatData[a][data_keys[i]]);
                }
            }
        }
        //repeatsourceTxt += '<div class="clear"></div>';
        elem.innerHTML = repeatsourceTxt;
    };

    ElementProto.DataSource = [{}];
    ElementProto.DropDownData = [{}];

    ElementProto.repeatSource =
        '<ul keypk="{{DataPk}}" rowNo="{{rowNo}}" onclick="fnLoadDataStatus(this);">' +
               /* '<li>' +
                    '<i class="{{PrdIcon}}"></i>' +
                    '<p>{{PCd}}</p>' +
                '</li>' +
                */
                '<li class="read-only" style="width:36% !Important">' +
                    '<label class="disable">{{LeadID}}</label>' +
                    /*'<p class="font-13">{{LeadNm}}</p>' +*/
                    '<p class="">{{LeadNm}}</p>' +
                '</li>' +
                 '<li style="width:15% !Important">' +
                   '<p>{{DataPk}}</p>' +
                 '</li>' +
                '<li style="width:28% !Important">' +
      '<p class="font-10">{{Time}}</p>' +
                   //'<p class="time">{{Time}}</p>' +
                 '</li>' +
                '<li class="status" style="white-space:nowrap;">' +
                   // '<p class="bg bg1">{{Pg_status}}</p>' +
                    '<p>{{Roles}}</p>' +
                '</li>' +
                '<div class="clear"></div>' +
         '</ul>';

    
    ElementProto.AgtrepeatSource = "<ul class='agt-lead-drop-down' Pk='{{Pk}}' rowNo='{{rowNo}}' onclick=fnLoadDataStatus(this,'Agt_')>" +
                                    "<li>" +
                                        "<i class='icon-home-loan'></i>" +
                                        "<div class='clear'></div>" +
                                        "<span class='bg bg5'>{{AgentJob}}</span>" +
                                    "</li>" +
                                    "<li class='read-only'>" +
                                        "<p>{{JobAgentName}}</p>" +
                                        "<label>{{AgtLeadId}}</label>" +
                                        "<p>{{AppName}}</p>" +
                                    "</li>" +
                                    "<li class='status'>" +
                                        "<p class='bg {{bg}}'><i class='icon-pending'></i></p>" +
                                        "<div class='clear'></div>" +
                                        "<p>{{DueDys}}</p>" +
                                   "</li>" +
                                "</ul>";

    ElementProto.repeatagtleadSource =
                     '<ul leadpk="{{LajLedFk}}" rowNo="{{rowNo}}" onclick="fnLoadagtjob(this)">' +
                    '<li>' +
                    '<i class="icon-home-loan"></i>' +
                    '<p>{{PCd}}</p>' +
                '</li>' +
                '<li class="read-only">' +
                    '<label class="disable">{{LeadID}}</label>' +
                    '<p class="font-13">{{LeadNm}}</p>' +
                '</li>' +
                '<div class="clear"></div>' +
         '</ul>';


    /* DEFINITIONS */

    ElementProto.createdCallback = function () {
        /* Fired when the Element is created */
    }
    ElementProto.attachedCallback = function () {
        /* Fired when the Element is attached to the document */

        /* Changing the content & Events */

        //var shadow = this.createShadowRoot();

        var shadow = this;
        var componentWidth = this.getAttribute("width") || this.width || "100%";
        var componentHeight = this.getAttribute("height") || this.height || "100%";
        var componentID = this.getAttribute("id") || this.id || "";
        var styles = this.getAttribute("style") || this.style || "";
        var dataTxt = this.getAttribute("dashboardData") || this.dashboardData;
        var themecolor = this.getAttribute("themecolor") || this.themecolor || "";
        var type = this.getAttribute("type") || this.type || "lead";

        //styles = "<style>" + styles + "</style>"

        if (dataTxt && typeof dataTxt == "string") {
            dataTxt = dataTxt.replace(/}/g, "");
            dataTxt = dataTxt.replace(/{/g, "");
            AppendData = window[dataTxt];
        }
        else if (typeof dataTxt == "object") {
            AppendData = dataTxt;
        }
        var htmltoAppend = "";

        if (HtmlSrc && HtmlSrc != "") {
            var textContent = document.querySelector("#" + HtmlSrc).import;
            htmltoAppend = textContent.querySelector("custom-component").innerHTML;
        } else {
            htmltoAppend = document.getElementById("HtmlSrc").innerHTML;
        }

        if (typeof AppendData == "object") {
            var setData = AppendData.setData;
            if (setData && typeof setData == "object") {
                var data_keys = Object.keys(setData);
                for (var i = 0; i < data_keys.length; i++) {
                    var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                    htmltoAppend = htmltoAppend.replace(toReplace, setData[data_keys[i]]);
                }
            }
            shadow.innerHTML = htmltoAppend;
            this.innerHTML = htmltoAppend;

            //_ProtoType.ElementProto.innerHTML = htmltoAppend;
            var repeaters = shadow.querySelectorAll("[isrepeat=true]");

            var repeatDataSrc = AppendData.repeatData;
            var RepeatId = repeatDataSrc.id || "Comp-dashBrdList";
            var repeatData = repeatDataSrc.src;
            shadow.DataSource = repeatData;

            if (repeatData.length >= 1) {
                var repeatsource = shadow.querySelector("#" + RepeatId).innerHTML;
                shadow.querySelector("#" + RepeatId).innerHTML = "";
                var repeatsourceTxt = "";
                for (var a = 0; a < repeatData.length; a++) {
                    repeatsourceTxt += repeatsource;
                    var data_keys = Object.keys(repeatData[a]);
                    for (var i = 0; i < data_keys.length; i++) {
                        var toReplaceRowNo = new RegExp("{{rowNo}}", "g");
                        repeatsourceTxt = repeatsourceTxt.replace(toReplaceRowNo, a);

                        var toReplace = new RegExp("{{" + data_keys[i] + "}}", "g");
                        repeatsourceTxt = repeatsourceTxt.replace(toReplace, repeatData[a][data_keys[i]]);
                    }
                }
                repeatsourceTxt += '<div class="clear"></div>';
                shadow.querySelector("#" + RepeatId).innerHTML = repeatsourceTxt;
            }
        }
        else { shadow.innerHTML = htmltoAppend; }


        /* Changing the content */

        var dashcomp = this;
        type = type.toLocaleLowerCase();
        if (type == "agent")
            $(dashcomp.querySelector("#Comp_dash_title")).text("Agents");

        /* OPTIONS - EVENTS */


        if (!COMP_DASHBRD_LOADED) {
            $(document).keydown(function (e) {
                e = e || window.event;
                var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
                var dashcomp = $("comp-dashboard");
                if (dashcomp.length == 0)
                    return;
                dashcomp = $(dashcomp[0]);
                var rows = $(dashcomp).find("[rowno]");
                var len = rows.length;
                switch (keyCode) {
                    case 38: // up
                        e.preventDefault();                        
                        var pos = $(dashcomp).find(".active-dash-row").index();
                        pos = pos == -1 ? len - 1 : pos == 0 ? len - 1 : pos - 1;
                        $(rows).removeClass("active-dash-row");
                        $(rows[pos]).addClass("active-dash-row");
                        if (rows[pos])
                            rows[pos].scrollIntoView(true);
                        if (pos < 4 && pos != 0)
                            $(dashcomp).find("[rowno]")[0].scrollIntoView(true);
                        break;
                    case 40: // down
                        e.preventDefault();                        
                        var pos = $(dashcomp).find(".active-dash-row").index();
                        pos = pos == -1 ? 0 : pos == len - 1 ? 0 : pos + 1;
                        $(rows).removeClass("active-dash-row");
                        $(rows[pos]).addClass("active-dash-row");
                        if (rows[pos])
                            rows[pos].scrollIntoView(true);
                        if (pos < 4)
                            $(dashcomp).find("[rowno]")[0].scrollIntoView(true);
                        break;
                    case 13: // down
                        $(dashcomp).find(".active-dash-row").click();
                        break;
                    default:
                        return;
                }

            });
        }
        COMP_DASHBRD_LOADED = true;

        /* OPTIONS - EVENTS */


        /* APLLY STYLES */
        componentHeight = componentHeight.replace("px", "");
        $(dashcomp).css({
            "float": "left",
            "width": componentWidth,
            "height": componentHeight
        });

        if (componentHeight != "" && componentHeight != "100%") {
            $(window).resize(function () {
                setTimeout(function () {
                    var componentForStyles = dashcomp.querySelector(".custom-component");
                    var componentForStyles_dashLst = dashcomp.querySelector("#Comp-dashBrdList");
                    var componentForStyles_dashtitle = dashcomp.querySelector(".dashboard-title");
                    if ($(window).width() < 768) {
                        $(componentForStyles).css({
                            "height": "auto"
                        });
                        $(dashcomp).css({
                            "height": "auto"
                        });
                        $(componentForStyles_dashtitle).attr("style", "height:auto;");
                        $(componentForStyles_dashLst).css({
                            "height": "auto"
                        });
                    }
                    else {
                        $(componentForStyles).css({
                            "height": (componentHeight - 5) + "px !important"
                        });
                        $(dashcomp).css({
                            "height": componentHeight
                        });
                        $(componentForStyles_dashLst).attr("style", "height:" + (componentHeight - 40) + "px !important");
                        $(componentForStyles_dashtitle).attr("style", "height:" + (componentHeight - 30) + "px !important");
                        $(componentForStyles_dashLst).css({
                            "height": (componentHeight - 40) + "px !important"
                        });
                    }
                }, 100);
            }).resize();
        }


        /* READY FUNCTION */

        var READY_FN_LIST = COMP_DASHBRD._readyFn;
        for (var i = 0; i < READY_FN_LIST.length; i++) {
            var fnObj = READY_FN_LIST[i];
            if ("#" + componentID == fnObj.selector) {
                var Rfn = fnObj.fn;
                if (Rfn && Rfn != null && Rfn != undefined && typeof Rfn == "function")
                    Rfn();
            }
        }

    }
    ElementProto.detachedCallback = function () {
        /* Fired when the Element is removed */
    }
    ElementProto.attributeChangedCallback = function (attrName, oldValue, newValue) {
        //console.log(attrName + "=" + oldValue + "=" + newValue);
    }

    ElementProto.html = function () {
        return this.innerHTML;
    }

    /*  Register our tag and its properties as an element in the document. 
       So that document will understand the tag and parse it as we designed    */
    var MyElement = document.registerElement(TagName, { prototype: ElementProto });
};

createComponent_dashboard("comp-dashboard", "dashboard");
