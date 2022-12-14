USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcForm12A_NEW]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PrcForm12A_NEW]
(
	@month char(6) = NULL,
	@qryid char(2) = NULL,
	@Flg   int     = 0,
	@XmlDoc text = Null,
	@UsrPk BIGINT = NULL,
	@BifurNm BIGINT = Null,	
	@Action varchar(10)=NULL,
	@FR3EmpFk varchar(5000)=NULL
)
AS
BEGIN
SET NOCOUNT ON  

	Declare @Basic_lmt numeric(12,2)  
	Declare @PFEMP_PRCNT numeric(12,2)  
	Declare @EPS_PRCNT numeric(4,2)  
	Declare @ADMN_PRCNT numeric(4,2)  
	Declare @EDLI_PRCNT numeric(4,2)  
	Declare @ADMN_EDLI_PRCNT numeric(27,3)  
	Declare @Prev_mon char(7)  
	Declare @Next_mon char(7)  
	Declare @ORG_NAME char(100)  
	Declare @Address1 char(100)  
	Declare @Address2 char(100)  
	Declare @Address3 char(100), @PF_CODE varchar(20)  
	Declare @StrMth char(6), @EndMth char(6), @MaxAge int  
	DECLARE @Frm12A varchar(2000) ,@FrmPSch VARCHAR(2000)  
	DECLARE @Cnt int,@cmpFk BIGINT  
	Declare @PfCmpFk bigint, @PfEmyFk bigint  
	DECLARE @UsrEmpFk BIGINT,@StatAmt varchar(50),@VpfCmpfk bigint   
	DECLARE @admedliconfig VARCHAR(100),@PfEEMYFk  bigint
	DECLARE @pfno BIGINT,@vpf BIGINT
	Declare @LAST_MON_SUBS_EPF int, @LAST_MON_SUBS_FPF int
	Declare @NEW_SUB_EPF int, @NEW_SUB_FPF int, @intXML int
	CREATE TABLE #LIST_TMP(PAYMTH CHAR(6), BASIC NUMERIC(27,2), PF NUMERIC(27,2), PY NUMERIC(27,2), EMPID INT)  
	create table #tmppfcheck (pfcEmpfk bigint)
	CREATE TABLE #LIST(PAYMTH CHAR(6), BASIC NUMERIC(27,2), BASICARR NUMERIC(27,2), PFEMP NUMERIC(27,2), PFEMPARR NUMERIC(27,2),
		PFEMY Numeric(27,2), PFEMYARR Numeric(27,2), VPF Numeric(27,2), EMPID INT,  
		LF_PFCAP numeric(27,2),LF_EPS numeric(27,2),LF_EPSARR numeric(27,2), LF_ADMCHGS numeric(27,2),LF_EDLI numeric(27,2),LF_ADMEDLI numeric(27,2),TOTAL_GROSS NUMERIC(27,2))---add Subbu  

	CREATE TABLE #LIST_FINAL(PAYMTH CHAR(6), BASIC NUMERIC(27,2), BASICARR NUMERIC(27,2), PFEMP NUMERIC(27,2), PFEMPARR NUMERIC(27,2),
		PFEMY Numeric(27,2), PFEMYARR Numeric(27,2), VPF Numeric(27,2), EMPID INT,  
		LF_PFCAP numeric(27,2),LF_EPS numeric(27,2),LF_EPSARR numeric(27,2), LF_ADMCHGS numeric(27,2),LF_EDLI numeric(27,2),LF_ADMEDLI numeric(27,2),FIN_TOTAL_GROSS NUMERIC(27,2))
	CREATE TABLE #LIST_Prv (L_EmpFk bigint)		
	CREATE TABLE #LIST_Final_Prv (L_EmpFk bigint)
	CREATE TABLE #TmpEmpDob (DobEmpFk BIGINT, Seldob char(10), Age INT)
	CREATE TABLE #TmpC([Name] varchar(50),REFPK BIGINT,CONDFK BIGINT)  
	CREATE TABLE #EmpPF_No ( PFEmpFk BIGINT, PFNO VARCHAR(250))  
	CREATE TABLE #EmpUAN(UANEmpFk BIGINT,UAN VARCHAR(100))
	CREATE TABLE #TrsEmpFk(TRSEMPFK BIGINT,TRSPRD VARCHAR(10))
	CREATE TABLE #PFCTC(PFExtEmpfk BIGINT)
	
	CREATE TABLE #DepEmp1(EmpFk BIGINT)  
	CREATE TABLE #DepEmp(EmpFk BIGINT)  
    CREATE TABLE #EmpTyp(EmpFk BIGINT, EmpTyp CHAR(50))  
    CREATE TABLE #Emp_FathNm(FathEmpFk BIGINT,FathNm VARCHAR(250),Relation VARCHAR(50))  

		SELECT @Prev_mon = dbo.gefgYYYYMM(dateadd(month, -1, dbo.gefgChar2Date(rtrim(@month)+'01'))) 
		SELECT @Next_mon = dbo.gefgYYYYMM(dateadd(month, 1, dbo.gefgChar2Date(rtrim(@month)+'01')))  
		SELECT @cmpfk = Usrcmpfk FROM ProGeMgUsrMas WITH (NOLOCK) WHERE USRPK = @UsrPk And Usrdelid = 0  
		select @pfno= ethpk from ProHrEmpAttrHdr with(nolock) where EthDelId =0 and EthTyp ='PF_NO'
	
	set @Basic_lmt = dbo.gefgGetPayCmpCnfg('CmpMaxBasicLmt',@cmpfk,@UsrPk)  
	set @PFEMP_PRCNT = dbo.gefgGetPayCmpCnfg('CmpPFBasicCap',@cmpfk,@UsrPk)  
	set @EPS_PRCNT = dbo.gefgGetPayCmpCnfg('CmpFPFPer',@cmpfk,@UsrPk)  
	set @ADMN_PRCNT = dbo.gefgGetPayCmpCnfg('CmpADMINPer',@cmpfk,@UsrPk)  
	set @EDLI_PRCNT = dbo.gefgGetPayCmpCnfg('CmpEDLIPer',@cmpfk,@UsrPk)  
	set @ADMN_EDLI_PRCNT = dbo.gefgGetPayCmpCnfg('CmpADMINEDLIPer',@cmpfk,@UsrPk)  
	set @MaxAge =  dbo.gefgGetPayCmpCnfg('CmpEmpRetireAge',@cmpfk,@UsrPk)  
	set @StatAmt =  dbo.gefgGetPayCmpCnfg('CmpPFStat',@Cmpfk,@UsrPk)    
	set @admedliconfig = dbo.gefgGetPayCmpCnfg('CmpAdmEdliChrg',@Cmpfk,@UsrPk) 
	   
	select @PfCmpFk = scppk FROM pymgsalcomp WITH (NOLOCK) WHERE scpcd = 'PFEMP' AND ScpDelId = 0  
	select @PfEMYFk = scppk FROM pymgsalcomp WITH (NOLOCK) WHERE scpcd = 'PFEMY' AND ScpDelId = 0
	select @PfEEMYFk = scppk FROM pymgsalcomp WITH (NOLOCK) WHERE scpcd = 'PFEEMY' AND ScpDelId = 0   
	select @VpfCmpfk= scppk FROM pymgsalcomp WITH (NOLOCK) WHERE scpcd = 'VPF'  

 
	 IF @month < = '201406'
		SET @Vpf = 1
  
	 SELECT @ORG_NAME = RTRIM(CmpDispNm),  
		@Address1 = RTRIM(ISNULL(ConAdd1, '')),   
		@Address2 = RTRIM(ISNULL(ConAdd2, '')),  
		@Address3 = RTRIM(ConCity)--,  
	FROM ProFaMgCmpMas WITH (NOLOCK), ProFaMgLocMas WITH (NOLOCK), ProFaMgConDtls WITH (NOLOCK)  
	WHERE CmpCurLocFk = LocPk AND LocAddFk = ConPk AND  
		LocDelId = 0 AND CmpDelId = 0 AND ConDelId = 0 and CmpPk = @Cmpfk  
 
	SELECT @UsrEmpFk = UsrDpdFk FROM ProGeMgUsrMas WITH (NOLOCK)  
	WHERE UsrPK = @UsrPk AND UsrDelId = 0  


	INSERT INTO #DEPEMP1  
	SELECT Empfk FROM dbo.PyFnEmpHier(0, @UsrPk) --where empfk = 3612

--	INSERT INTO #DEPEMP1  
--	SELECT @USREMPFK  
  
	INSERT INTO #DEPEMP  
	SELECT EmpFk FROM #DEPEMP1  
	GROUP BY EmpFk  
   
	SELECT Empfk AS 'RelEmpFk' INTO #RelEmp FROM #depemp,pytremptofrolog WITH (NOLOCK),PyMgAcCalDfn WITH (NOLOCK)  
	WHERE Tfoempfk = Empfk AND Tfotyp = 0 AND Tfodelid = 0  
	   AND CalMonth = @month AND CalPk = TfoCalFk AND CalDelId = 0 AND Calcmpfk = @cmpFk  
  
--SELECT * FROM #RelEmp  
--RETURN  
  
	SELECT EmpFk As NewEmpfk INTO #NewJoin  
	FROM #depemp,pytremptofrolog WITH (NOLOCK),PyMgAcCalDfn WITH (NOLOCK)  
	WHERE tfoempfk = empfk and tfotyp = 1 and tfodelid = 0  
		AND CalMonth >= @month AND CalPk = TfoCalFk AND CalDelId = 0 AND Calcmpfk = @cmpFk  

  
	INSERT INTO #EmpTyp (EmpFk, EmpTyp)  
	SELECT EmpFk, 'R'  
	FROM #DepEmp  

	UPDATE #EmpTyp SET EmpTyp = 'C'  
	FROM ProFaMgEmpMas WITH(NOLOCK)  
	WHERE EmpPk = EmpFk AND EmpDelId = 0   
	AND EmpCd LIKE '%GET%' AND EmpCmpFk = @CmpFk  

 -------------to be removed once the user is inculed in the xml----------------  
	IF @qryid = 'XL'  
	BEGIN  
		INSERT INTO #tmpc  
		select '', @Usrempfk, 1  

		INSERT INTO #tmpc  
		SELECT '', EmpFk, 1 FROM #depemp  
	END  

--select * from #DepEmp
--return
--SELECT * FROM #PAYSL
--RETURN
--PAYMTH, BASIC, BASICARR PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI
--select * from #EmpTyp
	INSERT INTO #LIST (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR, LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
	SELECT PayCalPrd ,CASE WHEN @StatAmt = 'PFCap' THEN PstBasicCap          
					  Else (((ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)) END, --Else PstGrsAmt END, 
					  isnull(PstarrGrsAmt,0), IsNull(PstStaAmt, 0), isnull(PstArrStaAmt,0), 0, 0,0, PstEmpFk, 0, 0, 0, 0, 0,0  
	FROM ProHrPrsStatRgr WITH (NOLOCK)  
		JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PstPrsFk AND PayCalPrd = @month AND PayDelId = 0  
	WHERE PstScpfk = @PfCmpFk AND PstDelId = 0 and pststaamt >= 0  
		AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PstEmpFk)  
		AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PstEmpFk)-- AND EmpTyp = 'R')  

  IF @Action = 'PF_SMT_NEW' 
  BEGIN
	INSERT INTO #LIST(EMPID,TOTAL_GROSS)
	SELECT PyhEmpFk AS 'EmpFk',ISNULL(PyhGrsAmt, 0) AS 'Amount'
	FROM ProHrPrsPayRgr WITH (NOLOCK)  
    JOIN ProHrPayPrsLog WITH (NOLOCK) ON PyhPrsFk = PayPk AND PayDelId = 0 AND PayCalPrd = @month --and PayVchFk <> @VChFk 
		AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PyhEmpFk)  
		AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PyhEmpFk)
	WHERE PyhDelId = 0  
 END

 IF @Action = 'PF_SMT_NEW' 
	BEGIN

		INSERT INTO #LIST (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
		--SELECT PayCalPrd , 0, 0, 0, 0,IsNull(PstStaAmt, 0), isnull(PstArrStaAmt,0),0, PstEmpFk, PstBasiccap, pstepsprcnt, isnull(PstArrEpsPrcnt,0), pstadmchgs, pstedlichgs, pstadmonedli  
		SELECT PayCalPrd , 0, 0, 0, 0,IsNull(PstStaAmt, 0), isnull(PstArrStaAmt,0),0, PstEmpFk, PstBasiccap, 
		pstepsprcnt,--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*8/100,0), 
		isnull(PstArrEpsPrcnt,0), pstadmchgs, pstedlichgs, pstadmonedli  
		--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*@ADMN_PRCNT/100,0), 
		--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*@EDLI_PRCNT/100,0),
		--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*@ADMN_EDLI_PRCNT/100,0)  
		FROM ProHrPrsStatRgr WITH (NOLOCK)  
			JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PstPrsFk AND PayCalPrd = @month AND PayDelId = 0  
		WHERE PstScpfk = @PfEMYFk AND PstDelId = 0 and pststaamt >= 0  
			AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PstEmpFk)  
			AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PstEmpFk)-- AND EmpTyp = 'R')
		GROUP BY   PayCalPrd,PstStaAmt,PstEmpFk,PstBasiccap,pstepsprcnt,PstArrEpsPrcnt,PstArrStaAmt,pstadmchgs, pstedlichgs, pstadmonedli  
  
		INSERT INTO #LIST (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
		SELECT PayCalPrd , 0, 0, 0, 0,0,0,IsNull(PstStaAmt, 0), PstEmpFk, PstBasiccap, 
		pstepsprcnt,--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*8/100,0), 
		0,  pstadmchgs, pstedlichgs, pstadmonedli  
		--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*@ADMN_PRCNT/100,0), 
		--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*@EDLI_PRCNT/100,0),
		--ROUND((SUM(ISNULL(PstStaAmt,0) + ISNULL(PstArrStaAmt ,0))*100/12)*@ADMN_EDLI_PRCNT/100,0)   
		FROM ProHrPrsStatRgr WITH (NOLOCK)  
			JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PstPrsFk AND PayCalPrd = @month AND PayDelId = 0  
		WHERE PstScpfk = @VpfCmpfk AND PstDelId = 0 and pststaamt >= 0  
			AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PstEmpFk)  
			AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PstEmpFk)-- AND EmpTyp = 'R')  
		GROUP BY   PayCalPrd,PstStaAmt,PstEmpFk,PstBasiccap,pstepsprcnt,PstArrEpsPrcnt,PstArrStaAmt,pstadmchgs, pstedlichgs, pstadmonedli  
	END
	ELSE
	BEGIN

	INSERT INTO #LIST (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
	SELECT PayCalPrd , 0, 0, 0, 0,ISNULL(PstStaAmt, 0), ISNULL(PstArrStaAmt,0),0, PstEmpFk, PstBasiccap, pstepsprcnt, ISNULL(PstArrEpsPrcnt,0), pstadmchgs, pstedlichgs, pstadmonedli  
	FROM ProHrPrsStatRgr WITH (NOLOCK)  
		JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PstPrsFk AND PayCalPrd = @month AND PayDelId = 0  
	WHERE PstScpfk = @PfEMYFk AND PstDelId = 0 and pststaamt >= 0  
		AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PstEmpFk)  
		AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PstEmpFk)-- AND EmpTyp = 'R')  
  
	INSERT INTO #LIST (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
	SELECT PayCalPrd , 0, 0, 0, 0,0,0,ISNULL(PstStaAmt, 0), PstEmpFk, PstBasiccap, pstepsprcnt, 0, pstadmchgs, pstedlichgs, pstadmonedli  
	FROM ProHrPrsStatRgr WITH (NOLOCK)  
		JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PstPrsFk AND PayCalPrd = @month AND PayDelId = 0  
	WHERE PstScpfk = @VpfCmpfk AND PstDelId = 0 and pststaamt >= 0  
		AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PstEmpFk)  
		AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PstEmpFk)-- AND EmpTyp = 'R')  
	END
	
	--return
	--SELECT * FROM #PAYSL 
	--WHERE NOT EXISTS(SELECT NULL FROM #LIST WHERE EMPID =PEMPFK )
	

/*
	-- For Consultants  
	INSERT INTO #LIST (PAYMTH, BASIC, PFEMP, PFEMY, VPF, EMPID,LF_PFCAP,LF_EPS ,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
	SELECT PayCalPrd , SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00 , SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)), 0, 0, PysEmpFk, 0, 0, 0, 0, 0  
	FROM ProHrPrsPayDtls WITH (NOLOCK)  
		JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PysPrsFk AND PayCalPrd = @month AND PayDelId = 0  
	WHERE PysScpfk = @PfCmpFk AND PysDelId = 0 -- and PstStaAmt >= 0  
		AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PysEmpFk)  
		AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PysEmpFk AND EmpTyp = 'C')  
	GROUP BY PayCalPrd, PysEmpFk  
  
	INSERT INTO #LIST (PAYMTH, BASIC, PFEMP, PFEMY, VPF, EMPID,LF_PFCAP,LF_EPS ,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)   
	SELECT PayCalPrd , 0, 0, SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)), 0, PysEmpFk, @PFEMP_PRCNT,   
		CASE WHEN (SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) < @PFEMP_PRCNT   
		THEN ROUND((SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) * (@EPS_PRCNT / 100.00), 0)  
		ELSE Floor(SUM(@PFEMP_PRCNT / 12.00)) END,  
		ROUND((SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) * (@ADMN_PRCNT / 100.00),0),   
		CASE WHEN (SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) < @PFEMP_PRCNT  
		THEN ROUND((SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) * (@EDLI_PRCNT / 100.00), 0)  
		ELSE ROUND(SUM(@PFEMP_PRCNT * @EDLI_PRCNT/100.00),0) END,   
		CASE WHEN (SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) < @PFEMP_PRCNT  
		THEN ROUND((SUM(IsNull(PysAmt, 0) + IsNull(PysArrears, 0)) / 12.00 * 100.00) * (@ADMN_EDLI_PRCNT / 100.00), 0)  
		ELSE ROUND(SUM(@PFEMP_PRCNT * @ADMN_EDLI_PRCNT/100),0) END  
	FROM ProHrPrsPayDtls WITH (NOLOCK)  
	JOIN ProHrPayPrsLog WITH (NOLOCK) ON PayPk = PysPrsFk AND PayCalPrd = @month AND PayDelId = 0  
	WHERE PysScpfk = @PfEMYFk AND PysDelId = 0 -- and pststaamt >= 0  
	AND Exists(SELECT NULL FROM #DepEmp WHERE EmpFk = PysEmpFk)  
	AND EXISTS(SELECT NULL FROM #EmpTyp WHERE EmpFk = PysEmpFk AND EmpTyp = 'C')  
	GROUP BY PayCalPrd, PysEmpFk  
  */
	--INSERT INTO #LIST_FINAL (PAYMTH, BASIC, PFEMP, PFEMY, VPF, EMPID,LF_PFCAP,LF_EPS ,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
	IF @Action = 'PF_SMT_NEW'
	BEGIN
		INSERT INTO #LIST_FINAL (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI,FIN_TOTAL_GROSS)  
		SELECT paymth, round(sum(Basic),0), round(sum(BASICARR),0),round(sum(PfEmp),0), round(sum(PFEMPARR),0),round(sum(pfemy),0), round(sum(PFEMYARR),0),round(sum(vpf),0), empid,   
		CASE WHEN sum(LF_pfcap) < sum(Basic) THEN round(sum(LF_pfcap),0) ELSE round(sum(Basic),0) END,   
		round(sum(lf_eps),0), round(sum(LF_EPSARR),0), sum(LF_admchgs), sum(LF_edli), sum(LF_admedli),round(sum(TOTAL_GROSS),0)  
		FROM #list  
		GROUP BY paymth, empid  
	END
	ELSE
	BEGIN
		INSERT INTO #LIST_FINAL (PAYMTH, BASIC, BASICARR, PFEMP, PFEMPARR, PFEMY, PFEMYARR, VPF, EMPID, LF_PFCAP,LF_EPS,LF_EPSARR,LF_ADMCHGS,LF_EDLI,LF_ADMEDLI)  
		SELECT paymth, round(sum(Basic),0), round(sum(BASICARR),0),round(sum(PfEmp),0), round(sum(PFEMPARR),0),round(sum(pfemy),0), round(sum(PFEMYARR),0),round(sum(vpf),0), empid,   
		CASE WHEN sum(LF_pfcap) < sum(Basic) THEN round(sum(LF_pfcap),0) ELSE round(sum(Basic),0) END,   
		round(sum(lf_eps),0), round(sum(LF_EPSARR),0), sum(LF_admchgs), sum(LF_edli), sum(LF_admedli)
		FROM #list  
		GROUP BY paymth, empid  
	END
	SELECT @Cnt = count(*) FROM #list_final  
	
	INSERT into #TrsEmpFk
	select TrsEmpFk ,TrsPrd 	
	from #DepEmp  
	join pytremptrslog with (nolock) on  trsdelid = 0 and trsprd = @month and TrsEmpFk =EmpFk 
	group by TrsEmpFk ,TrsPrd 
	
	Insert into #tmppfcheck (pfcEmpfk)
	select trsempfk
	from  #TrsEmpFk 
	join PyMgEmpPaySl with (nolock) ON EpSdDelId  = 0 and EpsdScpFk  in (@PfEMYFk,@PfEEMYFk ) and EpSdAmt >0
	where EpsdEmpFk =trsempfk 	
    
	INSERT INTO #EmpPF_No  
	SELECT EmpFk, RTRIM(ISNULL(EodEntyDesc, '')) AS 'PFNO' FROM ProHrEmpOffDtls WITH (NOLOCK)  
	JOIN ProHrEmpAttrHdr WITH (NOLOCK) ON EodEtrhFk = EthPk AND EthGrp = 'OFFICIAL' AND EthTyp = 'PF_NO'   
	JOIN #DepEmp ON EmpFk = EodEmpFk  
	LEFT OUTER Join #tmppfcheck on pfcempfk = empfk
	WHERE EodDelId = 0 
	
	INSERT INTO #EmpUAN 
	SELECT EmpFk,RTRIM (ISNULL(EodEntyDesc,'')) AS 'UAN' FROM ProHrEmpOffDtls WITH (NOLOCK)
	JOIN ProHrEmpAttrHdr WITH(NOLOCK) ON EodEtrhFk=EthPk and EthGrp='OFFICIAL' AND EthTyp='UAN'
	JOIN #DepEmp ON EmpFk=EodEmpFk  
	WHERE EodDelId = 0

	SELECT EtsEmpFk,ISNULL(EtsEmpLopDys,0) As 'LopDays' INTO #TranDtls   
	FROM #DepEmp,ProHrEmpTrnsDtls WITH (NOLOCK)  
	WHERE EtsTrsPrd = @Month AND EtsDelid = 0 AND EmpFk = EtsEmpFk  
	GROUP BY EtsEmpFk,EtsEmpLopDys  
  
	INSERT INTO #Emp_FathNm(FathEmpFk,FathNm,Relation)  
	SELECT RlnEmpFk,RTRIM(ISNULL(RlnNm,'')),EtdDesc  
	FROM ProHrEmpRlnMas WITH (NOLOCK)  
		JOIN ProHrEmpAttrDet WITH (NOLOCK) ON RlnEtrdFk = EtdPk and EtdCd = 'FATHNM' AND EtdDelId = 0  
		JOIN ProHrEmpAttrHdr WITH (NOLOCK) ON EthPk = EtdEthFk AND EthTyp = 'RELATION' AND EthDelId = 0  
		JOIN #NewJoin ON NewEmpfk = RlnEmpFk  
	WHERE RlnDelId = 0  
  
	IF @Cnt = 0   
	BEGIN  
    
		IF @Action='FR3PF' OR @Action = 'FR3PF_VER' OR @Action = 'PF_SMT_NEW'  
		BEGIN  
			SELECT '' AS CODE,'' AS UAN,'No Details Found' NAME,'' AS BASIC,'' AS PFCAP,   
			'' AS PFEMPLOYEE, '' AS EPS,'' AS  PFEMPLOYER,'' AS  ADMINCHARGES,   
			'' AS EDLI, '' AS ADMINCHARGESONEDLI, '' AS Location,   
			'' AS CostCentre, '' AS Department,  
			'' AS  DOJ, '' as 'DOR', 'All' as 'bi_All',  
			'0.0000' AS 'VBF',0 AS 'TBAS', 0 AS 'TPFCAP', 0 AS 'TPFEMPLOYEE',  
			0 AS 'TPFEMPLOYER',0 AS 'TADMIN_CHG',0 AS 'TEDLI'  
			,0 AS 'TADMIN_EDL','0' AS 'T_CHG','0' AS 'T_Rwcnt',0 AS 'TEPS',  
			'0.0000' AS 'T_VBF','0' AS 'TOT_AC1','0'AS 'TOT_AC_OTH','0'AS 'TOT_BAS',  
			'0' AS 'T_Sub_TotChg','' as 'spnOrgNm', rtrim(ISNULL(@Address1,'')) as 'spnAdd1',  
			rtrim(ISNULL(@Address2,'')) as 'spnAdd2', rtrim(ISNULL(@Address3,'')) as 'spnAdd3',  
			rtrim(isnull(@pf_code,'')) AS 'spnPFcode',  
			'' as 'spnMonTitl','' as 'spnLastMonEP','' as 'spnLastMonPF','' as 'spnLastMonED',  
			'' as 'spnNewSubEP','' as 'spnNewSubPF','' as 'spnNewSubED','' as 'spnRelSubEP',  
			'' as 'spnRelSubPF','' as 'spnRelSubED','' as 'spnTotSubEP','' as 'spnTotSubPF',  
			'' as 'spnTotSubED','' as 'spnTotSubC',''  as 'spnTotEmp','' as 'spnWages',  
			'' As 'spnPFCap','' as 'spnPFEmp','' as 'spnPFWrkShar', '' as 'spnEPS',  
			'' as 'spnPFEmy',''  as 'spnPFEmpShar','' as 'spnAdminChrgd','' as 'spnAdminChrgr',  
			'' as 'spnEDLI','' as 'spnAdminEDLId','' as 'spnAdminEDLIr','' as 'spnFrmDt', '' as 'spnToDt' ,   
			'' AS '12Aact' , '' AS '12aSCh'  
		END   
		ELSE   
		BEGIN  
			RAISERROR('No Details Found ',16,1)  
		END  
		RETURN   
	END   
  
	IF(@qryid = 'XL')  
	Begin  
		CREATE TABLE #RemitDtls  
		(CODE VARCHAR(50), NAME VARCHAR(100),GEN char(1),BASIC NUMERIC(27, 7), BASICARR NUMERIC(27, 7), PFCAP NUMERIC(27, 7), PFEMPLOYEE NUMERIC(27, 7), PFEMPLOYEEARR NUMERIC(27, 7),   
		EPS NUMERIC(27, 7), EPSARR NUMERIC(27, 7), PFEMPLOYER NUMERIC(27, 7), PFEMPLOYERARR NUMERIC(27, 7), ADMINCHARGES NUMERIC(27, 7), EDLI NUMERIC(27, 7),  
		ADMINCHARGESONEDLI NUMERIC(27, 7), Location VARCHAR(100), CostCentre VARCHAR(100), Department VARCHAR(100),  
		Category VARCHAR(100), EmpTyp VARCHAR(100), Grade VARCHAR(100),DOB CHAR(20),DOJ CHAR(20), DOR CHAR(20),RESREL varchar(50),EmpFk BIGINT,VPF Numeric(27,7),RMT_TOTAL_GROSS NUMERIC(27, 7))  
  
		INSERT INTO #TmpEmpDob (DobEmpFk, Seldob, Age)
		SELECT RlnEmpFk DobEmpFk,dbo.gefgDMY(rlndob) AS SELDOB,datediff(year, rlndob, dbo.gefgchar2date('28/'+ right(@month, 2)+ '/' + left(@month,4))) Age  
		--INTO #TmpEmpDob  
		FROM #List_Final  
		JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = EmpId AND RlnDelId = 0  
		JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0  
		-- JOIN #DepEmp on empfk = RlnEmpfk  
		JOIN #NewJoin ON NewEmpfk = RlnEmpFk 
		GROUP BY RlnEmpFk,rlndob		 
				  
IF ISNULL(@Action,'') = 'PF_SMT_NEW' 
BEGIN
		INSERT INTO #RemitDtls(CODE,NAME,BASIC, BASICARR, PFCAP, PFEMPLOYEE, PFEMPLOYEEARR,EPS, EPSARR, PFEMPLOYER, PFEMPLOYERARR,ADMINCHARGES, EDLI, ADMINCHARGESONEDLI,DOB,EmpFk,RMT_TOTAL_GROSS)  
		SELECT RTRIM(EmpCd) 'CODE', /* rtrim(EmpFstNm) + ' ' + rtrim(isnull(EmpLstNm,'')) */ rtrim(EmpDispNM) 'NAME',  
		--round(SUM(BASIC),0) AS 'BASIC',   
		ROUND(SUM(PFEMP*100/12),0)AS 'BASIC', 
		round(SUM(BASICARR),0) AS 'BASICARR',   
		round(sum(LF_PFCAP),0) As 'PFCAP',  
		round(SUM(PFEMP),0) 'PFEMPLOYEE',   
		round(SUM(PFEMPARR),0) 'PFEMPLOYEEARR',   
		round(sum(LF_EPS),0) AS 'EPS' ,  
		round(sum(LF_EPSARR),0) AS 'EPSARR' ,  
		round(SUM(PFEMY - LF_EPS),0) AS 'PFEMPLOYER',  
		round(SUM(PFEMYARR - LF_EPSARR),0) AS 'PFEMPLOYERARR',  
		round(sum(LF_ADMCHGS),0) AS 'ADMIN CHARGES',  
		round(sum(LF_EDLI),0) AS 'EDLI',  
		round(sum(LF_ADMEDLI),0) AS 'ADMIN CHARGES ON EDLI',SELDOB,  
		EmpPk,
		round(SUM(FIN_TOTAL_GROSS),0) AS 'TOTAL GROSS'
		FROM #LIST_FINAL  
		JOIN ProFaMgEmpMas WITH (NOLOCK) ON EmpPk = EmpId    
		LEFT OUTER JOIN #TmpEmpDob ON DobEmpfk = Empid  
		WHERE EmpDelId = 0 AND EmpCmpfk = @Cmpfk  
		GROUP BY EmpCd, EmpDispNM, empdoj, EmpPk,Age,EmpSex,SELDOB  
		ORDER BY empcd  
END
ELSE
BEGIN 
		INSERT INTO #RemitDtls(CODE,NAME,BASIC, BASICARR, PFCAP, PFEMPLOYEE, PFEMPLOYEEARR,EPS, EPSARR, PFEMPLOYER, PFEMPLOYERARR,ADMINCHARGES, EDLI, ADMINCHARGESONEDLI,DOB,EmpFk)  
		SELECT RTRIM(EmpCd) 'CODE', /* rtrim(EmpFstNm) + ' ' + rtrim(isnull(EmpLstNm,'')) */ rtrim(EmpDispNM) 'NAME',  
		round(SUM(BASIC),0) AS 'BASIC',   
		round(SUM(BASICARR),0) AS 'BASICARR',   
		round(sum(LF_PFCAP),0) As 'PFCAP',  
		round(SUM(PFEMP),0) 'PFEMPLOYEE',   
		round(SUM(PFEMPARR),0) 'PFEMPLOYEEARR',   
		round(sum(LF_EPS),0) AS 'EPS' ,  
		round(sum(LF_EPSARR),0) AS 'EPSARR' ,  
		round(SUM(PFEMY - LF_EPS),0) AS 'PFEMPLOYER',  
		round(SUM(PFEMYARR - LF_EPSARR),0) AS 'PFEMPLOYERARR',  
		round(sum(LF_ADMCHGS),0) AS 'ADMIN CHARGES',  
		round(sum(LF_EDLI),0) AS 'EDLI',  
		round(sum(LF_ADMEDLI),0) AS 'ADMIN CHARGES ON EDLI',SELDOB,  
		EmpPk
		FROM #LIST_FINAL  
		JOIN ProFaMgEmpMas WITH (NOLOCK) ON EmpPk = EmpId    
		LEFT OUTER JOIN #TmpEmpDob ON DobEmpfk = Empid  
		WHERE EmpDelId = 0 AND EmpCmpfk = @Cmpfk  
		GROUP BY EmpCd, EmpDispNM, empdoj, EmpPk,Age,EmpSex,SELDOB  
		ORDER BY empcd  
END

--select * from #LIST_FINAL   where empid = 2918
--return
  --      SELECT * FROM #RelEmp
		--RETURN
        -- Relived employees Rev Date is Previous Month -----  
  
        INSERT INTO #RemitDtls(CODE,NAME,BASIC,PFCAP, PFEMPLOYEE, EPS, PFEMPLOYER, ADMINCHARGES, EDLI, ADMINCHARGESONEDLI,DOB,EmpFk)  
        SELECT Empcd, /* rtrim(EmpFstNm) + ' ' + rtrim(isnull(EmpLstNm,'')) */ rtrim(EmpDispNM),0,0,0,0,0,0,0,0,'',RelEmpFk  
        FROM #RelEmp  
               JOIN proFaMgempMas WITH (NOLOCK) ON Emppk = RelEmpFk AND EmpDelid = 0 AND EmpCmpFk = @Cmpfk   
        WHERE RelEmpFk NOT IN (SELECT Empfk FROM #RemitDtls)  
         
        ----- Full month Lop employees ------  
  
		SELECT EtsempFk,LopDays INTO #FullLop FROM #TranDtls,PyMgAccalDfn WITH (NOLOCK)    
		  WHERE Lopdays = CalWrkDays AND Calmonth = @Month AND Caldelid = 0 AND Calcmpfk = @Cmpfk  

		INSERT INTO #RemitDtls(CODE,NAME,BASIC,PFCAP, PFEMPLOYEE, EPS, PFEMPLOYER, ADMINCHARGES, EDLI, ADMINCHARGESONEDLI,DOB,EmpFk)  
		SELECT Empcd,/* rtrim(EmpFstNm) + ' ' + rtrim(isnull(EmpLstNm,'')) */ rtrim(EmpDispNM),0,0,0,0,0,0,0,0,'',EtsEmpFk  
		FROM #FullLop   
			 JOIN proFaMgempMas WITH (NOLOCK) ON Emppk = EtsEmpFk AND EmpDelid = 0 AND EmpCmpFk = @Cmpfk   
		WHERE EtsEmpFk NOT IN (SELECT Empfk FROM #RemitDtls)  
  
-- SELECT * FROM #RemitDtls WHERE EmpFk IN (1410,1910,2419,2512,2677,2682,2897,2961,2969)  
-- SELECT * FROM #RemitDtls ---WHERE EmpFk IN ('1011','1410')  
-- RETURN  

        ----PFEMY Exists employee only Relieved Data should update...------------------
        
        INSERT INTO #PFCTC(PFExtEmpfk) 
        SELECT Empfk FROM #RemitDtls
         JOIN PymgEmpPaySl WITH (NOLOCK) ON EmpFk = EpsdEmpFk and EpSdDelId= 0 and EpsdScpFk in(@PfEMYFk,@PfEEMYFk) AND EpSdAmt <> 0 
  
  
		UPDATE #RemitDtls SET GEN = empSex from #RemitDtls,#NewJoin,ProFaMgempMAs WITH (NOLOCK)  
		WHERE Empfk = EmpPk AND EmpFk = Newempfk and empDelid = 0 AND EmpCmpfk = @Cmpfk  
  
		UPDATE #RemitDtls SET Location = GeoDesc  
		FROM ProGeGeoDefn WITH (NOLOCK), ProHrEmpOffDtls WITH (NOLOCK), ProHrEmpAttrHdr WITH (NOLOCK)  
		WHERE EodEtrdFk = GeoPk AND EodEmpFk = EmpFk AND EthPk = EodEtrhFk   
		AND EodDelId = 0 AND GeoDelId = 0 AND EthTyp = 'LOCN' AND GeoCmpfk = @Cmpfk  

		UPDATE #RemitDtls SET CostCentre = EtdDesc  
		FROM ProHrEmpOffDtls WITH (NOLOCK), ProHrEmpAttrHdr WITH (NOLOCK), ProHrEmpAttrDet WITH (NOLOCK)  
		WHERE EthPk = EtdEthFk AND EthPk = EodEtrhFk AND EodEtrdFk = EtdPk AND   
		EodEmpFk = EmpFk AND EodDelId = 0 AND EthTyp = 'COST_CENTRE'  

		UPDATE #RemitDtls SET Department = EtdDesc  
		FROM ProHrEmpOffDtls WITH (NOLOCK), ProHrEmpAttrHdr WITH (NOLOCK), ProHrEmpAttrDet WITH (NOLOCK)  
		WHERE EthPk = EtdEthFk AND EthPk = EodEtrhFk AND EodEtrdFk = EtdPk AND   
		EodEmpFk = EmpFk AND EodDelId = 0 AND EthTyp = 'DEPT'  
  
		UPDATE #RemitDtls SET Category = EtdDesc  
		FROM ProHrEmpOffDtls WITH (NOLOCK), ProHrEmpAttrHdr WITH (NOLOCK), ProHrEmpAttrDet WITH (NOLOCK)  
		WHERE EthPk = EtdEthFk AND EthPk = EodEtrhFk AND EodEtrdFk = EtdPk AND   
		EodEmpFk = EmpFk AND EodDelId = 0 AND EthTyp = 'CATEGORY'  
  
		UPDATE #RemitDtls SET EmpTyp = EtdDesc  
		FROM ProHrEmpOffDtls WITH (NOLOCK), ProHrEmpAttrHdr WITH (NOLOCK), ProHrEmpAttrDet WITH (NOLOCK)  
		WHERE EthPk = EtdEthFk AND EthPk = EodEtrhFk AND EodEtrdFk = EtdPk AND   
		EodEmpFk = EmpFk AND EodDelId = 0 AND EthTyp = 'EMP_TYP'  
  
		UPDATE #RemitDtls SET Grade = EtdDesc  
		FROM ProHrEmpOffDtls WITH (NOLOCK), ProHrEmpAttrHdr WITH (NOLOCK), ProHrEmpAttrDet WITH (NOLOCK)  
		WHERE EthPk = EtdEthFk AND EthPk = EodEtrhFk AND EodEtrdFk = EtdPk AND   
		EodEmpFk = EmpFk AND EodDelId = 0 AND EthTyp = 'GRADE'  
  
		UPDATE #RemitDtls SET DOR = EodEntyDesc,RESREL = CASE WHEN ISNULL(EodEntyDesc,'') <> '' THEN 'C' ELSE '' END  
		FROM #RelEmp,ProHrEmpOffDtls WITH (NOLOCK),ProHrEmpAttrHdr WITH (NOLOCK)  
		WHERE EthPk = EodEtrhFk AND EodEmpFk = EmpFk AND Empfk = RelempFk   
		AND EodDelId = 0 AND EthTyp = 'REL_DT'   
  
        UPDATE #RemitDtls SET DOJ = dbo.gefgDMY(empdoj) FROM #RemitDtls,  
              #NewJoin,PRoFAMgempMas WITH (NOLOCK)  
        WHERE Emppk = Newempfk AND empDelid = 0 and empFk = Newempfk AND Empcmpfk = @Cmpfk  
  
		DECLARE @ScpPk BIGINT  
		SELECT @ScpPk = ScpPk FROM PyMgSalComp WITH (NOLOCK) WHERE ScpCd = 'VPF' AND ScpDelId = 0  
    
		SELECT SUM(PysAmt)+ SUM(PysArrears) AS Amt, PysEmpFk  INTO #VPF  
		FROM ProHrPrsPayDtls WITH (NOLOCK), ProHrPayPrsLog WITH (NOLOCK),#RemitDtls   
		WHERE PysEmpFk = EmpFk AND PysDelId = 0 AND PysScpFk = @ScpPk AND  
		PayPk = PysPrsFk AND PayDelId = 0 AND PayCalPrd = @month  
		GROUP BY PysEmpFk  
  
		UPDATE #RemitDtls SET VPF = Amt FROM #VPF WHERE EmpFk = PysEMpFk  
		
  
/*  
  UPDATE #RemitDtls SET VPF = Sum(PysAmt)+Sum(PysArrears)  
  FROM ProHrPrsPayDtls WITH (NOLOCK), ProHrPayPrsLog WITH (NOLOCK)  
  WHERE PysEmpFk = EmpFk AND PysDelId = 0 AND PysScpFk = @ScpPk AND  
   PayPk = PysPrsFk AND PayDelId = 0 AND PayCalPrd = @month  
*/    --SELECT @Action

		IF ISNULL(@Action,'')='FR3PF' OR ISNULL(@Action,'') = 'FR3PF_VER' OR  ISNULL(@Action,'') = 'PF_SMT_NEW'  
		BEGIN  
   
			Declare @TBAS Numeric(27,7),@TPFCAP Numeric(27,7),@TPFEMPLOYEE Numeric(27,7),  
			@TEPS Numeric(27,7),@TPFEMPLOYER Numeric(27,7),  
			@TADMIN_CHG Numeric(27,7),@TEDLI Numeric(27,7),  
			@TADMIN_EDL Numeric(27,7),@T_RCD Bigint,  
			@T_VPF Numeric(27,7)  
  
			SELECT @T_RCD= COUNT(*) FROM #RemitDtls    
			WHERE EXISTS(SELECT NULL FROM #tmpC WHERE REFPK  = EmpFk )--AND CondFk = @BifurNm)  
  
			SELECT  
			@TBAS= round(SUM(BASIC),0) ,  
			@TPFCAP=round(sum(LF_PFCAP),0) ,  
			@TPFEMPLOYEE=round(SUM(PFEMP),0) ,   
			@TEPS= ROUND(SUM(LF_EPS),0),  
			@TPFEMPLOYER = ROUND( SUM(PFEMY - LF_EPS),0),  
			@TADMIN_CHG = round(sum(LF_ADMCHGS),0),  
			@TEDLI = round(sum(LF_EDLI),0),  
			@TADMIN_EDL = round(sum(LF_ADMEDLI),0)   
			FROM #LIST_FINAL JOIN ProFaMgEmpMas WITH (NOLOCK) ON EmpPk = EMPID AND EmpDelId = 0   
			  LEFT OUTER JOIN #TmpEmpDob on DobEmpfk = EmpId  
			WHERE EXISTS(SELECT NULL FROM #tmpC WHERE REFPK  = Emppk)--( AND CondFk = @BifurNm)  
  
			SELECT @T_VPF=SUM(ISNULL(VPF,0)) FROM #RemitDtls  

--SELECT * FROM #RemitDtls WHERE EmpFk IN (1410,1910,2419,2512,2677,2682,2897,2961,2969)  
--SELECT * FROM #EmpPF_No WHERE PFEmpfk IN (1410,1910,2419,2512,2677,2682,2897,2961,2969)  
--SELECT * FROM #tmpC WHERE REFPK IN (1410,1910,2419,2512,2677,2682,2897,2961,2969)  
-- RETURN  
--SELECT * FROM #TranDtls WHERE EtsEmpFk IN ('1011','1410')  
--RETURN  
--CODE,NAME,BASIC, BASICARR, PFCAP, PFEMPLOYEE, PFEMPLOYEEARR,EPS, EPSARR, PFEMPLOYER, PFEMPLOYERARR  

			IF ISNULL(@Action,'') = 'FR3PF_VER'  
			BEGIN   
			IF EXISTS (select NULL from #Flex WHERE GlobalFlex = 1)
			BEGIN
				SELECT 'EmpCode,MemberId,UAN,MemberName,EPFWages,EPSWages,EPFContribution(EE Share)due,EPFContribution(EE Share)being remitted,EPS Contribution due,EPS Contribution being remitted,Diff EPF and EPS Contribution(ER Share)due,Diff EPF and EPS Contribution(ER Share)being remitted,NCPDAYS,Refund of Advances,ArrearEPF Wage,Arrear EPF EE Share,Arrear EPF ER Share,Arrear EPS Share,Father or Husband Name,Relationship with the Member,Date of Birth,Gender,Date of Joining EPF,Date of Joining EPS,Date of Exit from EPF,Date of Exit from EPS,Reason for leaving' headerText,			
				'100,100,140,100,100,200,250,150,200,300,350,100,150,150,150,150,150,150,200,150,90,140,140,140,140,140' width,
				'CODE,PFNo,NAME,BASIC,PFCAP,EPFCD,EPFCR,EPSD,EPSR,DIFEPFD,DIFEPFR,NCPDAYS,REFADV,ARREPFWAGE,ARREPFEESHARE,ARREPFERSHARE,ARREPSSHARE,FATHUSNM,RELATION,DOB,GEN,DOJEPF,DOJEPS,DOEEPF,DOEEPS,RESREL' dataField,
				'left,left,left,left,left,left,left,left,left,left' align
				SELECT CODE AS 'CODE',PFNO AS 'PFNo' ,UAN AS 'UAN',NAME AS 'NAME',BASIC ,   
							   PFCAP,PFEMPLOYEE  + ISNULL(VPF,0)AS EPFCD,PFEMPLOYEE + ISNULL(VPF,0)AS EPFCR, EPS AS EPSD,EPS AS EPSR,   
							   PFEMPLOYER  + ISNULL(VPF,0) As DIFEPFD,PFEMPLOYER  + ISNULL(VPF,0) As DIFEPFR,ADMINCHARGES,ISNULL(LopDays,0) As 'NCPDAYS',   
							   '0' As REFADV,BASICARR As ARREPFWAGE,PFEMPLOYEEARR AS ARREPFEESHARE,PFEMPLOYERARR AS ARREPFERSHARE ,EPSARR AS ARREPSSHARE,  
							   ISNULL(FathNm,'') As FATHUSNM,ISNULL(RELATION,'') As 'RELATION',ISNULL(GEN,'') AS GEN,ISNULL(RESREL,'') AS 'RESREL',   
							   EDLI,ADMINCHARGESONEDLI, ADMINCHARGES 'ADMINCHGS', ADMINCHARGESONEDLI 'ADMINCHGSEDLI',   
				ISNULL(VPF,0) AS 'VPF', Location, CostCentre, Department,ISNULL(DOB,'') AS 'DOB',  
							   ISNULL(DOJ,'') As 'DOJEPF',ISNULL(DOJ,'') As 'DOJEPS',ISNULL(DOR, '') as 'DOEEPF',ISNULL(DOR, '') as'DOEEPS',EmpFk  
				FROM #RemitDtls   
							 JOIN #EmpPF_No ON EmpFk = PFEmpfk  
							 LEFT OUTER JOIN #EmpUAN ON EmpFk=UANEmpFk
							 LEFT OUTER JOIN #TranDtls ON EmpFk = EtsempFk   
							 LEFT OUTER JOIN #Emp_FathNm ON Empfk = Fathempfk   
				WHERE EXISTS(SELECT NULL FROM #tmpC WHERE REFPK  = EmpFk)  
						 ORDER BY RTRIM(CODE)
				
			END
			
			ELSE
			BEGIN
					
					create table #finalform(CODE varchar(100),PFNO varchar(100),UAN varchar(100),NAME varchar(100),[BASIC] numeric(27,2),PFCAP numeric(27,2),EPFCD numeric(27,2),EPFCR numeric(27,2), EPSD numeric(27,2), 
					EPSR numeric(27,2),DIFEPFD numeric(27,2),DIFEPFR numeric(27,2),ADMINCHARGES numeric(27,2),NCPDAYS numeric(27,2),
					REFADV numeric(27,2),ARREPFWAGE numeric(27,2),ARREPFEESHARE numeric(27,2),ARREPFERSHARE numeric(27,2),ARREPSSHARE numeric(27,2),
					FATHUSNM varchar(100),RELATION varchar(100),GEN varchar(100),RESREL varchar(100),EDLI numeric(27,2),ADMINCHARGESONEDLI numeric(27,2),
					ADMINCHGS numeric(27,2),ADMINCHGSEDLI numeric(27,2),VPF numeric(27,2), Location varchar(100), CostCentre varchar(100), Department varchar(100),DOB varchar(100),DOJEPF varchar(100),DOJEPS varchar(100)
					,DOEEPF varchar(100),DOEEPS varchar(100),EmpFk bigint,ord bigint)
			
				--(CODE VARCHAR(50), NAME VARCHAR(100),GEN char(1),BASIC NUMERIC(27, 7), BASICARR NUMERIC(27, 7), PFCAP NUMERIC(27, 7), PFEMPLOYEE NUMERIC(27, 7), PFEMPLOYEEARR NUMERIC(27, 7),   
				--EPS NUMERIC(27, 7), EPSARR NUMERIC(27, 7), PFEMPLOYER NUMERIC(27, 7), PFEMPLOYERARR NUMERIC(27, 7), ADMINCHARGES NUMERIC(27, 7), EDLI NUMERIC(27, 7),  
				--ADMINCHARGESONEDLI NUMERIC(27, 7), Location VARCHAR(100), CostCentre VARCHAR(100), Department VARCHAR(100),  
				--Category VARCHAR(100), EmpTyp VARCHAR(100), Grade VARCHAR(100),DOB CHAR(20),DOJ CHAR(20), DOR CHAR(20),RESREL varchar(50),EmpFk BIGINT,VPF Numeric(27,7))  
		
					INSERT INTO #finalform (CODE,PFNO,UAN ,NAME ,BASIC ,PFCAP,EPFCD ,EPFCR ,EPSD,EPSR ,DIFEPFD ,DIFEPFR,ADMINCHARGES,NCPDAYS ,
											REFADV ,ARREPFWAGE ,ARREPFEESHARE ,ARREPFERSHARE,ARREPSSHARE ,
											FATHUSNM ,RELATION ,GEN,RESREL ,EDLI ,ADMINCHARGESONEDLI ,ADMINCHGS ,ADMINCHGSEDLI ,VPF ,Location ,CostCentre ,Department 
											,dob,DOJEPF ,DOJEPS ,DOEEPF ,DOEEPS ,EmpFk ,ord )
					SELECT CODE AS 'CODE',convert(varchar(10),PFNO) AS 'PFNo',convert(varchar(100),UAN) AS 'UAN',NAME AS 'NAME',BASIC ,   
								   PFCAP,PFEMPLOYEE  + ISNULL(VPF,0)AS EPFCD,PFEMPLOYEE + ISNULL(VPF,0)AS EPFCR, EPS AS EPSD,EPS AS EPSR,   
								   PFEMPLOYER  + CASE WHEN isnull(@Vpf,0) = 1 THEN ISNULL(VPF,0) ELSE 0 END AS DIFEPFD,PFEMPLOYER  + CASE WHEN ISNULL(@Vpf,0) = 1 THEN ISNULL(VPF,0) ELSE 0 END AS DIFEPFR,
								   ADMINCHARGES,ISNULL(LopDays,0) As 'NCPDAYS',   /* changed for VPF + PFEMY issue */
								   '0' As REFADV,BASICARR As ARREPFWAGE,PFEMPLOYEEARR AS ARREPFEESHARE,PFEMPLOYERARR AS ARREPFERSHARE ,EPSARR AS ARREPSSHARE,  
								   ISNULL(FathNm,'') As FATHUSNM,ISNULL(RELATION,'') As 'RELATION',ISNULL(GEN,'') AS GEN,ISNULL(RESREL,'') AS 'RESREL',   
								   EDLI,ADMINCHARGESONEDLI, ADMINCHARGES 'ADMINCHGS', ADMINCHARGESONEDLI 'ADMINCHGSEDLI',   
					ISNULL(VPF,0) AS 'VPF', Location, CostCentre, Department,ISNULL(DOB,'') AS 'DOB',  
								   ISNULL(DOJ,'') As 'DOJEPF',ISNULL(DOJ,'') As 'DOJEPS',ISNULL(DOR, '') as 'DOEEPF',ISNULL(DOR, '') as'DOEEPS',EmpFk  ,1
								   --INTO #FinalForm
					FROM #RemitDtls   
								 JOIN #EmpPF_No ON EmpFk = PFEmpfk 
								 JOIN #PFCTC ON EmpFk = PFExtEmpfk 
								 LEFT OUTER JOIN #EmpUAN ON EmpFk=UANEmpFk 
								 LEFT OUTER JOIN #TranDtls ON EmpFk = EtsempFk   
								 LEFT OUTER JOIN #Emp_FathNm ON Empfk = Fathempfk   
					WHERE EXISTS(SELECT NULL FROM #tmpC WHERE REFPK  = EmpFk)  
							 ORDER BY RTRIM(CODE)
					
					declare @basic numeric(27,2),@pffund numeric(27,2),@admedli numeric(27,2),@pf numeric(27,2)
					declare @admchgs numeric(27,2),@penfund numeric(27,2),@pension numeric(27,2)
					
					set @basic =0 set @pffund =0
					
					select @basic= SUM([BASIC] ),@pffund =SUM(PFCAP ),@pf=SUM(EPFCD )+SUM(DIFEPFD),@admchgs =SUM(ADMINCHGS)
					,@penfund=SUM(EPSD),@admedli = SUM(ADMINCHGSEDLI),@pension =SUM(EPSD)
					from #finalform 
		
					insert into #finalform (CODE,PFNO,UAN ,NAME ,BASIC ,PFCAP,EPFCD ,EPFCR ,EPSD,EPSR ,DIFEPFD ,DIFEPFR,ADMINCHARGES,NCPDAYS ,
										REFADV ,ARREPFWAGE ,ARREPFEESHARE ,ARREPFERSHARE,ARREPSSHARE ,
										FATHUSNM ,RELATION ,GEN,RESREL ,EDLI ,ADMINCHARGESONEDLI ,ADMINCHGS ,ADMINCHGSEDLI ,VPF ,Location ,CostCentre ,Department 
										,dob,DOJEPF ,DOJEPS ,DOEEPF ,DOEEPS ,EmpFk ,ord )
					SELECT 'ZZZ-GrandTotal' AS 'CODE',convert(varchar(10),'')AS 'PFNo',convert(varchar(100),'') AS 'UAN'  ,''AS 'NAME',SUM([basic])[basic],   
								   sum(PFCAP)PFCAP,SUM(EPFCD)EPFCD,sum(EPFCR) EPFCR, sum(EPSD) EPSD,sum(EPSR) EPSR,   
								   sum(DIFEPFD) DIFEPFD,sum(DIFEPFR) DIFEPFR,sum(ADMINCHARGES) ADMINCHARGES,sum(NCPDAYS)NCPDAYS,   
								   sum(isnull(convert(numeric(27,2),REFADV),0)) REFADV,
								   sum(isnull(convert(numeric(27,2),ARREPFWAGE),0)) ARREPFWAGE,sum(isnull(convert(numeric(27,2),ARREPFEESHARE),0))ARREPFEESHARE,
								   sum(isnull(convert(numeric(27,2),ARREPFERSHARE ),0)) ARREPFERSHARE,sum(isnull(convert(numeric(27,2),ARREPSSHARE),0)) ARREPSSHARE,  
								   '' As FATHUSNM,'' As 'RELATION','' AS GEN,'' AS 'RESREL',   
								   SUM( EDLI),sum(ADMINCHARGESONEDLI),sum(ADMINCHGS), sum(ADMINCHGSEDLI),   
									sum(VPF),'' Location,'' CostCentre,'' Department,'' AS 'DOB',  
								   '' As 'DOJEPF','' As 'DOJEPS',''  as 'DOEEPF','' as'DOEEPS',0 empfk,2
					from #FinalForm		
				
				SELECT CASE WHEN ISNUMERIC(CODE)= 1 THEN '''' + CODE ELSE CODE END AS 'Emp Code', PFNo AS 'Member Id',''''+isnull(UAN,'') AS 'UAN', NAME AS 'Member Name',
							BASIC AS 'EPFWages', PFCAP AS 'EPSWages',EPFCD AS 'EPFContribution EE Share due', EPFCR AS 'EPFContribution EE Share being remitted',
							EPSD AS 'EPS Contribution due',EPSR AS 'EPS Contribution being remitted',DIFEPFD AS 'Diff EPF and EPS Contribution ER Share due',
							DIFEPFR AS 'Diff EPF and EPS Contribution ER Share being remitted',NCPDAYS AS 'NCPDAYS',REFADV AS 'Refund of Advances',
							ARREPFWAGE AS 'ArrearEPF Wage',ARREPFEESHARE AS 'Arrear EPF EE Share',ARREPFERSHARE AS 'Arrear EPF ER Share',
							ARREPSSHARE AS 'Arrear EPS Share',FATHUSNM AS 'Father or Husband Name',RELATION AS 'Relationship with the Member' 
							,DOB AS 'Date of Birth',GEN AS 'Gender',DOJEPF AS 'Date of Joining EPF',DOJEPS AS 'Date of Joining EPS',
							DOEEPF AS 'Date of Exit from EPF',DOEEPS AS 'Date of Exit from EPS',RESREL AS 'Reason for leaving' 
				FROM #FinalForm	
				order by CODE ,ord  

		 	 END					 
  			END  
		ELSE IF ISNULL(@Action,'') = 'PF_SMT_NEW'  
		BEGIN   
			IF EXISTS (select NULL from #Flex WHERE GlobalFlex = 1)
			BEGIN
				--SELECT 'EmpCode,EPF Number,UAN Number,Name Of Employees,Gross Salary,EPS Salary,EPF Contribution,EPFContribution(EE Share)being remitted,EPS Contribution,EPS Contribution being remitted,Diff EPF and EPS Contribution(ER Share)due,Diff EPF and EPS Contribution(ER Share)being remitted,NCPDAYS,Advance,ArrearEPF Wage,Arrear EPF EE Share,Arrear EPF ER Share,Arrear EPS Share,Father or Husband Name,Relationship with the Member,Date of Birth,Gender,Date of Joining EPF,Date of Joining EPS,Date of Exit from EPF,Date of Exit from EPS,Reason for leaving,Acc_No_22,Acc_No_2' headerText,			
				SELECT 'EmpCode,EPF Number,UAN Number,Name Of Employees,Gross Salary,EPS Salary,EPF Contribution,EPFContribution(EE Share)being remitted,EPS Contribution,EPS Contribution being remitted,Diff EPF and EPS Contribution(ER Share)due,Diff EPF and EPS Contribution(ER Share)being remitted,NCPDAYS,Advance,ArrearEPF Wage,Arrear EPF EE Share,Arrear EPF ER Share,Arrear EPS Share,Father or Husband Name,Relationship with the Member,Date of Birth,Gender,Date of Joining EPF,Date of Joining EPS,Date of Exit from EPF,Date of Exit from EPS,Reason for leaving,Acc_No_22,Acc_No_2' headerText,			
				'100,100,140,100,100,200,250,150,200,300,350,100,150,150,150,150,150,150,200,150,90,140,140,140,140,140,140,140' width,
				'CODE,PFNo,NAME,BASIC,PFCAP,EPFCD,EPFCR,EPSD,EPSR,DIFEPFD,DIFEPFR,NCPDAYS,REFADV,ARREPFWAGE,ARREPFEESHARE,ARREPFERSHARE,ARREPSSHARE,FATHUSNM,RELATION,DOB,GEN,DOJEPF,DOJEPS,DOEEPF,DOEEPS,RESREL,Acc_No_22,Acc_No_2' dataField,
				'left,left,left,left,left,left,left,left,left,left,left,left' align
				SELECT CODE AS 'CODE',PFNO AS 'PFNo' ,UAN AS 'UAN',NAME AS 'NAME',BASIC 'BASIC' ,   
							   PFCAP,PFEMPLOYEE  + ISNULL(VPF,0)AS EPFCD,PFEMPLOYEE + ISNULL(VPF,0)AS EPFCR, EPS AS EPSD,EPS AS EPSR,   
							   PFEMPLOYER  + ISNULL(VPF,0) As DIFEPFD,PFEMPLOYER  + ISNULL(VPF,0) As DIFEPFR,ADMINCHARGES,ISNULL(LopDays,0) As 'NCPDAYS',   
							   '0' As REFADV,BASICARR As ARREPFWAGE,PFEMPLOYEEARR AS ARREPFEESHARE,PFEMPLOYERARR AS ARREPFERSHARE ,EPSARR AS ARREPSSHARE,  
							   ISNULL(FathNm,'') As FATHUSNM,ISNULL(RELATION,'') As 'RELATION',ISNULL(GEN,'') AS GEN,ISNULL(RESREL,'') AS 'RESREL',   
							   EDLI,ADMINCHARGESONEDLI, ADMINCHARGES 'ADMINCHGS', ADMINCHARGESONEDLI 'ADMINCHGSEDLI',   
							   ISNULL(VPF,0) AS 'VPF', Location, CostCentre, Department,ISNULL(DOB,'') AS 'DOB',  
							   ISNULL(DOJ,'') As 'DOJEPF',ISNULL(DOJ,'') As 'DOJEPS',ISNULL(DOR, '') as 'DOEEPF',ISNULL(DOR, '') as'DOEEPS',EmpFk,
							   CONVERT(NUMERIC(27,2),(ISNULL(PFCAP,0)*(0.85/100))) 'Acc_No_2',CONVERT(NUMERIC(27,2),(ISNULL(PFCAP,0)*(0.01/100))) 'Acc_No_22'
				FROM #RemitDtls   
							 JOIN #EmpPF_No ON EmpFk = PFEmpfk  
							 LEFT OUTER JOIN #EmpUAN ON EmpFk=UANEmpFk
							 LEFT OUTER JOIN #TranDtls ON EmpFk = EtsempFk   
							 LEFT OUTER JOIN #Emp_FathNm ON Empfk = Fathempfk   
				WHERE EXISTS(SELECT NULL FROM #tmpC WHERE REFPK  = EmpFk)  
						 ORDER BY RTRIM(CODE)
				
			END
			
			ELSE
			BEGIN
					
					DECLARE @finalform1 TABLE (CODE VARCHAR(100),PFNO VARCHAR(100),UAN VARCHAR(100),NAME VARCHAR(100),[BASIC] NUMERIC(27,2),PFCAP NUMERIC(27,2),EPFCD NUMERIC(27,2),EPFCR NUMERIC(27,2), EPSD NUMERIC(27,2), 
					EPSR NUMERIC(27,2),DIFEPFD NUMERIC(27,2),DIFEPFR NUMERIC(27,2),ADMINCHARGES NUMERIC(27,2),NCPDAYS NUMERIC(27,2),
					REFADV NUMERIC(27,2),ARREPFWAGE NUMERIC(27,2),ARREPFEESHARE NUMERIC(27,2),ARREPFERSHARE NUMERIC(27,2),ARREPSSHARE NUMERIC(27,2),
					FATHUSNM varchar(100),RELATION VARCHAR(100),GEN VARCHAR(100),RESREL VARCHAR(100),EDLI NUMERIC(27,2),ADMINCHARGESONEDLI NUMERIC(27,2),
					ADMINCHGS NUMERIC(27,2),ADMINCHGSEDLI NUMERIC(27,2),VPF NUMERIC(27,2), Location VARCHAR(100), CostCentre VARCHAR(100), Department VARCHAR(100),DOB VARCHAR(100),DOJEPF VARCHAR(100),DOJEPS VARCHAR(100)
					,DOEEPF VARCHAR(100),DOEEPS VARCHAR(100),EmpFk BIGINT,ord BIGINT,FNL_TOTAL_GROSS NUMERIC(27,2))
			
				--(CODE VARCHAR(50), NAME VARCHAR(100),GEN char(1),BASIC NUMERIC(27, 7), BASICARR NUMERIC(27, 7), PFCAP NUMERIC(27, 7), PFEMPLOYEE NUMERIC(27, 7), PFEMPLOYEEARR NUMERIC(27, 7),   
				--EPS NUMERIC(27, 7), EPSARR NUMERIC(27, 7), PFEMPLOYER NUMERIC(27, 7), PFEMPLOYERARR NUMERIC(27, 7), ADMINCHARGES NUMERIC(27, 7), EDLI NUMERIC(27, 7),  
				--ADMINCHARGESONEDLI NUMERIC(27, 7), Location VARCHAR(100), CostCentre VARCHAR(100), Department VARCHAR(100),  
				--Category VARCHAR(100), EmpTyp VARCHAR(100), Grade VARCHAR(100),DOB CHAR(20),DOJ CHAR(20), DOR CHAR(20),RESREL varchar(50),EmpFk BIGINT,VPF Numeric(27,7))  
		
					INSERT INTO @Finalform1 (CODE,PFNO,UAN ,NAME ,BASIC ,PFCAP,EPFCD ,EPFCR ,EPSD,EPSR ,DIFEPFD ,DIFEPFR,ADMINCHARGES,NCPDAYS ,
											REFADV ,ARREPFWAGE ,ARREPFEESHARE ,ARREPFERSHARE,ARREPSSHARE ,
											FATHUSNM ,RELATION ,GEN,RESREL ,EDLI ,ADMINCHARGESONEDLI ,ADMINCHGS ,ADMINCHGSEDLI ,VPF ,Location ,CostCentre ,Department 
											,dob,DOJEPF ,DOJEPS ,DOEEPF ,DOEEPS ,EmpFk ,ord,FNL_TOTAL_GROSS )
					SELECT CODE AS 'CODE',CONVERT(VARCHAR(10),PFNO) AS 'PFNo',CONVERT(VARCHAR(100),UAN) AS 'UAN',NAME AS 'NAME',BASIC 'BASIC' ,   
								   PFCAP,PFEMPLOYEE  + ISNULL(VPF,0)AS EPFCD,PFEMPLOYEE + ISNULL(VPF,0)AS EPFCR, EPS AS EPSD,EPS AS EPSR,   
								   PFEMPLOYER  + CASE WHEN ISNULL(@Vpf,0) = 1 THEN ISNULL(VPF,0) ELSE 0 END AS DIFEPFD,PFEMPLOYER  + CASE WHEN ISNULL(@Vpf,0) = 1 THEN ISNULL(VPF,0) ELSE 0 END AS DIFEPFR,
								   ADMINCHARGES,ISNULL(LopDays,0) As 'NCPDAYS',   /* changed for VPF + PFEMY issue */
								   '0' AS REFADV,BASICARR AS ARREPFWAGE,PFEMPLOYEEARR AS ARREPFEESHARE,PFEMPLOYERARR AS ARREPFERSHARE ,EPSARR AS ARREPSSHARE,  
								   ISNULL(FathNm,'') AS FATHUSNM,ISNULL(RELATION,'') AS 'RELATION',ISNULL(GEN,'') AS GEN,ISNULL(RESREL,'') AS 'RESREL',   
								   EDLI,ADMINCHARGESONEDLI, ADMINCHARGES 'ADMINCHGS', ADMINCHARGESONEDLI 'ADMINCHGSEDLI',   
								   ISNULL(VPF,0) AS 'VPF', Location, CostCentre, Department,ISNULL(DOB,'') AS 'DOB',  
								   ISNULL(DOJ,'') AS 'DOJEPF',ISNULL(DOJ,'') AS 'DOJEPS',ISNULL(DOR, '') AS 'DOEEPF',ISNULL(DOR, '') AS'DOEEPS',EmpFk  ,1,RMT_TOTAL_GROSS
								   --INTO @FinalForm1
					FROM #RemitDtls   
								 JOIN #EmpPF_No ON EmpFk = PFEmpfk 
								 JOIN #PFCTC ON EmpFk = PFExtEmpfk 
								 LEFT OUTER JOIN #EmpUAN ON EmpFk=UANEmpFk 
								 LEFT OUTER JOIN #TranDtls ON EmpFk = EtsempFk   
								 LEFT OUTER JOIN #Emp_FathNm ON Empfk = Fathempfk   
					WHERE EXISTS(SELECT NULL FROM #tmpC WHERE REFPK  = EmpFk)  
							 ORDER BY RTRIM(CODE)
					
					DECLARE @basic1 NUMERIC(27,2),@pffund1 NUMERIC(27,2),@admedli1 NUMERIC(27,2),@pf1 NUMERIC(27,2)
					DECLARE @admchgs1 NUMERIC(27,2),@penfund1 NUMERIC(27,2),@pension1 NUMERIC(27,2)
					
					SET @basic1 =0 SET @pffund1 =0
					
					SELECT @basic1= SUM([BASIC] ),@pffund1 =SUM(PFCAP ),@pf1=SUM(EPFCD )+SUM(DIFEPFD),@admchgs1 =SUM(ADMINCHGS)
					,@penfund1=SUM(EPSD),@admedli1 = SUM(ADMINCHGSEDLI),@pension1 =SUM(EPSD)
					FROM @Finalform1 
		
					INSERT INTO @Finalform1 (CODE,PFNO,UAN ,NAME ,BASIC ,PFCAP,EPFCD ,EPFCR ,EPSD,EPSR ,DIFEPFD ,DIFEPFR,ADMINCHARGES,NCPDAYS ,
										REFADV ,ARREPFWAGE ,ARREPFEESHARE ,ARREPFERSHARE,ARREPSSHARE ,
										FATHUSNM ,RELATION ,GEN,RESREL ,EDLI ,ADMINCHARGESONEDLI ,ADMINCHGS ,ADMINCHGSEDLI ,VPF ,Location ,CostCentre ,Department 
										,dob,DOJEPF ,DOJEPS ,DOEEPF ,DOEEPS ,EmpFk ,ord,FNL_TOTAL_GROSS )
					SELECT 'ZZZ-GrandTotal' AS 'CODE',CONVERT(VARCHAR(10),'')AS 'PFNo',CONVERT(VARCHAR(100),'') AS 'UAN'  ,''AS 'NAME',SUM([basic])[basic],   
								   SUM(PFCAP)PFCAP,SUM(EPFCD)EPFCD,SUM(EPFCR) EPFCR, SUM(EPSD) EPSD,SUM(EPSR) EPSR,   
								   SUM(DIFEPFD) DIFEPFD,SUM(DIFEPFR) DIFEPFR,SUM(ADMINCHARGES) ADMINCHARGES,SUM(NCPDAYS)NCPDAYS,   
								   SUM(ISNULL(CONVERT(NUMERIC(27,2),REFADV),0)) REFADV,
								   SUM(ISNULL(CONVERT(NUMERIC(27,2),ARREPFWAGE),0)) ARREPFWAGE,SUM(ISNULL(CONVERT(NUMERIC(27,2),ARREPFEESHARE),0))ARREPFEESHARE,
								   SUM(ISNULL(CONVERT(NUMERIC(27,2),ARREPFERSHARE ),0)) ARREPFERSHARE,SUM(ISNULL(CONVERT(NUMERIC(27,2),ARREPSSHARE),0)) ARREPSSHARE,  
								   '' AS FATHUSNM,'' AS 'RELATION','' AS GEN,'' AS 'RESREL',   
								   SUM( EDLI),SUM(ADMINCHARGESONEDLI),SUM(ADMINCHGS), SUM(ADMINCHGSEDLI),   
									SUM(VPF),'' Location,'' CostCentre,'' Department,'' AS 'DOB',  
								   '' AS 'DOJEPF','' AS 'DOJEPS',''  AS 'DOEEPF','' AS'DOEEPS',0 empfk,2,SUM(FNL_TOTAL_GROSS)'FNL_TOTAL_GROSS'
					FROM @FinalForm1		

				SELECT  CODE,PFNo AS 'EPF Number',''''+ISNULL(UAN,'') AS 'UAN Number', NAME AS 'Name Of Employees',
						ARREPFWAGE AS 'Arr_EPF Wages',PFCAP AS 'Arr_EPS Wages',PFCAP AS 'Arr_EDLI Wages',ARREPFEESHARE AS 'Ar_EPF_EE_Share',ARREPFERSHARE AS 'Arr_EPF_ER_Share',
						ARREPSSHARE AS 'Arr_EPS_Share',( ARREPFWAGE + PFCAP + PFCAP + ARREPFEESHARE + ARREPFERSHARE + ARREPSSHARE ) AS 'TOTAL'
				FROM @Finalform1	
				ORDER BY CODE ,ord  

				SELECT	CODE,PFNo AS 'EPF Number',''''+ISNULL(UAN,'') AS 'UAN Number', NAME AS 'Name Of Employees',
							BASIC AS 'Gross Salary',BASIC AS 'EPF Salary', PFCAP AS 'EPS Salary',PFCAP AS 'EDLI Salary',
							EPFCD AS 'EPF Contribution', --EPFCR AS 'EPFContribution EE Share being remitted',
							EPSD AS 'EPS Contribution',--EPSR AS 'EPS Contribution being remitted',
							DIFEPFD AS 'EPF EPS Diff Remitted',EDLI 'EDLI Contribution',
							--DIFEPFR AS 'Diff EPF and EPS Contribution ER Share being remitted',
							--CONVERT(NUMERIC(27,2),(BASIC * (0.50/100))) 'EDLI Contribution' ,
							NCPDAYS AS 'NCPDAYS',REFADV AS 'Advances',--EDLI,
							--CONVERT(NUMERIC(27,2),(PFCAP*(0.85/100))) 'Acc_No_2',
							--ADMINCHARGES 'Acc_No_2', CONVERT(NUMERIC(27,2),(PFCAP*(0.01/100))) 'Acc_No_22',
							--CONVERT(NUMERIC(27,2),((ISNULL(EDLI,0))+(ISNULL(PFCAP,0)*(0.01/100))+(BASIC * (0.50/100))+(ISNULL(EPFCD,0))+(ISNULL(EPSD,0)))) 'Total',
							ADMINCHARGES 'Acc_No_2', CONVERT(NUMERIC(27,2),(PFCAP*(0.01/100))) 'Acc_No_22',
							CONVERT(NUMERIC(27,2),((ISNULL(EDLI,0))+(ISNULL(PFCAP,0)*(0.01/100))+(BASIC * (0.50/100))+(ISNULL(EPFCD,0))+(ISNULL(EPSD,0)))) 'Total',
							Remarks = CASE  WHEN ISNULL(DOEEPF,'') <> '' THEN  'Relieved'
											WHEN ISNULL(GEN,'') <> '' THEN 'New Joinee' ELSE '' END
									  --CASE  WHEN GEN = '' THEN '' ELSE 'New Joinee' END	 --'Remarks'	
				FROM @FinalForm1	--WHERE DOEEPF<>''
				ORDER BY CODE ,ord  
		
			 END
  		END  
		END  
	END  
	IF(@qryid = 'RT')
	BEGIN

		DECLARE @Cur_Mon_Sub_EPF int, @Cur_Mon_Sub_FPF int, @REL_SUB_EPF INT, @REL_SUB_FPF INT,
			@Prv_REL_SUB_EPF INT, @Prv_REL_SUB_FPF INT--, @Prev_mon varchar(6)

		SELECT @Prev_mon = dbo.gefgYYYYMM(dateadd(month, -1, dbo.gefgChar2Date(rtrim(@month)+'01')))

		SELECT tfoempfk empfk, pststaamt
		INTO #tmpPrvjnEmp
		FROM pytremptofrolog WITH (NOLOCK)
		JOIN pymgaccaldfn WITH (NOLOCK) ON calpk = tfocalfk AND caldelid = 0 and calmonth < @Month AND CalCmpFk = @CmpFk
		JOIN prohrPrsstatrgr WITH (NOLOCK) ON pstempfk = tfoempfk AND pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt <= 0
		JOIN prohrpayprslog WITH (NOLOCK) ON paypk = pstprsfk AND paydelid = 0 and paycalprd = calmonth 
		join #DepEmp on EmpFk =PstEmpFk 
		WHERE tfotyp = 1 AND tfodelid = 0
	
-- SELECT * FROM #tmpPrvjnEmp

--	and not exists (select Null from prohrPrsstatrgr with (nolock) 
--							join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd =  @Month
--						where pstscpfk = @PfCmpFk and pstdelid = 0 and pststaamt <=0 and pstempfk = tfoempfk)
--	where tfotyp = 1 and tfodelid = 0

--select count(*) from #list_final
--select * from #tmpprvjnemp


--pfemp
--select ''''+ rtrim(empcd), rtrim(empdispnm), empid
--from #List_final 
--join Profamgempmas with (nolock) on emppk = empid
--		where pfemp> 0 --and not exists (select Null from #tmpPrvjnEmp where empfk = empid)


		select @Cur_Mon_Sub_EPF = count(EMPID) from #List_final
			where pfemp> 0 --and not exists (select Null from #tmpPrvjnEmp where empfk = empid)

 
--	select empid, datediff(year, rlndob, dbo.gefgchar2date('30/'+ right(@month, 2)+ '/' + left(@month,4)))
--	from #List_final
--	JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = empid AND RlnDelId = 0
--	JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
--	where rlndob is null

		select @Cur_Mon_Sub_FPF = count(Empid) 
		from #List_final
			JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = empid AND RlnDelId = 0
			JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
			and isnull(datediff(year, rlndob, dbo.gefgchar2date('25/'+ right(@month, 2)+ '/' + left(@month,4))),0) <= @MaxAge
		where pfemp > 0

		SELECT @NEW_SUB_EPF = count(TfoEmpfk)
		FROM #list_final 
			join PyTrEmpToFroLog with (nolock) on tfoempfk = empid and tfodelid = 0 and tfotyp = 1
			join PyMgAcCalDfn with (nolock) on CalPk = TfoCalFk AND CalMonth = @Month AND CalDelId = 0 AND CalCmpFk = @CmpFk
--	join prohrPrsstatrgr with (nolock) on pstempfk = empid and pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt > 0
--	join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd = calmonth 


		SELECT @NEW_SUB_EPF = count(TfoEmpfk)
		FROM #list_final 
			join PyTrEmpToFroLog with (nolock) on tfoempfk = empid and tfodelid = 0 and tfotyp = 1
			join PyMgAcCalDfn with (nolock) on CalPk = TfoCalFk AND CalMonth = @Month AND CalDelId = 0 AND CalCmpFk = @CmpFk

		SELECT @NEW_SUB_FPF = count(TfoEmpfk)
			FROM #list_final 
		join PyTrEmpToFroLog with (nolock) on tfoempfk = empid and tfodelid = 0 and tfotyp = 1
		join PyMgAcCalDfn with (nolock) on CalPk = TfoCalFk AND CalMonth = @Month AND CalDelId = 0 AND CalCmpFk = @CmpFk
--	JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = empid AND RlnDelId = 0
--	JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
--	 and isnull(datediff(year, rlndob, dbo.gefgchar2date('30/'+ right(@month, 2)+ '/' + left(@month,4))),0) <= @MaxAge
--	join prohrPrsstatrgr with (nolock) on pstempfk = empid and pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt > 0
--	join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd = calmonth 

		SELECT @REL_SUB_EPF = COUNT(TfoEmpFk) 
		FROM ProFaMgEmpMas with (Nolock)
			JOIN PytrEmpToFroLog with (Nolock) ON EmpPk = TfoEmpFk AND TfoDelId = 0
			JOIN PyMgAcCalDfn with (Nolock) ON CalPk = TfoCalFk AND CalDelId = 0 AND CalCmpFk = @CmpFk
			JOIN PyMgEmpPaySl with (Nolock) ON EpSdEmpFk = EmpPk AND EpSdDelId = 0
		WHERE CalMonth = @Month AND TfoTyp = 0 AND epsdscpfk = @PfEMYFk AND EmpDelId = 0 and epsdamt > 0
			and datediff(day, empdoj, tfodt) <> 0 AND EmpCmpFk = @CmpFk
			AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = EmpPK)

		SELECT @Prv_REL_SUB_EPF = COUNT(TfoEmpFk) 
		FROM ProFaMgEmpMas with (Nolock)
			JOIN PytrEmpToFroLog with (Nolock) ON EmpPk = TfoEmpFk AND TfoDelId = 0
			JOIN PyMgAcCalDfn with (Nolock) ON CalPk = TfoCalFk AND CalDelId = 0 AND CalCmpFk = @CmpFk
			JOIN PyMgEmpPaySl with (Nolock) ON EpSdEmpFk = EmpPk AND EpSdDelId = 0
		WHERE CalMonth = @Prev_mon AND TfoTyp = 0 AND epsdscpfk = @PfEMYFk AND EmpDelId = 0 and epsdamt > 0
			and datediff(day, empdoj, tfodt) <> 0 AND EmpCmpFk = @CmpFk
			AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = EmpPK)

		SELECT @REL_SUB_FPF = COUNT(TfoEmpFk) 
		FROM ProFaMgEmpMas with (Nolock)
			JOIN PytrEmpToFroLog with (Nolock) ON EmpPk = TfoEmpFk AND TfoDelId = 0
			JOIN PyMgAcCalDfn with (Nolock) ON CalPk = TfoCalFk AND CalDelId = 0 AND CalCmpFk = @CmpFk
			JOIN PyMgEmpPaySl with (Nolock) ON EpSdEmpFk = EmpPk AND EpSdDelId = 0
			JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = EmpPk AND RlnDelId = 0
			JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
				and isnull(datediff(year, rlndob, dbo.gefgchar2date('25/'+ right(@month, 2)+ '/' + left(@month,4))),0) <= @MaxAge
		WHERE CalMonth = @Month AND TfoTyp = 0 AND epsdscpfk = @PfEMYFk AND EmpDelId = 0 and epsdamt > 0
			and datediff(day, empdoj, tfodt) <> 0 AND EmpCmpFk = @CmpFk
			AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = EmpPK)

		SELECT @Prv_REL_SUB_FPF = COUNT(TfoEmpFk) 
		FROM ProFaMgEmpMas with (Nolock)
			JOIN PytrEmpToFroLog with (Nolock) ON EmpPk = TfoEmpFk AND TfoDelId = 0
			JOIN PyMgAcCalDfn with (Nolock) ON CalPk = TfoCalFk AND CalDelId = 0 AND CalCmpFk = @CmpFk
			JOIN PyMgEmpPaySl with (Nolock) ON EpSdEmpFk = EmpPk AND EpSdDelId = 0
			JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = EmpPk AND RlnDelId = 0
			JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
				and isnull(datediff(year, rlndob, dbo.gefgchar2date('25/'+ right(@month, 2)+ '/' + left(@month,4))),0) <= @MaxAge
		WHERE CalMonth = @Prev_mon AND TfoTyp = 0 AND epsdscpfk = @PfEMYFk AND EmpDelId = 0 and epsdamt > 0
			and datediff(day, empdoj, tfodt) <> 0 AND EmpCmpFk = @CmpFk
			AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = EmpPK)


		Select @LAST_MON_SUBS_EPF=count(*) from #LIST_Prv

---	set @LAST_MON_SUBS_EPF = @Cur_Mon_Sub_EPF  - @NEW_SUB_EPF + @Prv_REL_SUB_EPF
		select @LAST_MON_SUBS_FPF = count(*) 
		from #LIST_Prv
			JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = L_Empfk AND RlnDelId = 0
			JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
			and isnull(datediff(year, rlndob, dbo.gefgchar2date('25/'+ right(@month, 2)+ '/' + left(@month,4))),0) <= @MaxAge
	 
	---set @LAST_MON_SUBS_FPF = @Cur_Mon_Sub_FPF  - @NEW_SUB_FPF + @Prv_REL_SUB_FPF

--select @LAST_MON_SUBS_EPF, @Cur_Mon_Sub_EPS, @NEW_SUB_EPF,  
--@LAST_MON_SUBS_FPF, @Cur_Mon_Sub_FPF, @NEW_SUB_FPF,  @REL_SUB_EPF, @REL_SUB_FPF  


--
--	select count(pstempfk) from prohrPrsstatrgr with (nolock)
--		join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd =  @month
--		join #DepEmp on empfk = pstempfk
--	where pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt > 0
--
--	select @LAST_MON_SUBS_EPF = count(pstempfk) from prohrPrsstatrgr with (nolock)
--		join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd =  @Prev_mon
--		join #DepEmp on empfk = pstempfk
--	where pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt > 0
--
--	select @LAST_MON_SUBS_FPF = count(pstempfk) from prohrPrsstatrgr with (nolock)
--		join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd =  @Prev_mon
--		join #DepEmp on empfk = pstempfk
--		JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = Pstempfk AND RlnDelId = 0
--		JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
--		 and datediff(year, rlndob, dbo.gefgchar2date('30/'+ right(@month, 2)+ '/' + left(@month,4))) <= @MaxAge
--	where pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt > 0
--
----	SELECT @REL_SUB = COUNT(TfoEmpFk) 
----		FROM PyTrEmpToFroLog with (nolock)
----		join PyMgAcCalDfn with (nolock) on CalPk = TfoCalFk AND CalMonth = @Prev_mon AND CalDelId = 0 
----	WHERE TfoDelId = 0 AND TfoTyp = 0
----		AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = TfoEmpFk) 
--
--
--
--
--	SELECT @NEW_SUB_EPF = count(TfoEmpfk)
--		FROM PyTrEmpToFroLog with (nolock)
--		join PyMgAcCalDfn with (nolock) on CalPk = TfoCalFk AND CalMonth = @Month AND CalDelId = 0 
--		join Prohrprsstatrgr with (nolock) on pstempfk = tfoempfk and pstdelid = 0 and pstscpfk = @PfCmpfk and pststaamt > 0
--		join prohrpayprslog with (nolock) on paypk = pstprsfk and paydelid = 0 and paycalprd =  @Month
--	WHERE TfoDelId = 0 AND TfoTyp = 1
--		AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = TfoEmpFk) 
--

--return

--	SELECT @LAST_MON_SUBS_EPF = COUNT(PysEmpFk)  FROM ProHrPrsPayDtls with (nolock), ProhrPayPrsLog with (nolock)
--	WHERE PayPk = PysPrsFk AND PysScpFk = @PfCmpFk AND PysDelId = 0 
--		AND PayCalPrd = @Prev_mon AND PayDelId = 0
--
--
--
--	SELECT @LAST_MON_SUBS_FPF = COUNT(PysEmpFk) FROM ProHrPrsPayDtls with (nolock), ProhrPayPrsLog with (nolock)
--	WHERE PayPk = PysPrsFk AND PysScpFk = @PfCmpFk AND PysDelId = 0 
--		AND PayCalPrd = @Prev_mon AND PayDelId = 0
--
---- 	SELECT @REL_SUB = count(DISTINCT PfEmpFk) FROM pytremppfdtls, ProHrEmpOffDtls, ProHrEmpAttrDet, ProHrEmpAttrHdr
---- 	 WHERE pfempFk = EodEmpFk AND EthPK = EtdEthFk AND EtdPk = EodEtrdFk AND EthTyp = 'REL_DT' 
---- 		AND EthPk = EodEtrhFk --AND 
---- --		dbo.gefgyyyymm(dbo.gefgChar2Date(Case When ISNULL(EodEntyDesc, '') = '' Then '01/01/1900' Else RTRIM(EodEntyDesc) End)) = @Prev_mon
---- 		AND PFDelID = 0 AND EodDelId = 0 AND EtdDelId = 0 AND EthDelId = 0
--
---- 	SELECT EodEmpFk, EodEntyDesc INTO #EmpRel FROM ProHrEmpOffDtls, ProHrEmpAttrHdr
---- 	 WHERE EthTyp = 'REL_DT' AND EthPk = EodEtrhFk --AND 
---- 		AND EodDelId = 0 AND EthDelId = 0 AND ISNULL(EodEntyDesc, '') <> ''
---- 
---- 	SELECT @REL_SUB = COUNT(EodEmpFk) FROM #EmpRel 
---- 	WHERE dbo.gefgYYYYMM(dbo.gefgChar2Date(EodEntyDesc)) = @Month 
--
---- 	select @Month
---- 	select * from #DepEmp
--
--	SELECT @REL_SUB = COUNT(TfoEmpFk) FROM PyTrEmpToFroLog with (nolock), PyMgAcCalDfn with (nolock)
--	WHERE CalPk = TfoCalFk AND TfoDelId = 0 AND CalDelId = 0 AND CalMonth = @Month AND TfoTyp = 0
--		AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = TfoEmpFk) 
--
---- 	SELECT COUNT(TfoEmpFk) FROM PyTrEmpToFroLog, PyMgAcCalDfn
---- 	WHERE CalPk = TfoCalFk AND TfoDelId = 0 AND CalDelId = 0 AND CalMonth = '200909' AND TfoTyp = 0
---- 		AND EXISTS(SELECT NULL FROM #DepEmp WHERE EmpFk = TfoEmpFk) 
--
--	
---- 	SELECT @NEW_SUB_EPF = count(distinct empid) FROM #list_final
----   	 WHERE NOT EXISTS (select NULL FROM PytrEmpPfDtls WHERE pfempfk = empid AND PfTrsPrd = @Prev_mon)
---- 	   AND  PF > 0
---- 
---- 	SELECT @NEW_SUB_FPF = count(distinct empid) FROM #list_final
----   	 WHERE NOT EXISTS (select NULL FROM PytrEmpPfDtls WHERE pfempfk = empid AND PfTrsPrd = @Prev_mon)
---- 	   AND PF > 0
--
--	SELECT @NEW_SUB_EPF = COUNT(EmpId) FROM #list_final
--	WHERE NOT EXISTS(SELECT NULL FROM ProHrPrsPayDtls with (nolock), ProhrPayPrsLog  with (nolock)
--			WHERE PayPk = PysPrsFk AND PysScpFk = @PfCmpFk AND PysDelId = 0 
--				AND PayCalPrd = @Prev_mon AND PayDelId = 0 AND EmpId = PysEmpFk)
--
-----	SELECT @NEW_SUB_EPF
--
--	SELECT @NEW_SUB_FPF = COUNT(EmpId) FROM #list_final
--	WHERE NOT EXISTS(SELECT NULL FROM ProHrPrsPayDtls with (nolock), ProhrPayPrsLog  with (nolock)
--			WHERE PayPk = PysPrsFk AND PysScpFk = @PfCmpFk AND PysDelId = 0 
--				AND PayCalPrd = @Prev_mon AND PayDelId = 0 AND EmpId = PysEmpFk)
--	
--
---- 	select @ORG_NAME = CfgOrgNm,
---- 		@Address1 = ConAdd1,
---- 		@Address2 = ConAdd2,
---- 		--@Address3 = case ConAdd3 when null then '' else ConAdd3 end,
---- 		@Address3 = ConCity,
---- 		@PF_CODE = cfgPfcdNo
---- 		from PymgConfig, PymgConDtls
---- 		where CfgOrgConFk = ConPk

		SELECT @ORG_NAME = RTRIM(CmpDispNm),
			@Address1 = RTRIM(ISNULL(ConAdd1, '')), 
			@Address2 = RTRIM(ISNULL(ConAdd2, '')),
 			@Address3 = RTRIM(ConCity)--,
	-- 		@PF_CODE = ''
		FROM ProFaMgCmpMas with (nolock), ProFaMgLocMas with (nolock), ProFaMgConDtls with (nolock)
		WHERE CmpCurLocFk = LocPk AND LocAddFk = ConPk AND
			LocDelId = 0 AND CmpDelId = 0 AND ConDelId = 0 AND CmpPk = @CmpFk

		SELECT @PF_CODE = RTRIM(CmpDesc) FROM ProHrCmpCnfgHdr with (nolock), ProHrCmpCnfgEntry with (nolock)
		WHERE CmpCchFk = CchPk AND CchDelId = 0 AND CmpDelId = 0 AND CchCd = 'CmpPFCode' AND CmpCmpFk = @CmpFk

		SELECT @StrMth = FyrStartMth, @EndMth = FyrEndMth
		FROM ProFaMgFyrDefn with (nolock)
		WHERE FyrStartMth <= @month and FyrEndMth >= @month

		insert into #TmpEmpDob (DobEmpFk, Age)
		SELECT RlnEmpFk DobEmpFk, datediff(year, rlndob, dbo.gefgchar2date('25/'+ right(@month, 2)+ '/' + left(@month,4))) Age
		--Into #TmpEmpDob
		From #List_Final
		JOIN ProHrEmpRlnMas WITH (NOLOCK) ON RlnEmpfk = EmpId AND RlnDelId = 0
		JOIN ProHrEmpAttrDet WITH (NOLOCK) ON EtdPk = RlnEtrdFk  AND EtdCd = 'SELF' AND EtdDelid = 0
		Join #DepEmp on empfk = RlnEmpfk


--	select * from #TmpPF
------------subbu---------------
			-- Added By Manoj for Fastreport
			SET @Frm12A   = 'Employees'' Provident Fund And  Misc.Provisions Act,1952'
			SET @FrmPSch  = 'Employees'' Pension Scheme [Paragraph 20(4)]'

-- SELECT @LAST_MON_SUBS_EPF, @Cur_Mon_Sub_EPS, @NEW_SUB_EPF,  
-- @LAST_MON_SUBS_FPF, @Cur_Mon_Sub_FPF, @NEW_SUB_FPF,  @REL_SUB_EPF, @REL_SUB_FPF  
--
--SELECT '123'
--SELECT COUNT(*) FROM #LIST_FINAL


--select EMPcd,a.* from #list_final a, ProFaMgEmpMas with (nolock) where EmpPk = EMPID

--select ROUND(sum(LF_PFCAP),0)	AS 'spnPnWages'
--FROM #LIST_FINAL
----LEFT OUTER JOIN #TmpEmpDob ON DobEmpFk = empid 
--return

			select  rtrim(ISNULL(@ORG_NAME,'')) as 'spnOrgNm', rtrim(ISNULL(@Address1,'')) as 'spnAdd1',
			rtrim(ISNULL(@Address2,'')) as 'spnAdd2', rtrim(ISNULL(@Address3,'')) as 'spnAdd3',
			rtrim(isnull(@pf_code,'')) AS 'spnPFcode',
			rtrim(dbo.gefgLongDate('my',rtrim(@month), '')) as 'spnMonTitl',
			@LAST_MON_SUBS_EPF as 'spnLastMonEP',
			@LAST_MON_SUBS_FPF as 'spnLastMonPF',
			@LAST_MON_SUBS_EPF as 'spnLastMonED',
			@NEW_SUB_EPF as 'spnNewSubEP',
			@NEW_SUB_FPF as 'spnNewSubPF',
			@NEW_SUB_EPF as 'spnNewSubED',
			@REL_SUB_EPF as 'spnRelSubEP',
			@REL_SUB_FPF as 'spnRelSubPF',
			@REL_SUB_EPF as 'spnRelSubED',
			@Cur_Mon_Sub_EPF as 'spnTotSubEP',
			@Cur_Mon_Sub_FPF as 'spnTotSubPF',
			@Cur_Mon_Sub_EPF as 'spnTotSubED',
			@Cur_Mon_Sub_EPF as 'spnTotSubC',
			@Cur_Mon_Sub_EPF as 'spnTotEmp',

-- select dbo.gefgCurFormat(10000, 0)
			dbo.gefgCurFormat(SUM(ROUND(BASIC,0)), 1) as 'spnWages', --PF BASIC
--				sum(case when age > @MaxAge then 0 else round(basic,0) end) as  'spnPnWages',  -- PENSION WAGES
			ROUND(sum(LF_PFCAP),0)	+  round(sum( case when LF_EPSARR = 0 then 0 else BASICARR end),0) AS 'spnPnWages',
			--dbo.gefgCurFormat(SUM(CASE WHEN @PFEMP_PRCNT < ROUND(BASIC,0) THEN @PFEMP_PRCNT ELSE ROUND(BASIC,0) END),1) AS 'spnPnWages',
			dbo.gefgCurFormat(ROUND(sum(PFEMP + VPF),0),1) as 'spnPFEmp',  --EMP 12%
			--round(sum(PFEMY-LF_EPS), 0) as 'spnPFWrkShar', --EMY DIFF (12 -8.33%)
			--round(sum(LF_EPS),0)as 'spnEPS',  --8.33%
			dbo.gefgCurFormat(round(sum(case when age > @MaxAge then PFemy else (PFEMY-LF_EPS) end),0),1) as 'spnPFWrkShar',
			dbo.gefgCurFormat(round(sum(case when age > @MaxAge then 0 else LF_EPS end),0),1) as 'spnEPS',
--				round(sum(BASIC) * @ADMN_PRCNT/100.0 ,0) as 'spnAdminChrgd',
--				round(sum(BASIC) * @EDLI_PRCNT/100.0 ,0) as 'spnEDLI',
--				round(sum(BASIC) * @ADMN_EDLI_PRCNT/100.0 ,0) as 'spnAdminEDLId',
-- SUM(LF_ADMCHGS) 'AdminChrg', SUM(LF_EDLI) 'Edli', SUM(LF_ADMEDLI) 'EdliAdminChrg',
			dbo.gefgCurFormat(round(sum(LF_ADMCHGS), 0),1)  as 'spnAdminChrgd',
			dbo.gefgCurFormat(round(sum(LF_EDLI), 0),1)  as 'spnEDLI',
			dbo.gefgCurFormat(round(sum(LF_ADMEDLI), 0),1)  as 'spnAdminEDLId',
			'Currency Period from ' + rtrim(dbo.gefgLongDate('MY', @StrMth, '')) + ' to ' + rtrim(dbo.gefgLongDate('MY', @EndMth, '')) as 'spnCurhdr',
			'Statement of contributions for the month of ' + dbo.gefgLongDate('MY', @month, '') as 'spnSathdr',
			dbo.gefgLongDate('MY', @StrMth, '') as 'spnFrmDt', dbo.gefgLongDate('MY', @EndMth, '') as 'spnToDt' , 
			@Frm12A AS '12Aact' , @FrmPSch AS '12aSCh'
			FROM #LIST_FINAL
			LEFT OUTER JOIN #TmpEmpDob ON DobEmpFk = empid
	END
END 




GO
