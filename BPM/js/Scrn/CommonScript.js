function guid() {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
          .toString(16)
          .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
      s4() + '-' + s4() + s4() + s4();
}

function isJson(str) {
    var result = false;
    str = str.trim();
    if ((str.indexOf("{") == 0 && str.indexOf("}") == str.length - 1) || (str.indexOf("[") == 0 && str.indexOf("]") == str.length - 1))
        result = true;
    return result;
}

function generateGuid() {
    return ("0000" + (Math.random() * Math.pow(36, 4) << 0).toString(36)).slice(-4);
}

function fnAddSelectOptwitVal(optns, id) {
    var options = JSON.parse(optns);
    var op = "";
    for (var i = 0; i < options.length; i++) {
        if (i == 0)
            op += "<option>--SELECT--</option>";
        op += "<option value=" + options[i].value + ">" + options[i].text + "</option>";
    }
    $("#" + id).append(op);
    $("#" + id).select2({
        width: '100%'
    });
    //$("#" + id).prop("disabled", true);
}

function fnAddNormalSelectOptions(optns, id, Flg) {
    var options = JSON.parse(optns);
    var op = "";
    for (var i = 0; i < options.length; i++) {
        if (i == 0 && Flg == 0)
            op += "<option>--SELECT--</option>";
        op += "<option>" + options[i] + "</option>";
    }
   $(id).append(op);
}

function fnAddSelectOptions(optns, id, Flg) {
    var options = JSON.parse(optns);
    var op = "";
    for (var i = 0; i < options.length; i++) {
        if (i == 0 && Flg == 0)
            op += "<option>--SELECT--</option>";
        op += "<option>" + options[i] + "</option>";
    }
    $("#" + id).append(op);
    $("#" + id).select2({
        width: '100%'
    });
    //$("#" + id).prop("disabled", true);
}

function fnCheckMandatory(formID) {
    var IsFormValid = true;
    var ErrInputs = [];
    $("#" + formID + " input[type=text]").each(function () {
        var id = $(this).attr("id");
        if (id != "" && id != null && id != undefined) {
            var IsMandate = (document.getElementById(id).isMandatory == undefined || document.getElementById(id).isMandatory == null) ? $("#" + id).attr("isMandatory") : document.getElementById(id).isMandatory;
            if (IsMandate || IsMandate == "true") {
                var isvalid = fnCheckValidInputValue(id, 1);
                if (!isvalid) {
                    IsFormValid = false;
                    ErrInputs.push(id);
                    $("#" + id).css("border", "1px solid red");
                }
                else {
                    $("#" + id).css("border", "");
                }
            }
            else {
                $("#" + id).css("border", "");
            }
        }
    });
    return IsFormValid;
}


function fnCheckValidInputValue(InputId, Flag) { // 1- input text, 2 - select 
    var Isvalid = true;
    var value = $("#" + InputId).val();
    if (Flag == 1) {
        if (value.trim() == "" || value == null || value == undefined) {
            Isvalid = false;
        }
    }
    if (Flag == 2) {
        if (value.trim() == "" || value == null || value == undefined || value == "-1" || value == -1 || value.toLowerCase() == "--select--") {
            Isvalid = false;
        }
    }
    return Isvalid;
}

function fnClearFormValsJson(FormID) {
    var arrValue = [];
    $("#" + FormID + " input[type=text]").each(function () {
        $(this).val("");
    });

    $("#" + FormID + " input[type=number]").each(function () {
        $(this).val("");
    });

    $("#" + FormID + " input[type=password]").each(function () {
        $(this).val("");
    });

    $("#" + FormID + " select").each(function () {
        $(this).val("");
    });
}


function fnGetFormValsJson_IdVal(FormID) {
    debugger;
    var arrValue = [];

    $("#" + FormID + " input[type=text]").each(function () {
        var nm1 = $(this).attr("id");
        arrValue.push({ id: nm1, idval: $(this).val() })
    });

    $("#" + FormID + " input[type=password]").each(function () {
        var nm2 = $(this).attr("id");
        arrValue.push({ id: nm2, idval: $(this).val() })
    });

    $("#" + FormID + " input[type=number]").each(function () {
        var nm3 = $(this).attr("id");
        arrValue.push({ id: nm3, idval: $(this).val() })
    });


    $("#" + FormID + " select").each(function () {
        var nm4 = $(this).attr("id");
        arrValue.push({ id: nm4, idval: $(this).val() })
    });

    return arrValue;
}

function fnGetFormValsJson(FormID) {
    var arrValue = [{}];
    $("#" + FormID + " input[type=text]").each(function () {
        var nm = $(this).attr("label");
        nm = nm.replace(/ /g, "_");
        arrValue[0][nm] = $(this).val();
    });
    return arrValue;
    /*
    OLD
    */

    $("#" + FormID + " input[type=text]").each(function () {
        var Id = $(this).attr("id");
        var DivId = "div_" + Id;
        var label = $("#" + DivId + " label").text();
        var Value = $(this).val();
        arrValue.push({ TYPE: "TEXT", ID: Id, LABEL: label, TEXTVALUE: Value, SELVALUE: "" });
    });
    $("#" + FormID + " select").each(function () {
        var Id = $(this).attr("id");
        var DivId = "div_" + Id;
        var label = $("#" + DivId + " label").text();
        var Value = $(this).val();
        arrValue.push({ TYPE: "SELECT", ID: Id, LABEL: label, TEXTVALUE: "", SELVALUE: Value });
    });
    return arrValue;
}

function fnFormClear(FormID) {
    $("#" + FormID + " input[type=text]").each(function () { $(this).val("") });
    //$("#" + FormID + " select").each(function () { });
}


function fnUploadFiles(ServDesc, fileData, callback) {
    if (fileData != null && fileData != "") {
        fnCallFileUploadWebService(ServDesc, fileData, callback, "", "");
    }
}

function fnReverseString(str) {
    if (str == "" || str == null) {
        alert("cannot process");
        return;
    }
    var ans = [];
    var ansStr = "";
    var arrStr = [];
    var val = "";
    var isValid = false;
    for (var a = 0; a < str.length; a++) {
        var char = str[a];
        if (char != " ") {
            isValid = true;
            val += char;
        }
        else {
            if (isValid) arrStr.push(val);
            val = "";
            isValid = false;
        }

        if (a == str.length - 1) { if (isValid) arrStr.push(val); }
    }

    for (var i = 0; i < arrStr.length; i++) {
        var TempArr = arrStr[i];
        for (var j = 0; j < TempArr.length; j++) {
            if (j == 0)
                ans[i] = TempArr[(TempArr.length - 1) - j];
            else
                ans[i] += TempArr[(TempArr.length - 1) - j];
        }
    }

    for (var k = 0; k < ans.length; k++) {
        ansStr += ans[k] + " ";
    }
    return ansStr;
}

function fnReverseString_1(str) {
    if (str == "" || str == null) {
        alert("cannot process");
        return;
    }
    var reverseStr = "";
    var Tans = "";
    for (var i = 0; i < str.length; i++) {
        var temp = str[i];
        if (temp != " ") {
            Tans = temp + Tans;
        }
        else {
            reverseStr = reverseStr + Tans + " ";
            Tans = "";
        }

        if (i == str.length - 1) {
            reverseStr = reverseStr + Tans + " ";
        }
    }
    return reverseStr;
}