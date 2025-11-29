#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Service URLs
PRODUCTPAGE_URL="http://productpage:9080"
DETAILS_URL="http://details:9080"
REVIEWS_URL="http://reviews:9080"
RATINGS_URL="http://ratings:9080"

# Request counter
REQUEST_COUNT=0

# Function to make a request and log it
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4
    
    REQUEST_COUNT=$((REQUEST_COUNT + 1))
    echo -e "${BLUE}[Request #${REQUEST_COUNT}]${NC} ${description}"
    
    if [ "$method" == "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
    elif [ "$method" == "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$url" -H "Content-Type: application/json" -d "$data")
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
    fi
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ Success${NC} - HTTP $http_code"
    elif [ "$http_code" -ge 400 ] && [ "$http_code" -lt 500 ]; then
        echo -e "${YELLOW}⚠ Client Error${NC} - HTTP $http_code"
    else
        echo -e "${RED}✗ Error${NC} - HTTP $http_code"
    fi
    
    # Show a snippet of the response if it exists
    if [ -n "$body" ] && [ "$body" != "0" ]; then
        echo "$body" | head -c 150
        if [ ${#body} -gt 150 ]; then
            echo "..."
        else
            echo ""
        fi
    fi
    
    echo ""
    sleep 0.5
}

echo "============================================"
echo "   Bookinfo Traffic Generator"
echo "============================================"
echo ""
echo "Starting traffic generation at $(date)"
echo ""

# Wait a moment for services to be ready
echo "Waiting for services to be ready..."
sleep 2
echo ""

# ===== ProductPage Service Requests =====
echo -e "${YELLOW}>>> Testing ProductPage Service${NC}"
echo ""

# Request 1: Get the main product page
make_request "GET" "${PRODUCTPAGE_URL}/productpage?u=normal" "" "GET /productpage (main page with reviews)"

# Request 2: Get product page with different user
make_request "GET" "${PRODUCTPAGE_URL}/productpage?u=test" "" "GET /productpage (different user session)"

# Request 3: Get product page without user parameter
make_request "GET" "${PRODUCTPAGE_URL}/productpage" "" "GET /productpage (no user parameter)"

# Request 4: Check health endpoint
make_request "GET" "${PRODUCTPAGE_URL}/health" "" "GET /health (productpage health check)"

# Request 5: Get static resources (simulating browser behavior)
make_request "GET" "${PRODUCTPAGE_URL}/static/bootstrap/css/bootstrap.min.css" "" "GET /static/bootstrap/css (CSS resource)"

# ===== Details Service Requests =====
echo -e "${YELLOW}>>> Testing Details Service${NC}"
echo ""

# Request 6: Get details for product 0
make_request "GET" "${DETAILS_URL}/details/0" "" "GET /details/0 (book details)"

# Request 7: Get details for product 1 (should return error)
make_request "GET" "${DETAILS_URL}/details/1" "" "GET /details/1 (non-existent product)"

# Request 8: Health check
make_request "GET" "${DETAILS_URL}/health" "" "GET /health (details service)"

# ===== Reviews Service Requests =====
echo -e "${YELLOW}>>> Testing Reviews Service${NC}"
echo ""

# Request 9: Get reviews for product 0
make_request "GET" "${REVIEWS_URL}/reviews/0" "" "GET /reviews/0 (product reviews)"

# Request 10: Get reviews for product 1 (should return error or no reviews)
make_request "GET" "${REVIEWS_URL}/reviews/1" "" "GET /reviews/1 (non-existent product)"

# Request 11: Health check
make_request "GET" "${REVIEWS_URL}/health" "" "GET /health (reviews service)"

# ===== Ratings Service Requests =====
echo -e "${YELLOW}>>> Testing Ratings Service${NC}"
echo ""

# Request 12: Get ratings for product 0
make_request "GET" "${RATINGS_URL}/ratings/0" "" "GET /ratings/0 (product ratings)"

# Request 13: Get ratings for product 1
make_request "GET" "${RATINGS_URL}/ratings/1" "" "GET /ratings/1 (non-existent product)"

# Request 14: Health check
make_request "GET" "${RATINGS_URL}/health" "" "GET /health (ratings service)"

# ===== Simulating Realistic User Behavior =====
echo -e "${YELLOW}>>> Simulating Realistic User Behavior (Multiple Page Views)${NC}"
echo ""

# Simulate a user browsing the site multiple times
for i in {1..5}; do
    user_types=("normal" "test" "reviewer" "user$i")
    user=${user_types[$((RANDOM % ${#user_types[@]}))]}
    make_request "GET" "${PRODUCTPAGE_URL}/productpage?u=${user}" "" "GET /productpage (simulated user: $user, visit #$i)"
done

# ===== POST Requests (if the API supports them) =====
echo -e "${YELLOW}>>> Testing POST Requests${NC}"
echo ""

# Note: The Bookinfo application is primarily read-only, but we'll attempt POST requests
# to demonstrate the capability. These may return 404 or 405 Method Not Allowed.

# Request 15: Attempt to post a rating (likely not supported, but demonstrates POST capability)
make_request "POST" "${RATINGS_URL}/ratings/" '{"reviewer":"test-user","rating":5}' "POST /ratings/0 (attempt to submit rating)"

# Request 16: Attempt to post a review (likely not supported)
make_request "POST" "${REVIEWS_URL}/reviews/" '{"reviewer":"test-user","text":"Great book!"}' "POST /reviews/0 (attempt to submit review)"

# ===== Summary =====
echo ""
echo "============================================"
echo "   Traffic Generation Complete"
echo "============================================"
echo ""
echo "Total requests sent: ${REQUEST_COUNT}"
echo "Completed at: $(date)"
echo ""
echo "To run this again, execute:"
echo "  ./run-traffic-gen.sh"
echo "Or manually with:"
echo "  nerdctl run --rm --network docker-compose-boutique_bookinfo traffic-generator"
echo "  docker run --rm --network docker-compose-boutique_bookinfo traffic-generator"
echo ""

