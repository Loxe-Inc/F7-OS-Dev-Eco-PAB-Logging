---
title: PAB Container Log Processor
description: Develop a set of tools for parsing logs from the PAB so that they are queriable from the frontend to determine state following transactions.
Ideascale: https://cardano.ideascale.com/a/dtd/PAB-Container-Log-Processor/384450-48088
---

# PAB Container Log Processor

## Background
The PAB is a great utility for automating interactions with the blockchain based on HTTP requests. It provides a mechanism to run code on chain but also have that code available for off-chain calculation and determination if a transactions will succeed. It also allows for lookups on the blockchain to be done without transactions or without the use of a 3rd party service like blockfrost.


## This repository
This repository contains a docker-compose.yml file, a fluentd directory, and a few unnecesary but helpful other things to be explained in a moment.

### Set up dependencies
Before working in this repository is that you should have a running node,chain-index,wallet-server,and PAB. If you do not have any of these, we can help with the first 3.
1. You can use our repo on docker hub for the node: 
  1. `loxeinc/node` this container is useful because it helps with running a system contained in a docker compose bundle. The user for this container is 1001:1002
2. You can use our repo on docker hub for the wallet-server:
  1. `loxeinc/wallet-server` this container is useful because it also works for running the system in a docker compose pacakge. The user for this container is 1001:1002
3. You can use our repo on docker hub for plutus-apps:
  1. `loxeinc/plutus-apps` this container is useful because its user is set up with uid 1001 and gid 1002 like the other containers and makes for easy configuration with a docker compose script. Either mount your PAB into this container as a volume or rebuild with your PAB added.

### Using PAB and Chain index
For the chain-index and PAB, you will need the plutus-apps repository. There is a submodule here linking to that repo. Forking that repository and building your PAB in place of the sample Game etc. PAB is an option, but we assume you know how to build your own PAB with endpoints. In our PAB we construct logging that needs to be parsed with the logInfo function. However, according to the `fluentd/conf/fluent.conf` you must change:
1. The tail source. You must point the path to the log to an existing and readable file, and the path to the position file to a writeable location.
2. Each line in your log that you want to process should match the regexp. To these matching lines the named groups from the regexp will be tagged pab.loginfo and so subsequent matches or filters will have that pattern and those group matches.


Each line in our logs looks like:
```
^[[34m[pab:Info:554]^[[0m [2022-06-28 02:05:26.85 UTC] 9154f517-8e35-4b05-a56a-232071bb4fba: "Logging tx object :: \"PartyCancelViaSys\" :: \"{\\\"partyAmounts\\\":[{\\\"paidParty\\\":{\\\"unPaymentPubKeyHash\\\":{\\\"getPubKeyHash\\\":\\\"ab595ab8e44eff26d6aba6fef0beb69d1314886d7434da0cabea2c52\\\"}},\\\"lovelace\\\":120000000000000},{\\\"paidParty\\\":{\\\"unPaymentPubKeyHash\\\":{\\\"getPubKeyHash\\\":\\\"deb574a09122abfb2172f5e3331813c942008392a4e28aaac04f57e3\\\"}},\\\"lovelace\\\":240000000000000}],\\\"txHash\\\":\\\"5822fcf201f3b5f8eb580a9e7433099826362a8b0face7b93d08bf4af0b681e6\\\",\\\"txCaseId\\\":\\\"41c09aaf-47aa-4b3a-9b10-3fca4ef5fd37\\\",\\\"txSubmitTime\\\":1656381926999}\""
```

Aeson make a pretty ugly nested quoting structure so we use ruby in the fluentd filter pipeline to clean it up and process it as JSON. You can do a lot of cleaning and modification to suit your needs. We wanted, here, the PKHs of the parties in the mediation receiving funding back as well as the txHash and the case that was being cancelled. We log everything that has a transaction, because the PAB can't communicate back to tell us what transaction happened. We run our PAB with the following command to output the stdout and stderr log to a single file:
```
nohup cabal run -- med-pab --config /ipc/testnet/pab/pab-config.yml webserver --passphrase abcdefghijklm > /ipc/testnet/pab/pab.out 2>&1 &
```
So in your container for the PAB you might have this be your CMD

With the Filter/Match pipeline you can modify the Aeson encoded string and then output to your desired platform (elasticsearch, mongodb, etc). Here we use mongodb becauase you can spin up a free atlas cluster and use this conf file.

## A Not on running the services together

In each of our containers we mount the ipc in this repo (or similar) to /ipc. It allows for a centralized communication hub for the node.socket and databases for the wallet, chain-index, and node. Use it as you see fit. We found doing this was functional, except that PAB in a container runs out of memory very fast. You have to give it high limits. Create a non-dev-opsy system to automatically change the slot point on startup and remove the old DB. Even in a non-container space, this is also necessary because of problems with PAB. Using these container images you can also run the entire system in kubernetes, but you must have a very large node.

## A Note on chain-index on mainnet

If you plan to operate on mainnet, the chain-index is extremely large. 

## To participate :
* Submit issues
* Fork this repository
* Submit Pull Requests

### Open source documents 
- [Licence](https://github.com/Catalyst-Challenges/F7-Open-Source-Developer-Ecosystem/blob/main/LICENSE)


