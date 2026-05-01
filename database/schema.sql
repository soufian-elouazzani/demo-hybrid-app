CREATE DATABASE DemoApp;
GO
USE DemoApp;
GO

CREATE TABLE Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

INSERT INTO Products (Name, Price) VALUES 
('Sample Product 1', 19.99),
('Sample Product 2', 29.99);

