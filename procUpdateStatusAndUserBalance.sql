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
-- Purpose:			����֧��
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
create PROCEDURE [dbo].[procUpdateStatusAndUserBalance]
(
	@Id int,
	@FApplyAmount decimal(19,4) , 
	@FApplyStatus int,  --�޸Ķ���״̬
	@FUpdateTime datetime,
	@FUserId int
)
AS
begin
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET NOCOUNT ON  

	declare @flag bit =0;
	declare @FCurryStatus int =1; --������ǰ״̬
	declare @FApplyAmountTemp decimal(19, 4) ;
	declare @FAccStatus int =1 --�˱�״̬

select @FApplyAmountTemp =FApplyAmount,@FCurryStatus=FApplyStatus from TEncashment(nolock) where Id =@Id
if(@FCurryStatus=4) --����Ѿ��ǳ���״̬���������޸�
begin
	select -1  --�����Ѿ������޷��޸�
	return;
end


if(@FApplyStatus=4 and @FCurryStatus=2) --���Ѿ��ǳɹ�״̬ Ȼ�� ȡ��������ʱ��
begin
	--�����Ҫ�ع������˱���Ҫ����Ϊʧ�����޷����޸�
	update [TEncashment] set FApplyStatus =@FApplyStatus,@FUpdateTime=@FUpdateTime where Id=@Id 
	--�����лع�
	update TUserBalance set FEncashment -= @FApplyAmountTemp ,FBalance +=@FApplyAmountTemp,FEncashmentCount -=1 where FUserId =@FUserId;

	update TMoneyChangesAccess set FAmount =@FApplyAmountTemp ,FStatus=2,FUpdateTime =@FUpdateTime where FUserId =@FUserId  --�˱�Ϊ�˵�
end
else if(@FApplyStatus=2 and @FCurryStatus=2)
begin
	select -2  --�˶����Ѿ��ǳɹ�״̬�벻Ҫ�ظ��ύ
	return;
end
else
begin

		BEGIN TRY     --try
		begin tran   --�������ʼ
		update [TEncashment] set FApplyStatus =@FApplyStatus,@FUpdateTime=@FUpdateTime where Id=@Id 

		if(@FApplyStatus =2)  --��������Ϊ�ɹ�ʱ
		begIn
		 set @FAccStatus =1 --�˱�ɹ�
		 update TUserBalance set FEncashment += @FApplyAmountTemp ,FBalance-=@FApplyAmountTemp,FEncashmentCount+=1 where FUserId =@FUserId;
		end
		else 
		begin
			set @FAccStatus =2
		end
		update TMoneyChangesAccess set FStatus=@FAccStatus,FUpdateTime =@FUpdateTime where FUserId =@FUserId


	COMMIT TRAN   --�ύ����
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN   --�����쳣���ع�����
		DECLARE @errMsg VARCHAR(300)
		SELECT @errMsg=ERROR_MESSAGE()
		RAISERROR(@errMsg, 16, 1) WITH NOWAIT 
	END CATCH
	
	end	
end;