USE [TravelDataBase]
GO
/****** Object:  StoredProcedure [dbo].[procGetUserBlanceAndMerchant]    Script Date: 2018/10/4 15:57:25 ******/
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procGetUserBlanceAndMerchant'), N'IsProcedure') = 1
	DROP PROCEDURE dbo.procGetUserBlanceAndMerchant
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------
-- Name:			procGetUserBlanceAndMerchant
-- Purpose:			获取用户余额以及商户表
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
Create PROCEDURE [dbo].[procGetUserBlanceAndMerchant]
(
	@userId int 

)
AS
begin
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	select top 1  [FUserId]
      ,[FBalance]
      ,[FDeposit]
      ,[FEncashment]
      ,[FDepositCount]
      ,[FEncashmentCount]  from TUserBalance(nolock) where FUserId =@userId

	  select 
	   [FAccountId]
      ,[FTPayBaseInfoId]
      ,[FMerchantCode]
      ,[FCollectFee]
      ,[FTotalAmount]
      ,[FCurrentAmount]
      ,[FPayType]
	  from TPaymentProviderNew(nolock) where FAccountId =@userId;
end;