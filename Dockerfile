FROM alpine:latest

RUN sed -i 's|https://dl-cdn.alpinelinux.org|http://mirrors.tuna.tsinghua.edu.cn|g' /etc/apk/repositories

RUN apk add --no-cache --virtual .build-app curl tzdata git

RUN apk add --no-cache openjdk17-jdk libstdc++

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN echo 'Asia/Shanghai' > /etc/timezone

WORKDIR /app

RUN curl 'https://gh.con.sh/https://github.com/iTXTech/mirai-console-loader/releases/download/v2.1.2/mcl-2.1.2.zip' | jar -x

RUN chmod +x /app/mcl

RUN git clone https://github.com/MrXiaoM/qsign.git

RUN cd ./qsign; \
    git checkout mirai; \
    sed -i 's|https\\:\/\/services\.gradle\.org\/distributions\/|http\\://mirrors.cloud.tencent.com/gradle/|' ./gradle/wrapper/gradle-wrapper.properties; \
    ./gradlew deploy

RUN find ./qsign -name 'qsign-*.zip' -type f -exec jar -xvf {} \; ; rm -rf ./qsign

RUN sed -i 's|^\(\$JAVA_BINARY\)|\1 -Dmirai.console.skip-end-user-readme|' ./mcl

RUN ./mcl --update-package net.mamoe:mirai-console --channel maven-prerelease

RUN ./mcl --update-package net.mamoe:mirai-core-all --channel maven-prerelease

RUN ./mcl --update-package net.mamoe:mirai-console-terminal --channel maven-prerelease

RUN ./mcl --update-package net.mamoe:mirai-api-http --channel stable-v2 --type plugin

RUN ./mcl --update-package xyz.cssxsh.mirai:mirai-device-generator --channel stable --type plugin

RUN ./mcl --boot-only

RUN ./mcl --dry-run

RUN ./mcl -u <<EOF
exit
EOF

RUN apk del .build-app

ENTRYPOINT [ "/app/mcl" ]
