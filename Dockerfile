FROM arm32v6/openjdk:8-alpine

ENV I2P_VERSION="0.9.33"
ENV I2P_DIR="/usr/local/bin"
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"

EXPOSE 2827 7650 7654 7655 7656 7657 7658 7659 7660 7661 7662 4444 6668 8998

RUN apk update && \
    apk add ca-certificates && \
    update-ca-certificates && \
    apk add openssl && \
    apk add --update binutils

#RUN addgroup -g 1000 -S i2p && adduser -u 1000 -S i2p -G i2p

RUN wget https://download.i2p2.de/releases/${I2P_VERSION}/i2pinstall_${I2P_VERSION}.jar

# RUN mkfifo /tmp/INSTALLOPTIONS && echo "INSTALL_PATH=${I2P_DIR}" > /tmp/INSTALLOPTIONS && java -jar i2pinstall_${I2P_VERSION}.jar  -options /tmp/INSTALLOPTIONS
RUN echo "INSTALL_PATH=${I2P_DIR}" > /tmp/INSTALLOPTIONS && java -jar i2pinstall_${I2P_VERSION}.jar  -options /tmp/INSTALLOPTIONS && rm /tmp/INSTALLOPTIONS

RUN sed -i 's/127\.0\.0\.1/0.0.0.0/g' ${I2P_DIR}/i2ptunnel.config && \
    sed -i 's/::1,127\.0\.0\.1/0.0.0.0/g' ${I2P_DIR}/clients.config && \
    printf "i2cp.tcp.bindAllInterfaces=true\n" >> ${I2P_DIR}/router.config && \
    printf "i2np.ipv4.firewalled=true\ni2np.ntcp.ipv6=false\n" >> ${I2P_DIR}/router.config && \
    printf "i2np.udp.ipv6=false\ni2np.upnp.enable=false\n" >> ${I2P_DIR}/router.config

VOLUME /var/lib/i2p

#USER i2p

ENV I2PTEMP="/tmp"
ENV MAXMEMOPT="-Xmx464m"
ENV PREFERv4=false
ENV JAVA="/usr/lib/jvm/java-1.8-openjdk/jre/bin/java"
ENV JAVAOPTS="${MAXMEMOPT} -Djava.net.preferIPv4Stack=${PREFERv4} -Djava.library.path=${I2P_DIR}:${I2P_DIR}/lib -Di2p.dir.base=${I2P_DIR} -DloggerFilenameOverride=logs/log-router-@.txt"

# create a list of all jar files in libs/ and send them into a temporary file to survice between layers
RUN CP="" && \
for jar in $(ls ${I2P_DIR}/lib/*.jar); do \
if [ ! -z $CP ]; then \
CP=${CP}:${jar}; \
else CP=${jar}; \
fi; \
done && \
echo "${CP}" > /tmp/JARLIST
			    
ENTRYPOINT ${JAVA} -cp "$(/bin/cat /tmp/JARLIST)" ${JAVAOPTS} net.i2p.router.RouterLaunch
