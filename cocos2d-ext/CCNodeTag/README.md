CCNodeTag
=========

Type of class  : Category to CCNode  
Uses extension : [None]

Adds tags to CCNode.

While the official replacement for tag in CCNode, is NSString *name, there are rare cases, where tag is useful. To use tags for CCNode, simply include this category into your project.

Usage:

- Add #include "CCNodeTag.h" in your .h or .m file
- Create a CCNode and add a tag property :

CCNode *node = [[CCNode alloc] init];
node.tag = 1000;