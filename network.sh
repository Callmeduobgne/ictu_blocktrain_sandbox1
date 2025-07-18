#!/bin/bash

# Thiết lập màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Hàm dừng mạng
network_down() {
    print_message "Dừng mạng Hyperledger Fabric..."
    docker-compose down -v
    docker system prune -f
    sudo rm -rf crypto-config/
    sudo rm -rf config/artifacts/
    print_message "Mạng đã được dừng và dọn dẹp."
}

# Hàm khởi động mạng
network_up() {
    print_step "Bước 1: Tạo crypto material..."
    if ! ./scripts/generate-artifacts.sh; then
        print_error "Lỗi khi tạo artifacts"
        exit 1
    fi
    
    print_step "Bước 2: Khởi động containers..."
    docker-compose up -d
    
    print_message "Chờ containers khởi động..."
    sleep 30
    
    print_step "Bước 3: Tạo channel..."
    docker exec cli ./scripts/create-channel.sh
    
    print_step "Bước 4: Deploy chaincode..."
    docker exec cli ./scripts/deploy-chaincode.sh
    
    print_step "Bước 5: Test chaincode..."
    docker exec cli ./scripts/test-chaincode.sh
    
    print_message "Mạng Hyperledger Fabric đã hoạt động thành công!"
    print_message "Sử dụng 'docker exec -it cli bash' để truy cập CLI container."
}

# Hàm hiển thị trạng thái
network_status() {
    print_message "Trạng thái containers:"
    docker ps -a
    print_message "Trạng thái mạng:"
    docker network ls | grep fabric
}

# Hàm hiển thị log
network_logs() {
    if [ -z "$1" ]; then
        print_message "Hiển thị log tất cả containers:"
        docker-compose logs
    else
        print_message "Hiển thị log container $1:"
        docker logs $1
    fi
}

# Hàm hiển thị hướng dẫn
show_help() {
    echo "Cách sử dụng: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  up      - Khởi động mạng Hyperledger Fabric"
    echo "  down    - Dừng và dọn dẹp mạng"
    echo "  status  - Hiển thị trạng thái mạng"
    echo "  logs    - Hiển thị log (thêm tên container để xem log cụ thể)"
    echo "  help    - Hiển thị hướng dẫn này"
    echo ""
    echo "Ví dụ:"
    echo "  $0 up"
    echo "  $0 down"
    echo "  $0 logs ca.ibn.ictu.edu.vn"
}

# Xử lý tham số dòng lệnh
case "$1" in
    "up")
        network_up
        ;;
    "down")
        network_down
        ;;
    "status")
        network_status
        ;;
    "logs")
        network_logs $2
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        print_error "Lệnh không hợp lệ: $1"
        show_help
        exit 1
        ;;
esac
