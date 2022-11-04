IF OBJECT_ID('PrcShflDDEEntry','P') IS NOT NULL
	DROP PROCEDURE PrcShflDDEEntry
GO
CREATE PROCEDURE PrcShflDDEEntry
(
	@Action			VARCHAR(100)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@LogDtls		VARCHAR(MAX)		=	NULL,
	@HdrFk			BIGINT				=	NULL,
	@LapPk			BIGINT				=	NULL,
	@RefFk			BIGINT				=	NULL,
	@QdeFk			BIGINT				=	NULL,
	@HdrJson		VARCHAR(MAX)		=	NULL,
	@AppJson		VARCHAR(MAX)		=	NULL,
	@LegalJson      VARCHAR(MAX)		=	NULL,
	@CreditJson     VARCHAR(MAX)		=	NULL,
	@ObliJson       VARCHAR(MAX)		=	NULL,
	@AssetJson      VARCHAR(MAX)		=	NULL,
	@BankJson       VARCHAR(MAX)		=	NULL,
	@KycJson        VARCHAR(MAX)		=	NULL,
	@Docdet         VARCHAR(MAX)        =   NULL,
	@Docgendet      VARCHAR(MAX)        =   NULL,
	@KycaddJson     VARCHAR(MAX)        =   NULL

)
AS
BEGIN
	
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40),@frstnm VARCHAR(100), @ActorNm VARCHAR(100), @Actor TINYINT,@Cusfk BIGINT, @CibilScr BIGINT,@dderel VARCHAR(100),
			@prdGfk BIGINT,@dde_Abtus varchar(20)	
	DECLARE	 @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,
			 @selActor TINYINT, @Query VARCHAR(MAX),@APPPk BIGINT,@LapFk BIGINT,@LaaFk BIGINT,@appno VARCHAR(100),@lnpur VARCHAR(100),
			 @nature VARCHAR(100),@dde_Asset_car VARCHAR(100),@dde_Asset_twowheelr VARCHAR(100),@dde_Asset_threewheelr VARCHAR(100),
			 @dde_Asset_Remarks VARCHAR(500),@dde_ob_remarks VARCHAR(500),@dde_cc_remarks VARCHAR(500),@ASSETPK BIGINT,@OBLIPK BIGINT,@CCPK BIGINT,
			 @dde_Astnotes_Pk BIGINT,@dde_OBnotes_Pk BIGINT,@dde_CCnotes_Pk BIGINT
	
	DECLARE	 @hide_per_var TINYINT,@hide_pre_per_var TINYINT,@hide_leg_var TINYINT,@hide_occ_var TINYINT,@hide_ass_var TINYINT,
			 @hide_cc_var TINYINT,@hide_ob_var TINYINT,@hide_ref_var TINYINT,@hide_frst_var TINYINT,@hide_sec_var TINYINT,@hide_sal_var TINYINT,
			 @hide_self_var TINYINT, @hide_personal_var TINYINT, @TmpAction VARCHAR(20), @hide_ref_hidden TINYINT,@hide_bank_hidden TINYINT,
			 @dde_pre_IsSameAdr TINYINT,@emptype INT ,@dde_docgen_hidden VARCHAR(20),@dde_doc_hidden VARCHAR(20),@dde_kyc_hidden varchar(20);

    --Kyc validation

	DECLARE @Kyc TABLE(LapRef varchar(20),Cnt varchar(20))

	CREATE TABLE #GLOBALDTLS
	(
		id BIGINT, LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100), PCd VARCHAR(100)
	)

	CREATE TABLE #HDTLS
	(
		xxid BIGINT, AppNo VARCHAR(50),AgtNm VARCHAR(100),AgtFk VARCHAR(100), dde_LnPur VARCHAR(100),PAppNo VARCHAR(50), 
		ActorNm VARCHAR(100),BuiLoc VARCHAR(100), Actor VARCHAR(10), CusFk BIGINT, CibilScr BIGINT,GrpPrdFk BIGINT,saleofzpk BIGINT,
		Approverflag VARCHAR(100),dde_Abtus VARCHAR(20),kyc_hid VARCHAR(20),doc_hid VARCHAR(20),docgen_hid VARCHAR(20)
	)

    --Temporary table to Save Legal hier details Grid
	CREATE TABLE #LEGALDTLS
	(
		lid BIGINT, dde_Per_Legal_heir_Name1 VARCHAR(100),dde_Per_Legal_heir_Relation1 VARCHAR(50),
		dde_Per_Legal_heir_Age1 VARCHAR(100),dde_Per_Legal_hier_Proof1 VARCHAR(100),dde_Per_Legal_heir_Ref1 VARCHAR(100),
		dde_legal_pk BIGINT
	)
	CREATE TABLE #Legal(LlhFk BIGINT)
	
    --Temporary table to Save Credit details Grid
	CREATE TABLE #CREDITDTLS
	(
		Cid BIGINT,dde_cc_ctype1  VARCHAR(100),dde_cc_issuingbnk1  VARCHAR(100),dde_cc_issuingbnk2 VARCHAR(100),dde_cc_limit1  VARCHAR(100),
		dde_cc_cno1  VARCHAR(50),dde_crd_Pk BIGINT
	)
	CREATE TABLE #Credit(CrdPk BIGINT)
	
    --Temporary table to Save Obligation details Grid
	CREATE TABLE #OBLIDTLS 
	(
		Oid BIGINT,dde_ob_IsIncl VARCHAR(100),dde_ob_typofloan VARCHAR(100),dde_ob_IsShri VARCHAR(100),dde_ob_bank1 VARCHAR(100),dde_ob_bank2 VARCHAR(100),dde_ob_refno1 VARCHAR(100),
		dde_ob_emi1 VARCHAR(100),dde_ob_outstnd1 VARCHAR(100),dde_ob_bal1 VARCHAR(100),dde_ob_notes VARCHAR(250),dde_obl_Pk BIGINT,dde_ob_lnamt1 VARCHAR(100)
	)
	CREATE TABLE #Oblig(OblPk BIGINT)

	--Temporary table to Save Asset details Grid
	CREATE TABLE #ASSETDTLS
	(
		Aid BIGINT,dde_Asset_type1 VARCHAR(100) ,dde_Asset_des1 VARCHAR(100),dde_Asset_amt1 VARCHAR(100),
		dde_Ast_Pk BIGINT
	)
	CREATE TABLE #Ast(AstFk BIGINT)
	
	--Temporary table to Save Bank details Grid
	CREATE TABLE #BankDTLS
	(
		bid BIGINT,dde_Bank_Name1 VARCHAR(100),dde_Bank_AcType1 VARCHAR(20),dde_Bank_AcNum1 VARCHAR(100),dde_Bank_bnkName1 VARCHAR(100),
		dde_Bank_bnkName2 VARCHAR(100),dde_Bank_branch1 VARCHAR(100),dde_Bank_branch2 VARCHAR(100),dde_bank_pk BIGINT,dde_op_since1 VARCHAR(100)
	)
	CREATE TABLE #Bnk(BnkFk BIGINT)
	--Temporary table to Save Kyc details Grid
	CREATE TABLE #Loandtls
	(
		lid BIGINT,dde_KycProof VARCHAR(100) ,dde_KycDocument VARCHAR(100),dde_KycDate VARCHAR(100),dde_KycPk BIGINT,dde_KycRefno VARCHAR(100),
		dde_KycrefDate VARCHAR(100),dde_kyc_notes VARCHAR(100),dde_DOCPK VARCHAR(100)
	)

	CREATE TABLE #Kycadddtls
	(
		lid BIGINT,dde_KycaddProof VARCHAR(100) ,dde_KycaddDocument VARCHAR(100),dde_KycaddDate VARCHAR(100),dde_KycaddPk BIGINT,dde_KycaddRefno VARCHAR(100),
		dde_KycaddrefDate VARCHAR(100),dde_kyc_addnotes VARCHAR(100),dde_addDOCPK VARCHAR(100)
	)
	CREATE TABLE #KYC(KYCfk BIGINT)
	CREATE TABLE #KYCadd(KYCfk BIGINT)
	
		CREATE TABLE #DOCDTLS
		(
		DID BIGINT,Com_Doctype VARCHAR(100),Com_DoctPk BIGINT,Com_RecDate VARCHAR(100),Com_Refno VARCHAR(100),Com_Docstatus VARCHAR(100),
		Com_ValidDate VARCHAR(100),Com_rowPk BIGINT ,Com_refDate VARCHAR(100),Com_notes VARCHAR(100)
		)
	CREATE TABLE #DOC(DOCFK BIGINT)

		CREATE TABLE #DOCgenDTLS
		(
		DID BIGINT,Com_genDoctype VARCHAR(100),Com_genDoctPk BIGINT,Com_genRecDate VARCHAR(100),Com_genRefno VARCHAR(100),Com_genDocstatus VARCHAR(100),
		Com_genValidDate VARCHAR(100),Com_genrowPk BIGINT ,Com_genrefDate VARCHAR(100),Com_gennotes VARCHAR(100)
		)
	CREATE TABLE #DOCgen(DOCgenFK BIGINT)
	--Temporary table to Save Title div,Aadhaar div,Personal(Present,Permanent),Occupation(Self Employed,Salaried),Reference Grid
	CREATE TABLE #DTLS
	(
		xid BIGINT, dde_Per_acc VARCHAR(20), dde_pin_ref VARCHAR(50), dde_ref_state VARCHAR(100), dde_ref_dis_city VARCHAR(100), 
		dde_ref_twn_vil VARCHAR(150), dde_ref_landmark VARCHAR(250), dde_ref_street VARCHAR(150), dde_ref_plotno VARCHAR(20), 
		dde_ref_building VARCHAR(100), dde_ref_doorno VARCHAR(20), dde_ref_email VARCHAR(100), dde_ref_resphno VARCHAR(50), dde_ref_mobno VARCHAR(50),
		dde_ref_offphno VARCHAR(50), dde_ref_Occ VARCHAR(100), dde_ref_relName VARCHAR(50), dde_ref_Name VARCHAR(100), 
		dde_occSelf_bus_ownershp VARCHAR(20), dde_occSelf_typOfOrg VARCHAR(20), 
		dde_occSelf_typOfbus VARCHAR(20), dde_occSal_typeOfOrg VARCHAR(20), dde_occ_typeOfEmployment VARCHAR(100), 
		dde_Per_sourcing VARCHAR(100), dde_Per_Comm_addr VARCHAR(20), dde_Per_relationwitSvs VARCHAR(20), 
		dde_Per_marital_status VARCHAR(20), dde_Per_community VARCHAR(20), dde_ins_uni VARCHAR(100), dde_Per_education VARCHAR(20), 
		dde_gender VARCHAR(20), dde_title VARCHAR(20), dde_cc_remarks VARCHAR(500),dde_CCnotes_Pk VARCHAR(100), dde_CrediCard_hidden VARCHAR(20), 
		dde_ob_remarks VARCHAR(500), dde_Obli_hidden VARCHAR(20), dde_Asset_Remarks VARCHAR(500),dde_Astnotes_Pk VARCHAR(100), dde_OBnotes_Pk VARCHAR(100),dde_Asset_hidden VARCHAR(20), 
		dde_occStud_addr_pin VARCHAR(50), dde_occStud_addr_state VARCHAR(100), dde_occStud_addr_Dis_city VARCHAR(100), 
		dde_occStud_addr_twn_vil VARCHAR(150), dde_occStud_addr_Landmark VARCHAR(250), dde_occStud_addr_Street VARCHAR(150), 
		dde_occStud_addr_Plotno VARCHAR(20), dde_occStud_addr_Building VARCHAR(100), dde_occStud_addr_doorno VARCHAR(20), 
		dde_occStud_UniversityName VARCHAR(100), dde_occSelf_busAddr_Pin VARCHAR(50), dde_occSelf_busAddr_state VARCHAR(100), 
		dde_occSelf_busAddr_Dis_city VARCHAR(100), dde_occSelf_busAddr_twn_vil VARCHAR(150), dde_occSelf_busAddr_Landmark VARCHAR(250), 
		dde_occSelf_busAddr_strt VARCHAR(150), dde_occSelf_busAddr_plotno VARCHAR(20), dde_occSelf_busAddr_doorno VARCHAR(20), 
		dde_occSelf_cin VARCHAR(50),dde_occSelf_noOfyrsCurrent VARCHAR(20),dde_occSelf_msme VARCHAR(20),dde_occSelf_turnover VARCHAR(50), dde_occSelf_Busphno VARCHAR(50), dde_occSelf_bus_em VARCHAR(100), 
		dde_occSelf_tot_bus VARCHAR(20), dde_occSelf_yrOfIncorp VARCHAR(20), dde_occSelf_NaturOfBus VARCHAR(100),dde_occSelf_NaturOfBus_others VARCHAR(100),dde_occSelf_bus VARCHAR(100), 
		dde_occSal_offAddr_pin VARCHAR(50), dde_occSal_offAddr_state VARCHAR(100), dde_occSal_offAddr_dis_city VARCHAR(100), 
		dde_occSal_offAddr_twn_vil VARCHAR(150), dde_occSal_offAddr_Landmark VARCHAR(250), dde_occSal_offAddr_strt VARCHAR(150), 
		dde_occSal_offAddr_plotno VARCHAR(20), dde_occSal_offAddr_building VARCHAR(100), dde_occSal_offAddr_doorno VARCHAR(20), 
		dde_occSal_SrcOfotherIncome VARCHAR(100), dde_occsal_otherIncome VARCHAR(100), dde_occSal_MonIncome VARCHAR(100), 
		dde_occSal_officialphno VARCHAR(20), dde_occSal_officialemail VARCHAR(100), dde_occSal_tot_emp VARCHAR(20), 
		dde_occSal_no_of_month VARCHAR(20), dde_occSal_desig VARCHAR(100), dde_occsal_nature_of_emp VARCHAR(100), dde_occ_org VARCHAR(100), 
		dde_Occ_hidden VARCHAR(20), dde_permanent_pin VARCHAR(50), dde_permanent_state VARCHAR(100), dde_permanent_dis_city VARCHAR(100), 
		dde_permanent_twn_vil VARCHAR(150), dde_permanent_lndmrk VARCHAR(250), dde_permanent_street VARCHAR(150), 
		dde_permanent_plotno VARCHAR(20), dde_permanent_building VARCHAR(100), dde_permanent_doorno VARCHAR(20), 
		dde_residing_yrs VARCHAR(20),dde_rental VARCHAR(100), dde_pin VARCHAR(6), dde_state VARCHAR(100), dde_dis_city VARCHAR(100), dde_twn_vil VARCHAR(150), 
		dde_lndmrk VARCHAR(250), dde_street VARCHAR(150), dde_plotno VARCHAR(20), dde_building VARCHAR(100), dde_doorno VARCHAR(20), 
		dde_pre_per_hidden VARCHAR(20), dde_Per_agname VARCHAR(20), dde_Per_agcode VARCHAR(20), dde_Per_refNO VARCHAR(100), 
		dde_Per_noOfDependent VARCHAR(20), dde_Per_mom_lastname VARCHAR(100), dde_Per_mom_Midname VARCHAR(100), dde_Per_mom_Fname VARCHAR(100), 
		dde_Per_Fat_hus_Lastname VARCHAR(100), dde_Per_Fat_hus_Midname VARCHAR(100), dde_Per_Fat_hus_Fname VARCHAR(100), 
		dde_Per_community_other VARCHAR(50), dde_Per_Religion VARCHAR(50),dde_Per_religion_other  VARCHAR(50), dde_Per_Nationality VARCHAR(50), dde_Per_Email VARCHAR(100), 
		dde_Per_Mobile VARCHAR(50), dde_Per_edu_others VARCHAR(50), dde_Personal_hidden VARCHAR(20), dde_pass_no VARCHAR(20), 
		dde_vot_id VARCHAR(20), dde_dl VARCHAR(20), dde_pan_no VARCHAR(20), dde_adr_no VARCHAR(20),dde_chk_doc VARCHAR(20), dde_Second_hidden VARCHAR(20), 
		dde_dob VARCHAR(20), dde_Lname VARCHAR(100), dde_Mname VARCHAR(100), dde_Fname VARCHAR(100), dde_app_relation VARCHAR(50), 
		dde_Pref VARCHAR(250), dde_First_hidden VARCHAR(20), dde_Legal_hidden VARCHAR(20), dde_ref_hidden VARCHAR(10),dde_Bank_hidden VARCHAR(20),
		dde_pre_IsSameAdr VARCHAR(20),dde_Per_res VARCHAR(20),dde_Per_alt VARCHAR(20),dde_Asset_car VARCHAR(20),
		dde_Asset_twowheelr VARCHAR(20),dde_Asset_threewheelr VARCHAR(20),dde_occSal_emp_id VARCHAR(50)
		
	)

	--Temporary table to Save Actor(Applicant or Co-Applicant etc) details Grid
	CREATE TABLE #ACTORDTLS(Actor TINYINT, ActorNm VARCHAR(100),FstNm VARCHAR(100),MidNm VARCHAR(100),LastNm VARCHAR(100),cusfk BIGINT,
	 AppFk BIGINT, LapFk BIGINT, Flg INT, CibilScr SMALLINT,Emptyp VARCHAR(20),Kyclapfk VARCHAR(20),Kyccount VARCHAR(20))

	--Temporary table to Save data from Qde table 
	CREATE TABLE #DTLSTBL
	(
		Pk BIGINT, dde_Fname VARCHAR(100),dde_Mname VARCHAR(100), dde_Lname VARCHAR(100), Actor TINYINT, dde_gender VARCHAR(20),
		dde_dob VARCHAR(20), dde_Per_Mobile VARCHAR(20), dde_Per_Email VARCHAR(100), dde_adr_no VARCHAR(100),dde_pan_no VARCHAR(20),dde_dl VARCHAR(100),
		dde_vot_id VARCHAR(100),dde_doorno VARCHAR(100),dde_building VARCHAR(100),dde_plotno VARCHAR(100),dde_street VARCHAR(100),dde_lndmrk VARCHAR(100),
		dde_twn_vil VARCHAR(100),dde_dis_city VARCHAR(100),dde_state VARCHAR(100),dde_pin VARCHAR(6),
		dde_Per_Fat_hus_Fname VARCHAR(100), dde_Per_Fat_hus_Midname VARCHAR(100), dde_Per_Fat_hus_Lastname VARCHAR(100), dde_pass_no VARCHAR(100),
		CusFk BIGINT, CibilScr SMALLINT,dde_chk_doc VARCHAR(10)
	)

	SELECT @CurDt = Getdate(), @RowId = Newid()
	
	IF @GlobalJson != '[]' AND @GlobalJson != ''
		BEGIN
			INSERT INTO #GLOBALDTLS
			EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,UsrNm,PrdCd'
			
			SELECT	@LeadPk = LeadPk, @GeoFk = GeoFk, @UsrPk = UsrPk, @UsrDispNm = UsrDispNm, @UsrNm = UsrNm
			FROM	#GLOBALDTLS
			
			SELECT	@PrdFk = PrdPk
			FROM	#GLOBALDTLS
			JOIN	GenPrdMas(NOLOCK) ON PrdCd = PCd AND PrdDelid = 0
		END

	IF @AppJson != '[]' AND @AppJson != ''
		BEGIN
			INSERT INTO #DTLS
            EXEC PrcParseJSON @AppJson,'dde_Per_acc,dde_pin_ref,dde_ref_state,dde_ref_dis_city,dde_ref_twn_vil,dde_ref_landmark,dde_ref_street,dde_ref_plotno,dde_ref_building,dde_ref_doorno,dde_ref_email,dde_ref_resphno,dde_ref_mobno,dde_ref_offphno,dde_ref_Occ,dde_ref_relName,dde_ref_Name,dde_occSelf_bus_ownershp,dde_occSelf_typOfOrg,dde_occSelf_typOfbus,dde_occSal_typeOfOrg,dde_occ_typeOfEmployment,dde_Per_sourcing,dde_Per_Comm_addr,dde_Per_relationwitSvs,dde_Per_marital_status,dde_Per_community,dde_ins_uni,dde_Per_education,dde_gender,dde_title,dde_cc_remarks,dde_ccnotes_Pk,dde_CrediCard_hidden,dde_ob_remarks,dde_Obli_hidden,dde_Asset_Remarks,dde_Astnotes_Pk,dde_OBnotes_Pk,dde_Asset_hidden,dde_occStud_addr_pin,dde_occStud_addr_state,dde_occStud_addr_Dis_city,dde_occStud_addr_twn_vil,dde_occStud_addr_Landmark,dde_occStud_addr_Street,dde_occStud_addr_Plotno,dde_occStud_addr_Building,dde_occStud_addr_doorno,dde_occStud_UniversityName,dde_occSelf_busAddr_Pin,dde_occSelf_busAddr_state,dde_occSelf_busAddr_Dis_city,dde_occSelf_busAddr_twn_vil,dde_occSelf_busAddr_Landmark,dde_occSelf_busAddr_strt,dde_occSelf_busAddr_plotno,dde_occSelf_busAddr_doorno,dde_occSelf_cin,dde_occSelf_noOfyrsCurrent,dde_occSelf_msme,dde_occSelf_turnover,dde_occSelf_Busphno,dde_occSelf_bus_em,dde_occSelf_tot_bus,dde_occSelf_yrOfIncorp,dde_occSelf_NaturOfBus,dde_occSelf_NaturOfBus_others,dde_occSelf_bus,dde_occSal_offAddr_pin,dde_occSal_offAddr_state,dde_occSal_offAddr_dis_city,dde_occSal_offAddr_twn_vil,dde_occSal_offAddr_Landmark,dde_occSal_offAddr_strt,dde_occSal_offAddr_plotno,dde_occSal_offAddr_building,dde_occSal_offAddr_doorno,dde_occSal_SrcOfotherIncome,dde_occsal_otherIncome,dde_occSal_MonIncome,dde_occSal_officialphno,dde_occSal_officialemail,dde_occSal_tot_emp,dde_occSal_no_of_month,dde_occSal_desig,dde_occsal_nature_of_emp,dde_occ_org,dde_Occ_hidden,dde_permanent_pin,dde_permanent_state,dde_permanent_dis_city,dde_permanent_twn_vil,dde_permanent_lndmrk,dde_permanent_street,dde_permanent_plotno,dde_permanent_building,dde_permanent_doorno,dde_residing_yrs,dde_rental,dde_pin,dde_state,dde_dis_city,dde_twn_vil,dde_lndmrk,dde_street,dde_plotno,dde_building,dde_doorno,dde_pre_per_hidden,dde_Per_agname,dde_Per_agcode,dde_Per_refNO,dde_Per_noOfDependent,dde_Per_mom_lastname,dde_Per_mom_Midname,dde_Per_mom_Fname,dde_Per_Fat_hus_Lastname,dde_Per_Fat_hus_Midname,dde_Per_Fat_hus_Fname,dde_Per_community_other,dde_Per_Religion,dde_Per_religion_other,dde_Per_Nationality,dde_Per_Email,dde_Per_Mobile,dde_Per_edu_others,dde_Personal_hidden,dde_pass_no,dde_vot_id,dde_dl,dde_pan_no,dde_adr_no,dde_chk_doc,dde_Second_hidden,dde_dob,dde_Lname,dde_Mname,dde_Fname,dde_app_relation,dde_Pref,dde_First_hidden,dde_Legal_hidden,dde_ref_hidden,dde_Bank_hidden,dde_pre_IsSameAdr,dde_Per_res,dde_Per_alt,dde_Asset_car,dde_Asset_twowheelr,dde_Asset_threewheelr,dde_occSal_emp_id' 		            
			SELECT	@hide_personal_var = dde_Personal_hidden, @hide_pre_per_var = dde_pre_per_hidden , @hide_occ_var = dde_Occ_hidden,
					@hide_self_var = dde_occ_typeOfEmployment, @hide_ass_var = dde_Asset_hidden , @hide_ob_var = dde_obli_hidden,
					@hide_cc_var = dde_CrediCard_hidden, @hide_ref_hidden = dde_ref_hidden, @hide_bank_hidden = dde_Bank_hidden,
					@dde_pre_IsSameAdr = dde_pre_IsSameAdr,@dde_Asset_car=dde_Asset_car,@dde_Asset_twowheelr=dde_Asset_twowheelr,
					@dde_Asset_threewheelr=dde_Asset_threewheelr,@dde_Asset_Remarks=dde_Asset_Remarks,@dde_ob_remarks=dde_ob_remarks,@dde_Astnotes_Pk=dde_Astnotes_Pk,
					@dde_OBnotes_Pk=dde_OBnotes_Pk,@dde_CCnotes_Pk=dde_CCnotes_Pk,@dde_cc_remarks=dde_cc_remarks
			FROM	#DTLS
			
        END           
	IF @LegalJson != '[]' AND @LegalJson != ''
		BEGIN
			INSERT INTO #LEGALDTLS
 			EXEC PrcParseJSON @LegalJson,'dde_Per_Legal_heir_Name1,dde_Per_Legal_heir_Relation1,dde_Per_Legal_heir_Age1,dde_Per_Legal_hier_Proof1,dde_Per_Legal_heir_Ref1,dde_legal_pk'
			
		END

	IF @Docdet != '[]' AND @Docdet != ''
		BEGIN
			INSERT INTO #DOCDTLS
			EXEC PrcParseJSON @Docdet,'Com_Doctype,Com_DoctPk,Com_RecDate,Com_Refno,Com_Docstatus,Com_ValidDate,Com_rowPk,Com_refDate,Com_notes'
	END

	IF @Docgendet != '[]' AND @Docgendet != ''
		BEGIN
			INSERT INTO #DOCgenDTLS
			EXEC PrcParseJSON @Docgendet,'Com_genDoctype,Com_genDoctPk,Com_genRecDate,Com_genRefno,Com_genDocstatus,Com_genValidDate,Com_genrowPk,Com_genrefDate,Com_gennotes'
	END

	IF @HdrJson != '[]' AND @HdrJson != ''
	BEGIN
	
		INSERT INTO #HDTLS
		EXEC PrcParseJSON @HdrJson,'AppNo,AgtNm,AgtFk,dde_LnPur,PAppNo,ActorNm,BuiLoc,Actor,CusFk,CibilScr,grpprdfk,saleofzpk,Approverflag,Abt_us,kyc_hid,doc_hid,docgen_hid'
		SELECT @ActorNm = ActorNm, @Actor = Actor, @CusFk = CusFk, @CibilScr = CibilScr,@prdGfk=GrpPrdFk,
		@dde_docgen_hidden=docgen_hid,@dde_doc_hidden=doc_hid,@dde_kyc_hidden=kyc_hid
		 FROM #HDTLS

	END

    IF @CreditJson != '[]' AND @CreditJson != ''
		BEGIN
			INSERT INTO #CREDITDTLS
			EXEC PrcParseJSON @CreditJson,'dde_cc_ctype1,dde_cc_issuingbnk1,dde_cc_issuingbnk2,dde_cc_limit1,dde_cc_cno1,dde_crd_Pk'
		END

	IF @ObliJson != '[]' AND @ObliJson != ''
		BEGIN
			INSERT INTO #OBLIDTLS
			EXEC PrcParseJSON @ObliJson,'dde_ob_IsIncl,dde_ob_typofloan,dde_ob_IsShri,dde_ob_bank1,dde_ob_bank2,dde_ob_refno1,dde_ob_emi1,dde_ob_outstnd1,dde_ob_bal1,dde_ob_notes,dde_obl_Pk,dde_ob_lnamt1'
		END

	IF @AssetJson != '[]' AND @AssetJson != ''
		BEGIN
			INSERT INTO #ASSETDTLS
			EXEC PrcParseJSON @AssetJson,'dde_Asset_type1,dde_Asset_des1,dde_Asset_amt1,dde_Ast_Pk'
		END

	IF @BankJson != '[]' AND @BankJson != ''
		BEGIN
			INSERT INTO #BankDTLS
			EXEC PrcParseJSON @BankJson,'dde_Bank_Name1,dde_Bank_AcType1,dde_Bank_AcNum1,dde_Bank_bnkName1,dde_Bank_bnkName2,dde_Bank_branch1,dde_Bank_branch2,dde_bank_pk,dde_op_since1'
		END		
			
	IF @KycJson != '[]' AND @KycJson != ''
		BEGIN
			INSERT INTO #Loandtls
 			EXEC PrcParseJSON @KycJson,'dde_KycProof,dde_KycDocument,dde_KycDate,dde_KycPk,dde_KycRefno,dde_KycrefDate,dde_kyc_notes,dde_DOCPK'			
		END

	IF @KycaddJson != '[]' AND @KycaddJson != ''
		BEGIN
			INSERT INTO #Kycadddtls
 			EXEC PrcParseJSON @KycaddJson,'dde_KycaddProof,dde_KycaddDocument,dde_KycaddDate,dde_KycaddPk,dde_KycaddRefno,dde_KycaddrefDate,dde_kyc_addnotes,dde_addDOCPK'			
		END
		

	BEGIN TRY

	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN
			IF @Action = 'SEL_PRD'
			BEGIN

			            SELECT  GrpNm 'productnm', GrpPk 'productpk', GrpCd 'ProductCode',GrpIconCls 'classnm'
						FROM	GenLvlDefn(NOLOCK)
						WHERE	GrpDelId = 0

			END

			IF @Action = 'PrdPkUpdate'
			BEGIN
	
                       UPDATE LosApp SET AppPGrpFk=@prdGfk WHERE AppLedFk=@LeadPk
		
                       UPDATE LosLead SET LedPGrpFk=@prdGfk WHERE LedPk=@LeadPk
			END

			IF @Action IN('LdDtls','S')
				BEGIN
					
					SET @TmpAction = @Action
					SET @APPPk = @HdrFk
	
					INSERT INTO @Kyc
					SELECT  KYCLapFk,COUNT(*)
					FROM	LosAppKYCDocuments
					WHERE	KYCLedFk = @LeadPk AND KycDelid = 0
					Group by KYCLapFk
					--select * from LosAppKYCDocuments WHERE	KYCLedFk = 5164 AND KycDelid = 0
					--To Check Whether Data present in dde table (Flag 1)
					INSERT INTO #ACTORDTLS(Actor, ActorNm,FstNm,MidNm,LastNm,cusfk, AppFk, LapFk, CibilScr,Flg,Emptyp,Kyclapfk,Kyccount)
					SELECT  LapActor 'Actor', CASE LapActor WHEN 1 THEN 'Co-Applicant' WHEN 2 THEN 'Guarantor' ELSE  ISNULL(LapActorNm,'Applicant ' + CONVERT(VARCHAR,LapActor))  END 'ActorNm',
							LapFstNm 'FstNm',LapMdNm 'MidNm',LapLstNm 'LastNm',LapCusFk 'Cusfk', AppPk, LapPk, ISNULL(LapCibil,0),1,LapEmpTyp 'EmpTyp',
							ISNULL(LapRef,-1) 'KYC',Cnt 'Kyccnt'
					FROM	LosApp(NOLOCK)
					JOIN	LosAppProfile(NOLOCK) ON LapPk = CASE @Action WHEN 'S' THEN ISNULL(@LapPk,0) ELSE LapPk END AND LapAppFk = AppPk AND LapDelid = 0
					LEFT JOIN	@Kyc ON ISNULL(LapRef,0) = LapPk
					WHERE	AppPk = CASE @Action WHEN 'S' THEN @APPPk ELSE AppPk END AND AppLedFk = @LeadPk AND AppDelid = 0
							
					--When First tym dde page is loaded(Flag 2) 			
					INSERT INTO #ACTORDTLS(Actor, ActorNm,FstNm,MidNm,LastNm,cusfk, AppFk, LapFk, CibilScr, Flg,Emptyp,Kyclapfk,Kyccount)
					SELECT  QDEActor 'Actor', CASE QDEActor WHEN 1 THEN 'Co-Applicant' WHEN 2 THEN 'Guarantor' ELSE  ISNULL(QDEActorNm,'Co-Applicant ' + CONVERT(VARCHAR,QDEActor))  END 'ActorNm',
							QDEFstNm 'FstNm',QDEMdNm 'MidNm',QDELstNm 'LastNm',QdeCusFk 'Cusfk', 0, QdePk, ISNULL(QdeCibil,0) , 2,-1,-1,-1
					FROM	LosQDE(NOLOCK)
					WHERE	QDELedFk = @LeadPk AND QdePk = CASE @Action WHEN 'S' THEN ISNULL(@QdeFk,0) ELSE QdePk END AND QDEDelid = 0
					AND		NOT EXISTS(SELECT 'X' FROM #ACTORDTLS WHERE Actor = QDEActor)
						
		            --return
					--To return Actor details(Result:1)
					SELECT	Actor 'Actor', ActorNm 'ActorNm', FstNm 'FstNm',MidNm 'MidNm',LastNm 'LastNm',cusfk 'CusFk', CASE Flg WHEN 1 THEN AppFk ELSE 0 END 'AppFk',
							CASE Flg WHEN 1 THEN LapFk ELSE 0 END 'LapFk', CASE Flg WHEN 2 THEN LapFk ELSE 0 END 'QdeFk' ,
							CibilScr 'CibilScr',Emptyp 'Emptyp',Kyclapfk 'Kyc',Kyccount 'Kyccnt'
					FROM	#ACTORDTLS ORDER BY Actor

					IF EXISTS(SELECT 'X' FROM #ACTORDTLS WHERE Flg =  2 AND ISNULL(Actor,0) = CASE @Action WHEN 'S' THEN ISNULL(Actor,0) ELSE 0 END)
						BEGIN
						
							SELECT	@QdeFk = LapFk  FROM #ACTORDTLS  WHERE Flg =  2 AND ISNULL(Actor,0) = 0
							SET		@Action = 'QdeDtls'
						END

					ELSE IF EXISTS(SELECT 'X' FROM #ACTORDTLS WHERE Flg =  1 AND ISNULL(Actor,0) = CASE @Action WHEN 'S' THEN ISNULL(Actor,0) ELSE 0 END)
						BEGIN
					
							SELECT	@LapPk = LapFk, @APPPk = AppFk FROM #ACTORDTLS  WHERE Flg =  1 AND ISNULL(Actor,0) = 0
							SET		@Action = 'DdeDtls'
						END			
				END

			IF @Action = 'QdeDtls'
				BEGIN
					SELECT 1 'FLG'

					INSERT INTO #DTLSTBL
					SELECT	QDePk 'Pk',QDEFstNm 'dde_Fname',QDEMdNm 'dde_Mname',
							QDELstNm 'dde_Lname', ISNULL(QDEActor,0) 'Actor',
							QDEGender 'dde_gender',
							DBO.gefgDMY(QDEDOB) 'dde_dob',ISNULL(QDAContact,'') 'dde_Per_Mobile',ISNULL(QDAEmail,'') 'dde_Per_Email',
							QDEAadhar 'dde_adr_no',QDEPAN 'dde_pan_no',QDEDrvLic 'dde_dl',QDEVoterId 'dde_vot_id',
							QDADoorNo 'dde_doorno',QDABuilding 'dde_building',QDAPlotNo 'dde_plotno',
							QDAStreet 'dde_street',QDALandmark 'dde_lndmrk',QDAArea 'dde_twn_vil',QDADistrict 'dde_dis_city',
							QDAState 'dde_state',QDAPin 'dde_pin',QDEFthFstNm 'dde_Per_Fat_hus_Fname',QDEFthMdNm 'dde_Per_Fat_hus_Midname',
							QDEFthLstNm 'dde_Per_Fat_hus_Lastname',QDEPassNum 'dde_pass_no', QDECusFk 'CusFk', QDECibil 'CibilScr',QdeOthDocAvl 'dde_chk_doc'
					FROM	LosQDE(NOLOCK)
					JOIN	LosQDEAddress(NOLOCK) ON QDAQDEFK = QDEPk AND QDADelId = 0
					WHERE	QDEPk = @QdeFk AND QDELedFk = @LeadPk AND QDEDelid = 0

					SELECT	Pk,dde_Fname,dde_Mname, dde_Lname, Actor, dde_gender, dde_dob, dde_Per_Mobile, dde_Per_Email,dde_adr_no,dde_pan_no,dde_dl,dde_vot_id,
							dde_doorno,dde_building,dde_plotno,dde_street,dde_lndmrk,dde_twn_vil,dde_dis_city,dde_state,dde_pin,
							dde_Per_Fat_hus_Fname, dde_Per_Fat_hus_Midname, dde_Per_Fat_hus_Lastname, dde_pass_no,CusFk,CibilScr,dde_chk_doc
					FROM	#DTLSTBL

					SELECT	DocLedFk 'LeadFk',ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',
							DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',DocActor 'Actor',DocCat	'Catogory',
							DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk'
					FROM	LosDocument(NOLOCK)
					JOIN	GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
					WHERE	DocLedFk = @LeadPk AND DocDelid = 0
				END
			
			 IF @Action = 'D'
				BEGIN
				SELECT	@LaaFk = LarLaaFk FROM LosAppRef(NOLOCK) WHERE LarPk = @RefFk AND LarDelid = 0
					UPDATE	LosAppRef
					SET		LarDelId = 1, LarDelFlg = dbo.gefgGetDelFlg(@CurDt),
							LarRowId = @RowId, LarModifiedBy = @UsrDispNm, LarModifiedDt =  @CurDt
					WHERE	LarPk = @RefFk AND LarDelId = 0
					
					SELECT	@Error = @@ERROR
					
					IF @Error > 0
						BEGIN
							RAISERROR('%s',16,1,'Error : DDE Header Delete')
							RETURN
						END
					
					UPDATE	LosAppAddress
					SET		LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),
							LaaRowId = @RowId,LaaModifiedBy = @UsrDispNm,LaaModifiedDt = @CurDt
					WHERE	LaaPk = @LaaFk AND LaaDelId = 0
					
					SELECT	@Error = @@ERROR
					
					IF @Error > 0
						BEGIN

							RAISERROR('%s',16,1,'Error : DDE Address Delete')
							RETURN
						END



				END

				IF @Action ='DocLoad'
				BEGIN
				SELECT	DocLedFk 'LeadFk',ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',
						DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',DocActor 'Actor',DocCat	'Catogory',
						DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk'
				FROM	LosDocument(NOLOCK)
				JOIN	GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
				WHERE	DocLedFk = @LeadPk AND DocDelid = 0

				SELECT	LedNm 'nm',GrpPk 'productpk', GrpCd 'PCd'
				FROM	GenLvlDefn(NOLOCK)
				JOIN    LosLead ON LedPGrpFk=GrpPk
				WHERE   GrpDelId = 0 AND LedPk = @LeadPk


				SELECT  GblNm 'Location',AppBuiLocFk 'Gblpk'
				FROM	LosApp(NOLOCK)				
				JOIN    GenBusiLocation ON AppBuiLocFk=GblPk
				WHERE	AppLedFk = @LeadPk AND AppDelid = 0
				END

				

			IF @Action = 'DdeDtls'
				BEGIN
					SELECT 2 'FLG'
					IF @TmpAction = 'LdDtls'
						SELECT	AppLnPur 'dde_LnPur', AppBuiLoc 'dde_builoc', AppPAppNo 'dde_PAppNo',AppPGrpFk 'lead_prdPk',GrpCd 'prdcode',GblNm 'Location',AppBuiLocFk 'Gblpk',
						        AppAbtus 'dde_Abtus'
						FROM	LosApp(NOLOCK)
						JOIN    GenLvlDefn ON AppPGrpFk=GrpPk
						Left JOIN    GenBusiLocation ON AppBuiLocFk=GblPk
						WHERE	AppPk = @AppPk AND AppDelid = 0
					ELSE
						SELECT 'S'
						--result 4
					--Applicant profile details
					SELECT	LapPrefNm 'dde_Pref',LapFstNm 'dde_Fname',LapMdNm 'dde_Mname',LapLstNm 'dde_Lname',LapGender 'dde_gender',
							DBO.gefgDMY(LapDOB) 'dde_dob',LapRelation 'dde_app_relation',
							LapMaritalSts 'dde_Per_marital_status',LapNationality 'dde_Per_Nationality',LapReligion 'dde_Per_Religion',LapCommunity 'dde_Per_community',
							LapDpdCnt 'dde_Per_noOfDependent',LapMobile 'dde_Per_Mobile',LapResi 'dde_Per_Religion',LapEMail 'dde_Per_Email',
							LapFatherFNm 'dde_Per_Fat_hus_Fname',LapFatherMNm 'dde_Per_Fat_hus_Midname',
							LapFatherLNm 'dde_Per_Fat_hus_Lastname',LapMotherFNm 'dde_Per_mom_Fname',LapMotherMNm 'dde_Per_mom_Midname',
							LapMotherLNm 'dde_Per_mom_lastname',LapEducation 'dde_Per_education',LapInsorUniv 'dde_ins_uni',
							LapAadhar 'dde_adr_no',LapPAN 'dde_pan_no',LapDrvLic 'dde_dl',LapVotId 'dde_vot_id',LapPassport 'dde_pass_no',
							LapTitle 'dde_title', ISNULL(LapEmpTyp,-1) 'dde_occ_typeOfEmployment', LapCusFk 'CusFk', LapCibil 'CibilScr', LapResi 'dde_Per_res',LapAltMobile 'dde_Per_alt',
							LosRelWthShriram 'dde_Per_relationwitSvs',LosRelWthShriramRefNo 'dde_Per_refNO',
							CASE ISNULL(LapEmpTyp,-1) WHEN 0 THEN 'emp-salaried' WHEN 1 THEN 'emp-self-prof' WHEN 4 THEN 'emp-student' ELSE '' END 'EmpClass',LapEduOth 'dde_Per_edu_others',LapComOth 'dde_Per_community_other',
							LapOthDocAvl 'dde_chk_doc'
					FROM	LosAppProfile(NOLOCK)
					WHERE	LapPk = @LapPk AND LapDelId=0

					--Present address
					SELECT	LaaAddTyp 'AddType',LaaComAdd 'dde_Per_Comm_addr',LaaAcmTyp 'dde_Per_acc',LaaYrsResi 'dde_residing_yrs',
							LaaDoorNo 'dde_doorno',LaaBuilding 'dde_building',LaaPlotNo 'dde_plotno',LaaStreet 'dde_street',LaaLandmark 'dde_lndmrk',
							LaaArea 'dde_twn_vil',LaaDistrict 'dde_dis_city',LaaState 'dde_state',LaaPin 'dde_pin',ISNULL(LaaRentAmt,0) 'dde_rental'
					FROM	LosAppAddress(NOLOCK)
				    WHERE	LaaLapFk=@LapPk AND LaaAddTyp='0' AND LaaDelId=0
					
					--Permanent address
	                SELECT	LaaAddTyp 'AddType',LaaDoorNo 'dde_permanent_doorno',LaaBuilding 'dde_permanent_building',
							LaaPlotNo 'dde_permanent_plotno',LaaStreet 'dde_permanent_street',LaaLandmark 'dde_permanent_lndmrk',
							LaaArea 'dde_permanent_twn_vil',LaaDistrict 'dde_permanent_dis_city',LaaState 'dde_permanent_state',LaaPin 'dde_permanent_pin',
							CASE LaaAcmTyp WHEN 3 THEN 0 ELSE 1 END 'dde_pre_IsSameAdr'
					FROM	LosAppAddress(NOLOCK)
				    WHERE	LaaLapFk=@LapPk AND LaaAddTyp='1' AND LaaDelId=0

					--Occupation SelfEmployed
					SELECT	LabBusiTyp 'dde_occSelf_typOfbus',LabOrgTyp 'dde_occSelf_typOfOrg',LabNm 'dde_occSelf_bus',LabNat 'dde_occSelf_NaturOfBus',LabOwnShip 'dde_occSelf_bus_ownershp',LabIncYr 'dde_occSelf_yrOfIncorp',LabBusiPrd 'dde_occSelf_tot_bus',
							LabCIN 'dde_occSelf_cin',LabCurBusiPrd 'dde_occSelf_noOfyrsCurrent',LabOffNo 'dde_occSelf_Busphno',LabEMail 'dde_occSelf_bus_em',
							LabMSME 'dde_occSelf_msme'
					FROM	LosAppBusiProfile(NOLOCK)
					WHERE	LabLapFk = @LapPk AND LabDelId=0

					--Occupation Salaried
					SELECT	LaeNm 'dde_occ_org',LaeTyp 'dde_occSal_typeOfOrg',LaeNat 'dde_occsal_nature_of_emp',LaeDesig 'dde_occSal_desig',LaeExp 'dde_occSal_no_of_month',
							LaeTotExp 'dde_occSal_tot_emp',LaeOffNo 'dde_occSal_officialphno',LaeEMail 'dde_occSal_officialemail',LaeEmpId 'dde_occSal_emp_id',
							LapMonIncAmt 'dde_occSal_MonIncome',LapOthIncAmt 'dde_occsal_otherIncome'
				    FROM	LosAppOffProfile(NOLOCK)
				    WHERE	LaeLapFk=@LapPk AND LaeDelId=0

					--Occupation address
					SELECT	LaaAddTyp 'AddType',LaaDoorNo 'dde_occSal_offAddr_doorno',LaaBuilding 'dde_occSal_offAddr_building',
							LaaPlotNo 'dde_occSal_offAddr_plotno',LaaStreet 'dde_occSal_offAddr_strt',LaaLandmark 'dde_occSal_offAddr_Landmark',
							LaaArea 'dde_occSal_offAddr_twn_vil',LaaDistrict 'dde_occSal_offAddr_dis_city',LaaState 'dde_occSal_offAddr_state',
							LaaPin 'dde_occSal_offAddr_pin'
					FROM	LosAppAddress(NOLOCK)
				    WHERE	LaaLapFk=@LapPk AND LaaAddTyp IN (-1,2,3,4) AND LaaDelId=0

					--Bank
			        SELECT  LbkPk 'dde_bank_pk',LbkNm 'dde_Bank_Name1', LbkAccTyp 'dde_Bank_AcType1',LbkAccNo 'dde_Bank_AcNum1',
							LbkBank 'dde_Bank_bnkName2',LbkBranch 'dde_Bank_branch2',LbkBnkFk 'dde_Bank_bnkName1',LbkBbmFk 'dde_Bank_branch1',
							DBO.gefgDMY(LbkOpSince) 'dde_op_since1'
					FROM	LosAppBank(NOLOCK)
				    WHERE	LbkLapFk = @LapPk AND LbkDelId=0  
				    				    
				--Asset
					SELECT	LasPk 'dde_Ast_Pk',LasTyp 'dde_Asset_type1',LasDesc 'dde_Asset_des1',LasAmt 'dde_Asset_amt1'
					FROM	LosAppAst(NOLOCK)
	
				    WHERE	LasLapFk=@LapPk AND  LasTyp IN (0,1,2,3,4,5)  AND LasDelId=0 

						--Obligation
					SELECT	LaoPk 'dde_obl_Pk',LoaIsIncl 'dde_ob_IsIncl',LaoTyp 'dde_ob_typofloan',LaoIsShri 'dde_ob_IsShri',
							LaoSrc 'dde_ob_bank1',LaoRefNo 'dde_ob_refno1',LaoEMI 'dde_ob_emi1',LaoOutstanding 'dde_ob_outstnd1',LaoTenure 'dde_ob_bal1',LaoNotes 'dde_ob_notes',
							CASE WHEN LaoLnamt=0 THEN 0 ELSE LaoLnamt END 'dde_ob_lnamt1'			
					FROM	LosAppObl(NOLOCK)
				    WHERE	LaoLapFk = @LapPk AND LaoDelId=0
				
				      --Credit Card
			        SELECT  LacPk 'dde_crd_Pk', LacTyp 'dde_cc_ctype1',LacIsuBnk 'dde_cc_issuingbnk2',LacBnkFk 'dde_cc_issuingbnk1',LacLimit 'dde_cc_limit1',LacCrdNo 'dde_cc_cno1'		
					FROM	LosAppCreditCrd(NOLOCK)
				    WHERE	LacLapFk = @LapPk AND LacDelId=0
					
					IF @TmpAction = 'LdDtls'
					BEGIN
						--Legal hier
						SELECT  LlhPk 'dde_legal_pk',LlhNm 'dde_Per_Legal_heir_Name1',LlhRelation 'dde_Per_Legal_heir_Relation1',LlhAge 'dde_Per_Legal_heir_Age1',
								LlhIsEmpl 'dde_Per_Legal_hier_Proof1',LlhMarSts 'dde_Per_Legal_heir_Ref1'
						FROM	LosAppLegalHier(NOLOCK)
						WHERE	LlhAppFk = @APPPk AND LlhDelId=0
						
						SELECT	LarPk 'pk' INTO #AppRef FROM LosAppRef(NOLOCK) WHERE LarAppFk = @APPPk AND LarDelId=0
						
						SELECT	pk FROM #AppRef
						SELECT	TOP 1 @RefFk = pk FROM #AppRef ORDER BY pk
						
						SET @Action = 'Ref'
					END

					SELECT	LasDesc 'dde_Asset_car'
					FROM	LosAppAst(NOLOCK)
				    WHERE	LasLapFk=@LapPk AND  LasTyp IN (6)  AND LasDelId=0 

					SELECT	LasDesc 'dde_Asset_twowheelr'
					FROM	LosAppAst(NOLOCK)
				    WHERE	LasLapFk=@LapPk AND  LasTyp IN (7)  AND LasDelId=0 

					SELECT	LasDesc 'dde_Asset_threewheelr'
					FROM	LosAppAst(NOLOCK)
				    WHERE	LasLapFk=@LapPk AND  LasTyp IN (8)  AND LasDelId=0 

				    SELECT	LanNotes 'dde_Asset_Remarks',LanPk 'dde_Astnotes_Pk'
					FROM	LosAppNotes(NOLOCK)
				    WHERE	LanLapFk=@LapPk AND LanTyp='A' AND LanDelId=0 

					SELECT	LanPk 'dde_OBnotes_Pk' ,LanNotes 'dde_ob_remarks'
					FROM	LosAppNotes(NOLOCK)
				    WHERE	LanLapFk=@LapPk AND LanTyp='O' AND LanDelId=0 

					SELECT	LanPk 'dde_ccnotes_Pk' ,LanNotes 'dde_cc_remarks'
					FROM	LosAppNotes(NOLOCK)
				    WHERE	LanLapFk=@LapPk AND LanTyp='C' AND LanDelId=0 

					SELECT	KYCPk 'dde_DOCPK',KYCDocTyp 'dde_KycProof',KYCGdmFk 'dde_KycPk',GdmName 'dde_KycDocument',DBO.gefgDMY(KYCValidUpto) 'dde_KycDate',
					        KYCDocVal 'dde_KycRefno',KYCRmks 'dde_kyc_notes',DBO.gefgDMY(KycRefDt) 'dde_KycrefDate'
					FROM	LosAppKYCDocuments(NOLOCK)
					JOIN    GenDocuments(NOLOCK) ON GdmPk=KYCGdmFk AND GdmDelId=0
				    WHERE	KYCLapFk=@LapPk AND KYCDelId=0 
					
				    SELECT   LadDocTyp 'Com_Doctype', LadGdmFk 'Com_DoctPk',DBO.gefgDMY(LadRcvdDt) 'Com_RecDate',LadDocVal 'Com_Refno',
			                 LadDocSts 'Com_Docstatus',DBO.gefgDMY(LadValidUpto) 'Com_ValidDate',LadPk 'Com_rowPk',GdmName 'Com_Docname',
						     LadRmks 'Com_notes',DBO.gefgDMY(LadRefDt) 'Com_refDate'
			        FROM     LosAppDocuments(NOLOCK)
			        JOIN     GenDocuments(NOLOCK) ON GdmPk=LadGdmFk AND GdmDelId=0
		            WHERE	 LadLapfk=@LapPk AND LadDelId=0 AND LadStage ='P'

					
				    SELECT   LadDocTyp 'Com_genDoctype', LadGdmFk 'Com_genDoctPk',DBO.gefgDMY(LadRcvdDt) 'Com_genRecDate',LadDocVal 'Com_genRefno',
			                 LadDocSts 'Com_genDocstatus',DBO.gefgDMY(LadValidUpto) 'Com_genValidDate',LadPk 'Com_genrowPk',GdmName 'Com_genDocname',
						     LadRmks 'Com_gennotes',DBO.gefgDMY(LadRefDt) 'Com_genrefDate'
			        FROM     LosAppDocuments(NOLOCK)
			        JOIN     GenDocuments(NOLOCK) ON GdmPk=LadGdmFk AND GdmDelId=0
		            WHERE	 LadLedFk=@LeadPk AND LadDelId=0  AND ISNULL(LadLapfk,0) = 0 AND LadStage ='P'

					SELECT	KYCPk 'dde_addDOCPK',KYCDocTyp 'dde_KycaddProof',KYCGdmFk 'dde_KycaddPk',GdmName 'dde_KycaddDocument',DBO.gefgDMY(KYCValidUpto) 'dde_KycaddDate',
					        KYCDocVal 'dde_KycaddRefno',KYCRmks 'dde_kyc_addnotes',DBO.gefgDMY(KycRefDt) 'dde_KycaddrefDate'
					FROM	LosAppKYCDocuments(NOLOCK)
					JOIN    GenDocuments(NOLOCK) ON GdmPk=KYCGdmFk AND GdmDelId=0
				    WHERE	KYCLapFk=@LapPk AND KYCDelId=0 AND KYCDocTyp not in ('A','I','S','D')
					
				END
				
			IF @Action = 'Ref'
				BEGIN
					--Reference
					SELECT		LarPk 'pk',LarNm 'dde_ref_Name',LarRel 'dde_ref_relName' ,LarOccup 'dde_ref_Occ',LarOffNo 'dde_ref_offphno',
								LarResNo 'dde_ref_resphno',LarEMail 'dde_ref_email',
								LaaAddTyp 'AddType',LaaDoorNo 'dde_ref_doorno',LaaBuilding 'dde_ref_building',LaaPlotNo 'dde_ref_plotno',
								LaaStreet 'dde_ref_street',LaaLandmark 'dde_ref_landmark',
								LaaArea 'dde_ref_twn_vil',LaaDistrict 'dde_ref_dis_city',LaaState 'dde_ref_state',LaaPin 'dde_pin_ref',
								LarMobNo 'dde_ref_mobno'
					FROM		LosAppRef(NOLOCK)
					JOIN		LosAppAddress(NOLOCK) ON LaaPk = LarLaaFk AND LaaDelid = 0
				    WHERE		LarPk = @RefFk
				END
			IF @Action = 'Save'
				BEGIN
					-- Header Details

			--30/11/2016 changes
		
						IF NOT EXISTS(SELECT 'X' FROM LosApp WHERE AppLedFk = @LeadPk AND AppDelId = 0) AND ISNULL(@HdrFk,0) = 0 
							BEGIN
								SELECT @frstnm = QDEFstNm  FROM LosQDE(NOLOCK) WHERE QDEActor = 0 AND QDELedFk = @LeadPk AND QDEDelId = 0
								INSERT INTO LosApp
								(
									AppLedFk,AppAgtFk,AppBGeoFk,AppPrdFk,AppApplNm,AppAppNo,AppPAppNo,AppLnPur,AppBuiLoc,
									AppRowId,AppCreatedBy,AppCreatedDt,AppModifiedBy,AppModifiedDt,AppDelFlg,AppDelId,AppPGrpFk,AppBuiLocFk,
									AppDocSts,AppAbtus
								)
								SELECT	@LeadPk,Agtfk,@GeoFk,@PrdFk, @frstnm, AppNo, PAppNo,dde_LnPur, BuiLoc,
										@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,@prdGfk,saleofzpk,Approverflag,dde_Abtus
								FROM	#HDTLS

								UPDATE	LosLead
								SET		LedPGrpFk = @prdGfk,LedModifiedBy = @UsrDispNm, LedModifiedDt = @CurDt, LedRowID = @RowId 
								WHERE	LedPk = @LeadPk

								SELECT	@APPPk = SCOPE_IDENTITY(),@Error = @@ERROR, @RowCount = @@ROWCOUNT
	
								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE Header Insert')
										RETURN
									END
					
								IF @RowCount = 0
									BEGIN
										RAISERROR('%s',16,1,'Error : No Rows Found for DDE Header Insert')
										RETURN
									END
							END
						ELSE
							BEGIN

								IF ISNULL(@HdrFk,0) = 0
									SELECT @HdrFk = AppPK FROM LosApp(NOLOCK) WHERE AppLedFk =@LeadPk AND AppDelId = 0

								SELECT @APPPk = @HdrFk, @LapFk = @LapPk

								UPDATE	LosApp
								SET		AppLnPur=dde_LnPur,AppBuiLoc = BuiLoc, AppPAppNo = PAppNo,AppPGrpFk=@prdGfk,AppRowId=@RowId,AppModifiedBy=@UsrDispNm,AppModifiedDt=@CurDt,
								        AppBuiLocFk=saleofzpk,AppDocSts=Approverflag,AppAbtus=dde_Abtus
								FROM	#HDTLS
								WHERE	AppPk = @APPPk AND AppDelid = 0						
							END
						
						--Personal Details
						IF @hide_personal_var = '20'
							BEGIN
							
								IF ISNULL(@LapFk,0) = 0
									BEGIN
							      Select @dderel=dde_Per_Religion  from  #DTLS
								  
								  IF @dderel = 'O'
								  BEGIN
								 Select @dderel=dde_Per_religion_other  from  #DTLS
								 
								  END

										INSERT INTO LosAppProfile
										(
											LapLedFK,LapAppFk,LapCusFk,LapCibil,LapActor,LapPrefNm,LapFstNm,LapMdNm,LapLstNm,LapGender,LapDOB,LapRelation,
											LapMaritalSts,LapNationality,LapReligion,LapCommunity,LapDpdCnt,LapMobile,LapResi,LapEMail,
											LapRowId,LapCreatedBy,LapCreatedDt,LapModifiedBy,LapModifiedDt,LapDelFlg,LapDelId,LapFatherFNm,LapFatherMNm,
											LapFatherLNm,LapMotherFNm,LapMotherMNm,LapMotherLNm,LapEducation,LapInsorUniv,
											LapAadhar,LapPAN,LapDrvLic,LapVotId,LapPassport,LapTitle, LapActorNm, LapEmpTyp,LapAltMobile,LosRelWthShriram,LosRelWthShriramRefNo,LapEduOth,LapComOth,
											LapOthDocAvl
										)
										SELECT	@LeadPk,@APPPk,@Cusfk,ISNULL(@CibilScr,0),@Actor,dde_Pref,dde_Fname,dde_Mname,dde_Lname,dde_gender,ISNULL(DBO.gefgChar2Date(dde_dob),@CurDt),dde_app_relation,
												dde_Per_marital_status,dde_Per_Nationality,@dderel,dde_Per_community,dde_Per_noOfDependent,dde_Per_Mobile,dde_Per_res,
												dde_Per_Email,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,
												dde_Per_Fat_hus_Fname,dde_Per_Fat_hus_Midname,dde_Per_Fat_hus_Lastname,
												dde_Per_mom_Fname,dde_Per_mom_Midname,dde_Per_mom_lastname,dde_Per_education,dde_ins_uni,
												dde_adr_no,dde_pan_no,dde_dl,dde_vot_id,dde_pass_no,dde_title, @ActorNm,
												ISNULL(dde_occ_typeOfEmployment,-1),dde_Per_alt,dde_Per_relationwitSvs,dde_Per_refNO,dde_Per_edu_others,dde_Per_community_other,
												CASE WHEN dde_chk_doc = '0' THEN 'Y' ELSE 'N' END
										FROM	#DTLS
										  		
										SELECT	@LapFk = SCOPE_IDENTITY(),@Error = @@ERROR
			
										IF @Error > 0
											BEGIN
												RAISERROR('%s',16,1,'Error : DDE Personal details Insert')
												RETURN
											END
									END
									ELSE
										BEGIN
										 Select @dderel=dde_Per_Religion  from  #DTLS
								  
								  IF @dderel = 'O'
								  BEGIN
								 Select @dderel=dde_Per_religion_other  from  #DTLS
								  END
											 UPDATE LosAppProfile
											 SET	LapPrefNm= dde_Pref,LapFstNm= dde_Fname,LapMdNm=dde_Mname,LapLstNm=dde_Lname,LapGender=dde_gender,LapDOB=ISNULL(DBO.gefgChar2Date(dde_dob),@CurDt),
													LapRelation=dde_app_relation,LapMaritalSts=dde_Per_marital_status,LapNationality=dde_Per_Nationality,LapReligion=@dderel,
													LapCommunity=dde_Per_community,LapDpdCnt=dde_Per_noOfDependent ,LapMobile=dde_Per_Mobile,LapResi=dde_Per_res,
													LapEMail=dde_Per_Email,LapRowId=@RowId,LapModifiedBy=@UsrDispNm,LapModifiedDt=@CurDt,LapFatherFNm=dde_Per_Fat_hus_Fname,
													LapFatherMNm=dde_Per_Fat_hus_Midname,LapFatherLNm=dde_Per_Fat_hus_Lastname,LapMotherFNm=dde_Per_mom_Fname,LapMotherMNm=dde_Per_mom_Midname,
													LapMotherLNm=dde_Per_mom_lastname,LapEducation=dde_Per_education,LapInsorUniv=dde_ins_uni,
													LapAadhar=dde_adr_no,LapPAN=dde_pan_no,LapDrvLic=dde_dl,LapVotId=dde_vot_id,LapPassport=dde_pass_no,
													LapTitle = dde_title, LapActorNm = @ActorNm,LapAltMobile=dde_Per_alt,LosRelWthShriram=dde_Per_relationwitSvs,
													LosRelWthShriramRefNo=dde_Per_refNO,LapEduOth=dde_Per_edu_others,LapComOth=dde_Per_community_other,LapOthDocAvl=CASE WHEN dde_chk_doc = '0' THEN 'Y' ELSE 'N' END
											FROM	#DTLS
											WHERE	LapPk=@LapFk  AND LapDelid = 0
										END

								--Present,Permanent	Address		
								IF @hide_pre_per_var = '0'
									BEGIN
										IF NOT EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp = 0 AND LaaDelid = 0)
											BEGIN
											
												INSERT INTO  LosAppAddress
												(
													LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
													LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
													LaaDelFlg,LaaDelId,LaaRentAmt 
												)
												SELECT	@LeadPk,@APPPk,@LapFk,dde_pre_per_hidden,dde_Per_Comm_addr,dde_Per_acc,isnull(dde_residing_yrs,''),dde_doorno,dde_building,dde_plotno,dde_street,dde_lndmrk,dde_twn_vil,
														dde_dis_city,dde_state,'Indian',dde_pin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,isnull(dde_rental,0)
												FROM	#DTLS

												SELECT	@LaaFk = SCOPE_IDENTITY(),@Error = @@ERROR
			
												IF @Error > 0
													BEGIN
														RAISERROR('%s',16,1,'Error : DDE Present Address Insert')
														RETURN
													END	
											END
										ELSE
											BEGIN
												 UPDATE LosAppAddress
												 SET	LaaComAdd=dde_Per_Comm_addr,LaaAcmTyp=dde_Per_acc,LaaYrsResi=isnull(dde_residing_yrs,''),LaaDoorNo=dde_doorno,
														LaaBuilding=dde_building,LaaPlotNo=dde_plotno,LaaStreet=dde_street,LaaLandmark=dde_lndmrk,
														LaaArea=dde_twn_vil,LaaDistrict=dde_dis_city,LaaState=dde_state,LaaPin=dde_pin,LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt,
														LaaRentAmt=isnull(dde_rental,0)
												 FROM	#DTLS
												 WHERE  LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp = 0 AND LaaDelid = 0
											END
										
									IF ISNULL(@dde_pre_IsSameAdr,0) = 0
											SET @hide_pre_per_var = '1';
                                        ELSE IF @dde_pre_IsSameAdr = 1
										BEGIN
										UPDATE	LosAppAddress
										SET		LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
										FROM	#DTLS
										WHERE	LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp=1 AND LaaAcmTyp=3 AND  LaaDelId = 0
										END
									END

								 IF @hide_pre_per_var='1'
									BEGIN
										IF NOT EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp = 1 AND LaaDelid = 0)
											BEGIN
												INSERT INTO  LosAppAddress
												(
													LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
													LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
													LaaDelFlg,LaaDelId
												)
												SELECT	@LeadPk,@APPPk,@LapFk,@hide_pre_per_var,0,CASE @dde_pre_IsSameAdr WHEN 1 THEN 0 ELSE 3 END,0,dde_permanent_doorno,dde_permanent_building,dde_permanent_plotno,dde_permanent_street,dde_permanent_lndmrk,
														dde_permanent_twn_vil,dde_permanent_dis_city,dde_permanent_state,'Indian',dde_permanent_pin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
												FROM	#DTLS

												SELECT	@LaaFk = SCOPE_IDENTITY(),@Error = @@ERROR
			
												IF @Error > 0
													BEGIN
														RAISERROR('%s',16,1,'Error : DDE Permanent Address Insert')
														RETURN
													END
											 END
										 ELSE
											 BEGIN
												UPDATE LosAppAddress
												SET		LaaAcmTyp= CASE @dde_pre_IsSameAdr WHEN 1 THEN 0 ELSE 3 END,LaaDoorNo=dde_permanent_doorno,LaaBuilding=dde_permanent_building,LaaPlotNo=dde_permanent_plotno,LaaStreet=dde_permanent_street,LaaLandmark=dde_permanent_lndmrk,
														LaaArea=dde_permanent_twn_vil,LaaDistrict=dde_permanent_dis_city,LaaState=dde_permanent_state,LaaPin=dde_permanent_pin,LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
												FROM	#DTLS
												WHERE	LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp = 1 AND LaaDelid = 0
											 END
									END
							END
						
					-- Occupation
						IF @hide_occ_var = '21'
							BEGIN
								IF EXISTS(SELECT 'X' FROM LosAppProfile(NOLOCK) WHERE LapEmpTyp <> @hide_self_var AND LapAppFk = @APPPk  AND LapPk = @LapFk AND  LapDelId = 0)
								BEGIN
									select @emptype = LapEmpTyp FROM LosAppProfile(NOLOCK) WHERE LapAppFk = @APPPk  AND LapPk = @LapFk AND  LapDelId = 0
									IF @emptype = 1
									BEGIN
										UPDATE	LosAppBusiProfile
										SET		LabDelId = 1, LabDelFlg = dbo.gefgGetDelFlg(@CurDt),LabRowId=@RowId,LabModifiedBy=@UsrDispNm,LabModifiedDt=@CurDt
										FROM	#DTLS
										WHERE	LabAppFk = @APPPk AND LabLapFk = @LapFk AND  LabDelId = 0
									END
									
									ELSE IF @emptype = 0
									BEGIN
										UPDATE	LosAppOffProfile
										SET		LaeDelId = 1, LaeDelFlg = dbo.gefgGetDelFlg(@CurDt),LaeRowId=@RowId,LaeModifiedBy=@UsrDispNm,LaeModifiedDt=@CurDt
										FROM	#DTLS
										WHERE	LaeAppFk = @APPPk AND LaeLapFk = @LapFk AND  LaeDelId = 0
									END
									
									UPDATE	LosAppAddress
									SET		LaaDelId = 1, LaaDelFlg = dbo.gefgGetDelFlg(@CurDt),LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
				                    FROM	#DTLS
									WHERE   LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp IN (-1,2,3,4) AND  LaaDelId = 0
                                END
                               

								UPDATE LosAppProfile SET LapEmpTyp = @hide_self_var WHERE LapPk = @LapFk
							     
								--Self Employed
									IF @hide_self_var = '1'
										BEGIN
											SELECT @hide_sal_var = 2
											IF NOT EXISTS(SELECT 'X' FROM LosAppBusiProfile(NOLOCK) WHERE LabAppFk = @APPPk AND LabLapFk = @LapFk AND  LabDelId = 0)
												BEGIN
												--30/11/2016 changes
												  Select @nature=dde_occSelf_NaturOfBus  from  #DTLS
								  
													  IF @nature = '8'
														BEGIN
														 Select @nature=dde_occSelf_NaturOfBus_others  from  #DTLS
														  END
													INSERT INTO LosAppBusiProfile
													(
														LabLedFk,LabAppFk,LabLapFk,LabBusiTyp,LabOrgTyp,LabNm,LabNat,LabOwnShip,LabIncYr,LabBusiPrd,LabCIN,LabOffNo,LabEMail,
														LabRowId,LabCreatedBy,LabCreatedDt,LabModifiedBy,LabModifiedDt,LabDelFlg,LabDelId,LabCurBusiPrd,LabMSME
													)
													SELECT	@LeadPk,@APPPk,@LapFk,dde_occSelf_typOfbus,Isnull(dde_occSelf_typOfOrg,-1),dde_occSelf_bus,@nature,
															dde_occSelf_bus_ownershp,dde_occSelf_yrOfIncorp,dde_occSelf_tot_bus,dde_occSelf_cin,dde_occSelf_Busphno,dde_occSelf_bus_em,
															@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,dde_occSelf_noOfyrsCurrent,dde_occSelf_msme
													FROM	#DTLS

													SELECT	@Error = @@ERROR
	
													IF @Error > 0
													BEGIN
														RAISERROR('%s',16,1,'Error : DDE Occupation self employed Insert')
														RETURN
													END
												END
											ELSE
											 BEGIN
											 Select @nature=dde_occSelf_NaturOfBus  from  #DTLS
								  
													  IF @nature = '8'
														BEGIN
														 Select @nature=dde_occSelf_NaturOfBus_others  from  #DTLS
													    END

												 UPDATE	LosAppBusiProfile
												 SET	LabBusiTyp=dde_occSelf_typOfbus,LabOrgTyp=Isnull(dde_occSelf_typOfOrg,-1),LabNm=dde_occSelf_bus,
														LabNat=@nature,LabOwnShip=dde_occSelf_bus_ownershp,LabIncYr=dde_occSelf_yrOfIncorp,
														LabBusiPrd=dde_occSelf_tot_bus,
														LabCIN=dde_occSelf_cin,LabOffNo=dde_occSelf_Busphno,LabEMail=dde_occSelf_bus_em,
														LabRowId=@RowId,LabModifiedBy=@UsrDispNm,LabModifiedDt=@CurDt,LabCurBusiPrd=dde_occSelf_noOfyrsCurrent,
														LabMSME=dde_occSelf_msme
												 FROM	#DTLS
												 WHERE  LabAppFk = @APPPk AND LabLapFk = @LapFk AND  LabDelId = 0

											END
										END

								--Salaried
									ELSE IF @hide_self_var = '0'
										BEGIN
										
											SELECT @hide_sal_var = '3'
											IF NOT EXISTS(SELECT 'X' FROM LosAppOffProfile(NOLOCK) WHERE LaeAppFk = @APPPk AND LaeLapFk = @LapFk AND  LaeDelId = 0)
												BEGIN
													INSERT INTO LosAppOffProfile
													(
														LaeLedFk,LaeAppFk,LaeLapFk,LaeNm,LaeTyp,LaeNat,LaeDesig,LaeExp,LaeTotExp,LaeOffNo,LaeEMail,LaeRowId,LaeCreatedBy,LaeCreatedDt,LaeModifiedBy,LaeModifiedDt,LaeDelFlg,LaeDelId,LaeEmpId,
														LapMonIncAmt,LapOthIncAmt
													)
													SELECT	@LeadPk,@APPPk,@LapFk,dde_occ_org,dde_occSal_typeOfOrg,dde_occsal_nature_of_emp,dde_occSal_desig,dde_occSal_no_of_month,
															dde_occSal_tot_emp,dde_occSal_officialphno,dde_occSal_officialemail,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,dde_occSal_emp_id,
															dde_occSal_MonIncome,dde_occsal_otherIncome
													FROM	#DTLS

													SELECT	@Error = @@ERROR
	
													IF @Error > 0
														BEGIN
															RAISERROR('%s',16,1,'Error : DDE Occupation salaried Address Insert')
															RETURN
														END
												END
											ELSE
												BEGIN
													UPDATE	LosAppOffProfile
													SET		LaeNm=dde_occ_org,LaeTyp=dde_occSal_typeOfOrg,LaeNat=dde_occsal_nature_of_emp,LaeDesig=dde_occSal_desig,
															LaeExp=dde_occSal_no_of_month,LaeTotExp=dde_occSal_tot_emp,
															LaeOffNo=dde_occSal_officialphno,LaeEMail=dde_occSal_officialemail,LaeRowId=@RowId,
															LaeModifiedBy=@UsrDispNm,LaeModifiedDt=@CurDt,LaeEmpId=dde_occSal_emp_id,
															LapMonIncAmt=dde_occSal_MonIncome,LapOthIncAmt=dde_occsal_otherIncome
													FROM	#DTLS
													WHERE	LaeAppFk = @APPPk AND LaeLapFk = @LapFk AND  LaeDelId = 0
												END
										END
									ELSE IF @hide_self_var = '4'
										SET @hide_sal_var = '4'
								
								IF ISNULL(@hide_sal_var,0) > 0
									BEGIN
										-- Occupation Address
											IF NOT EXISTS(SELECT 'X' FROM LosAppAddress(NOLOCK) WHERE LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp = @hide_sal_var AND LaaDelId = 0)
												BEGIN
													INSERT INTO  LosAppAddress
													(
														LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
														LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
														LaaDelFlg,LaaDelId
													)
													SELECT	@LeadPk,@APPPk,@LapFk,@hide_sal_var,0,0,0,dde_occSal_offAddr_doorno,dde_occSal_offAddr_building,dde_occSal_offAddr_plotno,dde_occSal_offAddr_strt,dde_occSal_offAddr_Landmark,
															dde_occSal_offAddr_twn_vil, dde_occSal_offAddr_dis_city,dde_occSal_offAddr_state,'Indian',dde_occSal_offAddr_pin,@RowId,
															@UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
													FROM	#DTLS

													SELECT	@LaaFk = SCOPE_IDENTITY(),@Error = @@ERROR
			
													IF @Error > 0
														BEGIN
															RAISERROR('%s',16,1,'Error : DDE Occupation Address Insert')
															RETURN
														END
												END
											ELSE
												BEGIN
													UPDATE	LosAppAddress
													SET		LaaDoorNo=dde_occSal_offAddr_doorno,LaaBuilding=dde_occSal_offAddr_building,LaaPlotNo=dde_occSal_offAddr_plotno,
															LaaStreet=dde_occSal_offAddr_strt,LaaLandmark=dde_occSal_offAddr_Landmark,
															LaaArea=dde_occSal_offAddr_twn_vil,LaaDistrict=dde_occSal_offAddr_dis_city,
															LaaState=dde_occSal_offAddr_state,LaaPin=dde_occSal_offAddr_pin,LaaRowId=@RowId,LaaModifiedBy=@UsrDispNm,LaaModifiedDt=@CurDt
													FROM	#DTLS
													WHERE   LaaAppFk = @APPPk AND LaaLapFk = @LapFk AND LaaAddTyp=@hide_sal_var AND  LaaDelId = 0
												END
									END
							END

					-- Bank
						IF @hide_bank_hidden='22'  
						BEGIN
							IF EXISTS(SELECT 'X' FROM #BankDTLS)
								BEGIN
								
								   UPDATE	LosAppBank
								   SET 	    LbkDelId = 1, LbkDelFlg = dbo.gefgGetDelFlg(@CurDt),LbkRowId=@RowId,LbkModifiedBy=@UsrDispNm,LbkModifiedDt=@CurDt
								   FROM	    #BankDTLS
								   WHERE	LbkAppFk = @APPPk AND LbkLapFk = @LapFk AND LbkDelid = 0

								
									INSERT INTO  LosAppBank
									(
										LbkLedFk,LbkAppFk,LbkLapFk,LbkNm,LbkAccTyp,LbkAccNo,LbkBnkFk,LbkBbmFk,LbkIFSC,LbkBank,LbkBranch,
										LbkRowId,LbkCreatedBy,LbkCreatedDt,LbkModifiedBy,LbkModifiedDt,LbkDelFlg,LbkDelId,LbkOpSince
									)
									OUTPUT INSERTED.LbkPk INTO #Bnk
									SELECT	@LeadPk,@APPPk,@LapFk,dde_Bank_Name1,dde_Bank_AcType1,dde_Bank_AcNum1,dde_Bank_bnkName1,dde_Bank_branch1,0,
											dde_Bank_bnkName2,dde_Bank_branch2,
											@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,DBO.gefgChar2Date(dde_op_since1)
									FROM	#BankDTLS
				
									

								
									SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE Bank Details Insert')
											RETURN
										END	

								END
						END
							
					   --ASSET
						--IF @hide_cc_var='23' BEGIN /* Remarks,Vehicle */ END 

						IF EXISTS(SELECT 'X' FROM #ASSETDTLS)
							BEGIN
							    UPDATE	LosAppAst
								SET 	LasDelid = 1, LasDelFlg = dbo.gefgGetDelFlg(@CurDt),LasRowId=@RowId,LasModifiedBy=@UsrDispNm,LasModifiedDt=@CurDt
								FROM	#ASSETDTLS
								WHERE	LasAppFk = @APPPk AND LasLapFk = @LapFk AND LasDelid = 0


								INSERT INTO  LosAppAst
								(
									LasLedFk,LasAppFk,LasLapFk,LasTyp,LasDesc,LasAmt,LasRowId,LasCreatedBy,LasCreatedDt,LasModifiedBy,LasModifiedDt,LasDelFlg,LasDelId
								)
								OUTPUT INSERTED.LasPk INTO #Ast
								SELECT	@LeadPk,@APPPk,@LapFk,dde_Asset_type1,dde_Asset_des1,dde_Asset_amt1,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
								FROM	#ASSETDTLS
								
								SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE Asset Grid Insert')
											RETURN
										END	
								

								--Asset Car
								IF (@dde_Asset_car != '-1')
			                    BEGIN
								INSERT INTO  LosAppAst
								(
									LasLedFk,LasAppFk,LasLapFk,LasTyp,LasDesc,LasAmt,LasRowId,LasCreatedBy,LasCreatedDt,LasModifiedBy,LasModifiedDt,LasDelFlg,LasDelId
								)
								OUTPUT INSERTED.LasPk INTO #Ast
								SELECT	@LeadPk,@APPPk,@LapFk,6,@dde_Asset_car,0,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
							
								SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE Asset Car Insert')
											RETURN
										END	

								END
								--Asset TwoWheeler
								IF (@dde_Asset_twowheelr != '-1')
			                    BEGIN
								INSERT INTO  LosAppAst
								(
									LasLedFk,LasAppFk,LasLapFk,LasTyp,LasDesc,LasAmt,LasRowId,LasCreatedBy,LasCreatedDt,LasModifiedBy,LasModifiedDt,LasDelFlg,LasDelId
								)
								OUTPUT INSERTED.LasPk INTO #Ast
								SELECT	@LeadPk,@APPPk,@LapFk,7,@dde_Asset_twowheelr,0,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
							
							    SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE Asset Twowheeler Insert')
											RETURN
										END	

								END
								--Asset ThreeWheeler
								IF (@dde_Asset_threewheelr != '-1')
			                    BEGIN
								INSERT INTO  LosAppAst
								(
									LasLedFk,LasAppFk,LasLapFk,LasTyp,LasDesc,LasAmt,LasRowId,LasCreatedBy,LasCreatedDt,LasModifiedBy,LasModifiedDt,LasDelFlg,LasDelId
								)
								OUTPUT INSERTED.LasPk INTO #Ast
								SELECT	@LeadPk,@APPPk,@LapFk,8,@dde_Asset_threewheelr,0,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
								
								SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE Asset ThreeWheeler Insert')
											RETURN
										END	

								END
								 
							END
								IF @hide_ass_var is Not Null AND ISNULL(@dde_Asset_Remarks,'') <> ''
							 BEGIN
								
								UPDATE	LosAppNotes
								SET 	LanDelId = 1, LanDelFlg = dbo.gefgGetDelFlg(@CurDt),LanRowId=@RowId,LanModifiedBy=@UsrDispNm,LanModifiedDt=@CurDt
								WHERE	LanAppFk = @APPPk AND LanLapFk = @LapFk AND LanTyp='A' AND LanDelId = 0 
								
								INSERT INTO  LosAppNotes
								(
								LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
								LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
								)
								SELECT	@LeadPk,@APPPk,@LapFk,'A',@dde_Asset_Remarks,
								@RowId, @UsrDispNm,@CurDt, @UsrDispNm, @CurDt, NULL, 0

                         			IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE Asset Notes Insert')
										RETURN
									END	

					            
                              END
					   --Obligation						
						--IF	@hide_cc_var='24' BEGIN /* Remarks */ END 

						IF EXISTS(SELECT 'X' FROM #OBLIDTLS)
							BEGIN
								UPDATE	LosAppObl
								SET	    LaoDelid = 1, LaoDelFlg = dbo.gefgGetDelFlg(@CurDt),LaoRowId=@RowId,LaoModifiedBy=@UsrDispNm,LaoModifiedDt=@CurDt
								FROM	#OBLIDTLS
								WHERE	LaoAppFk = @APPPk AND LaoLapFk = @LapFk AND LaoDelid = 0

								INSERT INTO LosAppObl
								(
									LaoLedFk,LaoAppFk,LaoLapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,LaoNotes,
									LaoRowId,LaoCreatedBy,LaoCreatedDt,LaoModifiedBy,LaoModifiedDt,LaoDelFlg,LaoDelId,LaoLnamt
								)
								OUTPUT INSERTED.LaoPk INTO #Oblig
								SELECT	@LeadPk,@APPPk,@LapFk,dde_ob_IsIncl,dde_ob_typofloan,dde_ob_IsShri,dde_ob_bank1,dde_ob_refno1,dde_ob_emi1,dde_ob_outstnd1,
										dde_ob_bal1,dde_ob_notes,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,CASE WHEN dde_ob_lnamt1 ='' THEN 0 ELSE dde_ob_lnamt1 END 
								FROM	#OBLIDTLS

								SELECT	@Error = @@ERROR
								IF	@Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE Obligation details Insert')
										RETURN
									END
									 --Obligation Notes 
								
							END
							
							--IF NOT EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE ISNULL(@hide_ob_var,0)=0)
							IF @hide_ob_var is Not Null AND ISNULL(@dde_ob_remarks,'') <> ''
							 BEGIN 
							 --Obligation Notes 
					

								UPDATE	LosAppNotes
								SET 	LanDelId = 1, LanDelFlg = dbo.gefgGetDelFlg(@CurDt),LanRowId=@RowId,LanModifiedBy=@UsrDispNm,LanModifiedDt=@CurDt
								WHERE	LanAppFk = @APPPk AND LanLapFk = @LapFk AND LanTyp='O' AND LanDelId = 0

								INSERT INTO  LosAppNotes
								(
								LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
								LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
								)
								SELECT	@LeadPk,@APPPk,@LapFk,'O',@dde_ob_remarks,
								@RowId, @UsrDispNm,@CurDt, @UsrDispNm, @CurDt, NULL, 0


								SELECT	@Error = @@ERROR
	
								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE Asset Notes Insert')
										RETURN
									END	

					          
							
							END

					   --CreditCard			
						--IF	@hide_cc_var='25' BEGIN /* Remarks */ END 

						IF EXISTS(SELECT 'X' FROM #CREDITDTLS)
							BEGIN
								UPDATE	LosAppCreditCrd
								SET 	LacDelid = 1, LacDelFlg = dbo.gefgGetDelFlg(@CurDt),LacRowId=@RowId,LacModifiedBy=@UsrDispNm,LacModifiedDt=@CurDt
								FROM	#CREDITDTLS
								WHERE	LacAppFk = @APPPk AND LacLapFk = @LapFk AND LacDelid = 0

								INSERT INTO LosAppCreditCrd
								(
									LacLedFk,LacAppFk,LacLapFk,LacTyp,LacIsuBnk,LacBnkFk,LacLimit,LacCrdNo,LacRowId,LacCreatedBy,LacCreatedDt,LacModifiedBy,LacModifiedDt,
									LacDelFlg,LacDelId
								)
								OUTPUT INSERTED.LacPk INTO #Credit
								SELECT	@LeadPk,@APPPk,@LapFk,dde_cc_ctype1,dde_cc_issuingbnk2,dde_cc_issuingbnk1,dde_cc_limit1,dde_cc_cno1,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
								FROM	#CREDITDTLS
								
								
								SELECT	@Error = @@ERROR
								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE CreditCard Insert')
										RETURN
									END						

							END

							--Credit Card Notes 
							--IF NOT EXISTS(SELECT 'X' FROM LosAppNotes(NOLOCK) WHERE ISNULL(@hide_cc_var,0)=0)
							IF @hide_cc_var is Not Null AND ISNULL(@dde_cc_remarks,'') <> ''
							 BEGIN 
								

								UPDATE	LosAppNotes
								SET 	LanDelId = 1, LanDelFlg = dbo.gefgGetDelFlg(@CurDt),LanRowId=@RowId,LanModifiedBy=@UsrDispNm,LanModifiedDt=@CurDt
								WHERE	LanAppFk = @APPPk AND LanLapFk = @LapFk AND LanTyp='C' AND LanDelId = 0 

								INSERT INTO  LosAppNotes
								(
								LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
								LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId
								)
								SELECT	@LeadPk,@APPPk,@LapFk,'C',@dde_cc_remarks,
								@RowId, @UsrDispNm,@CurDt, @UsrDispNm, @CurDt, NULL, 0


								SELECT	@Error = @@ERROR
	
								IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE Asset Notes Insert')
										RETURN
									END	

					        
								 END

					    --LegalHier					
						IF EXISTS(SELECT 'X' FROM #LEGALDTLS)
							BEGIN
								/*
								UPDATE	LosAppLegalHier
								SET		LlhNm=dde_Per_Legal_heir_Name1,LlhRelation=dde_Per_Legal_heir_Relation1,LlhAge=dde_Per_Legal_heir_Age1,
										LlhIsEmpl=dde_Per_Legal_hier_Proof1,
										LlhMarSts=dde_Per_Legal_heir_Ref1,LlhRowId=@RowId,LlhModifiedBy=@UsrDispNm,LlhModifiedDt=@CurDt
								FROM	#LEGALDTLS
								WHERE   LlhPk = dde_legal_pk AND LlhAppFk = @APPPk AND LlhDelId=0
								--AND NOT EXISTS(SELECT 'X' FROM #LEGALDTLS WHERE dde_legal_pk = LlhPk)
								*/
								
								UPDATE	LosAppLegalHier
								SET		LlhDelid = 1,LlhDelFlg = dbo.gefgGetDelFlg(@CurDt),LlhRowId=@RowId,LlhModifiedBy=@UsrDispNm,LlhModifiedDt=@CurDt
								FROM	LosAppLegalHier(NOLOCK)
								WHERE   LlhAppFk = @APPPk AND LlhDelid = 0
								
								INSERT INTO LosAppLegalHier
								 (
									LlhLedFk,LlhAppFk,LlhNm,LlhRelation,LlhAge,LlhIsEmpl,LlhMarSts,LlhRowId,LlhCreatedBy,LlhCreatedDt,LlhModifiedBy,LlhModifiedDt,LlhDelFlg,LlhDelId
								 )
								 OUTPUT INSERTED.LlhPk INTO #Legal
								 SELECT @LeadPk,@APPPk,dde_Per_Legal_heir_Name1,dde_Per_Legal_heir_Relation1,dde_Per_Legal_heir_Age1,
										ISNULL(dde_Per_Legal_hier_Proof1,'-1'),
										ISNULL(dde_Per_Legal_heir_Ref1,'-1'),
										@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
								 FROM	#LEGALDTLS
								

								 SELECT	@Error = @@ERROR
								 IF @Error > 0
									BEGIN
										RAISERROR('%s',16,1,'Error : DDE LegalHier Insert')
										RETURN
									END
							END
					
					    --Reference					    
					    IF LEFT(ISNULL(@hide_ref_hidden,0),1) = '3'
							BEGIN
								IF ISNULL(@RefFk,0) = 0
									BEGIN
										INSERT INTO  LosAppAddress
										(
											LaaLedFK,LaaAppFk,LaaLapFk,LaaAddTyp,LaaComAdd,LaaAcmTyp,LaaYrsResi,LaaDoorNo,LaaBuilding,LaaPlotNo,LaaStreet,LaaLandmark,
											LaaArea,LaaDistrict,LaaState,LaaCountry,LaaPin,LaaRowId,LaaCreatedBy,LaaCreatedDt,LaaModifiedBy,LaaModifiedDt,
											LaaDelFlg,LaaDelId
										)
										SELECT	@LeadPk,@APPPk,@LapFk,'5', 0,0,0,ISNULL(dde_ref_doorno,''),ISNULL(dde_ref_building,''),ISNULL(dde_ref_plotno,''),
												ISNULL(dde_ref_street,''),ISNULL(dde_ref_landmark,''),ISNULL(dde_ref_twn_vil,''),
												ISNULL(dde_ref_dis_city,''),ISNULL(dde_ref_state,''),'Indian',ISNULL(dde_pin_ref,''),@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0
										FROM	#DTLS

										SELECT	@LaaFk = SCOPE_IDENTITY(),@Error = @@ERROR
										IF @Error > 0
											BEGIN
												RAISERROR('%s',16,1,'Error : DDE Reference Address Insert')
												RETURN
											END

										INSERT INTO LosAppRef
										(
											LarLedFk,LarAppFk,LarLaaFk,LarNm,LarRel,LarOccup,LarOffNo,LarResNo,LarEMail,LarRowId,LarCreatedBy,LarCreatedDt,LarModifiedBy,
											LarModifiedDt,LarDelFlg,LarDelId,LarMobNo 
										)
										SELECT	@LeadPk,@APPPk,@LaaFk,ISNULL(dde_ref_Name,''),ISNULL(dde_ref_relName,''),ISNULL(dde_ref_Occ,''),ISNULL(dde_ref_offphno,''),
												ISNULL(dde_ref_resphno,''),ISNULL(dde_ref_email,''),@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,dde_ref_mobno
										FROM	#DTLS

										 SELECT	@RefFk = SCOPE_IDENTITY(), @Error = @@ERROR
										 IF @Error > 0
											BEGIN
												RAISERROR('%s',16,1,'Error : DDE Reference Insert')
												RETURN
											END

									END
									
								ELSE
									BEGIN
										SELECT	@LaaFk = LarLaaFk,@RefFk = LarPk FROM LosAppRef(NOLOCK) WHERE LarPk = @RefFk AND LarDelid = 0
										
										UPDATE	LosAppRef
										SET		LarNm = ISNULL(dde_ref_Name,''),LarRel = ISNULL(dde_ref_relName,''),LarOccup = ISNULL(dde_ref_Occ,''),
												LarOffNo  = ISNULL(dde_ref_offphno,''),LarResNo  = ISNULL(dde_ref_resphno,'') ,LarEMail  = ISNULL(dde_ref_email,''),
												LarRowId  = @RowId,LarModifiedBy = @UsrDispNm, LarModifiedDt = @CurDt,LarMobNo =ISNULL(dde_ref_mobno,'')
										FROM	#DTLS
										WHERE	LarPk = @RefFk AND LarDelid = 0

										UPDATE	LosAppAddress
										SET		LaaDoorNo = ISNULL(dde_ref_doorno,''),LaaBuilding = ISNULL(dde_ref_building,''),LaaPlotNo = ISNULL(dde_ref_plotno,''),
												LaaStreet = ISNULL(dde_ref_street,''),LaaLandmark = ISNULL(dde_ref_landmark,''),
												LaaArea = ISNULL(dde_ref_twn_vil,''),LaaDistrict = ISNULL(dde_ref_dis_city,''),
												LaaState = ISNULL(dde_ref_state,''),LaaPin = ISNULL(dde_pin_ref,''),
												LaaRowId = @RowId,LaaModifiedBy = @UsrDispNm,LaaModifiedDt = @CurDt
										FROM	#DTLS
										WHERE	LaaPk = @LaaFk AND LaaDelId = 0
								END
							END
							IF EXISTS(SELECT 'X' FROM #Loandtls)
							BEGIN
							 --   UPDATE	LosAppKYCDocuments
								--SET 	KYCDelId = 1, KYCDelFlg = dbo.gefgGetDelFlg(@CurDt),KYCRowId=@RowId,KYCModifiedBy=@UsrDispNm,KYCModifiedDt=@CurDt
								--FROM	#Loandtls
								--WHERE	KYCAppFk = @APPPk AND KYCLapFk = @LapFk AND KYCDelId = 0
								 INSERT INTO LosAppKYCDocuments
						              (
									   KYCLedFk,KYCAppFk,KYCLapFk,KYCDocTyp,KYCGdmFk,KYCDocVal,KYCValidUpto,
						               KYCRowId,KYCCreatedBy,KYCCreatedDt,KYCModifiedBy,KYCModifiedDt,KYCDelFlg,KYCDelId,
									   KycRefDt,KYCRmks
									  )
								OUTPUT INSERTED.KYCPk INTO #KYC
								SELECT	@LeadPk,@APPPk,@LapFk,dde_KycProof,dde_KycPk,dde_KycRefno,DBO.gefgChar2Date(dde_KycDate),@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,
								        DBO.gefgChar2Date(dde_KycrefDate),dde_kyc_notes
								FROM	#Loandtls where  ISNULL(dde_DOCPK ,0) = 0 AND ISNULL(dde_KycPk , 0) != 0 
							
							    UPDATE LosAppKYCDocuments
							    SET    KYCDocTyp=dde_KycProof,KYCGdmFk=dde_KycPk,KYCDocVal=dde_KycRefno,
							           KYCValidUpto=DBO.gefgChar2Date(dde_KycDate),KycRefDt=DBO.gefgChar2Date(dde_KycrefDate),
								       KYCRmks=dde_kyc_notes
							    FROM  #Loandtls where  KYCPk=dde_DOCPK 
							    
								
								SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE KYC Grid Insert')
											RETURN
										END	
								
						  END
						IF @dde_kyc_hidden = '26'
						BEGIN
						  IF EXISTS(SELECT 'X' FROM #Kycadddtls)
							BEGIN
							
							    UPDATE	LosAppKYCDocuments
								SET 	KYCDelId = 1, KYCDelFlg = dbo.gefgGetDelFlg(@CurDt),KYCRowId=@RowId,KYCModifiedBy=@UsrDispNm,KYCModifiedDt=@CurDt
								WHERE	KYCAppFk = @APPPk AND KYCLapFk = @LapFk AND KYCDelId = 0 AND KYCDocTyp NOT IN ('A','D','I','S')

							    INSERT INTO LosAppKYCDocuments
						              (
									   KYCLedFk,KYCAppFk,KYCLapFk,KYCDocTyp,KYCGdmFk,KYCDocVal,KYCValidUpto,
						               KYCRowId,KYCCreatedBy,KYCCreatedDt,KYCModifiedBy,KYCModifiedDt,KYCDelFlg,KYCDelId,
									   KycRefDt,KYCRmks
									  )
								OUTPUT INSERTED.KYCPk INTO #KYCadd
								SELECT	@LeadPk,@APPPk,@LapFk,dde_KycaddProof,dde_KycaddPk,dde_KycaddRefno,DBO.gefgChar2Date(dde_KycaddDate),@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,
								        DBO.gefgChar2Date(dde_KycaddrefDate),dde_kyc_addnotes
								FROM	#Kycadddtls where ISNULL(dde_KycaddPk , 0) != 0 
							
							    --UPDATE LosAppKYCDocuments
							    --SET    KYCDocTyp=dde_KycaddProof,KYCGdmFk=dde_KycaddPk,KYCDocVal=dde_KycaddRefno,
							       --    KYCValidUpto=DBO.gefgChar2Date(dde_KycaddDate),KycRefDt=DBO.gefgChar2Date(dde_KycaddrefDate),
								   --    KYCRmks=dde_kyc_addnotes
							    --FROM  #Kycadddtls where  KYCPk=dde_addDOCPK 
							    
								
								SELECT	@Error = @@ERROR

									IF @Error > 0
										BEGIN
											RAISERROR('%s',16,1,'Error : DDE KYC Grid Insert')
											RETURN
										END	
								
						      END
						  ELSE
						  BEGIN
						  IF EXISTS(SELECT 'X' FROM LosAppKYCDocuments WHERE KYCAppFk = @APPPk AND KYCLapFk = @LapFk AND KYCDelId = 0 AND KYCDocTyp NOT IN ('A','D','I','S') )
			              BEGIN
						        UPDATE	LosAppKYCDocuments
								SET 	KYCDelId = 1, KYCDelFlg = dbo.gefgGetDelFlg(@CurDt),KYCRowId=@RowId,KYCModifiedBy=@UsrDispNm,KYCModifiedDt=@CurDt
								WHERE	KYCAppFk = @APPPk AND KYCLapFk = @LapFk AND KYCDelId = 0 AND KYCDocTyp NOT IN ('A','D','I','S')
						  END
						  END
				       END
           IF @dde_doc_hidden = '27'
						BEGIN
			IF EXISTS(SELECT 'X' FROM #DOCDTLS)
			BEGIN
				 UPDATE	LosAppDocuments
				 SET 	LadDelId = 1, LadDelFlg = dbo.gefgGetDelFlg(@CurDt),LadRowId=@RowId,LadModifiedBy=@UsrDispNm,LadModifiedDt=@CurDt
				 WHERE	LadLapfk = @LapFk AND LadDelId = 0 AND LadStage='P'


				INSERT INTO LosAppDocuments
				(
					 LadLedFk,LadAppFk,LadDocTyp,LadGdmFk,LadRcvdBy,LadRcvdDt,LadDocVal,LadDocDt,LadDocSts,LadValidUpto,LadRowId,
					 LadCreatedBy,LadCreatedDt,LadModifiedBy,LadModifiedDt,LadDelFlg,LadDelId,
					 LadRmks,LadRefDt,LadLapfk,LadStage
	            )
				SELECT	@LeadPk,@AppPK,Com_Doctype,Com_DoctPk,@UsrPk,ISNULL(DBO.gefgChar2Date(Com_RecDate),''),Com_Refno,@CurDt,case when Com_Docstatus= '-1' then '' else Com_Docstatus end,DBO.gefgChar2Date(Com_ValidDate),
				        @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,Com_notes,DBO.gefgChar2Date(Com_refDate),@LapFk,'P'
			    FROM	#DOCDTLS
								
				SELECT	@Error = @@ERROR

				IF @Error > 0
				BEGIN
					RAISERROR('%s',16,1,'Error : DDE Documents Insert')
					RETURN
				END	
								
			END
			ELSE
			BEGIN
			IF EXISTS(SELECT 'X' FROM LosAppDocuments WHERE LadLapfk = @LapFk AND LadDelId = 0 AND LadStage='P' )
			BEGIN
			     UPDATE	LosAppDocuments
				 SET 	LadDelId = 1, LadDelFlg = dbo.gefgGetDelFlg(@CurDt),LadRowId=@RowId,LadModifiedBy=@UsrDispNm,LadModifiedDt=@CurDt
				 WHERE	LadLapfk = @LapFk AND LadDelId = 0 AND LadStage='P'
			END
			END

			END
			 IF @dde_docgen_hidden = '28'
			BEGIN
			  IF EXISTS(SELECT 'X' FROM #DOCgenDTLS)
			   BEGIN
				   UPDATE	LosAppDocuments
				   SET 	LadDelId = 1, LadDelFlg = dbo.gefgGetDelFlg(@CurDt),LadRowId=@RowId,LadModifiedBy=@UsrDispNm,LadModifiedDt=@CurDt
				   WHERE	LadLedFk=@LeadPk AND ISNULL(LadLapfk,0)=0 AND LadDelId = 0 AND LadStage='P'


				   INSERT INTO LosAppDocuments
				   (
					 LadLedFk,LadAppFk,LadDocTyp,LadGdmFk,LadRcvdBy,LadRcvdDt,LadDocVal,LadDocDt,LadDocSts,LadValidUpto,LadRowId,
					 LadCreatedBy,LadCreatedDt,LadModifiedBy,LadModifiedDt,LadDelFlg,LadDelId,
					 LadRmks,LadRefDt,LadStage
	                )
				   SELECT	@LeadPk,@AppPK,Com_genDoctype,Com_genDoctPk,@UsrPk,ISNULL(DBO.gefgChar2Date(Com_genRecDate),''),Com_genRefno,@CurDt,case when Com_genDocstatus= '-1' then '' else Com_genDocstatus end,DBO.gefgChar2Date(Com_genValidDate),
				        @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,Com_gennotes,DBO.gefgChar2Date(Com_genrefDate),'P'
			        FROM	#DOCgenDTLS
								
				  SELECT	@Error = @@ERROR

				   IF @Error > 0
				   BEGIN
					RAISERROR('%s',16,1,'Error : PostSanction Documents Insert')
					RETURN
				  END	
								
			END
		 ELSE
		 BEGIN
			IF EXISTS(SELECT 'X' FROM LosAppDocuments WHERE LadLedFk=@LeadPk AND ISNULL(LadLapfk,0)=0 AND LadDelId = 0 AND LadStage='P' )
			BEGIN
			     UPDATE	LosAppDocuments
				 SET 	LadDelId = 1, LadDelFlg = dbo.gefgGetDelFlg(@CurDt),LadRowId=@RowId,LadModifiedBy=@UsrDispNm,LadModifiedDt=@CurDt
				 WHERE	LadLedFk=@LeadPk AND ISNULL(LadLapfk,0)=0 AND LadDelId = 0 AND LadStage='P'
			END
		 END
	END
							SELECT @AppPk 'AppPk', @LapFk 'LapFk' , ISNULL(@RefFk,0) 'RefFk'

							--Legal hier
								SELECT  LlhPk 'dde_legal_pk'
								FROM	LosAppLegalHier(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #Legal WHERE LlhFk = LlhPk)
								AND		LlhDelId = 0
							
							
							--Asset
								SELECT	LasPk 'dde_Ast_Pk'
								FROM	LosAppAst(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #Ast WHERE AstFk = LasPk) AND LasTyp IN (0,1,2,3,4,5)  AND LasDelId=0
							
								
							--Obligation
								SELECT	LaoPk 'dde_obl_Pk'
								FROM	LosAppObl(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #Oblig WHERE OblPk = LaoPk) AND LaoDelId=0
							
								
							--Credit Card
								SELECT  LacPk 'dde_crd_Pk'
								FROM	LosAppCreditCrd(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #Credit WHERE CrdPk = LacPk) AND LacDelId=0
							
							--Bank
								SELECT  LbkPk 'dde_bank_pk'
								FROM	LosAppBank(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #Bnk WHERE BnkFk = LbkPk) AND LbkDelId=0

								--KYC
								SELECT  KYCPk 'dde_DOCPK'
								FROM	LosAppKYCDocuments(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #KYC WHERE KYCfk = KYCPk) AND KYCDelId=0

								--Doc
								SELECT  LadPk 'dde_DOCPK'
								FROM	LosAppDocuments(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #DOC WHERE DOCFK = LadPk) AND LadDelId=0 AND LadStage='P'

								--DocGen
								SELECT  LadPk 'dde_genDOCPK'
								FROM	LosAppDocuments(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #DOCgen WHERE DOCgenFK = LadPk) AND LadDelId=0 AND LadStage='P'

								--KYC
								SELECT  KYCPk 'dde_addDOCPK'
								FROM	LosAppKYCDocuments(NOLOCK)
								WHERE	EXISTS(SELECT 'X' FROM #KYCadd WHERE KYCfk = KYCPk) AND KYCDelId=0
								

							
				END
				IF @Action='SelectRefno'
				BEGIN

				SELECT KYCDocVal 'REFNO'
				FROM LosAppKYCDocuments(NOLOCK)
				WHERE KYCLedFk=@LeadPk AND KYCLapFk <> @LapPk AND KYCDelId=0
				END

			    IF @Action='SelectDocRefno'
				BEGIN

				SELECT LadDocVal 'REFNO'
				FROM LosAppDocuments(NOLOCK)
				WHERE LadLedFk=@LeadPk AND LadLapfk <> @LapPk AND LadDelId=0 AND LadStage='P'
				END
				
			    IF @Action='SelectDocGenRefno'
				BEGIN

				SELECT LadDocVal 'REFNO'
				FROM LosAppDocuments(NOLOCK)
				WHERE LadLedFk <> @LeadPk AND LadDelId=0 AND LadStage='P'
				END

			IF @Trancount = 1 AND @@TRANCOUNT = 1
				COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN

		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + Rtrim(ERROR_LINE()), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg)
		RETURN
	END CATCH
END

--DELETE FROM LosAppBank
--DELETE FROM LosAppAst
--DELETE FROM LosAppCreditCrd
--DELETE FROM LosAppLegalHier
--DELETE FROM LosAppObl
--DELETE FROM LosAppRef
--DELETE FROM LosAppBusiProfile
--DELETE FROM LosAppOffProfile
--DELETE FROM LosAppAddress where LaaLapFk=420
--DELETE FROM LosAppProfile
--DELETE FROM LosApp


--DELETE FROM LosApp

