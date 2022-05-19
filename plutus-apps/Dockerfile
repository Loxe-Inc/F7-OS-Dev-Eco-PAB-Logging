FROM ubuntu:focal
RUN apt-get update && apt-get install -y wget sudo xz-utils git && apt-get clean
ENV USER=cardano
ENV UID=1001
ENV GID=1002
RUN addgroup --gid $GID cardano
RUN adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --uid "$UID" \
    "$USER"
RUN mkdir /nix
RUN chown cardano:cardano /nix 
USER cardano
WORKDIR /home/cardano
RUN mkdir -p .config/nix
RUN wget https://releases.nixos.org/nix/nix-2.8.0/install && chmod u+x install && ./install --no-daemon
RUN echo "substituters  = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/\ntrusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=\nexperimental-features = nix-command flakes" >> .config/nix/nix.conf \
    && git clone https://github.com/input-output-hk/plutus-apps && cd plutus-apps && git checkout 7fb0e73765502b9876a78a5d80e993161823a54f
WORKDIR /home/cardano/plutus-apps
RUN /nix/store/*nix-2.8.0/bin/nix-instantiate shell.nix --indirect --add-root ./.nix-gc-roots/shell.drv
RUN /nix/store/*nix-2.8.0/bin/nix-shell --run "cabal update" 
RUN /nix/store/*nix-2.8.0/bin/nix-shell --run "cabal build plutus-pab-examples plutus-chain-index"
