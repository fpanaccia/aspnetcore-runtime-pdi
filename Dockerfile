FROM microsoft/dotnet:2.2-aspnetcore-runtime
RUN apt-get update && \
    mkdir /usr/share/man/man1 && \
    apt-get -y install --no-install-recommends openjdk-8-jre-headless && \
	apt-get -y install --no-install-recommends unzip && \
	apt-get -y install --no-install-recommends wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists && \
	apt-get purge -y --auto-remove

# Set required environment vars
ENV PDI_RELEASE=8.2 \
    PDI_VERSION=8.2.0.0-342 \
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
    http://downloads.sourceforge.net/project/pentaho/Pentaho%20${PDI_RELEASE}/client-tools/pdi-ce-${PDI_VERSION}.zip \
    -O /tmp/pdi-ce-${PDI_VERSION}.zip && \
    /usr/bin/unzip -q /tmp/pdi-ce-${PDI_VERSION}.zip -d  $PENTAHO_HOME && \
    rm /tmp/pdi-ce-${PDI_VERSION}.zip	

# We can only add KETTLE_HOME to the PATH variable now
# as the path gets eveluated - so it must already exist
ENV KETTLE_HOME=$PENTAHO_HOME/data-integration \
    PATH=$KETTLE_HOME:$PATH

# Create kettle.properties file
RUN mkdir -p $KETTLE_HOME/.kettle
WORKDIR $KETTLE_HOME/.kettle
RUN	printf 'KETTLE_EMPTY_STRING_DIFFERS_FROM_NULL=Y' >> kettle.properties

USER root