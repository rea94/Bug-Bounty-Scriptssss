#!/bin/bash


echo "   ____             "
echo "  / ___|___   ____  "
echo " | |   / _ \ / _  | "
echo " | |__| (_) | (_| | "
echo "  \____\___/ \____| "



urlsfile=$1

if [ -z "$urlsfile" ]; then
    echo "Usage: $0 <urlsfile>"
    exit 1
fi

function checkacao {
    local url=$1
    local origin=$2

    curl -vs "$url" -H"Origin: $origin" 2>&1 | grep -i "< Access-Control-Allow-Origin: $origin" &> /dev/null
}

function checkacac {
    local url=$1
    local origin=$2

    curl -vs "$url" -H"Origin: $origin" 2>&1 | grep -i "< Access-Control-Allow-Credentials: true" &> /dev/null
}

while read url; do
    domain=$(echo "$url" | sed -r 's#https?://([^/]*)/?.*#\1#')

    for origin in https://evil.com null https://$domain.evil.com https://${domain}evil.com; do
        if checkacao $url $origin; then
            echo "$url might be vulnerable with origin '$origin'"

            if checkacac $url $origin; then
                echo "$url with origin '$origin' has Allow-Credentials: true"
            fi
        else
            echo "$url isn't vulnerable with origin '$origin'"
        fi
        sleep 2
    done
done < $urlsfile
