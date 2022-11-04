IF OBJECT_ID('PrcShflPincodehelp','P') IS NOT NULL
	DROP PROCEDURE PrcShflPincodehelp
GO
CREATE PROCEDURE PrcShflPincodehelp
(
@Pincode VARCHAR(MAX)	= NULL,
@pin VARCHAR(MAX)	= NULL
)
AS
BEGIN 

	IF ISNULL(@Pincode,'0') = '0'
	BEGIN
	SELECT	PinCd 'Pincode',PinState 'State',PinCity 'City',PinArea 'Area',PinPk 'PinPk' 
	FROM	GenPinCode (NOLOCK) 
	WHERE	PinStatFlg = 'L' AND PinDelId = 0
	END
	ELSE
	BEGIN
	SELECT	PinCd 'Pincode',PinPk 'PinPk' ,PinState 'State',PinCity 'City',PinArea 'Area'
	FROM	GenPinCode (NOLOCK) 
	WHERE	PinStatFlg = 'L' AND PinDelId = 0 AND PinCd LIKE  '%' + @Pincode + '%'	
	END

END




