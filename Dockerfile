ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

SHELL ["/bin/bash", "-c"]

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG ACME_VERSION
ARG ACME_SHA256_CHECKSUM
ARG PACKAGES_TO_INSTALL

RUN \
    set -E -e -o pipefail \
    # Install dependencies. \
    && homelab install ${PACKAGES_TO_INSTALL:?} \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    # Download and install the release. \
    && homelab install-tar-dist \
        https://github.com/acmesh-official/acme.sh/archive/refs/tags/${ACME_VERSION:?}.tar.gz \
        "${ACME_SHA256_CHECKSUM:?}" \
        acme.sh \
        acme.sh-${ACME_VERSION:?} \
        ${USER_NAME:?} \
        ${GROUP_NAME:?} \
    # Set up symlink for the binary at a location accessible through $PATH. \
    && ln -sf /opt/acme.sh/acme.sh /opt/bin/acme.sh \
    # Clean up. \
    && homelab cleanup

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}
CMD ["acme.sh"]
