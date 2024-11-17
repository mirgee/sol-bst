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
        function(uint256, uint256) view returns (bool) comparator; // Custom comparator
    }

    function init(
        Tree storage tree,
        function(uint256, uint256) view returns (bool) _comparator
    ) internal {
        tree.comparator = _comparator;
        tree.root = NULL_NODE; // Initialize with sentinel value
    }

    function insert(Tree storage tree, uint256 value) internal {
        if (tree.root == NULL_NODE) {
            tree.root = value;
            tree.nodes[value] = Node(value, NULL_NODE, NULL_NODE);
            tree.size++;
            return;
        }

        uint256 current = tree.root;
        while (true) {
            if (tree.comparator(value, current)) {
                if (tree.nodes[current].left == NULL_NODE) {
                    tree.nodes[current].left = value;
                    tree.nodes[value] = Node(value, NULL_NODE, NULL_NODE);
                    tree.size++;
                    return;
                }
                current = tree.nodes[current].left;
            } else {
                if (tree.nodes[current].right == NULL_NODE) {
                    tree.nodes[current].right = value;
                    tree.nodes[value] = Node(value, NULL_NODE, NULL_NODE);
                    tree.size++;
                    return;
                }
                current = tree.nodes[current].right;
            }
        }
    }

    function peek(Tree storage tree) internal view returns (uint256) {
        require(tree.root != NULL_NODE, "Tree is empty");
        uint256 current = tree.root;
        while (tree.nodes[current].left != NULL_NODE) {
            current = tree.nodes[current].left;
        }
        return current;
    }

    function pop(Tree storage tree) internal returns (uint256) {
        require(tree.root != NULL_NODE, "Tree is empty");
        uint256 smallest = peek(tree);
        remove(tree, smallest);
        return smallest;
    }

    function remove(Tree storage tree, uint256 value) internal {
        tree.root = _remove(tree, tree.root, value);
    }

    function removeAll(Tree storage tree, uint256 value) internal {
        while (exists(tree, value)) {
            remove(tree, value);
        }
    }

    function exists(Tree storage tree, uint256 value) internal view returns (bool) {
        uint256 current = tree.root;
        while (current != NULL_NODE) {
            if (current == value) {
                return true;
            } else if (tree.comparator(value, current)) {
                current = tree.nodes[current].left;
            } else {
                current = tree.nodes[current].right;
            }
        }
        return false;
    }

    function _remove(Tree storage tree, uint256 current, uint256 value)
        internal
        returns (uint256)
    {
        if (current == NULL_NODE) return NULL_NODE;

        if (value == current) {
            if (tree.nodes[current].left == NULL_NODE && tree.nodes[current].right == NULL_NODE) {
                delete tree.nodes[current];
                tree.size--;
                return NULL_NODE;
            }
            if (tree.nodes[current].left == NULL_NODE) {
                uint256 right = tree.nodes[current].right;
                delete tree.nodes[current];
                tree.size--;
                return right;
            }
            if (tree.nodes[current].right == NULL_NODE) {
                uint256 left = tree.nodes[current].left;
                delete tree.nodes[current];
                tree.size--;
                return left;
            }

            uint256 successor = _findMin(tree, tree.nodes[current].right);
            tree.nodes[current].value = successor;
            tree.nodes[current].right = _remove(
                tree,
                tree.nodes[current].right,
                successor
            );
        } else if (tree.comparator(value, current)) {
            tree.nodes[current].left = _remove(tree, tree.nodes[current].left, value);
        } else {
            tree.nodes[current].right = _remove(
                tree,
                tree.nodes[current].right,
                value
            );
        }

        return current;
    }

    function _findMin(Tree storage tree, uint256 current)
        internal
        view
        returns (uint256)
    {
        while (tree.nodes[current].left != NULL_NODE) {
            current = tree.nodes[current].left;
        }
        return current;
    }
}

contract BinarySearchTree {
    using BST for BST.Tree;
    BST.Tree private tree;

    constructor() {
        tree.init(defaultComparator);
    }

    function defaultComparator(uint256 a, uint256 b)
        public
        pure
        returns (bool)
    {
        return a < b;
    }

    function insert(uint256 value) public {
        tree.insert(value);
    }

    function peek() public view returns (uint256) {
        return tree.peek();
    }

    function pop() public returns (uint256) {
        return tree.pop();
    }

    function remove(uint256 value) public {
        tree.remove(value);
    }

    function removeAll(uint256 value) public {
        tree.removeAll(value);
    }

    function exists(uint256 value) public view returns (bool) {
        return tree.exists(value);
    }

    function size() public view returns (uint256) {
        return tree.size;
    }
}
