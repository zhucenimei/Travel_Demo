USE [TravelDataBase]
GO
/****** Object:  StoredProcedure [dbo].[procBalanceAndOrderAssisUpdate]    Script Date: 2018/10/4 15:57:25 ******/
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procUpdatePaymentProviderNew'), N'IsProcedure') = 1
	DROP PROCEDURE dbo.procUpdatePaymentProviderNew
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------
-- Name:			procUpdatePaymentProviderNew
-- Purpose:			跟新商户表
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
Create PROCEDURE [dbo].[procUpdatePaymentProviderNew]
(
	@Id int ,
	@FAccountId int  ,
	@FTPayBaseInfoId int  ,
	@FMerchantCode nvarchar(30)  ,
	@FMerchantAccount nvarchar(50) ,
	@FMerchantKey nvarchar(50)  ,
	@FMerchantPrivateKey nvarchar(1000) ,
	@FMerchantPublicKey nvarchar(500) ,
	@FCollectFee decimal(19, 4)  ,
	@FPayType nvarchar(50)  ,
	@FCreateTime datetime ,
	@FUpdateTime datetime ,
	@FUserId int ,
	@FRemark nvarchar(MAX) =null,
	@FReserved1 nvarchar(50) =null,
	@FCurrentAmount decimal(19, 4) 

)
AS
begin

declare @tempUserid int =0;
select top 1 @tempUserid =FAccountId from TPaymentProviderNew(nolock) where FMerchantCode =@FMerchantCode
if(@tempUserid!=0 and @tempUserid!=@FAccountId )
begin	
	select -1 --商户已存在且不属于该用户
	return ;
end

---跟新订单辅助表
merge into TPaymentProviderNew a
using (select @FMerchantCode as FMerchantCode,@FPayType as FPayType) b on a.FMerchantCode =b.FMerchantCode and a.FPayType =b.FPayType
when matched then
    update set FTPayBaseInfoId=@FTPayBaseInfoId ,FCollectFee =@FCollectFee,FUpdateTime =@FUpdateTime --更新字段
when not matched then
    insert(
		FAccountId
		,FTPayBaseInfoId
		,FMerchantCode
		,FMerchantAccount
		,FMerchantKey
		,FMerchantPrivateKey
		,FMerchantPublicKey
		,FCollectFee
		,FPayType
		,FCreateTime
		,FUpdateTime
		,FUserId
		,FTotalAmount 
		,FCurrentAmount
		)values
		(
		@FAccountId
		,@FTPayBaseInfoId
		,@FMerchantCode
		,@FMerchantAccount
		,@FMerchantKey
		,@FMerchantPrivateKey
		,@FMerchantPublicKey
		,@FCollectFee
		,@FPayType
		,@FCreateTime
		,@FUpdateTime
		,@FAccountId
		,0
		,@FCurrentAmount
		);

---------跟新余额表

end;