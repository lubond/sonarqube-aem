FROM eclipse-temurin:17-jre-jammy

LABEL org.opencontainers.image.url=https://github.com/SonarSource/docker-sonarqube

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

#
# SonarQube community setup
#
#
# SonarQube setup with AEM Rules v1.6 jar
#
ARG AEM_RULE_JAR_VERSION=1.7
ARG SONARQUBE_VERSION=9.9.8.100196
ARG SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV JAVA_HOME='/opt/java/openjdk' \
    SONARQUBE_HOME=/opt/sonarqube \
    PATH="/opt/java/openjdk/bin:$PATH" \
    SONAR_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp" \
    AEM_RULES_JAR_URL=https://github.com/wttech/AEM-Rules-for-SonarQube/releases/download/v${AEM_RULE_JAR_VERSION}/sonar-aemrules-plugin-${AEM_RULE_JAR_VERSION}.jar

RUN set -eux; \
    groupadd --system --gid 1000 sonarqube; \
    useradd --system --uid 1000 --gid sonarqube sonarqube; \
    apt-get update; \
    apt-get --no-install-recommends -y install \
    bash \
    curl \
    fonts-dejavu \
    gnupg \
    unzip \
    gosu; \
    echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"; \
    sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"; \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    for server in $(shuf -e hkps://keys.openpgp.org \
    hkps://keyserver.ubuntu.com) ; do \
    gpg --batch --keyserver "${server}" --recv-keys 679F1EE92B19609DE816FDE81DB198F93525EC1A && break || : ; \
    done; \
    mkdir --parents /opt; \
    cd /opt; \
    curl --fail --location --output sonarqube.zip --silent --show-error "${SONARQUBE_ZIP_URL}"; \
    curl --fail --location --output sonarqube.zip.asc --silent --show-error "${SONARQUBE_ZIP_URL}.asc"; \
    gpg --batch --verify sonarqube.zip.asc sonarqube.zip; \
    unzip -q sonarqube.zip; \
    mv "sonarqube-${SONARQUBE_VERSION}" sonarqube; \
    curl --fail --location --output aemrules.jar --show-error "${AEM_RULES_JAR_URL}"; \
    mv aemrules.jar sonarqube/extensions/plugins; \
    rm sonarqube.zip*; \
    rm -rf ${SONARQUBE_HOME}/bin/*; \
    ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar"; \
    chmod -R 555 ${SONARQUBE_HOME}; \
    chmod -R ugo+wrX "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}"; \
    apt-get remove -y gnupg unzip curl; \
    rm -rf /var/lib/apt/lists/*;

COPY --chown=sonarqube:sonarqube run.sh sonar.sh quality.sh ${SONARQUBE_HOME}/bin/

WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000

ENTRYPOINT ["sh","-c","bin/quality.sh & bin/run.sh"]
CMD ["bin/sonar.sh"]
