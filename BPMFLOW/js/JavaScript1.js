$(document).ready(function () {

});
function fnsave() {
    debugger;
    var DtlsJson = [];
    DtlsJson = fnGetFormValsJson_IdVal("fuldiv");
    fnClearForm("fuldiv");
    var objProcData =
           {
               ProcedureName: "PrcShflbuilermas", Type: "SP", Parameters: ["save", JSON.stringify(DtlsJson)]
           };

    fnCallLOSWebService("DATA_SAVE", objProcData, fncallback, "MULTI", "");
}
function fncallback(SerDesc, Obj, param1, param2) {
    debugger;
    if (SerDesc == "DATA_SAVE") {
        var grddata = JSON.parse(Obj.result_1);
        var data = JSON.parse(Obj.result_2);
        for (var i = 0; i < grddata.length; i++) {
            var table = $('<table>' + '<tr>' + '<td>' + grddata[i].GbmCd + '</td>' + '<td>' + grddata[i].GbmName + '</td>' + '<td>' + grddata[i].GbmContactPerson + '</td>' + '<td>' + grddata[i].GbmMobileNo + '</td>' + '</tr>' + '</table>');
            $("#grddivid").append(table);
        }
        
   }

}
