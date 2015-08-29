USE [BMS_BETA_DEV]
GO
/****** Object:  StoredProcedure [dbo].[USP_OrderLine_I]    Script Date: 8/29/2015 7:13:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raj@AliteSoft
-- Create date: 27/06/2015
-- Description:	Insert values into table "tblOrdrLine"
-- =============================================
ALTER PROCEDURE [dbo].[USP_OrderLine_I] 
	-- Add the parameters for the stored procedure here
	@OrderID varchar(30) , 
	@ItemDescription varchar(max)  ,
	@RtnQuery int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Getting SequenceNo
	DECLARE @SequenceNo Int = 0
	SELECT @SequenceNo = ISNULL(MAX(SequenceNo),0) FROM tblOrdrLine WHERE EXC_Request_OrderId = @OrderID  
	
	DECLARE @tbl_BarCodeID Table (BarCodeID varchar(50), DisplayBarCodeID varchar(100))

	--Inserting Data into tblOrderLine
	Insert INTO tblOrdrLine (BarCodeID,EXC_CustomerId, EXC_CustomerName,EXC_Request_OrderId,SequenceNo,ProductDesc,IsActive,CreatedDate,CreatedTimeStamp, DisplayBarCodeID)
	Output inserted.BarCodeID, inserted.DisplayBarCodeID   into @tbl_BarCodeID 
	Select EXC_Request_OrderId+(CASE WHEN LEN(@SequenceNo + 1) = 1 THEN '00'+convert(varchar(3),(@SequenceNo + 1))
									 WHEN LEN(@SequenceNo + 1) = 2 THEN '0'+convert(varchar(3),(@SequenceNo + 1))
									 WHEN LEN(@SequenceNo + 1) = 3 THEN convert(varchar(3),(@SequenceNo + 1)) END) BarCodeID, 
		EXC_CustomerId, EXC_CustomerName, EXC_Request_OrderId, (@SequenceNo + 1) , @ItemDescription, 1, CONVERT(VARCHAR(8), GETDATE(), 112),CONVERT(VARCHAR(10),GETDATE(),108),
		EXC_Request_OrderId+'-' +(CASE WHEN LEN(@SequenceNo + 1) = 1 THEN '00'+convert(varchar(3),(@SequenceNo + 1))
									 WHEN LEN(@SequenceNo + 1) = 2 THEN '0'+convert(varchar(3),(@SequenceNo + 1))
									 WHEN LEN(@SequenceNo + 1) = 3 THEN convert(varchar(3),(@SequenceNo + 1)) END) DisplayBarCodeID 
	From tblOrdrHead 
	Where EXC_Request_OrderId = @OrderID
	if @RtnQuery=0 
	BEGIN
		Select BarCodeID + '|' + DisplayBarCodeID from @tbl_BarCodeID 
	END
END
