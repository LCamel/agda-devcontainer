FROM ghcr.io/lcamel/haskell-devcontainer:ghc-9.10.2

USER root

RUN --mount=type=bind,source=install-os-packages.sh,target=/tmp/install-os-packages.sh \
    bash -x /tmp/install-os-packages.sh

USER vscode

RUN --mount=type=bind,source=install-agda.sh,target=/tmp/install-agda.sh \
    --mount=type=bind,source=agda-versions.env,target=/tmp/agda-versions.env \
    bash -i -x /tmp/install-agda.sh

ENV LANG=C.UTF-8
ENV XDG_RUNTIME_DIR=/run/user/1000

CMD ["bash"]
