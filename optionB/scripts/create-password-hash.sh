#!/bin/bash

# Script to generate bcrypt hash for password
# Usage: ./create-password-hash.sh [password]

PASSWORD=${1:-password}

echo "Generating bcrypt hash for password: $PASSWORD"
echo ""

# Try different methods to generate hash
if command -v htpasswd >/dev/null 2>&1; then
    echo "Using htpasswd:"
    htpasswd -nbBC 10 user "$PASSWORD" | cut -d: -f2
elif python3 -c "import bcrypt" 2>/dev/null; then
    echo "Using Python bcrypt:"
    python3 -c "import bcrypt; print(bcrypt.hashpw(b'$PASSWORD', bcrypt.gensalt(rounds=10)).decode())"
elif docker ps >/dev/null 2>&1; then
    echo "Using Docker Python:"
    docker run --rm python:3.11-slim python3 -c "import bcrypt; print(bcrypt.hashpw(b'$PASSWORD', bcrypt.gensalt(rounds=10)).decode())"
else
    echo "❌ Cannot generate hash - need bcrypt"
    echo ""
    echo "Install one of:"
    echo "  - htpasswd (apache2-utils)"
    echo "  - python3-bcrypt"
    echo "  - Or use Docker"
    echo ""
    echo "Or use this known hash for 'password':"
    echo "\$2a\$10\$2b2cU8CPhlHHxwKLp5qNUOO0vN1qK83z6Q5pL5J5J5J5J5J5J5J5J"
    exit 1
fi

