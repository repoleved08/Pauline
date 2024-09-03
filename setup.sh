#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NEON='\033[1;35m'
RESET='\033[0m'

# Function to check and install figlet
install_figlet() {
    if ! command -v figlet &> /dev/null; then
        echo -e "${BLUE}figlet not found. Installing figlet...${RESET}"
        sudo apt-get update
        sudo apt-get install -y figlet
    else
        echo -e "${GREEN}figlet is already installed.${RESET}"
    fi
}

# Function to check and install Go
install_go() {
    if ! command -v go &> /dev/null; then
        echo -e "${BLUE}Go not found. Installing Go...${RESET}"
        wget https://golang.org/dl/go1.20.3.linux-amd64.tar.gz -O go.tar.gz
        sudo tar -C /usr/local -xzf go.tar.gz
        export PATH=$PATH:/usr/local/go/bin
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        source ~/.bashrc
    else
        echo -e "${GREEN}Go is already installed.${RESET}"
    fi
}

# Install dependencies
install_figlet
install_go

# ASCII banner for script name
echo -e "${NEON}$(figlet -f slant 'Pauline')${RESET}"

# Prompt for project name
echo -e "${NEON}Enter the project name:${RESET} "
read project_name

# Check if the directory already exists
if [ -d "$project_name" ]; then
    echo -e "${RED}Directory '$project_name' already exists. Exiting.${RESET}"
    exit 1
fi

# Create project directory and navigate into it
mkdir "$project_name"
cd "$project_name" || exit

# Prompt for module name
echo -e "${NEON}Enter the Go module name:${RESET} "
read module_name

# Define the folder structure
folders=(
    "cmd"
    "config"
    "controllers"
    "middleware"
    "models"
    "routes"
)

# Create the folders
for folder in "${folders[@]}"; do
    mkdir -p "$folder"
done

# Create initial files
touch cmd/main.go
touch config/config.go
touch middleware/middleware.go
touch routes/routes.go

# Initialize Go module
echo -e "${GREEN}Initializing Go module: $module_name${RESET}"
go mod init "$module_name"
go get -u gorm.io/gorm
go get github.com/golang-jwt/jwt/v5
go get golang.org/x/crypto/bcrypt
go get github.com/joho/godotenv
go get -u gorm.io/driver/postgres

# Create .env file
cat <<EOL > .env
DB_HOST=localhost
DB_PORT=5432
DB_USER=user
DB_PASSWORD=password
DB_NAME=database
EOL

# Create .gitignore file
cat <<EOL > .gitignore
# Go binaries
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
# Logs
*.log
# Dependency directories
vendor/
# Environment files
.env
# Ignore docs folder
docs/
EOL

echo -e "${GREEN}Setup complete!${RESET}"

