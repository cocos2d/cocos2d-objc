#!/bin/sh

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpFloat/CGFloat/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpVect/CGPoint/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpv(/CGPointMake(/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpvmult/CGPointMult/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpvadd/CGPointAdd/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpvsub/CGPointSub/g' $i >$i.new
mv $i.new $i
done

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/cpvzero/CGPointZero/g' $i >$i.new
mv $i.new $i
done
