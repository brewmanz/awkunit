#!/bin/bash
echo "Build ..."
cd ~/git/awkunit
AWKSRCPATH=~/gawk-src/gawk-5.0.1 make
sudo make install

echo "Run test_sum ..."
cd examples
./test_sum.awk < sum.asserts
cd ..
