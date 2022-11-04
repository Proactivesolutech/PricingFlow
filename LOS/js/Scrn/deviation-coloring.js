// JavaScript source code

function isEqualTo(val,structure)
{

    for(a in structure)
    {
        if(structure[a] == val)
        {
            return true;
        }
    }
    return false;
}

function fnLOSDeviation(CreditData) {
    debugger;
    var DeviationObj = [];
    if (CreditData == "INIT") {
        fnOnchange({});
        return;
    }    
    var AppData = window.DevAppData;
    if (!AppData)
        return;
    /* 
        INPUT
            1. Applicants Details 
            2. Credit Details - ProductCode,IsProof,IncomeType,NETINCOME,IIR,FOIR,TENURE,LTV

        OUTPUT 
            1. Age Deviation
            2. FOIR/ IIR Deviation
            3. LTV Deviation
            4. Income Deviation
        
    */
    var MARGIN_VAL = 0;
    var isIIRDeviation,isFOIRDeviation, ApprovedBy, IIRDeviation, isLTVDeviation, LTVDeviation;
    try {

        var ProductCode = CreditData.PRD_CODE, IsProof = CreditData.SAL_PROOF ? 0 : 1,
            IncomeType = CreditData.SALARY_TYPE == "SAL" ? "S" : CreditData.SALARY_TYPE == "SELF" ? "SE" : "",
            NETINCOME = CreditData.INCOME,
            IIR = (CreditData.IIR || 0).toFixed(2),
            FOIR = (CreditData.FOIR || 0).toFixed(2),
            TENURE = CreditData.TENURE, TENUREinYEARS = CreditData.TENURE / 12,

            // LTV for Normal
            LTV = (Number(CreditData.LTV) || 0).toFixed(2),
            LTV_M = Number(CreditData.LTV_M) || 0,
            LTV_A = Number(CreditData.LTV_A) || 0,
            // LTV for Topup
            TOPUP_LTV = CreditData.TOPUP_LTV_A == 0 ? CreditData.TOPUP_LTV_M : Math.min(CreditData.TOPUP_LTV_M, CreditData.TOPUP_LTV_A) || 0,
            TOPUP_LTV_M = Number(CreditData.TOPUP_LTV_M) || 0,
            TOPUP_LTV_A = Number(CreditData.TOPUP_LTV_A) || 0,
            // LTV for BT
            BT_LTV = CreditData.BT_LTV_A == 0 ? CreditData.BT_LTV_M : Math.min(CreditData.BT_LTV_M, CreditData.BT_LTV_A) || 0,
            BT_LTV_M = Number(CreditData.BT_LTV_M) || 0,
            BT_LTV_A = Number(CreditData.BT_LTV_A) || 0;

        if (isEqualTo(ProductCode, ['HLExt', 'HLImp'])) {
            LTV = LTV_M;
        }

        var MrkorAct = 'M';
        // choose max LTV percentage or Min Prop value
        if (LTV_A != 0)
        {
            if (LTV_A > LTV_M)
                MrkorAct = 'A';
            LTV = Math.max(LTV_A, LTV_M);
        }
        if (BT_LTV_A != 0)
        {
            if (BT_LTV_A > BT_LTV_M)
                MrkorAct = 'A';
            BT_LTV = Math.max(BT_LTV_A, BT_LTV_M);
        }
        if (TOPUP_LTV_A != 0)
        {
            if (TOPUP_LTV_A > TOPUP_LTV_M)
                MrkorAct = 'A';
            TOPUP_LTV = Math.max(TOPUP_LTV_A, TOPUP_LTV_M);
        }

        var isIIR_FOIR = 'F';
        //LTV: ARR_LTV,LTV_M: MrkLTV, LTV_A: AgrLTV, BT_LTV_A: BT_LTV_A, TOPUP_LTV_A: TOPUP_LTV_A, BT_LTV_M: BT_LTV_M, TOPUP_LTV_M: TOPUP_LTV_M

        /* --------------------------------- IIR DEVIATIONS -------------------------------------- */
        MARGIN_VAL = 0
        if (LapArr.indexOf(ProductCode) >= 0) {
            isIIR_FOIR = 'I';

            isIIRDeviation = 'N';            
            if (NETINCOME >= 10000 && NETINCOME <= 15000) {
                MARGIN_VAL = 40

                if (IIR <= 40)
                    isIIRDeviation = 'N'
                else
                    isIIRDeviation = 'D'
            }
            else if (NETINCOME >= 15001 && NETINCOME <= 30000) {
                MARGIN_VAL = 45

                if (IIR <= 45)
                    isIIRDeviation = 'N'
                else
                    isIIRDeviation = 'D'
            }
            else if (NETINCOME > 30000) {
                MARGIN_VAL = 50

                if (IIR <= 50)
                    isIIRDeviation = 'N'
                else
                    isIIRDeviation = 'D'
                            
                IIRDeviation = 0

                if (isIIRDeviation == 'D')
                    IIRDeviation = (NETINCOME >= 10000 && NETINCOME <= 15000) ? IIR - 40 : (NETINCOME >= 15001 && NETINCOME <= 30000) ? IIR - 45 :
                                    NETINCOME > 30000 ? IIR - 50 : 0;
            }

            ApprovedBy = 1

            if (IIRDeviation != 0) {
                if (Math.abs(IIRDeviation) <= 5)
                    ApprovedBy = 3
                else if (Math.abs(IIRDeviation) > 5)
                    ApprovedBy = 4
            }
            var iirDiv = "";
            if (ProductDiv == "HL")            
                iirDiv = $("#Fin_FOIR");
            else
                iirDiv = $("#BT_Fin_FOIR");

            $(iirDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

            if (isIIRDeviation == 'D') {
                $(iirDiv).addClass("bg2");
                $(iirDiv).attr("title", "IIR Deviated, Should be approved by Level " + ApprovedBy);
            }
            if (isIIRDeviation == 'N') {
                $(iirDiv).addClass("bg1");
                $(iirDiv).attr("title", "");
            }
            $(iirDiv).attr("AprvLevel", ApprovedBy);

            var obj = {
                stage: 'C', AttrDesc: 'IIR', ApplicableTo: 'General'
                , status: isIIRDeviation, Arrived: IIR, approvedBy: ApprovedBy, remarks: '', Deviated: '', baseval: ''
            };
            DeviationObj.push(obj);
        }        

            /* --------------------------------- IIR DEVIATIONS -------------------------------------- */

            /*------------------------------- FOIR DEVIATIONS  --------------------------------------*/
        else if (FOIR != 0) {
            MARGIN_VAL = 0;
            isIIR_FOIR = 'F';
            if (NETINCOME >= 0 && NETINCOME <= 30000) {
                MARGIN_VAL = 50;

                if (FOIR <= 50)
                    isFOIRDeviation = 'N';
                else
                    isFOIRDeviation = 'D';
            }
            else if (NETINCOME > 30000) {
                MARGIN_VAL = 60;
                if (FOIR <= 60)
                    isFOIRDeviation = 'N';
                else
                    isFOIRDeviation = 'D';
            }

            FOIRDeviation = 0;

            if (isFOIRDeviation == 'D') {
                FOIRDeviation = (NETINCOME >= 0 && NETINCOME <= 30000) ? FOIR - 50 : (NETINCOME > 30000) ? FOIR - 60 : 0;
            }

            ApprovedBy = 1

            if (FOIRDeviation != 0) {
                if (Math.abs(FOIRDeviation) <= 5)
                    ApprovedBy = 2
                else if (Math.abs(FOIRDeviation) <= 10)
                    ApprovedBy = 3
                else if (Math.abs(FOIRDeviation) > 10)
                    ApprovedBy = 4
            }

            var iirDiv = "";
            if (ProductDiv == "HL")
                iirDiv = $("#Fin_FOIR");
            else
                iirDiv = $("#BT_Fin_FOIR");

            $(iirDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

            if (isFOIRDeviation == 'D') {
                $(iirDiv).addClass("bg2");
                $(iirDiv).attr("title", "IIR Deviated, Should be approved by Level " + ApprovedBy);
            }
            if (isFOIRDeviation == 'N') {
                $(iirDiv).addClass("bg1");
                $(iirDiv).attr("title", "");
            }
            $(iirDiv).attr("AprvLevel", ApprovedBy);

            var obj = {
                stage: 'C', AttrDesc: 'FOIR', ApplicableTo: 'General'
            , status: isFOIRDeviation, Arrived: FOIR, approvedBy: ApprovedBy, remarks: '', Deviated: '', baseval: ''
            };
            DeviationObj.push(obj);

        }

        /*------------------------------- FOIR DEVIATIONS  --------------------------------------*/

        /*-------------------------------LTV DEVIATIONS-----------------------------*/
        if (LTV != 0) {

            LTVDeviation = 0, MARGIN_VAL = 0;

            // LAP            
            if (isEqualTo(ProductCode, ['LAPCom'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 50;

                    if (LTV <= 50) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 50 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 50;

                    if (LTV <= 50) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 50 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }
            // LAP            
            if (isEqualTo(ProductCode, ['LAPResi', 'LAPCom'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 60;

                    if (LTV <= 60) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 60 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 60;

                    if (LTV <= 60) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 60 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }
            // PLOT
            if (isEqualTo(ProductCode, ['PL'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 75;

                    if (LTV <= 75) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 75 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 70;

                    if (LTV <= 70) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }

            // NEW && RESALE
            if (isEqualTo(ProductCode, ['HLNew', 'HLResale'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 80;                    
                    if (LTV <= 80) {
                        isLTVDeviation = 'N', LTVDeviation = 0;                        
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 80 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 70;

                    if (LTV <= 70) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }
            // BALANCE TRANSFER
            if (isEqualTo(ProductCode, ['HLBT', 'LAPBT'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 75;

                    if (LTV <= 75) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 75 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 70;

                    if (LTV <= 70) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }
            // TOPUP  
            if (isEqualTo(ProductCode, ['HLTopup', 'LAPTopup'])) {
                isLTVDeviation = 'N';

                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");
                var topupLTVDiv = MrkorAct == 'A' ? $("#TOPUP_Fin_LTV_A") : $("#TOPUP_Fin_LTV_M");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(topupLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (LTV <= 50) {

                }

                if (TOPUP_LTV <= 50) {
                    if (IsProof == 0) {
                        MARGIN_VAL = 75;

                        if (LTV <= 75) {
                            isLTVDeviation = 'N';
                            $(LtvDiv).addClass("bg1");
                        }
                        else {
                            isLTVDeviation = 'D', MARGIN_VAL = 75, LTVDeviation = 75 - LTV;
                            $(LtvDiv).addClass("bg2");
                        }
                    }
                    else if (IsProof == 1) {
                        MARGIN_VAL = 70

                        if (LTV <= 70) {
                            isLTVDeviation = 'N';
                            $(LtvDiv).addClass("bg1");
                        }
                        else {
                            isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                            $(LtvDiv).addClass("bg2");
                        }
                    }
                    $(topupLTVDiv).addClass("bg1");
                }
                else {
                    isLTVDeviation = 'D', MARGIN_VAL = 50, LTVDeviation = 50 - TOPUP_LTV;
                    $(topupLTVDiv).addClass("bg2");

                    if (IsProof == 0) {
                        MARGIN_VAL = 75;

                        if (LTV <= 75) {
                            isLTVDeviation = 'N';
                            $(LtvDiv).addClass("bg1");
                        }
                        else {
                            isLTVDeviation = 'D', MARGIN_VAL = 75, LTVDeviation = 75 - LTV;
                            $(LtvDiv).addClass("bg2");
                        }
                    }
                    else if (IsProof == 1) {
                        MARGIN_VAL = 70

                        if (LTV <= 70) {
                            isLTVDeviation = 'N';
                            $(LtvDiv).addClass("bg1");
                        }
                        else {
                            isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                            $(LtvDiv).addClass("bg2");
                        }
                    }

                }
            }

            // BT + TOPUP 
            if (isEqualTo(ProductCode, ['HLBTTopup', 'LAPBTTopup'])) {
                isLTVDeviation = 'N';

                var LtvDiv = MrkorAct == 'A' ? $("#BT_Fin_LTV_A") : $("#BT_Fin_LTV");
                var topupLTVDiv = MrkorAct == 'A' ? $("#TOPUP_LTV_A") : $("#TOPUP_LTV_M");
                var BtLTVDiv = MrkorAct == 'A' ? $("#BT_LTV_A") : $("#BT_LTV_M");
                
                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(topupLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(BtLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 50;

                    if (BT_LTV <= 50) {
                        isLTVDeviation = 'N' ;
                        $(BtLTVDiv).addClass("bg1");

                        if (TOPUP_LTV <= 75) {
                            isLTVDeviation = 'N';
                            $(topupLTVDiv).addClass("bg1");
                        }
                        else {
                            isLTVDeviation = 'D', MARGIN_VAL = 75, LTVDeviation = 75 - TOPUP_LTV;
                            $(topupLTVDiv).addClass("bg2");
                        }                        
                    }
                    else {
                        isLTVDeviation = 'D', MARGIN_VAL = 50, LTVDeviation = 50 - BT_LTV                        
                        $(BtLTVDiv).addClass("bg2");
                    }

                    if (LTV <= 75) {
                        isLTVDeviation = 'N';
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', MARGIN_VAL = 75, LTVDeviation = 75 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }

                }
                else if (IsProof == 1) {
                    if (BT_LTV <= 50) {
                        MARGIN_VAL = 50

                        isLTVDeviation = 'N';
                        $(BtLTVDiv).addClass("bg1");

                        if (TOPUP_LTV <= 70) {
                            isLTVDeviation = 'N', MARGIN_VAL = 50;
                            $(topupLTVDiv).addClass("bg1");
                        }
                        else {
                            isLTVDeviation = 'D', MARGIN_VAL = 50, LTVDeviation = 50 - TOPUP_LTV;
                            $(topupLTVDiv).addClass("bg2");
                        }                       
                    }
                    else {
                        isLTVDeviation = 'D', MARGIN_VAL = 50, LTVDeviation = 50 - LTV
                        $(BtLTVDiv).addClass("bg2");
                    }

                    if (LTV <= 70) {
                        isLTVDeviation = 'N';
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', MARGIN_VAL = 70, LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }

                }
            }
            // IMPROVEMENT
            if (isEqualTo(ProductCode, ['HLImp'])) {

                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");
                var topupLTVDiv = MrkorAct == 'A' ? $("#TOPUP_Fin_LTV_A") : $("#TOPUP_Fin_LTV_M");
                var BtLTVDiv = MrkorAct == 'A' ? $("#BT_LTV_A") : $("#BT_LTV_M");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(topupLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(BtLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (ISEXISTING_LOAN && TOPUP_LTV != 0) {
                    if (LTV > 70) {
                        isLTVDeviation = 'D', MARGIN_VAL = 70, LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    } else { $(LtvDiv).addClass("bg1"); }
                    if (TOPUP_LTV > 50) {
                        isLTVDeviation = 'D', MARGIN_VAL = 50, LTVDeviation = 50 - TOPUP_LTV;
                        $(topupLTVDiv).addClass("bg2");
                    }
                    else { isLTVDeviation = 'N'; $(topupLTVDiv).addClass("bg1"); }
                }
                else {
                    MARGIN_VAL = 70;

                    if (LTV <= 70) {
                        isLTVDeviation = 'N';
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;;
                        $(LtvDiv).addClass("bg2");
                    }
                }

            }
            // EXTENSION
            if (isEqualTo(ProductCode, ['HLExt'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");
                var topupLTVDiv = MrkorAct == 'A' ? $("#TOPUP_Fin_LTV_A") : $("#TOPUP_Fin_LTV_M");
                var BtLTVDiv = MrkorAct == 'A' ? $("#BT_LTV_A") : $("#BT_LTV_M");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(topupLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $(BtLTVDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (ISEXISTING_LOAN && TOPUP_LTV != 0) {
                    if (LTV > 70) {
                        isLTVDeviation = 'D', MARGIN_VAL = 70, LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    } else { $(LtvDiv).addClass("bg1"); }
                    if (TOPUP_LTV > 50) {
                        isLTVDeviation = 'D', MARGIN_VAL = 50, LTVDeviation = 50 - TOPUP_LTV;
                        $(topupLTVDiv).addClass("bg2");
                    }
                    else { isLTVDeviation = 'N'; $(topupLTVDiv).addClass("bg1"); }
                }
                else {
                    MARGIN_VAL = 70

                    if (LTV <= 70) {
                        isLTVDeviation = 'N';
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }
            // SELF CONSTRUCTION
            if (isEqualTo(ProductCode, ['HLConst'])) {

                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");                

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");                

                if (IsProof == 0) {
                    MARGIN_VAL = 80;

                    if (LTV <= 80) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 80 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 70;

                    if (LTV <= 70) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }

            }
            // PLOT + CONSTRUCTION
            if (isEqualTo(ProductCode, ['HLPltConst'])) {
                var LtvDiv = MrkorAct == 'A' ? $("#Fin_LTV_A") : $("#Fin_LTV");

                $(LtvDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");

                if (IsProof == 0) {
                    MARGIN_VAL = 80

                    if (LTV <= 80) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 80 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
                else if (IsProof == 1) {
                    MARGIN_VAL = 70

                    if (LTV <= 70) {
                        isLTVDeviation = 'N', LTVDeviation = 0;
                        $(LtvDiv).addClass("bg1");
                    }
                    else {
                        isLTVDeviation = 'D', LTVDeviation = 70 - LTV;
                        $(LtvDiv).addClass("bg2");
                    }
                }
            }

            ApprovedBy = 1

            LTVDeviation = 0

            if (isLTVDeviation == 'D')
                ApprovedBy = 4;
            
        }

        var obj = {
            stage: 'C', AttrDesc: 'LTV', ApplicableTo: 'General'
            , status: isLTVDeviation, Arrived: LTV, approvedBy: ApprovedBy, remarks: '', Deviated: '', baseval: ''
        };
        DeviationObj.push(obj);

        /*-------------------------------LTV DEVIATIONS-----------------------------*/

        $("#NetIncome").attr("isDev", "N");

        var AppCount = AppData.length;
        var Loopcount = 0;
        var ArrAgeVAL;
        while (AppCount > Loopcount) {
            isAgeDeviation = 'N', AgeDeviation = 0;
            // SELECT THE ROW
            var TempAppTable = AppData[Loopcount];
             
            // GET THE VALUES OF THE ROW IN VARIABLES 
            var Age = TempAppTable.AgeatLogin, AgeMature = Number(TempAppTable.AgeatLogin) + Number(TENUREinYEARS)
                , income = TempAppTable.income,
                IncomeType = TempAppTable.incometype, Financier = TempAppTable.IncConsider, LapFk = TempAppTable.LapFk,
                BusinessAvg = TempAppTable.BusinessAvg, CashAvg = TempAppTable.CashAvg, SalIncome = TempAppTable.SalIncome,
                    Actor = TempAppTable.Actor, obligation = TempAppTable.obligations;

            IncomeType = IncomeType.trim();
            var sumaarydiv = $(".applicant-box.box-div[lapfk=" + LapFk + "]");
            var agebox = $(sumaarydiv).find("span[name='AGE']");

            /*-------------------- AGE DEVIATION ----------------------*/
            MARGIN_VAL = 21

            if ((IncomeType == 'S' && Financier == 'YES' && Age >= 21 && AgeMature <= 60) ||
                (IncomeType == 'S' && Financier == 'NA' && Age >= 18 && AgeMature <= 60) ||
                (IncomeType == 'SE' && Financier == 'YES' && Age >= 21 && AgeMature <= 65) ||
                (IncomeType == 'SE' && Financier == 'NA' && Age >= 18 && AgeMature <= 65) ||
                (IncomeType == '-'  && Age >= 18 && AgeMature <= 60) )
            {
                
                isAgeDeviation = 'N';
            }
            else {
                isAgeDeviation = 'D';
            }

            ArrAgeVAL = Age;

            if (isAgeDeviation == 'D') {

                if (IncomeType == 'S' && Financier == 'YES') {
                    if (Age < 21)
                        ArrAgeVAL = Age, MARGIN_VAL = 21;
                    else if (AgeMature > 60)
                        ArrAgeVAL = AgeMature, MARGIN_VAL = 60;
                }
                if (IncomeType == 'S' && Financier == 'NA') {
                    if (Age < 18)
                        ArrAgeVAL = Age, MARGIN_VAL = 18;
                    else if (AgeMature > 60)
                        ArrAgeVAL = AgeMature, MARGIN_VAL = 60;
                }
                if (IncomeType == 'SE' && Financier == 'YES') {
                    if (Age < 21)
                        ArrAgeVAL = Age, MARGIN_VAL = 21;
                    else if (AgeMature > 65)
                        ArrAgeVAL = AgeMature, MARGIN_VAL = 65;
                }
                if (IncomeType == 'SE' && Financier == 'NA') {
                    if (Age < 18)
                        ArrAgeVAL = Age, MARGIN_VAL = 18;
                    else if (AgeMature > 65)
                        ArrAgeVAL = AgeMature, MARGIN_VAL = 65;
                }

                if (IncomeType == '-') {
                    if (Age < 18)
                    {
                        ArrAgeVAL = Age, MARGIN_VAL = 18;
                    }
                    else if (AgeMature > 60) {
                        ArrAgeVAL = AgeMature, MARGIN_VAL = 60;
                    }
                }

                AgeDeviation = (IncomeType == 'S' && Financier == 'YES' && Age < 21) ? Age - 21 :
                (IncomeType == 'S' && Financier == 'YES' && AgeMature > 60) ? AgeMature - 60 :
                (IncomeType == 'S' && Financier == 'NA' && Age < 18) ? Age - 18 :
                (IncomeType == 'S' && Financier == 'NA' && AgeMature > 60) ? AgeMature - 60 :
                (IncomeType == 'SE' && Financier == 'YES' && Age < 21) ? Age - 21 :
                (IncomeType == 'SE' && Financier == 'YES' && AgeMature > 65) ? AgeMature - 65 :
                (IncomeType == 'SE' && Financier == 'NA' && Age < 18) ? Age - 18 :
                (IncomeType == 'SE' && Financier == 'NA' && AgeMature > 65) ? AgeMature - 65 :
                (IncomeType == '-' && Age < 18) ? Age - 18 :
                (IncomeType == '-' && AgeMature > 60) ? Age - 60 : 0;
            }
            else {
                ArrAgeVAL = Age;
            }

            //UPDATE	#AppData  isAgeDeviation = isAgeDeviation ,AgeDeviation = AgeDeviation 
            //WHERE	LapFk = LapFk				

            ApprovedBy = 1

            if (AgeDeviation != 0) {
                if (Math.abs(AgeDeviation) <= 2)
                    ApprovedBy = 1;
                if (Math.abs(AgeDeviation) <= 5)
                    ApprovedBy = 3;
                if (Math.abs(AgeDeviation) > 5)
                    ApprovedBy = 4;
            }

            agebox.removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
            if (isAgeDeviation == 'D') {
                $(agebox).addClass("bg2");
                $(agebox).attr("title", "Age Deviated, Should be approved by Level " + ApprovedBy);
            }
            if (isAgeDeviation == 'N') {
                $(agebox).addClass("bg1");
                $(agebox).attr("title", "");
            }
            
            var obj = {
                stage: 'C', AttrDesc: 'AGE', ApplicableTo: (Actor == 0 ? 'Applicant' : Actor == 1 ? 'CoApplicant' : Actor == 2 ? 'Guarantor' : '')
            , status: isAgeDeviation, Arrived: ArrAgeVAL, approvedBy: ApprovedBy, remarks: '', Deviated: '', baseval: ''
            };
            DeviationObj.push(obj);

            /*-------------------- AGE DEVIATION ----------------------*/


            /*-------------------- INCOME DEVIATION ----------------------*/

            MARGIN_VAL = 7500;
            var incomeDiv = $(sumaarydiv).find(".applicant-amount");
            isIncomeDeviation = 'N';            

            if (Financier == 'YES') {
                if ((IncomeType == 'S' && isIIR_FOIR == 'I' && (SalIncome - obligation) >= 7500) ||
                    (IncomeType == 'S' && isIIR_FOIR == 'F' && SalIncome >= 7500) ||
                    (IncomeType == 'SE' && isIIR_FOIR == 'I' && IsProof == 0 && BusinessAvg - obligation >= 120000) ||
                    (IncomeType == 'SE' && isIIR_FOIR == 'F' && IsProof == 0 && BusinessAvg  >= 120000) ||
                    //(IncomeType == 'SE' && isIIR_FOIR == 'I' && IsProof == 1 && CashAvg-obligation >= 10000) ||
                    //(IncomeType == 'SE' && isIIR_FOIR == 'F' && IsProof == 1 && CashAvg >= 10000) ||
                    (IncomeType == 'SE' && IsProof == 1) ||
                    (IncomeType == '-' && isIIR_FOIR == 'I' && income-obligation >= 7500) ||
                    (IncomeType == '-' && isIIR_FOIR == 'F' && income >= 7500)
                    )
                    isIncomeDeviation = 'N';
                else
                    isIncomeDeviation = 'D';
            }

            ApprovedBy = 1;
            IncomeDeviation = 0;
            if (isIncomeDeviation == 'D') {
                IncomeDeviation = (IncomeType == 'S' && isIIR_FOIR == 'I') ? (SalIncome - obligation) - 7500 : (IncomeType == 'S' && isIIR_FOIR == 'F') ? SalIncome - 7500 :
                    (IncomeType == 'SE' && isIIR_FOIR == 'I') ? BusinessAvg - obligation - 120000 : (IncomeType == 'SE' && isIIR_FOIR == 'F') ? BusinessAvg - 120000 :
                    (IncomeType == '-' && isIIR_FOIR == 'I') ? income - obligation - 7500 :
                    (IncomeType == '-' && isIIR_FOIR == 'F') ? income - 7500 : 0;
                
                ApprovedBy = 4;              
            }

            MARGIN_VAL = (IncomeType == 'S') ? 7500 : (IncomeType == 'SE' && IsProof == 0) ? 120000 : (IncomeType == 'SE' && IsProof == 1) ? 10000 : IncomeType == '-' ? 7500 : 0;
            
            $(incomeDiv).removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
            if (isIncomeDeviation == 'D') {
                $(incomeDiv).addClass("bg2");
                $("#NetIncome").attr("isDev", "Y");
                $(incomeDiv).attr("title", (Actor == 0 ? "Applicant's" : Actor == 1 ? "CoApplicant's" : Actor == 2 ? "Guaranter's " : "") + " Income Deviated, Should be approved by Level " + ApprovedBy);
            }
            if (isIncomeDeviation == 'N') {
                $(incomeDiv).addClass("bg1");
                $(incomeDiv).attr("title", "");
            }

            var incomeAppLvl = Number($("#NetIncome").attr("AprvLevel")) || 0;
            //if (ApprovedBy > incomeAppLvl) {
            if ($("#NetIncome").attr("isDev") == "Y") {
                $("#NetIncome").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $("#NetIncome").addClass("bg2");
            } else {
                $("#NetIncome").removeClass("bg1 bg2 bg3 bg4 bg5 bg6 bg7 bg8");
                $("#NetIncome").addClass("bg1");
                $("#NetIncome").attr("title", "");
                $("#NetIncome").attr("AprvLevel", ApprovedBy);
            }
            //}
            

            var obj = {
                stage: 'C', AttrDesc: 'INCOME', ApplicableTo: (Actor == 0 ? 'Applicant' : Actor == 1 ? 'CoApplicant' : Actor == 2 ? 'Guarantor' : '')
            , status: isIncomeDeviation, Arrived:
                (IncomeType == 'S' ? FormatCurrency(SalIncome) : IncomeType == 'SE' && IsProof == 0 ? FormatCurrency(BusinessAvg) : IncomeType == 'SE' && IsProof == 1 ? FormatCurrency(CashAvg) : FormatCurrency(income))
                , approvedBy: ApprovedBy, remarks: '', Deviated: '', baseval: ''
            };
            DeviationObj.push(obj);


            /*-------------------- INCOME DEVIATION ----------------------*/

            Loopcount++;
        }
        //WHILE LOOP 

        return DeviationObj;

    }
    catch (e) {
        console.log(e);
        return [];
    }
}