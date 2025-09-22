#!/bin/bash

# Mini Threat Intel Collector
# Uses AbuseIPDB API to check if IPs are malicious

API_KEY="a721609a2053460d9e3ccbd75c28085e47bba24b840c005a75876f495b26cb56971c5cb74c2a272e"
INPUT_FILE="ips.txt"
OUTPUT_FILE="report.txt"


> "$OUTPUT_FILE"

while read -r ip; do
    echo "Checking $ip..."
    response=$(curl -sG https://api.abuseipdb.com/api/v2/check \
      --data-urlencode "ipAddress=$ip" \
      -d maxAgeInDays=90 \
      -H "Key: $API_KEY" \
      -H "Accept: application/json")

    # Extract relevant fields using jq
    score=$(echo "$response" | jq -r '.data.abuseConfidenceScore')
    country=$(echo "$response" | jq -r '.data.countryCode')

    echo "$ip | Abuse Score: $score | Country: $country" >> "$OUTPUT_FILE"
done < "$INPUT_FILE"

echo "✅ Report generated in $OUTPUT_FILE"

