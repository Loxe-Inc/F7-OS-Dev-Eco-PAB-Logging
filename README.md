---
title: PAB Container Log Processor
description: Develop a set of tools for parsing logs from the PAB so that they are queriable from the frontend to determine state following transactions.
Ideascale: https://cardano.ideascale.com/a/dtd/PAB-Container-Log-Processor/384450-48088
---

# PAB Container Log Processor



Welcome to the GitHub repository of F7 - Open Source Developer Ecosystem

This repository contains a docker-compose.yml file, a fluentd directory, and a few unnecesary but helpful other things to be explained in a moment.

Before working in this repository is that you should have a running node,chain-index,wallet-server,and PAB. If you do not have any of these, we can help with the first 3.
1. You can use our repo on docker hub for the node: 
  1. `loxeinc/node` this container is useful because it helps with running a system contained in a docker compose bundle. The user for this container is 1001:1002
2. You can use our repo on docker hub for the wallet-server:
  1. `loxeinc/wallet-server` this container is useful because it also works for running the system in a docker compose pacakge. The user for this container is 1001:1002

For the chain-index and PAB, you will need the plutus-apps repository. There is a submodule here linking to that repo. Forking that repository and building your PAB in place of the sample Game etc. PAB is an option, but we assume you know how to build your own PAB with endpoints. In our PAB we construct logging that needs to be parsed with the logInfo function. However, according to the `fluentd/conf/fluent.conf` you must change:
1. The tail source. You must point the path to the log to an existing and readable file, and the path to the position file to a writeable location.
2. Each line in your log that you want to process should match the regexp. To these matching lines the named groups from the regexp will be tagged pab.loginfo and so subsequent matches or filters will have that pattern and those group matches.


Each line in our logs looks like:
```
^[[34m[pab:Info:554]^[[0m [2022-06-28 02:05:26.85 UTC] 9154f517-8e35-4b05-a56a-232071bb4fba: "Logging tx object :: \"PartyCancelViaSys\" :: \"{\\\"partyAmounts\\\":[{\\\"paidParty\\\":{\\\"unPaymentPubKeyHash\\\":{\\\"getPubKeyHash\\\":\\\"ab595ab8e44eff26d6aba6fef0beb69d1314886d7434da0cabea2c52\\\"}},\\\"lovelace\\\":120000000000000},{\\\"paidParty\\\":{\\\"unPaymentPubKeyHash\\\":{\\\"getPubKeyHash\\\":\\\"deb574a09122abfb2172f5e3331813c942008392a4e28aaac04f57e3\\\"}},\\\"lovelace\\\":240000000000000}],\\\"txHash\\\":\\\"5822fcf201f3b5f8eb580a9e7433099826362a8b0face7b93d08bf4af0b681e6\\\",\\\"txCaseId\\\":\\\"41c09aaf-47aa-4b3a-9b10-3fca4ef5fd37\\\",\\\"txSubmitTime\\\":1656381926999}\""
```

Aeson make a pretty ugly nested quoting structure so we use ruby in the fluentd filter pipeline to clean it up and process it as JSON. You can do a lot of cleaning and modification to suit your needs. We wanted, here, the PKHs of the parties in the mediation receiving funding back as well as the txHash and the case that was being cancelled. We log everything that has a transaction, because the PAB can't communicate back to tell us what transaction happened. We run our PAB with the following command to output the stdout and stderr log to a single file:
```
nohup cabal run -- med-pab --config /ipc/testnet/pab/pab-config.yml webserver --passphrase abcdefghijklm > med-pab.out 2>&1 &
```
So in your container for the PAB you might have this be your CMD

In each of our containers we mount the ipc in this repo (or similar) to /ipc. It allows for a centralized communication hub for the node.socket and databases for the wallet, chain-index, and node. 


## To participate :
* Submit issues
* Fork this repository
* Submit Pull Requests

### Open source documents 
- [Licence](https://github.com/Catalyst-Challenges/F7-Open-Source-Developer-Ecosystem/blob/main/LICENSE)


