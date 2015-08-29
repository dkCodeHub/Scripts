Alter Proc [dbo].[usp_PushOrderDetails]
(
            @strXML Varchar(Max) = NULL,
            @isHistoricalData Int = 1
)
As
Begin
Set @strXML = '<DocumentElement>
					<Data>
							<RecordID>1</RecordID>
							<PUSHED_CustomerId>R536</PUSHED_CustomerId>
							<PUSHED_CustomerName>New Customer</PUSHED_CustomerName>
							<PUSHED_Request_OrderId>ORD001</PUSHED_Request_OrderId>
							<PUSHED_AddressId>1</PUSHED_AddressId>
							<PUSHED_Address2_Locality>Andheri</PUSHED_Address2_Locality>
							<PUSHED_Landmark>Ashok Nagar</PUSHED_Landmark>
							<PUSHED_City>Mumbai</PUSHED_City>
							<PUSHED_ZipCode>400069</PUSHED_ZipCode>
							<PUSHED_PhoneNumber>9819969522</PUSHED_PhoneNumber>
							<PUSHED_NumberofBoxes>1</PUSHED_NumberofBoxes>
							<PUSHED_NumberOfSpaceItems>0</PUSHED_NumberOfSpaceItems>
							<PUSHED_Request_OrderType>Box_pickup</PUSHED_Request_OrderType>
							<PUSHED_PickUp_ReturnDate>15-Jun-2015</PUSHED_PickUp_ReturnDate>							
							<PUSHED_TimeSlot_ID>1</PUSHED_TimeSlot_ID>
							<PUSHED_ProductDescription>Landline Phone</PUSHED_ProductDescription>
					</Data>
				</DocumentElement>'

      Begin Try
            If(Len(@strXML) != 0)
			Begin
				DECLARE @XMLValue XML
				DECLARE @hDoc INT 

							
                Create Table #TempPush
				(
					BMS_ORDER_AutoID INT Identity(1,1), 
					PUSHED_CustomerId VARCHAR(50) NULL,
					PUSHED_CustomerName VARCHAR(250) NULL,
					PUSHED_Request_OrderId VARCHAR(50) NULL,
					PUSHED_AddressId INT NULL, 
					PUSHED_Address1 VARCHAR(250), 
					PUSHED_Address2_Locality VARCHAR(250), 
					PUSHED_Landmark VARCHAR(250), 
					PUSHED_City VARCHAR(250),
					PUSHED_ZipCode  VARCHAR(15), 
					PUSHED_PhoneNumber  VARCHAR(50), 
					PUSHED_NumberofBoxes INT NULL,
					PUSHED_NumberOfSpaceItems INT NULL,
					PUSHED_Request_OrderType varchar(50) NULL,
					PUSHED_PickUp_ReturnDate DATE NULL, 
					PUSHED_TimeSlot_ID INT NULL,
					PUSHED_ProductDescription varchar(100),
					OrdrFlag BIT NULL,
					PUSHED_PickUp_OrderTypeID int NULL
				)

				Create Table #DuplicateRecordsDB
				(								
					[EXC_CustomerId] [varchar](50) NULL,
					[EXC_Request_OrderId] [varchar](Max) NULL
				)
				
				SELECT @XMLValue = CAST(@strXML AS XML)

				EXEC SP_XML_PREPAREDOCUMENT @hDoc OUTPUT, @XMLValue
								
				INSERT INTO #TempPush(
					PUSHED_CustomerId,
					PUSHED_CustomerName,
					PUSHED_Request_OrderId,
					PUSHED_AddressId, 
					PUSHED_Address1, 
					PUSHED_Address2_Locality, 
					PUSHED_Landmark, 
					PUSHED_City,
					PUSHED_ZipCode, 
					PUSHED_PhoneNumber, 
					PUSHED_NumberofBoxes,
					PUSHED_NumberOfSpaceItems,
					PUSHED_Request_OrderType,
					PUSHED_PickUp_ReturnDate, 
					PUSHED_TimeSlot_ID,
					PUSHED_ProductDescription,
					OrdrFlag)
				SELECT  PUSHED_CustomerId,
					PUSHED_CustomerName,
					PUSHED_Request_OrderId,
					PUSHED_AddressId, 
					PUSHED_Address1, 
					PUSHED_Address2_Locality, 
					PUSHED_Landmark, 
					PUSHED_City,
					PUSHED_ZipCode, 
					PUSHED_PhoneNumber, 
					PUSHED_NumberofBoxes,
					PUSHED_NumberOfSpaceItems,
					PUSHED_Request_OrderType,
					PUSHED_PickUp_ReturnDate, 
					PUSHED_TimeSlot_ID,
					PUSHED_ProductDescription,
					iif(@isHistoricalData=1,1,0) As OrdrFlag
				FROM OPENXML(@hDoc,'DocumentElement/Data',2)
				WITH (
					[PUSHED_CustomerId] Varchar(50),
					[PUSHED_CustomerName] Varchar(250),
					[PUSHED_Request_OrderId] [varchar](50),
					[PUSHED_AddressId] Int,
					[PUSHED_Address1] [varchar](250),
					[PUSHED_Address2_Locality] [Varchar](250),
					[PUSHED_Landmark] Varchar(250),
					[PUSHED_City] Varchar(250),
					[PUSHED_ZipCode] Varchar(15),
					[PUSHED_PhoneNumber] Varchar(50),
					[PUSHED_NumberofBoxes] Int,
					[PUSHED_NumberOfSpaceItems] Int,
					[PUSHED_Request_OrderType] Int,
					[PUSHED_PickUp_ReturnDate] Date,
					[PUSHED_TimeSlot_ID] Int,
					[PUSHED_ProductDescription] [Varchar](100))
					--VALIDATION 1 : Correct Date Format			(Common)
					--VALIDATION 2 : Update Request Order Type		(common)
					--VALIDATION 3 : Update Time Slot ID			(Common)
					--VALIDATION 4 : Duplicate Order Details		(common)
									
					--VALIDATION 1 : Correct Date Format			(Common)
					update #TempPush set PUSHED_PickUp_ReturnDate=replace(convert(varchar,PUSHED_PickUp_ReturnDate,111),'/','-')
					where PUSHED_PickUp_ReturnDate is not null
									 
					--select replace(convert(varchar,getdate(),111),'/','-')
					--VALIDATION 2 : Update Request Order Type		(common)
					update #TempPush set [PUSHED_Request_OrderType]=case when Lower([PUSHED_Request_OrderType]) Like 'box_drop%'	then 1 
						when Lower([PUSHED_Request_OrderType]) Like '%drop%'		then 1
						when Lower([PUSHED_Request_OrderType]) Like 'drop%'		then 1
						when Lower([PUSHED_Request_OrderType]) Like '%drop'		then 1
						when Lower([PUSHED_Request_OrderType]) Like 'box_pickup%'		then 2
						when Lower([PUSHED_Request_OrderType]) Like '%pickup%'		then 2
						when Lower([PUSHED_Request_OrderType]) Like 'pickup%'			then 2
						when Lower([PUSHED_Request_OrderType]) Like '%pickup'			then 2		  
						when [PUSHED_Request_OrderType] = 'PickMaterial' then 3 end --[PUSHED_Request_OrderType] 
						
						--VALIDATION 4 : Duplicate Order Details		(common)

						INSERT INTO #DuplicateRecordsDB([EXC_CustomerId],[EXC_Request_OrderId])
						SELECT TOHT.PUSHED_CustomerId, 'Order Id : ' + TOHT.PUSHED_Request_OrderId + ' Already Exists' FROM #TempPush TOHT INNER JOIN tblOrdrHead TOH 
						ON TOHT.PUSHED_CustomerId = TOH.[EXC_CustomerId]
						and TOHT.PUSHED_Request_OrderId = TOH.[EXC_Request_OrderId]

						INSERT INTO UPload_DuplicateRecordsDB([EXC_CustomerId],[EXC_Request_OrderId])
						SELECT [EXC_CustomerId],[EXC_Request_OrderId] FROM #DuplicateRecordsDB
					--POST VALIDATION OF DATA INSERT ACCURATE DATA IN tblOrdrHead
						INSERT INTO tblOrdrHead(
									EXC_CustomerId
									,EXC_CustomerName
									,EXC_Request_OrderId
									,EXC_AddressId
									,EXC_Address1
									,EXC_Address2_Locality
									,EXC_Landmark
									,EXC_City
									,EXC_ZipCode
									,EXC_PhoneNumber
									,EXC_NumberofBoxes
									,EXC_NumberOfSpaceItems
									,EXC_Request_OrderType
									,EXC_PickUp_ReturnDate
									,EXC_TimeSlot_ID
									,OrdrFlag)
												
						SELECT		 PUSHED_CustomerId
									,PUSHED_CustomerName
									,PUSHED_Request_OrderId
									,PUSHED_AddressId
									,PUSHED_Address1
									,PUSHED_Address2_Locality
									,PUSHED_Landmark
									,PUSHED_City
									,PUSHED_ZipCode
									,PUSHED_PhoneNumber
									,PUSHED_NumberofBoxes
									,PUSHED_NumberOfSpaceItems
									,PUSHED_Request_OrderType
									,PUSHED_PickUp_ReturnDate
									,PUSHED_TimeSlot_ID
									,OrdrFlag FROM #TempPush
									inner join #DuplicateRecordsDB
									ON #TempPush.PUSHED_CustomerId = #DuplicateRecordsDB.[EXC_CustomerId]
									AND #TempPush.PUSHED_Request_OrderId = #DuplicateRecordsDB.[EXC_Request_OrderId]
									WHERE #TempPush.PUSHED_CustomerId IS NULL
									--WHERE PUSHED_Request_OrderId Not IN(SELECT D.EXC_Request_OrderId FROM #DuplicateRecordsDB D)

							IF(@isHistoricalData != 0)
								Begin
									DECLARE @TempTableRowCount int                     
									DECLARE @TempTableCounter int
									DECLARE @B_OrderId VARCHAR(50)
									DECLARE @PUSHED_ProductDescription VARCHAR(50)
									DECLARE @BOX_SpaceQty INT
									DECLARE @BOX_SpaceQtyCntr INT
									--req + cust
									--POST VALIDATION OF DATA INSERT ACCURATE DATA IN tblOrdrHead
									SELECT @TempTableRowCount=count(1) FROM #TempPush                           
		SET @TempTableCounter = 1                           
		--Started Loop for inserting into PatientTestMapping and PatientTestFieldMapping                      
		WHILE @TempTableCounter <= @TempTableRowCount     
		BEGIN
			select  @B_OrderId=PUSHED_Request_OrderId, @PUSHED_ProductDescription=PUSHED_ProductDescription,@BOX_SpaceQty=iif(PUSHED_NumberofBoxes=0,PUSHED_NumberOfSpaceItems,PUSHED_NumberofBoxes) from #TempPush WHERE BMS_ORDER_AutoID = @TempTableCounter          			
			SET @BOX_SpaceQtyCntr=1
			WHILE @BOX_SpaceQtyCntr<=@BOX_SpaceQty
			BEGIN
					EXEC USP_OrderLine_I @B_OrderId,@PUSHED_ProductDescription
					SET @BOX_SpaceQtyCntr=@BOX_SpaceQtyCntr+1
			END
			SET @TempTableCounter = @TempTableCounter + 1 
		END

									
								PRINT 'Inserting data into tblOrderLine'

								End
						End
                        Else 
							Begin
										Select 'No Data Pushed'
							End

							DROP TABLE #TempPush							
							Drop Table #DuplicateRecordsDb

            End Try

            Begin Catch
                        Select 'Un Identified Error'
            End Catch
End
