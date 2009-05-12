#!/bin/sh

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/ccRGBB/ccColor3B/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/ccColorB/ccColor4B/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/ccColorF/ccColor4F/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/ccVertex3D/ccVertex3F/g' $i >$i.new
mv $i.new $i
done
