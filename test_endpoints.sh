#!/bin/bash

# Configuration
SERVER_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0;0m' # No Color

echo -e "${BLUE}=== Starting Go HTTP Exercise Verification Script ===${NC}\n"

# Exercise 1: Basic Ping-Pong Server
echo -e "${BLUE}[Exercise 1: /ping]${NC}"
RESPONSE=$(curl -s "$SERVER_URL/ping")
if [ "$RESPONSE" == "pong" ]; then
    echo -e "${GREEN}✔ PASS: Got 'pong'${NC}"
else
    echo -e "${RED}✘ FAIL: Expected 'pong', got '$RESPONSE'${NC}"
fi
echo ""

# Exercise 2: Query Parameters & Path Validation
echo -e "${BLUE}[Exercise 2: /hello]${NC}"
# Test with name
RESP_NAME=$(curl -s "$SERVER_URL/hello?name=Alice")
if [[ "$RESP_NAME" == *"Hello, Alice!"* ]]; then
    echo -e "${GREEN}✔ PASS: Query param parsed successfully ('Hello, Alice!')${NC}"
else
    echo -e "${RED}✘ FAIL: Expected 'Hello, Alice!', got '$RESP_NAME'${NC}"
fi

# Test default guest
RESP_GUEST=$(curl -s "$SERVER_URL/hello")
if [[ "$RESP_GUEST" == *"Hello, Guest!"* ]]; then
    echo -e "${GREEN}✔ PASS: Default fallback working ('Hello, Guest!')${NC}"
else
    echo -e "${RED}✘ FAIL: Expected fallback, got '$RESP_GUEST'${NC}"
fi

# Test invalid method validation
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SERVER_URL/hello")
if [ "$STATUS_CODE" == "405" ]; then
    echo -e "${GREEN}✔ PASS: Blocked POST request with Status 405 Method Not Allowed${NC}"
else
    echo -e "${RED}✘ FAIL: POST request gave status $STATUS_CODE instead of 405${NC}"
fi
echo ""

# Exercise 3: Text Counter
echo -e "${BLUE}[Exercise 3: /count]${NC}"
# Test GET
RESP_GET=$(curl -s "$SERVER_URL/count")
if [[ "$RESP_GET" == *"Send a POST request"* ]]; then
    echo -e "${GREEN}✔ PASS: GET request displays instruction text${NC}"
else
    echo -e "${RED}✘ FAIL: Unexpected GET response '$RESP_GET'${NC}"
fi

# Test POST
RESP_POST=$(curl -s -X POST -d "Golang" "$SERVER_URL/count")
if [[ "$RESP_POST" == *"6"* ]]; then
    echo -e "${GREEN}✔ PASS: POST request calculated length correctly ('Golang' = 6)${NC}"
else
    echo -e "${RED}✘ FAIL: Expected length 6, got '$RESP_POST'${NC}"
fi
echo ""
