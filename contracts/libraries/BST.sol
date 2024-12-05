// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library BST {
    uint256 constant NULL_NODE = type(uint256).max;

    struct Node {
        uint256 value;
        uint256 left;
        uint256 right;
    }

    struct Tree {
        mapping(uint256 => Node) nodes;
        uint256 root;
        uint256 size;
        uint256 counter;
    }

    function init(Tree storage tree) internal {
        tree.root = NULL_NODE;
    }

    function insert(
        Tree storage tree,
        uint256 value,
        function(uint256, uint256) view returns (bool) comparator
    ) internal {
        uint256 nodeId = tree.counter++;
        if (tree.root == NULL_NODE) {
            tree.root = nodeId;
            tree.nodes[nodeId] = Node(value, NULL_NODE, NULL_NODE);
            tree.size++;
            return;
        }

        uint256 current = tree.root;
        while (true) {
            Node storage currentNode = tree.nodes[current];
            if (value == currentNode.value) {
                return;
            }
            if (comparator(value, currentNode.value)) {
                if (currentNode.left == NULL_NODE) {
                    currentNode.left = nodeId;
                    tree.nodes[nodeId] = Node(value, NULL_NODE, NULL_NODE);
                    tree.size++;
                    return;
                }
                current = currentNode.left;
            } else {
                if (currentNode.right == NULL_NODE) {
                    currentNode.right = nodeId;
                    tree.nodes[nodeId] = Node(value, NULL_NODE, NULL_NODE);
                    tree.size++;
                    return;
                }
                current = currentNode.right;
            }
        }
    }

    function peek(Tree storage tree) internal view returns (uint256) {
        require(tree.root != NULL_NODE, "Tree is empty");
        uint256 minId = _findMin(tree, tree.root);
        return tree.nodes[minId].value;
    }

    function pop(
        Tree storage tree,
        function(uint256, uint256) view returns (bool) comparator
    ) internal returns (uint256) {
        require(tree.root != NULL_NODE, "Tree is empty");
        uint256 minId = _findMin(tree, tree.root);
        uint256 minValue = tree.nodes[minId].value;
        remove(tree, minValue, comparator);
        return minValue;
    }

    function remove(
        Tree storage tree,
        uint256 value,
        function(uint256, uint256) view returns (bool) comparator
    ) internal {
        tree.root = _remove(tree, tree.root, value, comparator);
    }

    function exists(
        Tree storage tree,
        uint256 value,
        function(uint256, uint256) view returns (bool) comparator
    ) internal view returns (bool) {
        uint256 current = tree.root;
        while (current != NULL_NODE) {
            Node storage currentNode = tree.nodes[current];
            if (currentNode.value == value) {
                return true;
            } else if (comparator(value, currentNode.value)) {
                current = currentNode.left;
            } else {
                current = currentNode.right;
            }
        }
        return false;
    }

    function _remove(
        Tree storage tree,
        uint256 current,
        uint256 value,
        function(uint256, uint256) view returns (bool) comparator
    ) internal returns (uint256) {
        if (current == NULL_NODE) return NULL_NODE;

        Node storage currentNode = tree.nodes[current];
        if (value == currentNode.value) {
            if (
                currentNode.left == NULL_NODE && currentNode.right == NULL_NODE
            ) {
                delete tree.nodes[current];
                tree.size--;
                return NULL_NODE;
            }
            if (currentNode.left == NULL_NODE) {
                uint256 right = currentNode.right;
                delete tree.nodes[current];
                tree.size--;
                return right;
            }
            if (currentNode.right == NULL_NODE) {
                uint256 left = currentNode.left;
                delete tree.nodes[current];
                tree.size--;
                return left;
            }
            uint256 successor = _findMin(tree, currentNode.right);
            Node storage successorNode = tree.nodes[successor];
            currentNode.value = successorNode.value;
            currentNode.right = _remove(
                tree,
                currentNode.right,
                successorNode.value,
                comparator
            );
        } else if (comparator(value, currentNode.value)) {
            currentNode.left = _remove(
                tree,
                currentNode.left,
                value,
                comparator
            );
        } else {
            currentNode.right = _remove(
                tree,
                currentNode.right,
                value,
                comparator
            );
        }

        return current;
    }

    function _findMin(
        Tree storage tree,
        uint256 current
    ) internal view returns (uint256) {
        while (current != NULL_NODE) {
            Node storage currentNode = tree.nodes[current];
            if (currentNode.left == NULL_NODE) {
                return current;
            }
            current = currentNode.left;
        }
        return NULL_NODE;
    }
}
