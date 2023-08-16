# [Choice] Python version (use -bookworm or -bullseye variants on local arm64/Apple Silicon):
#3, 3.11, 3.10, 3.9, 3.8, 3-bookworm, 3.11-bookworm, 3.10-bookworm, 3.9-bookworm, 3.8-bookworm, 3-bullseye, 3.11-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye, 3-buster, 3.11-buster, 3.10-buster, 3.9-buster, 3.8-buster
ARG VARIANT=3.11-bookworm
FROM python:${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    && apt-get -y install --no-install-recommends  iputils-ping
# Temporary: Upgrade python packages due to https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-40897
# They are installed by the base image (python) which does not have the patch.
RUN python3 -m pip install --upgrade setuptools
# [Optional] If your pip requirements rarely change, uncomment this section to add them to the image.
COPY requirement* /tmp/pip-tmp/
#run only if requirements.txt is present
RUN if [ -f /tmp/pip-tmp/requirements.txt ];\
    then  pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt; fi

RUN if [ -f /tmp/pip-tmp/requirements.yml ];\
    then ansible-galaxy install -r  /tmp/pip-tmp/requirements.yml; fi\
    && rm -rf /tmp/pip-tmp
# RUN if [ -f /tmp/pip-tmp/requirements.txt ]; then pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
#     && if [ -f /tmp/pip-tmp/requirements.yml ]; then ansible-galaxy install -r requirements.yml fi\
#     && rm -rf /tmp/pip-tmp

# [Optional] Uncomment this section to install additional OS packages. RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1