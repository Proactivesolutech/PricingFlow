--SELECT 'DROP TABLE ' + NAME FROM SYSOBJECTS WHERE  XTYPE = 'U'

CREATE TABLE [dbo].[BpmToolBox](
	[BtbToolNm] varchar(100) NOT NULL,
	[BtbPk] [bigint] IDENTITY(1,1) NOT NULL,
	[BtbRowId] [RowId] NOT NULL,
	[BtbCreatedBy] varchar(100) NOT NULL,
	[BtbCreatedDt] datetime NOT NULL,
	[BtbModifiedBy] varchar(100) NOT NULL,
	[BtbModifiedDt] datetime NOT NULL,
	[BtbDelFlg] [DelFlg] NULL,
	[BtbDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BtbPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmToolBox] ADD  DEFAULT ((0)) FOR [BtbDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'BPM Tools Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmToolBox', @level2type=N'COLUMN',@level2name=N'BtbToolNm'
GO

CREATE TABLE [dbo].[BpmMas](
	[BpmNm] varchar(100) NOT NULL,
	[BpmFolderPath] varchar(100) NOT NULL,
	[BpmTrigFk]	FkId NOT NULL,
	[BpmPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BpmRowId] [RowId] NOT NULL,
	[BpmCreatedBy] varchar(100) NOT NULL,
	[BpmCreatedDt] datetime NOT NULL,
	[BpmModifiedBy] varchar(100) NOT NULL,
	[BpmModifiedDt] datetime NOT NULL,
	[BpmDelFlg] [DelFlg] NULL,
	[BpmDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BpmPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[BpmMas] ADD  DEFAULT ((0)) FOR [BpmDelId]
GO

CREATE TABLE [dbo].[BpmAttrMas](
	[BamBpmFk] [Fkid] NOT NULL,
	[BamAttrTyp] [tinyint] NOT NULL,
	[BamAttrFk] [Fkid] NOT NULL,
	[BamPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BamRowId] [RowId] NOT NULL,
	[BamCreatedBy] varchar(100) NOT NULL,
	[BamCreatedDt] datetime NOT NULL,
	[BamModifiedBy] varchar(100) NOT NULL,
	[BamModifiedDt] datetime NOT NULL,
	[BamDelFlg] [DelFlg] NULL,
	[BamDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BamPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmAttrMas] ADD  DEFAULT ((0)) FOR [BamDelId]
GO
ALTER TABLE [dbo].[BpmAttrMas]  WITH CHECK ADD FOREIGN KEY([BamBpmFk]) REFERENCES [dbo].[BpmMas] ([BpmPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Product, 1 - Branch' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmAttrMas', @level2type=N'COLUMN',@level2name=N'BamAttrTyp'
GO

CREATE TABLE [dbo].[BpmVersions](
	[BvmBpmFk] [Fkid] NOT NULL,
	[BvmXML] varchar(max) NOT NULL,
	[BvmVerNo] [tinyint] NOT NULL,
	[BvmPublish] [bit] NOT NULL,
	[BvmNotes] varchar(max) NOT NULL,
	[BvmPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BvmRowId] [RowId] NOT NULL,
	[BvmCreatedBy] varchar(100) NOT NULL,
	[BvmCreatedDt] datetime NOT NULL,
	[BvmModifiedBy] varchar(100) NOT NULL,
	[BvmModifiedDt] datetime NOT NULL,
	[BvmDelFlg] [DelFlg] NULL,
	[BvmDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BvmPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmVersions] ADD  DEFAULT ((0)) FOR [BvmVerNo]
GO
ALTER TABLE [dbo].[BpmVersions] ADD  DEFAULT ((0)) FOR [BvmPublish]
GO
ALTER TABLE [dbo].[BpmVersions] ADD  DEFAULT ((0)) FOR [BvmDelId]
GO
ALTER TABLE [dbo].[BpmVersions]  WITH CHECK ADD FOREIGN KEY([BvmBpmFk]) REFERENCES [dbo].[BpmMas] ([BpmPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Not Published, 1 - Published' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmVersions', @level2type=N'COLUMN',@level2name=N'BvmPublish'
GO

CREATE TABLE [dbo].[BpmFlow](
	[BfwBvmFk] [Fkid] NOT NULL,
	[BfwBtbFk] [Fkid] NOT NULL,
	[BfwId] varchar(100) NOT NULL,
	[BfwLabel] varchar(100) NOT NULL,
	[BfwPrtRef] varchar(100) NOT NULL,
	[BfwSubBvmFk] [Fkid] NULL,
	[BfwLaneRef] varchar(100) NULL,
	[BfwPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BfwRowId] [RowId] NOT NULL,
	[BfwCreatedBy] varchar(100) NOT NULL,
	[BfwCreatedDt] datetime NOT NULL,
	[BfwModifiedBy] varchar(100) NOT NULL,
	[BfwModifiedDt] datetime NOT NULL,
	[BfwDelFlg] [DelFlg] NULL,
	[BfwDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BfwPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmFlow] ADD  DEFAULT ((0)) FOR [BfwDelId]
GO
ALTER TABLE [dbo].[BpmFlow]  WITH CHECK ADD FOREIGN KEY([BfwBvmFk]) REFERENCES [dbo].[BpmVersions] ([BvmPk])
GO
ALTER TABLE [dbo].[BpmFlow]  WITH CHECK ADD FOREIGN KEY([BfwBtbFk]) REFERENCES [dbo].[BpmToolBox] ([BtbPk])
GO
ALTER TABLE [dbo].[BpmFlow]  WITH CHECK ADD FOREIGN KEY([BfwSubBvmFk]) REFERENCES [dbo].[BpmVersions] ([BvmPk])
GO

CREATE TABLE [dbo].[BpmObjInOut](
	[BioBvmFk] [Fkid] NOT NULL,
	[BioBfwFk] [Fkid] NOT NULL,
	[BioBtbFk] [Fkid] NOT NULL,
	[BioId] varchar(100) NOT NULL,
	[BioInBfwFk] [Fkid] NULL,
	[BioInId] varchar(100) NULL,
	[BioOutBfwFk] [Fkid] NULL,
	[BioOutId] varchar(100) NULL,
	[BioSubBfwFk] [Fkid] NULL,
	[BioPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BioRowId] [RowId] NOT NULL,
	[BioCreatedBy] varchar(100) NOT NULL,
	[BioCreatedDt] datetime NOT NULL,
	[BioModifiedBy] varchar(100) NOT NULL,
	[BioModifiedDt] datetime NOT NULL,
	[BioDelFlg] [DelFlg] NULL,
	[BioDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BioPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmObjInOut] ADD  DEFAULT ((0)) FOR [BioDelId]
GO
ALTER TABLE [dbo].[BpmObjInOut]  WITH CHECK ADD FOREIGN KEY([BioBvmFk]) REFERENCES [dbo].[BpmVersions] ([BvmPk])
GO
ALTER TABLE [dbo].[BpmObjInOut]  WITH CHECK ADD FOREIGN KEY([BioBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
ALTER TABLE [dbo].[BpmObjInOut]  WITH CHECK ADD FOREIGN KEY([BioBtbFk]) REFERENCES [dbo].[BpmToolBox] ([BtbPk])
GO
ALTER TABLE [dbo].[BpmObjInOut]  WITH CHECK ADD FOREIGN KEY([BioInBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
ALTER TABLE [dbo].[BpmObjInOut]  WITH CHECK ADD FOREIGN KEY([BioOutBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
ALTER TABLE [dbo].[BpmObjInOut]  WITH CHECK ADD FOREIGN KEY([BioSubBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO


CREATE TABLE [dbo].[BpmFlowUsr](
	[BfuBfwFk] [Fkid] NOT NULL,
	[BfuUsrFk] [Fkid] NOT NULL,
	[BfuExclude] [bit] NOT NULL,
	[BfuActive] [bit] NOT NULL,
	[BfuPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BfuRowId] [RowId] NOT NULL,
	[BfuCreatedBy] varchar(100) NOT NULL,
	[BfuCreatedDt] datetime NOT NULL,
	[BfuModifiedBy] varchar(100) NOT NULL,
	[BfuModifiedDt] datetime NOT NULL,
	[BfuDelFlg] [DelFlg] NULL,
	[BfuDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BfuPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmFlowUsr] ADD  DEFAULT ((0)) FOR [BfuExclude]
GO
ALTER TABLE [dbo].[BpmFlowUsr] ADD  DEFAULT ((0)) FOR [BfuActive]
GO
ALTER TABLE [dbo].[BpmFlowUsr] ADD  DEFAULT ((0)) FOR [BfuDelId]
GO
ALTER TABLE [dbo].[BpmFlowUsr]  WITH CHECK ADD FOREIGN KEY([BfuBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Include, 1 - Exclude' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmFlowUsr', @level2type=N'COLUMN',@level2name=N'BfuExclude'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Active, 1 - De-active' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmFlowUsr', @level2type=N'COLUMN',@level2name=N'BfuActive'
GO

CREATE TABLE [dbo].[BpmUIDefn](
	[BudBfwFk] [Fkid] NOT NULL,
	[BudCd]	varchar(5) NOT NULL,
	[BudDesignTyp] [tinyint] NOT NULL,
	[BudDesignData] varchar (MAX) NULL,
	[BudURL] varchar(100) NULL,
	[BudDecIsAuto] [bit] NOT NULL,
	[BudDecExp] varchar(max) NULL,
	[BudScript] varchar(max) NULL,
	[BudNotes] varchar(max) NULL,
	[BudPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BudRowId] [RowId] NOT NULL,
	[BudCreatedBy] varchar(100) NOT NULL,
	[BudCreatedDt] datetime NOT NULL,
	[BudModifiedBy] varchar(100) NOT NULL,
	[BudModifiedDt] datetime NOT NULL,
	[BudDelFlg] [DelFlg] NULL,
	[BudDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BudPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmUIDefn] ADD  DEFAULT ((0)) FOR [BudDelId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - Design Data, 1 - Screen attached', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmUIDefn', @level2type=N'COLUMN',@level2name=N'BudDesignTyp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Decision Fixing 0 - Auto Decision, 1 - Manual', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmUIDefn', @level2type=N'COLUMN',@level2name=N'BudDecIsAuto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Decision Expression', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmUIDefn', @level2type=N'COLUMN',@level2name=N'BudDecExp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If Script Control is choosed', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmUIDefn', @level2type=N'COLUMN',@level2name=N'BudScript'
GO

CREATE TABLE [dbo].[BpmExec](
	[BexKeyFk] [Fkid] NOT NULL,
	[BexBvmFk] [Fkid] NOT NULL,
	[BexBioFk] [Fkid] NOT NULL,
	[BexUsrFk] [Fkid] NOT NULL,
	[BexBrnchFk] [Fkid] NOT NULL,
	[BexRtnBfwFk] [Fkid] NULL,
	[BexAutoPass] [bit] NOT NULL,
	[BexRoundNo] [tinyint] NOT NULL,
	[BexPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BexRowId] [RowId] NOT NULL,
	[BexCreatedBy] varchar(100) NOT NULL,
	[BexCreatedDt] datetime NOT NULL,
	[BexDelFlg] [DelFlg] NULL,
	[BexDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BexPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmExec] ADD  DEFAULT ((0)) FOR [BexDelId]
GO
ALTER TABLE [dbo].[BpmExec] ADD  DEFAULT ((0)) FOR [BexAutoPass]
GO
ALTER TABLE [dbo].[BpmExec] WITH CHECK ADD FOREIGN KEY([BexBvmFk]) REFERENCES [dbo].[BpmVersions] ([BvmPk])
GO
ALTER TABLE [dbo].[BpmExec] WITH CHECK ADD FOREIGN KEY([BexBioFk]) REFERENCES [dbo].[BpmObjInOut] ([BioPk])
GO
ALTER TABLE [dbo].[BpmExec] WITH CHECK ADD FOREIGN KEY([BexRtnBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auto Pass tasks especially for AND / OR', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmExec', @level2type=N'COLUMN',@level2name=N'BexAutoPass'
GO

CREATE TABLE [dbo].[BpmExecStatus](
	[BesBexFk] [Fkid] NOT NULL,
	[BesKeyFk] [Fkid] NOT NULL,
	[BesBvmFk] [Fkid] NOT NULL,
	[BesBioFk] [Fkid] NOT NULL,
	[BesUsrFk] [Fkid] NOT NULL,
	[BesBrnchFk] [Fkid] NOT NULL,
	[BesRtnBfwFk] [Fkid] NULL,
	[BesAutoPass] [bit] NOT NULL,
	[BesSysEntry] [bit] NOT NULL,
	[BesRoundNo] [tinyint] NOT NULL,
	[BesPk] [Pkid] IDENTITY(1,1) NOT NULL,
	[BesRowId] [RowId] NOT NULL,
	[BesCreatedBy] varchar(100) NOT NULL,
	[BesCreatedDt] datetime NOT NULL,
	[BesDelFlg] [DelFlg] NULL,
	[BesDelId] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[BesPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BpmExecStatus] ADD  DEFAULT ((0)) FOR [BesDelId]
GO
ALTER TABLE [dbo].[BpmExecStatus] ADD  DEFAULT ((0)) FOR [BesAutoPass]
GO
ALTER TABLE [dbo].[BpmExecStatus] ADD  DEFAULT ((0)) FOR [BesSysEntry]
GO
ALTER TABLE [dbo].[BpmExecStatus] WITH CHECK ADD FOREIGN KEY([BesBexFk]) REFERENCES [dbo].[BpmExec] ([BexPk])
GO
ALTER TABLE [dbo].[BpmExecStatus] WITH CHECK ADD FOREIGN KEY([BesBvmFk]) REFERENCES [dbo].[BpmVersions] ([BvmPk])
GO
ALTER TABLE [dbo].[BpmExecStatus] WITH CHECK ADD FOREIGN KEY([BesBioFk]) REFERENCES [dbo].[BpmObjInOut] ([BioPk])
GO
ALTER TABLE [dbo].[BpmExecStatus] WITH CHECK ADD FOREIGN KEY([BesRtnBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auto Pass tasks especially for AND / OR, 0 - No Auto Pass, 1 - Auto Pass', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmExecStatus', @level2type=N'COLUMN',@level2name=N'BesAutoPass'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Closed by System especially for Return Cases, 0 - Not System Entry, 1 - System Entry ', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BpmExecStatus', @level2type=N'COLUMN',@level2name=N'BesSysEntry'
GO
