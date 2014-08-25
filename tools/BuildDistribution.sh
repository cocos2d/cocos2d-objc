#!/bin/bash

COCOS2D_VERSION=$1

if [ "$#" -ne 1 ]; then
    echo "usage: ./BuildDistribution.sh <version eg:3.2.0>"
    echo "eg  ./BuildDistribution.sh 3.2.0"
    exit 1
fi

# Change to the script's working directory no matter from where the script was called (except if there are symlinks used)
# Solution from: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo Script working directory: $SCRIPT_DIR
cd "$SCRIPT_DIR"

cd ..

# Clear docs directory
rm -Rf api-docs/

# Build documentation
echo "BUILDING DOCS"
xcodebuild -project cocos2d-ios.xcodeproj -target appledoc

# Create documentation docset
echo "RENAME DOCSET"
mv api-docs/docset/ api-docs/org.cocos2d.Cocos2D.docset

# Zip up distribution
echo "CREATE GIT ARCHIVE"
tools/git-archive-all ../cocos2d-swift-$1.zip

# Zip up documentation
echo "ZIP DOCS"
cd api-docs
zip ../../cocos2d-swift-$1.docset.zip org.cocos2d.Cocos2D.docset
