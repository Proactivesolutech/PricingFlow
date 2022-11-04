
function fnGenRept() {    
    if ($('#FrmDt').val() == "") {
        fnShflAlert("warning", "Provide From Date.");
        return;
    }

    if ($('#ToDt').val() == "") {
        fnShflAlert("warning", "Provide To Date.");
        return;
    }

    var CurrentDate = new Date();
   
    var Frmdate = $('#FrmDt').val().substring(0, 2);
    var Frmmonth = $('#FrmDt').val().substring(3, 5);
    var Frmyear = $('#FrmDt').val().substring(6, 10);

    var Frmdt = new Date(Frmyear, Frmmonth - 1, Frmdate);

    var Todate = $('#ToDt').val().substring(0, 2);
    var Tomonth = $('#ToDt').val().substring(3, 5);
    var Toyear = $('#ToDt').val().substring(6, 10);

    var ToDt = new Date(Toyear, Tomonth - 1, Todate);


    if (Frmdt > CurrentDate || ToDt > CurrentDate) {
        fnShflAlert("warning", "Selected date should not be greater than current date.");
        return;
    }

    if (Frmdt > ToDt) {
        fnShflAlert("warning", "From date should not be greater than To date.");
        return;
    }
    var objProcData = { ProcedureName: "PrcShflExceptionReport", Type: "SP", Parameters: ["PFOverride", $('#FrmDt').val(), $('#ToDt').val()] };
    fnCallLOSWebService("PFOverride", objProcData, fnExceptionResult, "MULTI");
}

function fnExceptionResult(service, Obj, param1, param2) {
    if (service == "PFOverride") {
        var Ovrrideinfo = JSON.parse(Obj.result);
        if (Ovrrideinfo.length > 0) {
            JSONToCSVConvertor(Ovrrideinfo, true, "PFOverride From " + $('#FrmDt').val() + " To " + $('#ToDt').val());
        }       
        else {
            fnShflAlert("warning", "There is no PF override details during selected period.");
            return;
        }
    }
}

