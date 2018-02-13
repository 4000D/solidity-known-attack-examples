const InsecureAuction = artifacts.require("./InsecureAuction.sol");

module.exports = function (deployer) {
  deployer.deploy(InsecureAuction);
};
