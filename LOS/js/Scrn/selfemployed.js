var LedGlobal = [{}];
var Action = ''
var IsFinalConfirm = "";
window.GlobalXml = [{}];
var LapArr = ['LAPResi', 'LAPCom', 'LAPBTTopup', 'LAPBT', 'LAPTopup'];
var productcode = "";
var OrgProductCode = "";
var ExpLoanAmt = 0;

$(document).ready(function () {
    var LeadInfo = localStorage.getItem("LeadInfo");
    if (LeadInfo != "") {
        var Obj = JSON.parse(LeadInfo);
        LedGlobal = Obj;
        fnLoadDetails();
    }
});

function fnLoadDetails() {    
    var PrcObj = { ProcedureName: "PrcShflCAM", Type: "SP", Parameters: ["GEN_CAM", JSON.stringify(LedGlobal)] };
    fnCallLOSWebService("GEN_CAM", PrcObj, fnLoadResult, "MULTI");
}

function fnLoadResult(ServiceFor, Obj, Param1, Param2) {
    if (!Obj.status) {
        alert(Obj.error);
        return;
    }
 
     if (ServiceFor == "GEN_CAM") {
        var AppDet = JSON.parse(Obj.result_1);
        var ExpDet = JSON.parse(Obj.result_2);
        var CredDet = JSON.parse(Obj.result_3);
        var BusiInc = JSON.parse(Obj.result_4);
        var SalInc = JSON.parse(Obj.result_5);
        var CashInc = JSON.parse(Obj.result_6);
        var OtherInc = JSON.parse(Obj.result_7);
        var BankBal = JSON.parse(Obj.result_8);
        var OblDet = JSON.parse(Obj.result_9);
        var LeadIncome = JSON.parse(Obj.result_10);
        var TechProp = JSON.parse(Obj.result_11);
        var MinMktVal = JSON.parse(Obj.result_12);

        if (TechProp && TechProp.length > 0) {
            fnTechProp(TechProp, MinMktVal);
        }

        if (!CredDet || CredDet.length == 0) {
            $("body").empty();
            setTimeout(function () { alert("Credit Officer entry is not done, CAM cannot be generated..") }, 200);
            //return;
        }
        if (AppDet && AppDet.length > 0) { fnBuildPersonalDetails(AppDet); }
        if (ExpDet && ExpDet.length > 0) { fnSetExpLoanDet(ExpDet); }
        if (CredDet && CredDet.length > 0) { fnSetLoanAttr_New(CredDet); }
        fnSetIncomeDetails(BusiInc, SalInc, CashInc, OtherInc, BankBal);
        if (OblDet && OblDet.length > 0) {
            //fnSetObligationData(OblDet);
            fnSetLeadObligationsList(OblDet);
        }
        if (LeadIncome && LeadIncome.length > 0) { fnSetLeadIncomeObl(LeadIncome); }

    }
}


function fnBuildPersonalDetails(data) {
    var CommonDiv = "";
    if (data.length > 0) {
        productcode = data[0].productcode;
        for (var i = 0; i < data.length; i++) {
            var EmpType = data[i].EmpType;
            CommonDiv += '<tbody>' +
                        '<tr>' +
                        '<td><label>' + data[i].Applicant + ' Name : </label> <span>' + data[i].ApplName + '</span></td>' +
                        ' <td width="40%"><label>Done By : </label> <span>' + data[i].UsrNm + '</span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td><label>Name of ' + (EmpType == 'O' ? 'Employer' : 'Business ') + ' : </label> <span>' + data[i].BuisNm + '</span></td>' +
                        '<td><label>Date : </label> <span>16/11/2016</span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td colspan="2"><label>Nature of ' + (EmpType == 'O' ? 'Employment' : 'Business ') + ' : </label> <span>' + data[i].BusiNat + '</span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td><label>Type of Organization : </label> <span> ' + data[i].OrgTyp + '</span></td>' +
                        '<td><label>Others : </label> <span> </span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td><label>Designation : </label> <span> ' + data[i].Design + ' </span></td>' +
                        '  <td>' +
                        ' <table width="100%" border="0" cellspacing="0" cellpadding="0">' +
                        '<tbody>' +
                        '<tr>' +
                        ' <td><label>D.O.B : </label> <span>  ' + data[i].dob + ' </span></td>' +
                        '<td><label>Age : </label> <span> ' + data[i].age + '  </span></td>' +
                        ' </tr>' +
                        '</tbody>' +
                        '</table>' +
                        '</td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td><label>No. of yrs in ' + (EmpType == 'O' ? 'Job' : 'Business') + ' : </label> <span>' + data[i].BusiPeriod + ' </span></td>' +
                        '<td><label>Total Experience : </label> <span>' + data[i].TotExp + '  </span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<td><label>Bureau Report : </label> <span> </span></td>' +
                        '<td><label>Bureau Score : </label> <span> ' + data[i].CibilScr + ' </span></td>' +
                        '</tr>' +
                        '                  <tr>' +
                        '<td><label>  </label> <span> </span></td>' +
                        ' <td><label>  </label> <span> </span></td>' +
                        '</tr>' +
                        '</tbody>';
        }
        $("#self-table").append(CommonDiv);
    }
}

function fnSetLoanAttr_BTtopup(data) {
    var OBL, IIR, NET_INC, FOIR, CBL, TENURE, LOAN_AMT, ROI, EMI, SPREAD, EST_PRP, ACT_PRP, LTV,
    ACT_LTV, LI, GI, TOPUP_AMT, BT_AMT, BT_ROI, BT_EMI, TOPUP_EMI, BT_LI, TOPUP_LI, BT_GI, TOPUP_GI, TOPUP_ROI;

    
    var AMT_OBL, AMT_NET_INC, AMT_LOAN_AMT, AMT_EMI, AMT_EST_PRP, AMT_ACT_PRP,
    AMT_LI, AMT_GI, AMT_TOPUP_AMT, AMT_BT_AMT, AMT_BT_EMI, AMT_TOPUP_EMI, AMT_BT_LI, AMT_TOPUP_LI, AMT_BT_GI, AMT_TOPUP_GI;

    OBL = data[0].OBL || 0;
    IIR = data[0].IIR || 0;
    NET_INC = data[0].NET_INC || 0;
    FOIR = data[0].FOIR || 0;
    CBL = data[0].CBL || 0;
    TENURE = data[0].TENUR || 0;
    LOAN_AMT = data[0].LOAN_AMT || 0;
    ROI = data[0].ROI || 0;
    EMI = data[0].EMI || 0;
    SPREAD = data[0].SPREAD || 0;
    EST_PRP = data[0].EST_PRP || 0;
    ACT_PRP = data[0].ACT_PRP || 0;
    LTV = data[0].LTV || 0;
    ACT_LTV = data[0].ACT_LTV || 0;
    LI = data[0].LI || 0;
    GI = data[0].GI || 0;
    TOPUP_AMT = data[0].TOPUP_AMT || 0;
    BT_AMT = data[0].BT_AMT || 0;
    BT_ROI = data[0].BT_ROI || 0;
    BT_EMI = data[0].BT_EMI || 0;
    TOPUP_EMI = data[0].TOPUP_EMI || 0;
    BT_LI = data[0].BT_LI || 0;
    TOPUP_LI = data[0].TOPUP_LI || 0;
    BT_GI = data[0].BT_GI || 0;
    TOPUP_GI = data[0].TOPUP_GI || 0;
    TOPUP_ROI = data[0].TOPUP_ROI || 0;

    AMT_OBL = FormatCurrency(OBL);
    AMT_NET_INC = FormatCurrency(NET_INC);
    AMT_LOAN_AMT = FormatCurrency(LOAN_AMT);
    AMT_EMI = FormatCurrency(EMI );    
    AMT_LI = FormatCurrency(LI);
    AMT_GI = FormatCurrency(GI);
    AMT_TOPUP_AMT = FormatCurrency(TOPUP_AMT);
    AMT_BT_AMT= FormatCurrency(BT_AMT);
    AMT_BT_EMI= FormatCurrency(BT_EMI);
    AMT_TOPUP_EMI = FormatCurrency(TOPUP_EMI);
    AMT_BT_LI = FormatCurrency(BT_LI);
    AMT_TOPUP_LI = FormatCurrency(TOPUP_LI);
    AMT_BT_GI = FormatCurrency(BT_GI);
    AMT_TOPUP_GI = FormatCurrency(TOPUP_GI);


    if (LapArr.indexOf(productcode) >= 0)
        FOIR = data[0].IIR;
    else
        FOIR = data[0].FOIR;

    /* BT LOAN DETAILS */

    $(".normal").find(".loan-title").text("Loan Detials - BT");

    $(".normal").find("#CurFOIR").html(FOIR + " <sup>%</sup>");
    $(".normal").find("#ElgFoir").html(FOIR + " <sup>%</sup>");

    $(".normal").find("#shplr").html("15 <sup>%</sup>");
    $(".normal").find("#ROI").html(BT_ROI + "<sup>%</sup>");
    var btspread = BT_ROI = 15;
    $(".normal").find("#spread").html(btspread + "<sup>%</sup>");
    $(".normal").find("#LoanAmt").html('<i class=icon-indian-rupee></i> ' + AMT_BT_AMT);
    $(".normal").find("#LoanAmt1").html('<i class=icon-indian-rupee></i> ' + AMT_BT_AMT);
    $(".normal").find("#Li").html('<i class=icon-indian-rupee></i> ' + AMT_BT_LI);
    $(".normal").find("#Gi").html('<i class=icon-indian-rupee></i> ' + AMT_BT_GI);
    $(".normal").find("#Emi").html('<i class=icon-indian-rupee></i> ' + AMT_BT_EMI);
    $(".normal").find("#PrpEmi").html('<i class=icon-indian-rupee></i> ' + AMT_BT_EMI);
    $(".normal").find("#Tenure").html(TENURE + "<sup>mo</sup>");
    $(".normal").find("#CurLTV").html(LTV + "<sup>%</sup>");

    $("#LtvToMV").html(LTV + "<sup>%</sup>");
    $("#CLIR").html("-");    

    $(".normal").find("#Nami").html('<i class=icon-indian-rupee></i> ' + FormatCurrency(NET_INC - OBL));
    $(".normal").find("#LoanLI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(Number(BT_AMT) + Number(BT_LI)));
    $(".normal").find("#LI_1").html(LI);
    $(".normal").find("#LoanGI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(Number(BT_AMT) + Number(BT_GI)));
    $(".normal").find("#GI_1").html(AMT_BT_GI);
    var emilakh = BT_EMI / Number(BT_AMT) * 100000;
    $(".normal").find("#EmiLakh").html('<i class=icon-indian-rupee></i> ' + emilakh.toFixed(2));
    $(".normal").find("#ElgLn").html('<i class=icon-indian-rupee></i> ' + AMT_BT_AMT);

    /* TOPUPLOAN DETAILS */
    $(".top-up").find("#CurFOIR").html(FOIR + " <sup>%</sup>");
    $(".top-up").find("#ElgFoir").html(FOIR + " <sup>%</sup>");

    $(".top-up").find("#shplr").html("15 <sup>%</sup>");
    $(".top-up").find("#ROI").html(TOPUP_ROI + "<sup>%</sup>");
    var btspread = TOPUP_ROI = 15;
    $(".top-up").find("#spread").html(btspread + "<sup>%</sup>");
    $(".top-up").find("#LoanAmt").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_AMT);
    $(".top-up").find("#LoanAmt1").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_AMT);
    $(".top-up").find("#Li").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_LI);
    $(".top-up").find("#Gi").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_GI);
    $(".top-up").find("#Emi").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_EMI);
    $(".top-up").find("#PrpEmi").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_EMI);
    $(".top-up").find("#Tenure").html(TENURE + "<sup>mo</sup>");
    $(".top-up").find("#CurLTV").html(LTV + "<sup>%</sup>");


    $(".top-up").find("#Nami").html('<i class=icon-indian-rupee></i> ' + FormatCurrency(NET_INC - OBL));
    $(".top-up").find("#LoanLI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(Number(TOPUP_AMT) + Number(TOPUP_LI)));
    $(".top-up").find("#LI_1").html(LI);
    $(".top-up").find("#LoanGI").html('<sup class="icon-indian-rupee"></sup>' + FormatCurrency(Number(TOPUP_AMT) + Number(TOPUP_GI)));
    $(".top-up").find("#GI_1").html(AMT_TOPUP_GI);
    emilakh = TOPUP_EMI / Number(TOPUP_AMT) * 100000;
    $(".top-up").find("#EmiLakh").html('<i class=icon-indian-rupee></i> ' + emilakh.toFixed(2));
    $(".top-up").find("#ElgLn").html('<i class=icon-indian-rupee></i> ' + AMT_TOPUP_AMT);

}


function fnSetLoanAttr_New(data) {
    var LI, GI, LOAN, TENURE, ROI, SPREAD, EMI, LI_EMI, GI_EMI, LG_EMI, FOIR, LTV, INCOME, OBLIGATION;
    var AMT_LI, AMT_GI, AMT_LOAN, TENURE, ROI, SPREAD, AMT_EMI, AMT_LI_EMI, AMT_GI_EMI, AMT_LG_EMI;
    //OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
    //ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI

    OrgProductCode = data[0].OrgProductCode;

    if (productcode == "HLBTTopup" || productcode == "LAPBTTopup" || productcode == "HLTopup" || productcode == "LAPTopup") {
        $(".top-up").show();
        fnSetLoanAttr_BTtopup(data);
        return;
    }

    if (LapArr.indexOf(productcode) >= 0)
        FOIR = data[0].IIR;
    else
        FOIR = data[0].FOIR;

    if (OrgProductCode != productcode && (productcode == "HLBT" || productcode == "LAPBT")) {
        LI = data[0].BT_LI.toFixed(2);
        AMT_LI = FormatCurrency(LI);
        GI = data[0].BT_GI.toFixed(2);
        AMT_GI = FormatCurrency(GI);
        //FOIR = data[0].FOIR;
        LTV = data[0].LTV;
        INCOME = data[0].NET_INC;
        OBLIGATION = data[0].OBL;
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
        //FOIR = data[0].FOIR;
        LTV = data[0].LTV;
        INCOME = data[0].NET_INC;
        OBLIGATION = data[0].OBL;
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
    $(".normal").find("#CurFOIR").html(FOIR + " <sup>%</sup>");
    $(".normal").find("#ElgFoir").html(FOIR + " <sup>%</sup>");

    $(".normal").find("#shplr").html("15 <sup>%</sup>");
    $(".normal").find("#ROI").html(ROI + "<sup>%</sup>");
    $(".normal").find("#spread").html(SPREAD + "<sup>%</sup>");
    $(".normal").find("#LoanAmt").html('<i class=icon-indian-rupee></i> ' + LOAN);
    $(".normal").find("#LoanAmt1").html('<i class=icon-indian-rupee></i> ' + LOAN);
    $(".normal").find("#Li").html('<i class=icon-indian-rupee></i> ' + LI);
    $(".normal").find("#Gi").html('<i class=icon-indian-rupee></i> ' + GI);
    $(".normal").find("#Emi").html('<i class=icon-indian-rupee></i> ' + EMI);
    $(".normal").find("#PrpEmi").html('<i class=icon-indian-rupee></i> ' + EMI);
    $(".normal").find("#Tenure").html(TENURE + "<sup>mo</sup>");
    $(".normal").find("#CurLTV").html(LTV + "<sup>%</sup>");

    $("#LtvToMV").html(LTV + "<sup>%</sup>");
    $("#CLIR").html("-");
    //var emiExp = CreditFormulas.PMT(ROI, TENURE, ExpLoanAmt);
    //emiExp
    //$("#CLIR").html("<sup>%</sup>");

    


    $(".normal").find("#Nami").html('<i class=icon-indian-rupee></i> ' + (INCOME - OBLIGATION));
    $(".normal").find("#LoanLI").html('<sup class="icon-indian-rupee"></sup>' + (Number(LOAN) + Number(LI)));
    $(".normal").find("#LI_1").html(LI);
    $(".normal").find("#LoanGI").html('<sup class="icon-indian-rupee"></sup>' + (Number(LOAN) + Number(GI)));
    $(".normal").find("#GI_1").html(GI);
    var emilakh = EMI / Number(LOAN) * 100000;
    $(".normal").find("#EmiLakh").html('<i class=icon-indian-rupee></i> ' + emilakh.toFixed(2));
    $(".normal").find("#ElgLn").html('<i class=icon-indian-rupee></i> ' + LOAN);

}


function fnSetLeadIncomeObl(LeadIncome) {
    var tbl = '';
    var totlInc = 0;
    var totlObl = 0;
    for (var i = 0; i < LeadIncome.length; i++) {
        if (i == 0)
            tbl += '<h2>Cash Flow Average per Month</h2>';
        var inc = FormatCurrency(LeadIncome[i].inc.toFixed(2));
        totlInc = totlInc + Number(LeadIncome[i].inc.toFixed(2));
        totlObl = totlObl + Number(LeadIncome[i].obl.toFixed(2));

        var obl = FormatCurrency(LeadIncome[i].obl.toFixed(2));
        var netinc = LeadIncome[i].inc - LeadIncome[i].obl;
        netinc = FormatCurrency(netinc.toFixed(2));
        tbl += '<table width="100" cellspacing="0" cellpadding="0"  class="applicant-table">' +
            '<tbody><tr><th colspan="2">' + LeadIncome[i].Actor + '' +
        '</th></tr><tr><td>Gross Income</td><td><i class=icon-indian-rupee></i> ' + inc + '</td>' +
        '</tr><tr><td>Indirect Expenses(Obligations)</td><td><i class=icon-indian-rupee></i> ' + obl + '</td></tr>' +
        '<tr><td><strong>Net Income</strong></td><td><strong><i class=icon-indian-rupee></i> ' + netinc + '</strong></td></tr>' +
        '</tbody></table>';
    }
    $("#LeadIncomeDiv").append(tbl);
    $("#totalinc").html('<i class=icon-indian-rupee></i> ' + FormatCurrency(totlInc.toString()));
    $("#totalObl").html('<i class=icon-indian-rupee></i> ' + FormatCurrency(totlObl.toString()));
    var Foir = 0;
    if (Number(totlInc) > 30000) { Foir = 60; }
    else { Foir = 50; }
    $("#FoirInc").html(Foir + "<sup>%</sup>");
    //$("#appLTV").html(Foir + "<sup>%</sup>");
}


function fnSetLeadObligationsList(data) {
    var tr = "";
    var totalOBL = 0;
    for (var i = 0; i < data.length; i++) {
        totalOBL = totalOBL + Number(data[i].OblEmi);
        tr += '<tr><td>' + data[i].Type + '</td><td colspan="2">' + FormatCurrency (data[i].OblEmi )+ '</td></tr>';
    }
    $("#OblAppend").after(tr);
    $("#totalOBL").html('<i class=icon-indian-rupee></i> ' + FormatCurrency(totalOBL));
}


function gup(name, url) {
    if (!url) url = location.href;
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(url);
    return results == null ? null : results[1];
}

function fnSetExpLoanDet(data) {
    $("#leadid").html(data[0].LeadNo);
    ExpLoanAmt = data[0].LnAmt;
    var CommonDiv = $(
        '<tbody>' +
        '<tr>' +
        '<td width="33%"><label>Loan Amount : </label><i class=icon-indian-rupee></i> <span>' + data[0].LnAmt + '</span></td>' +
        '<td width="33%"><label>ROI : </label> <span>' + data[0].ROI + '</span></td>' +
        '<td width="33%">Tenure in months : <span>' + data[0].Tenure + '</span></td>' +
        '</tr>' +
        '</tbody>');
    $("#amt_table").append(CommonDiv);
}

function fnSetObligationData(data) { }


function fnSetIncomeDetails(BusiInc, SalInc, CashInc, OtherInc, BankBal) {
    //var BsTable = "<table width='100%'>", SalTable = "<table width='100%'>", CashTable = "<table width='100%'>",
    //    OtherTable = "<table width='100%'>", BankTable = "<table width='100%'>";
    if (BusiInc && BusiInc.length > 0) {

        var Applicant = $(BusiInc).filter(function (i, n) {
            return (n.Actor == 0 || n.Actor == "0");
        });

        var CoApplicant = $(BusiInc).filter(function (i, n) {
            return (n.Actor == 1 || n.Actor == "1");
        });

        var Guarantor = $(BusiInc).filter(function (i, n) {
            return (n.Actor == 2 || n.Actor == "2");
        });


        if (Applicant && Applicant.length > 0)
            fnBuildIncomeDetails(Applicant, 0, "BusinessDiv");
        if (CoApplicant && CoApplicant.length > 0)
            fnBuildIncomeDetails(CoApplicant, 1, "BusinessDiv");
        if (Guarantor && Guarantor.length > 0)
            fnBuildIncomeDetails(Guarantor, 2, "BusinessDiv");

    } else { $("#BusinessDiv").empty(); }
    if (SalInc && SalInc.length > 0) {
        var Applicant = $(SalInc).filter(function (i, n) {
            return (n.Actor == 0 || n.Actor == "0");
        });

        var CoApplicant = $(SalInc).filter(function (i, n) {
            return (n.Actor == 1 || n.Actor == "1");
        });

        var Guarantor = $(SalInc).filter(function (i, n) {
            return (n.Actor == 2 || n.Actor == "2");
        });

        if (Applicant && Applicant.length > 0)
            fnBuildIncomeDetails(Applicant, 0, "SalaryDiv");
        if (CoApplicant && CoApplicant.length > 0)
            fnBuildIncomeDetails(CoApplicant, 1, "SalaryDiv");
        if (Guarantor && Guarantor.length > 0)
            fnBuildIncomeDetails(Guarantor, 2, "SalaryDiv");

    } else { $("#SalaryDiv").empty(); }
    if (CashInc && CashInc.length > 0) {
        var List = "";
        var AverageCol = $(CashInc).filter(function (i, n) {
            return (n.AvgType == -1 || n.AvgType == "-1");
        });

        var Applicant = $(CashInc).filter(function (i, n) {
            return (n.Actor == 0 || n.Actor == "0");
        });

        var CoApplicant = $(CashInc).filter(function (i, n) {
            return (n.Actor == 1 || n.Actor == "1");
        });

        var Guarantor = $(CashInc).filter(function (i, n) {
            return (n.Actor == 2 || n.Actor == "2");
        });

        if (Applicant && Applicant.length > 0)
            fnBuildIncomeDetails(Applicant, 0, "CashDiv");
        if (CoApplicant && CoApplicant.length > 0)
            fnBuildIncomeDetails(CoApplicant, 1, "CashDiv");
        if (Guarantor && Guarantor.length > 0)
            fnBuildIncomeDetails(Guarantor, 2, "CashDiv");

    } else { $("#CashDiv").empty(); }
    if (BankBal && BankBal.length > 0) {
        var List = "";
        var AverageCol = $(CashInc).filter(function (i, n) {
            return (n.AvgType == -1 || n.AvgType == "-1");
        });

        var Applicant = $(BankBal).filter(function (i, n) {
            return (n.Actor == 0 || n.Actor == "0");
        });

        var CoApplicant = $(BankBal).filter(function (i, n) {
            return (n.Actor == 1 || n.Actor == "1");
        });

        var Guarantor = $(BankBal).filter(function (i, n) {
            return (n.Actor == 2 || n.Actor == "2");
        });


        if (Applicant && Applicant.length > 0)
            fnBuildBankDetails(Applicant, 0, "BankDiv");
        if (CoApplicant && CoApplicant.length > 0)
            fnBuildBankDetails(CoApplicant, 1, "BankDiv");
        if (Guarantor && Guarantor.length > 0)
            fnBuildBankDetails(Guarantor, 2, "BankDiv");



    } else { $("#BankDiv").empty(); }

    if (OtherInc && OtherInc.length > 0) {

        var Applicant = $(OtherInc).filter(function (i, n) {
            return (n.Actor == 0 || n.Actor == "0");
        });

        var CoApplicant = $(OtherInc).filter(function (i, n) {
            return (n.Actor == 1 || n.Actor == "1");
        });

        var Guarantor = $(OtherInc).filter(function (i, n) {
            return (n.Actor == 2 || n.Actor == "2");
        });


        var ul = "<ul class='verticalul'>";
        for (var i = 0; i < OtherInc.length; i++) {
            ul += "<li>" + OtherInc[i].CompName + "   :   " + OtherInc[i].Amount + "</li>";
        }
        $("#OthersDiv").append(ul);
    } else { $("#OthersDiv").empty(); }
}


function fnBuildIncomeDetails(Data, type, divId) {

    if (type == 0) { $("#" + divId).append("<h2>Applicant</h2>"); }
    if (type == 1) { $("#" + divId).append("<h2>Co Applicant</h2>"); }
    if (type == 2) { $("#" + divId).append("<h2>Guarantor</h2>"); }

    var AverageCol = $(Data).filter(function (i, n) {
        return (n.AvgType == -1 || n.AvgType == "-1");
    });

    var titleUL = "<ul style='text-align:left;padding-left:0px;' class='verticalul'>";
    var AvgUL = "<ul class='verticalul'>";
    var CompLen = AverageCol.length;
    for (var a = 0; a < AverageCol.length; a++) {
        if (a == 0) {
            titleUL += "<li><strong>Components</strong></li>";
            AvgUL += "<li><strong>Average</strong></li>";
        }
        var Name = AverageCol[a].CompName;
        titleUL += "<li>" + Name + "</li>";
        var amt = FormatCurrency(AverageCol[a].Amount.toFixed(2).toString());
        AvgUL += "<li><i class=icon-indian-rupee></i> " + amt + "</li>";
    }
    titleUL += "</ul>";
    AvgUL += "</ul>";
    var period = 1;
    var List = "";
    $("#" + divId).append(titleUL + AvgUL);
    for (var i = 0; i < Data.length; i++) {
        var type = Data[i].AvgType;
        if (type == "-1")
            continue;
        var amt = FormatCurrency(Data[i].Amount.toFixed(2).toString());
        if (i == 0) {
            List += "<ul class='verticalul'><li><strong> " + Data[i].incomeName + "</strong></li><li><i class=icon-indian-rupee></i> " + amt + "</li>";
            period++;
        }
        else {
            if (i > CompLen - 1) {
                if (i % CompLen == 0) {
                    var cnt = i % CompLen;
                    List += "</ul><ul class='verticalul'><li><strong> " + Data[i].incomeName + "</strong></li><li><i class=icon-indian-rupee></i> " + amt + "</li>";
                    period++;
                }
                else { List += "<li><i class=icon-indian-rupee></i> " + amt + "</li>"; }
            }
            else { List += "<li><i class=icon-indian-rupee></i> " + amt + "</li>"; }
        }
    }
    List += "</ul>";
    $("#" + divId).append(List);
}


function fnBuildBankDetails(Data, type, divId) {


    if (type == 0) { $("#" + divId).append("<h2>Applicant</h2>"); }
    if (type == 1) { $("#" + divId).append("<h2>Co Applicant</h2>"); }
    if (type == 2) { $("#" + divId).append("<h2>Guarantor</h2>"); }

    var AverageCol = $(Data).filter(function (i, n) {
        return (n.AvgType == -1 || n.AvgType == "-1");
    });

    var titleUL = "<ul class='verticalul'>";
    var AvgUL = "<ul class='verticalul'>";
    var CompLen = AverageCol.length;
    var avgTot = 0;
    for (var a = 0; a < AverageCol.length; a++) {
        if (a == 0) {
            titleUL += "<li><strong>Components</strong></li>";
            AvgUL += "<li><strong>Average</strong></li>";
        }
        var Name = AverageCol[a].CompName;
        var arrName = [5, 15, 25, 30];
        var nm = arrName[a] ? "On " + arrName[a] + "th" : "Average";
        titleUL += "<li>" + nm + "</li>";
        var amt = FormatCurrency(AverageCol[a].Amount.toFixed(2).toString());
        if (nm != "Average") {
            AvgUL += "<li><i class=icon-indian-rupee></i> " + amt + "</li>";
            avgTot = Number(avgTot) + Number(AverageCol[a].Amount);
        }
        else {
            avgTot = avgTot.toFixed(2);
            AvgUL += "<li><i class=icon-indian-rupee></i> " + avgTot / a + "</li>";
        }
    }
    titleUL += "</ul>";
    AvgUL += "</ul>";
    $("#" + divId).append(titleUL + AvgUL);
    var period = 1;
    var BankAvg = 0;
    var List = "";
    for (var i = 0; i < Data.length; i++) {
        var type = Data[i].AvgType;
        if (type == "-1")
            continue;
        var amt = FormatCurrency(Data[i].Amount.toFixed(2).toString());
        if (i == 0) {
            List += "<ul class='verticalul'><li><strong>Period " + period + "</strong></li><li><i class=icon-indian-rupee></i> " + amt + "</li>";
            BankAvg = BankAvg + Number(Data[i].Amount);
            period++;
        }
        else {
            if (i > 4) {
                if (i % 5 == 0) {
                    List += "</ul><ul class='verticalul'><li><strong>Period " + period + "</strong></li><li><i class=icon-indian-rupee></i> " + amt + "</li>";
                    BankAvg = 0;
                    BankAvg = BankAvg + Number(Data[i].Amount);
                    period++;
                }
                else {
                    List += "<li><i class=icon-indian-rupee></i> " + amt + "</li>";
                }
            }
            else { List += "<li><i class=icon-indian-rupee></i> " + amt + "</li>"; }
        }
    }
    List += "</ul>";

    $("#" + divId).append(List);
}


function fnTechProp(TechProp,MinVal) {
    if (!TechProp || TechProp.length == 0)
        return;
    var tr = "";
    for (var i = 0; i < TechProp.length; i++) {
        tr += "  <tr><td>valuation " + (i + 1) + "</td><td>" + FormatCurrency(TechProp[i].MktVal) + "</td></tr>";
    }
    $("#PrpValuation").after(tr);
    $("#PrpLower").text(FormatCurrency(MinVal[0].MinMktVal));


}