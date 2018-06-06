# Inherit the mist.api image.
ARG FROM_IMAGE=mist/mist:staging
FROM $FROM_IMAGE

# Install plugins.
COPY ./rbac/ /opt/rbac/
COPY ./manage/ /opt/manage/
COPY ./insights/ /opt/insights/
COPY ./orchestration/ /opt/orchestration/
COPY ./auth/ /opt/auth/
RUN for plugin in rbac manage insights orchestration auth; do pip install -e /opt/$plugin; done

# Configure product defaults.
ENV DEFAULTS_FILE=/etc/mist/defaults.py \
    SETTINGS_FILE=/etc/mist/settings/settings.py
COPY ./defaults.py $DEFAULTS_FILE
RUN mkdir -p $(dirname $SETTINGS_FILE)

# Pass version info.
ARG MIST_VERSION_SHA
ARG MIST_VERSION_NAME
# Variables defined solely by ARG are accessible as environmental variables
# during build but not during runtime. To persist these in the image, they're
# redefined as ENV in addition to ARG.
ENV VERSION_REPO=mistio/mist-ee \
    VERSION_SHA=$MIST_VERSION_SHA \
    VERSION_NAME=$MIST_VERSION_NAME
RUN echo "{\"sha\":\"$VERSION_SHA\",\"name\":\"$VERSION_NAME\",\"repo\":\"$VERSION_REPO\",\"modified\":false}" \
        > /mist-version.json

# Generate swagger spec (API documentation).
RUN python /mist.api/openapi/generate_api_spec.py