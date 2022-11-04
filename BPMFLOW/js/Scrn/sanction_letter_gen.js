var LedGlobal;
var productcode = "";
var BTTop_Arr = ['HLBT','LAPBT','LAPBTTopup', 'LAPTopup', 'HLBTTopup', 'HLTopup'];
var ProductName = "";
var OrgProduct = "";
$(document).ready(function () {
    var LeadInfo = localStorage.getItem("LeadInfo");
    if (LeadInfo != "") {
        var Obj = JSON.parse(LeadInfo);
        LedGlobal = Obj;
    }
    var sancNo = gup("sancNo", "");
    LedGlobal[0].sancNo = sancNo;
    fnPrintSanctionLetter(LedGlobal);
});

function fnPrintSanctionLetter(LeadPk) {
    var PrcObj = { ProcedureName: "PrcShflSanctionLetter", Type: "SP", Parameters: ["PRINT_SCANCTION", JSON.stringify(LedGlobal)] };
    fnCallLOSWebService("SCANCTION_LETTER", PrcObj, fnSanctionResult, "MULTI");
}




function fnSanctionResult(ServiceFor, Obj, Param1, Param2) {
    if (ServiceFor == "SCANCTION_LETTER") {
        var LoanDtl = JSON.parse(Obj.result_1);
        var LeadNm = JSON.parse(Obj.result_2);
        var LoanAttr = JSON.parse(Obj.result_3);
        var Subjective = JSON.parse(Obj.result_4);
        var PFAmt = JSON.parse(Obj.result_5);

        if (PFAmt && PFAmt.length > 0) {
            $("#Pfamt").text(PFAmt[0].PF);
        }
        else { $("#Pfamt").text("0"); }

        if (LoanDtl && LoanDtl.length > 0) {
            if (LoanDtl[0].ERROR && LoanDtl[0].ERROR != "") {
                $("body").empty();
                setTimeout(function () { alert(LoanDtl[0].ERROR) }, 200);
                return;
            }
            $("#SancNo").text(LoanDtl[0].SancNo);
            $("#SancDt").text(LoanDtl[0].SancDate);
            productcode = LoanDtl[0].ProductCode;
            ProductName = LoanDtl[0].ProductName;
            $("#prodNm").text(ProductName);
        }
        if (LeadNm && LeadNm.length > 0) {
            OrgProduct = LeadNm[0].OrgProduct;
            $("#LeadNm").text(LeadNm[0].AppName + " , ");            
            $("#Purpose").text(LeadNm[0].Purpose);          
        }
        if (LoanAttr && LoanAttr.length > 0) {
            fnSetLoanAttr_BT(LoanAttr);
        }
        if (Subjective && Subjective.length > 0) {
            fnSetSubjective(Subjective);
        }
    }

}

function fnSetLoanAttr_BT(data) {
    var LI, GI, LOAN, TENURE, ROI, SPREAD, EMI, LI_EMI, GI_EMI, LG_EMI;
    var AMT_LI, AMT_GI, AMT_LOAN, TENURE, ROI, SPREAD, AMT_EMI, AMT_LI_EMI, AMT_GI_EMI, AMT_LG_EMI;
    //OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
    //ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI
    var LOAN_LI, LOAN_GI, LOAN_LG;
    $("#shplr").html("15 <sup>%</sup>");    

    if (productcode == "HLTopup" || productcode == "LAPTopup")
    {
        LI = data[0].TOPUP_LI.toFixed(2);
        AMT_LI = FormatCurrency(LI);
        GI = data[0].TOPUP_GI.toFixed(2);
        AMT_GI = FormatCurrency(GI);
        LOAN = data[0].TOPUP_AMT.toFixed(2);
        AMT_LOAN = FormatCurrency(LOAN);
        TENURE = data[0].TENUR;
        ROI = data[0].TOPUP_ROI;
        SPREAD = ROI - 15;
        EMI = data[0].TOPUP_EMI;
        AMT_EMI = EMI;
        LOAN_LI= Number(LOAN) + Number(LI);
        LOAN_GI = Number(LOAN) + Number(GI);
        LOAN_LG =  Number(LOAN) + Number(LI) + Number(GI);        

        LI_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_LI);
        GI_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_GI);
        LG_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_LG);

    }
    else if (OrgProduct != productcode && (productcode == "HLBT" || productcode == "LAPBT")) {
        LI = data[0].BT_LI.toFixed(2);
        AMT_LI = FormatCurrency(LI);
        GI = data[0].BT_GI.toFixed(2);
        AMT_GI = FormatCurrency(GI);
        LOAN = data[0].BT_AMT.toFixed(2);
        AMT_LOAN = FormatCurrency(LOAN);
        TENURE = data[0].TENUR;
        ROI = data[0].BT_ROI;
        SPREAD = ROI - 15;
        EMI = data[0].BT_EMI;
        AMT_EMI = EMI;
        LOAN_LI = Number(LOAN) + Number(LI);
        LOAN_GI = Number(LOAN) + Number(GI);
        LOAN_LG = Number(LOAN) + Number(LI) + Number(GI);

        LI_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_LI);
        GI_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_GI);
        LG_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_LG);
    }
    else {
        LI = data[0].LI.toFixed(2);
        AMT_LI = FormatCurrency(LI);
        GI = data[0].GI.toFixed(2);
        AMT_GI = FormatCurrency(GI);
        LOAN = data[0].LOAN_AMT.toFixed(2);
        AMT_LOAN = FormatCurrency(LOAN);
        TENURE = data[0].TENUR;
        ROI = data[0].ROI;
        SPREAD = ROI - 15;
        EMI = data[0].EMI;
        AMT_EMI = EMI;
        LOAN_LI = Number(LOAN) + Number(LI);
        LOAN_GI = Number(LOAN) + Number(GI);
        LOAN_LG = Number(LOAN) + Number(LI) + Number(GI);

        LI_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_LI);
        GI_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_GI);
        LG_EMI = CreditFormulas.PMT(ROI, TENURE, LOAN_LG);
    }
      
    $("#ROI").html(ROI+ "<sup>%</sup>");
    
    $("#spread").html(SPREAD + "<sup>%</sup>");
        
    $("#LoanAmt").text(AMT_LOAN);
    $("#LoanAmt1").html('<sup class="icon-indian-rupee"></sup>' + AMT_LOAN);    
    $("#Li").text(AMT_LI);    
    $("#Gi").text(AMT_GI);
    $("#Emi").html('<sup class="icon-indian-rupee"></sup>' + AMT_EMI);
    $("#tenure").html(TENURE + "<sup>mo</sup>");
    $("#LoanLI").html('<sup class="icon-indian-rupee"></sup>' + LOAN_LI);
    $("#LI_1").html('<sup class="icon-indian-rupee"></sup>' + LI_EMI);

    $("#LoanGI").html('<sup class="icon-indian-rupee"></sup>' + LOAN_GI);    
    $("#GI_1").html('<sup class="icon-indian-rupee"></sup>' + GI_EMI);

    $("#lipi").html('<sup class="icon-indian-rupee"></sup>' + LOAN_LG);
    $("#lipiamt").html('<sup class="icon-indian-rupee"></sup>' + LG_EMI);

}

function fnSetLoanAttr_new(data) {
    var LI, GI, LOAN, TENURE, ROI;
    $("#shplr").html("15 <sup>%</sup>");
    var value = "";
    value = data[0].ROI.toFixed(2);
    ROI = value;
    $("#ROI").html(value + "<sup>%</sup>");
    var sprd = Number(value) - 15.00;
    $("#spread").html(sprd + "<sup>%</sup>");

    value = data[0].LOAN_AMT.toFixed(2);
    LOAN = value;
    value = FormatCurrency(value);
    $("#LoanAmt").text(value);
    $("#LoanAmt1").html('<sup class="icon-indian-rupee"></sup>' + value);

    value = data[0].LI.toFixed(0);
    LI = value;
    value = FormatCurrency(value);
    $("#Li").text(value);

    value = data[0].GI.toFixed(0);
    GI = value;
    value = FormatCurrency(value);
    $("#Gi").text(value);


    value = data[0].EMI.toFixed(0);
    value = FormatCurrency(value);
    $("#Emi").html('<sup class="icon-indian-rupee"></sup>' + value);

    TENURE = data[0].TENUR;
    $("#tenure").html(TENURE + "<sup>mo</sup>");

    var Irate = ROI, LoanAmt, Tenure = TENURE;

    var lnLi = Number(LOAN) + Number(LI);
    var lnGi = Number(LOAN) + Number(GI);
    var lnGL = Number(LOAN) + Number(LI) + Number(GI);
    $("#LoanLI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(lnLi.toString()));
    LoanAmt = lnLi;
    var LiEMI = CreditFormulas.PMT(Irate, Tenure, LoanAmt);
    $("#LI_1").html('<sup class="icon-indian-rupee"></sup>'+ FormatCurrency(LiEMI));

    $("#LoanGI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(lnGi.toString()));
    LoanAmt = lnGi;
    var GiEMI = CreditFormulas.PMT(Irate, Tenure, LoanAmt);
    $("#GI_1").html('<sup class="icon-indian-rupee"></sup>'+ FormatCurrency(GiEMI));


    $("#lipi").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(lnGL.toString()));
    LoanAmt = lnGL;
    var GLEMI = CreditFormulas.PMT(Irate, Tenure, LoanAmt);
    $("#lipiamt").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(GLEMI));
}

function fnSetLoanAttr(data) {
    var LI, GI, LOAN , TENURE , ROI ;
    $("#shplr").html("15 <sup>%</sup>");
    for (var i = 0; i < data.length; i++) {
        var comp = data[i].AttrCode;
        var value = data[i].Value;                                                                                                    
        if (comp == "ROI") {
            value = value.toFixed(2);
            ROI  = value;
            $("#ROI").html(value + "<sup>%</sup>");
            var sprd = value - 15.00;
            $("#spread").html(sprd + "<sup>%</sup>");
        }

        if (comp == "LOAN_AMT") {
            value = value.toFixed(0);
            LOAN = value;
            value = FormatCurrency(value);
            $("#LoanAmt").text(value);
            $("#LoanAmt1").html('<sup class="icon-indian-rupee"></sup>' + value);
        }
        if (comp == "LI") {            
            value = value.toFixed(0);
            LI = value;
            value = FormatCurrency(value);
            $("#Li").text(value);
        }
        if (comp == "GI") {            
            value = value.toFixed(0);
            GI = value;
            value = FormatCurrency(value);
            $("#Gi").text(value);
        }

        if (comp == "EMI") {
            value = value.toFixed(0);
            value = FormatCurrency(value);
            $("#Emi").text(value);
        }

        if (comp == "OBL") {

        }
        if (comp == "NET_INC") {

        }

        if (comp == "CBL") {

        }

        if (comp == "TENUR") {
            TENURE = value;
            $("#tenure").html(value + "<sup>mo</sup>");
        }

        if (comp == "ACT_PRP") {

        }

        if (comp == "EST_PRP") {

        }
    }


    var Irate = ROI, LoanAmt, Tenure = TENURE;

    var lnLi =  Number(LOAN) + Number(LI);
    var lnGi = Number(LOAN) + Number(GI);
    var lnGL = Number(LOAN) + Number(LI) + Number(GI);
    $("#LoanLI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(lnLi.toString()));
    LoanAmt = lnLi;
    var LiEMI = CreditFormulas.PMT(Irate, Tenure, LoanAmt);
    $("#LI_1").text(LiEMI);
    
    $("#LoanGI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(lnGi.toString()));
    LoanAmt = lnGi;
    var GiEMI = CreditFormulas.PMT(Irate, Tenure, LoanAmt);
    $("#GI_1").text(GiEMI);
    

    $("#lipi").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(lnGL.toString()));
    LoanAmt = lnGL;
    var GLEMI = CreditFormulas.PMT(Irate, Tenure, LoanAmt);
    $("#lipiamt").text(GLEMI);    
}

function fnSetSubjective(data) {
    var ul = "<tr>";
    for (var i = 0; i < data.length; i++) {
        ul += "<td style='padding:0 30px;'>" + (i + 1) + " . " + data[i].condition + "</td> </tr>";
    }
    ul += "</ul>";
    $("#subjective").append(ul);
}


function gup(name, url) {
    if (!url) url = location.href;
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(url);
    return results == null ? null : results[1];
}