--Create database Travel_Management;

Select * from Travels
Select * from Categories
--Tạo bảng
USE Travel_Management
create table Travels(
	trID int NOT NULL,
	Name varchar(100) NOT NULL,
	price int null,
	days int NOT NULL,
	catID INT NOT NULL,
	startdate datetime null		
)

create table Categories(
	catID INT NOT NULL,
	catname varchar(100) NOT NULL,
	counts INT NULL
)

--Thêm khóa chính
Alter TABLE Travels ADD Primary key (trID)
Alter TABLE Categories ADD Primary key (catID)

--Thêm khóa ngoại
Alter TABLE Travels ADD Foreign Key (catID) References Categories

--Rằng buộc check
Alter TABLE Travels ADD Constraint check_days CHECK (days>=0 AND days<=15)

--Rằng buộc unique
Alter TABLE Travels ADD UNIQUE (Name)

--Rằng buộc Default 
ALTER TABLE Travels
ADD CONSTRAINT DF_Startdate 
DEFAULT GETDATE() FOR startdate

--Chèn dữ liệu vào bảng
Insert INTO Categories(catID, catname) 
Values(100, 'Beaches') 
Insert INTO Categories(catID, catname) 
Values(200, 'Family Travel')
Insert INTO Categories(catID, catname) 
Values(300, 'Food and Drink')
Insert INTO Categories(catID, catname) 
Values(400, 'Sking')

Insert INTO Travels(trID, Name, price, days, catID) 
Values(10, 'Manele Bay, Hawai', 200, 2, 100)
Insert INTO Travels(trID, Name, price, days, catID) 
Values(11, 'Hilton Waikoloa Village', 250, 4, 200)
Insert INTO Travels(trID, Name, price, days, catID) 
Values(12, 'Clearwater Beach, Florida', 300, 7, 100)
Insert INTO Travels(trID, Name, price, days, catID) 
Values(13, 'Sandwich Paradise', 180, 2, 300)
Insert INTO Travels(trID, Name, price, days, catID) 
Values(14, 'Caps May, New Jersey', 300, 4, 100)

--Truy vấn group, join
SELECT Travels2.catID, Categories.catname, Travels2.Quanity
FROM(
SELECT Travels.catID as catID, count(*) as Quanity FROM Travels GROUP BY catID  
) as Travels2
INNER JOIN Categories 
ON Travels2.catID = Categories.catID

--Cập nhật dữ liệu counts
Update Categories 
SET counts = 3 WHERE catID=100
Update Categories 
SET counts = 1 WHERE catID=200
Update Categories 
SET counts = 1 WHERE catID=300

--Update giá
Update Travels 
SET price = price*1.1 
WHERE days>5 AND catID
IN(SELECT Categories.catID FROM Categories WHERE Categories.catname = 'Food and Drink')

--Thêm trigger

		-- Trigger update giá
CREATE TRIGGER TG_Travels_Update
ON Travels AFTER INSERT, UPDATE 
AS	
BEGIN
	Declare @price INT 
	SET @price = (SELECT price from inserted)
	IF @price <= 0
	BEGIN
		RAISERROR ('Travel tour''s price must be greater than zero',1,1)
		ROLLBACK
	END
END  

		--Trigger update counts
CREATE TRIGGER TG_Travels_Delete
ON Travels AFTER DELETE 
AS
BEGIN
	Declare @catID INT = (SELECT catID from DELETED)
	UPDATE Categories 
	SET counts = counts-1
	WHERE Categories.catID = @catID AND counts > 0
END

		--Trigger update startdate
CREATE TRIGGER TG_Travels_Insert 
ON Travels AFTER INSERT 
AS
BEGIN
	Declare @date datetime = (SELECT startdate from inserted) 
	IF @date - GETDATE() < 0 
	BEGIN
		RAISERROR ('Travel tour''s startdate must be after the current date.',1,1)
		ROLLBACK
	END
END

