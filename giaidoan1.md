# 📚 Kế Hoạch Triển Khai Mạng Hyperledger Fabric với Docker

## 🎯 Mục Tiêu Giai Đoạn 1

Mục tiêu là triển khai một mạng Hyperledger Fabric cho tổ chức **ibn** trên nền tảng Docker với các thành phần sau:

- 1 CA (Certificate Authority)
- 1 Orderer
- 1 Peer
- 1 CLI container
- 1 Chaincode (ví dụ Fabcar)

## 🚀 Các Thành Phần Docker

1. **Hyperledger Fabric CA** (Cấp phát chứng chỉ)
2. **Hyperledger Fabric Orderer** (Sắp xếp giao dịch)
3. **Hyperledger Fabric Peer** (Lưu trữ dữ liệu)
4. **Hyperledger Fabric CLI** (Công cụ dòng lệnh để thao tác với Fabric)
5. **Hyperledger Fabric CCEnv** (Runtime cho Chaincode)

## 🛠️ Các Bước Triển Khai

### Bước 1: Tạo CA Server với Docker

- Cấu hình Docker Compose cho CA server.
- Đặt tên container là `ca.ibn.ictu.edu.vn`.
- Cài đặt các thông số cấu hình cho server CA.

### Bước 2: Cấp Chứng Chỉ Cho Các Thành Phần

- Sử dụng **fabric-ca-client** để đăng ký và cấp chứng chỉ cho các thành phần như Admin, Peer, Orderer.

### Bước 3: Khởi Tạo và Chạy Orderer

- Tạo cấu hình và khởi chạy **orderer.ictu.edu.vn** với Docker.

### Bước 4: Khởi Tạo và Chạy Peer

- Tạo cấu hình cho **peer0.ibn.ictu.edu.vn** và kết nối nó với Orderer.

### Bước 5: Tạo Channel và Deploy Chaincode

- Tạo channel (vd: `mychannel`) và deploy chaincode như `fabcar`.

### Bước 6: Quản Lý và Thao Tác Dữ Liệu

- Sử dụng **peer CLI** để thực hiện các thao tác như query, invoke trên mạng blockchain.

---

## 🔧 Các Tệp Cấu Hình

- **docker-compose.yaml**: Cấu hình tất cả các dịch vụ Docker (ca, orderer, peer, cli).
- **crypto-config/**: Thư mục lưu trữ các chứng chỉ và khóa bảo mật.
- **configtx.yaml**: Cấu hình cho việc tạo channel và cấu hình các peer, orderer.

## ✅ Kết Quả

Sau khi thực hiện xong, bạn sẽ có một mạng Hyperledger Fabric cơ bản, sẵn sàng để thử nghiệm và học hỏi các tính năng như tạo block, giao dịch và triển khai chaincode.

---

## 📌 Ghi Chú Quan Trọng

- Đảm bảo rằng bạn đã cập nhật các tệp cấu hình với tên miền `ictu.edu.vn`.
- Các container có thể cần được khởi động lại khi cấu hình thay đổi.
- Hãy kiểm tra lại các log Docker để đảm bảo các container hoạt động bình thường.
