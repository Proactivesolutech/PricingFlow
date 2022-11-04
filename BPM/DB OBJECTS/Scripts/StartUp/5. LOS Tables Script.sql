CREATE TABLE [dbo].[LosLead](
	[LedId] varchar(50) NOT NULL,
	[LedAgtFk] FkId NOT NULL,
	[LedBGeoFk] [fkid] NOT NULL,
	[LedNm] varchar(100) NOT NULL,
	[LedDOB] datetime NOT NULL,
	[LedPrdFk] [fkid] NOT NULL,
	[LedEmpCat] INT NOT NULL,
	[LedMrktVal] numeric(27,7) NOT NULL,
	[LedPrvLnCrd] bit NOT NULL,
	[LedLnAmt] numeric(27,7) NOT NULL,
	[LedTenure] int NOT NULL,
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
ALTER TABLE [dbo].[LosLead]  WITH CHECK ADD FOREIGN KEY([LedAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosLead]  WITH CHECK ADD FOREIGN KEY([LedBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosLead]  WITH CHECK ADD FOREIGN KEY([LedPrdFk]) REFERENCES [dbo].[GenPrdMas] ([PrdPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LOS Lead Id'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedId'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch GeoMaster Fk - Reference'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Name'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Date of Birth'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employment category 0 - Public, 1 - Private'		, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosLead', @level2type=N'COLUMN',@level2name=N'LedEmpCat'
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
	[DocAgtFk] FkId NOT NULL,
	[DocBGeoFk] [fkid] NOT NULL,
	[DocPrdFk] [fkid] NOT NULL,
	[DocActor] tinyint NOT NULL,
	[DocSubActor] TINYINT NOT NULL,
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
ALTER TABLE [dbo].[LosDocument]  WITH CHECK ADD FOREIGN KEY([DocAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosDocument]  WITH CHECK ADD FOREIGN KEY([DocBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosDocument]  WITH CHECK ADD FOREIGN KEY([DocPrdFk]) REFERENCES [dbo].[GenPrdMas] ([PrdPk])
GO
ALTER TABLE [dbo].[LosDocument] ADD  DEFAULT ((0)) FOR [DocDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk reference of the document'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch Fk refernce'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk Reference'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document Actor( 0 - Applicant, 1 - CoApplicant)'			, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document category(KYC, Property, INC)'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocCat'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document subcategory( Addres Proof, Id Proof )'			, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocSubCat'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the document( ex: Voter Id)'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Saved documents physical path', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDocument', @level2type=N'COLUMN',@level2name=N'DocPath'
GO

CREATE TABLE [dbo].[LosQDE](
	[QDELedFk]			[fkid] NOT NULL,
	[QDEBGeoFk]			[fkid] NOT NULL,
	[QDEPrdFk]			[fkid] NOT NULL,
	[QDEActor]			tinyint NOT NULL,
	[QDESubActor]		TINYINT NOT NULL,
	[QDEFstNm]			varchar(100) NOT NULL,
	[QDEMdNm]			varchar(100) NOT NULL,
	[QDELstNm]			varchar(100) NOT NULL,
	[QDEFthFstNm]	varchar(100) NOT NULL,
	[QDEFthMdNm]		varchar(100) NOT NULL,
	[QDEFthLstNm]	varchar(100) NOT NULL,
	[QDEGender]			INT NOT NULL,
	[QDEDOB]			datetime NOT NULL,
	[QDEContact]		varchar(50)	 NOT NULL,
	[QDEEmail]			varchar(100) NOT NULL,
	[QDEAadhar]			varchar(20) NOT NULL,
	[QDEPAN]			varchar(20) NOT NULL,
	[QDEDrvLic]			varchar(20) NOT NULL,
	[QDEVoterId]		varchar(20) NOT NULL,
	[QDECusFk]			[FkId] NULL,
	[QDeCibil]			SMALLINT,
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
ALTER TABLE [dbo].[LosQDE]  WITH CHECK ADD FOREIGN KEY([QDEBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosQDE]  WITH CHECK ADD FOREIGN KEY([QDEPrdFk]) REFERENCES [dbo].[GenPrdMas] ([PrdPk])
GO
ALTER TABLE [dbo].[LosQDE]  WITH CHECK ADD FOREIGN KEY([QDECusFk]) REFERENCES [dbo].[Loscustomer] ([CusPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk reference'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDELedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch Geo Fk reference'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk reference'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actor 0 - Applicant, 1 - CoApplicant, 2 - Guarantor', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Middle Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDELstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father First Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEFthFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father Middle Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEFthMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father Last Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEFthLstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender 0 - Male, 1 - Female'				, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of birth '							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact Number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEContact'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email ID'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEEmail'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Aadhar Number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEAadhar'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PAN number '								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEPAN'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Driving License Number'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEDrvLic'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voter Id'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDE', @level2type=N'COLUMN',@level2name=N'QDEVoterId'
GO

CREATE TABLE [dbo].[LosQDEAddress](
	[QDAQDEFK]			[fkid] NOT NULL,
	[QDAAddTyp]			INT NOT NULL,
	[QDADoorNo]			varchar(10) NOT NULL,
	[QDABuilding]		varchar(150) NOT NULL,
	[QDAPlotNo]			varchar(20) NOT NULL,
	[QDAStreet]			varchar(150) NOT NULL,
	[QDALandmark]		varchar(250) NOT NULL,
	[QDAArea]			varchar(150) NOT NULL,
	[QDADistrict]		varchar(100) NOT NULL,
	[QDAState]			varchar(100) NOT NULL,
	[QDACountry]		varchar(100) NOT NULL,
	[QDAPin]			char(6) NOT NULL,
	[QDAPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[QDARowId]			[RowId] NOT NULL,
	[QDACreatedBy]		varchar(100) NOT NULL,
	[QDACreatedDt]		datetime NOT NULL,
	[QDAModifiedBy]		varchar(100) NOT NULL,
	[QDAModifiedDt]		datetime NOT NULL,
	[QDADelFlg]			[DelFlg] NULL,
	[QDADelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QDAPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosQDEAddress] ADD  DEFAULT ((0)) FOR [QDADelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type of Address ( 0 - Present, 1 - Permanent, 2 - Official, 3 - Business ) ', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDAAddTyp'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Door Number'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDADoorNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Building name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDABuilding'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Plot number'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDAPlotNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Street name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDAStreet'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Land mark'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDALandmark'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Area'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDAArea'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'District '								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDADistrict'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDAState'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDACountry'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PIN Code'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosQDEAddress', @level2type=N'COLUMN',@level2name=N'QDAPin'
GO

CREATE TABLE [dbo].[LosAadhar](
	[AadLedFk] [fkid] NOT NULL,
	[AadNo] varchar(20) NOT NULL,
	[AadDoorNo] varchar(10) NOT NULL,
	[AadBuilding] varchar(150) NOT NULL,
	[AadPlotNo] varchar(20) NOT NULL,
	[AadStreet] varchar(150) NOT NULL,
	[AadLandmark] varchar(250) NOT NULL,
	[AadArea] varchar(150) NOT NULL,
	[AadDistrict] varchar(100) NOT NULL,
	[AadState] varchar(100) NOT NULL,
	[AadCountry] varchar(100) NOT NULL,
	[AadPin] char(6) NOT NULL,
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PIN code'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAadhar', @level2type=N'COLUMN',@level2name=N'AadPin'
GO

CREATE TABLE [dbo].[LosCustomer](
	[CusFstNm] varchar(100) NOT NULL,
	[CusMdNm] varchar(100) NOT NULL,
	[CusLstNm] varchar(100) NOT NULL,
	[CusFthFstNm] varchar(100) NOT NULL,
	[CusFthMdNm] varchar(100) NOT NULL,
	[CusFthLstNm] varchar(100) NOT NULL,
	[CusGender] INT NOT NULL,
	[CusDOB] datetime NOT NULL,
	[CusContact] varchar(50) NOT NULL,
	[CusEmail] varchar(100) NOT NULL,
	[CusAadhar] varchar(20) NOT NULL,
	[CusPAN] varchar(20) NOT NULL,
	[CusDrvLic] varchar(20) NOT NULL,
	[CusPrdFk]	[fkid] NOT NULL,
	[CusVoterId] varchar(20) NOT NULL,	
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
ALTER TABLE [dbo].[LosCustomer]  WITH CHECK ADD FOREIGN KEY([CusPrdFk]) REFERENCES [dbo].[GenPrdMas] ([PrdPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer First name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer middle name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer last name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusLstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Father First Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusFthFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Father Middle Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusFthMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Customer Father Last Name'								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusFthLstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender ( 0 - Male, 1 - Female )'					, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of birth'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact number'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusContact'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email ID'											, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusEmail'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Aadhar Number'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusAadhar'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PAN number'										, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusPAN'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Driving License'									, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosCustomer', @level2type=N'COLUMN',@level2name=N'CusDrvLic'
GO

CREATE TABLE [dbo].[LosCustomerAddress](
	[CadCusFk] [fkid] NOT NULL,
	[CadDoorNo] varchar(10) NOT NULL,
	[CadBuilding] varchar(150) NOT NULL,
	[CadPlotNo] varchar(20) NOT NULL,
	[CadStreet] varchar(150) NOT NULL,
	[CadLandmark] varchar(250) NOT NULL,
	[CadArea] varchar(150) NOT NULL,
	[CadDistrict] varchar(100) NOT NULL,
	[CadState] varchar(100) NOT NULL,
	[CadCountry] varchar(100) NOT NULL,	
	[CadPin] char(6) NOT NULL,	
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

CREATE TABLE [dbo].[LosApp](
	[AppLedFk] [fkid] NOT NULL,
	[AppAgtFk] FkId NOT NULL,
	[AppBGeoFk] [fkid] NOT NULL,
	[AppPrdFk] [fkid] NOT NULL,
	[AppApplNm] varchar(100) NOT NULL,
	[AppAppNo] varchar(50) NOT NULL,
	[AppPAppNo] varchar(50) NOT NULL,
	[AppLnPur] INT NOT NULL,	
	[AppBuiLoc] VARCHAR(100) NOT NULL,
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
ALTER TABLE [dbo].[LosApp]  WITH CHECK ADD FOREIGN KEY([AppAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosApp]  WITH CHECK ADD FOREIGN KEY([AppLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lead Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppLedFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch Geo FK reference'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppBGeoFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product Fk refenece'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppPrdFk'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosApp', @level2type=N'COLUMN',@level2name=N'AppApplNm'
GO

CREATE TABLE [dbo].[LosAppProfile](
	[LapLedFk] [fkid] NOT NULL,
	[LapAppFk] [fkid] NOT NULL,
	[LapCusFk] [fkid] NOT NULL,
	[LapActor] tinyint NOT NULL,
	[LapTitle] INT NOT NULL,	
	[LapPrefNm] varchar(250) NOT NULL,
	[LapFstNm] varchar(100) NOT NULL,
	[LapMdNm] varchar(100) NOT NULL,
	[LapLstNm] varchar(100) NOT NULL,
	[LapGender] INT NOT NULL,	
	[LapDOB] datetime NOT NULL,	
	[LapRelation]  VARCHAR(50) NOT NULL,
	[LapFatherFNm] varchar(100) NOT NULL,
	[LapFatherMNm] varchar(100) NOT NULL,
	[LapFatherLNm] varchar(100) NOT NULL,	
	[LapMotherFNm] varchar(100) NOT NULL,
	[LapMotherMNm] varchar(100) NOT NULL,
	[LapMotherLNm] varchar(100) NOT NULL,	
	[LapMaritalSts] INT NOT NULL,	
	[LapNationality] varchar(50) NOT NULL,	
	[LapReligion] varchar(50) NOT NULL,	
	[LapCommunity] INT NOT NULL,	
	[LapEducation] INT NOT NULL,	
	[LapInsorUniv]  varchar(100),	
	[LapDpdCnt] tinyint NOT NULL,
	[LapMobile] varchar(50) NOT NULL,	
	[LapResi] varchar(50) NOT NULL,	
	[LapEMail] varchar(100) NOT NULL,	
	[LapAadhar]		varchar(20) NOT NULL,
	[LapPAN]		varchar(20) NOT NULL,
	[LapDrvLic]		varchar(20) NOT NULL,
	[LapVotId]		varchar(20) NOT NULL,
	[LapPassport]	varchar(20) NOT NULL,	
	[LapEmpTyp]		INT NOT NULL,	
	[LapCibil]		SMALLINT NOT NULL,
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actor 0 - Applicant, 1 - coapplicant,2 - guarantor'				, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Title 0-Ms, 1-Mr, 2-Mrs'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapTitle'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prefered name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapPrefNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapFstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Middle name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMdNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapLstNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Gender 0 - Male, 1- Female'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapGender'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date od birth'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapDOB'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relation to the applicant 0 - Self, 1 - Spouse, 2 - Father, 3 - Mother, 4 - Childern, 5 - Friend'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapRelation'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father/Husband First name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapFatherFNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father/Husband Middle name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapFatherMNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Father/Husband Last name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapFatherLNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mother First name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMotherFNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mother Middle name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMotherMNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mother Last name'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMotherLNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Marital status ( 0 - Married, 1- Single, 2 - Divorce, 3 - Widower', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMaritalSts'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nationality'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapNationality'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Religion'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapReligion'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Community 0 - OBC, 1 - SC, 2 - ST, 3 - MBC, 4 - General, 5 - Others' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapCommunity'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Education 0 - Matriculate, 1 - Undergraduate, 2 - Graduate, 3 - Post graduate, 4 - Others' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapEducation'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'University/Institute Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapInsorUniv'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dependent count'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapDpdCnt'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'mobile number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapMobile'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Residence number'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapResi'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapEMail'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee Type 0-Salaried, 1- Self Employed, 2- House Wife, 3 - Pensioner, 4 - Student'							, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppProfile', @level2type=N'COLUMN',@level2name=N'LapEmpTyp'
GO

CREATE TABLE [dbo].[LosAppAddress](
	[LaaLedFk] [fkid] NOT NULL,
	[LaaAppFk] [fkid] NOT NULL,
	[LaaLapFk] [fkid] NOT NULL,
	[LaaAddTyp] INT NOT NULL,
	[LaaComAdd] INT NOT NULL,
	[LaaAcmTyp] INT NOT NULL,
	[LaaYrsResi] tinyint NOT NULL,
	[LaaDoorNo] varchar(20) NOT NULL,
	[LaaBuilding] varchar(100) NOT NULL,	
	[LaaPlotNo] varchar(20) NOT NULL,	
	[LaaStreet] varchar(150) NOT NULL,	
	[LaaLandmark] varchar(250) NOT NULL,	
	[LaaArea] varchar(150) NOT NULL,	
	[LaaDistrict] varchar(100) NOT NULL,	
	[LaaState] varchar(100) NOT NULL,	
	[LaaCountry] varchar(100) NOT NULL,	
	[LaaPin] char(6) NOT NULL,	
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type of Address ( 0 - Present, 1 - Permanent, 2 - Official, 3 - Business, 4 - Lead Reference ) ', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaAddTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Communication Address ( 0 - No, 1 - Yes ) ', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaComAdd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Accomodation Type ( 0 - Rental, 1 - Parental, 2 - Paying Guest, 3 - Self-Owned, 4 - Employer Provided', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAddress', @level2type=N'COLUMN',@level2name=N'LaaAcmTyp'
GO

CREATE TABLE [dbo].[LosAppOffProfile](
	[LaeLedFk]		[fkid] NOT NULL,
	[LaeAppFk]		[fkid] NOT NULL,
	[LaeLapFk]		[fkid] NOT NULL,
	[LaeNm]			varchar(100) NOT NULL,	
	[LaeTyp]		INT NOT NULL,
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
ALTER TABLE [dbo].[LosAppOffProfile] ADD  DEFAULT ((0)) FOR [LaeDelId]
GO
ALTER TABLE [dbo].[LosAppOffProfile]  WITH CHECK ADD FOREIGN KEY([LaeLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppOffProfile]  WITH CHECK ADD FOREIGN KEY([LaeAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppOffProfile]  WITH CHECK ADD FOREIGN KEY([LaeLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type of Organization ( 0 - Public, 1 - Private, 2 - State, 3 - Central, 4 - Semi Government)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppOffProfile', @level2type=N'COLUMN',@level2name=N'LaeTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nature of the Employer', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppOffProfile', @level2type=N'COLUMN',@level2name=N'LaeNat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the Organization', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppOffProfile', @level2type=N'COLUMN',@level2name=N'LaeNm'
GO

CREATE TABLE [dbo].[LosAppBusiProfile](
	[LabLedFk]		[fkid] NOT NULL,
	[LabAppFk]		[fkid] NOT NULL,
	[LabLapFk]		[fkid] NOT NULL,
	[LabBusiTyp]	INT NOT NULL,	
	[LabOrgTyp]		INT NOT NULL,
	[LabNm]			varchar(100) NOT NULL,
	[LabNat]		varchar(100) NOT NULL,
	[LabOwnShip]	INT NOT NULL,
	[LabIncYr]		int	NOT NULL,
	[LabBusiPrd]	tinyint	NOT NULL,
	[LabCIN]		varchar(20) NOT NULL,
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type of Business ( 0 - Professional, 1 - NonProfessional )', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiProfile', @level2type=N'COLUMN',@level2name=N'LabBusiTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type of Organizaiton ( 0 - Public, 1 - Private, 2 - State, 3 - Central, 4 - Semi Government)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiProfile', @level2type=N'COLUMN',@level2name=N'LabOrgTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Business Ownership ( 0 - Partnership, 1 - Sole Proprietorship)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiProfile', @level2type=N'COLUMN',@level2name=N'LabOwnShip'
GO

CREATE TABLE [dbo].[LosAppBank](
	[LbkLedFk]		[fkid] NOT NULL,
	[LbkAppFk]		[fkid] NOT NULL,
	[LbkLapFk]		[fkid] NOT NULL,
	[LbkNm]			varchar(100) NOT NULL,
	[LbkAccTyp]		INT NOT NULL,
	[LbkAccNo]		varchar(100) NOT NULL,
	[LbkBank]		varchar(100) NOT NULL,
	[LbkBranch]		varchar(100) NOT NULL,
	[LbkIFSC]		varchar(50) NOT NULL,
	[LbkBnkTran]	INT NULL,
	[LbkAvgBkBal]	NUMERIC(27,7),
	[LbkInChqBnc]	INT NULL,
	[LbkNotes]		VARCHAR(250),
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bank A/C Type ( 0 - Savings, 1 - Current, 2 - Fixed Deposit)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBank', @level2type=N'COLUMN',@level2name=N'LbkAccTyp'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bank Last Transaction ( 0 - <6, 1 - 6-18, 3 - >18)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBank', @level2type=N'COLUMN',@level2name=N'LbkBnkTran'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inward Cheque Bounce ( 0 - 0, 1 - <3, 3 - >=3)', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBank', @level2type=N'COLUMN',@level2name=N'LbkInChqBnc'
GO

CREATE TABLE [dbo].[LosAppAst](
	[LasLedFk]		[fkid] NOT NULL,
	[LasAppFk]		[fkid] NOT NULL,
	[LasLapFk]		[fkid] NOT NULL,
	[LasTyp]		INT NOT NULL,
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asset Type 0 - Bank Saving, 1 - Immovable property, 2 - Shares and securities, 3 - Insurance/ sum Assured, 4 - PF/PPF Balance, 5 - Fixed Deposits', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppAst', @level2type=N'COLUMN',@level2name=N'LasTyp'
GO


CREATE TABLE [dbo].[LosAppObl](
	[LaoLedFk]		[fkid] NOT NULL,
	[LaoAppFk]		[fkid] NOT NULL,
	[LaoLapFk]		[fkid] NOT NULL,
	[LoaIsIncl]		TINYINT NOT NULL,
	[LaoTyp]		INT NOT NULL,
	[LaoIsShri]		TINYINT NOT NULL,
	[LaoSrc]		varchar(100) NOT NULL,
	[LaoRefNo]		VARCHAR(100) NOT NULL,
	[LaoEMI]		numeric(27,7) NOT NULL,
	[LaoOutstanding]numeric(27,7) NOT NULL,
	[LaoTenure]		int NOT NULL,
	[LaoNotes]		VARCHAR(250) NULL,
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Type 0 - Bike, 1 - Car, 2 - Two Wheeler, 3 - Home, 4 - LAP', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppObl', @level2type=N'COLUMN',@level2name=N'LaoTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Taken at Shriram 0 - No, 1 - Yes', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppObl', @level2type=N'COLUMN',@level2name=N'LaoIsShri'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Included or Not 0 - Yes, 1 - No', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppObl', @level2type=N'COLUMN',@level2name=N'LoaIsIncl'
GO

CREATE TABLE [dbo].[LosAppCreditCrd](
	[LacLedFk]		[fkid] NOT NULL,
	[LacAppFk]		[fkid] NOT NULL,
	[LacLapFk]		[fkid] NOT NULL,
	[LacTyp]		INT NOT NULL,
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Card Type 0 - Master, 1 - Visa, 2 - Amex', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCreditCrd', @level2type=N'COLUMN',@level2name=N'LacTyp'
GO

CREATE TABLE [dbo].[LosComp](
	[LcmTyp]			INT	NOT NULL,
	[LcmNm]				varchar(100) NOT NULL,
	[LcmAddLess]		int NOT NULL,
	[LcmIsTot]			bit	NOT NULL,
	[LcmSeq]			INT NOT NULL,
	[LcmPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[LcmRowId]			[RowId] NOT NULL,
	[LcmCreatedBy]		varchar(100) NOT NULL,
	[LcmCreatedDt]		datetime NOT NULL,
	[LcmModifiedBy]		varchar(100) NOT NULL,
	[LcmModifiedDt]		datetime NOT NULL,
	[LcmDelFlg]			[DelFlg] NULL,
	[LcmDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LcmPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosComp] ADD  DEFAULT ((0)) FOR [LcmDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LcmTyp 0 - Salaried, 1 - Business, 2 - Cash', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosComp', @level2type=N'COLUMN',@level2name=N'LcmTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Add this value, -1 - deduct this value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosComp', @level2type=N'COLUMN',@level2name=N'LcmAddLess'

CREATE TABLE [dbo].[LosAppSalInc](
	[LsiLedFk]		[fkid] NOT NULL,
	[LsiAppFk]		[fkid] NOT NULL,
	[LsiLapFk]		[fkid] NOT NULL,
	[LsiMon]		INT	NOT NULL,
	[LsiLcmFk]		[fkid] NOT NULL,
	[LsiAddLess]	int NOT NULL,
	[LsiVal]		numeric(27,7) NOT NULL,
	[LsiIncExl]		bit NOT NULL, 
	/*[LsiMOP]		tinyint	NOT NULL,-- TBD
	[LsiNotes]		VARCHAR(250), -- TBD */
	[LsiIncNm]		VARCHAR(50) NOT NULL,
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
ALTER TABLE [dbo].[LosAppSalInc]  WITH CHECK ADD FOREIGN KEY([LsiLcmFk]) REFERENCES [dbo].[LosComp] ([LcmPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Add this value, -1 - deduct this value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppSalInc', @level2type=N'COLUMN',@level2name=N'LsiAddLess'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Consider this income also, 1 - dont consider this income', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppSalInc', @level2type=N'COLUMN',@level2name=N'LsiIncExl'
GO

CREATE TABLE [dbo].[LosAppBusiInc](
	[LbiLedFk]		[fkid] NOT NULL,
	[LbiAppFk]		[fkid] NOT NULL,
	[LbiLapFk]		[fkid] NOT NULL,
	[LbiYr]			VARCHAR(25)	NOT NULL,
	[LbiLcmFk]		[fkid] NOT NULL,	
	[LbiAddLess]	int NOT NULL,
	[LbiVal]		numeric(27,7) NOT NULL,
	[LbiIncExl]		bit NOT NULL,
	/* [LbiNotes]		VARCHAR(250), -- TBD */
	[LbiIncNm]		VARCHAR(50) NOT NULL,
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
ALTER TABLE [dbo].[LosAppBusiInc]  WITH CHECK ADD FOREIGN KEY([LbiLcmFk]) REFERENCES [dbo].[LosComp] ([LcmPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Add this value, -1 - deduct this value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiInc', @level2type=N'COLUMN',@level2name=N'LbiAddLess'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Consider this income also, 1 - dont consider this income', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppBusiInc', @level2type=N'COLUMN',@level2name=N'LbiIncExl'
GO

CREATE TABLE [dbo].[LosAppCshInc](
	[LciLedFk]		[fkid] NOT NULL,
	[LciAppFk]		[fkid] NOT NULL,
	[LciLapFk]		[fkid] NOT NULL,
	[LciYr]			VARCHAR(25) NOT NULL,
	[LciLcmFk]		[fkid] NOT NULL,	
	[LciAddLess]	int NOT NULL,
	[LciVal]		numeric(27,7) NOT NULL,
	-- TBD (Notes)
	[LciIncExl]		bit NOT NULL,
	[LciPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LciRowId]		[RowId] NOT NULL,
	[LciCreatedBy]	varchar(100) NOT NULL,
	[LciCreatedDt]	datetime NOT NULL,
	[LciModifiedBy] varchar(100) NOT NULL,
	[LciModifiedDt] datetime NOT NULL,
	[LciDelFlg]		[DelFlg] NULL,
	[LciDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LciPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppCshInc] ADD  DEFAULT ((0)) FOR [LciDelId]
GO
ALTER TABLE [dbo].[LosAppCshInc]  WITH CHECK ADD FOREIGN KEY([LciLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppCshInc]  WITH CHECK ADD FOREIGN KEY([LciAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppCshInc]  WITH CHECK ADD FOREIGN KEY([LciLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
ALTER TABLE [dbo].[LosAppCshInc]  WITH CHECK ADD FOREIGN KEY([LciLcmFk]) REFERENCES [dbo].[LosComp] ([LcmPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Add this value, -1 - deduct this value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCshInc', @level2type=N'COLUMN',@level2name=N'LciAddLess'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Consider this income also, 1 - dont consider this income', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppCshInc', @level2type=N'COLUMN',@level2name=N'LciIncExl'
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
CREATE TABLE [dbo].[LosAppRef](
	[LarLedFk]		[fkid] NOT NULL,
	[LarAppFk]		[fkid] NOT NULL,
	[LarLaaFk]		[fkid] NOT NULL,
	[LarNm]			varchar(100)	NOT NULL,
	[LarRel]		VARCHAR(50) NOT NULL,
	[LarOccup]		varchar(100)	NOT NULL,
	[LarOffNo]		varchar(50)		NULL,
	[LarResNo]		varchar(50)		NULL,
	[LarEMail]		varchar(100)	NULL,
	[LarPk]			[pkid] IDENTITY(1,1) NOT NULL,
	[LarRowId]		[RowId] NOT NULL,
	[LarCreatedBy]	varchar(100) NOT NULL,
	[LarCreatedDt]	datetime NOT NULL,
	[LarModifiedBy] varchar(100) NOT NULL,
	[LarModifiedDt] datetime NOT NULL,
	[LarDelFlg]		[DelFlg] NULL,
	[LarDelId]		[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LarPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppRef] ADD  DEFAULT ((0)) FOR [LarDelId]
GO
ALTER TABLE [dbo].[LosAppRef] WITH CHECK ADD FOREIGN KEY([LarLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppRef] WITH CHECK ADD FOREIGN KEY([LarAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppRef] WITH CHECK ADD FOREIGN KEY([LarLaaFk]) REFERENCES [dbo].[LosAppAddress] ([LaaPk])
GO

CREATE TABLE [dbo].[LosAppOblAct](
	[LoaLedFk] [dbo].[FkId] NOT NULL,
	[LoaAppFk] [dbo].[FkId] NOT NULL,
	[LoaLapFk] [dbo].[FkId] NOT NULL,
	[LoaTyp] [INT] NOT NULL,
	[LoaSrc] [varchar](100) NOT NULL,
	[LoaEMI] [numeric](27, 7) NOT NULL,
	[LoaOutstanding] [numeric](27, 7) NOT NULL,
	[LoaTenure] [int] NOT NULL,
	[LoaIncExl] BIT NOT NULL,
	[LoaIssvs]	BIT NOT NULL,
	[LoaRefNo]	VARCHAR(100),
	/*[LoaNotes]	VARCHAR(250), -- TBD*/
	[LoaPk] [dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[LoaRowId] [dbo].[RowId] NOT NULL,
	[LoaCreatedBy] [varchar](100) NOT NULL,
	[LoaCreatedDt] [datetime] NOT NULL,
	[LoaModifiedBy] [varchar](100) NOT NULL,
	[LoaModifiedDt] [datetime] NOT NULL,
	[LoaDelFlg] [dbo].[DelFlg] NULL,
	[LoaDelId] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LoaPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LosAppOblAct] ADD  DEFAULT ((0)) FOR [LoaDelId]
GO

ALTER TABLE [dbo].[LosAppOblAct]  WITH CHECK ADD FOREIGN KEY([LoaAppFk])
REFERENCES [dbo].[LosApp] ([AppPk])
GO

ALTER TABLE [dbo].[LosAppOblAct]  WITH CHECK ADD FOREIGN KEY([LoaLapFk])
REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO

ALTER TABLE [dbo].[LosAppOblAct]  WITH CHECK ADD FOREIGN KEY([LoaLedFk])
REFERENCES [dbo].[LosLead] ([LedPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Loan Type 0 - Bike, 1 - Car, 2 - Two Wheeler, 3 - Home, 4 - LAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppOblAct', @level2type=N'COLUMN',@level2name=N'LoaTyp'
GO

CREATE TABLE [dbo].[LosAppOthInc](
	[LoiLedFk]		[fkid] NOT NULL,
	[LoiAppFk]		[fkid] NOT NULL,
	[LoiLapFk]		[fkid] NOT NULL,
	/*[LoiNotes]		[VARCHAR](250), -- TBD*/ 
	[LoiDesc]		[VARCHAR](250),
	[LoiPeriod]		[INT] NOT NULL,
	[LoiAmt]		[numeric](27, 7) NOT NULL,
	[LoiPk]			[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[LoiRowId]		[dbo].[RowId] NOT NULL,
	[LoiCreatedBy]	[varchar](100) NOT NULL,
	[LoiCreatedDt]	[datetime] NOT NULL,
	[LoiModifiedBy] [varchar](100) NOT NULL,
	[LoiModifiedDt] [datetime] NOT NULL,
	[LoiDelFlg]		[dbo].[DelFlg] NULL,
	[LoiDelId]		[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LoiPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LosAppOthInc] ADD  DEFAULT ((0)) FOR [LoiDelId]
GO

ALTER TABLE [dbo].[LosAppOthInc]  WITH CHECK ADD FOREIGN KEY([LoiAppFk])
REFERENCES [dbo].[LosApp] ([AppPk])
GO

ALTER TABLE [dbo].[LosAppOthInc]  WITH CHECK ADD FOREIGN KEY([LoiLapFk])
REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO

ALTER TABLE [dbo].[LosAppOthInc]  WITH CHECK ADD FOREIGN KEY([LoiLedFk])
REFERENCES [dbo].[LosLead] ([LedPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Period 0 - Monthly, 1 - Yearly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppOthInc', @level2type=N'COLUMN',@level2name=N'LoiPeriod'
GO


CREATE TABLE [dbo].[LosAppLegalHier](
	[LlhLedFk]		[fkid] NOT NULL,
	[LlhAppFk]		[fkid] NOT NULL,
	[LlhNm]			VARCHAR(100) NOT NULL,
	[LlhRelation]	VARCHAR(50) NOT NULL,
	[LlhAge]		INT NOT NULL,
	[LlhIsEmpl]		INT NOT NULL,
	[LlhMarSts]		INT NOT NULL,
	[LlhPk]			[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[LlhRowId]		[dbo].[RowId] NOT NULL,
	[LlhCreatedBy]	[varchar](100) NOT NULL,
	[LlhCreatedDt]	[datetime] NOT NULL,
	[LlhModifiedBy] [varchar](100) NOT NULL,
	[LlhModifiedDt] [datetime] NOT NULL,
	[LlhDelFlg]		[dbo].[DelFlg] NULL,
	[LlhDelId]		[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LlhPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LosAppLegalHier] ADD  DEFAULT ((0)) FOR [LlhDelId]
GO

ALTER TABLE [dbo].[LosAppLegalHier]  WITH CHECK ADD FOREIGN KEY([LlhAppFk])
REFERENCES [dbo].[LosApp] ([AppPk])
GO

ALTER TABLE [dbo].[LosAppLegalHier]  WITH CHECK ADD FOREIGN KEY([LlhLedFk])
REFERENCES [dbo].[LosLead] ([LedPk])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Employed 0 - Employed, 1 - UnEmployed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppLegalHier', @level2type=N'COLUMN',@level2name=N'LlhIsEmpl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Married 0 - Single, 1 - Married' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAppLegalHier', @level2type=N'COLUMN',@level2name=N'LlhMarSts'
GO


CREATE TABLE [dbo].[LosDedColMat](
	[LdcNm]			VARCHAR(100) NOT NULL,
	[LdcSrcCol]		VARCHAR(100) NOT NULL,
	[LdcDestCol]	VARCHAR(100) NOT NULL,
	[LdcPk]			[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[LdcRowId]		[dbo].[RowId] NOT NULL,
	[LdcCreatedBy]	[varchar](100) NOT NULL,
	[LdcCreatedDt]	[datetime] NOT NULL,
	[LdcModifiedBy] [varchar](100) NOT NULL,
	[LdcModifiedDt] [datetime] NOT NULL,
	[LdcDelFlg]		[dbo].[DelFlg] NULL,
	[LdcDelId]		[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LdcPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LosDedColMat] ADD  DEFAULT ((0)) FOR [LdcDelId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source Column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDedColMat', @level2type=N'COLUMN',@level2name=N'LdcSrcCol'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Destination Column' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDedColMat', @level2type=N'COLUMN',@level2name=N'LdcDestCol'
GO


CREATE TABLE [dbo].[LosDedRulHdr](
	[LdrRuleNm]		[VARCHAR] (500) NOT NULL,
	[LdrRulTyp]		[TINYINT]	NOT NULL,
	[LdrPk]			[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[LdrRowId]		[dbo].[RowId] NOT NULL,
	[LdrCreatedBy]	[varchar](100) NOT NULL,
	[LdrCreatedDt]	[datetime] NOT NULL,
	[LdrModifiedBy] [varchar](100) NOT NULL,
	[LdrModifiedDt] [datetime] NOT NULL,
	[LdrDelFlg]		[dbo].[DelFlg] NULL,
	[LdrDelId]		[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LdrPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LosDedRulHdr] ADD  DEFAULT ((0)) FOR [LdrDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rule Type 0-Stringent Rules, 1-Moderate Rules' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDedRulHdr', @level2type=N'COLUMN',@level2name=N'LdrRulTyp'
GO

CREATE TABLE [dbo].[LosDedRulDtls](
	[LddLdrFk]		[FkId] NOT NULL,
	[LddLdcFk]		[FkId] NOT NULL,
	[LddOperator]	[VARCHAR](25) NOT NULL,
	[LddLogExp]		[VARCHAR](25) NOT NULL,
	[LddPk]			[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[LddRowId]		[dbo].[RowId] NOT NULL,
	[LddCreatedBy]	[varchar](100) NOT NULL,
	[LddCreatedDt]	[datetime] NOT NULL,
	[LddModifiedBy] [varchar](100) NOT NULL,
	[LddModifiedDt] [datetime] NOT NULL,
	[LddDelFlg]		[dbo].[DelFlg] NULL,
	[LddDelId]		[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LddPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[LosDedRulDtls] ADD  DEFAULT ((0)) FOR [LddDelId]
GO
ALTER TABLE [dbo].[LosDedRulDtls]  WITH CHECK ADD FOREIGN KEY([LddLdrFk])
REFERENCES [dbo].[LosDedRulHdr] ([LdrPk])
GO
ALTER TABLE [dbo].[LosDedRulDtls]  WITH CHECK ADD FOREIGN KEY([LddLdcFk])
REFERENCES [dbo].[LosDedColMat] ([LdcPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LosDedRulHdr Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDedRulDtls', @level2type=N'COLUMN',@level2name=N'LddLdrFk'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LosDedColMat Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosDedRulDtls', @level2type=N'COLUMN',@level2name=N'LddLdcFk'
GO

CREATE TABLE [dbo].[LosProp](
	[PrpSeller]			VARCHAR(250),
    [PrpPrj]            VARCHAR(250),
    [PrpTyp]            TINYINT ,	-- 1 - Residential, 2 - Commercial 
    [PrpLedFk]			[fkid] NOT NULL,
    [PrpAppFk]			[fkid] NOT NULL,
    [PrpDoorNo]			VARCHAR(20),
    [PrpBuilding]		VARCHAR(100),
    [PrpPlotNo]			VARCHAR(20),
    [PrpStreet]			VARCHAR(150),
    [PrpLandmark]		VARCHAR(250),
    [PrpArea]			VARCHAR(150),
    [PrpDistrict]		VARCHAR(100),
    [PrpState]			VARCHAR(100),
    [PrpCountry]		VARCHAR(100),
	[PrpPin]			CHAR(6),
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
ALTER TABLE [dbo].[LosProp]  WITH CHECK ADD FOREIGN KEY([PrpLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosProp]  WITH CHECK ADD FOREIGN KEY([PrpAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Property type -  1 - Residential, 2 - Commercial '								, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosProp', @level2type=N'COLUMN',@level2name=N'PrpTyp'
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


/********* Agent Tables **************/
CREATE TABLE [dbo].[LosAgentJob]
(
	[LajLedFk] [fkid] NOT NULL,
	[LajBGeoFk] [fkid] NOT NULL,
	[LajPrdFk] [fkid] NOT NULL,
    [LajAgtFk]   FkId NOT NULL,
    [LajSrvTyp]  TINYINT NOT NULL,
    [LajJobNo]   VARCHAR(100) NOT NULL,
    [LajJobDt]   DATETIME NOT NULL,
    [LajPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LajRowId] [RowId] NOT NULL,
	[LajCreatedBy] varchar(100) NOT NULL,
	[LajCreatedDt] datetime NOT NULL,
	[LajModifiedBy] varchar(100) NOT NULL,
	[LajModifiedDt] datetime NOT NULL,
	[LajDelFlg] [DelFlg] NULL,
	[LajDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LajPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LosAgentJob]  WITH CHECK ADD FOREIGN KEY([LajAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosAgentJob]  WITH CHECK ADD FOREIGN KEY([LajLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAgentJob]  WITH CHECK ADD FOREIGN KEY([LajBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosAgentJob]  WITH CHECK ADD FOREIGN KEY([LajPrdFk]) REFERENCES [dbo].[GenPrdMas] ([PrdPk])
GO
ALTER TABLE [dbo].[LosAgentJob] ADD  DEFAULT ((0)) FOR [LajDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Agent Service Offered ,  0-Field Investigator(Residence),1-Field Investigator(Office),2- Docuemnt Verifier,3-Collection Feedback,4-Legal Verfier,5-Technical Verifier'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentJob', @level2type=N'COLUMN',@level2name=N'LajSrvTyp'


CREATE TABLE [dbo].[LosAgentVerf]
(
    [LavLajFk]  FkId NOT NULL,
    [LavLapFk]	FkId NOT NULL,
    [LavNm]		VARCHAR(100) NOT NULL,
    [LavMobNo]	VARCHAR(25) NOT NULL,
    [LavAddTyp]	TINYINT NOT NULL,
    [LavDoorNo]	varchar(10) NOT NULL,
	[LavBuilding]	varchar(150) NOT NULL,
	[LavPlotNo]	varchar(20) NOT NULL,
	[LavStreet]	varchar(150) NOT NULL,
	[LavLandmark]	varchar(250) NOT NULL,
	[LavArea]	varchar(150) NOT NULL,
	[LavDistrict]	varchar(100) NOT NULL,
	[LavState]	varchar(100) NOT NULL,
	[LavCountry]	varchar(100) NOT NULL,
	[LavPin]	char(6) NOT NULL,
    [LavPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LavRowId] [RowId] NOT NULL,
	[LavCreatedBy] varchar(100) NOT NULL,
	[LavCreatedDt] datetime NOT NULL,
	[LavModifiedBy] varchar(100) NOT NULL,
	[LavModifiedDt] datetime NOT NULL,
	[LavDelFlg] [DelFlg] NULL,
	[LavDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED
(
	[LavPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LosAgentVerf]  WITH CHECK ADD FOREIGN KEY([LavLajFk]) REFERENCES [dbo].[LosAgentJob] ([LajPk])
GO
ALTER TABLE [dbo].[LosAgentVerf]  WITH CHECK ADD FOREIGN KEY([LavLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
ALTER TABLE [dbo].[LosAgentVerf] ADD  DEFAULT ((0)) FOR [LavDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actor ,  0-Applicant,1-CoApplicant,2-Guarantor'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentVerf', @level2type=N'COLUMN',@level2name=N'LavActor'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicant Preferred Name'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentVerf', @level2type=N'COLUMN',@level2name=N'LavNm'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Address Type'						, @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentVerf', @level2type=N'COLUMN',@level2name=N'LavAddTyp'


CREATE TABLE [dbo].[LosAgentPrpVerf]
(
    [LpvLajFk]  FkId NOT NULL,
    [LpvPrpSeller]	varchar(250) NOT NULL,
	[LpvPrpPrj]	varchar(250) NOT NULL,
	[LpvPrpTyp]	tinyint NOT NULL,
	[LpvBuyNm] VARCHAR(100) NOT NULL,
    [LpvDoorNo]	varchar(10) NOT NULL,
	[LpvBuilding]	varchar(150) NOT NULL,
	[LpvPlotNo]	varchar(20) NOT NULL,
	[LpvStreet]	varchar(150) NOT NULL,
	[LpvLandmark]	varchar(250) NOT NULL,
	[LpvArea]	varchar(150) NOT NULL,
	[LpvDistrict]	varchar(100) NOT NULL,
	[LpvState]	varchar(100) NOT NULL,
	[LpvCountry]	varchar(100) NOT NULL,
	[LpvPin]	char(6) NOT NULL,
    [LpvPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LpvRowId] [RowId] NOT NULL,
	[LpvCreatedBy] varchar(100) NOT NULL,
	[LpvCreatedDt] datetime NOT NULL,
	[LpvModifiedBy] varchar(100) NOT NULL,
	[LpvModifiedDt] datetime NOT NULL,
	[LpvDelFlg] [DelFlg] NULL,
	[LpvDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED
(
	[LpvPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LosAgentPrpVerf]  WITH CHECK ADD FOREIGN KEY([LpvLajFk]) REFERENCES [dbo].[LosAgentJob] ([LajPk])
GO
ALTER TABLE [dbo].[LosAgentPrpVerf] ADD  DEFAULT ((0)) FOR [LpvDelId]
GO

CREATE TABLE [dbo].[LosAgentDocs]
(
    [LadLajFk]  FkId NOT NULL,
    [LadSrvTyp]	TINYINT NOT NULL,
    [LadDocFk]	FkId NOT NULL,
    [LadDpdFk]	FkId NOT NULL,
    [LadDocCt] VARCHAR(100) NOT NULL,
    [LadDocSubCt] VARCHAR(100) NOT NULL,
    [LadPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LadRowId] [RowId] NOT NULL,
	[LadCreatedBy] varchar(100) NOT NULL,
	[LadCreatedDt] datetime NOT NULL,
	[LadModifiedBy] varchar(100) NOT NULL,
	[LadModifiedDt] datetime NOT NULL,
	[LadDelFlg] [DelFlg] NULL,
	[LadDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED
(
	[LadPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LosAgentDocs]  WITH CHECK ADD FOREIGN KEY([LadLajFk]) REFERENCES [dbo].[LosAgentJob] ([LajPk])
GO
ALTER TABLE [dbo].[LosAgentDocs]  WITH CHECK ADD FOREIGN KEY([LadDocFk]) REFERENCES [dbo].[LosDocument] ([DocPk])
GO
ALTER TABLE [dbo].[LosAgentDocs] ADD  DEFAULT ((0)) FOR [LadDelId]
GO

CREATE TABLE [dbo].[LosAgentFBJob]
(
	[LfjJobNo]   VARCHAR(100) NOT NULL,
    [LfjJobDt]   DATETIME NOT NULL,
    [LfjAgtFk]   FkId NOT NULL,
    [LfjSrvTyp]  TINYINT NOT NULL,
    [LfjRptDt]	DATETIME NOT NULL,
    [LfjRptSts] TINYINT NOT NULL,
    [LfjNotes] VARCHAR(100) NOT NULL,
    [LfjAgtRefNo] VARCHAR(100) NOT NULL,
    [LfjLavFk]	FkId NULL,
    [LfjLpvFk]	FkId NULL,
    [LfjLajFk]	FkId NULL,
    [LfjJobSts]	TINYINT NOT NULL,
    [LfjPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LfjRowId] [RowId] NOT NULL,
	[LfjCreatedBy] varchar(100) NOT NULL,
	[LfjCreatedDt] datetime NOT NULL,
	[LfjModifiedBy] varchar(100) NOT NULL,
	[LfjModifiedDt] datetime NOT NULL,
	[LfjDelFlg] [DelFlg] NULL,
	[LfjDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED
(
	[LfjPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[LosAgentFBJob]  WITH CHECK ADD FOREIGN KEY([LfjLavFk]) REFERENCES [dbo].[LosAgentVerf] ([LavPk])
GO
ALTER TABLE [dbo].[LosAgentFBJob]  WITH CHECK ADD FOREIGN KEY([LfjLpvFk]) REFERENCES [dbo].[LosAgentPrpVerf] ([LpvPk])
GO
ALTER TABLE [dbo].[LosAgentFBJob]  WITH CHECK ADD FOREIGN KEY([LfjLajFk]) REFERENCES [dbo].[LosAgentJob] ([LajPk])
GO
ALTER TABLE [dbo].[LosAgentFBJob] ADD  DEFAULT ((0)) FOR [LfjJobSts]
GO
ALTER TABLE [dbo].[LosAgentFBJob] ADD  DEFAULT ((0)) FOR [LfjDelId]
GO

CREATE TABLE [dbo].[LosAgentFBDocs]
(
    [LfdLfjFk]	FkId NOT NULL,
    [LfdDocFk]	FkId NOT NULL,
    [LfdNotes] VARCHAR(250),
    [LfdSts]  TINYINT NOT NULL,
    [LfdPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LfdRowId] [RowId] NOT NULL,
	[LfdCreatedBy] varchar(100) NOT NULL,
	[LfdCreatedDt] datetime NOT NULL,
	[LfdModifiedBy] varchar(100) NOT NULL,
	[LfdModifiedDt] datetime NOT NULL,
	[LfdDelFlg] [DelFlg] NULL,
	[LfdDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED
(
	[LfdPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[LosAgentFBDocs]  WITH CHECK ADD FOREIGN KEY([LfdLfjFk]) REFERENCES [dbo].[LosAgentFBJob] ([LfjPk])
GO
ALTER TABLE [dbo].[LosAgentFBDocs]  WITH CHECK ADD FOREIGN KEY([LfdDocFk]) REFERENCES [dbo].[LosDocument] ([DocPk])
GO
ALTER TABLE [dbo].[LosAgentFBDocs] ADD  DEFAULT ((0)) FOR [LfdDelId]
GO


CREATE TABLE dbo.[LosAgentFBLegal]
(
    [LflLfjFk]  FkId NOT NULL,
	[LflEast]	VARCHAR(100) NOT NULL,
	[LflWest]	VARCHAR(100) NOT NULL,
	[LflNorth]	VARCHAR(100) NOT NULL,
	[LflSouth]	VARCHAR(100) NOT NULL,
	[LflRefNo]	VARCHAR(100) NOT NULL,
	[LflAppPlnNo]	VARCHAR(100) NOT NULL,
	[LflAstCost]	NUMERIC(27,7) NOT NULL,
	[LflRegChg]		NUMERIC(27,7) NOT NULL,
	[LflStmpChg]	NUMERIC(27,7) NOT NULL,
	[LflAgrmtVal]		NUMERIC(27,7) NOT NULL,
	[LflPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LflRowId] [RowId] NOT NULL,
	[LflCreatedBy] varchar(100) NOT NULL,
	[LflCreatedDt] datetime NOT NULL,
	[LflModifiedBy] varchar(100) NOT NULL,
	[LflModifiedDt] datetime NOT NULL,
	[LflDelFlg] [DelFlg] NULL,
	[LflDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LflPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[LosAgentFBLegal]  WITH CHECK ADD FOREIGN KEY([LflLfjFk]) REFERENCES [dbo].[LosAgentFBJob] ([LfjPk])
GO
ALTER TABLE [dbo].[LosAgentFBLegal] ADD  DEFAULT ((0)) FOR [LflDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - East', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflEast'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - West', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflWest'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - North', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflNorth'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - South', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflSouth'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference Number', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflRefNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Approval Plan Number', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflAppPlnNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asset Cost', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflAstCost'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Registration Charges', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflRegChg'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stamp Duty Charges', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflStmpChg'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Agreement Value', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBLegal', @level2type=N'COLUMN',@level2name=N'LflAgrmtVal'


CREATE TABLE dbo.[LosAgentFBTechnical]
(
    [LftLfjFk]  FkId NOT NULL,
	[LftEast]	VARCHAR(100) NOT NULL,
	[LftWest]	VARCHAR(100) NOT NULL,
	[LftNorth]	VARCHAR(100) NOT NULL,
	[LftSouth]	VARCHAR(100) NOT NULL,
	[LftRefNo]	VARCHAR(100) NOT NULL,
	[LftMktVal]		NUMERIC(27,7) NOT NULL,
	[LftAmenAmt]	NUMERIC(27,7) NOT NULL,
	[LftPk]  [pkid] IDENTITY(1,1) NOT NULL,
	[LftRowId] [RowId] NOT NULL,
	[LftCreatedBy] varchar(100) NOT NULL,
	[LftCreatedDt] datetime NOT NULL,
	[LftModifiedBy] varchar(100) NOT NULL,
	[LftModifiedDt] datetime NOT NULL,
	[LftDelFlg] [DelFlg] NULL,
	[LftDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LftPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[LosAgentFBTechnical]  WITH CHECK ADD FOREIGN KEY([LftLfjFk]) REFERENCES [dbo].[LosAgentFBJob] ([LfjPk])
GO
ALTER TABLE [dbo].[LosAgentFBTechnical] ADD  DEFAULT ((0)) FOR [LftDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - East', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftEast'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - West', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftWest'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - North', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftNorth'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Boundaries As Per Sale Deed - South', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftSouth'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference Number', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftRefNo'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Approval Plan Number', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftMktVal'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asset Cost', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LosAgentFBTechnical', @level2type=N'COLUMN',@level2name=N'LftAmenAmt'


CREATE TABLE [dbo].[LosPropLegal](
	[LplLedFk]			FkId NOT NULL,
	[LplAgtFk]			FkId NOT NULL,
	[LplBGeoFk]			FkId NOT NULL,
	[LplPrpFk]			FkId NOT NULL,
    [LplRptDt]			DATETIME,
    [LplNotes]			VARCHAR(MAX),
    [LplSts]			TINYINT NOT NULL,
    [LplBuilderNm]		VARCHAR(100) NOT NULL,
    [LplBuilderCIN]		VARCHAR(100) NOT NULL,
    [LplRefNo]			VARCHAR(100) NOT NULL,
    [LplSrchPer]		INT NOT NULL,
    [LplClrMrkt]		TINYINT NOT NULL,
	[LplAstCost]		NUMERIC(27,7) NOT NULL,
	[LplRegChg]			NUMERIC(27,7) NOT NULL,
	[LplStmpChg]		NUMERIC(27,7) NOT NULL,
	[LplAgrmtVal]		NUMERIC(27,7) NOT NULL,
	[LplAvLtv]			NUMERIC(27,7) NOT NULL,
	[LplPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[LplRowId]			[RowId]	NOT NULL,
	[LplCreatedBy]		VARCHAR(100) NOT NULL,
	[LplCreatedDt]		DATETIME NOT NULL,
	[LplModifiedBy]		VARCHAR(100) NOT NULL,
	[LplModifiedDt]		DATETIME NOT NULL,
	[LplDelFlg]			[DelFlg] NULL,
	[LplDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LplPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosPropLegal] ADD  DEFAULT ((0)) FOR [LplDelId]
GO
ALTER TABLE [dbo].[LosPropLegal]  WITH CHECK ADD FOREIGN KEY([LplLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosPropLegal]  WITH CHECK ADD FOREIGN KEY([LplAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosPropLegal]  WITH CHECK ADD FOREIGN KEY([LplBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosPropLegal]  WITH CHECK ADD FOREIGN KEY([LplPrpFk]) REFERENCES [dbo].[LosProp] ([PrpPk])
GO

CREATE TABLE [dbo].[LosPropOwner](
	[LpoLplFk]			[FkId]	NOT NULL,
	[LpoLapFk]			[FkId]	NOT NULL,
	[LpoPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[LpoRowId]			[RowId]	NOT NULL,
	[LpoCreatedBy]		VARCHAR(100) NOT NULL,
	[LpoCreatedDt]		DATETIME NOT NULL,
	[LpoModifiedBy]		VARCHAR(100) NOT NULL,
	[LpoModifiedDt]		DATETIME NOT NULL,
	[LpoDelFlg]			[DelFlg] NULL,
	[LpoDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LpoPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosPropOwner] ADD  DEFAULT ((0)) FOR [LpoDelId]
GO
ALTER TABLE [dbo].[LosPropOwner]  WITH CHECK ADD FOREIGN KEY([LpoLplFk]) REFERENCES [dbo].[LosPropLegal] ([LplPk])
GO
ALTER TABLE [dbo].[LosPropOwner]  WITH CHECK ADD FOREIGN KEY([LpoLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO


CREATE TABLE [dbo].[LosPropTechnical](
	[LptLedFk]			FkId NOT NULL,
	[LptAgtFk]			FkId NOT NULL,
	[LptBGeoFk]			FkId NOT NULL,
	[LptPrpFk]			FkId NOT NULL,
    [LptRptDt]			DATETIME,
    [LptSts]			TINYINT NOT NULL,
	[LptMktVal]			NUMERIC(27,7) NOT NULL,
	[LptAmenAmt]		NUMERIC(27,7) NOT NULL,
	[LptPrpValRmks]		VARCHAR(MAX),
	[LptPrpTyp]			INT NOT NULL,
	[LptDemolishRsk]	INT NOT NULL,
	[LptUdsArea]		NUMERIC(27,7),
	[LptUdsmmt]			INT NOT NULL,
	[LptUdsVal]			NUMERIC(27,7),
	[LptSupBuldArea]	NUMERIC(27,7),
	[LptSupBuldmmt]		INT NOT NULL,
	[LptBuldArea]		NUMERIC(27,7),
	[LptBuldmmt]		INT NOT NULL,
	[LptCrpArea]		NUMERIC(27,7),
	[LptCrpmmt]			INT NOT NULL,
	[LptEstmt]			NUMERIC(27,7),
	[LptOwnTyp]			INT NOT NULL,
	[LptPossessTyp]		INT NOT NULL,
	[LptSurvNo]			VARCHAR(100) NOT NULL,
	[LptLocTyp]			INT NOT NULL,
	[LptApprLandUse]	INT NOT NULL,
	[LptApprAuth]		VARCHAR(100) NOT NULL,
	[LptPropDtRmks]		VARCHAR(MAX),
	[LptBuldAge]		INT NOT NULL,
	[LptEstmtBuldLife]	INT NOT NULL,
	[LptStructTyp]		VARCHAR(100) NOT NULL,
	[LptFloorNo]		INT NOT NULL,
	[LptConstPer]		INT NOT NULL,
	[LptConstRmks]		VARCHAR(MAX),
	[LptLandArea]		NUMERIC(27,7),
	[LptLandVal]		NUMERIC(27,7),
	[LptLandmmt]		INT,
	[LptLeasePer]		INT,
	[LptPk]				[pkid] IDENTITY(1,1) NOT NULL,
	[LptRowId]			[RowId]	NOT NULL,
	[LptCreatedBy]		VARCHAR(100) NOT NULL,
	[LptCreatedDt]		DATETIME NOT NULL,
	[LptModifiedBy]		VARCHAR(100) NOT NULL,
	[LptModifiedDt]		DATETIME NOT NULL,
	[LptDelFlg]			[DelFlg] NULL,
	[LptDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LptPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosPropTechnical] ADD  DEFAULT ((0)) FOR [LptDelId]
GO
ALTER TABLE [dbo].[LosPropTechnical]  WITH CHECK ADD FOREIGN KEY([LptLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosPropTechnical]  WITH CHECK ADD FOREIGN KEY([LptAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosPropTechnical]  WITH CHECK ADD FOREIGN KEY([LptBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosPropTechnical]  WITH CHECK ADD FOREIGN KEY([LptPrpFk]) REFERENCES [dbo].[LosProp] ([PrpPk])
GO

CREATE TABLE [dbo].[LosProcChrg](
	[LpcLedFk]		[fkid] NOT NULL,
	[LpcAgtFk]		FkId NOT NULL,
	[LpcBGeoFk]		[fkid] NOT NULL,
	[LpcPrdFk]		[fkid] NOT NULL,
	[LpcDocTyp]		FKID,
	[LpcChrg]		NUMERIC(27,7) NOT NULL,
	[LpcInstrAmt]	NUMERIC(27,7) NOT NULL,
	[LpcPayTyp]		CHAR(1),
    [LpcInstrNo]	VARCHAR(50),
	[LpcInstrDt]	DATETIME,
	[LpcChqSts]		CHAR(1),
	[LpcChqClrDt]	DATETIME,
	[LpcPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LpcRowId] [RowId] NOT NULL,
	[LpcCreatedBy] varchar(100) NOT NULL,
	[LpcCreatedDt] datetime NOT NULL,
	[LpcModifiedBy] varchar(100) NOT NULL,
	[LpcModifiedDt] datetime NOT NULL,
	[LpcDelFlg] [DelFlg] NULL,
	[LpcDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LpcPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosProcChrg]  WITH CHECK ADD FOREIGN KEY([LpcLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosProcChrg]  WITH CHECK ADD FOREIGN KEY([LpcAgtFk]) REFERENCES [dbo].[GenAgents] ([AgtPk])
GO
ALTER TABLE [dbo].[LosProcChrg]  WITH CHECK ADD FOREIGN KEY([LpcBGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[LosProcChrg]  WITH CHECK ADD FOREIGN KEY([LpcPrdFk]) REFERENCES [dbo].[GenPrdMas] ([PrdPk])
GO
ALTER TABLE [dbo].[LosProcChrg] ADD  DEFAULT ((0)) FOR [LpcDelId]
GO

CREATE TABLE [dbo].[LosAppTeleVerify](
	[LtvLedFk]	FKID	NOT NULL,
	[LtvAppFk]	FKID	NOT NULL,
	[LtvLapFk]	FKID	NOT NULL,
	[LtvRptDt]	FKID	NOT NULL,
	[LtvNotes]	VARCHAR(MAX)	NOT NULL,
	[LtvPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LtvRowId] [RowId] NOT NULL,
	[LtvCreatedBy] varchar(100) NOT NULL,
	[LtvCreatedDt] datetime NOT NULL,
	[LtvModifiedBy] varchar(100) NOT NULL,
	[LtvModifiedDt] datetime NOT NULL,
	[LtvDelFlg] [DelFlg] NULL,
	[LtvDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LtvPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppTeleVerify]  WITH CHECK ADD FOREIGN KEY([LtvLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppTeleVerify]  WITH CHECK ADD FOREIGN KEY([LtvAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppTeleVerify]  WITH CHECK ADD FOREIGN KEY([LtvLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
ALTER TABLE [dbo].[LosAppTeleVerify] ADD  DEFAULT ((0)) FOR [LtvDelId]
GO

CREATE TABLE [dbo].[LosAppPD](
	[LpdLedFk]	FKID	NOT NULL,
	[LpdAppFk]	FKID	NOT NULL,
	[LpdLapFk]	FKID	NOT NULL,
	[LpdRptDt]	FKID	NOT NULL,
	[LpdNotes]	VARCHAR(MAX)	NOT NULL,
	[LpdPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LpdRowId] [RowId] NOT NULL,
	[LpdCreatedBy] varchar(100) NOT NULL,
	[LpdCreatedDt] datetime NOT NULL,
	[LpdModifiedBy] varchar(100) NOT NULL,
	[LpdModifiedDt] datetime NOT NULL,
	[LpdDelFlg] [DelFlg] NULL,
	[LpdDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LpdPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosAppPD]  WITH CHECK ADD FOREIGN KEY([LpdLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosAppPD]  WITH CHECK ADD FOREIGN KEY([LpdAppFk]) REFERENCES [dbo].[LosApp] ([AppPk])
GO
ALTER TABLE [dbo].[LosAppPD]  WITH CHECK ADD FOREIGN KEY([LpdLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
ALTER TABLE [dbo].[LosAppPD] ADD  DEFAULT ((0)) FOR [LpdDelId]
GO

CREATE TABLE [dbo].[LosRCU](
	[LruLedFk]	FKID	NOT NULL,
	[LruLapFk]	FKID	NOT NULL,
	[LruDocFk]	FKID	NOT NULL,
	[LruScreen]	BIT	NOT NULL,
	[LruSample]	BIT	NOT NULL,
	[LruRptSts]	BIT	NOT NULL,
	[LruRptDt]	FKID	NOT NULL,
	[LruNotes]	VARCHAR(MAX),
	[LruApprovalNt]	VARCHAR(MAX),
	[LruPk] [pkid] IDENTITY(1,1) NOT NULL,
	[LruRowId] [RowId] NOT NULL,
	[LruCreatedBy] varchar(100) NOT NULL,
	[LruCreatedDt] datetime NOT NULL,
	[LruModifiedBy] varchar(100) NOT NULL,
	[LruModifiedDt] datetime NOT NULL,
	[LruDelFlg] [DelFlg] NULL,
	[LruDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[LruPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LosRCU]  WITH CHECK ADD FOREIGN KEY([LruLedFk]) REFERENCES [dbo].[LosLead] ([LedPk])
GO
ALTER TABLE [dbo].[LosRCU]  WITH CHECK ADD FOREIGN KEY([LruLapFk]) REFERENCES [dbo].[LosAppProfile] ([LapPk])
GO
ALTER TABLE [dbo].[LosRCU]  WITH CHECK ADD FOREIGN KEY([LruDocFk]) REFERENCES [dbo].[LosDocument] ([DocPk])
GO
ALTER TABLE [dbo].[LosRCU] ADD  DEFAULT ((0)) FOR [LruDelId]
GO