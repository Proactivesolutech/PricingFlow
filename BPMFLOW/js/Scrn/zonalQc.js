
$(document).ready(function () {
    fnLoadAgentsDetails();
});
function fnLoadAgentsDetails() {
    var objProcData = { ProcedureName: "PrcShflLedAgtMgt", Type: "SP", Parameters: ["Dash"] }
    fnCallLOSWebService("Agents", objProcData, fnQcZoResult, "MULTI");
  
}
function fnQcZoResult(ServDesc, Obj, Param1, Param2)
{
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
    if (ServDesc == "Agents") {

        var AgentData = JSON.parse(Obj.result);

        for (var i = 0; i < AgentData.length; i++) {
            var clsNm = ""; var LoadhtmlPg = ""; 
            var SerType = parseInt(AgentData[i].ServiceType);
            var bg = (AgentData[i].AgtJobDt >= 0) ? "bg3" : "bg2";
            var DueDys = (AgentData[i].AgtJobDt >= 0) ? AgentData[i].AgtJobDt : (-1) * (AgentData[i].AgtJobDt);

            if(SerType == 0 || SerType == 1){
                LoadhtmlPg = "field-investigation.html";
            }
            else if(SerType == 2){
                LoadhtmlPg = "document-verification.html";
            }
            else if(SerType == 3){
                LoadhtmlPg = "collection-feedback.html";
            }
            else if(SerType == 4){
                LoadhtmlPg = "legal-verification.html";
            }
            else if(SerType == 5){
                LoadhtmlPg = "technical-verification.html";
            }

            var UlData = $(
                "<ul LedFk =" + AgentData[i].LajLedFk + " LajFk = " + AgentData[i].LajPk + " RefPk = " + AgentData[i].Pk + " AgtFk = " + AgentData[i].AgtPk + " HtmlPg = " + LoadhtmlPg + " onclick=fnBeforeLoadHtml(this)>" +
                    "<li>" +
                        "<i class='icon-agents'></i>" +
                        "<div class='clear'></div>" +
                        "<span class='bg bg5'>"+ AgentData[i].AgentJob +"</span>" +
                    "</li>" +
                    "<li class='read-only'>" +
                        "<p>" + AgentData[i].AgentName + "</p>" +
                        "<label>" + AgentData[i].LeadId + "</label>" +
                        "<p>" + AgentData[i].AppName + "</p>" +
                    "</li>" +
                    "<li class='status'>" +
                        "<p class='bg " + bg + "'><i class='icon-pending'></i></p>" +
                        "<div class='clear'></div>" +
                        "<p>Due " + DueDys + " days</p>" +
                   "</li>" +
                "</ul>"
            )
            $(".agent-list").append(UlData);
        }
    }
}

function fnBeforeLoadHtml(ulObj) {

    GlobalXml[0].FwdDataPk = $(ulObj).attr("LedFk");
    GlobalXml[0].LajFk = $(ulObj).attr("LajFk");
    GlobalXml[0].RefPk = $(ulObj).attr("RefPk");
    GlobalXml[0].AgtFk = $(ulObj).attr("AgtFk");

    LoadHtmlDiv($(ulObj).attr("HtmlPg"));
}