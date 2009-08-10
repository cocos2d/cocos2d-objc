/*
* Copyright (c) 2009 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#include "b2DynamicTree.h"

#include <string.h>
#include <float.h>

b2DynamicTree::b2DynamicTree()
{
	m_root = b2_nullNode;
	m_nodeCount = b2Max(b2_nodePoolSize, 1);
	m_nodes = (b2DynamicTreeNode*)b2Alloc(m_nodeCount * sizeof(b2DynamicTreeNode));
	memset(m_nodes, 0, m_nodeCount * sizeof(b2DynamicTreeNode));

	// Build a linked list for the free list. The parent
	// pointer becomes the "next" pointer.
	for (int32 i = 0; i < m_nodeCount - 1; ++i)
	{
		m_nodes[i].parent = uint16(i + 1);
	}
	m_nodes[m_nodeCount-1].parent = b2_nullNode;
	m_freeList = 0;

	m_path = 0;
}

b2DynamicTree::~b2DynamicTree()
{
	// This frees the entire tree in one shot.
	b2Free(m_nodes);
}

// Allocate a node from the pool. Grow the pool if necessary.
uint16 b2DynamicTree::AllocateNode()
{
	// Peel a node off the free list.
	if (m_freeList != b2_nullNode)
	{
		uint16 node = m_freeList;
		m_freeList = m_nodes[node].parent;
		m_nodes[node].parent = b2_nullNode;
		m_nodes[node].child1 = b2_nullNode;
		m_nodes[node].child2 = b2_nullNode;
		return node;
	}

	// The free list is empty. Rebuild a bigger pool.
	int32 newPoolCount = b2Min(2 * m_nodeCount, USHRT_MAX - 1);
	b2Assert(newPoolCount > m_nodeCount);
	b2DynamicTreeNode* newPool = (b2DynamicTreeNode*)b2Alloc(newPoolCount * sizeof(b2DynamicTreeNode));
	memcpy(newPool, m_nodes, m_nodeCount * sizeof(b2DynamicTreeNode));
	memset(newPool + m_nodeCount, 0, (newPoolCount - m_nodeCount) * sizeof(b2DynamicTreeNode));

	// Build a linked list for the free list. The parent
	// pointer becomes the "next" pointer.
	for (int32 i = m_nodeCount; i < newPoolCount - 1; ++i)
	{
		newPool[i].parent = uint16(i + 1);
	}
	newPool[newPoolCount-1].parent = b2_nullNode;
	m_freeList = uint16(m_nodeCount);

	b2Free(m_nodes);
	m_nodes = newPool;
	m_nodeCount = newPoolCount;

	// Finally peel a node off the new free list.
	uint16 node = m_freeList;
	m_freeList = m_nodes[node].parent;
	return node;
}

// Return a node to the pool.
void b2DynamicTree::FreeNode(uint16 node)
{
	b2Assert(node < USHRT_MAX);
	m_nodes[node].parent = m_freeList;
	m_freeList = node;
}

// Create a proxy in the tree as a leaf node. We return the index
// of the node instead of a pointer so that we can grow
// the node pool.
uint16 b2DynamicTree::CreateProxy(const b2AABB& aabb, void* userData)
{
	uint16 node = AllocateNode();

	// Fatten the aabb.
	b2Vec2 center = aabb.GetCenter();
	b2Vec2 extents = b2_fatAABBFactor * aabb.GetExtents();
	m_nodes[node].aabb.lowerBound = center - extents;
	m_nodes[node].aabb.upperBound = center + extents;
	m_nodes[node].userData = userData;

	InsertLeaf(node);

	return node;
}

void b2DynamicTree::DestroyProxy(uint16 proxyId)
{
	b2Assert(proxyId < m_nodeCount);
	b2Assert(m_nodes[proxyId].IsLeaf());

	RemoveLeaf(proxyId);
	FreeNode(proxyId);
}

void b2DynamicTree::MoveProxy(uint16 proxyId, const b2AABB& aabb)
{
	b2Assert(proxyId < m_nodeCount);

	b2Assert(m_nodes[proxyId].IsLeaf());

	if (m_nodes[proxyId].aabb.Contains(aabb))
	{
		return;
	}

	RemoveLeaf(proxyId);

	b2Vec2 center = aabb.GetCenter();
	b2Vec2 extents = b2_fatAABBFactor * aabb.GetExtents();

	m_nodes[proxyId].aabb.lowerBound = center - extents;
	m_nodes[proxyId].aabb.upperBound = center + extents;

	InsertLeaf(proxyId);
}

void* b2DynamicTree::GetProxy(uint16 proxyId)
{
	if (proxyId < m_nodeCount)
	{
		return m_nodes[proxyId].userData;
	}
	else
	{
		return NULL;
	}
}

void b2DynamicTree::InsertLeaf(uint16 leaf)
{
	if (m_root == b2_nullNode)
	{
		m_root = leaf;
		m_nodes[m_root].parent = b2_nullNode;
		return;
	}

	// Find the best sibling for this node.
	b2Vec2 center = m_nodes[leaf].aabb.GetCenter();
	uint16 sibling = m_root;
	if (m_nodes[sibling].IsLeaf() == false)
	{
		do 
		{
			uint16 child1 = m_nodes[sibling].child1;
			uint16 child2 = m_nodes[sibling].child2;

			b2Vec2 delta1 = b2Abs(m_nodes[child1].aabb.GetCenter() - center);
			b2Vec2 delta2 = b2Abs(m_nodes[child2].aabb.GetCenter() - center);

			float32 norm1 = delta1.x + delta1.y;
			float32 norm2 = delta2.x + delta2.y;

			if (norm1 < norm2)
			{
				sibling = child1;
			}
			else
			{
				sibling = child2;
			}

		}
		while(m_nodes[sibling].IsLeaf() == false);
	}

	// Create a parent for the siblings.
	uint16 node1 = m_nodes[sibling].parent;
	uint16 node2 = AllocateNode();
	m_nodes[node2].parent = node1;
	m_nodes[node2].userData = NULL;
	m_nodes[node2].aabb.Combine(m_nodes[leaf].aabb, m_nodes[sibling].aabb);

	if (node1 != b2_nullNode)
	{
		if (m_nodes[m_nodes[sibling].parent].child1 == sibling)
		{
			m_nodes[node1].child1 = node2;
		}
		else
		{
			m_nodes[node1].child2 = node2;
		}

		m_nodes[node2].child1 = sibling;
		m_nodes[node2].child2 = leaf;
		m_nodes[sibling].parent = node2;
		m_nodes[leaf].parent = node2;

		do 
		{
			if (m_nodes[node1].aabb.Contains(m_nodes[node2].aabb))
			{
				break;
			}

			m_nodes[node1].aabb.Combine(m_nodes[m_nodes[node1].child1].aabb, m_nodes[m_nodes[node1].child2].aabb);
			node2 = node1;
			node1 = m_nodes[node1].parent;
		}
		while(node1 != b2_nullNode);
	}
	else
	{
		m_nodes[node2].child1 = sibling;
		m_nodes[node2].child2 = leaf;
		m_nodes[sibling].parent = node2;
		m_nodes[leaf].parent = node2;
		m_root = node2;
	}
}

void b2DynamicTree::RemoveLeaf(uint16 leaf)
{
	if (leaf == m_root)
	{
		m_root = b2_nullNode;
		return;
	}

	uint16 node2 = m_nodes[leaf].parent;
	uint16 node1 = m_nodes[node2].parent;
	uint16 sibling;
	if (m_nodes[node2].child1 == leaf)
	{
		sibling = m_nodes[node2].child2;
	}
	else
	{
		sibling = m_nodes[node2].child1;
	}

	if (node1 != b2_nullNode)
	{
		// Destroy node2 and connect node1 to sibling.
		if (m_nodes[node1].child1 == node2)
		{
			m_nodes[node1].child1 = sibling;
		}
		else
		{
			m_nodes[node1].child2 = sibling;
		}
		m_nodes[sibling].parent = node1;
		FreeNode(node2);

		// Adjust ancestor bounds.
		while (node1 != b2_nullNode)
		{
			b2AABB oldAABB = m_nodes[node1].aabb;
			m_nodes[node1].aabb.Combine(m_nodes[m_nodes[node1].child1].aabb, m_nodes[m_nodes[node1].child2].aabb);

			if (oldAABB.Contains(m_nodes[node1].aabb))
			{
				break;
			}

			node1 = m_nodes[node1].parent;
		}
	}
	else
	{
		m_root = sibling;
		m_nodes[sibling].parent = b2_nullNode;
		FreeNode(node2);
	}
}

void b2DynamicTree::Rebalance(int32 iterations)
{
	if (m_root == b2_nullNode)
	{
		return;
	}

	for (int32 i = 0; i < iterations; ++i)
	{
		uint16 node = m_root;

		uint32 bit = 0;
		while (m_nodes[node].IsLeaf() == false)
		{
			uint16* children = &m_nodes[node].child1;
			node = children[(m_path >> bit) & 1];
			bit = (bit + 1) & (8* sizeof(uint32) - 1);
		}
		++m_path;

		RemoveLeaf(node);
		InsertLeaf(node);
	}
}
