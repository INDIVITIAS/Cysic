#!/bin/bash

# Определения цветов и форматирования
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки для пунктов меню
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_SSH="🔑"
ICON_START="▶️"
ICON_RESTART="🔄"
ICON_LOGS="📄"
ICON_DELETE="🗑️"
ICON_EXIT="❌"

# Функции для рисования границ
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}

print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_TELEGRAM} Подписывайтесь на наш Telegram!${RESET}"
}

# Логотип и информация
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \\  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\\ \\  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo -e ""
    echo -e "${YELLOW}Подписывайтесь на Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}Подписывайтесь на YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Здесь про аирдропы и ноды: https://t.me/indivitias${RESET}"
    echo -e "${YELLOW}Купи мне крипто бутылочку... кефира 😏${RESET} ${MAGENTA} 👉  https://bit.ly/4eBbfIr  👈 ${MAGENTA}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ll"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd hyperlane"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e "  - ${YELLOW}Запуск меню скрипта (не установка) из директории hyperlane:${RESET} bash hyper.sh"
    echo -e ""
}

# Функция для установки ноды
install_node() {
    echo 'Начинаю установку ноды...'

    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y make screen build-essential unzip lz4 gcc git jq

    read -p "Введите ваш EVM-кошелек: " evm_wallet

    curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
    bash ~/setup_linux.sh $evm_wallet

    cd ~/cysic-verifier/
    bash start.sh
    sleep 5
    pkill -f start.sh

    sudo tee /etc/systemd/system/cysic.service > /dev/null <<EOF
[Unit]
Description=Cysic Verifier
After=network.target

[Service]
User=$USER
WorkingDirectory=/root/cysic-verifier
ExecStart=bash /root/cysic-verifier/start.sh
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable cysic
    sudo systemctl daemon-reload
    sudo systemctl start cysic

    echo "Нода Cysic успешно установлена и настроена."
}

# Функция для запуска ноды
start_node() {
    echo 'Запускаем ноду...'
    sudo systemctl start cysic
    echo 'Нода запущена.'
}

# Функция для перезагрузки ноды
restart_node() {
    echo 'Перезагружаем ноду...'
    sudo systemctl restart cysic
    echo 'Нода перезагружена.'
}

# Функция для просмотра логов
check_logs() {
    sudo journalctl -u cysic -f --no-hostname -o cat
}

# Функция для удаления ноды
delete_node() {
    read -p 'Вы уверены, что хотите удалить ноду? (y/n): ' confirm
    if [[ $confirm == [yY] ]]; then
        echo 'Удаляем ноду...'
        sudo systemctl stop cysic
        sudo systemctl disable cysic
        sudo rm /etc/systemd/system/cysic.service
        sudo systemctl daemon-reload
        sudo rm -rf ~/cysic-verifier
        echo 'Нода удалена.'
    else
        echo 'Удаление ноды отменено.'
    fi
}

# Функция для выхода из скрипта
exit_from_script() {
    exit 0
}

# Отображение меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    echo -e "    ${YELLOW}Пожалуйста, выберите опцию:${RESET}"
    echo
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установка и настройка ноды"
    echo -e "    ${CYAN}2.${RESET} ${ICON_START} Запуск ноды"
    echo -e "    ${CYAN}3.${RESET} ${ICON_RESTART} Перезагрузка ноды"
    echo -e "    ${CYAN}4.${RESET} ${ICON_LOGS} Просмотр логов"
    echo -e "    ${CYAN}5.${RESET} ${ICON_DELETE} Удаление ноды"
    echo -е "    ${CYAN}6.${RESET} ${ICON_EXIT} Выйти из скрипта"
    draw_bottom_border
    echo -е "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -е "${CYAN}║${RESET}              ${YELLOW}Введите свой выбор [1-6]:${RESET}           ${CYAN}║${RESET}"
    echo -е "${CYАН}╚══════════════════════════════════════════════════════╝${RESET}"
    read -p " " choice
}

# Основное меню
while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            start_node
            ;;
        3)
            restart_node
            ;;
        4)
            check_logs
            ;;
        5)
            delete_node
            ;;
        6)
            exit_from_script
            ;;
        *)
            echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
            ;;
    esac
done
