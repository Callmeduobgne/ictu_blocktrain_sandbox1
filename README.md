# Mạng Hyperledger Fabric - Tổ chức Ibn

## Tổng quan

Dự án này triển khai một mạng Hyperledger Fabric đơn giản với các thành phần:

- 1 Certificate Authority (CA)
- 1 Orderer
- 1 Peer (peer0.ibn.ictu.edu.vn)
- 1 CLI container
- 1 Chaincode (Fabcar)

## Cấu trúc thư mục

.
├── docker-compose.yaml       # Cấu hình Docker containers
├── crypto-config.yaml        # Cấu hình tạo chứng chỉ
├── configtx.yaml            # Cấu hình channel và network
├── network.sh               # Script chính để quản lý mạng
├── scripts/
│   ├── generate-artifacts.sh # Tạo artifacts
│   ├── create-channel.sh     # Tạo channel
│   ├── deploy-chaincode.sh   # Deploy chaincode
│   └── test-chaincode.sh     # Test chaincode
├── config/
│   └── artifacts/           # Chứa genesis block, channel tx
├── crypto-config/           # Chứa chứng chỉ và keys
└── README.md               # File này

## Yêu cầu hệ thống

- Docker >= 20.x
- Docker Compose >= 1.29
- Git
- Bash shell

## Cài đặt và chạy

### 1. Chuẩn bị

```bash
# Cấp quyền thực thi cho các script
chmod +x network.sh
chmod +x scripts/*.sh
```

### 2. Khởi động mạng

```bash
# Khởi động toàn bộ mạng
./network.sh up
```

### 3. Kiểm tra trạng thái

```bash
# Xem trạng thái containers
./network.sh status

# Xem log của tất cả containers
./network.sh logs

# Xem log của container cụ thể
./network.sh logs ca.ibn.ictu.edu.vn
```

### 4. Tương tác với mạng

```bash
# Truy cập CLI container
docker exec -it cli bash

# Trong CLI container, bạn có thể chạy các lệnh peer
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'
```

### 5. Dừng mạng

```bash
# Dừng và dọn dẹp mạng
./network.sh down
```

## Các lệnh chaincode hữu ích

### Query tất cả xe

```bash
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'
```

### Query xe cụ thể

```bash
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR0"]}'
```

### Tạo xe mới

```bash
peer chaincode invoke -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem -C mychannel -n fabcar --peerAddresses peer0.ibn.ictu.edu.vn:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt -c '{"Args":["createCar","CAR11","Honda","Civic","Red","Alice"]}'
```

### Chuyển chủ sở hữu

```bash
peer chaincode invoke -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem -C mychannel -n fabcar --peerAddresses peer0.ibn.ictu.edu.vn:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt -c '{"Args":["changeCarOwner","CAR11","Bob"]}'
```

## Cấu hình mạng

### Thành phần

- **CA**: `ca.ibn.ictu.edu.vn:7054`
- **Orderer**: `orderer.ictu.edu.vn:7050`
- **Peer**: `peer0.ibn.ictu.edu.vn:7051`
- **Channel**: `mychannel`
- **Chaincode**: `fabcar`

### Cổng

- CA: 7054
- Orderer: 7050
- Peer: 7051
- CLI: Không có cổng external

## Troubleshooting

### Lỗi thường gặp

1. **Container không khởi động**: Kiểm tra Docker daemon
2. **Lỗi chứng chỉ**: Xóa thư mục crypto-config và chạy lại
3. **Lỗi channel**: Đảm bảo tất cả containers đang chạy

### Dọn dẹp hoàn toàn

```bash
./network.sh down
docker system prune -a
sudo rm -rf crypto-config/ config/artifacts/
```

## Triển khai lên server

1. Sao chép tệp lên server:

```bash
scp -r /Users/duongluong/ictu_blocktrain_sandbox1 user@server:/path/to/destination
```

2.Cài đặt Docker trên server:

```bash
sudo apt update
sudo apt install docker.io docker-compose -y
```

3.Chạy mạng trên server:

```bash
./network.sh up
```

## Liên hệ

Nếu có vấn đề, vui lòng tạo issue hoặc liên hệ admin.
