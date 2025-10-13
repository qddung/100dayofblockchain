1. Stored Procedure: Liệt kê nhân viên chưa lập phiếu nhập trong năm @nam
sqlCREATE PROCEDURE sp_NhanVienChuaLapPhieuNhap
    @nam INT
AS
BEGIN
    SELECT 
        N.MANV, 
        N.HO + ' ' + N.TEN AS HOTEN
    FROM NhanVien N
    WHERE N.TrangThaiXoa = 0
      AND NOT EXISTS (
          SELECT 1 
          FROM PhieuNhap PN 
          WHERE PN.MANV = N.MANV 
            AND YEAR(PN.NGAY) = @nam
      );
END;
2. Stored Procedure: Liệt kê chi tiết các mặt hàng đã xuất trong hóa đơn @sohd
sqlCREATE PROCEDURE sp_ChiTietXuatHoaDon
    @sohd NCHAR(8)
AS
BEGIN
    SELECT 
        PX.NGAY,
        C.MAVT AS MaMH,
        V.TENVT AS TenMH,
        C.SOLUONG,
        C.DONGIA,
        C.SOLUONG * C.DONGIA AS Trigia
    FROM PhieuXuat PX
    INNER JOIN CTPX C ON PX.MAPX = C.MAPX
    INNER JOIN Vattu V ON C.MAVT = V.MAVT
    WHERE PX.MAPX = @sohd;
END;
3. Stored Procedure: Liệt kê các phiếu nhập trong 6 tháng đầu năm @nam
sqlCREATE PROCEDURE sp_PhieuNhap6ThangDau
    @nam INT
AS
BEGIN
    SELECT 
        PN.MAPN AS SoPhieu,
        PN.NGAY,
        PN.MANV,
        N.HO + ' ' + N.TEN AS HotenNV
    FROM PhieuNhap PN
    INNER JOIN NhanVien N ON PN.MANV = N.MANV
    WHERE YEAR(PN.NGAY) = @nam 
      AND MONTH(PN.NGAY) <= 6;
END;
4. Stored Procedure: Đếm số lượng nhân viên trong công ty
sqlCREATE PROCEDURE sp_DemNhanVien
AS
BEGIN
    SELECT COUNT(*) AS SoLuongNhanVien
    FROM NhanVien
    WHERE TrangThaiXoa = 0;
END;
5. Stored Procedure: Đếm số lượng phiếu nhập đã lập
sqlCREATE PROCEDURE sp_DemPhieuNhap
AS
BEGIN
    SELECT COUNT(*) AS SoLuongPhieuNhap
    FROM PhieuNhap;
END;
6. Stored Procedure: Liệt kê nhân viên có lương trong khoảng @luongmin đến @luongmax
sqlCREATE PROCEDURE sp_NhanVienTheoLuong
    @luongmin FLOAT,
    @luongmax FLOAT
AS
BEGIN
    SELECT 
        MANV,
        HO + ' ' + TEN AS HOTEN,
        NGAYSINH,
        LUONG
    FROM NhanVien
    WHERE LUONG BETWEEN @luongmin AND @luongmax
      AND TrangThaiXoa = 0;
END;
7. Stored Procedure: Liệt kê các phiếu thuộc loại @loai trong khoảng @tungay đến @denngay
sqlCREATE PROCEDURE sp_PhieuTheoLoaiThoiGian
    @loai NVARCHAR(20),
    @tungay DATE,
    @denngay DATE
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    
    IF @loai = 'NHAP'
    BEGIN
        SET @sql = N'
        SELECT 
            PN.MAPN AS PHIEU,
            PN.NGAY AS NGAYLAP,
            SUM(CT.SOLUONG * CT.DONGIA) AS THANHTIEN,
            N.HO + '' '' + N.TEN AS HOTENNV
        FROM PhieuNhap PN
        INNER JOIN NhanVien N ON PN.MANV = N.MANV
        INNER JOIN CTPN CT ON PN.MAPN = CT.MAPN
        WHERE PN.NGAY BETWEEN @tungay AND @denngay
        GROUP BY PN.MAPN, PN.NGAY, N.HO, N.TEN
        ORDER BY PN.NGAY';
    END
    ELSE IF @loai = 'XUAT'
    BEGIN
        SET @sql = N'
        SELECT 
            PX.MAPX AS PHIEU,
            PX.NGAY AS NGAYLAP,
            SUM(CT.SOLUONG * CT.DONGIA) AS THANHTIEN,
            N.HO + '' '' + N.TEN AS HOTENNV
        FROM PhieuXuat PX
        INNER JOIN NhanVien N ON PX.MANV = N.MANV
        INNER JOIN CTPX CT ON PX.MAPX = CT.MAPX
        WHERE PX.NGAY BETWEEN @tungay AND @denngay
        GROUP BY PX.MAPX, PX.NGAY, N.HO, N.TEN
        ORDER BY PX.NGAY';
    END
    ELSE
    BEGIN
        RAISERROR('Loai phieu khong hop le (chi chap nhan ''NHAP'' hoac ''XUAT'')', 16, 1);
        RETURN;
    END;
    
    EXEC sp_executesql @sql, 
        N'@tungay DATE, @denngay DATE',
        @tungay = @tungay, @denngay = @denngay;
END;
8. Stored Procedure: Đếm số lượng mã vật tư trong công ty
sqlCREATE PROCEDURE sp_DemVatTu
AS
BEGIN
    SELECT COUNT(*) AS SoLuongMaVatTu
    FROM Vattu;
END;
9. Stored Procedure: Đếm số lần nhập/xuất của vật tư @mavt
sqlCREATE PROCEDURE sp_DemLanNhapXuatVatTu
    @mavt NCHAR(4)
AS
BEGIN
    -- Phần a: Tổng số lượt nhập/xuất (số phiếu chứa vật tư)
    SELECT 
        V.MAVT,
        V.TENVT,
        COUNT(DISTINCT CTPN.MAPN) + COUNT(DISTINCT CTPX.MAPX) AS SOLUOT_NHAP_XUAT
    FROM Vattu V
    LEFT JOIN CTPN ON V.MAVT = CTPN.MAVT
    LEFT JOIN CTPX ON V.MAVT = CTPX.MAVT
    WHERE V.MAVT = @mavt
    GROUP BY V.MAVT, V.TENVT;
    
    -- Phần b: Số lượt nhập và xuất riêng biệt
    SELECT 
        V.MAVT,
        V.TENVT,
        COUNT(DISTINCT CTPN.MAPN) AS SOLUOT_NHAP,
        COUNT(DISTINCT CTPX.MAPX) AS SOLUOT_XUAT
    FROM Vattu V
    LEFT JOIN CTPN ON V.MAVT = CTPN.MAVT
    LEFT JOIN CTPX ON V.MAVT = CTPX.MAVT
    WHERE V.MAVT = @mavt
    GROUP BY V.MAVT, V.TENVT;
END;
10. Stored Procedure: Thống kê phiếu @loai trong năm @nam theo từng nhân viên
sqlCREATE PROCEDURE sp_ThongKePhieuTheoNhanVien
    @loai NVARCHAR(20),
    @nam INT
AS
BEGIN
    IF @loai = 'NHAP'
    BEGIN
        SELECT 
            PN.MANV AS MANV,
            N.HO + ' ' + N.TEN AS HOTEN,
            COUNT(*) AS SOLUOT_LAP_PHIEU_NHAP
        FROM PhieuNhap PN
        INNER JOIN NhanVien N ON PN.MANV = N.MANV
        WHERE YEAR(PN.NGAY) = @nam
        GROUP BY PN.MANV, N.HO, N.TEN;
    END
    ELSE IF @loai = 'XUAT'
    BEGIN
        SELECT 
            PX.MANV AS MANV,
            N.HO + ' ' + N.TEN AS HOTEN,
            COUNT(*) AS SOLUOT_LAP_PHIEU_XUAT
        FROM PhieuXuat PX
        INNER JOIN NhanVien N ON PX.MANV = N.MANV
        WHERE YEAR(PX.NGAY) = @nam
        GROUP BY PX.MANV, N.HO, N.TEN;
    END
    ELSE
    BEGIN
        RAISERROR('Loai phieu khong hop le (chi chap nhan ''NHAP'' hoac ''XUAT'')', 16, 1);
    END;
END;
11. Stored Procedure: Liệt kê doanh thu theo từng tháng trong năm @nam
sqlCREATE PROCEDURE sp_DoanhThuTheoThang
    @nam INT
AS
BEGIN
    SELECT 
        MONTH(PX.NGAY) AS Thang,
        SUM(CT.SOLUONG * CT.DONGIA) AS DoanhThu
    FROM PhieuXuat PX
    INNER JOIN CTPX CT ON PX.MAPX = CT.MAPX
    WHERE YEAR(PX.NGAY) = @nam
    GROUP BY MONTH(PX.NGAY)
    ORDER BY Thang;
END;
12. Stored Procedure: Liệt kê số lượng tồn của vật tư @mavt
sqlCREATE PROCEDURE sp_TonVatTu
    @mavt NCHAR(4)
AS
BEGIN
    SELECT 
        MAVT,
        SOLUONGTON
    FROM Vattu
    WHERE MAVT = @mavt;
END;
13. Stored Procedure: Liệt kê số lượng tồn của tất cả vật tư
sqlCREATE PROCEDURE sp_TonTatCaVatTu
AS
BEGIN
    SELECT 
        V.MAVT,
        V.TENVT,
        ISNULL(SUM(CTPN.SOLUONG), 0) AS TGNHAP,
        ISNULL(SUM(CTPX.SOLUONG), 0) AS TGXUAT,
        V.SOLUONGTON AS SOLUONG_TON
    FROM Vattu V
    LEFT JOIN CTPN ON V.MAVT = CTPN.MAVT
    LEFT JOIN CTPX ON V.MAVT = CTPX.MAVT
    GROUP BY V.MAVT, V.TENVT, V.SOLUONGTON
    ORDER BY V.MAVT;
END;
14. Stored Procedure: Liệt kê chi tiết phiếu @loai của nhân viên @manv trong năm @nam
sqlCREATE PROCEDURE sp_PhieuChiTietNhanVien
    @loai NVARCHAR(20),
    @manv INT,
    @nam INT
AS
BEGIN
    IF @loai = 'NHAP'
    BEGIN
        SELECT 
            PN.MANV AS Manv,
            N.HO + ' ' + N.TEN AS HotenNV,
            'NHAP' AS LoaiPhieu,
            PN.MAPN AS SoPhieu,
            PN.NGAY AS NgayLap,
            V.TENVT,
            C.SOLUONG AS SoLg,
            C.DONGIA
        FROM PhieuNhap PN
        INNER JOIN NhanVien N ON PN.MANV = N.MANV
        INNER JOIN CTPN C ON PN.MAPN = C.MAPN
        INNER JOIN Vattu V ON C.MAVT = V.MAVT
        WHERE PN.MANV = @manv 
          AND YEAR(PN.NGAY) = @nam
        ORDER BY PN.NGAY;
    END
    ELSE IF @loai = 'XUAT'
    BEGIN
        SELECT 
            PX.MANV AS Manv,
            N.HO + ' ' + N.TEN AS HotenNV,
            'XUAT' AS LoaiPhieu,
            PX.MAPX AS SoPhieu,
            PX.NGAY AS NgayLap,
            V.TENVT,
            C.SOLUONG AS SoLg,
            C.DONGIA
        FROM PhieuXuat PX
        INNER JOIN NhanVien N ON PX.MANV = N.MANV
        INNER JOIN CTPX C ON PX.MAPX = C.MAPX
        INNER JOIN Vattu V ON C.MAVT = V.MAVT
        WHERE PX.MANV = @manv 
          AND YEAR(PX.NGAY) = @nam
        ORDER BY PX.NGAY;
    END
    ELSE
    BEGIN
        RAISERROR('Loai phieu khong hop le (chi chap nhan ''NHAP'' hoac ''XUAT'')', 16, 1);
    END;
END;
15. Stored Procedure: Tạo phiếu nhập từ đơn đặt hàng @SoHieu
sqlCREATE PROCEDURE sp_Tao_Phieu_Nhap
    @SoPN NCHAR(8),
    @NgayNhap DATE,
    @MaNV INT,
    @SoHieu NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Kiểm tra đơn đặt hàng tồn tại
        IF NOT EXISTS (SELECT 1 FROM DatHang WHERE MasoDDH = @SoHieu)
        BEGIN
            RAISERROR('Don dat hang %s khong ton tai.', 16, 1, @SoHieu);
            ROLLBACK;
            RETURN;
        END;
        
        -- Tạo phiếu nhập chính (tối ưu: kiểm tra trùng MAPN trước)
        IF EXISTS (SELECT 1 FROM PhieuNhap WHERE MAPN = @SoPN)
        BEGIN
            RAISERROR('Ma phieu nhap %s da ton tai.', 16, 1, @SoPN);
            ROLLBACK;
            RETURN;
        END;
        
        INSERT INTO PhieuNhap (MAPN, NGAY, MasoDDH, MANV)
        VALUES (@SoPN, @NgayNhap, @SoHieu, @MaNV);
        
        -- Tạo chi tiết phiếu nhập từ chi tiết đơn đặt hàng (tối ưu: INSERT SELECT trực tiếp)
        INSERT INTO CTPN (MAPN, MAVT, SOLUONG, DONGIA)
        SELECT @SoPN, CTD.MAVT, CTD.SOLUONG, CTD.DONGIA
        FROM CTDDH CTD
        WHERE CTD.MasoDDH = @SoHieu;
        
        -- Cập nhật tồn kho (tối ưu: UPDATE với subquery)
        UPDATE V
        SET V.SOLUONGTON = V.SOLUONGTON + ISNULL(CTPN.SOLUONG, 0)
        FROM Vattu V
        INNER JOIN CTPN ON V.MAVT = CTPN.MAVT
        WHERE CTPN.MAPN = @SoPN;
        
        COMMIT TRANSACTION;
        PRINT 'Tao phieu nhap thanh cong!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
16. Stored Procedure: Cập nhật mức giảm giá cho khách hàng dựa trên doanh thu năm @Nam
sqlCREATE PROCEDURE sp_Cap_Nhat_Muc_Giam_Gia
    @DoanhThuToiThieu DECIMAL(18,2),
    @Nam INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SoLuongThayDoi INT = 0;
    DECLARE @MaKH NVARCHAR(50), @MucGiamGiaHienTai DECIMAL(5,4), @DoanhThuKH DECIMAL(18,2);
    
    -- Kiểm tra điều kiện @DoanhThuToiThieu
    IF @DoanhThuToiThieu < 10000000
    BEGIN
        RAISERROR('DoanhThuToiThieu phai >= 10.000.000', 16, 1);
        RETURN;
    END;
    
    -- Sử dụng cursor để xử lý từng khách hàng (logic phức tạp, đếm thay đổi)
    DECLARE kh_cursor CURSOR FOR
    SELECT 
        KH.MaKH,
        ISNULL(KH.MucGiamGia, 0) AS MucGiamGia,
        ISNULL(SUM(CT.Trigia), 0) AS DoanhThu  -- Giả sử CHITIETHOADON có Trigia = SOLUONG * DONGIA
    FROM KHACHHANG KH
    LEFT JOIN HOADON HD ON KH.MaKH = HD.MaKH
    LEFT JOIN CHITIETHOADON CT ON HD.sohd = CT.sohd
    WHERE YEAR(HD.Ngay) = @Nam
      AND ISNULL(SUM(CT.Trigia), 0) >= @DoanhThuToiThieu
    GROUP BY KH.MaKH, KH.MucGiamGia;
    
    OPEN kh_cursor;
    FETCH NEXT FROM kh_cursor INTO @MaKH, @MucGiamGiaHienTai, @DoanhThuKH;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @MucGiamGiaMoi DECIMAL(5,4);
        
        IF @MucGiamGiaHienTai = 0
        BEGIN
            SET @MucGiamGiaMoi = 0.05;
        END
        ELSE IF @DoanhThuKH <= 20000000
        BEGIN
            SET @MucGiamGiaMoi = @MucGiamGiaHienTai + 0.01;
        END
        ELSE IF @DoanhThuKH <= 40000000
        BEGIN
            SET @MucGiamGiaMoi = @MucGiamGiaHienTai + 0.02;
        END
        ELSE
        BEGIN
            SET @MucGiamGiaMoi = @MucGiamGiaHienTai + 0.03;
        END;
        
        -- Cập nhật nếu có thay đổi (tối ưu: chỉ update khi khác)
        IF @MucGiamGiaMoi <> @MucGiamGiaHienTai
        BEGIN
            UPDATE KHACHHANG 
            SET MucGiamGia = @MucGiamGiaMoi 
            WHERE MaKH = @MaKH;
            SET @SoLuongThayDoi = @SoLuongThayDoi + 1;
        END;
        
        FETCH NEXT FROM kh_cursor INTO @MaKH, @MucGiamGiaHienTai, @DoanhThuKH;
    END;
    
    CLOSE kh_cursor;
    DEALLOCATE kh_cursor;
    
    SELECT @SoLuongThayDoi AS SoLuongKhachHangThayDoi;
END;