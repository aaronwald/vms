FROM envoyproxy/envoy:latest
COPY envoy.yaml /etc/envoy/envoy.yaml
CMD /usr/local/bin/envoy -c /etc/envoy/envoy.yaml --service-cluster front-proxy --component-log-level grpc:trace,connection:debug,http2:trace,client:trace

