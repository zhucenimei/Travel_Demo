use [TravelDataBase]
GO
IF OBJECTPROPERTY(OBJECT_ID(N'procTOrdersPageList'), N'IsProcedure') = 1
  DROP PROCEDURE dbo.procTOrdersPageList 
GO
--------------------------------------------------------------------------------------------
-- Name:      procGetMemberGroupUserListByPageList
-- Purpose:      获取会员组会员分页列表
-- Location:    Lottery
-- Authorized to:  Lottery
--
-- Author:        Evan
-- Create date:      2015/04/10
-- Excecution Example:  EXEC dbo.procGetMemberGroupUserListByPageList 41139,3,1,20
-- Alter: 
-------------------------------------------------------------------------------------------- 
CREATE PROCEDURE procTOrdersPageList
(
  @pageIndex int,
  @pageSize int,
  @UserId int =0,
  @FOrderNumber nvarchar(50) =null,
  @StartTime datetime,
  @EndTime	datetime
)
AS
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET NOCOUNT ON

CREATE TABLE #Temp_Torder
(
  Id int ,
  TOrderNumber nvarchar(50) ,
  TPayType nvarchar(10) ,
  TPayAccNum nvarchar(38) ,
  TPayNum int ,
  TPayMerchantName nvarchar(50) ,
  TPayMerchantType int ,
  TAmount decimal(19, 4) ,
  TEffectAmount decimal(19, 4) ,
  FCharge decimal(19, 4) ,
  FCreateTime datetime ,
  FOrderStatus int ,
  FOrderBackStatus int  ,
  FOrderBackNum int  ,
  TMerchantOrderId nvarchar(50) ,
  ThreeOrderNum nvarchar(50) ,
  TMerchantUrl nvarchar(200) ,
  TReturnURL nvarchar(50) ,
  FUpdateTime datetime ,
  FMerchantCode nvarchar(50) ,
);

	declare @strsql  nvarchar(4000)=''; 
set	@strsql ='DECLARE @offset int
SET @offset = (@pageIndex - 1) * @pageSize ';
set @strsql +='INSERT INTO #Temp_Torder
SELECT 
Id,TOrderNumber,TPayType,TPayAccNum,TPayNum,TPayMerchantName,TPayMerchantType,
TAmount,TEffectAmount,FCharge,FCreateTime,FOrderStatus,FOrderBackStatus,FOrderBackNum,
TMerchantOrderId,ThreeOrderNum,TMerchantUrl,TReturnURL,FUpdateTime,FMerchantCode '

set @strsql +='FROM dbo.TOrders(nolock) where 1=1  '

if(@UserId<>0)
begin
 set @strsql +=' and FUserId = @UserId '
 end


 if(@FOrderNumber is not NULL and @FOrderNumber<>'')
 begin
   set @strsql +=' and TOrderNumber = @FOrderNumber' ;
 end
 else
 begin
 set @strsql +=' and   FUpdateTime >= @StartTime  and  FUpdateTime <= @EndTime' ;-- + @TOrderNumber;

 end

 set @strsql +=' ORDER BY FCreateTime DESC
OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;'


exec sp_executesql @strsql,N'@pageIndex int,@pageSize int,@UserId int,@FOrderNumber nvarchar(50),@StartTime datetime, @EndTime datetime',
                 @pageIndex,@pageSize,@UserId,@FOrderNumber,@StartTime,@EndTime


print(@strsql);

select b.FOrderNum,b.FMerchantBackStatus,FBackCount
 from #Temp_Torder as a inner join TOrderAssist(nolock) 
 as b on a.TOrderNumber =b.FOrderNum

 select Id,TOrderNumber,TPayType,TPayAccNum,TPayNum,TPayMerchantName,TPayMerchantType,
TAmount,TEffectAmount,FCharge,FCreateTime,FOrderStatus,FOrderBackStatus,FOrderBackNum,
TMerchantOrderId,ThreeOrderNum,TMerchantUrl,TReturnURL,FUpdateTime,FMerchantCode 
from #Temp_Torder




declare @sqlcount nvarchar(4000); 

set @sqlcount ='select count(0) as totalCount from TOrders(nolock) where  FUpdateTime >= @StartTime  and  FUpdateTime <= @EndTime '

if(@UserId<>0)
begin
	set @sqlcount+=' and FUserId =@UserId'
	end
if(@FOrderNumber is not null and @FOrderNumber<>'')
	begin
	set @sqlcount +=' and TOrderNumber = @FOrderNumber' ;
	end


exec sp_executesql @sqlcount,N'@UserId int,@FOrderNumber nvarchar(50),@StartTime datetime, @EndTime datetime',
					@UserId,@FOrderNumber,@StartTime,@EndTime

END
GO