CREATE TABLE [dbo].[LosLead](
	[LedId] varchar(100) NOT NULL,
	[LedAgtNm] varchar(100) NOT NULL,
	[LedBGeoFk] [fkid] NOT NULL,
	[LedNm] varchar(100) NOT NULL,
	[LedDOB] datetime NOT NULL,
	[LedPrdFk] [fkid] NOT NULL,
	[LedEmpCat] varchar(100) NOT NULL,
	[LedMrktVal] numeric(27,7) NOT NULL,
	[LedPrvLnCrd] bit NOT NULL,
	[LedLnAmt] numeric(27,7) NOT NULL,
	[LedTenure] tinyint NOT NULL,
	[LedDflt] bit NOT NULL,
	[LedMonInc] numeric(27,7) NOT NULL,
	[LedIncPrf] bit NOT NULL,
	[LedMonObli] numeric(27,7) NOT NULL,
	[LedCIBILScr] int NOT NULL,
	[LedEMI] numeric(27,7) NOT NULL,
	[LedROI] numeric(5,2) NOT NULL,
	[LedPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LedRowId] [RowId] NOT NULL,
	[LedCreatedBy] varchar(100) NOT NULL,
	[LedCreatedDt] datetime NOT NULL,
	[LedModifiedBy] varchar(100) NOT NULL,
	[LedModifiedDt] datetime NOT NULL,
	[LedDelFlg] [DelFlg] NULL,
	[LedDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LedPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosLead] ADD  DEFAULT ((0)) FOR [LedDelId]
GO
ALTER TABLE [dbo].[LosLead]  WITH CHECK ADD FOREIGN KEY([LedBGeoFk]) REFERENCES [dbo].[ShflGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosLead]  WITH CHECK ADD FOREIGN KEY([LedPrdFk]) REFERENCES [dbo].[ShflPrdMas] ([PrdPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Lead Id'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedId'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Agent Name - Reference'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedAgtNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch GeoMaster Fk - Reference'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Name'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Date of Birth'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employment category'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedEmpCat'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estimated Markert value of property'				, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedMrktVal'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Previous loan or card history? 0 - No, 1 - Yes '	, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedPrvLnCrd'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expected Loan Amount'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedLnAmt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expected Repayment Tenure'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedTenure'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Defaulted on loan/card? 0- No , 1 - Yes'			, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedDflt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monthly Income'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedMonInc'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Has Income Proofs? 0 - No , 1 - yes '				, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedIncPrf'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monthly Obligations'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedMonObli'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CIBLIL Score'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedCIBILScr'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estimated EMI'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedEMI'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estimated Rate of Interest'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedROI'
GO

CREATE TABLE [dbo].[LosDocument](
	[DocLedFk] [fkid] NOT NULL,
	[DocAgtNm] varchar(100) NOT NULL,
	[DocBGeoFk] [fkid] NOT NULL,
	[DocPrdFk] [fkid] NOT NULL,
	[DocActor] varchar(100) NOT NULL,
	[DocCat]	varchar(100) NOT NULL,
	[DocSubCat] varchar(100) NOT NULL,
	[DocNm]		varchar(100) NOT NULL,
	[DocPath]	varchar(500) NOT NULL,
	[DocPk] [pkid] IDENTITY(1,1) NOT NULL,
	[DocRowId] [RowId] NOT NULL,
	[DocCreatedBy] varchar(100) NOT NULL,
	[DocCreatedDt] datetime NOT NULL,
	[DocModifiedBy] varchar(100) NOT NULL,
	[DocModifiedDt] datetime NOT NULL,
	[DocDelFlg] [DelFlg] NULL,
	[DocDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[DocPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosDocument]  WITH CHECK ADD FOREIGN KEY([DocLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosDocument]  WITH CHECK ADD FOREIGN KEY([DocBGeoFk]) REFERENCES [dbo].[ShflGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosDocument]  WITH CHECK ADD FOREIGN KEY([DocPrdFk]) REFERENCES [dbo].[ShflPrdMas] ([PrdPk])
GO
ALTER TABLE [dbo].[LosDocument] ADD  DEFAULT ((0)) FOR [DocDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk reference of the document'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Agent name'												, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocAgtNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch Fk refernce'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk Reference'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Actor(Applicant/CoApplicant)'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document category(KYC, Property, INC)'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocCat'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document subcategory( Addres Proof, Id Proof )'			, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocSubCat'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the document( ex: Voter Id)'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Saved documents physical path'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocPath'
GO

CREATE TABLE [dbo].[LosQDE](
	[QDELedFk]			[fkid] NOT NULL,
	[QDEBGeoFk]			[fkid] NOT NULL,
	[QDEPrdFk]			[fkid] NOT NULL,
	[QDEActor]			varchar(100) NOT NULL,
	[QDEFstNm]			varchar(100) NOT NULL,
	[QDEMdNm]			varchar(100) NOT NULL,
	[QDELstNm]			varchar(100) NOT NULL,
	[QDEGender]			varchar(100) NOT NULL,
	[QDEDOB]			datetime NOT NULL,
	[QDEContact]		numeric NOT NULL,
	[QDEEmail]			varchar(100) NOT NULL,
	[QDEAadhar]			varchar(100) NOT NULL,
	[QDEPAN]			varchar(100) NOT NULL,
	[QDEDrvLic]			varchar(100) NOT NULL,
	[QDEVoterId]		varchar(100) NOT NULL,
	[QDEDoorNo]			varchar(100) NOT NULL,
	[QDEBuilding]		varchar(100) NOT NULL,
	[QDEPlotNo]			varchar(500) NOT NULL,
	[QDEStreet]			varchar(100) NOT NULL,
	[QDELandmark]		varchar(100) NOT NULL,
	[QDEArea]			varchar(100) NOT NULL,
	[QDEDistrict]		varchar(100) NOT NULL,
	[QDEState]			varchar(100) NOT NULL,
	[QDECountry]		varchar(100) NOT NULL,
	[QDEPin]			numeric NOT NULL,
	[QDEPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[QDERowId]			[RowId] NOT NULL,
	[QDECreatedBy]		varchar(100) NOT NULL,
	[QDECreatedDt]		datetime NOT NULL,
	[QDEModifiedBy]		varchar(100) NOT NULL,
	[QDEModifiedDt]		datetime NOT NULL,
	[QDEDelFlg]			[DelFlg] NULL,
	[QDEDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QDEPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosQDE] ADD  DEFAULT ((0)) FOR [QDEDelId]
GO
ALTER TABLE [dbo].[LosQDE]  WITH CHECK ADD FOREIGN KEY([QDELedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosQDE]  WITH CHECK ADD FOREIGN KEY([QDEBGeoFk]) REFERENCES [dbo].[ShflGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosQDE]  WITH CHECK ADD FOREIGN KEY([QDEPrdFk]) REFERENCES [dbo].[ShflPrdMas] ([PrdPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk reference'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDELedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch Geo Fk reference'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk reference'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actor - Applicant/CoApplicant'			, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Middle Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDELstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender '									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of birth '							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact Number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEContact'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email ID'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEEmail'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Aadhar Number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEAadhar'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PAN number '								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEPAN'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Driving License Number'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEDrvLic'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voter Id'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEVoterId'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Door Number'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEDoorNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Building name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEBuilding'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plot number'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEPlotNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Street name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEStreet'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Land mark'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDELandmark'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEArea'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'District '								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEDistrict'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEState'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDECountry'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PIN Code'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEPin'
GO

CREATE TABLE [dbo].[LosAadhar](
	[AadLedFk] [fkid] NOT NULL,
	[AadNo] varchar(100) NOT NULL,
	[AadDoorNo] varchar(100) NOT NULL,
	[AadBuilding] varchar(100) NOT NULL,
	[AadPlotNo] varchar(100) NOT NULL,
	[AadStreet] varchar(100) NOT NULL,
	[AadLandmark] varchar(100) NOT NULL,
	[AadArea] varchar(100) NOT NULL,
	[AadDistrict] varchar(100) NOT NULL,
	[AadState] varchar(100) NOT NULL,
	[AadCountry] varchar(100) NOT NULL,
	[AadPin] numeric NOT NULL,
	[AadPk] [pkid] IDENTITY(1,1) NOT NULL,
	[AadRowId] [RowId] NOT NULL,
	[AadCreatedBy] varchar(100) NOT NULL,
	[AadCreatedDt] datetime NOT NULL,
	[AadModifiedBy] varchar(100) NOT NULL,
	[AadModifiedDt] datetime NOT NULL,
	[AadDelFlg] [DelFlg] NULL,
	[AadDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[AadPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAadhar] ADD  DEFAULT ((0)) FOR [AadDelId]
GO
ALTER TABLE [dbo].[LosAadhar]  WITH CHECK ADD FOREIGN KEY([AadLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Aadhar Number'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'House Door Number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadDoorNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Building name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadBuilding'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plot number'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadPlotNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Street name'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadStreet'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Land mark'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadLandmark'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area'											, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadArea'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'District'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadDistrict'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadState'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadCountry'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PIN code'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2typeN'COLUMN',@level2name=N'AadPin'
GO


CREATE TABLE [dbo].[LosCustomer](
	[CusFstNm] varchar(100) NOT NULL,
	[CusMdNm] varchar(100) NOT NULL,
	[CusLstNm] varchar(100) NOT NULL,
	[CusGender] varchar(100) NOT NULL,
	[CusDOB] datetime NOT NULL,
	[CusContact] numeric NOT NULL,
	[CusEmail] varchar(100) NOT NULL,
	[CusAadhar] varchar(100) NOT NULL,
	[CusPAN] varchar(100) NOT NULL,
	[CusDrvLic] varchar(100) NOT NULL,	
	[CusPk] [pkid] IDENTITY(1,1) NOT NULL,
	[CusRowId] [RowId] NOT NULL,
	[CusCreatedBy] varchar(100) NOT NULL,
	[CusCreatedDt] datetime NOT NULL,
	[CusModifiedBy] varchar(100) NOT NULL,
	[CusModifiedDt] datetime NOT NULL,
	[CusDelFlg] [DelFlg] NULL,
	[CusDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[CusPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosCustomer] ADD  DEFAULT ((0)) FOR [CusDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer First name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer middle name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer last name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusLstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender'											, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of birth'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact number'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusContact'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email ID'											, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusEmail'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Aadhar Number'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusAadhar'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PAN number'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusPAN'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Driving License'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusDrvLic'
GO

CREATE TABLE [dbo].[LosCustomerAddress](
	[CadCusFk] varchar(100) NOT NULL,
	[CadDoorNo] varchar(100) NOT NULL,
	[CadBuilding] varchar(100) NOT NULL,
	[CadPlotNo] varchar(100) NOT NULL,
	[CadStreet] datetime NOT NULL,
	[CadLandmark] numeric NOT NULL,
	[CadArea] varchar(100) NOT NULL,
	[CadDistrict] varchar(100) NOT NULL,
	[CadState] varchar(100) NOT NULL,
	[CadCountry] varchar(100) NOT NULL,	
	[CadPin] varchar(100) NOT NULL,	
	[CadPk] [pkid] IDENTITY(1,1) NOT NULL,
	[CadRowId] [RowId] NOT NULL,
	[CadCreatedBy] varchar(100) NOT NULL,
	[CadCreatedDt] datetime NOT NULL,
	[CadModifiedBy] varchar(100) NOT NULL,
	[CadModifiedDt] datetime NOT NULL,
	[CadDelFlg] [DelFlg] NULL,
	[CadDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[CadPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosCustomerAddress] ADD  DEFAULT ((0)) FOR [CadDelId]
GO
ALTER TABLE [dbo].[LosCustomerAddress]  WITH CHECK ADD FOREIGN KEY([CadCusFk]) REFERENCES [dbo].[LosCustomer] ([CusPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Fk referance'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadCusFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Door number'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadDoorNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Building name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadBuilding'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plot name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadPlotNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Street name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadStreet'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Land mark'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadLandmark'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadArea'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'District'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadDistrict'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadState'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'country'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadCountry'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PIN code'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomerAddress', @level2type=N'COLUMN',@level2name=N'CadPin'
GO

CREATE TABLE [dbo].[LosAppEmpProfile](
	[LaeLedFk]		[fkid] NOT NULL,
	[LaeAppFk]		[fkid] NOT NULL,
	[LaeLapFk]		[fkid] NOT NULL,
	[LaeTyp]		varchar(100) NOT NULL,
	[LaeTitle]		char(10) NOT NULL,
	[LaeNat]		varchar(100) NOT NULL,
	[LaeDesig]		varchar(100) NOT NULL,
	[LaeExp]		tinyint	NOT NULL,
	[LaeTotExp]		tinyint	NOT NULL,
	[LaeOffNo]		varchar(20) NOT NULL,
	[LaeEMail]		varchar(100) NOT NULL,
	[LaePk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LaeRowId]		[RowId] NOT NULL,
	[LaeCreatedBy]	varchar(100) NOT NULL,
	[LaeCreatedDt]	datetime NOT NULL,
	[LaeModifiedBy] varchar(100) NOT NULL,
	[LaeModifiedDt] datetime NOT NULL,
	[LaeDelFlg]		[DelFlg] NULL,
	[LaeDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LaePk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppEmpProfile] ADD  DEFAULT ((0)) FOR [LaeDelId]
GO
ALTER TABLE [dbo].[LosAppEmpProfile]  WITH CHECK ADD FOREIGN KEY([LaeLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppEmpProfile]  WITH CHECK ADD FOREIGN KEY([LaeAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppEmpProfile]  WITH CHECK ADD FOREIGN KEY([LaeLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO

CREATE TABLE [dbo].[LosAppBusiProfile](
	[LabLedFk]		[fkid] NOT NULL,
	[LabAppFk]		[fkid] NOT NULL,
	[LabLapFk]		[fkid] NOT NULL,
	[LabCat]		bit NOT NULL,
	[LabTyp]		varchar(100) NOT NULL,
	[LabTitle]		char(10) NOT NULL,
	[LabNat]		varchar(100) NOT NULL,
	[LabOwnShip]	varchar(100) NOT NULL,
	[LabIncYr]		int	NOT NULL,
	[LabBusiPrd]	tinyint	NOT NULL,
	[LabCIN]		varchar(50) NOT NULL,
	[LabOffNo]		varchar(50) NOT NULL,
	[LabEMail]		varchar(100) NOT NULL,
	[LabPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LabRowId]		[RowId] NOT NULL,
	[LabCreatedBy]	varchar(100) NOT NULL,
	[LabCreatedDt]	datetime NOT NULL,
	[LabModifiedBy] varchar(100) NOT NULL,
	[LabModifiedDt] datetime NOT NULL,
	[LabDelFlg]		[DelFlg] NULL,
	[LabDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LabPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppBusiProfile] ADD  DEFAULT ((0)) FOR [LabDelId]
GO
ALTER TABLE [dbo].[LosAppBusiProfile]  WITH CHECK ADD FOREIGN KEY([LabLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppBusiProfile]  WITH CHECK ADD FOREIGN KEY([LabAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppBusiProfile]  WITH CHECK ADD FOREIGN KEY([LabLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Professional, 1 - NonProfessional', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiProfile', @level2type=N'COLUMN',@level2name=N'LabCat'
GO

CREATE TABLE [dbo].[LosAppBank](
	[LbkLedFk]		[fkid] NOT NULL,
	[LbkAppFk]		[fkid] NOT NULL,
	[LbkLapFk]		[fkid] NOT NULL,
	[LbkNm]			varchar(100) NOT NULL,
	[LbkAccTyp]		varchar(100) NOT NULL,
	[LbkAccNo]		varchar(100) NOT NULL,
	[LbkBank]		varchar(100) NOT NULL,
	[LbkBranch]		varchar(100) NOT NULL,
	[LbkIFSC]		varchar(100) NOT NULL,
	[LbkPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LbkRowId]		[RowId] NOT NULL,
	[LbkCreatedBy]	varchar(100) NOT NULL,
	[LbkCreatedDt]	datetime NOT NULL,
	[LbkModifiedBy] varchar(100) NOT NULL,
	[LbkModifiedDt] datetime NOT NULL,
	[LbkDelFlg]		[DelFlg] NULL,
	[LbkDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LbkPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppBank] ADD  DEFAULT ((0)) FOR [LbkDelId]
GO
ALTER TABLE [dbo].[LosAppBank]  WITH CHECK ADD FOREIGN KEY([LbkLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppBank]  WITH CHECK ADD FOREIGN KEY([LbkAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppBank]  WITH CHECK ADD FOREIGN KEY([LbkLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO

CREATE TABLE [dbo].[LosAppAst](
	[LasLedFk]		[fkid] NOT NULL,
	[LasAppFk]		[fkid] NOT NULL,
	[LasLapFk]		[fkid] NOT NULL,
	[LasTyp]		varchar(100) NOT NULL,
	[LasDesc]		varchar(max) NOT NULL,
	[LasAmt]		numeric(27,7) NOT NULL,
	[LasPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LasRowId]		[RowId] NOT NULL,
	[LasCreatedBy]	varchar(100) NOT NULL,
	[LasCreatedDt]	datetime NOT NULL,
	[LasModifiedBy] varchar(100) NOT NULL,
	[LasModifiedDt] datetime NOT NULL,
	[LasDelFlg]		[DelFlg] NULL,
	[LasDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LasPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppAst] ADD  DEFAULT ((0)) FOR [LasDelId]
GO
ALTER TABLE [dbo].[LosAppAst]  WITH CHECK ADD FOREIGN KEY([LasLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppAst]  WITH CHECK ADD FOREIGN KEY([LasAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppAst]  WITH CHECK ADD FOREIGN KEY([LasLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asset Type Bank Saving, Shares', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAst', @level2type=N'COLUMN',@level2name=N'LasTyp'
GO


CREATE TABLE [dbo].[LosAppObl](
	[LaoLedFk]		[fkid] NOT NULL,
	[LaoAppFk]		[fkid] NOT NULL,
	[LaoLapFk]		[fkid] NOT NULL,
	[LaoTyp]		varchar(100) NOT NULL,
	[LaoSrc]		varchar(100) NOT NULL,
	[LaoEMI]		numeric(27,7) NOT NULL,
	[LaoOutstanding]numeric(27,7) NOT NULL,
	[LaoTenure]		tinyint NOT NULL,
	[LaoPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LaoRowId]		[RowId] NOT NULL,
	[LaoCreatedBy]	varchar(100) NOT NULL,
	[LaoCreatedDt]	datetime NOT NULL,
	[LaoModifiedBy] varchar(100) NOT NULL,
	[LaoModifiedDt] datetime NOT NULL,
	[LaoDelFlg]		[DelFlg] NULL,
	[LaoDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LaoPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppObl] ADD  DEFAULT ((0)) FOR [LaoDelId]
GO
ALTER TABLE [dbo].[LosAppObl]  WITH CHECK ADD FOREIGN KEY([LaoLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppObl]  WITH CHECK ADD FOREIGN KEY([LaoAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppObl]  WITH CHECK ADD FOREIGN KEY([LaoLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Type Bike, Car', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppObl', @level2type=N'COLUMN',@level2name=N'LaoTyp'
GO

CREATE TABLE [dbo].[LosAppCreditCrd](
	[LacLedFk]		[fkid] NOT NULL,
	[LacAppFk]		[fkid] NOT NULL,
	[LacLapFk]		[fkid] NOT NULL,
	[LacTyp]		varchar(100) NOT NULL,
	[LacIsuBnk]		varchar(100) NOT NULL,
	[LacLimit]		numeric(27,7) NOT NULL,
	[LacCrdNo]		varchar(50)	NOT NULL,
	[LacPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LacRowId]		[RowId] NOT NULL,
	[LacCreatedBy]	varchar(100) NOT NULL,
	[LacCreatedDt]	datetime NOT NULL,
	[LacModifiedBy] varchar(100) NOT NULL,
	[LacModifiedDt] datetime NOT NULL,
	[LacDelFlg]		[DelFlg] NULL,
	[LacDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LacPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppCreditCrd] ADD  DEFAULT ((0)) FOR [LacDelId]
GO
ALTER TABLE [dbo].[LosAppCreditCrd]  WITH CHECK ADD FOREIGN KEY([LacLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppCreditCrd]  WITH CHECK ADD FOREIGN KEY([LacAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppCreditCrd]  WITH CHECK ADD FOREIGN KEY([LacLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Card Type Master, Visa', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCreditCrd', @level2type=N'COLUMN',@level2name=N'LacTyp'
GO

CREATE TABLE [dbo].[LosAppSalInc](
	[LsiLedFk]		[fkid] NOT NULL,
	[LsiAppFk]		[fkid] NOT NULL,
	[LsiLapFk]		[fkid] NOT NULL,
	[LsiMon]		tinyint	NOT NULL,
	[LsiComp]		varchar(100) NOT NULL,
	[LsiAddLess]	int NOT NULL,
	[LsiVal]		numeric(27,7) NOT NULL,
	[LsiIncExl]		bit NOT NULL,
	[LsiPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LsiRowId]		[RowId] NOT NULL,
	[LsiCreatedBy]	varchar(100) NOT NULL,
	[LsiCreatedDt]	datetime NOT NULL,
	[LsiModifiedBy] varchar(100) NOT NULL,
	[LsiModifiedDt] datetime NOT NULL,
	[LsiDelFlg]		[DelFlg] NULL,
	[LsiDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LsiPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppSalInc] ADD  DEFAULT ((0)) FOR [LsiDelId]
GO
ALTER TABLE [dbo].[LosAppSalInc]  WITH CHECK ADD FOREIGN KEY([LsiLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppSalInc]  WITH CHECK ADD FOREIGN KEY([LsiAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppSalInc]  WITH CHECK ADD FOREIGN KEY([LsiLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Add this value, -1 - deduct this value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppSalInc', @level2type=N'COLUMN',@level2name=N'LsiAddLess'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Consider this income also, 1 - dont consider this income', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppSalInc', @level2type=N'COLUMN',@level2name=N'LsiIncExl'
GO

CREATE TABLE [dbo].[LosAppBusiInc](
	[LbiLedFk]		[fkid] NOT NULL,
	[LbiAppFk]		[fkid] NOT NULL,
	[LbiLapFk]		[fkid] NOT NULL,
	[LbiYr]			tinyint	NOT NULL,
	[LbiComp]		varchar(100) NOT NULL,
	[LbiAddLess]	int NOT NULL,
	[LbiVal]		numeric(27,7) NOT NULL,
	[LbiIncExl]		bit NOT NULL,
	[LbiPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LbiRowId]		[RowId] NOT NULL,
	[LbiCreatedBy]	varchar(100) NOT NULL,
	[LbiCreatedDt]	datetime NOT NULL,
	[LbiModifiedBy] varchar(100) NOT NULL,
	[LbiModifiedDt] datetime NOT NULL,
	[LbiDelFlg]		[DelFlg] NULL,
	[LbiDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LbiPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppBusiInc] ADD  DEFAULT ((0)) FOR [LbiDelId]
GO
ALTER TABLE [dbo].[LosAppBusiInc]  WITH CHECK ADD FOREIGN KEY([LbiLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppBusiInc]  WITH CHECK ADD FOREIGN KEY([LbiAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppBusiInc]  WITH CHECK ADD FOREIGN KEY([LbiLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Add this value, -1 - deduct this value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiInc', @level2type=N'COLUMN',@level2name=N'LbiAddLess'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Consider this income also, 1 - dont consider this income', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiInc', @level2type=N'COLUMN',@level2name=N'LbiIncExl'
GO

CREATE TABLE [dbo].[LosAppBnkBal](
	[LbbLedFk]	[fkid] NOT NULL,
	[LbbAppFk]	[fkid] NOT NULL,
	[LbbLapFk]	[fkid] NOT NULL,
	[LbbBnkNm]	varchar(100)	NOT NULL,
	[LbbMon]	tinyint	NOT NULL,
	[LbbDay]	tinyint NOT NULL,	
	[LbbVal]	numeric(27,7) NOT NULL,
	[LbbPk]		[pkid] IDENTITY(1,1) NOT NULL,
	[LbbRowId] [RowId] NOT NULL,
	[LbbCreatedBy] varchar(100) NOT NULL,
	[LbbCreatedDt] datetime NOT NULL,
	[LbbModifiedBy] varchar(100) NOT NULL,
	[LbbModifiedDt] datetime NOT NULL,
	[LbbDelFlg] [DelFlg] NULL,
	[LbbDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LbbPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppBnkBal] ADD  DEFAULT ((0)) FOR [LbbDelId]
GO
ALTER TABLE [dbo].[LosAppBnkBal]  WITH CHECK ADD FOREIGN KEY([LbbLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppBnkBal]  WITH CHECK ADD FOREIGN KEY([LbbAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppBnkBal]  WITH CHECK ADD FOREIGN KEY([LbbLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk reference of the document', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBnkBal', @level2type=N'COLUMN',@level2name=N'LbbMon'
GO

CREATE TABLE [dbo].[LosApp](
	[AppLedFk] [fkid] NOT NULL,
	[AppAgtNm] varchar(100) NOT NULL,
	[AppBGeoFk] [fkid] NOT NULL,
	[AppPrdFk] [fkid] NOT NULL,
	[AppApplNm] varchar(100) NOT NULL,
	[AadStreet] varchar(100) NOT NULL,
	[AppAppNo] numeric NOT NULL,
	[AppPAppNo] numeric NOT NULL,
	[AppLnPur] varchar(100) NOT NULL,	
	[AppPk] [pkid] IDENTITY(1,1) NOT NULL,
	[AppRowId] [RowId] NOT NULL,
	[AppCreatedBy] varchar(100) NOT NULL,
	[AppCreatedDt] datetime NOT NULL,
	[AppModifiedBy] varchar(100) NOT NULL,
	[AppModifiedDt] datetime NOT NULL,
	[AppDelFlg] [DelFlg] NULL,
	[AppDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[AppPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosApp] ADD  DEFAULT ((0)) FOR [AppDelId]
GO
ALTER TABLE [dbo].[LosApp]  WITH CHECK ADD FOREIGN KEY([AppLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Agent name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppAgtNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch Geo FK reference'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppApplNm'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppAppNo'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppPAppNo'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppLnPur'
GO


CREATE TABLE [dbo].[LosAppProfile](
	[LapLedFk] [fkid] NOT NULL,
	[LapAppFk] [fkid] NOT NULL,
	[LapCusFk] [fkid] NOT NULL,
	[LapActor] varchar(100) NOT NULL,
	[LapPrefNm] varchar(100) NOT NULL,
	[LapFstNm] varchar(100) NOT NULL,
	[LapMdNm] varchar(100) NOT NULL,
	[LapLstNm] varchar(100) NOT NULL,
	[LapGender] varchar(100) NOT NULL,	
	[LapDOB] datetime NOT NULL,	
	[LapRelation] varchar(100) NOT NULL,	
	[LapFatherNm] varchar(100) NOT NULL,	
	[LapMotherNm] varchar(100) NOT NULL,	
	[LapMaritalSts] varchar(100) NOT NULL,	
	[LapNationality] varchar(100) NOT NULL,	
	[LapReligion] varchar(100) NOT NULL,	
	[LapCommunity] varchar(100) NOT NULL,	
	[LapDpdCnt] tinyint NOT NULL,	
	[LapMobile] numeric NOT NULL,	
	[LapResi] numeric NOT NULL,	
	[LapEMail] varchar(100) NOT NULL,				
	[LapPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LapRowId] [RowId] NOT NULL,
	[LapCreatedBy] varchar(100) NOT NULL,
	[LapCreatedDt] datetime NOT NULL,
	[LapModifiedBy] varchar(100) NOT NULL,
	[LapModifiedDt] datetime NOT NULL,
	[LapDelFlg] [DelFlg] NULL,
	[LapDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LapPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppProfile] ADD  DEFAULT ((0)) FOR [LapDelId]
GO
ALTER TABLE [dbo].[LosAppProfile]  WITH CHECK ADD FOREIGN KEY([LapLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppProfile]  WITH CHECK ADD FOREIGN KEY([LapAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppProfile]  WITH CHECK ADD FOREIGN KEY([LapCusFk]) REFERENCES [dbo].[LosCustomer] ([CusPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Fk reference'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapAppFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Fk refernce'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapCusFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actor - Applicant, coapplicant,guarantor,Reference'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prefered name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapPrefNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Middle name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapLstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date od birth'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relation to the applicant- Self , wife '							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapRelation'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapFatherNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mother name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMotherNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Marital status'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMaritalSts'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nationality'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapNationality'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Religion'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapReligion'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Community'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapCommunity'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dependent count'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapDpdCnt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'mobile number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMobile'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Residence number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapResi'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapEMail'

GO


CREATE TABLE [dbo].[LosAppAddress](
	[LaaLedFk] [fkid] NOT NULL,
	[LaaAppFk] [fkid] NOT NULL,
	[LaaLapFk] [fkid] NOT NULL,
	[LaaAddTyp] varchar(100) NOT NULL,
	[LaaComAdd] varchar(100) NOT NULL,
	[LaaAcmTyp] varchar(100) NOT NULL,
	[LaaYrsResi] varchar(100) NOT NULL,
	[LaaDoorNo] varchar(100) NOT NULL,
	[LaaBuilding] varchar(100) NOT NULL,	
	[LaaPlotNo] datetime NOT NULL,	
	[LaaStreet] varchar(100) NOT NULL,	
	[LaaLandmark] varchar(100) NOT NULL,	
	[LaaArea] varchar(100) NOT NULL,	
	[LaaDistrict] varchar(100) NOT NULL,	
	[LaaState] varchar(100) NOT NULL,	
	[LaaCountry] varchar(100) NOT NULL,	
	[LaaPin] varchar(100) NOT NULL,	
	[LaaPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LaaRowId] [RowId] NOT NULL,
	[LaaCreatedBy] varchar(100) NOT NULL,
	[LaaCreatedDt] datetime NOT NULL,
	[LaaModifiedBy] varchar(100) NOT NULL,
	[LaaModifiedDt] datetime NOT NULL,
	[LaaDelFlg] [DelFlg] NULL,
	[LaaDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LaaPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppAddress] ADD  DEFAULT ((0)) FOR [LaaDelId]
GO
ALTER TABLE [dbo].[LosAppAddress]  WITH CHECK ADD FOREIGN KEY([LaaLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppAddress]  WITH CHECK ADD FOREIGN KEY([LaaAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppAddress]  WITH CHECK ADD FOREIGN KEY([LaaLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaLedFk'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaAppFk'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaLapFk'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaAddTyp'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaComAdd'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaAcmTyp'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaYrsResi'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaDoorNo'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaBuilding'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaPlotNo'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaStreet'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaLandmark'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaArea'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaDistrict'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaState'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaCountry'
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LaaPin'

GO 



CREATE TABLE [dbo].[LosProp](
	[PrpSeller]			VARCHAR(250),
    [PrpPrj]            VARCHAR(250),
    [PrpTyp]            TINYINT ,	-- 1 - Residential, 2 - Commercial     
	[PrpPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[PrpRowId]			[RowId]	NOT NULL,
	[PrpCreatedBy]		VARCHAR(100) NOT NULL,
	[PrpCreatedDt]		DATETIME NOT NULL,
	[PrpModifiedBy]		VARCHAR(100) NOT NULL,
	[PrpModifiedDt]		DATETIME NOT NULL,
	[PrpDelFlg]			[DelFlg] NULL,
	[PrpDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[PrpPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosProp] ADD  DEFAULT ((0)) FOR [PrpDelId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Property type -  1 - Residential, 2 - Commercial '								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosProp', @level2type=N'COLUMN',@level2name=N'PrpTyp'
GO


CREATE TABLE [dbo].[LosPropAddress](
	[LpaPrpFk]			[fkid] NOT NULL,
    [LpaLedFk]			[fkid] NOT NULL,
    [LpaAppFk]			[fkid] NOT NULL,
    [LpaDoorNo]			VARCHAR(20),
    [LpaBuilding]		VARCHAR(100),
    [LpaPlotNo]			VARCHAR(20),
    [LpaStreet]			VARCHAR(150),
    [LpaLandmark]		VARCHAR(250),
    [LpaArea]			VARCHAR(150),
    [LpaDistrict]		VARCHAR(100),
    [LpaState]			VARCHAR(100),
    [LpaCountry]		VARCHAR(100),
	[LpaPin]			CHAR(6),
    [LpaPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[LpaRowId]			[RowId]	NOT NULL,
	[LpaCreatedBy]		VARCHAR(100) NOT NULL,
	[LpaCreatedDt]		DATETIME NOT NULL,
	[LpaModifiedBy]		VARCHAR(100) NOT NULL,
	[LpaModifiedDt]		DATETIME NOT NULL,
	[LpaDelFlg]			[DelFlg] NULL,
	[LpaDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LpaPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosPropAddress] ADD  DEFAULT ((0)) FOR [LpaDelId]
GO
ALTER TABLE [dbo].[LosPropAddress]  WITH CHECK ADD FOREIGN KEY([LpaLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosPropAddress]  WITH CHECK ADD FOREIGN KEY([LpaAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO

CREATE TABLE [dbo].[LosNHB](
	[NHBLedFk]			[fkid] NOT NULL,
    [NHBAppFk]			[fkid] NOT NULL,
    [NHBPuccaHouse]     TINYINT ,			--                0 - No, 1 - Yes
	[NHBHosCat]         TINYINT,			--                1 - LIG, 2 - EWS, 3 - MIG, 4 - HIG
    [NHBHosInc]			NUMERIC(10,2),
    [NHBLocCd]          VARCHAR(50),
    [NHBLocNm]          VARCHAR(250),
    [NHBPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[NHBRowId]			[RowId]	NOT NULL,
	[NHBCreatedBy]		VARCHAR(100) NOT NULL,
	[NHBCreatedDt]		DATETIME NOT NULL,
	[NHBModifiedBy]		VARCHAR(100) NOT NULL,
	[NHBModifiedDt]		DATETIME NOT NULL,
	[NHBDelFlg]			[DelFlg] NULL,
	[NHBDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[NHBPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosNHB] ADD  DEFAULT ((0)) FOR [NHBDelId]
GO
ALTER TABLE [dbo].[LosNHB]  WITH CHECK ADD FOREIGN KEY([NHBLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosNHB]  WITH CHECK ADD FOREIGN KEY([NHBAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'NHBPuccaHouse -  0 - No, 1 - Yes'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosNHB', @level2type=N'COLUMN',@level2name=N'NHBPuccaHouse'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'House category 1 - LIG, 2 - EWS, 3 - MIG, 4 - HIG'			, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosNHB', @level2type=N'COLUMN',@level2name=N'NHBHosCat'
GO

CREATE TABLE [dbo].[LosNHBDpd](
	[LndNHBFk]          [fkid] NOT NULL,
    [LndDpdNm]          VARCHAR(250),
    [LndProof]          TINYINT,     --            1 - PanNo, etc
    [LndRefNo]          VARCHAR(50),
    [LndPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[LndRowId]			[RowId]	NOT NULL,
	[LndCreatedBy]		VARCHAR(100) NOT NULL,
	[LndCreatedDt]		DATETIME NOT NULL,
	[LndModifiedBy]		VARCHAR(100) NOT NULL,
	[LndModifiedDt]		DATETIME NOT NULL,
	[LndDelFlg]			[DelFlg] NULL,
	[LndDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LndPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosNHBDpd] ADD  DEFAULT ((0)) FOR [LndDelId]
GO
ALTER TABLE [dbo].[LosNHBDpd]  WITH CHECK ADD FOREIGN KEY([LndNHBFk]) REFERENCES [dbo].[LosNHB] ([NHBPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dependent proof  - 1 - PanNo, etc'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosNHBDpd', @level2type=N'COLUMN',@level2name=N'LndProof'
GO


Create Table LosSanction
(
	LsnLedFk [FkId] NOT NULL,
	LsnBGeoFk [FKID] NOT NULL,
	LsnPrdFk [FKID] NOT NULL,
	LsnAppFk [FKID] NOT NULL,
	LsnSancNo VARCHAR(50) NOT NULL,
	LsnSancDt DATETIME NOT NULL,
	LsnEMIDueDt	TINYINT	NULL,
	LsnEMI NUMERIC(27,7) NULL,
	LsnPk [PKID] IDENTITY(1,1) NOT NULL,
	LsnRowId [RowId] NOT NULL,
	LsnCreatedBy varchar(100) NOT NULL,
	LsnCreatedDt datetime NOT NULL,
	LsnModifiedBy varchar(100) NOT NULL,
	LsnModifiedDt datetime NOT NULL,
	LsnDelFlg [DelFlg] NULL,
	LsnDelId bit NOT NULL,
PRIMARY KEY CLUSTERED 
(
    LsnPk ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].LosSanction  WITH CHECK ADD FOREIGN KEY(LsnLedFk) REFERENCES [dbo].LosLead (LedPk)
GO
ALTER TABLE [dbo].LosSanction  WITH CHECK ADD FOREIGN KEY(LsnBGeoFk) REFERENCES [dbo].GenGeoMas (GeoPK)
GO
ALTER TABLE [dbo].LosSanction  WITH CHECK ADD FOREIGN KEY(LsnPrdFk) REFERENCES [dbo].GenPrdMas (PrdPk)
GO
ALTER TABLE [dbo].LosSanction  WITH CHECK ADD FOREIGN KEY(LsnAppFk) REFERENCES [dbo].LosApp (AppPk)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Lead Id Fk - Reference',		@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch GeoMaster Fk - Reference', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Master Fk - Reference',	@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Fk - Reference',		@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnAppFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Sanction Number',			@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnSancNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Sanction Date',				@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnSancDt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan EMI due days(7 Or 15)',			@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnEMIDueDt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan EMI Amount',						@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSanction', @level2type=N'COLUMN',@level2name=N'LsnEMI'
GO


Create Table LosInsurance
(
	LisLedFk [FKID]	NOT NULL,
	LisBGeoFk [FKID]	NOT NULL,
	LisPrdFk [FKID]	NOT NULL,
	LisAppFk [FKID]	NOT NULL,
	LisLsnFk [FKID]	NOT NULL,
	LisTyp BIT	NOT NULL,
	LisLapFk [FKID]	NOT NULL,
	LisIsurer VARCHAR(250)	NOT NULL,
	LisSumAssured NUMERIC(27,7)	NOT NULL,
	LisPremium NUMERIC(27,7)	NOT NULL,
	LisSinJnt BIT	NULL,
	LisPlcyPrd TINYINT	NULL,
	LisPerAccCvr BIT	NULL,
	LisAddtoLn BIT	NULL,
	LisPk [PKID] IDENTITY(1,1) NOT NULL,	
	LisRowId [RowId] NOT NULL,
	LisCreatedBy varchar(100) NOT NULL,
	LisCreatedDt datetime NOT NULL,
	LisModifiedBy varchar(100) NOT NULL,
	LisModifiedDt datetime NOT NULL,
	LisDelFlg [DelFlg] NULL,
	LisDelId bit NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		LisPk ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].LosInsurance  WITH CHECK ADD FOREIGN KEY(LisLedFk) REFERENCES [dbo].LosLead (LedPk)
GO
ALTER TABLE [dbo].LosInsurance  WITH CHECK ADD FOREIGN KEY(LisBGeoFk) REFERENCES [dbo].GenGeoMas (GeoPK)
GO
ALTER TABLE [dbo].LosInsurance  WITH CHECK ADD FOREIGN KEY(LisPrdFk) REFERENCES [dbo].GenPrdMas (PrdPk)
GO
ALTER TABLE [dbo].LosInsurance  WITH CHECK ADD FOREIGN KEY(LisAppFk) REFERENCES [dbo].LosApp (AppPk)
GO
ALTER TABLE [dbo].LosInsurance  WITH CHECK ADD FOREIGN KEY(LisLsnFk) REFERENCES [dbo].LosSanction (LsnPk)
GO
ALTER TABLE [dbo].LosInsurance  WITH CHECK ADD FOREIGN KEY(LisLapFk) REFERENCES [dbo].LosAppProfile (LapPk)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Lead Id Fk - Reference',									@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch GeoMaster Fk - Reference',								@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Master Fk - Reference',								@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Fk - Reference',									@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisAppFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Sanction No Fk - Reference',								@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisLsnFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Insurance Type ? 0 - General Insurance, 1 - Life Insurance',	@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisTyp'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Profile Fk - Reference',							@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisLapFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Insurance Company Name',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisIsurer'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Insurance Coverage Amount',									@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisSumAssured'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Insurance Premium Amount',									@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisPremium'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Single, 1 - Joint',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisSinJnt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Insurance Policy Period',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisPlcyPrd'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Personal Accident Cover ? 0 - Yes, 1 - No',					@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisPerAccCvr'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Added Insurance to EMI? 0 - Yes, 1 - No',						@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsurance', @level2type=N'COLUMN',@level2name=N'LisAddtoLn'
Go


Create Table LosInsNominee
(
	LinLisFk [FKID] NOT NULL,
	LinNominee VARCHAR(250) NOT NULL,
	LinAge TINYINT NOT NULL,
	LinGender CHAR(1) NOT NULL,
	LinRelation	VARCHAR(100) NOT NULL,
	LinGuardian	VARCHAR(250) NOT NULL,
	LinGuardianRel VARCHAR(100) NOT NULL,
	LinPk [PKID] Identity(1,1) NOT NULL,
	LinRowId [RowId] NOT NULL,
	LinCreatedBy varchar(100) NOT NULL,
	LinCreatedDt datetime NOT NULL,
	LinModifiedBy varchar(100) NOT NULL,
	LinModifiedDt datetime NOT NULL,
	LinDelFlg [DelFlg] NULL,
	LinDelId bit NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		LinPk ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].LosInsNominee  WITH CHECK ADD FOREIGN KEY(LinLisFk) REFERENCES [dbo].LosInsurance (LisPk)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Insurance Fk - Reference',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinLisFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nominee Name',				@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinNominee'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nominee Age',					@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinAge'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nominee Gender',				@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relationship with Nominee',	@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinRelation'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Guardian Name',				@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinGuardian'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relationship with Guardian',	@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosInsNominee', @level2type=N'COLUMN',@level2name=N'LinGuardianRel'
Go



Create Table LosSeller
(
	LslLedFk [FKID]	NOT NULL,
	LslBGeoFk [FKID] NOT NULL,
	LslPrdFk [FKID] NOT NULL,
	LslAppFk [FKID] NOT NULL,
	LslLsnFk [FKID]	NOT NULL,
	LslNm VARCHAR(250) NOT NULL,
	LslTyp CHAR(1) NOT NULL,
	LslDoorNo	varchar(10),
	LslBuilding	varchar(150),
	LslPlotNo	varchar(20),
	LslStreet	varchar(150),
	LslLandmark	varchar(250),
	LslArea	varchar(150),
	LslDistrict	varchar(100),
	LslState	varchar(100),
	LslCountry	varchar(100),
	LslPin	char(6),
	LslPk [PKID] Identity(1,1) Not Null,
	LslRowId [RowId] NOT NULL,
	LslCreatedBy varchar(100) NOT NULL,
	LslCreatedDt datetime NOT NULL,
	LslModifiedBy varchar(100) NOT NULL,
	LslModifiedDt datetime NOT NULL,
	LslDelFlg [DelFlg] NULL,
	LslDelId bit NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		LslPk ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].LosSeller  WITH CHECK ADD FOREIGN KEY(LslLedFk) REFERENCES [dbo].LosLead (LedPk)
GO
ALTER TABLE [dbo].LosSeller  WITH CHECK ADD FOREIGN KEY(LslBGeoFk) REFERENCES [dbo].GenGeoMas (GeoPK)
GO
ALTER TABLE [dbo].LosSeller  WITH CHECK ADD FOREIGN KEY(LslPrdFk) REFERENCES [dbo].GenPrdMas (PrdPk)
GO
ALTER TABLE [dbo].LosSeller  WITH CHECK ADD FOREIGN KEY(LslAppFk) REFERENCES [dbo].LosApp (AppPk)
GO
ALTER TABLE [dbo].LosSeller  WITH CHECK ADD FOREIGN KEY(LslLsnFk) REFERENCES [dbo].LosSanction (LsnPk)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Lead Id Fk - Reference',							@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch GeoMaster Fk - Reference',						@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Master Fk - Reference',						@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Fk - Reference',							@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslAppFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Sanction No Fk - Reference',						@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslLsnFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Name',											@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Type ? B - Builder, S - Seller, C - Customer',	@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslTyp'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Flat / Door Number',							@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslDoorNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Building',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslBuilding'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Plot No',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslPlotNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Street Name',									@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslStreet'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Landmark',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslLandmark'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Area',											@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslArea'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller District',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslDistrict'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller State',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslState'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller Country',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslCountry'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Seller PinCode',										@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosSeller', @level2type=N'COLUMN',@level2name=N'LslPin'
Go

Create Table LosAppCheque
(
	LcqLsnFk [FKID] NOT NULL,
	LcqPayMode CHAR(1) NOT NULL,
	LcqLbkFk [FKID] NOT NULL,
	LcqChqCnt TINYINT NOT NULL,
	LcqPk [PKID] Identity(1,1) Not Null,
	LcqRowId [RowId] NOT NULL,
	LcqCreatedBy varchar(100) NOT NULL,
	LcqCreatedDt datetime NOT NULL,
	LcqModifiedBy varchar(100) NOT NULL,
	LcqModifiedDt datetime NOT NULL,
	LcqDelFlg [DelFlg] NULL,
	LcqDelId bit NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		LcqPk ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].LosAppCheque  WITH CHECK ADD FOREIGN KEY(LcqLsnFk) REFERENCES [dbo].LosSanction (LsnPk)
GO
ALTER TABLE [dbo].LosAppCheque  WITH CHECK ADD FOREIGN KEY(LcqLbkFk) REFERENCES [dbo].LosAppBank (LbkPk)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Sanction No Fk - Reference',		@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCheque', @level2type=N'COLUMN',@level2name=N'LcqLsnFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pay Mode? P - PDC, E - ECS, N - NACH',@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCheque', @level2type=N'COLUMN',@level2name=N'LcqPayMode'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Bank Fk - Reference ',		@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCheque', @level2type=N'COLUMN',@level2name=N'LcqLbkFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of Cheque Count ',				@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCheque', @level2type=N'COLUMN',@level2name=N'LcqChqCnt'
Go


Create Table LosPayDtls
(
	LpdLsnFk [FKID] NOT NULL,
	LpdPayTo CHAR(1) NOT NULL,
	LpdInsTyp CHAR(1) NOT NULL,
	LpdAmt NUMERIC(27,7) NOT NULL,
	LpdInFav VARCHAR(100) NOT NULL,
	LpdPk [PKID] Identity(1,1) Not Null,	
	LpdRowId [RowId] NOT NULL,
	LpdCreatedBy varchar(100) NOT NULL,
	LpdCreatedDt datetime NOT NULL,
	LpdModifiedBy varchar(100) NOT NULL,
	LpdModifiedDt datetime NOT NULL,
	LpdDelFlg [DelFlg] NULL,
	LpdDelId bit NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		LpdPk ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].LosPayDtls  WITH CHECK ADD FOREIGN KEY(LpdLsnFk) REFERENCES [dbo].LosSanction (LsnPk)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Sanction No Fk - Reference', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosPayDtls', @level2type=N'COLUMN',@level2name=N'LpdLsnFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Paid To? G - General Insurer, L - Life Insurer, S - Seller, B - Builder', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosPayDtls', @level2type=N'COLUMN',@level2name=N'LpdPayTo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Instrument Type? C - Cheque, D - DD, N - NEFT, R - RTGS', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosPayDtls', @level2type=N'COLUMN',@level2name=N'LpdInsTyp'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Paid Loan Amount', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosPayDtls', @level2type=N'COLUMN',@level2name=N'LpdAmt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'In Favour to Insurer/Seller/Builder', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosPayDtls', @level2type=N'COLUMN',@level2name=N'LpdInFav'
Go     