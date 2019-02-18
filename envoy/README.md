

# Build

```bash
docker build -t envoy_coypu_test:v1 .
```

# Run
```
docker network create coypu_net
docker run --net coypu_net --name coypu --dns 8.8.8.8 -p 8089:8089 -p 8080:8080 -i --rm -t coypu 
docker run --net coypu_net --name envoy -d -p 10000:10000 -p 10010:10010 envoy_coypu_test:v1
```
