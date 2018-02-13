// https://consensys.github.io/smart-contract-best-practices/known_attacks/#integer-overflow-and-underflow
pragma solidity ^0.4.18;

contract BankBook {
  mapping (address => uint) public initialBalances;
  mapping (address => uint[]) public remains;
  mapping (address => uint8) public lastIndex;

  function() public payable {
    deposit();
  }

  function deposit() public payable {
    require(initialBalances[msg.sender] == 0);
    uint[] storage senderRemains = remains[msg.sender];

    initialBalances[msg.sender] = msg.value;
    senderRemains.length++;
    senderRemains[0] = msg.value;
  }

  function withdraw(uint _amount) public {
    uint index = uint(lastIndex[msg.sender]);
    uint[] storage senderRemains = remains[msg.sender];

    require(senderRemains[index] >= _amount);

    senderRemains.length++;
    senderRemains[index + 1] = senderRemains[index] - _amount;
    lastIndex[msg.sender] = uint8(index + 1);

    msg.sender.transfer(_amount);
  }

  function withdraw() public {
    withdraw(getRemainBalance()); // withdraw all remains
  }

  function getRemainBalance() public view returns (uint) {
    return getRemainBalance(msg.sender);
  }

  function getRemainBalance(address _addr) public view returns (uint) {
    return remains[_addr][lastIndex[_addr]];
  }
}
