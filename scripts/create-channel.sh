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

#Tạo channel
print_message "Tạo channel mychannel..."
peer channel create -o orderer.ictu.edu.vn:7050 -c mychannel -f ./config/artifacts/mychannel.tx --outputBlock ./config/artifacts/mychannel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem

# Join channel
print_message "Join peer vào channel..."
peer channel join -b ./config/artifacts/mychannel.block

# Cập nhật anchor peer
print_message "Cập nhật anchor peer..."
peer channel update -o orderer.ictu.edu.vn:7050 -c mychannel -f ./config/artifacts/IbnMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ictu.edu.vn/orderers/orderer.ictu.edu.vn/msp/tlscacerts/tlsca.ictu.edu.vn-cert.pem

print_message "Hoàn thành thiết lập channel!"
print_message "Channel 'mychannel' đã sẵn sàng để deploy chaincode."
