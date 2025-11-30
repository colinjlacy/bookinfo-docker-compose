# Bookinfo Docker Compose

This is a Docker Compose implementation of the [Istio Bookinfo](https://github.com/istio/istio/tree/master/samples/bookinfo) sample application, designed to run without requiring Kubernetes or Istio.

## Pero, like...why?

In [another repo](https://github.com/colinjlacy/golang-http-profiler) I have an eBPF/Golang project that profiles `syscall` interactions and logs HTTP requests, a PoC implementation of what's described in [this issue](https://github.com/cncf/toc/issues/1797).

During the first [meeting of the minds](https://docs.google.com/document/d/1oz_1K1l-VuLuy-JPOh7oWrDqPzoImpYH5racSMJ5Br0/edit) at KubeCon Atlanta, we talked about proving out this concept on something like Istio's Bookinfo or the [GCP Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) in order to demonstrate (and understand the challenges of) scalability.

In keeping with the the crawl/walk/run mantra, I'm first proving this out on a lima VM running on my Mac, listening to traffic between running containers. Future iterations will likely result some DaemonSets and will be able to profile on Kubernetes.

## Architecture

The application consists of four microservices:

- **productpage** (port 9080): The main frontend service that displays book information
- **details** (port 9081): Provides additional book details
- **reviews** (port 9082): Provides book reviews (v1 - no ratings stars)
- **ratings** (port 9083): Provides book ratings

All services are accessible from your host machine on their respective ports.

## Prerequisites

- Docker compose 
  - or a compatible alternative, e.g. [podman compose](https://docs.podman.io/en/latest/markdown/podman-compose.1.html), [nerdctl compose](https://github.com/containerd/nerdctl/blob/main/docs/command-reference.md#compose)
- A Linux environment, if using [the HTTP profiler](https://github.com/colinjlacy/golang-http-profiler).
  - instructions on how to profile are in that repo.

## Getting Started

### 1. Start the Services

```bash
docker compose up -d
# podman compose up -d
# nerdctl compose up -d
```

This will start all four microservices. Wait about 10-15 seconds for all services to start.

### 2. Verify Services are Running

```bash
docker compose ps
# podman compose ps
# nerdctl compose ps
```

All services should show as "running".

### 3. Access the Application

Open your browser and navigate to:

```
http://localhost:9080/productpage
```

You can also access individual services:

- Details service: `http://localhost:9081/details/0`
- Reviews service: `http://localhost:9082/reviews/0`
- Ratings service: `http://localhost:9083/ratings/0`

### 4. Generate Traffic

The traffic generator is a containerized Node.js application using Axios that simulates realistic user traffic.

To run the traffic generator script:

**Easiest Method:**
```bash
./scripts/run-traffic-gen.sh
```

**Manually:**
```bash
docker build -t traffic-generator ./traffic-generator/
# or: nerdctl build -t traffic-generator ./traffic-generator/
# or: podman build -t traffic-generator ./traffic-generator/

# Run the traffic generator
docker run --rm --network docker-compose-boutique_bookinfo traffic-generator
# or: nerdctl run --rm --network docker-compose-boutique_bookinfo traffic-generator
# or: podman run --rm --network docker-compose-boutique_bookinfo traffic-generator
```

The traffic generator will execute a one-time script that:
- Makes GET requests to all service endpoints
- Simulates realistic user behavior with multiple page views
- Makes POST requests to endpoints that support them
- Displays colored output showing request status and responses
- Makes approximately 19 requests total
- All requests return successful HTTP 200 status codes

## Stopping the Services

```bash
docker compose down
# podman compose down
# nerdctl compose down
```

To stop and remove all data:
```bash
docker compose down -v
# podman compose down -v
# nerdctl compose down -v
```

## Service Details

### ProductPage Service
- **Image**: docker.io/istio/examples-bookinfo-productpage-v1:1.20.1
- **Port**: 9080
- **Endpoints**:
  - `/productpage` - Main page
  - `/health` - Health check

### Details Service
- **Image**: docker.io/istio/examples-bookinfo-details-v1:1.20.1
- **Port**: 9081 (mapped from internal 9080)
- **Endpoints**:
  - `/details/{product_id}` - Get book details
  - `/health` - Health check

### Reviews Service
- **Image**: docker.io/istio/examples-bookinfo-reviews-v1:1.20.1
- **Port**: 9082 (mapped from internal 9080)
- **Version**: v1 (no star ratings displayed)
- **Endpoints**:
  - `/reviews/{product_id}` - Get book reviews
  - `/health` - Health check

### Ratings Service
- **Image**: docker.io/istio/examples-bookinfo-ratings-v1:1.20.1
- **Port**: 9083 (mapped from internal 9080)
- **Endpoints**:
  - `/ratings/{product_id}` - Get book ratings
  - `/health` - Health check

### Port conflicts

If you have port conflicts, you can modify the port mappings in `docker-compose.yaml`:

```yaml
ports:
  - "YOUR_PORT:9080"
```

## References

- [Istio Bookinfo Sample](https://github.com/istio/istio/tree/master/samples/bookinfo)
- [Bookinfo API Specification](https://github.com/istio/istio/blob/master/samples/bookinfo/swagger.yaml)

