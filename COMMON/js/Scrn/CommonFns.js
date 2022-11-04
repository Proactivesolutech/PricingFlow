
function getCurrDateTime() {
    try {
        var dt = new Date();
        var Month = parseInt(dt.getMonth()) + 1;
        var dtstring = dt.getFullYear()
            + '-' + Month
            + '-' + dt.getDate()
            + ' ' + dt.getHours()
            + ':' + dt.getMinutes()
            + ':' + dt.getSeconds()
        return dtstring;
    } catch (ex) { return ''; }
}

function setLocalStorage(id, val) {
    if (!val) { val = "" }
    val = (val == "undefined" || val == "null") ? "" : val;
    localStorage.setItem(Encrypt(id), Encrypt(val.toString()));
}

function getLocalStorage(id) {
    var val = Decrypt(localStorage.getItem(Decrypt(id)));
    return val;
}
function Encrypt(str) {
    if (!str) { str = "" }
    str = (str == "undefined" || str == "null") ? "" : str;
    try {
        var key = 146;
        var pos = 0;
        ostr = '';
        while (pos < str.length) {
            ostr = ostr + String.fromCharCode(str.charCodeAt(pos) ^ key)
            pos += 1;
        };
        return ostr;
    } catch (ex) { return '' }
}

function Decrypt(str) {
    if (!str) { str = "" }
    str = (str == "undefined" || str == "null") ? "" : str;
    try {
        var key = 146;
        var pos = 0;
        ostr = '';
        while (pos < str.length) {
            ostr = ostr + String.fromCharCode(key ^ str.charCodeAt(pos))
            pos += 1;
        };
        return ostr;
    } catch (ex) { return '' }
}

$(document).on("focusin", ".currency", function () {
    debugger;
    var txt = $(this).val() || "";
    txt = txt.trim();
    if (txt == "" || txt.length <= 3)
        return;
    var cur_val = FormatCleanComma($(this).val());
    $(this).val(cur_val);
});
$(document).on("focusout", ".currency", function () {
    var CurVal = $(this).val().trim();
    if (CurVal == "")
        return;

    $(this).val(FormatCurrency(CurVal));
});
function FormatCurrency(value) {
    try {
        if (value == null || value == undefined || value == "")
            return "0";
        value = value.toString();
        value = value.trim();
        value = FormatCleanComma(value);
        var isMinus = false;
        if (value.indexOf("-") == 0) {
            isMinus = true;
            value = value.replace("-", "");
        }

        var samount = value;
        var dVal, sVal;
        var Cnt;

        if (samount.lastIndexOf(".") != -1) {
            sVal = samount.substring(0, samount.lastIndexOf("."));
            dVal = samount.substring(samount.lastIndexOf(".") + 1, samount.length)
        }
        else {
            sVal = samount;
            dVal = "";
        }

        if (parseInt(sVal.length) <= 3) {
            if (dVal == "")
                return  isMinus ? "-" + sVal : sVal;
            else
                return isMinus ? "-" + (sVal + "." + dVal) : (sVal + "." + dVal);

        }

        for (var i = 0; i < Math.floor((sVal.length - (1 + i)) / 2) ; i++) {
            if (i == 0) {
                Cnt = sVal.length - 3;
            }
            else {
                Cnt = Cnt - 2;
            }
            if (sVal.substring(0, Cnt) != "")
                sVal = sVal.substring(0, Cnt) + "," + sVal.substring(Cnt);
        }

        if (dVal == "")
            return isMinus ? "-" + sVal : sVal;
        else
            return ((isMinus ? "-" + sVal : sVal) + "." + dVal);
    }
    catch (exception) { alert("Format Comma", exception); }
}

function FormatCleanComma(num) {
    if (!num)
        return 0;
    num = num.toString();
    var sVal = '';
    var nVal = num.length;
    var sChar = '';

    try {
        for (i = 0; i < nVal; i++) {
            sChar = num.charAt(i);
            if (sChar != ",")
                sVal += num.charAt(i);
        }
    }
    catch (exception) { alert("Format Clean", exception); }
    if (num.length == 0) { sVal = 0; }
    return sVal;
}

function UpperCase(UpperValue) {
    if (UpperValue != "") {
        return UpperValue.toUpperCase();
    }
}
function ValidatePAN(nPANNo) {
    if (nPANNo != "") {
        var pancardPattern = /^([a-zA-Z]{5})(\d{4})([a-zA-Z]{1})$/;
        var patternArray = nPANNo.match(pancardPattern);
        if (patternArray == null) {
            return false;
        }
        return true;
    }
}

function isEmail(email, id) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    var IsMail = regex.test(email);
    if (IsMail == false) {
        $(id).css("border-color", "red");
        return false;
    }
    $(id).css("border-color", "");
    return true;
}

$(document).on("focusout", ".email", function () {
    if ($(this).val().trim() == "")
        return;

    var RtnMailSts = isProperEmail($(this).val().trim());
    if (RtnMailSts == false) {
        fnShflAlert("error", "Invalid Mail ID");
        $(this).focus();
    }
});

function isProperEmail(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}


$(document).on("focusout", ".adhar", function () {
    var AadharVal = $(this).val().trim();
    var Sts = false;

    if (AadharVal == "")
        return;

    Sts = validateAadhar(AadharVal);
    if (Sts == false) {
        fnShflAlert("error", "Invalid Adhar No.");
        $(this).focus();
    }
});


function validateAadhar(aadharNo) {
    var isValid = Aahdar_validate(aadharNo);
    return isValid;
}

// multiplication table d
var Aadhar_Multiplication = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
];

// permutation table p
var Aadhar_permutation = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
];

// inverse table inv
var Aadhar_inverse = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

// converts string or number to an array and inverts it
function invArray(array) {

    if (Object.prototype.toString.call(array) == "[object Number]") {
        array = String(array);
    }

    if (Object.prototype.toString.call(array) == "[object String]") {
        array = array.split("").map(Number);
    }

    return array.reverse();

}

// validates checksum
function Aahdar_validate(array) {

    var c = 0;
    var invertedArray = invArray(array);

    for (var i = 0; i < invertedArray.length; i++) {
        c = Aadhar_Multiplication[c][Aadhar_permutation[(i % 8)][invertedArray[i]]];
    }

    return (c === 0);
}

jQuery.fn.justtext = function () {
    return $(this).clone().children().remove().end().text().trim();
};

function fnRestrictDate(field) {
    $(field).change(function () {
        var xDate = $(this).val().trim();
        var arrDateParts = new Array();
        if (xDate.indexOf("/") != -1) {
            arrDateParts = xDate.split('/');
            if (arrDateParts.length != 3) {
                xDate = "";
            }

            if (arrDateParts.length == 3) {
                var dd = parseInt(arrDateParts[0]);
                var mm = parseInt(arrDateParts[1]);
                var yy = parseInt(arrDateParts[2]);
                if ((dd >= 1 && dd <= 31) && (mm >= 1 && mm <= 12) && (yy >= 1000 && yy <= 9999)) {
                    xDate = xDate
                }
                else {
                    xDate = "";
                }
            }
        }
        else {
            xDate = "";
        }
        $(this).val(xDate);
    });
}
//function isalphanumeric(evt) {
//    evt = (evt) ? evt : window.event;
//    var charCode = (evt.which) ? evt.which : evt.keyCode;
//    if (charCode > 48 && (charCode < 65 || charCode > 90) && (charCode < 97 || charCode > 122) && (charCode < 48 || charCode > 57)) {
//        return false;
//    }
//    return true;
//}
$(document).on("keypress", "[restrict='alphanumeric']", function (e) {
    var RtnMobSts = fnAlphanumericKeyPress(e, $(this));
});
function fnAlphanumericKeyPress(e, elem) {
    var a = [];
    var k = e.which ? e.which : e.keyCode;

    for (i = 65; i < 91; i++) {
        a.push(i);
    }

    for (i = 97; i < 123; i++) {
        a.push(i);
    }
    for (i = 48; i < 58; i++) {
        a.push(i);
    }
    if (k == 46 || k == 8 || k == 37 || k == 39) {
        a.push(k);
    }
    if (!(a.indexOf(k) >= 0))
        e.preventDefault();
}
$(document).on("keypress", "[restrict='address']", function (e) {
    var RtnMobSts = fnplotnumKeyPress(e, $(this));
});
function fnplotnumKeyPress(e, elem) {
    var a = [];
    var k = e.which ? e.which : e.keyCode;

    for (i = 31; i < 91; i++) {
        a.push(i);
    }
    for (i = 93; i < 126; i++) {
        a.push(i);
    }
    if (k == 46 || k == 8 || k == 37 || k == 39) {
        a.push(k);
    }
    if (!(a.indexOf(k) >= 0))
        e.preventDefault();
}

//function isalphaspace(evt) {
//    evt = (evt) ? evt : window.event;
//    var charCode = (evt.which) ? evt.which : evt.keyCode;
//    if (charCode > 64 && (charCode < 65 || charCode > 90) && (charCode < 97 || charCode > 122) && (charCode < 31 || charCode > 33)) {
//        return false;
//    }
//    return true;
//}
$(document).on("keypress", "[restrict='alphaspace']", function (e) {
    var RtnMobSts = fnAlphaspaceKeyPress(e, $(this));
});
function fnAlphaspaceKeyPress(e, elem) {
    var a = [];
    var k = e.which ? e.which : e.keyCode;

    for (i = 65; i < 91; i++) {
        a.push(i);
    }

    for (i = 97; i < 123; i++) {
        a.push(i);
    }
    for (i = 32; i < 33; i++) {
        a.push(i);
    }
    if (k == 46 || k == 8 || k == 37 || k == 39) {
        a.push(k);
    }
    if (!(a.indexOf(k) >= 0))
        e.preventDefault();
}
//function isalpha(evt) {
//    evt = (evt) ? evt : window.event;
//    var charCode = (evt.which) ? evt.which : evt.keyCode;
//    if (charCode > 64 && (charCode < 64 || charCode > 91) && (charCode < 96 || charCode > 123)) {
//        return false;
//    }
//    return true;
//}
$(document).on("keypress", "[restrict='alphaonly']", function (e) {
    var RtnMobSts = fnAlphaKeyPress(e, $(this));
});
function fnAlphaKeyPress(e, elem) {
    var a = [];
    var k = e.which ? e.which : e.keyCode;

    for (i = 65; i < 91; i++) {
        a.push(i);
    }

    for (i = 97; i < 123; i++) {
        a.push(i);
    }
    if (k == 46 || k == 8 || k == 37 || k == 39) {
        a.push(k);
    }
    if (!(a.indexOf(k) >= 0))
        e.preventDefault();
}
function isNumber(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}
$(document).on("keypress", "[restrict='number']", function (e) {
    var RtnMobSts = fnNumberKeyPress(e,$(this));
});
function fnNumberKeyPress(e, elem) {
    var a = [];
    var k = e.which ? e.which : e.keyCode;

    for (i = 48; i < 58; i++)
        a.push(i);

    if (k == 46 || k == 8 || k == 39 || k == 45) {
        a.push(k);
    }

    if (!(a.indexOf(k) >= 0))
        e.preventDefault();
}
//function isNumber(evt) {
//    debugger;
//    evt = (evt) ? evt : window.event;
//    var charCode = (evt.which) ? evt.which : evt.keyCode;
//    if (charCode > 31 && (charCode < 48 || charCode > 57) && (charCode < 44 || charCode > 46)) {
//        return false;
//    }
//    return true;
//}
$(document).on("keypress", "[restrict='numbersub']", function (e) {
    var RtnMobSts = fnNumberSubKeyPress(e, $(this));
});
function fnNumberSubKeyPress(e, elem) {
    debugger;
    var a = [];
    var k = e.which ? e.which : e.keyCode;

    for (i = 48; i < 58; i++)
        a.push(i);
    for (i = 45; i < 46; i++) {
        a.push(i);

        if (k == 46 || k == 8 || k == 37 || k == 39) {
            a.push(k);
        }

        if (!(a.indexOf(k) >= 0))
            e.preventDefault();
    }
}

    function fnShflAlert(status, ErrMsg, SuccessHandler, ErrorHandler, AlertFlg) {

        $("#error_msg").empty();
        $("#AlertIcon").attr("class", "");
        $("#AlertIcon").attr("title", "");
        $("#btn_Ok").attr("onclick", "");
        $("#btn_Cancel").attr("onclick", "");
        $("#btn_Cancel").hide();

        if (status == 'error') {
            $("#title_msg").text("Error");
            $("#AlertIcon").attr("class", "icon-close");
            $("#AlertIcon").attr("title", "Error");
        }
        if (status == 'success') {
            $("#title_msg").text("success");
            $("#AlertIcon").attr("class", "icon-tick");
            $("#AlertIcon").attr("title", "Success");
        }
        if (status == 'warning') {
            $("#title_msg").text("warning");
            $("#AlertIcon").attr("class", "icon-warning");
            $("#AlertIcon").attr("title", "Warning");
        }
        $("#error_msg").html(ErrMsg);

        if (SuccessHandler != undefined && SuccessHandler != "" && SuccessHandler != null)
            $("#btn_Ok").attr("onclick", SuccessHandler);
        else
            $("#btn_Ok").click(function () { $(".error-div").hide(); })

        if (AlertFlg == "confirm") {

            if (ErrorHandler != undefined && ErrorHandler != "" && ErrorHandler != null)
                $("#btn_Cancel").attr("onclick", ErrorHandler);
            else
                $("#btn_Cancel").click(function () { $(".error-div").hide(); })

            $("#btn_Cancel").show();
        }
        $(".error-div").show();
    }

    $(document).on("focusout", ".dob", function () {
        if ($(this).val().trim() == "")
            return;

        var birthdate = new Date($(this).val());
        var age = calculateAge(birthdate.getMonth(), birthdate.getDate(), birthdate.getFullYear());

        if (age < 18) {
            $(this).focus()
        }
    });

    function calculateAge(birthMonth, birthDay, birthYear) {
        todayDate = new Date();
        todayYear = todayDate.getFullYear();
        todayMonth = todayDate.getMonth();
        todayDay = todayDate.getDate();
        age = todayYear - birthYear;

        if (todayMonth < birthMonth - 1) {
            age--;
        }

        if (birthMonth - 1 == todayMonth && todayDay < birthDay) {
            age--;
        }
        return age;
    }

    $(document).on("focusout", ".mobile", function () {
        if ($(this).val().trim() == "")
            return;

        var RtnMobSts = isProperMobileNumber($(this));
        if (RtnMobSts == false) {
            $(this).focus();
        }
    });



    function isProperMobileNumber(txtMobObj) {
        var txtMobile = $(txtMobObj).val().trim();

        var len = txtMobile.length;
        var ErrMsg = "";

        if (len != 10) {
            ErrMsg = "Enter 10 Digit Mobile Number";
        }
        else if (txtMobile[0] != '7' && txtMobile[0] != '8' && txtMobile[0] != '9') {
            ErrMsg = "Mobile Number should Start with 7 or 8 or 9";
        }
        else if (!isNumeric(txtMobile)) {
            ErrMsg = "Mobile Number should be Numeric";
        }

        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            $(txtMobObj).focus();
            return false;
        }
        else
            return true;
    }

    $(document).on("focusout", ".phone", function () {
        if ($(this).val().trim() == "")
            return;

        var RtnMobSts = isProperPhoneNumber($(this));
        if (RtnMobSts == false) {
            $(this).focus();
        }
    });

    function isProperPhoneNumber(txtMobObj) {
        var txtMobile = $(txtMobObj).val().trim();

        var len = txtMobile.length;
        var ErrMsg = "";

        if (len > 15) {
            ErrMsg = "Phone number should not be greater than 15 digits";
        }

        if (!isNumeric(txtMobile)) {
            ErrMsg = "Phone Number should be Numeric";
        }

        if (ErrMsg != "") {
            fnShflAlert("error", ErrMsg);
            $(txtMobObj).focus();
            return false;
        }
        else
            return true;
    }


    function isMobileNumber(evt, sender) { // Allows only 10 numbers // ONKEYPRESS FUNCTION
        //evt = (evt) ? evt : window.event;
        var charCode = (evt.which) ? evt.which : evt.keyCode;
        var NumValue = $(sender).val();
        if (charCode > 31 && (charCode < 48 || charCode > 57)) {//|| NumValue.length > 9) {
            return false;
        }
        return true;
    }

    function isProperMobileNumber_Del(txtMobId) { //// VALIDATOR FUNCTION   
        var txtMobile = document.getElementById(txtMobId);
        if (!isNumeric(txtMobile.value)) { $(txtMobile).css("border-color", "red"); return false; }
        if (txtMobile.value.length < 10) {
            $(txtMobile).css("border-color", "red");
            return false;
        }
        $(txtMobile).css("border-color", "")
        return true;
    }

    function isNumeric(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }

    function vaildateInput(val, id, error) {
        if (val == undefined || val == null || val == '' || val.trim().length == 0) {
            $(id).css('border-color', 'red');
            $(id).val('');
            if (error != "" && error != undefined) {
                $(id).attr('placeholder', error);
            }
            //$(id).focus();
            return false;
        }
        $(id).css('border-color', '');
        return true;
    }
    function funAmtValid(Obj, evt) {
        var inputVal = $("#" + Obj.id).val().replace(/[^0-9]/g, '');
        var x = inputVal// 12345652457.557;
        x = x.toString();
        var afterPoint = '';
        if (x.indexOf('.') > 0)
            afterPoint = x.substring(x.indexOf('.'), x.length);
        x = Math.floor(x);
        x = x.toString();
        var lastThree = x.substring(x.length - 3);
        var otherNumbers = x.substring(0, x.length - 3);
        if (otherNumbers != '')
            lastThree = ',' + lastThree;
        var res = otherNumbers.replace(/\B(?=(\d{2})+(?!\d))/g, ",") + lastThree + afterPoint;
        $("#" + Obj.id).val(res);
    }
    function funRestrictSpecialChar(Obj, evt) {
        var inputVal = $("#" + Obj.id).val();
        re = /[`~!@#$%^&*()_|+\-=?;:'"<>\{\}\[\]\\\/]/gi;
        var isSplChar = re.test(inputVal);
        if (isSplChar) {
            var no_spl_char = inputVal.replace(/[`~!@#$%^&*()_|+\-=?;:'"<>\{\}\[\]\\\/]/gi, '');
            $("#" + Obj.id).val(no_spl_char);
        }
    }




    var CreditFormulas = {

        RISK_CALC: function () {

        },

        FOIR_AMT: function (INCOME, OBLIGATIONS, FOIR_PERC) {
            /*
            *  INCOME - MONTHLY INCOME 
            *  OBLIGATIONS  - MONTHLY ONLIGATIONS 
            */

            var FOIR_AMT = (INCOME * FOIR_PERC / 100) - OBLIGATIONS;
        },

        /* TO FIND THE LOAN AMOUNT BASED ON LTV  */
        LoanAmt_LTV: function (PROPVALUE, LTV) {
            /*  RETURNS LTV % OF PROPERTY VALUE      
             *  PrpValue  - Market value of the Property
             *  LTV - LTV percentage
            */
            var Loan_LTV = PROPVALUE * (LTV / 100);
            return Loan_LTV;
        },
        /* TO FIND THE LOAN AMOUNT BASED ON FOIR  */
        LoanAmt_FOIR: function (FOIR, TENURE, ROI, INCOME, OBLIGATIONS) {
            /*  RETURNS LOAN AMOUNT (FOIR)      - PV FORMULA
             *  FOIR - FOIR PERCENTAGE
             *  TENURE - TENURE IN MONTHS
             *  ROI - RATE OF INTEREST ANNNUAL
             *  INCOME - MONTHLY INCOME 
             *  OBLIGATIONS  - MONTHLY ONLIGATIONS
            */
            ROI = ROI / 12 / 100; // MONTHLY 
            var FOIR_AMT = (INCOME * (FOIR / 100)) - OBLIGATIONS;
            var X_FACTOR = Math.pow((1 + ROI), TENURE);
            var LOAN_FOIR = (FOIR_AMT / ROI) * ((X_FACTOR - 1) / X_FACTOR);
            return LOAN_FOIR;
        },

        LOAN_CALC: function (INCOME, OBLIGATIONS, EXPLOAN, TENURE, MRKPROP_VAL, LTV_PERC,
            FOIR, SHPLR, SALARY_TYPE, SAL_PROOF, CIBIL, AGR_PROPVAL, PRODUCTCODE, EXISTLOAN, waiverROI) {

            waiverROI = Number(waiverROI) || 0;

            // Add Existing and TopUP loan When the product is TOPUP
            if (PRODUCTCODE == 'HLTopup')
                EXPLOAN = Number(EXPLOAN) + Number(EXISTLOAN);

            var PropZeroFlag = false;
            var minPropValue;
            if (AGR_PROPVAL > 0)
                minPropValue = Math.min(MRKPROP_VAL, AGR_PROPVAL);
            else
                minPropValue = MRKPROP_VAL;
            if (minPropValue == 0)
                PropZeroFlag = true;

            //LOAN AMT BASED ON LTV
            var LOAN_AMT_LTV = minPropValue * (LTV_PERC / 100);

            console.log("Loan Value based on LTV " + LOAN_AMT_LTV)
            // LOAN AMT BASED ON FOIR 
            var ROI = SHPLR / 12 / 100; // MONTHLY 
            var FOIR_AMT = (INCOME * (FOIR / 100)) - OBLIGATIONS;
            var X_FACTOR = Math.pow((1 + ROI), TENURE);
            var LOAN_AMT_FOIR = (FOIR_AMT / ROI) * ((X_FACTOR - 1) / X_FACTOR);

            console.log("Loan Value based on FOIR " + LOAN_AMT_FOIR)

            // LOAN AMT BASED ON FOIR
            var FINAL_LOAN_AMT = Math.min(LOAN_AMT_LTV, LOAN_AMT_FOIR, EXPLOAN);
            console.log("Loan Amount " + FINAL_LOAN_AMT)
            if (PropZeroFlag)
                FINAL_LOAN_AMT = Math.min(LOAN_AMT_FOIR, EXPLOAN);
            console.log("Flag  Loan Amount " + FINAL_LOAN_AMT)

            // TEMP EMI
            var TEMP_EMI = FINAL_LOAN_AMT * ROI * (X_FACTOR / (X_FACTOR - 1));
            console.log("Temp EMI " + TEMP_EMI)

            // ARRIVED LTV FOR FINAL LOAN AMOUNT
            var ARR_LTV = (FINAL_LOAN_AMT / minPropValue) * 100;

            console.log("LTV " + ARR_LTV);
            // ARRIVED FOIR FOR FINAL LOAN AMOUNT
            var ARR_FOIR = ((TEMP_EMI + OBLIGATIONS) / INCOME) * 100;
            ARR_FOIR = ARR_FOIR.toFixed(2);
            console.log("FOIR " + ARR_FOIR);
            // ARRIVED ROI

            var ROI_COMP = {};
            if (SALARY_TYPE == "SAL") {
                //ROI_COMP = { CIBIL: CIBIL, FOIR: ARR_FOIR };
                ROI_COMP = { CIBIL: CIBIL, FOIR: ARR_FOIR };
                
            }
            else if (SALARY_TYPE == "SELF") {
                //ROI_COMP = { IsIncomeProof: SAL_PROOF, LTV: ARR_LTV, CIBIL: CIBIL, FOIR: ARR_FOIR };
                ROI_COMP = { IsIncomeProof: SAL_PROOF, LTV: ARR_LTV, CIBIL: CIBIL, FOIR: ARR_FOIR };
                
            }

            var ARR_ROI = CreditFormulas.ROI(SALARY_TYPE, ROI_COMP);
            var FIN_ARR_ROI = ARR_ROI + waiverROI;

            if (PRODUCTCODE == 'HLTopup')
            {
                ARR_ROI = ARR_ROI + 1;
                FIN_ARR_ROI = FIN_ARR_ROI + 1;
            }
            console.log("ROI - Arrived ROI -- > " + ARR_ROI);

            //var X_ARR_ROI = ARR_ROI / 12 / 100;
            var X_ARR_ROI = FIN_ARR_ROI / 12 / 100;
            var Y_FACTOR = Math.pow((1 + X_ARR_ROI), TENURE);
            var ARR_EMI = FINAL_LOAN_AMT * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1);
            
            if (PRODUCTCODE == "HLTopup")
            {
                ARR_EMI = (FINAL_LOAN_AMT - Number(EXISTLOAN)) * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1);
            }

            console.log("EMI " + ARR_EMI);

            var FIN_ARR_FOIR = ((ARR_EMI + OBLIGATIONS) / INCOME) * 100;

            console.log("FOIR " + FIN_ARR_FOIR);

            var AgrLTV;
            var MrkLTV;
            if ($.isNumeric(AGR_PROPVAL) && AGR_PROPVAL != 0)
                AgrLTV = FINAL_LOAN_AMT / AGR_PROPVAL * 100;
            else
                AgrLTV = 0;
            if ($.isNumeric(MRKPROP_VAL) && MRKPROP_VAL != 0)
                MrkLTV = FINAL_LOAN_AMT / MRKPROP_VAL * 100;
            else
                MrkLTV = 0;

            var PRD_CODE, OUTSTD_AMT, ARR_OUTSTD_AMT, TOPUP_AMT, ARR_TOPUP_AMT, BT_EMI, TOPUP_EMI;

            if (PRODUCTCODE == 'HLBTTopup' || PRODUCTCODE == 'HLTopup') {
                OUTSTD_AMT = EXISTLOAN;
                ARR_OUTSTD_AMT = OUTSTD_AMT;

                TOPUP_AMT = FINAL_LOAN_AMT - OUTSTD_AMT;
                ARR_TOPUP_AMT = TOPUP_AMT;

                if (FINAL_LOAN_AMT <= OUTSTD_AMT) {
                    ARR_TOPUP_AMT = 0
                    ARR_OUTSTD_AMT = FINAL_LOAN_AMT;
                }

                //X_ARR_ROI = ARR_ROI / 12 / 100;
                X_ARR_ROI = FIN_ARR_ROI / 12 / 100;
                Y_FACTOR = Math.pow((1 + X_ARR_ROI), TENURE);
                BT_EMI = Math.round(ARR_OUTSTD_AMT * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1), 0);

                //X_ARR_ROI = (ARR_ROI + 1) / 12 / 100;
                X_ARR_ROI = (FIN_ARR_ROI + 1) / 12 / 100;
                Y_FACTOR = Math.pow((1 + X_ARR_ROI), TENURE);
                TOPUP_EMI = Math.round(ARR_TOPUP_AMT * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1), 0);


                if (PRODUCTCODE == 'HLTopup') {
                    if ($.isNumeric(AGR_PROPVAL) && AGR_PROPVAL != 0)
                        AgrLTV = (FINAL_LOAN_AMT) / AGR_PROPVAL * 100;
                    else
                        AgrLTV = 0;

                    if ($.isNumeric(MRKPROP_VAL) && MRKPROP_VAL != 0)
                        MrkLTV = (FINAL_LOAN_AMT) / MRKPROP_VAL * 100;
                    else
                        MrkLTV = 0;
                }
                
                if (PRODUCTCODE == 'HLBTTopup') {
                    FIN_ARR_FOIR = ((BT_EMI + TOPUP_EMI + OBLIGATIONS) / INCOME) * 100;
                }
            }

            var BT_LTV_A = 0, TOPUP_LTV_A = 0;
            var BT_LTV_M = 0, TOPUP_LTV_M = 0;

            var BtTopupArr = ['HLBT', 'HLTopup', 'HLBTTopup', 'LAPBT', 'LAPTopup', 'LAPBTTopup'];
            if (BtTopupArr.indexOf(PRODUCTCODE) >= 0) {                

                //MRKPROP_VAL AGR_PROPVAL
                if (MRKPROP_VAL != 0) {
                    BT_LTV_M = (ARR_OUTSTD_AMT / MRKPROP_VAL) * 100;
                    TOPUP_LTV_M = (ARR_TOPUP_AMT / MRKPROP_VAL) * 100;
                }
                else {
                    BT_LTV_M = 0;
                    TOPUP_LTV_M = 0;
                }

                if (AGR_PROPVAL != 0) {
                    BT_LTV_A = (ARR_OUTSTD_AMT / AGR_PROPVAL) * 100;
                    TOPUP_LTV_A = (ARR_TOPUP_AMT / AGR_PROPVAL) * 100;
                }
                else {
                    BT_LTV_A = 0;
                    TOPUP_LTV_A = 0;
                }
            }


            if (PRODUCTCODE == 'HLExt' || PRODUCTCODE == 'HLImp') {

                ARR_OUTSTD_AMT = EXISTLOAN || 0;
                if (AGR_PROPVAL != 0) {
                    TOPUP_LTV_A = FINAL_LOAN_AMT / AGR_PROPVAL * 100;
                    AgrLTV = (FINAL_LOAN_AMT + ARR_OUTSTD_AMT) / AGR_PROPVAL * 100;
                }
                else {
                    TOPUP_LTV_A = 0
                    AgrLTV = 0
                }

                if (MRKPROP_VAL != 0) {
                    TOPUP_LTV_M = FINAL_LOAN_AMT / MRKPROP_VAL * 100;
                    MrkLTV = (FINAL_LOAN_AMT + ARR_OUTSTD_AMT) / MRKPROP_VAL * 100;
                }
                else {
                    TOPUP_LTV_M = 0
                    MrkLTV = 0
                }
            }

            
            if (IsPNI == 'Y' && (CREDIT_APPROVER_NO == 1 || CREDIT_APPROVER_NO == 2)) {
                if (PRODUCTCODE == 'HLNew' || PRODUCTCODE == 'HLResale' || PRODUCTCODE == 'HLConst' || PRODUCTCODE == 'HLPltConst') {
                    if (SAL_PROOF)
                        ARR_LTV = 80, MrkLTV = 80, AgrLTV=80;
                    else
                        ARR_LTV = 70, MrkLTV = 70, AgrLTV = 70;
                }
            }
            
            
            var RET_OBJ = {
                INCOME: INCOME, OBLIGATIONS: OBLIGATIONS, SALARY_TYPE: SALARY_TYPE, SAL_PROOF: SAL_PROOF, TENURE: TENURE,
                PRD_CODE: PRODUCTCODE, OUTSTD_AMT: EXISTLOAN, ARR_OUTSTD_AMT: ARR_OUTSTD_AMT, TOPUP_AMT: TOPUP_AMT, ARR_TOPUP_AMT: ARR_TOPUP_AMT, BT_EMI: BT_EMI,
                TOPUP_EMI: TOPUP_EMI, LOAN_AMT: Math.round(FINAL_LOAN_AMT), EMI: Math.round(ARR_EMI), FOIR: FIN_ARR_FOIR, ROI: ARR_ROI, LTV: ARR_LTV,
                LTV_M: MrkLTV, LTV_A: AgrLTV, BT_LTV_A: BT_LTV_A, TOPUP_LTV_A: TOPUP_LTV_A, BT_LTV_M: BT_LTV_M, TOPUP_LTV_M: TOPUP_LTV_M
            };
            console.log(RET_OBJ)
            return RET_OBJ;
        },


        LOAN_CALC_LAP: function (INCOME, OBLIGATIONS, EXPLOAN, TENURE, MRKPROP_VAL, LTV_PERC,
            IIR, SHPLR, SALARY_TYPE, SAL_PROOF, CIBIL, AGR_PROPVAL, PRODUCTCODE, EXISTLOAN, waiverROI) {


            waiverROI = Number(waiverROI) || 0;
            // Add Existing and TopUP loan When the product is TOPUP
            if (PRODUCTCODE == 'LAPTopup')
                EXPLOAN = Number(EXPLOAN) + Number(EXISTLOAN);

            var PropZeroFlag = false;
            var minPropValue;
            if (AGR_PROPVAL > 0)
                minPropValue = Math.min(MRKPROP_VAL, AGR_PROPVAL);
            else
                minPropValue = MRKPROP_VAL;
            if (minPropValue == 0)
                PropZeroFlag = true;

            //LOAN AMT BASED ON LTV
            var LOAN_AMT_LTV = minPropValue * (LTV_PERC / 100);

            console.log("Loan Value based on LTV " + LOAN_AMT_LTV)
            // LOAN AMT BASED ON FOIR 
            var ROI = SHPLR / 12 / 100; // MONTHLY 
            var IIR_AMT = ((INCOME - OBLIGATIONS) * (IIR / 100));
            var X_FACTOR = Math.pow((1 + ROI), TENURE);
            var LOAN_AMT_IIR = (IIR_AMT / ROI) * ((X_FACTOR - 1) / X_FACTOR);

            console.log("Loan Value based on FOIR " + LOAN_AMT_IIR)

            // LOAN AMT BASED ON FOIR
            var FINAL_LOAN_AMT = Math.min(LOAN_AMT_LTV, LOAN_AMT_IIR, EXPLOAN);
            console.log("Loan Amount " + FINAL_LOAN_AMT)
            if (PropZeroFlag)
                FINAL_LOAN_AMT = Math.min(LOAN_AMT_IIR, EXPLOAN);
            console.log("Flag  Loan Amount " + FINAL_LOAN_AMT)

            // TEMP EMI
            var TEMP_EMI = FINAL_LOAN_AMT * ROI * (X_FACTOR / (X_FACTOR - 1));
            console.log("Temp EMI " + TEMP_EMI)

            // ARRIVED LTV FOR FINAL LOAN AMOUNT
            var ARR_LTV = (FINAL_LOAN_AMT / minPropValue) * 100;

            console.log("LTV " + ARR_LTV);
            // ARRIVED FOIR FOR FINAL LOAN AMOUNT
            var ARR_IIR = (TEMP_EMI / (INCOME - OBLIGATIONS)) * 100;
            ARR_IIR = ARR_IIR.toFixed(2);
            console.log("FOIR " + ARR_IIR);
            // ARRIVED ROI

            var ARR_ROI = 18;            
            var FIN_ARR_ROI = ARR_ROI + waiverROI;

            if (PRODUCTCODE == 'LAPTopup')
            {
                ARR_ROI = ARR_ROI + 1;
                FIN_ARR_ROI = FIN_ARR_ROI + 1;
            }
            console.log("ROI - Arrived ROI -- > " + ARR_ROI);

            //var X_ARR_ROI = ARR_ROI / 12 / 100;
            var X_ARR_ROI = FIN_ARR_ROI / 12 / 100;
            var Y_FACTOR = Math.pow((1 + X_ARR_ROI), TENURE);
            var ARR_EMI = FINAL_LOAN_AMT * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1);

            if (PRODUCTCODE == 'LAPTopup') {
                ARR_EMI = (FINAL_LOAN_AMT - Number(EXISTLOAN)) * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1);
            }

            console.log("EMI " + ARR_EMI);

            var FIN_ARR_IIR = (ARR_EMI / (INCOME - OBLIGATIONS)) * 100;

            console.log("FOIR " + FIN_ARR_IIR);

            var AgrLTV;
            var MrkLTV;
            if ($.isNumeric(AGR_PROPVAL) && AGR_PROPVAL != 0)
                AgrLTV = FINAL_LOAN_AMT / AGR_PROPVAL * 100;
            else
                AgrLTV = 0;
            if ($.isNumeric(MRKPROP_VAL) && MRKPROP_VAL != 0)
                MrkLTV = FINAL_LOAN_AMT / MRKPROP_VAL * 100;
            else
                MrkLTV = 0;

            var PRD_CODE, OUTSTD_AMT, ARR_OUTSTD_AMT, TOPUP_AMT, ARR_TOPUP_AMT, BT_EMI, TOPUP_EMI;

            if (PRODUCTCODE == 'LAPBTTopup' || PRODUCTCODE == 'LAPTopup') {
                OUTSTD_AMT = EXISTLOAN;
                ARR_OUTSTD_AMT = OUTSTD_AMT;

                TOPUP_AMT = FINAL_LOAN_AMT - OUTSTD_AMT;
                ARR_TOPUP_AMT = TOPUP_AMT;

                if (FINAL_LOAN_AMT <= OUTSTD_AMT) {
                    ARR_TOPUP_AMT = 0
                    ARR_OUTSTD_AMT = FINAL_LOAN_AMT;
                }

                //X_ARR_ROI = ARR_ROI / 12 / 100;
                X_ARR_ROI = FIN_ARR_ROI / 12 / 100;
                
                Y_FACTOR = Math.pow((1 + X_ARR_ROI), TENURE);
                BT_EMI = Math.round(ARR_OUTSTD_AMT * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1), 0);

                //X_ARR_ROI = (ARR_ROI + 1) / 12 / 100;
                X_ARR_ROI = (FIN_ARR_ROI + 1) / 12 / 100;
                Y_FACTOR = Math.pow((1 + X_ARR_ROI), TENURE);
                TOPUP_EMI = Math.round(ARR_TOPUP_AMT * X_ARR_ROI * Y_FACTOR / (Y_FACTOR - 1), 0);


                if (PRODUCTCODE == 'LAPTopup') {
                    if ($.isNumeric(AGR_PROPVAL) && AGR_PROPVAL != 0)
                        AgrLTV = (FINAL_LOAN_AMT) / AGR_PROPVAL * 100;
                    else
                        AgrLTV = 0;

                    if ($.isNumeric(MRKPROP_VAL) && MRKPROP_VAL != 0)
                        MrkLTV = (FINAL_LOAN_AMT) / MRKPROP_VAL * 100;
                    else
                        MrkLTV = 0;
                }

                if (PRODUCTCODE == 'LAPBTTopup') {
                    FIN_ARR_IIR = ((BT_EMI + TOPUP_EMI) / (INCOME - OBLIGATIONS)) * 100;
                }

            }


            var BT_LTV_A = 0, TOPUP_LTV_A = 0;
            var BT_LTV_M = 0, TOPUP_LTV_M = 0;

            var BtTopupArr = ['HLBT', 'HLTopup', 'HLBTTopup', 'LAPBT', 'LAPTopup', 'LAPBTTopup'];
            if (BtTopupArr.indexOf(PRODUCTCODE) >= 0) {

                //MRKPROP_VAL AGR_PROPVAL
                if (MRKPROP_VAL != 0) {
                    BT_LTV_M = (ARR_OUTSTD_AMT / MRKPROP_VAL) * 100;
                    TOPUP_LTV_M = (ARR_TOPUP_AMT / MRKPROP_VAL) * 100;
                }
                else {
                    BT_LTV_M = 0;
                    TOPUP_LTV_M = 0;
                }

                if (AGR_PROPVAL != 0) {
                    BT_LTV_A = (ARR_OUTSTD_AMT / AGR_PROPVAL) * 100;
                    TOPUP_LTV_A = (ARR_TOPUP_AMT / AGR_PROPVAL) * 100;
                }
                else {
                    BT_LTV_A = 0;
                    TOPUP_LTV_A = 0;
                }


            }


            var RET_OBJ = {
                INCOME: INCOME, OBLIGATIONS: OBLIGATIONS, SALARY_TYPE: SALARY_TYPE, SAL_PROOF: SAL_PROOF, TENURE: TENURE,
                PRD_CODE: PRODUCTCODE, OUTSTD_AMT: EXISTLOAN, ARR_OUTSTD_AMT: ARR_OUTSTD_AMT, TOPUP_AMT: TOPUP_AMT, ARR_TOPUP_AMT: ARR_TOPUP_AMT, BT_EMI: BT_EMI,
                TOPUP_EMI: TOPUP_EMI, LOAN_AMT: Math.round(FINAL_LOAN_AMT), EMI: Math.round(ARR_EMI), IIR: FIN_ARR_IIR, ROI: ARR_ROI, LTV: ARR_LTV,
                LTV_M: MrkLTV, LTV_A: AgrLTV, BT_LTV_A: BT_LTV_A, TOPUP_LTV_A: TOPUP_LTV_A, BT_LTV_M: BT_LTV_M, TOPUP_LTV_M: TOPUP_LTV_M
            };
            console.log(RET_OBJ)
            return RET_OBJ;
        },


        // OLD


        /* TO FIND THE EMI AMOUNT FOR GIVEN LOAN AMOUNT */
        PMT: function (Irate, tenure, LoanAmt) {
            /*        
             *  Irate   - Interset rate per annum;
             *  tenure  - Loan Tenure in month 
             *  LoanAmt - Principle amount (Loan amount) 
            */
            if (!Irate) Irate = 0;
            if (!tenure) tenure = 0;
            if (!LoanAmt) LoanAmt = 0;

            //Irate = Irate > 1 ? Irate / 100 : Irate;
            //var pmt = (LoanAmt * Irate) / (1 - Math.pow(1 + Irate, tenure));

            var ROI = Irate / 12 / 100;
            Val = Math.pow((1 + ROI), tenure);
            var pmt = LoanAmt * ROI * (Val / (Val - 1));

            //var pmt = Irate * LoanAmt * Math.pow((1 + Irate), tenure) / (1 - Math.pow((1 + Irate), tenure));
            return Math.round(Math.abs(pmt));
        },

        /* TO FIND NET INCOME  */
        NetIncome: function (MIncome, MObligations) {
            /*        
             *  MIncome - Monthly income 
             *  MObligations - Monthly Obligations
            */
            if (!MIncome) MIncome = 0;
            if (!MObligations) MObligations = 0;
            if (MObligations > MIncome)
                return 0;
            else
                return Math.abs((MIncome - MObligations).toFixed(2));
        },
        /* TO FIND FOIR -  ~~~~ FIXED OBLIGATIONS TO INCOME RATIO  ~~~~  */
        FOIR: function (NetIncomePerMonth) {
            /*  If ( Net Income <= 30000 ) THEN 50% of Net Income ELSE 60% of Net Income )        
             *  NetIncomePerMonth - Monthly income - Obligations
            */
            var foir;
            if (NetIncomePerMonth <= 30000)
                foir = 0.5;
            else
                foir = 0.6;

            return foir.toFixed(2);
        },
        /* TO CALCULATE RATE OF INTEREST  */
        ROI: function (type, components) {
            /*  Returns ROI%
             *  type - Salaried / Self employed
             *  Components - components required to calculate ROI
             *  if type = SAL then Components = CIBIL , FOIR% 
             *  if type = SELF then Components = IsIncomeProof, LTV% , CIBIL, FOIR%
            */
            var roi = 15; // default value
            if (type == "SAL") {
                var CIBIL = components.CIBIL;
                var FOIR = components.FOIR;

                if (FOIR < 1) FOIR = FOIR * 100; // Convert it to percentage            

                if (CIBIL > 800 && FOIR <= 55)
                    roi = 11; // 11%
                else if (CIBIL >= 751 && CIBIL <= 800 && FOIR <= 55)
                    roi = 12; // 12%
                else if (CIBIL >= 701 && CIBIL <= 750 && FOIR <= 55)
                    roi = 13; // 13%
                else if (CIBIL > 700 && FOIR > 55)
                    roi = 14; // 14%
                else if (CIBIL <= 700 && FOIR <= 55)
                    roi = 14.5; // 14.5%
                else if (CIBIL <= 700 && FOIR > 55)
                    roi = 15; // 15%
            }
            if (type == "SELF") {
                var IsIncomeProof = components.IsIncomeProof || false;
                var LTV = components.LTV;
                var CIBIL = components.CIBIL;
                var FOIR = components.FOIR;
                if (FOIR < 1) FOIR = FOIR * 100; // Convert it to percentage            
                if (LTV < 1) LTV = LTV * 100; // Convert it to percentage                  

                if (IsIncomeProof && LTV <= 50 && CIBIL > 750 && FOIR <= 40)
                    roi = 11; // 11%
                else if (IsIncomeProof && LTV <= 50 && CIBIL > 750 && FOIR > 40 && FOIR <= 60)
                    roi = 12; // 12%
                else if (IsIncomeProof && LTV <= 50 && CIBIL > 750 && FOIR > 60)
                    roi = 13; // 13%
                else if (IsIncomeProof && LTV <= 50 && CIBIL <= 750)
                    roi = 13.5; // 13.5%
                else if (IsIncomeProof && LTV > 50 && CIBIL > 750)
                    roi = 14; // 14%
                else if (IsIncomeProof && LTV > 50 && CIBIL <= 750)
                    roi = 15.5; // 15.5%

                /*
                
                else if (!IsIncomeProof && LTV < 50 && CIBIL > 701 && CIBIL <= 750)
                    roi = 13; // 13%
                    
                */
                else if (!IsIncomeProof && LTV <= 50 && CIBIL > 800)
                    roi = 13; // 13%
                else if (!IsIncomeProof && LTV <= 50 && CIBIL > 750 && CIBIL <= 800)
                    roi = 14; // 14%
                else if (!IsIncomeProof && LTV <= 50 && CIBIL <= 750)
                    roi = 14.5; // 14.5%
                else if (!IsIncomeProof && LTV > 50 && CIBIL > 750)
                    roi = 15; // 15%
                else if (!IsIncomeProof && LTV > 50 && CIBIL <= 750)
                    roi = 16; // 16%
            }
            return roi;
        },
        /* TO CALCULATE ELIGIBLE LOAN AMT  */
        EligibleLoanAmt: function (NetIncomePerMonth, Tenure, PropVal, LTV, FOIRPerc, ROI) {
            /*  Returns Eligible Loan amount
             *   NetIncomePerMonth - Income - obliagtion /  month
             *   Tenure - Loan tenure in months
             */
            var foirvalue = NetIncomePerMonth * FOIRPerc;
            var PMT = CreditFormulas.PMT(ROI, Tenure, 100000);
            var PreEligibleAmt = foirvalue / PMT * 100000;
            var PrpVal = PropVal * LTV / 100;

            return PreEligibleAmt > PrpVal ? PrpVal : PreEligibleAmt;
        }
    };


    //var amt = CreditFormulas.PMT(12 / (100 * 12), 60, 1000000);
    //alert(amt);



var creditOfficer = {
    Status: {
        "P": { code: "P", name: "POSITIVE", class: "bg1" },
        "N": { code: "N", name: "NEGATIVE", class: "bg2" },
        "M": { code: "M", name: "MODERATE", class: "bg3" }
    },
    DeviationFactors: {
        /* To find the Age deviation with respect to Age and salary type */
        Age: function (age, contribute, incometype, Tenure) {
            /*  returns status = P - Postive , N- Negative M - Moderate
                *  age - Age of the Person
                *  contribute - Is Salary contributing to Loan . true / false
                *  incometype - Salaried , Self employed
                *  Tenure - Tenure in Years
            */
            if (!Tenure)
                Tenure = 0;

            Tenure = Number(Tenure);
            age = Number(age);
            var status = "P";
            if (incometype == "SAL") {
                var c1 = contribute && age >= 21 && age + Tenure <= 60;
                var c2 = !contribute && age >= 18 && age + Tenure <= 60;
                if (c1 || c2)
                    status = "P";
                else
                    status = "N";
            }
            else if (incometype == "SELF") {
                var c3 = contribute && age >= 21 && age + Tenure <= 65;
                var c4 = !contribute && age >= 21 && age + Tenure <= 65;
                if (c3 || c4)
                    status = "P";
                else
                    status = "N";
            }
            return status;
        },
        /* Job Experience Factor */
        JobExperience: function (SalType, EmployerorType, Employment, Experience) {
            /*  returns status = P - Postive , N- Negative M - Moderate
                *  SalType - Salaried , Self employed
                *  EmployerorType - G- GOvt , NG - Non Govt , P -Professional , NP - Non Professional
                *  Employment  - Permenant / contractual Temporary
                *  Experience - Job Experience in years
            */
            var status = "P";
            if (SalType == "SAL") {
                if (EmployerorType == "G") {
                    if (Employment == "P")
                        status = "P";
                    else
                        status = "N";

                }
                else if (EmployerorType == "NG") {
                    if (Employment == "P")
                        status = "P";
                    else
                        status = "N";
                }
            }
            else if (SalType == "SELF") {
                if (EmployerorType == "P") {
                    if (Experience >= 3)
                        status = "P";
                    else
                        status = "N";
                }
                else if (EmployerorType == "NP") {
                    if (Experience >= 2)
                        status = "P";
                    else
                        status = "N";
                }
            }
            return status;
        },
        /* Income Deviations */
        Income: function (incometype, incomeMonth) {
            /*  returns status = P - Postive , N- Negative M - Moderate
                *  incometype - Salaried , Self employed
                *  incomeMonth - Monthly salary
            */
            var status = "P";
            if (incometype == "SAL") {
                if (incomeMonth >= 7500)
                    status = "P";
                else
                    status = "N";
            }
            else if (incometype == "SELF") {
                if (incomeMonth >= 10000)
                    status = "P";
                else
                    status = "N";
            }

            return status;
        },
        /* FOIR Deviations */
        FOIR: function (incomeMonth, FOIR) {
            /*  returns status = P - Postive , N- Negative M - Moderate
                *  incomeMonth - Monthly salary . 
            */
            var status = "P";
            FOIR = FOIR < 1 ? FOIR * 100 : FOIR;
            if (incomeMonth <= 30000) {
                if (FOIR <= 50)
                    status = "P";
                else
                    status = "N";
            }
            else if (incomeMonth > 30000) {
                if (FOIR <= 60)
                    status = "P";
                else
                    status = "N";
            }

            return status;
        },
        /* LTV Deviations */
        LTV: function (LTV) {
            // above 80%
            var status = "P";
            if (LTV > 80)
                status = "N"
            return status;
        }

    }
}

/* CERSAI VALIDATION */

/* Flat & Plot Validation */
function fnflatValidation(flatid) {
    var CersaiErr = "";
    if ($(flatid).val().trim() == "")
        return CersaiErr;

    var RtnMailSts = isProperVal($(flatid).val().trim());
    if (RtnMailSts == false) {
        CersaiErr = "Enter Proper Flat No !!"  
    }
    return CersaiErr;
}

function fnplotValidation(plotid)
{
    var CersaiErr = "";
    if ($(plotid).val().trim() == "")
        return CersaiErr;

    var RtnMailSts = isProperVal($(plotid).val().trim());
    if (RtnMailSts == false) {
        CersaiErr = "Enter Proper Plot No !!"
    }
    return CersaiErr;
}
function isProperVal(special) {
    var regex = /^[ A-Za-z0-9]+[A-Za-z0-9@/*)(+=,.-:;_\]\[]*$/;
    return regex.test(special);
}

/* Building Validation */

function fnbuidValidation(buildId){
    var CersaiErr = "";
    if ($(buildId).val().trim() == "")
        return CersaiErr;

    var RtnFirstSts = isProperChar($(buildId).val().trim());
    if (RtnFirstSts == false) {
        CersaiErr = "Enter Proper Building Name !!"
    }
    return CersaiErr;
}
function isProperChar(First) {
    var regex = /^[ A-Za-z0-9]/;
    return regex.test(First);
}

/* Street Validation */

function fnstreetValidation(streetid) {
    var CersaiErr = "";
    if ($(streetid).val().trim() == "")
        return CersaiErr;

    var RtnspecstrSts = isProperStr($(streetid).val().trim());
    if (RtnspecstrSts == false) {        
        CersaiErr = "Enter Proper Street Name !!"
    }
    return CersaiErr;
}

function isProperStr(specialStr) {
    var regex = /^[ A-Za-z0-9]+[A-Za-z0-9)(\]\[]*$/;
    return regex.test(specialStr);
}

/* LandMark Validation */

function fnlandmarkValidation(landmarkid){
    var CersaiErr = "";
    if ($(landmarkid).val().trim() == "")
        return CersaiErr;

    var RtnspecLMSts = isProperLM($(landmarkid).val().trim());
    if (RtnspecLMSts == false) {   
        CersaiErr = "Enter Proper LandMark !!"
    }
    return CersaiErr;
}
function isProperLM(specialLM) {
    var regex = /^[ A-Za-z0-9]+[A-Za-z0-9@#&/*)(+=,.-:;_\]\[]*$/;
    return regex.test(specialLM);
}

var xmlStr = "";
//added by Vijay for getting XMl Data for Point 9
function fnGetXMLData() {
    var Url = getLocalStorage("BpmUrl") + "RestServiceSvc.svc/fnGetXMLData";
    var fileName = "D:\\Working\\BPM\\SHFL LENDING\\SHFL\\RS\\SHFL_DOCS\\Config_Files\\Config_Integration.xml";
    var obj = {};
    obj.ConfigKey = fileName;
    $.ajax({
        url: Url,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(obj),
        success: function (result) {
            xmlStr = JSON.parse(result).ConfigValue;
            xmlStr = $.parseXML(xmlStr);
        },
        error: function (result) {
            console.log('Error: ', result);
        }
    });
}