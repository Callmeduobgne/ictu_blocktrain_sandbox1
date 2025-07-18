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
CHANNEL_NAME="mychannel"

# Test 1: Query tất cả xe
print_message "Test 1: Query tất cả xe..."
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["queryAllCars"]}'

# Test 2: Query xe cụ thể
print_message "Test 2: Query xe CAR0..."
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["queryCar","CAR0"]}'

# Test 3: Tạo xe mới
print_message "Test 3: Tạo xe mới CAR10..."
peer chaincode invoke -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem -C $CHANNEL_NAME -n $CHAINCODE_NAME --peerAddresses peer0.ibn.ictu.edu.vn:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt -c '{"Args":["createCar","CAR10","Toyota","Prius","Blue","Tom"]}'

# Test 4: Query xe vừa tạo
print_message "Test 4: Query xe CAR10 vừa tạo..."
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["queryCar","CAR10"]}'

# Test 5: Chuyển chủ sở hữu
print_message "Test 5: Chuyển chủ sở hữu CAR10..."
peer chaincode invoke -o orderer.ictu.edu.vn:7050 --ordererTLSHostnameOverride orderer.ictu.edu.vn --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem -C $CHANNEL_NAME -n $CHAINCODE_NAME --peerAddresses peer0.ibn.ictu.edu.vn:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibn.ictu.edu.vn/peers/peer0.ibn.ictu.edu.vn/tls/ca.crt -c '{"Args":["changeCarOwner","CAR10","Jerry"]}'

# Test 6: Query xe sau khi chuyển chủ
print_message "Test 6: Query xe CAR10 sau khi chuyển chủ..."
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["queryCar","CAR10"]}'

print_message "Hoàn thành test chaincode!"
print_message "Mạng Hyperledger Fabric đã hoạt động thành công!"
