--SELECT 'DROP TABLE ' + name FROM SYSOBJECTS WHERE NAME LIKE 'Qry%'
--GO
CREATE TABLE [dbo].[QryCategory](
	[QrcNm]				varchar(100) NOT NULL,
	[QrcPk]				[Pkid] IDENTITY(1,1) NOT NULL,
	[QrcRowId]			[RowId] NOT NULL,
	[QrcCreatedBy]		varchar(100) NOT NULL,
	[QrcCreatedDt]		datetime NOT NULL,
	[QrcModifiedBy]		varchar(100) NOT NULL,
	[QrcModifiedDt]		datetime NOT NULL,
	[QrcDelFlg]			[DelFlg] NULL,
	[QrcDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QrcPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QryCategory] ADD  DEFAULT ((0)) FOR [QrcDelId]
GO
CREATE TABLE [dbo].[QryHdr](
	[QrhKeyFk]			[Fkid] NOT NULL,
	[QrhBvmFk]			[Fkid] NOT NULL,
	[QrhBfwFk]			[Fkid] NOT NULL,
	--[QrhTag]			varchar(100) NOT NULL,
	[QrhQrcFk]			[Fkid] NOT NULL,
	[QrhSoln]			varchar(100) NULL,
	[QrhPk]				[Pkid] IDENTITY(1,1) NOT NULL,
	[QrhRowId]			[RowId] NOT NULL,
	[QrhCreatedBy]		varchar(100) NOT NULL,
	[QrhCreatedDt]		datetime NOT NULL,
	[QrhModifiedBy]		varchar(100) NOT NULL,
	[QrhModifiedDt]		datetime NOT NULL,
	[QrhDelFlg]			[DelFlg] NULL,
	[QrhDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QrhPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QryHdr] ADD  DEFAULT ((0)) FOR [QrhDelId]
GO
ALTER TABLE [dbo].[QryHdr]  WITH CHECK ADD FOREIGN KEY([QrhBvmFk]) REFERENCES [dbo].[BpmVersions] ([BvmPk])
GO
ALTER TABLE [dbo].[QryHdr]  WITH CHECK ADD FOREIGN KEY([QrhBfwFk]) REFERENCES [dbo].[BpmFlow] ([BfwPk])
GO
ALTER TABLE [dbo].[QryHdr]  WITH CHECK ADD FOREIGN KEY([QrhQrcFk]) REFERENCES [dbo].[QryCategory] ([QrcPk])
GO
CREATE TABLE [dbo].[QryDtls](
	[QrdQrhFk]			[Fkid] NOT NULL,
	[QrdDate]			datetime NOT NULL,
	[QrdNotes]			varchar(MAX) NOT NULL,
	[QrdSeqNo]			tinyint NOT NULL,
	[QrdPk]				[Pkid] IDENTITY(1,1) NOT NULL,
	[QrdRowId]			[RowId] NOT NULL,
	[QrdCreatedBy]		varchar(100) NOT NULL,
	[QrdCreatedDt]		datetime NOT NULL,
	[QrdModifiedBy]		varchar(100) NOT NULL,
	[QrdModifiedDt]		datetime NOT NULL,
	[QrdDelFlg]			[DelFlg] NULL,
	[QrdDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QrdPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QryDtls] ADD  DEFAULT ((0)) FOR [QrdDelId]
GO
ALTER TABLE [dbo].[QryDtls]  WITH CHECK ADD FOREIGN KEY([QrdQrhFk]) REFERENCES [dbo].[QryHdr] ([QrhPk])
GO

CREATE TABLE [dbo].[QryOut](
	[QrOQrdFk]			[Fkid] NOT NULL,
	[QrOUsrFk]			[Fkid] NOT NULL,
	[QrOPk]				[Pkid] IDENTITY(1,1) NOT NULL,
	[QrORowId]			[RowId] NOT NULL,
	[QrOCreatedBy]		varchar(100) NOT NULL,
	[QrOCreatedDt]		datetime NOT NULL,
	[QrOModifiedBy]		varchar(100) NOT NULL,
	[QrOModifiedDt]		datetime NOT NULL,
	[QrODelFlg]			[DelFlg] NULL,
	[QrODelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QrOPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QryOut] ADD  DEFAULT ((0)) FOR [QrODelId]
GO
ALTER TABLE [dbo].[QryOut]  WITH CHECK ADD FOREIGN KEY([QrOQrdFk]) REFERENCES [dbo].[QryDtls] ([QrdPk])
GO
ALTER TABLE [dbo].[QryOut]  WITH CHECK ADD FOREIGN KEY([QrOUsrFk]) REFERENCES [dbo].[ShflUsrMas] ([UsrPk])
GO

CREATE TABLE [dbo].[QryIn](
	[QrIQrdFk]			[Fkid] NOT NULL,
	[QrIQrOFk]			[Fkid] NOT NULL,
	[QrIUsrFk]			[Fkid] NOT NULL,
	[QrIPk]				[Pkid] IDENTITY(1,1) NOT NULL,
	[QrIRowId]			[RowId] NOT NULL,
	[QrICreatedBy]		varchar(100) NOT NULL,
	[QrICreatedDt]		datetime NOT NULL,
	[QrIModifiedBy]		varchar(100) NOT NULL,
	[QrIModifiedDt]		datetime NOT NULL,
	[QrIDelFlg]			[DelFlg] NULL,
	[QrIDelId]			[bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[QrIPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QryIn] ADD  DEFAULT ((0)) FOR [QrIDelId]
GO
ALTER TABLE [dbo].[QryIn]  WITH CHECK ADD FOREIGN KEY([QrIQrdFk]) REFERENCES [dbo].[QryDtls] ([QrdPk])
GO
ALTER TABLE [dbo].[QryIn]  WITH CHECK ADD FOREIGN KEY([QrIQrOFk]) REFERENCES [dbo].[QryOut] ([QrOPk])
GO
ALTER TABLE [dbo].[QryIn]  WITH CHECK ADD FOREIGN KEY([QrIUsrFk]) REFERENCES [dbo].[ShflUsrMas] ([UsrPk])
GO