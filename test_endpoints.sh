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

# Exercise 4: Basic Math API
echo -e "${BLUE}[Exercise 4: /calculate]${NC}"
# Test valid math
RESP_MATH=$(curl -s "$SERVER_URL/calculate?op=add&a=12&b=8")
if [[ "$RESP_MATH" == *"20"* ]]; then
    echo -e "${GREEN}✔ PASS: 12 + 8 = 20 handled successfully${NC}"
else
    echo -e "${RED}✘ FAIL: Expected 20, got '$RESP_MATH'${NC}"
fi

# Test invalid input validation
STATUS_MATH=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/calculate?op=multiply&a=abc&b=5")
if [ "$STATUS_MATH" == "400" ]; then
    echo -e "${GREEN}✔ PASS: Rejected non-integer values with Status 400 Bad Request${NC}"
else
    echo -e "${RED}✘ FAIL: Expected status 400 for bad parameters, got $STATUS_MATH${NC}"
fi
echo ""

# Exercise 5: User-Agent Echo
echo -e "${BLUE}[Exercise 5: /agent]${NC}"
RESP_AGENT=$(curl -s -H "User-Agent: CustomTester/1.0" "$SERVER_URL/agent")
if [[ "$RESP_AGENT" == *"CustomTester/1.0"* ]]; then
    echo -e "${GREEN}✔ PASS: Header value extracted and echoed back${NC}"
else
    echo -e "${RED}✘ FAIL: Expected agent info to be visible, got '$RESP_AGENT'${NC}"
fi
echo ""

# Exercise 6: Secure Dashboard
echo -e "${BLUE}[Exercise 6: /dashboard]${NC}"
# Test unauthorized access
STATUS_DASH_BAD=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/dashboard")
if [ "$STATUS_DASH_BAD" == "401" ]; then
    echo -e "${GREEN}✔ PASS: Missing API key blocked with Status 401 Unauthorized${NC}"
else
    echo -e "${RED}✘ FAIL: Expected status 401 for unauthorized traffic, got $STATUS_DASH_BAD${NC}"
fi

# Test authorized access
RESP_DASH_GOOD=$(curl -s -H "X-API-Key: secret123" "$SERVER_URL/dashboard")
if [[ "$RESP_DASH_GOOD" == *"Welcome"* ]]; then
    echo -e "${GREEN}✔ PASS: Access granted with correct token header${NC}"
else
    echo -e "${RED}✘ FAIL: Correct token rejected. Response: '$RESP_DASH_GOOD'${NC}"
fi
echo ""

# Exercise 7: Simple Redirector
echo -e "${BLUE}[Exercise 7: /legacy -> /v2]${NC}"
# Test redirect status
REDIRECT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/legacy")
if [ "$REDIRECT_STATUS" == "301" ]; then
    echo -e "${GREEN}✔ PASS: Route /legacy issues a 301 Permanent Redirect${NC}"
else
    echo -e "${RED}✘ FAIL: Expected redirect status 301, got $REDIRECT_STATUS${NC}"
fi

# Test following the location redirect
RESP_REDIRECT=$(curl -s -L "$SERVER_URL/legacy")
if [[ "$RESP_REDIRECT" == *"version 2"* ]]; then
    echo -e "${GREEN}✔ PASS: Followed redirect pipeline to /v2 successfully${NC}"
else
    echo -e "${RED}✘ FAIL: Target redirection payload path failed. Got: '$RESP_REDIRECT'${NC}"
fi

echo -e "\n${BLUE}=== Testing Complete ===${NC}"

#!/bin/bash
SERVER_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0;0m'

echo -e "${BLUE}=== HTTP Resurgence Verification ===${NC}\n"

# Exercise 1: /method-inspector
echo -e "${BLUE}[Exercise 1: /method-inspector]${NC}"
R1=$(curl -s -X GET "$SERVER_URL/method-inspector")
if [[ "$R1" == *"GET"* ]]; then echo -e "${GREEN}✔ PASS: GET detected${NC}"; else echo -e "${RED}✘ FAIL: got '$R1'${NC}"; fi
R1P=$(curl -s -X POST "$SERVER_URL/method-inspector")
if [[ "$R1P" == *"POST"* ]]; then echo -e "${GREEN}✔ PASS: POST detected${NC}"; else echo -e "${RED}✘ FAIL: got '$R1P'${NC}"; fi


# Exercise 2: /echo
echo -e "\n${BLUE}[Exercise 2: /echo]${NC}"
R2=$(curl -s -X POST -d "Hello Go" "$SERVER_URL/echo")
if [[ "$R2" == *"Hello Go"* ]]; then echo -e "${GREEN}✔ PASS: body echoed${NC}"; else echo -e "${RED}✘ FAIL: got '$R2'${NC}"; fi
R2G=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$SERVER_URL/echo")
if [ "$R2G" == "405" ]; then echo -e "${GREEN}✔ PASS: GET blocked with 405${NC}"; else echo -e "${RED}✘ FAIL: expected 405 got $R2G${NC}"; fi


# Exercise 3: /headers
echo -e "\n${BLUE}[Exercise 3: /headers]${NC}"
R3=$(curl -s -H "X-Custom-Token: abc123" "$SERVER_URL/headers")
if [[ "$R3" == *"abc123"* ]]; then echo -e "${GREEN}✔ PASS: header echoed${NC}"; else echo -e "${RED}✘ FAIL: got '$R3'${NC}"; fi
R3E=$(curl -s "$SERVER_URL/headers")
if [[ "$R3E" == *"missing"* || "$R3E" == *"Missing"* ]]; then echo -e "${GREEN}✔ PASS: missing header handled${NC}"; else echo -e "${RED}✘ FAIL: got '$R3E'${NC}"; fi


# Exercise 4: /form
echo -e "\n${BLUE}[Exercise 4: /form]${NC}"
R4=$(curl -s -X POST -d "username=Ada&language=Go" "$SERVER_URL/form")
if [[ "$R4" == *"Ada"* && "$R4" == *"Go"* ]]; then echo -e "${GREEN}✔ PASS: form parsed${NC}"; else echo -e "${RED}✘ FAIL: got '$R4'${NC}"; fi
R4E=$(curl -s -o /dev/null -w "%{http_code}" -X POST -d "username=&language=Go" "$SERVER_URL/form")
if [ "$R4E" == "400" ]; then echo -e "${GREEN}✔ PASS: empty field returns 400${NC}"; else echo -e "${RED}✘ FAIL: expected 400 got $R4E${NC}"; fi


# Exercise 5: /status
echo -e "\n${BLUE}[Exercise 5: /status]${NC}"
R5=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/status?code=404")
if [ "$R5" == "404" ]; then echo -e "${GREEN}✔ PASS: 404 returned${NC}"; else echo -e "${RED}✘ FAIL: expected 404 got $R5${NC}"; fi
R5B=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL/status?code=banana")
if [ "$R5B" == "400" ]; then echo -e "${GREEN}✔ PASS: bad code returns 400${NC}"; else echo -e "${RED}✘ FAIL: expected 400 got $R5B${NC}"; fi
