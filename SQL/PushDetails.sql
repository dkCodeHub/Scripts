--Select * From tblOrdrHead

ALTER Proc [dbo].[usp_PushOrderDetails]
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
							<PUSHED_Request_OrderType>1</PUSHED_Request_OrderType>
							<PUSHED_PickUp_ReturnDate></PUSHED_PickUp_ReturnDate>
							<PUSHED_TimeSlot_ID>1</PUSHED_TimeSlot_ID>
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
								PUSHED_Request_OrderType INT NULL,
								PUSHED_PickUp_ReturnDate DATE NULL, 
								PUSHED_TimeSlot_ID INT NULL,
								OrdrFlag BIT NULL
							)

							SELECT @XMLValue = CAST(@strXML AS XML)

							EXEC SP_XML_PREPAREDOCUMENT @hDoc OUTPUT, @XMLValue


							If(@isHistoricalData = 0)
								Begin
								
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
										0 As OrdrFlag
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
										[PUSHED_TimeSlot_ID] Int)
									--VALIDATION 1 : Correct Date Format			(Common)
									--VALIDATION 2 : Update Request Order Type		(common)
									--VALIDATION 3 : Update Time Slot ID			(Common)
									--VALIDATION 4 : Update Request Order Type		(common)
									--VALIDATION 5 : Duplicate Order Details		(common)

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
								End
                            Else
								Begin
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
										1 As OrdrFlag
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
										[PUSHED_TimeSlot_ID] Int)

									--VALIDATION 1 : Correct Date Format 
									--VALIDATION 2 : Update Request Order Type
									--VALIDATION 3 : Update Time Slot ID
									--VALIDATION 4 : Update Request Order Type
									--VALIDATION 5 : Duplicate Order Details
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

								End
						End
                        Else 
							Begin
										Select 'No Data Pushed'
							End

							DROP TABLE #TempPush
            End Try

            Begin Catch
                        Select 'Un Identified Error'
            End Catch
End
