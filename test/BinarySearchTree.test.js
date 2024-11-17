const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BinarySearchTree", function () {
  let BinarySearchTree, bst;

  beforeEach(async function () {
    BinarySearchTree = await ethers.getContractFactory("BinarySearchTree");
    bst = await BinarySearchTree.deploy();
    await bst.deployed();
  });

  it("should initialize with size 0", async function () {
    expect(await bst.size()).to.equal(0);
  });

  it("should insert elements and update size", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    expect(await bst.size()).to.equal(3);
  });

  it("should maintain BST order", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    // Peek should return the smallest value
    expect(await bst.peek()).to.equal(5);
  });

  it("should pop the smallest element", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    // Pop the smallest element (5)
    const smallest = await bst.pop();
    expect(smallest).to.equal(5);

    // Verify size
    expect(await bst.size()).to.equal(2);

    // Peek now returns the next smallest element
    expect(await bst.peek()).to.equal(10);
  });

  it("should remove a specific element", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    // Remove a specific element
    await bst.remove(10);

    // Verify size
    expect(await bst.size()).to.equal(2);

    // Verify element no longer exists
    expect(await bst.exists(10)).to.equal(false);
    expect(await bst.exists(5)).to.equal(true);
    expect(await bst.exists(15)).to.equal(true);
  });

  it("should remove all occurrences of a specific value", async function () {
    await bst.insert(10);
    await bst.insert(10);
    await bst.insert(15);

    // Remove all occurrences of 10
    await bst.removeAll(10);

    // Verify size
    expect(await bst.size()).to.equal(1);

    // Verify 10 is completely removed
    expect(await bst.exists(10)).to.equal(false);
    expect(await bst.exists(15)).to.equal(true);
  });

  it("should handle duplicate values gracefully", async function () {
    await bst.insert(10);
    await bst.insert(10);
    await bst.insert(10);

    // Size should increase for each insertion
    expect(await bst.size()).to.equal(3);

    // Remove all duplicates
    await bst.removeAll(10);

    expect(await bst.size()).to.equal(0);
    expect(await bst.exists(10)).to.equal(false);
  });

  it("should throw an error when peeking or popping an empty tree", async function () {
    await expect(bst.peek()).to.be.revertedWith("Tree is empty");
    await expect(bst.pop()).to.be.revertedWith("Tree is empty");
  });

  it("should verify existence of elements", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    expect(await bst.exists(10)).to.equal(true);
    expect(await bst.exists(5)).to.equal(true);
    expect(await bst.exists(15)).to.equal(true);
    expect(await bst.exists(20)).to.equal(false);
  });
});
