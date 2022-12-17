#!/bin/bash
cp xmonadctl.hs /tmp
cd /tmp
ghc --make xmonadctl.hs
sudo cp xmonadctl /usr/local/bin
rm -f xmonadctl*

