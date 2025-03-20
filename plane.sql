-- Tạo cơ sở dữ liệu
CREATE DATABASE HangKhongVN;
GO

USE HangKhongVN;
GO

-- Bảng loại máy bay
CREATE TABLE LoaiMayBay (
    LoaiID INT PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL
);

-- Bảng máy bay
CREATE TABLE MayBay (
    MaMayBay INT PRIMARY KEY,
    LoaiID INT FOREIGN KEY REFERENCES LoaiMayBay(LoaiID),
    HangSanXuat NVARCHAR(100) NOT NULL
);

-- Bảng phi công
CREATE TABLE PhiCong (
    MaSo INT PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai NVARCHAR(15),
    Luong DECIMAL(10,2) CHECK (Luong > 0)
);

-- Bảng kỹ thuật viên
CREATE TABLE KyThuatVien (
    MaSo INT PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255),
    SoDienThoai NVARCHAR(15),
    Luong DECIMAL(10,2) CHECK (Luong > 0)
);

-- Bảng kiểm tra máy bay
CREATE TABLE KiemTraMayBay (
    MaDot INT PRIMARY KEY,
    LoaiKiemTra NVARCHAR(100) NOT NULL,
    NgayKiemTra DATE NOT NULL,
    MaSoKTV INT FOREIGN KEY REFERENCES KyThuatVien(MaSo),
    MaMayBay INT FOREIGN KEY REFERENCES MayBay(MaMayBay)
);

-- Bảng quản lý phi công lái máy bay (bảng trung gian nếu một phi công có thể lái nhiều loại máy bay)
CREATE TABLE PhiCong_MayBay (
    MaSo INT,
    MaMayBay INT,
    PRIMARY KEY (MaSo, MaMayBay),
    FOREIGN KEY (MaSo) REFERENCES PhiCong(MaSo),
    FOREIGN KEY (MaMayBay) REFERENCES MayBay(MaMayBay)
);

-- Nhập dữ liệu mẫu
-- Dữ liệu mẫu cho bảng LoaiMayBay
INSERT INTO LoaiMayBay (LoaiID, TenLoai) 
VALUES 
(1, N'Máy bay thương mại'), 
(2, N'Máy bay quân sự');

-- Dữ liệu mẫu cho bảng MayBay
INSERT INTO MayBay (MaMayBay, LoaiID, HangSanXuat) 
VALUES 
(1, 1, N'Boeing'), 
(2, 1, N'Airbus'), 
(3, 2, N'F-16');
select * from MayBay
-- Dữ liệu mẫu cho bảng PhiCong
INSERT INTO PhiCong (MaSo, HoTen, SoDienThoai, Luong) 
VALUES 
(101, N'Nguyen Van A', '0123456789', 3000),
(102, N'Nguyen Thi B', '0123456788', 3500);
select * from PhiCong
-- Dữ liệu mẫu cho bảng KyThuatVien
INSERT INTO KyThuatVien (MaSo, HoTen, DiaChi, SoDienThoai, Luong) 
VALUES 
(202, N'Pham Thanh D', N'Hai Phong', '0987654322', 2700),
(203, N'Nguyen Thi E', N'TP HCM', '0987654323', 2800);

-- Dữ liệu mẫu cho bảng KiemTraMayBay
INSERT INTO KiemTraMayBay (MaDot, LoaiKiemTra, NgayKiemTra, MaSoKTV, MaMayBay)
VALUES 
(2, N'Kiểm tra hệ thống điện', '2024-02-01', 202, 1),
(3, N'Kiểm tra động cơ', '2024-03-01', 203, 2);

-- Dữ liệu mẫu cho bảng PhiCong_MayBay
-- Chỉ thêm những phi công và máy bay đã tồn tại
INSERT INTO PhiCong_MayBay (MaSo, MaMayBay)
VALUES 
(101, 1), 
(102, 2);

-- Truy vấn cơ bản
SELECT * FROM MayBay;
SELECT * FROM PhiCong WHERE Luong > 2000;

-- Truy vấn nâng cao
SELECT P.HoTen, M.HangSanXuat 
FROM PhiCong P 
JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
JOIN MayBay M ON PM.MaMayBay = M.MaMayBay;

-- Tạo VIEW
-- VIEW cơ bản: Lấy danh sách phi công
CREATE VIEW v_PhiCong AS 
SELECT MaSo, HoTen, Luong FROM PhiCong;

-- VIEW nâng cao: Lấy danh sách phi công và máy bay mà họ có thể lái
CREATE VIEW v_PhiCongMayBay AS 
SELECT P.HoTen, M.HangSanXuat 
FROM PhiCong P 
JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
JOIN MayBay M ON PM.MaMayBay = M.MaMayBay;

-- VIEW lọc: Lấy danh sách kỹ thuật viên có lương trên 2500
CREATE VIEW v_KyThuatVien_LuongCao AS 
SELECT HoTen, Luong FROM KyThuatVien WHERE Luong > 2500;

-- VIEW nâng cao: Lấy thông tin phi công và kiểm tra máy bay mà họ đã tham gia
CREATE VIEW v_PhiCong_KiemTraMayBay AS 
SELECT P.HoTen, K.LoaiKiemTra, K.NgayKiemTra, M.HangSanXuat 
FROM PhiCong P 
JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
JOIN MayBay M ON PM.MaMayBay = M.MaMayBay
JOIN KiemTraMayBay K ON M.MaMayBay = K.MaMayBay;

-- VIEW thống kê: Tính tổng số phi công và máy bay theo loại máy bay
CREATE VIEW v_ThongKePhiCongMayBay AS 
SELECT LM.TenLoai, COUNT(DISTINCT P.MaSo) AS SoLuongPhiCong, COUNT(DISTINCT M.MaMayBay) AS SoLuongMayBay
FROM LoaiMayBay LM
JOIN MayBay M ON LM.LoaiID = M.LoaiID
JOIN PhiCong_MayBay PM ON M.MaMayBay = PM.MaMayBay
JOIN PhiCong P ON PM.MaSo = P.MaSo
GROUP BY LM.TenLoai;
having by 

-- VIEW tổng hợp: Danh sách phi công cùng thông tin máy bay và kỹ thuật viên kiểm tra
CREATE VIEW v_PhiCong_MayBay_KTV AS 
SELECT P.HoTen AS PhiCong, M.HangSanXuat AS MayBay, K.LoaiKiemTra AS KiemTra, K.NgayKiemTra
FROM PhiCong P
JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
JOIN MayBay M ON PM.MaMayBay = M.MaMayBay
JOIN KiemTraMayBay K ON M.MaMayBay = K.MaMayBay;

-- VIEW phân tích: Phi công và các máy bay đã được kiểm tra trong tháng 2
CREATE VIEW v_PhiCong_MayBay_FebruaryCheck AS 
SELECT P.HoTen, M.HangSanXuat, K.LoaiKiemTra, K.NgayKiemTra
FROM PhiCong P 
JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
JOIN MayBay M ON PM.MaMayBay = M.MaMayBay
JOIN KiemTraMayBay K ON M.MaMayBay = K.MaMayBay
WHERE MONTH(K.NgayKiemTra) = 3;

--
CREATE VIEW v_PhiCong AS 
SELECT MaSo, HoTen FROM PhiCong;
select * from v_PhiCong
-- Tạo INDEX
CREATE INDEX idx_HoTen ON PhiCong(HoTen);

--
-- Index cho bảng PhiCong
CREATE INDEX idx_PhiCong_HoTen ON PhiCong(HoTen);

-- Index cho bảng MayBay
CREATE INDEX idx_MayBay_LoaiID ON MayBay(LoaiID);

-- Index cho bảng KiemTraMayBay
CREATE INDEX idx_KiemTraMayBay_MaMayBay ON KiemTraMayBay(MaMayBay);

-- Index cho bảng PhiCong_MayBay
CREATE INDEX idx_PhiCong_MayBay ON PhiCong_MayBay(MaSo, MaMayBay);

-- Index cho bảng KyThuatVien
CREATE INDEX idx_KyThuatVien_Luong ON KyThuatVien(Luong);

-- Index cho bảng LoaiMayBay
CREATE INDEX idx_LoaiMayBay_TenLoai ON LoaiMayBay(TenLoai);

-- Index cho bảng PhiCong (Lọc theo lương)
CREATE INDEX idx_PhiCong_Luong ON PhiCong(Luong);

-- Index cho bảng KiemTraMayBay (Lọc theo ngày kiểm tra)
CREATE INDEX idx_KiemTraMayBay_Ngay ON KiemTraMayBay(NgayKiemTra);

-- Index cho bảng MayBay (Lọc theo hãng sản xuất)
CREATE INDEX idx_MayBay_HangSanXuat ON MayBay(HangSanXuat);

-- Index cho bảng PhiCong_MayBay (Lọc theo máy bay)
CREATE INDEX idx_PhiCongMayBay_MaMayBay ON PhiCong_MayBay(MaMayBay);

-- Tạo Stored Procedure
CREATE PROCEDURE sp_GetPhiCong
AS
BEGIN
    SELECT * FROM PhiCong;
END;
--

-- Stored Procedure không tham số: Lấy tất cả phi công
CREATE PROCEDURE sp_GetAllPhiCong
AS
BEGIN
    SELECT * FROM PhiCong;
END;

-- Stored Procedure có tham số: Lấy phi công theo MaSo
CREATE PROCEDURE sp_GetPhiCongByMaSo
    @MaSo INT
AS
BEGIN
    SELECT * FROM PhiCong WHERE MaSo = @MaSo;
END;

-- Stored Procedure có tham số và OUTPUT: Cập nhật lương phi công và trả về lương mới
CREATE PROCEDURE sp_UpdateLuongPhiCong
    @MaSo INT, 
    @Luong DECIMAL(10,2),
    @NewLuong DECIMAL(10,2) OUTPUT
AS
BEGIN
    UPDATE PhiCong
    SET Luong = @Luong
    WHERE MaSo = @MaSo;

    SELECT @NewLuong = Luong FROM PhiCong WHERE MaSo = @MaSo;
END;

-- Stored Procedure không tham số: Lấy thông tin tất cả máy bay
CREATE PROCEDURE sp_GetAllMayBay
AS
BEGIN
    SELECT * FROM MayBay;
END;

-- Stored Procedure có tham số: Xóa phi công theo MaSo
CREATE PROCEDURE sp_DeletePhiCongByMaSo
    @MaSo INT
AS
BEGIN
    DELETE FROM PhiCong WHERE MaSo = @MaSo;
END;

-- Stored Procedure không tham số: Lấy tất cả kiểm tra máy bay
CREATE PROCEDURE sp_GetAllKiemTraMayBay
AS
BEGIN
    SELECT * FROM KiemTraMayBay;
END;

-- Stored Procedure có tham số: Thêm kiểm tra máy bay
CREATE PROCEDURE sp_AddKiemTraMayBay
    @MaDot INT, 
    @LoaiKiemTra NVARCHAR(100), 
    @NgayKiemTra DATE, 
    @MaSoKTV INT, 
    @MaMayBay INT
AS
BEGIN
    INSERT INTO KiemTraMayBay (MaDot, LoaiKiemTra, NgayKiemTra, MaSoKTV, MaMayBay) 
    VALUES (@MaDot, @LoaiKiemTra, @NgayKiemTra, @MaSoKTV, @MaMayBay);
END;

-- Stored Procedure có OUTPUT: Tính tổng số phi công có thể lái máy bay theo loại
CREATE PROCEDURE sp_CountPhiCongByLoaiMayBay
    @LoaiID INT, 
    @SoLuongPhiCong INT OUTPUT
AS
BEGIN
    SELECT @SoLuongPhiCong = COUNT(DISTINCT P.MaSo)
    FROM PhiCong P
    JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
    JOIN MayBay M ON PM.MaMayBay = M.MaMayBay
    WHERE M.LoaiID = @LoaiID;
END;

-- Tạo Function
CREATE FUNCTION fn_TinhLuong(@HeSo DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @HeSo * 3000;
END;


-- Function tính tổng lương của phi công
CREATE FUNCTION fn_TongLuongPhiCong()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TongLuong DECIMAL(10,2);
    SELECT @TongLuong = SUM(Luong) FROM PhiCong;
    RETURN @TongLuong;
END;

-- Function lấy danh sách phi công theo lương
CREATE FUNCTION fn_GetPhiCongByLuong(@LuongMin DECIMAL(10,2))
RETURNS TABLE
AS
RETURN (
    SELECT * FROM PhiCong WHERE Luong >= @LuongMin
);



-- Function trả về bảng phi công theo khu vực
CREATE FUNCTION fn_GetPhiCongByKhuVuc(@DiaChi NVARCHAR(255))
RETURNS TABLE
AS
RETURN (
    SELECT * FROM KyThuatVien WHERE DiaChi = @DiaChi
);

-- Function lấy số lượng phi công theo khu vực
CREATE FUNCTION fn_CountPhiCongByDiaChi(@DiaChi NVARCHAR(255))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;
    SELECT @SoLuong = COUNT(*) FROM KyThuatVien WHERE DiaChi = @DiaChi;
    RETURN @SoLuong;
END;

-- Function lấy thông tin máy bay theo loại
CREATE FUNCTION fn_GetMayBayByLoai(@LoaiID INT)
RETURNS TABLE
AS
RETURN (
    SELECT * FROM MayBay WHERE LoaiID = @LoaiID
);

-- Function tính lương tổng cho phi công từ một vùng
CREATE FUNCTION fn_TinhLuongTongByKhuVuc(@DiaChi NVARCHAR(255))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TongLuong DECIMAL(10,2);
    SELECT @TongLuong = SUM(Luong) FROM PhiCong
    WHERE MaSo IN (SELECT MaSo FROM KyThuatVien WHERE DiaChi = @DiaChi);
    RETURN @TongLuong;
END;

-- Function trả về bảng phi công và máy bay của họ
CREATE FUNCTION fn_GetPhiCongMayBay()
RETURNS @PhiCongMayBay TABLE (HoTen NVARCHAR(100), HangSanXuat NVARCHAR(100))
AS
BEGIN
    INSERT INTO @PhiCongMayBay
    SELECT P.HoTen, M.HangSanXuat
    FROM PhiCong P
    JOIN PhiCong_MayBay PM ON P.MaSo = PM.MaSo
    JOIN MayBay M ON PM.MaMayBay = M.MaMayBay;
    RETURN;
END;

-- Tạo Trigger
CREATE TRIGGER trg_CheckLuong ON PhiCong
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Luong < 1000)
    BEGIN
        RAISERROR (N'Lương không hợp lệ!', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
--
-- Trigger khi thêm phi công mới vào bảng PhiCong
CREATE TRIGGER trg_AfterInsertPhiCong
ON PhiCong
AFTER INSERT
AS
BEGIN
    PRINT 'Phi công mới đã được thêm vào hệ thống';
END;

-- Trigger khi xóa phi công
CREATE TRIGGER trg_AfterDeletePhiCong
ON PhiCong
AFTER DELETE
AS
BEGIN
    PRINT 'Phi công đã bị xóa khỏi hệ thống';
END;

-- Trigger khi cập nhật lương phi công
CREATE TRIGGER trg_AfterUpdateLuongPhiCong
ON PhiCong
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Luong)
    BEGIN
        PRINT 'Lương của phi công đã được cập nhật';
    END
END;

-- Trigger khi thêm kiểm tra mới cho máy bay
CREATE TRIGGER trg_AfterInsertKiemTraMayBay
ON KiemTraMayBay
AFTER INSERT
AS
BEGIN
    PRINT 'Kiểm tra máy bay đã được thêm';
END;

-- Trigger khi xóa kiểm tra máy bay
CREATE TRIGGER trg_AfterDeleteKiemTraMayBay
ON KiemTraMayBay
AFTER DELETE
AS
BEGIN
    PRINT 'Kiểm tra máy bay đã bị xóa';
END;

-- Trigger khi thêm máy bay vào bảng MayBay
CREATE TRIGGER trg_AfterInsertMayBay
ON MayBay
AFTER INSERT
AS
BEGIN
    PRINT 'Máy bay mới đã được thêm vào hệ thống';
END;

-- Trigger khi cập nhật thông tin máy bay
CREATE TRIGGER trg_AfterUpdateMayBay
ON MayBay
AFTER UPDATE
AS
BEGIN
    IF UPDATE(HangSanXuat)
    BEGIN
        PRINT 'Thông tin máy bay đã được cập nhật';
    END
END;

-- Sao lưu
BACKUP DATABASE HangKhongVN TO DISK = 'D:\backup_HangKhongVN.bak';

-- Phục hồi
RESTORE DATABASE HangKhongVN FROM DISK = 'D:\backup_HangKhongVN.bak' WITH REPLACE;


-- Tạo login cho người dùng
CREATE LOGIN HangKhong WITH PASSWORD ='123456';
GO

-- Tạo người dùng trong cơ sở dữ liệu
USE HangKhongVN;
GO
CREATE USER User_Name FOR LOGIN HangKhong;
GO

USE HangKhongVN;
GO
-- Cấp quyền SELECT cho người dùng trên bảng PhiCong
GRANT SELECT ON PhiCong TO User_Name;
GO

-- Cấp quyền INSERT, UPDATE cho người dùng trên bảng MayBay
GRANT INSERT, UPDATE ON MayBay TO User_Name;
GO

-- Cấp quyền EXECUTE để người dùng có thể thực thi stored procedure
GRANT EXECUTE ON sp_GetPhiCong TO User_Name;
GO

-- Cấp quyền db_owner cho người dùng (quản trị toàn bộ cơ sở dữ liệu)
USE HangKhongVN;
GO
EXEC sp_addrolemember 'db_owner', 'HangKhong';
GO

