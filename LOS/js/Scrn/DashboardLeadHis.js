$(document).ready(function () {
    debugger;
    var extraparam = JSON.stringify(GlobalBrnch);
    $("#Leaddash-help").attr("Extraparam", extraparam);
    //$("#data_div_Id").hide();
});
function Leadclick(rowjson) {
    debugger;    
    $("#LeadDiv").find("li.Lead input[name='helptext']").val(rowjson.LeadId);
    $("#LeadDiv").find("li.Lead input[key='Leaddash-help']").attr("valtext",rowjson.LeadId);
    $("#LeadDiv").find("li.Lead input[key='Leaddash-help']").attr("value", rowjson.LeadId);
    $("#Ritscrndata").empty();
    $("#PenursrefdataId").empty();
    $("#data_div_Id").show();
    $("#Bal_LeadNm").text(rowjson.LeadName);
    $("#Bal_Branch").text(rowjson.BranchName);
    $("#his_lead_prdicon").addClass(rowjson.hdnPrdIcon);
    $("#his_lead_prdnm").text(rowjson.hdnPrdNm);
    window.leadpk = rowjson.LeadPk;
    var verfk = GlobalXml.CurVerFlowPk;
    var objProcData = { ProcedureName: "PrcGetLeadHis", Type: "SP", Parameters: [leadpk, verfk, gConfig["gBTFlow"] + "~" + gConfig["gPIFlow"] + "~" + gConfig["gPNIFlow"]] };
    fnCallWebService("vers_fk_sel", objProcData, fnhisResult, "MULTI");

}
function fnhisResult(service, Obj, param1, param2)
{
    debugger;
    if (service == "vers_fk_sel") {
        var Compata = JSON.parse(Obj.result_9);
        $("#fulHtmlcompdivId").empty();
        $("#PenursrefdataId").empty();
        
        if (Compata != "") {
            var ul = "";
            for (var i = 0; i < Compata.length; i++) {
                ul = $('<ul class="form-controls">' +
                        '<li class="read-only width-20">' +
                            '<p>' + Compata[i]["Screen Name"] + '</p>' +
                        '</li>' +
                        '<li class="read-only width-19">' +
                            '<p>' + Compata[i]["UsrNm"] + '</p>' +
                        '</li>' +
                        '</ul>');

                $("#fulHtmlcompdivId").append(ul);
            }

        }
        var Penursrefata = JSON.parse(Obj.result_7);
        if (Penursrefata != "") {
            var ul = "";
            for (var i = 0; i < Penursrefata.length; i++) {
                ul = $('<ul class="form-controls">' +
                        '<li class="read-only width-20">' +
                            '<p>' + Penursrefata[i].ScreenName + '</p>' +
                        '</li>' +                                  
                        '<li class="read-only width-19">' +
                            '<p>' + Penursrefata[i].UsrNm + '</p>' +
                        '</li>' + '</ul>');

                $("#PenursrefdataId").append(ul);
            }

        }
    }
}
