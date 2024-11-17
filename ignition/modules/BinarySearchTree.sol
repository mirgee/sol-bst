const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("BSTModule", (m) => {
  const bst = m.contract("BinarySearchTree");
  return { bst };
});
