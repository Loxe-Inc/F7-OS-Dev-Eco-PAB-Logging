/nix/store/*nix-2.8.0/bin/nix-shell --run "cabal run -- med-pab --config $PAB_CONFIG migrate"
/nix/store/*nix-2.8.0/bin/nix-shell --run "cabal run -- med-pab --config $PAB_CONFIG webserver --passphrase $PAB_PASSPHRASE"
