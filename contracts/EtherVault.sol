// https://consensys.github.io/smart-contract-best-practices/known_attacks/#reentrancy
pragma solidity ^0.4.18;

contract EtherVault {
  mapping (address => uint) public deposits;

  function() payable {
    deposit();
  }

  function deposit() payable {
    deposits[msg.sender] = deposits[msg.sender] + msg.value;
  }

  function withdraw() {
    require(deposits[msg.sender] > 0);

    uint amount = deposits[msg.sender];

    require(msg.sender.call.value(amount)());
    deposits[msg.sender] = 0;
  }
}
