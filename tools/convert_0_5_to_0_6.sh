#!/bin/sh

# issue #
for i in `find . -name \*.[hm]`
do
sed -e 's/(void)touches/(BOOL)ccTouches/g' $i >$i.new
mv $i.new $i
done


# issue 
for i in `find . -name \*.[hm]`
do
sed -e 's/removeAll]/removeAndStopAll]/g' $i >$i.new
mv $i.new $i
done
