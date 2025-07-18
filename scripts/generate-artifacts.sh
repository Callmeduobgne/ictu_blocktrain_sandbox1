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

# Kiểm tra và tạo thư mục artifacts
mkdir -p ./config/artifacts

# Bước 1: Tạo chứng chỉ
print_message "Tạo chứng chỉ crypto material..."
if ! cryptogen generate --config=./crypto-config.yaml; then
    print_error "Lỗi khi tạo chứng chỉ"
    exit 1
fi

# Bước 2: Tạo genesis block
print_message "Tạo genesis block..."
if ! configtxgen -profile IctuOrdererGenesis -channelID system-channel -outputBlock ./config/artifacts/genesis.block; then
    print_error "Lỗi khi tạo genesis block"
    exit 1
fi

# Bước 3: Tạo channel transaction
print_message "Tạo channel transaction..."
if ! configtxgen -profile IctuChannel -outputCreateChannelTx ./config/artifacts/mychannel.tx -channelID mychannel; then
    print_error "Lỗi khi tạo channel transaction"
    exit 1
fi

# Bước 4: Tạo anchor peer transaction
print_message "Tạo anchor peer transaction..."
if ! configtxgen -profile IctuChannel -outputAnchorPeersUpdate ./config/artifacts/IbnMSPanchors.tx -channelID mychannel -asOrg IbnMSP; then
    print_error "Lỗi khi tạo anchor peer transaction"
    exit 1
fi

print_message "Hoàn thành thiết lập artifacts!"
print_message "Bạn có thể chạy 'docker-compose up -d' để khởi động mạng."
