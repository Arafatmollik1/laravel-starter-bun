#!/bin/bash
# Generate PgBouncer userlist.txt entries
# Usage: ./docker/pgbouncer/generate-userlist.sh username password

if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    echo "Example: $0 laravel mypassword"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Generate MD5 hash: md5(password + username)
HASH=$(echo -n "${PASSWORD}${USERNAME}" | md5sum | awk '{print $1}')

echo "\"${USERNAME}\" \"md5${HASH}\""

