FROM golang
RUN go get github.com/zhenghaoz/gorse/...

COPY gorse.toml gorse.toml

CMD gorse serve -c gorse.toml
