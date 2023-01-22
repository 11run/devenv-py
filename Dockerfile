# ベースとなるイメージを指定
ARG VERSION=3.11.1-bullseye
FROM python:${VERSION}

# ユーザ情報
ARG USER_NAME=user \
    GROUP_NAME=user \
    UID=1000 \
    GID=1000

# ユーザ作成処理
RUN groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -l -u ${UID} -m ${USER_NAME} -g ${GROUP_NAME} && \
    install -m ${UID} -o ${UID} -g ${GID} -m 644 /etc/skel/.bashrc /home/${USER_NAME}/.bashrc && \
    echo 'test -d ${HOME}/.local/bin && export PATH=${PATH}:${HOME}/.local/bin' >> /home/${USER_NAME}/.bashrc && \
    chsh ${USER_NAME} -s /bin/bash

# パッケージインストール
ARG PACKAGES=bash-completion=1:2.11-2
RUN apt-get update && \
    apt-get install --no-install-recommends --yes ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# poetryインストールスクリプトのURL
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
ARG POETRY=https://install.python-poetry.org
RUN curl -sSL ${POETRY} | python -

# poetryの入力補完スクリプトを生成して保存
USER root
RUN /home/${USER_NAME}/.local/bin/poetry completions bash > /etc/bash_completion.d/poetry.bash-completion

# 実行ユーザを指定
USER ${USER_NAME}