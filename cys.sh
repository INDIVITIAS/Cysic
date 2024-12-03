#!/bin/bash

# Цвета и форматирование
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки
ICON_INSTALL="🛠️"
ICON_START="▶️"
ICON_RESTART="🔄"
ICON_LOGS="📄"
ICON_DELETE="🗑️"
ICON_EXIT="❌"

# Функции для рисования
draw_border() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle() {
    echo -e "${CYAN}╠════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom() {
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${RESET}"
}

# Логотип
display_logo() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \\  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\\ \\  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
}

# Установка
install_node() {
    echo -e "${YELLOW}Начинаем установку ноды...${RESET}"
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt-get install -y make screen build-essential unzip lz4 gcc git jq
    read -p "Введите ваш EVM-кошелек: " evm_wallet

    curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
    bash ~/setup_linux.sh "$evm_wallet"
    cd ~/cysic-verifier/ || exit
    bash start.sh
    sleep 5
    pkill -f start.sh

    # Добавление в systemd
    sudo tee /etc/systemd/system/cysic.service > /dev/null <<EOF
[Unit]
Description=Cysic Verifier
After=network.target

[Service]
User=$USER
WorkingDirectory=/root/cysic-verifier
ExecStart=/bin/bash /root/cysic-verifier/start.sh
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable cysic
    sudo systemctl daemon-reload
    sudo systemctl start cysic
    echo -e "${GREEN}Установка завершена!${RESET}"
}

# Запуск
start_node() {
    echo -e "${YELLOW}Запускаем ноду...${RESET}"
    sudo systemctl start cysic
    echo -e "${GREEN}Нода запущена.${RESET}"
}

# Перезапуск
restart_node() {
    echo -e "${YELLOW}Перезагружаем ноду...${RESET}"
    sudo systemctl restart cysic
    echo -e "${GREEN}Нода перезагружена.${RESET}"
}

# Логи
check_logs() {
    echo -e "${YELLOW}Просмотр логов. Для выхода нажмите Ctrl+C.${RESET}"
    sudo journalctl -u cysic -f --no-hostname -o cat
}

# Удаление
delete_node() {
    read -p "Вы уверены, что хотите удалить ноду? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        sudo systemctl stop cysic
        sudo systemctl disable cysic
        sudo rm /etc/systemd/system/cysic.service
        sudo systemctl daemon-reload
        sudo rm -rf ~/cysic-verifier
        echo -e "${RED}Нода удалена.${RESET}"
    else
        echo -e "${YELLOW}Удаление отменено.${RESET}"
    fi
}

# Выход
exit_script() {
    echo -e "${YELLOW}Выход...${RESET}"
    exit 0
}

# Меню
show_menu() {
    clear
    draw_border
    display_logo
    draw_middle
    echo -e " ${CYAN}1.${RESET} ${ICON_INSTALL} Установка ноды"
    echo -e " ${CYAN}2.${RESET} ${ICON_START} Запуск ноды"
    echo -e " ${CYAN}3.${RESET} ${ICON_RESTART} Перезапуск"
    echo -e " ${CYAN}4.${RESET} ${ICON_LOGS} Логи"
    echo -e " ${CYAN}5.${RESET} ${ICON_DELETE} Удаление"
    echo -e " ${CYAN}6.${RESET} ${ICON_EXIT} Выход"
    draw_bottom
    read -p "Ваш выбор [1-6]: " choice
}

# Основной цикл
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) start_node ;;
        3) restart_node ;;
        4) check_logs ;;
        5) delete_node ;;
        6) exit_script ;;
        *) echo -e "${RED}Неверный выбор!${RESET}" ;;
    esac
    sleep 1
done
