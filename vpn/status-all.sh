#!/bin/sh

root="$( cd "$(dirname "$0")"; pwd -P )"

echo "Host apple"
ssh admin@apple.local 'sudo wg'
echo

echo "Host banana"
ssh admin@banana.local 'sudo wg'
echo

echo "Host cherry"
ssh admin@cherry.local 'sudo wg'
echo

echo "Host dewberry"
ssh admin@dewberry.local 'sudo wg'
echo

echo "Host elderberry"
ssh admin@elderberry.local 'sudo wg'
echo

echo "Host fig"
ssh admin@fig.local 'sudo wg'
echo
