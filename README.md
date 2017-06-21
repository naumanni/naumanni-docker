Naumanni standalone docker image

# Requires

* docker >= 17.05

17.05で導入されたmulti-state buildの機能を使っているため、2016-06-20現在、Docker for MacではEdge系統が必要です。（他環境は未確認）


# Setup

gitからCloneして最新の状態に

```
$ git clone https://github.com/naumanni/naumanni-docker.git
$ cd naumanni-docker
$ git submodule update
```

Dockerイメージを作成

```
$ docker build -t naumanni/naumanni-standalone .
```

Dockerイメージを実行

```
$ docker run -it -p 8080:80 naumanni/naumanni-standalone
```

ブラウザで http://127.0.0.1:8080/ にアクセスするとnaumanniが見られるはずです。

# Customize

config.es6.docker, config.py.docker, plugins/
等の各ファイルをいじると自分好みにカスタマイズできます
