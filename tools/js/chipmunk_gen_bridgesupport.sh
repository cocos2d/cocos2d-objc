gen_bridge_metadata -F complete --no-64-bit -c '-DCP_ALLOW_PRIVATE_ACCESS=0 -DNDEBUG -I. -Iconstraints/.' *.h constraints/*.h -o ../../../../tools/js/chipmunk.bridgesupport
