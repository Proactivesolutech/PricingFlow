
BEGIN TRAN

	DECLARE @Pk BIGINT, @BnkCd VARCHAR(100), @BnkNm VARCHAR(100), @IFSC VARCHAR(20), @MICR VARCHAR(100), @Addr VARCHAR(MAX) , @Location VARCHAR(100),
			@Centre VARCHAR(100), @State VARCHAR(100)

	SELECT	@BnkCd	= 'HDFC',
			@BnkNm	= 'HDFC Bank Ltd.',
			@IFSC	= 'HDFC0003646',
			@MICR	= '440240017',
			@Addr	= 'Ground Floor, Status Enclave, near Aychit Mandir, Bus Stand, Lakda Pul, Mahal, Nagpur  - 440002',
			@Location	=	'Mahal Nagpur',
			@Centre	=	'Nagpur',
			@State	=	'Maharashtra'

	INSERT INTO GenBnkMas(BnkCd,BnkNm,BnkStatFlg,BnkRowId,BnkCreatedDt,BnkCreatedBy,BnkModifiedDt,BnkModifiedBy,BnkDelFlg,BnkDelId)
	OUTPUT INSERTED.*
	SELECT @BnkCd,@BnkNm,'L', NEWID(), GETDATE(),'ADMIN',GETDATE(),'ADMIN',NULL,0

	SELECT @Pk = SCOPE_IDENTITY()

	INSERT INTO GenBnkBrnchMas
	(
		BbmBnkFk,BbmLoc,BbmMICR,BbmIFSC,BbmCentre,BbmAddress,BbmState,BbmStatFlg,BbmRowId,
		BbmCreatedBy,BbmCreatedDt,BbmModifiedBy,BbmModifiedDt,BbmDelFlg,BbmDelId
	)
	OUTPUT INSERTED.*
	SELECT @Pk, @Location, @MICR, @IFSC, @Centre, @Addr, @State, 'L', NEWID(),'ADMIN', GETDATE(), 'ADMIN', GETDATE(),NULL,0

ROLLBACK TRAN