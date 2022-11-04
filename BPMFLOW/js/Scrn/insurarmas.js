var Global = [{}];
var Action = '';
var IsFinalConfirm = "";
var inpk = 0;
var AppJson = [];
$(document).ready(function () { 
    Global[0].USERNAME = GlobalXml[0].UsrNm;
    fnloadGrid();
});

function fnfinalResult(ServDesc, Obj, Param1, Param2)
{
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
  
    if (ServDesc == "Save") {
        fnClearForm("insurar_info", 1);
        $("#griddiv").empty();
        fnloadGrid();
    }
    if (ServDesc == "Load") {
        var loaddata = JSON.parse(Obj.result);
        for (var i = 0; i < loaddata.length; i++) {
            var table = $('<tr onclick="fnrowselect(this);" InsPk=' + loaddata[i].InPk + '>' + '<td>' + loaddata[i].Inscode + '</td>' + '<td>' + loaddata[i].InsName + '</td>' + '<td>' + loaddata[i].InsDispName + '</td>' + '</tr>');
            $("#griddiv").append(table);
        }
    }
    if (ServDesc == "Select") {
        debugger
        var seldata = JSON.parse(Obj.result);
        fnSetValues("insurar", seldata);
    }
}
function fnrowselect(elem) {
    debugger;
    var pkval = $(elem).attr("InsPk");
    $("#InPk").val(pkval);
    var objProcData = { ProcedureName: "PrcShflInsurar", Type: "SP", Parameters: ["Select", "", "", pkval] };
    fnCallLOSWebService("Select", objProcData, fnfinalResult, "MULTI", "");

}
function fnloadGrid()
{
        var objProcData = { ProcedureName: "PrcShflInsurar", Type: "SP", Parameters: ["Load", "", "",""] };
        fnCallLOSWebService("Load", objProcData, fnfinalResult, "MULTI", "");
}
function fnconfirmdetails()
{
    debugger
    AppJson = fnGetFormValsJson_IdVal("insurar_info", 1);

    var objProcData =
         {
             ProcedureName: "PrcShflInsurar",
             Type: "SP",
             Parameters:
             [
                 "Save", JSON.stringify(Global), JSON.stringify(AppJson),""
             ]
         };
    fnCallLOSWebService("Save", objProcData, fnfinalResult, "MULTI");
}