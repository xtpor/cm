#!/bin/sh

root="$( cd "$(dirname "$0")"; pwd -P )"

./install.sh admin@apple.local apple
./install.sh admin@banana.local banana
./install.sh admin@cherry.local cherry
./install.sh admin@dewberry.local dewberry
./install.sh admin@elderberry.local elderberry
./install.sh admin@fig.local fig
