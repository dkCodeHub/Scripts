
Create Table UPload_DuplicateRecordsDB
(
	RecordNo Int identity(1,1),
	[EXC_CustomerId] [varchar](50) NULL,
	[EXC_Request_OrderId] [varchar](Max) NULL
)
GO
