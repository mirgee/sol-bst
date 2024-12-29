const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("RedBlackTree", (m) => {
  const bst = m.contract("RedBlackTree");
  return { bst };
});
