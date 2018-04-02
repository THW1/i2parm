FROM arm32v6/openjdk:8-alpine

ENV I2P_VERSION 0.9.33
ENV I2P_DIR /usr/local/bin
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

EXPOSE 2827 7650 7654 7655 7656 7657 7658 7659 7660 7661 7662 4444 6668 8998

RUN apk update && \
    apk add ca-certificates && \
    update-ca-certificates && \
    apk add openssl && \
    apk add --update binutils

#RUN wget https://download.tanukisoftware.com/wrapper/3.5.34/wrapper-linux-armel-32-3.5.34.tar.gz
#RUN tar -xzf wrapper-linux-armel-32-3.5.34.tar.gz && \
#     cp wrapper-linux-armel-32-3.5.34/bin/wrapper  ${I2P_DIR}/i2psvc && \
#     cp wrapper-linux-armel-32-3.5.34/lib/wrapper.jar ${I2P_DIR}/lib/ && \
#     cp wrapper-linux-armel-32-3.5.34/lib/libwrapper.so  ${I2P_DIR}/lib/

RUN wget https://download.i2p2.de/releases/0.9.33/i2pinstall_0.9.33.jar

RUN addgroup -g 1000 -S i2p && adduser -u 1000 -S username -G i2p

RUN java -jar i2pinstall_0.9.33.jar -console

RUN sed -i 's/127\.0\.0\.1/0.0.0.0/g' ${I2P_DIR}/i2ptunnel.config && \
    sed -i 's/::1,127\.0\.0\.1/0.0.0.0/g' ${I2P_DIR}/clients.config && \
    printf "i2cp.tcp.bindAllInterfaces=true\n" >> ${I2P_DIR}/router.config && \
    printf "i2np.ipv4.firewalled=true\ni2np.ntcp.ipv6=false\n" >> ${I2P_DIR}/router.config && \
    printf "i2np.udp.ipv6=false\ni2np.upnp.enable=false\n" >> ${I2P_DIR}/router.config && \
    sed -i s/#MAXMEMOPT=\"-Xmx256m\"/MAXMEMOPT=\"-Xmx464m\"/ ${I2P_DIR}/runplain.sh

VOLUME /var/lib/i2p

USER i2p

ENTRYPOINT ["/usr/local/bin/runplain.sh"]
