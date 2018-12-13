FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app
RUN echo America/Argentina/Buenos_Aires >/etc/timezone && \
ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata
EXPOSE 80

RUN apt-get update && \
    mkdir /usr/share/man/man1 && \
    apt-get -y install --no-install-recommends openjdk-8-jre-headless && \
	apt-get -y install --no-install-recommends unzip && \
	apt-get -y install --no-install-recommends wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists && \
	apt-get purge -y --auto-remove

# Set required environment vars
ENV PDI_RELEASE=6.0 \
    PDI_VERSION=6.0.1.0-386 \
    CARTE_PORT=8181 \
    PENTAHO_JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    PENTAHO_HOME=/home/pentaho

# Create user
RUN mkdir ${PENTAHO_HOME} && \
    groupadd -r pentaho && \
    useradd -s /bin/bash -d ${PENTAHO_HOME} -r -g pentaho pentaho && \
    chown pentaho:pentaho ${PENTAHO_HOME}
	
# Switch to the pentaho user
USER pentaho

# Download PDI
RUN /usr/bin/wget \
    --progress=dot:giga \
    http://downloads.sourceforge.net/project/pentaho/Data%20Integration/${PDI_RELEASE}/pdi-ce-${PDI_VERSION}.zip \
    -O /tmp/pdi-ce-${PDI_VERSION}.zip && \
    /usr/bin/unzip -q /tmp/pdi-ce-${PDI_VERSION}.zip -d  $PENTAHO_HOME && \
    rm /tmp/pdi-ce-${PDI_VERSION}.zip	

# We can only add KETTLE_HOME to the PATH variable now
# as the path gets eveluated - so it must already exist
ENV KETTLE_HOME=$PENTAHO_HOME/data-integration \
    PATH=$KETTLE_HOME:$PATH