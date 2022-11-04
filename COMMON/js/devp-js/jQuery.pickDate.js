jQuery.fn.pickDate = function (options, prop, val) {
    var id = this.selector;
    window.glob_id = id;
    var width = $(id).css("width");
    $(id).attr("placeholder", "dd/mm/yyyy");
    var DateInput = document.querySelector(id);
    var div = document.createElement("div");
    div.id = "Div_CalPick";
    $(this).after(div);
    $("#Div_CalPick").attr("style", "width:" + width + " !important;position:absolute;z-index:9999;background:#FFF;border:1px solid red;");
    $("#Div_CalPick").loadPickDate();
    $("#Div_CalPick").hide();
    $("#Div_CalPick").children().each(function () {
        fnaddclassTochild(this);
    });


    $(DateInput).click(function () {
        $("#Div_CalPick").hide();
        setTimeout(function () { $("#Div_CalPick").show(); }, 50);
        $(document).click(function (e) {
            var cls = "";
            cls = $(e.target).attr("class");
            if (cls == null || cls == undefined) {
                cls = "";
            }
            if ("#" + e.target.id != id && cls.indexOf('pickDate_child') == -1)
                $("#Div_CalPick").hide();
        });
    });
}

function fnaddclassTochild(ts) {
    $(ts).addClass('pickDate_child');
    if ($(ts).children().length > 0) {
        $(ts).children().each(function () {
            fnaddclassTochild(this)
        })
    }
}
jQuery.fn.loadPickDate = function () {
    var id = this.selector;
    var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    var month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    var MonthSelect = document.createElement('select');
    MonthSelect.id = 'MonthSelect';
    //document.querySelector(id).appendChild(MonthSelect);
    var YearSelect = document.createElement('select');
    YearSelect.id = 'YearSelect';
    //document.querySelector(id).appendChild(YearSelect);

    /* TITLE */
    var titleTable = document.createElement('table');
    titleTable.id = 'titleTable';
    document.querySelector(id).appendChild(titleTable)
    var titTR = "<tr style='height:40px;background:#FF5555;color:#FFFFFF'><td id='MonthBack' style='text-align:center;font-weight:bold;font-size:19px;cursor:pointer;'><</td><td style='text-align:center;' colspan='5' id='TitleDt'></td><td style='text-align:center;font-weight:bold;font-size:19px;cursor:pointer;' id='MonthFront'>></td></tr>";
    $("#titleTable").append(titTR)
    $("#titleTable").css({
        "border": "1px solid #FF5555"
        //"border-collapse": "collapse"
    })
    document.querySelector("#TitleDt").appendChild(MonthSelect);
    document.querySelector("#TitleDt").appendChild(YearSelect);

    $('#MonthFront').click(function () {
        var Front = parseInt($("#MonthSelect").val());
        if (Front == 11) {
            var NxtYrVal = parseInt($("#YearSelect").val()) + 1;
            $("#YearSelect").val(NxtYrVal);
            $("#MonthSelect").val(0);
            $("#MonthSelect").change();
        }
        else {
            $("#MonthSelect").val(Front + 1);
            $("#MonthSelect").change();
        }
    });

    $('#MonthBack').click(function () {
        var Back = parseInt($("#MonthSelect").val());
        if (Back == 0) {
            var PrevYrVal = parseInt($("#YearSelect").val()) - 1;
            $("#YearSelect").val(PrevYrVal);
            $("#MonthSelect").val(11);
            $("#MonthSelect").change();
        }
        else {
            $("#MonthSelect").val(Back - 1);
            $("#MonthSelect").change();
        }

    });

    /* TITLE */

    var DtPicktable = document.createElement('table');
    DtPicktable.id = 'calendartbl';
    document.querySelector(id).appendChild(DtPicktable);

    /* CALENDAR */
    var tr = "";
    for (var a = 0; a < 6; a++) {
        if (a == 0)
            tr += "<tr class='days' style='border-bottom:1px solid #265578;'><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>";
        tr += "<tr class='date'><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>";
    }
    document.querySelector("#" + DtPicktable.id).innerHTML = tr;

    var daycount = 0;
    $("#" + DtPicktable.id + " tr.days td").each(function () {
        $(this).text(days[daycount]);
        daycount++;
    });
    var date = 1;
    $("#" + DtPicktable.id + " tr.date td").each(function () {
        var val = date > 31 ? '' : date;
        $(this).text(val);
        $(this).addClass('YesDate');
        date++;
    });
    /* CALENDAR */

    /* MONTH */
    var mnth = "";
    for (var i = 0; i < month.length; i++) {
        mnth += "<option value='" + i + "'>" + month[i] + "</option>";
    }
    $("#" + MonthSelect.id).append(mnth);
    /* MONTH */

    /* YEAR */
    var d = new Date();
    //d.setFullYear(17,0,1);
    var CurYear = d.getFullYear();
    var CurMonth = d.getMonth();
    var StartYear = CurYear - 1;
    var EndYear = CurYear + 30;
    // var StartYear = 1000;
    // var EndYear = 3000;

    var yr = "";
    for (var y = StartYear; y < EndYear; y++) {
        yr += "<option>" + y + "</option>";
    }
    $("#" + YearSelect.id).append(yr);
    $("#" + YearSelect.id).val(CurYear);
    $("#" + MonthSelect.id).val(CurMonth)
    /* YEAR */

    /* CHANGE FUNCTIONS */
    var MCountArr = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var MCountArrLeap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    $("#" + MonthSelect.id).change(function () {
        var selYear = $("#" + YearSelect.id).val();
        var selMonth = $("#" + MonthSelect.id).val();
        var firstDay = new Date(selYear, selMonth, 1)
        //var lastDay = new Date(selYear,selMonth+1,0)
        var monthDayCount = 30;
        if ((selYear % 4 == 0) && (selYear % 100 != 0 || selYear % 400 == 0)) {
            monthDayCount = MCountArrLeap[$("#" + MonthSelect.id).val()]
        }
        else {
            monthDayCount = MCountArr[$("#" + MonthSelect.id).val()]
        }

        var StartDayArr = firstDay.toString().split(" ");
        var indx = days.indexOf(StartDayArr[0]);

        var idaycount = 0;
        $("#" + DtPicktable.id + " tr.date td").removeClass('YesDate');
        $("#" + DtPicktable.id + " tr.date td").each(function () {
            if (this.parentElement.rowIndex == 1) {
                if (indx == 0) {
                    $(this).text("")
                }
                else {
                    if (this.cellIndex >= indx) {
                        $(this).text((idaycount + 1));
                        $(this).addClass('YesDate');
                        idaycount++;
                    }
                    else {
                        $(this).text("");
                    }
                }
            }
            else {
                if (idaycount >= monthDayCount) {
                    $(this).text("");
                }
                else {
                    $(this).text((idaycount + 1));
                    $(this).addClass('YesDate');
                    idaycount++;
                }
            }
        });
        $("#" + DtPicktable.id + " tr.date td").css("border", "0px solid red");
        $("#" + DtPicktable.id + " tr.date td.YesDate").css("border", "1px solid red");
    })

    $("#" + YearSelect.id).change(function () {
        var selYear = $("#" + YearSelect.id).val();
        var selMonth = $("#" + MonthSelect.id).val();
        var firstDay = new Date(selYear, selMonth, 1)
        //var lastDay = new Date(selYear,selMonth+1,0)
        var monthDayCount = 30;
        if ((selYear % 4 == 0) && (selYear % 100 != 0 || selYear % 400 == 0)) {
            monthDayCount = MCountArrLeap[$("#" + MonthSelect.id).val()]
        }
        else {
            monthDayCount = MCountArr[$("#" + MonthSelect.id).val()]
        }

        var StartDayArr = firstDay.toString().split(" ");
        var indx = days.indexOf(StartDayArr[0]);

        var idaycount = 0;
        $("#" + DtPicktable.id + " tr.date td").removeClass('YesDate');
        $("#" + DtPicktable.id + " tr.date td").each(function () {
            if (this.parentElement.rowIndex == 1) {
                if (indx == 0) {
                    $(this).text("")
                }
                else {
                    if (this.cellIndex >= indx) {
                        $(this).text((idaycount + 1));
                        $(this).addClass('YesDate');
                        idaycount++;
                    }
                    else {
                        $(this).text("");
                    }
                }
            }
            else {
                if (idaycount >= monthDayCount) {
                    $(this).text("");
                }
                else {
                    $(this).text((idaycount + 1));
                    $(this).addClass('YesDate');
                    idaycount++;
                }
            }
        });
        $("#" + DtPicktable.id + " tr.date td").css("border", "0px solid red");
        $("#" + DtPicktable.id + " tr.date td.YesDate").css("border", "1px solid red");
    })

    /* CHANGE FUNTION */

    /* INIT FUNTION */
    var selYear = $("#" + YearSelect.id).val();
    var selMonth = $("#" + MonthSelect.id).val();
    var firstDay = new Date(selYear, selMonth, 1)
    //var lastDay = new Date(selYear,selMonth+1,0)
    var monthDayCount = 30;
    if ((selYear % 4 == 0) && (selYear % 100 != 0 || selYear % 400 == 0)) {
        monthDayCount = MCountArrLeap[$("#" + MonthSelect.id).val()]
    }
    else {
        monthDayCount = MCountArr[$("#" + MonthSelect.id).val()]
    }
    var StartDayArr = firstDay.toString().split(" ");
    var indx = days.indexOf(StartDayArr[0]);

    var idaycount = 0;

    $("#" + DtPicktable.id + " tr.date td").removeClass('YesDate');
    $("#" + DtPicktable.id + " tr.date td").each(function () {
        if (this.parentElement.rowIndex == 1) {
            if (indx == 0) {
                $(this).text("")
            }
            else {
                if (this.cellIndex >= indx) {
                    $(this).text((idaycount + 1));
                    $(this).addClass('YesDate');
                    idaycount++;
                }
                else {
                    $(this).text("");
                }
            }
        }
        else {
            if (idaycount >= monthDayCount) {
                $(this).text("");
            }
            else {
                $(this).text((idaycount + 1));
                $(this).addClass('YesDate');
                idaycount++;
            }
        }
    });
    /* INIT FUNTION */

    /* STYLES */

    $(".YesDate").mouseover(function () {
        $(this).css({ "background": "red", "color": "#FFF" })
    });
    $(".YesDate").mouseleave(function () {
        $(this).css({ "background": "#FFF", "color": "#666" })
    });

    $("#" + DtPicktable.id).css({
        //"border-collapse": "collapse",
        "width": "100%",
        "border-radius": "8px !important"
    });

    $("#" + DtPicktable.id + " tr td").css({
        "color": "#666666",
        //"padding": "10px 20px 10px 20px",
        "text-align": "center",
        "cursor": "pointer"
    });

    $("#" + DtPicktable.id + " tr.date td").css("border", "0px solid red");
    $("#" + DtPicktable.id + " tr.date td.YesDate").css("border", "1px solid red");

    $("#" + DtPicktable.id + " tr.days td").css({
        "border": "0px solid #FF5555"
    });

    var selectel = $(id).find("select");
    selectel.css({
        //"padding": "5px",
        //"width": "100px",
        "border-radius": "4px",
        "margin": "3px",
        "border": "1px solid #FF5555",
        "outline": "none"
    });
    var width = $("#" + DtPicktable.id).css("width");
    $("#titleTable").css({
        //"width": width
    });
    /* STYLES */

    /* CLICK FUNCTION */

    $("#" + DtPicktable.id + " tr.date td").click(function () {
        if ($(this).text() != "") {
            var retYear = $("#" + YearSelect.id).val();
            var retMonth = parseInt($("#" + MonthSelect.id).val()) + 1;
            var retDate = parseInt($(this).text());
            var strDate = retDate > 9 ? retDate : "0" + retDate;
            var strMonth = retMonth > 9 ? retMonth : "0" + retMonth;
            var returnDate = strDate + "/" + strMonth + "/" + retYear;
            $(glob_id).val(returnDate);
            $("#Div_CalPick").hide();
        }
    });

    /* CLICK FUNCTION */

    var width = $("#" + DtPicktable.id).css("width");
    $("#titleTable").css({
        "width": width,
        "border": "1px solid #265578",
        "border-collapse": "collapse"
    })
}