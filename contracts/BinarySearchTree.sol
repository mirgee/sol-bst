// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./libraries/BST.sol";

contract BinarySearchTree {
    using BST for BST.Tree;
    BST.Tree private tree;

    event Popped(uint256 value);

    constructor() {
        tree.init(defaultComparator);
    }

    function defaultComparator(
        uint256 a,
        uint256 b
    ) public pure returns (bool) {
        return a < b;
    }

    function insert(uint256 value) public {
        tree.insert(value);
    }

    function peek() public view returns (uint256) {
        return tree.peek();
    }

    function root() public view returns (uint256) {
      return tree.root;
    }

    function pop() public returns (uint256) {
        uint256 popped = tree.pop();
        emit Popped(popped);
        return popped;
    }

    function remove(uint256 value) public {
        tree.remove(value);
    }

    function exists(uint256 value) public view returns (bool) {
        return tree.exists(value);
    }

    function size() public view returns (uint256) {
        return tree.size;
    }
}
