const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("BinarySearchTree", (m) => {
  const bst = m.contract("BinarySearchTree");
  return { bst };
});
