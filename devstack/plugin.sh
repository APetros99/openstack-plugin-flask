#!/bin/bash

# Usa realpath per garantire path assoluti
PLUGIN_DIR=$(realpath /opt/stack/openstack-plugin-flask)
APP_DIR=$(realpath "$PLUGIN_DIR/app")
SERVICE_DIR=$(realpath "$PLUGIN_DIR/devstack/service")
SYSTEMD_DIR=$(realpath /etc/systemd/system)

# Log delle directory per debug
echo "PLUGIN_DIR: $PLUGIN_DIR"
echo "APP_DIR: $APP_DIR"
echo "SERVICE_DIR: $SERVICE_DIR"
echo "SYSTEMD_DIR: $SYSTEMD_DIR"

# Funzione per installare le dipendenze Flask
function install_flask_dependencies {
    echo "🛠️ Installing Flask and dependencies..."

    # 1️⃣ Verifica se la directory APP_DIR esiste
    if [[ ! -d "$APP_DIR" ]]; then
        echo "❌ ERROR: Directory $APP_DIR does not exist."
        exit 1
    fi

    # 2️⃣ Crea la virtual environment se non esiste
    if [[ ! -d "$APP_DIR/venv" ]]; then
        echo "📦 Creating virtual environment in $APP_DIR/venv"
        python3 -m venv "$APP_DIR/venv" || { echo "❌ ERROR: Failed to create virtual environment"; exit 1; }
    fi

    # 3️⃣ Attiva la virtual environment
    echo "🐍 Activating virtual environment in $APP_DIR/venv"
    source "$APP_DIR/venv/bin/activate"

    # 4️⃣ Controlla se il file requirements.txt esiste
    if [[ ! -f "$APP_DIR/requirements.txt" ]]; then
        echo "❌ ERROR: requirements.txt not found in $APP_DIR"
        deactivate
        exit 1
    fi

    # 5️⃣ Installa le dipendenze
    echo "📦 Installing Python dependencies from $APP_DIR/requirements.txt"
    pip install -r "$APP_DIR/requirements.txt" || { 
        echo "❌ ERROR: Failed to install dependencies"; 
        deactivate; 
        exit 1; 
    }

    # 6️⃣ Disattiva la virtual environment
    deactivate
    echo "✅ Flask dependencies installed successfully"
}

# Funzione per copiare il file di servizio systemd
function copy_service_file {
    echo "🛠️ Moving service file to systemd directory..."

    # 1️⃣ Controlla se il file esiste
    if [[ ! -f "$SERVICE_DIR/openstack-plugin-flask.service" ]]; then
        echo "❌ ERROR: Service file not found at $SERVICE_DIR/openstack-plugin-flask.service"
        exit 1
    fi

    # 2️⃣ Copia il file nella directory systemd
    sudo cp "$SERVICE_DIR/openstack-plugin-flask.service" "$SYSTEMD_DIR" || { 
        echo "❌ ERROR: Failed to copy service file"; 
        exit 1; 
    }

    # 3️⃣ Abilita il servizio e ricarica systemd
    sudo systemctl enable openstack-plugin-flask.service || { 
        echo "❌ ERROR: Failed to enable systemd plugin service"; 
        exit 1; 
    }

    sudo systemctl daemon-reload || { 
        echo "❌ ERROR: Failed to reload systemd daemon"; 
        exit 1; 
    }

    echo "✅ Service file successfully moved and systemd reloaded"
}

# Funzione per avviare il plugin Flask
function start_flask_plugin {
    echo "🚀 Starting Flask service..."
    sudo systemctl start openstack-plugin-flask.service || { 
        echo "❌ ERROR: Failed to start service"; 
        exit 1; 
    }
    echo "✅ Flask service started successfully"
}

# Funzione di configurazione del plugin
function configure_flask_plugin {
    echo "⚙️ Configuring Flask service..."
    # Aggiungi qui le configurazioni specifiche del plugin Flask
}

# Log delle azioni eseguite in DevStack
if is_service_enabled openstack-plugin-flask; then
    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        echo "🛠️ No additional packages to install for Flask Plugin."

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        echo "📦 Installing Flask Plugin"
        install_flask_dependencies
        copy_service_file

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        echo "⚙️ Configuring Flask Plugin"
        configure_flask_plugin

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        echo "🚀 Initializing Flask Plugin"
        start_flask_plugin
    fi

    if [[ "$1" == "unstack" ]]; then
        echo "🛠️ Stopping Flask service..."
        sudo systemctl stop openstack-plugin-flask.service || { 
            echo "❌ ERROR: Failed to stop service"; 
            exit 1; 
        }
    fi

    if [[ "$1" == "clean" ]]; then
        echo "🛠️ Removing service file from systemd directory..."
        sudo rm "$SYSTEMD_DIR/openstack-plugin-flask.service" || { 
            echo "❌ ERROR: Failed to remove service file"; 
            exit 1; 
        }
    fi
fi
