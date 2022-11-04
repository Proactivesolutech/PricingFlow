
var global_Led_Json = "";
var global_Led_Json_1 = "";
var cnt = 0;
var c = 0;
var Mas_Loaded_Flow = 0;
var selFlow = 0;

$(document).ready(function () {
    fnleadload();
});

function fnleadload() {
    var objProcData = { ProcedureName: "PrcShflLeadDetails", Type: "SP", Parameters: ["Load"] };
    fnCallLOSWebService("Lead_Load", objProcData, fnLeadResult, "MULTI");
}

function fnExport() {
    if (Mas_Loaded_Flow == 0) {
        fnShflAlert("warning", "Select any Flow to Export Data");
        return;
    }
    var objProcData = { ProcedureName: "PrcGetLeadHis", Type: "SP", Parameters: ["", "", Mas_Loaded_Flow, "TATEXPORT"] };
    fnCallWebService("Lead_Info_Export", objProcData, fnLeadResult, "MULTI");
}

function fnCallPni() {
    Mas_Loaded_Flow = gConfig["gPNIFlow"];
    selFlow = 2;
    $("#tracking-div_Mas").empty();
    var objProcData = { ProcedureName: "PrcGetLeadHis", Type: "SP", Parameters: ["", "", gConfig["gPNIFlow"], "TAT"] };
    fnCallWebService("Lead_Info", objProcData, fnLeadResult, "MULTI");
}
function fnCallPi() {
    Mas_Loaded_Flow = gConfig["gPIFlow"];
    selFlow = 1;
    $("#tracking-div_Mas").empty();
    var objProcData = { ProcedureName: "PrcGetLeadHis", Type: "SP", Parameters: ["", "", gConfig["gPIFlow"], "TAT"] };
    fnCallWebService("Lead_Info", objProcData, fnLeadResult, "MULTI");
}
function fnCallLap() {
    Mas_Loaded_Flow = gConfig["gBTFlow"];
    selFlow = 3;
    $("#tracking-div_Mas").empty();
    var objProcData = { ProcedureName: "PrcGetLeadHis", Type: "SP", Parameters: ["", "", gConfig["gBTFlow"], "TAT"] };
    fnCallWebService("Lead_Info", objProcData, fnLeadResult, "MULTI");
}

function fnLeadResult(service, Obj, param1, param2) {

    if (service == "Lead_Load") {
        global_Led_Json = JSON.parse(Obj.result);
        global_Led_Json_1 = JSON.parse(Obj.result);
    }

    if (service == "Lead_Info_Export") {
        var his_info = JSON.parse(Obj.result);

        var final_his_export = [];
        for (var j = 0; j < global_Led_Json.length; j++) {
            var finalExpObj;
            for (var i = 0; i < his_info.length; i++) {
                if (global_Led_Json[j].LeadPk == his_info[i].LeadPk) {
                    finalExpObj = $.extend(global_Led_Json[j], his_info[i]);
                    delete finalExpObj['LeadPk'];
                    final_his_export.push(finalExpObj);
                }
            }
        }
        if (final_his_export.length > 0) {
            var label = "";
            if (selFlow == 3) { label = "BT + Top UP Lead History"; }
            else if (selFlow == 2) { label = "Property Not Identified Lead History"; }
            else { label = "Property Identified Lead History"; }

            JSONToCSVConvertor(final_his_export, true, label);
        }
        
    }
    if (service == "Lead_Info") {        
        var leadpk = JSON.parse(Obj.result_1);
        var info = JSON.parse(Obj.result_2);
        var data = [];
        var OwnerArray = [];
        var OwnerData = {};
        for (var i = 0; i < leadpk.length; i++) {
            data = [];
            $("#tracking-div_Mas").show();

            $("#tracking-div_Mas").append
             (
                '<div class="box-div">' +
                         '<div class="tracking-div box-div">' +
                            '<div id="lead_div_' + i + '">' +
                            '</div>' +
                            '<div class="tracking-content">' +
                                '<div id="border_div" class="track-border"></div>' +
                                '<div id="track_data_div_' + i + '"  class="history-main">' +
                                    '<h3 style="visibility:hidden;">Data Entry</h3>' +
                            '</div>' +
                         '</div>' +
                '</div>'
             );

            for (j = 0; j < info.length; j++) {
                if (leadpk[i].LdFk == info[j].LdFk) {

                    OwnerData = { 'PgCd': info[j].PgCd, 'UsrNm': info[j].UsrNm, 'Dt': info[j].Dt, 'Tim': info[j].Tim, 'HisPk': info[j].HisPk, 'LdFk': info[j].LdFk };
                    data.push(OwnerData);
                }
            }

            var n = 0;
            for (d = 0; d < data.length; d++) {
                var StsCls = "bg1"; var EmptyClass = "";
                var nbsp = data[d].Dt + '(' + data[d].Tim + ')';

                if (data[d].HisPk == 0) {
                    n += 100;
                    StsCls = "bg";
                    EmptyClass = "class='empty-div'";
                    nbsp = "&nbsp;"
                }
                if (data[d].HisPk == 1) {
                    n += 125;
                    StsCls = "bg3";
                }
                else
                    n += 125;
                debugger
                for (g = 0; g < global_Led_Json_1.length; g++) {
                    if (data[d].LdFk == global_Led_Json_1[g].LeadPk) {
                        $("#lead_div_" + i).empty();
                        $("#lead_div_" + i).append
                         (
                          '<ul class="left">' +
                                '<li class="appendinfo">' +
                                '<label><b>' + global_Led_Json_1[g].Leadid + '</b></label>' +
                                '<p><b>' + global_Led_Json_1[g].Leadname + ' - ' + global_Led_Json_1[g].branchname + '</b></p>' +
                                '</li>' +
                            '</ul>'
                         );
                    }
                }

                $("#track_data_div_" + i).append
                (
                    '<div  class="history-sub">' +
                         '<h4>' + data[d].PgCd + '</h4>' +
                         '<span class="' + StsCls + ' round"></span>' +
                         '<p ' + EmptyClass + '>' + nbsp + '</p>' +
                     '</div>'
                );

            }
            $("#border_div").css("width", n.toString() + "px")
        }
    }
}
