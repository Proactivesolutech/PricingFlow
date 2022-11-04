$(document).ready(function () {
    console.log("post");
    fnaddRole();
    fnaddGeo();
    fnSelectData();
    fnclick();
});
function fnclr() {
    $("#UsrRolTbl tbody tr").empty();
    $("#UsrGeoTbl tbody tr").empty();
    $('#usrRolDetails').val('0');
    $('#UsrGeoDetails').val('0');
    $('#UserCde').val('');
    $('#UserNm').val('');
    $('#UserPwd').val('');
    $('#pk_id').val('');
}
function fnclear() {
    $("#UsrRolTbl tbody").empty();
    $("#UsrGeoTbl tbody").empty();
}

function fnclick() {
    (function () {
        if (window.addEventListener) {
            window.addEventListener('load', run, false);
        } else if (window.attachEvent) {
            window.attachEvent('onload', run);
        }

        function run() {
            var t = document.getElementById('UserTbl');
            t.onclick = function (event) {
                event = event || window.event; //IE8
                var target = event.target || event.srcElement;
                while (target && target.nodeName != 'TR') { // find TR
                    target = target.parentElement;
                }
                var cells = target.cells;
                if (!cells.length || target.parentNode.nodeName == 'THEAD') {
                    return;
                }
                var f1 = document.getElementById('UserCde');
                var f2 = document.getElementById('UserNm');
                var f3 = document.getElementById('pk_id');
                var f4 = document.getElementById('UserPwd');
                f1.value = cells[0].innerHTML;
                f2.value = cells[1].innerHTML;
                f3.value = cells[2].innerHTML;
                f4.value = cells[3].innerHTML;
                fnSelRowData();
            };
        }
    })();
}

function fnInsUpd() {

    var text = $("#pk_id").val()
    if (text == 0) {
        fnSaveData();
    }
    else
        fnUpdateData();
}

function fnclose(elem) {
    //if ($("#test ul").length == 1)
    //    return;
    $($(elem).parent().parent()).remove();
}
function fnSelRowData() {
    var Pk = $("#pk_id").val();
    if (Pk.trim() == "" || isNaN(Pk))
        return;
    var objProcData = { ProcedureName: "PrcGenUsrMaster", Type: "SP", Parameters: ['SELTBL', '', '', '', Pk] };
    fnCallWebService("SELTBL", objProcData, fnBPMResult, "MULTI");
}

function fnSelectData() {
    var Pk = $("#pk_id").val();
    var objProcData = { ProcedureName: "PrcGenUsrMaster", Type: "SP", Parameters: ['SELECT', '', '', '', ''] };
    fnCallWebService("SELECT", objProcData, fnBPMResult, "MULTI");
}

function fnUpdateData() {


    var Pk = $("#pk_id").val();
    var usrCod = $("#UserCde").val();
    var usrName = $("#UserNm").val();
    var usrPwd = $("#UserPwd").val();
    var data = [{ UserCode: usrCod, UserName: usrName, UserPassword: usrPwd }];
    var json_usrEntryData = JSON.stringify(data);

    var jsonArr = [];

    $("#UsrRolTbl tbody tr").each(function () {
        var jsonObj = {};
        var Rolid = $(this).attr('pk');
        //var name = $(this).attr("name");
        jsonObj["roledesc"] = Rolid;
        jsonArr.push(jsonObj);
    });


    var json_roledata = JSON.stringify(jsonArr);


    var jsonArr1 = [];
    $("#UsrGeoTbl tbody tr").each(function () {
        var jsonObj1 = {};
        var Geoid = $(this).attr('pk');
        //var name = $(this).attr("name");
        jsonObj1["geodesc"] = Geoid;
        jsonArr1.push(jsonObj1);

    });

    var json_Geodata = JSON.stringify(jsonArr1);



    var objProcData = { ProcedureName: "PrcGenUsrMaster", Type: "SP", Parameters: ['UPDATE', json_usrEntryData, json_roledata, json_Geodata, Pk] };
    fnCallWebService("UPDATE", objProcData, fnBPMResult, "MULTI");
}
function fnDeleteData() {
    var Pk = $("#pk_id").val();
    var objProcData = { ProcedureName: "PrcGenUsrMaster", Type: "SP", Parameters: ['DELETE', '', '', '', Pk] };
    fnCallWebService("DELETE", objProcData, fnBPMResult, "MULTI");

}





function fnInsRole() {

    var Role = $("#usrRolDetails :selected").text();
    var Rolval = $("#usrRolDetails").val();
    if (Rolval == 0) {
        return;
    }
    //var roledesc = "roledesc"
    if ($("#UsrRolTbl tbody tr[pk='" + Rolval + "']").length == 0) {
        tr = "<tr pk='" + Rolval + "'><td>" + Role + "</td></tr>";
        $("#UsrRolTbl tbody").append(tr);

    }
    $('#usrRolDetails').val('0');
}
function fnInsGeo() {
    var Geo = $("#UsrGeoDetails :selected").text();
    var Geoval = $("#UsrGeoDetails").val();
    if (Geoval == 0) {
        return;
    }
    //var geodesc = "geodesc";
    if ($("#UsrGeoTbl tbody tr[pk='" + Geoval + "']").length == 0) {
        tr = "<tr pk='" + Geoval + "' ><td>" + Geo + "</td></tr>";
        $("#UsrGeoTbl tbody").append(tr);
    }
    $('#UsrGeoDetails').val('0');
}

function fnaddRole() {
    var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['ADDROLE', ''] };
    fnCallWebService("ADDROLE", objProcData, fnBPMResult, "MULTI");

}
function fnaddGeo() {

    var objProcData = { ProcedureName: "GeoDetails", Type: "SP", Parameters: ['ADDGEO', ''] };
    fnCallWebService("ADDGEO", objProcData, fnBPMResult, "MULTI");
}

function fnSaveData() {

    var usrCod = $("#UserCde").val();
    var usrName = $("#UserNm").val();
    var usrPwd = $("#UserPwd").val();
    var data = [{ UserCode: usrCod, UserName: usrName, UserPassword: usrPwd }];
    var json_usrEntryData = JSON.stringify(data);

    var jsonArr = [];

    $("#UsrRolTbl tbody tr").each(function () {
        var jsonObj = {};

        var Rolid = $(this).attr('pk');
        //var name = $(this).attr("name");
        jsonObj["roledesc"] = Rolid;
        jsonArr.push(jsonObj);
    });


    var json_roledata = JSON.stringify(jsonArr);


    var jsonArr1 = [];
    $("#UsrGeoTbl tbody tr").each(function () {
        var jsonObj1 = {};
        var Geoid = $(this).attr('pk');
        //var name = $(this).attr("name");
        //var val1 = $("#gen").getVal();
        //var name1 = $("#gen").attr(name);
        jsonObj1["geodesc"] = Geoid;
        //jsonObj1["geodesc"] = Geoid;
        jsonArr1.push(jsonObj1);

    });

    var json_Geodata = JSON.stringify(jsonArr1);

    var objProcData = { ProcedureName: "PrcGenUsrMaster", Type: "SP", Parameters: ['SAVE', json_usrEntryData, json_roledata, json_Geodata] };
    fnCallWebService("SAVE", objProcData, fnBPMResult, "MULTI");
    //fnCallLOSWebService("LOSSAVE", objProcData, fnBPMResult, "MULTI");
}
function fnBPMResult(ServDesc, Obj, Param1, Param2, Param3) {


    if (ServDesc == "SAVE") {
        alert("Saved Succesfully");
        fnSelectData();
        fnclr();
    }


    if (ServDesc == "UPDATE") {
        alert("Updated  Succesfully");
        fnSelectData();
        fnSelRowData();
        //fnclr();
    }

    if (ServDesc == "DELETE") {
        alert("Deleted Successfully");
        fnSelectData();

        fnclr();
    }
    if (ServDesc == "SELTBL") {
        var Usrdata = JSON.parse(Obj.result_1);
        var RolData = JSON.parse(Obj.result_2);
        var GeoData = JSON.parse(Obj.result_3);
        $("#UsrRolTbl tbody ").empty();
        $("#UsrGeoTbl tbody ").empty();
        for (var i = 0; i < Usrdata.length; i++) {
            $("#UserCde").val(Usrdata[i].UsrCode);
            $("#UserNm").val(Usrdata[i].UsrNm);
            $("#UserPwd").val(Usrdata[i].UsrPwd);
        }
        var tr;
        for (var j = 0; j < RolData.length; j++) {
            tr += "<tr pk='" + RolData[j].RoleFk + "'><td>" + RolData[j].RolNm + "</td></tr>";
        }

        $("#UsrRolTbl tbody").append(tr);
        $('#UsrRolTbl tr td:nth-child(2)').hide();

        var trG;
        for (var k = 0; k < GeoData.length; k++) {
            trG += "<tr pk='" + GeoData[k].GeoFk + "'><td>" + GeoData[k].GeoNm + "</td></tr>";
        }

        $("#UsrGeoTbl tbody").append(trG);
        $('#UsrGeoTbl tr td:nth-child(2)').hide();


    }

    if (ServDesc == "ADDROLE") {

        var data = JSON.parse(Obj.result);
        var option = '<option value ="0" selected>Choose User Roles</option>';
        for (var i = 0; i < data.length; i++) {
            option += '<option value ="' + data[i].RolPk + '">' + data[i].RolNm + '</option>';

        }

        $("#usrRolDetails").append(option);
    }

    if (ServDesc == "ADDGEO") {

        var data = JSON.parse(Obj.result);
        var option = '<option value ="0" selected>Choose User Location</option>';
        for (var i = 0; i < data.length; i++) {
            option += '<option value ="' + data[i].GeoPk + '">' + data[i].GeoNm + '</option>';

        }

        $("#UsrGeoDetails").append(option);
    }

    if (ServDesc == "SELECT") {
        var data = JSON.parse(Obj.result);

        $("#UserTbl").empty();
        var tr = "<caption>List of users</caption> <tr><th> User Code</th><th>User Name</th><th style='display:none;'>&nbsp</th><th>Password</th>";
        for (var i = 0; i < data.length; i++) {
            tr += "<tr><td>" + data[i].UsrCode + "</td><td>" + data[i].UsrNm + "</td><td style='display:none;'>" + data[i].UsrPk + "</td><td>" + data[i].UsrPwd + "</td></tr>";
        }

        $("#UserTbl").append(tr);
        // $('#UserTbl tr td:nth-child(3)').hide();
        // $('#UserTbl tr td:nth-child(4)').hide();
    }


}