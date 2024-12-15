#!/bin/bash

# Imposta i percorsi assoluti per garantire che le directory siano sempre corrette
PLUGIN_DIR=$(realpath /opt/stack/openstack-plugin-flask)
APP_DIR=$(realpath "$PLUGIN_DIR/app")
SERVICE_DIR=$(realpath "$PLUGIN_DIR/devstack/service")
SYSTEMD_DIR=$(realpath /etc/systemd/system)

# Log dei percorsi per debug
echo "Paths in use:"
echo "PLUGIN_DIR: $PLUGIN_DIR"
echo "APP_DIR: $APP_DIR"
echo "SERVICE_DIR: $SERVICE_DIR"
echo "SYSTEMD_DIR: $SYSTEMD_DIR"

# Funzione per installare le dipendenze necessarie per il plugin Flask
function install_flask_dependencies {
    echo "Installing Flask and its dependencies..."

    # Controlla se la directory esiste
    if [[ ! -d "$APP_DIR" ]]; then
        echo "ERROR: Directory $APP_DIR does not exist."
        exit 1
    fi

    # Crea la virtual environment se non esiste
    if [[ ! -d "$APP_DIR/venv" ]]; then
        echo "Creating virtual environment in $APP_DIR/venv"
        python3 -m venv "$APP_DIR/venv" || { echo "ERROR: Failed to create virtual environment"; exit 1; }
    fi

    # Attiva la virtual environment
    echo "Activating virtual environment"
    source "$APP_DIR/venv/bin/activate"

    # Controlla la presenza di requirements.txt
    if [[ ! -f "$APP_DIR/requirements.txt" ]]; then
        echo "ERROR: requirements.txt not found in $APP_DIR"
        deactivate
        exit 1
    fi

    # Installa le dipendenze
    echo "Installing dependencies from requirements.txt"
    pip install -r "$APP_DIR/requirements.txt" || { 
        echo "ERROR: Failed to install dependencies"; 
        deactivate
        exit 1
    }

    # Disattiva la virtual environment
    deactivate
    echo "Flask dependencies installed successfully"
}

# Funzione per copiare il file di servizio systemd
function copy_service_file {
    echo "Copying service file to systemd directory..."

    # Verifica che il file di servizio esista
    if [[ ! -f "$SERVICE_DIR/openstack-plugin-flask.service" ]]; then
        echo "ERROR: Service file not found at $SERVICE_DIR/openstack-plugin-flask.service"
        exit 1
    fi

    # Copia il file di servizio nella directory di systemd
    sudo cp "$SERVICE_DIR/openstack-plugin-flask.service" "$SYSTEMD_DIR" || { 
        echo "ERROR: Failed to copy service file"; 
        exit 1 
    }

    # Abilita il servizio e ricarica systemd
    sudo systemctl enable openstack-plugin-flask.service || { 
        echo "ERROR: Failed to enable the systemd service"; 
        exit 1 
    }

    sudo systemctl daemon-reload || { 
        echo "ERROR: Failed to reload systemd daemon"; 
        exit 1 
    }

    echo "Service file copied successfully, and systemd reloaded"
}

# Funzione per avviare il servizio Flask
function start_flask_plugin {
    echo "Starting Flask service..."
    sudo systemctl start openstack-plugin-flask.service || { 
        echo "ERROR: Failed to start the Flask service"; 
        exit 1 
    }
    echo "Flask service started successfully"
}

# Funzione per configurare il plugin Flask (se necessario)
function configure_flask_plugin {
    echo "Configuring Flask service..."
    # Configurazioni specifiche possono essere aggiunte qui
}

# Se il servizio è abilitato, esegui i comandi in base allo stato di DevStack
if is_service_enabled openstack-plugin-flask; then
    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        echo "Pre-install step for Flask Plugin - nothing to do here."

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        echo "Installing Flask Plugin"
        install_flask_dependencies
        copy_service_file

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        echo "Configuring Flask Plugin"
        configure_flask_plugin

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        echo "Initializing Flask Plugin"
        start_flask_plugin
    fi

    if [[ "$1" == "unstack" ]]; then
        echo "Stopping Flask service..."
        sudo systemctl stop openstack-plugin-flask.service || { 
            echo "ERROR: Failed to stop the service"; 
            exit 1 
        }
    fi

    if [[ "$1" == "clean" ]]; then
        echo "Cleaning systemd service file..."
        sudo rm "$SYSTEMD_DIR/openstack-plugin-flask.service" || { 
            echo "ERROR: Failed to remove the service file"; 
            exit 1 
        }
    fi
fi
