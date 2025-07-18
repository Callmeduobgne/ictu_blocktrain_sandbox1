#!/bin/bash

# Thiết lập màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hàm in thông báo
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Thiết lập biến môi trường
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="IbnMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/users/Admin@ibn.ictu.edu.vn/msp
export CORE_PEER_ADDRESS=peer0.ibn.ictu.edu.vn:7051

CHAINCODE_NAME="fabcar"
CHAINCODE_VERSION="1.0"
CHANNEL_NAME="mychannel"

# Bước 1: Package chaincode
print_message "Đóng gói chaincode..."
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ./chaincode/fabcar/go --lang golang --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION}

if [ $? -eq 0 ]; then
    print_message "Chaincode đã được đóng gói thành công"
else
    print_error "Lỗi khi đóng gói chaincode"
    exit 1
fi

# Bước 2: Install chaincode
print_message "Cài đặt chaincode..."
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

if [ $? -eq 0 ]; then
    print_message "Chaincode đã được cài đặt thành công"
else
    print_error "Lỗi khi cài đặt chaincode"
    exit 1
fi

# Bước 3: Query installed chaincode
print_message "Kiểm tra chaincode đã cài đặt..."
peer lifecycle chaincode queryinstalled

# Lấy package ID
PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep ${CHAINCODE_NAME}_${CHAINCODE_VERSION} | awk '{print $3}' | cut -d',' -f1)
print_message "Package ID: $PACKAGE_ID"

if [ -z "$PACKAGE_ID" ]; then
    print_error "Không thể lấy Package ID"
    exit 1
fi

# Bước 4: Approve chaincode
print_message "Phê duyệt chaincode..."
peer lifecycle chaincode approveformyorg -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --package-id ${PACKAGE_ID} --sequence 1

if [ $? -eq 0 ]; then
    print_message "Chaincode đã được phê duyệt thành công"
else
    print_error "Lỗi khi phê duyệt chaincode"
    exit 1
fi

# Bước 5: Check commit readiness
print_message "Kiểm tra sẵn sàng commit..."
peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem --output json

# Bước 6: Commit chaincode
print_message "Commit chaincode..."
peer lifecycle chaincode commit -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --peerAddresses peer0.ibn.ictu.edu.vn:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt --version ${CHAINCODE_VERSION} --sequence 1

if [ $? -eq 0 ]; then
    print_message "Chaincode đã được commit thành công"
else
    print_error "Lỗi khi commit chaincode"
    exit 1
fi

# Bước 7: Query committed chaincode
print_message "Kiểm tra chaincode đã commit..."
peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem

# Bước 8: Initialize chaincode
print_message "Khởi tạo chaincode..."
peer chaincode invoke -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} --peerAddresses peer0.ibn.ictu.edu.vn:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

if [ $? -eq 0 ]; then
    print_message "Chaincode đã được khởi tạo thành công"
else
    print_warning "Có thể có lỗi khi khởi tạo chaincode"
fi

print_message "Hoàn thành deploy chaincode!"
print_message "Chaincode '${CHAINCODE_NAME}' đã sẵn sàng để sử dụng."
