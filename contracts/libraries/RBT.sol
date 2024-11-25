// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library RBT {
    uint256 constant NULL_NODE = type(uint256).max;

    struct Node {
        uint256 value;
        uint256 left;
        uint256 right;
        uint256 parent;
        bool red;
    }

    struct Tree {
        mapping(uint256 => Node) nodes;
        uint256 root;
        uint256 size;
        uint256 counter;
        function(uint256, uint256) view returns (bool) comparator;
    }

    function insert(Tree storage tree, uint256 value) internal {
        uint256 nodeId = tree.counter++;
        Node memory newNode = Node({
            value: value,
            left: NULL_NODE,
            right: NULL_NODE,
            parent: NULL_NODE,
            red: true
        });

        if (tree.root == NULL_NODE) {
            tree.root = nodeId;
            newNode.red = false;
            tree.nodes[nodeId] = newNode;
            tree.size++;
            return;
        }

        uint256 current = tree.root;

        while (true) {
            Node storage currentNode = tree.nodes[current];
            if (value == currentNode.value) {
                return;
            }
            if (tree.comparator(value, currentNode.value)) {
                if (currentNode.left == NULL_NODE) {
                    currentNode.left = nodeId;
                    newNode.parent = current;
                    break;
                }
                current = currentNode.left;
            } else {
                if (currentNode.right == NULL_NODE) {
                    currentNode.right = nodeId;
                    break;
                }
                current = currentNode.right;
            }
        }

        tree.nodes[nodeId] = newNode;
        tree.size++;

        _fixRedRed(tree, nodeId);
    }

    function _fixRedRed(Tree storage tree, uint256 nodeId) internal {
        uint256 parentId = tree.nodes[nodeId].parent;
        if (!tree.nodes[parentId].red) {
            return;
        }

        uint256 grandParentId = tree.nodes[parentId].parent;
        uint256 uncleId = _getUncle(tree, nodeId);

        if (uncleId != NULL_NODE && tree.nodes[uncleId].red) {
            // Change the color of P and U to black
            tree.nodes[tree.nodes[nodeId].parent].red = false;
            tree.nodes[uncleId].red = false;
            if (grandParentId != NULL_NODE) {
                // Change the color of G to red
                tree.nodes[grandParentId].red = true;
                // Make G the new current node and repeat
                _fixRedRed(tree, grandParentId);
            }
        } else {
            if (tree.root == parentId) {
                tree.nodes[parentId].red = false;
            }
            // TODO: Implement rotations
        }
    }

    function _getUncle(
        Tree storage tree,
        uint256 nodeId
    ) internal view returns (uint256) {
        uint256 parentId = tree.nodes[nodeId].parent;
        uint256 grandParentId = tree.nodes[parentId].parent;

        if (grandParentId == NULL_NODE) {
            return NULL_NODE;
        }

        if (tree.nodes[grandParentId].left == parentId) {
            return tree.nodes[grandParentId].right;
        } else {
            return tree.nodes[grandParentId].left;
        }
    }
}
