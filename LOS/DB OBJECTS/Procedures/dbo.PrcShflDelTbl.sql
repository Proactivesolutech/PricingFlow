IF EXISTS(SELECT NULL FROM sysobjects WHERE name='Prcshfldeltbl' AND [type]='P')
	DROP PROC Prcshfldeltbl
GO
CREATE PROCEDURE Prcshfldeltbl (@Action VARCHAR(100),@LeadPk BIGINT = NULL) 
AS 
  BEGIN 
      IF @Action = 'S' 
        BEGIN 
            --LEAD-- 
            SELECT	LedPk,LedId,ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') LedAgtNm,LedBGeoFk,LedNm,LedDOB,
					LedPrdFk,LedEmpCat,LedMrktVal,LedPrvLnCrd,LedLnAmt,LedTenure,LedDflt,LedMonInc,LedIncPrf,LedMonObli,LedCIBILScr,LedEMI,LedROI,
					LedPk 
            FROM	LosLead (NOLOCK) 
            JOIN	GenAgents(NOLOCK) ON AgtPk = LedAgtFk AND AgtDelid = 0
            WHERE	LedPk = @LeadPk AND	LedDelId = 0 			

            --SCAN-- 
            SELECT	DocLedFk,ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') DocAgtNm,DocBGeoFk,DocPrdFk,DocActor,
					DocCat,DocSubCat,DocNm, DocPath,DocPk 
            FROM	LosDocument (NOLOCK) 
            JOIN	GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
            WHERE	DocLedFk = @LeadPk AND DocDelId = 0             

            --QDE-- 
            SELECT	QDELedFk,QDEBGeoFk,QDEPrdFk,QDEActor,QDEFstNm,QDEMdNm,QDELstNm,QDEGender,QDEDOB,QDEAadhar,QDEPAN,QDEDrvLic,QDEVoterId,QDEActorNm,
					QDEFthFstNm,QDEFthMdNm,QDEFthLstNm,QDEPassNum,QdeCusFk,QDEPk 
            FROM	LosQDE (NOLOCK) 
            WHERE	QDELedFk = @LeadPk  AND QDEDelId = 0 
			              
            SELECT	QDELedFk,QDAQDEFK,QDAAddTyp,QDADoorNo,QDABuilding,QDAPlotNo,QDAStreet,QDALandmark,QDAArea,QDADistrict,QDAState,QDACountry,QDAPin,
					QDAContact,QDAEmail,QDAPk 
			FROM		LosQDEAddress (NOLOCK) 
			JOIN		LosQDE (NOLOCK) ON QDEPk = QDAQDEFK  AND QDADelId = 0 
			WHERE  QDELedFk = @LeadPk  AND QDEDelId = 0 
              
            --CUSTOMER-- 
            SELECT	QDELedFk,CusFstNm,CusMdNm,CusLstNm,CusGender,CusDOB,CusAadhar,CusPAN,CusDrvLic,CusVoterId,CusFthFstNm,CusFthMdNm,CusFthLstNm,
					CusPk 
            FROM	LosCustomer (NOLOCK) 
			JOIN	LosQDE (NOLOCK) ON QdeCusFk = CusPk AND CusDelId = 0 
            WHERE	QDELedFk = @LeadPk AND QDEDelId = 0 
			               
            SELECT	QDELedFk,CadCusFk,CadDoorNo,CadBuilding,CadPlotNo,CadStreet,CadLandmark,CadArea,CadDistrict,CadState,CadCountry,CadPin,CadPk,
					CadEmail,CadContact 
            FROM	LosCustomerAddress(NOLOCK) 
			JOIN	LosQDE(NOLOCK) ON QdeCusFk = CadCusFk AND CadDelId = 0      
            WHERE	QDELedFk = @LeadPk AND QDEDelId = 0                

            --DDE-- 
            SELECT	AppLedFk,ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') AppAgtNm,AppBGeoFk,AppPrdFk,AppApplNm,
					AppAppNo,AppPAppNo,AppLnPur,AppBuiLoc,AppPk 
            FROM	LosApp (NOLOCK) 
            JOIN	GenAgents(NOLOCK) ON AgtPk = AppAgtFk AND AgtDelid = 0
            WHERE	AppLedFk = @LeadPk AND AppDelId = 0  
               
            SELECT	LapLedFk,LapAppFk,LapCusFk,LapActor,LapPrefNm,LapFstNm,LapMdNm,LapLstNm,LapDOB,LapRelation,LapNationality,LapReligion,LapMobile,
					LapResi, LapEMail,LapActorNm,LapFatherFNm,LapFatherMNm,LapFatherLNm,LapMotherFNm,LapMotherMNm,LapMotherLNm,LapInsorUniv,LapTitle,
					LapMaritalSts,LapCommunity,LapEducation,LapGender,LapDpdCnt,LapAadhar,LapPAN,LapDrvLic,LapVotId,LapPassport,LapEmpTyp,LapPk 
            FROM	LosAppProfile (NOLOCK) 
            WHERE	LapLedFk = @LeadPk AND LapDelId = 0 
			              
            SELECT	LabLedFk,LabAppFk,LabLapFk,LabNm,LabNat,LabIncYr,LabCIN,LabOffNo,LabEMail,LabOwnShip,LabBusiTyp,LabOrgTyp,LabBusiPrd,LabPk
            FROM	LosAppBusiProfile (NOLOCK) 
            WHERE	LabLedFk = @LeadPk AND LabDelId = 0
               
            SELECT	LaeLedFk,LaeAppFk,LaeLapFk,LaeNm,LaeTyp,LaeNat,LaeDesig,LaeOffNo,LaeEMail,LaeTotExp,LaeExp,LaePk
            FROM	LosAppOffProfile (NOLOCK) 
            WHERE	LaeLedFk = @LeadPk AND LaeDelId = 0                

            SELECT	LaaLedFk,LaaAppFk,LaaLapFk,LaaAddTyp,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,LaaArea,LaaDistrict,LaaState,
					LaaCountry,LaaPin,LaaAcmTyp,LaaComAdd,LaaYrsResi,LaaPk
            FROM	LosAppAddress ( NOLOCK) 
            WHERE	LaaLedFk = @LeadPk AND LaaDelId = 0
                
            SELECT	LbkLedFk,LbkAppFk,LbkLapFk,LbkNm,LbkAccNo,LbkBank,LbkBranch,LbkIFSC,LbkAccTyp,LbkBnkTran,LbkAvgBkBal,LbkInChqBnc,LbkNotes,LbkPk
            FROM	LosAppBank (NOLOCK) 
            WHERE	LbkLedFk = @LeadPk AND LbkDelId = 0                

            SELECT	LasLedFk,LasAppFk,LasLapFk,LasDesc,LasAmt,LasTyp,LasPk 
            FROM	LosAppAst (NOLOCK) 
            WHERE	LasLedFk = @LeadPk AND LasDelId = 0 
               

            SELECT	LaoLedFk,LaoAppFk,LaoLapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,LaoNotes,LaoPk 
            FROM	LosAppObl (NOLOCK) 
            WHERE	LaoLedFk = @LeadPk AND LaoDelId = 0 
               

            SELECT LacLedFk,LacAppFk,LacLapFk,LacIsuBnk,LacLimit,LacCrdNo,LacTyp,LacPk 
            FROM   LosAppCreditCrd (NOLOCK) 
            WHERE  LacLedFk = @LeadPk 
               AND LacDelId = 0 

            SELECT LlhLedFk,LlhAppFk,LlhNm,LlhRelation,LlhAge,LlhIsEmpl, 
                   LlhMarSts,LlhPk 
            FROM   LosAppLegalHier (NOLOCK) 
            WHERE  LlhLedFk = @LeadPk 
               AND LlhDelId = 0 

            SELECT LarLedFk,LarAppFk,LarLaaFk,LarNm,LarRel,LarOccup,LarOffNo, 
                   LarResNo,LarEMail,LarPk 
            FROM   LosAppRef (NOLOCK) 
            WHERE  LarLedFk = @LeadPk 
               AND LarDelId = 0 

            --BRANCH CREDIT-- 
            SELECT LbiLedFk,LbiAppFk,LbiLapFk,LbiYr,LbiLcmFk,LbiAddLess,LbiVal, 
                   LbiIncExl,LbiPk 
            FROM   LosAppBusiInc (NOLOCK) 
            WHERE  LbiLedFk = @LeadPk 
               AND LbiDelId = 0 

            SELECT LsiLedFk,LsiAppFk,LsiLapFk,LsiMon,LsiLcmFk,LsiAddLess,LsiVal, 
                   LsiIncExl,LsiPk 
            FROM   LosAppSalInc (NOLOCK) 
            WHERE  LsiLedFk = @LeadPk 
               AND LsiDelId = 0 

            SELECT LciLedFk,LciAppFk,LciLapFk,LciYr,LciLcmFk,LciAddLess,LciVal, 
                   LciIncExl,LciPk 
            FROM   LosAppCshInc (NOLOCK) 
            WHERE  LciLedFk = @LeadPk 
               AND LciDelId = 0 

            SELECT LoiLedFk,LoiAppFk,LoiLapFk,LoiDesc,LoiPeriod,LoiAmt,LoiPk 
            FROM   LosAppOthInc (NOLOCK) 
            WHERE  LoiLedFk = @LeadPk 
               AND LoiDelId = 0 

            SELECT LbbLedFk,LbbAppFk,LbbLapFk,LbbBnkNm,LbbMon,LbbDay,LbbVal,LbbPk 

            FROM   LosAppBnkBal (NOLOCK) 
            WHERE  LbbLedFk = @LeadPk 
               AND LbbDelId = 0 

            SELECT NHBLedFk,NHBAppFk,NHBPuccaHouse,NHBHosCat,NHBHosInc,NHBLocCd, 
                   NHBLocNm ,NHBPk 
            FROM   LosNHB (NOLOCK) 
            WHERE  NHBLedFk = @LeadPk 
               AND NHBDelId = 0 

            SELECT NHBLedFk,LndNHBFk,LndDpdNm,LndProof,LndRefNo,LndPk 
            FROM   LosNHBDpd (NOLOCK) 
            JOIN LosNHB (NOLOCK) 
            ON NHBPk = LndNHBFk 
            AND LndDelId = 0 
            WHERE  NHBLedFk = @LeadPk 
            AND NHBDelId = 0 
        END 

      IF @Action = 'D' 
        BEGIN 
			DELETE FROM LosAppExistLn WHERE LelLedFk = ISNULL(@LeadPk,LelLedFk)

			DELETE FROM LosColletral WHERE LcdLedFk = ISNULL(@LeadPk,LcdLedFk)

			DELETE  T FROM LosInsNominee T
			JOIN LosInsurance S ON S.LisPk = T.LinLisFk WHERE LisLedFk = ISNULL(@LeadPk,LisLedFk)

			DELETE T FROM LosInsurance T WHERE  LisLedFk = ISNULL(@LeadPk,LisLedFk)
			
			DELETE T FROM LosAgentFBJob T
			JOIN LosAgentJob ON LajPk = LfjLajFk AND LajLedFk = ISNULL(@LeadPk,LajLedFk) AND LajSrvTyp = 6

			DELETE T FROM LosAgentVerf T 
			JOIN LosAgentJob S 
			ON S.LajPk = T.LavLajFk
			WHERE S.LajLedFk = ISNULL(@LeadPk,LajLedFk) AND LajSrvTyp = 6

			DELETE  FROM LosAgentJob
		    WHERE LajLedFk = ISNULL(@LeadPk, LajLedFk) AND LajSrvTyp = 6

			DELETE  FROM LosSeller WHERE LslLedFk = ISNULL(@LeadPk,LslLedFk)			

			DELETE FROM LosPropAstCost WHERE PacLedFk = ISNULL(@LeadPk,PacLedFk)

			DELETE FROM LosAppNotes WHERE LanLedFk = ISNULL(@LeadPk,LanLedFk)

			DELETE FROM LosDeviation WHERE LdvLedFk = ISNULL(@LeadPk,LdvLedFk)

			DELETE FROM LosAppDates WHERE AdtLedFk = ISNULL(@LeadPk,AdtLedFk)

			DELETE FROM LosRiskCalc WHERE LrcLedFk = ISNULL(@LeadPk,LrcLedFk)

			DELETE T FROM LosSanctionAttr T
			JOIN	LosSanction S ON S.LsnPk = T.LsaLsnFk  WHERE LsnLedFk = ISNULL(@LeadPk,LsnLedFk)								
			
			DELETE FROM LosLoan WHERE LlnLedFk = ISNULL(@LeadPk,LlnLedFk)											
			
			DELETE T FROM LosAppCheque T
			JOIN LosSanction S ON S.LsnPk = T.LcqLsnFk WHERE LsnLedFk = ISNULL(@LeadPk,LsnLedFk)						

			DELETE T FROM LosPayDtls T
			JOIN LosSanction S ON S.LsnPk = T.LpdLsnFk WHERE LsnLedFk = ISNULL(@LeadPk,LsnLedFk)

			DELETE FROM LosPostSanction WHERE LpsLedFk = ISNULL(@LeadPk,LpsLedFk)
				
			DELETE T FROM LosSubjCondtion T
			JOIN LosSanction S ON S.LsnPk = T.LscLsnFk WHERE LsnLedFk = ISNULL(@LeadPk,LsnLedFk)

			DELETE FROM LosSanction WHERE LsnLedFk = ISNULL(@LeadPk,LsnLedFk)

			DELETE FROM LosRCU WHERE LruLedFk = ISNULL(@LeadPk,LruLedFk)
			
			DELETE T FROM LosCreditAttrNotes T WHERE LcnLedFk = ISNULL(@LeadPk,LcnLedFk)
			
			DELETE T FROM LosCreditAttr T
			JOIN LosCredit ON LcaLcrFk = LcrPk AND LcrLedFk = ISNULL(@LeadPk,LcrLedFk)
			
			DELETE FROM LosCredit WHERE LcrLedFk  = ISNULL(@LeadPk,LcrLedFk)

			DELETE FROM LosRCU WHERE LruLedFk = ISNULL(@LeadPk,LruLedFk)
			
			DELETE FROM LosPropTechnical WHERE LptLedFk = ISNULL(@LeadPk,LptLedFk)
			
			DELETE T FROM LosPropOwner T
			JOIN LosPropLegal ON LplPk = LpoLplFk AND LplLedFk = ISNULL(@LeadPk,LplLedFk)
			
			DELETE FROM LosPropLegal WHERE LplLedFk = ISNULL(@LeadPk,LplLedFk)
			
			DELETE T FROM LosProcChrgDtls T, LosProcChrg  WHERE LpcdLpcFk = LpcPk AND LpcLedFk = ISNULL(@LeadPk,LpcLedFk)
			
			DELETE FROM LosProcChrg WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk)
			
			DELETE FROM LosAppTeleVerify WHERE LtvLedFk = ISNULL(@LeadPk,LtvLedFk)
			
			DELETE FROM LosAppPD WHERE LpdLedFk = ISNULL(@LeadPk,LpdLedFk)						
			
			DELETE T FROM LosAgentFBLegal T
			JOIN LosAgentFBJob ON LfjPk = LflLfjFk AND LfjSrvTyp = 4
			JOIN LosAgentJob ON LajPk = LfjLajFk AND LajLedFk = ISNULL(@LeadPk,LajLedFk)
			
			DELETE T FROM LosAgentFBTechnical T
			JOIN LosAgentFBJob ON  LfjPk = LftLfjFk AND LfjSrvTyp = 5
			JOIN LosAgentJob ON LajPk = LfjLajFk AND LajLedFk = ISNULL(@LeadPk,LajLedFk)
			
			DELETE T FROM LosAgentFBJob T
			JOIN LosAgentJob ON LajPk = LfjLajFk AND LajLedFk = ISNULL(@LeadPk,LajLedFk)

            DELETE T FROM LosAgentPrpVerf T
			JOIN LosAgentJob S 
			ON S.LajPk = T.LpvLajFk
			WHERE S.LajLedFk = ISNULL(@LeadPk,LajLedFk)
							
			DELETE T FROM LosAgentVerf T 
			JOIN LosAgentJob S 
			ON S.LajPk = T.LavLajFk
			WHERE S.LajLedFk = ISNULL(@LeadPk,LajLedFk)

			DELETE  FROM LosAgentJob
		    WHERE LajLedFk = ISNULL(@LeadPk, LajLedFk)											
			
			DELETE FROM Losprop 
			WHERE  PrpLedFk = Isnull(@LeadPk, PrpLedFk)

			DELETE FROM LosAppSalInc 
            WHERE  LsiLedFk = Isnull(@LeadPk, LsiLedFk) 

			DELETE FROM LosAppBusiInc 
            WHERE  LbiLedFk = Isnull(@LeadPk, LbiLedFk)         

            DELETE FROM LosAppCshInc 
            WHERE  LciLedFk = Isnull(@LeadPk, LciLedFk) 

            DELETE FROM LosAppOthInc 
            WHERE  LoiLedFk = Isnull(@LeadPk, LoiLedFk) 

			DELETE FROM LosAppObl 
            WHERE  LaoLedFk = Isnull(@LeadPk, LaoLedFk) 
			
			DELETE FROM LosAppIncObl WHERE LioLedFk = ISNULL(@LeadPk,LioLedFk)
			
            DELETE C 
            FROM   LosNHBDpd C 
            JOIN LosNHB 
            ON NHBPk = LndNHBFk 
            WHERE  NHBLedFk = Isnull(@LeadPk, NHBLedFk) 

            DELETE FROM LosNHB 
            WHERE  NHBLedFk = Isnull(@LeadPk, NHBLedFk) 

            DELETE FROM LosAppBnkBal 
            WHERE  LbbLedFk = Isnull(@LeadPk, LbbLedFk) 

            DELETE FROM LosAppRef 
            WHERE  LarLedFk = Isnull(@LeadPk, LarLedFk) 

            DELETE FROM LosAppBusiProfile 
            WHERE  LabLedFk = Isnull(@LeadPk, LabLedFk) 

            DELETE FROM LosAppOffProfile 
            WHERE  LaeLedFk = Isnull(@LeadPk, LaeLedFk) 

            DELETE FROM LosAppBank 
            WHERE  LbkLedFk = Isnull(@LeadPk, LbkLedFk) 

            DELETE FROM LosAppAst 
            WHERE  LasLedFk = Isnull(@LeadPk, LasLedFk) 
        
            DELETE FROM LosAppCreditCrd 
            WHERE  LacLedFk = Isnull(@LeadPk, LacLedFk) 

            DELETE FROM LosAppLegalHier 
            WHERE  LlhLedFk = Isnull(@LeadPk, LlhLedFk) 

            DELETE FROM LosAppAddress 
            WHERE  LaaLedFk = Isnull(@LeadPk, LaaLedFk) 
			
			DELETE FROM LosAppKYCDocuments
			WHERE  KYCLedFk = Isnull(@LeadPk, KYCLedFk) 
			
			DELETE FROM LosAppDocuments
			WHERE  LadLedFk = Isnull(@LeadPk, LadLedFk) 
			
            DELETE FROM LosAppProfile 
            WHERE  LapLedFk = Isnull(@LeadPk, LapLedFk) 

            DELETE FROM LosApp 
            WHERE  AppLedFk = Isnull(@LeadPk, AppLedFk) 

            DELETE a 
            FROM   LosCustomerAddress a 
            JOIN LosQde 
            ON QdeCusFk = CadCusFk 
            WHERE  QDELedFk = Isnull(@LeadPk, QDELedFk) 

            DELETE A 
            FROM   LosCustomer A 
            JOIN LosQDE 
            ON QdeCusFk = CusPk 
            WHERE  QDELedFk = Isnull(@LeadPk, QDELedFk) 

            DELETE b 
            FROM   LosQDEAddress b 
            JOIN LosQDE 
            ON QDAQDEFK = QDEPk 
            WHERE  QDELedFk = Isnull(@LeadPk, QDELedFk) 

            DELETE FROM LosQDE 
            WHERE  QDELedFk = Isnull(@LeadPk, QDELedFk) 

            DELETE FROM LosDocument 
            WHERE  DocLedFk = Isnull(@LeadPk, DocLedFk) 
 
            IF ISNULL(@LeadPk,0) = 0
            BEGIN 
				DELETE FROM LosLead 
				WHERE  LedPk = Isnull(@LeadPk, LedPk) 
				
				DELETE FROM GenLog
				DELETE FROM LosCustomerAddress
				DELETE FROM LosCustomer
            END
        END
  END 