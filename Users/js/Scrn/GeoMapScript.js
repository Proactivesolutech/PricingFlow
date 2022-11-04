$(document).ready(function ()
{
    //fnclick();
    fnSelectData();
    calcHeight(); //Viewport Height Function Starts
    commontabs(); //Common tab style
    querypopup();
    rightdocument(); /*Document Popup*/
    popupclose(); /*close popup function*/
});


function fnInsUpd() {
    var text = $("#Fk").val()
    if (text == "")
    {
        fnInsertData();
    }
    else
        fnUpdateData();
}


    function fnSelectData() {
        var objProcData = { ProcedureName: "GeoMapDetails", Type: "SP", Parameters: ['SELECT','','','','',''] };
        fnCallWebService("SELECT", objProcData, fnBPMResult, "MULTI");
    }


    function fnInsertData() {
        debugger;
        var brnh = $("#comp-help_l1").find("input[name='helptext']").attr("val");
        var znl = $("#comp-help_l2").find("input[name='helptext']").attr("val");
        var ste = $("#comp-help_l3").find("input[name='helptext']").attr("val");
        var ctl = $("#comp-help_l4").find("input[name='helptext']").attr("val");
        var objProcData = { ProcedureName: "GeoMapDetails", Type: "SP", Parameters: ['SAVE', brnh, znl, ste, ctl] };
   
    fnCallWebService("SAVE", objProcData, fnBPMResult, "MULTI");
    fnCallLOSWebService("LOSSAVE", objProcData, fnBPMResult, "MULTI");
    }

    function fnUpdateData() {
        debugger;
        var brnh = $("#comp-help_l1").find("input[name='helptext']").attr("val");
        var znl = $("#comp-help_l2").find("input[name='helptext']").attr("val");
        var ste = $("#comp-help_l3").find("input[name='helptext']").attr("val");
        var ctl = $("#comp-help_l4").find("input[name='helptext']").attr("val");
        var objProcData = { ProcedureName: "GeoMapDetails", Type: "SP", Parameters: ['UPDATE', brnh, znl, ste, ctl, $("#Fk").val()] };
        fnCallWebService("UPDATE", objProcData, fnBPMResult, "MULTI");
    }
    
    function fnDeleteData() {
        var objProcData = { ProcedureName: "GeoMapDetails", Type: "SP", Parameters: ['DELETE', '', '','','', $("#Fk").val()] };
        fnCallWebService("DELETE", objProcData, fnBPMResult, "MULTI");
    }

    function fnselval(fkval) {
        debugger;
        var val = $(fkval).find("td[style='display: none;']").text();
        var objProcData = { ProcedureName: "GeoMapDetails", Type: "SP", Parameters: ['SET_VAL', '', '', '', '', val] };
        fnCallWebService("SET_VAL", objProcData, fnBPMResult, "MULTI");
    }
    



    function fnBPMResult(ServDesc, Obj, Param1, Param2, Param3) {
        debugger;
        if (ServDesc == "SET_VAL") {
            debugger;
            var Bdata = JSON.parse(Obj.result_1);
            var zoldata = JSON.parse(Obj.result_2);
            var stdata = JSON.parse(Obj.result_3);
            var celdata = JSON.parse(Obj.result_4);
            var pk = JSON.parse(Obj.result_5);
            $("#comp-help_l1").find("input[name='helptext']").attr("val", Bdata[0].pk);
            $("#comp-help_l2").find("input[name='helptext']").attr("val", zoldata[0].pk);
            $("#comp-help_l3").find("input[name='helptext']").attr("val", stdata[0].pk);
            $("#comp-help_l4").find("input[name='helptext']").attr("val", celdata[0].pk);
            $("#comp-help_l1").find("input[name='helptext']").val(Bdata[0].GeoNm);
            $("#comp-help_l2").find("input[name='helptext']").val(zoldata[0].GeoNm);
            $("#comp-help_l3").find("input[name='helptext']").val(stdata[0].GeoNm);
            $("#comp-help_l4").find("input[name='helptext']").val(celdata[0].GeoNm);
            $("#Fk").val(pk[0].pk);
        }
        if (ServDesc == "SELECT") {
        var data = JSON.parse(Obj.result);
        $("#GeoMapTbl").empty();
        var tr = "<caption>GEO MAP DETAILS</caption> <tr><th> Branch</th><th> Zone</th><th>State</th><th>CENTRAL</th></tr>";
        for (var i = 0; i < data.length; i++) {
            tr += "<tr onclick='fnselval(this);'><td>" + data[i].Branch + "</td><td>" + data[i].Zone + "</td><td>" + data[i].State + "</td><td>" + data[i].Centre + "</td><td>" +data[i].Fk + "</td></tr>";
        }
         $("#GeoMapTbl").append(tr);
        $('#GeoMapTbl tr td:nth-child(5)').hide();
         }

        if(ServDesc == "UPDATE")
        {
        alert("Updated Successfully")
        fnSelectData();
        fnclear();    
        }

        if (ServDesc == "SAVE") {
            alert("Saved Succesfully");
            fnSelectData();
            fnclear();
        }
        if (ServDesc == "DELETE") {
            alert("Deleted Successfully");
            fnSelectData();
            fnclear();
        }
}
    function fnclear() {
        $("#comp-help_l1").find("input[name='helptext']").val('');
        $("#comp-help_l2").find("input[name='helptext']").val('');
        $("#comp-help_l3").find("input[name='helptext']").val('');
        $("#comp-help_l4").find("input[name='helptext']").val('');
        $('#Fk').val('');
    }




