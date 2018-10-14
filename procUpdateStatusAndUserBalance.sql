USE [TravelDataBase]
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procUpdateStatusAndUserBalance'), N'IsProcedure') = 1
	DROP PROCEDURE dbo.procUpdateStatusAndUserBalance
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------
-- Name:			procEncashmentUpdate
-- Purpose:			跟新支付
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
create PROCEDURE [dbo].[procUpdateStatusAndUserBalance]
(
	@Id int,
	@FApplyAmount decimal(19,4) , 
	@FApplyStatus int,  --修改订单状态
	@FUpdateTime datetime,
	@FUserId int
)
AS
begin
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET NOCOUNT ON  

	declare @flag bit =0;
	declare @FCurryStatus int =1; --订单当前状态
	declare @FApplyAmountTemp decimal(19, 4) ;
	declare @FAccStatus int =1 --账变状态

select @FApplyAmountTemp =FApplyAmount,@FCurryStatus=FApplyStatus from TEncashment(nolock) where Id =@Id
if(@FCurryStatus=4) --如果已经是撤销状态则不允许再修改
begin
	select -1  --订单已经撤销无法修改
	return;
end


if(@FApplyStatus=4 and @FCurryStatus=2) --当已经是成功状态 然后 取消订单的时候
begin
	--金额需要回滚。且账变需要跟新为失败且无法再修改
	update [TEncashment] set FApplyStatus =@FApplyStatus,@FUpdateTime=@FUpdateTime where Id=@Id 
	--余额进行回滚
	update TUserBalance set FEncashment -= @FApplyAmountTemp ,FBalance +=@FApplyAmountTemp,FEncashmentCount -=1 where FUserId =@FUserId;

	update TMoneyChangesAccess set FAmount =@FApplyAmountTemp ,FStatus=2,FUpdateTime =@FUpdateTime where FUserId =@FUserId  --账变为退单
end
else if(@FApplyStatus=2 and @FCurryStatus=2)
begin
	select -2  --此订单已经是成功状态请不要重复提交
	return;
end
else
begin

		BEGIN TRY     --try
		begin tran   --标记事务开始
		update [TEncashment] set FApplyStatus =@FApplyStatus,@FUpdateTime=@FUpdateTime where Id=@Id 

		if(@FApplyStatus =2)  --当订单改为成功时
		begIn
		 set @FAccStatus =1 --账变成功
		 update TUserBalance set FEncashment += @FApplyAmountTemp ,FBalance-=@FApplyAmountTemp,FEncashmentCount+=1 where FUserId =@FUserId;
		end
		else 
		begin
			set @FAccStatus =2
		end
		update TMoneyChangesAccess set FStatus=@FAccStatus,FUpdateTime =@FUpdateTime where FUserId =@FUserId


	COMMIT TRAN   --提交事务
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN   --发生异常，回滚事务
		DECLARE @errMsg VARCHAR(300)
		SELECT @errMsg=ERROR_MESSAGE()
		RAISERROR(@errMsg, 16, 1) WITH NOWAIT 
	END CATCH
	
	end	
end;