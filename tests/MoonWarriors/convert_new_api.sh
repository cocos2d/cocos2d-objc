#!/bin/sh

# sharedDirector
for i in `find . -name \*.js`
do
sed -e 's/sharedDirector()/getInstance()/g' $i >$i.new
mv $i.new $i
done


# shared texture cache
for i in `find . -name \*.js`
do
sed -e 's/sharedTextureCache()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedSpriteFrameCache 
for i in `find . -name \*.js`
do
sed -e 's/sharedSpriteFrameCache()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedAnimationCache 
for i in `find . -name \*.js`
do
sed -e 's/sharedAnimationCache()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedEngine 
for i in `find . -name \*.js`
do
sed -e 's/sharedEngine()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedFileUtils 
for i in `find . -name \*.js`
do
sed -e 's/sharedFileUtils()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedShaderCache 
for i in `find . -name \*.js`
do
sed -e 's/sharedShaderCache()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedConfiguration 
for i in `find . -name \*.js`
do
sed -e 's/sharedConfiguration()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# sharedDispatcher 
for i in `find . -name \*.js`
do
sed -e 's/sharedDispatcher()/getInstance()/g' $i >$i.new
mv $i.new $i
done

# AudioManager
for i in `find . -name \*.js`
do
sed -e 's/AudioManager/AudioEngine/g' $i >$i.new
mv $i.new $i
done

# locationInView() 
for i in `find . -name \*.js`
do
sed -e 's/locationInView()/getLocation()/g' $i >$i.new
mv $i.new $i
done

# previousLocationInView() 
for i in `find . -name \*.js`
do
sed -e 's/previousLocationInView()/getPreviousLocation()/g' $i >$i.new
mv $i.new $i
done


# Sprite.createWithSpriteFrameName
for i in `find . -name \*.js`
do
sed -e 's/Sprite\.createWithSpriteFrame(/Sprite\.createWithSpriteFrameName(/g' $i >$i.new
mv $i.new $i
done

# cc.CC -> cc.
for i in `find . -name \*.js`
do
sed -e 's/cc\.CC/cc\./g' $i >$i.new
mv $i.new $i
done

# cc.cc -> cc.
for i in `find . -name \*.js`
do
sed -e 's/cc\.cc/cc\./g' $i >$i.new
mv $i.new $i
done

# ccTouches... -> onTouches
for i in `find . -name \*.js`
do
sed -e 's/ccTouches/onTouches/g' $i >$i.new
mv $i.new $i
done

# ccTouch... -> onTouch
for i in `find . -name \*.js`
do
sed -e 's/ccTouch/onTouch/g' $i >$i.new
mv $i.new $i
done


# SpriteFrameCache: addSpriteFramesWithFile -> addSpriteFrames
for i in `find . -name \*.js`
do
sed -e 's/addSpriteFramesWithFile/addSpriteFrames/g' $i >$i.new
mv $i.new $i
done

## Point: cc.PointMake -> cc.p
#for i in `find . -name \*.js`
#do
#sed -e 's/cc\.PointMake/cc\.p/g' $i >$i.new
#mv $i.new $i
#done

## Point: new cc.Point -> cc.p
#for i in `find . -name \*.js`
#do
#sed -e 's/new cc\.Point(/cc\.p(/g' $i >$i.new
#mv $i.new $i
#done


# Ouch: Sprite.createWithSpriteFrameNameNameNameNameNameNameNameNameName
for i in `find . -name \*.js`
do
sed -e 's/Sprite.createWithSpriteFrameNameNameNameNameNameNameNameNameName/Sprite.createWithSpriteFrameName/g' $i >$i.new
mv $i.new $i
done
