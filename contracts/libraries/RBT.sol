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

    function init(
        Tree storage tree,
        function(uint256, uint256) view returns (bool) _comparator
    ) internal {
        tree.counter = 0;
        tree.size = 0;
        tree.comparator = _comparator;
        tree.root = NULL_NODE;
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

    // TODO: Maintain top for O(1) complexity
    function peek(Tree storage tree) internal view returns (uint256) {
        require(tree.root != NULL_NODE, "Tree is empty");
        uint256 current = tree.root;
        while (tree.nodes[current].left != NULL_NODE) {
            current = tree.nodes[current].left;
        }
        return tree.nodes[current].value;
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

            if (tree.nodes[grandParentId].left == parentId) {
                if (tree.nodes[parentId].left == nodeId) {
                    _rotateRight(tree, grandParentId);
                } else {
                    _rotateLeft(tree, parentId);
                    _rotateRight(tree, grandParentId);
                }
            } else {
                if (tree.nodes[parentId].right == nodeId) {
                    _rotateLeft(tree, grandParentId);
                } else {
                    _rotateRight(tree, parentId);
                    _rotateLeft(tree, grandParentId);
                }
            }

            tree.nodes[parentId].red = false;
            tree.nodes[grandParentId].red = true;
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

    function _rotateLeft(Tree storage tree, uint256 nodeId) internal {
        uint256 rightChildId = tree.nodes[nodeId].right;
        uint256 parentId = tree.nodes[nodeId].parent;

        tree.nodes[nodeId].right = tree.nodes[rightChildId].left;
        if (tree.nodes[rightChildId].left != NULL_NODE) {
            tree.nodes[tree.nodes[rightChildId].left].parent = nodeId;
        }

        tree.nodes[rightChildId].parent = parentId;
        if (parentId == NULL_NODE) {
            tree.root = rightChildId;
        } else if (tree.nodes[parentId].left == nodeId) {
            tree.nodes[parentId].left = rightChildId;
        } else {
            tree.nodes[parentId].right = rightChildId;
        }

        tree.nodes[rightChildId].left = nodeId;
        tree.nodes[nodeId].parent = rightChildId;
    }

    function _rotateRight(Tree storage tree, uint256 nodeId) internal {
        uint256 leftChildId = tree.nodes[nodeId].left;
        uint256 parentId = tree.nodes[nodeId].parent;

        tree.nodes[nodeId].left = tree.nodes[leftChildId].right;
        if (tree.nodes[leftChildId].right != NULL_NODE) {
            tree.nodes[tree.nodes[leftChildId].right].parent = nodeId;
        }

        tree.nodes[leftChildId].parent = parentId;
        if (parentId == NULL_NODE) {
            tree.root = leftChildId;
        } else if (tree.nodes[parentId].left == nodeId) {
            tree.nodes[parentId].left = leftChildId;
        } else {
            tree.nodes[parentId].right = leftChildId;
        }

        tree.nodes[leftChildId].right = nodeId;
        tree.nodes[nodeId].parent = leftChildId;
    }
}
