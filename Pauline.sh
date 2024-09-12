#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NEON='\033[1;35m'
RESET='\033[0m'
NEON='\033[1;35m'   # Neon color (magenta)
RESET='\033[0m'     # Reset color
SMALL_TEXT='\033[0;36m'  # Cyan for small text

# Function to display loader
show_loader() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep "$pid")" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to check and install figlet
install_figlet() {
    echo -e "${BLUE}Checking system requirements...${RESET}"
    sleep 2
    if ! command -v figlet &> /dev/null; then
        echo -e "${BLUE}figlet not found. Installing figlet...${RESET}"
        sudo apt-get update && sudo apt-get install -y figlet &
        show_loader
    else
        echo -e "${GREEN}figlet is already installed.${RESET}"
    fi
}

# Function to check and install Go
install_go() {
    if ! command -v go &> /dev/null; then
        echo -e "${BLUE}Go not found. Installing Go...${RESET}"
        wget https://golang.org/dl/go1.20.3.linux-amd64.tar.gz -O go.tar.gz &
        show_loader
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
figlet_output=$(figlet -f Bloody 'Pauline')
echo -e "${NEON}${figlet_output}${RESET}"

# Get terminal width and calculate padding
terminal_width=$(tput cols)
small_text="Developed by: Norman Bii"
contact_text="Contact: techxtrasol.design@gmail.com"
padding=$(( (terminal_width - ${#small_text}) / 4 ))
contact_padding=$(( (terminal_width - ${#contact_text}) / 4 ))

# Centered smaller text
printf "%${padding}s${SMALL_TEXT}%s${RESET}\n" "" "$small_text"
printf "%${contact_padding}s${SMALL_TEXT}%s${RESET}\n" "" "$contact_text"

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
    "handlers"
    "middleware"
    "models"
    "routes"
)

# Create the folders and insert content into files
for folder in "${folders[@]}"; do
    mkdir -p "$folder"
    if [[ "$folder" == "config" ]]; then
        # Add initial code for config.go
        cat <<EOL > config/config.go
package config

import (
    "fmt"
    "log"
    "os"
    "github.com/joho/godotenv"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() {
    err := godotenv.Load()
    if err != nil {
        log.Fatal("Error loading .env file")
    }

    dsn := fmt.Sprintf("user=%s host=%s password=%s port=%s dbname=%s sslmode=disable",
        os.Getenv("DB_USER"),
        os.Getenv("DB_HOST"),
        os.Getenv("DB_PASSWORD"),
        os.Getenv("DB_PORT"),
        os.Getenv("DB_NAME"),
    )

    var dbError error
    DB, dbError = gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if dbError != nil {
        log.Fatal("Failed to connect to the database", dbError)
    }

    fmt.Println("Database connected successfully!")
}
EOL
    else
        # Create default files for other folders
        touch "$folder/$folder.go"
        echo "package $folder" > "$folder/$folder.go"
    fi
done

# Special case for main.go in the cmd folder
cat <<EOL > cmd/main.go
package main

import (
    "fmt"
)

func main() {
    fmt.Println("Hello, World!")
}
EOL

# Initialize Go module and handle go mod errors
echo -e "${GREEN}Initializing Go module: $module_name${RESET}"
if ! go mod init "$module_name"; then
    echo -e "${RED}Failed to initialize Go module.${RESET}"
    exit 1
fi

# Install Go dependencies with loader and error handling
dependencies=(
    "gorm.io/gorm"
    "github.com/golang-jwt/jwt/v5"
    "golang.org/x/crypto/bcrypt"
    "github.com/joho/godotenv"
    "gorm.io/driver/postgres"
)

for dep in "${dependencies[@]}"; do
    echo -e "${NEON}Installing $dep...${RESET}"
    go get -u "$dep" &
    show_loader
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install $dep.${RESET}"
    else
        echo -e "${GREEN}$dep installed successfully.${RESET}"
    fi
done

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

# Run go mod tidy and handle errors
echo -e "${NEON}Tidying up Go modules...${RESET}"
if ! go mod tidy; then
    echo -e "${RED}Failed to tidy Go modules.${RESET}"
else
    echo -e "${GREEN}Go modules tidied successfully.${RESET}"
fi

echo -e "${GREEN}Setup complete!${RESET}"
