USE [TravelDataBase]
GO
/****** Object:  StoredProcedure [dbo].[Proc_CommonPagingStoredProcedure]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------
--  desc: 通用分页存储过程			
---------------------------------------------------

CREATE PROCEDURE [dbo].[Proc_CommonPagingStoredProcedure]
@Tables nvarchar(1000),			--表名,多表请使用 tableA a inner join tableB b On a.AID = b.AID
@PK nvarchar(100),				--主键，可以带表头 a.AID
@Sort nvarchar(200) = '',		--排序字段
@PageNumber int = 1,			--开始页码
@PageSize int = 10,				--页大小
@Fields nvarchar(1000) = '*',	--读取字段
@Filter nvarchar(1000) = NULL,	--Where条件
@isCount bit = 0  ,   --1		--是否获得总记录数
@Total	int output
AS

DECLARE @strFilter nvarchar(2000)
declare @sql Nvarchar(max)
IF @Filter IS NOT NULL AND @Filter != ''
  BEGIN
   SET @strFilter = ' WHERE 1=1 ' + @Filter + ' '
  END
ELSE
  BEGIN
   SET @strFilter = ' '
  END
if @isCount = 1 --获得记录条数
    begin
		Declare @CountSql Nvarchar(max) 
		Set @CountSql = 'SELECT @TotalCount= Count(1) FROM ' + @Tables + @strFilter 
		Execute sp_executesql @CountSql,N'@TotalCount int output',@TotalCount= @Total Output 
		-- 针对groupby后无数据时，@Total会变为null
		if @Total is null
			begin
				set @Total = 0
			end
    end
    
if @Sort is null or @Sort = ''''
  set @Sort = @PK + ' DESC '

IF @PageNumber < 1
  SET @PageNumber = 1

if @PageNumber = 1 --第一页提高性能
begin 
  set @sql = 'select top ' + str(@PageSize) +' '+@Fields+ '  from ' + @Tables + ' ' + @strFilter + ' ORDER BY  '+ @Sort 
end 
else
  begin   
	DECLARE @START_ID varchar(50)
	DECLARE @END_ID varchar(50) 


	SET @START_ID = convert(varchar(50),(@PageNumber - 1) * @PageSize + 1)
	SET @END_ID = convert(varchar(50),@PageNumber * @PageSize)
    set @sql =  ' SELECT * '+
   'FROM (SELECT ROW_NUMBER() OVER(ORDER BY '+@Sort+') AS rownum, 
     '+@Fields+ '
      FROM '+@Tables+ @strFilter +' ) AS D
   Where rownum >= '+@START_ID+' AND  rownum <=' +@END_ID +' ORDER BY '+substring(@Sort,charindex('.',@Sort)+1,len(@Sort)-charindex('.',@Sort))
  END
 

EXEC(@sql)
GO
/****** Object:  Table [dbo].[Account]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AccountNo] [nvarchar](20) NULL,
	[Password] [nvarchar](50) NULL,
	[UserId] [int] NULL,
	[CreateTime] [datetime] NULL,
	[ModifyTime] [datetime] NULL,
	[Enabled] [int] NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Categories]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CityArea]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CityArea](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CityName] [nvarchar](50) NULL,
	[ProvinceFlag] [int] NULL,
 CONSTRAINT [PK_CityArea] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CommentInfo]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommentInfo](
	[Id] [nvarchar](50) NOT NULL,
	[CommentDate] [datetime] NULL,
	[ComentDetail] [nvarchar](255) NULL,
	[CommentLevel] [int] NULL,
	[NewsId] [int] NULL,
	[UserId] [int] NULL,
	[Enabled] [bit] NULL,
	[UserName] [nvarchar](20) NULL,
	[Support] [int] NULL,
	[UnSupport] [int] NULL,
 CONSTRAINT [PK_CommentInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewsDetails]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Details] [text] NULL,
	[ImageUrl] [nvarchar](50) NULL,
	[PublishTime] [datetime] NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_NewsDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewsInfo]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NewsContent] [text] NULL,
	[NewsTheme] [nvarchar](50) NULL,
	[NewsTitle] [nvarchar](50) NULL,
	[CreateTime] [datetime] NULL,
	[NewsAuthor] [nvarchar](20) NULL,
	[modifyTime] [datetime] NULL,
 CONSTRAINT [PK_NewsInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewsList]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TrTitle] [nvarchar](50) NULL,
	[ReportTime] [datetime] NULL,
	[Descript] [nvarchar](300) NULL,
	[NewsType] [int] NULL,
	[ImageUrl] [nvarchar](50) NULL,
	[UserId] [int] NULL,
	[Recommend] [int] NULL,
	[ExpireTime] [datetime] NULL,
	[DetailId] [int] NULL,
	[UserName] [nvarchar](10) NULL,
	[CommentId] [int] NULL,
 CONSTRAINT [PK_NewsList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NewTitleInfo]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewTitleInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DiscriptTitle] [text] NULL,
	[NewTitle] [nvarchar](50) NULL,
	[CrateTime] [datetime] NULL,
	[ModifyTime] [datetime] NULL,
	[NewsId] [int] NULL,
	[AuthorName] [nvarchar](50) NULL,
 CONSTRAINT [PK_NewTitleInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProvinceCity]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProvinceCity](
	[Id] [int] NOT NULL,
	[ParentId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Sort] [int] NOT NULL,
 CONSTRAINT [PK__Province__3214EC07F9908615] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Resource]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ResourceName] [nvarchar](20) NULL,
	[FileName] [nvarchar](50) NULL,
	[FilePath] [nvarchar](50) NULL,
	[ImagePath] [nvarchar](250) NULL,
	[NewListId] [int] NULL,
	[ConvertStatus] [int] NULL,
	[UserId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
	[Flag] [int] NULL,
 CONSTRAINT [PK_Resource] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ResourceInfo]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResourceInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BeforPath] [nvarchar](50) NULL,
	[FileName] [nvarchar](20) NULL,
	[NewName] [nvarchar](20) NULL,
	[PathAll] [nvarchar](50) NULL,
	[CrateTime] [datetime] NULL,
	[Enabled] [int] NULL,
	[NewsId] [int] NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_ResourceInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TEncashment]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEncashment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FCreateTime] [datetime] NOT NULL,
	[FOrderFlowNum] [nvarchar](50) NOT NULL,
	[FApplyAmount] [decimal](19, 4) NOT NULL,
	[FBeforeBalance] [decimal](19, 4) NOT NULL,
	[FAfterBalance] [decimal](19, 4) NOT NULL,
	[FPrivilege] [int] NOT NULL,
	[FUserName] [nvarchar](18) NOT NULL,
	[FApplyCarNo] [nvarchar](20) NOT NULL,
	[FApplyBankName] [nvarchar](20) NOT NULL,
	[FUpdateTime] [datetime] NOT NULL,
	[FApplyStatus] [int] NOT NULL,
	[FThirdOrderId] [nvarchar](20) NOT NULL,
	[FIpAddress] [nvarchar](30) NOT NULL,
	[FPhoneNum] [nvarchar](20) NOT NULL,
	[FProvince] [nvarchar](20) NOT NULL,
	[FCity] [nvarchar](20) NOT NULL,
	[FReserved1] [nvarchar](50) NOT NULL,
	[FReserved2] [nvarchar](50) NULL,
 CONSTRAINT [PK_TEncashment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TOrders]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TOrderNumber] [nvarchar](50) NOT NULL,
	[TPayee] [nvarchar](50) NOT NULL,
	[TPayAccNum] [nvarchar](38) NOT NULL,
	[TPayNum] [int] NOT NULL,
	[TPayMerchantName] [nvarchar](50) NOT NULL,
	[TPayMerchantType] [int] NOT NULL,
	[TAmount] [decimal](19, 4) NOT NULL,
	[TEffectAmount] [decimal](19, 4) NOT NULL,
	[FCharge] [decimal](19, 4) NOT NULL,
	[FCreateTime] [datetime] NOT NULL,
	[FOrderStatus] [int] NOT NULL,
	[FOrderBackStatus] [int] NOT NULL,
	[FOrderBackNum] [int] NOT NULL,
 CONSTRAINT [PK_TOrders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TPaymentProvider]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TPaymentProvider](
	[FID] [int] IDENTITY(1,1) NOT NULL,
	[FCompanyID] [int] NOT NULL,
	[FMerchantId] [int] NOT NULL,
	[FMerchantName] [nvarchar](50) NOT NULL,
	[FMerchantCode] [varchar](50) NOT NULL,
	[FMerchantAccount] [varchar](50) NOT NULL,
	[FMerchantKey] [varchar](4096) NULL,
	[FMemberGroupID] [varchar](100) NOT NULL,
	[FDisableAmount] [decimal](19, 4) NOT NULL,
	[FCardType] [nvarchar](50) NOT NULL,
	[FOrder] [int] NULL,
	[FStatus] [int] NOT NULL,
	[FLastUpdateUserId] [int] NULL,
	[FLastUpdateTime] [datetime] NULL,
	[FCurrentAmount] [decimal](19, 4) NULL,
	[FTotalAmount] [decimal](19, 4) NULL,
	[FPayBuildDomain] [varchar](200) NULL,
	[FPayBackDomain] [varchar](200) NULL,
	[FEncryptionPassword] [varchar](4096) NULL,
	[FPayType] [varchar](200) NULL,
	[FSupportClearing] [bit] NULL,
	[FBankCode] [varchar](100) NULL,
	[FBankConfig] [varchar](2000) NULL,
	[FMallDomain] [varchar](500) NULL,
	[FQueryDomain] [varchar](500) NULL,
	[FRemitDomain] [varchar](500) NULL,
	[FMaxDepositAmount] [decimal](19, 4) NULL,
	[FMinDepositAmount] [decimal](19, 4) NULL,
	[FDepositAmount] [decimal](19, 4) NULL,
	[FShowName] [nvarchar](50) NULL,
	[FIsSupportWap] [bit] NOT NULL,
	[FWapPayBuildDomain] [varchar](200) NULL,
	[FWapPayType] [varchar](50) NULL,
	[FPayBackIP] [varchar](5000) NULL,
	[FIsCharge] [bit] NULL,
	[FCharge] [decimal](19, 4) NULL,
	[FCollectFee] [decimal](19, 4) NULL,
	[FHomeView] [varchar](50) NULL,
	[FDrawNotityUrl] [varchar](255) NULL,
	[FDrawSubmitUrl] [varchar](255) NULL,
	[FDrawQueryUrl] [varchar](255) NULL,
	[FIsDepositAddRandom] [bit] NULL,
	[FDeviceType] [int] NOT NULL,
	[FWayType] [int] NOT NULL,
	[FSettlementCycle] [varchar](100) NULL,
	[FDepositRandomNum] [int] NULL,
	[FDrawBankConfig] [varchar](5000) NULL,
	[FConfigurationName] [varchar](200) NULL,
	[FCompanyGroupID] [varchar](8000) NULL,
	[FCompanyPay] [bit] NULL,
	[FIsCode] [bit] NULL,
	[IsShowName] [int] NULL,
	[FIsShowShortcut] [bit] NULL,
	[FShortcutSet] [varchar](max) NULL,
	[FDrawKey] [varchar](5000) NULL,
 CONSTRAINT [PK_TPaymentProvider] PRIMARY KEY CLUSTERED 
(
	[FID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TravelStrategy]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TravelStrategy](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NULL,
	[Author] [nvarchar](20) NULL,
	[PublisherId] [int] NULL,
	[PublishDate] [datetime] NULL,
	[ISBN] [nvarchar](50) NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[ContentDescription] [nvarchar](max) NULL,
	[AurhorDescription] [nvarchar](300) NULL,
	[EditorComment] [nvarchar](300) NULL,
	[TOC] [nvarchar](max) NULL,
	[CategoryId] [int] NULL,
	[AreaCategoyId] [int] NULL,
	[Click] [int] NULL,
 CONSTRAINT [PK_TravelStrategy] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserInfo]    Script Date: 2018/9/15 1:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](20) NULL,
	[Role] [int] NOT NULL,
	[CrateTime] [datetime] NULL,
	[FBanTime] [datetime] NULL,
	[FStatus] [int] NOT NULL,
	[FIpAddress] [nvarchar](50) NULL,
	[FBalance] [decimal](19, 4) NOT NULL,
 CONSTRAINT [PK_UserInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Account] ON 

GO
INSERT [dbo].[Account] ([Id], [AccountNo], [Password], [UserId], [CreateTime], [ModifyTime], [Enabled]) VALUES (1, N'sa', N'202cb962ac59075b964b07152d234b70', 1, CAST(0x0000A56300000000 AS DateTime), CAST(0x0000A9590025F2FE AS DateTime), 1)
GO
INSERT [dbo].[Account] ([Id], [AccountNo], [Password], [UserId], [CreateTime], [ModifyTime], [Enabled]) VALUES (2, N'mic', N'202cb962ac59075b964b07152d234b70', 2, CAST(0x0000A955018A8053 AS DateTime), CAST(0x0000A95B00D77370 AS DateTime), 0)
GO
INSERT [dbo].[Account] ([Id], [AccountNo], [Password], [UserId], [CreateTime], [ModifyTime], [Enabled]) VALUES (3, N'laomi', N'202cb962ac59075b964b07152d234b70', 3, CAST(0x0000A95600E6A5AA AS DateTime), CAST(0x0000A95600FDE48C AS DateTime), 0)
GO
INSERT [dbo].[Account] ([Id], [AccountNo], [Password], [UserId], [CreateTime], [ModifyTime], [Enabled]) VALUES (4, N'mic1', N'202cb962ac59075b964b07152d234b70', 4, CAST(0x0000A958018900B3 AS DateTime), CAST(0x0000A958018900B3 AS DateTime), 0)
GO
INSERT [dbo].[Account] ([Id], [AccountNo], [Password], [UserId], [CreateTime], [ModifyTime], [Enabled]) VALUES (5, N'mic2', N'202cb962ac59075b964b07152d234b70', 5, CAST(0x0000A95801895D31 AS DateTime), CAST(0x0000A95801895D31 AS DateTime), 0)
GO
INSERT [dbo].[Account] ([Id], [AccountNo], [Password], [UserId], [CreateTime], [ModifyTime], [Enabled]) VALUES (6, N'mic031', N'202cb962ac59075b964b07152d234b70', 6, CAST(0x0000A95900262B63 AS DateTime), CAST(0x0000A95900262B63 AS DateTime), 0)
GO
SET IDENTITY_INSERT [dbo].[Account] OFF
GO
SET IDENTITY_INSERT [dbo].[Categories] ON 

GO
INSERT [dbo].[Categories] ([Id], [Name]) VALUES (1, N'难度5星')
GO
INSERT [dbo].[Categories] ([Id], [Name]) VALUES (2, N'难度4星')
GO
INSERT [dbo].[Categories] ([Id], [Name]) VALUES (3, N'难度3星')
GO
INSERT [dbo].[Categories] ([Id], [Name]) VALUES (4, N'难度2星')
GO
INSERT [dbo].[Categories] ([Id], [Name]) VALUES (5, N'难度1星')
GO
SET IDENTITY_INSERT [dbo].[Categories] OFF
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'1d49ca0e-8b74-44b0-ad8a-16048ee7ec91', CAST(0x0000A6E6013110C8 AS DateTime), N'this is my test comment05', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'298925f1-89ea-4223-a38b-f3a3d6ca7aec', CAST(0x0000A6E601253A0F AS DateTime), N'this is my test comment01', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'59629c25-13c7-4996-9339-fc7b13203e94', CAST(0x0000A82200BDB4C2 AS DateTime), N'122222222222', 0, 1, 0, 0, N'122', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'6eb14b36-51f7-4e5c-857f-404700bc14a9', CAST(0x0000A6E60124DFBB AS DateTime), N'aaaaaaaaaaaaaaaaaaaaaa', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'9f340213-b8bd-4c55-a903-c96a41eab5a9', CAST(0x0000A6E7010F0FF0 AS DateTime), N'打雷啦，快收衣服啦', 0, 1, 0, 0, N'刘备', 1, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'a10751e9-92ac-4733-8ad9-bb5a74a00dd9', CAST(0x0000A6E601246192 AS DateTime), N'123asdfasdf', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'a64547dd-54a0-4269-b498-53f53948a19f', CAST(0x0000A6E60132EDBA AS DateTime), N'this is my test comment06', 0, 5, 0, 0, N'诸葛亮', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'a9e01bf9-4ae2-42d4-a275-a7a929b534a4', CAST(0x0000A6E60122877D AS DateTime), N'123123', 0, 3, 0, 0, N'sa', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'eb12c611-b601-433b-9dfb-7b0c2f2c1b2d', CAST(0x0000A6E60130F698 AS DateTime), N'this is my test comment04', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'f390b4aa-d258-4492-9c1a-84bea2ae6f3a', CAST(0x0000A6E60130EB98 AS DateTime), N'this is my test comment03', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
INSERT [dbo].[CommentInfo] ([Id], [CommentDate], [ComentDetail], [CommentLevel], [NewsId], [UserId], [Enabled], [UserName], [Support], [UnSupport]) VALUES (N'fbcc0de5-56d5-48bd-af4a-5a9c18429ec1', CAST(0x0000A6E60130DB7A AS DateTime), N'this is my test comment02', 0, 5, 0, 0, N'miczhou', 0, 0)
GO
SET IDENTITY_INSERT [dbo].[NewsDetails] ON 

GO
INSERT [dbo].[NewsDetails] ([Id], [Details], [ImageUrl], [PublishTime], [UserId]) VALUES (1, N'<p>
                    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?
                </p>', N'/content/images/subsys/blog/blog-thumb-1.jpg', CAST(0x0000A6CB00000000 AS DateTime), 1)
GO
INSERT [dbo].[NewsDetails] ([Id], [Details], [ImageUrl], [PublishTime], [UserId]) VALUES (2, N'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', N'', CAST(0x0000A6E101874F0F AS DateTime), 1)
GO
INSERT [dbo].[NewsDetails] ([Id], [Details], [ImageUrl], [PublishTime], [UserId]) VALUES (3, N'<p><img alt="" src="\UploadFiles\草鸡棒\52\cat2.jpg" style="width: 100px; height: 150px; border-width: 0px; border-style: solid; margin-left: 0px; margin-right: 0px; float: left;" />在哪遥远的aasdjflasjd就</p>

<p style="box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: &quot;Open Sans&quot;, sans-serif;">Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?</p>

<p style="box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: &quot;Open Sans&quot;, sans-serif;">Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?</p>

<blockquote style="box-sizing: border-box; padding-top: 10px; padding-right: 20px; padding-bottom: 10px; margin: 0px 0px 20px 50px; font-size: 17.5px; border-left-color: rgb(238, 238, 238); color: rgb(161, 161, 161); font-family: &quot;Open Sans&quot;, sans-serif;">
<p style="box-sizing: border-box; margin: 0px; line-height: 30px; padding-bottom: 15px; font-size: 14px;">Vestibulum id ligula porta felis euismod semper. Sed posuere consectetur est at lobortis. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Duis mollis, est non commodo luctus, nisi erat port titor ligula, eget lacinia odio sem nec elit.</p>
</blockquote>

<p style="box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: &quot;Open Sans&quot;, sans-serif;">consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.</p>
', N'', CAST(0x0000A6E10189D9F7 AS DateTime), 1)
GO
INSERT [dbo].[NewsDetails] ([Id], [Details], [ImageUrl], [PublishTime], [UserId]) VALUES (4, N'<p><img alt="" src="\UploadFiles\草鸡棒\52\cat2.jpg" style="width: 100px; height: 150px; border-width: 0px; border-style: solid; margin-left: 0px; margin-right: 0px; float: left;" />在哪遥远的aasdjflasjd就</p>

<p open="" style="box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: ">Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?</p>

<p open="" style="box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: ">Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?</p>

<blockquote open="" style="box-sizing: border-box; padding-top: 10px; padding-right: 20px; padding-bottom: 10px; margin: 0px 0px 20px 50px; font-size: 17.5px; border-left-color: rgb(238, 238, 238); color: rgb(161, 161, 161); font-family: ">
<p style="box-sizing: border-box; margin: 0px; line-height: 30px; padding-bottom: 15px; font-size: 14px;">Vestibulum id ligula porta felis euismod semper. Sed posuere consectetur est at lobortis. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Duis mollis, est non commodo luctus, nisi erat port titor ligula, eget lacinia odio sem nec elit.</p>
</blockquote>

<p open="" style="box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: ">consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.</p>
', N'', CAST(0x0000A6E40179E8A7 AS DateTime), 1)
GO
INSERT [dbo].[NewsDetails] ([Id], [Details], [ImageUrl], [PublishTime], [UserId]) VALUES (5, N'&lt;p&gt;&amp;lt;p&amp;gt;&amp;lt;img alt=&amp;quot;&amp;quot; src=&amp;quot;\UploadFiles\草鸡棒\52\cat2.jpg&amp;quot; style=&amp;quot;width: 100px; height: 150px; border-width: 0px; border-style: solid; margin-left: 0px; margin-right: 0px; float: left;&amp;quot; /&amp;gt;在哪遥远的aasdjflasjd就&amp;lt;/p&amp;gt;&lt;/p&gt;

&lt;p&gt;&amp;lt;p open=&amp;quot;&amp;quot; style=&amp;quot;box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: &amp;quot;&amp;gt;Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?&amp;lt;/p&amp;gt;&lt;/p&gt;

&lt;p&gt;&amp;lt;p open=&amp;quot;&amp;quot; style=&amp;quot;box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: &amp;quot;&amp;gt;Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?&amp;lt;/p&amp;gt;&lt;/p&gt;

&lt;p&gt;&amp;lt;blockquote open=&amp;quot;&amp;quot; style=&amp;quot;box-sizing: border-box; padding-top: 10px; padding-right: 20px; padding-bottom: 10px; margin: 0px 0px 20px 50px; font-size: 17.5px; border-left-color: rgb(238, 238, 238); color: rgb(161, 161, 161); font-family: &amp;quot;&amp;gt;&lt;br /&gt;
&amp;lt;p style=&amp;quot;box-sizing: border-box; margin: 0px; line-height: 30px; padding-bottom: 15px; font-size: 14px;&amp;quot;&amp;gt;Vestibulum id ligula porta felis euismod semper. Sed posuere consectetur est at lobortis. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Duis mollis, est non commodo luctus, nisi erat port titor ligula, eget lacinia odio sem nec elit.&amp;lt;/p&amp;gt;&lt;br /&gt;
&amp;lt;/blockquote&amp;gt;&lt;/p&gt;

&lt;p&gt;&amp;lt;p open=&amp;quot;&amp;quot; style=&amp;quot;box-sizing: border-box; margin: 0px 0px 10px; padding-bottom: 15px; font-size: 14px; color: rgb(122, 118, 118); font-family: &amp;quot;&amp;gt;consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.&amp;lt;/p&amp;gt;&lt;/p&gt;
', N'', CAST(0x0000A6E4017AA6C9 AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[NewsDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[NewsList] ON 

GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (1, N'大南山', CAST(0x0000A6C600000000 AS DateTime), N'大南山风景秀丽，欢迎大家来玩', 1, N'/content/images/subsys/blog/blog-thumb-1.jpg', 1, 2, CAST(0x0000A6CB00000000 AS DateTime), 1, N'草鸡棒', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (2, N'马峦山', CAST(0x0000A69C00000000 AS DateTime), N'马峦山郊野公园好玩', 1, N'/content/images/subsys/blog/blog-thumb-2.jpg', 1, 2, CAST(0x0000A65C00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (3, N'梧桐山', CAST(0x0000A5FE00000000 AS DateTime), N'深圳第一高峰，大家踊跃参与', 1, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡棒', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (4, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (5, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 2, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (6, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 3, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (7, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 4, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (8, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 5, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (9, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (10, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (11, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (12, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (13, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (14, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (15, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
INSERT [dbo].[NewsList] ([Id], [TrTitle], [ReportTime], [Descript], [NewsType], [ImageUrl], [UserId], [Recommend], [ExpireTime], [DetailId], [UserName], [CommentId]) VALUES (16, N'惠州三水', CAST(0x0000A46F00000000 AS DateTime), N'惠州白水寨，是名副其实的旅游露营圣地，小伙伴们还在担心什么赶紧来吧', 2, N'/content/images/subsys/blog/blog-thumb-3.jpg', 1, 2, CAST(0x0000A65D00000000 AS DateTime), 1, N'草鸡帮', 1)
GO
SET IDENTITY_INSERT [dbo].[NewsList] OFF
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (100, 0, N'安徽', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (101, 100, N'合肥', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (102, 100, N'安庆', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (103, 100, N'毫州', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (104, 100, N'蚌埠', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (105, 100, N'滁州', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (106, 100, N'巢湖', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (107, 100, N'池州', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (108, 100, N'阜阳', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (109, 100, N'淮北', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (110, 100, N'淮南', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (111, 100, N'黄山站', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (112, 100, N'六安', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (113, 100, N'马鞍山', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (114, 100, N'宿州', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (115, 100, N'铜陵', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (116, 100, N'芜湖', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (117, 100, N'宣城', 1)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (200, 0, N'澳门', 2)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (300, 0, N'北京', 3)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (400, 0, N'重庆', 4)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (500, 0, N'福建', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (501, 500, N'福州', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (502, 500, N'龙岩', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (503, 500, N'南平', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (504, 500, N'宁德', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (505, 500, N'莆田', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (506, 500, N'泉州', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (507, 500, N'三明', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (508, 500, N'厦门', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (509, 500, N'漳州', 5)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (600, 0, N'甘肃', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (601, 600, N'兰州', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (602, 600, N'白银', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (603, 600, N'定西', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (604, 600, N'合作', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (605, 600, N'金昌', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (606, 600, N'酒泉', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (607, 600, N'嘉峪关', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (608, 600, N'临夏', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (609, 600, N'平凉', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (610, 600, N'庆阳', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (611, 600, N'天水', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (612, 600, N'武威', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (613, 600, N'武都', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (614, 600, N'张掖', 6)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (700, 0, N'广东', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (701, 700, N'广州', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (702, 700, N'潮州', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (703, 700, N'东莞', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (704, 700, N'佛山', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (705, 700, N'河源', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (706, 700, N'惠州', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (707, 700, N'江门', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (708, 700, N'揭阳', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (709, 700, N'梅州', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (710, 700, N'茂名', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (711, 700, N'清远', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (712, 700, N'深圳', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (713, 700, N'汕头', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (714, 700, N'韶关', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (715, 700, N'汕尾', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (716, 700, N'阳江', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (717, 700, N'云浮', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (718, 700, N'珠海', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (719, 700, N'中山', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (720, 700, N'湛江', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (721, 700, N'肇庆', 7)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (800, 0, N'广西', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (801, 800, N'南宁', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (802, 800, N'北海', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (803, 800, N'白色', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (804, 800, N'崇左', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (805, 800, N'防城港', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (806, 800, N'桂林', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (807, 800, N'贵港', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (808, 800, N'贺州', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (809, 800, N'河池', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (810, 800, N'柳州', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (811, 800, N'来宾', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (812, 800, N'钦州', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (813, 800, N'梧州', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (814, 800, N'玉林', 8)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (900, 0, N'贵州', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (901, 900, N'贵阳', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (902, 900, N'安顺', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (903, 900, N'毕节', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (904, 900, N'都匀', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (905, 900, N'凯里', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (906, 900, N'六盘水', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (907, 900, N'晴隆', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (908, 900, N'铜仁', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (909, 900, N'兴义', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (910, 900, N'遵义', 9)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1000, 0, N'海南', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1001, 1000, N'海口', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1002, 1000, N'白沙', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1003, 1000, N'保亭', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1004, 1000, N'澄迈', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1005, 1000, N'昌江', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1006, 1000, N'儋州', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1007, 1000, N'定安', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1008, 1000, N'东方', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1009, 1000, N'临高', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1010, 1000, N'陵水', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1011, 1000, N'乐东', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1012, 1000, N'南沙岛', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1013, 1000, N'琼海', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1014, 1000, N'琼中', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1015, 1000, N'三亚', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1016, 1000, N'屯昌', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1017, 1000, N'五指山', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1018, 1000, N'文昌', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1019, 1000, N'万宁', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1020, 1000, N'西沙', 10)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1100, 0, N'河北', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1101, 1100, N'石家庄', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1102, 1100, N'保定', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1103, 1100, N'承德', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1104, 1100, N'沧州', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1105, 1100, N'衡水', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1106, 1100, N'邯郸', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1107, 1100, N'廊坊', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1108, 1100, N'秦皇岛', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1109, 1100, N'唐山', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1110, 1100, N'邢台', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1111, 1100, N'张家口', 11)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1200, 0, N'河南', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1201, 1200, N'郑州', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1202, 1200, N'安阳', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1203, 1200, N'鹤壁', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1204, 1200, N'焦作', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1205, 1200, N'济源', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1206, 1200, N'开封', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1207, 1200, N'洛阳', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1208, 1200, N'漯河', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1209, 1200, N'南阳', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1210, 1200, N'濮阳', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1211, 1200, N'平顶山', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1212, 1200, N'三门峡', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1213, 1200, N'商丘', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1214, 1200, N'新乡', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1215, 1200, N'许昌', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1216, 1200, N'信阳', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1217, 1200, N'周口', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1218, 1200, N'驻马店', 12)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1300, 0, N'黑龙江', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1301, 1300, N'哈尔滨', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1302, 1300, N'大庆', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1303, 1300, N'大兴安岭', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1304, 1300, N'鹤岗', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1305, 1300, N'黑河', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1306, 1300, N'佳木斯', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1307, 1300, N'鸡西', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1308, 1300, N'牡丹江', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1309, 1300, N'齐齐哈尔', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1310, 1300, N'七台河', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1311, 1300, N'双鸭山', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1312, 1300, N'绥化', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1313, 1300, N'伊春', 13)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1400, 0, N'湖北', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1401, 1400, N'武汉', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1402, 1400, N'鄂州', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1403, 1400, N'恩施', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1404, 1400, N'黄石', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1405, 1400, N'黄冈', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1406, 1400, N'荆州', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1407, 1400, N'荆门', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1408, 1400, N'潜江', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1409, 1400, N'十堰', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1410, 1400, N'随州', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1411, 1400, N'神农架', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1412, 1400, N'天门', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1413, 1400, N'襄阳', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1414, 1400, N'孝感', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1415, 1400, N'咸宁', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1416, 1400, N'仙桃', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1417, 1400, N'宜昌', 14)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1500, 0, N'湖南', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1501, 1500, N'长沙', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1502, 1500, N'常德', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1503, 1500, N'郴州', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1504, 1500, N'衡阳', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1505, 1500, N'怀化', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1506, 1500, N'吉首', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1507, 1500, N'娄底', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1508, 1500, N'黔阳', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1509, 1500, N'邵阳', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1510, 1500, N'湘潭', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1511, 1500, N'岳阳', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1512, 1500, N'益阳', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1513, 1500, N'永州', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1514, 1500, N'株洲', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1515, 1500, N'张家界', 15)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1600, 0, N'吉林', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1601, 1600, N'长春', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1602, 1600, N'白山', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1603, 1600, N'白城', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1604, 1600, N'吉林', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1605, 1600, N'辽源', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1606, 1600, N'四平', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1607, 1600, N'松原', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1608, 1600, N'通化', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1609, 1600, N'延吉', 16)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1700, 0, N'江苏', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1701, 1700, N'南京', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1702, 1700, N'常州', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1703, 1700, N'淮安', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1704, 1700, N'连云港', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1705, 1700, N'南通', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1706, 1700, N'苏州', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1707, 1700, N'宿迁', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1708, 1700, N'秦州', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1709, 1700, N'无锡', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1710, 1700, N'徐州', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1711, 1700, N'盐城', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1712, 1700, N'扬州', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1713, 1700, N'镇江', 17)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1800, 0, N'江西', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1801, 1800, N'南昌', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1802, 1800, N'抚州', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1803, 1800, N'赣州', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1804, 1800, N'九江', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1805, 1800, N'景德镇', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1806, 1800, N'吉安', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1807, 1800, N'萍乡', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1808, 1800, N'上饶', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1809, 1800, N'新余', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1810, 1800, N'鹰潭', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1811, 1800, N'宜春', 18)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1900, 0, N'辽宁', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1901, 1900, N'沈阳', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1902, 1900, N'鞍山', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1903, 1900, N'本溪', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1904, 1900, N'朝阳', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1905, 1900, N'大连', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1906, 1900, N'丹东', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1907, 1900, N'抚顺', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1908, 1900, N'阜新', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1909, 1900, N'葫芦岛', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1910, 1900, N'锦州', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1911, 1900, N'辽阳', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1912, 1900, N'盘锦', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1913, 1900, N'铁岭', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (1914, 1900, N'营口', 19)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2000, 0, N'内蒙古', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2001, 2000, N'呼和浩特', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2002, 2000, N'阿拉善左旗', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2003, 2000, N'包头', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2004, 2000, N'赤峰', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2005, 2000, N'鄂尔多斯', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2006, 2000, N'呼伦贝尔', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2007, 2000, N'集宁', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2008, 2000, N'临河', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2009, 2000, N'通辽', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2010, 2000, N'乌兰浩特', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2011, 2000, N'乌海', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2012, 2000, N'锡林浩特', 20)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2100, 0, N'宁夏', 21)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2101, 2100, N'银川', 21)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2102, 2100, N'固原', 21)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2103, 2100, N'石嘴山', 21)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2104, 2100, N'吴忠', 21)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2105, 2100, N'中卫', 21)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2200, 0, N'青海', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2201, 2200, N'西宁', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2202, 2200, N'果洛', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2203, 2200, N'海东', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2204, 2200, N'海南', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2205, 2200, N'海北', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2206, 2200, N'海西', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2207, 2200, N'黄南', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2208, 2200, N'玉树', 22)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2300, 0, N'山东', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2301, 2300, N'济南', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2302, 2300, N'滨州', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2303, 2300, N'东营', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2304, 2300, N'德州', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2305, 2300, N'菏泽', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2306, 2300, N'济宁', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2307, 2300, N'莱芜', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2308, 2300, N'临沂', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2309, 2300, N'聊城', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2310, 2300, N'青岛', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2311, 2300, N'日照', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2312, 2300, N'泰安', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2313, 2300, N'潍坊', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2314, 2300, N'威海', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2315, 2300, N'烟台', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2316, 2300, N'淄博', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2317, 2300, N'枣庄', 23)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2400, 0, N'山西', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2401, 2400, N'太原', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2402, 2400, N'长治', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2403, 2400, N'大同', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2404, 2400, N'晋城', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2405, 2400, N'晋中', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2406, 2400, N'临汾', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2407, 2400, N'吕梁', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2408, 2400, N'朔州', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2409, 2400, N'忻州', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2410, 2400, N'阳泉', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2411, 2400, N'运城', 24)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2500, 0, N'陕西', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2501, 2500, N'西安', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2502, 2500, N'宝康', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2503, 2500, N'宝鸡', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2504, 2500, N'陈仓', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2505, 2500, N'汉中', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2506, 2500, N'商洛', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2507, 2500, N'铜川', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2508, 2500, N'渭南', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2509, 2500, N'咸阳', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2510, 2500, N'延安', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2511, 2500, N'榆林', 25)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2600, 0, N'上海', 26)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2700, 0, N'四川', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2701, 2700, N'成都', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2702, 2700, N'阿贝', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2703, 2700, N'巴中', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2704, 2700, N'德阳', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2705, 2700, N'达州', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2706, 2700, N'广元', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2707, 2700, N'广安', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2708, 2700, N'甘孜', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2709, 2700, N'泸州', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2710, 2700, N'乐山', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2711, 2700, N'凉山', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2712, 2700, N'绵阳', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2713, 2700, N'眉山', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2714, 2700, N'内江', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2715, 2700, N'南充', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2716, 2700, N'攀枝花', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2717, 2700, N'遂宁', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2718, 2700, N'宜宾', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2719, 2700, N'雅安', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2720, 2700, N'自贡', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2721, 2700, N'资阳', 27)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2800, 0, N'天津', 28)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (2900, 0, N'台湾', 29)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3000, 0, N'西藏', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3001, 3000, N'拉萨', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3002, 3000, N'阿里', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3003, 3000, N'昌都', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3004, 3000, N'林芝', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3005, 3000, N'那曲', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3006, 3000, N'日喀则', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3007, 3000, N'山南', 30)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3100, 0, N'香港', 31)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3200, 0, N'新疆', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3201, 3200, N'乌鲁木齐', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3202, 3200, N'阿克苏', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3203, 3200, N'阿图什', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3204, 3200, N'阿勒泰', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3205, 3200, N'阿拉尔', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3206, 3200, N'博乐', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3207, 3200, N'昌吉', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3208, 3200, N'哈密', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3209, 3200, N'和田', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3210, 3200, N'克拉玛依', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3211, 3200, N'喀什', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3212, 3200, N'库尔勒', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3213, 3200, N'石河子', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3214, 3200, N'吐鲁番', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3215, 3200, N'塔城', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3216, 3200, N'伊宁', 32)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3300, 0, N'云南', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3301, 3300, N'昆明', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3302, 3300, N'保山', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3303, 3300, N'楚雄', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3304, 3300, N'大理', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3305, 3300, N'德宏', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3306, 3300, N'红河', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3307, 3300, N'景洪', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3308, 3300, N'丽江', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3309, 3300, N'临沧', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3310, 3300, N'怒江', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3311, 3300, N'曲靖', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3312, 3300, N'思茅', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3313, 3300, N'文山', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3314, 3300, N'香格里拉', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3315, 3300, N'玉溪', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3316, 3300, N'昭通', 33)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3400, 0, N'浙江', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3401, 3400, N'杭州', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3402, 3400, N'湖州', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3403, 3400, N'嘉兴', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3404, 3400, N'金华', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3405, 3400, N'丽水', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3406, 3400, N'宁波', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3407, 3400, N'衢州', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3408, 3400, N'绍兴', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3409, 3400, N'台州', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3410, 3400, N'温州', 34)
GO
INSERT [dbo].[ProvinceCity] ([Id], [ParentId], [Name], [Sort]) VALUES (3411, 3400, N'舟山', 34)
GO
SET IDENTITY_INSERT [dbo].[UserInfo] ON 

GO
INSERT [dbo].[UserInfo] ([Id], [UserName], [Role], [CrateTime], [FBanTime], [FStatus], [FIpAddress], [FBalance]) VALUES (1, N'草鸡棒', 1, CAST(0x0000A56300000000 AS DateTime), CAST(0x0000A56300000000 AS DateTime), 0, NULL, CAST(0.0000 AS Decimal(19, 4)))
GO
INSERT [dbo].[UserInfo] ([Id], [UserName], [Role], [CrateTime], [FBanTime], [FStatus], [FIpAddress], [FBalance]) VALUES (2, N'距离发财还有很远', 2, CAST(0x0000A955018A8053 AS DateTime), CAST(0x0000A954018A8053 AS DateTime), 1, N'127.0.0.1', CAST(0.0000 AS Decimal(19, 4)))
GO
INSERT [dbo].[UserInfo] ([Id], [UserName], [Role], [CrateTime], [FBanTime], [FStatus], [FIpAddress], [FBalance]) VALUES (3, N'米', 3, CAST(0x0000A95600E6A5AA AS DateTime), CAST(0x0000A95500E6A5AA AS DateTime), 1, N'127.0.0.1', CAST(0.0000 AS Decimal(19, 4)))
GO
INSERT [dbo].[UserInfo] ([Id], [UserName], [Role], [CrateTime], [FBanTime], [FStatus], [FIpAddress], [FBalance]) VALUES (4, N'aaaa', 3, CAST(0x0000A958018900B3 AS DateTime), CAST(0x0000A9570189012A AS DateTime), 1, N'123123', CAST(0.0000 AS Decimal(19, 4)))
GO
INSERT [dbo].[UserInfo] ([Id], [UserName], [Role], [CrateTime], [FBanTime], [FStatus], [FIpAddress], [FBalance]) VALUES (5, N'miczhouaa', 3, CAST(0x0000A95801895D31 AS DateTime), CAST(0x0000A95701895D31 AS DateTime), 1, N'12312312', CAST(0.0000 AS Decimal(19, 4)))
GO
INSERT [dbo].[UserInfo] ([Id], [UserName], [Role], [CrateTime], [FBanTime], [FStatus], [FIpAddress], [FBalance]) VALUES (6, N'miczhou', 3, CAST(0x0000A95900262B63 AS DateTime), CAST(0x0000A95800262B63 AS DateTime), 1, N'123123123', CAST(0.0000 AS Decimal(19, 4)))
GO
SET IDENTITY_INSERT [dbo].[UserInfo] OFF
GO
ALTER TABLE [dbo].[ProvinceCity] ADD  CONSTRAINT [DF__ProvinceC__paren__5CD6CB2B]  DEFAULT ((0)) FOR [ParentId]
GO
ALTER TABLE [dbo].[ProvinceCity] ADD  CONSTRAINT [DF__ProvinceCi__Sort__5DCAEF64]  DEFAULT ((0)) FOR [Sort]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF_TPaymentProvider_Fstatus]  DEFAULT ((0)) FOR [FStatus]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF__TPaymentP__FCurr__4FD1D5C8]  DEFAULT ((0)) FOR [FCurrentAmount]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF__TPaymentP__FTota__50C5FA01]  DEFAULT ((0)) FOR [FTotalAmount]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF_TPaymentProvider_FSupportClearing]  DEFAULT ((0)) FOR [FSupportClearing]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF__TPaymentP__FDepo__00976AB9]  DEFAULT ((100)) FOR [FDepositAmount]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF_TPaymentProvider_FIsSupportWap]  DEFAULT ((0)) FOR [FIsSupportWap]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF_TPaymentProvider_FDeviceType]  DEFAULT ((0)) FOR [FDeviceType]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  CONSTRAINT [DF_TPaymentProvider_FWayType]  DEFAULT ((0)) FOR [FWayType]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  DEFAULT ((2)) FOR [FDepositRandomNum]
GO
ALTER TABLE [dbo].[TPaymentProvider] ADD  DEFAULT ((0)) FOR [IsShowName]
GO
ALTER TABLE [dbo].[UserInfo] ADD  CONSTRAINT [DF_UserInfo_Role]  DEFAULT ((3)) FOR [Role]
GO
ALTER TABLE [dbo].[UserInfo] ADD  CONSTRAINT [DF_UserInfo_Status]  DEFAULT ((0)) FOR [FStatus]
GO
ALTER TABLE [dbo].[UserInfo] ADD  CONSTRAINT [DF_UserInfo_FBalance]  DEFAULT ((0)) FOR [FBalance]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'账户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Account', @level2type=N'COLUMN',@level2name=N'AccountNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'密码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Account', @level2type=N'COLUMN',@level2name=N'Password'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Account', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Account', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Account', @level2type=N'COLUMN',@level2name=N'ModifyTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作为单点登录用字段' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Account', @level2type=N'COLUMN',@level2name=N'Enabled'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'类别表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Categories', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'难以程度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Categories', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'评论idGuid来插' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'评论数据' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'CommentDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'评论详情' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'ComentDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'评论层级' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'CommentLevel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'NewsId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否激活' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'Enabled'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户名字' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支持' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'Support'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'不持支' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CommentInfo', @level2type=N'COLUMN',@level2name=N'UnSupport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻详情表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsDetails', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻内容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsDetails', @level2type=N'COLUMN',@level2name=N'Details'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻图片' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsDetails', @level2type=N'COLUMN',@level2name=N'ImageUrl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'发布时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsDetails', @level2type=N'COLUMN',@level2name=N'PublishTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作者ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsDetails', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻内容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsInfo', @level2type=N'COLUMN',@level2name=N'NewsContent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻主题' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsInfo', @level2type=N'COLUMN',@level2name=N'NewsTheme'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻标题' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsInfo', @level2type=N'COLUMN',@level2name=N'NewsTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsInfo', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻作者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsInfo', @level2type=N'COLUMN',@level2name=N'NewsAuthor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsInfo', @level2type=N'COLUMN',@level2name=N'modifyTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻列表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻标题' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'TrTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'ReportTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'Descript'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻类别' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'NewsType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'图片地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'ImageUrl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'推荐指数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'Recommend'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'终止日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'ExpireTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻详情Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'DetailId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'评论Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewsList', @level2type=N'COLUMN',@level2name=N'CommentId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'描述主题' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewTitleInfo', @level2type=N'COLUMN',@level2name=N'DiscriptTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻主题' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewTitleInfo', @level2type=N'COLUMN',@level2name=N'NewTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewTitleInfo', @level2type=N'COLUMN',@level2name=N'CrateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewTitleInfo', @level2type=N'COLUMN',@level2name=N'ModifyTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewTitleInfo', @level2type=N'COLUMN',@level2name=N'NewsId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作者id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NewTitleInfo', @level2type=N'COLUMN',@level2name=N'AuthorName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'资源名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'ResourceName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上传后文件名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'FilePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'图片地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'ImagePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻描述Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'NewListId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'转换状态(默认是0/转好是1，失败是2)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'ConvertStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上传用户Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动标识1标识没去，2表去了' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Resource', @level2type=N'COLUMN',@level2name=N'Flag'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'原路径' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'BeforPath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新文件名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'NewName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'全路径' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'PathAll'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'CrateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否激活' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'Enabled'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新闻id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'NewsId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ResourceInfo', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FCreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订单流水号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FOrderFlowNum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提款金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FApplyAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'之前余额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FBeforeBalance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'改变后余额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FAfterBalance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'手续费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FPrivilege'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提款用户名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FUserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提现卡号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FApplyCarNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提现银行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FApplyBankName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'完成时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FUpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提现状态 0-全部 1-等待付款 2-付款成功 3-付款失败 4-取消订单' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FApplyStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'三方订单id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FThirdOrderId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FIpAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'手机号码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FPhoneNum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'省' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FProvince'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'市' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FCity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'预留字段1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FReserved1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'预留字段2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TEncashment', @level2type=N'COLUMN',@level2name=N'FReserved2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订单列表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订单号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TOrderNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'收款人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TPayee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'收款人账号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TPayAccNum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入款笔数(暂时不作用)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TPayNum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支付通道名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TPayMerchantName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支付通道id 1-微信 2 支付宝' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TPayMerchantType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支付金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'实际金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'TEffectAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'手续费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'FCharge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'FCreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订单状态' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'FOrderStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订单回调状态' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'FOrderBackStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订单回调次数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TOrders', @level2type=N'COLUMN',@level2name=N'FOrderBackNum'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'公司ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FCompanyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1、环讯支付，2、国付宝支付' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMerchantId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'三方支付商名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMerchantName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商户编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMerchantCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'账户号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMerchantAccount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商户密匙' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMerchantKey'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'会员组，0代表全部,多个分组用逗号隔开' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMemberGroupID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'停用金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FDisableAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支持的支付类型。银行卡：BANK_B2C，微信：WeiXin，支付宝：ZhiFuBao等,多类型之间用逗号隔开。为空时，默认为：BANK_B2C' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FCardType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'显示顺序' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'状态。0、停用，1、启用，2、删除' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最后更新的人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FLastUpdateUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'设置最后更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FLastUpdateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商户签约域名，用来向三方发送在线支付订单请求' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FPayBuildDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'接受三方支付通知的域名，可以与签约域名相同。' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FPayBackDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'加密密码。有些可逆加密，加密时用到的密码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FEncryptionPassword'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支付方式。银行卡、微信、信用卡等' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FPayType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'该支付商是否支持清算（结算）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FSupportClearing'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商城中转域名。如果需要经过商城中转，这个字段是商城域名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FMallDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支付订单查询地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FQueryDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自动结算接口地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FRemitDomain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否收取手续费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FIsCharge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'收取手续费比例' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FCharge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商务收款费率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FCollectFee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'支持的客户端设备类型。0：所有；1、仅支持电脑端；2、仅支持手机端' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FDeviceType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'通道类型。0、全部通道；1、扫码支付；2、客户端支付' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FWayType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'通道清算周期参数。有些支付提供多种清算通道，例如：T0、T1、T2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FSettlementCycle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否显示商户别名（1:是，0:否）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'IsShowName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否显示金额快捷方式' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FIsShowShortcut'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'金额快捷设置' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider', @level2type=N'COLUMN',@level2name=N'FShortcutSet'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'三方支付提供商' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TPaymentProvider'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'旅游列表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'标题' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'Author'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'出版商id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'PublisherId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'出版日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'PublishDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'唯一标识' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'ISBN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'UnitPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'内容描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'ContentDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作者描述' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'AurhorDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'编辑评论' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'EditorComment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'章节内容路线图' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'TOC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'难度类型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'CategoryId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'区域类型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'AreaCategoyId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'点击数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TravelStrategy', @level2type=N'COLUMN',@level2name=N'Click'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Role'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'CrateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户禁用时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'FBanTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'账户状态产考UserStatus 枚举 1-待审核 2-正常 3-冻结 4-role错误' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'FStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'账户ip地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'FIpAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'账户余额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'FBalance'
GO
