$(document).ready (function()
{
    fnSelectData()
    calcHeight(); //Viewport Height Function Starts
    commontabs(); //Common tab style
    querypopup();
    rightdocument(); /*Document Popup*/
    popupclose(); /*close popup function*/
});


        function fnclear() {
            $('#RolNm').val('');
            $('#RolLvlNo').val('0');
            $('#RolPk').val('');
        }

        function fnInsUpd() {
            var text = $("#RolPk").val()
            if (text == 0) {
                fnSaveData();
            }
            else
                fnUpdateData();
        }

        function fnSaveData() {
            var objProcData = { ProcedureName: "RoleDetails", Type: "SP", Parameters: ['INSERT', $("#RolNm").val(), $("#RolLvlNo").val()] };
            fnCallWebService("INSERT", objProcData, fnBPMResult, "MULTI");
            fnCallLOSWebService("LOSINSERT", objProcData, fnBPMResult, "MULTI");
        }

        function fnSelectData() {
            var objProcData = { ProcedureName: "RoleDetails", Type: "SP", Parameters: ['SELECT', '', '', ''] };
            fnCallWebService("SELECT", objProcData, fnBPMResult, "MULTI");
        }

        function fnUpdateData() {
            var objProcData = { ProcedureName: "RoleDetails", Type: "SP", Parameters: ['UPDATE', $("#RolNm").val(), $("#RolLvlNo").val(), $("#RolPk").val()] };
            fnCallWebService("UPDATE", objProcData, fnBPMResult, "MULTI");
        }

        function fnDeleteData() {
            var objProcData = { ProcedureName: "RoleDetails", Type: "SP", Parameters: ['DELETE', '', '', $("#RolPk").val()] };
            fnCallWebService("DELETE", objProcData, fnBPMResult, "MULTI");
        }


function fnBPMResult(ServDesc, Obj, Param1, Param2, Param3) {
    debugger;
    if (ServDesc == "INSERT") {
        alert("Saved Succesfully");
        fnSelectData();
        fnclear();
    }

    if (ServDesc == "SELECT") {
        var data = JSON.parse(Obj.result);

        $("#RolTbl").empty();
        var tr = "<caption>ROLE MASTER DETAILS</caption> </br><tr><th> Level No</th><th> Name</th>";
        for (var i = 0; i < data.length; i++) {
            tr += "<tr onclick='fnselval(this);'><td>" + data[i].RolLvlNo + "</td><td>" + data[i].RolNm + "</td><td id='rolpk'>" + data[i].RolPk + "</td></tr>";
        }
        $("#RolTbl").append(tr);
        $('#RolTbl tr td:nth-child(3)').hide();
    }

    if (ServDesc == "UPDATE") {
        alert("Updated Successfully");
        fnSelectData();
        fnclear();
    }

    if (ServDesc == "DELETE") {
        alert("Deleted Successfully");
        fnSelectData();
        fnclear();
    }
    if (ServDesc == "SEL_ROW") {        
        var seldata = JSON.parse(Obj.result_1);
        var pkdata = JSON.parse(Obj.result_2);
        $("#RolPk").val(pkdata[0].PK);
        $("#RolNm").val(seldata[0].RolNm);
        $("#RolLvlNo").find("option[selected='selected']").attr("value", seldata[0].RolLvlNo);      
        if (seldata[0].RolLvlNo == 1) {        
            $("#RolLvlNo").find("option[selected='selected']").text("Branch");
        } else if (seldata[0].RolLvlNo == 2) {
            $("#RolLvlNo").find("option[selected='selected']").text("Zonal");
        } else if (seldata[0].RolLvlNo == 3) {
            $("#RolLvlNo").find("option[selected='selected']").text("State");
        } else if (seldata[0].RolLvlNo == 4) {
            $("#RolLvlNo").find("option[selected='selected']").text("Central");
        }
       
    }

}
function fnselval(tr) {
    var rolpk=$(tr).find("td[id='rolpk']").text();
    var objProcData = { ProcedureName: "RoleDetails", Type: "SP", Parameters: ['SEL_ROW', '', '',rolpk] };
    fnCallWebService("SEL_ROW", objProcData, fnBPMResult, "MULTI");
}
