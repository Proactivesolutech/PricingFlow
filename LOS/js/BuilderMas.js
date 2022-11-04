$(document).ready(function () {
    fnloadval();
});

function fnloadval() {
    var objProcData = { ProcedureName: "PrcShflbuildermas", Type: "SP", Parameters: ["LOAD", "", ""] };
    fnCallLOSWebService("LOAD_SELECT", objProcData, fncallback, "MULTI", "");
}
function fnsave() {
    debugger;
    var DtlsJson = [];
    DtlsJson = fnGetFormValsJson_IdVal("fuldiv");
    var ErrMsg = fnChkMandatory("fuldiv");
    if (ErrMsg != "") {
        fnShflAlert("error", ErrMsg);
        return false;
    }
    var gbmpk = $("#hidpkid").attr("pk");
    if (gbmpk != "" && typeof gbmpk != "undefined")
        Action = "UPDATE";
    else
        Action = "SAVE";
    fnClearForm("fuldiv");

    var objProcData =
           {
               ProcedureName: "PrcShflbuildermas", Type: "SP", Parameters: [Action, JSON.stringify(DtlsJson), gbmpk]
           };

    fnCallLOSWebService("DATA_SAVE", objProcData, fncallback, "MULTI", "");
}
function fncallback(SerDesc, Obj, param1, param2) {
    debugger;
    if (SerDesc == "LOAD_SELECT") {       
        var loaddata = JSON.parse(Obj.result);
        for (var i = 0; i < loaddata.length; i++) {
            var table = $('<tr onclick="fnrowselect(this);" GbmFk=' + loaddata[i].GbaGbmFk + '>' + '<td>' + loaddata[i].GbmCd + '</td>' + '<td>' + loaddata[i].GbmName + '</td>' + '<td>' + loaddata[i].GbmContactPerson + '</td>' + '<td>' + loaddata[i].GbmMobileNo + '</td>' + '</tr>');
            $("#grddivid").append(table);
        }
    }
    if (SerDesc == "DATA_SAVE") {       
        $("#hidpkid").attr("pk","");
        $("#grddivid").empty();
        fnloadval();
        
    }
    if(SerDesc == "DATA_SELECT")
    {
        var seldata = JSON.parse(Obj.result);
        fnSetValues("fuldiv", seldata);
        if (seldata.length > 0) {
            var location = seldata[0].GbaPin ? seldata[0].GbaPin : "";
            if (location != "") {
                $("#fuldiv").find("li.pinnum comp-help").find("input[name='helptext']").val(seldata[0].GbaPin);
                $("#fuldiv").find("li.pinnum input[key=dde_builoc]").attr("valtext", seldata[0].GbaPin);
            }
        }
    }

}
function fnrowselect(elem) {
    debugger;
    var pkval = $(elem).attr("GbmFk");
    $("#hidpkid").attr("pk", pkval);
    var objProcData = { ProcedureName: "PrcShflbuildermas", Type: "SP", Parameters: ["SELECT", "", pkval] };
    fnCallLOSWebService("DATA_SELECT", objProcData, fncallback, "MULTI", "");

}
function Pinclick(rowjson, elem) {
    $(elem).siblings("input").val(rowjson.Pincode);
    $(elem).parent().siblings("li.state").find("input").val(rowjson.State);
    $(elem).parent().siblings("li.district").find("input").val(rowjson.City);
    $(elem).parent().siblings("li.city").find("input").val(rowjson.Area);
}