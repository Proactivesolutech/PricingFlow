CREATE TABLE [dbo].[GenScrnMas](
	[GsmSid]			int		NOT NULL,
	[GsmNm]				varchar(100) NOT NULL,
	[GsmPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[GsmRowId]			[dbo].[RowId] NOT NULL,
	[GsmCreatedDt]		[datetime] NULL,
	[GsmCreatedBy]		varchar(100) NOT NULL,
	[GsmModifiedDt]		[datetime] NULL,
	[GsmModifiedBy]		varchar(100) NOT NULL,
	[GsmDelFlg]			[dbo].[DelFlg] NULL,
	[GsmDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[GsmPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenScrnMas] ADD  DEFAULT ((0)) FOR [GsmDelId]
GO

CREATE TABLE [dbo].[GenGeoMas](
	[GeoNm]				[varchar](100) NULL,
	[GeoLvlNo]			[int] NULL,
	[GeoPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[GeoRowId]			[dbo].[RowId] NOT NULL,
	[GeoCreatedDt]		[datetime] NULL,
	[GeoCreatedBy]		varchar(100) NOT NULL,
	[GeoModifiedDt]		[datetime] NULL,
	[GeoModifiedBy]		varchar(100) NOT NULL,
	[GeoDelFlg]			[dbo].[DelFlg] NULL,
	[GeoDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[GeoPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenGeoMas] ADD  DEFAULT ((0)) FOR [GeoDelId]
GO

CREATE TABLE [dbo].[GenGeoMap](
	[GemGeoBFk]			[dbo].[FkId] NOT NULL,
	[GemGeoZFk]			[dbo].[FkId] NOT NULL,
	[GemGeoSFk]			[dbo].[FkId] NOT NULL,
	[GemGeoCFk]			[dbo].[FkId] NOT NULL,
	[GemPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[GemRowId]			[dbo].[RowId] NOT NULL,
	[GemCreatedDt]		[datetime] NOT NULL,
	[GemCreatedBy]		varchar(100) NOT NULL,
	[GemModifiedDt]		[datetime] NOT NULL,
	[GemModifiedBy]		varchar(100) NOT NULL,
	[GemDelFlg]			[dbo].[DelFlg] NULL,
	[GemDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[GemPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenGeoMap] ADD  DEFAULT ((0)) FOR [GemDelId]
GO
ALTER TABLE [dbo].[GenGeoMap]  WITH CHECK ADD FOREIGN KEY([GemGeoBFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[GenGeoMap]  WITH CHECK ADD FOREIGN KEY([GemGeoZFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[GenGeoMap]  WITH CHECK ADD FOREIGN KEY([GemGeoSFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO
ALTER TABLE [dbo].[GenGeoMap]  WITH CHECK ADD FOREIGN KEY([GemGeoCFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO

CREATE TABLE [dbo].[GenPrdMas](
	[PrdCd]				[varchar](50) NULL,
	[PrdNm]				[varchar](100) NULL,
	[PrdPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[PrdRowId]			[dbo].[RowId] NOT NULL,
	[PrdCreatedDt]		[datetime] NULL,
	[PrdCreatedBy]		varchar(100) NOT NULL,
	[PrdModifiedDt]		[datetime] NULL,
	[PrdModifiedBy]		varchar(100) NOT NULL,
	[PrdDelFlg]			[dbo].[DelFlg] NULL,
	[PrdDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PrdPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenPrdMas] ADD  DEFAULT ((0)) FOR [PrdDelId]
GO

CREATE TABLE [dbo].[GenRole](
	[RolNm]				[varchar](100) NULL,
	[RolLvlNo]			[int] NULL,
	[RolPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[RolRowId]			[dbo].[RowId] NOT NULL,
	[RolCreatedDt]		[datetime] NULL,
	[RolCreatedBy]		varchar(100) NOT NULL,
	[RolModifiedDt]		[datetime] NULL,
	[RolModifiedBy]		varchar(100) NOT NULL,
	[RolDelFlg]			[dbo].[DelFlg] NULL,
	[RolDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RolPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenRole] ADD  DEFAULT ((0)) FOR [RolDelId]
GO

CREATE TABLE [dbo].[GenUsrMas](
	[UsrNm]				[varchar](50) NULL,
	[UsrDispNm]			[varchar](100) NULL,
	[UsrPwd]			[varchar](max) NULL,
	[UsrPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[UsrRowId]			[dbo].[RowId] NOT NULL,
	[UsrCreatedDt]		[datetime] NULL,
	[UsrCreatedBy]		varchar(100) NOT NULL,
	[UsrModifiedDt]		[datetime] NULL,
	[UsrModifiedBy]		varchar(100) NOT NULL,
	[UsrDelFlg]			[dbo].[DelFlg] NULL,
	[UsrDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UsrPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenUsrMas] ADD  DEFAULT ((0)) FOR [UsrDelId]
GO

CREATE TABLE [dbo].[GenUsrBrnDtls](
	[UbdUsrFk]			[dbo].[FkId] NOT NULL,
	[UbdGeoFk]			[dbo].[FkId] NOT NULL,
	[UbdPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[UbdRowId]			[dbo].[RowId] NOT NULL,
	[UbdCreatedDt]		[datetime] NULL,
	[UbdCreatedBy]		varchar(100) NOT NULL,
	[UbdModifiedDt]		[datetime] NULL,
	[UbdModifiedBy]		varchar(100) NOT NULL,
	[UbdDelFlg]			[dbo].[DelFlg] NULL,
	[UbdDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UbdPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenUsrBrnDtls] ADD  DEFAULT ((0)) FOR [UbdDelId]
GO
ALTER TABLE [dbo].[GenUsrBrnDtls]  WITH CHECK ADD FOREIGN KEY([UbdUsrFk]) REFERENCES [dbo].[GenUsrMas] ([UsrPk])
GO
ALTER TABLE [dbo].[GenUsrBrnDtls]  WITH CHECK ADD FOREIGN KEY([UbdGeoFk]) REFERENCES [dbo].[GenGeoMas] ([GeoPk])
GO

CREATE TABLE [dbo].[GenUsrRoleDtls](
	[UrdUsrFk]			[dbo].[FkId] NOT NULL,
	[UrdRolFk]			[dbo].[FkId] NOT NULL,
	[UrdPk]				[dbo].[PkId] IDENTITY(1,1) NOT NULL,
	[UrdRowId]			[dbo].[RowId] NOT NULL,
	[UrdCreatedDt]		[datetime] NULL,
	[UrdCreatedBy]		varchar(100) NOT NULL,
	[UrdModifiedDt]		[datetime] NULL,
	[UrdModifiedBy]		varchar(100) NOT NULL,
	[UrdDelFlg]			[dbo].[DelFlg] NULL,
	[UrdDelId]			[bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UrdPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenUsrRoleDtls] ADD  DEFAULT ((0)) FOR [UrdDelId]
GO
ALTER TABLE [dbo].[GenUsrRoleDtls]  WITH CHECK ADD FOREIGN KEY([UrdUsrFk]) REFERENCES [dbo].[GenUsrMas] ([UsrPk])
GO
ALTER TABLE [dbo].[GenUsrRoleDtls]  WITH CHECK ADD FOREIGN KEY([UrdRolFk]) REFERENCES [dbo].[GenRole] ([RolPk])
GO

CREATE TABLE [dbo].[GenLog](
	[LogActDate] [datetime] NOT NULL,
	[LogUser] [varchar](100) NOT NULL,
	[LogTrsTyp] [tinyint] NOT NULL,
	[LogSID] [int] NOT NULL,
	[LogRefFk] [dbo].[FkId] NULL,
	[LogQry] [varchar](max) NOT NULL,
	[LogSts] [tinyint] NOT NULL,
	[LogErrMsg] [varchar](max) NULL,
	[LogIpDynAdd] [char](20) NULL,
	[LogIpMcAdd] [char](20) NOT NULL,
	[LogMobRDesk] [tinyint] NOT NULL,
	[LogBrowser] [varchar](max) NOT NULL,
	[LogLongitude] [varchar](50) NOT NULL,
	[LogLatitude] [varchar](50) NOT NULL,
	[LogArea] [varchar](max) NULL,
	[LogCity] [varchar](100) NOT NULL,
	[LogState] [varchar](100) NOT NULL,
	[LogCountry] [varchar](100) NOT NULL,
	[LogPk] [dbo].[PkId] IDENTITY(1,1) NOT NULL,
CONSTRAINT [PK_GenLog] PRIMARY KEY CLUSTERED 
(
	[LogPk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
