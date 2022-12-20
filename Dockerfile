FROM openkbs/jdk-mvn-py3-vnc

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

## ---- USER_NAME is defined in parent image: openkbs/jdk-mvn-py3-x11 already ----
###########################################################################
#### ---- DO NOT CHANGE Below unless release location changed    ---- #####
###########################################################################
ENV PROTEGE_VERSION=5.5.0
USER ${USER}
WORKDIR ${HOME}

# Use release:
# https://github.com/protegeproject/protege-distribution/releases/download/v5.5.0/Protege-5.5.0-linux.tar.gz
ARG PROTEGE_TGZ_URL=https://github.com/protegeproject/protege-distribution/releases/download/v${PROTEGE_VERSION}/Protege-${PROTEGE_VERSION}-linux.tar.gz

ENV PROTEGE_HOME=${HOME}/Protege-${PROTEGE_VERSION}
RUN wget --no-check-certificate -c ${PROTEGE_TGZ_URL}
RUN tar xvfz $(basename ${PROTEGE_TGZ_URL}) && \
    ln -s ${PROTEGE_HOME} $HOME/Protege && \
    cd ${PROTEGE_HOME} && \
    ls -al ${PROTEGE_HOME} && \
    rm -f $(basename ${PROTEGE_TGZ_URL})

ENV PROTEGE_PLUGIN=${PROTEGE_PLUGIN:-${PROTEGE_HOME}/plugins}
ENV PROTEGE_WORKSPACE=${HOME}/workspace-protege

##################################
#### VNC ####
##################################
WORKDIR ${HOME}
USER ${USER}

#ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
#CMD ["--wait"]

###########################################################################
#### ---- Protege Specifics: Setup                               ---- #####
###########################################################################
RUN wget --no-check-certificate -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

RUN curl -k https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/google-chrome-keyring.gpg'


RUN sudo apt-get update -y && \
    sudo apt install -y graphviz

RUN sudo mkdir -p ${HOME}/.Protege ${PROTEGE_WORKSPACE} ${PROTEGE_PLUGIN} 
    
## -- Protege --
VOLUME ${HOME}/.Protege

## -- Protege Workspace --
VOLUME ${PROTEGE_WORKSPACE}

## -- Protege Plugin (to persist across multiple delete and create) --
VOLUME ${PROTEGE_PLUGIN}

USER ${USER}
WORKDIR ${HOME}

CMD ["/bin/bash", "-c", "${PROTEGE_HOME}/run.sh"]

