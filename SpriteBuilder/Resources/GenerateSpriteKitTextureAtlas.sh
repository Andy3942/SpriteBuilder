#!/bin/bash

INPUTDIR=$1
OUTPUTDIR=$2

echo Generating Sprite Kit Texture Atlas: $3
#echo Input: $INPUTDIR
#echo Output: $OUTPUTDIR

/Applications/Xcode.app/Contents/Developer/usr/bin/TextureAtlas "$INPUTDIR" "$OUTPUTDIR"
