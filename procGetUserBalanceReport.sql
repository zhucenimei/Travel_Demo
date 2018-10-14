USE [TravelDataBase]
GO
/****** Object:  StoredProcedure [dbo].[procGetUserBlanceAndMerchant]    Script Date: 2018/10/4 15:57:25 ******/
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procGetUserBalanceReport'), N'IsProcedure') = 1
	DROP PROCEDURE dbo.procGetUserBalanceReport
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------
-- Name:			procGetUserBlanceAndMerchant
-- Purpose:			用户金额报表
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
Create PROCEDURE [dbo].[procGetUserBalanceReport]
(
	@pageIndex int,
	@pageSize int
)
AS
begin
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	create table #temp(
	FUserId int,
	FUserName nvarchar(20) ,
	FBalance decimal(19, 4) ,
	FDeposit decimal(19, 4) ,
	FEncashment decimal(19, 4) ,
	FDepositCount int ,
	FEncashmentCount int ,
	);
	declare @total int;
	select  @total=COUNT(0) from TUserBalance(nolock);

	DECLARE @offset int
	SET @offset = (@pageIndex-1) * @pageSize
	insert into #temp
	select 
	   FUserId
	  ,FUserName
      ,[FBalance]
      ,[FDeposit]
      ,[FEncashment]
      ,[FDepositCount]
      ,[FEncashmentCount]  
	  from TUserBalance(nolock) 
	  order by FBalance
	 OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;

		select 
		a.FAccountId 
		 ,a.FMerchantCode as FPritfMerchantCode
		,b.[FMerchantCode] as FThreeMerchantCode
		, a.[FCollectFee] as FThreeCollectFee
		, b.[FCollectFee] as FPritfCollectFee
		,b.[FPayType]
		,b.FMerchantName
		from
		TPaymentProviderNew(nolock) as a inner join Tpaybaseinfo(nolock) as b on a.FTPayBaseInfoId =b.Id
		where a.FAccountId in (select FUserId from #temp);
	
	  
	
		SELECT * FROM #temp ;
		SELECT @total;

	


	  --SELECT * FROM ( SELECT * ,row_index=ROW_NUMBER() OVER(ORDER BY tt.FAddTime desc ) FROM
	  -- (select wechat.*,acc.FAccount as FParentAccount from TWechatGenUrl  wechat
	  -- inner join TAccounts acc on acc.FID =wechat.FParentId
	  -- where wechat.FCompanyId=@companyId and wechat.FAddTime>=@startDate and wechat.FAddTime<=@endDate and wechat.FStatus=1
	  -- ) tt  WHERE 1=1   ) t WHERE t.row_index 
	  -- BETWEEN (@pageIndex-1)*@pageSize+1 AND @pageIndex*@pageSize

   --select @totalCount as totalCount
end;