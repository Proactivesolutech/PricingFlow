$(document).ready(function ()
{  
    fnSelectData();
    calcHeight(); //Viewport Height Function Starts
    commontabs(); //Common tab style
    querypopup();
    rightdocument(); /*Document Popup*/
    popupclose(); /*close popup function*/
});

    function fnclear(){
        $('#GeoNm').val('');
        $('#GeoLvlNo').val('0');
        $('#GeoLvlNo').text('');
        $('#GeoPk').val('');
    }


    function fnInsUpd()
    {
        var text = $("#GeoPk").val()
        if (text == 0){
            fnSaveData();
        }
        else
            fnUpdateData();
    }

    function fnSaveData() {      
        var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['INSERT', $("#GeoNm").val(), $("#GeoLvlNo").val()] };
        fnCallWebService("INSERT", objProcData, fnBPMResult, "MULTI");
        fnCallLOSWebService("LOSINSERT", objProcData, fnBPMResult, "MULTI");
    }

    function fnSelectData() {
        var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['SELECT','','',''] };
        fnCallWebService("SELECT", objProcData, fnBPMResult, "MULTI");
    }

    function fnUpdateData() {
        var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['UPDATE', $("#GeoNm").val(), $("#GeoLvlNo").val(),$("#GeoPk").val()] };
        fnCallWebService("UPDATE", objProcData, fnBPMResult, "MULTI");
    }

    function fnDeleteData() {
        var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['DELETE','','',$("#GeoPk").val()] };
        fnCallWebService("DELETE", objProcData, fnBPMResult, "MULTI");
    }

    function fnBPMResult(ServDesc, Obj, Param1, Param2, Param3) {

          if (ServDesc == "INSERT") {
            alert("Saved Succesfully");
            fnSelectData();
            fnclear();
         }

         if (ServDesc == "SELECT") {
             var data = JSON.parse(Obj.result);
    
            $("#GeoTbl").empty();
            var tr = "<caption>GEO MASTER DETAILS</caption> <tr><th> Level No</th><th> Name</th>";
            for (var i = 0; i < data.length; i++) {
                tr += "<tr onclick='fnselval(this);'><td>" + data[i].GeoLvlNo + "</td><td>" + data[i].GeoNm + "</td><td id='geopk'>" + data[i].GeoPk + "</td></tr>";
            }
       
            $("#GeoTbl").append(tr);
            $('#GeoTbl tr td:nth-child(3)').hide();
         }

        if(ServDesc == "UPDATE")
        {
        alert("Updated Successfully")
        fnSelectData();
        fnclear();    
        }

        if (ServDesc == "DELETE")
        {
            alert("Deleted Successfully");
            fnSelectData();
            fnclear();
        }
       
        if (ServDesc == "SAVE") {
            alert("Saved Succesfully");
            fnclear();
        }
        if (ServDesc == "SEL_ROW") {
            var seldata = JSON.parse(Obj.result_1);
            var pkdata = JSON.parse(Obj.result_2);
            $("#GeoPk").val(pkdata[0].PK);
            $("#GeoNm").val(seldata[0].GeoNm);
            $("#GeoLvlNo").find("option[selected='selected']").attr("value", seldata[0].RolLvlNo);
            if (seldata[0].GeoLvlNo == 1) {
                $("#GeoLvlNo").find("option[selected='selected']").text("Branch");
            } else if (seldata[0].GeoLvlNo == 2) {
                $("#GeoLvlNo").find("option[selected='selected']").text("Zonal");
            } else if (seldata[0].GeoLvlNo == 3) {
                $("#GeoLvlNo").find("option[selected='selected']").text("State");
            } else if (seldata[0].GeoLvlNo == 4) {
                $("#GeoLvlNo").find("option[selected='selected']").text("Central");
            }
        }
    }
    function fnselval(tr) {
        var Geopk = $(tr).find("td[id='geopk']").text();
        var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['SEL_ROW', '', '', Geopk] };
        fnCallWebService("SEL_ROW", objProcData, fnBPMResult, "MULTI");
    }


