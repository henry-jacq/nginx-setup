#!/bin/bash

# This script will setup nginx server for ready to use

serv_avail="/etc/nginx/sites-available"
serv_enabled="/etc/nginx/sites-enabled"
new_doc_root="/var/www/html"
default_page="/usr/share/nginx/html/index.html"
default_error_page="/usr/share/nginx/html/50x.html"
default_server_block="./conf/000-default.conf"
default_server_block_name="000-default.conf"


function verify_exec() {
    # Check if the script running on a arch system
    if [[ ! -f "/etc/arch-release" ]]; then
        echo "==> This script works on arch-based system only!"
        exit -1
    fi
}

function initial_setup() {
    echo -e "\n==> Setting up nginx...\n"
    echo -e "==> Creating server entries...\n"

    if [[ ! -d "$serv_avail" ]]; then
        sudo mkdir -p $serv_avail
    fi

    if [[ ! -d "$serv_enabled" ]]; then
        sudo mkdir -p $serv_enabled
    fi

    sleep 0.5
}

function setup_new_document_root() {
    echo -e "==> Creating new document root '$new_doc_root'\n"
    if [[ ! -d "$new_doc_root" ]]; then
        sudo mkdir -p $new_doc_root
    fi
    sleep 0.5

    echo -e "==> Adding files to new document root...\n"
    if [[ -f $default_page ]]; then
        sudo mv $default_page $new_doc_root
    fi
    if [[ -f $default_error_page ]]; then
        sudo mv $default_error_page $new_doc_root
    fi

    echo -e "==> Updating nginx configuration...\n"
    if [[ -f "./conf/nginx.conf" ]]; then
        sudo cp ./conf/nginx.conf /etc/nginx/nginx.conf
    else
        echo -e "\n==> Nginx config not found!\n"
        exit -1
    fi
    sleep 1

    echo -e "==> Files added to new document root!\n"
    sleep 1
}

function enable_default_server_block() {
    echo -e "==> Copying default server block...\n"
    if [[ -f "$default_server_block" ]]; then
        sudo cp "$default_server_block" $serv_avail
    fi

    echo -e "==> Enabling default server block...\n"
    if [[ -f "$serv_avail/$default_server_block_name" ]]; then
        if [[ ! -f "$serv_enabled/$default_server_block_name" ]]; then
            sudo ln -s "$serv_avail/$default_server_block_name" "$serv_enabled/$default_server_block_name"
        else
            echo -e "==> Default server block already enabled!\n"
        fi
    fi

    sleep 0.5
}

function restart_nginx() {
    echo -e "==> Restarting nginx server...\n"
    sudo systemctl restart nginx
    echo -e "==> Nginx setup installed successfully!\n"
}

function setup_dependencies() {

    echo -e "\n==> Setting up dependencies...\n"

    packages=('nginx-mainline' 'php')

    for package in ${packages[@]}; do
        echo -e "\n==> Installing ${package}...\n"
        sudo pacman -S $package --noconfirm > /dev/null
    done
}

function install_scripts() {
    echo -e "\n==> Installing scripts to manage server blocks..."
    scripts=('e2ensite' 'e2dissite')
    for script in ${scripts[@]}; do
        chmod +x "./scripts/$script"
        sudo cp "./scripts/$script" "/usr/local/bin"
    done
    echo -e "\n==> Scripts installed successfully...\n"
}

function main() {
    setup_dependencies
    verify_exec
    initial_setup
    setup_new_document_root
    enable_default_server_block
    restart_nginx
    install_scripts
}

main "$@"