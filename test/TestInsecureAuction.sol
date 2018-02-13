pragma solidity ^0.4.18;

import "../contracts/InsecureAuction.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract TestInsecureAuction {
  uint public initialBalance = 100 ether;
  uint public fallCnt;

  function () payable {
    require(false); // direct throw
  }

  function testBid1() {
    InsecureAuction a = InsecureAuction(DeployedAddresses.InsecureAuction());

    require(address(a).call.value(2 ether)(bytes4(sha3("bid()"))));
    require(address(a).call.value(3 ether)(bytes4(sha3("bid()"))) == false);

    Assert.equal(address(a).balance, 2 ether, "auction has only 2 ethers");
  }
}
