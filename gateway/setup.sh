#!/bin/bash

# gateway/setup.sh
# Installs dependencies for all demo cases

BASE_DIR=$(pwd)

echo "Installing dependencies for all demo cases..."

for case_dir in gateway/oracle/case-*; do
    if [ -d "$case_dir" ]; then
        echo "Installing for $(basename "$case_dir")..."
        cd "$case_dir"
        
        # Create a basic package.json if it doesn't exist
        if [ ! -f "package.json" ]; then
            cat <<EOF > package.json
{
  "name": "$(basename "$case_dir")",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "ethers": "^6.13.2",
    "dotenv": "^16.4.5"
  }
}
EOF
        fi
        
        npm install --silent
        cd "$BASE_DIR"
    fi
done

echo "All dependencies installed."
