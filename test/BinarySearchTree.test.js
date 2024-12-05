const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BinarySearchTree", function () {
  let BinarySearchTree, bst;

  beforeEach(async function () {
    BinarySearchTree = await ethers.getContractFactory("BinarySearchTree");
    bst = await BinarySearchTree.deploy();
  });

  it("maintain BST order", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    expect(await bst.peek()).to.equal(5);
  });

  it("pop the smallest element", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    const smallest = await (await bst.pop()).wait();
    expect(
      smallest.logs.find((e) => e?.fragment?.name === "Popped").args.value
    ).to.equal(5);

    expect(await bst.size()).to.equal(2);
    expect(await bst.peek()).to.equal(10);
  });

  it("remove the root", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    await (await bst.remove(10)).wait();

    expect(await bst.size()).to.equal(2);
    expect(await bst.exists(10)).to.equal(false);
    expect(await bst.exists(5)).to.equal(true);
    expect(await bst.exists(15)).to.equal(true);
  });

  it("remove a leaf", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    await (await bst.remove(5)).wait();

    expect(await bst.size()).to.equal(2);
    expect(await bst.exists(10)).to.equal(true);
    expect(await bst.exists(5)).to.equal(false);
    expect(await bst.exists(15)).to.equal(true);
  });

  it("remove a node with two children", async function () {
    await bst.insert(20);
    await bst.insert(10);
    await bst.insert(30);
    await bst.insert(5);
    await bst.insert(15);
    await bst.insert(25);
    await bst.insert(35);

    await (await bst.remove(20)).wait();

    expect(await bst.size()).to.equal(6);
    expect(await bst.exists(20)).to.equal(false);
    expect(await bst.peek()).to.equal(5);
  });

  it("remove a node with one child", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(7);

    await (await bst.remove(5)).wait();

    expect(await bst.size()).to.equal(2);
    expect(await bst.exists(5)).to.equal(false);
    expect(await bst.exists(7)).to.equal(true);
    expect(await bst.peek()).to.equal(7);
  });

  it("insert and remove multiple elements", async function () {
    const elements = [50, 30, 70, 20, 40, 60, 80];

    for (const value of elements) {
      await bst.insert(value);
    }

    expect(await bst.size()).to.equal(elements.length);

    await bst.remove(20);
    await bst.remove(70);

    expect(await bst.size()).to.equal(elements.length - 2);
    expect(await bst.exists(20)).to.equal(false);
    expect(await bst.exists(70)).to.equal(false);
    expect(await bst.exists(50)).to.equal(true);
    expect(await bst.exists(30)).to.equal(true);
  });

  it("attempt to remove non-existent element", async function () {
    await bst.insert(10);
    await bst.insert(20);

    await (await bst.remove(30)).wait();

    expect(await bst.size()).to.equal(2);
    expect(await bst.exists(10)).to.equal(true);
    expect(await bst.exists(20)).to.equal(true);
  });

  it("accurate size maintained after each operation", async function () {
    await bst.insert(10);
    expect(await bst.size()).to.equal(1);
    await bst.insert(20);
    expect(await bst.size()).to.equal(2);
    await bst.insert(10);
    expect(await bst.size()).to.equal(2);
    await bst.remove(10);
    expect(await bst.size()).to.equal(1);
    await bst.remove(10);
    expect(await bst.size()).to.equal(1);
    await bst.remove(20);
    expect(await bst.size()).to.equal(0);
  });

  it("handle duplicate values gracefully", async function () {
    await bst.insert(10);
    await bst.insert(10);
    await bst.insert(10);

    expect(await bst.size()).to.equal(1);

    await bst.remove(10);

    expect(await bst.size()).to.equal(0);
    expect(await bst.exists(10)).to.equal(false);
  });

  it("throw an error when peeking or popping an empty tree", async function () {
    await expect(bst.peek()).to.be.revertedWith("Tree is empty");
    await expect(bst.pop()).to.be.revertedWith("Tree is empty");
  });

  it("check existence of elements", async function () {
    await bst.insert(10);
    await bst.insert(5);
    await bst.insert(15);

    expect(await bst.exists(10)).to.equal(true);
    expect(await bst.exists(5)).to.equal(true);
    expect(await bst.exists(15)).to.equal(true);
    expect(await bst.exists(20)).to.equal(false);
  });

  it("list all elements in sorted order", async function () {
    const elements = [50, 30, 70, 20, 40, 60, 80];

    for (const value of elements) {
      await bst.insert(value);
    }

    const list = await bst.list();
    const listValues = list.map((bn) => Number(bn));
    const expectedList = [...elements].sort((a, b) => a - b);

    expect(listValues).to.deep.equal(expectedList);
  });
});
