USE [TravelDataBase]
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procEncashmentUpdate'), N'IsProcedure') = 1
	DROP PROCEDURE dbo.procEncashmentUpdate
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------
-- Name:			procEncashmentUpdate
-- Purpose:			¸úÐÂÖ§¸¶
-- Author:				mic
-- Create date:			2018/01/25
-- Alter: 
--------------------------------------------------------------------------------------------
create PROCEDURE [dbo].[procEncashmentUpdate]
(
	@Id int,
	@FApplyAmount decimal(19,4) ,
	@FBeforeBalance  decimal(19,4) ,
	@FAfterBalance decimal(19,4) ,
	@FPrivilege decimal(19,4) ,
	@FUserName nvarchar(18),
	@FApplyCarNo nvarchar(20),
	@FApplyBankName nvarchar(20),
	@FUpdateTime nvarchar(20),
	@FIpAddress nvarchar(30),
	@FPhoneNum nvarchar(20),
	@FProvince nvarchar(20),
	@FCity nvarchar(20),
	@FReserved1 nvarchar(50), 
	@FReserved2 nvarchar(50) 
)
AS
begin
merge into [TEncashment] a
using (select @Id as Id) b on a.Id=b.Id and a.FApplyStatus =1
when matched then
    update set	FApplyAmount = @FApplyAmount ,
				 FBeforeBalance = @FBeforeBalance ,
				 FAfterBalance = @FAfterBalance ,
				 FPrivilege = @FPrivilege ,
				 FUserName = @FUserName ,
				 FApplyCarNo = @FApplyCarNo ,
				 FApplyBankName = @FApplyBankName ,
				 FUpdateTime = @FUpdateTime ,
				 FIpAddress = @FIpAddress ,
				 FPhoneNum = @FPhoneNum ,
				 FProvince = @FProvince ,
				 FCity = @FCity ,
				 FReserved1 = @FReserved1 ,
				 FReserved2 = @FReserved2 ;
		
end;