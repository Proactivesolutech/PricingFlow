var IsBranchCredit = false;
var ISMOVENXT = "";
var statusList = creditOfficer.Status;
var Deviations = creditOfficer.DeviationFactors;
var isEditMode = false;
var AGENT_VERF;
var ProductDiv = "";
var productCode = "";
var product = [{ name: "", class: "" }, { name: "Home Loan", class: "icon-home-loan" }, { name: "", class: "" }, { name: "Top Up", class: "icon-topup-loan" }, { name: "Balance Transfer", class: "icon-balance-transfer" }, { name: "LAP", class: "icon-lap" }];
var customerClass = [{ name: "Salaried ", class: "icon-salaried" }, { name: "Self Employed", class: "icon-self-employed" },
                    { name: "House wife", class: "" }, { name: "Pensioner", class: "" }, { name: "Student", class: "" }];
var incomeClass = [{ name: "Proof ", class: "icon-proof" }, { name: "No Proof", class: "icon-no-proof" }, { name: "Surrogate", class: "icon-sorrogate" }];

var GLOB_CREDIT = {};
var GLOB_APP = [];
var LapArr = ['LAPResi', 'LAPCom', 'LAPBTTopup', 'LAPBT', 'LAPTopup'];
var BTTopArr = ['LAPBTTopup', 'LAPBT', 'LAPTopup', 'HLBTTopup', 'HLBT', 'HLTopup'];
var isLapProduct = false;

var ApproverLevel = 0;
var MaxApproverLevel = 1;

GlobalXml[0].Role = GlobalRoles[0].Role;
var Credit_Atr = "";
var Credit_Elem = "";
var editNotesPK = "";

var CustFinGlobal = [{}];
var taxGlobal = [{}];
var remainingTenure = 0;
var crtPFClrdAmt = 0;
/*Changes start By Kani On 20/12/2016*/
var PFflag = 0;
$(document).on("click", ".bc_link_feeback_credit.bg-tag", function () {
    fnOnPopUpCust($(this));
});

/*Changes end By Kani On 20/12/2016*/

/**/
$(document).ready(function () {
    $(".PFAdjust").hide();
    GlobalXml[0].SancRvnNo = window.SancRvnNo;

    ApproverLevel = GlobalXml[0].CLvlNo;

    CustFinGlobal[0].FwdDataPk = GlobalXml[0].FwdDataPk;
    CustFinGlobal[0].LeadPk = GlobalXml[0].FwdDataPk;
    CustFinGlobal[0].GeoFk = GlobalXml[0].BrnchFk;
    CustFinGlobal[0].UsrPk = GlobalXml[0].UsrPk;
    CustFinGlobal[0].UsrDispNm = GlobalXml[0].UsrNm;
    CustFinGlobal[0].UsrNm = GlobalXml[0].UsrCd;
    CustFinGlobal[0].PrdCd = GlobalXml[0].PrdCd;
    CustFinGlobal[0].RoleFk = GlobalRoles[0].Role;
    CustFinGlobal[0].BrnchFk = GlobalXml[0].BrnchFk;
    CustFinGlobal[0].PrdNm = GlobalXml[0].PrdNm;
    CustFinGlobal[0].LeadNm = GlobalXml[0].LeadNm;
    CustFinGlobal[0].LeadID = GlobalXml[0].LeadID;
    CustFinGlobal[0].PrdFk = GlobalXml[0].PrdFk;
    CustFinGlobal[0].AgtNm = GlobalXml[0].AgtNm;
    CustFinGlobal[0].AgtFk = GlobalXml[0].AgtFk;
    CustFinGlobal[0].Branch = GlobalXml[0].Branch;   

    fnCALoadIMC();    

    /* for ROI adjust */

    $(".roi-adjust").ionRangeSlider({
        min: -3, max: 3, from: 0, step: 0.25,
        onChange: function (data) {
            fnChangeRoiAdjust(data, "C")
        },
        onUpdate: function (data) {
            fnChangeRoiAdjust(data, "U")
        }
    });

    $(".roi-adjust-input").keydown(function (e) {
        var elem = this;
        var keyCode = e.which ? e.which : e.keyCode
        var ret = true;
        //var val = !isNaN(e.key);
        //ret = ((keyCode >= 48 && keyCode <= 57) || val || keyCode == 46 || keyCode == 8 || keyCode == 37 || keyCode == 39);
        //if (keyCode == 46) {
        //    var txt = FormatCleanComma($(elem).justtext());
        //    if (txt.replace(/[^.]/g, "").length > 0)
        //        ret = false;            
        //}

        if (keyCode == 13) {
            $(this).focusout();
            ret = false;
        }
        return ret;
    });

    $(".roi-adjust-input").focusout(function (e) {
        var txt = $(this).justtext() || "";
        var isNum = isNaN(txt);
        if (txt == "" || isNum)
        { txt = 0; $(this).text('0'); }
        txt = Number(txt);
        var box = $(this).closest(".box-sum");
        var slider = $(box).find(".roi-adjust").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: -3, max: 3, from: txt, step: 0.25,
                onChange: function (data) {
                    fnChangeRoiAdjust(data, "C")
                },
                onUpdate: function (data) {
                    fnChangeRoiAdjust(data, "U")
                }
            });
        $(this).closest(".hover-div").removeClass("hover-div-animation");
        $(this).closest(".hover-show").hide();
    });

    $(".roi-box").mouseover(function () {
        var reducedROI = $(this).find(".arrived-roi").justtext();
        var roiadjust = Number($(this).find(".roi-adjust").data("ionRangeSlider").result.from || 0);
        $(this).find(".roi-adjust-input").text(roiadjust);        
        if (reducedROI == "") {
            var roi = $(this).find("p[key='textval']").justtext();
            $(this).find(".arrived-roi").text(roi);
        }                
        $(this).find(".hover-div").addClass("hover-div-animation");
        $(this).find(".hover-show").show();
        //$(this).find(".roi-adjust-input").focus();
    });

    $(".roi-box").mouseleave(function () {
        var reducedROI = $(this).find(".arrived-roi").justtext();
        if (!$(this).find(".roi-adjust-input").is(":focus"))
        {
            $(this).find(".hover-show").hide();
            $(this).find(".hover-div").removeClass("hover-div-animation");
        }
    });
    /* for ROI adjust */
    //~JPR

    $("#RoiWaiver,#RoiWaiver_BT").focusout(function (e) {
        var txt = $(this).val();        
        txt = txt.trim();
        $(this).attr("val", txt);
        if (!isNaN(txt)) {
            var ID = $(this).attr("id");
            var type = ID == "RoiWaiver" ? "NA" : "BT";
        } else {
            $(this).val(0);
            $(this).attr("val", 0);
        }
        fnOnchange({});
    });

    $("#ManualDeviationLevel").select2({
        minimumResultsForSearch: -1
    });   
    if ($("#deviationFactors").length > 0) {
        fnOpenDeviationFatcors("INIT");
    }
    $(document).on("keypress", "span.value", function (e) {
        
        var elem = this;
        var keyCode = e.which ? e.which : e.keyCode
        var ret = ((keyCode >= 48 && keyCode <= 57) || keyCode == 46 || keyCode == 8 || keyCode == 37 || keyCode == 39);
        if (keyCode == 46) {
            var txt = FormatCleanComma($(elem).justtext());
            var htmtxt = $(elem).html();
            if (txt.replace(/[^.]/g, "").length > 0)
                ret = false;
        }

        if (keyCode == 13) {
            txt = FormatCleanComma($(elem).justtext()) || "";
            txt = txt.trim();
            var value = Number(txt);
            var slider = $(elem).closest("div").find("[key=rangeval]").data("ionRangeSlider");
            if (slider)
                slider.update({
                    from: value,
                    onChange: fnOnchange,
                    onUpdate: fnOnchange,
                    onFinish: function () {
                        fnSelectRemPF();
                    }
                });
            fnSelectRemPF();
        }

        return ret;
    });

    $(document).on("focusout", "span.value", function (e) {
        var elem = this;
        var txt = FormatCleanComma($(elem).justtext()) || "";
        txt = txt.trim();
        var value = Number(txt);
        var slider = $(elem).closest("div").find("[key=rangeval]").data("ionRangeSlider");
        if (slider)
            slider.update({
                from: value,
                onChange: fnOnchange,
                onUpdate: fnOnchange,
                onFinish: function () {
                    fnSelectRemPF();
                }
            });
        fnSelectRemPF();
    });



    if (!window.CREDIT_APPROVER_NO)
        window.CREDIT_APPROVER_NO = 1;
    console.log("c of");
    fnSelectSummary();
    fnSelectNotes();
    fnSelectQuery();    
    

    $(".right-query-content i.icon-plus,.property-sum .icon-warning").click(function (e) {
        $("#Crd_Comment").val("");
        $("#Crd_Comment").attr("placeholder", "Enter text");
        $("#subjective-div").show();
        $("#subjective-div input[type=button]").val("ADD")
        Credit_Atr = $(this).closest(".box-sum").attr("attrName");
    });

    $(".subjective-div i.icon-plus").click(function (e) {
        $("#Crd_Comment").val("");
        $("#Crd_Comment").attr("placeholder", "Enter text");
        $("#subjective-div").show();
        $("#subjective-div input[type=button]").val("ADD");
        Credit_Atr = "SUBJECTIVE";
    });


    $("input[class='for-currency']").focusout(function () {
        var value = FormatCleanComma($(this).val());
        if (value != "" && value != "0") {
            value = FormatCurrency(value);
            $(this).val(value);
        }
    });

    fnBTfocusEvents();

    $("#TxtFin_LI").focusout(function () {
        var val = FormatCleanComma($(this).val());
        val = Number(val) ? Number(val) : 0;
        if (val == 0)
            $(this).val(0);
        var LoanAmt = Number(FormatCleanComma($("#Fin_LOAN [key='textval']").justtext()));
        //LoanAmt = LoanAmt * 100000;
        var totAmt = LoanAmt + val;
        var Irate = Number($("#Fin_ROI [key='textval']").justtext());

        var waiver = Number($("#RoiWaiver").attr("val")) || 0;
        Irate = Number(Irate) + Number(waiver);

        var tenure = Number($("#ElgTenure [key='textval'] .value").justtext());
        if (tenure > 0 && Irate > 0 && totAmt > 0) {
            var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
            EmiVal = Math.round(EmiVal.toFixed(2));
            $("#Fin_EMI_L").find("[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal) + '');

            var LI = Number(FormatCleanComma($("#TxtFin_LI").val()));
            var GI = Number(FormatCleanComma($("#TxtFin_GI").val()));
            var Total_LG = Number(LoanAmt + LI + GI);
            var EMI_LG = CreditFormulas.PMT(Irate, tenure, Total_LG);
            EMI_LG = Math.round(EMI_LG.toFixed(2));
            $("#Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> ' + FormatCurrency(EMI_LG));
        }

    });
    $("#TxtFin_GI").focusout(function () {
        var val = FormatCleanComma($(this).val());
        val = Number(val) ? Number(val) : 0;
        if (val == 0)
            $(this).val(0);
        var LoanAmt = Number(FormatCleanComma($("#Fin_LOAN [key='textval']").justtext()));
        //LoanAmt = LoanAmt * 100000;
        var totAmt = LoanAmt + val;
        var Irate = Number($("#Fin_ROI [key='textval']").justtext());
        var waiver = Number($("#RoiWaiver").attr("val")) || 0;
        Irate = Number(Irate) + Number(waiver);
        var tenure = Number($("#ElgTenure [key='textval'] .value").justtext());
        if (tenure > 0 && Irate > 0 && totAmt > 0) {
            var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
            EmiVal = Math.round(EmiVal.toFixed(2));
            $("#Fin_EMI_G").find("[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal));

            var LI = Number(FormatCleanComma($("#TxtFin_LI").val()));
            var GI = Number(FormatCleanComma($("#TxtFin_GI").val()));
            var Total_LG = Number(LoanAmt + LI + GI);
            var EMI_LG = CreditFormulas.PMT(Irate, tenure, Total_LG);
            EMI_LG = Math.round(EMI_LG.toFixed(2));
            $("#Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> ' + FormatCurrency(EMI_LG));

        }
    });
    
});

function fnCALoadIMC() {
    var IMCConfig = [{}];
    IMCConfig[0].BrnchFk = CustFinGlobal[0].GeoFk;
    IMCConfig[0].PrdFk = CustFinGlobal[0].PrdFk;

    var objProcData = { ProcedureName: "PrcShflBpm_Proj", Type: "SP", Parameters: ["CMP_CONFIG_POLICY", JSON.stringify(IMCConfig), "gIMC"] };
    fnCallLOSWebService("CMP_CONFIG_POLICY", objProcData, fnCreditOffResult, "MULTI", "");
}
function fnSetLeadInfo(LeadInfo) {
    
    $("#txtCrLeadID").text(LeadInfo.LeadId);
    $("#txtCrAppNo").text(LeadInfo.ApplicationNo);
    $("#txtCrBrnchNm").text(LeadInfo.BranchName);
    $("#txtCrPurpose").text(LeadInfo.Purpose);

    var custClass_tmp = [{ name: "Salaried ", class: "icon-salaried" }, { name: "Self Employed", class: "icon-self-employed" }];
    var incClass_tmp = [{ name: "Proof ", class: "icon-proof" }, { name: "No Proof", class: "icon-no-proof" }];

    SALTYPE = LeadInfo.customerClass || 0;
    SALPRF = LeadInfo.incomeClass || 0;

    if (!LeadInfo.ProductFk || LeadInfo.ProductFk == "" || LeadInfo.ProductFk == "0") {
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("ProductChoosed", false);
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("class", LeadInfo.grpicon);
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("grpfk", LeadInfo.ProductGrpFk);
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("prdfk", "0");
        $(".category-icons").find("li:nth-child(1) p").text(LeadInfo.grpName);
        $(".category-icons").find("li:nth-child(1) p").attr("title", LeadInfo.grpName);
    }
    else {
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("ProductChoosed", true);
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("class", LeadInfo.prdicon);
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("grpfk", LeadInfo.ProductGrpFk);
        $(".category-info .category-icons.div-left li:nth-child(1) i").attr("prdfk", LeadInfo.ProductFk);
        $(".category-icons").find("li:nth-child(1) p").text(LeadInfo.ProductName);
        $(".category-icons").find("li:nth-child(1) p").attr("title", LeadInfo.ProductName);
    }

    GLOB_CREDIT.PRD_CD = LeadInfo.ProductCode;
    productCode = LeadInfo.ProductCode;
    if (LapArr.indexOf(productCode) >= 0) {
        $("#IIRorFOIR h5").text("IIR");
        $("#Fin_FOIR h5").text("IIR");
        $("#BT_Fin_FOIR h5").text("IIR");
    }
    $(".category-info .category-icons.div-left li:nth-child(2) i").attr("class", custClass_tmp[SALTYPE].class);
    $(".category-icons").find("li:nth-child(2) p").text(custClass_tmp[SALTYPE].name);

    $(".category-info .category-icons.div-left li:nth-child(3) i").attr("class", incClass_tmp[SALPRF].class);
    $(".category-icons").find("li:nth-child(3) p").text(incClass_tmp[SALPRF].name);
}

function fnSelectSummary() {
    GlobalXml[0].ApproverLvl = window.CREDIT_APPROVER_NO;
    var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["SELECT_SUMMARY", JSON.stringify(GlobalXml)] };
    fnCallLOSWebService("SELECT_SUMMARY", PrcObj, fnCreditOffResult, "MULTI");
    fnSelManualDev_ZC();
}


function fnBuildSummaryCard(data, AgentVerf) {
    var appendDiv = $(".applicant-summary");
    appendDiv.empty();
    var appendText = "";

    for (var i = 0; i < data.length; i++) {

        var custmrCLASS = data[i].customerClass;
        //custmrCLASS = custmrCLASS.toString() == "-1" ? 0 : custmrCLASS;
        var incmCLASS = data[i].incomeClass;
        //incmCLASS = incmCLASS.toString() == "-1" ? 0 : incmCLASS;

        appendText += '<div Actor="' + data[i].Actor + '" LapFk="' + data[i].AppFk + '" class="applicant-box box-div">' +
                        '<div>' +
                        '  <div onclick="fnOpenCreditScreen_DDE()"  class="applicant-info div-left cursor"> <img src="images/photo.jpg" alt="">' +
                        '          </div>' +
                        '         <div class="div-left applicant-income">' +
                        '          <div class="read-only">' +
                        '           <label>' + data[i].ApplicantType + '</label>' +
                        '          <p class="name">' + (custmrCLASS == -1 ? "-" : customerClass[custmrCLASS].name) + '</p>' +
                        '       </div>' +
                        '      <div onclick="fnOpenCreditScreen(event,this)" class="applicant-amount cursor">' +
                        '       <p class="income-amount"><i class="icon-indian-rupee"></i>' + FormatCurrency(data[i].income) + '</p>' +
                        '      <p class="liability-amount"><i class="icon-indian-rupee"></i>' + FormatCurrency(data[i].Obligation) + '</p>' +
                        '            </div>' +
                        '         </div>' +
                        '        <i class="' + (incmCLASS == -1 ? "" : incomeClass[incmCLASS].class) + ' div-right"></i>' +
                        '       <div class="clear"></div>' +
                        '    </div>' +
                        '   <p>' + data[i].ApplicantName + '</p>' +
                        '   <div>' +
                        '    <div class="cibil-score">' +
                        '            <h5>' + data[i].CIBILscore + '</h5>' +
                        '           <p>Cibil</p>' +
                        '        </div>' +
                        '       <div Actor="' + data[i].Actor + '" LapFk="' + data[i].AppFk + '"  class="applicant-verification"> ' +
                        '           <span key="age" name="AGE" class="bg-tag div-left">' + data[i].Age + '</span> ' +
                        '           <span key="EXP" name="EXP" class="bg-tag div-left" title="Experience">EXP</span> ' +
                        '           <span pk="0" name="PD" title="Personal Discussion" flag = "2" class="bc_link_feeback_credit bg-tag bg8 cursor">PD</span> ' +
                        '           <span name="FIR" title="Field Investigation - Residencial" class="bg-tag bg8 cursor"  onclick="fnAgentspopup(this);">FIR</span> ' +
                        '           <span name="FIO" title="Field Investigation - Office" class="bg-tag bg8 cursor" onclick="fnAgentspopup(this);" >FIO</span> ' +
                        '           <span name="DV" title="Document verification" class="bg-tag bg8 cursor" onclick="fnAgentspopup(this);">DV</span>' +
                        '           <span pk = "0" name="TER" title="Televerification - Residencial" flag = "3"  class="bc_link_feeback_credit bg-tag bg8 cursor" >TER</span>' +
                        '           <span pk = "0" name="TEO" title="Televerification - Office" flag = "1" class="bc_link_feeback_credit bg-tag bg8 cursor" >TEO</span>' +
                        '           <span name="CF" title="Collection FeedBack" class="bg-tag bg8 cursor" onclick="fnAgentspopup(this);" >CF</span>' +
                        '          </div>' +
                        '        <div class="clear"></div>' +
                        '     </div>' +
                        '  </div>';
    }
    appendText += '<div class="clear"></div>';
    appendDiv.append(appendText);

    // 0- negative 1 - neutral 2 - positive
    $(".applicant-summary .applicant-verification span, .credit-label-list span").click(function () {
        var clickedSatus;
        var attr = $(this).attr("name");
        if (attr == "LV" || attr == "TV") {
            clickedSatus = $(AGENT_VERF).filter(function () {
                return this.serv == attr;
            });
        }
        else {
            var LapFk = $(this).closest(".applicant-verification").attr("LapFk");
            clickedSatus = $(AGENT_VERF).filter(function () {
                return this.serv == attr && this.LapFk == LapFk;
            });
        }

        if (clickedSatus.length > 0) {
            var docPath = clickedSatus[0].DocPath;
            docPath = docPath ? docPath : "";
            if (docPath != "") {
                var dotIndex = docPath.lastIndexOf(".");
                if (dotIndex != -1) {
                    var filetype = docPath.substring(dotIndex + 1);
                    filetype = filetype.toLowerCase();
                    var downloadFileTypes = ["txt", "doc", "docx", "ppt", "xls", "xlsx"];
                    if (downloadFileTypes.indexOf(filetype) >= 0) {
                        var fileURL = SerLOSUrlDomain + docPath;
                        window.open(fileURL, "_blank");
                        return false;
                    }
                }
                localStorage.setItem("previewPath", docPath);
                $("#div-document-content").empty();
                $("#div-document-content").show();
                $(".content-div").addClass("center-collapse");
                $("#div-document-content").load("documents.html", function () { });
            }
        }
    });

    if (AgentVerf && AgentVerf.length > 0) {
        $(".applicant-summary .applicant-verification span").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
        $(".applicant-summary .applicant-verification span").addClass("bg8");
        $(".credit-label-list span").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
        $(".credit-label-list span").addClass("bg8");
        var StsRejTV = "";
        var StsPendingTV = "";
        var StsRejLV = "";
        var StsPendingLV = "";
        for (var i = 0; i < AgentVerf.length; i++) {
            var LapFk = AgentVerf[i].LapFk;
            var Key = AgentVerf[i].serv;
            var status = AgentVerf[i].Status;
            if (Key == "TV") {
                var span = $(".credit-label-list span[name='" + Key + "']");
                $(span).removeClass("bg8");
                if (status == "0" || status == 0) {StsRejTV = "R"}
                if (status == "1" || status == 1) {StsPendingTV = "P"}
                if (status == "2" || status == 2) {}
                if (StsRejTV == "R") { $(span).removeClass("bg1 bg2 bg3"); $(span).addClass("bg2"); }
                if (StsPendingTV == "P" && StsRejTV == "") { $(span).removeClass("bg1 bg2 bg3"); $(span).addClass("bg3"); }
                if (StsRejTV == "" && StsPendingTV == "") { $(span).removeClass("bg1 bg2 bg3"); $(span).addClass("bg1"); }
            }
            else if (Key == "LV") {
                var span = $(".credit-label-list span[name='" + Key + "']");
                $(span).removeClass("bg8");
                if (status == "0" || status == 0) {StsRejLV = "R" }
                if (status == "1" || status == 1) {StsPendingLV = "P" }
                if (status == "2" || status == 2) {}
                if (StsRejLV == "R") { $(span).removeClass("bg1 bg2 bg3"); $(span).addClass("bg2"); }
                if (StsPendingLV == "P" && StsRejLV == "") { $(span).removeClass("bg1 bg2 bg3"); $(span).addClass("bg3"); }
                if (StsRejLV == "" && StsPendingLV == "") { $(span).removeClass("bg1 bg2 bg3"); $(span).addClass("bg1"); }
            }
               
            else {
                if (LapFk == 0 || LapFk == "0") {

                }
                else {
                    var SummaryDiv = $(".applicant-summary").find(".applicant-box[LapFk='" + LapFk + "']");
                    var span = $(SummaryDiv).find(".applicant-verification span[name='" + Key + "']");
                    $(span).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                    if (status == "0" || status == 0) { $(span).addClass("bg2"); }
                    if (status == "1" || status == 1) { $(span).addClass("bg3"); }
                    if (status == "2" || status == 2) { $(span).addClass("bg1"); }
                }
            }
        }


    }
}

function fnOpenDoc(elem) {
    $("#div-document-content").show();
    $(".content-div").addClass("center-collapse");
    $("#div-document-content").load("documents.html", function () {
    });
}

function fnCallScrnFn(isMoveNext, param) {
    
    ISMOVENXT = isMoveNext;

    if (ProductDiv == "HL")
        fnCreditandSanctionEntry(ISMOVENXT, param);
    else
        fnCreditandSanctionEntry_BT(ISMOVENXT, param);
}

function fnCreditOffResult(ServiceFor, Obj, Param1, Param2) {
    if (!Obj.status)
    { fnShflAlert("error", Obj.error); return; }

    if (ServiceFor == "ADD_MANUALDEV") { }

    if (ServiceFor == "MANUALDEV_DATA") {
        var DevList = JSON.parse(Obj.result_1);
        var SelectedList = JSON.parse(Obj.result_2);
        fnSetDeviationData('DeviationDataDiv_ZC', DevList, SelectedList);
    }

    if (ServiceFor == "DEVIATION_DATA") {
        var DevData = JSON.parse(Obj.result);
        DevData = DevData ? DevData : [];
        window.DevAppData = DevData;
        fnLOSDeviation("INIT");
        // Disable All Inputs for approver
        fnDisableAllInputs();
    }

    if (ServiceFor == "DEVIATION_LIST") {
        var DevList = JSON.parse(Obj.result_1);
        var MaxAprv = JSON.parse(Obj.result_2);
        var Notes = JSON.parse(Obj.result_3);
        if (!DevList || DevList.length == 0) {
            fnShflAlert("error", "Deviation List not arrived for this Lead.");
            return;
        }
        $("#credit-popup .popup-content").empty();
        $("#credit-popup").show();
        var maxApp = 1;
        if (MaxAprv && MaxAprv.length > 0)
            maxApp = MaxAprv[0].MaxApproverLevel;
        $("#credit-popup .popup-content").append("<h2 style='font-size:12px;'>Final Approval Level : Level " + maxApp + "</h2><br>");

        var devTbl = "<table style='text-align: left;' border='0'> <tr><th>Stage</th><th>Deviation Factor</th><th>ApplicableTo</th><th>Status</th><th>Arrived</th><th>Deviation</th><th>Base</th>" +
            "<th>Approval Level</th><th>Remarks</th></tr>";
        for (var i = 0; i < DevList.length; i++) {
            devTbl += "<tr " + (DevList[i].status == "D" ? "style='color:red;'" : "") + " ><td>" + DevList[i].stage + "</td><td>" + DevList[i].AttrDesc + "</td><td>" + DevList[i].ApplicableTo + "</td><td>" + (DevList[i].status == "N" ? "No Deviation" : "Deviated") + "</td>" +
                "<td>" + DevList[i].Arrived + "</td><td>" + DevList[i].Deviated + "</td><td>" + DevList[i].baseval + "</td><td>Level " + DevList[i].approvedBy + "</td><td>" + DevList[i].remarks + "</td></tr>";
        }
        devTbl += "</table>";

        devTbl = $(devTbl);
        $(devTbl).find("td").css({ "padding": "5px 0px" });
        $("#credit-popup .popup-content").append(devTbl);

        var appUsr = [
        { level: 1, user: 'ZCA' },
        { level: 2, user: 'HO' },
        { level: 3, user: 'HCO' },
        { level: 4, user: 'COO' },
        { level: 5, user: 'MD' },
        ];
        var usrlist = "<table style='margin-top:50px;text-align: left;' border='0'> <tr><th>Level</th><th>Approver</th></tr>";
        for (var j = 0; j < maxApp; j++) {
            usrlist += "<tr><td>" + appUsr[j].level + "</td><td>" + appUsr[j].user + "</td></tr>";
        }
        usrlist += "</table>";

        usrlist = $(usrlist);
        $(usrlist).find("td").css({ "padding": "5px 0px" });
        $("#credit-popup .popup-content").append(usrlist);
    }

    if (ServiceFor == "CHECK_SANCTION") {
        var data = JSON.parse(Obj.result_1);
        var CAMdata = JSON.parse(Obj.result_2);
        var RSKdata = JSON.parse(Obj.result_3);
        if (Param2 == "SANC") {

            if (!data || data.length == 0) {
                fnShflAlert("error", "Sanction Not yet Generated!");
                return;
            }
            for (var i = 0; i < data.length; i++) {
                fnGenerateReport("SANC", data[i].sancNo);
            }
        }
        else if (Param2 == "CAM") {
            if (!CAMdata || CAMdata.length == 0) {
                fnShflAlert("error", "CAM Not yet Generated!");
                return;
            }

            if (productCode == "HLBTTopup" || productCode == 'LAPBTTopup') {
                // CAM for BT
                fnGenerateReport("CAM", 0);
                // CAM for TOPUP
                setTimeout(function () {
                    fnGenerateReport("CAM", 1);
                }, 200);

            } else {
                fnGenerateReport("CAM", "");
            }
            fnGenerateReport("RISK", "");
        }
    }

    if (ServiceFor == "CMP_CONFIG_POLICY") {
        var data = JSON.parse(Obj.result);
        if (data != null && data.length != 0) {
            gConfig["gIMC"] = data[0].ConfigVal;
        }
    }

    if (ServiceFor == "INSERT_CREDIT") {
        var data = JSON.parse(Obj.result_1);
        if (!data || data.length == 0) {
            fnShflAlert("error", "Error Occured");
            return;
        }
        var ResultCount = Obj.ResultCount;
        var Sancdata = JSON.parse(Obj["result_1"]);
        var MaxApprNo = JSON.parse(Obj["result_2"]);
        if (MaxApprNo && MaxApprNo.length > 0)
            MaxApproverLevel = MaxApprNo[0].ApproverLevel;
        if (Sancdata && Sancdata.length > 0 && Sancdata[0].SanctionPk) {
            if (CREDIT_APPROVER_NO == 2 || CREDIT_APPROVER_NO == 4)
                GlobalXml[0].DpdFk = Sancdata[0].SanctionPk;
        }

        if (ISMOVENXT != "") {
            if (ISMOVENXT == "true" || ISMOVENXT == true && CREDIT_APPROVER_NO == 1 || CREDIT_APPROVER_NO == 3)
            {
                
                var pfPaid = 0;
                
                if (ProductDiv == "HL") 
                    pfPaid = Number(FormatCleanComma($("#Fin_PF_REC [key=textval]").justtext()));
                else
                    pfPaid = Number(FormatCleanComma($("#BT_Fin_PF_REC [key=textval]").justtext()));
                // PF amount
                if (pfPaid < gConfig["gIMC"] || crtPFClrdAmt < gConfig["gIMC"]) {            
                    fnShflAlert("error", "Collected PF is less than the minimum collection amount.. Cannot Handover!");
                    return;
                }                                
            }
            if ((CREDIT_APPROVER_NO == 2 || CREDIT_APPROVER_NO == 4) && MaxApproverLevel && MaxApproverLevel != ApproverLevel && MaxApproverLevel != 0) {
                fnCallFinalConfirmation(ISMOVENXT, 'C');
            }
            else {
                if (ISMOVENXT == "true" || ISMOVENXT == true)
                    fnApproveDeviations();
                fnCallFinalConfirmation(ISMOVENXT);
            }
        }
    }

    if (ServiceFor == "SELECT_QUERY") {
        var Header = JSON.parse(Obj.result_1);
        var Details = JSON.parse(Obj.result_2);
        window.GLOB_QRY_DTL = Details;
        var QryDiv = $(".credit-query-div .notes-list");
        QryDiv.empty();
        var qry = "";
        for (var i = 0; i < Header.length; i++) {
            var solved = Header[i].solution;
            var SolvedClass = "";
            var solvedtext = "";
            var bg = "";
            if (solved == "0") {
                SolvedClass = "icon-pending";
                solvedtext = "Pending";
                bg = "bg3";
            }
            else if (solved == "1") {
                SolvedClass = "icon-positive";
                solvedtext = "Resolved";
                bg = "bg1";
            }
            else if (solved == "2") {
                SolvedClass = "icon-negative";
                solvedtext = "not ok";
                bg = "bg2";
            }
            else {
                SolvedClass = "icon-pending";
                solvedtext = "Pending";
                bg = "bg3";
            }

            qry += '<li class="QryListLI" style="cursor:pointer;" qryPk="' + Header[i].hdrpk + '">' +
                    '    <div class="div-left">' +
                    '    <img src="images/user.png">' +
                    '    <p><span style="white-space:nowrap;" class="bg-tag bg-blue">' + Header[i].userName + '</span></p>' +
                    '    </div>' +
                    '    <div class="div-right">' +
                    '    <div class="notes-info"><span class="bg-tag ' + bg + '"><i class="' + SolvedClass + '"></i> ' + solvedtext + '</span></div>' +
                    '    <div style="padding: 0 50px;">' +
                    '    <p><span class="bg-tag bg8">' + Header[i].category + '</span></p>' +
                    '    <p>' + Header[i].date + '</p>' +
                    //'    <p>' + Header[i].category + '</p>' +
                    '    </div>' +
                    '    </div>' +
                    '    <div class="clear"></div>' +
                    '<div class="QryList">' +
                    '</div>' +
                    '    <div class="clear"></div>' +
                    '    </li>';
        }
        QryDiv.append(qry);

        $(QryDiv).find(".QryListLI").click(function () {
            if ($(this).find(".QryList p").length > 0)
            { $(this).find(".QryList").empty(); }
            else {
                var QryHdrPk = $(this).attr("qryPk");
                $(this).find(".QryList").empty();
                for (var i = 0; i < GLOB_QRY_DTL.length; i++) {
                    if (GLOB_QRY_DTL[i].hdrpk == QryHdrPk) {
                        $(this).find(".QryList").append("<p>" + GLOB_QRY_DTL[i].usr + " : " + GLOB_QRY_DTL[i].msg + "</p>");
                    }
                }
            }
        });
    }

    if (ServiceFor == "ADD_NOTES") {
        var Result = JSON.parse(Obj.result);
        if (!Result || Result.length == 0)
            return;
        fnSelectNotes();
        $("#subjective-div").hide();
    }
    if (ServiceFor == "SELECT_NOTES") {
        var Result = JSON.parse(Obj.result);
        var notesdiv = $(".notes-div .notes-list");
        notesdiv.empty();
        if (!Result && Result.length == 0)
            return;
        var notes = "";
        for (var i = 0; i < Result.length; i++) {
            notes += '<li NotesPk="' + Result[i].NotesPk + '">' +
                    '     <div class="div-left">' +
                    '        <img src="images/user.png">' +
                    '<p><span class="bg-tag bg1">' + Result[i].UserName + '</span></p>' +
                    '                                </div>' +
                    '                               <div class="div-right">' +
                    '                                  <div class="notes-info"><i onclick="fnEditNotes(' + Result[i].NotesPk + ',this,' + Result[i].UserPk + ')" class="icon-edit cursor"></i></div>' +
                    '                                 <p><span class="bg-tag bg8">' + Result[i].AttrCode + '</span></p>' +
                    '                                <p>' + Result[i].DTime + '</p>' +
                    '                               <p class="notes">' + Result[i].Notes + '</p>' +
                    '                          </div>' +
                    '<div class="clear"></div>' +
                    '</li>';
        }
        $(notesdiv).append(notes);
    }

    if (ServiceFor == "SELECT_SUMMARY") {
        var Appdata = JSON.parse(Obj.result_1);
        var CreditData = JSON.parse(Obj.result_2);
        var ExpData = JSON.parse(Obj.result_3);
        var LeadSummary = JSON.parse(Obj.result_4);
        var LoanData = JSON.parse(Obj.result_5);
        var PfData = JSON.parse(Obj.result_6);
        var AgtData = JSON.parse(Obj.result_7);
        var PFWaiver = JSON.parse(Obj.result_8);
        var sancNo = JSON.parse(Obj.result_9);
        var recommenedData = JSON.parse(Obj.result_10);
        var SubjectiveData = JSON.parse(Obj.result_11);
        var InputParams = JSON.parse(Obj.result_12);
        var PreviousRecommened = JSON.parse(Obj.result_13);
        var LoanNo = JSON.parse(Obj.result_14);
        var ExistingLoan = JSON.parse(Obj.result_15);
        var MaxApprvr = JSON.parse(Obj.result_16);
        var ManualDev = JSON.parse(Obj.result_17);
        var WaiverROI = JSON.parse(Obj.result_18);        

        if (ManualDev.length > 0) {
            $("#ManualDeviationLevel").val(ManualDev[0].Level).trigger("change");
            $("#ManualDeviationRmks").val(ManualDev[0].Remarks);
        }
        if (MaxApprvr && MaxApprvr.length > 0)
            MaxApproverLevel = MaxApprvr[0].ApproverLevel;
        var iscalled = false;

        GLOB_APP = Appdata;
        IsPNI = Appdata[0].IsPNI;

        fnSetProductVariations(ExistingLoan);
        if (LeadSummary && LeadSummary.length > 0) {
            fnSetLeadInfo(LeadSummary[0]);            
        }

        // APPLICANTS SUMMARY
        AGENT_VERF = AgtData;
        if (Appdata && Appdata.length > 0)
        { fnBuildSummaryCard(Appdata, AgtData); }
        else
        { alert("No Applicants found"); }

        // SAVED CREDIT DATA
        if (CreditData && CreditData.length > 0) {
            GlobalXml[0].CreditPk = CreditData[0].CreditPk;
            //fnSETArrLoanData_BT(LoanData, InputParams, PreviousRecommened);            
            if (ProductDiv == "HL")
                fnSetCreditInfo(CreditData);
            else
                fnSetCreditInfo_BT(CreditData);

        }

        // SAVED INPUT PARAMS FOR CREDIT
        if (InputParams && InputParams.length > 0) {
            fnSetCreditInputParams(InputParams);
        } else {
            if (PreviousRecommened && PreviousRecommened.length > 0)
                fnSetCreditInputParams(PreviousRecommened);
            else {
                // TO SET ARRIVED DATA IF PERVIOUS APPROVER DATA NOT EXISTS                
                fnSETArrLoanData(LoanData, [4], [4]);
            }
        }
        
        if (PfData && PfData.length > 0) {
            var pfrec = Number(PfData[0].PfAmount).toFixed(2);
            pfrec = FormatCurrency(pfrec);
            var pfrecId = ProductDiv == "HL" ? "Fin_PF_REC" : "BT_Fin_PF_REC";
            $("#" + pfrecId + " [key=textval]").html("<i class='icon-indian-rupee'></i>" + pfrec);
        }
        else {
            var pfrecId = ProductDiv == "HL" ? "Fin_PF_REC" : "BT_Fin_PF_REC";
            $("#" + pfrecId + " [key=textval]").html("<i class='icon-indian-rupee'></i> 0 ");
        }
       
        // Recommended DaTA
        if (recommenedData && recommenedData.length) {
            var rec_div = $(".recommended-sum.div-left");
            var rupeeicon = "<i class='icon-indian-rupee'></i> ";

            var LoanAmt = (ProductDiv == "HL" || CREDIT_APPROVER_NO == 1) ? rupeeicon + FormatCurrency(recommenedData[0].LOAN_AMT) :
                "BT " + rupeeicon + FormatCurrency(recommenedData[0].BT_AMT) + "</br>" + "TOPUP " + rupeeicon + FormatCurrency(recommenedData[0].TOPUP_AMT);
            var Roi = (ProductDiv == "HL" || CREDIT_APPROVER_NO == 1) ? rupeeicon + recommenedData[0].ROI :
                "BT " + rupeeicon + recommenedData[0].BT_ROI + "</br>" + "TOPUP " + rupeeicon + recommenedData[0].TOPUP_ROI;
            
            var emi = (ProductDiv == "HL" || CREDIT_APPROVER_NO == 1) ? rupeeicon + FormatCurrency(recommenedData[0].EMI) :
                "BT " + rupeeicon + FormatCurrency(recommenedData[0].BT_EMI) + "</br>" + "TOPUP " + rupeeicon + FormatCurrency(recommenedData[0].TOPUP_EMI);

            $(rec_div).find("#LoanDiv [key=textval]").html(LoanAmt);
            $(rec_div).find("#ROIdiv [key=textval]").html(Roi);
            $(rec_div).find("#EMIdiv [key=textval]").html(emi);
            
            if (ProductDiv != "HL" && CREDIT_APPROVER_NO != 1)
                $(rec_div).find("[key=textval]").css("font-size", "12px");
        }

        // EXPECTED DATA
        if (ExpData && ExpData.length > 0) {
            fnSetExpectedValues(ExpData);
        }

        // ARRIVED LOAN DATA
        if (LoanData && LoanData.length > 0) {
            fnSETArrLoanData(LoanData, InputParams, PreviousRecommened);
        }

        if (sancNo && sancNo.length > 0) {
            if ($("#txtCrSancNo").length > 0)
                $("#txtCrSancNo").text(sancNo[0].SancNo);
        }
        if (LoanNo && LoanNo.length > 0) {
            if ($("#LoanNo").length > 0)
                $("#LoanNo").text(LoanNo[0].LoanNo);
        }
        $(".subjective-div ul.sub-notes").empty();
        if (SubjectiveData && SubjectiveData.length > 0) {            
            if ($(".subjective-div").length > 0) {
                for (var i = 0; i < SubjectiveData.length; i++) {
                    var notes = '<li class="subjective-li" pk="' + SubjectiveData[i].Spk + '">' +
                  '    <div class="div-left">' +
                  '    <p class="date" style="display:none;">' + SubjectiveData[i].DTime + '</p>' +
                  '    <p class="notes">' + SubjectiveData[i].Snote + '</p>' +
                  '    </div>' +
                  '  <div class="div-right">' +
                  '  <i class="icon-edit cursor" onclick="fnEditNotes(0,this)"></i>' +
                  '  <i class="icon-delete cursor" onclick="fnDeleteSubj(this)"></i>' +
                  '  </div>' +
                  '<div class="clear"></div>' +
                  '</li>';

                    $(".subjective-div ul.sub-notes").append(notes);
                }
            }
        }        
        // PF WAIVER VALUES
        SetPfWaiver(PFWaiver);
     
        var waiverOnROI = 0;
        if (WaiverROI && WaiverROI.length > 0)
            waiverOnROI = WaiverROI[0].waiverROI;

        if (productCode == "HLBTTopup" || productCode == "LAPBTTopup") {
            $("#ElgTenure h5").text("BT Tenure");
            $("#ElgTenure_TOP").show();
            waiverOnROI = Number(waiverOnROI);
            $("#BT_Fin_ROI .hover-div").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
            var bg = waiverOnROI >= 0 ? "bg1" : "bg2";
            $("#BT_Fin_ROI .hover-div").addClass(bg);

            $("#RoiWaiver_BT").attr("val", waiverOnROI);
            $("#RoiWaiver_BT").val(waiverOnROI)

            var slider = $("#BT_Fin_ROI").find(".roi-adjust").data("ionRangeSlider");
            if (slider)
                slider.update({
                    min: -3,
                    max: 3,
                    from: waiverOnROI,
                    step: 0.25,
                    onChange: function (data) {
                        fnChangeRoiAdjust(data, "C")
                    },
                    onUpdate: function (data) {
                        fnChangeRoiAdjust(data, "U")
                    }
                });

        } else {
            $("#RoiWaiver").attr("val", waiverOnROI);
            $("#RoiWaiver").val(waiverOnROI);
            var slider = $("#Fin_ROI").find(".roi-adjust").data("ionRangeSlider");
            waiverOnROI = Number(waiverOnROI);
            $("#Fin_ROI .hover-div").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
            var bg = waiverOnROI >= 0 ? "bg1" : "bg2";
            $("#Fin_ROI .hover-div").addClass(bg);
            if (slider)
                slider.update({
                    min: -3,
                    max: 3,
                    from: waiverOnROI,
                    step: 0.25,
                    onChange: function (data) {
                        fnChangeRoiAdjust(data, "C")
                    },
                    onUpdate: function (data) {
                        fnChangeRoiAdjust(data, "U")
                    }
                });
        }

        var PrcObj = { ProcedureName: "PrcShflgetDeviationData", Type: "SP", Parameters: [GlobalXml[0].FwdDataPk] };
        fnCallLOSWebService("DEVIATION_DATA", PrcObj, fnCreditOffResult, "MULTI");
        fnSelectPFDetails();
        fnSelectRemPF();
       
    }

    /*Changes By Kani On 20/12/2016*/

    if (ServiceFor == "SELECT_FB_POP") {
        
        var teledata = JSON.parse(Obj.result_1);
        var pddata = JSON.parse(Obj.result_2);
        var TeleData_Ph = JSON.parse(Obj.result_3);
        var type = Param2;
        var tmpType = type == 1 ? 2 : 1;

        var tmpTeledata = $(teledata).filter(function () {
            return this.type == tmpType;
        });

        fnSelectFB_POP_ZCPI(type, tmpTeledata, pddata, TeleData_Ph);
    }
    /*Changes end By Kani On 20/12/2016*/
    if (ServiceFor == "TAX") {
        
        var TAXdata = JSON.parse(Obj.result_1);
        var TAX_Instdata = JSON.parse(Obj.result_2);
        var PF_Clrddata = JSON.parse(Obj.result_3);
        if (PF_Clrddata && PF_Clrddata.length > 0) {
            crtPFClrdAmt = PF_Clrddata[0].totclrdPF;
        }        
        var tr = '';
        var pfrecId = ProductDiv == "HL" ? "Fin_PF_REC" : "BT_Fin_PF_REC";
        var pfFinId = ProductDiv == "HL" ? "Fin_PF" : "BT_Fin_PF";
        tr = '<tr><th>Charge Name</th><th>Percentage(%)</th><th>Amount</th></tr>';
        for (var i = 0; i < TAXdata.length; i++) {
            tr += '<tr><td>' + TAXdata[i].CompNm + '</td><td>' + TAXdata[i].Per + '</td><td>' + TAXdata[i].TaxAmt + '</td></tr>';            
        }
        $("#taxpf").empty();
        $("#taxpf").append(tr);

        var trIns = '';
        trIns = '<tr><th>Instrument No</th><th>Instrument Date</th><th>Instrument Amount</th><th>Deposited Date</th><th>Deposited Bank</th><th>BRS Status</th></tr>';

        $("#" + pfrecId).removeClass("bg1 bg2 bg8");        
        for (var i = 0; i < TAX_Instdata.length; i++) {
            
            trIns += '<tr><td>' + TAX_Instdata[i].LpcInstrNo + '</td><td>' + TAX_Instdata[i].LpcInstrDt + '</td><td>' + TAX_Instdata[i].LpcInstrAmt + '</td><td>' + TAX_Instdata[i].LpcInstrdepoDt + '</td><td>' + TAX_Instdata[i].BankNm + '</td><td>' + TAX_Instdata[i].Chq_sts + '</td></tr>';
        }
        if (crtPFClrdAmt < gConfig["gIMC"]) {
            $("#" + pfrecId).addClass("bg2");
        }
        else {
            $("#" + pfrecId).addClass("bg1");
        }
        $("#taxpf_inst").empty();
        $("#taxpf_inst").append(trIns);
        $(".totPF, .PFinst").show();
        $(".RemPF").hide();
    }
    if (ServiceFor == "RemPF") {
        
        var RemPFdata = JSON.parse(Obj.result);
        var finalVal = 0;
        if (RemPFdata && RemPFdata.length > 0) {            
        var tr = '';
        tr = '<tr><th>Charge Name</th><th>Percentage(%)</th><th>Amount</th></tr>';
        for (var i = 0; i < RemPFdata.length; i++) {
            tr += '<tr><td>' + RemPFdata[i].CompNm + '</td><td>' + RemPFdata[i].CompPer + '</td><td>' + RemPFdata[i].RemPF + '</td></tr>';
            if (RemPFdata[i].CompCd == "PFVAL") { finalVal = RemPFdata[i].RemPF; }
        }
        $("#Remainingpf").empty();
        $("#Remainingpf").append(tr);   
        var pfrecId = ProductDiv == "HL" ? "Fin_REM_PF_REC" : "BT_Fin_REM_PF_REC";
        $("#" + pfrecId + " [key=textval]").html("<i class='icon-indian-rupee'></i>" + FormatCurrency(finalVal));
    }
        else {
        var pfrecId = ProductDiv == "HL" ? "Fin_REM_PF_REC" : "BT_Fin_REM_PF_REC";
        $("#" + pfrecId + " [key=textval]").html("<i class='icon-indian-rupee'></i> 0 ");
        }
        //fnSelectPFDetails();
}

}



function SetPfWaiver(PFWaiver) {

    var wvrID = ProductDiv == "HL" ? "waiveramt" : "BT_waiveramt";
    var Pfid = ProductDiv == "HL" ? "Fin_PF" : "BT_Fin_PF";

    if (PFWaiver && PFWaiver.length > 0) {
        var pfperc = PFWaiver[0].perc || 1.5;
        $("#" + wvrID + "").val(FormatCurrency(PFWaiver[0].waiveramt));
        $("#" + Pfid + " [key=textval]").html("<i class='icon-indian-rupee'></i> " + FormatCurrency(PFWaiver[0].PfAmount));
        var slider = $("#" + Pfid + " [key=rangeval]").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 0,
                max: 2,
                from: pfperc,
                step: 0.5,
                onChange: fnOnchange,
                //onUpdate: fnOnchange,
                onFinish: function () {
                    fnSelectRemPF();
                }
            });
    }
    else {
        var slider = $("#" + Pfid + " [key=rangeval]").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 0,
                max: 2,
                from: 1.5,
                step: 0.5,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });
    }
  
}


function fnCreditComment() {
    //box - sum
    var comment = $("#Crd_Comment").val().trim();
    if (comment == "")
        return;
    if (Credit_Atr == "SUBJECTIVE") {        
        if (Credit_Elem != "") {
            $(Credit_Elem).text(comment);
        } else {
            var notes = '<li class="subjective-li">' +
                       '    <div class="div-left">' +
                       '    <p class="date" style="display:none;">' + new Date().toLocaleString() + '</p>' +
                       '    <p class="notes" >' + comment + '</p>' +
                       '    </div>' +
                       '  <div class="div-right">' +
                      '  <i class="icon-edit cursor" onclick="fnEditNotes(0,this)"></i>' +
                      '  <i class="icon-delete cursor" onclick="fnDeleteSubj(this)"></i>' +
                      '  </div>' +
                       '<div class="clear"></div>' +
                       '</li>';
            $(".subjective-div .sub-notes").append(notes);            
        }
        $("#subjective-div").hide();        
    }
    else {
        var commentOBJ = { Attr: (Credit_Atr == "EDIT" ?  editNotesPK : Credit_Atr), LnaFk: 0, Notes: comment };
        var DetailsJson = [{ NotesJson: JSON.stringify(commentOBJ) }];
        var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: [(Credit_Atr == "EDIT" ? "EDIT_NOTES" : "ADD_NOTES"), JSON.stringify(GlobalXml), JSON.stringify(DetailsJson)] };
        fnCallLOSWebService("ADD_NOTES", PrcObj, fnCreditOffResult, "MULTI");
    }
    Credit_Atr = "";
    Credit_Elem = "";
}


function fnSelectNotes() {
    var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["SELECT_NOTES", JSON.stringify(GlobalXml)] };
    fnCallLOSWebService("SELECT_NOTES", PrcObj, fnCreditOffResult, "MULTI");
}


function fnSelectQuery() {
    var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["SELECT_QUERY", JSON.stringify(GlobalXml)] };
    fnCallWebService("SELECT_QUERY", PrcObj, fnCreditOffResult, "MULTI");
}


function fnAgentVerfDeviation(AgentData) {
    var VerfData = AgentData;
    var ofcsts;
    var Percsts;
    for (var i = 0; i < VerfData.length; i++) {
        var serv = VerfData[i].serv;
        var LapFk = VerfData[i].LapFk;
        var Status = VerfData[i].Status;
        var dvCls = Status == 0 ? statusList["N"].class : Status == 1 ? statusList["M"].class : statusList["P"].class;
        var ActiveDiv;
        if (serv == "PD") {

        }
        if (serv == "FIO") { }
        if (serv == "FIR") { }
        if (serv == "DV") { }
        if (serv == "CF") { }
        if (serv == "LV") { }
        if (serv == "TV") { }
        if (serv == "TE") { }
        $(ActiveDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
        $(ActiveDiv).addClass(dvCls);
    }
}




function fnInputChanged_BT(OBJ) {
    var LoanAmt = OBJ.LOAN_AMT;
    var LoanAmt_L = OBJ.LOAN_AMT;
    LoanAmt_L = Math.round(LoanAmt_L.toFixed(2));
    var BT_Amt = FormatCleanComma($("#BT_amt [key='textval']").justtext());
    var BT_LoanAmt_L = BT_Amt;
    var TOP_LoanAmt_L = LoanAmt_L - BT_Amt;
    if (LoanAmt_L < BT_Amt) {
        BT_LoanAmt_L = LoanAmt_L;
        TOP_LoanAmt_L = 0;
    }
    $("#TOP_Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(TOP_LoanAmt_L) + '');
    $("#BT_amt [key='textval']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(BT_LoanAmt_L) + '');

    var EMI = Math.round((OBJ.TOPUP_EMI || 0 ).toFixed(2))
    EMI = FormatCurrency(EMI);
    $("#TOP_Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i>' + EMI + '');
    var M_LTV = OBJ.LTV_M;
    var A_LTV = OBJ.LTV_A;
    var waiverROI = Number($("#RoiWaiver_BT").attr("val")) || 0;
    $("#BT_Fin_LTV [key='textval']").html(M_LTV.toFixed(2) + '<span class="percentage"></span>');
    $("#BT_Fin_LTV_A [key='textval']").html(A_LTV.toFixed(2) + '<span class="percentage"></span>');
    $("#BT_Fin_ROI [key='textval']").html(OBJ.ROI + '<span class="percentage"></span>');
    var waiverBTROI = $("#RoiWaiver_BT").attr("val");
    $("#BT_Fin_ROI .arrived-roi").text(Number(OBJ.ROI) + Number(waiverBTROI));


    $("#TOP_Fin_ROI [key='textval']").html((Number(OBJ.ROI + waiverROI) + 1) + ' <span class="percentage"></span>');
    var IIR_FOIR;
    if (isLapProduct)
        IIR_FOIR = OBJ.IIR;
    else
        IIR_FOIR = OBJ.FOIR;
    $("#BT_Fin_FOIR [key='textval']").html(IIR_FOIR.toFixed(2) + '<span class="percentage"></span>');

    setTimeout(function () {
        $("#BT_TxtFin_GI").focusout();
        $("#BT_TxtFin_LI").focusout();
        $("#TOP_TxtFin_GI").focusout();
        $("#TOP_TxtFin_LI").focusout();
    }, 300);

    var lnval = Number(FormatCleanComma($("#TOP_Fin_LOAN [key=textval]").justtext()));
    lnval = lnval + Number(FormatCleanComma($("#BT_amt [key=textval]").justtext()));
    var dataPerc = $("#BT_Fin_PF [key=rangeval]").val();
    lnval = lnval * dataPerc / 100;
    lnval = Math.round(lnval);
    lnval = FormatCurrency(lnval);
    $("#BT_Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);

    var Irate = Number($("#BT_Fin_ROI [key='textval']").justtext());
    var tenure = Number($("#ElgTenure [key='textval'] .value").justtext());
    var totAmt = Number(FormatCleanComma($("#BT_amt [key='textval']").justtext()));
    var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
    EmiVal = OBJ.BT_EMI || 0;
    $("#BT_Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal) + '');

    $("#BT_LTV_A [key='textval']").html(OBJ.BT_LTV_A.toFixed(2) + '<span class="percentage"></span>');
    $("#TOPUP_LTV_A [key='textval']").html(OBJ.TOPUP_LTV_A.toFixed(2) + '<span class="percentage"></span>');

    $("#BT_LTV_M [key='textval']").html(OBJ.BT_LTV_M.toFixed(2) + '<span class="percentage"></span>');
    $("#TOPUP_LTV_M [key='textval']").html(OBJ.TOPUP_LTV_M.toFixed(2) + '<span class="percentage"></span>');

    GLOB_CREDIT.LTV = OBJ.LTV_PERC_A;
    GLOB_CREDIT.FOIR = IIR_FOIR;
    GLOB_CREDIT.TENURE = OBJ.TENURE;
    //TOPUP TENURE CALC
    fnChangeTopupTENURE();      
}

function fnInputChanged(OBJ) {
    var LoanAmt = OBJ.LOAN_AMT;
    //var LoanAmt_L = OBJ.LOAN_AMT / 100000.00;

    if (productCode == 'HLTopup' || productCode == 'LAPTopup') {
        var LoanAmt_L = OBJ.ARR_TOPUP_AMT;
        LoanAmt_L = Math.round(LoanAmt_L.toFixed(2));
        LoanAmt_L = FormatCurrency(LoanAmt_L);
        $("#Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i>' + LoanAmt_L + '');
    } else {
        var LoanAmt_L = OBJ.LOAN_AMT;
        LoanAmt_L = Math.round(LoanAmt_L.toFixed(2));
        LoanAmt_L = FormatCurrency(LoanAmt_L);
        $("#Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i>' + LoanAmt_L + '');
    }

    var EMI = Math.round(OBJ.EMI.toFixed(2))
    EMI = FormatCurrency(EMI);
    $("#Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i>' + EMI + '');
    var M_LTV = OBJ.LTV_M;
    var A_LTV = OBJ.LTV_A;
    $("#Fin_LTV [key='textval']").html(M_LTV.toFixed(2) + '<span class="percentage"></span>');
    $("#Fin_LTV_A [key='textval']").html(A_LTV.toFixed(2) + '<span class="percentage"></span>');
    var waiverROI = Number($("#RoiWaiver").attr("val")) || 0;
    $("#Fin_ROI [key='textval']").html(OBJ.ROI + '<span class="percentage"></span>');
    var waiverROI = $("#RoiWaiver").attr("val");
    $("#Fin_ROI .arrived-roi").text(Number(OBJ.ROI) + Number(waiverROI));
    var IIR_FOIR;
    if (isLapProduct)
        IIR_FOIR = OBJ.IIR;
    else
        IIR_FOIR = OBJ.FOIR;
    $("#Fin_FOIR [key='textval']").html(IIR_FOIR.toFixed(2) + '<span class="percentage"></span>');

    if (productCode == "HLExt" || productCode == "HLImp" || productCode == "HLTopup") {
        $("#TOPUP_Fin_LTV_A [key='textval']").html((OBJ.TOPUP_LTV_A || 0).toFixed(2) + ' <span class="percentage"></span>');
        $("#TOPUP_Fin_LTV_M [key='textval']").html((OBJ.TOPUP_LTV_M || 0).toFixed(2) + ' <span class="percentage"></span>');
    }

    if (productCode == "HLTopup" || productCode == "LAPTopup" || productCode == "HLExt" || productCode == "HLImp") {
        if (productCode == "HLExt" || productCode == "HLImp") {
            $("#TOPUP_Fin_LTV_A h5").html("Ext/Imp LTV (Agreement)");
            $("#TOPUP_Fin_LTV_M h5").html("Ext/Imp LTV (Market)");
        }
        $("#TOPUP_Fin_LTV_A [key='textval']").html((OBJ.TOPUP_LTV_A || 0).toFixed(2) + ' <span class="percentage"></span>');
        $("#TOPUP_Fin_LTV_M [key='textval']").html((OBJ.TOPUP_LTV_M || 0).toFixed(2) + ' <span class="percentage"></span>');
        $(".topup-ltv").show();
    }
    else {
        $(".topup-ltv").hide();
    }

    setTimeout(function () {
        $("#TxtFin_GI").focusout();
        $("#TxtFin_LI").focusout();
    }, 500);

    var lnval = Number(FormatCleanComma($("#Fin_LOAN [key=textval]").justtext()));
    var dataPerc = $("#Fin_PF [key=rangeval]").val();
    lnval = lnval * dataPerc / 100;
    lnval = Math.round(lnval);
    lnval = FormatCurrency(lnval);
    $("#Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);

    GLOB_CREDIT.LTV = OBJ.LTV_PERC_A;
    GLOB_CREDIT.FOIR = IIR_FOIR;
    GLOB_CREDIT.TENURE = OBJ.TENURE;
}


function fnSetCreditInfo(data) {
    data = data ? data : [];
    if (!data && data.length == 0)
        return;
    var INCOME, OBLIGATIONS, ROI, EMI, LOAN_AMT, TENURE, MRKPROP_VAL, LTV_PERC, LTV_PERC_A, AGRPROP_VAL,
        FOIR, SALARY_TYPE, SAL_PROOF, CIBIL, LI, GI, TOPUP_LTV_A, TOPUP_LTV_M , IIR , ROI_CHANGE;
    var SHPLR = 15;

    var OBJ = data[0];
    ROI_CHANGE = OBJ.ROI_CHANGE || 0;
    INCOME = OBJ.NET_INC || 0, OBLIGATIONS = OBJ.OBL || 0, ROI = (OBJ.ROI + ROI_CHANGE) || 0, EMI = OBJ.EMI || 0, LOAN_AMT = OBJ.LOAN_AMT || 0, IIR = OBJ.IIR || 0,
    TENURE = OBJ.TENUR || 0, MRKPROP_VAL = OBJ.EST_PRP || 0, LTV_PERC = OBJ.LTV || 0, LTV_PERC_A = OBJ.ACT_LTV || 0, AGRPROP_VAL = OBJ.ACT_PRP || 0,
    FOIR = OBJ.FOIR || 0, CIBIL = OBJ.CBL || 0, LI = OBJ.LI || 0, GI = OBJ.GI || 0, TOPUP_LTV_A = OBJ.TOPUP_LTV_A || 0, TOPUP_LTV_M = OBJ.TOPUP_LTV_M || 0;

    if (LapArr.indexOf(productCode) == -1) {
        FOIR = FOIR.toFixed(2);
        $("#Fin_FOIR [key='textval']").html(FOIR + '<span class="percentage"></span>');
    }
    else {
        IIR = IIR.toFixed(2);
        FOIR = IIR;
        $("#Fin_FOIR [key='textval']").html(IIR + '<span class="percentage"></span>');
    }

    LTV_PERC = LTV_PERC.toFixed(2);
    $("#Fin_LTV [key='textval']").html(LTV_PERC + '<span class="percentage"></span>');

    LTV_PERC_A = LTV_PERC_A.toFixed(2);
    $("#Fin_LTV_A [key='textval']").html(LTV_PERC_A + ' <span class="percentage"></span>');

    ROI = ROI.toFixed(2);
    
    $("#Fin_ROI [key='textval']").html(ROI  + ' <span class="percentage"></span>');

    var LoanAMtLakh = LOAN_AMT;
    LoanAMtLakh = Math.round(LoanAMtLakh.toFixed(2));
    LoanAMtLakh = FormatCurrency(LoanAMtLakh);
    $("#Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i> ' + LoanAMtLakh + '');

    $("#TxtFin_LI").val(FormatCurrency(LI));
    $("#TxtFin_GI").val(FormatCurrency(GI));

    EMI = Math.round(EMI.toFixed(2));
    EMI = FormatCurrency(EMI);
    $("#Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i> ' + EMI);
       
    if (productCode == "HLTopup" || productCode == "LAPTopup" || productCode == "HLExt" || productCode == "HLImp") {

        if (productCode == "HLExt" || productCode == "HLImp") {
            $("#TOPUP_Fin_LTV_A h5").html("Ext/Imp LTV (Agreement)");
            $("#TOPUP_Fin_LTV_M h5").html("Ext/Imp LTV (Market)");
        }

        $("#TOPUP_Fin_LTV_A [key='textval']").html(TOPUP_LTV_A.toFixed(2) + ' <span class="percentage"></span>');
        $("#TOPUP_Fin_LTV_M [key='textval']").html(TOPUP_LTV_M.toFixed(2) + ' <span class="percentage"></span>');
        $(".topup-ltv").show();
    }
    else { $(".topup-ltv").hide(); }

    /* SET GLOBAL DEVIATION PARAMS */
    GLOB_CREDIT.LTV = LTV_PERC_A;
    GLOB_CREDIT.FOIR = FOIR;
    GLOB_CREDIT.TENURE = TENURE;
    GLOB_CREDIT.INCOME = INCOME;

    setTimeout(function () {
        $("#TxtFin_GI").focusout();
        $("#TxtFin_LI").focusout();
    }, 500);

    /*
    var lnval = Number($("#Fin_LOAN [key=textval]").justtext());
    var dataPerc = $("#Fin_PF [key=rangeval]").val();
    dataPerc = $("#Fin_PF [key=rangeval]").data("ionRangeSlider").old_from;
    lnval = lnval * 100000 * dataPerc / 100;
    lnval = Math.ceil(lnval);
    $("#Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);
    */
}



function fnSetCreditInfo_BT(data) {
    data = data ? data : [];
    if (!data && data.length == 0)
        return;
    var OBJ = data[0];
    var INCOME, OBLIGATIONS, ROI, EMI, LOAN_AMT, TENURE, MRKPROP_VAL, LTV_PERC, LTV_PERC_A, AGRPROP_VAL,
        IIR,FOIR, SALARY_TYPE, SAL_PROOF, CIBIL, LI, GI, BT_GI, BT_LI, TOP_GI, TOP_LI, BT_LOAN_AMT;

    var BT_ROI, TOPUP_ROI, PRD_CODE, OUTSTD_AMT, ARR_OUTSTD_AMT, TOPUP_AMT, ARR_TOPUP_AMT, BT_EMI, TOPUP_EMI, ROI_CHANGE;


    ROI_CHANGE = OBJ.ROI_CHANGE || 0;
    INCOME = OBJ.NET_INC || 0, OBLIGATIONS = OBJ.OBL || 0, ROI = OBJ.ROI || 0, EMI = OBJ.EMI || 0, LOAN_AMT = OBJ.LOAN_AMT || 0, TENURE = OBJ.TENUR || 0,
    MRKPROP_VAL = OBJ.EST_PRP || 0, LTV_PERC = OBJ.LTV || 0, LTV_PERC_A = OBJ.ACT_LTV || 0, AGRPROP_VAL = OBJ.ACT_PRP || 0,
    IIR = OBJ.IIR || 0, FOIR = OBJ.FOIR || 0, CIBIL = OBJ.CBL || 0, LI = OBJ.LI || 0, GI = OBJ.GI || 0, BT_GI = OBJ.BT_GI || 0, BT_LI = OBJ.BT_LI || 0,
    TOP_GI = OBJ.TOPUP_GI || 0, TOP_LI = OBJ.TOPUP_LI || 0, BT_LOAN_AMT = OBJ.BT_AMT || 0, BT_ROI = (OBJ.BT_ROI + ROI_CHANGE) || 0, TOPUP_ROI = (OBJ.TOPUP_ROI + ROI_CHANGE) || 0,
    TOPUP_AMT = OBJ.TOPUP_AMT || 0, BT_EMI = OBJ.BT_EMI || 0, TOPUP_EMI = OBJ.TOPUP_EMI || 0;
    var SHPLR = 15;


    if (LapArr.indexOf(productCode) == -1) {
        FOIR = FOIR.toFixed(2);
        $("#BT_Fin_FOIR [key='textval']").html(FOIR + '<span class="percentage"></span>');
    }
    else {
        IIR = IIR.toFixed(2);
        FOIR = IIR;
        $("#BT_Fin_FOIR [key='textval']").html(IIR + '<span class="percentage"></span>');
    }

    LTV_PERC = LTV_PERC.toFixed(2);
    $("#BT_Fin_LTV [key='textval']").html(LTV_PERC + '<span class="percentage"></span>');

    LTV_PERC_A = LTV_PERC_A.toFixed(2);
    $("#BT_Fin_LTV_A [key='textval']").html(LTV_PERC_A + ' <span class="percentage"></span>');

    BT_ROI = BT_ROI.toFixed(2);
    $("#BT_Fin_ROI [key='textval']").html(BT_ROI + ' <span class="percentage"></span>');

    TOPUP_ROI = TOPUP_ROI.toFixed(2);
    $("#TOP_Fin_ROI [key='textval']").html(TOPUP_ROI + ' <span class="percentage"></span>');

    var LoanAMtLakh = BT_LOAN_AMT;
    LoanAMtLakh = Math.round(LoanAMtLakh.toFixed(2));
    LoanAMtLakh = FormatCurrency(LoanAMtLakh);
    $("#BT_amt [key='textval']").html('<i class="icon-indian-rupee"></i> ' + LoanAMtLakh + '');

    LoanAMtLakh = TOPUP_AMT;
    LoanAMtLakh = Math.round(LoanAMtLakh.toFixed(2));
    LoanAMtLakh = FormatCurrency(LoanAMtLakh);
    $("#TOP_Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i> ' + LoanAMtLakh + '');

    BT_EMI = Math.round(BT_EMI.toFixed(2));
    BT_EMI = FormatCurrency(BT_EMI);
    $("#BT_Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i> ' + BT_EMI);

    TOPUP_EMI = Math.round(TOPUP_EMI.toFixed(2));
    TOPUP_EMI = FormatCurrency(TOPUP_EMI);
    $("#TOP_Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i> ' + TOPUP_EMI);

    $("#BT_TxtFin_GI").val(FormatCurrency(BT_GI));

    $("#BT_TxtFin_LI").val(FormatCurrency(BT_LI));

    $("#TOP_TxtFin_GI").val(FormatCurrency(TOP_GI));
    $("#TOP_TxtFin_LI").val(FormatCurrency(TOP_LI));   

    /* SET GLOBAL DEVIATION PARAMS */
    GLOB_CREDIT.LTV = LTV_PERC_A;
    GLOB_CREDIT.FOIR = FOIR;
    GLOB_CREDIT.TENURE = TENURE;
    GLOB_CREDIT.INCOME = INCOME;

    setTimeout(function () {
        $("#BT_TxtFin_GI").focusout();
        $("#BT_TxtFin_LI").focusout();
        $("#TOP_TxtFin_GI").focusout();
        $("#TOP_TxtFin_LI").focusout();
    }, 500);

}


function fnSetExpectedValues(ExpData) {
    var exploan = ExpData[0].ExpLOAN;
    var expROI = ExpData[0].ExpROI;
    var expEMI = ExpData[0].ExpEMI;
    $("#ExpLoanAMt p").attr("OrgVal", ExpData[0].ExpLOAN);
    $("#ExpLoanAMt p").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(exploan));
    $("#ExpROI p").attr("OrgVal", ExpData[0].ExpROI);
    $("#ExpROI p").html(expROI + '<span class="percentage"></span>');
    $("#ExpEMI p").attr("OrgVal", ExpData[0].ExpEMI);
    $("#ExpEMI p").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(expEMI));
}

var SALTYPE;
var SALPRF;
var GLB_OBLIGATIONS;
function fnSETArrLoanData(LoanData, InputParams, PreviousRecommened) {

    if (LoanData[0].PRD_CODE == "HLBTTopup" || LoanData[0].PRD_CODE == "LAPBTTopup") {
        fnSETArrLoanData_BT(LoanData, InputParams, PreviousRecommened);
        return;
    }

    var INCOME, OBLIGATIONS, ROI, EMI, LOAN_AMT, TENURE, MRKPROP_VAL, LTV_PERC, LTV_PERC_A, AGRPROP_VAL,
        FOIR, SALARY_TYPE, SAL_PROOF, CIBIL, LI, GI, SHPLR, TOPUP_LTV_M, TOPUP_LTV_A;

    var LOAN_AMT_NEW, LTV_PERC_NEW, FOIR_PERC_NEW;

    var slider;

    AGRPROP_VAL = LoanData[0].ACT_PRP_VAL
    MRKPROP_VAL = LoanData[0].MRK_PRP;
    LTV_PERC_NEW = LoanData[0].LTV_PERC_New;
    LTV_PERC = LoanData[0].LTV;
    LOAN_AMT = LoanData[0].LOAN_AMT;
    LOAN_AMT_NEW = LoanData[0].Loan_Amt_New;
    TENURE = LoanData[0].TENURE;
    ROI = LoanData[0].ROI.toFixed(2);
    CIBIL = LoanData[0].CIBIL;
    INCOME = LoanData[0].INCOME;
    EMI = LoanData[0].EMI;
    ActLTV = LoanData[0].ActLTV;
    SHPLR = LoanData[0].SHPLR;
    OBLIGATIONS = LoanData[0].OBLIGATIONS;
    GLB_OBLIGATIONS = LoanData[0].OBLIGATIONS;
    FOIR = LoanData[0].FOIR;
    FOIR_PERC_NEW = LoanData[0].FOIR_PERC_New;

    SALTYPE = LoanData[0].SAL_TYPE || 0;
    SALPRF = LoanData[0].SAL_PRF || 0;

    /* SET GLOBAL DEVIATION PARAMS */
    GLOB_CREDIT.SALTYPE = SALTYPE;
    GLOB_CREDIT.SALPRF = SALPRF;
    GLOB_CREDIT.INCOME = INCOME;
    GLOB_CREDIT.FOIR = FOIR;

    var finLon = LoanData[0].ARR_OUTSTD_AMT;
    finLon = Math.round(finLon.toFixed(2));
    finLon = FormatCurrency(finLon);

    if (productCode != "LAPTopup" && productCode != "HLTopup")
        $("#Exst_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i> ' + finLon + '');

    // Agreemnet value    
    var ActValLakh = LoanData[0].ACT_PRP_VAL;
    ActValLakh = ActValLakh.toFixed(2);
    $("#Prp_ValDiv [key='Agr']").attr("orgval", AGRPROP_VAL);
    $("#Prp_ValDiv").find("[key='Agr']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(AGRPROP_VAL));

    // MARKET VALUE     
    var mrkval = MRKPROP_VAL;
    mrkval = mrkval.toFixed(2);
    $("#Prp_ValDiv").find("[key='Mrk']").attr("OrgVal", MRKPROP_VAL);
    $("#Prp_ValDiv").find("[key='Mrk']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(MRKPROP_VAL));


    if (InputParams.length == 0 && PreviousRecommened.length == 0) {
        // TENURE
        GLOB_CREDIT.TENURE = TENURE;
        if (remainingTenure != 0 && remainingTenure < TENURE && productCode != "HLBTTopup" && productCode != "LAPBTTopup") {
            fnShflAlert("warning", "Given Tenure should not be greater than Existing Loan's Tenure <br/> Existing Loan Tenure is : " + remainingTenure);
        }
        
        $("#ElgTenure").find("[key='textval']").html('<span class="value" contenteditable="true">' + TENURE + '</span><span class="month"></span>');;
        $("#ElgTenure").find("[key='rangetext']").val(TENURE);
        slider = $("#ElgTenure").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 400,
                from: TENURE,
                onChange: fnOnchange
                //onUpdate: fnOnchange
                
            });
    }
    // CIBIL SCORE
    $("#CibilScr").find("[key='textval']").text(CIBIL);

    // INCOME 
    $("#NetIncome").find("[key='textval_Inc']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(INCOME)));

    //OBLIGATIONS
    $("#NetIncome").find("[key='textval_Obl']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(OBLIGATIONS)));


    if (InputParams.length == 0 && PreviousRecommened.length == 0) {

        // LTV PERC
        var ltv = LTV_PERC_NEW.toFixed(2);
        $("#Prp_Loan2ValMrk").find("[key='textval']").attr("OrgVal", LTV_PERC_NEW);
        $("#Prp_Loan2ValMrk").find("[key='textval']").html('<span class="value" contenteditable="true">' + ltv + '</span> <span class="percentage"></span>');
        slider = $("#Prp_Loan2ValMrk").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 0,
                max: parseInt(ltv) + 50,
                from: ltv,
                step: 0.01,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });


        // LOAN AMOUNT
        var loanAmt = LOAN_AMT_NEW;
        loanAmt = loanAmt.toFixed(2);
        $("#ElgLoanAmt").find("[key='textval']").attr("OrgVal", LOAN_AMT_NEW);
        $("#ElgLoanAmt").find("[key='textval']").html('<i class="icon-indian-rupee"></i><span class="value" contenteditable="true">' + FormatCurrency(loanAmt));
        $("#ElgLoanAmt").find("[key='rangetext']").val(loanAmt);
        slider = $("#ElgLoanAmt").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 0,
                max: loanAmt * 3,
                from: loanAmt,
                step: 1,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });



        //ROI    
        $("#ElgLoanROI").find("[key='textval']").attr("orgval", SHPLR);
        $("#ElgLoanROI").find("[key='textval']").html('<span class="value" contenteditable="true">' + SHPLR + '</span><span class="percentage"></span>');
        slider = $("#ElgLoanROI").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 20,
                from: SHPLR,
                step: 0.01,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
            });

        // FOIR
        var FOIRnew = FOIR_PERC_NEW.toFixed(2);
        $("#IIRorFOIR").find("[key='textval']").html('<span class="value" contenteditable="true">' + FOIRnew + ' </span> <span class="percentage"></span>');
        $("#IIRorFOIR").find("[key='rangetext']").val(FOIRnew);
        slider = $("#IIRorFOIR").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 100,
                from: FOIRnew,
                step: 0.01,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });

        // SET DEFAULT ARRIVED VALUES
        //var finLon = LOAN_AMT / 100000;
        finLon = LOAN_AMT;
        finLon = Math.round(finLon.toFixed(2));
        finLon = FormatCurrency(finLon);
        $("#Fin_FOIR [key='textval']").html(FOIR.toFixed(2) + '<span class="percentage"></span>');
        $("#Fin_LTV [key='textval']").html(LTV_PERC.toFixed(2) + '<span class="percentage"></span>');
        $("#Fin_LTV_A [key='textval']").html(ActLTV.toFixed(2) + ' <span class="percentage"></span>');
        $("#Fin_ROI [key='textval']").html(ROI + ' <span class="percentage"></span>');
        $("#Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i> ' + finLon + '');
        EMI = Math.round(EMI.toFixed(2));
        EMI = FormatCurrency(EMI);
        $("#Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i> ' + EMI);

        if (productCode == "HLTopup" || productCode == "LAPTopup" || productCode == "HLExt" || productCode == "HLImp") {
            TOPUP_LTV_M = LoanData[0].TOPUP_LTV_M, TOPUP_LTV_A = LoanData[0].TOPUP_LTV_A;

            if (productCode == "HLExt" || productCode == "HLImp") {
                $("#TOPUP_Fin_LTV_A h5").html("Ext/Imp LTV (Agreement)");
                $("#TOPUP_Fin_LTV_M h5").html("Ext/Imp LTV (Market)");
            }

            $("#TOPUP_Fin_LTV_A [key='textval']").html(TOPUP_LTV_A.toFixed(2) + ' <span class="percentage"></span>');
            $("#TOPUP_Fin_LTV_M [key='textval']").html(TOPUP_LTV_M.toFixed(2) + ' <span class="percentage"></span>');
            $(".topup-ltv").show();
        }
        else { $(".topup-ltv").hide(); }

        setTimeout(function () {
            $("#TxtFin_GI").focusout();
            $("#TxtFin_LI").focusout();
        }, 500);


        var lnval = Number(FormatCleanComma($("#Fin_LOAN [key='textval']").justtext()));
        var dataPerc = $("#Fin_PF [key=rangeval]").data("ionRangeSlider").update({
            from: 1.5,
            onFinish: function () {
                fnSelectRemPF();
            }
        });
        //lnval = lnval * 100000 * 1.5 / 100;
        lnval = lnval * 1.5 / 100;
        lnval = Math.round(lnval);
        lnval = FormatCurrency(lnval);
        $("#Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);
    }

    //~~fnSelectRemPF();
}





function fnSETArrLoanData_BT(LoanData, InputParams, PreviousRecommened) {
    var INCOME, OBLIGATIONS, ROI, EMI, LOAN_AMT, TENURE, MRKPROP_VAL, LTV_PERC, LTV_PERC_A, AGRPROP_VAL,
        FOIR, SALARY_TYPE, SAL_PROOF, CIBIL, LI, GI, SHPLR,
        PRD_CODE, OUTSTD_AMT, ARR_OUTSTD_AMT, TOPUP_AMT, ARR_TOPUP_AMT, BT_EMI, TOPUP_EMI, BT_LTV_A, TOPUP_LTV_A, BT_LTV_M, TOPUP_LTV_M;

    var LOAN_AMT_NEW, LTV_PERC_NEW, FOIR_PERC_NEW;

    var slider;

    PRD_CODE = LoanData[0].PRD_CODE, OUTSTD_AMT = LoanData[0].OUTSTD_AMT, ARR_OUTSTD_AMT = LoanData[0].ARR_OUTSTD_AMT,
    TOPUP_AMT = LoanData[0].TOPUP_AMT, ARR_TOPUP_AMT = LoanData[0].ARR_TOPUP_AMT, BT_EMI = LoanData[0].BT_EMI, TOPUP_EMI = LoanData[0].TOPUP_EMI;

    AGRPROP_VAL = LoanData[0].ACT_PRP_VAL, MRKPROP_VAL = LoanData[0].MRK_PRP, LTV_PERC_NEW = LoanData[0].LTV_PERC_New,
    LTV_PERC = LoanData[0].LTV, LOAN_AMT = LoanData[0].LOAN_AMT, LOAN_AMT_NEW = LoanData[0].Loan_Amt_New, TENURE = LoanData[0].TENURE,
    ROI = LoanData[0].ROI.toFixed(2), CIBIL = LoanData[0].CIBIL, INCOME = LoanData[0].INCOME, EMI = LoanData[0].EMI,
    ActLTV = LoanData[0].ActLTV, SHPLR = LoanData[0].SHPLR, OBLIGATIONS = LoanData[0].OBLIGATIONS, GLB_OBLIGATIONS = LoanData[0].OBLIGATIONS,
    FOIR = LoanData[0].FOIR, SALTYPE = LoanData[0].SAL_TYPE || 0, SALPRF = LoanData[0].SAL_PRF || 0, FOIR_PERC_NEW = LoanData[0].FOIR_PERC_New,
    BT_LTV_A = LoanData[0].BT_LTV_A || 0, TOPUP_LTV_A = LoanData[0].TOPUP_LTV_A || 0,
    BT_LTV_M = LoanData[0].BT_LTV_M || 0, TOPUP_LTV_M = LoanData[0].TOPUP_LTV_M || 0;


    $("#BT_LTV_A [key='textval']").html(BT_LTV_A.toFixed(2) + '<span class="percentage"></span>');
    $("#TOPUP_LTV_A [key='textval']").html(TOPUP_LTV_A.toFixed(2) + '<span class="percentage"></span>');

    $("#BT_LTV_M [key='textval']").html(BT_LTV_M.toFixed(2) + '<span class="percentage"></span>');
    $("#TOPUP_LTV_M [key='textval']").html(TOPUP_LTV_M.toFixed(2) + '<span class="percentage"></span>');


    /* SET GLOBAL DEVIATION PARAMS */
    GLOB_CREDIT.SALTYPE = SALTYPE;
    GLOB_CREDIT.SALPRF = SALPRF;
    GLOB_CREDIT.INCOME = INCOME;
    GLOB_CREDIT.FOIR = FOIR;

    // Agreemnet value    
    var ActValLakh = LoanData[0].ACT_PRP_VAL;
    ActValLakh = ActValLakh.toFixed(2);
    $("#Prp_ValDiv [key='Agr']").attr("orgval", AGRPROP_VAL);
    $("#Prp_ValDiv").find("[key='Agr']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(AGRPROP_VAL));

    // MARKET VALUE     
    var mrkval = MRKPROP_VAL;
    mrkval = mrkval.toFixed(2);
    $("#Prp_ValDiv").find("[key='Mrk']").attr("OrgVal", MRKPROP_VAL);
    $("#Prp_ValDiv").find("[key='Mrk']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(MRKPROP_VAL));


    if (InputParams.length == 0 && PreviousRecommened.length == 0) {
        // TENURE
        GLOB_CREDIT.TENURE = TENURE;

        if (remainingTenure != 0 && remainingTenure < TENURE && productCode != "HLBTTopup" && productCode != "LAPBTTopup") {
            fnShflAlert("warning", "Given Tenure should not be greater than Existing Loan's Tenure <br/> Existing Loan Tenure is : " + remainingTenure);
        }

        $("#ElgTenure").find("[key='textval']").html('<span class="value" contenteditable="true">' + TENURE + '</span><span class="month"></span>');;
        $("#ElgTenure").find("[key='rangetext']").val(TENURE);
        slider = $("#ElgTenure").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 400,
                from: TENURE,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
            });


        $("#ElgTenure_TOP").find("[key='textval']").html('<span class="value" contenteditable="true">' + TENURE + '</span><span class="month"></span>');;
        $("#ElgTenure_TOP").find("[key='rangetext']").val(TENURE);
        slider = $("#ElgTenure_TOP").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 400,
                from: TENURE,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
            });

    }

    // CIBIL SCORE
    $("#CibilScr").find("[key='textval']").text(CIBIL);

    // INCOME 
    $("#NetIncome").find("[key='textval_Inc']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(INCOME)));

    //OBLIGATIONS
    $("#NetIncome").find("[key='textval_Obl']").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(OBLIGATIONS)));


    if (InputParams.length == 0 && PreviousRecommened.length == 0) {

        // LTV PERC
        var ltv = LTV_PERC_NEW.toFixed(2);
        $("#Prp_Loan2ValMrk").find("[key='textval']").attr("OrgVal", LTV_PERC_NEW);
        $("#Prp_Loan2ValMrk").find("[key='textval']").html('<span class="value" contenteditable="true">' + ltv + ' </span> <span class="percentage"></span>');
        slider = $("#Prp_Loan2ValMrk").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 0,
                max: parseInt(ltv) + 50,
                from: ltv,
                step: 0.01,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });


        // LOAN AMOUNT
        var loanAmt = LOAN_AMT_NEW;
        loanAmt = loanAmt.toFixed(2);
        $("#ElgLoanAmt").find("[key='textval']").attr("OrgVal", LOAN_AMT_NEW);
        $("#ElgLoanAmt").find("[key='textval']").html('<i class="icon-indian-rupee"></i><span class="value" contenteditable="true">' + FormatCurrency(loanAmt));
        $("#ElgLoanAmt").find("[key='rangetext']").val(loanAmt);
        slider = $("#ElgLoanAmt").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 0,
                max: loanAmt * 3,
                from: loanAmt,
                step: 1,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });



        //ROI    
        $("#ElgLoanROI").find("[key='textval']").attr("orgval", SHPLR);
        $("#ElgLoanROI").find("[key='textval']").html('<span class="value" contenteditable="true">' + SHPLR + '</span><span class="percentage"></span>');
        slider = $("#ElgLoanROI").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 20,
                from: SHPLR,
                step: 0.01,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
            });

        // FOIR
        var FOIRnew = FOIR_PERC_NEW.toFixed(2);
        $("#IIRorFOIR").find("[key='textval']").html('<span class="value" contenteditable="true">' + FOIRnew + '</span> <span class="percentage"></span>');
        $("#IIRorFOIR").find("[key='rangetext']").val(FOIRnew);
        slider = $("#IIRorFOIR").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 100,
                from: FOIRnew,
                step: 0.01,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
                onFinish: function () {
                    fnSelectRemPF();
                }
            });


        PRD_CODE = LoanData[0].PRD_CODE, OUTSTD_AMT = LoanData[0].OUTSTD_AMT, ARR_OUTSTD_AMT = LoanData[0].ARR_OUTSTD_AMT,
        TOPUP_AMT = LoanData[0].TOPUP_AMT, ARR_TOPUP_AMT = LoanData[0].ARR_TOPUP_AMT, BT_EMI = LoanData[0].BT_EMI, TOPUP_EMI = LoanData[0].TOPUP_EMI;

        // SET DEFAULT ARRIVED VALUES
        //var finLon = LOAN_AMT / 100000;
        var finLon = ARR_OUTSTD_AMT;
        finLon = Math.round(finLon.toFixed(2));
        finLon = FormatCurrency(finLon);
        $("#BT_Fin_FOIR [key='textval']").html(FOIR.toFixed(2) + '<span class="percentage"></span>');
        $("#BT_Fin_LTV [key='textval']").html(LTV_PERC.toFixed(2) + '<span class="percentage"></span>');
        $("#BT_Fin_LTV_A [key='textval']").html(ActLTV.toFixed(2) + ' <span class="percentage"></span>');
        $("#BT_Fin_ROI [key='textval']").html(ROI + ' <span class="percentage"></span>');
        $("#TOP_Fin_ROI [key='textval']").html((Number(ROI) + 1) + ' <span class="percentage"></span>');

        $("#BT_amt [key='textval']").html('<i class="icon-indian-rupee"></i> ' + finLon + '');

        finLon = ARR_TOPUP_AMT;
        finLon = Math.round(finLon.toFixed(2));
        finLon = FormatCurrency(finLon);
        $("#TOP_Fin_LOAN [key='textval']").html('<i class="icon-indian-rupee"></i> ' + finLon + '');

        BT_EMI = Math.round(BT_EMI.toFixed(2));
        BT_EMI = FormatCurrency(BT_EMI);
        $("#BT_Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i> ' + BT_EMI);

        TOPUP_EMI = Math.round(TOPUP_EMI.toFixed(2));
        TOPUP_EMI = FormatCurrency(TOPUP_EMI);
        $("#TOP_Fin_EMI [key='textval']").html('<i class="icon-indian-rupee"></i> ' + TOPUP_EMI);


        setTimeout(function () {
            $("#BT_TxtFin_GI").focusout();
            $("#BT_TxtFin_LI").focusout();
            $("#TOP_TxtFin_GI").focusout();
            $("#TOP_TxtFin_LI").focusout();
        }, 500);

        var lnval = Number(FormatCleanComma($("#TOP_Fin_LOAN [key='textval']").justtext()));
        lnval = lnval + Number(FormatCleanComma($("#BT_amt [key=textval]").justtext()));
        var dataPerc = $("#BT_Fin_PF [key=rangeval]").data("ionRangeSlider").update({
            from: 1.5,
            onFinish: function () {
                fnSelectRemPF();
            }
        });
        //lnval = lnval * 100000 * 1.5 / 100;
        lnval = lnval * 1.5 / 100;
        lnval = Math.round(lnval);
        lnval = FormatCurrency(lnval);
        $("#BT_Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);
    }
    //~~fnSelectRemPF();
}

function fnChangeRoiAdjust(data, type) {
    var input;
    input = data.input;
    var waiveROI = data.from;
    var hoverBox = $(input).closest(".hover-show");
    var roiBox = $(hoverBox).closest(".box-sum");
    var roi = $(roiBox).find("p[key='textval']").justtext();    
    var arrived = Number(roi);
    if (type == "C")
        arrived = Number(roi) + Number(waiveROI);
    $(roiBox).find(".arrived-roi").text(arrived);
    $(roiBox).find(".roi-adjust-input").text(waiveROI);
    //~JPR
    $(roiBox).find(".roi-waiver-span input").val(waiveROI);    
    $(roiBox).find(".roi-waiver-span input").focusout();
    $(roiBox).find(".hover-div").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
    var bg = waiveROI >= 0 ? "bg1" : "bg2";
    $(roiBox).find(".hover-div").addClass(bg);
}

function fnOnchange(data) {
    
    var input ;
    var attr;
    if (data == {}) {
        input = "";
        attr = "";
    } else {
        input = data.input;
        attr = $(input).attr("colkey");
    }
    

    var INCOME, OBLIGATIONS, EXPLOAN, TENURE, MRKPROP_VAL, LTV_PERC, FOIR, SHPLR, SALARY_TYPE, SAL_PROOF, CIBIL, ROI, TENURE_TOP;
    OBLIGATIONS = GLB_OBLIGATIONS;

    INCOME = $("#NetIncome").find("[key='textval_Inc']").justtext();
    INCOME = FormatCleanComma(INCOME);
    EXPLOAN = FormatCleanComma($("#ElgLoanAmt .value").justtext());
    TENURE = $("#ElgTenure").find("[key='textval'] .value").justtext();
    MRKPROP_VAL = FormatCleanComma($("#Prp_ValDiv").find("[key='Mrk']").justtext());
    AGRPROP_VAL = FormatCleanComma($("#Prp_ValDiv").find("[key='Agr']").justtext());
    LTV_PERC = $("#Prp_Loan2ValMrk").find("[key='textval'] .value").justtext();
    FOIR = $("#IIRorFOIR").find("[key='textval'] .value").justtext();
    SHPLR = $("#ElgLoanROI").find("[key='textval'] .value").justtext();
    SALARY_TYPE = SALTYPE == 0 ? "SAL" : "SELF";
    SAL_PROOF = SALPRF == 0 ? true : false;

    CIBIL = $("#CibilScr").find("[key='textval']").justtext();

    var OUTLoanOBJ;

    if (attr == "LTV_M") {
        $(input).closest("div.box-sum").find("p[key='textval']").html('<span class="value" contenteditable="true">' + data.from + '</span> <span class="percentage"></span>');
        LTV_PERC = data.from;
    }
    if (attr == "LOAN_AMT") {
        EXPLOAN = data.from;
        $(input).closest("div.box-sum").find("p[key='textval']").attr("orgval", EXPLOAN);
        $(input).closest("div.box-sum").find("p[key='textval']").html('<i class="icon-indian-rupee"></i><span class="value" contenteditable="true"> ' + FormatCurrency(EXPLOAN));
    }
    if (attr == "TENURE") {
        TENURE = data.from;
        $(input).closest("div.box-sum").find("p[key='textval']").html('<span class="value" contenteditable="true">' + data.from + '</span> <span class="month"></span>');

        var toptenure = $("#ElgTenure_TOP").find("[key='rangetext']").val();
        //if (toptenure > TENURE) {
        //    $("#ElgTenure_TOP").find("[key='rangetext']").val(TENURE);
        //    $("#ElgTenure_TOP p[key='textval']").html('<span class="value" contenteditable="true">' + TENURE + '</span> <span class="month"></span>');
        //}
        slider = $("#ElgTenure_TOP").find("[key='rangeval']").data("ionRangeSlider");
        if (slider)
            slider.update({
                min: 10,
                max: 400,
                from: toptenure,
                onChange: fnOnchange,
                //onUpdate: fnOnchange
            });
    }

    if (attr == "TENURE_TOP") {
        TENURE_TOP = data.from;
        $(input).closest("div.box-sum").find("p[key='textval']").html('<span class="value" contenteditable="true">' + data.from + '</span> <span class="month"></span>');        
    }

    if (attr == "ROI") {
        ROI = data.from;
        SHPLR = ROI;
        $(input).closest("div.box-sum").find("p[key='textval']").html('<span class="value" contenteditable="true">' + data.from + '</span> <span class="percentage"></span>');
    }

    if (attr == "FOIR") {
        FOIR = data.from;
        $(input).closest("div.box-sum").find("p[key='textval']").html('<span class="value" contenteditable="true">' + data.from + '</span> <span class="percentage"></span>');
    }

    if (attr == "PF") {
        if (ProductDiv == "HL") {
            var lnval = Number(FormatCleanComma($("#Fin_LOAN [key=textval]").justtext()));
            //lnval = lnval * 100000 * data.from / 100;
            lnval = lnval * data.from / 100;
            lnval = Math.round(lnval);
            lnval = FormatCurrency(lnval);
            $("#Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);
        }
        else {
            var lnval = Number(FormatCleanComma($("#TOP_Fin_LOAN [key=textval]").justtext()));
            //lnval = lnval * 100000 * data.from / 100;
            lnval = lnval + Number(FormatCleanComma($("#BT_amt [key=textval]").justtext()));
            lnval = lnval * data.from / 100;
            lnval = Math.round(lnval);
            lnval = FormatCurrency(lnval);
            $("#BT_Fin_PF [key=textval]").html('<i class="icon-indian-rupee"></i>' + lnval);
        }
        //~~fnSelectRemPF();
    }

    if (attr != "PF") {
        //console.log(INCOME, OBLIGATIONS, EXPLOAN, TENURE, MRKPROP_VAL, LTV_PERC, FOIR, SHPLR, SALARY_TYPE, SAL_PROOF, CIBIL, AGRPROP_VAL)
        var ExistLoan = Number(FormatCleanComma($("#Exst_LOAN [key='textval']").justtext()));
        if (productCode == "HLBTTopup" || productCode == "LAPBTTopup")
            ExistLoan = Number(FormatCleanComma($("#BT_amt [key='textval']").justtext()));
        //Exst_LOAN
        ExistLoan = ExistLoan ? ExistLoan : 0;


        var waiverROI = $("#RoiWaiver").attr("val");
        var waiverBTROI = $("#RoiWaiver_BT").attr("val");

        if (ProductDiv == "HL")
            waiverROI = Number(waiverROI) || 0;
        else
            waiverROI = Number(waiverBTROI) || 0;

        if (LapArr.indexOf(productCode) >= 0) {
            isLapProduct = true;
            OUTLoanOBJ = CreditFormulas.LOAN_CALC_LAP(INCOME, OBLIGATIONS, EXPLOAN, TENURE, MRKPROP_VAL, LTV_PERC, FOIR, SHPLR, SALARY_TYPE, SAL_PROOF, CIBIL, AGRPROP_VAL, productCode, ExistLoan, waiverROI);
        }
        else {
            OUTLoanOBJ = CreditFormulas.LOAN_CALC(INCOME, OBLIGATIONS, EXPLOAN, TENURE, MRKPROP_VAL, LTV_PERC, FOIR, SHPLR, SALARY_TYPE, SAL_PROOF, CIBIL, AGRPROP_VAL, productCode, ExistLoan, waiverROI);
        }

        if (ProductDiv == "HL")
            fnInputChanged(OUTLoanOBJ);
        else
            fnInputChanged_BT(OUTLoanOBJ);

        fnLOSDeviation(OUTLoanOBJ);
        
        //~~fnSelectRemPF();
     
        return OUTLoanOBJ;
    }
}




function fnCreditandSanctionEntry_BT(isMoveNxt, IsReject) {
    // TO SAVE CREDIT TABLE INPUT DATA
    
    var inputLtv = $("#Prp_Loan2ValMrk").find("[key='textval'] .value").justtext();
    var InputFOIR = $("#IIRorFOIR").find("[key='textval'] .value").justtext();
    var InputROI = $("#ElgLoanROI").find("[key='textval'] .value").justtext();
    var InputLoan = FormatCleanComma($("#ElgLoanAmt").find("[key='textval'] .value").justtext());
    var InputTenure = Number($("#ElgTenure").find("[key='textval'] .value").justtext());
    var InputTenure_TOP = Number($("#ElgTenure_TOP").find("[key='textval'] .value").justtext());

    if (InputTenure_TOP > InputTenure) {
        fnShflAlert("warning", "Topup Tenure should not be greater BT Tenure.");
        return;
    }


    if (Number(inputLtv) > 90) {
        fnShflAlert("warning", "LTV should not be greater than 90.");
        return;
    }

    var CreditInput = { LTV: inputLtv, ROI: InputROI, LOAN: InputLoan, FOIR: InputFOIR, TENURE: InputTenure, TENUR_TOP: InputTenure_TOP };

    var OBL, NET_INC, FOIR, CBL, TENUR, LOAN_AMT, ROI, EMI, SPREAD, EST_PRP, ACT_PRP, LTV, ACT_LTV, LI, GI,
    TOPUP_AMT, BT_AMT, TOPUP_ROI, BT_ROI, TOPUP_EMI, BT_EMI, TOPUP_LI, BT_LI, TOPUP_GI, BT_GI, BT_LTV_A, TOPUP_LTV_A, BT_LTV_M, TOPUP_LTV_M, ROI_CHANGE;

    OBL = Number(FormatCleanComma($("#NetIncome p[key='textval_Obl']").justtext()));
    NET_INC = Number(FormatCleanComma($("#NetIncome p[key='textval_Inc']").justtext()));
    FOIR = Number($("#BT_Fin_FOIR p[key='textval']").justtext());
    CBL = Number($("#CibilScr p[key='textval']").justtext());
    TENUR = Number($("#ElgTenure p[key='textval'] .value").justtext());
    //LOAN_AMT = Number($("#Fin_LOAN p[key='textval']").justtext()) * 100000;
    TOPUP_AMT = Number(FormatCleanComma($("#TOP_Fin_LOAN p[key='textval']").justtext()));
    TOPUP_ROI = Number($("#TOP_Fin_ROI p[key='textval']").justtext());
    BT_AMT = Number(FormatCleanComma($("#BT_amt p[key='textval']").justtext()));
    BT_ROI = Number($("#BT_Fin_ROI p[key='textval']").justtext());
    TOPUP_EMI = Number(FormatCleanComma($("#TOP_Fin_EMI p[key='textval']").justtext()));
    BT_EMI = Number(FormatCleanComma($("#BT_Fin_EMI p[key='textval']").justtext()));
    SPREAD = Number($("#TOP_Fin_ROI p[key='textval']").justtext()) - 15;

    EST_PRP = Number(FormatCleanComma($("#Prp_ValDiv [key='Mrk']").justtext()));
    ACT_PRP = Number(FormatCleanComma($("#Prp_ValDiv [key='Agr']").justtext()));
    LTV = Number($("#BT_Fin_LTV p[key='textval']").justtext());
    ACT_LTV = Number($("#BT_Fin_LTV_A p[key='textval']").justtext());
    BT_LI = Number(FormatCleanComma($("#BT_TxtFin_LI").val()));
    TOPUP_LI = Number(FormatCleanComma($("#TOP_TxtFin_LI").val()));
    BT_GI = Number(FormatCleanComma($("#BT_TxtFin_GI").val()));
    TOPUP_GI = Number(FormatCleanComma($("#TOP_TxtFin_GI").val()));

    BT_LTV_A = Number($("#BT_LTV_A p[key='textval']").justtext());
    TOPUP_LTV_A = Number($("#TOPUP_LTV_A p[key='textval']").justtext());
    BT_LTV_M = Number($("#BT_LTV_M p[key='textval']").justtext());
    TOPUP_LTV_M = Number($("#TOPUP_LTV_M p[key='textval']").justtext());

    BT_LI_EMI = Number(FormatCleanComma($("#BT_Fin_EMI_L p[key='textval']").justtext()));
    BT_GI_EMI = Number(FormatCleanComma($("#BT_Fin_EMI_G p[key='textval']").justtext()));
    BT_LIGI_EMI = Number(FormatCleanComma($("#BT_Fin_EMI_LG p[key='textval']").justtext()));

    TOPUP_LI_EMI = Number(FormatCleanComma($("#TOP_Fin_EMI_L p[key='textval']").justtext()));
    TOPUP_GI_EMI = Number(FormatCleanComma($("#TOP_Fin_EMI_L p[key='textval']").justtext()));
    TOPUP_LIGI_EMI = Number(FormatCleanComma($("#TOP_Fin_EMI_L p[key='textval']").justtext()));

    var waiverROI = Number($("#RoiWaiver_BT").attr("val")) || 0;
    ROI_CHANGE = waiverROI;

    if (BTTopArr.indexOf(productCode) >= 0) {
        if (remainingTenure != 0 && remainingTenure < TENUR && productCode != "HLBTTopup" && productCode != "LAPBTTopup") {
            fnShflAlert("warning", "Given Tenure should not be greater than Existing Loan's Tenure <br/> Existing Loan Tenure is : " + remainingTenure);
            return;
        }
    }

    LOAN_AMT = Number(TOPUP_AMT) + Number(BT_AMT);

    if (TOPUP_AMT == 0) {
        fnShflAlert("warning", "Topup Loan Amount cannot be zero. Can't Proceed!");
        return;
    }

    var PFVAL = Number(FormatCleanComma($("#BT_Fin_PF p[key='textval']").justtext()));
    var AttrCreditInsert = [{ Attr: "OBL", value: OBL }, { Attr: "NET_INC", value: NET_INC }, { Attr: "CBL", value: CBL }, { Attr: "TENUR", value: TENUR }, { Attr: "TOPUP_AMT", value: TOPUP_AMT },
       { Attr: "BT_AMT", value: BT_AMT }, { Attr: "BT_ROI", value: (BT_ROI + ROI_CHANGE) }, { Attr: "TOPUP_ROI", value: (TOPUP_ROI) }, { Attr: "BT_EMI", value: BT_EMI }, { Attr: "TOPUP_EMI", value: TOPUP_EMI }, { Attr: "SPREAD", value: SPREAD },
       { Attr: "EST_PRP", value: EST_PRP }, { Attr: "ACT_PRP", value: ACT_PRP }, { Attr: "LTV", value: LTV }, { Attr: "ACT_LTV", value: ACT_LTV }, { Attr: "BT_LI", value: BT_LI }, { Attr: "TOPUP_LI", value: TOPUP_LI },
       { Attr: "BT_GI", value: BT_GI }, { Attr: "TOPUP_GI", value: TOPUP_GI }, { Attr: "LOAN_AMT", value: LOAN_AMT }, { Attr: "BT_LTV_A", value: BT_LTV_A },
       { Attr: "TOPUP_LTV_A", value: TOPUP_LTV_A }, { Attr: "BT_LTV_M", value: BT_LTV_M }, { Attr: "TOPUP_LTV_M", value: TOPUP_LTV_M },

       { Attr: "BT_LI_EMI", value: BT_LI_EMI }, { Attr: "BT_GI_EMI", value: BT_GI_EMI }, { Attr: "BT_LIGI_EMI", value: BT_LIGI_EMI },
       { Attr: "TOPUP_LI_EMI", value: TOPUP_LI_EMI }, { Attr: "TOPUP_GI_EMI", value: TOPUP_GI_EMI }, { Attr: "TOPUP_LIGI_EMI", value: TOPUP_LIGI_EMI },
       { Attr: "ROI_CHANGE", value: ROI_CHANGE }
    ];

    if (LapArr.indexOf(productCode) >= 0) {
        AttrCreditInsert.push({ Attr: "IIR", value: FOIR });
    }
    else {
        AttrCreditInsert.push({ Attr: "FOIR", value: FOIR });
    }

    if (productCode == "HLBTTopup" || productCode == "LAPBTTopup") {
        var toptenure = Number($("#ElgTenure_TOP p[key='textval'] .value").justtext());
        AttrCreditInsert.push({ Attr: "TENUR_TOP", value: toptenure });
    }

    var notesOBJ = [];
    $(".subjective-div .sub-notes li").each(function () {
        var dt = $(this).find(".date").text();
        var note = $(this).find(".notes").text();
        var OBJ = { notes: note, date: dt };
        notesOBJ.push(OBJ);
    });


    var perc = $("#BT_Fin_PF [key='rangeval']").val();
    var waiveramt = Number(FormatCleanComma($("#BT_waiveramt").val()));
    waiveramt = waiveramt ? waiveramt : 0;
    var pfjson = [{ Attr: "PF", value: PFVAL, perc: perc, waiver: waiveramt }];

    var X_GlobalXml = GlobalXml;
    var emi = $("#Fin_EMI").find("[key='textval']").justtext();
    emi = FormatCleanComma(emi);
    emi = Number(emi) ? Number(emi) : 0;
    X_GlobalXml[0].EMI = emi;
    X_GlobalXml[0].TOP_EMI = TOPUP_EMI;
    GlobalXml[0].SancRvnNo = window.SancRvnNo;
    X_GlobalXml[0].SancRvnNo = window.SancRvnNo;
    X_GlobalXml[0].isMoveNxt = isMoveNxt;
    X_GlobalXml[0].IsReject = IsReject;
    X_GlobalXml[0].CurApprover = ApproverLevel;
    X_GlobalXml[0].MaxApprover = MaxApproverLevel;
    X_GlobalXml[0].waiverROI = waiverROI;
    

    var ManualDeviation = fnGetSelectedDeviation("DeviationDataDiv_ZC");
    if (ManualDeviation && ManualDeviation.length > 0) {
        var lvl = ManualDeviation[0].level;
        if (lvl == "") {
            fnShflAlert("warning", "Choose deviation level");
            return;
        }
        fnSaveManualDev_ZC();
    }

    var DetailsJson = {
        NotesJson: "", CreditJson: JSON.stringify(AttrCreditInsert),
        SubjectiveJSON: JSON.stringify(notesOBJ), PFJson: JSON.stringify(pfjson),
        CreditInJSON: JSON.stringify(CreditInput),
        ManualDeviation: ""
    };

    var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["INSERT_CREDIT_NEW", JSON.stringify(X_GlobalXml), JSON.stringify(DetailsJson)] };
    fnCallLOSWebService("INSERT_CREDIT", PrcObj, fnCreditOffResult, "MULTI");

}

function fnCreditandSanctionEntry(isMoveNxt, IsReject) {
    // TO SAVE CREDIT TABLE INPUT DATA        
    var inputLtv = $("#Prp_Loan2ValMrk").find("[key='textval'] .value").justtext();
    var InputFOIR = $("#IIRorFOIR").find("[key='textval'] .value").justtext();
    var InputROI = $("#ElgLoanROI").find("[key='textval'] .value").justtext();
    var InputLoan = FormatCleanComma($("#ElgLoanAmt").find("[key='textval'] .value").justtext());
    var InputTenure = $("#ElgTenure").find("[key='textval'] .value").justtext();
    if (Number(inputLtv) > 90) {
        fnShflAlert("warning", "LTV should not be greater than 90.");
        return;
    }

    var CreditInput = { LTV: inputLtv, ROI: InputROI, LOAN: InputLoan, FOIR: InputFOIR ,TENURE:InputTenure };

    var OBL, NET_INC, FOIR, CBL, TENUR, LOAN_AMT, ROI, EMI, SPREAD, EST_PRP, ACT_PRP, LTV, ACT_LTV, LI, GI;
    OBL = Number(FormatCleanComma($("#NetIncome p[key='textval_Obl']").justtext()));
    NET_INC = Number(FormatCleanComma($("#NetIncome p[key='textval_Inc']").justtext()));
    FOIR = Number($("#Fin_FOIR p[key='textval']").justtext());
    CBL = Number($("#CibilScr p[key='textval']").justtext());
    TENUR = Number($("#ElgTenure p[key='textval'] .value").justtext());
    //LOAN_AMT = Number($("#Fin_LOAN p[key='textval']").justtext()) * 100000;
    LOAN_AMT = Number(FormatCleanComma($("#Fin_LOAN p[key='textval']").justtext()));
    ROI = Number($("#Fin_ROI p[key='textval']").justtext());
    EMI = Number(FormatCleanComma($("#Fin_EMI p[key='textval']").justtext()));
    SPREAD = Number($("#Fin_ROI p[key='textval']").justtext()) - 15;
    EST_PRP = Number(FormatCleanComma($("#Prp_ValDiv [key='Mrk']").justtext()));
    ACT_PRP = Number(FormatCleanComma($("#Prp_ValDiv [key='Agr']").justtext()));
    LTV = Number($("#Fin_LTV p[key='textval']").justtext());
    ACT_LTV = Number($("#Fin_LTV_A p[key='textval']").justtext());
    LI = Number(FormatCleanComma($("#TxtFin_LI").val()));
    GI = Number(FormatCleanComma($("#TxtFin_GI").val()));

    LI_EMI = Number(FormatCleanComma($("#Fin_EMI_L p[key='textval']").justtext()));
    GI_EMI = Number(FormatCleanComma($("#Fin_EMI_G p[key='textval']").justtext()));
    LIGI_EMI = Number(FormatCleanComma($("#Fin_EMI_LG p[key='textval']").justtext()));

    var waiverROI = Number($("#RoiWaiver").attr("val")) || 0;
    ROI_CHANGE = waiverROI;

    if (BTTopArr.indexOf(productCode) >= 0 || productCode == "HLExt" || productCode == "HLImp") {
        if (remainingTenure != 0 && remainingTenure < TENUR ) {
            fnShflAlert("warning", "Given Tenure should not be greater than Existing Loan's Tenure <br/> Existing Loan Tenure is : " + remainingTenure);
            return;
        }
    }

    var PFVAL = Number(FormatCleanComma($("#Fin_PF p[key='textval']").justtext()));
    var AttrCreditInsert = [{ Attr: "OBL", value: OBL }, { Attr: "NET_INC", value: NET_INC }, { Attr: "CBL", value: CBL }, { Attr: "TENUR", value: TENUR },
        { Attr: "LOAN_AMT", value: LOAN_AMT }, { Attr: "ROI", value: (ROI + ROI_CHANGE) }, { Attr: "EMI", value: EMI }, { Attr: "SPREAD", value: SPREAD },
       { Attr: "EST_PRP", value: EST_PRP }, { Attr: "ACT_PRP", value: ACT_PRP }, { Attr: "LTV", value: LTV }, { Attr: "ACT_LTV", value: ACT_LTV }, { Attr: "LI", value: LI }, { Attr: "GI", value: GI },
       { Attr: "LI_EMI", value: LI_EMI }, { Attr: "GI_EMI", value: GI_EMI }, { Attr: "LIGI_EMI", value: LIGI_EMI },
       { Attr: "ROI_CHANGE", value: ROI_CHANGE }
    ];

    if (LapArr.indexOf(productCode) >= 0) {
        AttrCreditInsert.push({ Attr: "IIR", value: FOIR });
    }
    else {
        AttrCreditInsert.push({ Attr: "FOIR", value: FOIR });
    }

    if (productCode == "HLTopup" || productCode == "LAPTopup" || productCode == "HLExt" || productCode == "HLImp") {
        var ltopLTV_A = Number($("#TOPUP_Fin_LTV_A [key='textval']").justtext());
        var ltopLTV_M = Number($("#TOPUP_Fin_LTV_M [key='textval']").justtext());
        AttrCreditInsert.push({ Attr: "TOPUP_LTV_A", value: ltopLTV_A });
        AttrCreditInsert.push({ Attr: "TOPUP_LTV_M", value: ltopLTV_M });
    }

    var notesOBJ = [];
    $(".subjective-div .sub-notes li").each(function () {
        var dt = $(this).find(".date").text();
        var note = $(this).find(".notes").text();
        var OBJ = { notes: note, date: dt };
        notesOBJ.push(OBJ);
    });


    var perc = $("#Fin_PF [key='rangeval']").val();
    var waiveramt = Number(FormatCleanComma($("#waiveramt").val()));
    waiveramt = waiveramt ? waiveramt : 0;
    var pfjson = [{ Attr: "PF", value: PFVAL, perc: perc, waiver: waiveramt }];

    var X_GlobalXml = GlobalXml;
    var emi = $("#Fin_EMI").find("[key='textval']").justtext();
    emi = FormatCleanComma(emi);
    emi = Number(emi) ? Number(emi) : 0;
    X_GlobalXml[0].EMI = emi;
    GlobalXml[0].SancRvnNo = window.SancRvnNo;
    X_GlobalXml[0].SancRvnNo = window.SancRvnNo;
    X_GlobalXml[0].isMoveNxt = isMoveNxt;
    X_GlobalXml[0].IsReject = IsReject;
    X_GlobalXml[0].CurApprover = ApproverLevel;
    X_GlobalXml[0].MaxApprover = MaxApproverLevel;    
    X_GlobalXml[0].waiverROI = waiverROI;

    var ManualDeviation = fnGetSelectedDeviation("DeviationDataDiv_ZC");
    if (ManualDeviation && ManualDeviation.length > 0) {
        var lvl = ManualDeviation[0].level;
        if (lvl == "") {
            fnShflAlert("warning", "Choose deviation level");
            return;
        }
        fnSaveManualDev_ZC();
    }

    var DetailsJson = {
        NotesJson: "", CreditJson: JSON.stringify(AttrCreditInsert),
        SubjectiveJSON: JSON.stringify(notesOBJ), PFJson: JSON.stringify(pfjson),
        CreditInJSON: JSON.stringify(CreditInput),
        ManualDeviation: ""
    };
    var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["INSERT_CREDIT_NEW", JSON.stringify(X_GlobalXml), JSON.stringify(DetailsJson)] };
    fnCallLOSWebService("INSERT_CREDIT", PrcObj, fnCreditOffResult, "MULTI");
}


function fnSetCreditInputParams(InputParams) {
    var I_LTV = InputParams[0].LTV;
    var I_FOIR = InputParams[0].FOIR;
    var I_LOAN = InputParams[0].LOAN;
    var I_ROI = InputParams[0].ROI;
    var I_TENURE = InputParams[0].TENURE;
    var I_TENURETOP = InputParams[0].TENURE_TOP || I_TENURE;

    $("#Prp_Loan2ValMrk").find("[key='textval']").attr("OrgVal", I_LTV);
    $("#Prp_Loan2ValMrk").find("[key='textval']").html('<span class="value" contenteditable="true">' + I_LTV + ' </span><span class="percentage"></span>');
    slider = $("#Prp_Loan2ValMrk").find("[key='rangeval']").data("ionRangeSlider");
    if (slider)
        slider.update({
            min: 0,
            max: parseInt(I_LTV) + 50,
            from: I_LTV,
            step: 0.01,
            onChange: fnOnchange,
            //onUpdate: fnOnchange
            onFinish: function () {
                fnSelectRemPF();
            }
        });


    // LOAN AMOUNT
    var loanAmt = I_LOAN;
    loanAmt = loanAmt.toFixed(2);
    $("#ElgLoanAmt").find("[key='textval']").attr("OrgVal", I_LOAN);
    $("#ElgLoanAmt").find("[key='textval']").html('<i class="icon-indian-rupee"></i><span class="value" contenteditable="true">' + FormatCurrency(loanAmt));
    $("#ElgLoanAmt").find("[key='rangetext']").val(loanAmt);
    slider = $("#ElgLoanAmt").find("[key='rangeval']").data("ionRangeSlider");
    if (slider)
        slider.update({
            min: 0,
            max: loanAmt * 3,
            from: loanAmt,
            step: 1,
            onChange: fnOnchange,
            //onUpdate: fnOnchange
            onFinish: function () {
                fnSelectRemPF();
            }
        });


    //ROI    
    $("#ElgLoanROI").find("[key='textval']").attr("orgval", I_ROI);
    $("#ElgLoanROI").find("[key='textval']").html('<span class="value" contenteditable="true">' + I_ROI + '</span><span class="percentage"></span>');
    slider = $("#ElgLoanROI").find("[key='rangeval']").data("ionRangeSlider");
    if (slider)
        slider.update({
            min: 10,
            max: 20,
            from: I_ROI,
            step: 0.01,
            onChange: fnOnchange,
            //onUpdate: fnOnchange
        });

    // FOIR
    var FOIRnew = I_FOIR;
    $("#IIRorFOIR").find("[key='textval']").html('<span class="value" contenteditable="true">' + FOIRnew + '</span><span class="percentage"></span>');
    $("#IIRorFOIR").find("[key='rangetext']").val(FOIRnew);
    slider = $("#IIRorFOIR").find("[key='rangeval']").data("ionRangeSlider");
    if (slider)
        slider.update({
            min: 10,
            max: 100,
            from: FOIRnew,
            step: 0.01,
            onChange: fnOnchange,
            //onUpdate: fnOnchange
            onFinish: function () {
                fnSelectRemPF();
            }
        });
    GLOB_CREDIT.TENURE = I_TENURE;
    $("#ElgTenure").find("[key='textval']").html('<span class="value" contenteditable="true">' + I_TENURE + '</span><span class="month"></span>');;
    $("#ElgTenure").find("[key='rangetext']").val(I_TENURE);
    slider = $("#ElgTenure").find("[key='rangeval']").data("ionRangeSlider");
    if (slider)
        slider.update({
            min: 10,
            max: 400,
            from: I_TENURE,
            onChange: fnOnchange,
            //onUpdate: fnOnchange
        });

    $("#ElgTenure_TOP").find("[key='textval']").html('<span class="value" contenteditable="true">' + I_TENURETOP + '</span><span class="month"></span>');;
    $("#ElgTenure_TOP").find("[key='rangetext']").val(I_TENURE);
    slider = $("#ElgTenure_TOP").find("[key='rangeval']").data("ionRangeSlider");
    if (slider)
        slider.update({
            min: 10,
            max: 400,
            from: I_TENURETOP,
            onChange: fnOnchange,
            //onUpdate: fnOnchange
        });

}

function fnGenerateCAM() {
    var objProcData = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["CHECK_SANCTION", JSON.stringify(GlobalXml)] }
    fnCallLOSWebService("CHECK_SANCTION", objProcData, fnCreditOffResult, "MULTI", "CAM");
}

function fnGenerateSanction() {    
    var objProcData = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["CHECK_SANCTION", JSON.stringify(GlobalXml)] }
    fnCallLOSWebService("CHECK_SANCTION", objProcData, fnCreditOffResult, "MULTI", "SANC");
}

function fnOpenCreditScreen_DDE(e, elem) {
    
    if (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
    }
    
    if (!window.DDE)
        window.DDE = 1;
    $("#credit-popup input[type=button]").hide();
    $("#credit-popup").show();
    $("#credit-popup").find(".popup-content").empty();
    $("#credit-popup").find(".popup-content").load("detail-data-entry.html", function () {
        GlobalXml[0].IsAll = "1";
    });

}

function fnOpenCreditScreen(e, elem) {
    if (e) {
        e.preventDefault();
        e.stopImmediatePropagation();
    }
        isDeviationTable = false;
    $("#credit-popup").find(".popup-content").empty();
    if (window.CREDIT_APPROVER_NO == 1 || window.CREDIT_APPROVER_NO == 3) 
        $("#credit-popup input[type=button]").show();
    else
        $("#credit-popup input[type=button]").hide();
        $("#credit-popup").show();        
    $("#credit-popup").find(".popup-content").load("customer-financials.html", function () { });
}

function fnCloseCredit() {
    $("#credit-popup").hide();
    $("#credit-popup").find(".popup-content").empty();
    if (IsBranchCredit && !isDeviationTable) {
        //var htmlnm = $("#div-user-content").attr("pagename");
        //LoadHtmlDiv(htmlnm);        
        fnSelectSummary();
    }
    $(".applicant-box").show();
    GlobalXml[0].IsAll = "0";
    $(".category-info .category-icons").click(function (e) {
        e.preventDefault();
    });
}


function fnCallBranchCredit() {
    IsBranchCredit = true;
    fnSaveFinancialData(true);
    //setTimeout(function () { fnCloseCredit(); }, 500);
}


function fnOmnipop() {
    $("#fold_nm").val(GlobalXml[0].LeadID);
    window.open("", "newWin", "location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,left=20,top=20,width=600,height=600");
    PostForm.submit();
}

function fnSetProductVariations(ExistingLoan) {
    ProductDiv = "";
    productCode = "";
    window.ISEXISTING_LOAN = false;
    if (ExistingLoan && ExistingLoan.length > 0) {
        window.ISEXISTING_LOAN = true;
        var PrdCode = ExistingLoan[0].PrdCode;
        remainingTenure = ExistingLoan[0].remaining;
        productCode = PrdCode;
        if (LapArr.indexOf(PrdCode) >= 0) {
            $("#IIRorFOIR h5").text("IIR");
            $("#Fin_FOIR h5").text("IIR");
            $("#BT_Fin_FOIR h5").text("IIR");
        }
        if (productCode == "HLBTTopup" || productCode == 'LAPBTTopup') {

            $("#BT_amt h5").text("BT LOAN");
            ProductDiv = "FOR-BT-TOP";
            $('[divfor="FOR-BT-TOP"]').show();
            $('[divfor="HL"]').hide();
            $('[divfor="FOR-BT-TOP"]').find("#BT_amt p[key=textval]").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(ExistingLoan[0].amount)));
            $('[divfor="FOR-BT-TOP"]').find("#BT_amt p[key=textval]").attr("orgval", Math.round(ExistingLoan[0].amount));
        }
        if (PrdCode == "HLBT" || PrdCode == "HLTopup" || PrdCode == 'LAPBT' || PrdCode == 'LAPTopup') {
            if (PrdCode == "HLTopup" || PrdCode == 'LAPTopup') {
                $("#Fin_LOAN h5").text("TOPUP LOAN");
                $("#Exst_LOAN").show();
            }
            if (PrdCode == "HLBT" || PrdCode == "LAPBT") {
                $("#Fin_LOAN h5").text("BT LOAN");
            }
            $("#Exst_LOAN p[key=textval]").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(ExistingLoan[0].amount)));
            $("#Exst_LOAN p[key=textval]").attr("orgval", Math.round(ExistingLoan[0].amount));

            $('[divfor="FOR-BT-TOP"]').hide();
            $('[divfor="HL"]').show();
            ProductDiv = "HL";
        }
        if (PrdCode == "HLExt" || PrdCode == "HLImp") {
            $("#Exst_LOAN").show();
            $("#Exst_LOAN p[key=textval]").html('<i class="icon-indian-rupee"></i>' + FormatCurrency(Math.round(ExistingLoan[0].amount)));
            $("#Exst_LOAN p[key=textval]").attr("orgval", Math.round(ExistingLoan[0].amount));
            ProductDiv = "HL";
            $('[divfor="FOR-BT-TOP"]').hide();
            $('[divfor="HL"]').show();
        }
    }
    else {
        window.ISEXISTING_LOAN = false;
        $('[divfor="FOR-BT-TOP"]').hide();
        $('[divfor="HL"]').show();
        ProductDiv = "HL";
        productCode = "HL";
    }
}


function fnBTfocusEvents() {
    $("#BT_TxtFin_LI").focusout(function () {
        
        var val = FormatCleanComma($(this).val());
        val = Number(val) ? Number(val) : 0;
        if (val == 0)
            $(this).val(0);
        var LoanAmt = Number(FormatCleanComma($("#BT_amt [key='textval']").justtext()));
        //LoanAmt = LoanAmt * 100000;

        var totAmt = LoanAmt + val;
        var Irate = Number($("#BT_Fin_ROI [key='textval']").justtext());

        var waiver = Number($("#RoiWaiver_BT").attr("val")) || 0;
        Irate = Number(Irate) + Number(waiver);

        var tenure = Number($("#ElgTenure [key='textval'] .value").justtext());
        if (tenure > 0 && Irate > 0 && totAmt > 0) {
            var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
            EmiVal = Math.round(EmiVal.toFixed(2));
            $("#BT_Fin_EMI_L").find("[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal));

            var LI = Number(FormatCleanComma($("#BT_TxtFin_LI").val()));
            var GI = Number(FormatCleanComma($("#BT_TxtFin_GI").val()));
            var Total_LG = Number(LoanAmt + LI + GI);
            var EMI_LG = CreditFormulas.PMT(Irate, tenure, Total_LG);
            EMI_LG = Math.round(EMI_LG.toFixed(2));
            $("#BT_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> ' + FormatCurrency(EMI_LG));
        }
        else {
            $("#BT_Fin_EMI_L").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0 ');
            $("#BT_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0');
        }

    });
    $("#BT_TxtFin_GI").focusout(function () {
        var val = FormatCleanComma($(this).val());
        val = Number(val) ? Number(val) : 0;
        if (val == 0)
            $(this).val(0);
        var LoanAmt = Number(FormatCleanComma($("#BT_amt [key='textval']").justtext()));
        //LoanAmt = LoanAmt * 100000;
        var totAmt = LoanAmt + val;
        var Irate = Number($("#BT_Fin_ROI [key='textval']").justtext());

        var waiver = Number($("#RoiWaiver_BT").attr("val")) || 0;
        Irate = Number(Irate) + Number(waiver);

        var tenure = Number($("#ElgTenure [key='textval'] .value").justtext());
        if (tenure > 0 && Irate > 0 && totAmt > 0) {
            var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
            EmiVal = Math.round(EmiVal.toFixed(2));
            $("#BT_Fin_EMI_G").find("[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal));

            var LI = Number(FormatCleanComma($("#BT_TxtFin_LI").val()));
            var GI = Number(FormatCleanComma($("#BT_TxtFin_GI").val()));
            var Total_LG = Number(LoanAmt + LI + GI);
            var EMI_LG = CreditFormulas.PMT(Irate, tenure, Total_LG);
            EMI_LG = Math.round(EMI_LG.toFixed(2));
            $("#BT_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> ' + FormatCurrency(EMI_LG));
        }
        else {
            $("#BT_Fin_EMI_G").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0 ');
            $("#BT_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0');
        }
    });
    $("#TOP_TxtFin_GI").focusout(function () {
        var val = FormatCleanComma($(this).val());
        val = Number(val) ? Number(val) : 0;
        if (val == 0)
            $(this).val(0);
        var LoanAmt = Number(FormatCleanComma($("#TOP_Fin_LOAN [key='textval']").justtext()));
        //LoanAmt = LoanAmt * 100000;
        var totAmt = LoanAmt + val;
        var Irate = Number($("#TOP_Fin_ROI [key='textval']").justtext());

        var waiver = Number($("#RoiWaiver_BT").attr("val")) || 0;
        //Irate = Number(Irate) + Number(waiver);
        Irate = Number(Irate);

        var tenure = Number($("#ElgTenure_TOP [key='textval'] .value").justtext());
        if (tenure > 0 && Irate > 0 && totAmt > 0) {
            var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
            EmiVal = Math.round(EmiVal.toFixed(2));
            $("#TOP_Fin_EMI_G").find("[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal));

            var LI = Number(FormatCleanComma($("#TOP_TxtFin_LI").val()));
            var GI = Number(FormatCleanComma($("#TOP_TxtFin_GI").val()));
            var Total_LG = Number(LoanAmt + LI + GI);
            var EMI_LG = CreditFormulas.PMT(Irate, tenure, Total_LG);
            EMI_LG = Math.round(EMI_LG.toFixed(2));
            $("#TOP_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> ' + FormatCurrency(EMI_LG));
        }
        else {
            $("#TOP_Fin_EMI_G").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0 ');
            $("#TOP_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0');
        }
    });
    $("#TOP_TxtFin_LI").focusout(function () {
        var val = FormatCleanComma($(this).val());
        val = Number(val) ? Number(val) : 0;
        if (val == 0)
            $(this).val(0);
        var LoanAmt = Number(FormatCleanComma($("#TOP_Fin_LOAN [key='textval']").justtext()));
        //LoanAmt = LoanAmt * 100000;
        var totAmt = LoanAmt + val;
        var Irate = Number($("#TOP_Fin_ROI [key='textval']").justtext());

        var waiver = Number($("#RoiWaiver_BT").attr("val")) || 0;
        //Irate = Number(Irate) + Number(waiver);
        Irate = Number(Irate);

        var tenure = Number($("#ElgTenure_TOP [key='textval'] .value").justtext());
        if (tenure > 0 && Irate > 0 && totAmt > 0) {
            var EmiVal = CreditFormulas.PMT(Irate, tenure, totAmt);
            EmiVal = Math.round(EmiVal.toFixed(2));
            $("#TOP_Fin_EMI_L").find("[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(EmiVal));

            var LI = Number(FormatCleanComma($("#TOP_TxtFin_LI").val()));
            var GI = Number(FormatCleanComma($("#TOP_TxtFin_GI").val()));
            var Total_LG = Number(LoanAmt + LI + GI);
            var EMI_LG = CreditFormulas.PMT(Irate, tenure, Total_LG);
            EMI_LG = Math.round(EMI_LG.toFixed(2));
            $("#TOP_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> ' + FormatCurrency(EMI_LG));
        }
        else {
            $("#TOP_Fin_EMI_L").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0 ');
            $("#TOP_Fin_EMI_LG").find("[key='textval']").html(' <i class="icon-indian-rupee"></i> 0');
        }
    });
}




/*Changes By Kani On 20/12/2016*/

function fnAgentspopup(elem) {
    
    if ($(elem).hasClass("bg8"))
    {
        return;
    }    
    var scrname = ''
    $('#agent_load_div').empty(); flag = 1; lapfk = 0; ServiceType = -1;
    lapfk = $(elem).parent("div.applicant-verification").attr("LapFk");
    scrname = $(elem).attr("name");
    if (scrname == "FIR") {
        ServiceType = 0;
        $("#agent_load_div").load("field-investigation.html");
        $("#agents-popup").show();
    }
    if (scrname == "FIO") {
        ServiceType = 1;
        $("#agent_load_div").load("field-investigation.html");
        $("#agents-popup").show();

    }
    if (scrname == "DV") {
        ServiceType = 2;
        $("#agent_load_div").load("document-verification.html");
        $("#agents-popup").show();

    }
    if (scrname == "CF") {
        ServiceType = 3;
        $("#agent_load_div").load("field-investigation.html");
        $("#agents-popup").show();

    }
    if (scrname == "LV") {
        ServiceType = 4;
        $("#agent_load_div").load("LegalManager.html");
        $("#agents-popup").show();

    }
    if (scrname == "TV") {
        ServiceType = 5;
        $("#agent_load_div").load("technical-Manager.html");
        $("#agents-popup").show();

    }
    GlobalXml[0].ServiceType = ServiceType;
}
//function fnOpenverfPopup() {
//    if (scrname == "LV") {
//        ServiceType = 4;
//        $("#agent_load_div").load("legal-verification.html");
//        $("#agents-popup").show();

//    }
//    if (scrname == "TV") {
//        ServiceType = 5;
//        $("#agent_load_div").load("technical-verification.html");
//        $("#agents-popup").show();

//    }

//}

function fnOnPopUpCust(PopObj) {
    
    $("#bc_Feedback_div_ZCPI input[name='text']").val("");
    $("#bc_Feedback_div_ZCPI textarea[name='text']").val("");
    $("#rptsts_ZCPI").attr("class", "icon-positive");
    $("#rptstsZCPI").closest("p.bg").attr("class", "bg bg1");
    $("#bc_Feedback_div_ZCPI input[key=pop_rptstatus]").val(2);
    $(".contact-details label").text("Details");
    $(".contact-details #ltv_Mob_ZCPI span").text("");
    $(".contact-details #ltv_Lnd_ZCPI span").text("");
    $("#PDfileList_ZCPI").empty();

    $("span.TVphNo").removeClass("active");
    $("span.TVphNo").css("color", "");
    var sel_Pop_typ = $(PopObj).attr("flag");
    Pk = $(PopObj).attr("pk");
    var LapFk;
    LapFk = $(PopObj).parent("div.applicant-verification").attr("LapFk");
    var PrcObj = { ProcedureName: "PrcShflCustFinancials", Type: "SP", Parameters: ["SELECT_FB_POP", JSON.stringify(CustFinGlobal), "", "", LapFk] }
    fnCallLOSWebService("SELECT_FB_POP", PrcObj, fnCreditOffResult, "MULTI", sel_Pop_typ);


}

function fnSelectFB_POP_ZCPI(type, teledata, pddata, TV_Ph) {    
    if (type == 1 || type == 3) {
        $("#mobnum_ZCPI").show();
        $("#bc_Feedback_div_ZCPI").attr("notetype", type);
        if (type == 1)
            $("#Feeback_title_ZCPI").text("Tele Verification - Office");
        else if (type == 3)
            $("#Feeback_title_ZCPI").text("Tele Verification - Residential");
        if (TV_Ph.length > 0) {
            if (type == 3) {
                $(".contact-details label").text("Contact Details");
                $(".contact-details #ltv_Mob_ZCPI span").text(TV_Ph[0].LapMob);
                $(".contact-details #ltv_Mob_ZCPI span").attr("PhNo", TV_Ph[0].LapMob);
                $(".contact-details #ltv_Lnd_ZCPI span").text(TV_Ph[0].LapRes);
                $(".contact-details #ltv_Lnd_ZCPI span").attr("PhNo", TV_Ph[0].LapRes);
                var althtml;
                if (TV_Ph[0].alterno != "") {
                    althtml = '<i class="icon-mobile"></i>Alternate No : <span class="TVphNo" PhNo="' + TV_Ph[0].alterno + '">' + TV_Ph[0].alterno + '</span></p>';
                    $(".contact-details #ltv_alter_ZCPI").html(althtml);
                }
                $(".contact-details #ltv_off_ZCPI").html("");
            }
            else if (type == 1) {
                $(".contact-details #ltv_alter_ZCPI").html("");
                $(".contact-details label").text("Contact Details");
                $(".contact-details #ltv_Mob_ZCPI span").text(TV_Ph[0].LapMob);
                $(".contact-details #ltv_Mob_ZCPI span").attr("PhNo", TV_Ph[0].LapMob);
                $(".contact-details #ltv_Lnd_ZCPI span").text(TV_Ph[0].LapRes);
                $(".contact-details #ltv_Lnd_ZCPI span").attr("PhNo", TV_Ph[0].LapRes);
                var offHTML = "";
                if (TV_Ph[0].OffNo != "")
                    offHTML = '<i class="icon-landline"></i>Office No : <span class="TVphNo" PhNo="' + TV_Ph[0].OffNo + '">' + TV_Ph[0].OffNo + '</span></p>';
                else
                    offHTML = '<i class="icon-landline"></i>Business No : <span class="TVphNo" PhNo="' + TV_Ph[0].BusNo + '">' + TV_Ph[0].BusNo + '</span></p>';
                $(".contact-details #ltv_off_ZCPI").html(offHTML);
            }
        }
        if (teledata.length > 0) {                    
            $("p.TVphNo").find("i").attr("style", "");
            $("span.TVphNo[PhNo=" + teledata[0].appnumber + "]").parent().find("i").css("color", "red")            
        }
        if (teledata.length > 0) {
            if (teledata[0].pop_rptstatus == 0) {
                $("#rptsts_ZCPI").attr("class", "icon-negative");
                $("#rptsts_ZCPI").closest("p").attr("class", "bg bg2");
            }
            else if (teledata[0].pop_rptstatus == 1) {
                $("#rptsts_ZCPI").attr("class", "icon-no-status");
                $("#rptsts_ZCPI").closest("p").attr("class", "bg bg7");
            }
            else if (teledata[0].pop_rptstatus == 2) {
                $("#rptsts_ZCPI").attr("class", "icon-positive");
                $("#rptsts_ZCPI").closest("p").attr("class", "bg bg1");
            }
            $("#spantele").attr("pk", teledata[0].LtvPk);
            $("#bc_Feedback_div_ZCPI").attr("notepk", teledata[0].LtvPk);
            fnSetValues("bc_Feedback_div_ZCPI", teledata);
            $("#bc_Feedback_div_ZCPI").show();
        }
        else {
            $("#bc_Feedback_div_ZCPI").attr("notepk", 0);
            $("#bc_RptDt_ZCPI").val("");
            $("#bc_RptRmks_ZCPI").val("");
        }

  
        $("#PDattachDiv_ZCPI").hide();
        $("#bc_Feedback_div_ZCPI").show();

    }
    else if (type == 2) {
        $("#Feeback_title_ZCPI").text("Personal Discussion");
        $("#bc_Feedback_div_ZCPI").attr("notetype", 2);
        $("#mobnum_ZCPI").hide();

        $("#PDattachDiv_ZCPI").show();

        if (TV_Ph.length > 0) {
            $(".contact-details label").text("Contact Details");
            $(".contact-details #ltv_Mob_ZCPI span").text(TV_Ph[0].LapMob);
            $(".contact-details #ltv_Lnd_ZCPI span").text(TV_Ph[0].LapRes);
        }
        if (pddata.length > 0) {
            if (pddata[0].pop_rptstatus == 0) {
                $("#rptsts_ZCPI").attr("class", "icon-negative");
                $("#rptsts").closest("p").attr("class", "bg bg2");

            }
            else if (pddata[0].pop_rptstatus == 1) {
                $("#rptsts_ZCPI").attr("class", "icon-no-status");
                $("#rptsts_ZCPI").closest("p").attr("class", "bg bg7");

            }
            else if (pddata[0].pop_rptstatus == 2) {
                $("#rptsts_ZCPI").attr("class", "icon-positive");
                $("#rptsts_ZCPI").closest("p").attr("class", "bg bg1");

            }
            $("#spanpd").attr("pk", pddata[0].LpdPk);
            $("#bc_Feedback_div_ZCPI").attr("notepk", pddata[0].LpdPk);

            var DocPath = pddata[0].filepath;
            $("#PDfileList_ZCPI").empty();
            if (DocPath && DocPath != '' && DocPath != null) {
                var n = DocPath.lastIndexOf("___") + 3;
                var docfiles = '<span pk="0" path="' + DocPath + '" ><i class="icon-attach"></i>' + DocPath.substr(n, DocPath.length) + '</span>';
                $("#PDfileList_ZCPI").append(docfiles);
            }

            fnSetValues("bc_Feedback_div_ZCPI", pddata);
            $("#bc_Feedback_div_ZCPI").show();



        } else {
            $("#bc_Feedback_div_ZCPI").attr("notepk", 0);
            $("#bc_RptDt_ZCPI").val("");
            $("#bc_RptRmks_ZCPI").val("");
        }
        $("#bc_Feedback_div_ZCPI").show();
    }
}
/*Changes By Kani On 20/12/2016*/
/*CHANGES ON 26/12/2016*/


/*CHANGES ON 26/12/2016*/


var pdfCount = 0;
var ReportService = getLocalStorage("PdfUrl");

function fnGenerateReport(type, refNo) {

    try { fnShowLOSProgress(); }
    catch (ex) { }

    var jsondata = {};
    var RepDetail = {};

    $.ajaxSetup({
        async: false
    });
       
    if (type == "CAM") {
        var HTMLObj = $.getJSON('ReportFiles/CamSheet/CamSample.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/CamSheet/CamSample.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "CAM_" + refNo + "_" + CustFinGlobal[0].LeadNm + ".json";
        RepDetail.Inputparam = JSON.stringify({ "@LeadFk": GlobalXml[0].FwdDataPk, "@BTTOPflag": refNo });
    }
    if (type == "RISK") {
        var HTMLObj = $.getJSON('ReportFiles/Risk Calculation Matrix/riskcalculation.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/Risk Calculation Matrix/riskcalculation.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "RISKCALC_" + CustFinGlobal[0].LeadNm + ".json";
        RepDetail.Inputparam = JSON.stringify({ "@LeadPk": GlobalXml[0].FwdDataPk });
    }

    if (type == "SANC") {
        var HTMLObj = $.getJSON('ReportFiles/SanctionLetter/SanctionSample.html');
        var HTMLtext = HTMLObj.responseText;
        RepDetail.HTML = HTMLtext;
        var JSONObj = $.getJSON('ReportFiles/SanctionLetter/SanctionSample.json');
        var JSONtext = JSONObj.responseText;
        RepDetail.DataJSON = JSONtext;
        RepDetail.FileName = "SANCTION_" + CustFinGlobal[0].LeadNm + ".json";
        var Gxml = GlobalXml;
        Gxml[0].sancNo = refNo;
        RepDetail.Inputparam = JSON.stringify({ "@Action": "PRINT_SANCTION", "@GlobalJson": JSON.stringify(Gxml) });
    }
    var DATAURL = ReportService + "JsonRender";    
    jsondata.RepDetail = RepDetail;    
    jQuery.support.cors = true;
    $.ajax({
        crossDomain: true,
        cache: false,
        type: "POST",
        url: DATAURL,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(jsondata),
        success: function (d) {

            try { fnRemoveLOSProgress(); }
            catch (ex) { }

            var resdata = JSON.parse(d.GenReportResult);
            if (resdata.Lst_ErrorLog != undefined) {
                fnShflAlert("error", resdata.Lst_ErrorLog[0].Message);
            }
            else {
                console.log(resdata);
                window.open(resdata, "_blankPDF" + pdfCount);
                pdfCount++;

            }
        },
        error: function (xhr, reason, ex) {

            try { fnRemoveLOSProgress(); }
            catch (ex) { }
            var err = $.parseJSON(xhr.responseText);
            if (err != null && xhr.status.toString() != "0") {
                fnShflAlert("error", 'Error Code : ' + xhr.status + "\nError Message :" + xhr.statusText);
            }
        }
    });


}


function fnOpenDeviationFatcors(type) {
    if (CREDIT_APPROVER_NO == 1 || CREDIT_APPROVER_NO == 3) {
        if (type == "INIT")
            return;

        var creditdata = fnOnchange({});
        var returnObj = fnLOSDeviation(creditdata);
        fnBuildDeviationTable(returnObj);
    }
    else {
        var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["DEVIATION_LIST", JSON.stringify(GlobalXml)] };
        fnCallLOSWebService("DEVIATION_LIST", PrcObj, fnCreditOffResult, "MULTI");
    }
}


var isDeviationTable = false;
function fnBuildDeviationTable(DevList) {
    isDeviationTable = true;
    $("#credit-popup .popup-content").empty();
    $("#credit-popup").show();
    $("#credit-popup input[type=button]").hide();
    if (DevList.length == 0)
        return;
    var maxApp = 5;
    var devTbl = "<table style='text-align: left;' border='0'> <tr><th>Stage</th><th>Deviation Factor</th><th>ApplicableTo</th><th>Status</th><th>Arrived</th><th style='display:none;'>Deviation</th><th style='display:none;'>Base</th>" +
        "<th>Approval Level</th><th>Remarks</th></tr>";
    for (var i = 0; i < DevList.length; i++) {
        devTbl += "<tr " + (DevList[i].status == "D" ? "style='color:red;'" : "") + " ><td>" + DevList[i].stage + "</td><td>" + DevList[i].AttrDesc + "</td><td>" + DevList[i].ApplicableTo + "</td><td>" + (DevList[i].status == "N" ? "No Deviation" : "Deviated") + "</td>" +
            "<td>" + DevList[i].Arrived + "</td><td style='display:none;'>" + DevList[i].Deviated + "</td><td style='display:none;'>" + DevList[i].baseval + "</td><td>Level " + DevList[i].approvedBy + "</td><td>" + DevList[i].remarks + "</td></tr>";
    }
    devTbl += "</table>";

    devTbl = $(devTbl);
    $(devTbl).find("td").css({ "padding": "5px 0px" });
    $("#credit-popup .popup-content").append(devTbl);

    var appUsr = [
         { level: 1, user: 'ZCA' },
         { level: 2, user: 'HO' },
         { level: 3, user: 'HCO' },
         { level: 4, user: 'COO' },
         { level: 5, user: 'MD' },
    ];
    var usrlist = "<table style='margin-top:50px;text-align: left;' border='0'> <tr><th>Level</th><th>Approver</th></tr>";
    for (var j = 0; j < maxApp; j++) {
        usrlist += "<tr><td>" + appUsr[j].level + "</td><td>" + appUsr[j].user + "</td></tr>";
    }
    usrlist += "</table>";

    usrlist = $(usrlist);
    $(usrlist).find("td").css({ "padding": "5px 0px" });
    $("#credit-popup .popup-content").append(usrlist);

}



function fnEditNotes(Notespk, elem,UsrPk) {
    Credit_Elem = elem;
    var notes = "";
    if (Notespk == 0) {
        Credit_Atr = "SUBJECTIVE";
        Credit_Elem = $(elem).closest("li").find(".notes");
        notes = $(elem).closest("li").find(".notes").text();
    }
    else {
        if (Number(UsrPk) != Number(GlobalXml[0].UsrPk))
        {
            fnShflAlert("warning", "Cannot edit the notes entered by other users");
            return;
        }
        Credit_Atr = "EDIT";
        editNotesPK = Notespk;
        notes = $(elem).closest("li[NotesPk=" + Notespk + "]").find(".notes").text();
    }
    $("#subjective-div").show();
    $("#Crd_Comment").val(notes);
    $("#subjective-div input[type=button]").val("UPDATE");
}


function fnChangeTopupTENURE() {
    setTimeout(function () {
        var topupTenure = $("#ElgTenure_TOP").find("[key='rangeval']").val();
        var topupROI = $("#TOP_Fin_ROI p[key=textval]").justtext();

        var waiver = Number($("#RoiWaiver_BT").attr("val")) || 0;        
        //topupROI = Number(topupROI) + Number(waiver);
        topupROI = Number(topupROI);

        var topupLoan = Number(FormatCleanComma($("#TOP_Fin_LOAN p[key=textval]").justtext()));        
        var income = Number(FormatCleanComma($("#NetIncome").find("p[key='textval_Inc']").justtext()));
        var BtEmi = Number(FormatCleanComma($("#BT_Fin_EMI p[key=textval]").justtext()));
        var obligations = Number(FormatCleanComma($("#NetIncome").find("p[key='textval_Obl']").justtext()));

        var TopupEMI = CreditFormulas.PMT(topupROI, topupTenure, topupLoan);
        TopupEMI = Math.round(TopupEMI);
        var FoirIIR;
        if (productCode == "HLBTTopup")
            FoirIIR = (((TopupEMI + BtEmi) + obligations) / income) * 100;
        if (productCode == "LAPBTTopup")
            FoirIIR = ((TopupEMI + BtEmi) / (income - obligations)) * 100;
        FoirIIR = FoirIIR.toFixed(2);

        $("#BT_Fin_FOIR p[key='textval']").html(FoirIIR + '<span class="percentage"></span>');
        $("#TOP_Fin_EMI").find("p[key='textval']").html(' <i class="icon-indian-rupee"></i>' + FormatCurrency(TopupEMI));

        $("#TOP_TxtFin_LI").focusout();
        $("#TOP_TxtFin_GI").focusout();
    }, 500);
}



function fnSelManualDev_ZC() {
    var PrcObj = { ProcedureName: "PrcShflManualDeviation", Type: "SP", Parameters: ["MANUALDEV_DATA", JSON.stringify(CustFinGlobal), "","C"] };
    fnCallLOSWebService("MANUALDEV_DATA", PrcObj, fnCreditOffResult, "MULTI");
}

function fnSaveManualDev_ZC() {
    fnSaveManualDeviation('DeviationDataDiv_ZC', 'C', fnCreditOffResult, 'ADD_MANUALDEV', CustFinGlobal);
}

function fnDisableAllInputs() {
    if (CREDIT_APPROVER_NO == 1 || CREDIT_APPROVER_NO == 3)
        return;
    var Inputs = $("input[type='text']");
    for (var i = 0; i < Inputs.length; i++) {
        $(Inputs[i]).attr("readonly","readonly")
        var slider = $(Inputs[i]).data("ionRangeSlider")
        if (slider) {
            slider.update({
                disable: true
            });
        }
    }

    var contenteditables = $("[contenteditable]");
    for (var j = 0; j < contenteditables.length; j++) {
        $(contenteditables[j]).attr("contenteditable",false);
        $(contenteditables[j]).removeAttr("contenteditable");
    }
    //$("textarea").attr("readonly", "readonly");
}

function fnDeleteSubj(elem) {
    if (confirm("Do you want to delete?"))
        $(elem).closest("li").remove();
}
$(document).on("click", "#Fin_PF_REC,#BT_Fin_PF_REC", function () {
    $("#CApf").show();
    $("#spn_title").html("PF Received Details");
    taxGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["CREDIT_TAX", JSON.stringify(taxGlobal)] };
    fnCallLOSWebService("TAX", PrcObj, fnCreditOffResult, "MULTI");
});

$(document).on("click", "#Fin_PF,#BT_Fin_PF", function () {
    $("#CApf").show();
    $("#spn_title").html("PF Details");
    taxGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    var PFvalue = parseInt(FormatCleanComma($(this).find("p").text()));
    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["CREDIT_TAX", JSON.stringify(taxGlobal), "", "", "", PFvalue] };
    fnCallLOSWebService("TAX", PrcObj, fnCreditOffResult, "MULTI");
});

$(document).on("click", "#Fin_REM_PF_REC,#BT_Fin_REM_PF_REC", function () {
    $("#CApf").show();
    $("#spn_title").html("Remaining PF Details");
    $(".totPF, .PFinst").hide();
    $(".RemPF").show();
    fnSelectRemPF();
});

function fnSelectRemPF() {
    
    var collectedPF = 0;
    var TotPF = 0;
    var TotPFid = ProductDiv == "HL" ? "Fin_PF" : "BT_Fin_PF";
    var CollectedPFid = ProductDiv == "HL" ? "Fin_PF_REC" : "BT_Fin_PF_REC";
    var waiverPFid = ProductDiv == "HL" ? "waiveramt" : "BT_waiveramt";
    var LeadFk = GlobalXml[0].FwdDataPk;
    TotPF = Number(FormatCleanComma($("#" + TotPFid + " p[key='textval']").justtext())).toFixed(2);
    collectedPF = Number(FormatCleanComma($("#" + CollectedPFid + " p[key='textval']").justtext())).toFixed(2);
    WaiverPF = Number(FormatCleanComma($("#" + waiverPFid).val())).toFixed(2);


    var PrcObj = { ProcedureName: "PrcSHFLRemPfCalc", Type: "SP", Parameters: [LeadFk, TotPF, collectedPF, WaiverPF] };
    fnCallLOSWebService("RemPF", PrcObj, fnCreditOffResult, "MULTI");
}


function fnSelectPFDetails() {
    
    taxGlobal[0].LeadFk = GlobalXml[0].FwdDataPk;
    var PrcObj = { ProcedureName: "PrcSHFLLosScan", Type: "SP", Parameters: ["CREDIT_TAX", JSON.stringify(taxGlobal)] };
    fnCallLOSWebService("TAX", PrcObj, fnCreditOffResult, "MULTI");
}

function fnApproveDeviations() {
    var PrcObj = { ProcedureName: "PrcShflCreditOff_new", Type: "SP", Parameters: ["APPROVE_DEVIATION", JSON.stringify(GlobalXml)] };
    fnCallLOSWebService("APPROVE_DEVIATION", PrcObj, fnCreditOffResult, "MULTI");
}