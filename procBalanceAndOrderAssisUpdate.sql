USE [TravelDataBase]
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procBalanceAndOrderAssisUpdate'), N'IsProcedure') = 1
	DROP PROCEDURE dbo.procBalanceAndOrderAssisUpdate
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------
-- Name:			procEncashmentUpdate
-- Purpose:			跟新余额，余订单辅助表
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
create PROCEDURE [dbo].[procBalanceAndOrderAssisUpdate]
(
	@FOrderNum nvarchar(50) ,
	@FMerchantBackStatus int ,
	@FUserId int,
	@FDeposit decimal(19,4) 
)
AS
begin

---跟新订单辅助表
merge into TOrderAssist a
using (select @FOrderNum as FOrderNum) b on a.FOrderNum =b.FOrderNum 
when matched then
    update set  FMerchantBackStatus=@FMerchantBackStatus ,FBackCount+=1 --更新字段
when not matched then
    insert(
		FOrderNum
		,FMerchantBackStatus
		,FBackCount
		)values
		(
			@FOrderNum,
			@FMerchantBackStatus,
			1
		);

---------跟新余额表

merge into TUserBalance a
using (select @FUserId as FUserId) b on a.FUserId =b.FUserId 
when matched then
    update set  FDeposit=@FDeposit, FBalance+= @FDeposit,FDepositCount+=1--更新字段
when not matched then
    insert(
		FUserId
		,FBalance
		,FDeposit
		,FEncashment
		,FDepositCount
		,FEncashmentCount
		)values
		(
			@FUserId,
			@FDeposit,
			@FDeposit,
			0,
			0,
			0
		);
end;