#!/bin/sh

# issue #
for i in `find . -name \*.m`
do
sed -e 's/drawPoint(/drawPointDeprecated(/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.m`
do
sed -e 's/drawLine(/drawLineDeprecated(/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.m`
do
sed -e 's/drawPoly(/drawPolyDeprecated(/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.m`
do
sed -e 's/drawCircle(/drawCircleDeprecated(/g' $i >$i.new
mv $i.new $i
done
