ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_LABEL
FROM $BASE_IMAGE_NAME:$BASE_IMAGE_LABEL

SHELL ["/bin/bash", "-c"]

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG ACME_INSTALL_DIR
ARG ACME_VERSION
ARG ACME_SHA256_CHECKSUM
ARG ACME_TAR_FILE=acme.tar.gz

# hadolint ignore=DL3003,DL4006
RUN \
    set -e -o pipefail \
    # Create the user and the group. \
    && groupadd --gid ${GROUP_ID:?} ${GROUP_NAME:?} \
    && useradd \
        --create-home \
        --shell /bin/bash \
        --uid ${USER_ID:?} \
        --gid ${GROUP_ID:?} \
        ${USER_NAME:?} \
    # Prepare the install directory. \
    && rm -rf ${ACME_INSTALL_DIR:?} \
    && mkdir ${ACME_INSTALL_DIR:?} \
    && cd ${ACME_INSTALL_DIR:?} \
    # Download and unpack the release. \
    && curl --silent --location --output ${ACME_TAR_FILE:?} \
        https://github.com/acmesh-official/acme.sh/archive/refs/tags/${ACME_VERSION:?}.tar.gz \
    && (echo "${ACME_SHA256_CHECKSUM:?} ${ACME_TAR_FILE:?}" | sha256sum -c) \
    && tar xf ${ACME_TAR_FILE:?} \
    && rm ${ACME_TAR_FILE:?} \
    # Set up symlinks. \
    && ln -s acme.sh-${ACME_VERSION:?} acme.sh \
    && ln -s ${ACME_INSTALL_DIR:?}/acme.sh/acme.sh /usr/bin/acme.sh \
    # Make the installed directory owned by the user and the group we created. \
    && chown -R ${USER_NAME:?}:${GROUP_NAME:?} ${ACME_INSTALL_DIR:?}

USER $USER_NAME:$GROUP_NAME
WORKDIR /home/$USER_NAME
CMD ["/bin/bash"]
