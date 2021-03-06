# https://hjl.daoapp.io/
# 作者hjl~
# 如果要添加主题，请修改本文件，修改后请将添加主题命令以及上一行前面的#号删除
# 下面是机读部分
FROM node:4-slim
RUN groupadd user && useradd --create-home --home-dir /home/user -g user user
RUN apt-get update && apt-get install -y \
		ca-certificates \
		wget \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true
ENV GHOST_SOURCE /usr/src/ghost
WORKDIR $GHOST_SOURCE
ENV GHOST_VERSION 0.9.0
RUN buildDeps=' \
		gcc \
		make \
		python \
		unzip \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& wget -O ghost.zip "https://ghost.org/archives/ghost-${GHOST_VERSION}.zip" \
	&& unzip ghost.zip \
	&& rm config.example.js
COPY config.js $GHOST_SOURCE/config.example.js
WORKDIR $GHOST_SOURCE
RUN npm install --production \
	&& rm ghost.zip \
	&& npm cache clean \
	&& rm -rf /tmp/npm*
RUN apt-get update \
    && apt-get install -y zip
# WORKDIR /usr/src/ghost/content/themes
# RUN git clone 粘贴你要添加的主题的github clone地址
ENV GHOST_CONTENT /var/lib/ghost
RUN mkdir -p "$GHOST_CONTENT" && chown -R user:user "$GHOST_CONTENT"
VOLUME $GHOST_CONTENT
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 2368
CMD ["npm", "start"]
