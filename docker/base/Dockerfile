FROM ubuntu:xenial

# install packages
RUN set -eux; \
	apt-get update; apt-get upgrade -y ; \
	apt-get install -y gosu sudo locales make less build-essential openjdk-8-jdk curl libapr1 unzip uuid-runtime jq bsdmainutils wget python docker.io psmisc software-properties-common apt-transport-https; \
	rm -rf /var/lib/apt/lists/*;

# Install latest git
RUN set -eux; \
  add-apt-repository -y ppa:git-core/ppa; \
  apt-get update; \
  apt-get install -y git

# Install Adopt JDK11
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - ; \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ ; \
    apt-get update ; apt-get install -y adoptopenjdk-11-hotspot

# Install Temurin JDK17
RUN wget -q https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz
RUN tar -C /usr/lib/jvm -xzf OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz

# Add java to PATH for all users, and user
# use java8 by default, but provide java11 as well
RUN echo "PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin:$PATH" >> /etc/environment
RUN echo "JAVA_HOME_8_X64=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
RUN echo "JAVA_HOME_11_X64=/usr/lib/jvm/adoptopenjdk-11-hotspot-amd64" >> /etc/environment
RUN echo "JAVA_HOME_17_X64=/usr/lib/jvm/jdk-17.0.1+12" >> /etc/environment
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
RUN update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac
RUN update-alternatives --set jps /usr/lib/jvm/java-8-openjdk-amd64/bin/jps
RUN update-alternatives --set jstack /usr/lib/jvm/java-8-openjdk-amd64/bin/jstack
RUN update-alternatives --set javadoc /usr/lib/jvm/java-8-openjdk-amd64/bin/javadoc

ENV JAVA_HOME_8_X64 "/usr/lib/jvm/java-8-openjdk-amd64"
ENV JAVA_HOME_11_X64 "/usr/lib/jvm/adoptopenjdk-11-hotspot-amd64"
ENV JAVA_HOME_17_X64 "/usr/lib/jvm/jdk-17.0.1+12"
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64"

# Install go
RUN mkdir -p /usr/share/go \
 && curl -fsSL -o /tmp/go.tar.gz https://go.dev/dl/go1.18.1.linux-amd64.tar.gz \
 && tar -xzf /tmp/go.tar.gz -C /usr/share/go --strip-components=1 \
 && rm -f /tmp/go.tar.gz \
 && ln -s /usr/share/go/bin/go /usr/bin/go

# Install hugo
RUN mkdir -p /usr/share/hugo \ 
 && curl -fsSL -o /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.98.0/hugo_extended_0.98.0_Linux-64bit.tar.gz \
 && tar -xzf /tmp/hugo.tar.gz -C /usr/share/hugo \
 && rm -f /tmp/hugo.tar.gz \
 && ln -s /usr/share/hugo/hugo /usr/bin/hugo

# Install maven
ARG MAVEN_VERSION=3.8.6
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

# Use UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen ; locale-gen ; update-locale en_US.UTF-8
ENV LC_ALL "en_US.UTF-8"
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
